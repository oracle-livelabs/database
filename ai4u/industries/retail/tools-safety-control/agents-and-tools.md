# Tools, Safety, and Human Control

## Introduction

Automation without control invites risk. This lab enforces Seer Equity Retail’s governance playbook: separation of duties, explicit tool permissions, audit logging, and human escalation for expert-tier decisions.

### Scenario

David Huang must prove to compliance that inventory specialists cannot authenticate items and authenticators cannot submit new ones. He also needs a full audit trail when Marcus Patel overrides an auto-list recommendation.

### Objectives

- Register tools for submission intake, authentication, and audit logging with scoped profiles.
- Configure `INVENTORY_AGENT` and `AUTHENTICATION_AGENT` with non-overlapping tool sets.
- Implement escalation logic requiring human approval for Expert Appraisal.
- Demonstrate audit queries that show every decision’s provenance.

## Task 1: Define Tool Registry Entries

```sql
<copy>
CREATE TABLE tool_registry (
    tool_name        VARCHAR2(50) PRIMARY KEY,
    description      VARCHAR2(200),
    allowed_roles    VARCHAR2(200)
);

INSERT INTO tool_registry VALUES ('ITEM_SUBMIT_TOOL', 'Create new item submissions.', 'INVENTORY_AGENT');
INSERT INTO tool_registry VALUES ('AUTHENTICATE_TOOL', 'Authenticate and grade submissions.', 'AUTHENTICATION_AGENT');
INSERT INTO tool_registry VALUES ('AUDIT_APPEND_TOOL', 'Write structured audit events.', 'AUTHENTICATION_AGENT');
COMMIT;
</copy>
```

## Task 2: Create Audit Logging Procedure

```sql
<copy>
CREATE OR REPLACE PROCEDURE append_audit_entry(
    p_actor        VARCHAR2,
    p_submission   VARCHAR2,
    p_action       VARCHAR2,
    p_details      CLOB
) AS
BEGIN
    INSERT INTO audit_log (audit_id, actor, submission_id, action_type, action_details, action_ts)
    VALUES (
        sys_guid(),
        p_actor,
        p_submission,
        p_action,
        p_details,
        SYSDATE
    );
END;
/
</copy>
```

## Task 3: Register Governance Tools

```sql
<copy>
BEGIN
    DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
        tool_name   => 'ITEM_SUBMIT_TOOL',
        attributes  => '{"tool_type":"SQL","tool_params":{"profile_name":"inventory_profile"}}',
        description => 'Insert new records into ITEM_SUBMISSIONS under intake supervision.'
    );

    DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
        tool_name   => 'AUTHENTICATE_TOOL',
        attributes  => '{"tool_type":"SQL","tool_params":{"profile_name":"authentication_profile"}}',
        description => 'Update submission status, write workflow logs, and append audit entries.'
    );

    DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
        tool_name   => 'AUDIT_APPEND_TOOL',
        attributes  => '{"tool_type":"SQL","tool_params":{"profile_name":"authentication_profile"}}',
        description => 'Invoke append_audit_entry with structured payloads.'
    );
END;
/
</copy>
```

## Task 4: Enforce Separation of Duties

```sql
<copy>
BEGIN
    DBMS_CLOUD_AI_AGENT.UPDATE_AGENT(
        agent_name => 'INVENTORY_AGENT',
        attributes => json_object(
            'tools' VALUE json_array('ITEM_SUBMIT_TOOL', 'ITEM_LOOKUP_TOOL', 'MEMORY_LOOKUP_TOOL')
        )
    );
END;
/

BEGIN
    DBMS_CLOUD_AI_AGENT.UPDATE_AGENT(
        agent_name => 'AUTHENTICATION_AGENT',
        attributes => json_object(
            'tools' VALUE json_array('AUTHENTICATE_TOOL', 'POLICY_LOOKUP_TOOL', 'REFERENCE_LOOKUP_TOOL', 'MEMORY_LOOKUP_TOOL', 'PRECEDENT_SEARCH_TOOL', 'AUDIT_APPEND_TOOL')
        )
    );
END;
/
</copy>
```

## Task 5: Implement Escalation Workflow

Expert Appraisal requires human approval. Use a stored procedure to enforce the checkpoint.

```sql
<copy>
CREATE OR REPLACE PROCEDURE escalate_expert_appraisal(
    p_submission_id VARCHAR2,
    p_reviewer      VARCHAR2,
    p_notes         CLOB
) AS
BEGIN
    INSERT INTO audit_log (audit_id, actor, submission_id, action_type, action_details, action_ts)
    VALUES (
        sys_guid(),
        p_reviewer,
        p_submission_id,
        'EXPERT_ESCALATION',
        p_notes,
        SYSDATE
    );

    UPDATE item_submissions
       SET current_status = 'EXPERT_REVIEW'
     WHERE submission_id = p_submission_id;
END;
/
</copy>
```

Expose the escalation routine as a tool reserved for human supervisors.

```sql
<copy>
BEGIN
    DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
        tool_name   => 'EXPERT_ESCALATE_TOOL',
        attributes  => '{"tool_type":"SQL","tool_params":{"profile_name":"authentication_profile"}}',
        description => 'Escalate submissions to human expert reviewers with audit logging.'
    );
END;
/
```

Assign the tool to supervisory tasks only (documented in the notebook with manual execution).

## Task 6: Demonstrate Controlled Execution

1. Inventory specialist submits a new item:

```sql
<copy>
EXEC DBMS_CLOUD_AI_AGENT.SET_TEAM('INVENTORY_SUPPORT_TEAM');
SELECT AI AGENT 'Create a submission for ITEM-41210, declared value 320, condition 7.5, rarity COMMON.';
</copy>
```

2. Authentication agent processes the submission:

```sql
<copy>
EXEC DBMS_CLOUD_AI_AGENT.SET_TEAM('ROUTING_TEAM');
SELECT AI AGENT 'Route submission ITEM-41210 based on declared value 320, condition 7.5, rarity COMMON.';
</copy>
```

3. Audit log verification:

```sql
<copy>
SELECT actor, submission_id, action_type, action_details
  FROM audit_log
 ORDER BY action_ts DESC
 FETCH FIRST 5 ROWS;
</copy>
```

## Task 7: Validate Permissions

Ensure privilege boundaries hold.

```sql
<copy>
-- Inventory user should fail to authenticate submissions
CONNECT inventory_agent_user/<password>
EXEC authenticate_tool(...); -- should raise insufficient privileges

-- Authentication user should fail to insert submissions
CONNECT authentication_agent_user/<password>
EXEC item_submit_tool(...); -- should raise insufficient privileges
</copy>
```

(Provide instructions in the notebook for switching credentials.)

## Summary

Governed tool assignments, audit trails, and expert escalation protect Seer Equity Retail from unauthorized actions. Agents remain powerful yet controllable, satisfying compliance while accelerating operations.

## Workshop Plan (Generated)
- Reinforce tool registration, role separation, and audit logging for inventory vs authentication agents.
- Include policy checks ensuring loyalty data isn’t exposed outside authorized tools.
- Demonstrate escalation workflows requiring human approval for Expert Appraisal tier decisions.
- Document audit trail queries proving provenance and compliance for Seer Equity executives.
