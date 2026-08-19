# Triage Risk Signals with Select AI Agents

## Introduction

Seer Bank has moved from dashboards and SQL evidence to governed natural-language answers. The risk analyst can ask which product categories have the highest exposure. They can also inspect the SQL behind the answer.

The next step is action. When a high-priority signal appears, the team needs a consistent way to retrieve evidence, apply the review rule, and leave an audit record.

Select AI Agents fit this Seer Bank workflow. The agent does not receive broad permission to change finance data. It receives two narrow tools. One reads the highest-priority risk signal. One creates a simulated analyst-review record only after the database function checks the threshold.

In this lab, you use Oracle Machine Learning to create tools, an agent, a task, and a team. Then you run `SELECT AI AGENT` and inspect the action history.

The agent has two function tools:

- `FINANCE_SIGNAL_LOOKUP_TOOL` retrieves the highest-priority current risk signal.
- `FINANCE_ESCALATE_TOOL` checks the score threshold and creates one simulated analyst-review record.

The tools cannot change transactions, accounts, balances, products, clients, or source risk signals.

### Objectives

- Import and run the supplied Select AI Agent notebook in OML.
- Create finance tools, an agent, a task, and a team with `DBMS_CLOUD_AI_AGENT`.
- Run a conditional finance workflow with `SELECT AI AGENT`.
- Inspect the business audit record and Oracle agent histories.
- Prove that repeated requests do not create duplicate escalations.

Estimated Time: **22 minutes**

### Business Scenario

| Step | Finance focus |
| --- | --- |
| Business Problem | High-risk signals need consistent triage and a durable review record. |
| Technical Challenge | An agent must retrieve evidence, apply a rule, and record the outcome without changing protected finance data. |
| Persona Focus | A risk operations analyst requests triage; an AI engineer exposes narrow tools; a reviewer inspects the audit history. |
| What You Will See | A Select AI Agent can coordinate approved read and write tools inside a constrained database boundary. |
| Database Capability | Oracle Select AI Agents, function tools, OML notebooks, `AGENT_ACTIONS`, and native history views. |
| Outcome | Seer Bank turns AI-assisted triage into a controlled, reviewable database workflow. |

**Persona focus:** You turn a Seer Bank risk request into a constrained agent workflow.

## Task 1: Import the Finance Select AI Agent Notebook

1. Download [finance-select-ai-agent-notebook.json](files/finance-select-ai-agent-notebook.json).

2. From the Oracle Machine Learning home page, click **Notebooks**.

    ![Oracle Machine Learning Notebooks page](images/oml-notebooks-home.png)

3. Click **Import** and select **From File**.

    ![Import a notebook in Oracle Machine Learning](images/oml-import-notebook.png)

4. Choose `finance-select-ai-agent-notebook.json`.

    ![Choose the finance agent notebook file](images/oml-import-file.png)

5. Open the imported notebook from the Notebooks table.

    ![Imported Select AI Agent notebook in the Oracle Machine Learning Notebooks table](images/oml-open-notebook.png)

Leave the notebook open. Tasks 2 through 7 run in this OML notebook. Each runnable paragraph includes the title, explanation, and command together.

## Task 2: Prepare the Evidence and Profile

Start by confirming the profile and the finance evidence that the tools use.

1. Set the profile, refresh the approved object list, and inspect the top risk signal.

    ```sql
    <copy>
    EXEC DBMS_CLOUD_AI.SET_PROFILE('genai');

    BEGIN
      DBMS_CLOUD_AI.SET_ATTRIBUTE(
        profile_name    => 'genai',
        attribute_name  => 'object_list',
        attribute_value => '[{"owner": "' || USER || '", "name": "RISK_SIGNALS_V"},' ||
                           '{"owner": "' || USER || '", "name": "SIGNAL_SOURCES_V"},' ||
                           '{"owner": "' || USER || '", "name": "AGENT_ACTIONS"}]'
      );
    END;
    /

    SELECT finance_get_top_signal() AS signal_evidence
    FROM dual;
    </copy>
    ```

    > This command is already in your notebook. Click the play button (▶) to run it.

    **Expected result:** The profile is set, the object list is refreshed, and one text value identifies the top risk signal.

The lookup function is read-only. The escalation function can insert only a constrained `AGENT_ACTIONS` record. It checks the threshold first.

## Task 3: Create the Finance Agent Tools

The notebook resets any supplied agent metadata. Then it creates the two function tools for the workflow.

1. Reset the workshop agent objects and simulated action rows.

    ```sql
    <copy>
    EXEC DBMS_CLOUD_AI_AGENT.DROP_TEAM('FINANCE_RISK_TEAM', TRUE);
    EXEC DBMS_CLOUD_AI_AGENT.DROP_TASK('FINANCE_RISK_TASK', TRUE);
    EXEC DBMS_CLOUD_AI_AGENT.DROP_AGENT('FINANCE_RISK_AGENT', TRUE);
    EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('FINANCE_SIGNAL_LOOKUP_TOOL', TRUE);
    EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('FINANCE_ESCALATE_TOOL', TRUE);

    DELETE FROM agent_actions
    WHERE agent_name = 'FINANCE_RISK_AGENT';
    COMMIT;
    </copy>
    ```

    > This command is already in your notebook. Click the play button (▶) to run it.

    **Expected result:** The previous team, task, agent, and tools are removed. Prior simulated action rows from this workshop agent are also removed.

2. Create the two function tools.

    ```sql
    <copy>
    BEGIN
      DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
        tool_name   => 'FINANCE_SIGNAL_LOOKUP_TOOL',
        attributes  => '{
          "instruction": "Retrieve the highest-priority current Seer Bank risk signal. This tool has no parameters. Always call it before deciding whether to escalate.",
          "function": "finance_get_top_signal"
        }',
        description => 'Returns the highest-priority finance risk signal and its evidence'
      );

      DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
        tool_name   => 'FINANCE_ESCALATE_TOOL',
        attributes  => '{
          "instruction": "Create one analyst-review escalation for the highest-priority risk signal. This tool has no parameters and independently enforces a criticality threshold of 70. Call it only after FINANCE_SIGNAL_LOOKUP_TOOL.",
          "function": "finance_escalate_top_signal"
        }',
        description => 'Creates a controlled risk-signal review record when the threshold is met'
      );
    END;
    /
    </copy>
    ```

    > This command is already in your notebook. Click the play button (▶) to run it.

    **Expected result:** Both tools are created and enabled.

## Task 4: Create the Agent, Task, and Team

Now build the agent workflow. The role defines the boundary. The task requires evidence before action. The team activates the task for `SELECT AI AGENT`.

1. Create the agent, task, and team.

    ```sql
    <copy>
    BEGIN
      DBMS_CLOUD_AI_AGENT.CREATE_AGENT(
        agent_name  => 'FINANCE_RISK_AGENT',
        attributes  => '{
          "profile_name": "genai",
          "role": "You are a Seer Bank risk-triage agent. Use only the supplied tools. Always retrieve database evidence before deciding. You may create a simulated analyst-review escalation, but you must never change transactions, accounts, balances, products, clients, or the source risk signal."
        }',
        description => 'Coordinates controlled finance risk-signal triage'
      );

      DBMS_CLOUD_AI_AGENT.CREATE_TASK(
        task_name   => 'FINANCE_RISK_TASK',
        attributes  => '{
          "instruction": "For each request: 1) call FINANCE_SIGNAL_LOOKUP_TOOL; 2) report the signal ID, criticality, severity, exposure, and source; 3) if the criticality score is at least 70, call FINANCE_ESCALATE_TOOL once; 4) report whether the escalation was created. Never claim a write occurred unless the escalation tool confirms it. User request: {query}",
          "tools": ["FINANCE_SIGNAL_LOOKUP_TOOL", "FINANCE_ESCALATE_TOOL"]
        }',
        description => 'Looks up the strongest finance risk signal and conditionally escalates it'
      );

      DBMS_CLOUD_AI_AGENT.CREATE_TEAM(
        team_name   => 'FINANCE_RISK_TEAM',
        attributes  => '{
          "agents": [{
            "name": "FINANCE_RISK_AGENT",
            "task": "FINANCE_RISK_TASK"
          }],
          "process": "sequential"
        }',
        description => 'Finance risk-triage team'
      );
    END;
    /
    </copy>
    ```

    > This command is already in your notebook. Click the play button (▶) to run it.

    **Expected result:** The agent, task, and sequential team are created and enabled.

2. Verify the agent component inventory.

    ```sql
    <copy>
    SELECT 'TOOL' AS object_type,
           tool_name AS object_name,
           status
    FROM user_ai_agent_tools
    WHERE tool_name IN (
      'FINANCE_SIGNAL_LOOKUP_TOOL',
      'FINANCE_ESCALATE_TOOL'
    )
    UNION ALL
    SELECT 'AGENT', agent_name, status
    FROM user_ai_agents
    WHERE agent_name = 'FINANCE_RISK_AGENT'
    UNION ALL
    SELECT 'TASK', task_name, status
    FROM user_ai_agent_tasks
    WHERE task_name = 'FINANCE_RISK_TASK'
    UNION ALL
    SELECT 'TEAM', agent_team_name, status
    FROM user_ai_agent_teams
    WHERE agent_team_name = 'FINANCE_RISK_TEAM'
    ORDER BY object_type, object_name;
    </copy>
    ```

    > This command is already in your notebook. Click the play button (▶) to run it.

    **Expected output:** Two tools, one agent, one task, and one team are `ENABLED`.

## Task 5: Run Select AI Agent

Unlike chat or narration, the agent can coordinate an approved write through the controlled escalation tool.

1. Set the active team and run the agent request.

    ```sql
    <copy>
    EXEC DBMS_CLOUD_AI_AGENT.SET_TEAM('FINANCE_RISK_TEAM');

    SELECT AI AGENT
      Find the highest-priority current risk signal. If its criticality score is at least 70, create one escalation record for analyst review. Report the signal ID, score, severity, and whether an escalation was created.;
    </copy>
    ```

    > This command is already in your notebook. Click the play button (▶) to run it.

    **Expected result:** The agent calls the lookup tool and reports the evidence. It calls the escalation tool only when the score meets the threshold.

## Task 6: Review the Agent Evidence

Review the business action record and the native Oracle history views.

1. Review the business action record and Oracle agent histories.

    ```sql
    <copy>
    SELECT action_id,
           action_type,
           entity_type,
           entity_id AS signal_id,
           execution_status,
           executed_at
    FROM agent_actions
    WHERE agent_name = 'FINANCE_RISK_AGENT'
    ORDER BY action_id DESC
    FETCH FIRST 5 ROWS ONLY;

    SELECT tool_name,
           TO_CHAR(start_date, 'HH24:MI:SS') AS called_at,
           SUBSTR(output, 1, 100) AS result
    FROM user_ai_agent_tool_history
    WHERE tool_name IN (
      'FINANCE_SIGNAL_LOOKUP_TOOL',
      'FINANCE_ESCALATE_TOOL'
    )
    ORDER BY start_date DESC
    FETCH FIRST 10 ROWS ONLY;

    SELECT team_name,
           TO_CHAR(start_date, 'HH24:MI:SS') AS started,
           state
    FROM user_ai_agent_team_history
    WHERE team_name = 'FINANCE_RISK_TEAM'
    ORDER BY start_date DESC
    FETCH FIRST 5 ROWS ONLY;
    </copy>
    ```

    > This command is already in your notebook. Click the play button (▶) to run it.

    **Expected result:** When the threshold is met, `AGENT_ACTIONS` shows one completed `ESCALATE_REVIEW` row. The history views show the tool calls and latest team run.

## Task 7: Prove Idempotency and the Protected Boundary

Run the same request again. The escalation function checks for an existing review record before it inserts.

1. Run the same request again and count the escalation rows.

    ```sql
    <copy>
    SELECT AI AGENT
      Run the finance risk triage again and report whether an escalation already exists.;

    SELECT entity_id AS signal_id,
           COUNT(*) AS escalation_rows
    FROM agent_actions
    WHERE agent_name = 'FINANCE_RISK_AGENT'
      AND action_type = 'ESCALATE_REVIEW'
    GROUP BY entity_id
    ORDER BY entity_id;
    </copy>
    ```

    > This command is already in your notebook. Click the play button (▶) to run it.

    **Expected result:** Each signal has at most one escalation row. The function reports that a record already exists.

The agent language model does not grant database privileges. Its actions remain limited to the two registered Oracle function tools.

## Acknowledgements

* **Author** - Linda Foinding, Principal Database Product Manager
* **Last Updated By/Date** - Oracle Database Product Management, July 2026
