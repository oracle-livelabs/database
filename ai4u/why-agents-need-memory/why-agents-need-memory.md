# Why Agents Need Memory

## Introduction

In this lab, you'll experience the forgetting problem firsthand—and understand why memory is essential for agents that do real work.

Most AI agents have amnesia. Every conversation starts fresh. They don't remember what happened yesterday, what they learned last week, or what rules they're supposed to follow. This works for demos. It fails completely in production.

You'll tell an agent something important, clear the session, and watch it forget everything.

Estimated Time: 10 minutes

### Objectives

* Experience the forgetting problem directly
* Understand the difference between chat memory and agentic memory
* See why stateless agents can't run real workflows
* Recognize the need for persistent memory

### Prerequisites

This lab assumes you have:

* Completed Labs 1-4 or have a working agent setup
* An AI profile named `genai` already configured
* Oracle Database 26ai with Select AI Agent
* Basic knowledge of SQL

## Task 1: Create an Agent Without Memory

We'll create an agent that has no way to store or retrieve information between sessions.

1. Create a simple customer service agent.

    ```sql
    <copy>
    -- Create a basic SQL tool so the agent can function
    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
            tool_name   => 'BASIC_SQL_TOOL',
            attributes  => '{"tool_type": "SQL",
                            "tool_params": {"profile_name": "genai"}}',
            description => 'Basic SQL query tool'
        );
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
    /

    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_AGENT(
            agent_name  => 'FORGETFUL_AGENT',
            attributes  => '{"profile_name": "genai",
                            "role": "You are a helpful customer service agent. Remember any preferences or information customers share with you so you can serve them better."}',
            description => 'Agent without memory capabilities'
        );
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
    /

    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_TASK(
            task_name   => 'FORGETFUL_TASK',
            attributes  => '{"instruction": "Help the customer with their request. {query}",
                            "tools": ["BASIC_SQL_TOOL"]}',
            description => 'Task without memory tools'
        );
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
    /

    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_TEAM(
            team_name   => 'FORGETFUL_TEAM',
            attributes  => '{"agents": [{"name": "FORGETFUL_AGENT", "task": "FORGETFUL_TASK"}],
                            "process": "sequential"}',
            description => 'Team demonstrating memory limitations'
        );
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
    /
    </copy>
    ```

2. Set the team for your session.

    ```sql
    <copy>
    EXEC DBMS_CLOUD_AI_AGENT.SET_TEAM('FORGETFUL_TEAM');
    </copy>
    ```

## Task 2: Teach the Agent Something

Let's give the agent important information about a customer.

1. Tell the agent about customer preferences.

    ```sql
    <copy>
    SELECT AI AGENT I am Sarah Chen from Acme Corp. I prefer email contact and my timezone is Pacific. Please remember this for future interactions;
    </copy>
    ```

The agent acknowledges and seems to understand.

2. Immediately ask about what you just said.

    ```sql
    <copy>
    SELECT AI AGENT What is my preferred contact method;
    </copy>
    ```

The agent can recall this—it's still in the conversation context.

3. Ask another question in the same session.

    ```sql
    <copy>
    SELECT AI AGENT What timezone am I in;
    </copy>
    ```

Still works—the context is maintained within the session.

## Task 3: Experience the Forgetting

Now let's simulate what happens when the session ends and a new one begins.

1. Clear the team (simulating session end).

    ```sql
    <copy>
    EXEC DBMS_CLOUD_AI_AGENT.CLEAR_TEAM;
    </copy>
    ```

2. Start a new session.

    ```sql
    <copy>
    EXEC DBMS_CLOUD_AI_AGENT.SET_TEAM('FORGETFUL_TEAM');
    </copy>
    ```

3. Ask about the preferences you shared.

    ```sql
    <copy>
    SELECT AI AGENT What is my preferred contact method;
    </copy>
    ```

**The agent doesn't know.** It might say it doesn't have that information or ask you to tell it.

4. Try asking about your name and company.

    ```sql
    <copy>
    SELECT AI AGENT Who am I and what company do I work for;
    </copy>
    ```

**Gone.** Everything you told it has been forgotten.

## Task 4: See the Business Impact

This isn't just an inconvenience—it breaks real workflows.

1. Simulate Day 1: Customer reports an issue.

    ```sql
    <copy>
    SELECT AI AGENT I am having problems with my order ORD-5678. The shipment is delayed and I need it urgently for a client presentation on Friday;
    </copy>
    ```

2. The agent acknowledges the issue. Now simulate Day 2:

    ```sql
    <copy>
    EXEC DBMS_CLOUD_AI_AGENT.CLEAR_TEAM;
    EXEC DBMS_CLOUD_AI_AGENT.SET_TEAM('FORGETFUL_TEAM');
    </copy>
    ```

3. Customer calls back for an update.

    ```sql
    <copy>
    SELECT AI AGENT Any update on my order issue;
    </copy>
    ```

**The agent has no idea what issue you're talking about.** The customer has to explain everything again.

## Task 5: Understand What's Missing

Let's be clear about what the agent lacks:

1. Query what tools the agent has.

    ```sql
    <copy>
    SELECT tool_name, description 
    FROM USER_AI_AGENT_TOOLS;
    </copy>
    ```

The forgetful agent has no memory tools—no way to store or retrieve information.

2. Check if anything was recorded in history.

    ```sql
    <copy>
    SELECT 
        tool_name,
        TO_CHAR(start_date, 'YYYY-MM-DD HH24:MI:SS') as when
    FROM USER_AI_AGENT_TOOL_HISTORY
    WHERE start_date > SYSTIMESTAMP - INTERVAL '10' MINUTE
    ORDER BY start_date DESC;
    </copy>
    ```

## Summary

In this lab, you experienced the forgetting problem:

* Told an agent important information
* Watched it forget everything when the session ended
* Understood why this breaks real workflows
* Recognized the gap between chat memory and agentic memory

**Key takeaway:** Intelligence doesn't matter if an agent can't remember what just happened. Without memory, agents perform. With memory, agents progress.

## Learn More

* [DBMS_CLOUD_AI_AGENT Package](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/dbms-cloud-ai-agent-package.html)

## Acknowledgements

* **Author** - David Start
* **Last Updated By/Date** - David Start, January 2026

## Cleanup (Optional)

```sql
<copy>
EXEC DBMS_CLOUD_AI_AGENT.DROP_TEAM('FORGETFUL_TEAM', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TASK('FORGETFUL_TASK', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_AGENT('FORGETFUL_AGENT', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('BASIC_SQL_TOOL', TRUE);
</copy>
```
