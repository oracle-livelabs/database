# Why Agents Need Memory

## Introduction

Without durable memory, Seer Equity Retail repeats the same questions with every collector. This lab demonstrates the forgetting problem and shows how to persist facts, preferences, and loyalty perks so `INVENTORY_AGENT` and `AUTHENTICATION_AGENT` never lose context.

### Scenario

Alex Martinez expects the system to remember a 20 percent loyalty discount and email-only updates. Today, specialists capture the notes in spreadsheets. Agents forget between calls, leading to frustration and escalations.

### Objectives

- Experience the forgetting problem with a fresh `INVENTORY_AGENT` session.
- Insert loyalty facts and contact preferences into `AGENT_MEMORY`.
- Retrieve and validate memory entries through SQL and agent prompts.
- Enforce guardrails so only authorized tools write or read specific memory categories.

## Task 1: Demonstrate Forgetting

```sql
<copy>
EXEC DBMS_CLOUD_AI_AGENT.SET_TEAM('INVENTORY_SUPPORT_TEAM');
SELECT AI AGENT 'Remember that Alex Martinez has a 20 percent loyalty discount and prefers email updates.';

-- Clear session context (simulated)
EXEC DBMS_SESSION.RESET_PACKAGE;

SELECT AI AGENT 'What do you know about Alex Martinez loyalty perks?';
</copy>
```

Observe the agent has no memory.

## Task 2: Seed Memory Facts

```sql
<copy>
INSERT INTO agent_memory (memory_id, agent_id, memory_type, content)
VALUES (
    sys_guid(),
    'INVENTORY_AGENT',
    'FACT',
    json_object(
        'fact'      VALUE 'Alex Martinez has a 20% loyalty discount and email-only communication requirement',
        'category'  VALUE 'loyalty_preference',
        'about'     VALUE 'Alex Martinez',
        'effective' VALUE TO_CHAR(SYSDATE, 'YYYY-MM-DD')
    ));

COMMIT;
</copy>
```

## Task 3: Register Memory Tools

```sql
<copy>
BEGIN
    DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
        tool_name   => 'MEMORY_LOOKUP_TOOL',
        attributes  => '{"tool_type":"SQL","tool_params":{"profile_name":"inventory_profile"}}',
        description => 'Retrieve loyalty and contact preferences from AGENT_MEMORY.'
    );
END;
/
```

## Task 4: Update Agent Instructions

```sql
<copy>
BEGIN
    DBMS_CLOUD_AI_AGENT.UPDATE_AGENT(
        agent_name => 'INVENTORY_AGENT',
        attributes => json_object(
            'role' VALUE 'You are a Seer Equity inventory specialist. Always consult memory before answering.',
            'instructions' VALUE 'Use MEMORY_LOOKUP_TOOL when collectors are mentioned. Cite loyalty perks, communication preferences, and effective dates.'
        )
    );
END;
/

BEGIN
    DBMS_CLOUD_AI_AGENT.UPDATE_TASK(
        task_name  => 'INVENTORY_LOOKUP_TASK',
        attributes => json_object(
            'prompt' VALUE 'Answer collector questions about submission status and loyalty perks.
Request: {query}',
            'tools'  VALUE json_array('ITEM_LOOKUP_TOOL', 'MEMORY_LOOKUP_TOOL')
        )
    );
END;
/
</copy>
```

## Task 5: Retrieve Memory

```sql
<copy>
SELECT ai_response
  FROM TABLE(DBMS_CLOUD_AI.ASK_AGENT(
        agent_name => 'INVENTORY_AGENT',
        prompt     => 'Summarize loyalty perks and communication preferences for Alex Martinez.' ));
</copy>
```

The agent should reference the loyalty discount and email preference.

## Task 6: Guard Memory Writes

Only governance-approved tools can modify memory.

```sql
<copy>
GRANT INSERT, UPDATE ON agent_memory TO authentication_agent_user;
REVOKE DELETE ON agent_memory FROM authentication_agent_user;
REVOKE INSERT, UPDATE, DELETE ON agent_memory FROM inventory_agent_user;
</copy>
```

Explain to learners how inventory agents request updates from governance teams instead of writing directly.

## Task 7: Audit Memory Usage

```sql
<copy>
SELECT tool_name, TO_CHAR(start_date, 'YYYY-MM-DD HH24:MI:SS') AS executed_at
  FROM user_ai_agent_tool_history
 WHERE tool_name = 'MEMORY_LOOKUP_TOOL'
 ORDER BY start_date DESC
 FETCH FIRST 5 ROWS;
</copy>
```

## Summary

Durable memory eliminates repeat questioning and ensures agents act on loyalty commitments consistently. Subsequent labs extend these patterns to procedural, decision, and reference memories.

## Workshop Plan (Generated)
- Center story on Alex Martinez’s loyalty discount and communication preferences stored in `AGENT_MEMORY`.
- Provide exercises that detect memory gaps, add facts, and verify retrieval across sessions.
- Include governance reminders ensuring memory updates respect privacy and audit constraints.
