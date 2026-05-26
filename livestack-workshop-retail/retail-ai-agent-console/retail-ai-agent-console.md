# Retail AI Agent Console

## Introduction

A retail operations leader, fulfillment manager, commerce analyst, or AI platform owner needs to see how agentic assistance supports day-to-day retail decisions. AI agents become hard to trust when they operate as black boxes outside the operational data platform.

Oracle AI Database helps by keeping source data, SQL execution, PL/SQL tools, and durable action logging in the database. The application orchestrates the agent workflow and shows runtime profile, tool badges, route context, and recent agent actions. In SQL Worksheet, you verify the database tools behind that scene and create one auditable test row.

Estimated Time: 8 minutes

### Objectives

- Verify PL/SQL functions used as agent tools.
- Call a tool that returns inventory evidence.
- Log an agent action and verify the audit row.
- Clean up the workshop test row.
- Explain why observable agent behavior matters for enterprise retail workflows.


## Task 1: Verify the agent tool functions
1. Review the related application screen before you run the SQL.

    ![Retail AI Agent Console overview](images/agent-console-overview.png " ")

    *Figure 1: Retail AI Agent Console shows runtime profile, example questions, and recent agent actions.*

2. Run this query.

    Start here by checking the tools the agent is allowed to use. If these PL/SQL functions are present and valid, the agent workflow has a trusted database action layer instead of an uncontrolled set of prompts.

    ```sql
    <copy>
    SELECT object_name AS "Tool", status AS "Status"
    FROM all_objects
    WHERE owner = SYS_CONTEXT('USERENV','CURRENT_SCHEMA')
      AND object_type = 'FUNCTION'
      AND object_name IN (
        'DETECT_TRENDING_PRODUCTS','CHECK_PRODUCT_INVENTORY',
        'FIND_BEST_FULFILLMENT','GET_INFLUENCER_NETWORK','LOG_AGENT_DECISION'
      )
    ORDER BY object_name;
    </copy>
    ```

    Expected output:

    | Tool | Status |
    | --- | --- |
    | `CHECK_PRODUCT_INVENTORY` | VALID |
    | `DETECT_TRENDING_PRODUCTS` | VALID |
    | `FIND_BEST_FULFILLMENT` | VALID |
    | `GET_INFLUENCER_NETWORK` | VALID |
    | `LOG_AGENT_DECISION` | VALID |
    {: title="Agent Tool Functions"}

3. These functions give the agent a trusted action layer.

## Task 2: Call an inventory tool
1. Use the live Retail AI Agent Console context from Figure 1 before you run the SQL.

2. Call one inventory tool with a fixed product name.

    This step shows the bridge between a question and a trusted database action. Instead of inventing an answer, the agent-style function reads inventory evidence from the database and returns a controlled response.

    ```sql
    <copy>
    SELECT SUBSTR(check_product_inventory('Neon Grid Hoodie'), 1, 500) AS "Inventory"
    FROM dual;
    </copy>
    ```

    Expected output:

    | Inventory |
    | --- |
    | Inventory for "Neon Grid Hoodie" across 14 centers (3947 total units): Kansas City Central (Edwardsville, Kansas): 484 on hand, 19 reserved [OK]... |
    {: title="Inventory Tool Result"}

3. The app can ask an agent question. The trusted action still reads governed database state.

## Task 3: Log and verify an audit action
1. Use the live Retail AI Agent Console context from Figure 1 before you run the SQL.

2. Run this controlled audit call.

    Enterprise agent workflows need an audit trail. This call creates a simple record of who acted, what action was taken, and what type of retail object was involved.

    ```sql
    <copy>
    SELECT log_agent_decision(
             'workshop_validation_agent',
             'explain_retail_signal',
             'product',
             'Workshop test: verified database-grounded retail agent workflow.'
           ) AS "Result"
    FROM dual;
    </copy>
    ```

    Expected output:

    | Check | Result |
    | --- | --- |
    | Agent audit insert | Decision logged: `explain_retail_signal` by `workshop_validation_agent` |
    {: title="Agent Audit Insert Result"}

3. Verify the audit row.

    Logging only helps when someone can inspect the record afterward. This query lets you see the audit row the database captured for the agent action.

    ```sql
    <copy>
    SELECT agent_name AS "Agent",
           action_type AS "Action",
           entity_type AS "Entity",
           execution_status AS "Status"
    FROM agent_actions
    WHERE agent_name = 'workshop_validation_agent'
    ORDER BY executed_at DESC
    FETCH FIRST 1 ROW ONLY;
    </copy>
    ```

    Expected output:

    | Agent | Action | Entity | Status |
    | --- | --- | --- | --- |
    | `workshop_validation_agent` | `explain_retail_signal` | product | completed |
    {: title="Latest Agent Audit Row"}

4. The audit row makes agent activity reviewable.

## Task 4: Clean up the validation row

1. Clean up the validation row if your instructor asks for a pristine audit table.

    The previous step intentionally added a workshop test row. Clean it up only when directed so the lab stays tidy, while remembering that real production audit rows should be preserved for review.

    ```sql
    <copy>
    DELETE FROM agent_actions
    WHERE agent_name = 'workshop_validation_agent';
    COMMIT;
    </copy>
    ```

    Expected output:

    | Check | Result |
    | --- | --- |
    | Agent audit cleanup | Rows deleted and committed. |
    {: title="Agent Audit Cleanup Result"}

2. The workshop test row is now gone. Production audit rows should remain for review.

## Acknowledgements

* **Author** - Pat Shepherd, Senior Principal Database Product Manager
* **Last Updated By/Date** - Oracle Database Product Management, May 2026
