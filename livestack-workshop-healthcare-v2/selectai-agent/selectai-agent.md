# Build a Healthcare Agent with Select AI Agent

## Introduction

In Lab 7, Nina Patel used Select AI to ask one healthcare question at a time. She inspected the generated SQL, ran it against governed healthcare views, and refined the prompt until the result contained the service and region details needed for a capacity review.

That pattern works for an individual question, but Nina now needs a reusable healthcare operations assistant that an application can call consistently. Jessica, the DBA, does not want to give an AI system unrestricted database access. She gives Nina's agent one approved capability: a read-only SQL tool that uses the `GENAI` profile and the healthcare views configured in the previous lab.

In this lab, you register the SQL tool, create Nina's agent, task, and team, and run the same demand-risk question through the team. Oracle records the team run and tool calls so Nina can review the answer and Jessica can inspect how the assistant used its approved capability. The SQL still runs with the current database user's privileges.

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

| Step | Healthcare focus |
| --- | --- |
| Business Problem | Nina needs a repeatable assistant for healthcare demand and capacity questions. |
| Technical Challenge | The agent must use governed healthcare data through one approved, read-only capability. |
| Persona Focus | You follow Nina and Jessica as they turn the reviewed Select AI pattern into an assistant. |
| What You Will See | An agent receives a request, calls its SQL tool, returns an answer, and records its activity. |
| Database Capability | Select AI Agent, `DBMS_CLOUD_AI_AGENT`, AI profiles, and a built-in SQL tool. |
| Outcome | Nina has a controlled agent that can answer questions from the healthcare views. |

> **Prerequisite:** Complete [Lab 7: Ask Healthcare Questions with Select AI](?lab=selectai). This lab uses its `GENAI` profile and healthcare views. You create the agent, task, and team here.

<details>
<summary><strong>Repeating this lab?</strong></summary>

For your first run, continue to Task 1. To repeat the lab, run this block with **Run Script (F5)**. It removes only the four `NINA_HEALTHCARE_` objects listed below.

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

**Expected output:** `PL/SQL procedure successfully completed.`

</details>

## Task 1: Prepare the profile

In Lab 7, Nina used the `GENAI` profile to ask and review one question at a time. She now wants a reusable healthcare assistant. Before Jessica creates it, she confirms that the profile is available, configures it for the agent, and checks the healthcare views it will use.

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

2. Configure the profile for this lab:

    ```sql
    <copy>
    BEGIN
      DBMS_CLOUD_AI.SET_ATTRIBUTE(
        profile_name    => 'GENAI',
        attribute_name  => 'model',
        attribute_value => 'xai.grok-4.3'
      );
    END;
    /
    </copy>
    ```

    **Expected output:** `PL/SQL procedure successfully completed.`

3. Confirm the profile settings:

    ```sql
    <copy>
    SELECT profile_name,
           attribute_name,
           attribute_value
    FROM user_cloud_ai_profile_attributes
    WHERE profile_name = 'GENAI'
      AND attribute_name IN ('model', 'object_list')
    ORDER BY attribute_name;
    </copy>
    ```

    **Expected output:** Two rows: `model` is `xai.grok-4.3`, and `object_list` contains `CARE_DEMAND_FORECASTS_V`, `CARE_SERVICES_V`, `QUALITY_CAPACITY_SIGNALS_V`, and `CARE_SERVICE_REQUESTS_V`.

    The `object_list` gives the SQL tool focused schema context. Database privileges still decide which objects and rows the current user can read.

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

The SQL tool defines what the assistant can use. Jessica now defines who the assistant represents, what work it should perform, and how Oracle runs the pieces together.

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

    The agent's role directs it to answer from healthcare database results rather than invent values.

2. Confirm that the agent was created:

    ```sql
    <copy>
    SELECT agent_name,
           status
    FROM user_ai_agents
    WHERE agent_name = 'NINA_HEALTHCARE_AGENT';
    </copy>
    ```

    **Expected output:** One row for `NINA_HEALTHCARE_AGENT` with status `ENABLED`.

3. Create the read-only task:

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

    The task asks the agent to call the SQL tool once. Task 5 shows the actual call count.
  
4. Create the team:

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

    The team is the runnable unit. It connects Nina's agent to the read-only task and its approved SQL tool. An application can call the team with a healthcare question.
  
## Task 4: Run a healthcare demand question

Nina asks the assistant the refined demand-risk question from Lab 7. Reusing the question lets her compare the agent's answer with the SQL result she already reviewed. She requests the five highest-risk service-region forecasts as a table, with all five fields included.

In SQL Worksheet, call `DBMS_CLOUD_AI_AGENT.RUN_TEAM` with the team name.

1. Ask the agent:

    ```sql
    <copy>
    SELECT DBMS_CLOUD_AI_AGENT.RUN_TEAM(
             team_name   => 'NINA_HEALTHCARE_TEAM',
             user_prompt => 'Show the five care services with the highest demand risk. Include the service name, category, region, predicted demand, and demand risk factor. Return all five rows as a table with these five columns. Preserve every requested field, including category, in the final answer.',
             params      => '{"conversation_id": "' || DBMS_CLOUD_AI.CREATE_CONVERSATION() || '"}'
           ) AS agent_answer;
    </copy>
    ```

    The query creates a conversation ID and passes it to `RUN_TEAM`. The ID lets Oracle record the prompt and response together in the agent conversation history.

2. Review the agent's answer.

    **Expected output:** Five rows with service name, category, region, predicted demand, and demand risk factor. The first row is `mRNA LNP Clinical Batch` in the `Northeast Corridor`, with demand `2578` and risk factor `2.06`. Compare every field with the table in Lab 7, Task 5.
  
    > **Data sharing:** The agent uses the configured provider to process its request and tool results. Use it only with approved data.

## Task 5: Inspect what the agent did

Nina has an answer, but Jessica also needs an execution trail. Together they inspect the team run and tool calls recorded by Oracle AI Database.

1. Review the latest runs of the healthcare team:

    ```sql
    <copy>
    SELECT team_name,
         team_exec_id,
         state,
         start_date,
         end_date
    FROM user_ai_agent_team_history
    WHERE team_name = 'NINA_HEALTHCARE_TEAM'
    ORDER BY start_date DESC
    FETCH FIRST 5 ROWS ONLY;
    </copy>
    ```

    **Expected output:** The latest row shows `NINA_HEALTHCARE_TEAM`, state `SUCCEEDED`, and start and end times. Note its `TEAM_EXEC_ID` to match the run with its tool calls.

2. Review the SQL tool calls for that latest team run:

    ```sql
    <copy>
    SELECT tool_name,
         team_exec_id,
         invocation_id,
         agent_name,
         task_name,
         start_date,
         end_date
    FROM user_ai_agent_tool_history
    WHERE tool_name = 'NINA_HEALTHCARE_SQL_TOOL'
      AND team_exec_id = (
        SELECT team_exec_id
        FROM user_ai_agent_team_history
        WHERE team_name = 'NINA_HEALTHCARE_TEAM'
        ORDER BY start_date DESC
        FETCH FIRST 1 ROW ONLY
      )
    ORDER BY start_date DESC;
    </copy>
    ```

    **Expected output:** Rows for `NINA_HEALTHCARE_SQL_TOOL`, `NINA_HEALTHCARE_AGENT`, and `NINA_HEALTHCARE_TASK`, with the same `TEAM_EXEC_ID` as the latest team run. Count the rows to check how many tool calls occurred.

    The matching execution IDs link Nina's request to the approved tool calls. Nina can trace the answer to the tool, while Jessica can review when each call started and ended. The assistant's database activity has a visible execution record.

## Optional challenge: Compare the regions

Rerun the Task 4 query, replacing only `user_prompt` with: `Among the five care-service forecast rows with the highest demand risk factor, which regions appear more than once? Return each repeated region and its count within those five rows.`

**Expected output:** `New York Metro` appears twice among the top five forecasts.

## Conclusion: Build an Assistant You Can Review

Congratulations on completing this lab! You registered a SQL tool, created Nina's agent, task, and team, and asked a healthcare demand question. You compared the answer with Lab 7's results and inspected the team's execution history and tool calls.

Nina now has a reusable assistant that an application can call for capacity-planning questions, while Jessica can review its database activity.

## Next Steps

Read the [Oracle AI Database Select AI Agent documentation](https://docs.oracle.com/en/database/oracle/oracle-database/26/selai/).

## Acknowledgements

* **Author** - Linda Foinding, Principal Product Manager, Oracle Database Product Management
* **Last Updated By/Date** - Oracle Database Product Management, September 2026
