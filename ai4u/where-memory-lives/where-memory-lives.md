# Where Agent Memory Should Live

## Introduction

In this lab, you'll build a **memory core**, the converged database foundation that gives AI agents **agentic memory**.

### The Business Problem

In Lab 5, you experienced the forgetting problem firsthand. Sarah Chen from Acme Industries had to explain her preferences and rate exception to three different loan officers. The AI assistant forgot everything the moment each session ended.

This isn't just frustrating. It's costing Seers Equity business. Clients feel unvalued. Loan officers waste time re-gathering information. And compliance can't track what was communicated.

> *"Every conversation starts from zero. I told your AI about my preferences last week. Today it has no idea who I am."*
>
> Sarah Chen, Acme Industries

### What You'll Learn

In this lab, you'll solve the forgetting problem by building a **memory core**, the database foundation that gives agents persistent memory:

1. **Create memory tables** using Oracle's native JSON for flexible storage
2. **Build remember/recall functions** that agents call as tools
3. **Register the tools** so the agent can store and retrieve facts
4. **Test across sessions** to prove memory persists

The key insight: Memory isn't a model capability. It's a database capability. The LLM provides intelligence; your database provides memory. Together, they create agents that actually remember.

**What you'll build:** A persistent memory system where agents store and recall client information across sessions.

Estimated Time: 15 minutes

### Objectives

* Build a memory core using Oracle's native JSON type
* Create PL/SQL functions as agent tools for memory
* Register tools with the agent framework
* Have conversations with an agent that has true agentic memory

### Prerequisites

This lab assumes you have:

* Completed Labs 1-6 or have a working agent setup
* An AI profile named `genai` already configured

## Task 1: Create the Memory Core Table

The memory table is the foundation, where the agent stores everything it learns.

1. Create the memory core table.

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

    ```sql
    <copy>
    CREATE INDEX idx_memory_about ON agent_memory m (m.content.about.string());
    CREATE INDEX idx_memory_type ON agent_memory(memory_type);
    </copy>
    ```

## Task 2: Create the Remember Function

This function becomes the agent's "save to memory" capability.

1. Create the function to store facts.

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

## Task 3: Create the Recall Function

The recall function is the agent's "search memory" capability.

1. Create the function to retrieve facts.

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

## Task 4: Register the Agent Tools

Tools bridge your PL/SQL functions and the AI agent.

1. Register the "remember" tool.

    ```sql
    <copy>
    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
            tool_name   => 'REMEMBER_TOOL',
            attributes  => '{"instruction": "Store a fact for future reference. Parameters: P_FACT (the information to remember), P_CATEGORY (optional: general, preference, contact, etc), P_ABOUT (optional: the entity this fact is about, e.g. Acme Corp). Use this when the user shares important information.",
                            "function": "remember_fact"}',
            description => 'Stores facts in long-term memory for future recall'
        );
    END;
    /
    </copy>
    ```

2. Register the "recall" tool.

    ```sql
    <copy>
    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
            tool_name   => 'RECALL_TOOL',
            attributes  => '{"instruction": "Retrieve facts from memory. Parameters: P_ABOUT (optional: entity name to search for), P_CATEGORY (optional: filter by category). Use this when asked about something you might have stored.",
                            "function": "recall_facts"}',
            description => 'Retrieves stored facts from long-term memory'
        );
    END;
    /
    </copy>
    ```

3. Verify the tools were created.

    ```sql
    <copy>
    SELECT tool_name, status, description FROM USER_AI_AGENT_TOOLS;
    </copy>
    ```

## Task 5: Create the Agent, Task, and Team

1. Create the agent with memory awareness.

    ```sql
    <copy>
    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_AGENT(
            agent_name  => 'MEMORY_AGENT',
            attributes  => '{"profile_name": "genai",
                            "role": "You are a helpful assistant with persistent memory. When users share information, use REMEMBER_TOOL to store it. When users ask questions, use RECALL_TOOL to check your memory. Always use your tools - never guess."}',
            description => 'An agent with persistent memory'
        );
    END;
    /
    </copy>
    ```

2. Create the task.

    ```sql
    <copy>
    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_TASK(
            task_name   => 'MEMORY_TASK',
            attributes  => '{"instruction": "Process this user request. If the user shares information worth remembering, call REMEMBER_TOOL to store it. If the user asks a question, call RECALL_TOOL to search memory first. Do not ask clarifying questions. User request: {query}",
                            "tools": ["REMEMBER_TOOL", "RECALL_TOOL"]}',
            description => 'Task for memory-enabled conversations'
        );
    END;
    /
    </copy>
    ```

3. Create the team.

    ```sql
    <copy>
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

## Task 6: Talk to Your Agent

Now let's see memory in action.

1. Set the team.

    ```sql
    <copy>
    EXEC DBMS_CLOUD_AI_AGENT.SET_TEAM('MEMORY_TEAM');
    </copy>
    ```

2. Tell the agent something to remember.

    ```sql
    <copy>
    SELECT AI AGENT Customer Acme Corp prefers to be contacted by email, not phone;
    </copy>
    ```

3. Tell it more.

    ```sql
    <copy>
    SELECT AI AGENT The main contact for Acme Corp is Sarah Johnson and their timezone is Pacific;
    </copy>
    ```

4. Ask about what it knows.

    ```sql
    <copy>
    SELECT AI AGENT What do you know about Acme Corp;
    </copy>
    ```

The agent recalls the stored facts.

## Task 7: Verify Persistence Across Sessions

1. Clear and reset the session.

    ```sql
    <copy>
    EXEC DBMS_CLOUD_AI_AGENT.CLEAR_TEAM;
    EXEC DBMS_CLOUD_AI_AGENT.SET_TEAM('MEMORY_TEAM');
    </copy>
    ```

2. Ask about previous information.

    ```sql
    <copy>
    SELECT AI AGENT Who is the contact for Acme Corp;
    </copy>
    ```

**The agent remembers!** Because facts are stored in the database, not session memory.

3. View the memory core contents.

    ```sql
    <copy>
    SELECT 
        memory_type,
        JSON_SERIALIZE(content PRETTY) as content_json,
        created_at
    FROM agent_memory
    ORDER BY created_at DESC;
    </copy>
    ```

## Summary

In this lab, you built a **memory core** using Oracle's converged database:

* Created a memory table with native JSON
* Built remember and recall functions
* Registered them as agent tools
* Had conversations with an agent that remembers
* Verified persistence across sessions

**Key takeaway:** The memory core isn't another model layer. It's a converged database. Everything lives in one place: one transaction, one security model, one query language.

## Learn More

* [DBMS_CLOUD_AI_AGENT Package](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/dbms-cloud-ai-agent-package.html)
* [JSON Developer's Guide](https://docs.oracle.com/en/database/oracle/oracle-database/26/adjsn/)

## Acknowledgements

* **Author** - David Start
* **Last Updated By/Date** - David Start, January 2026

## Cleanup (Optional)

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
