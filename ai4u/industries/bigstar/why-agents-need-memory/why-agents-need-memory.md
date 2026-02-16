# Why Agents Need Memory

## Introduction

In this lab, you'll experience the forgetting problem firsthand and understand why memory is essential for agents that do real work.

Most AI agents have amnesia. Every conversation starts fresh. They don't remember what happened yesterday, what they learned last week, or what pricing guides they're supposed to follow. This works for demos. It fails completely in production.

You'll tell an agent something important, clear the session, and watch it forget everything.

### The Business Problem

Last month at Big Star Collectibles, an inventory specialist quoted standard pricing to Alex Martinez, a collector who's been with the company for six years and has a **20% loyalty discount** on file.

Alex was not happy:

> *"I've told three different people my preferences. Why doesn't anyone remember? I specifically asked to be contacted by email, not phone. I have a loyalty discount that took months to earn. And every time I call, it's like starting over."*
>
> Alex Martinez, Big Star Collectibles VIP

This is exactly what's happening with Big Star Collectibles' AI assistants. They have amnesia. Every conversation starts fresh. A customer shares their preferences, and five minutes later (or after a session reset), the AI has no idea who they are.

### What You'll Learn

This lab lets you experience the forgetting problem directly. You'll tell an agent about a customer, clear the session, and watch it forget everything. This demonstrates why memory is essential, not just nice to have.

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
    https://github.com/davidastart/database/blob/main/ai4u/industries/bigstar/why-agents-need-memory/lab5-why-agents-need-memory.json
    </copy>
    ```

5. Click **Ok**.

You should now be on the screen with the notebook imported. This workshop will have all of the screenshots and detailed information however the notebook will have the commands and basic instructions for completing the lab.

## Task 2: Create an Agent Without Memory

We'll create an agent that has no way to store or retrieve information between sessions. Notice that we tell the agent in its role to "remember" things, but we don't give it any tools to actually do that. This is the gap: the agent wants to remember but has no way to make memories persist.

1. Create a simple inventory specialist assistant agent.

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
                            "role": "You are an inventory specialist assistant for Big Star Collectibles. Remember any preferences or information customers share with you so you can serve them better. Build relationships by recalling past interactions."}',
            description => 'Agent without memory capabilities'
        );
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
    /

    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_TASK(
            task_name   => 'FORGETFUL_TASK',
            attributes  => '{"instruction": "Help the inventory specialist with their request. Remember customer preferences and details for future interactions. {query}",
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

## Task 3: Teach the Agent About Alex Martinez

Let's give the agent important information about a customer, just like a real inventory specialist would share.

1. Tell the agent about Alex Martinez's preferences.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    SELECT AI AGENT Alex Martinez prefers email contact, never phone. Their timezone is Pacific. They have a 20 percent loyalty discount that was earned last year due to VIP collector status with Big Star Collectibles. Please remember this for future interactions;
    </copy>
    ```

The agent acknowledges and seems to understand. It might even thank you for the information.

2. Immediately ask about what you just said.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    SELECT AI AGENT What is Alex Martinez's preferred contact method;
    </copy>
    ```

The agent can recall this, it's still in the conversation context.

3. Ask another question in the same session.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    SELECT AI AGENT What loyalty discount does Alex Martinez have;
    </copy>
    ```

Still works, the context is maintained within the session.

## Task 4: Experience the Forgetting

Now let's simulate what happens when the session ends and a new one begins, like when Alex calls back the next day.

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
    SELECT AI AGENT What is Alex Martinez's preferred contact method;
    </copy>
    ```

**The agent has no idea.** It might apologize and say it doesn't have that information, or it might make something up. Either way, everything you told it is gone.

4. Try asking about the loyalty discount.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    SELECT AI AGENT What loyalty discount does Alex Martinez have;
    </copy>
    ```

**Gone.** All of it. Forgotten.

## Task 5: Understand Why This Breaks Real Workflows

This isn't just annoying. It makes agents unusable for production work.

**What happens in the real world:**

1. **Monday morning**: Alex Martinez calls. You tell the agent about their 20% loyalty discount and email preference.
2. **Monday afternoon**: Session clears. The agent forgets.
3. **Tuesday**: Alex calls back. The agent has no record. Alex gets quoted standard pricing again.
4. **Wednesday**: Alex is frustrated and calls to complain. The agent still doesn't know who they are.
5. **Thursday**: Alex takes their business to a competitor who remembers them.

**What Big Star Collectibles needs:**

- When a customer shares a preference, it should stick
- When an inventory specialist notes a loyalty discount, it should persist
- When a decision is made about an item, that context should inform future decisions
- Agents should get smarter over time, not reset every conversation

**The solution:** Agentic memory. You'll build it in the next labs.

## Task 6: See What Happens With Context Limits

Even within a single session, context can overflow.

1. Give the agent a lot of information.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    SELECT AI AGENT Here is information about our top collectors. Alex Martinez: VIP status, 20 percent discount, prefers email. Jordan Lee: Gold tier, 10 percent discount, prefers phone. Sam Chen: Standard tier, no discount, prefers text. Morgan Taylor: Platinum tier, 25 percent discount, prefers email. Casey Kim: Silver tier, 5 percent discount, prefers phone. Please remember all of this;
    </copy>
    ```

2. Now add more context by asking several questions.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    SELECT AI AGENT What types of collectibles does Big Star specialize in;
    SELECT AI AGENT How does authentication work;
    SELECT AI AGENT What are the different loyalty tiers;
    SELECT AI AGENT Explain the grading process;
    </copy>
    ```

3. Go back and ask about the first customer.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    SELECT AI AGENT What is Alex Martinez's loyalty discount;
    </copy>
    ```

**Depending on context size**, the agent might have forgotten. Even without clearing the session, the early information can fall out of context as new information comes in.

## Summary

In this lab, you directly experienced the forgetting problem:

* Created an agent without memory tools
* Taught it important customer information
* Saw it recall within the same session
* Cleared the session and watched it forget everything
* Understood why this makes agents unusable for real workflows

**Key takeaway:** An agent without memory is just an expensive way to frustrate customers. Every conversation starts from zero. Nothing persists. Nothing accumulates. For Big Star Collectibles, this means VIP collectors like Alex Martinez get treated like strangers every time they interact.

The next labs show you how to fix this. You'll build persistent memory using Oracle Database, giving your agents the ability to remember, learn, and improve over time.

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
