# Why Agents Need Memory

## Introduction

In this lab, you'll experience the forgetting problem firsthand and understand why memory is essential for agents that do real work.

Most AI agents have amnesia. Every conversation starts fresh. They don't remember what happened yesterday, what they learned last week, or what rules they're supposed to follow. This works for demos. It fails completely in production.

You'll tell an agent something important, clear the session, and watch it forget everything.

### The Business Problem

Last month at Seer Equity, a loan officer quoted standard rates to Sarah Chen, a client who's been with the company for six years and has a **15% rate exception** on file.

Sarah was not happy:

> *"I've told three different people my preferences. Why doesn't anyone remember? I specifically asked to be contacted by email, not phone. I have a rate exception that took months to negotiate. And every time I call, it's like starting over."*
>
> Sarah Chen, Seer Equity Client

This is exactly what's happening with Seer Equity's AI assistants. They have amnesia. Every conversation starts fresh. A client shares their preferences, and five minutes later (or after a session reset), the AI has no idea who they are.

### What You'll Learn

This lab lets you experience the forgetting problem directly. You'll tell an agent about a client, clear the session, and watch it forget everything. This demonstrates why memory is essential, not just nice to have.

**What you'll build:** Nothing permanent. This lab is about experiencing the problem that the rest of the workshop solves.

Estimated Time: 10 minutes

### Objectives

* Experience the forgetting problem directly
* Understand the difference between chat memory and agentic memory
* See why stateless agents can't run real workflows
* Recognize the need for persistent memory

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
    https://github.com/davidastart/database/blob/main/ai4u/why-agents-need-memory/lab5-why-agents-need-memory.json
    </copy>
    ```

5. Click **Import**.

You should now be on the screen with the notebook imported. This workshop will have all of the screenshots and detailed information however the notebook will have the commands and basic instructions for completing the lab.

## Task 2: Create an Agent Without Memory

We'll create an agent that has no way to store or retrieve information between sessions. Notice that we tell the agent in its role to "remember" things, but we don't give it any tools to actually do that. This is the gap: the agent wants to remember but has no way to make memories persist.

1. Create a simple loan officer assistant agent.

    > This command is already in your notebook—just click the play button (▶) to run it.

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
                            "role": "You are a loan officer assistant for Seer Equity. Remember any preferences or information clients share with you so you can serve them better. Build relationships by recalling past interactions."}',
            description => 'Agent without memory capabilities'
        );
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
    /

    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_TASK(
            task_name   => 'FORGETFUL_TASK',
            attributes  => '{"instruction": "Help the loan officer with their request. Remember client preferences and details for future interactions. {query}",
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

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    EXEC DBMS_CLOUD_AI_AGENT.SET_TEAM('FORGETFUL_TEAM');
    </copy>
    ```

## Task 3: Teach the Agent About Sarah Chen

Let's give the agent important information about a client, just like a real loan officer would share.

1. Tell the agent about Sarah Chen's preferences.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    SELECT AI AGENT Sarah Chen prefers email contact, never phone. Her timezone is Pacific. She has a 15 percent rate exception that was approved last year due to her long relationship with Seer Equity. Please remember this for future interactions;
    </copy>
    ```

The agent acknowledges and seems to understand. It might even thank you for the information.

2. Immediately ask about what you just said.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    SELECT AI AGENT What is Sarah Chen's preferred contact method;
    </copy>
    ```

The agent can recall this, it's still in the conversation context.

3. Ask another question in the same session.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    SELECT AI AGENT What rate exception does Sarah Chen have;
    </copy>
    ```

Still works, the context is maintained within the session.

## Task 4: Experience the Forgetting

Now let's simulate what happens when the session ends and a new one begins, like when Sarah calls back the next day.

1. Clear the team (simulating session end).

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    EXEC DBMS_CLOUD_AI_AGENT.CLEAR_TEAM;
    </copy>
    ```

2. Start a new session.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    EXEC DBMS_CLOUD_AI_AGENT.SET_TEAM('FORGETFUL_TEAM');
    </copy>
    ```

3. Ask about the preferences you shared.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    SELECT AI AGENT What is Sarah Chen's preferred contact method;
    </copy>
    ```

**The agent doesn't know.** It might say it doesn't have that information or ask you to tell it.

4. Try asking about her rate exception.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    SELECT AI AGENT What rate exception does Sarah Chen have;
    </copy>
    ```

**Gone.** Everything you told it has been forgotten. This is exactly what happened when Sarah Chen called Seer Equity and got quoted standard rates.

## Task 5: See the Business Impact

This isn't just an inconvenience. It breaks real workflows and damages client relationships.

1. Simulate Day 1: Client shares important information.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    SELECT AI AGENT I am working with client TechStart Inc. They need all communications sent to their CFO, not the general email. They are sensitive about being contacted during market hours. They have a special pricing tier because they bring us 10 loans per year;
    </copy>
    ```

2. The agent acknowledges the information. Now simulate Day 2:

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    EXEC DBMS_CLOUD_AI_AGENT.CLEAR_TEAM;
    EXEC DBMS_CLOUD_AI_AGENT.SET_TEAM('FORGETFUL_TEAM');
    </copy>
    ```

3. A different loan officer asks about TechStart.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    SELECT AI AGENT What special requirements does TechStart Inc have;
    </copy>
    ```

**The agent has no idea.** The new loan officer might contact the wrong person, call during market hours, or quote the wrong rates. The client gets frustrated. The relationship suffers.

## Task 6: Understand What's Missing

Let's be clear about what the agent lacks:

1. Query what tools the agent has.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    SELECT tool_name, description 
    FROM USER_AI_AGENT_TOOLS;
    </copy>
    ```

The forgetful agent has no memory tools. It has no way to store or retrieve information persistently.

2. Check if anything was recorded in history.

    > This command is already in your notebook—just click the play button (▶) to run it.

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

The tool calls are logged, but the client information itself? Lost.

## Task 7: The Real Cost to Seer Equity

Consider what this forgetting costs:

| What's Forgotten | Business Impact |
|------------------|-----------------|
| Contact preferences | Clients get annoyed by wrong contact method |
| Rate exceptions | Long-term clients quoted wrong rates |
| Relationship history | Every interaction feels like starting over |
| Special requirements | Compliance and service failures |
| Past decisions | Same issues get re-decided differently |

Sarah Chen's experience wasn't unique. It's happening every day with every client who interacts with Seer Equity's AI assistants.

## Summary

In this lab, you experienced the forgetting problem:

* Told an agent important client information
* Watched it forget everything when the session ended
* Understood why this breaks real workflows
* Recognized the gap between chat memory and agentic memory

**Key takeaway:** Intelligence doesn't matter if an agent can't remember what just happened. Without memory, agents perform. With memory, agents progress. Sarah Chen shouldn't have to explain her preferences three times, and with agentic memory, she won't have to.

The next labs will show you how to solve this problem.

## Learn More

* [`DBMS_CLOUD_AI_AGENT` Package](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/dbms-cloud-ai-agent-package.html)

## Acknowledgements

* **Author** - David Start
* **Last Updated By/Date** - David Start, January 2026

## Cleanup (Optional)

> This command is already in your notebook—just click the play button (▶) to run it.

```sql
<copy>
EXEC DBMS_CLOUD_AI_AGENT.DROP_TEAM('FORGETFUL_TEAM', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TASK('FORGETFUL_TASK', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_AGENT('FORGETFUL_AGENT', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('BASIC_SQL_TOOL', TRUE);
</copy>
```
