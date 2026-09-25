# How Agents Plan the Work

## Introduction

In the previous labs, your agent had one or two tools. But real work requires multiple tools and the judgment to know which ones to call and in what order. In this lab, you'll give an agent three tools and watch how it plans its approach.

You'll also see how system prompts can control the planning — from letting the LLM choose freely to enforcing a strict step-by-step sequence. This is the difference between an agent that "figures it out" and one that follows your business process every time.

### The Business Problem

At Seer Equity, a loan officer needs a complete picture of an applicant: their profile, their loans, and their rate eligibility. Today, that means checking three different screens. Tomorrow, the agent handles all three lookups in a single request.

But here's the catch: should the agent always check rate eligibility *after* looking up the applicant? Or can it call the tools in any order? The answer depends on your business process — and you'll see how to control that.

**Estimated Time**: 10 minutes

### Objectives

* Build an agent with three distinct tools
* Watch the agent plan which tools to call and in what order
* Compare a flexible agent (LLM chooses order) vs. a structured agent (controlled order)
* Understand how system prompts shape agent behavior

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

## Task 2: Create Multi-Table Data

The agent needs multiple tables to plan across. Let's create an applicant table and a loans table.

1. Create the tables and insert sample data.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    execute_ddl(conn, """
    CREATE TABLE demo_applicants (
        applicant_id    VARCHAR2(20) PRIMARY KEY,
        name            VARCHAR2(100),
        credit_tier     VARCHAR2(20),
        contact_email   VARCHAR2(100),
        contact_pref    VARCHAR2(20)
    )
    """)

    execute_ddl(conn, """
    CREATE TABLE demo_loans (
        loan_id       VARCHAR2(20) PRIMARY KEY,
        applicant_id  VARCHAR2(20),
        status        VARCHAR2(30),
        amount        NUMBER(12,2),
        loan_type     VARCHAR2(30),
        rate          NUMBER(5,2)
    )
    """)

    with conn.cursor() as cur:
        cur.executemany(
            "INSERT INTO demo_applicants VALUES (:1, :2, :3, :4, :5)",
            [
                ("APP-001", "Acme Corp",  "PREFERRED", "sarah@acme.com",     "EMAIL"),
                ("APP-002", "TechStart",  "STANDARD",  "info@techstart.com", "PHONE"),
            ],
        )
        cur.executemany(
            "INSERT INTO demo_loans VALUES (:1, :2, :3, :4, :5, :6)",
            [
                ("LOAN-100", "APP-001", "APPROVED",     150000, "Business", 7.9),
                ("LOAN-101", "APP-001", "PENDING",       75000, "Personal", 8.5),
                ("LOAN-102", "APP-002", "UNDER_REVIEW",  45000, "Auto",     9.9),
            ],
        )
    conn.commit()

    print("Created demo_applicants (2 rows) and demo_loans (3 rows).")
    </copy>
    ```

## Task 3: Build Three Tools

Each tool serves a different purpose. The agent will need to decide which combination to use.

1. Create tools for applicant lookup, loan history, and rate eligibility.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    @tool
    def get_applicant(applicant_id: str) -> str:
        """Get applicant details by ID (e.g. APP-001). Returns name, credit tier, contact info."""
        with conn.cursor() as cur:
            cur.execute("""
                SELECT 'Applicant: ' || name || ', Credit Tier: ' || credit_tier ||
                       ', Contact: ' || contact_email || ' (' || contact_pref || ')'
                FROM demo_applicants WHERE applicant_id = :id
            """, {"id": applicant_id})
            row = cur.fetchone()
        return row[0] if row else f"Applicant not found: {applicant_id}"


    @tool
    def get_applicant_loans(applicant_id: str) -> str:
        """Get all loans for an applicant. Returns loan IDs, statuses, amounts, and rates."""
        with conn.cursor() as cur:
            cur.execute("""
                SELECT loan_id, status, amount, loan_type, rate
                FROM demo_loans WHERE applicant_id = :id ORDER BY amount DESC
            """, {"id": applicant_id})
            rows = cur.fetchall()

        if not rows:
            return "No loans found for applicant."

        lines = [f"  {r[0]}: {r[1]}, ${r[2]:,.2f} {r[3]} at {r[4]}%" for r in rows]
        return f"Found {len(rows)} loans:\n" + "\n".join(lines)


    @tool
    def check_rate_eligibility(applicant_id: str) -> str:
        """Check rate eligibility for an applicant. Returns eligible rate tier and limits."""
        with conn.cursor() as cur:
            cur.execute(
                "SELECT credit_tier FROM demo_applicants WHERE applicant_id = :id",
                {"id": applicant_id},
            )
            row = cur.fetchone()

        if not row:
            return "Applicant not found."

        tier = row[0]
        tiers = {
            "PREFERRED": "PREFERRED RATES: Eligible for rates starting at 7.9% APR. Up to $500K limit.",
            "STANDARD":  "STANDARD RATES: Eligible for rates starting at 9.9% APR. Up to $100K limit.",
        }
        return tiers.get(tier, "SUBPRIME RATES: Rates starting at 14.9% APR. Up to $25K limit.")

    print("Tools created: get_applicant, get_applicant_loans, check_rate_eligibility")
    </copy>
    ```

## Task 4: Flexible Agent — LLM Chooses the Order

First, let's see what happens when you give the agent a vague system prompt and let it decide which tools to call.

1. Create a flexible agent and give it a broad request.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    FLEXIBLE_PROMPT = """You are a loan officer assistant for Seer Equity.
    Use your tools to look up applicant information, loan history, and rate eligibility.
    Always use the tools — never guess or make up information."""

    flexible_agent = create_react_agent(
        model=llm,
        tools=[get_applicant, get_applicant_loans, check_rate_eligibility],
        prompt=FLEXIBLE_PROMPT,
    )

    # The LLM decides which tools to call and in what order
    response = flexible_agent.invoke({
        "messages": [("user", "Give me a complete picture of applicant APP-001 including their loans and rate eligibility")]
    })

    # Show the planning trace
    print("=== Agent Planning Trace ===")
    for msg in response["messages"]:
        if hasattr(msg, "tool_calls") and msg.tool_calls:
            for tc in msg.tool_calls:
                print(f"  Step: {tc['name']}({tc['args']})")
    print()
    print("=== Final Answer ===")
    print(response["messages"][-1].content)
    </copy>
    ```

    The agent decided which tools to call and in what order. It might call all three, or it might call them in a different order than you expect. The LLM is planning on its own.

## Task 5: Structured Agent — Controlled Order

Now let's control the sequence. With a specific system prompt, you can force the agent to follow a predictable business process.

1. Create a structured agent with explicit ordering instructions.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    STRUCTURED_PROMPT = """You are a loan officer assistant for Seer Equity.

    For applicant inquiries, ALWAYS follow this exact sequence:
    1. First, look up the applicant using get_applicant
    2. Then, get their loans using get_applicant_loans
    3. Finally, check rate eligibility using check_rate_eligibility

    Report all findings. Never skip a step. Never guess."""

    structured_agent = create_react_agent(
        model=llm,
        tools=[get_applicant, get_applicant_loans, check_rate_eligibility],
        prompt=STRUCTURED_PROMPT,
    )

    # Now the agent follows a predictable sequence
    response = structured_agent.invoke({
        "messages": [("user", "Tell me about applicant APP-001")]
    })

    # Verify the order
    print("=== Structured Execution Order ===")
    step = 1
    for msg in response["messages"]:
        if hasattr(msg, "tool_calls") and msg.tool_calls:
            for tc in msg.tool_calls:
                print(f"  Step {step}: {tc['name']}({tc['args']})")
                step += 1
    print()
    print("=== Final Answer ===")
    print(response["messages"][-1].content)
    </copy>
    ```

    This time the agent follows the exact sequence: applicant first, then loans, then rate eligibility. Every time. The system prompt is your control mechanism.

## Task 6: Compare the Two Approaches

1. Think about when to use each approach.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    print("""
    ┌──────────────────┬──────────────────────────────┬──────────────────────────────┐
    │                  │ Flexible Agent                │ Structured Agent             │
    ├──────────────────┼──────────────────────────────┼──────────────────────────────┤
    │ Tool order       │ LLM decides                  │ You decide                   │
    │ Predictability   │ May vary between runs        │ Same sequence every time     │
    │ Best for         │ Exploration, ad-hoc queries  │ Regulated processes          │
    │ Risk             │ May skip steps               │ May call unnecessary tools   │
    │ Business use     │ Research, discovery           │ Compliance, auditing         │
    └──────────────────┴──────────────────────────────┴──────────────────────────────┘

    At Seer Equity, loan processing needs the structured approach.
    When a compliance officer asks "did you check rate eligibility?",
    the answer should always be "yes" — because the agent always does it.
    """)
    </copy>
    ```

## Task 7: Clean Up

1. Drop the tables when you're done.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    execute_ddl(conn, "DROP TABLE demo_loans PURGE")
    execute_ddl(conn, "DROP TABLE demo_applicants PURGE")
    print("Cleanup complete.")
    </copy>
    ```

## Summary

You've learned how agents plan their work:

* **Flexible agents** let the LLM choose which tools to call and in what order — great for exploration.
* **Structured agents** use system prompts to enforce a specific sequence — essential for regulated business processes.
* The **system prompt** is your primary control mechanism. It's not just a personality description — it's a behavior specification.

The key insight: **the system prompt is where business logic meets AI**. A well-crafted prompt turns a general-purpose LLM into a predictable, auditable business tool.

You may now **proceed to the next lab**.

## Learn More

* [LangChain Agent Concepts](https://python.langchain.com/docs/concepts/agents/)
* [Prompt Engineering for Agents](https://python.langchain.com/docs/concepts/prompt_templates/)
* [LangGraph Documentation](https://langchain-ai.github.io/langgraph/)

## Acknowledgements

* **Author** - David Start
* **Last Updated By/Date** - David Start, February 2026
