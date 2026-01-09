# How Agents Actually Get Work Done

## Introduction

In this lab, you'll trace an agent through its complete execution loop—from understanding a request to taking action and reporting results.

Every agent follows the same pattern: understand, plan, execute tools, analyze results, and respond. By observing this loop in detail, you'll understand exactly how agents transform requests into outcomes.

Estimated Time: 10 minutes

### Objectives

* Trace the complete agent execution loop
* Understand the relationship between LLM reasoning and tool actions
* Use history views to see every step
* Recognize the pattern that all agents follow

### Prerequisites

This lab assumes you have:

* Completed Labs 1-3 or have a working agent setup
* An AI profile named `genai` already configured

## Task 1: Set Up an Observable Agent

We'll create an agent with tools that log what's happening so you can see each step clearly.

1. Create tables and sequence for tracking.

    ```sql
    <copy>
    CREATE SEQUENCE expense_requests_seq START WITH 1001;

    CREATE TABLE workflow_log (
        log_id      NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
        step_name   VARCHAR2(100),
        step_detail VARCHAR2(500),
        logged_at   TIMESTAMP DEFAULT SYSTIMESTAMP
    );

    CREATE TABLE expense_requests (
        request_id  VARCHAR2(20) PRIMARY KEY,
        employee    VARCHAR2(100),
        amount      NUMBER(10,2),
        category    VARCHAR2(50),
        status      VARCHAR2(30) DEFAULT 'NEW',
        created_at  TIMESTAMP DEFAULT SYSTIMESTAMP
    );
    </copy>
    ```

2. Create the first tool function - create expense request.

    ```sql
    <copy>
    CREATE OR REPLACE FUNCTION create_expense_request(
        p_employee VARCHAR2,
        p_amount   NUMBER,
        p_category VARCHAR2
    ) RETURN VARCHAR2 AS
        PRAGMA AUTONOMOUS_TRANSACTION;
        v_request_id VARCHAR2(20);
    BEGIN
        v_request_id := 'EXP-' || TO_CHAR(SYSDATE, 'YYMMDD') || '-' || expense_requests_seq.NEXTVAL;
        
        -- Log the step
        INSERT INTO workflow_log (step_name, step_detail) 
        VALUES ('CREATE_REQUEST', 'Created ' || v_request_id || ' for ' || p_employee || ', $' || p_amount);
        
        -- Create the request
        INSERT INTO expense_requests (request_id, employee, amount, category, status)
        VALUES (v_request_id, p_employee, p_amount, p_category, 'SUBMITTED');
        
        COMMIT;
        RETURN 'Created expense request ' || v_request_id || ' for $' || p_amount || ' (' || p_category || ')';
    END;
    /
    </copy>
    ```

3. Create the second tool function - check expense rules.

    ```sql
    <copy>
    CREATE OR REPLACE FUNCTION check_expense_rules(
        p_amount   NUMBER,
        p_category VARCHAR2
    ) RETURN VARCHAR2 AS
        PRAGMA AUTONOMOUS_TRANSACTION;
        v_result VARCHAR2(200);
    BEGIN
        -- Log the step
        INSERT INTO workflow_log (step_name, step_detail) 
        VALUES ('CHECK_RULES', 'Checking rules for $' || p_amount || ', category: ' || p_category);
        
        -- Apply rules
        IF p_amount < 100 THEN
            v_result := 'AUTO_APPROVE: Amount under $100';
        ELSIF p_amount < 500 THEN
            v_result := 'MANAGER_APPROVAL: Amount $100-500 requires manager';
        ELSE
            v_result := 'DIRECTOR_APPROVAL: Amount $500+ requires director';
        END IF;
        
        COMMIT;
        RETURN v_result;
    END;
    /
    </copy>
    ```

4. Create the third tool function - route for approval.

    ```sql
    <copy>
    CREATE OR REPLACE FUNCTION route_for_approval(
        p_request_id VARCHAR2,
        p_approval_level VARCHAR2
    ) RETURN VARCHAR2 AS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        -- Log the step
        INSERT INTO workflow_log (step_name, step_detail) 
        VALUES ('ROUTE_APPROVAL', 'Routing ' || p_request_id || ' for ' || p_approval_level);
        
        -- Update status
        UPDATE expense_requests 
        SET status = 'PENDING_' || p_approval_level
        WHERE request_id = p_request_id;
        
        COMMIT;
        RETURN 'Routed ' || p_request_id || ' for ' || p_approval_level || ' approval';
    END;
    /
    </copy>
    ```

5. Register the tools.

    ```sql
    <copy>
    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
            tool_name   => 'CREATE_EXPENSE_TOOL',
            attributes  => '{"instruction": "Create a new expense request. Parameters: P_EMPLOYEE (employee name), P_AMOUNT (dollar amount as number), P_CATEGORY (travel, meals, or supplies). Returns the request ID.",
                            "function": "create_expense_request"}',
            description => 'Creates an expense request and returns the request ID'
        );
        
        DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
            tool_name   => 'CHECK_RULES_TOOL',
            attributes  => '{"instruction": "Check what approval level is needed for an expense. Parameters: P_AMOUNT (dollar amount as number), P_CATEGORY. Returns AUTO_APPROVE, MANAGER_APPROVAL, or DIRECTOR_APPROVAL.",
                            "function": "check_expense_rules"}',
            description => 'Returns the required approval level based on amount and category'
        );
        
        DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
            tool_name   => 'ROUTE_APPROVAL_TOOL',
            attributes  => '{"instruction": "Route an expense for approval. Only call this if CHECK_RULES_TOOL returned MANAGER_APPROVAL or DIRECTOR_APPROVAL. Do NOT call this for AUTO_APPROVE. Parameters: P_REQUEST_ID (the EXP-YYMMDD-NNNN format ID), P_APPROVAL_LEVEL (MANAGER or DIRECTOR).",
                            "function": "route_for_approval"}',
            description => 'Routes the expense request to the appropriate approver'
        );
    END;
    /
    </copy>
    ```

6. Create the agent and team.

    ```sql
    <copy>
    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_AGENT(
            agent_name  => 'EXPENSE_EXEC_AGENT',
            attributes  => '{"profile_name": "genai",
                            "role": "You are an expense processing agent. Process expenses by: 1) Creating the request, 2) Checking the rules, 3) Only routing for approval if rules require it. If rules say AUTO_APPROVE, do not route."}',
            description => 'Agent demonstrating execution loop'
        );
        
        DBMS_CLOUD_AI_AGENT.CREATE_TASK(
            task_name   => 'EXPENSE_EXEC_TASK',
            attributes  => '{"instruction": "Process the expense request: 1. Call CREATE_EXPENSE_TOOL to create the request 2. Call CHECK_RULES_TOOL to determine approval level 3. If result contains MANAGER_APPROVAL or DIRECTOR_APPROVAL, call ROUTE_APPROVAL_TOOL. If result is AUTO_APPROVE, do NOT call ROUTE_APPROVAL_TOOL - just confirm the expense is auto-approved. User request: {query}",
                            "tools": ["CREATE_EXPENSE_TOOL", "CHECK_RULES_TOOL", "ROUTE_APPROVAL_TOOL"]}',
            description => 'Task for expense execution demo'
        );
        
        DBMS_CLOUD_AI_AGENT.CREATE_TEAM(
            team_name   => 'EXPENSE_EXEC_TEAM',
            attributes  => '{"agents": [{"name": "EXPENSE_EXEC_AGENT", "task": "EXPENSE_EXEC_TASK"}],
                            "process": "sequential"}',
            description => 'Team for execution demo'
        );
    END;
    /
    </copy>
    ```

## Task 2: Execute a Complete Workflow

Now let's run a request and trace every step.

1. Clear the log and set the team.

    ```sql
    <copy>
    TRUNCATE TABLE workflow_log;
    EXEC DBMS_CLOUD_AI_AGENT.SET_TEAM('EXPENSE_EXEC_TEAM');
    </copy>
    ```

2. Submit an expense request.

    ```sql
    <copy>
    SELECT AI AGENT Submit a $250 expense for meals for John Smith;
    </copy>
    ```

3. Immediately check the workflow log.

    ```sql
    <copy>
    SELECT 
        step_name,
        step_detail,
        TO_CHAR(logged_at, 'HH24:MI:SS.FF3') as time
    FROM workflow_log
    ORDER BY log_id;
    </copy>
    ```

**Observe the execution sequence:**
- CREATE_REQUEST: The expense was created
- CHECK_RULES: Rules were evaluated ($250 requires manager)
- ROUTE_APPROVAL: It was routed for manager approval

## Task 3: Trace the Agent's Tool Calls

The history views show what the agent did.

1. Query the tool history.

    ```sql
    <copy>
    SELECT 
        tool_name,
        TO_CHAR(start_date, 'HH24:MI:SS.FF3') as started,
        TO_CHAR(end_date, 'HH24:MI:SS.FF3') as ended,
        SUBSTR(output, 1, 60) as result
    FROM USER_AI_AGENT_TOOL_HISTORY
    ORDER BY start_date DESC
    FETCH FIRST 10 ROWS ONLY;
    </copy>
    ```

2. Check the expense request that was created.

    ```sql
    <copy>
    SELECT 
        request_id,
        employee,
        amount,
        category,
        status,
        TO_CHAR(created_at, 'HH24:MI:SS') as created
    FROM expense_requests
    ORDER BY created_at DESC;
    </copy>
    ```

You can see the actual record the agent created.

## Task 4: Trace Different Execution Paths

Different amounts trigger different rules and therefore different execution paths.

1. Submit a small expense (auto-approve path).

    ```sql
    <copy>
    TRUNCATE TABLE workflow_log;
    SELECT AI AGENT Submit a $50 expense for supplies for Jane Doe;
    </copy>
    ```

2. Check the workflow log.

    ```sql
    <copy>
    SELECT step_name, step_detail FROM workflow_log ORDER BY log_id;
    </copy>
    ```

**Observe:** Only CREATE_REQUEST and CHECK_RULES appear - no ROUTE_APPROVAL because the rules said AUTO_APPROVE (under $100).

3. Check the expense record status.

    ```sql
    <copy>
    SELECT request_id, employee, amount, status 
    FROM expense_requests 
    WHERE employee = 'Jane Doe';
    </copy>
    ```

The status is SUBMITTED (not PENDING_MANAGER) - it was auto-approved, so no routing was needed.

4. Submit a large expense (director approval path).

    ```sql
    <copy>
    TRUNCATE TABLE workflow_log;
    SELECT AI AGENT Submit a $750 expense for travel for Bob Wilson;
    </copy>
    ```

5. Check the workflow log again.

    ```sql
    <copy>
    SELECT step_name, step_detail FROM workflow_log ORDER BY log_id;
    </copy>
    ```

**Observe:** All three steps appear - $750 requires DIRECTOR_APPROVAL so it was routed.

6. Check the expense record status.

    ```sql
    <copy>
    SELECT request_id, employee, amount, status 
    FROM expense_requests 
    WHERE employee = 'Bob Wilson';
    </copy>
    ```

The status is PENDING_DIRECTOR because the $750 expense was routed for director approval.

## Task 5: Compare All Three Expenses

Let's see all the expenses and their different statuses.

```sql
<copy>
SELECT 
    request_id,
    employee,
    amount,
    status,
    CASE 
        WHEN amount < 100 THEN 'Auto-approved'
        WHEN amount < 500 THEN 'Manager approval'
        ELSE 'Director approval'
    END as approval_path
FROM expense_requests
ORDER BY created_at;
</copy>
```

## Task 6: Understand the Execution Pattern

Every agent execution follows this pattern:

1. **Receive request** → The user submits a query
2. **LLM understands** → Interprets the intent
3. **LLM plans** → Determines which tools and in what order
4. **Tool executes** → First tool runs, returns result
5. **LLM analyzes** → Interprets the result
6. **Next tool** → Repeat steps 4-5 for each tool (conditionally)
7. **LLM responds** → Generates final response

Query to see the complete execution timeline:

```sql
<copy>
SELECT 
    'TOOL: ' || tool_name as step,
    TO_CHAR(start_date, 'HH24:MI:SS.FF3') as time,
    SUBSTR(output, 1, 50) as output
FROM USER_AI_AGENT_TOOL_HISTORY
WHERE start_date > SYSTIMESTAMP - INTERVAL '5' MINUTE
ORDER BY start_date;
</copy>
```

Compare with your workflow log:

```sql
<copy>
SELECT 
    'LOG: ' || step_name as step,
    TO_CHAR(logged_at, 'HH24:MI:SS.FF3') as time,
    step_detail as output
FROM workflow_log
WHERE logged_at > SYSTIMESTAMP - INTERVAL '5' MINUTE
ORDER BY logged_at;
</copy>
```

## Summary

In this lab, you traced the complete agent execution loop:

* Created an observable agent with logging tools
* Watched a multi-step workflow execute
* Traced tool calls through history views
* Saw how different inputs lead to different execution paths

**Key takeaway:** The agent orchestrates, the LLM thinks, the tools act. Every step is logged. Every action is traceable.

## Learn More

* [DBMS_CLOUD_AI_AGENT Package](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/dbms-cloud-ai-agent-package.html)

## Acknowledgements

* **Author** - David Start
* **Last Updated By/Date** - David Start, January 2026

## Cleanup (Optional)

```sql
<copy>
EXEC DBMS_CLOUD_AI_AGENT.DROP_TEAM('EXPENSE_EXEC_TEAM', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TASK('EXPENSE_EXEC_TASK', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_AGENT('EXPENSE_EXEC_AGENT', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('CREATE_EXPENSE_TOOL', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('CHECK_RULES_TOOL', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('ROUTE_APPROVAL_TOOL', TRUE);
DROP TABLE expense_requests PURGE;
DROP TABLE workflow_log PURGE;
DROP SEQUENCE expense_requests_seq;
DROP FUNCTION create_expense_request;
DROP FUNCTION check_expense_rules;
DROP FUNCTION route_for_approval;
</copy>
```
