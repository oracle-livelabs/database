# AI Operations Agent Console: Trusted Actions

## Introduction

An AI-assisted workflow should not be a black box. It should summarize risk through approved tools and leave a durable record of what was proposed or done. This lab uses database-backed helper functions behind the agent console pattern.

The final operating step is controlled action. An AI-assisted workflow should not only summarize risk; it should use approved tools and leave a durable record of what action was proposed or taken.

After evidence is found, ranked, investigated, and governed, the bank needs an action record. This lab shows that an AI-assisted workflow can use approved database tools and leave an audit row.

<details>
<summary><strong>Key terms: agent, tool, Procedural Language/Structured Query Language (PL/SQL) function, and audit row</strong></summary>

> - An **agent** is software that can help summarize information, route a request, or ask an approved tool to perform work. In finance, an agent must be observable because recommendations and actions may affect risk, compliance, service, or client outcomes.
>
> - A **tool** is an approved function the agent is allowed to call. Tools keep the agent from acting only through free-form text; they define the controlled operations the agent can perform, such as summarizing risk signals or logging a decision.
>
> - A **PL/SQL function** is database logic stored in Oracle Database. In this lab, PL/SQL represents the approved business logic an agent-style workflow can call near governed finance data.
>
> - An **audit row** is a database record that shows what happened, who or what performed the action, and when it occurred. Audit rows turn an AI-assisted interaction into durable evidence that an operator or reviewer can inspect later.

</details>

The image below is the AI Operations Agent Console. It is not meant to be a generic chatbot screen; it shows an operational agent surface where finance questions can be routed to approved tools, returned as structured database-backed evidence, and recorded in a recent actions audit trail. The SQL in this lab uses the same pattern: call controlled database logic and then inspect the durable action record.

![AI Operations Agent Console](images/agent-console.png " ")

### Objectives

- Call the risk signal helper function.
- Log and inspect an agent decision.

Estimated Time: **8 minutes**

### Business Scenario

| Step | Finance focus |
| --- | --- |
| Business Problem | AI-assisted operations need a record of what was decided, why, and when. |
| Technical Challenge | Agent workflows need controlled tools and durable audit rows instead of untracked chat actions. |
| Persona Focus | Operations leaders review actions; AI engineers and database developers expose approved PL/SQL tools and audit records. |
| What You Will See | PL/SQL tools can return grounded summaries and write auditable action history. |
| Database Capability | Stored functions and AGENT\_ACTIONS provide controlled tool execution and audit records. |
| Outcome | Agent workflows become reviewable database events instead of untracked chat output. |

Persona focus: You support the operations leader by turning an AI-assisted action into a database event that can be inspected and governed.

## Task 1: Call the trend detection function

Call the approved PL/SQL helper function that summarizes current risk signals for operations review.

1. Run the approved PL/SQL helper function.

    > **SQL Worksheet reminder:** Need a reminder on how to open and use the SQL Worksheet? Return to [Getting Started Task 2: Open SQL Worksheet](/workshops/sandbox/index.html?lab=getting-started#Task2:OpenSQLWorksheet) for the step-by-step graphic showing where to paste and run SQL statements.

    You are calling the same kind of controlled database tool an AI-assisted operations workflow can use. The SQL invokes `DETECT_TRENDING_PRODUCTS` with a 48-hour window and a minimum severity threshold, then returns a concise risk summary produced by approved PL/SQL logic.

    <details>
    <summary><strong>Why this matters: agent tools should live close to governed data</strong></summary>

    > In a fractured environment, an AI assistant may summarize data from one system, trigger actions in another, and leave audit history somewhere else. That makes it hard to know what data was used and whether the action was recorded correctly.
    >
    > Oracle Database can hold the governed data, the approved PL/SQL tool, and the audit trail together. That makes agent-assisted work more controlled and reviewable.

    </details>

    ```sql
    <copy>
    SELECT detect_trending_products(48, 50) AS risk_signal_summary
    FROM dual;
    </copy>
    ```

    **Expected output: Risk Signal Tool Summary**

    | Risk Signal Summary |
    | --- |
    | Found 10 critical financial products (last 48h): Options Trading Enablement (Civic National Bank) - 1 signals, risk severity 72.3, 512667 exposure,... |


2. Review the summary text.
    The function packages query logic behind a controlled tool interface. That gives an agent a safe way to summarize current risk without generating unsupported text from outside the database.

    Expected output starts with a phrase like `Found 10 critical financial products`. The function turns current signal data into an operations-ready summary that an agent or analyst can use to decide what needs escalation.

    This matters because the summary is produced by an approved database function, not by free-form interpretation outside the governed data boundary. The agent can help move work forward, but the database still provides the controlled evidence path.

## Task 2: Log an auditable agent action

Log an agent action and inspect the audit trail that confirms the action was recorded.

1. Run this query:

    You are recording an operational escalation as durable database evidence. The SQL calls `LOG_AGENT_DECISION` with the acting team, action type, entity type, and rationale so the agent workflow produces an auditable row instead of only a chat response.

    ```sql
    <copy>
    SELECT log_agent_decision(
             'RISK_SIGNAL_TEAM',
             'ESCALATE',
             'RISK_SIGNAL',
             'Critical signal exposure escalation for operations review'
           ) AS result
    FROM dual;
    </copy>
    ```

    **Expected output: Agent Decision Result**

    | Result |
    | --- |
    | Decision logged: ESCALATE by RISK\_SIGNAL\_TEAM |


2. Inspect the latest audit rows.

    You are confirming that the action you just logged is visible in the audit trail. The SQL reads the latest rows from `AGENT_ACTIONS`, orders by newest action first, and returns the actor, action, entity type, status, and execution time for review.

    ```sql
    <copy>
    SELECT agent_name,
           action_type,
           entity_type,
           execution_status,
           executed_at
    FROM agent_actions
    ORDER BY action_id DESC
    FETCH FIRST 5 ROWS ONLY;
    </copy>
    ```

    **Expected output: Agent Action Audit Trail**

    | Agent Name | Action Type | Entity Type | Execution Status | Executed At |
    | --- | --- | --- | --- | --- |
    | RISK\_SIGNAL\_TEAM | ESCALATE | RISK\_SIGNAL | completed | timestamp varies |
    | RISK\_SIGNAL\_TEAM | ESCALATE | RISK\_SIGNAL | completed | timestamp varies |
    | RISK\_SIGNAL\_TEAM | ESCALATE | RISK\_SIGNAL | completed | timestamp varies |
    | RISK\_SIGNAL\_TEAM | ESCALATE | RISK\_SIGNAL | completed | timestamp varies |
    | RISK\_SIGNAL\_TEAM | ESCALATE | RISK\_SIGNAL | completed | timestamp varies |


3. Confirm the action is recorded.
    The first query writes the action; the second confirms the write is visible in the audit trail. Together they show the difference between an AI suggestion and an operational action the bank can review.

    The audit row is the database evidence that the action occurred. It records who the agent acted as, what action was requested, what entity type was affected, the execution status, and the timestamp.

    That is the difference between "the assistant said something" and "the bank has a reviewable operational record."

    This is the operational payoff: the same database foundation that produced risk evidence also records the AI-assisted response for later review.

## Acknowledgements

* **Author** - Pat Shepherd, Senior Principal Database Product Manager
* **Contributor** - Linda Foinding, Principal Database Product Manager
* **Last Updated By/Date** - Oracle Database Product Management, June 2026
