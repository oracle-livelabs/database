# The Four Types of Agent Memory

## Introduction

In this lab, you'll build all four types of memory that agents need to operate effectively.

Just like people don't rely on one kind of memory, agents can't either. Agents need:

- **Short-term context** — What's happening right now
- **Long-term facts** — Stable information about entities
- **Decisions and outcomes** — What was decided and why
- **Reference knowledge** — Policies and procedures

You'll create each type and see how they work together to make agents consistent and explainable.

Estimated Time: 15 minutes

### Objectives

* Create the four types of agent memory
* Understand when each type is used
* Store and retrieve from each memory type
* See how agents coordinate multiple memory types

### Prerequisites

This lab assumes you have:

* Completed Labs 1-7 or have a working agent setup
* An AI profile named `genai` already configured
* Oracle Database 26ai with Select AI Agent
* Basic knowledge of SQL and JSON

## Task 1: Create the Memory Tables

We'll create structures for each memory type.

1. Create the unified memory table with type classification.

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

## Task 2: Short-Term Context (Current Task)

Short-term context holds what's happening right now—the active information for completing the current task.

1. Create functions for short-term context.

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

    ```sql
    <copy>
    -- Set context for current task
    SELECT set_context('SESSION-001', 'current_customer', 'Acme Corp, Premium tier, discussing order issue') FROM DUAL;
    SELECT set_context('SESSION-001', 'current_order', 'ORD-5678, shipped late, customer needs by Friday') FROM DUAL;

    -- Retrieve context
    SELECT get_context('SESSION-001') FROM DUAL;
    </copy>
    ```

## Task 3: Long-Term Facts (Persistent Entity Knowledge)

Long-term facts are stable information the agent should rely on across tasks and sessions.

1. Create functions for long-term facts.

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

    ```sql
    <copy>
    -- Facts about customers
    SELECT store_fact('CUST-001', 'Prefers email contact over phone', 'preference') FROM DUAL;
    SELECT store_fact('CUST-001', 'Timezone is Pacific', 'preference') FROM DUAL;
    SELECT store_fact('CUST-001', 'Approved for 20% discount exception', 'exception') FROM DUAL;
    SELECT store_fact('CUST-001', 'Primary contact is Sarah Johnson', 'contact') FROM DUAL;

    SELECT store_fact('CUST-002', 'Requires PO number on all invoices', 'requirement') FROM DUAL;
    SELECT store_fact('CUST-002', 'Annual contract renewal in March', 'schedule') FROM DUAL;
    </copy>
    ```

3. Retrieve facts.

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

## Task 4: Decisions and Outcomes (Audit Trail)

Decisions and outcomes record what the agent decided and what happened.

1. Create functions for decisions and outcomes.

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

    ```sql
    <copy>
    -- Record past decisions and their outcomes
    SELECT record_decision(
        'CUST-001',
        'Premium customer complained about shipping delay',
        'Offered expedited shipping at no cost',
        'Customer satisfied, relationship preserved',
        'true'
    ) FROM DUAL;

    SELECT record_decision(
        'CUST-002',
        'Standard customer requested refund after 45 days',
        'Explained 30-day policy but offered store credit',
        'Customer accepted store credit, positive resolution',
        'true'
    ) FROM DUAL;

    SELECT record_decision(
        'CUST-003',
        'Customer upset about billing error',
        'Explained company policy without offering resolution',
        'Customer cancelled account and posted negative review',
        'false'
    ) FROM DUAL;
    </copy>
    ```

3. Search for relevant past decisions.

    ```sql
    <copy>
    -- Set display width for CLOB output
    SET LONG 5000
    SET LINESIZE 200

    -- Find decisions about shipping issues
    SELECT find_past_decisions('shipping') as shipping_decisions FROM DUAL;

    -- Find decisions about billing
    SELECT find_past_decisions('billing') as billing_decisions FROM DUAL;
    </copy>
    ```

## Task 5: Reference Knowledge (Policies and Procedures)

Reference knowledge is background information the agent consults but does not change.

1. Create functions for reference knowledge.

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

    ```sql
    <copy>
    -- Add policies
    SELECT add_reference('policy', 'Return Policy - Premium', 
        'Premium members may return items within 90 days for full refund, no questions asked. ' ||
        'Standard restocking fees are waived. Free return shipping included.') FROM DUAL;
        
    SELECT add_reference('policy', 'Return Policy - Standard',
        'Standard members may return items within 30 days. A 15% restocking fee applies. ' ||
        'Customer pays return shipping.') FROM DUAL;
        
    SELECT add_reference('procedure', 'Escalation Process',
        'Billing disputes: 1) Agent attempts resolution, 2) If over $100, escalate to Team Lead, ' ||
        '3) If unresolved after 24 hours, escalate to Manager, 4) Customer may request VP review.') FROM DUAL;
        
    SELECT add_reference('guideline', 'Tone and Communication',
        'Always be empathetic and solution-focused. Acknowledge customer frustration before ' ||
        'explaining policy. Offer alternatives when saying no.') FROM DUAL;
    </copy>
    ```

3. Query reference knowledge.

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

## Task 6: A Complete Example

Let's trace how an agent would use all four types together.

```sql
<copy>
-- Set display width for CLOB output
SET LONG 5000
SET LINESIZE 200

-- Scenario: Customer CUST-001 calls about a late shipment

-- 1. Set short-term context (current task)
SELECT set_context('SESSION-002', 'customer', 'CUST-001 calling about late shipment') as step1_context FROM DUAL;
SELECT set_context('SESSION-002', 'issue', 'Order ORD-789 delayed 3 days') as step1_issue FROM DUAL;

-- 2. Check long-term facts (what do we know about them?)
SELECT get_facts('CUST-001') as step2_facts FROM DUAL;

-- 3. Check reference knowledge (what is the policy?)
SELECT get_reference('policy', 'return') as step3_policy FROM DUAL;

-- 4. Find similar past decisions (what worked before?)
SELECT find_past_decisions('shipping delay') as step4_past_decisions FROM DUAL;

-- 5. Agent makes decision based on all of this, then records it
SELECT record_decision(
    'CUST-001',
    'Premium customer CUST-001 reported 3-day shipping delay on ORD-789',
    'Offered expedited replacement shipping and $25 credit for inconvenience',
    'Customer satisfied, appreciated proactive resolution',
    'true'
) as step5_decision FROM DUAL;

-- 6. Learn new fact if relevant
SELECT store_fact('CUST-001', 'Sensitive to shipping delays - prioritize expedited options', 'preference') as step6_new_fact FROM DUAL;
</copy>
```

## Summary

In this lab, you built the four types of agent memory:

* **Short-term context** — Current task inputs (expires with task)
* **Long-term facts** — Stable entity knowledge (persists forever)
* **Decisions and outcomes** — Audit trail (persists forever)
* **Reference knowledge** — Policies and procedures (human-maintained)

Together, these memories make agents consistent, contextual, and explainable.

## Learn More

* [Oracle JSON Developer's Guide](https://docs.oracle.com/en/database/oracle/oracle-database/26/adjsn/)
* [DBMS_CLOUD_AI_AGENT Package](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/dbms-cloud-ai-agent-package.html)

## Acknowledgements

* **Author** - David Start
* **Last Updated By/Date** - David Start, January 2026

## Cleanup (Optional)

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
