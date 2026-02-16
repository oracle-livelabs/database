# The Four Types of Agent Memory

## Introduction

In this lab, you'll implement all four types of agent memory that production systems need.

In Lab 7, you built basic memory with `remember_fact` and `recall_facts`. That works for simple facts. But real agents need four distinct memory types, each serving a different purpose in the workflow.

### The Business Problem

At Big Star Collectibles, agents need to juggle multiple types of information:

- **What am I working on RIGHT NOW?** (Current item submission being processed)
- **What do I know about THIS CUSTOMER?** (Alex Martinez's 20% discount and email preference)
- **What did we DECIDE BEFORE?** (How we graded similar vintage comics last month)
- **What are the OFFICIAL RULES?** (Corporate grading standards and pricing policies)

Without structured memory types, this information gets mixed together or lost. The agent can't distinguish between temporary context and permanent knowledge.

### What You'll Learn

This lab shows you how to build all four memory types:

1. **Short-Term Context Memory**: Session state that clears when the task completes
2. **Long-Term Facts Memory**: Customer preferences that persist forever
3. **Decisions and Outcomes Memory**: Past appraisals and their results
4. **Reference Knowledge Memory**: Corporate policies (human-maintained)

**What you'll build:** A complete memory architecture for Big Star Collectibles agents.

Estimated Time: 15 minutes

### Objectives

* Understand the four distinct memory types
* Build memory tables for each type
* Create functions that maintain memory boundaries
* See how each memory type serves different purposes

### Prerequisites

For this workshop, we provide the environment. You'll need:

* Basic knowledge of SQL and PL/SQL, or the ability to follow along with the prompts
* Completion of Lab 7 (Where Memory Lives)

## Task 1: Import the Lab Notebook

Before you begin, you are going to import a notebook that has all of the commands for this lab into Oracle Machine Learning.

1. From the Oracle Machine Learning home page, click **Notebooks**.

2. Click **Import** to expand the Import drop down.

3. Select **Git**.

4. Paste the following GitHub URL leaving the credential field blank:

    ```text
    <copy>
    https://github.com/davidastart/database/blob/main/ai4u/industries/bigstar/four-memory-types/lab8-four-memory-types.json
    </copy>
    ```

5. Click **Ok**.

## Task 2: Understand the Four Memory Types

Before building them, let's understand what each memory type does:

| Memory Type | Purpose | Lifespan | Example |
|-------------|---------|----------|---------|
| **Short-Term Context** | Track current work session | Cleared after task completes | "Currently processing item ITEM-12345" |
| **Long-Term Facts** | Customer preferences and history | Persists forever | "Alex Martinez prefers email, has 20% discount" |
| **Decisions & Outcomes** | Past actions and results | Persists forever, used for learning | "Graded vintage comic at 9.2 based on near-mint condition" |
| **Reference Knowledge** | Official policies and standards | Maintained by humans, updated periodically | "Platinum tier: 20% discount on all purchases" |

## Task 3: Create Memory Type 1 - Short-Term Context

Short-term context tracks what the agent is currently working on. It clears when the task completes.

> This command is already in your notebook—just click the play button (▶) to run it.

```sql
<copy>
-- Table for short-term context
CREATE TABLE session_context (
    session_id    VARCHAR2(100) PRIMARY KEY,
    context_data  JSON NOT NULL,
    created_at    TIMESTAMP DEFAULT SYSTIMESTAMP,
    expires_at    TIMESTAMP
);

-- Function to set current context
CREATE OR REPLACE FUNCTION set_context(
    p_session_id VARCHAR2,
    p_context    VARCHAR2
) RETURN VARCHAR2 AS
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    MERGE INTO session_context sc
    USING DUAL ON (sc.session_id = p_session_id)
    WHEN MATCHED THEN
        UPDATE SET context_data = JSON_OBJECT('context' VALUE p_context, 'updated' VALUE SYSTIMESTAMP)
    WHEN NOT MATCHED THEN
        INSERT (session_id, context_data, expires_at)
        VALUES (p_session_id, JSON_OBJECT('context' VALUE p_context), SYSTIMESTAMP + INTERVAL '1' HOUR);
    COMMIT;
    RETURN 'Context set: ' || p_context;
END;
/

-- Function to get current context
CREATE OR REPLACE FUNCTION get_context(p_session_id VARCHAR2) RETURN VARCHAR2 AS
    v_context VARCHAR2(1000);
BEGIN
    SELECT JSON_VALUE(context_data, '$.context')
    INTO v_context
    FROM session_context
    WHERE session_id = p_session_id
    AND expires_at > SYSTIMESTAMP;
    RETURN v_context;
EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN 'No active context';
END;
/
</copy>
```

## Task 4: Create Memory Type 2 - Long-Term Facts

Long-term facts are customer preferences, loyalty discounts, and relationship history. These persist forever.

> This command is already in your notebook—just click the play button (▶) to run it.

```sql
<copy>
-- Table for long-term facts (built in Lab 7, extended here)
CREATE TABLE customer_facts (
    fact_id       RAW(16) DEFAULT SYS_GUID() PRIMARY KEY,
    customer_name VARCHAR2(100),
    fact_type     VARCHAR2(50),
    fact_data     JSON NOT NULL,
    created_at    TIMESTAMP DEFAULT SYSTIMESTAMP
);

CREATE INDEX idx_customer_facts ON customer_facts(customer_name, fact_type);

-- Function to store customer facts
CREATE OR REPLACE FUNCTION store_customer_fact(
    p_customer    VARCHAR2,
    p_fact_type   VARCHAR2,
    p_fact_value  VARCHAR2
) RETURN VARCHAR2 AS
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    INSERT INTO customer_facts (customer_name, fact_type, fact_data)
    VALUES (
        p_customer,
        p_fact_type,
        JSON_OBJECT(
            'value' VALUE p_fact_value,
            'stored_at' VALUE TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS')
        )
    );
    COMMIT;
    RETURN 'Stored ' || p_fact_type || ' for ' || p_customer;
END;
/

-- Function to retrieve customer facts
CREATE OR REPLACE FUNCTION get_customer_facts(
    p_customer   VARCHAR2,
    p_fact_type  VARCHAR2 DEFAULT NULL
) RETURN CLOB AS
    v_result CLOB := '';
    v_count  NUMBER := 0;
BEGIN
    FOR rec IN (
        SELECT fact_type, JSON_VALUE(fact_data, '$.value') as fact_value
        FROM customer_facts
        WHERE UPPER(customer_name) = UPPER(p_customer)
        AND (p_fact_type IS NULL OR fact_type = p_fact_type)
        ORDER BY created_at DESC
    ) LOOP
        v_result := v_result || rec.fact_type || ': ' || rec.fact_value || CHR(10);
        v_count := v_count + 1;
    END LOOP;

    IF v_count = 0 THEN RETURN 'No facts found for ' || p_customer; END IF;
    RETURN v_result;
END;
/
</copy>
```

## Task 5: Create Memory Type 3 - Decisions and Outcomes

Decisions memory stores past appraisals, authentication outcomes, and their rationale. This helps agents learn from history.

> This command is already in your notebook—just click the play button (▶) to run it.

```sql
<copy>
-- Table for decisions and outcomes
CREATE TABLE appraisal_decisions (
    decision_id      RAW(16) DEFAULT SYS_GUID() PRIMARY KEY,
    item_type        VARCHAR2(50),
    decision_type    VARCHAR2(50),
    decision_data    JSON NOT NULL,
    outcome          VARCHAR2(100),
    created_at       TIMESTAMP DEFAULT SYSTIMESTAMP
);

CREATE INDEX idx_decisions_type ON appraisal_decisions(item_type, decision_type);

-- Function to store a decision
CREATE OR REPLACE FUNCTION store_decision(
    p_item_type    VARCHAR2,
    p_decision     VARCHAR2,
    p_rationale    VARCHAR2,
    p_outcome      VARCHAR2
) RETURN VARCHAR2 AS
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    INSERT INTO appraisal_decisions (item_type, decision_type, decision_data, outcome)
    VALUES (
        p_item_type,
        'APPRAISAL',
        JSON_OBJECT(
            'decision' VALUE p_decision,
            'rationale' VALUE p_rationale,
            'timestamp' VALUE SYSTIMESTAMP
        ),
        p_outcome
    );
    COMMIT;
    RETURN 'Stored decision: ' || p_decision;
END;
/

-- Function to find similar past decisions
CREATE OR REPLACE FUNCTION find_similar_decisions(
    p_item_type  VARCHAR2,
    p_limit      NUMBER DEFAULT 5
) RETURN CLOB AS
    v_result CLOB := '';
    v_count  NUMBER := 0;
BEGIN
    FOR rec IN (
        SELECT
            JSON_VALUE(decision_data, '$.decision') as decision,
            JSON_VALUE(decision_data, '$.rationale') as rationale,
            outcome
        FROM appraisal_decisions
        WHERE item_type = p_item_type
        ORDER BY created_at DESC
        FETCH FIRST p_limit ROWS ONLY
    ) LOOP
        v_result := v_result || 'Decision: ' || rec.decision ||
                   ', Rationale: ' || rec.rationale ||
                   ', Outcome: ' || rec.outcome || CHR(10);
        v_count := v_count + 1;
    END LOOP;

    IF v_count = 0 THEN
        RETURN 'No past decisions found for ' || p_item_type;
    END IF;

    RETURN 'Found ' || v_count || ' similar decisions:' || CHR(10) || v_result;
END;
/
</copy>
```

## Task 6: Create Memory Type 4 - Reference Knowledge

Reference knowledge is corporate policies, grading standards, and pricing guides. Maintained by humans, not agents.

> This command is already in your notebook—just click the play button (▶) to run it.

```sql
<copy>
-- Table for reference knowledge
CREATE TABLE reference_knowledge (
    knowledge_id  RAW(16) DEFAULT SYS_GUID() PRIMARY KEY,
    category      VARCHAR2(50),
    topic         VARCHAR2(100),
    content       CLOB,
    last_updated  TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_by    VARCHAR2(100)
);

CREATE INDEX idx_knowledge_category ON reference_knowledge(category);

-- Insert sample grading standards
INSERT INTO reference_knowledge (category, topic, content, updated_by)
VALUES (
    'GRADING_STANDARDS',
    'Vintage Comics',
    'Vintage comics must meet these standards: Grade 9.0+ for Near Mint (minor imperfections). Grade 7.0-8.9 for Very Fine (moderate wear). Grade 5.0-6.9 for Fine (visible wear). Minimum grade 5.0 required for authentication.',
    'Policy Committee'
);

INSERT INTO reference_knowledge (category, topic, content, updated_by)
VALUES (
    'PRICING_TIERS',
    'Loyalty Discounts',
    'Platinum tier: 20% discount (750+ loyalty points or 5+ years). Gold tier: 10% discount (500-749 points). Silver tier: 5% discount (250-499 points). Standard: No discount (under 250 points).',
    'Finance Department'
);

COMMIT;

-- Function to look up reference knowledge
CREATE OR REPLACE FUNCTION lookup_knowledge(
    p_category VARCHAR2,
    p_topic    VARCHAR2 DEFAULT NULL
) RETURN CLOB AS
    v_result CLOB := '';
    v_count  NUMBER := 0;
BEGIN
    FOR rec IN (
        SELECT topic, content, TO_CHAR(last_updated, 'YYYY-MM-DD') as updated
        FROM reference_knowledge
        WHERE category = p_category
        AND (p_topic IS NULL OR UPPER(topic) LIKE '%' || UPPER(p_topic) || '%')
        ORDER BY last_updated DESC
    ) LOOP
        v_result := v_result || rec.topic || ' (updated: ' || rec.updated || '):' || CHR(10) ||
                   rec.content || CHR(10) || CHR(10);
        v_count := v_count + 1;
    END LOOP;

    IF v_count = 0 THEN
        RETURN 'No knowledge found for category: ' || p_category;
    END IF;

    RETURN v_result;
END;
/
</copy>
```

## Task 7: Register All Memory Tools

Now register all the memory functions as tools the agent can use.

> This command is already in your notebook—just click the play button (▶) to run it.

```sql
<copy>
BEGIN
    -- Short-term context tools
    DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
        tool_name   => 'SET_CONTEXT_TOOL',
        attributes  => '{"instruction": "Set current working context. Use when starting to work on a specific item.",
                        "function": "set_context"}',
        description => 'Sets short-term session context'
    );

    DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
        tool_name   => 'GET_CONTEXT_TOOL',
        attributes  => '{"instruction": "Get current working context.",
                        "function": "get_context"}',
        description => 'Retrieves current session context'
    );

    -- Long-term customer fact tools
    DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
        tool_name   => 'STORE_FACT_TOOL',
        attributes  => '{"instruction": "Store long-term customer facts like preferences, loyalty discounts, contact methods.",
                        "function": "store_customer_fact"}',
        description => 'Stores customer facts permanently'
    );

    DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
        tool_name   => 'GET_FACTS_TOOL',
        attributes  => '{"instruction": "Retrieve stored facts about a customer.",
                        "function": "get_customer_facts"}',
        description => 'Gets customer facts from long-term memory'
    );

    -- Decision memory tools
    DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
        tool_name   => 'STORE_DECISION_TOOL',
        attributes  => '{"instruction": "Store an appraisal decision for future learning.",
                        "function": "store_decision"}',
        description => 'Records decisions and outcomes'
    );

    DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
        tool_name   => 'FIND_DECISIONS_TOOL',
        attributes  => '{"instruction": "Find past decisions for similar items to learn from history.",
                        "function": "find_similar_decisions"}',
        description => 'Finds similar past decisions'
    );

    -- Reference knowledge tool
    DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
        tool_name   => 'LOOKUP_POLICY_TOOL',
        attributes  => '{"instruction": "Look up official grading standards, pricing policies, or corporate guidelines.",
                        "function": "lookup_knowledge"}',
        description => 'Retrieves reference knowledge and policies'
    );
END;
/
</copy>
```

## Task 8: Test All Four Memory Types

Create an agent that uses all memory types and see them in action.

> This command is already in your notebook—just click the play button (▶) to run it.

```sql
<copy>
BEGIN
    DBMS_CLOUD_AI_AGENT.CREATE_AGENT(
        agent_name  => 'FULL_MEMORY_AGENT',
        attributes  => '{"profile_name": "genai",
                        "role": "You are a Big Star Collectibles agent with full memory capabilities. Use short-term context for current work, long-term facts for customer history, decision memory to learn from past appraisals, and reference knowledge for official policies."}',
        description => 'Agent with all four memory types'
    );

    DBMS_CLOUD_AI_AGENT.CREATE_TASK(
        task_name   => 'FULL_MEMORY_TASK',
        attributes  => '{"instruction": "Use all memory types appropriately: SET_CONTEXT_TOOL for current work, STORE_FACT_TOOL/GET_FACTS_TOOL for customer info, STORE_DECISION_TOOL/FIND_DECISIONS_TOOL for learning, LOOKUP_POLICY_TOOL for official rules. User request: {query}",
                        "tools": ["SET_CONTEXT_TOOL", "GET_CONTEXT_TOOL", "STORE_FACT_TOOL", "GET_FACTS_TOOL", "STORE_DECISION_TOOL", "FIND_DECISIONS_TOOL", "LOOKUP_POLICY_TOOL"]}',
        description => 'Task using all memory types'
    );

    DBMS_CLOUD_AI_AGENT.CREATE_TEAM(
        team_name   => 'FULL_MEMORY_TEAM',
        attributes  => '{"agents": [{"name": "FULL_MEMORY_AGENT", "task": "FULL_MEMORY_TASK"}],
                        "process": "sequential"}',
        description => 'Team with complete memory architecture'
    );
END;
/

EXEC DBMS_CLOUD_AI_AGENT.SET_TEAM('FULL_MEMORY_TEAM');
</copy>
```

Now test each memory type:

```sql
<copy>
-- Test 1: Short-term context
SELECT AI AGENT Set context that I'm currently working on item ITEM-67890;
SELECT AI AGENT What am I currently working on;

-- Test 2: Long-term facts
SELECT AI AGENT Store the fact that Alex Martinez prefers email contact;
SELECT AI AGENT What facts do we have about Alex Martinez;

-- Test 3: Decision memory
SELECT AI AGENT Store a decision that we graded a vintage comic at 9.2 based on near-mint condition and outcome was successful sale;
SELECT AI AGENT What past decisions do we have for vintage comics;

-- Test 4: Reference knowledge
SELECT AI AGENT Look up the official grading standards for vintage comics;
SELECT AI AGENT Look up the pricing tier policies;
</copy>
```

## Summary

In this lab, you built a complete memory architecture with all four types:

* **Short-Term Context**: Session state that tracks current work
* **Long-Term Facts**: Customer preferences and history that persist forever
* **Decisions & Outcomes**: Past appraisals used for learning
* **Reference Knowledge**: Official policies maintained by humans

**Key takeaway:** Not all memory is the same. Short-term context clears when work completes. Long-term facts persist forever. Decisions accumulate for learning. Reference knowledge comes from corporate policy. For Big Star Collectibles, this means agents know what they're working on NOW, what they know about customers FOREVER, what worked BEFORE, and what the company REQUIRES.

## Learn More

* [`DBMS_CLOUD_AI_AGENT` Package](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/dbms-cloud-ai-agent-package.html)

## Acknowledgements

* **Author** - David Start
* **Last Updated By/Date** - David Start, January 2026

## Cleanup (Optional)

> This command is already in your notebook—just click the play button (▶) to run it.

```sql
<copy>
EXEC DBMS_CLOUD_AI_AGENT.DROP_TEAM('FULL_MEMORY_TEAM', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TASK('FULL_MEMORY_TASK', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_AGENT('FULL_MEMORY_AGENT', TRUE);
-- Drop all memory tools
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('SET_CONTEXT_TOOL', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('GET_CONTEXT_TOOL', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('STORE_FACT_TOOL', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('GET_FACTS_TOOL', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('STORE_DECISION_TOOL', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('FIND_DECISIONS_TOOL', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('LOOKUP_POLICY_TOOL', TRUE);
-- Drop memory tables
DROP TABLE session_context PURGE;
DROP TABLE customer_facts PURGE;
DROP TABLE appraisal_decisions PURGE;
DROP TABLE reference_knowledge PURGE;
-- Drop functions
DROP FUNCTION set_context;
DROP FUNCTION get_context;
DROP FUNCTION store_customer_fact;
DROP FUNCTION get_customer_facts;
DROP FUNCTION store_decision;
DROP FUNCTION find_similar_decisions;
DROP FUNCTION lookup_knowledge;
</copy>
```
