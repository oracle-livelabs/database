# Build a Hospitality Agent with Select AI Agent

![Nina — hospitality lab banner](images/nina.png)

## Introduction

Nina Patel has used Select AI for individual questions. Her guest-review screen now needs an assistant that can handle a request and follow-up questions.

Jessica, the DBA, does not want to give an AI system unrestricted access to the database. She gives Nina's agent one approved tool: a SQL tool that uses the `GENAI` profile and the hospitality tables configured in the previous lab.

In this lab, you create an agent, give it the built-in SQL query tool, and run a question through its team. The instructions ask for read-only answers. SQL still runs with the database user’s privileges. `LLUSER` owns the workshop objects, so it is not an example of a production account with restricted access.

<details>
<summary><strong>Key terms: agent, tool, task, and team</strong></summary>

> - An **agent** is a configured role that follows instructions when it handles a request.
>
> - A **tool** is a capability the agent is allowed to call. In this lab, the tool runs SQL through the `GENAI` profile.
>
> - A **task** tells the agent what to do and which tools it may use.
>
> - A **team** connects the agent and task so an application or SQL session can run them together.

</details>

### Objectives

- Confirm that the `GENAI` profile from the previous lab is available.
- Verify which hospitality tables the SQL tool may use.
- Register a read-only SQL tool for the hospitality schema.
- Create an agent, task, and team with `DBMS_CLOUD_AI_AGENT`.
- Run a hospitality question through the team.
- Review the agent's tool history and explain why the tool boundary matters.

Estimated Time: **15 minutes**

### Hands-on Scenario

| Step                | Hospitality focus                                                                                  |
| ------------------- | ---------------------------------------------------------------------------------------------- |
| Business Problem    | Nina needs a hospitality answer that can feed a guest-review screen.                            |
| Technical Challenge | The agent must use database data through an approved capability, not unrestricted access.      |
| Persona Focus       | You follow Nina as she turns a Select AI question into a small hospitality assistant.              |
| What You Will See   | An agent receives a request, calls its SQL tool, and returns a hospitality answer.                 |
| Database Capability | Select AI Agent, `DBMS_CLOUD_AI_AGENT`, AI profiles, and a built-in SQL tool.                   |
| Outcome             | Nina has a controlled agent that can answer questions from the hospitality schema.                |

> **Prerequisite:** Complete [Lab 7: Ask Hospitality Questions with Select AI](?lab=selectai). This lab uses the `GENAI` profile and its `object_list`.

## Task 1: Check the profile and table access

The agent's SQL tool uses the existing `GENAI` profile. The profile's `object_list` limits the tables Select AI may use when it generates SQL. Database privileges provide the second control: the SQL still runs as the current database user and cannot read tables that user cannot access.

1. Check the profile:

    ```sql
    <copy>
    SELECT profile_name,
           status
    FROM user_cloud_ai_profiles
    WHERE profile_name = 'GENAI';
    </copy>
    ```

    The profile should be enabled. If it is not present, complete Lab 7 first or ask the DBA which profile to use.

2. Check the tables listed in the profile:

    ```sql
    <copy>
    SELECT profile_name,
           attribute_name,
           attribute_value
    FROM user_cloud_ai_profile_attributes
    WHERE profile_name = 'GENAI'
      AND attribute_name = 'object_list';
    </copy>
    ```

    The list should contain only the workshop tables needed for this lab: `STAY_OFFERS`, `RESERVATIONS`, `RESERVATION_NIGHTS`, and `GUESTS`. The `object_list` guides SQL generation; it is not a replacement for database grants.

3. Check the agent objects already in your schema:

    ```sql
    <copy>
    SELECT agent_name,
           status
    FROM user_ai_agents
    ORDER BY agent_name;
    </copy>
    ```

  The workshop objects use names beginning with `NINA_HOSPITALITY_`. If you already ran this lab, you can reuse the existing objects or run the reset block in the appendix before starting again.

## Task 2: Register the SQL tool

The SQL tool is the agent's only database capability in this lab. It uses the `GENAI` profile, so the profile's object list limits the schema metadata available for generated SQL.

1. Register the tool:

    ```sql
    <copy>
    BEGIN
      DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
        tool_name   => 'NINA_HOSPITALITY_SQL_TOOL',
        attributes  => '{"tool_type": "SQL", "tool_params": {"profile_name": "genai"}}',
        description => 'Read-only SQL access to the workshop hospitality tables'
      );
    END;
    /
    </copy>
    ```

    The tool lets the agent ask Select AI to generate and run SQL. It uses the profile’s table list and the current database user’s privileges.
  
2. Confirm the tool definition:

    ```sql
    <copy>
    SELECT tool_name,
           status,
           description
    FROM user_ai_agent_tools
    WHERE tool_name = 'NINA_HOSPITALITY_SQL_TOOL';
    </copy>
    ```
  
## Task 3: Create Nina's agent, task, and team

The tool by itself does nothing. Nina's agent needs a role, a task needs instructions, and a team connects the two.

1. Create the agent:

    ```sql
    <copy>
    BEGIN
      DBMS_CLOUD_AI_AGENT.CREATE_AGENT(
        agent_name  => 'NINA_HOSPITALITY_AGENT',
        attributes  => '{"profile_name": "genai", "role": "You are Nina Patel''s hospitality data assistant. Answer questions using the approved SQL tool. Use database results for stay offer, reservation, nightly charge, and guest facts. Do not invent values."}',
        description => 'Hospitality assistant for Nina Patel'
      );
    END;
    /
    </copy>
    ```

2. Create the task:

    ```sql
    <copy>
    BEGIN
      DBMS_CLOUD_AI_AGENT.CREATE_TASK(
        task_name  => 'NINA_HOSPITALITY_TASK',
        attributes => '{"instruction": "Answer Nina''s hospitality question: {query}. Use NINA_HOSPITALITY_SQL_TOOL once to retrieve the required data. Return a concise answer based on the database result. Do not repeat the same tool call and do not make changes to database records.", "tools": ["NINA_HOSPITALITY_SQL_TOOL"], "enable_human_tool": "false"}',
        description => 'Answer read-only stay offer and guest questions'
      );
    END;
    /
    </copy>
    ```
  
3. Create the team:

    ```sql
    <copy>
    BEGIN
      DBMS_CLOUD_AI_AGENT.CREATE_TEAM(
        team_name  => 'NINA_HOSPITALITY_TEAM',
        attributes => '{"agents": [{"name": "NINA_HOSPITALITY_AGENT", "task": "NINA_HOSPITALITY_TASK"}], "process": "sequential"}',
        description => 'Read-only hospitality question team'
      );
    END;
    /
    </copy>
    ```

    The team is the runnable unit. It connects Nina's role, the task instructions, and the SQL tool.
  
## Task 4: Run a hospitality question

Database Actions does not support the `SELECT AI AGENT` command directly. Use `DBMS_CLOUD_AI_AGENT.RUN_TEAM` in SQL Worksheet and provide the team name in the function call.

1. Ask the agent:

    ```sql
    <copy>
    SELECT DBMS_CLOUD_AI_AGENT.RUN_TEAM(
             team_name   => 'NINA_HOSPITALITY_TEAM',
             user_prompt => 'Which five stay offers have the highest booked room revenue? Sum reservation_nights.line_total only for confirmed, checked_in, or checked_out reservations. Include the stay offer name, category, total revenue, and room nights booked.',
             params      => '{"conversation_id": "' || DBMS_CLOUD_AI.CREATE_CONVERSATION() || '"}'
           ) AS agent_answer;
    </copy>
    ```

    ![SQL Worksheet result — agent answer](images/sql-agent-answer.jpg)

    *Scroll the result grid to inspect additional rows and columns.*
  
    Database Actions does not keep an agent conversation ID for this call, so the query creates one and passes it to `RUN_TEAM`. The ID lets Oracle record the prompt and response in the agent conversation history.

    

2. Review the answer.

    Look for the stay offer ranking, category, revenue, and room nights booked. The exact wording may vary because an AI provider generates the response, but the answer should be based on the hospitality tables available through `GENAI`.
  
    > **Note:** This team has a read-only SQL tool. It can query the data, but the task instructions do not give it a tool for inserting, updating, or deleting records.

3. Optional challenge: ask a follow-up question that connects the highest-revenue stay offer to its guests and reservations. A more detailed request may take longer because the agent has to interpret more steps.

## Task 5: Inspect what the agent did

Nina needs more than a final answer. She also wants to know whether the agent called the approved tool and how the request was processed.

1. Review the latest team runs:

    ```sql
    <copy>
    SELECT team_name,
         team_exec_id,
         state,
         start_date,
         end_date
    FROM user_ai_agent_team_history
    ORDER BY start_date DESC
    FETCH FIRST 5 ROWS ONLY;
    </copy>
    ```

    ![SQL Worksheet result — agent history](images/sql-agent-history.jpg)

    *Scroll the result grid to inspect additional rows and columns.*

    

2. Review the latest tool calls:

    ```sql
    <copy>
    SELECT tool_name,
         invocation_id,
         agent_name,
         task_name,
         start_date,
         end_date
    FROM user_ai_agent_tool_history
    ORDER BY start_date DESC
    FETCH FIRST 10 ROWS ONLY;
    </copy>
    ```

    ![SQL Worksheet result — agent tools](images/sql-agent-tools.jpg)

    *Scroll the result grid to inspect additional rows and columns.*

  

  The history should show `NINA_HOSPITALITY_SQL_TOOL`. Nina and Jessica can use it to check which tool the agent called.

## Conclusion: Give the agent a controlled way to work

In Lab 7, Nina used Select AI to turn a question into SQL. In this lab, she gave an agent a role, a task, and one approved SQL tool. The agent can handle a broader request and decide when it needs database information, while the database still controls the profile, object list, privileges, and tool history.

The application can call this assistant with a request. Jessica can review its tools and disable the tool or team when access is no longer needed.

Two controls apply to table access. The profile’s `object_list` guides which tables the tool considers. Database grants and row-level policies determine which data the session can read. Give an application agent only the access it needs.

The example remains read-only on purpose. Before an agent is allowed to change data, the team should add a narrowly defined function tool, clear instructions, and a confirmation step for the user.

## Appendix: Reset the workshop objects

Run this block only if you want to recreate the objects used in this lab. It removes only the four names created here.

```sql
<copy>
BEGIN
  DBMS_CLOUD_AI_AGENT.DROP_TEAM('NINA_HOSPITALITY_TEAM', TRUE);
  DBMS_CLOUD_AI_AGENT.DROP_TASK('NINA_HOSPITALITY_TASK', TRUE);
  DBMS_CLOUD_AI_AGENT.DROP_AGENT('NINA_HOSPITALITY_AGENT', TRUE);
  DBMS_CLOUD_AI_AGENT.DROP_TOOL('NINA_HOSPITALITY_SQL_TOOL', TRUE);
END;
/
</copy>
```

## Next Steps

Read the [Oracle AI Database Select AI Agent documentation](https://docs.oracle.com/en/database/oracle/oracle-database/26/selai/).

## Acknowledgements

* **Author** - Matt Kowalik
* **Contributor** - Kevin Lazarz
* **Last Updated By/Date** - Matt Kowalik, September 2026
