# Why Agents Beat Zero-Shot Prompts

## Introduction

Zero-shot prompts describe processes. Seer Equity Retail needs automation that actually completes them. In this lab you will compare a plain LLM prompt, a Select AI query, and a governed agent that updates retail submission data in real time.

### Scenario

Marcus Patel, Senior Authenticator, wants to move a batch of submissions. He needs to know which items remain in `AUTHENTICATING` status and mark any finished pieces as `GRADED`. The chatbot explains steps. The agent with tools executes them.

### Objectives

- Create a `SAMPLE_ITEMS` table with retail-specific status values.
- Register lookup and update PL/SQL functions as tools on `inventory_profile`.
- Contrast zero-shot chat, Select AI, and SELECT AI AGENT behavior.
- Demonstrate guardrails so only inventory roles can update statuses.

## Task 1: Import the Lab Notebook

Open `lab2-agents-vs-zero-shot.json` in Oracle Machine Learning and run the cells as instructed.

## Task 2: Experience Zero-Shot Prompting

```sql
<copy>
EXEC DBMS_CLOUD_AI.SET_PROFILE('inventory_profile');
SELECT AI CHAT How do I check the status of a collector submission;
SELECT AI CHAT What is the status of submission ITEM-30214;
SELECT AI CHAT Update submission ITEM-30214 to graded;
</copy>
```

Observe that the responses describe actions but do not access Seer Equity data.

## Task 3: Build Sample Items for Testing

```sql
<copy>
CREATE TABLE sample_items (
    submission_id   VARCHAR2(20) PRIMARY KEY,
    submitter       VARCHAR2(100),
    item_type       VARCHAR2(40),
    status          VARCHAR2(30),
    declared_value  NUMBER(12,2),
    condition_grade NUMBER(3,1),
    last_update_ts  DATE DEFAULT SYSDATE
);

COMMENT ON COLUMN sample_items.status IS 'SUBMITTED, AUTHENTICATING, GRADED, LISTED, or REJECTED.';

INSERT INTO sample_items VALUES ('ITEM-40101', 'Alex Martinez', 'Sports Card', 'AUTHENTICATING', 7200, 9.1, SYSDATE - 2);
INSERT INTO sample_items VALUES ('ITEM-40102', 'Maria Santos', 'Vintage Comic', 'GRADED', 2100, 8.3, SYSDATE - 4);
INSERT INTO sample_items VALUES ('ITEM-40103', 'James Wilson', 'Memorabilia', 'SUBMITTED', 360, 6.2, SYSDATE - 1);
INSERT INTO sample_items VALUES ('ITEM-40104', 'Priya Desai', 'Limited Sneaker', 'LISTED', 980, 8.8, SYSDATE - 3);
COMMIT;
</copy>
```

## Task 4: Register Lookup and Update Tools

```sql
<copy>
CREATE OR REPLACE FUNCTION lookup_sample_item(p_submission_id VARCHAR2) RETURN CLOB AS
    v_payload CLOB;
BEGIN
    SELECT json_object(
               'submission_id' VALUE submission_id,
               'status' VALUE status,
               'item_type' VALUE item_type,
               'declared_value' VALUE declared_value,
               'condition_grade' VALUE condition_grade,
               'last_update_ts' VALUE TO_CHAR(last_update_ts, 'YYYY-MM-DD HH24:MI:SS')
           )
      INTO v_payload
      FROM sample_items
     WHERE submission_id = p_submission_id;
    RETURN v_payload;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN json_object('error' VALUE 'Submission not found');
END;
/

CREATE OR REPLACE FUNCTION update_sample_item_status(
    p_submission_id VARCHAR2,
    p_new_status    VARCHAR2
) RETURN VARCHAR2 AS
BEGIN
    UPDATE sample_items
       SET status = p_new_status,
           last_update_ts = SYSDATE
     WHERE submission_id = p_submission_id;

    IF SQL%ROWCOUNT = 0 THEN
        RETURN 'No submission updated';
    END IF;

    RETURN 'Status updated to ' || p_new_status;
END;
/
</copy>
```

Expose the functions as governed tools.

```sql
<copy>
BEGIN
    DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
        tool_name     => 'ITEM_LOOKUP_TOOL',
        attributes    => '{"tool_type":"SQL","tool_params":{"profile_name":"inventory_profile"}}',
        description   => 'Retrieves submission details for Seer Equity retail items.'
    );

    DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
        tool_name     => 'ITEM_UPDATE_TOOL',
        attributes    => '{"tool_type":"SQL","tool_params":{"profile_name":"inventory_profile"}}',
        description   => 'Updates submission status when policy allows.'
    );
END;
/
</copy>
```

## Task 5: Compare Interaction Modes

### Zero-Shot

```sql
<copy>
SELECT AI CHAT Mark ITEM-40101 as graded;
</copy>
```

### Select AI

```sql
<copy>
SELECT AI USING PROFILE inventory_profile 'What is the status of submission ITEM-40101?';
</copy>
```

### Agent Execution

```sql
<copy>
BEGIN
    DBMS_CLOUD_AI_AGENT.CREATE_AGENT(
        agent_name => 'RETAIL_STATUS_AGENT',
        attributes => json_object(
            'role' VALUE 'You verify and update Seer Equity retail submissions. Use tools, cite statuses, and log outcomes.',
            'instructions' VALUE 'Only update when the collector or policy requires it; otherwise report the current state.'
        )
    );
END;
/

BEGIN
    DBMS_CLOUD_AI_AGENT.CREATE_TASK(
        task_name  => 'STATUS_UPDATE_TASK',
        attributes => json_object(
            'prompt' VALUE 'Request: {query}',
            'tools'  VALUE json_array('ITEM_LOOKUP_TOOL', 'ITEM_UPDATE_TOOL')
        )
    );
END;
/

BEGIN
    DBMS_CLOUD_AI_AGENT.CREATE_TEAM(
        team_name  => 'STATUS_TEAM',
        attributes => json_object(
            'agents'  VALUE json_array(json_object('name' VALUE 'RETAIL_STATUS_AGENT', 'task' VALUE 'STATUS_UPDATE_TASK')),
            'process' VALUE 'sequential'
        )
    );
END;
/

EXEC DBMS_CLOUD_AI_AGENT.SET_TEAM('STATUS_TEAM');
SELECT AI AGENT 'Check submission ITEM-40101. If it is still authenticating, mark it as graded and confirm the change.';
</copy>
```

Verify the update happened:

```sql
<copy>
SELECT submission_id, status FROM sample_items WHERE submission_id = 'ITEM-40101';
</copy>
```

## Task 6: Enforce Guardrails

Allow updates for inventory specialists only.

```sql
<copy>
GRANT UPDATE ON sample_items TO inventory_agent_user;
REVOKE UPDATE ON sample_items FROM authentication_agent_user;
</copy>
```

Impersonate the authentication profile to confirm updates are blocked.

```sql
<copy>
EXEC DBMS_CLOUD_AI_AGENT.SET_PROFILE('authentication_profile');
SELECT AI AGENT 'Attempt to update submission ITEM-40102 to AUTHENTICATING.';
</copy>
```

The attempt should fail, proving role separation.

## Task 7: Log the Outcome

```sql
<copy>
INSERT INTO item_workflow_log (log_id, submitted_by, action, item_reference, status_note)
VALUES (
    sys_guid(),
    'INVENTORY_AGENT',
    'LAB2_AGENT_UPDATE',
    'ITEM-40101',
    'Agent changed status from AUTHENTICATING to GRADED using authorized tool'
);

COMMIT;
</copy>
```

Query recent tool history:

```sql
<copy>
SELECT tool_name, TO_CHAR(start_date, 'HH24:MI:SS') AS called_at
  FROM user_ai_agent_tool_history
 ORDER BY start_date DESC
 FETCH FIRST 5 ROWS ONLY;
</copy>
```

## Summary

Zero-shot prompting narrates instructions. Select AI retrieves data. Governed agents check conditions, invoke tools, and update records while leaving audit trails. Seer Equity Retail uses this pattern to keep authentication pipelines moving without losing control.

## Workshop Plan (Generated)
- Contrast zero-shot prompts vs governed agents through Marcus Patel’s batch authentication workflow.
- Update sample data and tool registrations (`ITEM_LOOKUP_TOOL`, `ITEM_UPDATE_TOOL`) with Seer Equity Retail naming.
- Demonstrate guardrails restricting updates to inventory roles while authenticators remain read-only.
- Capture audit log inserts that document automated transitions from AUTHENTICATING to GRADED states.
