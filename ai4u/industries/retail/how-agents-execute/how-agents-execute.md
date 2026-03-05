# How Agents Execute the Work

## Introduction

Plans mean little without action. In this lab, Seer Equity Retail implements execution logic that routes submissions, writes workflow logs, and enforces the three-tier appraisal model: Auto-List, Standard Appraisal, Expert Appraisal, plus Blocked exceptions.

### Scenario

Jennifer Lee, Lead Inventory Specialist, needs the system to decide how to route ITEM-30214. The agent must evaluate value, rarity, and condition, insert workflow records, and trigger the right human or automated follow-up.

### Objectives

- Build PL/SQL packages that evaluate submissions against routing thresholds.
- Register execution tools for routing, logging, and status updates.
- Drive `ROUTING_AGENT` to call the correct tool chain, record decisions, and hand off escalations.

## Task 1: Import the Execution Notebook

Open `lab4-execution.json` in Oracle Machine Learning. Use it to execute the SQL blocks below.

## Task 2: Create Workflow Tables

These tables persist routing steps and audit-ready context.

```sql
<copy>
CREATE TABLE item_requests (
    request_id        VARCHAR2(36) PRIMARY KEY,
    submission_id     VARCHAR2(20) NOT NULL,
    requested_tier    VARCHAR2(20) NOT NULL,
    requested_by      VARCHAR2(50) NOT NULL,
    request_ts        DATE DEFAULT SYSDATE,
    notes             CLOB
);

CREATE TABLE item_workflow_log (
    log_id            VARCHAR2(36) PRIMARY KEY,
    submission_id     VARCHAR2(20) NOT NULL,
    action_type       VARCHAR2(30) NOT NULL,
    routed_tier       VARCHAR2(20),
    actor             VARCHAR2(50) NOT NULL,
    status_note       CLOB,
    action_ts         DATE DEFAULT SYSDATE
);
</copy>
```

## Task 3: Implement Routing Logic

```sql
<copy>
CREATE OR REPLACE PACKAGE retail_routing AS
    FUNCTION assess_item(
        p_submission_id    VARCHAR2,
        p_declared_value   NUMBER,
        p_condition_grade  NUMBER,
        p_rarity_code      VARCHAR2
    ) RETURN VARCHAR2;
END retail_routing;
/

CREATE OR REPLACE PACKAGE BODY retail_routing AS
    FUNCTION assess_item(
        p_submission_id    VARCHAR2,
        p_declared_value   NUMBER,
        p_condition_grade  NUMBER,
        p_rarity_code      VARCHAR2
    ) RETURN VARCHAR2 AS
    BEGIN
        IF p_condition_grade < 3.0 OR p_rarity_code = 'FLAGGED' THEN
            RETURN 'BLOCKED';
        ELSIF p_declared_value < 500 AND p_condition_grade >= 7.0 AND p_rarity_code = 'COMMON' THEN
            RETURN 'AUTO_LIST';
        ELSIF (p_declared_value BETWEEN 500 AND 5000)
              OR (p_condition_grade BETWEEN 5.0 AND 6.9)
              OR p_rarity_code = 'LIMITED' THEN
            RETURN 'STANDARD_APPRAISAL';
        ELSE
            RETURN 'EXPERT_APPRAISAL';
        END IF;
    END assess_item;
END retail_routing;
/
</copy>
```

## Task 4: Register Execution Tools

```sql
<copy>
BEGIN
    DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
        tool_name   => 'ROUTING_DECISION_TOOL',
        attributes  => '{"tool_type":"SQL","tool_params":{"profile_name":"inventory_profile"}}',
        description => 'Call retail_routing.assess_item to determine routing tier.'
    );

    DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
        tool_name   => 'REQUEST_WRITE_TOOL',
        attributes  => '{"tool_type":"SQL","tool_params":{"profile_name":"inventory_profile"}}',
        description => 'Insert routing requests into ITEM_REQUESTS.'
    );

    DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
        tool_name   => 'WORKFLOW_LOG_TOOL',
        attributes  => '{"tool_type":"SQL","tool_params":{"profile_name":"inventory_profile"}}',
        description => 'Append execution details to ITEM_WORKFLOW_LOG.'
    );
END;
/
</copy>
```

## Task 5: Define the Routing Agent

```sql
<copy>
BEGIN
    DBMS_CLOUD_AI_AGENT.CREATE_AGENT(
        agent_name => 'ROUTING_AGENT',
        attributes => json_object(
            'role' VALUE 'You evaluate Seer Equity retail submissions, selecting routing tiers and logging actions.',
            'instructions' VALUE 'Always report the routing tier and log your decision with rationale referencing value, condition, and rarity.'
        )
    );
END;
/

BEGIN
    DBMS_CLOUD_AI_AGENT.CREATE_TASK(
        task_name  => 'ROUTING_TASK',
        attributes => json_object(
            'prompt' VALUE 'Route the submission based on value, condition, and rarity.
Request: {query}',
            'tools'  VALUE json_array('ROUTING_DECISION_TOOL', 'REQUEST_WRITE_TOOL', 'WORKFLOW_LOG_TOOL')
        )
    );
END;
/

BEGIN
    DBMS_CLOUD_AI_AGENT.CREATE_TEAM(
        team_name  => 'ROUTING_TEAM',
        attributes => json_object(
            'agents'  VALUE json_array(json_object('name' VALUE 'ROUTING_AGENT', 'task' VALUE 'ROUTING_TASK')),
            'process' VALUE 'sequential'
        )
    );
END;
/
</copy>
```

## Task 6: Execute a Routing Request

```sql
<copy>
EXEC DBMS_CLOUD_AI_AGENT.SET_TEAM('ROUTING_TEAM');
SELECT AI AGENT 'Evaluate submission ITEM-30214 with declared value 7200, condition grade 9.1, rarity GRAIL. Route it and log the action.';
</copy>
```

Verify results:

```sql
<copy>
SELECT submission_id, requested_tier, requested_by
  FROM item_requests
 ORDER BY request_ts DESC
 FETCH FIRST 5 ROWS;

SELECT submission_id, routed_tier, status_note
  FROM item_workflow_log
 ORDER BY action_ts DESC
 FETCH FIRST 5 ROWS;
</copy>
```

Expect `EXPERT_APPRAISAL` for the high-value, rare item. Repeat with lower-value submissions to observe `AUTO_LIST` and `STANDARD_APPRAISAL` tiers.

## Task 7: Handle Blocked Scenarios

```sql
<copy>
SELECT AI AGENT 'Evaluate submission ITEM-40103 with declared value 360, condition 2.5, rarity FLAGGED. Route it and log the result.';
</copy>
```

Confirm the log records `BLOCKED` with rationale for compliance review.

## Summary

Seer Equity Retail now routes submissions with parity to the finance baseline while reflecting authentic retail triggers. The agent writes every decision to workflow logs, preserving auditable context for governance and human follow-up.

## Workshop Plan (Generated)
- Implement routing logic mapping value, rarity, and condition to Auto-List, Standard Appraisal, and Expert Appraisal.
- Show `AUTHENTICATION_AGENT` executing tool chains that write to `ITEM_REQUESTS` and `ITEM_WORKFLOW_LOG`.
- Validate parity with original three-tier thresholds while embedding retail-specific table names and status values.
