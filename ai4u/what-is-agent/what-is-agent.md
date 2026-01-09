# What Is an AI Agent, Really?

## Introduction

Most people think AI is just a chatbot. You ask a question, it gives an answer. But agents do more. They don't just respond, they *act*. They look up real data, make decisions based on your systems, and complete tasks.

In this lab, you'll see that difference firsthand at **Seers Equity**, a growing financial services company. You'll create an agent that can query actual loan application data from your database. It won't explain how to check applications. It will actually check them and give you real answers.

### The Business Problem

At Seers Equity, loan officers spend hours every day answering the same question: *"What's my loan status?"*

When a client calls, the loan officer has to log into the system, navigate to the right screen, find the application, and read out the status. It's tedious. It's slow. And it takes time away from actually helping clients.

The company tried deploying a chatbot. But when a client asked "What's the status of my loan application?", the chatbot responded with a 5-step tutorial on how to log in and check. The client didn't want a tutorial. They wanted their status.

> *"I asked the AI about my loan and it told me how to look it up. I know how to look it up! I wanted you to just tell me the status."*
>
> Frustrated Seers Equity client

### What You'll Learn

This lab shows you the fundamental difference between a chatbot (explains how) and an agent (actually does it). You'll build an agent that queries real loan data and returns actual answers. This is the first step toward solving Seers Equity's client service challenges.

**What you'll build:** A loan application lookup agent with a SQL tool that queries your database.

Estimated Time: 10 minutes

### Objectives

* Create sample loan application data for the agent to query
* Build an agent with a SQL tool
* See the agent look up real loan information
* Understand why execution beats explanation

### Prerequisites

This lab assumes you have:

* An AI profile named `genai` already configured with your AI provider credentials

## Task 1: Create the Loan Applications Table

First, let's create a loan applications table. This gives the agent something real to work with, the kind of data that a chatbot would never be able to access.

1. Create the loan applications table.

    ```sql
    <copy>
    CREATE TABLE loan_applications (
        application_id     VARCHAR2(20) PRIMARY KEY,
        applicant_name     VARCHAR2(100),
        application_date   DATE,
        loan_status        VARCHAR2(30),
        loan_amount        NUMBER(12,2),
        loan_type          VARCHAR2(30)
    );
    </copy>
    ```

2. Add comments so Select AI understands what this table contains.

    >**Note:** Select AI reads table and column comments to understand your schema. Good comments make the AI smarter about your data.

    ```sql
    <copy>
    COMMENT ON TABLE loan_applications IS 'Seers Equity loan applications including status tracking and amounts';
    COMMENT ON COLUMN loan_applications.application_id IS 'Unique application identifier like LOAN-12345';
    COMMENT ON COLUMN loan_applications.applicant_name IS 'Full name of the person or business applying for the loan';
    COMMENT ON COLUMN loan_applications.application_date IS 'Date the loan application was submitted';
    COMMENT ON COLUMN loan_applications.loan_status IS 'Current status: Pending, Under Review, Approved, or Denied';
    COMMENT ON COLUMN loan_applications.loan_amount IS 'Requested loan amount in dollars';
    COMMENT ON COLUMN loan_applications.loan_type IS 'Type of loan: Personal, Auto, Mortgage, or Business';
    </copy>
    ```

3. Add sample loan applications.

    ```sql
    <copy>
    INSERT INTO loan_applications VALUES ('LOAN-12345', 'Alex Chen', DATE '2025-01-02', 'Approved', 45000, 'Personal');
    INSERT INTO loan_applications VALUES ('LOAN-12346', 'Maria Santos', DATE '2025-01-03', 'Under Review', 275000, 'Mortgage');
    INSERT INTO loan_applications VALUES ('LOAN-12347', 'James Wilson', DATE '2024-12-28', 'Approved', 32000, 'Auto');
    INSERT INTO loan_applications VALUES ('LOAN-12348', 'Sarah Johnson', DATE '2025-01-04', 'Pending', 85000, 'Business');
    COMMIT;
    </copy>
    ```

4. Verify the data exists.

    ```sql
    <copy>
    SELECT application_id, applicant_name, loan_status, loan_amount, loan_type FROM loan_applications;
    </copy>
    ```

## Task 2: Add the Table to Your AI Profile

For Select AI to query your table, the profile needs to know about it. We'll add the table to your existing `genai` profile's object list.

1. Add the LOAN_APPLICATIONS table to the genai profile.

    >**Note:** The `object_list` tells Select AI which tables it can query. Without this, the AI won't know your table exists.

    ```sql
    <copy>
    BEGIN
        DBMS_CLOUD_AI.SET_ATTRIBUTE(
            profile_name    => 'genai',
            attribute_name  => 'object_list',
            attribute_value => '[{"owner": "' || USER || '", "name": "LOAN_APPLICATIONS"}]'
        );
    END;
    /
    </copy>
    ```

2. Verify the profile has the table.

    ```sql
    <copy>
    SELECT profile_name, status FROM USER_CLOUD_AI_PROFILES WHERE profile_name = 'genai';
    </copy>
    ```

## Task 3: Create the Agent Components

Now let's build an agent that can query this data. We need four pieces: a tool, an agent, a task, and a team.

1. Create the SQL tool. This gives the agent the ability to query your database.

    ```sql
    <copy>
    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
            tool_name   => 'LOAN_LOOKUP',
            attributes  => '{"tool_type": "SQL",
                            "tool_params": {"profile_name": "genai"}}',
            description => 'Query the LOAN_APPLICATIONS table. Columns: APPLICATION_ID, APPLICANT_NAME, APPLICATION_DATE, LOAN_STATUS (Pending/Under Review/Approved/Denied), LOAN_AMOUNT, LOAN_TYPE (Personal/Auto/Mortgage/Business).'
        );
    END;
    /
    </copy>
    ```

2. Create the agent with a clear role.

    ```sql
    <copy>
    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_AGENT(
            agent_name  => 'LOAN_AGENT',
            attributes  => '{"profile_name": "genai",
                            "role": "You are a loan application assistant for Seers Equity. Always use the LOAN_LOOKUP tool to query the database and provide answers. Never ask clarifying questions - just query the data and report what you find."}',
            description => 'Agent that looks up loan application information'
        );
    END;
    /
    </copy>
    ```

3. Create the task that tells the agent what to do and which tools to use.

    ```sql
    <copy>
    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_TASK(
            task_name   => 'LOAN_TASK',
            attributes  => '{"instruction": "Answer questions about Seers Equity loan applications by querying the LOAN_APPLICATIONS table using the LOAN_LOOKUP tool. The table has columns: APPLICATION_ID, APPLICANT_NAME, APPLICATION_DATE, LOAN_STATUS (Pending, Under Review, Approved, Denied), LOAN_AMOUNT, LOAN_TYPE (Personal, Auto, Mortgage, Business). Do not ask clarifying questions - query the data and provide the answer. User question: {query}",
                            "tools": ["LOAN_LOOKUP"]}',
            description => 'Task for handling loan application inquiries'
        );
    END;
    /
    </copy>
    ```

4. Create the team that connects everything together.

    ```sql
    <copy>
    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_TEAM(
            team_name   => 'LOAN_TEAM',
            attributes  => '{"agents": [{"name": "LOAN_AGENT", "task": "LOAN_TASK"}],
                            "process": "sequential"}',
            description => 'Team for loan application inquiries'
        );
    END;
    /
    </copy>
    ```

5. Verify everything is created.

    ```sql
    <copy>
    SELECT tool_name, status FROM USER_AI_AGENT_TOOLS WHERE tool_name = 'LOAN_LOOKUP';
    SELECT agent_name, status FROM USER_AI_AGENTS WHERE agent_name = 'LOAN_AGENT';
    SELECT task_name, status FROM USER_AI_AGENT_TASKS WHERE task_name = 'LOAN_TASK';
    SELECT agent_team_name, status FROM USER_AI_AGENT_TEAMS WHERE agent_team_name = 'LOAN_TEAM';
    </copy>
    ```

## Task 4: See the Agent in Action

Now let's see the difference between an agent and a chatbot.

1. Set the team for your session.

    ```sql
    <copy>
    EXEC DBMS_CLOUD_AI_AGENT.SET_TEAM('LOAN_TEAM');
    </copy>
    ```

2. Ask about a specific loan application.

    **This is the key moment.** The agent doesn't explain *how* to check loan status. It actually queries the loan_applications table and tells you the answer.

    ```sql
    <copy>
    SELECT AI AGENT What is the status of loan application LOAN-12345;
    </copy>
    ```

3. Ask about another application.

    ```sql
    <copy>
    SELECT AI AGENT How much did James Wilson apply for;
    </copy>
    ```

4. Ask a question that requires reasoning over data.

    ```sql
    <copy>
    SELECT AI AGENT Which loan applications are still pending or under review;
    </copy>
    ```

## Task 5: See What Happened Behind the Scenes

The agent used a tool to get real answers. Let's see the evidence.

1. Check the tool execution history.

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

2. Check the team execution history.

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

## Task 6: The Chatbot vs Agent Difference

**A chatbot would say:**

> "To check the status of a loan application, you would typically:
> 1. Log into the Seers Equity portal
> 2. Navigate to Application Status
> 3. Enter your application ID
> 4. View the current status"

**The agent said:**

> "Loan application LOAN-12345 for Alex Chen was submitted on January 2, 2025 for a $45,000 personal loan. Current status: Approved."

Same question. One explains the process. The other runs it.

That's what makes an agent an agent. It doesn't just know things. It *does* things. And that's exactly what Seers Equity's clients need.

## Summary

In this lab, you experienced the fundamental nature of AI agents:

* Created a loan applications table with descriptive comments for Select AI
* Added the table to your AI profile's object_list
* Built an agent with access to a SQL tool
* Watched it query real loan data to answer questions
* Saw the execution history proving it took action
* Understood the difference between explanation and execution

**Key takeaway:** An agent acts on your systems. A chatbot explains how you could act on your systems. That's the difference that matters for Seers Equity, and for your business.

## Learn More

* [DBMS_CLOUD_AI_AGENT Package](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/dbms-cloud-ai-agent-package.html)

## Acknowledgements

* **Author** - David Start
* **Last Updated By/Date** - David Start, January 2026

## Cleanup (Optional)

```sql
<copy>
EXEC DBMS_CLOUD_AI_AGENT.DROP_TEAM('LOAN_TEAM', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TASK('LOAN_TASK', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_AGENT('LOAN_AGENT', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('LOAN_LOOKUP', TRUE);
DROP TABLE loan_applications PURGE;
</copy>
```
