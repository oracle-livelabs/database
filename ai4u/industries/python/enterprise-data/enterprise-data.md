# Why Enterprise Data Matters

## Introduction

In the last lab, you saw that agents forget between sessions. But there's another problem: even within a session, a generic LLM doesn't know *your* business. It doesn't know Seer Equity's rates, policies, or clients. Ask it "What rate does a preferred customer get?" and it will either hallucinate an answer or admit it doesn't know.

In this lab, you'll connect the agent to enterprise data in Oracle 26ai — real policy tables and applicant records. The difference between a generic chatbot and a useful business tool is access to your data.

### The Business Problem

Seer Equity's loan officers tried asking the AI chatbot about the company's rate tiers. The chatbot confidently answered with rates it made up — rates that don't match any of Seer Equity's actual policies. A loan officer quoted these hallucinated rates to a client, who later discovered the real rates were different. Trust in the AI tool plummeted.

The problem: the LLM was trained on the internet, not on Seer Equity's internal rate tables.

**Estimated Time**: 10 minutes

### Objectives

* See a generic LLM hallucinate (or refuse to answer) about company-specific data
* Create enterprise data tables in Oracle 26ai (policies and applicants)
* Build tools that give the agent access to real business data
* Watch the agent give correct, data-backed answers

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

## Task 2: Show What the LLM Doesn't Know

Before connecting to any data, ask the LLM about Seer Equity's rates. Watch what happens.

1. Ask the LLM directly — no tools.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    response = llm.invoke("What interest rates does Seer Equity offer for preferred customers?")
    print("LLM (no tools) says:")
    print(response.content)
    </copy>
    ```

    The LLM will either make up rates or say it doesn't have that information. Either way, it's useless for a loan officer who needs the real answer.

## Task 3: Create Enterprise Data Tables

Now let's create the data that the agent needs: loan policies and applicant records.

1. Create the policy and applicant tables.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    execute_ddl(conn, """
    CREATE TABLE loan_policies (
        policy_id    VARCHAR2(20) PRIMARY KEY,
        policy_name  VARCHAR2(100),
        policy_text  CLOB,
        rate_tier    VARCHAR2(50),
        loan_types   VARCHAR2(200)
    )
    """)

    execute_ddl(conn, """
    CREATE TABLE se_applicants (
        applicant_id      VARCHAR2(20) PRIMARY KEY,
        name              VARCHAR2(100),
        company           VARCHAR2(100),
        credit_score      NUMBER(3),
        rate_tier         VARCHAR2(20),
        client_since      DATE,
        rate_exception    NUMBER(5,2),
        total_loans       NUMBER(3)
    )
    """)

    print("Tables created: loan_policies, se_applicants")
    </copy>
    ```

2. Insert Seer Equity's actual policies and applicant data.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    with conn.cursor() as cur:
        cur.execute("""
            INSERT INTO loan_policies VALUES ('POL-PREF', 'Preferred Rate Tier',
            'Preferred rate is 7.9% APR for customers with credit score 750+. '||
            'Maximum loan amount $500,000. Requires 20% down payment for mortgages. '||
            'Rate exception up to 15% discount available for clients with 5+ year history.',
            'PREFERRED', 'Personal, Auto, Mortgage, Business')
        """)
        cur.execute("""
            INSERT INTO loan_policies VALUES ('POL-STD', 'Standard Rate Tier',
            'Standard rate is 12.9% APR for customers with credit score 650-749. '||
            'Maximum loan amount $250,000. Requires 25% down payment for mortgages. '||
            'No rate exceptions available for this tier.',
            'STANDARD', 'Personal, Auto, Business')
        """)
        cur.execute("""
            INSERT INTO loan_policies VALUES ('POL-CREDIT', 'Credit Requirements',
            'Minimum credit score 550 for any loan consideration. '||
            'Credit score 750+ qualifies for Preferred tier. '||
            'Credit score 650-749 qualifies for Standard tier. '||
            'Credit score below 650 requires additional documentation and cosigner.',
            'ALL', 'All loan types')
        """)
    conn.commit()

    with conn.cursor() as cur:
        cur.executemany("""
            INSERT INTO se_applicants VALUES (:1, :2, :3, :4, :5, TO_DATE(:6, 'YYYY-MM-DD'), :7, :8)
        """, [
            ("APP-001", "Sarah Chen", "Acme Industries", 780, "PREFERRED", "2019-03-15", 15, 8),
            ("APP-002", "TechStart LLC", None,            710, "STANDARD",  "2022-06-01", None, 2),
            ("APP-003", "GlobalCo",      None,            620, "STANDARD",  "2024-01-10", None, 1),
        ])
    conn.commit()

    print("Seeded: 3 policies, 3 applicants")
    </copy>
    ```

## Task 4: Build Enterprise Data Tools

These tools give the agent access to Seer Equity's real data. The key instruction: **always use the tools, never guess at rates**.

1. Create the policy and applicant lookup tools.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    @tool
    def get_loan_policy(policy_type: str, rate_tier: str = None) -> str:
        """Look up Seer Equity loan policies. Parameters: policy_type (e.g. rate, credit,
        preferred, standard), rate_tier (PREFERRED or STANDARD, optional).
        Always use this to answer policy questions — never guess at rates."""
        with conn.cursor() as cur:
            sql = """
                SELECT policy_name, policy_text, rate_tier FROM loan_policies
                WHERE (UPPER(policy_name) LIKE '%' || UPPER(:ptype) || '%'
                       OR UPPER(policy_text) LIKE '%' || UPPER(:ptype) || '%')
            """
            params = {"ptype": policy_type}
            if rate_tier:
                sql += " AND (rate_tier = :tier OR rate_tier = 'ALL')"
                params["tier"] = rate_tier
            cur.execute(sql, params)
            rows = cur.fetchall()

        if not rows:
            return f"No policy found for: {policy_type}"

        result = ""
        for name, text, tier in rows:
            text_str = text.read() if hasattr(text, "read") else str(text)
            result += f"{name} ({tier}): {text_str}\n\n"
        return result


    @tool
    def get_applicant_info(applicant_name: str) -> str:
        """Look up applicant information by name. Returns credit score, rate tier,
        client history, and any rate exceptions."""
        with conn.cursor() as cur:
            cur.execute("""
                SELECT name, company, credit_score, rate_tier,
                       TO_CHAR(client_since, 'YYYY-MM-DD'), rate_exception, total_loans
                FROM se_applicants
                WHERE UPPER(name) LIKE '%' || UPPER(:name) || '%'
            """, {"name": applicant_name})
            row = cur.fetchone()

        if not row:
            return f"Applicant not found: {applicant_name}"

        name, company, credit, tier, since, exception, loans = row
        result = f"Applicant: {name}"
        if company:
            result += f" ({company})"
        result += f", Credit Score: {credit}, Rate Tier: {tier}"
        result += f", Client Since: {since}, Total Loans: {loans}"
        if exception:
            result += f", Rate Exception: {exception}% discount"
        else:
            result += ", No rate exception"
        return result

    print("Tools created: get_loan_policy, get_applicant_info")
    </copy>
    ```

## Task 5: Create the Informed Agent

1. Build the agent with enterprise data tools and test it.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    SYSTEM_PROMPT = """You are a loan officer assistant for Seer Equity.
    You have access to company loan policies and applicant information.
    ALWAYS use your tools to look up real data — never guess at rates,
    requirements, or applicant details."""

    agent = create_react_agent(
        model=llm,
        tools=[get_loan_policy, get_applicant_info],
        prompt=SYSTEM_PROMPT,
    )

    print("Enterprise-connected agent created.")
    </copy>
    ```

2. Ask the same question again — this time with data access.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    response = agent.invoke({
        "messages": [("user", "What interest rates does Seer Equity offer for preferred customers?")]
    })
    print(response["messages"][-1].content)
    </copy>
    ```

    Now the agent returns **7.9% APR** — the real rate from Seer Equity's policy table.

3. Ask about a specific client.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    response = agent.invoke({
        "messages": [("user", "Is Sarah Chen eligible for preferred rates and does she have any special pricing?")]
    })
    print(response["messages"][-1].content)
    </copy>
    ```

    The agent looks up Sarah Chen's record, finds her 780 credit score (Preferred tier), and reports her 15% rate exception. Real data. Real answers.

## Task 6: Clean Up

1. Drop the tables when you're done.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    execute_ddl(conn, "DROP TABLE loan_policies PURGE")
    execute_ddl(conn, "DROP TABLE se_applicants PURGE")
    print("Cleanup complete.")
    </copy>
    ```

## Summary

You've solved the hallucination problem by connecting the agent to enterprise data:

| | Without Enterprise Data | With Enterprise Data |
|---|---|---|
| **Rates** | Hallucinated or "I don't know" | 7.9% APR (from policy table) |
| **Applicant info** | No access | Credit score, rate tier, exceptions |
| **Trust** | Cannot be trusted | Data-backed answers |
| **Source** | LLM training data | Oracle 26ai tables |

The key insight: **an LLM is only as useful as the data it can access**. Enterprise data tools turn a generic chatbot into a business-specific assistant that gives correct, auditable answers.

You may now **proceed to the next lab**.

## Learn More

* [Retrieval-Augmented Generation (RAG)](https://python.langchain.com/docs/concepts/rag/)
* [LangChain Tool Design](https://python.langchain.com/docs/concepts/tools/)
* [Oracle Database 26ai CLOB Support](https://docs.oracle.com/en/database/oracle/oracle-database/)

## Acknowledgements

* **Author** - David Start
* **Last Updated By/Date** - David Start, February 2026
