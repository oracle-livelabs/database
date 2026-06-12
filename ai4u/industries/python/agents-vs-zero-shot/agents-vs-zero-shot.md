# Why Agents Beat Zero-Shot Prompts

## Introduction

In Lab 1, you built an agent that could look up loan data. But how much better is it than just asking the LLM directly? In this lab, you'll see the answer by comparing three levels of AI capability side by side.

You'll start with a raw LLM that has no access to your data, then add read-only tools, and finally give the agent both read *and* write capabilities. The difference is dramatic — and it's exactly why Seer Equity needs agents, not chatbots.

### The Business Problem

At Seer Equity, loan officers need to do more than just look up information. When a loan application finishes review, someone needs to update its status. Today that's a manual process: check the application, verify the review is complete, then navigate to another screen to change the status.

An agent can do both steps in a single request: check the loan, and if the conditions are met, update it automatically.

**Estimated Time**: 10 minutes

### Objectives

* See what happens when you ask an LLM without data access (zero-shot)
* Build read and write tools for loan management
* Watch an agent coordinate a multi-step check-then-update workflow
* Understand the three levels: zero-shot, read-only, and read+write

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

## Task 2: Create Sample Data

1. Create a loans table for this lab.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    execute_ddl(conn, """
    CREATE TABLE sample_loans (
        application_id   VARCHAR2(20) PRIMARY KEY,
        applicant        VARCHAR2(100),
        status           VARCHAR2(30),
        amount           NUMBER(12,2),
        loan_type        VARCHAR2(30),
        application_date DATE DEFAULT SYSDATE
    )
    """)

    sample_data = [
        ("LOAN-12345", "Acme Corp",  "UNDER_REVIEW", 150000, "Business"),
        ("LOAN-12346", "TechStart",  "PENDING",       45000, "Business"),
        ("LOAN-12347", "GlobalCo",   "APPROVED",     275000, "Mortgage"),
    ]

    with conn.cursor() as cur:
        cur.executemany("""
            INSERT INTO sample_loans (application_id, applicant, status, amount, loan_type)
            VALUES (:1, :2, :3, :4, :5)
        """, sample_data)
    conn.commit()

    print("Created sample_loans with", len(sample_data), "rows.")
    </copy>
    ```

## Task 3: Zero-Shot — LLM With No Tools

What happens when you ask the LLM about your data without giving it any tools? It has to guess — or admit it doesn't know.

1. Ask the LLM directly.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    zero_shot_response = llm.invoke("What is the status of loan LOAN-12345 at Seer Equity?")
    print("Zero-shot response:")
    print(zero_shot_response.content)
    </copy>
    ```

    The LLM will either hallucinate an answer or say it doesn't have access to that information. Either way, it's useless for real work.

    >**Note:** This is the "chatbot" approach. The LLM has no connection to your database. It can only work with what's in its training data — which doesn't include your loan applications.

## Task 4: Build Read and Write Tools

Now let's give the agent real capabilities. A lookup tool for reading and an update tool for writing.

1. Create the tools.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    @tool
    def lookup_loan(application_id: str) -> str:
        """Look up loan application status and details by application ID."""
        with conn.cursor() as cur:
            cur.execute("""
                SELECT 'Loan ' || application_id || ': ' || status ||
                       ', Applicant: ' || applicant ||
                       ', Amount: $' || amount ||
                       ', Type: ' || loan_type
                FROM sample_loans
                WHERE application_id = :app_id
            """, {"app_id": application_id})
            row = cur.fetchone()

        if not row:
            return f"Loan application {application_id} not found."
        return row[0]


    @tool
    def update_loan_status(application_id: str, new_status: str) -> str:
        """Update a loan application status. Valid statuses: PENDING, UNDER_REVIEW, APPROVED, DENIED.
        Always look up the loan first before updating."""
        with conn.cursor() as cur:
            cur.execute(
                "SELECT status FROM sample_loans WHERE application_id = :app_id",
                {"app_id": application_id},
            )
            row = cur.fetchone()
            if not row:
                return f"Loan application {application_id} not found. Cannot update."

            old_status = row[0]
            cur.execute("""
                UPDATE sample_loans SET status = UPPER(:new_status)
                WHERE application_id = :app_id
            """, {"new_status": new_status, "app_id": application_id})
        conn.commit()

        return f"Loan {application_id} updated from {old_status} to {new_status.upper()}"

    print("Tools created: lookup_loan, update_loan_status")
    </copy>
    ```

## Task 5: Create the Agent and Test Read+Write

The real power of an agent is coordination. You can give it a conditional instruction — "check the loan, and *if* it meets a condition, update it" — and the agent figures out the steps.

1. Create the agent with both tools.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    SYSTEM_PROMPT = """You are a loan management agent for Seer Equity.
    You can look up loan applications and update their status.
    Always look up a loan first before updating it.
    Never make up loan information — always use your tools."""

    agent = create_react_agent(
        model=llm,
        tools=[lookup_loan, update_loan_status],
        prompt=SYSTEM_PROMPT,
    )

    print("Agent created with read+write tools.")
    </copy>
    ```

2. Test a multi-step workflow: check and conditionally update.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    # LOAN-12345 is UNDER_REVIEW — the agent should check, then approve
    response = agent.invoke({
        "messages": [("user", "Check loan LOAN-12345 and if it is under review, approve it")]
    })
    print(response["messages"][-1].content)
    </copy>
    ```

    Watch the agent: it first calls `lookup_loan` to check the status, sees "UNDER_REVIEW", then calls `update_loan_status` to change it to "APPROVED". Two tool calls, coordinated automatically.

3. Test the conditional logic — what happens when the condition isn't met.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    # LOAN-12346 is PENDING, not UNDER_REVIEW — the agent should NOT approve
    response = agent.invoke({
        "messages": [("user", "Check loan LOAN-12346 and if it is under review, approve it")]
    })
    print(response["messages"][-1].content)
    </copy>
    ```

    The agent checks, sees "PENDING" (not "UNDER_REVIEW"), and correctly reports that no update was needed. This is the kind of reasoning that zero-shot prompts simply cannot do.

## Task 6: Compare the Three Levels

1. Review what you've learned.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    print("""
    ┌─────────────────┬──────────────────┬─────────────┬────────────────────┐
    │ Approach        │ Can Access Data  │ Can Modify   │ Can Coordinate     │
    ├─────────────────┼──────────────────┼─────────────┼────────────────────┤
    │ Zero-shot LLM   │ No               │ No           │ No                 │
    │ LLM + read tool │ Yes              │ No           │ No                 │
    │ LangChain Agent │ Yes              │ Yes          │ Yes (multi-step)   │
    └─────────────────┴──────────────────┴─────────────┴────────────────────┘
    """)
    </copy>
    ```

## Task 7: Clean Up

1. Drop the table when you're done.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    execute_ddl(conn, "DROP TABLE sample_loans PURGE")
    print("Cleanup complete.")
    </copy>
    ```

## Summary

You've now seen the three levels of AI capability:

* **Zero-shot**: The LLM guesses or admits ignorance. No data access at all.
* **Read-only**: The agent can look up real data but can't take action.
* **Read+write agent**: The agent can check conditions *and* act on them — a multi-step workflow in a single request.

The key insight: an agent with read+write tools and a clear system prompt can coordinate multi-step workflows that would otherwise require a human clicking through multiple screens.

You may now **proceed to the next lab**.

## Learn More

* [LangChain ReAct Pattern](https://python.langchain.com/docs/concepts/agents/)
* [Tool Calling in LangChain](https://python.langchain.com/docs/concepts/tool_calling/)
* [python-oracledb Documentation](https://python-oracledb.readthedocs.io/)

## Acknowledgements

* **Author** - David Start
* **Last Updated By/Date** - David Start, February 2026
