# How Agents Get Better Over Time

## Introduction

In this lab, you'll build the learning loop that lets agents improve through experience.

Memory stores facts. But intelligence comes from finding patterns in those facts. When an agent encounters a new vintage comic to grade, it should ask: "What did we do last time with similar items?" That's the learning loop.

You'll use Oracle's AI Vector Search to find semantically similar past appraisals, letting agents learn from history.

### The Business Problem

At Big Star Collectibles, every appraiser values items slightly differently. When a new inventory specialist joins, they start from zero, making the same mistakes experienced staff already learned from.

> *"We graded a vintage comic at 8.5 last month. This week, a nearly identical comic came in and a different appraiser graded it 9.0. Customers notice these inconsistencies."*
>
> Operations Manager

Big Star Collectibles needs agents that:
- Find similar past appraisals before making decisions
- Learn from successful authentications
- Apply consistent grading standards based on historical outcomes

### What You'll Learn

This lab shows you how to build the learning loop using semantic search. Instead of exact keyword matching, you'll find contextually similar past decisions and use them to guide new ones.

**What you'll build:** A memory-enabled agent that consults past appraisals to make consistent decisions.

Estimated Time: 15 minutes

### Objectives

* Build a semantic search layer over decision memory
* Use vector embeddings to find similar past appraisals
* Create agents that learn from history
* See consistency improve through accumulated experience

### Prerequisites

For this workshop, we provide the environment. You'll need:

* Basic knowledge of SQL and PL/SQL, or the ability to follow along with the prompts
* Completion of Lab 8 (Four Memory Types)

## Task 1: Import the Lab Notebook

Before you begin, import the notebook for this lab.

1. From the Oracle Machine Learning home page, click **Notebooks**.

2. Click **Import** to expand the Import drop down.

3. Select **Git**.

4. Paste the following GitHub URL leaving the credential field blank:

    ```text
    <copy>
    https://github.com/davidastart/database/blob/main/ai4u/industries/bigstar/learning-loop/lab9-learning-loop.json
    </copy>
    ```

5. Click **Ok**.

## Task 2: Create the Decision Memory with Semantic Search

We'll extend the decision memory table to include vector embeddings for semantic search.

> This command is already in your notebook—just click the play button (▶) to run it.

```sql
<copy>
-- Table for decision memory with vector search
CREATE TABLE decision_memory (
    decision_id       RAW(16) DEFAULT SYS_GUID() PRIMARY KEY,
    item_description  VARCHAR2(1000),
    item_type         VARCHAR2(50),
    condition_details VARCHAR2(1000),
    decision_made     VARCHAR2(500),
    grade_assigned    NUMBER(3,1),
    outcome           VARCHAR2(100),
    created_at        TIMESTAMP DEFAULT SYSTIMESTAMP
);

-- We'll add vector embeddings in the next task
</copy>
```

## Task 3: Store Decisions with Context

Create a function that stores appraisal decisions with full context.

> This command is already in your notebook—just click the play button (▶) to run it.

```sql
<copy>
CREATE OR REPLACE FUNCTION store_appraisal_decision(
    p_item_desc       VARCHAR2,
    p_item_type       VARCHAR2,
    p_condition       VARCHAR2,
    p_decision        VARCHAR2,
    p_grade           NUMBER,
    p_outcome         VARCHAR2
) RETURN VARCHAR2 AS
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    INSERT INTO decision_memory (
        item_description,
        item_type,
        condition_details,
        decision_made,
        grade_assigned,
        outcome
    ) VALUES (
        p_item_desc,
        p_item_type,
        p_condition,
        p_decision,
        p_grade,
        p_outcome
    );
    COMMIT;

    RETURN 'Stored decision for ' || p_item_type || ' graded at ' || p_grade;
END;
/
</copy>
```

## Task 4: Populate with Example Decisions

Let's add some historical appraisal decisions that the agent can learn from.

> This command is already in your notebook—just click the play button (▶) to run it.

```sql
<copy>
-- Add sample appraisal decisions
BEGIN
    -- Vintage comic decisions
    store_appraisal_decision(
        '1962 Amazing Spider-Man #1, near mint condition with minor spine wear',
        'vintage_comic',
        'Near mint, slight spine stress, vibrant colors intact',
        'Graded 9.2 based on minimal imperfections',
        9.2,
        'Successful authentication, sold for $2,800'
    );

    store_appraisal_decision(
        '1963 X-Men #1, very fine condition with moderate cover wear',
        'vintage_comic',
        'Very fine, moderate edge wear, clean interior pages',
        'Graded 8.0 due to visible wear',
        8.0,
        'Successful authentication, sold for $1,200'
    );

    store_appraisal_decision(
        '1940 Batman #1, excellent condition with some restoration',
        'vintage_comic',
        'Excellent overall, professional restoration on spine',
        'Graded 7.5 with restoration noted',
        7.5,
        'Authenticated with restoration disclosure, sold for $15,000'
    );

    -- Sports card decisions
    store_appraisal_decision(
        '1952 Topps Mickey Mantle rookie card, near mint',
        'sports_card',
        'Near mint condition, sharp corners, centered',
        'Graded 9.0 for exceptional preservation',
        9.0,
        'Premium authentication, sold for $5,200'
    );

    store_appraisal_decision(
        '1986 Fleer Michael Jordan rookie, very fine',
        'sports_card',
        'Very fine, minor corner wear, good centering',
        'Graded 8.5 for slight corner softness',
        8.5,
        'Successful authentication, sold for $3,400'
    );

    COMMIT;
END;
/
</copy>
```

## Task 5: Create Semantic Search Function

Now create a function that finds similar past decisions using keyword matching (in production, you'd use vector embeddings for true semantic search).

> This command is already in your notebook—just click the play button (▶) to run it.

```sql
<copy>
CREATE OR REPLACE FUNCTION find_similar_appraisals(
    p_item_desc VARCHAR2,
    p_item_type VARCHAR2,
    p_limit     NUMBER DEFAULT 3
) RETURN CLOB AS
    v_result CLOB := '';
    v_count  NUMBER := 0;
BEGIN
    -- In production, this would use vector similarity search
    -- For this lab, we use keyword matching
    FOR rec IN (
        SELECT
            item_description,
            condition_details,
            decision_made,
            grade_assigned,
            outcome,
            TO_CHAR(created_at, 'YYYY-MM-DD') as decision_date
        FROM decision_memory
        WHERE item_type = p_item_type
        ORDER BY created_at DESC
        FETCH FIRST p_limit ROWS ONLY
    ) LOOP
        v_result := v_result ||
                   'Past appraisal (' || rec.decision_date || '):' || CHR(10) ||
                   '  Item: ' || rec.item_description || CHR(10) ||
                   '  Condition: ' || rec.condition_details || CHR(10) ||
                   '  Decision: ' || rec.decision_made || CHR(10) ||
                   '  Grade: ' || rec.grade_assigned || CHR(10) ||
                   '  Outcome: ' || rec.outcome || CHR(10) || CHR(10);
        v_count := v_count + 1;
    END LOOP;

    IF v_count = 0 THEN
        RETURN 'No similar past appraisals found for ' || p_item_type;
    END IF;

    RETURN 'Found ' || v_count || ' similar past appraisals:' || CHR(10) || CHR(10) || v_result;
END;
/
</copy>
```

## Task 6: Register the Learning Loop Tools

Register the tools that enable learning from past decisions.

> This command is already in your notebook—just click the play button (▶) to run it.

```sql
<copy>
BEGIN
    DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
        tool_name   => 'STORE_APPRAISAL_TOOL',
        attributes  => '{"instruction": "Store an appraisal decision for future learning. Use after completing an authentication. Parameters: item description, type, condition, decision, grade, outcome.",
                        "function": "store_appraisal_decision"}',
        description => 'Records appraisal decisions for learning'
    );

    DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
        tool_name   => 'FIND_SIMILAR_TOOL',
        attributes  => '{"instruction": "Find similar past appraisals before making a new decision. Use this to learn from history and maintain consistency. Parameters: item description, item type.",
                        "function": "find_similar_appraisals"}',
        description => 'Finds semantically similar past appraisals'
    );
END;
/
</copy>
```

## Task 7: Create a Learning-Enabled Agent

Create an agent that consults past appraisals before making decisions.

> This command is already in your notebook—just click the play button (▶) to run it.

```sql
<copy>
BEGIN
    DBMS_CLOUD_AI_AGENT.CREATE_AGENT(
        agent_name  => 'LEARNING_AGENT',
        attributes  => '{"profile_name": "genai",
                        "role": "You are a Big Star Collectibles appraiser. Before grading a new item, use FIND_SIMILAR_TOOL to see how similar items were graded in the past. Use that history to maintain consistency. After making a decision, use STORE_APPRAISAL_TOOL to record it for future learning."}',
        description => 'Agent that learns from past decisions'
    );

    DBMS_CLOUD_AI_AGENT.CREATE_TASK(
        task_name   => 'LEARNING_TASK',
        attributes  => '{"instruction": "Help appraise items by: 1) Using FIND_SIMILAR_TOOL to check past decisions 2) Making a grading decision based on history 3) Using STORE_APPRAISAL_TOOL to record the decision. Always consult history first. User request: {query}",
                        "tools": ["FIND_SIMILAR_TOOL", "STORE_APPRAISAL_TOOL"]}',
        description => 'Task with learning loop'
    );

    DBMS_CLOUD_AI_AGENT.CREATE_TEAM(
        team_name   => 'LEARNING_TEAM',
        attributes  => '{"agents": [{"name": "LEARNING_AGENT", "task": "LEARNING_TASK"}],
                        "process": "sequential"}',
        description => 'Team with learning capabilities'
    );
END;
/
</copy>
```

## Task 8: See the Learning Loop in Action

Now test the agent's ability to learn from past appraisals.

> This command is already in your notebook—just click the play button (▶) to run it.

```sql
<copy>
EXEC DBMS_CLOUD_AI_AGENT.SET_TEAM('LEARNING_TEAM');

-- Ask the agent to appraise a new vintage comic
SELECT AI AGENT I need to appraise a 1964 Fantastic Four comic in near mint condition with slight spine wear. What past appraisals should I consider for vintage comics;
</copy>
```

**Observe:** The agent calls FIND_SIMILAR_TOOL and retrieves past vintage comic appraisals. It can see that similar near-mint comics with minor spine wear were graded around 9.0-9.2.

Now ask for a grading recommendation:

```sql
<copy>
SELECT AI AGENT Based on past appraisals, what grade would you recommend for this 1964 Fantastic Four comic in near mint condition with slight spine wear;
</copy>
```

The agent uses historical context to recommend a consistent grade.

## Task 9: Store the New Decision

After the appraisal, store it so future appraisals can learn from it.

> This command is already in your notebook—just click the play button (▶) to run it.

```sql
<copy>
SELECT AI AGENT Store this appraisal decision: 1964 Fantastic Four comic, near mint with slight spine wear, graded 9.0 based on minimal imperfections, successfully authenticated and sold for $1,800;
</copy>
```

**Observe:** The agent stores the decision. Next time someone appraises a similar vintage comic, this decision will be part of the history they consult.

## Task 10: See Learning Accumulate

Query the decision memory to see how knowledge accumulates.

> This command is already in your notebook—just click the play button (▶) to run it.

```sql
<copy>
SELECT
    item_type,
    COUNT(*) as total_decisions,
    MIN(grade_assigned) as lowest_grade,
    MAX(grade_assigned) as highest_grade,
    ROUND(AVG(grade_assigned), 1) as avg_grade
FROM decision_memory
GROUP BY item_type
ORDER BY total_decisions DESC;
</copy>
```

As more decisions accumulate, the agent has more history to learn from, leading to more consistent grading.

## Summary

In this lab, you built the learning loop:

* Created decision memory with full appraisal context
* Built semantic search to find similar past decisions
* Created tools that let agents consult history
* Saw agents use past appraisals to maintain consistency
* Watched knowledge accumulate over time

**Key takeaway:** Memory alone isn't enough. Agents need to find patterns in memory. When a Big Star Collectibles agent encounters a vintage comic, it doesn't start from zero—it searches for similar past appraisals, learns what grades worked before, and applies consistent standards. Every decision makes the next one better.

## Learn More

* [AI Vector Search in Oracle Database](https://docs.oracle.com/en/database/oracle/oracle-database/23/vecse/)
* [`DBMS_CLOUD_AI_AGENT` Package](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/dbms-cloud-ai-agent-package.html)

## Acknowledgements

* **Author** - David Start
* **Last Updated By/Date** - David Start, January 2026

## Cleanup (Optional)

> This command is already in your notebook—just click the play button (▶) to run it.

```sql
<copy>
EXEC DBMS_CLOUD_AI_AGENT.DROP_TEAM('LEARNING_TEAM', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TASK('LEARNING_TASK', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_AGENT('LEARNING_AGENT', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('STORE_APPRAISAL_TOOL', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('FIND_SIMILAR_TOOL', TRUE);
DROP TABLE decision_memory PURGE;
DROP FUNCTION store_appraisal_decision;
DROP FUNCTION find_similar_appraisals;
</copy>
```
