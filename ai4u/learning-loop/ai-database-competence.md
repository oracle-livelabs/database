# How an AI Database Builds Competence

## Introduction

In this lab, you'll build the learning loop that turns agents from first-day interns into seasoned contributors.

### The Business Problem

Seer Equity approved a similar loan three months ago. Same amount, same credit profile, same industry. The loan officer who handled it negotiated special terms based on the client's cash flow timing. But today's loan officer has no idea that case exists.

> *"We keep solving the same problems from scratch. Someone figured out how to handle seasonal cash flow for agricultural clients last quarter, but that knowledge just... disappeared."*
>
> Jennifer, Senior Loan Officer

The problem isn't intelligence. It's retrieval. When a new situation arises, the agent can't find similar past situations to learn from. And when a similar keyword search fails ("seasonal" vs "cyclical" vs "variable cash flow"), the connection is lost.

### What You'll Learn

In this lab, you'll build **semantic search**, the ability to find relevant past experiences by *meaning*, not just keywords:

1. **Load an ONNX embedding model** directly into the database
2. **Add vector columns** to store semantic meaning alongside facts
3. **Build semantic search** that finds "seasonal cash flow" when you search for "cyclical revenue"
4. **Create the learning loop**: action → result → memory → improvement

This is what lets agents learn from experience. Not just store it, but retrieve it when it's relevant.

**What you'll build:** A semantic memory system that finds similar past decisions and improves over time.

Estimated Time: 15 minutes

### Objectives

* Load an ONNX embedding model into the database
* Add VECTOR columns for semantic embeddings
* Create semantic search that finds by meaning
* Build the learning loop: action → result → memory → improvement
* See how agents get better over time

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
    https://github.com/davidastart/database/blob/main/ai4u/learning-loop/lab9-learning-loop.json
    </copy>
    ```

5. Click **Import**.

You should now be on the screen with the notebook imported. This workshop will have all of the screenshots and detailed information however the notebook will have the commands and basic instructions for completing the lab.

## Task 2: Create the Memory Table

First, we'll create a memory table to store agent experiences. The key difference from earlier labs is the VECTOR column—this stores the mathematical representation of what each memory means.

1. Create the agent memory table with a vector column for semantic embeddings.

    The `embedding` column with type `VECTOR(384)` stores 384 numbers that capture the meaning of each memory. Two memories with similar meanings will have similar vectors, even if they use different words.

    ```sql
    <copy>
    CREATE TABLE agent_memory (
        memory_id      RAW(16) DEFAULT SYS_GUID() PRIMARY KEY,
        memory_type    VARCHAR2(20) NOT NULL,
        session_id     VARCHAR2(100),
        entity_id      VARCHAR2(100),
        content        JSON NOT NULL,
        embedding      VECTOR(384),
        created_at     TIMESTAMP DEFAULT SYSTIMESTAMP,
        expires_at     TIMESTAMP
    );

    CREATE INDEX idx_memory_type ON agent_memory(memory_type);
    </copy>
    ```

## Task 3: Load the ONNX Embedding Model

Embedding models convert text into numerical vectors that capture meaning. Instead of calling an external API every time we need an embedding, we load the model directly into the database. This means embeddings happen locally, instantly, and without network latency.

1. Download the model.

    We're using a pre-trained model called "all_MiniLM_L12_v2" that's good at understanding the meaning of sentences. This downloads the model file to the database server.

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

    This loads the ONNX model into the database so we can use it in SQL. Once loaded, we can call `VECTOR_EMBEDDING()` in any query to convert text to vectors.

    ```sql
    <copy>
    -- Drop model if it already exists
    EXEC DBMS_VECTOR.DROP_ONNX_MODEL(model_name => 'ALL_MINILM_L12_V2', force => true);

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

## Task 4: Create a Vector Index

A vector index makes similarity searches fast. Without an index, the database would have to compare your query against every single memory. With an index, it can quickly find the most similar ones.

1. Create a vector index for fast similarity search.

    The index uses "cosine distance" which measures how similar two vectors are based on their direction, not their size. A 95% accuracy target means the index is optimized for speed while staying very accurate.

    ```sql
    <copy>
    CREATE VECTOR INDEX idx_memory_vector ON agent_memory(embedding)
    ORGANIZATION NEIGHBOR PARTITIONS
    DISTANCE COSINE
    WITH TARGET ACCURACY 95;
    </copy>
    ```

## Task 5: Create the Learning Loop Functions

The learning loop: action → result → observe → interpret → store → retrieve → better decision. These two functions power the loop—one to store new experiences and one to find relevant past experiences.

1. Create a function to store experiences with embeddings.

    When we store an experience, we combine the situation, action, and outcome into text, then convert that text to a vector. This vector captures the meaning of the whole experience so we can find it later even if we use different words.

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

    This function takes a new situation and finds the most relevant past experiences. It converts your query to a vector, then finds memories with the most similar vectors. The "relevance" score shows how close the match is—higher percentages mean more relevant experiences.

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

## Task 6: Seed the Learning Database

Let's add some experiences the agent can learn from. We're deliberately adding both successes and failures—the agent needs to learn from both. Notice we're using different words for similar situations ("shipping delay" vs "late delivery") to test semantic search later.

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

## Task 7: See Semantic Search in Action

Now test finding relevant experience by meaning, not keywords. This is where the magic happens—we'll search using different words than what we stored, and the system will still find the right matches.

1. Search for a shipping issue (different words, same meaning).

    ```sql
    <copy>
    SET LONG 5000
    SET LINESIZE 200
    SELECT find_relevant_experience('customer angry about late delivery') as experience FROM DUAL;
    </copy>
    ```

**Observe:** Finds "shipping delay" experience even though we said "late delivery."

2. Search for a pricing situation.

    ```sql
    <copy>
    SET LONG 5000
    SET LINESIZE 200
    SELECT find_relevant_experience('customer wants us to match Amazon price') as experience FROM DUAL;
    </copy>
    ```

**Observe:** Finds the price match experience.

3. Search for a billing problem.

    ```sql
    <copy>
    SET LONG 5000
    SET LINESIZE 200
    SELECT find_relevant_experience('customer has billing complaint') as experience FROM DUAL;
    </copy>
    ```

**Observe:** Finds BOTH billing experiences: one that failed and one that succeeded. The agent can learn from both.

## Task 8: See the Learning Loop in Action

Let's trace a complete learning loop. This is how agents get better over time: they encounter a situation, look up what worked before, take informed action, and then record the outcome so future situations benefit from the experience.

1. **New situation arrives.**

    ```sql
    <copy>
    SET LONG 5000
    SET LINESIZE 200
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
    SET LONG 5000
    SET LINESIZE 200
    SELECT find_relevant_experience('invoice problem') as growing_experience FROM DUAL;
    </copy>
    ```

## Task 9: View the Competence Building

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

## Summary

In this lab, you built the learning loop:

* Loaded an ONNX embedding model into the database
* Added VECTOR column for semantic embeddings
* Created semantic search that finds by meaning
* Stored experiences that teach the agent
* Saw how agents retrieve relevant experience to decide

**Key takeaway:** This is how agents improve. Not magically, but systematically. Action, result, memory, improvement. The AI database powers it all.

## Cleanup (Optional)

```sql
<copy>
DROP TABLE agent_memory PURGE;
DROP FUNCTION store_experience;
DROP FUNCTION find_relevant_experience;

-- Drop the ONNX model
EXEC DBMS_VECTOR.DROP_ONNX_MODEL(model_name => 'ALL_MINILM_L12_V2', force => true);
</copy>
```

## Learn More

* [AI Vector Search Guide](https://docs.oracle.com/en/database/oracle/oracle-database/26/vecse/)

## Acknowledgements

* **Author** - David Start
* **Last Updated By/Date** - David Start, January 2026
