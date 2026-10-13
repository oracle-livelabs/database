#!/bin/bash
# LiveLabs Markdown Formatting Validator
# Validates markdown files against LiveLabs formatting standards

# Don't exit on first error - we want to check all files
set +e

ERRORS=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

log_error() {
    echo -e "${RED}ERROR${NC}: $1"
    ((ERRORS++))
}

log_success() {
    echo -e "${GREEN}PASS${NC}: $1"
}

# Get markdown files from args, directory, or find all in current directory
if [ $# -gt 0 ]; then
    # Check if first argument is a directory
    if [ -d "$1" ]; then
        TARGET_DIR="$1"
        echo "Scanning directory: $TARGET_DIR"
        echo ""
        FILES=$(find "$TARGET_DIR" -name "*.md" -type f | grep -v node_modules | grep -v .github | sort)
    else
        # Treat arguments as individual files
        FILES="$@"
    fi
else
    FILES=$(find . -name "*.md" -type f | grep -v node_modules | grep -v .github | sort)
fi

# Check if any files were found
if [ -z "$FILES" ]; then
    echo "No markdown files found."
    exit 0
fi

echo "================================================"
echo "LiveLabs Markdown Formatting Validator"
echo "================================================"
echo ""

for file in $FILES; do
    if [ ! -f "$file" ]; then
        continue
    fi

    echo "Checking: $file"
    FILE_ERRORS=0

    # Rule 1: Check for H1 title (must be first non-empty line)
    first_content=$(grep -v '^$' "$file" | head -1)
    if [[ ! "$first_content" =~ ^#[^#] ]]; then
        log_error "$file: First line must be an H1 title (# Title)"
        ((FILE_ERRORS++))
    fi

    # Rule 2: Check for only one H1 per file (excluding code blocks)
    # Use awk to skip content inside fenced code blocks
    # Only match proper fenced code blocks: ``` alone or ```language (not inline code spans)
    h1_count=$(awk '
        /^[[:space:]]*```[[:space:]]*$/ || /^[[:space:]]*```[a-zA-Z]+[[:space:]]*$/ {
            in_code = !in_code
            next
        }
        !in_code && /^# / { count++ }
        END { print count+0 }
    ' "$file")
    if [ "$h1_count" -gt 1 ]; then
        log_error "$file: Multiple H1 headers found ($h1_count). Only one H1 allowed per file."
        ((FILE_ERRORS++))
    fi

    # Rule 3: Check for Acknowledgements section
    if ! grep -q "^## Acknowledgements" "$file"; then
        log_error "$file: Missing '## Acknowledgements' section"
        ((FILE_ERRORS++))
    fi

    # Rule 4: (Removed - no longer checking for Author format in Acknowledgements)

    # Rule 5: Check image references have alt text
    # Pattern: ![](images/...) is invalid, should be ![alt text](images/...)
    if grep -n '!\[\]\s*(' "$file" | grep -v '^[0-9]*:.*!\[\](youtube:' > /dev/null 2>&1; then
        lines=$(grep -n '!\[\]\s*(' "$file" | grep -v '!\[\](youtube:' | cut -d: -f1 | tr '\n' ', ')
        log_error "$file (line $lines): Image references must have alt text: ![alt text](images/file.png)"
        ((FILE_ERRORS++))
    fi

    # Rule 5b: Disallow inline HTML anchor tags
    anchor_lines=$(grep -ni '<a[[:space:]]*href=' "$file" || true)
    if [ -n "$anchor_lines" ]; then
        while IFS= read -r anchor_line; do
            [ -z "$anchor_line" ] && continue
            anchor_lineno=${anchor_line%%:*}
            log_error "$file (line $anchor_lineno): HTML anchor tags (<a href=...>) are not allowed; use Markdown links instead."
            ((FILE_ERRORS++))
        done <<< "$anchor_lines"
    fi

    # Rule 6: Check YouTube format is correct
    if grep -E '\[.*\]\(youtube:' "$file" | grep -v '^\[]\(youtube:' > /dev/null 2>&1; then
        log_error "$file: YouTube embeds should use format: [](youtube:VIDEO_ID)"
        ((FILE_ERRORS++))
    fi

    # Rule 7: Check for proper Task format (## Task N: Description)
    task_headers=$(grep -n "^## Task" "$file" || true)
    if [ -n "$task_headers" ]; then
        while IFS= read -r line; do
            [ -z "$line" ] && continue
            if [[ ! "$line" =~ ^[0-9]+:##\ Task\ [0-9]+: ]]; then
                linenum=$(echo "$line" | cut -d: -f1)
                log_error "$file (line $linenum): Task headers should follow format '## Task N: Description'"
                ((FILE_ERRORS++))
            fi

        done <<< "$task_headers"
    fi

    # Rule 8: Check <copy> tags are properly closed
    open_copy=$(grep -c '<copy>' "$file" || true)
    close_copy=$(grep -c '</copy>' "$file" || true)
    if [ "$open_copy" -ne "$close_copy" ]; then
        log_error "$file: Mismatched <copy> tags (open: $open_copy, close: $close_copy)"
        ((FILE_ERRORS++))
    fi

    # Rule 9: Check Note format (skipped - blockquotes used for other purposes)

    # Rule 10: Check for Introduction or About section in labs
    if grep -q "^## Task" "$file"; then
        if ! grep -q "^## Introduction" "$file"; then
            log_error "$file: Labs with Tasks should have an '## Introduction' section"
            ((FILE_ERRORS++))
        fi
    fi

    # Rule 11: Check for Objectives section
    if ! grep -q "^### Objectives" "$file" && ! grep -q "^## Objectives" "$file"; then
        log_error "$file: Missing '### Objectives' section"
        ((FILE_ERRORS++))
    fi

    # Rule 12 & 13: Check for Estimated Time
    basename_file=$(basename "$file")
    if [ "$basename_file" = "introduction.md" ]; then
        # Rule 13: introduction.md must have "Estimated Workshop Time:"
        if ! grep -q "Estimated Workshop Time.*:" "$file"; then
            log_error "$file: introduction.md must contain 'Estimated Workshop Time:'"
            ((FILE_ERRORS++))
        fi
    else
        # Rule 12: Other files must have "Estimated Time:"
        if ! grep -qi "Estimated.*Time.*:" "$file"; then
            log_error "$file: Missing 'Estimated Time:' information"
            ((FILE_ERRORS++))
        fi
    fi

    # Rule 14: Check filenames in image references are lowercase
    image_refs=$(grep -oE '!\[.*?\]\((images/[^)]+)\)' "$file" | grep -oE 'images/[^)]+' || true)
    for img in $image_refs; do
        lowercase_img=$(echo "$img" | tr '[:upper:]' '[:lower:]')
        if [ "$img" != "$lowercase_img" ]; then
            log_error "$file: Image filename should be lowercase: $img"
            ((FILE_ERRORS++))
        fi
    done

    # Rule 16-18: Task sections with ordered lists need indented content inside numbered steps.
    # Task sections without ordered lists are exempt from indentation rules.
    indentation_errors=$(python3 - "$file" <<'PY'
import sys, re
path = sys.argv[1]
with open(path, encoding='utf-8') as handle:
    lines = handle.readlines()

# Find all ## headings and ## Task headings
heading_indices = []
task_indices = []
for idx, raw in enumerate(lines):
    if re.match(r'^## ', raw):
        heading_indices.append(idx)
        if re.match(r'^## Task', raw):
            task_indices.append(idx)

errors = []
for pos_index, start in enumerate(task_indices):
    section_start = start + 1
    # Bound section at the next ## heading (not just next Task)
    next_headings = [h for h in heading_indices if h > start]
    section_end = next_headings[0] if next_headings else len(lines)
    block = lines[section_start:section_end]
    if not block:
        continue

    # Check if this task section contains a top-level ordered list
    has_ordered_list = any(re.match(r'[0-9]+\. ', ln) for ln in block)

    # If no ordered list, indentation rules do not apply
    if not has_ordered_list:
        continue

    # Find where the first numbered step begins
    first_step_offset = None
    for offset, ln in enumerate(block):
        if re.match(r'[0-9]+\. ', ln):
            first_step_offset = offset
            break

    if first_step_offset is None:
        continue

    # Check indentation for all content after the first numbered step
    in_code_block = False
    for offset in range(first_step_offset, len(block)):
        ln = block[offset]
        raw_line = ln.rstrip('\n\r')
        stripped = raw_line.lstrip(' ')
        indent = len(raw_line) - len(stripped)
        line_no = section_start + offset + 1

        # Track fenced code blocks
        if stripped.startswith('```'):
            if not in_code_block:
                in_code_block = True
                if indent < 4:
                    errors.append(f"line {line_no}: Code blocks inside numbered steps must be indented with 4 spaces.")
            else:
                in_code_block = False
            continue

        # Skip lines inside code blocks
        if in_code_block:
            continue

        # Skip empty lines
        if not stripped:
            continue

        # Skip top-level numbered step lines (e.g. "1. Step description")
        if re.match(r'[0-9]+\. ', raw_line):
            continue

        # All other content after the first step must be indented >= 4 spaces
        if indent < 4:
            if stripped.startswith('!['):
                errors.append(f"line {line_no}: Images inside numbered steps must be indented with 4 spaces.")
            else:
                errors.append(f"line {line_no}: Content inside numbered steps must be indented with 4 spaces.")

if errors:
    sys.stdout.write("\n".join(errors))
PY
)

    if [ -n "$indentation_errors" ]; then
        while IFS= read -r err_line; do
            [ -z "$err_line" ] && continue
            log_error "$file: $err_line"
            ((FILE_ERRORS++))
        done <<< "$indentation_errors"
    fi

    # Rule 15: Check for Learn More section (optional - no check)

    if [ $FILE_ERRORS -eq 0 ]; then
        log_success "$file passed all required checks"
    fi
    echo ""
done

echo "================================================"
echo "Summary"
echo "================================================"
echo "Errors: $ERRORS"
echo ""

if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}Validation FAILED${NC}"
    exit 1
else
    echo -e "${GREEN}Validation PASSED${NC}"
    exit 0
fi
