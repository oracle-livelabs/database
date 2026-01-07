# Where Agent Memory Should Live

## Introduction

In this lab, you'll build a **memory core**—the converged database foundation that gives AI agents **agentic memory**.

The technology that unlocks agentic memory isn't another model layer—it's a converged database capable of serving as the memory core for agentic systems. Not a vector store. Not a caching layer. A real database that can handle everything agents need.

You'll create a memory table using JSON for flexible storage, build tools the agent can use to remember and recall facts, and have actual conversations with an AI that uses your database as its memory core.

This isn't a simulation—you'll actually converse with an AI agent that uses your database as its memory core.

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
* Oracle Database 26ai with Select AI Agent
* Basic knowledge of SQL and PL/SQL

## Task 1: Create the Memory Core Table

The memory table is the foundation—where the agent stores everything it learns.

By using Oracle's native JSON type, we get flexibility to store any fact structure without predefined schemas. The agent can remember a customer's email preference today and their timezone tomorrow without any ALTER TABLE statements.

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

    >**Note:** The `content` column is native `JSON` type—not VARCHAR2 storing JSON text. Oracle validates, indexes, and optimizes it automatically.

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
            AND (p_about IS NULL OR UPPER(m.content.about.string()) = UPPER(p_about))
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
            attributes  => '{"instruction": "Store a fact for future reference. Use when the user shares something worth remembering. IMPORTANT: Use UPPERCASE parameter names: P_FACT (the fact), P_CATEGORY (type), P_ABOUT (entity name).",
                            "function": "remember_fact"}',
            description => 'Stores facts in long-term memory'
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
            attributes  => '{"instruction": "Retrieve facts from memory. Use when you need to know about a person, customer, or entity. IMPORTANT: Use UPPERCASE parameter names: P_ABOUT (entity name), P_CATEGORY (optional filter).",
                            "function": "recall_facts"}',
            description => 'Retrieves facts from long-term memory'
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
                            "role": "You are a helpful assistant with the ability to remember facts. When users tell you things worth remembering, use REMEMBER_TOOL. When users ask about something, use RECALL_TOOL to check what you know. Always check your memory before saying you do not know something."}',
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
            attributes  => '{"instruction": "Process this user request. If the user shares information, call REMEMBER_TOOL once. If the user asks a question, call RECALL_TOOL once. Use at most ONE tool call, then respond. User request: {query}",
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
    SELECT AI AGENT Acme Corp's main contact is Sarah Johnson and their timezone is Pacific;
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

## Task 8: Understand the Converged Database Advantage

You just built a memory core with:

| Capability | What It Provides |
|------------|------------------|
| **Native JSON** | Flexible fact structure, no migrations |
| **SQL Access** | Query memory with standard SQL |
| **Indexing** | Fast lookups on JSON fields |
| **Transactions** | ACID guarantees on memory writes |
| **Security** | Database roles and privileges |
| **Persistence** | Survives restarts, reconnects |

Traditional architectures would scatter this across multiple systems. You did it in one database.

## Summary

In this lab, you built a **memory core** using Oracle's converged database:

* Created a memory table with native JSON
* Built remember and recall functions
* Registered them as agent tools
* Had conversations with an agent that remembers
* Verified persistence across sessions

**Key takeaway:** The memory core isn't another model layer—it's a converged database. Everything lives in one place: one transaction, one security model, one query language.

## Learn More

* [DBMS_CLOUD_AI_AGENT Package](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/dbms-cloud-ai-agent-package.html)
* [JSON Developer's Guide](https://docs.oracle.com/en/database/oracle/oracle-database/26/adjsn/)

## Acknowledgements

* **Author** - David Start
* **Last Updated By/Date** - David Start, January 2026
