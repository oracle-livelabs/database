# Build an Energy and Utilities Operational Review Agent

## Introduction

Nina Patel needs a repeatable way to review Gas Utility services whose supporting supplies are constrained. In Lab 7, she asked individual questions and checked the generated SQL and results. Jessica now helps her organize that work into an agent workflow with a defined role, an approved SQL tool, a task, and a team.

The business question remains specific: **which service/site combinations deserve operational review, and what database evidence supports that recommendation?** The agent can help gather and summarize evidence, while Nina checks the result and decides what needs further investigation.

In this lab, you define the workflow, run a capacity-risk question after platform readiness is confirmed, and inspect the execution history for that specific run. The workflow is not intended to dispatch crews, move supplies, update service requests, or predict that a customer will lose service.

The intended analysis is read-only, but that is not yet a verified security guarantee. Role and task instructions guide behavior; they do not enforce database permissions. Before live use, the platform must verify the tool’s execution path, effective privileges, and any applicable security policies.

Creating the tool, agent, task, and team changes the agent configuration. That setup is separate from the intended read-only analysis of operational data.

<details>
<summary><strong>Key terms: agent, tool, task, team, and execution history</strong></summary>

- An **agent** has a defined role and instructions that guide how it approaches a question. In this lab, its intended role is to support Energy and Utilities operational review.

- A **tool** is a capability the agent can call. This workflow uses a SQL tool intended to retrieve evidence from the approved utility views. Its configuration and effective database permissions determine what it can actually do.

- A **task** defines the work to perform and associates the approved tools with that work. Clear task instructions help keep the review focused, but they do not replace access controls.

- A **team** connects agents and tasks into a workflow that can be run.

- **Execution history** records information about workflow runs and tool activity. Correlating records to one specific run helps you inspect what happened instead of mixing evidence from different executions.

</details>

### Objectives

- Confirm platform readiness before creating or running the agent workflow.
- Register a scoped utility SQL tool intended for read-only operational review.
- Create the agent, task, and team for Nina’s capacity-review question.
- Run the workflow using approved workshop data.
- Correlate one specific team run with its tool execution history.
- Distinguish behavioral instructions from enforced permissions and verified execution evidence.

**Platform prerequisite — live validation pending**

Live execution requires an enabled, LLUSER-accessible `EU_GENAI` profile, an approved provider credential and model, working provider connectivity, an approved Energy and Utilities `object_list`, and the required LLUSER access to `DBMS_CLOUD_AI_AGENT`.

The platform must also verify the intended tool restrictions and effective permissions. If any prerequisite is unavailable or unverified, review the definitions as text only; do not run the creation or execution steps.

The workshop loader does not create the profile, credentials, provider configuration, tool, agent, task, or team.

**Security boundary**

The object list and instructions do not, by themselves, establish read-only access. Tool configuration, effective database privileges, and any applicable policies must enforce the approved scope.

Do not assume Virtual Private Database (VPD) or other row-level policies are configured unless the platform confirms them.

**Data-use disclosure**

Agent processing can send prompts, role and task instructions, and applicable schema metadata or other configured context to the AI provider. Depending on the tool and provider path, returned database values may also be sent.

Use only approved workshop data. Do not include passwords, credentials, personal data, confidential operational details, or other sensitive information in prompts or instructions.

Estimated Time: **15 minutes**

<video controls width="100%">
  <source src="https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/p/EcTjWk2IuZPZeNnD_fYMcgUhdNDIDA6rt9gaFj_WZMiL7VvxPBNMY60837hu5hga/n/c4u04/b/livelabsfiles/o/livestack/Videos/Finance/08-Finance%20Workshop_LAB-8_with-CC.mp4" type="video/mp4">
  Your browser does not support the video tag.
</video>

*The video uses a Finance example. Follow the E&U tasks below for this lab’s approved profile, views, and operational questions.*

### Hands-on Scenario

Jessica configures a workflow to help Nina review Gas Utility service/site combinations with constrained supplies. Nina checks the returned evidence against database rows rather than treating the agent’s explanation as an operational decision.

| Step | Energy & Utilities focus |
| --- | --- |
| Business Problem | Nina needs a repeatable review queue for utility services associated with constrained supplies. |
| Technical Challenge | Keep the workflow within its approved scope and trace its answer to the tool activity for a specific run. |
| Persona Focus | You work with Jessica to configure the workflow and with Nina to interpret its evidence. |
| What You Will Do | Define a SQL tool, agent, task, and team; run an approved question; and inspect the associated execution history. |
| Database Capability | Select AI Agent organizes agent roles, tools, tasks, and teams into a runnable workflow. |
| Outcome | Produce a traceable operational review supported by database evidence, without treating it as authorization to dispatch crews or change supplies. |


> **SQL Worksheet reminder:** Need a reminder on how to open and use the SQL Worksheet? Return to [Getting Started Task 2: Open SQL Worksheet](?lab=getting-started#Task2:OpenSQLWorksheet) for the step-by-step guide showing how to run SQL statements.


## Task 1: Check the profile context and authorization boundary

Before creating the workflow, Jessica confirms that it will use the approved profile and utility views from Lab 7. She also checks that the facilitator has verified the tool’s execution permissions—not just its instructions.

1. Inspect the profile status and object list.

    ```sql
    <copy>
    SELECT p.profile_name,
           p.status,
           a.attribute_value AS object_list
    FROM user_cloud_ai_profiles p
    JOIN user_cloud_ai_profile_attributes a
      ON a.profile_name = p.profile_name
    WHERE p.profile_name = 'EU_GENAI'
      AND a.attribute_name = 'object_list';
    </copy>
    ```

    **Expected output when configured:** A row for `EU_GENAI` with status `ENABLED` and the approved object list.

    If no row is returned, either the profile or its object-list attribute may be unavailable. Stop and ask the facilitator to investigate.

2. Confirm that the object list identifies these three views with owner `LLUSER`:

    - `EU_FIELD_LOGISTICS_SITES_V`
    - `EU_ASSET_CAPACITY_V`
    - `EU_UTILITY_SERVICES_V`

    Do not add request-detail, reliability-signal, or other objects. If the context differs from the approved configuration, stop before creating or running the workflow.

3. Confirm with the facilitator that the intended execution boundary has been verified.

    The object list supplies schema context; it does not grant database privileges or, by itself, demonstrate read-only enforcement. The SQL tool configuration, effective privileges, and any applicable database security policies must enforce the approved scope.

    This query does not inspect those controls or establish that Virtual Private Database (VPD) or other row-level policies are configured.

> **Checkpoint:** Owning workshop tables can confer write privileges. A role or prompt saying “read-only” does not remove those privileges. Do not continue to tool creation until the facilitator confirms the execution boundary.

## Task 2: Register the SQL tool

Jessica now registers the capability the agent will use to obtain database evidence. The workshop loader does not pre-create the tool, agent, task, or team; you create these learner-scoped configuration objects in this lab.

Creating a tool changes agent configuration. It is separate from the intended read-only analysis of operational data.

1. Check whether the named tool already exists.

    ```sql
    <copy>
    SELECT tool_name, status, description
    FROM user_ai_agent_tools
    WHERE tool_name = 'EU_NINA_UTILITIES_SQL_TOOL';
    </copy>
    ```

    If the query returns a row, stop and ask the facilitator to review the existing object. Do not drop, overwrite, or assume ownership of its configuration.

    Continue only if the query completes successfully with no rows and the prerequisites in Task 1 have been confirmed. A query error is not evidence that the tool is absent.

2. Create the SQL tool.

    In Database Actions, select the complete `BEGIN ... END;` block and its trailing `/`, then use **Run Script**. Use this method for the creation blocks in Task 3 as well. Use **Run Statement** for the `SELECT` queries.

    ```sql
    <copy>
    BEGIN
      DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
        tool_name   => 'EU_NINA_UTILITIES_SQL_TOOL',
        attributes  => '{"tool_type":"SQL","tool_params":{"profile_name":"EU_GENAI"}}',
        description => 'SQL tool for Energy and Utilities operational review; read-only enforcement requires platform verification'
      );
    END;
    /
    </copy>
    ```

    The definition associates the SQL tool with `EU_GENAI`. Its description documents the intended use; it does not impose a read-only permission restriction.

3. Query the tool metadata again.

    ```sql
    <copy>
    SELECT tool_name, status, description
    FROM user_ai_agent_tools
    WHERE tool_name = 'EU_NINA_UTILITIES_SQL_TOOL';
    </copy>
    ```

    Confirm that the named tool is present and enabled. If creation fails, the tool is missing, or its status is not enabled, stop and report the result to the facilitator.

> **Checkpoint:** An enabled tool is a configuration milestone, not proof that an agent run will succeed or that read-only behavior is enforced. Live execution and permission verification remain separate checks.

## Task 3: Create Nina's agent, task, and team

Jessica connects the approved SQL tool to an agent, a task, and a team. The role and task instructions describe the intended behavior; they do not enforce permissions. Tool configuration, effective database privileges, and applicable security policies determine what the workflow can access or execute.

Use **Run Statement** for the catalog queries. For each creation block, select the complete `BEGIN ... END;` block and its trailing `/`, then use **Run Script**.

1. Check whether any of the proposed agent, task, or team names already exist.

    ```sql
    <copy>
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
    </copy>
    ```

    Continue only if the query completes successfully with no rows. If any row appears, stop and ask the facilitator to review the existing objects. Do not drop, overwrite, or reset them or their histories.

2. Create the agent.

    ```sql
    <copy>
    BEGIN
      DBMS_CLOUD_AI_AGENT.CREATE_AGENT(
        agent_name  => 'EU_NINA_UTILITIES_AGENT',
        attributes  => '{"profile_name":"EU_GENAI","role":"You are Nina Patel''s Energy and Utilities operations assistant. Use only the approved SQL tool. Base every number on database results. Do not invent values or change data."}',
        description => 'Operational review assistant for Nina Patel; intended read-only behavior'
      );
    END;
    /
    </copy>
    ```

3. Create the task and associate it with the approved SQL tool.

    ```sql
    <copy>
    BEGIN
      DBMS_CLOUD_AI_AGENT.CREATE_TASK(
        task_name   => 'EU_NINA_UTILITIES_TASK',
        attributes  => '{"instruction":"Answer this operations question: {query}. Call EU_NINA_UTILITIES_SQL_TOOL at least once to obtain database evidence; make additional calls only when they answer a distinct part of the question. Return a concise review queue supported by the database rows. Do not request or claim insert, update, or delete operations, and do not invent records.","tools":["EU_NINA_UTILITIES_SQL_TOOL"],"enable_human_tool":"false"}',
        description => 'Answer read-only utility operations questions'
      );
    END;
    /
    </copy>
    ```

    The task requests database evidence and limits the intended behavior. Those instructions do not replace the platform’s permission checks or establish a human-approval gate.

4. Create the team that connects the agent and task.

    ```sql
    <copy>
    BEGIN
      DBMS_CLOUD_AI_AGENT.CREATE_TEAM(
        team_name   => 'EU_NINA_UTILITIES_TEAM',
        attributes  => '{"agents":[{"name":"EU_NINA_UTILITIES_AGENT","task":"EU_NINA_UTILITIES_TASK"}],"process":"sequential"}',
        description => 'Energy and Utilities operational review team'
      );
    END;
    /
    </copy>
    ```

5. Rerun the catalog query from step 1.

    After successful creation, expect three rows: one agent, one task, and one team, each with `ENABLED` status.

    If a creation block fails or an object is missing or disabled, stop and report the result. Earlier blocks may already have created objects; do not blindly rerun the entire sequence.

> **Checkpoint:** These objects are created by the learner, not installed by the loader. Enabled catalog entries confirm configuration state, not successful execution or read-only enforcement. This checkpoint remains unverified until live environment validation.

## Task 4: Run the capacity-risk question

Nina now asks the team for a focused review of Gas Utility services with constrained supplies. The capacity view already contains the service and site information needed for this question.

1. Confirm platform readiness with the facilitator, then record your run’s start time and timezone.

    Use **Run Statement** to execute the query below. It requests a new conversation for this invocation, so avoid repeated clicks or rerunning it while waiting for a result.

    ```sql
    <copy>
    SELECT DBMS_CLOUD_AI_AGENT.RUN_TEAM(
             team_name   => 'EU_NINA_UTILITIES_TEAM',
             user_prompt => 'Using EU_ASSET_CAPACITY_V, review Gas Utility service/site rows whose capacity_status is AT_RISK or OUT_OF_STOCK. Include utility_service_id, utility_service_name, field_logistics_site_id, field_logistics_site_name, quantity_on_hand, quantity_reserved, reorder_point, and capacity_status. Put OUT_OF_STOCK before AT_RISK, then quantity_on_hand minus quantity_reserved ascending, then service ID and site ID ascending. Explain why these rows deserve review without claiming a service outage or changing data.',
             params      => '{"conversation_id":"' ||
                            DBMS_CLOUD_AI.CREATE_CONVERSATION() || '"}'
           ) AS agent_answer
    FROM dual;
    </copy>
    ```

2. Review the returned answer against the question and database evidence.

    Confirm that it uses the requested category, capacity statuses, identifiers, and quantity fields. Check the requested ordering rather than assuming the agent followed it.

    Wording and the number of justified tool calls may vary. Missing fields, unsupported claims, or incorrect ordering are issues to investigate—not variations to accept without review.

    **Expected behavior to verify during live validation**

    | Evidence | What to verify |
    | --- | --- |
    | Answer scope | Uses Gas Utility service/site rows with `AT_RISK` or `OUT_OF_STOCK` capacity. |
    | Database values | Service and site identifiers, names, quantities, reorder points, and statuses match the supporting results. |
    | Ordering | Places `OUT_OF_STOCK` before `AT_RISK`, then sorts by net quantity, service ID, and site ID. |
    | Interpretation | Explains why the rows deserve review without claiming an outage or an operational action. |
    | Team history | The specific run identified in Task 5 reaches `SUCCEEDED`; other states require investigation. |
    | Tool history | Activity linked to that same run identifies `EU_NINA_UTILITIES_SQL_TOOL` and provides supporting evidence. |

    If no matching rows exist, the answer should report that outcome without inventing a service or site.

> **Checkpoint:** A plausible answer alone does not demonstrate a successful, correctly scoped run. In Task 5, correlate the answer with its specific team run and tool history. A `SUCCEEDED` status alone does not prove that the answer is correct or that no data was changed.

## Task 5: Inspect what the agent did

Nina checks whether the answer matches the database evidence. Jessica checks which workflow run produced it and which tools were called. Both checks matter: a plausible explanation does not establish how the agent obtained its answer.

1. List recent executions of this lab’s team.

    ```sql
    <copy>
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
    </copy>
    ```

    Compare the timestamps with the start time you recorded in Task 4, accounting for timezone differences. Record the matching `TEAM_EXEC_ID`.

    Do not assume the newest row is yours, especially when learners share a schema. Time alone may not uniquely identify a run. If your execution is not listed or cannot be identified unambiguously, stop and ask the facilitator.

2. Inspect tool activity for the identified run.

    Replace `PASTE_YOUR_TEAM_EXEC_ID` with the exact identifier you recorded, keeping the single quotes. The join checks that the identifier belongs to this lab’s team.

    ```sql
    <copy>
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
    </copy>
    ```

3. Review the team state and associated tool calls together.

    | Evidence | What to verify |
    | --- | --- |
    | `TEAM_EXEC_ID` | Matches the specific run you identified. |
    | Team state | Reports `SUCCEEDED` before you claim successful completion. Investigate other states with the facilitator. |
    | `TOOL_NAME` | Identifies `EU_NINA_UTILITIES_SQL_TOOL`. Investigate unexpected tools or missing calls. |
    | `AGENT_NAME` and `TASK_NAME` | Match the agent and task created for this lab. |
    | Invocation identifiers and timestamps | Distinguish the recorded calls within that run. |

    This query shows invocation metadata, not the executed SQL or returned database values. It can help trace tool activity, but it does not by itself verify the answer’s numbers or prove that every call was appropriate.

> **Checkpoint:** `SUCCEEDED` reports completion, not business correctness. History records orchestration activity; it is not, by itself, a compliance audit trail or proof that read-only access was enforced.

**🎯 Interactive challenge:** Review the object list, task instructions, tool configuration, database privileges, and run history. Which provide context, guidance, or evidence—and which can enforce access restrictions?

<details>
<summary><strong>Challenge answer</strong></summary>

- The **object list** supplies database context for SQL generation. Listing approved objects alone does not establish the complete authorization boundary.
- The **role and task instructions** guide behavior, including which tool to use and what question to answer. Instructions are not permission controls.
- The **run and tool histories** provide evidence of recorded workflow activity. The metadata queried here does not prove which SQL ran or whether data changed.
- The **tool’s implemented restrictions and effective database privileges** determine what operations are permitted. Applicable database policies can impose additional restrictions when configured.

Do not assume that Virtual Private Database (VPD), row-level policies, or read-only tool restrictions are present merely because the workshop mentions them. The platform must verify the actual configuration and execution path.

</details>

## Conclusion: Give the agent a controlled way to work

The intended workflow connects a role, task, team, and scoped SQL tool to help Nina review capacity evidence. Jessica checks the execution records and verifies the permissions behind that workflow; Nina checks the operational meaning of the answer.

Live creation, execution, answer accuracy, tool activity, run-history correlation, and read-only enforcement remain environment-validation pending. The definitions and queries in this lab do not establish that those checks have passed.

## Next Steps

Complete the final quiz. Distinguish the workflow you reviewed from any behavior you actually executed and verified.

Leave learner-created objects and histories intact. If a reset is needed, ask the facilitator to coordinate it; this lab does not delete them.

## Acknowledgements

* **Author** - Zileyah Onafowora
* **Last Updated By/Date** - Zileyah Onafowora, September 2026
