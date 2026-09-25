# Build a Healthcare Agent with Select AI Agent

## Introduction

In Lab 7, Nina Patel used Select AI to ask one healthcare question at a time. She inspected the generated SQL, ran it against governed healthcare views, and refined the prompt until the result contained the service and region details needed for a capacity review.

That pattern works for an individual question, but Nina now needs a reusable healthcare operations assistant that an application can call consistently. Jessica, the DBA, does not want to give an AI system unrestricted database access. She gives Nina's agent one approved capability: a read-only SQL tool that uses the `GENAI` profile and the healthcare views configured in the previous lab.

In this lab, you register the SQL tool, create Nina's agent, task, and team, and run the same demand-risk question through the team. Oracle records the team run and tool call so Nina can review the answer and Jessica can inspect how the assistant used its approved capability. The SQL still runs with the current database user's privileges.

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

- Confirm that the `GENAI` profile and healthcare views are available.
- Register a read-only SQL tool for the healthcare views.
- Create an agent, task, and team with `DBMS_CLOUD_AI_AGENT`.
- Run a healthcare demand question through the team.
- Review the team and tool history.

Estimated Time: **15 minutes**

### Hands-on Scenario

| Step                | Healthcare focus                                                                               |
| ------------------- | ---------------------------------------------------------------------------------------------- |
| Business Problem    | Nina needs a repeatable assistant for healthcare demand and capacity questions.                |
| Technical Challenge | The agent must use governed healthcare data through one approved, read-only capability.        |
| Persona Focus       | You follow Nina and Jessica as they turn the reviewed Select AI pattern into an assistant.      |
| What You Will See   | An agent receives a request, calls its SQL tool, returns an answer, and records its activity.  |
| Database Capability | Select AI Agent, `DBMS_CLOUD_AI_AGENT`, AI profiles, and a built-in SQL tool.                   |
| Outcome             | Nina has a controlled agent that can answer questions from the healthcare views.              |

> **Prerequisite:** Complete [Lab 7: Ask Healthcare Questions with Select AI](?lab=selectai). This lab uses the `GENAI` profile and its healthcare `object_list`.

## Task 1: Check the profile and table access

In Lab 7, Nina used the `GENAI` profile to ask and review one question at a time. She now wants a reusable healthcare assistant. Before Jessica creates it, she confirms the profile, healthcare views, and existing agent objects in the schema.

1. Confirm that the `GENAI` profile is available:

    ```sql
    <copy>
    SELECT profile_name,
           status
    FROM user_cloud_ai_profiles
    WHERE profile_name = 'GENAI';
    </copy>
    ```

    **Expected output:** `GENAI` appears with the status `ENABLED`. This is the same profile Nina used in Lab 7.

2. Check the healthcare views listed in the profile:

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

    **Expected output:** The list contains `CARE_DEMAND_FORECASTS_V`, `CARE_SERVICES_V`, `QUALITY_CAPACITY_SIGNALS_V`, and `CARE_SERVICE_REQUESTS_V`.

    The `object_list` gives the SQL tool focused schema context. Database privileges still decide which objects and rows the current user can read.

3. Check the agent objects already in your schema:

    ```sql
    <copy>
    SELECT agent_name,
           status
    FROM user_ai_agents
    ORDER BY agent_name;
    </copy>
    ```

    **Expected output:** The query returns any agents already defined in the schema. If no rows appear, continue. If a `NINA_HEALTHCARE_` object exists, use the reset block before recreating the lab objects.

    Review the result before creating anything. The objects in this lab use names beginning with `NINA_HEALTHCARE_`. If those names already exist, run the reset block in the appendix before continuing.

## Task 2: Register the SQL tool

Jessica gives the assistant one approved database capability: a read-only SQL tool. The tool uses the `GENAI` profile, so it works with the same healthcare views Nina reviewed in Lab 7.

1. Register the tool:

    ```sql
    <copy>
    BEGIN
      DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
        tool_name   => 'NINA_HEALTHCARE_SQL_TOOL',
        attributes  => '{"tool_type": "SQL", "tool_params": {"profile_name": "genai"}}',
        description => 'Read-only SQL access to the workshop healthcare operations views'
      );
    END;
    /
    </copy>
    ```

    **Expected output:** The block completes successfully and creates `NINA_HEALTHCARE_SQL_TOOL`.

    The tool does not create another data store. It gives the assistant a named path for generating and running SQL against the healthcare views. The current database user's privileges still apply when the SQL runs.
  
2. Confirm the tool definition:

    ```sql
    <copy>
    SELECT tool_name,
           status,
           description
    FROM user_ai_agent_tools
    WHERE tool_name = 'NINA_HEALTHCARE_SQL_TOOL';
    </copy>
    ```

    **Expected output:** `NINA_HEALTHCARE_SQL_TOOL` appears with the status `ENABLED` and a description of its read-only healthcare access.
  
## Task 3: Create Nina's agent, task, and team

The SQL tool defines what the assistant can use. Jessica now defines who the assistant represents, what work it may perform, and how Oracle runs the pieces together.

1. Create Nina's healthcare operations agent:

    ```sql
    <copy>
    BEGIN
      DBMS_CLOUD_AI_AGENT.CREATE_AGENT(
        agent_name  => 'NINA_HEALTHCARE_AGENT',
        attributes  => '{"profile_name": "genai", "role": "You are Nina Patel''s healthcare operations data assistant. Answer questions using the approved SQL tool. Use database results for care services, demand forecasts, quality and capacity signals, and service requests. Do not invent values."}',
        description => 'Healthcare operations assistant for Nina Patel'
      );
    END;
    /
    </copy>
    ```

    **Expected output:** The block completes successfully and creates `NINA_HEALTHCARE_AGENT`.

    The agent role tells the model to use healthcare database results and not invent values.

2. Create the read-only task:

    ```sql
    <copy>
    BEGIN
      DBMS_CLOUD_AI_AGENT.CREATE_TASK(
        task_name  => 'NINA_HEALTHCARE_TASK',
        attributes => '{"instruction": "Answer Nina''s healthcare operations question: {query}. Use NINA_HEALTHCARE_SQL_TOOL once to retrieve the required data. Return a concise answer based on the database result. Do not repeat the same tool call and do not make changes to database records.", "tools": ["NINA_HEALTHCARE_SQL_TOOL"], "enable_human_tool": "false"}',
        description => 'Answer read-only healthcare operations questions'
      );
    END;
    /
    </copy>
    ```

    **Expected output:** The block completes successfully and creates `NINA_HEALTHCARE_TASK`.

    The task permits one call to the approved SQL tool and explicitly prohibits changes to database records.
  
3. Create the team:

    ```sql
    <copy>
    BEGIN
      DBMS_CLOUD_AI_AGENT.CREATE_TEAM(
        team_name  => 'NINA_HEALTHCARE_TEAM',
        attributes => '{"agents": [{"name": "NINA_HEALTHCARE_AGENT", "task": "NINA_HEALTHCARE_TASK"}], "process": "sequential"}',
        description => 'Read-only healthcare operations question team'
      );
    END;
    /
    </copy>
    ```

    **Expected output:** The block completes successfully and creates `NINA_HEALTHCARE_TEAM`.

    The team is the runnable unit. It connects Nina's agent to the read-only task and its approved SQL tool.
  
## Task 4: Run a healthcare demand question

Nina asks the assistant the refined demand-risk question from Lab 7. Reusing the question lets her compare the agent's answer with the SQL result she already reviewed.

Database Actions does not support the `SELECT AI AGENT` command directly. In SQL Worksheet, call `DBMS_CLOUD_AI_AGENT.RUN_TEAM` and provide the team name.

1. Ask the agent:

    ```sql
    <copy>
    SELECT DBMS_CLOUD_AI_AGENT.RUN_TEAM(
             team_name   => 'NINA_HEALTHCARE_TEAM',
             user_prompt => 'Show the five care services with the highest demand risk. Include the service name, category, region, predicted demand, and demand risk factor.',
             params      => '{"conversation_id": "' || DBMS_CLOUD_AI.CREATE_CONVERSATION() || '"}'
           ) AS agent_answer;
    </copy>
    ```
    Database Actions does not keep an agent conversation ID for this call, so the query creates one and passes it to `RUN_TEAM`. The ID lets Oracle record the prompt and response in the agent conversation history.

2. Review the agent's answer.

    **Expected result:** The answer identifies five care service and region combinations and includes service name, category, predicted demand, and demand risk factor. `mRNA LNP Clinical Batch` in the `Northeast Corridor` should lead the result. The wording can vary by model, but the values should match the healthcare data available through `GENAI`.
  
    > **Note:** This team has a read-only SQL tool. It can query the data, but the task instructions do not give it a tool for inserting, updating, or deleting records.

3. Optional challenge: ask which regions appear more than once in the five highest-risk results. Compare the response with the rows from Lab 7.

## Task 5: Inspect what the agent did

Nina has an answer, but Jessica also needs an execution trail. Together they inspect the team run and tool call recorded by Oracle AI Database.

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

    **Expected output:** The latest row identifies `NINA_HEALTHCARE_TEAM`, its execution state, and its start and end times.

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

    **Expected output:** The latest tool history includes `NINA_HEALTHCARE_SQL_TOOL`, `NINA_HEALTHCARE_AGENT`, and `NINA_HEALTHCARE_TASK`.

    Nina can trace the answer to the approved tool, while Jessica can review when the call started and ended. The assistant is no longer an unexplained chat response. Its database activity has a visible execution record.

## Conclusion: Give the agent a controlled way to work

In Lab 7, Nina used Select AI to turn a question into SQL. In this lab, she gave an agent a role, a task, and one approved SQL tool. The agent can handle a broader request and decide when it needs database information, while the database still controls the profile, object list, privileges, and tool history.

That is the next step from Select AI to Select AI Agent: an application can call a defined healthcare operations assistant instead of assembling every question and database call itself. Jessica can review the tools available to the agent and remove access by disabling the tool or team.

The data boundary has two parts. The profile's `object_list` tells the SQL tool which healthcare views to consider, while database grants decide which objects and rows the session can read. Both should be kept narrow when an agent is used by an application.

The example remains read-only on purpose. Before an agent is allowed to change data, the team should add a narrowly defined function tool, clear instructions, and a confirmation step for the user.

## Appendix: Reset the workshop objects

Run this block only if you want to recreate the objects used in this lab. It removes only the four names created here.

1. Run the reset block:

    ```sql
    <copy>
BEGIN
  DBMS_CLOUD_AI_AGENT.DROP_TEAM('NINA_HEALTHCARE_TEAM', TRUE);
  DBMS_CLOUD_AI_AGENT.DROP_TASK('NINA_HEALTHCARE_TASK', TRUE);
  DBMS_CLOUD_AI_AGENT.DROP_AGENT('NINA_HEALTHCARE_AGENT', TRUE);
  DBMS_CLOUD_AI_AGENT.DROP_TOOL('NINA_HEALTHCARE_SQL_TOOL', TRUE);
END;
/
    </copy>
    ```

    **Expected output:** The block completes successfully and removes only the four `NINA_HEALTHCARE_` objects created in this lab.

## Next Steps

Read the [Oracle AI Database Select AI Agent documentation](https://docs.oracle.com/en/database/oracle/oracle-database/26/selai/).

## Acknowledgements

* **Author** - Linda Foinding, Principal Product Manager, Oracle Database Product Management
* **Last Updated By/Date** - Oracle Database Product Management, September 2026
