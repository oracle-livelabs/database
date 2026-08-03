# How Agents Actually Get Work Done

## Introduction

You've seen agents look up data, update records, and plan across multiple tools. Now it's time to build a real workflow — the kind that Seer Equity runs every day.

In this lab, you'll build a complete loan processing pipeline: create a loan request, assess its risk, and route it to the right handler. The agent coordinates the entire workflow, and every step is logged in Oracle 26ai for auditing.

### The Business Problem

At Seer Equity, every loan application goes through the same manual process — whether it's a $25,000 personal loan for a customer with perfect credit or a $450,000 mortgage that genuinely needs scrutiny. There's no smart routing. A $25,000 loan with a 780 credit score shouldn't require the same review as a complex mortgage. But without an automated risk assessment, everything gets the same treatment.

In this lab, you'll build the agent that fixes this.

**Estimated Time**: 15 minutes

### Objectives

* Build workflow tools that create, assess, and route loan requests
* Implement business rules for risk-based routing
* Watch an agent process loans through all four risk paths
* See every step logged in an audit trail in Oracle 26ai

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
    import json
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

## Task 2: Create the Workflow Tables

The agent needs three things: a sequence for generating IDs, a log table for auditing, and a loan requests table.

1. Create the workflow schema.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    execute_ddl(conn, """
    CREATE SEQUENCE loan_requests_seq START WITH 1001
    """)

    execute_ddl(conn, """
    CREATE TABLE workflow_log (
        log_id      NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
        step_name   VARCHAR2(100),
        step_detail VARCHAR2(500),
        logged_at   TIMESTAMP DEFAULT SYSTIMESTAMP
    )
    """)

    execute_ddl(conn, """
    CREATE TABLE loan_requests (
        request_id    VARCHAR2(20) PRIMARY KEY,
        applicant     VARCHAR2(100),
        amount        NUMBER(12,2),
        loan_type     VARCHAR2(50),
        credit_score  NUMBER(3),
        risk_level    VARCHAR2(30),
        status        VARCHAR2(30) DEFAULT 'NEW',
        routed_to     VARCHAR2(50),
        created_at    TIMESTAMP DEFAULT SYSTIMESTAMP
    )
    """)

    print("Workflow schema created: loan_requests_seq, workflow_log, loan_requests")
    </copy>
    ```

## Task 3: Build the Workflow Tools

These tools implement Seer Equity's loan processing pipeline. The first tool creates a loan request. The second assesses risk and routes it.

1. Build the create and route tools.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    @tool
    def create_loan_request(
        applicant: str, amount: float, loan_type: str, credit_score: int
    ) -> str:
        """Create a new loan request. Parameters: applicant (name), amount (dollar amount),
        loan_type (personal, auto, mortgage, or business), credit_score (300-850).
        Returns the new request ID."""
        with conn.cursor() as cur:
            cur.execute("SELECT loan_requests_seq.NEXTVAL FROM DUAL")
            seq_val = cur.fetchone()[0]

            cur.execute("SELECT TO_CHAR(SYSDATE, 'YYMMDD') FROM DUAL")
            date_str = cur.fetchone()[0]

            request_id = f"LN-{date_str}-{seq_val}"

            # Log the creation
            cur.execute("""
                INSERT INTO workflow_log (step_name, step_detail)
                VALUES ('CREATE_REQUEST', :detail)
            """, {"detail": f"Created {request_id} for {applicant}, ${amount} {loan_type}, Credit: {credit_score}"})

            # Insert the request
            cur.execute("""
                INSERT INTO loan_requests (request_id, applicant, amount, loan_type, credit_score, status)
                VALUES (:id, :applicant, :amount, :loan_type, :credit, 'SUBMITTED')
            """, {
                "id": request_id, "applicant": applicant,
                "amount": amount, "loan_type": loan_type.lower(), "credit": credit_score,
            })
        conn.commit()

        return f"Created loan request {request_id} for ${amount:,.2f} {loan_type}"


    @tool
    def assess_and_route(request_id: str) -> str:
        """Assess risk and route a loan request. Parameter: request_id (the LN-YYMMDD-NNNN ID).
        Returns the routing decision."""
        with conn.cursor() as cur:
            cur.execute("""
                SELECT amount, loan_type, credit_score
                FROM loan_requests WHERE request_id = :id
            """, {"id": request_id})
            row = cur.fetchone()

        if not row:
            return f"Request not found: {request_id}"

        amount, loan_type, credit_score = row

        # ── Business Rules ────────────────────────────────────────────
        if credit_score < 550:
            risk_level = "BLOCKED"
            route_to = "REJECTED"
            result = f"BLOCKED: Credit score {credit_score} below minimum 550."
        elif loan_type == "personal" and amount < 50000 and credit_score >= 700:
            risk_level = "LOW"
            route_to = "AUTO_APPROVED"
            result = f"AUTO_APPROVED: Personal loan under $50K with credit {credit_score}."
        elif amount < 250000 and loan_type != "mortgage":
            risk_level = "MEDIUM"
            route_to = "UNDERWRITER"
            result = f"Routed to UNDERWRITER: ${amount:,.2f} {loan_type} requires review."
        else:
            risk_level = "HIGH"
            route_to = "SENIOR_UNDERWRITER"
            result = f"Routed to SENIOR_UNDERWRITER: ${amount:,.2f} {loan_type} requires senior review."

        # ── Log and update ────────────────────────────────────────────
        final_status = route_to if route_to in ("AUTO_APPROVED", "REJECTED") else "PENDING_REVIEW"

        with conn.cursor() as cur:
            cur.execute("""
                INSERT INTO workflow_log (step_name, step_detail)
                VALUES ('ROUTE_DECISION', :detail)
            """, {"detail": f"{request_id} -> {route_to} (Risk: {risk_level})"})

            cur.execute("""
                UPDATE loan_requests
                SET risk_level = :risk, routed_to = :route, status = :status
                WHERE request_id = :id
            """, {"risk": risk_level, "route": route_to, "status": final_status, "id": request_id})
        conn.commit()

        return result

    print("Tools created: create_loan_request, assess_and_route")
    </copy>
    ```

    >**Note:** The business rules encode Seer Equity's routing logic. Low-risk personal loans auto-approve. Large loans or mortgages go to senior underwriters. Credit scores below 550 are blocked entirely.

## Task 4: Create the Execution Agent

1. Create the agent with a prompt that enforces the two-step workflow.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    SYSTEM_PROMPT = """You are a loan processing agent for Seer Equity.
    Process loans by:
    1. Creating the request with create_loan_request
    2. Assessing and routing with assess_and_route using the returned request ID
    Always complete both steps."""

    agent = create_react_agent(
        model=llm,
        tools=[create_loan_request, assess_and_route],
        prompt=SYSTEM_PROMPT,
    )

    print("Loan processing agent created.")
    </copy>
    ```

## Task 5: Process Loans and Observe the Workflow

Now process four different loans, each designed to hit a different risk path.

1. Clear the log and process all four test cases.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    execute_ddl(conn, "TRUNCATE TABLE workflow_log")

    test_cases = [
        "Process a $35,000 personal loan for John Smith with credit score 780",
        "Process a $150,000 business loan for Acme Corp with credit score 720",
        "Process a $450,000 mortgage for Jane Doe with credit score 750",
        "Process a $25,000 personal loan for Bob Wilson with credit score 520",
    ]

    for question in test_cases:
        print(f"\n{'='*60}")
        print(f"Request: {question}")
        response = agent.invoke({"messages": [("user", question)]})
        print(f"Result: {response['messages'][-1].content}")
    </copy>
    ```

    You should see four different outcomes:
    * **John Smith** ($35K personal, 780 credit) → AUTO_APPROVED
    * **Acme Corp** ($150K business, 720 credit) → UNDERWRITER
    * **Jane Doe** ($450K mortgage, 750 credit) → SENIOR_UNDERWRITER
    * **Bob Wilson** ($25K personal, 520 credit) → REJECTED

## Task 6: View the Workflow Log

Every step the agent took was logged in Oracle 26ai. This is the audit trail that Seer Equity's compliance team needs.

1. Query the workflow log.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    with conn.cursor() as cur:
        cur.execute("SELECT step_name, step_detail, logged_at FROM workflow_log ORDER BY logged_at")
        rows = cur.fetchall()

    print("\n=== Workflow Log (stored in Oracle 26ai) ===")
    for step_name, step_detail, logged_at in rows:
        print(f"  [{step_name}] {step_detail}")
    </copy>
    ```

    Every creation and every routing decision is recorded. When compliance asks "why was this loan auto-approved?", the log has the answer.

## Task 7: Clean Up

1. Drop the workflow objects when you're done.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    execute_ddl(conn, "DROP TABLE loan_requests PURGE")
    execute_ddl(conn, "DROP TABLE workflow_log PURGE")
    execute_ddl(conn, "DROP SEQUENCE loan_requests_seq")
    print("Cleanup complete.")
    </copy>
    ```

## Summary

You've built a complete loan processing workflow where the agent:

* **Creates** loan requests with auto-generated IDs
* **Assesses** risk using business rules (credit score + loan amount + loan type)
* **Routes** to the right handler (auto-approve, underwriter, senior underwriter, or reject)
* **Logs** every step in Oracle 26ai for auditing

The four risk paths you tested:

| Loan | Credit | Route | Why |
|------|--------|-------|-----|
| $35K Personal | 780 | Auto-approved | Low risk: small personal loan, excellent credit |
| $150K Business | 720 | Underwriter | Medium risk: large business loan |
| $450K Mortgage | 750 | Senior Underwriter | High risk: large mortgage |
| $25K Personal | 520 | Rejected | Blocked: credit below 550 minimum |

The key insight: **agents can enforce business rules consistently**. The same routing logic applies every time, and every decision is logged.

You may now **proceed to the next lab**.

## Learn More

* [LangChain Tool Calling](https://python.langchain.com/docs/concepts/tool_calling/)
* [Building Workflows with LangGraph](https://langchain-ai.github.io/langgraph/)
* [python-oracledb Documentation](https://python-oracledb.readthedocs.io/)

## Acknowledgements

* **Author** - David Start
* **Last Updated By/Date** - David Start, February 2026
