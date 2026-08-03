# What Is an AI Agent, Really?

## Introduction

Most people think AI is just a chatbot. You ask a question, it gives an answer. But agents do more. They don't just respond, they *act*. They look up real data, make decisions based on your systems, and complete tasks.

In this lab, you will see that difference firsthand at Seer Equity, a fictional financial services company. You will build a LangChain agent with a SQL tool that queries actual loan data from Oracle Database 26ai. It won't explain how to check a loan status. It will actually check it and give you real answers.

### The Business Problem

At Seer Equity, loan officers spend hours every day answering the same question: *"What's my loan status?"*

When a customer calls, the loan officer has to log into the system, navigate to the right screen, find the application, and read out the status. It's tedious. It's slow. And it takes time away from actually helping customers.

The company tried deploying a chatbot. But when a customer asked "What's the status of my loan?", the chatbot responded with a 5-step tutorial on how to log in and check. The customer didn't want a tutorial. They wanted their status.

> *"I asked the AI about my loan and it told me how to look it up. I know how to look it up! I wanted you to just tell me the status."*
>
> Frustrated Seer Equity customer

### What You Will Learn

This lab shows you the fundamental difference between a chatbot (explains how) and an agent (actually does it). You will build a LangChain agent that queries real loan data from Oracle 26ai and returns actual answers. This is the first step toward solving Seer Equity's customer service challenges.

**What you will build:** A loan application lookup agent using LangChain's `@tool` decorator and `create_react_agent`.

**Estimated Time**: 10 minutes

### Objectives

* Create sample loan application data in Oracle 26ai
* Build a LangChain agent with SQL tools
* See the agent look up real loan information
* Understand why execution beats explanation

### Prerequisites

* Completed the **Getting Started** lab
* Jupyter Notebook running with Oracle 26ai connection verified

## Task 1: Set Up the Notebook

Every lab in this workshop runs in a Jupyter notebook. Start by setting up your connection and helper functions.

1. Create a new Jupyter notebook for this lab (or open the provided one).

2. Run the shared setup code.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    import oracledb
    import os
    from langchain_openai import ChatOpenAI
    from langchain_core.tools import tool
    from langgraph.prebuilt import create_react_agent

    # ── Database Connection ──────────────────────────────────────────────
    conn = oracledb.connect(
        user=os.getenv("ORACLE_USER", "AGENT_USER"),
        password=os.getenv("ORACLE_PASSWORD"),
        dsn=os.getenv("ORACLE_DSN", "localhost:1521/FREEPDB1"),
    )
    print(f"Connected as: {conn.username}")

    # ── LLM ──────────────────────────────────────────────────────────────
    llm = ChatOpenAI(
        model=os.getenv("OPENAI_MODEL", "gpt-4o-mini"),
        temperature=0,
    )

    # ── Helper Functions ─────────────────────────────────────────────────
    def execute_sql(conn, sql, params=None, commit=False):
        """Execute SQL and optionally commit. Returns rows for SELECT."""
        with conn.cursor() as cur:
            cur.execute(sql, params or {})
            if commit:
                conn.commit()
            if sql.strip().upper().startswith("SELECT"):
                return cur.fetchall()
        return None

    def execute_ddl(conn, sql):
        """Execute DDL (CREATE, DROP, etc.)."""
        with conn.cursor() as cur:
            cur.execute(sql)
        conn.commit()

    print("Setup complete.")
    </copy>
    ```

## Task 2: Create the Loan Applications Table

First, let's create a loan applications table. This gives the agent something real to work with — the kind of data that a chatbot would never be able to access.

1. Create the table and insert sample data.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    execute_ddl(conn, """
    CREATE TABLE loan_applications (
        application_id     VARCHAR2(20) PRIMARY KEY,
        applicant_name     VARCHAR2(100),
        application_date   DATE,
        loan_status        VARCHAR2(30),
        loan_amount        NUMBER(12,2),
        loan_type          VARCHAR2(30)
    )
    """)

    sample_loans = [
        ("LOAN-12345", "Alex Chen",      "2025-01-02", "Approved",     45000,  "Personal"),
        ("LOAN-12346", "Maria Santos",   "2025-01-03", "Under Review", 275000, "Mortgage"),
        ("LOAN-12347", "James Wilson",   "2024-12-28", "Approved",     32000,  "Auto"),
        ("LOAN-12348", "Sarah Johnson",  "2025-01-04", "Pending",      85000,  "Business"),
    ]

    with conn.cursor() as cur:
        cur.executemany("""
            INSERT INTO loan_applications
            VALUES (:1, :2, TO_DATE(:3, 'YYYY-MM-DD'), :4, :5, :6)
        """, sample_loans)
    conn.commit()

    print("Table created with", len(sample_loans), "loan applications.")
    </copy>
    ```

    You should see:

    ```
    Table created with 4 loan applications.
    ```

2. Verify the data is there.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    rows = execute_sql(conn, "SELECT application_id, applicant_name, loan_status FROM loan_applications")
    for row in rows:
        print(row)
    </copy>
    ```

## Task 3: Build a Loan Lookup Tool

Now let's build the tool that gives the agent access to real data. In LangChain, you create tools with the `@tool` decorator.

1. Create two tools: one for looking up a specific loan, and one for listing loans.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    @tool
    def loan_lookup(application_id: str) -> str:
        """Look up a loan application by ID. Returns status, applicant, amount, and type."""
        with conn.cursor() as cur:
            cur.execute("""
                SELECT application_id, applicant_name, loan_status, loan_amount, loan_type
                FROM loan_applications
                WHERE application_id = :app_id
            """, {"app_id": application_id.upper()})
            row = cur.fetchone()

        if not row:
            return f"Loan application {application_id} not found."

        return (
            f"Loan {row[0]}: Status={row[2]}, Applicant={row[1]}, "
            f"Amount=${row[3]:,.2f}, Type={row[4]}"
        )


    @tool
    def list_loans(status_filter: str = None) -> str:
        """List loan applications, optionally filtered by status (Pending, Under Review, Approved, Denied)."""
        sql = "SELECT application_id, applicant_name, loan_status, loan_amount, loan_type FROM loan_applications"
        params = {}
        if status_filter:
            sql += " WHERE UPPER(loan_status) LIKE '%' || UPPER(:status) || '%'"
            params["status"] = status_filter
        sql += " ORDER BY application_date DESC"

        with conn.cursor() as cur:
            cur.execute(sql, params)
            rows = cur.fetchall()

        if not rows:
            return "No loan applications found."

        lines = []
        for r in rows:
            lines.append(f"  {r[0]}: {r[1]}, Status={r[2]}, ${r[3]:,.2f} {r[4]}")
        return f"Found {len(rows)} applications:\n" + "\n".join(lines)

    print("Tools created: loan_lookup, list_loans")
    </copy>
    ```

    >**Note:** The `@tool` decorator tells LangChain that this function can be called by an agent. The docstring becomes the tool description that the LLM reads to decide when to use it.

## Task 4: Create the Agent

With tools in hand, you can create the agent. LangChain's `create_react_agent` wires up the LLM, the tools, and a system prompt into an agent that can reason and act.

1. Create the loan application assistant agent.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    SYSTEM_PROMPT = """You are a loan application assistant for Seer Equity.
    Use your tools to query the database and provide answers.
    Never guess — always use the tools to look up real data.
    Never ask clarifying questions — query the data and report what you find."""

    agent = create_react_agent(
        model=llm,
        tools=[loan_lookup, list_loans],
        prompt=SYSTEM_PROMPT,
    )

    print("Agent created with tools:", [t.name for t in [loan_lookup, list_loans]])
    </copy>
    ```

## Task 5: Test the Agent

Now ask the agent real questions. Watch how it uses tools to find actual answers instead of guessing.

1. Ask about a specific loan.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    response = agent.invoke({"messages": [("user", "What is the status of loan application LOAN-12345?")]})
    print(response["messages"][-1].content)
    </copy>
    ```

    The agent will call the `loan_lookup` tool and return the real status from Oracle 26ai. No guessing. No tutorials.

2. Ask about a loan amount.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    response = agent.invoke({"messages": [("user", "How much did James Wilson apply for?")]})
    print(response["messages"][-1].content)
    </copy>
    ```

3. Filter by status.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    response = agent.invoke({"messages": [("user", "Which loan applications are still pending or under review?")]})
    print(response["messages"][-1].content)
    </copy>
    ```

    The agent uses `list_loans` with a status filter and returns only matching applications.

## Task 6: See the Execution Trail

One of the most powerful features of agents is that you can see exactly what they did. Every tool call is recorded in the message history.

1. Run a query and inspect the full execution trail.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    response = agent.invoke({"messages": [("user", "What is the status of loan application LOAN-12345?")]})

    print("=== Full Execution Trail ===")
    for msg in response["messages"]:
        print(f"[{msg.type}] {msg.content[:200] if msg.content else '(tool call)'}")
        if hasattr(msg, "tool_calls") and msg.tool_calls:
            for tc in msg.tool_calls:
                print(f"  → Tool: {tc['name']}({tc['args']})")
    </copy>
    ```

    You'll see the full chain: user question → agent decides to call `loan_lookup` → tool returns data → agent formats the answer. This is the agent loop in action.

## Task 7: Clean Up

1. Drop the table when you're done.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    execute_ddl(conn, "DROP TABLE loan_applications PURGE")
    print("Cleanup complete.")
    </copy>
    ```

## Summary

You just built your first AI agent. Here's what makes it different from a chatbot:

| | Chatbot | Agent |
|---|---|---|
| **Data access** | None | Queries Oracle 26ai |
| **Response** | "Here's how to check..." | "Loan LOAN-12345 is Approved" |
| **Tools** | None | `loan_lookup`, `list_loans` |
| **Accountability** | Black box | Full execution trail |

The key insight: **agents do, chatbots explain**. The `@tool` decorator and `create_react_agent` are all you need to cross that line.

You may now **proceed to the next lab**.

## Learn More

* [LangChain Tools Documentation](https://python.langchain.com/docs/concepts/tools/)
* [LangGraph ReAct Agent](https://langchain-ai.github.io/langgraph/how-tos/create-react-agent/)
* [python-oracledb Documentation](https://python-oracledb.readthedocs.io/)

## Acknowledgements

* **Author** - David Start
* **Last Updated By/Date** - David Start, February 2026
