# What Is an AI Agent, Really?

## Introduction

Most people think AI is just a chatbot. You ask a question, it gives an answer. But agents do more. They don't just respond, they *act*. They look up real data, make decisions based on your systems, and complete tasks.

![What Is An Agent?](./images/intro-lab1.png " ")

In this lab, you will see that difference firsthand at Big Star Collectibles, a fictitional growing collectibles retailer. you will create an agent that can query actual item submission data from your database. It won't explain how to check submissions. It will actually check them and give you real answers.

### The Business Problem

At Big Star Collectibles, inventory specialists spend hours every day answering the same question: *"What's my item status?"*

When a client calls, the inventory specialist has to log into the system, navigate to the right screen, find the submission, and read out the status. It's tedious. It's slow. And it takes time away from actually helping clients.

The company tried deploying a chatbot. But when a client asked "What's the status of my item submission?", the chatbot responded with a 5-step tutorial on how to log in and check. The client didn't want a tutorial. They wanted their status.

> *"I asked the AI about my item and it told me how to look it up. I know how to look it up! I wanted you to just tell me the status."*
>
> Frustrated Big Star Collectibles client

### What you will Learn

This lab shows you the fundamental difference between a chatbot (explains how) and an agent (actually does it). you will build an agent that queries real submission data and returns actual answers. This is the first step toward solving Big Star Collectibles' client service challenges.

**What you will build:** A item submission lookup agent with a SQL tool that queries your database.

**Estimated Time**: 10 minutes

### Objectives

* Create sample item submission data for the agent to query
* Build an agent with a SQL tool
* See the agent look up real item information
* Understand why execution beats explanation

### Prerequisites

For this workshop, we provide the environment. you will need:

* Basic knowledge of SQL or the ability to follow along with the prompts

## Task 1: Import the Lab Notebook

Before you begin, you are going to import a notebook that has all of the commands for this lab into Oracle Machine Learning. This way you don't have to copy and paste them over to run them.

1. From the Oracle Machine Learning home page, click **Notebooks**.

    ![OML home page with Notebooks option highlighted in the navigation menu](images/task1_1.png " ")

2. Click **Import** to expand the Import drop down.

    ![Notebooks page with Import button highlighted](images/task1_2.png " ")

3. Select **Git**.

    ![Import dropdown expanded with Git option highlighted](images/task1_3.png " ")

4. Paste the following GitHub URL leaving the credential field blank:

    ```text
    <copy>
    https://github.com/kaymalcolm/database/blob/main/ai4u/industries/retail-bigstar/what-is-agent/lab1-what-is-agent.json
    </copy>
    ```

5. Click **Ok**.

    ![Git Clone dialog with URL pasted and Import button highlighted](images/task1_5.png " ")

    You should now be on the screen with the notebook imported. This workshop will have all of the screenshots and detailed information however the notebook will have the commands and basic instructions for completing the lab.

## Task 2: Create the Item Submissions Table

First, let's create a item submissions table. This gives the agent something real to work with, the kind of data that a chatbot would never be able to access.

1. Create the item submissions table.

    > This command is already in your notebook - just click the play button (▶) to run it.

    ```sql
    <copy>
    CREATE TABLE item_submissions (
        submission_id     VARCHAR2(20) PRIMARY KEY,
        collector_name     VARCHAR2(100),
        submission_date   DATE,
        item_status        VARCHAR2(30),
        declared_value        NUMBER(12,2),
        item_type          VARCHAR2(30)
    );
    </copy>
    ```

    ![Task Information](./images/task2_1.png " ")

2. Add comments so Select AI understands what this table contains.

    >**Note:** Select AI reads table and column comments to understand your schema. Good comments make the AI smarter about your data.

    > This command is already in your notebook - just click the play button (▶) to run it.

    ```sql
    <copy>
    COMMENT ON TABLE item_submissions IS 'Big Star Collectibles item submissions including status tracking and amounts';
    COMMENT ON COLUMN item_submissions.submission_id IS 'Unique submission identifier like ITEM-12345';
    COMMENT ON COLUMN item_submissions.collector_name IS 'Full name of the person or business applying for the item';
    COMMENT ON COLUMN item_submissions.submission_date IS 'Date the item submission was submitted';
    COMMENT ON COLUMN item_submissions.item_status IS 'Current status: Submitted, Authenticating, Listed, or Security Hold';
    COMMENT ON COLUMN item_submissions.declared_value IS 'Requested declared value in dollars';
    COMMENT ON COLUMN item_submissions.item_type IS 'Type of item: sports_card, comic, sneaker, or memorabilia piece';
    </copy>
    ```

    ![Task Information](./images/task2_2.png " ")

3. Add sample item submissions.

    > This command is already in your notebook - just click the play button (▶) to run it.

    ```sql
    <copy>
    INSERT INTO item_submissions VALUES ('ITEM-20260115-1042', 'Alex Martinez', DATE '2026-01-15', 'Authenticating', 7800, 'sports_card');
    INSERT INTO item_submissions VALUES ('ITEM-20260114-0821', 'Jennifer Morales', DATE '2026-01-14', 'Submitted', 1200, 'comic');
    INSERT INTO item_submissions VALUES ('ITEM-20260113-0905', 'Priya Desai', DATE '2026-01-13', 'Listed', 420, 'sneaker');
    INSERT INTO item_submissions VALUES ('ITEM-20260112-0754', 'Marcus Reed', DATE '2026-01-12', 'Security Hold', 5600, 'memorabilia');
    COMMIT;
    </copy>
    ```

    ![Task Information](./images/task2_3.png " ")

4. Verify the data exists.

    > This command is already in your notebook - just click the play button (▶) to run it.

    ```sql
    <copy>
    SELECT submission_id, collector_name, item_status, declared_value, item_type FROM item_submissions;
    </copy>
    ```

    ![Task Information](./images/task2_4.png " ")

## Task 3: Add the Table to Your AI Profile

For Select AI to query your table, the profile needs to know about it. We'll add the table to your existing `genai` profile's object list.

1. Add the ITEM_SUBMISSIONS table to the genai profile.

    >**Note:** The `object_list` tells Select AI which tables it can query. Without this, the AI won't know your table exists.

    > This command is already in your notebook - just click the play button (▶) to run it.

    ```sql
    <copy>
    BEGIN
        DBMS_CLOUD_AI.SET_ATTRIBUTE(
            profile_name    => 'genai',
            attribute_name  => 'object_list',
            attribute_value => '[{"owner": "' || USER || '", "name": "ITEM_SUBMISSIONS"}]'
        );
    END;
    /
    </copy>
    ```

    ![Task Information](./images/task3_1.png " ")

## Task 4: Create the Agent Components

Now let's build an agent that can query this data. An agent system has four components that work together:

| Component | Purpose |
|-----------|--------|
| **Tool** | Defines a specific capability the agent can use (like querying a database) |
| **Agent** | The AI personality with a role and behavior guidelines |
| **Task** | Instructions that tell the agent what to do and which tools to use |
| **Team** | Brings agents and tasks together so you can run them |

Think of it like hiring a new employee: the **tool** is the software they'll use, the **agent** is the person with their job title and responsibilities, the **task** is their job description, and the **team** is the department that coordinates their work.

1. Create the SQL tool.

    A **tool** gives the agent a specific capability. Without tools, an agent can only talk, it can't actually do anything. This SQL tool connects to your AI profile and allows the agent to query the item submissions table. The description helps the agent understand when and how to use this tool.

    > This command is already in your notebook - just click the play button (▶) to run it.

    ```sql
    <copy>
    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
            tool_name   => 'ITEM_LOOKUP',
            attributes  => '{"tool_type": "SQL",
                            "tool_params": {"profile_name": "genai"}}',
            description => 'Query the ITEM_SUBMISSIONS table. Columns: SUBMISSION_ID, COLLECTOR_NAME, SUBMISSION_DATE, ITEM_STATUS (Submitted/Authenticating/Listed/Security Hold), DECLARED_VALUE, ITEM_TYPE (sports_card/comic/sneaker/memorabilia).'
        );
    END;
    /
    </copy>
    ```

    ![Task Information](./images/task4_1.png " ")

2. Create the agent.

    An **agent** is the AI entity that will handle requests. The `role` attribute shapes the agent's personality and behavior, it's like giving an employee their job title and explaining how they should approach their work. Here we're telling the agent it's a item submission assistant and should always use its tools rather than asking follow-up questions.

    > This command is already in your notebook - just click the play button (▶) to run it.

    ```sql
    <copy>
    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_AGENT(
            agent_name  => 'INVENTORY_AGENT',
            attributes  => '{"profile_name": "genai",
                            "role": "You are a item submission assistant for Big Star Collectibles. Always use the ITEM_LOOKUP tool to query the database and provide answers. Never ask clarifying questions - just query the data and report what you find."}',
            description => 'Agent that looks up item submission information'
        );
    END;
    /
    </copy>
    ```

    ![Task Information](./images/task4_2.png " ")

3. Create the task.

    A **task** is a set of instructions that tells the agent exactly what to do when it receives a request. It also specifies which tools the agent can use for this task. The `{query}` placeholder is where the user's question gets inserted. Think of the task as the detailed job description that guides the agent's work.

    > This command is already in your notebook - just click the play button (▶) to run it.

    ```sql
    <copy>
    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_TASK(
            task_name   => 'ITEM_TASK',
            attributes  => '{"instruction": "Answer questions about Big Star Collectibles item submissions by querying the ITEM_SUBMISSIONS table using the ITEM_LOOKUP tool. The table has columns: SUBMISSION_ID, COLLECTOR_NAME, SUBMISSION_DATE, ITEM_STATUS (Submitted, Authenticating, Listed, Security Hold), DECLARED_VALUE, ITEM_TYPE (sports_card, comic, sneaker, memorabilia). Do not ask clarifying questions - query the data and provide the answer. User question: {query}",
                            "tools": ["ITEM_LOOKUP"]}',
            description => 'Task for handling item submission inquiries'
        );
    END;
    /
    </copy>
    ```

    ![Task Information](./images/task4_3.png " ")

4. Create the team.

    A **team** is the container that brings everything together. It assigns agents to tasks and defines how they coordinate. The `process` attribute determines how work flows, "sequential" means agents work one after another (in this case we only have one agent). You interact with the team, and the team orchestrates which agent handles your request using which task.

    > This command is already in your notebook - just click the play button (▶) to run it.

    ```sql
    <copy>
    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_TEAM(
            team_name   => 'ITEM_TEAM',
            attributes  => '{"agents": [{"name": "INVENTORY_AGENT", "task": "ITEM_TASK"}],
                            "process": "sequential"}',
            description => 'Team for item submission inquiries'
        );
    END;
    /
    </copy>
    ```

    ![Task Information](./images/task4_4.png " ")

5. Verify everything is created.

    > This command is already in your notebook - just click the play button (▶) to run it.

    ```sql
    <copy>
    SELECT tool_name, status FROM USER_AI_AGENT_TOOLS WHERE tool_name = 'ITEM_LOOKUP';
    SELECT agent_name, status FROM USER_AI_AGENTS WHERE agent_name = 'INVENTORY_AGENT';
    SELECT task_name, status FROM USER_AI_AGENT_TASKS WHERE task_name = 'ITEM_TASK';
    SELECT agent_team_name, status FROM USER_AI_AGENT_TEAMS WHERE agent_team_name = 'ITEM_TEAM';
    </copy>
    ```

    ![Task Information](./images/task4_5.png " ")

## Task 5: See the Agent in Action

Now let's see the difference between an agent and a chatbot.

1. Set the team for your session.

    > This command is already in your notebook - just click the play button (▶) to run it.

    ```sql
    <copy>
    EXEC DBMS_CLOUD_AI_AGENT.SET_TEAM('ITEM_TEAM');
    </copy>
    ```

    ![Task Information](./images/task5_1.png " ")

2. Ask about a specific item submission.

    **This is the key moment.** The agent doesn't explain *how* to check item status. It actually queries the item_submissions table and tells you the answer.

    > This command is already in your notebook - just click the play button (▶) to run it.

    ```sql
    <copy>
    SELECT AI AGENT What is the status of item submission ITEM-12345;
    </copy>
    ```

    ![Task Information](./images/task5_2.png " ")

3. Ask about another submission.

    > This command is already in your notebook - just click the play button (▶) to run it.

    ```sql
    <copy>
    SELECT AI AGENT How much did Priya Desai apply for;
    </copy>
    ```

    ![Task Information](./images/task5_3.png " ")

4. Ask a question that requires reasoning over data.

    > This command is already in your notebook - just click the play button (▶) to run it.

    ```sql
    <copy>
    SELECT AI AGENT Which item submissions are still pending or under review;
    </copy>
    ```

    ![Task Information](./images/task5_4.png " ")

## Task 6: See What Happened Behind the Scenes

The agent used a tool to get real answers. Let's see the evidence.

1. Check the tool execution history.

    > This command is already in your notebook - just click the play button (▶) to run it.

    ```sql
    <copy>
    SELECT 
        tool_name,
        TO_CHAR(start_date, 'HH24:MI:SS') as called_at,
        SUBSTR(output, 1, 60) as result
    FROM USER_AI_AGENT_TOOL_HISTORY
    ORDER BY start_date DESC
    FETCH FIRST 5 ROWS ONLY;
    </copy>
    ```

    ![Task Information](./images/task6_1.png " ")

2. Check the team execution history.

    > This command is already in your notebook - just click the play button (▶) to run it.

    ```sql
    <copy>
    SELECT 
        team_name,
        TO_CHAR(start_date, 'HH24:MI:SS') as started,
        state
    FROM USER_AI_AGENT_TEAM_HISTORY
    ORDER BY start_date DESC
    FETCH FIRST 5 ROWS ONLY;
    </copy>
    ```

    ![Task Information](./images/task6_2.png " ")

## Task 7: The Chatbot vs Agent Difference

**A chatbot would say:**

> "To check the status of a item submission, you would typically:
> 1. Log into the Big Star Collectibles portal
> 2. Navigate to Submission Status
> 3. Enter your submission ID
> 4. View the current status"

**The agent said:**

> "Item submission ITEM-12345 for Alex Martinez was submitted on January 2, 2025 for a $45,000 personal item. Current status: Approved."

Same question. One explains the process. The other runs it.

That's what makes an agent an agent. It doesn't just know things. It *does* things. And that's exactly what Big Star Collectibles' clients need.

## Summary

In this lab, you experienced the fundamental nature of AI agents:

* Created a item submissions table with descriptive comments for Select AI
* Added the table to your AI profile's `object_list`
* Built an agent with access to a SQL tool
* Watched it query real submission data to answer questions
* Saw the execution history proving it took action
* Understood the difference between explanation and execution

**Key takeaway:** An agent acts on your systems. A chatbot explains how you could act on your systems. That's the difference that matters for Big Star Collectibles, and for your business.

## Learn More

* [Get an Autonomous Database for FREE!](https://www.oracle.com/autonomous-database/free-trial/)
* [Mark Hornick's Select AI Agent Blog](https://blogs.oracle.com/machinelearning/build-your-agentic-solution-using-oracle-adb-select-ai-agent)
* [Oracle Database Documentation](https://docs.oracle.com/en/database/oracle/oracle-database/)
* [`DBMS_CLOUD_AI_AGENT` Package](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/dbms-cloud-ai-agent-package.html)


## Acknowledgements

* **Author** - David Start, Director, Database Product Management
* **Last Updated By/Date** - Kay Malcolm, February 2026

## Cleanup (Optional)

> This command is already in your notebook - just click the play button (▶) to run it.

```sql
<copy>
EXEC DBMS_CLOUD_AI_AGENT.DROP_TEAM('ITEM_TEAM', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TASK('ITEM_TASK', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_AGENT('INVENTORY_AGENT', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('ITEM_LOOKUP', TRUE);
DROP TABLE item_submissions PURGE;
</copy>
```

![Cleanup](./images/cleanup.png " ")
