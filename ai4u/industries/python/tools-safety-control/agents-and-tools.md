# Tools, Safety, and Human Control

## Introduction

You've built agents that can query data, update records, store memories, and search by meaning. But in production, there's a critical question: **who can do what?**

In this capstone lab, you'll build two agents with different tool sets. A loan officer agent can submit applications but cannot approve them. An underwriter agent can review and approve but cannot submit. This is **separation of duties** — a compliance requirement that most AI systems ignore.

The key insight: security through architecture, not through prompts. The loan officer agent literally doesn't have an `approve_loan` tool. No prompt injection can make it approve a loan because the capability doesn't exist.

### The Business Problem

Seer Equity's compliance team has been worried: their current systems don't enforce separation of duties between loan submission and approval. It's just a policy that people are supposed to follow. One mistake away from a regulatory disaster.

In this lab, you'll build the solution: two agents with distinct toolsets, JSON-configured business rules, and a complete audit trail.

**Estimated Time**: 20 minutes

### Objectives

* Create a production loan processing schema with applicants, applications, and rules
* Build a JSON-configured rules engine for underwriting decisions
* Create a loan officer agent (submit only) and an underwriter agent (approve/deny only)
* Process loans through both agents and view the audit trail
* Understand separation of duties through tool-level access control

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

## Task 2: Create the Production Schema

This is the most complete schema in the workshop: applicants, applications with constraints, and a rules engine.

1. Create the tables and sequence.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    execute_ddl(conn, "CREATE SEQUENCE loan_app_seq START WITH 1001")

    execute_ddl(conn, """
    CREATE TABLE loan_applicants (
        applicant_id    VARCHAR2(20) PRIMARY KEY,
        name            VARCHAR2(100) NOT NULL,
        email           VARCHAR2(100) NOT NULL,
        credit_score    NUMBER(3) NOT NULL,
        annual_income   NUMBER(12,2),
        employment_years NUMBER(2)
    )
    """)

    execute_ddl(conn, """
    CREATE TABLE loan_applications (
        application_id  VARCHAR2(20) PRIMARY KEY,
        applicant_id    VARCHAR2(20) NOT NULL REFERENCES loan_applicants(applicant_id),
        loan_amount     NUMBER(12,2) NOT NULL,
        loan_type       VARCHAR2(50) NOT NULL,
        loan_purpose    VARCHAR2(500),
        risk_status     VARCHAR2(30) DEFAULT 'PENDING_REVIEW',
        submitted_at    TIMESTAMP DEFAULT SYSTIMESTAMP,
        decided_by      VARCHAR2(100),
        decided_at      TIMESTAMP,
        CONSTRAINT chk_positive CHECK (loan_amount > 0),
        CONSTRAINT chk_type CHECK (loan_type IN ('personal','auto','mortgage','business')),
        CONSTRAINT chk_status CHECK (risk_status IN ('APPROVED','DENIED','PENDING_REVIEW','AUTO_APPROVED'))
    )
    """)

    execute_ddl(conn, """
    CREATE TABLE underwriting_rules (
        rule_id      RAW(16) DEFAULT SYS_GUID() PRIMARY KEY,
        rule_name    VARCHAR2(200) NOT NULL,
        rule_type    VARCHAR2(20) NOT NULL,
        rule_config  JSON NOT NULL,
        priority     NUMBER DEFAULT 100,
        is_active    NUMBER(1) DEFAULT 1,
        CONSTRAINT chk_rule_type CHECK (rule_type IN ('BLOCK','REQUIRE_REVIEW','AUTO_APPROVE'))
    )
    """)

    print("Production schema created: loan_applicants, loan_applications, underwriting_rules")
    </copy>
    ```

## Task 3: Seed Applicants and Rules

1. Insert applicant data and JSON-configured underwriting rules.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    with conn.cursor() as cur:
        cur.executemany(
            "INSERT INTO loan_applicants VALUES (:1, :2, :3, :4, :5, :6)",
            [
                ("APP-001", "Alice Johnson", "alice@email.com", 780, 95000,  8),
                ("APP-002", "Bob Smith",     "bob@email.com",   695, 62000,  3),
                ("APP-003", "Carol Davis",   "carol@email.com", 520, 45000,  1),
                ("APP-004", "David Chen",    "david@email.com", 725, 120000, 12),
            ],
        )
    conn.commit()

    # JSON-configured underwriting rules (priority-ordered)
    rules = [
        ("Block High Risk - Low Credit", "BLOCK", 10,
         '{"field": "credit_score", "operator": "lt", "value": 550, '
         '"message": "Credit score below 550 does not meet minimum requirements."}'),
        ("Large Loan Review", "REQUIRE_REVIEW", 20,
         '{"field": "loan_amount", "operator": "gte", "value": 50000, '
         '"message": "Loans $50,000+ require underwriter review."}'),
        ("Mortgage Review", "REQUIRE_REVIEW", 30,
         '{"field": "loan_type", "operator": "eq", "value": "mortgage", '
         '"message": "All mortgage applications require underwriter review."}'),
        ("Borderline Credit Review", "REQUIRE_REVIEW", 40,
         '{"field": "credit_score", "operator": "between", "low": 550, "high": 650, '
         '"message": "Credit scores 550-650 require underwriter review."}'),
        ("Auto-approve Standard", "AUTO_APPROVE", 100,
         '{"field": "loan_amount", "operator": "lt", "value": 50000, '
         '"message": "Loans under $50K with good credit are auto-approved."}'),
    ]

    with conn.cursor() as cur:
        for name, rtype, priority, config in rules:
            cur.execute("""
                INSERT INTO underwriting_rules (rule_name, rule_type, rule_config, priority)
                VALUES (:name, :rtype, :config, :priority)
            """, {"name": name, "rtype": rtype, "config": config, "priority": priority})
    conn.commit()

    print("Seeded: 4 applicants, 5 underwriting rules")
    </copy>
    ```

    >**Note:** The underwriting rules are stored as JSON in Oracle 26ai. This means business users can modify the rules without changing code — just update the JSON. The rules engine evaluates them in priority order.

## Task 4: Build the Rules Engine

The rules engine reads JSON-configured rules from Oracle 26ai and evaluates them in priority order.

1. Create the rules engine function.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    def check_underwriting_rules(loan_amount: float, loan_type: str, credit_score: int) -> dict:
        """Evaluate underwriting rules in priority order. Returns the first matching rule."""
        with conn.cursor() as cur:
            cur.execute("""
                SELECT rule_name, rule_type, rule_config
                FROM underwriting_rules WHERE is_active = 1 ORDER BY priority
            """)
            rows = cur.fetchall()

        for rule_name, rule_type, rule_config_raw in rows:
            config_str = rule_config_raw.read() if hasattr(rule_config_raw, "read") else str(rule_config_raw)
            config = json.loads(config_str)

            field = config["field"]
            op = config["operator"]
            match = False

            if field == "loan_amount":
                if op == "gte" and loan_amount >= config["value"]:
                    match = True
                elif op == "lt" and loan_amount < config["value"]:
                    match = True
            elif field == "loan_type":
                if op == "eq" and loan_type.lower() == config["value"].lower():
                    match = True
            elif field == "credit_score":
                if op == "lt" and credit_score < config["value"]:
                    match = True
                elif op == "between" and config["low"] <= credit_score <= config["high"]:
                    match = True

            if match:
                return {"action": rule_type, "rule": rule_name, "message": config["message"]}

        return {"action": "AUTO_APPROVE", "message": "Meets all automated approval criteria."}

    print("Rules engine created.")
    </copy>
    ```

## Task 5: Build the Loan Officer Tools (Submit Only)

The loan officer agent can submit applications but has no ability to approve or deny them.

1. Create the submit tool.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    @tool
    def submit_loan_application(
        applicant_id: str, loan_amount: float, loan_type: str, loan_purpose: str
    ) -> str:
        """Submit a loan application. Parameters: applicant_id (e.g. APP-001),
        loan_amount (number), loan_type (personal/auto/mortgage/business),
        loan_purpose (description)."""
        # Look up applicant
        with conn.cursor() as cur:
            cur.execute(
                "SELECT credit_score FROM loan_applicants WHERE applicant_id = :id",
                {"id": applicant_id},
            )
            row = cur.fetchone()

        if not row:
            return json.dumps({"error": f"Applicant not found: {applicant_id}"})

        credit_score = row[0]

        # Check rules
        rule_result = check_underwriting_rules(loan_amount, loan_type, credit_score)

        if rule_result["action"] == "BLOCK":
            return json.dumps({"error": "BLOCKED", "message": rule_result["message"]})

        status = "AUTO_APPROVED" if rule_result["action"] == "AUTO_APPROVE" else "PENDING_REVIEW"

        # Generate application ID
        with conn.cursor() as cur:
            cur.execute("SELECT loan_app_seq.NEXTVAL FROM DUAL")
            seq = cur.fetchone()[0]
            cur.execute("SELECT TO_CHAR(SYSDATE, 'YYMMDD') FROM DUAL")
            ds = cur.fetchone()[0]
            app_id = f"LOAN-{ds}-{seq}"

            cur.execute("""
                INSERT INTO loan_applications
                (application_id, applicant_id, loan_amount, loan_type, loan_purpose,
                 risk_status, decided_by, decided_at)
                VALUES (:id, :aid, :amt, :lt, :lp, :status,
                        CASE WHEN :status2 = 'AUTO_APPROVED' THEN 'SYSTEM' ELSE NULL END,
                        CASE WHEN :status3 = 'AUTO_APPROVED' THEN SYSTIMESTAMP ELSE NULL END)
            """, {
                "id": app_id, "aid": applicant_id, "amt": loan_amount,
                "lt": loan_type.lower(), "lp": loan_purpose, "status": status,
                "status2": status, "status3": status,
            })
        conn.commit()

        msg = "Auto-approved." if status == "AUTO_APPROVED" else "Submitted for underwriter review."
        return json.dumps({
            "application_id": app_id, "status": status,
            "credit_score": credit_score, "message": msg,
        })

    print("Loan officer tool created: submit_loan_application")
    </copy>
    ```

## Task 6: Build the Underwriter Tools (Review/Approve/Deny Only)

The underwriter agent can see pending applications and approve or deny them, but cannot submit new ones.

1. Create the underwriter tools.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    @tool
    def get_pending_reviews() -> str:
        """Get list of loan applications waiting for underwriting review."""
        with conn.cursor() as cur:
            cur.execute("""
                SELECT la.application_id, ap.name, ap.credit_score,
                       la.loan_amount, la.loan_type, la.loan_purpose,
                       TO_CHAR(la.submitted_at, 'YYYY-MM-DD HH24:MI')
                FROM loan_applications la
                JOIN loan_applicants ap ON la.applicant_id = ap.applicant_id
                WHERE la.risk_status = 'PENDING_REVIEW'
                ORDER BY la.submitted_at
            """)
            rows = cur.fetchall()

        if not rows:
            return json.dumps({"message": "No loan applications pending review."})

        apps = []
        for app_id, name, credit, amount, ltype, purpose, submitted in rows:
            purpose_str = purpose.read() if hasattr(purpose, "read") else str(purpose) if purpose else "N/A"
            apps.append({
                "application_id": app_id, "applicant": name,
                "credit_score": credit, "amount": float(amount),
                "type": ltype, "purpose": purpose_str, "submitted": submitted,
            })
        return json.dumps(apps, indent=2)


    @tool
    def approve_loan(application_id: str) -> str:
        """Approve a loan application that is pending review."""
        with conn.cursor() as cur:
            cur.execute(
                "SELECT risk_status FROM loan_applications WHERE application_id = :id",
                {"id": application_id},
            )
            row = cur.fetchone()

            if not row:
                return json.dumps({"error": f"Application not found: {application_id}"})
            if row[0] != "PENDING_REVIEW":
                return json.dumps({"error": f"Cannot approve. Current status is {row[0]}."})

            cur.execute("""
                UPDATE loan_applications
                SET risk_status = 'APPROVED', decided_by = 'UNDERWRITER', decided_at = SYSTIMESTAMP
                WHERE application_id = :id
            """, {"id": application_id})
        conn.commit()

        return json.dumps({"application_id": application_id, "status": "APPROVED", "approved_by": "UNDERWRITER"})


    @tool
    def deny_loan(application_id: str) -> str:
        """Deny a loan application that is pending review."""
        with conn.cursor() as cur:
            cur.execute(
                "SELECT risk_status FROM loan_applications WHERE application_id = :id",
                {"id": application_id},
            )
            row = cur.fetchone()

            if not row:
                return json.dumps({"error": f"Application not found: {application_id}"})
            if row[0] != "PENDING_REVIEW":
                return json.dumps({"error": f"Cannot deny. Current status is {row[0]}."})

            cur.execute("""
                UPDATE loan_applications
                SET risk_status = 'DENIED', decided_by = 'UNDERWRITER', decided_at = SYSTIMESTAMP
                WHERE application_id = :id
            """, {"id": application_id})
        conn.commit()

        return json.dumps({"application_id": application_id, "status": "DENIED", "denied_by": "UNDERWRITER"})

    print("Underwriter tools created: get_pending_reviews, approve_loan, deny_loan")
    </copy>
    ```

## Task 7: Create Two Separate Agents

This is where separation of duties is enforced. Each agent gets a different set of tools.

1. Create the loan officer and underwriter agents.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    # ── LOAN OFFICER AGENT: can submit, CANNOT approve/deny ──────────────
    loan_officer_agent = create_react_agent(
        model=llm,
        tools=[submit_loan_application],  # Only submit — no approve/deny tools
        prompt="""You are a loan submission agent for Seer Equity loan officers.
    When asked to submit a loan application, call submit_loan_application.
    Report the result clearly — whether it was auto-approved, needs review, or was blocked.""",
    )

    # ── UNDERWRITER AGENT: can review/approve/deny, CANNOT submit ────────
    underwriter_agent = create_react_agent(
        model=llm,
        tools=[get_pending_reviews, approve_loan, deny_loan],  # No submit tool
        prompt="""You are an underwriting agent for Seer Equity.
    You can list pending loan applications, approve them, or deny them.
    When asked what needs review, call get_pending_reviews.
    When asked to approve, call approve_loan. When asked to deny, call deny_loan.""",
    )

    print("""
    Separation of Duties:
    ┌──────────────────────┬────────┬──────────────┬─────────┬────────┐
    │ Agent                │ Submit │ Get Pending  │ Approve │ Deny   │
    ├──────────────────────┼────────┼──────────────┼─────────┼────────┤
    │ Loan Officer Agent   │   Yes  │      No      │    No   │   No   │
    │ Underwriter Agent    │   No   │      Yes     │    Yes  │   Yes  │
    └──────────────────────┴────────┴──────────────┴─────────┴────────┘

    The Loan Officer Agent literally doesn't have approval tools.
    This is security through architecture, not through prompts.
    """)
    </copy>
    ```

## Task 8: Loan Officer Path — Submit Applications

The loan officer submits four applications. Some auto-approve, some need review, some get blocked.

1. Submit the applications.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    submissions = [
        "Submit a $25,000 personal loan for applicant APP-001 for debt consolidation",
        "Submit a $75,000 personal loan for applicant APP-004 for home renovation",
        "Submit a $250,000 mortgage for applicant APP-001 for primary residence purchase",
        "Submit a $20,000 auto loan for applicant APP-003 for a used car purchase",
    ]

    print("=== Loan Officer Submissions ===")
    for req in submissions:
        response = loan_officer_agent.invoke({"messages": [("user", req)]})
        print(f"\nRequest: {req}")
        print(f"Result: {response['messages'][-1].content}")
    </copy>
    ```

    Expected outcomes:
    * **APP-001, $25K personal**: Auto-approved (under $50K, good credit)
    * **APP-004, $75K personal**: Pending review (over $50K)
    * **APP-001, $250K mortgage**: Pending review (mortgage requires review)
    * **APP-003, $20K auto**: Blocked (credit score 520 < 550 minimum)

## Task 9: Underwriter Path — Review and Decide

Now the underwriter agent reviews what's pending and makes decisions.

1. Review and approve applications.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    print("\n=== Underwriter Review ===")

    # See what needs review
    response = underwriter_agent.invoke({
        "messages": [("user", "What loan applications need my review?")]
    })
    print(response["messages"][-1].content)
    </copy>
    ```

2. Approve the pending applications.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    # Approve the personal loan
    response = underwriter_agent.invoke({
        "messages": [("user", "Approve the personal loan application")]
    })
    print(response["messages"][-1].content)

    # Approve the mortgage
    response = underwriter_agent.invoke({
        "messages": [("user", "Approve the mortgage application")]
    })
    print(response["messages"][-1].content)
    </copy>
    ```

## Task 10: View the Audit Trail

Every decision is recorded in Oracle 26ai with who decided and when.

1. Query the complete audit trail.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    with conn.cursor() as cur:
        cur.execute("""
            SELECT application_id, applicant_id, loan_amount, loan_type,
                   risk_status, decided_by,
                   TO_CHAR(decided_at, 'YYYY-MM-DD HH24:MI:SS') as decided_at
            FROM loan_applications ORDER BY submitted_at
        """)
        rows = cur.fetchall()

    print("\n=== Complete Audit Trail (Oracle 26ai) ===")
    for app_id, appl_id, amount, ltype, status, decided_by, decided_at in rows:
        print(f"  {app_id}: {appl_id}, ${amount:,.2f} {ltype} -> {status} (by {decided_by or 'PENDING'}, {decided_at or 'N/A'})")
    </copy>
    ```

    The audit trail shows exactly who decided what and when:
    * Auto-approved loans show `decided_by = SYSTEM`
    * Underwriter-approved loans show `decided_by = UNDERWRITER`
    * Blocked applications don't make it into the table at all

## Task 11: Clean Up

1. Drop all objects when you're done.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    execute_ddl(conn, "DROP TABLE loan_applications PURGE")
    execute_ddl(conn, "DROP TABLE loan_applicants PURGE")
    execute_ddl(conn, "DROP TABLE underwriting_rules PURGE")
    execute_ddl(conn, "DROP SEQUENCE loan_app_seq")
    print("Cleanup complete.")
    </copy>
    ```

## Summary

You've built a complete, production-ready loan processing system with:

* **Separation of duties**: Loan officers submit, underwriters approve — enforced at the tool level
* **JSON-configured rules**: Business rules stored in Oracle 26ai, modifiable without code changes
* **Risk-based routing**: Auto-approve, review, or block based on credit score, amount, and type
* **Complete audit trail**: Every decision recorded with who, what, and when

The separation of duties model:

| Capability | Loan Officer Agent | Underwriter Agent |
|---|---|---|
| Submit applications | Yes | No |
| View pending reviews | No | Yes |
| Approve loans | No | Yes |
| Deny loans | No | Yes |

The key insight: **security through architecture beats security through prompts**. You can't prompt-inject an agent into using a tool it doesn't have. The loan officer agent physically cannot approve a loan — the function doesn't exist in its toolset.

Congratulations — you've completed the workshop!

## Learn More

* [LangChain Agent Security](https://python.langchain.com/docs/concepts/agents/)
* [Oracle Database Security](https://docs.oracle.com/en/database/oracle/oracle-database/)
* [Richmond Alake: Memory Substrate for AI Agents](https://medium.com/@richmondalake)
* [LangGraph Multi-Agent Patterns](https://langchain-ai.github.io/langgraph/)

## Acknowledgements

* **Author** - David Start
* **Last Updated By/Date** - David Start, February 2026
