# The Four Types of Agent Memory

## Introduction

Seer Equity Retail relies on context, facts, decisions, and reference knowledge to deliver consistent authentication experiences. This lab maps each memory type to concrete collectibles scenarios.

### Memory Types

1. **Context Memory** – Active session details like current submission and routing status.
2. **Fact Memory** – Persistent collector preferences, loyalty perks, and contact requirements.
3. **Decision Memory** – Prior authentication outcomes, rationale, and human involvement.
4. **Reference Memory** – Policy excerpts, grading standards, and routing thresholds.

### Objectives

- Populate each memory type with retail-focused examples.
- Expose helper functions to insert and retrieve memory content.
- Verify agents reference all four types when answering collector questions.

## Task 1: Context Memory

```sql
<copy>
INSERT INTO agent_memory (memory_id, agent_id, memory_type, content)
VALUES (
    sys_guid(),
    'INVENTORY_AGENT',
    'CONTEXT',
    json_object(
        'session_id' VALUE 'CALL-2026-0219-01',
        'active_submission' VALUE 'ITEM-40101',
        'current_status' VALUE 'AUTHENTICATING',
        'collector' VALUE 'Alex Martinez'
    ));

COMMIT;
</copy>
```

## Task 2: Fact Memory

```sql
<copy>
INSERT INTO agent_memory (memory_id, agent_id, memory_type, content)
VALUES (
    sys_guid(),
    'INVENTORY_AGENT',
    'FACT',
    json_object(
        'fact' VALUE 'Alex Martinez has a 20% loyalty discount and prefers email updates',
        'category' VALUE 'loyalty_preference',
        'collector' VALUE 'Alex Martinez'
    ));

COMMIT;
</copy>
```

## Task 3: Decision Memory

```sql
<copy>
INSERT INTO decision_memory (decision_id, submission_id, collector_name, decision_summary, decided_by)
VALUES (
    sys_guid(),
    'ITEM-39990',
    'Alex Martinez',
    'Expert appraisal graded the rookie card 9.2 near mint and recommended listing at $6,800 citing POL-PLAT clause 3.',
    'AUTHENTICATION_AGENT'
);

COMMIT;
</copy>
```

## Task 4: Reference Memory

```sql
<copy>
INSERT INTO reference_knowledge (reference_id, topic, content)
VALUES (
    sys_guid(),
    'Authentication Standards',
    json_object(
        'grading_scale' VALUE 'Use 1.0–10.0 scale; items under 5.0 trigger expert review.',
        'provenance'   VALUE 'Rare items require two provenance documents before listing.',
        'loyalty_rules' VALUE 'Platinum collectors retain minimum 15% discount even when flagged for manual review.'
    )
);

COMMIT;
</copy>
```

## Task 5: Helper Function

```sql
<copy>
CREATE OR REPLACE FUNCTION get_memory_bundle(p_collector VARCHAR2) RETURN CLOB AS
    v_context   CLOB;
    v_fact      CLOB;
    v_decision  CLOB;
    v_reference CLOB;
BEGIN
    SELECT json_arrayagg(content)
      INTO v_context
      FROM agent_memory
     WHERE memory_type = 'CONTEXT'
       AND content."collector" = p_collector;

    SELECT json_arrayagg(content)
      INTO v_fact
      FROM agent_memory
     WHERE memory_type = 'FACT'
       AND content."collector" = p_collector;

    SELECT json_arrayagg(json_object(
               'submission_id' VALUE submission_id,
               'summary' VALUE decision_summary,
               'decided_by' VALUE decided_by,
               'decided_ts' VALUE TO_CHAR(decided_ts, 'YYYY-MM-DD HH24:MI:SS')
           ))
      INTO v_decision
      FROM decision_memory
     WHERE collector_name = p_collector;

    SELECT json_arrayagg(content)
      INTO v_reference
      FROM reference_knowledge
     WHERE topic = 'Authentication Standards';

    RETURN json_object(
        'context' VALUE NVL(v_context, json_array()),
        'facts' VALUE NVL(v_fact, json_array()),
        'decisions' VALUE NVL(v_decision, json_array()),
        'references' VALUE NVL(v_reference, json_array())
    );
END;
/
</copy>
```

## Task 6: Agent Usage

```sql
<copy>
SELECT ai_response
  FROM TABLE(DBMS_CLOUD_AI.ASK_AGENT(
        agent_name => 'AUTHENTICATION_AGENT',
        prompt     => 'Gather all memories about Alex Martinez, including context, facts, decisions, and policy references.' ));
</copy>
```

The response should mention:
- Active submission and status (context)
- Loyalty discount and communication preference (fact)
- Past expert appraisal decision (decision)
- Relevant policy clauses from reference knowledge (reference)

## Summary

Understanding memory categories ensures future labs can enrich embeddings, precedence search, and governance controls without ambiguity.

## Workshop Plan (Generated)
- Illustrate episodic, semantic, procedural, and reflexive memories using Seer Equity retail events.
- Connect each memory type to corresponding tables (`DECISION_MEMORY`, `REFERENCE_KNOWLEDGE`) and lab artifacts.
- Include scenarios where agents blend memory types to explain valuations and routing choices.
