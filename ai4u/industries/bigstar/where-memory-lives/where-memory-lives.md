# Where Agent Memory Should Live

## Introduction

In this lab, you'll build a **memory core**, the converged database foundation that gives AI agents **agentic memory**.

### The Business Problem

In Lab 5, you experienced the forgetting problem firsthand. Alex Martinez had to explain their preferences and loyalty discount to three different inventory specialists. The AI assistant forgot everything the moment each session ended.

This isn't just frustrating. It's costing Big Star Collectibles business. Customers feel unvalued. Inventory specialists waste time re-gathering information. And compliance can't track what was communicated.

> *"Every conversation starts from zero. I told your AI about my preferences last week. Today it has no idea who I am."*
>
> Alex Martinez, Big Star Collectibles VIP

### What You'll Learn

In this lab, you'll solve the forgetting problem by building a **memory core**, the database foundation that gives agents persistent memory:

1. **Create memory tables** using Oracle's native JSON for flexible storage
2. **Build remember/recall functions** that agents call as tools
3. **Register the tools** so the agent can store and retrieve facts
4. **Test across sessions** to prove memory persists

The key insight: Memory isn't a model capability. It's a database capability. The LLM provides intelligence; your database provides memory. Together, they create agents that actually remember.

**What you'll build:** A persistent memory system where agents store and recall customer information across sessions.

Estimated Time: 15 minutes

### Objectives

* Build a memory core using Oracle's native JSON type
* Create PL/SQL functions as agent tools for memory
* Register tools with the agent framework
* Have conversations with an agent that has true agentic memory

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
    https://github.com/davidastart/database/blob/main/ai4u/industries/bigstar/where-memory-lives/lab7-where-memory-lives.json
    </copy>
    ```

5. Click **Ok**.

You should now be on the screen with the notebook imported. This workshop will have all of the screenshots and detailed information however the notebook will have the commands and basic instructions for completing the lab.

## Task 2: Create the Memory Core Table

The memory table is the foundation, where the agent stores everything it learns. We use JSON for the content because memories can have different shapes: some might be simple facts, others might be preferences with multiple attributes.

1. Create the memory core table.

    This table stores all agent memories. Each memory has a type (like FACT), JSON content (the actual information), and a timestamp. The JSON format gives us flexibility, we can store any kind of structured information.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    CREATE TABLE agent_memory (
        memory_id      RAW(16) DEFAULT SYS_GUID() PRIMARY KEY,
        agent_id       VARCHAR2(100) DEFAULT 'DEFAULT_AGENT',
        memory_type    VARCHAR2(20) DEFAULT 'FACT',
        content        JSON NOT NULL,
        created_at     TIMESTAMP DEFAULT SYSTIMESTAMP
    );
    </copy>
    ```

2. Create indexes for efficient JSON queries.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    CREATE INDEX idx_memory_about ON agent_memory m (m.content.about.string());
    CREATE INDEX idx_memory_type ON agent_memory(memory_type);
    </copy>
    ```

## Task 3: Create the Remember Function

This function becomes the agent's "save to memory" capability. When someone tells the agent something important, the agent calls this function to store it permanently.

1. Create the function to store facts.

    The function takes a fact (the information), an optional category (like "preference" or "contact"), and an optional "about" field (who or what this fact relates to). It stores everything as JSON and returns a confirmation.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    CREATE OR REPLACE FUNCTION remember_fact(
        p_fact     VARCHAR2,
        p_category VARCHAR2 DEFAULT 'general',
        p_about    VARCHAR2 DEFAULT NULL
    ) RETURN VARCHAR2 AS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        INSERT INTO agent_memory (memory_type, content)
        VALUES (
            'FACT',
            JSON_OBJECT(
                'fact'       VALUE p_fact,
                'category'   VALUE p_category,
                'about'      VALUE p_about,
                'source'     VALUE 'conversation',
                'remembered' VALUE TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS')
            )
        );
        COMMIT;

        RETURN 'Remembered: ' || p_fact ||
               CASE WHEN p_about IS NOT NULL THEN ' (about ' || p_about || ')' ELSE '' END;
    END;
    /
    </copy>
    ```

## Task 4: Create the Recall Function

The recall function is the agent's "search memory" capability. When someone asks the agent a question, the agent can search its memory for relevant facts.

1. Create the function to retrieve facts.

    This function searches the memory table for facts that match what we're looking for. You can search by entity ("about") or by category. It returns the most recent matching facts.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    CREATE OR REPLACE FUNCTION recall_facts(
        p_about    VARCHAR2 DEFAULT NULL,
        p_category VARCHAR2 DEFAULT NULL
    ) RETURN CLOB AS
        v_result CLOB := '';
        v_count  NUMBER := 0;
    BEGIN
        FOR rec IN (
            SELECT
                m.content.fact.string() as fact,
                m.content.category.string() as category,
                m.content.about.string() as about,
                created_at
            FROM agent_memory m
            WHERE memory_type = 'FACT'
            AND (p_about IS NULL OR UPPER(m.content.about.string()) LIKE '%' || UPPER(p_about) || '%')
            AND (p_category IS NULL OR UPPER(m.content.category.string()) = UPPER(p_category))
            ORDER BY created_at DESC
            FETCH FIRST 10 ROWS ONLY
        ) LOOP
            v_result := v_result || '- ' || rec.fact;
            IF rec.about IS NOT NULL THEN
                v_result := v_result || ' (about: ' || rec.about || ')';
            END IF;
            v_result := v_result || CHR(10);
            v_count := v_count + 1;
        END LOOP;

        IF v_count = 0 THEN
            RETURN 'No facts found matching the criteria.';
        END IF;

        RETURN 'Found ' || v_count || ' facts:' || CHR(10) || v_result;
    END;
    /
    </copy>
    ```

## Task 5: Register the Agent Tools

Tools bridge your PL/SQL functions and the AI agent. By registering these functions as tools, we give the agent the ability to remember and recall information. The instructions tell the agent when to use each tool.

1. Register the "remember" tool.

    The instruction tells the agent to use this tool when users share important information. This is how the agent knows to save things.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
            tool_name   => 'REMEMBER_TOOL',
            attributes  => '{"instruction": "Store a fact in memory when users share important information. Parameters: P_FACT (the information to remember), P_CATEGORY (type: preference, contact, loyalty_discount, etc.), P_ABOUT (who/what this relates to, e.g. customer name). Use this when users say remember, note, or share preferences.",
                            "function": "remember_fact"}',
            description => 'Stores facts in agent memory for future recall'
        );
    END;
    /
    </copy>
    ```

2. Register the "recall" tool.

    The instruction tells the agent to use this tool when it needs to look up stored information about a customer or topic.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
            tool_name   => 'RECALL_TOOL',
            attributes  => '{"instruction": "Retrieve facts from memory. Parameters: P_ABOUT (customer name or topic to search for), P_CATEGORY (optional filter by type). Use this before answering questions about customers or when asked what you know about someone.",
                            "function": "recall_facts"}',
            description => 'Retrieves stored facts from agent memory'
        );
    END;
    /
    </copy>
    ```

## Task 6: Create a Memory-Enabled Agent

Now we create an agent that has access to both memory tools. This agent can remember and recall information across sessions.

> This command is already in your notebook—just click the play button (▶) to run it.

```sql
<copy>
BEGIN
    DBMS_CLOUD_AI_AGENT.CREATE_AGENT(
        agent_name  => 'MEMORY_AGENT',
        attributes  => '{"profile_name": "genai",
                        "role": "You are an inventory specialist assistant for Big Star Collectibles. When users share important information about customers (preferences, discounts, contact methods), use REMEMBER_TOOL to store it. When asked about customers, use RECALL_TOOL to check what you know before answering. Always check memory first."}',
        description => 'Agent with persistent memory capabilities'
    );
END;
/

BEGIN
    DBMS_CLOUD_AI_AGENT.CREATE_TASK(
        task_name   => 'MEMORY_TASK',
        attributes  => '{"instruction": "Help inventory specialists by remembering customer information. When users share facts, use REMEMBER_TOOL. When asked about customers, use RECALL_TOOL first to check memory. User request: {query}",
                        "tools": ["REMEMBER_TOOL", "RECALL_TOOL"]}',
        description => 'Task with memory tools'
    );
END;
/

BEGIN
    DBMS_CLOUD_AI_AGENT.CREATE_TEAM(
        team_name   => 'MEMORY_TEAM',
        attributes  => '{"agents": [{"name": "MEMORY_AGENT", "task": "MEMORY_TASK"}],
                        "process": "sequential"}',
        description => 'Team with memory-enabled agent'
    );
END;
/
</copy>
```

## Task 7: Test Memory Across Sessions

Now let's see memory in action. We'll tell the agent about Alex Martinez, clear the session, and prove the memory persists.

1. Set the team and teach the agent about Alex Martinez.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    EXEC DBMS_CLOUD_AI_AGENT.SET_TEAM('MEMORY_TEAM');
    SELECT AI AGENT Remember that Alex Martinez prefers email contact and has a 20 percent loyalty discount;
    </copy>
    ```

**Observe:** The agent calls REMEMBER_TOOL and stores the facts.

2. Ask what the agent knows (same session).

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    SELECT AI AGENT What do you know about Alex Martinez;
    </copy>
    ```

**Observe:** The agent recalls the information from memory.

3. Clear the session (simulating end of day, restart, etc.).

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    EXEC DBMS_CLOUD_AI_AGENT.CLEAR_TEAM;
    </copy>
    ```

4. Start a new session.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    EXEC DBMS_CLOUD_AI_AGENT.SET_TEAM('MEMORY_TEAM');
    </copy>
    ```

5. Ask about Alex Martinez again.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    SELECT AI AGENT What do you know about Alex Martinez;
    </copy>
    ```

**The agent still remembers!** It calls RECALL_TOOL, finds the stored facts, and tells you about the email preference and 20% discount.

## Task 8: Add More Information

Memory accumulates over time. Let's add more facts.

> This command is already in your notebook—just click the play button (▶) to run it.

```sql
<copy>
SELECT AI AGENT Remember that Alex Martinez collects vintage sports cards and is a platinum tier customer;
SELECT AI AGENT What do you know about Alex Martinez;
</copy>
```

The agent now has multiple facts stored and can recall them all.

## Task 9: See What's in Memory

Look at the raw memory table to see what the agent stored.

> This command is already in your notebook—just click the play button (▶) to run it.

```sql
<copy>
SELECT
    TO_CHAR(created_at, 'YYYY-MM-DD HH24:MI:SS') as stored_at,
    JSON_VALUE(content, '$.fact') as fact,
    JSON_VALUE(content, '$.about') as about_who,
    JSON_VALUE(content, '$.category') as category
FROM agent_memory
WHERE memory_type = 'FACT'
ORDER BY created_at DESC;
</copy>
```

You'll see all the facts stored as JSON, searchable and persistent.

## Summary

In this lab, you built the foundation of agentic memory:

* Created a memory table with JSON storage for flexible fact representation
* Built `remember_fact` function to store information
* Built `recall_facts` function to retrieve information
* Registered both as agent tools
* Created a memory-enabled agent
* Tested memory persistence across session boundaries

**Key takeaway:** Memory isn't magic. It's a database table with functions agents can call. When Alex Martinez's preferences are stored in the database, they persist forever. Every inventory specialist, every session, every interaction can access that knowledge. This is how Big Star Collectibles goes from forgetting VIP customers to building lasting relationships.

## Learn More

* [`DBMS_CLOUD_AI_AGENT` Package](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/dbms-cloud-ai-agent-package.html)
* [JSON in Oracle Database](https://docs.oracle.com/en/database/oracle/oracle-database/23/adjsn/)

## Acknowledgements

* **Author** - David Start
* **Last Updated By/Date** - David Start, January 2026

## Cleanup (Optional)

> This command is already in your notebook—just click the play button (▶) to run it.

```sql
<copy>
EXEC DBMS_CLOUD_AI_AGENT.DROP_TEAM('MEMORY_TEAM', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TASK('MEMORY_TASK', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_AGENT('MEMORY_AGENT', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('REMEMBER_TOOL', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('RECALL_TOOL', TRUE);
DROP TABLE agent_memory PURGE;
DROP FUNCTION remember_fact;
DROP FUNCTION recall_facts;
</copy>
```
