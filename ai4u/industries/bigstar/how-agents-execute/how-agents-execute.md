# How Agents Actually Get Work Done

## Introduction

In this lab, you'll trace an agent through its complete execution loop, from understanding a request to taking action and reporting results.

Every agent follows the same pattern: understand, plan, execute tools, analyze results, and respond. By observing this loop in detail, you'll understand exactly how agents transform requests into outcomes.

### The Business Problem

At Big Star Collectibles, common items take as long to process as rare ones. A $50 recent sports card goes through the same authentication process as a $5,000 vintage comic.

> *"We spend hours authenticating items that should just auto-list. A $50 sports card with good condition? That shouldn't take the same time as a complex vintage comic."*
>
> David, Operations Manager

The company needs smart routing:
- **Under $500 with good condition** → Auto-list
- **$500-$5K** → Standard appraisal
- **$5K+ or rare collectibles** → Expert appraisal

Plus, everything needs to be logged for provenance. When a customer asks "why was this graded 8.5?", there needs to be an answer.

### What You'll Learn

This lab shows you how agents execute conditional workflows with audit logging. You'll build a rarity assessment system that routes items based on value and condition. This is the foundation for solving Big Star Collectibles' processing bottleneck.

**What you'll build:** An item authentication workflow with conditional routing and complete audit trails.

Estimated Time: 10 minutes

### Objectives

* Trace the complete agent execution loop
* Understand the relationship between LLM reasoning and tool actions
* Use history views to see every step
* Build conditional routing based on item rarity

### Prerequisites

For this workshop, we provide the environment. You'll need:

* Basic knowledge of SQL and PL/SQL, or the ability to follow along with the prompts

## Task 1: Import the Lab Notebook

Before you begin, you are going to import a notebook that has all of the commands for this lab into Oracle Machine Learning. This way you don't have to copy and paste them over to run them.

1. From the Oracle Machine Learning home page, click **Notebooks**.

2. Click **Import** to expand the Import drop down.

3. Select **Git**.

4. Paste the following GitHub URL leaving the credential field blank:

    ```text
    <copy>
    https://github.com/davidastart/database/blob/main/ai4u/industries/bigstar/how-agents-execute/lab4-how-agents-execute.json
    </copy>
    ```

5. Click **Ok**.

You should now be on the screen with the notebook imported. This workshop will have all of the screenshots and detailed information however the notebook will have the commands and basic instructions for completing the lab.

## Task 2: Set Up an Observable Agent

We'll create an agent with tools that log what's happening so you can see each step clearly. The key here is that our tools will write to a log table as they work, giving us a window into exactly what the agent is doing.

1. Create tables and sequence for tracking.

    We need two tables: one to log every step the agent takes (`workflow_log`) and one to store the actual item requests (`item_requests`). This separation lets us see both what the agent did AND what data it created.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    CREATE SEQUENCE item_requests_seq START WITH 1001;

    CREATE TABLE workflow_log (
        log_id      NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
        step_name   VARCHAR2(100),
        step_detail VARCHAR2(500),
        logged_at   TIMESTAMP DEFAULT SYSTIMESTAMP
    );

    CREATE TABLE item_requests (
        request_id       VARCHAR2(20) PRIMARY KEY,
        submitter        VARCHAR2(100),
        value            NUMBER(12,2),
        item_type        VARCHAR2(50),
        condition_grade  NUMBER(3,1),
        rarity_level     VARCHAR2(30),
        status           VARCHAR2(30) DEFAULT 'NEW',
        routed_to        VARCHAR2(50),
        created_at       TIMESTAMP DEFAULT SYSTIMESTAMP
    );
    </copy>
    ```

2. Create the first tool function - create item request.

    This function does two things: it creates an item request record AND it logs what it's doing. Every time the agent calls this tool, we'll see an entry in our workflow log. This is how we make the agent's work visible.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    CREATE OR REPLACE FUNCTION create_item_request(
        p_submitter       VARCHAR2,
        p_value           NUMBER,
        p_item_type       VARCHAR2,
        p_condition_grade NUMBER
    ) RETURN VARCHAR2 AS
        PRAGMA AUTONOMOUS_TRANSACTION;
        v_request_id VARCHAR2(20);
    BEGIN
        v_request_id := 'ITM-' || TO_CHAR(SYSDATE, 'YYMMDD') || '-' || item_requests_seq.NEXTVAL;

        -- Log the step
        INSERT INTO workflow_log (step_name, step_detail)
        VALUES ('CREATE_REQUEST', 'Created ' || v_request_id || ' for ' || p_submitter ||
                ', $' || p_value || ' ' || p_item_type || ', Condition: ' || p_condition_grade);

        -- Create the request
        INSERT INTO item_requests (request_id, submitter, value, item_type, condition_grade, status)
        VALUES (v_request_id, p_submitter, p_value, LOWER(p_item_type), p_condition_grade, 'SUBMITTED');

        COMMIT;
        RETURN 'Created item request ' || v_request_id || ' for $' || p_value || ' ' || p_item_type;
    END;
    /
    </copy>
    ```

3. Create the second tool function - assess rarity and route.

    This is where the business logic lives. The function looks at the item value, type, and condition grade, then decides where to route it. It logs both the assessment and the routing decision. This is the kind of conditional logic that makes agents useful—different inputs lead to different outcomes.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    CREATE OR REPLACE FUNCTION assess_and_route(
        p_request_id VARCHAR2
    ) RETURN VARCHAR2 AS
        PRAGMA AUTONOMOUS_TRANSACTION;
        v_value           NUMBER;
        v_item_type       VARCHAR2(50);
        v_condition_grade NUMBER;
        v_rarity_level    VARCHAR2(30);
        v_route_to        VARCHAR2(50);
        v_result          VARCHAR2(500);
    BEGIN
        -- Get request details
        SELECT value, item_type, condition_grade
        INTO v_value, v_item_type, v_condition_grade
        FROM item_requests WHERE request_id = p_request_id;

        -- Log the assessment start
        INSERT INTO workflow_log (step_name, step_detail)
        VALUES ('ASSESS_RARITY', 'Assessing ' || p_request_id || ': $' || v_value ||
                ', Condition: ' || v_condition_grade);

        -- Apply rarity rules
        IF v_condition_grade < 3.0 THEN
            v_rarity_level := 'DAMAGED';
            v_route_to := 'REJECTED';
            v_result := 'REJECTED: Condition grade ' || v_condition_grade || ' below minimum 3.0.';
        ELSIF v_item_type IN ('common_card', 'recent_issue') AND v_value < 500 AND v_condition_grade >= 7.0 THEN
            v_rarity_level := 'LOW';
            v_route_to := 'AUTO_LISTED';
            v_result := 'AUTO_LISTED: Common item under $500 with condition ' || v_condition_grade || '.';
        ELSIF v_value < 5000 AND v_item_type NOT IN ('vintage_comic', 'graded_card') THEN
            v_rarity_level := 'MEDIUM';
            v_route_to := 'STANDARD_APPRAISAL';
            v_result := 'Routed to STANDARD_APPRAISAL: $' || v_value || ' ' || v_item_type || ' requires review.';
        ELSE
            v_rarity_level := 'HIGH';
            v_route_to := 'EXPERT_APPRAISAL';
            v_result := 'Routed to EXPERT_APPRAISAL: $' || v_value || ' ' || v_item_type || ' requires expert review.';
        END IF;

        -- Log the routing decision
        INSERT INTO workflow_log (step_name, step_detail)
        VALUES ('ROUTE_DECISION', p_request_id || ' -> ' || v_route_to || ' (Rarity: ' || v_rarity_level || ')');

        -- Update the request
        UPDATE item_requests
        SET rarity_level = v_rarity_level,
            routed_to = v_route_to,
            status = CASE WHEN v_route_to IN ('AUTO_LISTED', 'REJECTED') THEN v_route_to ELSE 'PENDING_REVIEW' END
        WHERE request_id = p_request_id;

        COMMIT;
        RETURN v_result;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'Request not found: ' || p_request_id;
    END;
    /
    </copy>
    ```

4. Register the tools.

    We register both functions as tools. The `instruction` tells the agent what each tool does and what parameters it needs. The agent will use CREATE_ITEM_TOOL first to create the request, then ASSESS_ROUTE_TOOL to evaluate and route it.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
            tool_name   => 'CREATE_ITEM_TOOL',
            attributes  => '{"instruction": "Create a new item request. Parameters: P_SUBMITTER (name), P_VALUE (dollar amount as number), P_ITEM_TYPE (common_card, vintage_comic, graded_card, or recent_issue), P_CONDITION_GRADE (number 1.0-10.0). Returns the request ID.",
                            "function": "create_item_request"}',
            description => 'Creates an item request and returns the request ID'
        );

        DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
            tool_name   => 'ASSESS_ROUTE_TOOL',
            attributes  => '{"instruction": "Assess rarity and route an item request. Parameter: P_REQUEST_ID (the ITM-YYMMDD-NNNN format ID from CREATE_ITEM_TOOL). Returns routing decision.",
                            "function": "assess_and_route"}',
            description => 'Assesses rarity level and routes to appropriate reviewer'
        );
    END;
    /
    </copy>
    ```

5. Create the agent and team.

    The agent's role tells it to always complete both steps: create then assess. The task reinforces this with specific instructions. This ensures the agent follows a consistent workflow every time—create the request, get an ID back, then use that ID to assess and route.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_AGENT(
            agent_name  => 'ITEM_EXEC_AGENT',
            attributes  => '{"profile_name": "genai",
                            "role": "You are an item processing agent for Big Star Collectibles. Process items by: 1) Creating the request with CREATE_ITEM_TOOL, 2) Assessing and routing with ASSESS_ROUTE_TOOL. Always complete both steps."}',
            description => 'Agent demonstrating execution loop'
        );

        DBMS_CLOUD_AI_AGENT.CREATE_TASK(
            task_name   => 'ITEM_EXEC_TASK',
            attributes  => '{"instruction": "Process the item request: 1. Call CREATE_ITEM_TOOL to create the request 2. Call ASSESS_ROUTE_TOOL with the returned request ID to assess and route. Report the final routing decision. User request: {query}",
                            "tools": ["CREATE_ITEM_TOOL", "ASSESS_ROUTE_TOOL"]}',
            description => 'Task for item execution demo'
        );

        DBMS_CLOUD_AI_AGENT.CREATE_TEAM(
            team_name   => 'ITEM_EXEC_TEAM',
            attributes  => '{"agents": [{"name": "ITEM_EXEC_AGENT", "task": "ITEM_EXEC_TASK"}],
                            "process": "sequential"}',
            description => 'Team for execution demo'
        );
    END;
    /
    </copy>
    ```

## Task 3: Execute a Complete Workflow

Now let's run a request and trace every step.

1. Clear the log and set the team.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    TRUNCATE TABLE workflow_log;
    EXEC DBMS_CLOUD_AI_AGENT.SET_TEAM('ITEM_EXEC_TEAM');
    </copy>
    ```

2. Submit an item request that should auto-list.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    SELECT AI AGENT Process a $350 common_card for John Smith with condition grade 8.5;
    </copy>
    ```

3. Immediately check the workflow log.

    > This command is already in your notebook—just click the play button (▶) to run it.

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
- CREATE_REQUEST: The item was created
- ASSESS_RARITY: Rarity was evaluated
- ROUTE_DECISION: AUTO_LISTED (common card under $500 with 8.5 condition)

## Task 4: Trace the Agent's Tool Calls

The history views show what the agent did.

1. Query the tool history.

    > This command is already in your notebook—just click the play button (▶) to run it.

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

2. Check the item request that was created.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    SELECT
        request_id,
        submitter,
        value,
        item_type,
        condition_grade,
        rarity_level,
        routed_to,
        status
    FROM item_requests
    ORDER BY created_at DESC;
    </copy>
    ```

You can see the actual record the agent created, with the rarity assessment and routing.

## Task 5: Trace Different Execution Paths

Different item parameters trigger different routing paths.

1. Submit an item that needs standard appraisal.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    TRUNCATE TABLE workflow_log;
    SELECT AI AGENT Process a $1500 vintage_comic for Acme Collectibles with condition grade 7.0;
    </copy>
    ```

2. Check the workflow log.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    SELECT step_name, step_detail FROM workflow_log ORDER BY log_id;
    </copy>
    ```

**Observe:** Routed to EXPERT_APPRAISAL because vintage comic needs expert review.

3. Submit an item that needs expert review.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    TRUNCATE TABLE workflow_log;
    SELECT AI AGENT Process a $4500 graded_card for Jane Doe with condition grade 9.0;
    </copy>
    ```

4. Check the routing.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    SELECT step_name, step_detail FROM workflow_log ORDER BY log_id;
    </copy>
    ```

**Observe:** Routed to EXPERT_APPRAISAL because it's a graded card over $4K.

5. Submit an item that should be rejected.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    TRUNCATE TABLE workflow_log;
    SELECT AI AGENT Process a $250 recent_issue for Bob Wilson with condition grade 2.5;
    </copy>
    ```

6. Check the routing.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    SELECT step_name, step_detail FROM workflow_log ORDER BY log_id;
    </copy>
    ```

**Observe:** REJECTED because condition grade 2.5 is below minimum 3.0.

## Task 6: Compare All Items and Their Routes

Let's see all the items and their different routing decisions.

> This command is already in your notebook—just click the play button (▶) to run it.

```sql
<copy>
SELECT
    request_id,
    submitter,
    value,
    item_type,
    condition_grade,
    rarity_level,
    routed_to,
    status
FROM item_requests
ORDER BY created_at;
</copy>
```

## Task 7: Understand the Execution Pattern

Every agent execution follows this pattern:

1. **Receive request** → The user submits a query
2. **LLM understands** → Interprets the intent
3. **LLM plans** → Determines which tools and in what order
4. **Tool executes** → First tool runs, returns result
5. **LLM analyzes** → Interprets the result
6. **Next tool** → Repeat steps 4-5 for each tool (conditionally)
7. **LLM responds** → Generates final response

Query to see the complete execution timeline:

> This command is already in your notebook—just click the play button (▶) to run it.

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

> This command is already in your notebook—just click the play button (▶) to run it.

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
* Watched a multi-step workflow execute with rarity assessment
* Traced tool calls through history views
* Saw how different inputs lead to different routing paths

**Key takeaway:** The agent orchestrates, the LLM thinks, the tools act. Every step is logged. Every action is traceable. For Big Star Collectibles, this means common items auto-list in seconds, rare items get routed appropriately, and provenance has a complete audit trail.

## Learn More

* [`DBMS_CLOUD_AI_AGENT` Package](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/dbms-cloud-ai-agent-package.html)

## Acknowledgements

* **Author** - David Start
* **Last Updated By/Date** - David Start, January 2026

## Cleanup (Optional)

> This command is already in your notebook—just click the play button (▶) to run it.

```sql
<copy>
EXEC DBMS_CLOUD_AI_AGENT.DROP_TEAM('ITEM_EXEC_TEAM', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TASK('ITEM_EXEC_TASK', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_AGENT('ITEM_EXEC_AGENT', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('CREATE_ITEM_TOOL', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('ASSESS_ROUTE_TOOL', TRUE);
DROP TABLE item_requests PURGE;
DROP TABLE workflow_log PURGE;
DROP SEQUENCE item_requests_seq;
DROP FUNCTION create_item_request;
DROP FUNCTION assess_and_route;
</copy>
```
