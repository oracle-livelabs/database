# How an AI Database Builds Competence

## Introduction

In this lab, you'll build the learning loop that turns agents from first-day interns into seasoned contributors.

As covered in Post 9, agents don't improve automatically just by running more tasks. Without recording outcomes and retrieving relevant experience, agents repeat the same mistakes and rediscover the same edge cases. The learning loop changes this: **action → result → memory → improvement**.

The technical foundation for this loop is **semantic search**—the ability to find relevant past experiences by meaning, not just keywords. When an agent faces "customer angry about late delivery," it should find past experiences about "shipping delays" even though the words are different. That's what embedding models and vector search provide.

In this lab, you'll load an ONNX embedding model, add vector columns for semantic embeddings, and build the retrieval system that makes outcome-based learning possible.

Estimated Time: 15 minutes

### Objectives

* Load an ONNX embedding model into the database
* Add VECTOR columns for semantic embeddings
* Create semantic search that finds by meaning
* Build the learning loop: action → result → memory → improvement
* See how agents get better over time

### Prerequisites

This lab assumes you have:

* Completed Labs 7-8 or have memory tables
* An AI profile named `genai` already configured
* Oracle Database 26ai with Select AI Agent
* Basic knowledge of SQL

## Task 1: Load the ONNX Embedding Model

Embedding models convert text into numerical vectors that capture meaning. Similar meanings produce similar vectors, even with different words.

1. Download the model.

    ```sql
    <copy>
    BEGIN
        DBMS_CLOUD.GET_OBJECT(
            credential_name => NULL,
            directory_name  => 'DATA_PUMP_DIR',
            object_uri      => 'https://adwc4pm.objectstorage.us-ashburn-1.oci.customer-oci.com/' ||
                               'p/eLddQappgBJ7jNi6Guz9m9LOtYe2u8LWY19GfgU8flFK4N9YgP4kTlrE9Px3pE12/' ||
                               'n/adwc4pm/b/OML-Resources/o/all_MiniLM_L12_v2.onnx'
        );
    END;
    /
    </copy>
    ```

2. Load it into the database.

    ```sql
    <copy>
    BEGIN
        DBMS_VECTOR.LOAD_ONNX_MODEL(
            directory  => 'DATA_PUMP_DIR',
            file_name  => 'all_MiniLM_L12_v2.onnx',
            model_name => 'ALL_MINILM_L12_V2'
        );
    END;
    /
    </copy>
    ```

3. Verify the model is loaded.

    ```sql
    <copy>
    SELECT model_name, algorithm, mining_function 
    FROM user_mining_models 
    WHERE model_name = 'ALL_MINILM_L12_V2';
    </copy>
    ```

## Task 2: Add VECTOR Column to Memory

1. Add the embedding column.

    ```sql
    <copy>
    ALTER TABLE agent_memory ADD (
        embedding VECTOR(384)
    );
    </copy>
    ```

2. Create a vector index for fast similarity search.

    ```sql
    <copy>
    CREATE VECTOR INDEX idx_memory_vector ON agent_memory(embedding)
    ORGANIZATION NEIGHBOR PARTITIONS
    DISTANCE COSINE
    WITH TARGET ACCURACY 95;
    </copy>
    ```

## Task 3: Create the Learning Loop Functions

The learning loop: action → result → observe → interpret → store → retrieve → better decision.

1. Create a function to store experiences with embeddings.

    ```sql
    <copy>
    CREATE OR REPLACE FUNCTION store_experience(
        p_situation  VARCHAR2,
        p_action     VARCHAR2,
        p_outcome    VARCHAR2,
        p_success    VARCHAR2 DEFAULT 'true'
    ) RETURN VARCHAR2 AS
        PRAGMA AUTONOMOUS_TRANSACTION;
        v_search_text VARCHAR2(1000);
    BEGIN
        v_search_text := p_situation || ' ' || p_action || ' ' || p_outcome;
        
        INSERT INTO agent_memory (memory_type, content, embedding)
        VALUES (
            'EPISODIC',
            JSON_OBJECT(
                'situation'  VALUE p_situation,
                'action'     VALUE p_action,
                'outcome'    VALUE p_outcome,
                'success'    VALUE (CASE WHEN UPPER(p_success) = 'TRUE' THEN true ELSE false END),
                'recorded'   VALUE TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS')
            ),
            VECTOR_EMBEDDING(ALL_MINILM_L12_V2 USING v_search_text AS DATA)
        );
        COMMIT;
        
        RETURN 'Experience stored with semantic embedding';
    END;
    /
    </copy>
    ```

2. Create semantic search for similar experiences.

    ```sql
    <copy>
    CREATE OR REPLACE FUNCTION find_relevant_experience(
        p_situation VARCHAR2,
        p_limit     NUMBER DEFAULT 3
    ) RETURN CLOB AS
        v_result CLOB := '';
        v_count NUMBER := 0;
    BEGIN
        FOR rec IN (
            SELECT 
                m.content.situation.string() as situation,
                m.content.action.string() as action,
                m.content.outcome.string() as outcome,
                m.content.success.boolean() as success,
                ROUND(1 - VECTOR_DISTANCE(
                    embedding,
                    VECTOR_EMBEDDING(ALL_MINILM_L12_V2 USING p_situation AS DATA),
                    COSINE
                ), 3) as relevance
            FROM agent_memory m
            WHERE memory_type = 'EPISODIC'
            AND embedding IS NOT NULL
            ORDER BY VECTOR_DISTANCE(
                embedding,
                VECTOR_EMBEDDING(ALL_MINILM_L12_V2 USING p_situation AS DATA),
                COSINE
            )
            FETCH FIRST p_limit ROWS ONLY
        ) LOOP
            v_result := v_result || 
                'Situation: ' || rec.situation || CHR(10) ||
                'Action taken: ' || rec.action || CHR(10) ||
                'Outcome: ' || rec.outcome || 
                ' (Success: ' || CASE WHEN rec.success THEN 'Yes' ELSE 'No' END || ')' || CHR(10) ||
                'Relevance: ' || (rec.relevance * 100) || '%' || CHR(10) || CHR(10);
            v_count := v_count + 1;
        END LOOP;
        
        IF v_count = 0 THEN
            RETURN 'No relevant experiences found. This appears to be a new situation.';
        END IF;
        
        RETURN 'Found ' || v_count || ' relevant experiences:' || CHR(10) || CHR(10) || v_result;
    END;
    /
    </copy>
    ```

## Task 4: Seed the Learning Database

Let's add some experiences the agent can learn from.

```sql
<copy>
-- Successful resolutions
SELECT store_experience(
    'Premium customer complained about shipping delay',
    'Offered expedited shipping at no cost plus $20 credit',
    'Customer satisfied, left positive review',
    'true'
) FROM DUAL;

SELECT store_experience(
    'Customer requested price match from competitor',
    'Verified competitor price and approved 15% discount',
    'Customer placed order immediately',
    'true'
) FROM DUAL;

SELECT store_experience(
    'New customer confused about product setup',
    'Scheduled 30-minute video call for walkthrough',
    'Customer completed setup, purchased add-on products',
    'true'
) FROM DUAL;

-- A failure to learn from
SELECT store_experience(
    'Customer upset about billing error',
    'Explained company policy without offering resolution',
    'Customer cancelled account and posted negative review',
    'false'
) FROM DUAL;

SELECT store_experience(
    'Customer upset about billing error',
    'Immediately corrected the error and applied 10% credit',
    'Customer satisfied and upgraded their plan',
    'true'
) FROM DUAL;
</copy>
```

## Task 5: See Semantic Search in Action

Now test finding relevant experience by meaning, not keywords.

1. Search for a shipping issue (different words, same meaning).

    ```sql
    <copy>
    SELECT find_relevant_experience('customer angry about late delivery') as experience FROM DUAL;
    </copy>
    ```

    **Observe:** Finds "shipping delay" experience even though we said "late delivery."

2. Search for a pricing situation.

    ```sql
    <copy>
    SELECT find_relevant_experience('customer wants us to match Amazon price') as experience FROM DUAL;
    </copy>
    ```

    **Observe:** Finds the price match experience.

3. Search for a billing problem.

    ```sql
    <copy>
    SELECT find_relevant_experience('customer has billing complaint') as experience FROM DUAL;
    </copy>
    ```

    **Observe:** Finds BOTH billing experiences—one that failed and one that succeeded. The agent can learn from both.

## Task 6: See the Learning Loop in Action

Let's trace a complete learning loop.

1. **New situation arrives.**

    ```sql
    <copy>
    -- Agent receives: "Customer TechCorp is upset about incorrect invoice"
    SELECT find_relevant_experience('Customer upset about incorrect invoice') as past_experience FROM DUAL;
    </copy>
    ```

2. **Agent sees what worked before** (billing error → immediate correction + credit → success).

3. **Agent takes informed action** (applies the successful pattern).

4. **Outcome is recorded.**

    ```sql
    <copy>
    SELECT store_experience(
        'Customer TechCorp upset about incorrect invoice',
        'Immediately corrected invoice and applied 10% credit as goodwill',
        'Customer thanked us and confirmed continued partnership',
        'true'
    ) FROM DUAL;
    </copy>
    ```

5. **Next time, even more experience to draw from.**

    ```sql
    <copy>
    SELECT find_relevant_experience('invoice problem') as growing_experience FROM DUAL;
    </copy>
    ```

## Task 7: View the Competence Building

```sql
<copy>
SELECT 
    m.content.situation.string() as situation,
    m.content.success.boolean() as success,
    created_at
FROM agent_memory m
WHERE memory_type = 'EPISODIC'
ORDER BY created_at DESC;
</copy>
```

Each experience adds to the agent's knowledge. Over time:
- More situations covered
- Both successes and failures to learn from
- Better decisions through pattern matching

## Summary

In this lab, you built the learning loop:

* Loaded an ONNX embedding model into the database
* Added VECTOR column for semantic embeddings
* Created semantic search that finds by meaning
* Stored experiences that teach the agent
* Saw how agents retrieve relevant experience to decide

**Key takeaway:** This is how agents improve—not magically, but systematically. Action → result → memory → improvement. The AI database powers it all.

## Learn More

* [Blog Post: How an AI Database Builds Competence](../blogs/09-ai-database-competence.md)
* [AI Vector Search Guide](https://docs.oracle.com/en/database/oracle/oracle-database/26/vecse/)

## Acknowledgements

* **Author** - David Start
* **Last Updated By/Date** - David Start, December 2025
