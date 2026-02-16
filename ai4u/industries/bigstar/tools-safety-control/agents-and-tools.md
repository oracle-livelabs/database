# Tools, Safety, and Human Control

## Introduction

In this lab, you'll build the guardrails that make agents safe for production in retail collectibles.

Agents that can do anything are dangerous. In regulated environments like collectibles authentication, you need role-based access, separation of duties, and complete audit trails. This lab shows you how to build agents with proper controls.

### The Business Problem

At Big Star Collectibles, compliance requires separation of duties: the person who submits an item for authentication cannot be the same person who grades and prices it.

> *"Our current system doesn't enforce this. It's just a policy people are supposed to follow. We're one mistake away from a provenance disaster."*
>
> Compliance Officer

Big Star Collectibles needs:
- **Role-based agents**: Inventory specialists can submit but not grade
- **Automatic safety rules**: Items below condition grade 3.0 auto-reject
- **Smart routing**: Common items auto-list, rare ones get expert review
- **Complete audit trails**: Every decision logged with rationale

### What You'll Learn

This lab shows you how to build safe, controlled agent systems with:

1. Multiple agents with different capabilities
2. Role-based tool access (what each agent can do)
3. Automatic safety rules (what gets blocked)
4. Conditional routing (where work goes based on rules)
5. Complete audit logging (provenance for everything)

**What you'll build:** A two-agent system with enforced separation of duties and automatic routing.

Estimated Time: 15 minutes

### Objectives

* Build agents with restricted tool access
* Implement automatic safety rules
* Create conditional routing logic
* Log every action for compliance
* Understand how to make agents production-safe

### Prerequisites

For this workshop, we provide the environment. You'll need:

* Basic knowledge of SQL and PL/SQL, or the ability to follow along with the prompts

## Task 1: Import the Lab Notebook

Before you begin, import the notebook for this lab.

1. From the Oracle Machine Learning home page, click **Notebooks**.

2. Click **Import** to expand the Import drop down.

3. Select **Git**.

4. Paste the following GitHub URL leaving the credential field blank:

    ```text
    <copy>
    https://github.com/davidastart/database/blob/main/ai4u/industries/bigstar/tools-safety-control/lab10-tools-safety-control.json
    </copy>
    ```

5. Click **Ok**.

## Task 2: Create the Authentication Workflow Tables

Set up tables for item submissions, workflow tracking, and audit logging.

> This command is already in your notebook—just click the play button (▶) to run it.

```sql
<copy>
CREATE SEQUENCE submission_seq START WITH 1001;

-- Table for item submissions
CREATE TABLE item_submissions_wf (
    submission_id    VARCHAR2(20) PRIMARY KEY,
    submitter        VARCHAR2(100),
    submitted_by     VARCHAR2(100),
    item_type        VARCHAR2(50),
    condition_grade  NUMBER(3,1),
    estimated_value  NUMBER(12,2),
    rarity_level     VARCHAR2(30),
    status           VARCHAR2(50) DEFAULT 'SUBMITTED',
    routed_to        VARCHAR2(50),
    graded_by        VARCHAR2(100),
    final_grade      NUMBER(3,1),
    created_at       TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_at       TIMESTAMP
);

-- Audit log table
CREATE TABLE audit_log (
    log_id        NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    submission_id VARCHAR2(20),
    action_type   VARCHAR2(50),
    performed_by  VARCHAR2(100),
    action_detail VARCHAR2(1000),
    logged_at     TIMESTAMP DEFAULT SYSTIMESTAMP
);
</copy>
```

## Task 3: Create INVENTORY_AGENT Tools (Submit Only)

The inventory agent can submit items but cannot grade them.

> This command is already in your notebook—just click the play button (▶) to run it.

```sql
<copy>
-- Tool 1: Submit item for authentication
CREATE OR REPLACE FUNCTION submit_item_for_auth(
    p_submitter      VARCHAR2,
    p_submitted_by   VARCHAR2,
    p_item_type      VARCHAR2,
    p_condition      NUMBER,
    p_est_value      NUMBER
) RETURN VARCHAR2 AS
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_submission_id VARCHAR2(20);
    v_rarity VARCHAR2(30);
    v_route VARCHAR2(50);
BEGIN
    v_submission_id := 'SUB-' || TO_CHAR(SYSDATE, 'YYMMDD') || '-' || submission_seq.NEXTVAL;

    -- Automatic safety rules
    IF p_condition < 3.0 THEN
        v_rarity := 'DAMAGED';
        v_route := 'AUTO_REJECTED';
    ELSIF p_item_type IN ('common_card', 'recent_issue') AND p_est_value < 500 AND p_condition >= 7.0 THEN
        v_rarity := 'LOW';
        v_route := 'AUTO_LISTED';
    ELSIF p_est_value < 5000 THEN
        v_rarity := 'MEDIUM';
        v_route := 'STANDARD_APPRAISAL';
    ELSE
        v_rarity := 'HIGH';
        v_route := 'EXPERT_APPRAISAL';
    END IF;

    -- Insert submission
    INSERT INTO item_submissions_wf (
        submission_id, submitter, submitted_by, item_type,
        condition_grade, estimated_value, rarity_level,
        status, routed_to
    ) VALUES (
        v_submission_id, p_submitter, p_submitted_by, p_item_type,
        p_condition, p_est_value, v_rarity,
        CASE WHEN v_route IN ('AUTO_REJECTED', 'AUTO_LISTED') THEN v_route ELSE 'PENDING_AUTH' END,
        v_route
    );

    -- Log the action
    INSERT INTO audit_log (submission_id, action_type, performed_by, action_detail)
    VALUES (
        v_submission_id,
        'SUBMIT',
        p_submitted_by,
        'Submitted ' || p_item_type || ' with condition ' || p_condition || ', routed to ' || v_route
    );

    COMMIT;

    RETURN 'Submitted ' || v_submission_id || ' - Routed to: ' || v_route;
END;
/

-- Register the submit tool (INVENTORY_AGENT only)
BEGIN
    DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
        tool_name   => 'SUBMIT_ITEM_TOOL',
        attributes  => '{"instruction": "Submit an item for authentication. Parameters: submitter name, submitted_by (your agent name), item_type, condition_grade (1-10), estimated_value. Returns submission ID and routing.",
                        "function": "submit_item_for_auth"}',
        description => 'Submits items for authentication (inventory specialists only)'
    );
END;
/
</copy>
```

## Task 4: Create AUTHENTICATION_AGENT Tools (Grade Only)

The authentication agent can grade and price items but cannot submit them.

> This command is already in your notebook—just click the play button (▶) to run it.

```sql
<copy>
-- Tool 2: View pending submissions
CREATE OR REPLACE FUNCTION view_pending_submissions(
    p_route_type VARCHAR2 DEFAULT NULL
) RETURN CLOB AS
    v_result CLOB := '';
    v_count  NUMBER := 0;
BEGIN
    FOR rec IN (
        SELECT submission_id, submitter, item_type, condition_grade,
               estimated_value, routed_to
        FROM item_submissions_wf
        WHERE status = 'PENDING_AUTH'
        AND (p_route_type IS NULL OR routed_to = p_route_type)
        ORDER BY created_at
    ) LOOP
        v_result := v_result ||
                   'ID: ' || rec.submission_id ||
                   ', Submitter: ' || rec.submitter ||
                   ', Type: ' || rec.item_type ||
                   ', Condition: ' || rec.condition_grade ||
                   ', Value: $' || rec.estimated_value ||
                   ', Route: ' || rec.routed_to || CHR(10);
        v_count := v_count + 1;
    END LOOP;

    IF v_count = 0 THEN RETURN 'No pending submissions'; END IF;
    RETURN 'Found ' || v_count || ' pending items:' || CHR(10) || v_result;
END;
/

-- Tool 3: Authenticate and grade
CREATE OR REPLACE FUNCTION authenticate_and_grade(
    p_submission_id VARCHAR2,
    p_graded_by     VARCHAR2,
    p_final_grade   NUMBER,
    p_rationale     VARCHAR2
) RETURN VARCHAR2 AS
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_submitter VARCHAR2(100);
BEGIN
    -- Get submitter to check separation of duties
    SELECT submitted_by INTO v_submitter
    FROM item_submissions_wf
    WHERE submission_id = p_submission_id;

    -- Enforce separation of duties
    IF v_submitter = p_graded_by THEN
        RETURN 'BLOCKED: Cannot grade item you submitted (separation of duties)';
    END IF;

    -- Update with grade
    UPDATE item_submissions_wf
    SET final_grade = p_final_grade,
        graded_by = p_graded_by,
        status = 'AUTHENTICATED',
        updated_at = SYSTIMESTAMP
    WHERE submission_id = p_submission_id;

    -- Log the action
    INSERT INTO audit_log (submission_id, action_type, performed_by, action_detail)
    VALUES (
        p_submission_id,
        'AUTHENTICATE',
        p_graded_by,
        'Graded at ' || p_final_grade || '. Rationale: ' || p_rationale
    );

    COMMIT;

    RETURN 'Authenticated ' || p_submission_id || ' with grade ' || p_final_grade;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'Submission not found: ' || p_submission_id;
END;
/

-- Register authentication tools (AUTHENTICATION_AGENT only)
BEGIN
    DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
        tool_name   => 'VIEW_PENDING_TOOL',
        attributes  => '{"instruction": "View items pending authentication. Optional: filter by route type (STANDARD_APPRAISAL or EXPERT_APPRAISAL).",
                        "function": "view_pending_submissions"}',
        description => 'Views pending authentication submissions'
    );

    DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
        tool_name   => 'AUTHENTICATE_TOOL',
        attributes  => '{"instruction": "Authenticate and grade an item. Parameters: submission_id, graded_by (your agent name), final_grade (1-10), rationale. Cannot grade items you submitted.",
                        "function": "authenticate_and_grade"}',
        description => 'Authenticates and grades items (authenticators only)'
    );
END;
/
</copy>
```

## Task 5: Create Two Role-Based Agents

Create two agents with different tool access.

> This command is already in your notebook—just click the play button (▶) to run it.

```sql
<copy>
-- INVENTORY_AGENT (can submit, cannot grade)
BEGIN
    DBMS_CLOUD_AI_AGENT.CREATE_AGENT(
        agent_name  => 'INVENTORY_AGENT',
        attributes  => '{"profile_name": "genai",
                        "role": "You are INVENTORY_AGENT for Big Star Collectibles inventory specialists. You can submit items for authentication using SUBMIT_ITEM_TOOL. You CANNOT grade or authenticate items. Always use INVENTORY_AGENT as your agent name when calling tools."}',
        description => 'Agent for inventory specialists (submit only)'
    );

    DBMS_CLOUD_AI_AGENT.CREATE_TASK(
        task_name   => 'INVENTORY_TASK',
        attributes  => '{"instruction": "Help inventory specialists submit items. Use SUBMIT_ITEM_TOOL to create submissions. You cannot grade items. User request: {query}",
                        "tools": ["SUBMIT_ITEM_TOOL"]}',
        description => 'Task for inventory operations'
    );

    DBMS_CLOUD_AI_AGENT.CREATE_TEAM(
        team_name   => 'INVENTORY_TEAM',
        attributes  => '{"agents": [{"name": "INVENTORY_AGENT", "task": "INVENTORY_TASK"}],
                        "process": "sequential"}',
        description => 'Team for inventory specialists'
    );
END;
/

-- AUTHENTICATION_AGENT (can grade, cannot submit)
BEGIN
    DBMS_CLOUD_AI_AGENT.CREATE_AGENT(
        agent_name  => 'AUTHENTICATION_AGENT',
        attributes  => '{"profile_name": "genai",
                        "role": "You are AUTHENTICATION_AGENT for Big Star Collectibles authenticators. You can view pending items with VIEW_PENDING_TOOL and authenticate them with AUTHENTICATE_TOOL. You CANNOT submit items. Always use AUTHENTICATION_AGENT as your agent name when calling tools."}',
        description => 'Agent for authenticators (grade only)'
    );

    DBMS_CLOUD_AI_AGENT.CREATE_TASK(
        task_name   => 'AUTHENTICATION_TASK',
        attributes  => '{"instruction": "Help authenticators grade items. Use VIEW_PENDING_TOOL to see pending items. Use AUTHENTICATE_TOOL to grade them. You cannot submit items. User request: {query}",
                        "tools": ["VIEW_PENDING_TOOL", "AUTHENTICATE_TOOL"]}',
        description => 'Task for authentication operations'
    );

    DBMS_CLOUD_AI_AGENT.CREATE_TEAM(
        team_name   => 'AUTHENTICATION_TEAM',
        attributes  => '{"agents": [{"name": "AUTHENTICATION_AGENT", "task": "AUTHENTICATION_TASK"}],
                        "process": "sequential"}',
        description => 'Team for authenticators'
    );
END;
/
</copy>
```

## Task 6: Test Separation of Duties

See the role-based access control in action.

> This command is already in your notebook—just click the play button (▶) to run it.

```sql
<copy>
-- Test 1: Inventory specialist submits an item
EXEC DBMS_CLOUD_AI_AGENT.SET_TEAM('INVENTORY_TEAM');
SELECT AI AGENT Submit a vintage_comic for John Smith, condition grade 8.5, estimated value $1500. My agent name is INVENTORY_AGENT;
</copy>
```

**Observe:** The item is submitted and automatically routed based on value and condition.

```sql
<copy>
-- Test 2: Authenticator views pending items
EXEC DBMS_CLOUD_AI_AGENT.SET_TEAM('AUTHENTICATION_TEAM');
SELECT AI AGENT Show me items pending standard appraisal;
</copy>
```

**Observe:** The authenticator can see pending submissions.

```sql
<copy>
-- Test 3: Authenticator grades the item (use actual submission ID from step 1)
SELECT AI AGENT Authenticate submission SUB-XXXXXX-1001 with grade 8.5 and rationale that it shows excellent preservation with minor wear. My agent name is AUTHENTICATION_AGENT;
</copy>
```

**Observe:** Authentication succeeds because different agents submitted and graded.

## Task 7: Test Automatic Safety Rules

See the safety rules block bad submissions.

> This command is already in your notebook—just click the play button (▶) to run it.

```sql
<copy>
EXEC DBMS_CLOUD_AI_AGENT.SET_TEAM('INVENTORY_TEAM');

-- Test damaged item (condition < 3.0)
SELECT AI AGENT Submit a recent_issue for Bob Wilson, condition grade 2.5, estimated value $200. My agent name is INVENTORY_AGENT;
</copy>
```

**Observe:** Automatically routed to AUTO_REJECTED because condition grade is below 3.0.

```sql
<copy>
-- Test auto-list item
SELECT AI AGENT Submit a common_card for Sarah Lee, condition grade 8.0, estimated value $350. My agent name is INVENTORY_AGENT;
</copy>
```

**Observe:** Automatically routed to AUTO_LISTED (common card under $500 with good condition).

## Task 8: View the Complete Audit Trail

Check the audit log to see every action.

> This command is already in your notebook—just click the play button (▶) to run it.

```sql
<copy>
SELECT
    submission_id,
    action_type,
    performed_by,
    action_detail,
    TO_CHAR(logged_at, 'YYYY-MM-DD HH24:MI:SS') as when_logged
FROM audit_log
ORDER BY logged_at DESC;
</copy>
```

**Every action is logged:** Who submitted, who graded, what decisions were made, and when.

## Task 9: See All Submissions and Their Routes

Query the workflow table to see routing decisions.

> This command is already in your notebook—just click the play button (▶) to run it.

```sql
<copy>
SELECT
    submission_id,
    submitter,
    submitted_by,
    item_type,
    condition_grade,
    rarity_level,
    routed_to,
    status,
    graded_by,
    final_grade
FROM item_submissions_wf
ORDER BY created_at;
</copy>
```

## Summary

In this lab, you built a production-safe agent system:

* **Role-based agents**: INVENTORY_AGENT can submit, AUTHENTICATION_AGENT can grade
* **Tool restrictions**: Each agent has access only to appropriate tools
* **Automatic safety**: Damaged items auto-reject, common items auto-list
* **Conditional routing**: Items route based on value and rarity
* **Separation of duties**: Agents cannot grade their own submissions
* **Complete audit trail**: Every action logged for provenance

**Key takeaway:** Production agents need guardrails. For Big Star Collectibles, this means inventory specialists can't grade items they submit, damaged items automatically reject, routine items auto-list without review, and every decision has a complete audit trail. This is how you make agents safe for regulated environments.

## Learn More

* [`DBMS_CLOUD_AI_AGENT` Package](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/dbms-cloud-ai-agent-package.html)

## Acknowledgements

* **Author** - David Start
* **Last Updated By/Date** - David Start, January 2026

## Cleanup (Optional)

> This command is already in your notebook—just click the play button (▶) to run it.

```sql
<copy>
EXEC DBMS_CLOUD_AI_AGENT.DROP_TEAM('INVENTORY_TEAM', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TEAM('AUTHENTICATION_TEAM', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TASK('INVENTORY_TASK', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TASK('AUTHENTICATION_TASK', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_AGENT('INVENTORY_AGENT', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_AGENT('AUTHENTICATION_AGENT', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('SUBMIT_ITEM_TOOL', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('VIEW_PENDING_TOOL', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('AUTHENTICATE_TOOL', TRUE);
DROP TABLE item_submissions_wf PURGE;
DROP TABLE audit_log PURGE;
DROP SEQUENCE submission_seq;
DROP FUNCTION submit_item_for_auth;
DROP FUNCTION view_pending_submissions;
DROP FUNCTION authenticate_and_grade;
</copy>
```
