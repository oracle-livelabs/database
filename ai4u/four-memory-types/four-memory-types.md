# The Four Types of Agent Memory

## Introduction

In this lab, you'll build all four types of memory that agents need to operate effectively.

### The Business Problem

Seer Equity's loan officers are struggling with different kinds of information gaps:

- **During calls:** *"What did the client just say about their timeline? I was looking up their file."*
- **Across sessions:** *"Sarah Chen has a rate exception, but I don't remember the details."*
- **For compliance:** *"Why did we approve that loan at those terms? What was the reasoning?"*
- **For consistency:** *"What's our policy on credit score requirements? Different people tell me different things."*

These aren't the same problem. They need different solutions. Just like people don't rely on one kind of memory, agents can't either.

### What You'll Learn

In this lab, you'll build the four types of memory that solve these distinct problems:

| Memory Type | What It Stores | Seer Equity Example |
|-------------|----------------|----------------------|
| **Short-term** | Current conversation context | Client's question, active request |
| **Long-term** | Stable facts about entities | Sarah Chen prefers email, has 15% rate exception |
| **Episodic** | Decisions and their outcomes | Approved Sarah's loan because of 6-year history |
| **Reference** | Policies and procedures | Credit requirements, rate tiers, approval rules |

You'll create each type and see how they work together to make agents consistent and explainable.

**What you'll build:** A complete memory system with all four memory types working together.

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

2. Click **Import** to expand the Import drop down.

3. Select **Git**.

4. Paste the following GitHub URL leaving the credential field blank:

    ```text
    <copy>
    https://github.com/davidastart/database/blob/main/ai4u/four-memory-types/lab8-four-memory-types.json
    </copy>
    ```

5. Click **Ok**.

You should now be on the screen with the notebook imported. This workshop will have all of the screenshots and detailed information however the notebook will have the commands and basic instructions for completing the lab.

## Task 2: Create the Memory Tables

We'll create structures for each memory type. Instead of four separate tables, we use one main table with a `memory_type` column to distinguish between types. This makes it easier to query across all memories when needed.

1. Create the unified memory table with type classification.

    The table stores all four memory types. The `memory_type` column tells us what kind of memory it is. Short-term memories have a `session_id` and `expires_at`. Long-term memories have an `entity_id` to track what they're about.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    CREATE TABLE agent_memory (
        memory_id      RAW(16) DEFAULT SYS_GUID() PRIMARY KEY,
        memory_type    VARCHAR2(20) NOT NULL,  -- SHORTTERM, LONGTERM, DECISION, REFERENCE
        session_id     VARCHAR2(100),          -- For short-term context
        entity_id      VARCHAR2(100),          -- What this is about
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

2. Create a separate reference table for policies (read-only by agents).

    Reference knowledge is different—it's maintained by humans, not learned by the agent. We put it in a separate table to make this clear. Agents can read it, but they shouldn't change it.

    > This command is already in your notebook—just click the play button (▶) to run it.

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

## Task 3: Short-Term Context (Current Task)

Short-term context holds what's happening right now—the active information for completing the current task. Think of it like your working memory when you're on a phone call: who you're talking to, what they just said, what problem you're solving. It expires when the task is done.

1. Create functions for short-term context.

    The `set_context` function stores temporary information tied to a session. Notice the `expires_at` field—short-term context automatically expires after an hour. The `get_context` function retrieves all active context for a session.

    > This command is already in your notebook—just click the play button (▶) to run it.

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

2. Test short-term context.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    -- Set context for current task
    SELECT set_context('SESSION-001', 'current_customer', 'Sarah Chen, Premium tier, discussing loan application') FROM DUAL;
    SELECT set_context('SESSION-001', 'current_loan', 'LOAN-5678, personal loan, needs by Friday') FROM DUAL;

    -- Retrieve context
    SELECT get_context('SESSION-001') FROM DUAL;
    </copy>
    ```

## Task 4: Long-Term Facts (Persistent Entity Knowledge)

Long-term facts are stable information the agent should rely on across tasks and sessions. Unlike short-term context, these never expire. They're things like "Sarah prefers email" or "This customer has a rate exception."

1. Create functions for long-term facts.

    The `store_fact` function saves a fact about an entity. The `get_facts` function retrieves all facts about that entity, optionally filtered by category.

    > This command is already in your notebook—just click the play button (▶) to run it.

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

2. Store some long-term facts.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    -- Facts about customers
    SELECT store_fact('CUST-001', 'Prefers email contact over phone', 'preference') FROM DUAL;
    SELECT store_fact('CUST-001', 'Timezone is Pacific', 'preference') FROM DUAL;
    SELECT store_fact('CUST-001', 'Approved for 15% rate exception', 'exception') FROM DUAL;
    SELECT store_fact('CUST-001', 'Client since 2018', 'history') FROM DUAL;

    SELECT store_fact('CUST-002', 'Requires all documents via secure portal', 'requirement') FROM DUAL;
    SELECT store_fact('CUST-002', 'Annual loan review in March', 'schedule') FROM DUAL;
    </copy>
    ```

3. Retrieve facts.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    -- Set display width for CLOB output
    SET LONG 5000
    SET LINESIZE 200

    -- Get all facts about a customer
    SELECT get_facts('CUST-001') as facts FROM DUAL;

    -- Get only preferences
    SELECT get_facts('CUST-001', 'preference') as preferences FROM DUAL;
    </copy>
    ```

## Task 5: Decisions and Outcomes (Audit Trail)

Decisions and outcomes record what the agent decided and what happened. This is your audit trail—when someone asks "why did we do that?", you can look it up. It also helps the agent learn from past decisions.

1. Create functions for decisions and outcomes.

    The `record_decision` function stores what situation occurred, what decision was made, and whether it worked. The `find_past_decisions` function searches for similar situations to learn from.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    -- Record a decision
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

2. Record some decisions.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    -- Record past decisions and their outcomes
    SELECT record_decision(
        'CUST-001',
        'Long-term customer requested rate exception due to payment history',
        'Approved 15% rate exception based on 6-year relationship',
        'Customer satisfied, renewed multiple loans',
        'true'
    ) FROM DUAL;

    SELECT record_decision(
        'CUST-002',
        'New customer requested rate exception on first loan',
        'Declined exception but offered standard preferred rate',
        'Customer accepted, relationship established',
        'true'
    ) FROM DUAL;

    SELECT record_decision(
        'CUST-003',
        'Customer with missed payments requested rate exception',
        'Declined exception citing payment history concerns',
        'Customer upset but policy was correct',
        'true'
    ) FROM DUAL;
    </copy>
    ```

3. Search for relevant past decisions.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    -- Set display width for CLOB output
    SET LONG 5000
    SET LINESIZE 200

    -- Find decisions about rate exceptions
    SELECT find_past_decisions('rate exception') as rate_decisions FROM DUAL;

    -- Find decisions about payment history
    SELECT find_past_decisions('payment') as payment_decisions FROM DUAL;
    </copy>
    ```

## Task 6: Reference Knowledge (Policies and Procedures)

Reference knowledge is background information the agent consults but does not change. These are your company policies, procedures, and guidelines—things that humans maintain and agents follow.

1. Create functions for reference knowledge.

    The `add_reference` function is for administrators to add policies. The `get_reference` function lets agents look up what the policy says. Notice agents can read but not write—this keeps your policies under human control.

    > This command is already in your notebook—just click the play button (▶) to run it.

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

2. Add reference knowledge (policies).

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    -- Add policies
    SELECT add_reference('policy', 'Rate Exception Policy - Preferred', 
        'Clients with 5+ years history and no missed payments may receive up to 15% rate discount. ' ||
        'Approval required from senior loan officer. Document rationale in loan notes.') FROM DUAL;
        
    SELECT add_reference('policy', 'Rate Exception Policy - Standard',
        'Standard clients may request rate review after 2 years of on-time payments. ' ||
        'Maximum 10% discount. Requires underwriter approval.') FROM DUAL;
        
    SELECT add_reference('procedure', 'Escalation Process',
        'Rate disputes: 1) Loan officer reviews history, 2) If over $50K loan, escalate to Senior Officer, ' ||
        '3) If unresolved, escalate to Branch Manager, 4) Customer may request formal review.') FROM DUAL;
        
    SELECT add_reference('guideline', 'Client Communication',
        'Always be empathetic and solution-focused. Acknowledge client concerns before ' ||
        'explaining policy. Offer alternatives when declining requests.') FROM DUAL;
    </copy>
    ```

3. Query reference knowledge.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    -- Set display width for CLOB output
    SET LONG 5000
    SET LINESIZE 200

    -- Get all policies
    SELECT get_reference('policy') as policies FROM DUAL;

    -- Get escalation procedure
    SELECT get_reference('procedure', 'escalation') as escalation FROM DUAL;
    </copy>
    ```

## Task 7: A Complete Example

Let's trace how an agent would use all four types together.

> This command is already in your notebook—just click the play button (▶) to run it.

```sql
<copy>
-- Set display width for CLOB output
SET LONG 5000
SET LINESIZE 200

-- Scenario: Customer CUST-001 (Sarah Chen) calls about a rate exception request

-- 1. Set short-term context (current task)
SELECT set_context('SESSION-002', 'customer', 'CUST-001 Sarah Chen calling about rate exception') as step1_context FROM DUAL;
SELECT set_context('SESSION-002', 'issue', 'Requesting rate review on new $75K personal loan') as step1_issue FROM DUAL;

-- 2. Check long-term facts (what do we know about them?)
SELECT get_facts('CUST-001') as step2_facts FROM DUAL;

-- 3. Check reference knowledge (what is the policy?)
SELECT get_reference('policy', 'rate exception') as step3_policy FROM DUAL;

-- 4. Find similar past decisions (what worked before?)
SELECT find_past_decisions('rate exception') as step4_past_decisions FROM DUAL;

-- 5. Agent makes decision based on all of this, then records it
SELECT record_decision(
    'CUST-001',
    'Long-term client Sarah Chen requested rate exception on new $75K personal loan',
    'Approved 15% rate exception based on 6-year history and existing exception status',
    'Client satisfied, loan processed same day',
    'true'
) as step5_decision FROM DUAL;

-- 6. Learn new fact if relevant
SELECT store_fact('CUST-001', 'Prefers quick decisions - values efficiency', 'preference') as step6_new_fact FROM DUAL;
</copy>
```

## Summary

In this lab, you built the four types of agent memory:

* **Short-term context**: Current task inputs (expires with task)
* **Long-term facts**: Stable entity knowledge (persists forever)
* **Decisions and outcomes**: Audit trail (persists forever)
* **Reference knowledge**: Policies and procedures (human-maintained)

Together, these memories make agents consistent, contextual, and explainable.

## Learn More

* [Oracle JSON Developer's Guide](https://docs.oracle.com/en/database/oracle/oracle-database/26/adjsn/)
* [`DBMS_CLOUD_AI_AGENT` Package](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/dbms-cloud-ai-agent-package.html)

## Acknowledgements

* **Author** - David Start
* **Last Updated By/Date** - David Start, January 2026

## Cleanup (Optional)

> This command is already in your notebook—just click the play button (▶) to run it.

```sql
<copy>
DROP TABLE agent_memory;
DROP TABLE reference_knowledge;
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
