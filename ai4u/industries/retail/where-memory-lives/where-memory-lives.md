# Where Agent Memory Should Live

## Introduction

Agent memory must be structured and governed. This lab designs Seer Equity Retail’s memory architecture by separating facts, tasks, decisions, and references across JSON storage, duality views, and audit boundaries.

### Scenario

David Huang, Governance Lead, wants confidence that Alex Martinez’s loyalty perks, open tasks, and precedent decisions live in the right stores with the correct retention policies. You will design schemas and confirm retrieval patterns.

### Objectives

- Model memory categories in `AGENT_MEMORY`, `DECISION_MEMORY`, and `REFERENCE_KNOWLEDGE`.
- Build JSON duality views for convenient access while keeping relational governance.
- Demonstrate CRUD patterns that respect role-based access.

## Task 1: Create Memory Views

```sql
<copy>
CREATE OR REPLACE VIEW memory_facts AS
SELECT content."about"        AS collector,
       content."fact"         AS fact_detail,
       content."category"     AS category,
       content."effective"    AS effective_date
  FROM agent_memory
 WHERE memory_type = 'FACT';

CREATE OR REPLACE VIEW memory_tasks AS
SELECT content."submission_id"  AS submission_id,
       content."task_detail"     AS task_detail,
       content."assigned_to"     AS assigned_to,
       content."due_at"          AS due_at
  FROM agent_memory
 WHERE memory_type = 'TASK';
</copy>
```

## Task 2: Populate Task Memories

```sql
<copy>
INSERT INTO agent_memory (memory_id, agent_id, memory_type, content)
VALUES (
    sys_guid(),
    'ROUTING_AGENT',
    'TASK',
    json_object(
        'submission_id' VALUE 'ITEM-40102',
        'task_detail'   VALUE 'Schedule standard appraisal follow-up with Marcus Patel.',
        'assigned_to'   VALUE 'AUTHENTICATION_AGENT',
        'due_at'        VALUE TO_CHAR(SYSDATE + 1, 'YYYY-MM-DD')
    ));

COMMIT;
</copy>
```

## Task 3: Model Decision Memory

```sql
<copy>
CREATE TABLE decision_memory (
    decision_id       VARCHAR2(36) PRIMARY KEY,
    submission_id     VARCHAR2(20),
    collector_name    VARCHAR2(100),
    decision_summary  CLOB,
    embedding_vector  VECTOR(1024),
    decided_by        VARCHAR2(50),
    decided_ts        DATE DEFAULT SYSDATE
);
</copy>
```

Explain how embeddings will be loaded in Lab 9 to power semantic search.

## Task 4: Create Duality Views

```sql
<copy>
CREATE OR REPLACE JSON RELATIONAL DUALITY VIEW decision_memory_view AS
  SELECT decision_id,
         json_object(
             'submission_id'    VALUE submission_id,
             'collector_name'   VALUE collector_name,
             'decision_summary' VALUE decision_summary,
             'decided_by'       VALUE decided_by,
             'decided_ts'       VALUE TO_CHAR(decided_ts, 'YYYY-MM-DD"T"HH24:MI:SS')
         )
    FROM decision_memory;
</copy>
```

## Task 5: Register Governance Tools

```sql
<copy>
BEGIN
    DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
        tool_name   => 'MEMORY_FACT_TOOL',
        attributes  => '{"tool_type":"SQL","tool_params":{"profile_name":"inventory_profile"}}',
        description => 'Retrieve fact memories for collectors.'
    );

    DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
        tool_name   => 'MEMORY_TASK_TOOL',
        attributes  => '{"tool_type":"SQL","tool_params":{"profile_name":"authentication_profile"}}',
        description => 'List pending tasks and due dates for authentication teams.'
    );
END;
/
</copy>
```

## Task 6: Enforce Access Control

- Inventory agents can read facts but not tasks.
- Authentication agents can read tasks but not modify facts without governance approval.

```sql
<copy>
GRANT SELECT ON memory_facts TO inventory_agent_user;
GRANT SELECT ON memory_tasks TO authentication_agent_user;
REVOKE SELECT ON memory_tasks FROM inventory_agent_user;
</copy>
```

## Task 7: Demonstrate Retrieval

```sql
<copy>
SELECT ai_response
  FROM TABLE(DBMS_CLOUD_AI.ASK_AGENT(
        agent_name => 'INVENTORY_AGENT',
        prompt     => 'List loyalty facts for Alex Martinez from memory_facts.' ));

SELECT ai_response
  FROM TABLE(DBMS_CLOUD_AI.ASK_AGENT(
        agent_name => 'AUTHENTICATION_AGENT',
        prompt     => 'Review open tasks for authentication agents using memory_tasks.' ));
</copy>
```

## Summary

Seer Equity’s memory architecture now separates facts, tasks, and decisions with governed access paths. This foundation supports the richer memory types introduced in the next lab.

## Workshop Plan (Generated)
- Architect memory stores separating collector facts, loyalty perks, workflow checkpoints, and task reminders.
- Map each JSON Duality region to Seer Equity operations teams for durability and security.
- Provide table schemas and notebook snippets aligning with retail data categories.
