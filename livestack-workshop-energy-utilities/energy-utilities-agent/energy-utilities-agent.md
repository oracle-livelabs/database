# Build an Energy and Utilities Agent with Select AI Agent

## Introduction

Nina has used Select AI for one question at a time. She now wants a repeatable operations assistant. Jessica gives the agent one approved SQL tool that uses the narrow profile from Lab 7. The role and task text are instructions; LLUSER privileges and the Select AI SQL capability are the enforcement boundary for database access.

Estimated Time: **15 minutes**

<details>
<summary><strong>Key terms: agent, tool, task, and team</strong></summary>

> An **agent** has a role. A **tool** is a capability it may call. A **task** supplies instructions and binds approved tools. A **team** connects the agent and task into a runnable unit.

</details>

### Objectives

- Register a read-only utility SQL tool.
- Create Nina's agent, task, and team.
- Run a capacity-risk question.
- Inspect team and tool execution history.

### Hands-on Scenario

Nina asks the agent to review Gas Utility services with constrained capacity. Jessica verifies both the returned evidence and the record of the approved tool call.

> **SQL Worksheet reminder:** Return to [Getting Started Task 2](?lab=getting-started#Task2:OpenSQLWorksheet) if you need the launch and execution steps.

> **Platform prerequisite — live validation pending:** Live agent execution requires an enabled, LLUSER-accessible `EU_GENAI` profile, an approved provider credential and model, working provider connectivity, a governed Energy and Utilities `object_list`, and LLUSER access to `DBMS_CLOUD_AI_AGENT`. If `EU_GENAI` is unavailable, review the object definitions but do not run the creation or execution steps. The workshop loader does not create the profile, credentials, provider configuration, tool, agent, task, or team.

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

## Task 2: Register the SQL tool

The loader does not pre-create the tool, agent, task, or team. You create these learner-scoped objects in this lab.

1. Reset only this lab's Utilities agent catalog entries so the creation sequence is rerunnable.

    <copy>
    ```sql
    BEGIN
      BEGIN DBMS_CLOUD_AI_AGENT.DROP_TEAM('EU_NINA_UTILITIES_TEAM', TRUE); EXCEPTION WHEN OTHERS THEN NULL; END;
      BEGIN DBMS_CLOUD_AI_AGENT.DROP_TASK('EU_NINA_UTILITIES_TASK', TRUE); EXCEPTION WHEN OTHERS THEN NULL; END;
      BEGIN DBMS_CLOUD_AI_AGENT.DROP_AGENT('EU_NINA_UTILITIES_AGENT', TRUE); EXCEPTION WHEN OTHERS THEN NULL; END;
      BEGIN DBMS_CLOUD_AI_AGENT.DROP_TOOL('EU_NINA_UTILITIES_SQL_TOOL', TRUE); EXCEPTION WHEN OTHERS THEN NULL; END;
    END;
    /
    ```
    </copy>

2. Create the learner-scoped SQL tool.

    <copy>
    ```sql
    BEGIN
      DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
        tool_name   => 'EU_NINA_UTILITIES_SQL_TOOL',
        attributes  => '{"tool_type":"SQL","tool_params":{"profile_name":"EU_GENAI"}}',
        description => 'Read-only SQL access to the governed Energy and Utilities views'
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

1. Create the agent.

    <copy>
    ```sql
    BEGIN
      DBMS_CLOUD_AI_AGENT.CREATE_AGENT(
        agent_name  => 'EU_NINA_UTILITIES_AGENT',
        attributes  => '{"profile_name":"EU_GENAI","role":"You are Nina Patel''s Energy and Utilities operations assistant. Use only the approved SQL tool. Base every number on database results. Do not invent values or change data."}',
        description => 'Read-only operations evidence assistant for Nina Patel'
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
        description => 'Read-only Energy and Utilities review team'
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

    Expect three rows with `ENABLED` status. These objects exist because you created them in this lab, not because the loader installed them.

## Task 4: Run the capacity-risk question

1. Run the team in Database Actions SQL Worksheet.

    <copy>
    ```sql
    SELECT DBMS_CLOUD_AI_AGENT.RUN_TEAM(
             team_name   => 'EU_NINA_UTILITIES_TEAM',
             user_prompt => 'Review Gas Utility services with capacity at risk. Include service name, field logistics site, quantity on hand, quantity reserved, reorder point, and capacity status. Recommend which rows Nina should review first.',
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
    | Team history | The latest `EU_NINA_UTILITIES_TEAM` run reaches `SUCCEEDED`. |
    | Tool history | One or more calls name `EU_NINA_UTILITIES_SQL_TOOL`. |

## Task 5: Inspect what the agent did

1. Review the latest team execution.

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

2. Review the approved tool calls.

    <copy>
    ```sql
    WITH latest_team_run AS (
      SELECT team_exec_id
      FROM user_ai_agent_team_history
      WHERE team_name = 'EU_NINA_UTILITIES_TEAM'
      ORDER BY start_date DESC
      FETCH FIRST 1 ROW ONLY
    )
    SELECT h.team_exec_id,
           h.tool_name,
           h.invocation_id,
           h.agent_name,
           h.task_name,
           h.start_date,
           h.end_date
    FROM user_ai_agent_tool_history h
    JOIN latest_team_run r
      ON r.team_exec_id = h.team_exec_id
    WHERE h.tool_name = 'EU_NINA_UTILITIES_SQL_TOOL'
    ORDER BY h.start_date DESC,
             h.invocation_id DESC
    FETCH FIRST 10 ROWS ONLY;
    ```
    </copy>

> **Checkpoint:** A confident answer is not enough. Nina checks the cited values; Jessica checks that the approved tool ran and that the team completed. These history views record orchestration activity; they are not a compliance-grade audit trail. Regulated workflows need a durable action log and, where appropriate, Oracle Unified Auditing or Fine-Grained Auditing. Write access would require a separate narrow function tool, explicit approval, an idempotency key, and audited execution.

> **🎯 Interactive challenge:** Review the profile object list, task instruction, and tool history. Name one control at each layer that limits what the team can do.

<details>
<summary><strong>Challenge answer</strong></summary>

The profile limits the metadata supplied as model context, the task guides the agent toward the approved SQL tool, and tool history records the calls. These are useful layers, but prompt and task wording are not enforcement mechanisms. Tool configuration, database privileges, VPD, and row-level security enforce access.

</details>

## Conclusion: Give the agent a controlled way to work

Nina combined a role, task, team, and one read-only SQL tool. The profile object list, database privileges, and history views make the boundary visible and reviewable.

## Next Steps

Complete the final quiz, then use the appendix only if the facilitator asks you to reset the learner-scoped agent objects.

## Appendix: Reset the workshop objects

Run this block only when you need to recreate the four learner-scoped objects.

1. Run the reset only when the facilitator asks you to recreate the objects.

    <copy>
    ```sql
    BEGIN
      BEGIN DBMS_CLOUD_AI_AGENT.DROP_TEAM('EU_NINA_UTILITIES_TEAM', TRUE); EXCEPTION WHEN OTHERS THEN NULL; END;
      BEGIN DBMS_CLOUD_AI_AGENT.DROP_TASK('EU_NINA_UTILITIES_TASK', TRUE); EXCEPTION WHEN OTHERS THEN NULL; END;
      BEGIN DBMS_CLOUD_AI_AGENT.DROP_AGENT('EU_NINA_UTILITIES_AGENT', TRUE); EXCEPTION WHEN OTHERS THEN NULL; END;
      BEGIN DBMS_CLOUD_AI_AGENT.DROP_TOOL('EU_NINA_UTILITIES_SQL_TOOL', TRUE); EXCEPTION WHEN OTHERS THEN NULL; END;
    END;
    /
    ```
    </copy>

## Acknowledgements

* **Author** - Oracle Database Product Management
* **Last Updated By/Date** - Oracle Database Product Management, September 2026
