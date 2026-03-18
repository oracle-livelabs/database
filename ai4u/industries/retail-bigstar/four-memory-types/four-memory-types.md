# The Four Types of Agent Memory

## Introduction

In this lab, you'll build all four types of memory that agents need to operate effectively.

### The Business Problem

Two similar business item submissions came in last quarter at Big Star Collectibles. Same item amount, similar credit profiles, similar businesses. One got approved at preferred rates; the other got denied outright.

> *"Every inventory specialist handles the same situation differently. There's no way to learn from past decisions or ensure consistency."*

The problem isn't just forgetting clients. It's forgetting *decisions*. Without memory of what worked before, every item decision starts from scratch.

### What You'll Learn

Agents need four types of memory, just like people:

| Memory Type | Purpose | Example at Big Star Collectibles |
|-------------|---------|-------------------------|
| **Short-term context** | What's happening right now | "Working on ITEM-5678 for Sarah Chen" |
| **Long-term facts** | Stable client information | "Sarah Chen has 15% rate exception" |
| **Decisions/outcomes** | What we decided before | "Approved similar item last quarter, client paid on time" |
| **Reference knowledge** | Corporate policies | "Preferred rate is 7.9% for 750+ credit" |

In this lab, you'll build all four types and see how they work together to make agents consistent and explainable.

**What you'll build:** A complete four-type memory architecture for item decisions.

Estimated Time: 15 minutes

### Objectives

* Create the four types of agent memory
* Understand when each type is used
* Store and retrieve from each memory type
* See how agents coordinate multiple memory types

### Prerequisites

For this workshop, we provide the environment. You'll need:

* Basic knowledge of SQL and PL/SQL, or the ability to follow along with the prompts

## Task 1: Import the Lab Notebook

Before you begin, you are going to import a notebook that has all of the commands for this lab into Oracle Machine Learning. This way you don't have to copy and paste them over to run them.

1. From the Oracle Machine Learning home page, click **Notebooks**.

    ![OML home page with Notebooks highlighted in the Quick Actions section](images/task1_1.png " ")

2. Click **Import** to expand the Import drop down.

    ![Notebooks page with Import button highlighted in the toolbar](images/task1_2.png " ")

3. Select **Git**.

    ![Import dropdown showing File and Git options, with Git highlighted](images/task1_3.png " ")

4. Paste the following GitHub URL leaving the credential field blank, then click **OK**.

    ```text
    <copy>
    https://github.com/kaymalcolm/database/blob/main/ai4u/industries/retail-bigstar/four-memory-types/lab8-four-memory-types.json
    </copy>
    ```

    ![Git Clone dialog with the GitHub URI field highlighted and OK button highlighted](images/task1_5.png " ")

    You should now be on the screen with the notebook imported. This workshop will have all of the screenshots and detailed information, however the notebook will have the commands and basic instructions for completing the lab.

## Task 2: Create the Memory Tables

You'll create two tables: `agent_memory` for short-term, long-term, and decision memory with a type classifier, and `reference_knowledge` for item policies that agents can read but not modify.

1. Create the unified memory table.

    The `memory_type` constraint limits values to SHORTTERM, LONGTERM, DECISION, and REFERENCE. Short-term entries have a `session_id` and `expires_at`; long-term and decision entries use `entity_id` to track what they're about.

    > This command is already in your notebook — just click the play button (▶) to run it.

    ```sql
    <copy>
    CREATE TABLE agent_memory (
        memory_id      RAW(16) DEFAULT SYS_GUID() PRIMARY KEY,
        memory_type    VARCHAR2(20) NOT NULL,  -- SHORTTERM, LONGTERM, DECISION, REFERENCE
        session_id     VARCHAR2(100),          -- For short-term context
        entity_id      VARCHAR2(100),          -- What this is about (client or item)
        content        JSON NOT NULL,
        created_at     TIMESTAMP DEFAULT SYSTIMESTAMP,
        expires_at     TIMESTAMP,              -- For short-term context expiration
        CONSTRAINT chk_memory_type CHECK (memory_type IN ('SHORTTERM', 'LONGTERM', 'DECISION', 'REFERENCE'))
    );

    CREATE INDEX idx_memory_type ON agent_memory(memory_type);
    CREATE INDEX idx_memory_entity ON agent_memory(entity_id);
    CREATE INDEX idx_memory_session ON agent_memory(session_id);
    </copy>
    ```

    ![CREATE TABLE agent_memory with memory_type, session_id, entity_id, content, expires_at columns and CHECK constraint, plus three CREATE INDEX statements, with output: Table AGENT_MEMORY created, Index IDX_MEMORY_TYPE created, Index IDX_MEMORY_ENTITY created, Index IDX_MEMORY_SESSION created](images/task2_1.png " ")

2. Create the reference knowledge table.

    Reference knowledge is different -- it's maintained by humans, not agents. The `updated_by` column tracks who changed the policy. Agents can read it, but they shouldn't change it.

    > This command is already in your notebook — just click the play button (▶) to run it.

    ```sql
    <copy>
    CREATE TABLE reference_knowledge (
        ref_id       RAW(16) DEFAULT SYS_GUID() PRIMARY KEY,
        category     VARCHAR2(100) NOT NULL,
        name         VARCHAR2(200) NOT NULL,
        content      JSON NOT NULL,
        is_active    NUMBER(1) DEFAULT 1,
        created_at   TIMESTAMP DEFAULT SYSTIMESTAMP,
        updated_by   VARCHAR2(100)  -- Humans update this, not agents
    );
    </copy>
    ```

    ![CREATE TABLE reference_knowledge with category, name, content, is_active, updated_by columns, with output: Table REFERENCE_KNOWLEDGE created](images/task2_2.png " ")

## Task 3: Short-Term Context (Current Task)

Short-term context holds what's happening right now -- the active information for completing the current item task. Think of it like a inventory specialist's working memory: who they're talking to, what they just said, what problem they're solving. It expires when the task is done.

1. Create functions for short-term context.

    `set_context` stores temporary information tied to a session. Notice the `expires_at` field -- short-term context automatically expires after one hour. `get_context` retrieves all active context for a session.

    > This command is already in your notebook — just click the play button (▶) to run it.

    ```sql
    <copy>
    -- Store short-term context
    CREATE OR REPLACE FUNCTION set_context(
        p_session_id  VARCHAR2,
        p_entity_id   VARCHAR2,
        p_context     VARCHAR2
    ) RETURN VARCHAR2 AS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        -- Clear old context for this session/entity
        DELETE FROM agent_memory 
        WHERE memory_type = 'SHORTTERM' 
        AND session_id = p_session_id 
        AND entity_id = p_entity_id;

        -- Store new context (expires in 1 hour)
        INSERT INTO agent_memory (memory_type, session_id, entity_id, content, expires_at)
        VALUES (
            'SHORTTERM', 
            p_session_id, 
            p_entity_id,
            JSON_OBJECT('context' VALUE p_context, 'set_at' VALUE TO_CHAR(SYSTIMESTAMP, 'HH24:MI:SS')),
            SYSTIMESTAMP + INTERVAL '1' HOUR
        );
        COMMIT;
        RETURN 'Context set for ' || p_entity_id;
    END;
    /

    -- Get short-term context
    CREATE OR REPLACE FUNCTION get_context(
        p_session_id VARCHAR2,
        p_entity_id  VARCHAR2 DEFAULT NULL
    ) RETURN VARCHAR2 AS
        v_result CLOB := '';
    BEGIN
        FOR rec IN (
            SELECT entity_id, JSON_VALUE(content, '$.context') as context
            FROM agent_memory
            WHERE memory_type = 'SHORTTERM'
            AND session_id = p_session_id
            AND (p_entity_id IS NULL OR entity_id = p_entity_id)
            AND (expires_at IS NULL OR expires_at > SYSTIMESTAMP)
        ) LOOP
            v_result := v_result || rec.entity_id || ': ' || rec.context || CHR(10);
        END LOOP;

        IF v_result IS NULL THEN
            RETURN 'No active context found.';
        END IF;
        RETURN v_result;
    END;
    /
    </copy>
    ```

    ![Notebook cell showing CREATE OR REPLACE FUNCTION set_context with PRAGMA AUTONOMOUS_TRANSACTION, DELETE and INSERT logic for SHORTTERM memory with 1-hour expiry](images/task3_1a.png " ")

    ![Continuation showing get_context function body and output: Function SET_CONTEXT compiled, Function GET_CONTEXT compiled](images/task3_1b.png " ")

2. Test short-term context.

    Set context for a item processing session. You should see both context items returned -- the client info and the application details.

    > This command is already in your notebook — just click the play button (▶) to run it.

    ```sql
    <copy>
    -- Set context for current item task
    SELECT set_context('SESSION-001', 'current_client', 'Sarah Chen, Preferred tier, discussing personal item') FROM DUAL;
    SELECT set_context('SESSION-001', 'current_application', 'ITEM-5678, $75K personal item, needs by Friday') FROM DUAL;

    -- Retrieve context
    SELECT get_context('SESSION-001') FROM DUAL;
    </copy>
    ```

    You should see both context entries returned: `current_client: Sarah Chen, Preferred tier, discussing personal item` and `current_application: ITEM-5678, $75K personal item, needs by Friday`.

    ![set_context calls for SESSION-001 with current_client and current_application, followed by get_context returning both entries: current_client: Sarah Chen Preferred tier discussing personal item, and current_application: ITEM-5678 $75K personal item needs by Friday](images/task3_2.png " ")

## Task 4: Long-Term Facts (Persistent Entity Knowledge)

Long-term facts are stable information about clients that the agent should rely on across all tasks and sessions. Unlike short-term context, these never expire.

1. Create functions for long-term facts.

    `store_fact` saves a fact about an entity with an optional category. `get_facts` retrieves all facts about that entity, optionally filtered by category.

    > This command is already in your notebook — just click the play button (▶) to run it.

    ```sql
    <copy>
    -- Store a long-term fact
    CREATE OR REPLACE FUNCTION store_fact(
        p_entity_id   VARCHAR2,
        p_fact        VARCHAR2,
        p_category    VARCHAR2 DEFAULT 'general'
    ) RETURN VARCHAR2 AS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        INSERT INTO agent_memory (memory_type, entity_id, content)
        VALUES (
            'LONGTERM',
            p_entity_id,
            JSON_OBJECT(
                'fact'     VALUE p_fact,
                'category' VALUE p_category,
                'learned'  VALUE TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS')
            )
        );
        COMMIT;
        RETURN 'Fact stored about ' || p_entity_id || ': ' || p_fact;
    END;
    /

    -- Retrieve facts about an entity
    CREATE OR REPLACE FUNCTION get_facts(
        p_entity_id VARCHAR2,
        p_category  VARCHAR2 DEFAULT NULL
    ) RETURN CLOB AS
        v_result CLOB := '';
        v_count NUMBER := 0;
    BEGIN
        FOR rec IN (
            SELECT 
                JSON_VALUE(content, '$.fact') as fact,
                JSON_VALUE(content, '$.category') as category
            FROM agent_memory
            WHERE memory_type = 'LONGTERM'
            AND entity_id = p_entity_id
            AND (p_category IS NULL OR JSON_VALUE(content, '$.category') = p_category)
            ORDER BY created_at DESC
        ) LOOP
            v_result := v_result || '- ' || rec.fact || ' (' || rec.category || ')' || CHR(10);
            v_count := v_count + 1;
        END LOOP;

        IF v_count = 0 THEN
            RETURN 'No facts found for ' || p_entity_id;
        END IF;
        RETURN 'Found ' || v_count || ' facts about ' || p_entity_id || ':' || CHR(10) || v_result;
    END;
    /
    </copy>
    ```

    ![CREATE OR REPLACE FUNCTION store_fact inserting LONGTERM records with fact, category, and learned timestamp](images/task4_1a.png " ")

    ![Continuation showing get_facts function body with LONGTERM query, and output: Function STORE_FACT compiled, Function GET_FACTS compiled](images/task4_1b.png " ")

2. Store long-term facts about clients.

    Store several facts about two clients using different categories: `contact_preference`, `rate_exception`, `relationship`, `requirement`, `schedule`. These will persist across all sessions.

    > This command is already in your notebook — just click the play button (▶) to run it.

    ```sql
    <copy>
    -- Facts about Big Star Collectibles clients
    SELECT store_fact('CLIENT-001', 'Prefers email contact, never phone', 'contact_preference') FROM DUAL;
    SELECT store_fact('CLIENT-001', 'Pacific timezone, best contact time is 9-11am PT', 'contact_preference') FROM DUAL;
    SELECT store_fact('CLIENT-001', 'Approved for 15% rate exception due to 6-year relationship', 'rate_exception') FROM DUAL;
    SELECT store_fact('CLIENT-001', 'Client since 2018, excellent payment history on 3 previous items', 'relationship') FROM DUAL;

    SELECT store_fact('CLIENT-002', 'Requires all documents via secure portal', 'requirement') FROM DUAL;
    SELECT store_fact('CLIENT-002', 'Annual item review scheduled for March', 'schedule') FROM DUAL;
    </copy>
    ```

    ![Six store_fact calls for CLIENT-001 and CLIENT-002, with output lines confirming each fact stored: Fact stored about CLIENT-001: Prefers email contact never phone, Fact stored about CLIENT-001: Approved for 15% rate exception due to 6-year relationship, etc.](images/task4_2.png " ")

3. Retrieve facts.

    You should see 4 facts for CLIENT-001 when retrieving all, and 2 when filtered to `contact_preference`.

    > This command is already in your notebook — just click the play button (▶) to run it.

    ```sql
    <copy>
    -- Get all facts about a client
    SELECT get_facts('CLIENT-001') as facts FROM DUAL;

    -- Get only contact preferences
    SELECT get_facts('CLIENT-001', 'contact_preference') as contact_prefs FROM DUAL;
    </copy>
    ```

    ![get_facts queries showing FACTS result: Found 4 facts about CLIENT-001 with Client since 2018 visible, and CONTACT_PREFS result: Found 2 facts about CLIENT-001 with Pacific timezone best contact time is 9-11am visible](images/task4_3.png " ")

## Task 5: Decisions and Outcomes (Audit Trail)

Decisions and outcomes record what the agent decided and what happened. This is your audit trail -- when someone asks "why did we do that?", you can look it up. Notice the third decision has `success = false`. The agent should learn what NOT to do from failures too.

1. Create functions for decisions and outcomes.

    `record_decision` stores what situation occurred, what decision was made, and whether it worked. `find_past_decisions` searches for similar situations to learn from.

    > This command is already in your notebook — just click the play button (▶) to run it.

    ```sql
    <copy>
    -- Record a item decision
    CREATE OR REPLACE FUNCTION record_decision(
        p_entity_id   VARCHAR2,
        p_situation   VARCHAR2,
        p_decision    VARCHAR2,
        p_outcome     VARCHAR2,
        p_success     VARCHAR2 DEFAULT 'true'
    ) RETURN VARCHAR2 AS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        INSERT INTO agent_memory (memory_type, entity_id, content)
        VALUES (
            'DECISION',
            p_entity_id,
            JSON_OBJECT(
                'situation' VALUE p_situation,
                'decision'  VALUE p_decision,
                'outcome'   VALUE p_outcome,
                'success'   VALUE (CASE WHEN UPPER(p_success) = 'TRUE' THEN true ELSE false END),
                'recorded'  VALUE TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS')
            )
        );
        COMMIT;
        RETURN 'Decision recorded: ' || p_decision;
    END;
    /

    -- Find similar past decisions
    CREATE OR REPLACE FUNCTION find_past_decisions(
        p_situation VARCHAR2,
        p_limit     NUMBER DEFAULT 3
    ) RETURN CLOB AS
        v_result CLOB := '';
        v_count NUMBER := 0;
    BEGIN
        FOR rec IN (
            SELECT 
                entity_id,
                JSON_VALUE(content, '$.situation') as situation,
                JSON_VALUE(content, '$.decision') as decision,
                JSON_VALUE(content, '$.outcome') as outcome,
                JSON_VALUE(content, '$.success') as success
            FROM agent_memory
            WHERE memory_type = 'DECISION'
            AND (
                UPPER(JSON_VALUE(content, '$.situation')) LIKE '%' || UPPER(p_situation) || '%'
                OR UPPER(p_situation) LIKE '%' || UPPER(SUBSTR(JSON_VALUE(content, '$.situation'), 1, 20)) || '%'
            )
            ORDER BY created_at DESC
            FETCH FIRST p_limit ROWS ONLY
        ) LOOP
            v_result := v_result || 
                'Situation: ' || rec.situation || CHR(10) ||
                'Decision: ' || rec.decision || CHR(10) ||
                'Outcome: ' || rec.outcome || 
                ' (Success: ' || rec.success || ')' || CHR(10) || '---' || CHR(10);
            v_count := v_count + 1;
        END LOOP;

        IF v_count = 0 THEN
            RETURN 'No similar decisions found.';
        END IF;
        RETURN 'Found ' || v_count || ' similar decisions:' || CHR(10) || v_result;
    END;
    /
    </copy>
    ```

    ![CREATE OR REPLACE FUNCTION record_decision inserting DECISION records with situation, decision, outcome, success boolean, and recorded timestamp](images/task5_1a.png " ")

    ![Continuation showing find_past_decisions function with LIKE-based situation matching, and output: Function RECORD_DECISION compiled, Function FIND_PAST_DECISIONS compiled](images/task5_1b.png " ")

2. Record past item decisions.

    > This command is already in your notebook — just click the play button (▶) to run it.

    ```sql
    <copy>
    -- Record past item decisions and their outcomes
    SELECT record_decision(
        'CLIENT-001',
        'Preferred client requested rate exception for personal item',
        'Approved 15% rate discount based on 6-year relationship and payment history',
        'Client accepted item terms, successful disbursement, on-time payments',
        'true'
    ) FROM DUAL;

    SELECT record_decision(
        'CLIENT-002',
        'Standard client requested larger item than credit profile supported',
        'Offered smaller item amount with path to increase after 12 months good standing',
        'Client accepted modified terms, built relationship for future business',
        'true'
    ) FROM DUAL;

    SELECT record_decision(
        'CLIENT-003',
        'Client with marginal credit requested business item',
        'Denied application citing credit score without offering alternatives',
        'Client went to competitor, later became successful business we lost',
        'false'
    ) FROM DUAL;

    SELECT record_decision(
        'CLIENT-003',
        'Client with marginal credit requested business item',
        'Offered secured item option with credit-building program',
        'Client accepted, improved credit over 18 months, now Preferred tier',
        'true'
    ) FROM DUAL;
    </copy>
    ```

    ![Four record_decision calls for CLIENT-001 through CLIENT-003, with output confirming each decision recorded including the false success entry for the denied CLIENT-003 application](images/task5_2.png " ")

3. Search for similar past decisions.

    For rate exception you should find 1 similar decision. For marginal credit you should find 2 -- both the failed approach (denied without alternatives) and the successful one (secured item with credit-building program).

    > This command is already in your notebook — just click the play button (▶) to run it.

    ```sql
    <copy>
    -- Find decisions about rate exceptions
    SELECT find_past_decisions('rate exception') as rate_decisions FROM DUAL;

    -- Find decisions about marginal credit
    SELECT find_past_decisions('marginal credit') as credit_decisions FROM DUAL;
    </copy>
    ```

    ![find_past_decisions queries showing RATE_DECISIONS result: Found 1 similar decisions with Situation: Preferred client requested rate exception visible, and CREDIT_DECISIONS result: Found 2 similar decisions with Situation: Client with marginal credit requested busi visible](images/task5_3.png " ")

## Task 6: Reference Knowledge (Policies and Procedures)

Reference knowledge is Big Star Collectibles' policies, procedures, and guidelines maintained by humans. Agents consult it but don't modify it. This separation is important -- agents should follow corporate policies, not rewrite them.

1. Create functions for reference knowledge.

    `add_reference` is for administrators to add policies (tracks who added it). `get_reference` lets agents look up what the policy says.

    > This command is already in your notebook — just click the play button (▶) to run it.

    ```sql
    <copy>
    -- Add reference knowledge (admin function)
    CREATE OR REPLACE FUNCTION add_reference(
        p_category    VARCHAR2,
        p_name        VARCHAR2,
        p_content     VARCHAR2,
        p_updated_by  VARCHAR2 DEFAULT USER
    ) RETURN VARCHAR2 AS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        INSERT INTO reference_knowledge (category, name, content, updated_by)
        VALUES (
            p_category,
            p_name,
            JSON_OBJECT('text' VALUE p_content),
            p_updated_by
        );
        COMMIT;
        RETURN 'Reference added: ' || p_name;
    END;
    /

    -- Get reference knowledge (agent reads this)
    CREATE OR REPLACE FUNCTION get_reference(
        p_category VARCHAR2 DEFAULT NULL,
        p_name     VARCHAR2 DEFAULT NULL
    ) RETURN CLOB AS
        v_result CLOB := '';
        v_count NUMBER := 0;
    BEGIN
        FOR rec IN (
            SELECT category, name, JSON_VALUE(content, '$.text') as text
            FROM reference_knowledge
            WHERE is_active = 1
            AND (p_category IS NULL OR UPPER(category) LIKE '%' || UPPER(p_category) || '%')
            AND (p_name IS NULL OR UPPER(name) LIKE '%' || UPPER(p_name) || '%')
            ORDER BY category, name
        ) LOOP
            v_result := v_result || '[' || rec.category || '] ' || rec.name || ':' || CHR(10) ||
                       rec.text || CHR(10) || CHR(10);
            v_count := v_count + 1;
        END LOOP;

        IF v_count = 0 THEN
            RETURN 'No reference knowledge found.';
        END IF;
        RETURN 'Found ' || v_count || ' references:' || CHR(10) || v_result;
    END;
    /
    </copy>
    ```

    ![CREATE OR REPLACE FUNCTION add_reference inserting into reference_knowledge with category, name, JSON content, and updated_by tracking](images/task6_1a.png " ")

    ![Continuation showing get_reference function querying reference_knowledge by category and name with is_active filter, and output: Function ADD_REFERENCE compiled, Function GET_REFERENCE compiled](images/task6_1b.png " ")

2. Add reference knowledge (policies).

    Add Big Star Collectibles' item policies as an administrator would. Notice the different categories: `policy`, `procedure`, `guideline`.

    > This command is already in your notebook — just click the play button (▶) to run it.

    ```sql
    <copy>
    -- Add Big Star Collectibles item policies
    SELECT add_reference('policy', 'Personal Item - Preferred Rate', 
        'Preferred customers (credit score 750+) qualify for personal items at 7.9% APR. ' ||
        'Maximum item amount $100,000. No origination fee. Same-day approval for amounts under $50,000.') FROM DUAL;
        
    SELECT add_reference('policy', 'Personal Item - Standard Rate',
        'Standard customers (credit score 650-749) qualify for personal items at 12.9% APR. ' ||
        'Maximum item amount $50,000. 2% origination fee applies. Approval within 2 business days.') FROM DUAL;
        
    SELECT add_reference('procedure', 'Risk Escalation Process',
        'Item risk escalation: 1) Agent assesses initial eligibility, 2) If DTI exceeds 35%, ' ||
        'escalate to underwriter, 3) If credit below 650, escalate to senior underwriter, ' ||
        '4) Applicant may request manager review of any decision.') FROM DUAL;
        
    SELECT add_reference('guideline', 'Client Communication Standards',
        'Always be professional and solution-focused. Acknowledge client concerns before ' ||
        'explaining policy. When declining, always offer alternatives or a path forward.') FROM DUAL;
    </copy>
    ```

    ![Four add_reference calls adding Personal Item Preferred Rate, Personal Item Standard Rate, Risk Escalation Process, and Client Communication Standards, with output confirming each reference added](images/task6_2.png " ")

3. Query reference knowledge.

    You should see both rate policies when searching for `policy`, and the escalation steps when searching for `escalation`.

    > This command is already in your notebook — just click the play button (▶) to run it.

    ```sql
    <copy>
    -- Get all item policies
    SELECT get_reference('policy') as policies FROM DUAL;

    -- Get escalation procedure
    SELECT get_reference('procedure', 'escalation') as escalation FROM DUAL;
    </copy>
    ```

    ![get_reference queries showing POLICIES result: Found 2 references with [policy] Personal Item - Preferred Rate: Preferred customers visible, and ESCALATION result: Found 1 references with [procedure] Risk Escalation Process: Item risk escalation: 1 visible](images/task6_3.png " ")

## Task 7: A Complete Example

Now let's trace how an agent uses all four memory types together when handling a real inquiry at Big Star Collectibles.

**Scenario:** CLIENT-001 (Sarah Chen) calls about a new item request.

> This command is already in your notebook — just click the play button (▶) to run it.

```sql
<copy>
-- Scenario: CLIENT-001 (Sarah Chen) inquires about a new item

-- 1. Set short-term context (current task)
SELECT set_context('SESSION-002', 'client', 'CLIENT-001 Sarah Chen calling about new personal item') as step1_context FROM DUAL;
SELECT set_context('SESSION-002', 'issue', '$75K request, wants to know applicable rate') as step1_issue FROM DUAL;

-- 2. Check long-term facts (what do we know about them?)
SELECT get_facts('CLIENT-001') as step2_facts FROM DUAL;

-- 3. Check reference knowledge (what is the policy?)
SELECT get_reference('policy', 'preferred') as step3_policy FROM DUAL;

-- 4. Find similar past decisions (what worked before?)
SELECT find_past_decisions('rate exception') as step4_past_decisions FROM DUAL;

-- 5. Agent makes decision based on all of this, then records it
SELECT record_decision(
    'CLIENT-001',
    'Preferred client Sarah Chen requested $75K personal item',
    'Quoted preferred rate 7.9% with 15% rate exception applied per client history',
    'Client satisfied with rate, proceeded with application same day',
    'true'
) as step5_decision FROM DUAL;

-- 6. Learn new fact if relevant
SELECT store_fact('CLIENT-001', 'Values quick decisions - appreciates same-day processing', 'preference') as step6_new_fact FROM DUAL;
</copy>
```

The agent sets context, pulls long-term facts, checks policy, finds relevant past decisions, records the new decision, and stores a newly learned preference -- all in a single workflow.

![Complete example cell showing all six steps for SESSION-002 with CLIENT-001 Sarah Chen, and output confirming STEP1_CONTEXT: Context set for client, STEP1_ISSUE: Context set for issue](images/task7_1.png " ")

## Summary

In this lab, you built the four types of agent memory:

| Memory Type | Purpose | Lifespan | Who Updates |
|-------------|---------|----------|-------------|
| **Short-term** | Current item task context | Expires (1 hour) | Agent |
| **Long-term** | Client knowledge | Forever | Agent |
| **Decision** | Item decision audit trail | Forever | Agent |
| **Reference** | Item policies | Forever | Humans |

Together, these memories make agents consistent (same client, same treatment), contextual (aware of current situation), explainable (every decision is logged), and compliant (following human-defined policies).

## Learn More

* [Oracle JSON Developer's Guide](https://docs.oracle.com/en/database/oracle/oracle-database/26/adjsn/)
* [`DBMS_CLOUD_AI_AGENT` Package](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/dbms-cloud-ai-agent-package.html)

## Acknowledgements

* **Author** - David Start, Director, Database Product Management
* **Last Updated By/Date** - Kay Malcolm, February 2026

## Cleanup (Optional)

> This command is already in your notebook — just click the play button (▶) to run it.

```sql
<copy>
DROP TABLE agent_memory PURGE;
DROP TABLE reference_knowledge PURGE;
DROP FUNCTION set_context;
DROP FUNCTION get_context;
DROP FUNCTION store_fact;
DROP FUNCTION get_facts;
DROP FUNCTION record_decision;
DROP FUNCTION find_past_decisions;
DROP FUNCTION add_reference;
DROP FUNCTION get_reference;
</copy>
```

![DROP TABLE agent_memory PURGE, DROP TABLE reference_knowledge PURGE, and eight DROP FUNCTION statements, with output showing Table AGENT_MEMORY dropped, Table REFERENCE_KNOWLEDGE dropped, Function SET_CONTEXT dropped, Function GET_CONTEXT dropped](images/cleanup.png " ")
