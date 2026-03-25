# The Learning Loop at Seer Equity

## Introduction

In this lab, you'll build the learning loop that turns agents from first-day interns into seasoned loan officers.

### The Business Problem

Seer Equity approved a similar loan three months ago. Same amount, same credit profile, same industry. The loan officer who handled it negotiated special terms based on the client's cash flow timing. But today's loan officer has no idea that case exists.

> *"We keep solving the same problems from scratch. Someone figured out how to handle seasonal cash flow for agricultural clients last quarter, but that knowledge just... disappeared."*
>
> Jennifer, Senior Loan Officer

The problem isn't intelligence. It's retrieval. When a new situation arises, the agent can't find similar past situations to learn from. And when keyword search fails ("seasonal" vs "cyclical" vs "variable cash flow"), the connection is lost.

### What You'll Learn

In this lab, you'll build **semantic search**, the ability to find relevant past loan decisions by *meaning*, not just keywords:

1. **Load an ONNX embedding model** directly into the database
2. **Add vector columns** to store semantic meaning alongside facts
3. **Build semantic search** that finds "seasonal cash flow" when you search for "cyclical revenue"
4. **Create the learning loop**: decision → outcome → memory → better future decisions

This is what lets agents learn from experience. Not just store it, but retrieve it when it's relevant.

**What you'll build:** A semantic memory system that finds similar past loan decisions and improves over time.

**Estimated Time:** 20 minutes

### Objectives

* Load an ONNX embedding model into the database
* Add VECTOR columns for semantic embeddings
* Create semantic search that finds by meaning
* Build a memory-enabled agent with five tools
* See how agents get better over time

### Prerequisites

For this workshop, we provide the environment. You'll need:

* Basic knowledge of SQL and PL/SQL, or the ability to follow along with the prompts

## Task 1: Import the Lab Notebook

Before you begin, you are going to import a notebook that has all of the commands for this lab into Oracle Machine Learning. This way you don't have to copy and paste them over to run them.

1. From the Oracle Machine Learning home page, click **Notebooks**.

    ![OML home page with Notebooks highlighted](images/task1_1.png)

2. Click **Import** to expand the Import drop down.

    ![Notebooks page with Import button highlighted](images/task1_2.png)

3. Select **Git**.

    ![Import dropdown with Git option highlighted](images/task1_3.png)

4. Paste the following GitHub URL leaving the credential field blank, then click **OK**.

    ```text
    <copy>
    https://github.com/davidastart/database/blob/main/ai4u/learning-loop/lab9-learning-loop.json
    </copy>
    ```

    ![Git Clone dialog with URL field and OK button highlighted](images/task1_4.png)

    You should now be on the screen with the notebook imported. This workshop will have all of the screenshots and detailed information however the notebook will have the commands and basic instructions for completing the lab.

## Task 2: Load the ONNX Embedding Model

Embedding models convert text into numerical vectors that capture meaning. Instead of calling an external API every time we need an embedding, we load the model directly into the database. This means embeddings happen locally, instantly, and without network latency.

We're using a pre-trained model called "all_MiniLM_L12_v2" that's good at understanding the meaning of sentences.

1. Download the model.

    > This command is already in your notebook—just click the play button (▶) to run it.

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

    ![Download ONNX model - PL/SQL procedure successfully completed](images/task2_1.png)

2. Load the model into the database.

    This loads the ONNX model into the database so we can use it in SQL. Once loaded, we can call `VECTOR_EMBEDDING()` in any query to convert text to vectors.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    -- Drop model if it already exists
    BEGIN
        DBMS_VECTOR.DROP_ONNX_MODEL(model_name => 'ALL_MINILM_L12_V2', force => true);
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
    /

    -- Load the model
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

    ![Load ONNX model into database - two PL/SQL procedures successfully completed](images/task2_2.png)

3. Verify the model is loaded.

    **Watch for:** You should see `ALL_MINILM_L12_V2` listed with algorithm and mining function.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    SELECT model_name, algorithm, mining_function 
    FROM user_mining_models 
    WHERE model_name = 'ALL_MINILM_L12_V2';
    </copy>
    ```

    ![Verify model loaded - ALL_MINILM_L12_V2 with ONNX algorithm and EMBEDDING function](images/task2_3.png)

## Task 3: Create the Memory Infrastructure

Create tables that will hold Seer Equity's agent memory. The key difference from earlier labs is the VECTOR column—this stores the mathematical representation of what each memory means.

The `embedding` column with type `VECTOR(384)` stores 384 numbers that capture the meaning of each memory. Two memories with similar meanings will have similar vectors, even if they use different words.

1. Create the memory and policies tables.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    -- Main memory table with vector embeddings
    CREATE TABLE seers_memory (
        memory_id      RAW(16) DEFAULT SYS_GUID() PRIMARY KEY,
        memory_type    VARCHAR2(20) NOT NULL,
        entity_id      VARCHAR2(100),
        content        JSON NOT NULL,
        embedding      VECTOR(384),
        created_at     TIMESTAMP DEFAULT SYSTIMESTAMP,
        CONSTRAINT chk_mem_type CHECK (memory_type IN ('FACT', 'DECISION', 'CONTEXT'))
    );

    -- Loan policies table (reference knowledge)
    CREATE TABLE seers_policies (
        policy_id    RAW(16) DEFAULT SYS_GUID() PRIMARY KEY,
        policy_type  VARCHAR2(50) NOT NULL,
        policy_name  VARCHAR2(200) NOT NULL,
        content      JSON NOT NULL,
        is_active    NUMBER(1) DEFAULT 1
    );

    -- Indexes
    CREATE INDEX idx_seers_mem_type ON seers_memory(memory_type);
    CREATE INDEX idx_seers_mem_entity ON seers_memory(entity_id);
    CREATE INDEX idx_seers_policy_type ON seers_policies(policy_type);
    </copy>
    ```

    ![Create seers_memory and seers_policies tables - both tables created successfully](images/task3_1.png)

2. Create a vector index for fast similarity search.

    A vector index makes similarity searches fast. Without an index, the database would have to compare your query against every single memory. With an index, it can quickly find the most similar ones.

    The index uses "cosine distance" which measures how similar two vectors are based on their direction, not their size.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    CREATE VECTOR INDEX idx_memory_vector ON seers_memory(embedding)
    ORGANIZATION NEIGHBOR PARTITIONS
    DISTANCE COSINE
    WITH TARGET ACCURACY 95;
    </copy>
    ```

    ![Create vector index - Vector INDEX created](images/task3_2.png)

## Task 4: Populate Seer Equity Loan Policies

Add Seer Equity's loan policies. These are the corporate rules the agent must follow when processing loan applications.

> This command is already in your notebook—just click the play button (▶) to run it.

```sql
<copy>
INSERT INTO seers_policies (policy_type, policy_name, content) VALUES (
    'rate_policy',
    'Personal Loan - Preferred Rate',
    '{"description": "Preferred customers with credit score 750+ qualify for personal loans at 7.9% APR. Maximum loan amount $100,000. No origination fee. Same-day approval for loans under $50,000.",
      "credit_min": 750, "apr": 7.9, "max_amount": 100000}'
);

INSERT INTO seers_policies (policy_type, policy_name, content) VALUES (
    'rate_policy',
    'Personal Loan - Standard Rate',
    '{"description": "Standard customers with credit score 650-749 qualify for personal loans at 12.9% APR. Maximum loan amount $50,000. 2% origination fee applies.",
      "credit_min": 650, "credit_max": 749, "apr": 12.9, "max_amount": 50000}'
);

INSERT INTO seers_policies (policy_type, policy_name, content) VALUES (
    'rate_policy',
    'Business Loan - Preferred',
    '{"description": "Established businesses (3+ years) with strong financials qualify for business loans at 8.5% APR. Maximum $500,000. Requires 2 years tax returns and business plan.",
      "business_years_min": 3, "apr": 8.5, "max_amount": 500000}'
);

INSERT INTO seers_policies (policy_type, policy_name, content) VALUES (
    'escalation_policy',
    'Risk Escalation Guidelines',
    '{"description": "Escalation rules: 1) DTI above 35% requires underwriter review, 2) Credit below 650 requires senior underwriter, 3) Loans above $250K require committee approval, 4) Any exception to policy requires manager sign-off."}'
);

INSERT INTO seers_policies (policy_type, policy_name, content) VALUES (
    'exception_policy',
    'Rate Exception Authority',
    '{"description": "Rate exceptions may be granted for: 1) Long-term clients (5+ years) - up to 15% discount, 2) Multi-product relationships - up to 10% discount, 3) Strategic accounts - case by case with VP approval. All exceptions must be documented."}'
);

COMMIT;
</copy>
```

![Insert five loan policies into seers_policies and commit](images/task4_1.png)

## Task 5: Create Memory Functions with Semantic Search

Create the core memory functions. The key difference from earlier labs: these functions use vector embeddings to store semantic meaning, and `find_similar_decisions` uses vector similarity search to find relevant past decisions by meaning, not just keywords.

1. Create functions to store and recall client facts.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    -- Remember a fact about a client (with semantic embedding)
    CREATE OR REPLACE FUNCTION remember_client_fact(
        p_client      VARCHAR2,
        p_fact        VARCHAR2,
        p_category    VARCHAR2 DEFAULT 'general'
    ) RETURN VARCHAR2 AS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        INSERT INTO seers_memory (memory_type, entity_id, content, embedding)
        VALUES (
            'FACT', 
            UPPER(p_client), 
            JSON_OBJECT(
                'fact' VALUE p_fact,
                'category' VALUE p_category,
                'learned' VALUE TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS')
            ),
            VECTOR_EMBEDDING(ALL_MINILM_L12_V2 USING p_fact AS DATA)
        );
        COMMIT;
        RETURN 'Remembered about ' || p_client || ': ' || p_fact;
    END;
    /

    -- Recall everything about a client
    CREATE OR REPLACE FUNCTION recall_client_info(
        p_client VARCHAR2
    ) RETURN CLOB AS
        v_result CLOB := '';
        v_count NUMBER := 0;
    BEGIN
        FOR rec IN (
            SELECT 
                JSON_VALUE(content, '$.fact') as fact,
                JSON_VALUE(content, '$.category') as category,
                TO_CHAR(created_at, 'YYYY-MM-DD') as learned_date
            FROM seers_memory
            WHERE memory_type = 'FACT'
            AND UPPER(entity_id) = UPPER(p_client)
            ORDER BY created_at DESC
        ) LOOP
            v_result := v_result || '- ' || rec.fact || ' [' || rec.category || ', learned ' || rec.learned_date || ']' || CHR(10);
            v_count := v_count + 1;
        END LOOP;
        
        IF v_count = 0 THEN
            RETURN 'No information found about client ' || p_client || '. This may be a new client.';
        END IF;
        RETURN 'Found ' || v_count || ' facts about ' || p_client || ':' || CHR(10) || v_result;
    END;
    /
    </copy>
    ```

    ![remember_client_fact and recall_client_info functions - top half of code](images/task5_1a.png)

    ![recall_client_info function compiled - REMEMBER_CLIENT_FACT and RECALL_CLIENT_INFO compiled](images/task5_1b.png)

2. Create functions to record and find loan decisions with semantic search.

    This is where the magic happens. When we store a decision, we embed the situation description. When we search, we find decisions with similar meaning—even if the words are different.

    The `find_similar_decisions` function uses `VECTOR_DISTANCE()` and `VECTOR_EMBEDDING()` to find semantically similar past decisions.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    -- Record a loan decision (with semantic embedding)
    CREATE OR REPLACE FUNCTION record_loan_decision(
        p_client      VARCHAR2,
        p_situation   VARCHAR2,
        p_decision    VARCHAR2,
        p_outcome     VARCHAR2 DEFAULT NULL
    ) RETURN VARCHAR2 AS
        PRAGMA AUTONOMOUS_TRANSACTION;
        v_search_text VARCHAR2(2000);
    BEGIN
        v_search_text := p_situation || ' ' || p_decision || ' ' || NVL(p_outcome, '');
        
        INSERT INTO seers_memory (memory_type, entity_id, content, embedding)
        VALUES (
            'DECISION', 
            UPPER(p_client), 
            JSON_OBJECT(
                'situation' VALUE p_situation,
                'decision' VALUE p_decision,
                'outcome' VALUE NVL(p_outcome, 'Pending'),
                'recorded' VALUE TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS')
            ),
            VECTOR_EMBEDDING(ALL_MINILM_L12_V2 USING v_search_text AS DATA)
        );
        COMMIT;
        RETURN 'Decision recorded for ' || p_client || ': ' || p_decision;
    END;
    /

    -- Find similar past decisions using SEMANTIC SEARCH
    CREATE OR REPLACE FUNCTION find_similar_decisions(
        p_situation VARCHAR2,
        p_limit     NUMBER DEFAULT 3
    ) RETURN CLOB AS
        v_result CLOB := '';
        v_count NUMBER := 0;
    BEGIN
        FOR rec IN (
            SELECT 
                entity_id as client,
                JSON_VALUE(content, '$.situation') as situation,
                JSON_VALUE(content, '$.decision') as decision,
                JSON_VALUE(content, '$.outcome') as outcome,
                ROUND(1 - VECTOR_DISTANCE(
                    embedding,
                    VECTOR_EMBEDDING(ALL_MINILM_L12_V2 USING p_situation AS DATA),
                    COSINE
                ), 3) as relevance
            FROM seers_memory
            WHERE memory_type = 'DECISION'
            AND embedding IS NOT NULL
            ORDER BY VECTOR_DISTANCE(
                embedding,
                VECTOR_EMBEDDING(ALL_MINILM_L12_V2 USING p_situation AS DATA),
                COSINE
            )
            FETCH FIRST p_limit ROWS ONLY
        ) LOOP
            v_result := v_result || 
                'Client: ' || rec.client || CHR(10) ||
                'Situation: ' || rec.situation || CHR(10) ||
                'Decision: ' || rec.decision || CHR(10) ||
                'Outcome: ' || rec.outcome || CHR(10) ||
                'Relevance: ' || (rec.relevance * 100) || '%' || CHR(10) || '---' || CHR(10);
            v_count := v_count + 1;
        END LOOP;
        
        IF v_count = 0 THEN
            RETURN 'No similar past decisions found. This appears to be a new type of situation.';
        END IF;
        RETURN 'Found ' || v_count || ' similar past decisions:' || CHR(10) || v_result;
    END;
    /
    </copy>
    ```

    ![record_loan_decision function - top half of code](images/task5_2a.png)

    ![find_similar_decisions function compiled - RECORD_LOAN_DECISION and FIND_SIMILAR_DECISIONS compiled](images/task5_2b.png)

3. Create a function to look up loan policies.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    -- Look up loan policies
    CREATE OR REPLACE FUNCTION lookup_policy(
        p_policy_type VARCHAR2 DEFAULT NULL,
        p_search      VARCHAR2 DEFAULT NULL
    ) RETURN CLOB AS
        v_result CLOB := '';
        v_count NUMBER := 0;
    BEGIN
        FOR rec IN (
            SELECT 
                policy_type,
                policy_name,
                JSON_VALUE(content, '$.description') as description
            FROM seers_policies
            WHERE is_active = 1
            AND (p_policy_type IS NULL OR UPPER(policy_type) LIKE '%' || UPPER(p_policy_type) || '%')
            AND (p_search IS NULL OR UPPER(policy_name) LIKE '%' || UPPER(p_search) || '%' 
                 OR UPPER(JSON_VALUE(content, '$.description')) LIKE '%' || UPPER(p_search) || '%')
            ORDER BY policy_type, policy_name
        ) LOOP
            v_result := v_result || '[' || rec.policy_type || '] ' || rec.policy_name || ':' || CHR(10) ||
                       rec.description || CHR(10) || CHR(10);
            v_count := v_count + 1;
        END LOOP;
        
        IF v_count = 0 THEN
            RETURN 'No matching policies found.';
        END IF;
        RETURN 'Found ' || v_count || ' policies:' || CHR(10) || v_result;
    END;
    /
    </copy>
    ```

    ![lookup_policy function - LOOKUP_POLICY compiled](images/task5_3.png)

## Task 6: Register the Memory Tools

Register all five functions as agent tools. The instructions tell the agent when to use each tool. Note that `FIND_DECISIONS_TOOL` now uses semantic search.

> This command is already in your notebook—just click the play button (▶) to run it.

```sql
<copy>
BEGIN
    DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
        tool_name   => 'REMEMBER_CLIENT_TOOL',
        attributes  => '{"instruction": "Store a fact about a Seer Equity client for future reference. Parameters: P_CLIENT (client name), P_FACT (information to remember), P_CATEGORY (optional: contact_preference, rate_exception, relationship, requirement, behavior). Use only when the user provides NEW client facts. Do not store the same fact twice in one request. Never call this tool based on prior tool output; only from the original user request. For a multi-fact request, store each distinct fact once, then stop calling tools and respond.",
                        "function": "remember_client_fact"}',
        description => 'Stores facts about clients in long-term memory with semantic embeddings'
    );
END;
/

BEGIN
    DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
        tool_name   => 'RECALL_CLIENT_TOOL',
        attributes  => '{"instruction": "Retrieve everything known about a Seer Equity client. Parameter: P_CLIENT (client name to search). Use this FIRST when asked about any client to check what you already know.",
                        "function": "recall_client_info"}',
        description => 'Retrieves all stored facts about a client'
    );
END;
/

BEGIN
    DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
        tool_name   => 'RECORD_DECISION_TOOL',
        attributes  => '{"instruction": "Record a loan decision for audit trail. Parameters: P_CLIENT (client name), P_SITUATION (what was the request/situation), P_DECISION (what was decided), P_OUTCOME (optional: what happened as a result). Use after making or discussing significant loan decisions.",
                        "function": "record_loan_decision"}',
        description => 'Records loan decisions for audit and learning with semantic embeddings'
    );
END;
/

BEGIN
    DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
        tool_name   => 'FIND_DECISIONS_TOOL',
        attributes  => '{"instruction": "Search for similar past loan decisions using semantic search. Parameter: P_SITUATION (describe the situation - the search finds similar meanings, not just keywords). Use when facing a decision to learn from past experience.",
                        "function": "find_similar_decisions"}',
        description => 'Finds similar past decisions using semantic vector search'
    );
END;
/

BEGIN
    DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
        tool_name   => 'POLICY_LOOKUP_TOOL',
        attributes  => '{"instruction": "Look up Seer Equity loan policies. Parameters: P_POLICY_TYPE (optional: rate_policy, escalation_policy, exception_policy), P_SEARCH (optional: search term). Use when you need to know company lending policy or rates.",
                        "function": "lookup_policy"}',
        description => 'Retrieves Seer Equity loan policies and guidelines'
    );
END;
/
</copy>
```

![Register tools - REMEMBER, RECALL, RECORD, FIND tools visible](images/task6_1a.png)

![Register tools - POLICY_LOOKUP_TOOL and five PL/SQL procedures successfully completed](images/task6_1b.png)

## Task 7: Create the Memory-Enabled Agent

Create an agent with access to all memory tools. The role instructions tell the agent to use its memory proactively and leverage semantic search for finding similar past decisions.

> This command is already in your notebook—just click the play button (▶) to run it.

```sql
<copy>
BEGIN
    DBMS_CLOUD_AI_AGENT.CREATE_AGENT(
        agent_name  => 'SEERS_MEMORY_AGENT',
        attributes  => '{"profile_name": "genai",
                        "role": "You are a loan officer assistant for Seer Equity with full memory capabilities. ALWAYS check your memory first when asked about a client (use RECALL_CLIENT_TOOL). When loan officers share client information, store it (use REMEMBER_CLIENT_TOOL). When making loan decisions, check policy (POLICY_LOOKUP_TOOL) and past decisions (FIND_DECISIONS_TOOL). Record important decisions (RECORD_DECISION_TOOL). Never guess about client information - always check your memory and tools. Never call REMEMBER_CLIENT_TOOL repeatedly for the same fact. Do not call tools from tool output text; call tools only from the user request intent. After completing required tool calls, provide a final answer and stop."}',
        description => 'Memory-enabled loan officer assistant with semantic search'
    );
END;
/

BEGIN
    DBMS_CLOUD_AI_AGENT.CREATE_TASK(
        task_name   => 'SEERS_MEMORY_TASK',
        attributes  => '{"instruction": "Process this loan officer request using your memory tools. When asked about a client, FIRST use RECALL_CLIENT_TOOL. When given client information, use REMEMBER_CLIENT_TOOL only for distinct new facts in the user request. Never use REMEMBER_CLIENT_TOOL on your own tool outputs or responses. Maximum 3 REMEMBER_CLIENT_TOOL calls per user request. When asked about policies or rates, use POLICY_LOOKUP_TOOL. For decision guidance, use FIND_DECISIONS_TOOL (it uses semantic search to find similar situations even with different wording). Record decisions with RECORD_DECISION_TOOL when a decision is made. After relevant tools run, provide the final response and stop. Do not ask clarifying questions. User request: {query}",
                        "tools": ["REMEMBER_CLIENT_TOOL", "RECALL_CLIENT_TOOL", "RECORD_DECISION_TOOL", "FIND_DECISIONS_TOOL", "POLICY_LOOKUP_TOOL"]}',
        description => 'Task with full memory capabilities and semantic search'
    );
END;
/

BEGIN
    DBMS_CLOUD_AI_AGENT.CREATE_TEAM(
        team_name   => 'SEERS_MEMORY_TEAM',
        attributes  => '{"agents": [{"name": "SEERS_MEMORY_AGENT", "task": "SEERS_MEMORY_TASK"}],
                        "process": "sequential"}',
        description => 'Memory-enabled loan processing team'
    );
END;
/
</copy>
```

![Create SEERS_MEMORY_AGENT, SEERS_MEMORY_TASK, and SEERS_MEMORY_TEAM - PL/SQL procedure successfully completed](images/task7_1.png)

## Task 8: Seed Historical Decisions for Learning

Add historical loan decisions that the agent can learn from. Notice we're using varied wording—"seasonal cash flow," "cyclical revenue," "variable income"—to test semantic search later.

Each decision is stored with a vector embedding that captures its meaning.

> This command is already in your notebook—just click the play button (▶) to run it.

```sql
<copy>
-- Decision about seasonal business cash flow
INSERT INTO seers_memory (memory_type, entity_id, content, embedding) VALUES (
    'DECISION', 'HARVEST FARMS',
    '{"situation": "Agricultural client with seasonal cash flow requested business loan with flexible payment schedule",
      "decision": "Approved loan with quarterly payments aligned to harvest cycles instead of monthly",
      "outcome": "Client paid on time, renewed for larger amount next season",
      "recorded": "2024-06-15"}',
    VECTOR_EMBEDDING(ALL_MINILM_L12_V2 USING 
        'Agricultural client with seasonal cash flow requested business loan with flexible payment schedule. Approved loan with quarterly payments aligned to harvest cycles instead of monthly. Client paid on time, renewed for larger amount next season.' AS DATA)
);

-- Decision about rate exception for long-term client
INSERT INTO seers_memory (memory_type, entity_id, content, embedding) VALUES (
    'DECISION', 'GLOBALCO',
    '{"situation": "Long-term client requested rate exception for expansion loan",
      "decision": "Approved 12% rate discount based on 7-year relationship and $2M in previous loans",
      "outcome": "Client expanded successfully, referred two new business clients",
      "recorded": "2024-08-20"}',
    VECTOR_EMBEDDING(ALL_MINILM_L12_V2 USING 
        'Long-term client requested rate exception for expansion loan. Approved 12% rate discount based on 7-year relationship and $2M in previous loans. Client expanded successfully, referred two new business clients.' AS DATA)
);

-- Decision about new client wanting exception (what NOT to do)
INSERT INTO seers_memory (memory_type, entity_id, content, embedding) VALUES (
    'DECISION', 'NEWSTART INC',
    '{"situation": "New business client requested rate exception without established relationship",
      "decision": "Denied exception request outright citing policy",
      "outcome": "Client went to competitor, later became successful business we lost",
      "recorded": "2024-04-10"}',
    VECTOR_EMBEDDING(ALL_MINILM_L12_V2 USING 
        'New business client requested rate exception without established relationship. Denied exception request outright citing policy. Client went to competitor, later became successful business we lost.' AS DATA)
);

-- Better approach for new client wanting exception
INSERT INTO seers_memory (memory_type, entity_id, content, embedding) VALUES (
    'DECISION', 'TECHSTART LLC',
    '{"situation": "New business client requested rate exception without established relationship",
      "decision": "Offered standard rate with commitment to review for exception after 12 months of on-time payments",
      "outcome": "Client accepted, became loyal customer, now qualifies for preferred rates",
      "recorded": "2024-05-22"}',
    VECTOR_EMBEDDING(ALL_MINILM_L12_V2 USING 
        'New business client requested rate exception without established relationship. Offered standard rate with commitment to review for exception after 12 months of on-time payments. Client accepted, became loyal customer, now qualifies for preferred rates.' AS DATA)
);

-- Decision about client with variable income
INSERT INTO seers_memory (memory_type, entity_id, content, embedding) VALUES (
    'DECISION', 'CONSULTING PARTNERS',
    '{"situation": "Consulting firm with cyclical revenue patterns needed loan for equipment",
      "decision": "Structured loan with variable payments tied to quarterly revenue, higher in Q4, lower in Q1",
      "outcome": "Client appreciated flexibility, maintained perfect payment record",
      "recorded": "2024-07-15"}',
    VECTOR_EMBEDDING(ALL_MINILM_L12_V2 USING 
        'Consulting firm with cyclical revenue patterns needed loan for equipment. Structured loan with variable payments tied to quarterly revenue, higher in Q4, lower in Q1. Client appreciated flexibility, maintained perfect payment record.' AS DATA)
);

COMMIT;
</copy>
```

![Seed historical decisions - first three decisions inserted (HARVEST FARMS, GLOBALCO, NEWSTART INC)](images/task8_1a.png)

![Seed historical decisions - CONSULTING PARTNERS decision inserted, COMMIT, 1 row inserted x3](images/task8_1b.png)

## Task 9: Test Semantic Search Directly

Before using the agent, let's test semantic search directly. This demonstrates the power of vector search—finding relevant results by meaning, not keywords.

1. Search for "irregular income patterns."

    Watch it find "seasonal cash flow" and "cyclical revenue" even though those exact words aren't in the query.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    SELECT DBMS_LOB.SUBSTR(find_similar_decisions('client has irregular income patterns throughout the year'), 4000, 1) AS similar_decisions FROM DUAL;
    </copy>
    ```

    **Observe:** Finds Consulting Partners ("cyclical revenue") and Harvest Farms ("seasonal cash flow") even though we said "irregular income patterns."

    ![Semantic search for irregular income - finds CONSULTING PARTNERS first](images/task9_1.png)

2. Search for "new customer asking for a discount."

    This should find both the failed approach (NewStart - denied outright) and the successful approach (TechStart - offered path to exception). The agent can learn from both successes and failures!

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    SELECT DBMS_LOB.SUBSTR(find_similar_decisions('new customer asking for a discount on their first loan'), 4000, 1) AS similar_decisions FROM DUAL;
    </copy>
    ```

    **Observe:** Finds BOTH the failed approach (NewStart) and the successful approach (TechStart).

    ![Semantic search for new customer discount - finds GLOBALCO, NEWSTART, TECHSTART](images/task9_2.png)

3. Activate the memory agent.

    Set the memory team as active. Now your `SELECT AI AGENT` commands will go to an agent with full memory and semantic search capabilities.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    EXEC DBMS_CLOUD_AI_AGENT.SET_TEAM('SEERS_MEMORY_TEAM');
    </copy>
    ```

    ![SET_TEAM SEERS_MEMORY_TEAM - PL/SQL procedure successfully completed](images/task9_3.png)

## Task 10: See the Full Learning Loop

Now use the agent to demonstrate the complete learning loop.

1. Teach the agent about a client.

    Tell the agent about Acme Industries. The agent should use `REMEMBER_CLIENT_TOOL` to store these facts with semantic embeddings.

    **Watch for:** The agent should confirm it remembered the contact preference, rate exception, and relationship history.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    SELECT AI AGENT Acme Industries is one of our best clients. They prefer email contact through their CFO Sarah Chen. They have been with Seer Equity since 2019 and were approved for a 15% rate exception due to their excellent payment history on 4 previous loans. Please remember all of this;
    </copy>
    ```

    ![Teach agent about Acme Industries - All the given information about Acme Industries has been stored using the REMEMBER_CLIENT_TOOL](images/task10_1.png)

2. Test client recall.

    Ask about Acme Industries. The agent should use `RECALL_CLIENT_TOOL` and return all the facts you just taught it.

    **Watch for:** All the facts: email preference, Sarah Chen, since 2019, 15% rate exception, 4 previous loans.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    SELECT AI AGENT What do you know about Acme Industries;
    </copy>
    ```

    ![Recall Acme Industries - agent returns all stored facts about the client](images/task10_2.png)

3. Ask for guidance on a new situation.

    Ask the agent about handling a situation with "unpredictable revenue." Even though we stored decisions about "seasonal cash flow" and "cyclical revenue," semantic search will find them.

    **Watch for:** The agent should find Harvest Farms (seasonal) and Consulting Partners (cyclical) decisions.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    SELECT AI AGENT A landscaping company has unpredictable revenue - busy in spring and summer, slow in winter. They want a business loan. What have we done in similar situations;
    </copy>
    ```

    ![Ask about landscaping company - agent finds similar past decisions about seasonal/cyclical revenue](images/task10_3.png)

4. Record a new decision.

    Record a new decision based on the guidance. This decision will be stored with its own vector embedding, making it findable by semantic search in the future.

    **Watch for:** The agent should confirm it recorded the decision.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    SELECT AI AGENT We just approved a $150K equipment loan for GreenScape Landscaping with seasonal payment schedule - higher payments April through October, reduced payments November through March. Record this decision;
    </copy>
    ```

    ![Record GreenScape decision - The decision to approve a $150K equipment loan for GreenScape Landscaping has been recorded](images/task10_4.png)

## Task 11: Test Memory Persistence

Now the crucial test—clear the session and start fresh. This simulates logging out and back in, or a new day.

1. Clear and reset the session.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    EXEC DBMS_CLOUD_AI_AGENT.CLEAR_TEAM;
    EXEC DBMS_CLOUD_AI_AGENT.SET_TEAM('SEERS_MEMORY_TEAM');
    </copy>
    ```

    ![CLEAR_TEAM and SET_TEAM - two PL/SQL procedures successfully completed](images/task11_1.png)

2. Ask about Acme Industries in the "new" session.

    The agent has no conversation history—but it has memory tools.

    **Watch what happens:** The agent calls `RECALL_CLIENT_TOOL` and finds all the facts! Because they're stored in the database with embeddings, they persist across sessions.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    SELECT AI AGENT What do you know about Acme Industries and their rate arrangements;
    </copy>
    ```

    ![Ask Acme in new session - agent recalls all facts from database memory](images/task11_2.png)

3. Verify the learning loop.

    Search for seasonal payment decisions. The new GreenScape decision should now appear alongside the original Harvest Farms and Consulting Partners decisions.

    **Watch for:** THREE relevant decisions now, including the one you just recorded. The agent is learning!

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    SELECT DBMS_LOB.SUBSTR(find_similar_decisions('business with seasonal revenue needs flexible payments'), 4000, 1) AS similar_decisions FROM DUAL;
    </copy>
    ```

    ![Search seasonal - finds LANDSCAPING COMPANY as top result, 3 similar past decisions](images/task11_3.png)

## Task 12: Examine the Memory Core

1. Check the tool execution history.

    See exactly what tools the agent called and what results it got. This is full transparency into the agent's memory operations.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    SELECT 
        tool_name,
        TO_CHAR(start_date, 'HH24:MI:SS') as called_at,
        SUBSTR(output, 1, 80) as result_preview
    FROM USER_AI_AGENT_TOOL_HISTORY
    ORDER BY start_date DESC
    FETCH FIRST 15 ROWS ONLY;
    </copy>
    ```

    ![Tool execution history - 9 rows showing RECALL, RECORD, FIND, POLICY, REMEMBER tools with timestamps](images/task12_1.png)

2. Examine the memory tables.

    Look at what's stored in the memory tables, including which memories have vector embeddings.

    **Watch for:** All DECISION records should have embeddings (has_embedding = Yes), enabling semantic search.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    SELECT 
        memory_type,
        entity_id,
        JSON_VALUE(content, '$.situation') as situation,
        CASE WHEN embedding IS NOT NULL THEN 'Yes' ELSE 'No' END as has_embedding,
        TO_CHAR(created_at, 'YYYY-MM-DD HH24:MI') as created
    FROM seers_memory
    WHERE memory_type = 'DECISION'
    ORDER BY created_at DESC;
    </copy>
    ```

    ![Memory core - 7 DECISION rows all with has_embedding=Yes including GREENSCAPE LANDSCAPING](images/task12_2.png)

## Summary

In this lab, you built the learning loop with semantic search:

| Capability | What You Built | How It Works |
|---|---|---|
| Client facts | `remember_client_fact` / `recall_client_info` | Stores & retrieves with embeddings |
| Decision logging | `record_loan_decision` | Audit trail with semantic embedding |
| Semantic search | `find_similar_decisions` | `VECTOR_DISTANCE` finds by *meaning* |
| Policy lookup | `lookup_policy` | Retrieves corporate lending policies |

**Key Behaviors:**
- Agent checks memory FIRST when asked about a client
- Agent stores information when loan officers share it
- Agent finds similar situations even with different wording ("irregular income" → "seasonal cash flow")
- Agent learns from both successes AND failures
- Memory persists across sessions—no more forgetting

**The Learning Loop:**
1. New situation arrives
2. Agent searches for similar past decisions (semantic search)
3. Agent sees what worked before (and what didn't)
4. Agent takes informed action
5. Decision is recorded with embedding
6. Future searches benefit from this new knowledge

This is how agents improve. Not magically, but systematically. The AI database powers it all.

## Cleanup (Optional)

> This command is already in your notebook—just click the play button (▶) to run it.

```sql
<copy>
EXEC DBMS_CLOUD_AI_AGENT.DROP_TEAM('SEERS_MEMORY_TEAM', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TASK('SEERS_MEMORY_TASK', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_AGENT('SEERS_MEMORY_AGENT', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('REMEMBER_CLIENT_TOOL', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('RECALL_CLIENT_TOOL', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('RECORD_DECISION_TOOL', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('FIND_DECISIONS_TOOL', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('POLICY_LOOKUP_TOOL', TRUE);
DROP TABLE seers_memory PURGE;
DROP TABLE seers_policies PURGE;
DROP FUNCTION remember_client_fact;
DROP FUNCTION recall_client_info;
DROP FUNCTION record_loan_decision;
DROP FUNCTION find_similar_decisions;
DROP FUNCTION lookup_policy;

-- Drop the ONNX model
BEGIN
    DBMS_VECTOR.DROP_ONNX_MODEL(model_name => 'ALL_MINILM_L12_V2', force => true);
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
</copy>
```

![Cleanup - all objects dropped successfully](images/cleanup.png)

## Learn More

* [AI Vector Search Guide](https://docs.oracle.com/en/database/oracle/oracle-database/23/vecse/)
* [`DBMS_CLOUD_AI_AGENT` Package](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/dbms-cloud-ai-agent-package.html)

## Acknowledgements

* **Author** - David Start
* **Last Updated By/Date** - David Start, January 2026
