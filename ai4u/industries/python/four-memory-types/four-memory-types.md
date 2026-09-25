# The Four Types of Agent Memory

## Introduction

In Lab 7, you built a simple memory system with `remember_fact` and `recall_facts`. But not all memory is the same. A working note about a loan you're reviewing right now is different from a permanent fact about a client. A record of a past decision is different from a corporate policy document.

In this lab, you'll build all four types of agent memory, backed by a single unified schema in Oracle 26ai:

* **Short-term context** — expires after the session (working notes)
* **Long-term facts** — persists forever (client preferences, exceptions)
* **Decision history** — what happened, what was decided, and how it turned out
* **Reference knowledge** — human-maintained policies and procedures

### The Business Problem

At Seer Equity, loan officers need different kinds of memory for different tasks:

* "I'm currently reviewing Sarah Chen's rate exception" → **short-term context** (expires when the review is done)
* "Sarah Chen prefers email contact" → **long-term fact** (never expires)
* "Last time a long-term client requested a rate exception, we approved 15% and they renewed multiple loans" → **decision history** (learning from experience)
* "Rate exceptions require senior officer approval for amounts over $50K" → **reference knowledge** (company policy, maintained by humans)

**Estimated Time**: 15 minutes

### Objectives

* Create a unified memory schema with four memory types
* Build tools for each type: context, facts, decisions, and reference
* Seed realistic data and test each type independently
* Understand when to use which type

### Prerequisites

* Completed the **Getting Started** lab
* Jupyter Notebook running with Oracle 26ai connection verified

## Task 1: Set Up the Notebook

1. Create a new Jupyter notebook for this lab.

2. Run the shared setup code.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    import oracledb
    import os
    from langchain_openai import ChatOpenAI
    from langchain_core.tools import tool
    from langgraph.prebuilt import create_react_agent

    conn = oracledb.connect(
        user=os.getenv("ORACLE_USER", "AGENT_USER"),
        password=os.getenv("ORACLE_PASSWORD"),
        dsn=os.getenv("ORACLE_DSN", "localhost:1521/FREEPDB1"),
    )
    print(f"Connected as: {conn.username}")

    llm = ChatOpenAI(
        model=os.getenv("OPENAI_MODEL", "gpt-4o-mini"),
        temperature=0,
    )

    def execute_ddl(conn, sql):
        """Execute DDL (CREATE, DROP, etc.)."""
        with conn.cursor() as cur:
            cur.execute(sql)
        conn.commit()

    print("Setup complete.")
    </copy>
    ```

## Task 2: Create the Unified Memory Schema

One schema for all four memory types. Oracle 26ai's JSON columns handle the different structures within each type.

1. Create the memory and reference tables.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    execute_ddl(conn, """
    CREATE TABLE agent_memory (
        memory_id      RAW(16) DEFAULT SYS_GUID() PRIMARY KEY,
        memory_type    VARCHAR2(20) NOT NULL,
        session_id     VARCHAR2(100),
        entity_id      VARCHAR2(100),
        content        JSON NOT NULL,
        created_at     TIMESTAMP DEFAULT SYSTIMESTAMP,
        expires_at     TIMESTAMP,
        CONSTRAINT chk_memory_type CHECK (
            memory_type IN ('SHORTTERM', 'LONGTERM', 'DECISION', 'REFERENCE')
        )
    )
    """)

    execute_ddl(conn, "CREATE INDEX idx_mem_type ON agent_memory(memory_type)")
    execute_ddl(conn, "CREATE INDEX idx_mem_entity ON agent_memory(entity_id)")
    execute_ddl(conn, "CREATE INDEX idx_mem_session ON agent_memory(session_id)")

    execute_ddl(conn, """
    CREATE TABLE reference_knowledge (
        ref_id       RAW(16) DEFAULT SYS_GUID() PRIMARY KEY,
        category     VARCHAR2(100) NOT NULL,
        name         VARCHAR2(200) NOT NULL,
        content      JSON NOT NULL,
        is_active    NUMBER(1) DEFAULT 1,
        created_at   TIMESTAMP DEFAULT SYSTIMESTAMP,
        updated_by   VARCHAR2(100)
    )
    """)

    print("Four memory types, one database. No polyglot persistence.")
    </copy>
    ```

    >**Note:** The `expires_at` column is used only for short-term context. Long-term facts and decisions never expire. Reference knowledge is human-maintained — the agent reads it but never writes it.

## Task 3: Build Memory Tools for Each Type

Each memory type gets its own tools. This gives the agent fine-grained control over how it stores and retrieves different kinds of information.

1. Build the short-term context tools.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    # ── SHORT-TERM CONTEXT (expires after 1 hour) ────────────────────────

    @tool
    def set_context(session_id: str, entity_id: str, context: str) -> str:
        """Set short-term working context for the current session. Expires in 1 hour.
        Parameters: session_id, entity_id (what this is about), context (the info)."""
        with conn.cursor() as cur:
            cur.execute("""
                DELETE FROM agent_memory
                WHERE memory_type = 'SHORTTERM' AND session_id = :sid AND entity_id = :eid
            """, {"sid": session_id, "eid": entity_id})
            cur.execute("""
                INSERT INTO agent_memory (memory_type, session_id, entity_id, content, expires_at)
                VALUES ('SHORTTERM', :sid, :eid,
                        JSON_OBJECT('context' VALUE :ctx,
                                    'set_at' VALUE TO_CHAR(SYSTIMESTAMP, 'HH24:MI:SS')),
                        SYSTIMESTAMP + INTERVAL '1' HOUR)
            """, {"sid": session_id, "eid": entity_id, "ctx": context})
        conn.commit()
        return f"Context set for {entity_id}"


    @tool
    def get_context(session_id: str, entity_id: str = None) -> str:
        """Get short-term context for the current session."""
        sql = """
            SELECT entity_id, JSON_VALUE(content, '$.context') as context
            FROM agent_memory
            WHERE memory_type = 'SHORTTERM' AND session_id = :sid
            AND (expires_at IS NULL OR expires_at > SYSTIMESTAMP)
        """
        params = {"sid": session_id}
        if entity_id:
            sql += " AND entity_id = :eid"
            params["eid"] = entity_id

        with conn.cursor() as cur:
            cur.execute(sql, params)
            rows = cur.fetchall()

        if not rows:
            return "No active context found."
        return "\n".join(f"{eid}: {ctx}" for eid, ctx in rows)

    print("Short-term context tools created.")
    </copy>
    ```

2. Build the long-term facts tools.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    # ── LONG-TERM FACTS (permanent) ──────────────────────────────────────

    @tool
    def store_fact(entity_id: str, fact: str, category: str = "general") -> str:
        """Store a permanent fact about an entity. Facts persist forever."""
        with conn.cursor() as cur:
            cur.execute("""
                INSERT INTO agent_memory (memory_type, entity_id, content)
                VALUES ('LONGTERM', :eid, JSON_OBJECT(
                    'fact' VALUE :fact, 'category' VALUE :cat,
                    'learned' VALUE TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS')))
            """, {"eid": entity_id, "fact": fact, "cat": category})
        conn.commit()
        return f"Fact stored about {entity_id}: {fact}"


    @tool
    def get_facts(entity_id: str, category: str = None) -> str:
        """Retrieve long-term facts about an entity."""
        sql = """
            SELECT JSON_VALUE(content, '$.fact'), JSON_VALUE(content, '$.category')
            FROM agent_memory
            WHERE memory_type = 'LONGTERM' AND entity_id = :eid
        """
        params = {"eid": entity_id}
        if category:
            sql += " AND JSON_VALUE(content, '$.category') = :cat"
            params["cat"] = category
        sql += " ORDER BY created_at DESC"

        with conn.cursor() as cur:
            cur.execute(sql, params)
            rows = cur.fetchall()

        if not rows:
            return f"No facts found for {entity_id}"
        lines = [f"- {fact} ({cat})" for fact, cat in rows]
        return f"Found {len(rows)} facts about {entity_id}:\n" + "\n".join(lines)

    print("Long-term facts tools created.")
    </copy>
    ```

3. Build the decision history tools.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    # ── DECISION MEMORY (what happened and why) ───────────────────────────

    @tool
    def record_decision(
        entity_id: str, situation: str, decision: str, outcome: str, success: str = "true"
    ) -> str:
        """Record a decision with its outcome for future reference."""
        success_bool = success.lower() == "true"
        with conn.cursor() as cur:
            cur.execute("""
                INSERT INTO agent_memory (memory_type, entity_id, content)
                VALUES ('DECISION', :eid, JSON_OBJECT(
                    'situation' VALUE :sit, 'decision' VALUE :dec,
                    'outcome' VALUE :out,
                    'success' VALUE CASE WHEN :succ = 1 THEN 'true' ELSE 'false' END,
                    'recorded' VALUE TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS')))
            """, {"eid": entity_id, "sit": situation, "dec": decision,
                  "out": outcome, "succ": 1 if success_bool else 0})
        conn.commit()
        return f"Decision recorded: {decision}"


    @tool
    def find_past_decisions(situation: str, limit: int = 3) -> str:
        """Find past decisions for similar situations. Uses keyword matching."""
        with conn.cursor() as cur:
            cur.execute("""
                SELECT entity_id,
                       JSON_VALUE(content, '$.situation'),
                       JSON_VALUE(content, '$.decision'),
                       JSON_VALUE(content, '$.outcome'),
                       JSON_VALUE(content, '$.success')
                FROM agent_memory
                WHERE memory_type = 'DECISION'
                AND UPPER(JSON_VALUE(content, '$.situation')) LIKE '%' || UPPER(:sit) || '%'
                ORDER BY created_at DESC
                FETCH FIRST :lim ROWS ONLY
            """, {"sit": situation, "lim": limit})
            rows = cur.fetchall()

        if not rows:
            return "No similar decisions found."

        lines = []
        for eid, sit, dec, out, succ in rows:
            lines.append(f"Situation: {sit}\nDecision: {dec}\nOutcome: {out} (Success: {succ})\n---")
        return f"Found {len(rows)} similar decisions:\n" + "\n".join(lines)

    print("Decision history tools created.")
    </copy>
    ```

4. Build the reference knowledge tool.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    # ── REFERENCE KNOWLEDGE (human-maintained) ────────────────────────────

    @tool
    def get_reference(category: str = None, name: str = None) -> str:
        """Look up reference knowledge (policies, procedures, guidelines).
        This is human-maintained — the agent reads but never writes."""
        sql = """
            SELECT category, name, JSON_VALUE(content, '$.text')
            FROM reference_knowledge WHERE is_active = 1
        """
        params = {}
        if category:
            sql += " AND UPPER(category) LIKE '%' || UPPER(:cat) || '%'"
            params["cat"] = category
        if name:
            sql += " AND UPPER(name) LIKE '%' || UPPER(:name) || '%'"
            params["name"] = name
        sql += " ORDER BY category, name"

        with conn.cursor() as cur:
            cur.execute(sql, params)
            rows = cur.fetchall()

        if not rows:
            return "No reference knowledge found."
        lines = [f"[{cat}] {nm}:\n{txt}\n" for cat, nm, txt in rows]
        return f"Found {len(rows)} references:\n" + "\n".join(lines)

    print("Reference knowledge tool created.")
    </copy>
    ```

## Task 4: Seed Realistic Data

Let's populate each memory type with realistic Seer Equity data.

1. Seed long-term facts, decision history, and reference knowledge.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    # Long-term facts
    for eid, fact, cat in [
        ("CUST-001", "Prefers email contact over phone", "preference"),
        ("CUST-001", "Timezone is Pacific", "preference"),
        ("CUST-001", "Approved for 15% rate exception", "exception"),
        ("CUST-001", "Client since 2018", "history"),
        ("CUST-002", "Requires all documents via secure portal", "requirement"),
        ("CUST-002", "Annual loan review in March", "schedule"),
    ]:
        with conn.cursor() as cur:
            cur.execute("""
                INSERT INTO agent_memory (memory_type, entity_id, content)
                VALUES ('LONGTERM', :eid, JSON_OBJECT('fact' VALUE :fact, 'category' VALUE :cat,
                        'learned' VALUE TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS')))
            """, {"eid": eid, "fact": fact, "cat": cat})
    conn.commit()

    # Decision history
    decisions = [
        ("CUST-001", "Long-term customer requested rate exception due to payment history",
         "Approved 15% rate exception based on 6-year relationship",
         "Customer satisfied, renewed multiple loans", "true"),
        ("CUST-002", "New customer requested rate exception on first loan",
         "Declined exception but offered standard preferred rate",
         "Customer accepted, relationship established", "true"),
        ("CUST-003", "Customer with missed payments requested rate exception",
         "Declined exception citing payment history concerns",
         "Customer upset but policy was correct", "true"),
    ]
    for eid, sit, dec, out, succ in decisions:
        with conn.cursor() as cur:
            cur.execute("""
                INSERT INTO agent_memory (memory_type, entity_id, content)
                VALUES ('DECISION', :eid, JSON_OBJECT(
                    'situation' VALUE :sit, 'decision' VALUE :dec,
                    'outcome' VALUE :out, 'success' VALUE :succ,
                    'recorded' VALUE TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS')))
            """, {"eid": eid, "sit": sit, "dec": dec, "out": out, "succ": succ})
    conn.commit()

    # Reference knowledge (human-maintained policies)
    refs = [
        ("policy", "Rate Exception Policy - Preferred",
         "Clients with 5+ years history and no missed payments may receive up to 15% rate discount. "
         "Approval required from senior loan officer. Document rationale in loan notes."),
        ("policy", "Rate Exception Policy - Standard",
         "Standard clients may request rate review after 2 years of on-time payments. "
         "Maximum 10% discount. Requires underwriter approval."),
        ("procedure", "Escalation Process",
         "Rate disputes: 1) Loan officer reviews history, 2) If over $50K loan, escalate to Senior Officer, "
         "3) If unresolved, escalate to Branch Manager, 4) Customer may request formal review."),
        ("guideline", "Client Communication",
         "Always be empathetic and solution-focused. Acknowledge client concerns before explaining policy. "
         "Offer alternatives when declining requests."),
    ]
    for cat, nm, txt in refs:
        with conn.cursor() as cur:
            cur.execute("""
                INSERT INTO reference_knowledge (category, name, content, updated_by)
                VALUES (:cat, :nm, JSON_OBJECT('text' VALUE :txt), 'ADMIN')
            """, {"cat": cat, "nm": nm, "txt": txt})
    conn.commit()

    print("Seeded: 6 facts, 3 decisions, 4 reference documents.")
    </copy>
    ```

## Task 5: Test All Four Memory Types

Now call each tool directly to verify they work.

1. Test all four types.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    # Short-term context
    print("=== Short-Term Context ===")
    print(set_context.invoke({"session_id": "S001", "entity_id": "LOAN-5678", "context": "Working on Sarah Chen's rate review"}))
    print(get_context.invoke({"session_id": "S001"}))

    # Long-term facts
    print("\n=== Long-Term Facts ===")
    print(get_facts.invoke({"entity_id": "CUST-001"}))

    # Past decisions
    print("\n=== Decision History ===")
    print(find_past_decisions.invoke({"situation": "rate exception"}))

    # Reference knowledge
    print("\n=== Reference Knowledge ===")
    print(get_reference.invoke({"category": "policy"}))
    </copy>
    ```

    Each memory type serves a different purpose:

    | Type | Lifespan | Written By | Example |
    |------|----------|-----------|---------|
    | Short-term | Expires (1 hour) | Agent | "Currently reviewing LOAN-5678" |
    | Long-term | Forever | Agent | "Sarah Chen prefers email" |
    | Decision | Forever | Agent | "Approved 15% exception, customer renewed" |
    | Reference | Forever | Humans | "Rate exceptions require senior approval" |

## Task 6: Clean Up

1. Drop the tables when you're done.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    execute_ddl(conn, "DROP TABLE agent_memory PURGE")
    execute_ddl(conn, "DROP TABLE reference_knowledge PURGE")
    print("Cleanup complete.")
    </copy>
    ```

## Summary

You've built a complete memory system with four distinct types:

* **Short-term context**: Working notes that expire — like a scratchpad for the current task
* **Long-term facts**: Permanent knowledge about entities — client preferences, exceptions, history
* **Decision history**: What happened, what was decided, and how it turned out — learning from experience
* **Reference knowledge**: Human-maintained policies and procedures — the agent reads but never writes

All four types live in a single Oracle 26ai schema. One database. One transaction model. One security model. No polyglot persistence.

The key insight: **different kinds of memory have different lifespans, different authors, and different purposes**. A good memory system distinguishes between them.

You may now **proceed to the next lab**.

## Learn More

* [Oracle 26ai JSON Developer's Guide](https://docs.oracle.com/en/database/oracle/oracle-database/)
* [LangChain Memory Types](https://python.langchain.com/docs/concepts/memory/)
* [Richmond Alake: Memory Substrate Architecture](https://medium.com/@richmondalake)

## Acknowledgements

* **Author** - David Start
* **Last Updated By/Date** - David Start, February 2026
