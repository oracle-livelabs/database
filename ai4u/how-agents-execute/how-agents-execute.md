# How Agents Actually Get Work Done

## Introduction

In this lab, you'll trace an agent through its complete execution loop, from understanding a request to taking action and reporting results.

Every agent follows the same pattern: understand, plan, execute tools, analyze results, and respond. By observing this loop in detail, you'll understand exactly how agents transform requests into outcomes.

### The Business Problem

At Seer Equity, small loans take as long to process as big ones. A $25,000 personal loan for a client with excellent credit goes through the same review process as a $500,000 mortgage.

> *"We spend hours reviewing applications that should just auto-approve. A $25K personal loan with 800 credit? That shouldn't take the same time as a complex mortgage."*
>
> David, Operations Manager

The company needs smart routing:
- **Under $50K with good credit** → Auto-approve
- **$50K-$250K** → Underwriter review
- **$250K+ or mortgages** → Senior underwriter

Plus, everything needs to be logged for compliance. When a regulator asks "why was this approved?", there needs to be an answer.

### What You'll Learn

This lab shows you how agents execute conditional workflows with audit logging. You'll build a risk assessment system that routes loans based on amount and type. This is the foundation for solving Seer Equity's processing bottleneck.

**What you'll build:** A loan processing workflow with conditional routing and complete audit trails.

Estimated Time: 10 minutes

### Objectives

* Trace the complete agent execution loop
* Understand the relationship between LLM reasoning and tool actions
* Use history views to see every step
* Build conditional routing based on loan risk

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
    https://github.com/davidastart/database/blob/main/ai4u/how-agents-execute/lab4-how-agents-execute.json
    </copy>
    ```

5. Click **Ok**.

You should now be on the screen with the notebook imported. This workshop will have all of the screenshots and detailed information however the notebook will have the commands and basic instructions for completing the lab.

## Task 2: Set Up an Observable Agent

We'll create an agent with tools that log what's happening so you can see each step clearly. The key here is that our tools will write to a log table as they work, giving us a window into exactly what the agent is doing.

1. Create tables and sequence for tracking.

    We need two tables: one to log every step the agent takes (`workflow_log`) and one to store the actual loan requests (`loan_requests`). This separation lets us see both what the agent did AND what data it created.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    CREATE SEQUENCE loan_requests_seq START WITH 1001;

    CREATE TABLE workflow_log (
        log_id      NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
        step_name   VARCHAR2(100),
        step_detail VARCHAR2(500),
        logged_at   TIMESTAMP DEFAULT SYSTIMESTAMP
    );

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
    );
    </copy>
    ```

2. Create the first tool function - create loan request.

    This function does two things: it creates a loan request record AND it logs what it's doing. Every time the agent calls this tool, we'll see an entry in our workflow log. This is how we make the agent's work visible.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    CREATE OR REPLACE FUNCTION create_loan_request(
        p_applicant    VARCHAR2,
        p_amount       NUMBER,
        p_loan_type    VARCHAR2,
        p_credit_score NUMBER
    ) RETURN VARCHAR2 AS
        PRAGMA AUTONOMOUS_TRANSACTION;
        v_request_id VARCHAR2(20);
    BEGIN
        v_request_id := 'LN-' || TO_CHAR(SYSDATE, 'YYMMDD') || '-' || loan_requests_seq.NEXTVAL;
        
        -- Log the step
        INSERT INTO workflow_log (step_name, step_detail) 
        VALUES ('CREATE_REQUEST', 'Created ' || v_request_id || ' for ' || p_applicant || 
                ', $' || p_amount || ' ' || p_loan_type || ', Credit: ' || p_credit_score);
        
        -- Create the request
        INSERT INTO loan_requests (request_id, applicant, amount, loan_type, credit_score, status)
        VALUES (v_request_id, p_applicant, p_amount, LOWER(p_loan_type), p_credit_score, 'SUBMITTED');
        
        COMMIT;
        RETURN 'Created loan request ' || v_request_id || ' for $' || p_amount || ' ' || p_loan_type;
    END;
    /
    </copy>
    ```

3. Create the second tool function - assess risk and route.

    This is where the business logic lives. The function looks at the loan amount, type, and credit score, then decides where to route it. It logs both the assessment and the routing decision. This is the kind of conditional logic that makes agents useful—different inputs lead to different outcomes.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    CREATE OR REPLACE FUNCTION assess_and_route(
        p_request_id VARCHAR2
    ) RETURN VARCHAR2 AS
        PRAGMA AUTONOMOUS_TRANSACTION;
        v_amount       NUMBER;
        v_loan_type    VARCHAR2(50);
        v_credit_score NUMBER;
        v_risk_level   VARCHAR2(30);
        v_route_to     VARCHAR2(50);
        v_result       VARCHAR2(500);
    BEGIN
        -- Get request details
        SELECT amount, loan_type, credit_score
        INTO v_amount, v_loan_type, v_credit_score
        FROM loan_requests WHERE request_id = p_request_id;
        
        -- Log the assessment start
        INSERT INTO workflow_log (step_name, step_detail) 
        VALUES ('ASSESS_RISK', 'Assessing ' || p_request_id || ': $' || v_amount || 
                ', Credit: ' || v_credit_score);
        
        -- Apply risk rules
        IF v_credit_score < 550 THEN
            v_risk_level := 'BLOCKED';
            v_route_to := 'REJECTED';
            v_result := 'BLOCKED: Credit score ' || v_credit_score || ' below minimum 550.';
        ELSIF v_loan_type = 'personal' AND v_amount < 50000 AND v_credit_score >= 700 THEN
            v_risk_level := 'LOW';
            v_route_to := 'AUTO_APPROVED';
            v_result := 'AUTO_APPROVED: Personal loan under $50K with credit ' || v_credit_score || '.';
        ELSIF v_amount < 250000 AND v_loan_type != 'mortgage' THEN
            v_risk_level := 'MEDIUM';
            v_route_to := 'UNDERWRITER';
            v_result := 'Routed to UNDERWRITER: $' || v_amount || ' ' || v_loan_type || ' requires review.';
        ELSE
            v_risk_level := 'HIGH';
            v_route_to := 'SENIOR_UNDERWRITER';
            v_result := 'Routed to SENIOR_UNDERWRITER: $' || v_amount || ' ' || v_loan_type || ' requires senior review.';
        END IF;
        
        -- Log the routing decision
        INSERT INTO workflow_log (step_name, step_detail) 
        VALUES ('ROUTE_DECISION', p_request_id || ' -> ' || v_route_to || ' (Risk: ' || v_risk_level || ')');
        
        -- Update the request
        UPDATE loan_requests
        SET risk_level = v_risk_level, 
            routed_to = v_route_to,
            status = CASE WHEN v_route_to IN ('AUTO_APPROVED', 'REJECTED') THEN v_route_to ELSE 'PENDING_REVIEW' END
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

    We register both functions as tools. Notice how the instructions tell the agent what each tool does and what parameters it needs. The agent will use CREATE_LOAN_TOOL first to create the request, then ASSESS_ROUTE_TOOL to evaluate and route it.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
            tool_name   => 'CREATE_LOAN_TOOL',
            attributes  => '{"instruction": "Create a new loan request. Parameters: P_APPLICANT (name), P_AMOUNT (dollar amount as number), P_LOAN_TYPE (personal, auto, mortgage, or business), P_CREDIT_SCORE (number 300-850). Returns the request ID.",
                            "function": "create_loan_request"}',
            description => 'Creates a loan request and returns the request ID'
        );
        
        DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
            tool_name   => 'ASSESS_ROUTE_TOOL',
            attributes  => '{"instruction": "Assess risk and route a loan request. Parameter: P_REQUEST_ID (the LN-YYMMDD-NNNN format ID from CREATE_LOAN_TOOL). Returns routing decision.",
                            "function": "assess_and_route"}',
            description => 'Assesses risk level and routes to appropriate reviewer'
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
            agent_name  => 'LOAN_EXEC_AGENT',
            attributes  => '{"profile_name": "genai",
                            "role": "You are a loan processing agent for Seer Equity. Process loans by: 1) Creating the request with CREATE_LOAN_TOOL, 2) Assessing and routing with ASSESS_ROUTE_TOOL. Always complete both steps."}',
            description => 'Agent demonstrating execution loop'
        );
        
        DBMS_CLOUD_AI_AGENT.CREATE_TASK(
            task_name   => 'LOAN_EXEC_TASK',
            attributes  => '{"instruction": "Process the loan request: 1. Call CREATE_LOAN_TOOL to create the request 2. Call ASSESS_ROUTE_TOOL with the returned request ID to assess and route. Report the final routing decision. User request: {query}",
                            "tools": ["CREATE_LOAN_TOOL", "ASSESS_ROUTE_TOOL"]}',
            description => 'Task for loan execution demo'
        );
        
        DBMS_CLOUD_AI_AGENT.CREATE_TEAM(
            team_name   => 'LOAN_EXEC_TEAM',
            attributes  => '{"agents": [{"name": "LOAN_EXEC_AGENT", "task": "LOAN_EXEC_TASK"}],
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
    EXEC DBMS_CLOUD_AI_AGENT.SET_TEAM('LOAN_EXEC_TEAM');
    </copy>
    ```

2. Submit a loan request that should auto-approve.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    SELECT AI AGENT Process a $35000 personal loan for John Smith with credit score 780;
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
- CREATE_REQUEST: The loan was created
- ASSESS_RISK: Risk was evaluated
- ROUTE_DECISION: AUTO_APPROVED (personal under $50K with 780 credit)

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

2. Check the loan request that was created.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    SELECT 
        request_id,
        applicant,
        amount,
        loan_type,
        credit_score,
        risk_level,
        routed_to,
        status
    FROM loan_requests
    ORDER BY created_at DESC;
    </copy>
    ```

You can see the actual record the agent created, with the risk assessment and routing.

## Task 5: Trace Different Execution Paths

Different loan parameters trigger different routing paths.

1. Submit a loan that needs underwriter review.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    TRUNCATE TABLE workflow_log;
    SELECT AI AGENT Process a $150000 business loan for Acme Corp with credit score 720;
    </copy>
    ```

2. Check the workflow log.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    SELECT step_name, step_detail FROM workflow_log ORDER BY log_id;
    </copy>
    ```

**Observe:** Routed to UNDERWRITER because $150K business loan needs review.

3. Submit a loan that needs senior review.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    TRUNCATE TABLE workflow_log;
    SELECT AI AGENT Process a $450000 mortgage for Jane Doe with credit score 750;
    </copy>
    ```

4. Check the routing.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    SELECT step_name, step_detail FROM workflow_log ORDER BY log_id;
    </copy>
    ```

**Observe:** Routed to SENIOR_UNDERWRITER because it's a mortgage over $250K.

5. Submit a loan that should be blocked.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    TRUNCATE TABLE workflow_log;
    SELECT AI AGENT Process a $25000 personal loan for Bob Wilson with credit score 520;
    </copy>
    ```

6. Check the routing.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    SELECT step_name, step_detail FROM workflow_log ORDER BY log_id;
    </copy>
    ```

**Observe:** BLOCKED because credit score 520 is below minimum 550.

## Task 6: Compare All Loans and Their Routes

Let's see all the loans and their different routing decisions.

> This command is already in your notebook—just click the play button (▶) to run it.

```sql
<copy>
SELECT 
    request_id,
    applicant,
    amount,
    loan_type,
    credit_score,
    risk_level,
    routed_to,
    status
FROM loan_requests
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
* Watched a multi-step workflow execute with risk assessment
* Traced tool calls through history views
* Saw how different inputs lead to different routing paths

**Key takeaway:** The agent orchestrates, the LLM thinks, the tools act. Every step is logged. Every action is traceable. For Seer Equity, this means small loans auto-approve in seconds, complex loans get routed appropriately, and compliance has a complete audit trail.

## Learn More

* [`DBMS_CLOUD_AI_AGENT` Package](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/dbms-cloud-ai-agent-package.html)

## Acknowledgements

* **Author** - David Start
* **Last Updated By/Date** - David Start, January 2026

## Cleanup (Optional)

> This command is already in your notebook—just click the play button (▶) to run it.

```sql
<copy>
EXEC DBMS_CLOUD_AI_AGENT.DROP_TEAM('LOAN_EXEC_TEAM', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TASK('LOAN_EXEC_TASK', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_AGENT('LOAN_EXEC_AGENT', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('CREATE_LOAN_TOOL', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('ASSESS_ROUTE_TOOL', TRUE);
DROP TABLE loan_requests PURGE;
DROP TABLE workflow_log PURGE;
DROP SEQUENCE loan_requests_seq;
DROP FUNCTION create_loan_request;
DROP FUNCTION assess_and_route;
</copy>
```
