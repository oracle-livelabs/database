# How an AI Database Builds Competence

## Introduction

Seer Equity Retail cannot rely on keyword searches to recall precedent decisions. This lab builds the learning loop that ingests new authentication outcomes, embeds them as vectors, and retrieves similar cases to inform the next decision.

### Scenario

Jennifer Lee receives a high-value sneaker submission with unusual provenance notes. She wants to know how similar cases were handled, including pricing and human reviewers. Vector search surfaces the best matches even when the language differs.

### Objectives

- Load an ONNX embedding model into Oracle Database 26ai for retail precedent text.
- Extend `DECISION_MEMORY` with vector columns and metadata.
- Implement semantic search that recommends precedent cases based on meaning.
- Close the loop by writing new outcomes back to memory for future reuse.

## Task 1: Install the Embedding Model

```sql
<copy>
BEGIN
    DBMS_VECTOR.LOAD_MODEL(
        model_name => 'ai4u_retail_text_embedding',
        source_uri => 'https://objectstorage.us-phoenix-1.oraclecloud.com/.../all-MiniLM-L6-v2.onnx'
    );
END;
/
</copy>
```

Use the notebook’s helper script to stage the ONNX file in Object Storage if required.

## Task 2: Extend Decision Memory

```sql
<copy>
ALTER TABLE decision_memory ADD (
    decision_text   CLOB,
    embedding       VECTOR(384)
);
</copy>
```

## Task 3: Embed Existing Decisions

```sql
<copy>
UPDATE decision_memory dm
   SET dm.decision_text = dm.decision_summary,
       dm.embedding = DBMS_VECTOR.EMBED_TEXT(
           model_name => 'ai4u_retail_text_embedding',
           text       => dm.decision_summary
       );
COMMIT;
</copy>
```

## Task 4: Implement Semantic Search Function

```sql
<copy>
CREATE OR REPLACE FUNCTION find_similar_decisions(
    p_query_text VARCHAR2,
    p_top_n      PLS_INTEGER := 5
) RETURN SYS_REFCURSOR AS
    v_cursor SYS_REFCURSOR;
BEGIN
    OPEN v_cursor FOR
        SELECT submission_id,
               collector_name,
               decision_summary,
               decided_by,
               decided_ts,
               DBMS_VECTOR.COSINE_DISTANCE(
                   embedding,
                   DBMS_VECTOR.EMBED_TEXT('ai4u_retail_text_embedding', p_query_text)
               ) AS similarity
          FROM decision_memory
         ORDER BY similarity ASC
         FETCH FIRST p_top_n ROWS ONLY;
    RETURN v_cursor;
END;
/
</copy>
```

## Task 5: Create a Tool for Precedent Retrieval

```sql
<copy>
BEGIN
    DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
        tool_name   => 'PRECEDENT_SEARCH_TOOL',
        attributes  => '{"tool_type":"SQL","tool_params":{"profile_name":"authentication_profile"}}',
        description => 'Retrieve similar authentication decisions using semantic search.'
    );
END;
/
</copy>
```

The tool implementation references `TABLE(find_similar_decisions(:query_text, :top_n))` in the accompanying notebook script.

## Task 6: Update Learning Loop Agent Instructions

```sql
<copy>
BEGIN
    DBMS_CLOUD_AI_AGENT.UPDATE_AGENT(
        agent_name => 'AUTHENTICATION_AGENT',
        attributes => json_object(
            'instructions' VALUE 'Before finalizing a recommendation, call PRECEDENT_SEARCH_TOOL to retrieve similar cases and cite at least one.'
        )
    );
END;
/

BEGIN
    DBMS_CLOUD_AI_AGENT.UPDATE_TASK(
        task_name  => 'AUTHENTICATION_TASK',
        attributes => json_object(
            'tools' VALUE json_array('POLICY_LOOKUP_TOOL', 'REFERENCE_LOOKUP_TOOL', 'MEMORY_LOOKUP_TOOL', 'PRECEDENT_SEARCH_TOOL')
        )
    );
END;
/
</copy>
```

## Task 7: Run the Learning Loop

```sql
<copy>
SELECT ai_response
  FROM TABLE(DBMS_CLOUD_AI.ASK_AGENT(
        agent_name => 'AUTHENTICATION_AGENT',
        prompt     => 'Recommend a route for a $6,800 rookie card with pristine condition and unusual provenance, citing similar past cases.' ));
</copy>
```

Verify the response includes:
- Policy references (POL-PLAT/POL-GOLD as applicable)
- A cited precedent submission ID and summary
- Recommended tier (Expert Appraisal expected)

## Task 8: Persist New Decisions

```sql
<copy>
INSERT INTO decision_memory (
    decision_id,
    submission_id,
    collector_name,
    decision_summary,
    decision_text,
    embedding,
    decided_by
) VALUES (
    sys_guid(),
    'ITEM-41200',
    'Alex Martinez',
    'Expert appraisal confirmed provenance documents and listed at $6,900 under POL-PLAT clause 3.',
    'Expert appraisal confirmed provenance documents and listed at $6,900 under POL-PLAT clause 3.',
    DBMS_VECTOR.EMBED_TEXT('ai4u_retail_text_embedding', 'Expert appraisal confirmed provenance documents and listed at $6,900 under POL-PLAT clause 3.'),
    'AUTHENTICATION_AGENT'
);

COMMIT;
</copy>
```

## Summary

Semantic precedence transforms Seer Equity agents from reactive scripts into learning systems. Every new decision strengthens future recommendations, emitting evidence collectors and governance teams can trust.

## Workshop Plan (Generated)
- Build precedent vectors from past return decisions to recommend actions for similar submissions.
- Showcase competence tracking dashboards that flag SLA breaches, fraud risks, and calibration needs.
- Tie learning loop outputs back to Priya Desai’s KPIs for Seer Equity Retail.
