#!/usr/bin/env python3
"""Static safety checks for the Retail LiveStack handoff SQL.

Run before giving the file to LiveLabs Green Button:

    python3 backend-provisioning/scripts/validate_handoff_sql.py

The checks catch known repeatability hazards:
- unresolved or incorrectly guarded password placeholders
- missing ORA-28007 handler for existing LLUSER reruns
- exported INSERTs into generated/virtual columns
- mismatched fixed-row PROMPT counts versus INSERT counts
- random data generator constructs in the handoff file
- missing final repeatability assertion block
"""
from __future__ import annotations

import re
import sys
from collections import Counter, defaultdict
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
DEFAULT_SQL = SCRIPT_DIR.parent / "database-source" / "retail_workshop_admin_create_lab_seed.sql"


def strip_comments(text: str) -> str:
    text = re.sub(r"/\*.*?\*/", "", text, flags=re.S)
    text = re.sub(r"--.*?$", "", text, flags=re.M)
    return text


def split_csv(text: str) -> list[str]:
    out: list[str] = []
    buf: list[str] = []
    depth = 0
    in_string = False
    i = 0
    while i < len(text):
        ch = text[i]
        if ch == "'":
            buf.append(ch)
            if in_string and i + 1 < len(text) and text[i + 1] == "'":
                buf.append("'")
                i += 2
                continue
            in_string = not in_string
        elif not in_string:
            if ch == "(":
                depth += 1
                buf.append(ch)
            elif ch == ")":
                depth = max(0, depth - 1)
                buf.append(ch)
            elif ch == "," and depth == 0:
                out.append("".join(buf).strip())
                buf = []
            else:
                buf.append(ch)
        else:
            buf.append(ch)
        i += 1
    tail = "".join(buf).strip()
    if tail:
        out.append(tail)
    return out


def find_table_blocks(text: str) -> dict[str, str]:
    blocks: dict[str, str] = {}
    pattern = re.compile(r'CREATE\s+TABLE\s+"([^"]+)"\s*\(', re.I)
    for m in pattern.finditer(text):
        table = m.group(1)
        start = m.end() - 1
        depth = 0
        in_string = False
        end = None
        for i in range(start, len(text)):
            ch = text[i]
            if ch == "'":
                if in_string and i + 1 < len(text) and text[i + 1] == "'":
                    continue
                in_string = not in_string
            elif not in_string:
                if ch == "(":
                    depth += 1
                elif ch == ")":
                    depth -= 1
                    if depth == 0:
                        semi = text.find(";", i)
                        end = semi if semi != -1 else i
                        break
        if end is not None:
            blocks[table] = text[start + 1 : end]
    return blocks


def generated_columns(table_block: str) -> set[str]:
    cols: set[str] = set()
    for part in split_csv(table_block):
        m = re.match(r'\s*"([^"]+)"\s+(.*)$', part, flags=re.S)
        if not m:
            continue
        col, rest = m.group(1), m.group(2).upper()
        if " GENERATED ALWAYS AS " in rest or " VIRTUAL" in rest:
            cols.add(col)
    return cols


def main() -> int:
    sql_path = Path(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT_SQL
    text = sql_path.read_text(encoding="utf-8", errors="replace")
    uncommented = strip_comments(text)
    errors: list[str] = []
    warnings: list[str] = []

    if "IF INSTR(q'[${user_password}]', '${') > 0 THEN" not in text:
        errors.append("password placeholder guard must use INSTR(..., '${') so substitution does not self-compare")
    if "SQLCODE = -28007" not in text:
        errors.append("existing-user password reuse handler for ORA-28007 is missing")
    if "PROMPT Running final repeatability assertions" not in text:
        errors.append("final repeatability assertion block is missing")
    elif not re.search(r"PROMPT Running final repeatability assertions\s+DECLARE\s+v_count NUMBER;\s+PROCEDURE", text, flags=re.S):
        errors.append("final assertion block must declare v_count before local procedures for PL/SQL syntax")
    assertion_start = text.find("PROMPT Running final repeatability assertions")
    assertion_end = text.find("PROMPT Final readiness summary", assertion_start) if assertion_start != -1 else -1
    assertion_block = text[assertion_start:assertion_end] if assertion_start != -1 and assertion_end != -1 else ""
    if re.search(r"\bFROM\s+user_(indexes|views|objects|property_graphs|mining_models)\b", assertion_block, flags=re.I):
        errors.append("final assertion block must use ALL_* owner=CURRENT_SCHEMA views because it runs as ADMIN with CURRENT_SCHEMA set to target schema")

    # The header comment mentions banned generators. Check executable text only.
    for pattern in [r"\bDBMS_RANDOM\b", r"\bCONNECT\s+BY\b"]:
        if re.search(pattern, uncommented, flags=re.I):
            errors.append(f"handoff SQL must not contain executable {pattern}")

    table_blocks = find_table_blocks(uncommented)
    generated_by_table = {t: generated_columns(b) for t, b in table_blocks.items()}

    insert_re = re.compile(r'INSERT\s+INTO\s+"([^"]+)"\s*\((.*?)\)\s*VALUES\s*\(', re.I | re.S)
    insert_counts: Counter[str] = Counter()
    for m in insert_re.finditer(uncommented):
        table = m.group(1)
        cols = [c.strip().strip('"').upper() for c in split_csv(m.group(2))]
        insert_counts[table] += 1
        bad = sorted(set(cols) & generated_by_table.get(table, set()))
        if bad:
            errors.append(f"INSERT into generated/virtual column(s) for {table}: {', '.join(bad)}")

    prompt_re = re.compile(r'PROMPT\s+Loading\s+([A-Z0-9_]+):\s+(\d+)\s+(?:fixed rows exported|fixed rows needed)', re.I)
    prompt_counts = {m.group(1).upper(): int(m.group(2)) for m in prompt_re.finditer(text)}
    for table, expected in sorted(prompt_counts.items()):
        actual = insert_counts.get(table, 0)
        if actual != expected:
            errors.append(f"fixed-row count mismatch for {table}: prompt says {expected}, INSERT count is {actual}")
    for table in sorted(set(insert_counts) - set(prompt_counts)):
        warnings.append(f"INSERTs found for {table} but no fixed-row PROMPT count was found")

    print(f"Validated: {sql_path}")
    print(f"Tables with CREATE TABLE blocks: {len(table_blocks)}")
    print(f"Fixed-row table prompts: {len(prompt_counts)}")
    print(f"INSERT statements counted: {sum(insert_counts.values())}")
    if warnings:
        print("Warnings:")
        for warning in warnings:
            print(f"  - {warning}")
    if errors:
        print("Errors:")
        for error in errors:
            print(f"  - {error}")
        return 1
    print("OK: handoff SQL passed static repeatability checks.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
