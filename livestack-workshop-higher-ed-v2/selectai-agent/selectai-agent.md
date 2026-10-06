# Build a Student-Support Agent with Select AI Agent

<!-- markdownlint-configure-file
{
  "MD013": {
    "code_blocks": false,
    "tables": false
  },
  "MD033": {
    "allowed_elements": [
      "details",
      "summary",
      "strong"
    ]
  }
}
-->

## Introduction

![Nina Patel and Jessica Chan introduce the student-support agent lab](images/nina.png)

Nina Patel has used Select AI to ask one student-support operations question at
a time. She now wants a repeatable assistant for questions about aggregate
campus workload and service capacity.

Jessica gives the agent one approved tool: a SQL tool that uses the `GENAI`
profile and its allow-list of summary views. The tool is read-only. The agent
cannot update requests, make admissions decisions, or determine what an
individual student should receive.

![A read-only agent uses one approved SQL tool and leaves an execution history](images/agent-boundary.svg)

<details>
<summary><strong>Key terms: agent, tool, task, and team</strong></summary>

> * An **agent** follows a configured role when it handles a request.
> * A **tool** is a capability the agent is allowed to call. This lab uses one
>   SQL tool.
> * A **task** tells the agent what to do and which tools it may use.
> * A **team** connects an agent and task so a SQL session or application can
>   run them together.

</details>

### Objectives

* Confirm that the `GENAI` profile and its view allow-list are available.
* Register a read-only SQL tool.
* Create an agent, task, and team with `DBMS_CLOUD_AI_AGENT`.
* Run an aggregate Higher Education operations question.
* Review team and tool history.

Estimated Time: **15 minutes**

### Hands-on Scenario

| Step | Higher Education focus |
| --- | --- |
| Business Problem | Nina needs repeatable answers about support operations and campus capacity. |
| Technical Challenge | The agent needs a narrow, reviewable way to query database information. |
| Persona Focus | You configure Nina's assistant with Jessica's access boundary. |
| What You Will See | An agent calls one SQL tool and records the execution history. |
| Database Capability | Select AI Agent, `DBMS_CLOUD_AI_AGENT`, profiles, and a built-in SQL tool. |
| Outcome | Nina has a controlled assistant for aggregate service-planning questions. |

> **Prerequisite:** Complete
> [Lab 7: Ask Student-Success Questions with Select AI](?lab=selectai). This lab
> uses the `GENAI` profile and its `object_list`.

## Task 1: Check the profile and approved views

1. Confirm that the profile is enabled:

    ```sql
    <copy>
    SELECT profile_name,
           status
    FROM user_cloud_ai_profiles
    WHERE profile_name = 'GENAI';
    </copy>
    ```

2. Review its object list by using **Run Script (F5)**:

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

    The list should contain only `PROGRAM_SUPPORT_OVERVIEW_V`,
    `CAMPUS_SUPPORT_CAPACITY_V`, and `COURSE_SECTION_CAPACITY_V` for the
    workshop schema.

3. Check existing agent definitions:

    ```sql
    <copy>
    SELECT agent_name, status
    FROM user_ai_agents
    ORDER BY agent_name;
    </copy>
    ```

The lab objects begin with `NINA_STUDENT_SUPPORT_`. If you already created them,
use the optional reset appendix before recreating them.

## Task 2: Register the approved SQL tool

1. Create a SQL tool that uses the `GENAI` profile:

    ```sql
    <copy>
    BEGIN
      DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
        tool_name   => 'NINA_STUDENT_SUPPORT_SQL_TOOL',
        attributes  => '{"tool_type":"SQL","tool_params":{"profile_name":"GENAI"}}',
        description => 'Read-only SQL access to approved student-support summary views'
      );
    END;
    /
    </copy>
    ```

2. Confirm the tool definition:

    ```sql
    <copy>
    SELECT tool_name,
           status,
           description
    FROM user_ai_agent_tools
    WHERE tool_name = 'NINA_STUDENT_SUPPORT_SQL_TOOL';
    </copy>
    ```

The tool provides a named query capability. The profile's object list guides SQL
generation, and the database user's privileges still control the objects the SQL
can read.

## Task 3: Create Nina's agent, task, and team

1. Create the agent with a role that instructs it to answer operational-summary
    questions:

    ```sql
    <copy>
    BEGIN
      DBMS_CLOUD_AI_AGENT.CREATE_AGENT(
        agent_name  => 'NINA_STUDENT_SUPPORT_AGENT',
        attributes  => '{"profile_name":"GENAI","role":"You are Nina Patel''s read-only student-support operations assistant at Seer Higher Education. Use only the approved SQL tool and database results. Answer questions about aggregate campus service demand, program workload, and course-section capacity. Do not make admissions, disciplinary, eligibility, or individual academic outcome decisions. Do not invent values or change database records."}',
        description => 'Read-only student-support operations assistant'
      );
    END;
    /
    </copy>
    ```

2. Create a task that instructs the agent to invoke the approved tool once.
    Check the tool history after the run to confirm what it did:

    ```sql
    <copy>
    BEGIN
      DBMS_CLOUD_AI_AGENT.CREATE_TASK(
        task_name  => 'NINA_STUDENT_SUPPORT_TASK',
        attributes => '{"instruction":"Answer this student-support operations question: {query}. Use NINA_STUDENT_SUPPORT_SQL_TOOL once to retrieve aggregate data. Return a concise answer grounded in the tool result. Do not repeat the same tool call. Do not make changes to database records or decisions about individual students.","tools":["NINA_STUDENT_SUPPORT_SQL_TOOL"],"enable_human_tool":"false"}',
        description => 'Answer read-only program and campus capacity questions'
      );
    END;
    /
    </copy>
    ```

3. Connect the agent and task in a team:

    ```sql
    <copy>
    BEGIN
      DBMS_CLOUD_AI_AGENT.CREATE_TEAM(
        team_name  => 'NINA_STUDENT_SUPPORT_TEAM',
        attributes => '{"agents":[{"name":"NINA_STUDENT_SUPPORT_AGENT","task":"NINA_STUDENT_SUPPORT_TASK"}],"process":"sequential"}',
        description => 'Read-only student-support planning team'
      );
    END;
    /
    </copy>
    ```

The team is the runnable unit. It connects Nina's assistant, task instructions,
and approved SQL tool.

## Task 4: Run an operations question

Ask the team for an aggregate service-planning result:

```sql
<copy>
SELECT DBMS_CLOUD_AI_AGENT.RUN_TEAM(
         team_name   => 'NINA_STUDENT_SUPPORT_TEAM',
         user_prompt => 'Which five programs have the most open tutoring requests this term? Include the campus, request count, and relevant support-center capacity. Do not include student names.',
         params      => '{"conversation_id":"' || DBMS_CLOUD_AI.CREATE_CONVERSATION() || '"}'
       ) AS agent_answer;
</copy>
```

Review whether the answer is based on the approved views and contains the
requested aggregate fields. Wording may vary by provider. Compare the answer’s
counts and capacity figures with the database results.

The SQL tool is read-only. The task gives the agent no tool for inserting,
updating, or deleting records.

## Task 5: Inspect the agent history

1. Review the most recent team runs:

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

2. Review the most recent tool calls:

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

The tool history should include `NINA_STUDENT_SUPPORT_SQL_TOOL`. Match the
agent, task, and timestamps to the run you just started; these queries return
recent activity without filtering to this team. Check the team’s `STATE` before
treating the run as successful.

## Conclusion: Give the agent one controlled way to work

Nina's team combines a defined role, a narrow task, an approved SQL tool, and
execution history. The profile, object list, and database privileges help keep
the data boundary clear. The example stays read-only and focused on service
planning.

## Appendix: Reset the workshop agent objects

Run this block only if you want to remove the four objects created by this lab
before recreating them. It does not remove workshop data or profile settings.

```sql
<copy>
BEGIN
  DBMS_CLOUD_AI_AGENT.DROP_TEAM('NINA_STUDENT_SUPPORT_TEAM', TRUE);
  DBMS_CLOUD_AI_AGENT.DROP_TASK('NINA_STUDENT_SUPPORT_TASK', TRUE);
  DBMS_CLOUD_AI_AGENT.DROP_AGENT('NINA_STUDENT_SUPPORT_AGENT', TRUE);
  DBMS_CLOUD_AI_AGENT.DROP_TOOL('NINA_STUDENT_SUPPORT_SQL_TOOL', TRUE);
END;
/
</copy>
```

## Acknowledgements

* **Author** - Linda Foinding
* **Contributor** - Teodor Constantin Nechita
* **Last Updated By/Date** - Teodor Constantin Nechita, October 2026
