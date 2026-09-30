# Build an Energy and Utilities Operational Review Agent

## Introduction

Labs 1–6 established the database evidence behind an operational review. Lab 7 introduced a question-and-review workflow for the approved site, service, and capacity views. Jessica now helps Nina organize that workflow into an agent, a SQL tool, a task, and a team. Nina still decides what deserves attention; the agent is not authorized by its instructions to dispatch crews or change supplies.

The intended behavior is read-only operational review. This is not yet a verified security guarantee: the platform must check the actual tool execution path and effective database permissions before live use. Role and task text guide behavior; tool configuration, database privileges, VPD, and row-level security enforce access.

Estimated Time: **15 minutes**

<details>
<summary><strong>Key terms: agent, tool, task, and team</strong></summary>

> An **agent** has a role. A **tool** is a capability it may call. A **task** supplies instructions and binds approved tools. A **team** connects the agent and task into a runnable unit.

</details>

### Objectives

- Register a scoped utility SQL tool intended for read-only review, after platform readiness is confirmed.
- Create Nina's agent, task, and team.
- Run a capacity-risk question.
- Correlate one specific team run with its tool execution history.

### Hands-on Scenario

Nina needs a review queue of Gas Utility service/site pairs whose supplies are constrained. Jessica configures the workflow; Nina checks its evidence against database rows. The agent may summarize the evidence, but it must not turn a supply constraint into an unsupported claim that a customer will lose service.

> **SQL Worksheet reminder:** Return to [Getting Started Task 2](?lab=getting-started#Task2:OpenSQLWorksheet) if you need the launch and execution steps.
>
> **Platform prerequisite — live validation pending:** Live agent execution requires an enabled, LLUSER-accessible `EU_GENAI` profile, an approved provider credential and model, working provider connectivity, a governed Energy and Utilities `object_list`, and LLUSER access to `DBMS_CLOUD_AI_AGENT`. If `EU_GENAI` is unavailable, review the object definitions but do not run the creation or execution steps. The workshop loader does not create the profile, credentials, provider configuration, tool, agent, task, or team.
>
> **Data-use disclosure:** Select AI Agent sends the learner's prompt, the agent role and task instructions, and applicable schema metadata or other configured context to the AI provider. Do not include passwords, credentials, personal data, confidential operational details, or other sensitive information in prompts or instructions. Depending on the configured tool and provider path, returned database context may also be sent to the provider; use only approved data.

## Task 1: Check the profile context and authorization boundary

1. Confirm the profile and narrow object list from Lab 7.

    <copy>
    ```sql
    SELECT p.profile_name,
           p.status,
           a.attribute_value AS object_list
    FROM user_cloud_ai_profiles p
    JOIN user_cloud_ai_profile_attributes a
      ON a.profile_name = p.profile_name
    WHERE p.profile_name = 'EU_GENAI'
      AND a.attribute_name = 'object_list';
    ```
    </copy>

    The `object_list` supplies schema metadata as model context; it does not grant access and is not an authorization boundary. LLUSER privileges, the SQL tool configuration, and database controls such as Virtual Private Database (VPD) or row-level security enforce access.

2. Check that the approved context is the three LLUSER views `EU_FIELD_LOGISTICS_SITES_V`, `EU_ASSET_CAPACITY_V`, and `EU_UTILITY_SERVICES_V`. Do not add request-detail or reliability-signal objects. Stop if the profile is unavailable, the context differs from the approved configuration, or the facilitator has not confirmed the execution boundary. Being the owner of workshop tables can confer write privileges; a prompt saying “read-only” does not remove them.

## Task 2: Register the SQL tool

The loader does not pre-create the tool, agent, task, or team. You create these learner-scoped objects in this lab.

1. Check for an existing tool before creating it. If this query returns a row, stop and ask the facilitator to review the existing object. Do not drop or overwrite it.

    <copy>
    ```sql
    SELECT tool_name, status, description
    FROM user_ai_agent_tools
    WHERE tool_name = 'EU_NINA_UTILITIES_SQL_TOOL';
    ```
    </copy>

2. Create the learner-scoped SQL tool. In Database Actions, select the complete `BEGIN ... END;` block and its trailing `/`, then use **Run Script**. Use this method for each creation block in Task 3; use **Run Statement** for the `SELECT` queries.

    <copy>
    ```sql
    BEGIN
      DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
        tool_name   => 'EU_NINA_UTILITIES_SQL_TOOL',
        attributes  => '{"tool_type":"SQL","tool_params":{"profile_name":"EU_GENAI"}}',
        description => 'SQL tool for Energy and Utilities operational review; read-only enforcement requires platform verification'
      );
    END;
    /
    ```
    </copy>

3. Confirm that the tool is enabled.

    <copy>
    ```sql
    SELECT tool_name, status, description
    FROM user_ai_agent_tools
    WHERE tool_name = 'EU_NINA_UTILITIES_SQL_TOOL';
    ```
    </copy>

## Task 3: Create Nina's agent, task, and team

The role and task instructions guide the model; they are not security controls. The registered tool, LLUSER privileges, and database security policies determine what the team can access or execute.

Before running the creation blocks, run the scoped catalog query in step 4. If it returns any rows, stop and ask the facilitator to review those existing names. This lab does not silently reset catalog objects or their histories.

1. Create the agent.

    <copy>
    ```sql
    BEGIN
      DBMS_CLOUD_AI_AGENT.CREATE_AGENT(
        agent_name  => 'EU_NINA_UTILITIES_AGENT',
        attributes  => '{"profile_name":"EU_GENAI","role":"You are Nina Patel''s Energy and Utilities operations assistant. Use only the approved SQL tool. Base every number on database results. Do not invent values or change data."}',
        description => 'Operational review assistant for Nina Patel; intended read-only behavior'
      );
    END;
    /
    ```
    </copy>

2. Create the task.

    <copy>
    ```sql
    BEGIN
      DBMS_CLOUD_AI_AGENT.CREATE_TASK(
        task_name   => 'EU_NINA_UTILITIES_TASK',
        attributes  => '{"instruction":"Answer this operations question: {query}. Call EU_NINA_UTILITIES_SQL_TOOL at least once to obtain database evidence; make additional calls only when they answer a distinct part of the question. Return a concise review queue supported by the database rows. Do not request or claim insert, update, or delete operations, and do not invent records.","tools":["EU_NINA_UTILITIES_SQL_TOOL"],"enable_human_tool":"false"}',
        description => 'Answer read-only utility operations questions'
      );
    END;
    /
    ```
    </copy>

3. Create the team.

    <copy>
    ```sql
    BEGIN
      DBMS_CLOUD_AI_AGENT.CREATE_TEAM(
        team_name   => 'EU_NINA_UTILITIES_TEAM',
        attributes  => '{"agents":[{"name":"EU_NINA_UTILITIES_AGENT","task":"EU_NINA_UTILITIES_TASK"}],"process":"sequential"}',
        description => 'Energy and Utilities operational review team'
      );
    END;
    /
    ```
    </copy>

4. Confirm that the learner-created agent, task, and team are enabled.

    <copy>
    ```sql
    SELECT 'AGENT' AS object_type,
           agent_name AS object_name,
           status
    FROM user_ai_agents
    WHERE agent_name = 'EU_NINA_UTILITIES_AGENT'
    UNION ALL
    SELECT 'TASK',
           task_name,
           status
    FROM user_ai_agent_tasks
    WHERE task_name = 'EU_NINA_UTILITIES_TASK'
    UNION ALL
    SELECT 'TEAM',
           agent_team_name,
           status
    FROM user_ai_agent_teams
    WHERE agent_team_name = 'EU_NINA_UTILITIES_TEAM'
    ORDER BY object_type;
    ```
    </copy>

    After successful creation, check for three rows with `ENABLED` status. These objects should exist because you created them in this lab, not because the loader installed them. This checkpoint remains unverified until live environment validation.

## Task 4: Run the capacity-risk question

1. Note the start time of your run so you can identify it in Task 5. Run the team in Database Actions SQL Worksheet only after the facilitator confirms platform readiness. The question stays within the capacity view, which already contains service and site information.

    <copy>
    ```sql
    SELECT DBMS_CLOUD_AI_AGENT.RUN_TEAM(
             team_name   => 'EU_NINA_UTILITIES_TEAM',
             user_prompt => 'Using EU_ASSET_CAPACITY_V, review Gas Utility service/site rows whose capacity_status is AT_RISK or OUT_OF_STOCK. Include utility_service_id, utility_service_name, field_logistics_site_id, field_logistics_site_name, quantity_on_hand, quantity_reserved, reorder_point, and capacity_status. Put OUT_OF_STOCK before AT_RISK, then quantity_on_hand minus quantity_reserved ascending, then service ID and site ID ascending. Explain why these rows deserve review without claiming a service outage or changing data.',
             params      => '{"conversation_id":"' ||
                            DBMS_CLOUD_AI.CREATE_CONVERSATION() || '"}'
           ) AS agent_answer
    FROM dual;
    ```
    </copy>

2. Confirm the answer cites database values from the approved views. Wording, row order, and the number of justified tool calls may vary.

    **Expected output pattern**

    | Evidence | Stable check |
    | --- | --- |
    | Answer | Names a service and site with capacity fields from the database. |
    | Team history | Your identified `EU_NINA_UTILITIES_TEAM` run reaches `SUCCEEDED`; inspect other states rather than claiming success. |
    | Tool history | Calls for that same run name `EU_NINA_UTILITIES_SQL_TOOL`; investigate missing or unexpected evidence. |

## Task 5: Inspect what the agent did

1. List recent executions of this lab's team. Match the time to your run and record its `TEAM_EXEC_ID`. Do not assume the newest row is yours when learners share a schema. If you cannot identify your run unambiguously, stop and ask the facilitator.

    <copy>
    ```sql
    SELECT team_name,
           team_exec_id,
           state,
           start_date,
           end_date
    FROM user_ai_agent_team_history
    WHERE team_name = 'EU_NINA_UTILITIES_TEAM'
    ORDER BY start_date DESC,
             team_exec_id DESC
    FETCH FIRST 5 ROWS ONLY;
    ```
    </copy>

2. Replace `PASTE_YOUR_TEAM_EXEC_ID` below with the exact identifier you recorded, keeping the single quotes. Review calls for that run only. The join also confirms that the identifier belongs to this lab's team.

    <copy>
    ```sql
    SELECT h.team_exec_id,
           h.tool_name,
           h.invocation_id,
           h.agent_name,
           h.task_name,
           h.start_date,
           h.end_date
    FROM user_ai_agent_tool_history h
    JOIN user_ai_agent_team_history r
      ON r.team_exec_id = h.team_exec_id
    WHERE r.team_name = 'EU_NINA_UTILITIES_TEAM'
      AND r.team_exec_id = 'PASTE_YOUR_TEAM_EXEC_ID'
    ORDER BY h.start_date,
             h.invocation_id;
    ```
    </copy>

> **Checkpoint:** A confident answer is not enough. Nina checks the cited values; Jessica checks the state and tool calls for the same identified run. `SUCCEEDED` reports completion, not business correctness. History records orchestration activity; it is not, by itself, a compliance audit trail or proof that read-only access was enforced.

> **🎯 Interactive challenge:** Review the object list, task instruction, tool configuration, database privileges, and run history. Which supply context or evidence, and which actually enforce access?

<details>
<summary><strong>Challenge answer</strong></summary>

The profile limits the metadata supplied as model context, the task guides the agent toward the approved SQL tool, and tool history records the calls. These are useful layers, but prompt and task wording are not enforcement mechanisms. Tool configuration, database privileges, VPD, and row-level security enforce access.

</details>

## Conclusion: Give the agent a controlled way to work

The intended workflow combines a role, task, team, and scoped SQL tool so Nina can review capacity evidence. Jessica must still verify permissions and the tool execution path. Live creation, execution, answers, tool calls, run history, and read-only enforcement remain environment-validation pending. No successful agent result is assumed in this lab.

## Next Steps

Complete the final quiz. If the environment is not ready, distinguish the workflow you reviewed from behavior you have actually executed. Ask the facilitator to handle any later reset; this lab does not delete learner objects or histories.

## Acknowledgements

* **Author** - Oracle Database Product Management
* **Last Updated By/Date** - Oracle Database Product Management, September 2026
