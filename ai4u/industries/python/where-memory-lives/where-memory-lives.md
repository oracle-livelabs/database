# Where Agent Memory Should Live

## Introduction

In Lab 5, you experienced the forgetting problem. In Lab 6, you connected to enterprise data. Now it's time to solve the memory problem for good.

In this lab, you'll build a persistent memory system using Oracle 26ai's native JSON type. The agent will store facts about clients and recall them across sessions — even across agent restarts. The memory lives in the database, not in the prompt.

This is where Richmond Alake's core argument comes alive: **the database is the right substrate for agent memory**. Not the filesystem. Not a separate key-value store. The same database that already handles your transactions, your security, and your concurrency.

### The Business Problem

Remember Sarah Chen? In Lab 5, the agent forgot everything about her the moment a new session started. In this lab, you'll fix that. The agent will store Sarah's preferences, rate exception, and relationship history in Oracle 26ai — and recall them in any future session.

One table. One transaction model. One security model. One query language.

**Estimated Time**: 15 minutes

### Objectives

* Create a memory table with JSON columns in Oracle 26ai
* Build `remember_fact` and `recall_facts` tools
* Store information in one session and recall it in a completely new session
* Verify that memory persists by querying it directly in SQL

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

## Task 2: Create the Memory Table

Oracle 26ai's native JSON type is perfect for agent memory. Each memory is a JSON document — flexible enough to store any kind of fact, yet queryable with SQL.

1. Create the memory table.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    execute_ddl(conn, """
    CREATE TABLE agent_memory (
        memory_id      RAW(16) DEFAULT SYS_GUID() PRIMARY KEY,
        agent_id       VARCHAR2(100) DEFAULT 'DEFAULT_AGENT',
        memory_type    VARCHAR2(20) DEFAULT 'FACT',
        content        JSON NOT NULL,
        created_at     TIMESTAMP DEFAULT SYSTIMESTAMP
    )
    """)

    execute_ddl(conn, "CREATE INDEX idx_memory_type ON agent_memory(memory_type)")

    print("Memory table created in Oracle 26ai.")
    print("One table. One transaction model. One security model. One query language.")
    </copy>
    ```

    >**Note:** The `content` column uses Oracle 26ai's native JSON type. This means each memory can have a different structure — a contact preference looks different from a rate exception — but they all live in the same table and are queryable with SQL.

## Task 3: Build Memory Tools

These are the two tools that give the agent persistent memory: `remember_fact` to store and `recall_facts` to retrieve.

1. Create the memory tools.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    @tool
    def remember_fact(fact: str, category: str = "general", about: str = None) -> str:
        """Store a fact for future reference. Parameters: fact (the information to remember),
        category (general, preference, contact, exception, etc.), about (the entity this
        fact is about, e.g. 'Sarah Chen'). Use this when the user shares important information."""
        with conn.cursor() as cur:
            cur.execute("""
                INSERT INTO agent_memory (memory_type, content)
                VALUES ('FACT', JSON_OBJECT(
                    'fact'       VALUE :fact,
                    'category'   VALUE :category,
                    'about'      VALUE :about,
                    'source'     VALUE 'conversation',
                    'remembered' VALUE TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS')
                ))
            """, {"fact": fact, "category": category, "about": about})
        conn.commit()

        result = f"Remembered: {fact}"
        if about:
            result += f" (about {about})"
        return result


    @tool
    def recall_facts(about: str = None, category: str = None) -> str:
        """Retrieve facts from memory. Parameters: about (entity name to search for),
        category (filter by category). Use this when asked about something you might have stored."""
        sql = """
            SELECT m.content.fact.string(),
                   m.content.category.string(),
                   m.content.about.string(),
                   created_at
            FROM agent_memory m
            WHERE memory_type = 'FACT'
        """
        params = {}
        if about:
            sql += " AND UPPER(m.content.about.string()) LIKE '%' || UPPER(:about) || '%'"
            params["about"] = about
        if category:
            sql += " AND UPPER(m.content.category.string()) = UPPER(:category)"
            params["category"] = category
        sql += " ORDER BY created_at DESC FETCH FIRST 10 ROWS ONLY"

        with conn.cursor() as cur:
            cur.execute(sql, params)
            rows = cur.fetchall()

        if not rows:
            return "No facts found matching the criteria."

        lines = []
        for fact, cat, abt, ts in rows:
            line = f"- {fact}"
            if abt:
                line += f" (about: {abt})"
            lines.append(line)
        return f"Found {len(rows)} facts:\n" + "\n".join(lines)

    print("Memory tools created: remember_fact, recall_facts")
    </copy>
    ```

    >**Note:** The `recall_facts` tool uses Oracle 26ai's JSON dot-notation (`m.content.fact.string()`) to query inside the JSON document. No special JSON parsing needed — it's just SQL.

## Task 4: Create the Memory-Enabled Agent

1. Create the agent with memory tools.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    SYSTEM_PROMPT = """You are a helpful assistant with persistent memory powered by Oracle 26ai.
    When users share information, use remember_fact to store it.
    When users ask questions, use recall_facts to check your memory first.
    Always use your tools — never guess from previous conversation context alone."""

    agent = create_react_agent(
        model=llm,
        tools=[remember_fact, recall_facts],
        prompt=SYSTEM_PROMPT,
    )

    print("Memory-enabled agent created.")
    </copy>
    ```

## Task 5: Session 1 — Store Information

Tell the agent about Sarah Chen. This time, the agent will store the facts in Oracle 26ai.

1. Share facts about Sarah Chen.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    response = agent.invoke({
        "messages": [("user", "Customer Sarah Chen prefers to be contacted by email, not phone.")]
    })
    print(response["messages"][-1].content)
    </copy>
    ```

2. Share more facts.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    response = agent.invoke({
        "messages": [("user", "Sarah Chen has a 15 percent rate exception and her timezone is Pacific.")]
    })
    print(response["messages"][-1].content)
    </copy>
    ```

3. Verify recall within the session.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    response = agent.invoke({
        "messages": [("user", "What do you know about Sarah Chen?")]
    })
    print(response["messages"][-1].content)
    </copy>
    ```

    The agent uses `recall_facts` to retrieve the stored facts — not the conversation history.

## Task 6: Session 2 — The Memory Survives

This is the moment of truth. Create a brand new agent instance with no prior conversation history and ask about Sarah Chen.

1. Create a completely new agent and ask about Sarah Chen.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    # ── Simulate a new session ──
    # Create a BRAND NEW agent instance — fresh context, no message history
    fresh_agent = create_react_agent(
        model=llm,
        tools=[remember_fact, recall_facts],
        prompt=SYSTEM_PROMPT,
    )

    # Ask the new agent — it has ZERO prior conversation context
    response = fresh_agent.invoke({
        "messages": [("user", "What is Sarah Chen's preferred contact method?")]
    })
    print("New session, new agent instance:")
    print(response["messages"][-1].content)
    </copy>
    ```

    The agent remembers! It calls `recall_facts`, finds the stored fact about email preference, and returns the answer. The memory lives in Oracle 26ai, not in the prompt.

2. Ask about the rate exception too.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    response = fresh_agent.invoke({
        "messages": [("user", "What rate exception does Sarah Chen have?")]
    })
    print(response["messages"][-1].content)
    </copy>
    ```

    15% rate exception — pulled from the database. No more forgetting.

## Task 7: Verify Memory in Oracle

The memory is just a table. You can query it directly with SQL — no agent needed.

1. Query the memory table directly.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    with conn.cursor() as cur:
        cur.execute("""
            SELECT m.content.fact.string() AS fact,
                   m.content.about.string() AS about,
                   m.content.category.string() AS category,
                   created_at
            FROM agent_memory m
            ORDER BY created_at
        """)
        rows = cur.fetchall()

    print("=== Agent Memory (stored in Oracle 26ai) ===")
    for fact, about, category, ts in rows:
        print(f"  [{category}] {fact} (about: {about})")
    </copy>
    ```

    This is the power of the database as memory substrate. The memory is:
    * **Durable**: survives agent restarts, crashes, and redeployments
    * **Queryable**: standard SQL with JSON dot-notation
    * **Auditable**: timestamps, categories, and source tracking
    * **Concurrent**: multiple agents can read and write simultaneously (ACID)

## Task 8: Clean Up

1. Drop the memory table when you're done.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    execute_ddl(conn, "DROP TABLE agent_memory PURGE")
    print("Cleanup complete.")
    </copy>
    ```

## Summary

You've built a persistent memory system that solves the forgetting problem:

| | Lab 5 (Stateless) | Lab 7 (Persistent Memory) |
|---|---|---|
| **Storage** | Context window only | Oracle 26ai JSON table |
| **Survives restarts** | No | Yes |
| **Multiple agents** | No sharing | Shared memory table |
| **Queryable** | No | SQL with JSON dot-notation |
| **Auditable** | No | Timestamps, categories, sources |

The key insight: **memory is a database capability, not a model capability**. The LLM is stateless. Oracle 26ai is durable. Put the memory where it belongs.

You may now **proceed to the next lab**.

## Learn More

* [Oracle 26ai JSON Developer's Guide](https://docs.oracle.com/en/database/oracle/oracle-database/)
* [LangChain Persistence](https://python.langchain.com/docs/concepts/persistence/)
* [Richmond Alake: Choosing the Right Memory Substrate](https://medium.com/@richmondalake)

## Acknowledgements

* **Author** - David Start
* **Last Updated By/Date** - David Start, February 2026
