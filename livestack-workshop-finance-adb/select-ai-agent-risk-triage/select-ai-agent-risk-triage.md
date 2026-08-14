# Triage Risk Signals with Select AI Agents

## Introduction

In the previous lab, `SELECT AI CHAT` explained general finance concepts and Select AI queried approved Seer Bank data. Neither path could take action. In this lab, you follow the next part of the AI4U pattern in Oracle Machine Learning: create tools, an agent, a task, and a team; run `SELECT AI AGENT`; and inspect the resulting action history.

The agent has two narrow function tools:

- `FINANCE_V2_SIGNAL_LOOKUP_TOOL` retrieves the highest-priority current risk signal.
- `FINANCE_V2_ESCALATE_TOOL` independently checks the score threshold and creates one simulated analyst-review record.

The tools cannot change transactions, accounts, balances, products, clients, or the source risk signal.

### Objectives

- Import and run the supplied Select AI Agent notebook in OML.
- Create finance tools, an agent, a task, and a team with `DBMS_CLOUD_AI_AGENT`.
- Run a conditional finance workflow with `SELECT AI AGENT`.
- Inspect the business audit record and Oracle agent histories.
- Prove that repeated requests do not create duplicate escalations.

Estimated Time: **22 minutes**

### Operating Story

| Step | Finance focus |
| --- | --- |
| Business Problem | High-risk signals need consistent triage and a durable escalation record. |
| Technical Challenge | An agent must retrieve evidence, apply a controlled rule, and record the outcome without changing protected financial data. |
| Persona Focus | A risk operations analyst requests triage; an AI engineer exposes narrow tools; a reviewer inspects the audit history. |
| What You Will Prove | A Select AI Agent can coordinate approved read and write tools while remaining inside a constrained database boundary. |
| Database Capability | Oracle Select AI Agents, function tools, OML notebooks, `AGENT_ACTIONS`, and native history views. |
| Outcome | AI-assisted triage becomes a controlled, reviewable database workflow. |

Persona focus: You are the AI engineer converting a risk analyst's request into a tool-constrained agent workflow that leaves evidence for review.

## Task 1: Import the Finance Select AI Agent Notebook

1. Download [finance-select-ai-agent-notebook.json](files/finance-select-ai-agent-notebook.json).

2. From the Oracle Machine Learning home page, click **Notebooks**.

    ![Oracle Machine Learning Notebooks page](images/oml-notebooks-home.png " ")

3. Click **Import** and select **From File**.

    ![Import a notebook in Oracle Machine Learning](images/oml-import-notebook.png " ")

4. Choose `finance-select-ai-agent-notebook.json`.

    ![Choose the finance agent notebook file](images/oml-import-file.png " ")

5. Open the imported notebook.

    ![Open the imported Oracle Machine Learning notebook](images/oml-open-notebook.png " ")

Run each notebook paragraph in order. The notebook contains the same commands shown below.

## Task 2: Inspect the Finance Evidence and Action Boundary

1. Retrieve the current highest-priority risk signal through the supplied database function.

    ```sql
    <copy>
    SELECT finance_v2_get_top_signal() AS signal_evidence
    FROM dual;
    </copy>
    ```

    **Expected result:** One text value identifies the signal ID, criticality, severity, exposure, source, and evidence.

2. Remove only prior simulated escalations created by this workshop agent.

    ```sql
    <copy>
    DELETE FROM agent_actions
    WHERE agent_name = 'FINANCE_V2_RISK_AGENT';
    COMMIT;
    </copy>
    ```

    **Expected result:** The paragraph reports the number of deleted workshop-agent rows and commits the reset. Other finance data remains unchanged.

The lookup function is read-only. The escalation function can insert only a constrained `AGENT_ACTIONS` record after independently checking the threshold.

## Task 3: Create the Finance Agent Tools

The loader supplies the database functions and a ready-to-run copy of the agent objects. Reset the agent metadata so you can build the objects yourself, as you do in AI4U.

1. Drop the supplied team, task, agent, and tools.

    ```sql
    <copy>
    EXEC DBMS_CLOUD_AI_AGENT.DROP_TEAM('FINANCE_V2_RISK_TEAM', TRUE);
    EXEC DBMS_CLOUD_AI_AGENT.DROP_TASK('FINANCE_V2_RISK_TASK', TRUE);
    EXEC DBMS_CLOUD_AI_AGENT.DROP_AGENT('FINANCE_V2_RISK_AGENT', TRUE);
    EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('FINANCE_V2_SIGNAL_LOOKUP_TOOL', TRUE);
    EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('FINANCE_V2_ESCALATE_TOOL', TRUE);
    </copy>
    ```

    **Expected result:** The five supplied agent objects are removed so the notebook can recreate them.

2. Create a read-only lookup tool and a controlled escalation tool.

    ```sql
    <copy>
    BEGIN
      DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
        tool_name   => 'FINANCE_V2_SIGNAL_LOOKUP_TOOL',
        attributes  => '{
          "instruction": "Retrieve the highest-priority current Seer Bank risk signal. This tool has no parameters. Always call it before deciding whether to escalate.",
          "function": "finance_v2_get_top_signal"
        }',
        description => 'Returns the highest-priority finance risk signal and its evidence'
      );

      DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
        tool_name   => 'FINANCE_V2_ESCALATE_TOOL',
        attributes  => '{
          "instruction": "Create one analyst-review escalation for the highest-priority risk signal. This tool has no parameters and independently enforces a criticality threshold of 70. Call it only after FINANCE_V2_SIGNAL_LOOKUP_TOOL.",
          "function": "finance_v2_escalate_top_signal"
        }',
        description => 'Creates a controlled risk-signal review record when the threshold is met'
      );
    END;
    /
    </copy>
    ```

    **Expected result:** Both tools are created and enabled.

## Task 4: Create the Agent, Task, and Team

1. Create the finance risk agent.

    ```sql
    <copy>
    BEGIN
      DBMS_CLOUD_AI_AGENT.CREATE_AGENT(
        agent_name  => 'FINANCE_V2_RISK_AGENT',
        attributes  => '{
          "profile_name": "FINANCE_V2_GENAI",
          "role": "You are a Seer Bank risk-triage agent. Use only the supplied tools. Always retrieve database evidence before deciding. You may create a simulated analyst-review escalation, but you must never change transactions, accounts, balances, products, clients, or the source risk signal."
        }',
        description => 'Coordinates controlled finance risk-signal triage'
      );

      DBMS_CLOUD_AI_AGENT.CREATE_TASK(
        task_name   => 'FINANCE_V2_RISK_TASK',
        attributes  => '{
          "instruction": "For each request: 1) call FINANCE_V2_SIGNAL_LOOKUP_TOOL; 2) report the signal ID, criticality, severity, exposure, and source; 3) if the criticality score is at least 70, call FINANCE_V2_ESCALATE_TOOL once; 4) report whether the escalation was created. Never claim a write occurred unless the escalation tool confirms it. User request: {query}",
          "tools": ["FINANCE_V2_SIGNAL_LOOKUP_TOOL", "FINANCE_V2_ESCALATE_TOOL"]
        }',
        description => 'Looks up the strongest finance risk signal and conditionally escalates it'
      );

      DBMS_CLOUD_AI_AGENT.CREATE_TEAM(
        team_name   => 'FINANCE_V2_RISK_TEAM',
        attributes  => '{
          "agents": [{
            "name": "FINANCE_V2_RISK_AGENT",
            "task": "FINANCE_V2_RISK_TASK"
          }],
          "process": "sequential"
        }',
        description => 'Finance V2 risk-triage team'
      );
    END;
    /
    </copy>
    ```

    **Expected result:** The agent, task, and sequential team are created and enabled.

2. Verify the completed component inventory.

    ```sql
    <copy>
    SELECT 'TOOL' AS object_type,
           tool_name AS object_name,
           status
    FROM user_ai_agent_tools
    WHERE tool_name IN (
      'FINANCE_V2_SIGNAL_LOOKUP_TOOL',
      'FINANCE_V2_ESCALATE_TOOL'
    )
    UNION ALL
    SELECT 'AGENT', agent_name, status
    FROM user_ai_agents
    WHERE agent_name = 'FINANCE_V2_RISK_AGENT'
    UNION ALL
    SELECT 'TASK', task_name, status
    FROM user_ai_agent_tasks
    WHERE task_name = 'FINANCE_V2_RISK_TASK'
    UNION ALL
    SELECT 'TEAM', agent_team_name, status
    FROM user_ai_agent_teams
    WHERE agent_team_name = 'FINANCE_V2_RISK_TEAM'
    ORDER BY object_type, object_name;
    </copy>
    ```

    **Expected output:** Two tools, one agent, one task, and one team are `ENABLED`.

## Task 5: Run Select AI Agent

1. Set the active team.

    ```sql
    <copy>
    EXEC DBMS_CLOUD_AI_AGENT.SET_TEAM('FINANCE_V2_RISK_TEAM');
    </copy>
    ```

    **Expected result:** `FINANCE_V2_RISK_TEAM` becomes the active team for the OML session.

2. Ask the agent to retrieve evidence, decide, and act.

    ```sql
    <copy>
    SELECT AI AGENT
      Find the highest-priority current risk signal. If its criticality score is at least 70, create one escalation record for analyst review. Report the signal ID, score, severity, and whether an escalation was created.
    </copy>
    ```

    **Expected result:** The agent calls the lookup tool, reports the finance evidence, and calls the escalation tool only when the database score meets the threshold.

Unlike Select AI Chat or Select AI Narrate, the agent can coordinate an approved write because its task includes the controlled escalation tool.

## Task 6: Review the Agent Evidence

1. Query the business action record.

    ```sql
    <copy>
    SELECT action_id,
           action_type,
           entity_type,
           entity_id AS signal_id,
           execution_status,
           executed_at
    FROM agent_actions
    WHERE agent_name = 'FINANCE_V2_RISK_AGENT'
    ORDER BY action_id DESC
    FETCH FIRST 5 ROWS ONLY;
    </copy>
    ```

    **Expected result:** When the threshold is met, one completed `ESCALATE_REVIEW` row identifies the selected risk signal.

2. Query the database-native tool history.

    ```sql
    <copy>
    SELECT tool_name,
           TO_CHAR(start_date, 'HH24:MI:SS') AS called_at,
           SUBSTR(output, 1, 100) AS result
    FROM user_ai_agent_tool_history
    WHERE tool_name IN (
      'FINANCE_V2_SIGNAL_LOOKUP_TOOL',
      'FINANCE_V2_ESCALATE_TOOL'
    )
    ORDER BY start_date DESC
    FETCH FIRST 10 ROWS ONLY;
    </copy>
    ```

    **Expected result:** The history shows the lookup call and, when required, the escalation call.

3. Query the team execution history.

    ```sql
    <copy>
    SELECT team_name,
           TO_CHAR(start_date, 'HH24:MI:SS') AS started,
           state
    FROM user_ai_agent_team_history
    WHERE team_name = 'FINANCE_V2_RISK_TEAM'
    ORDER BY start_date DESC
    FETCH FIRST 5 ROWS ONLY;
    </copy>
    ```

    **Expected result:** The latest team execution appears with its recorded state.

## Task 7: Prove Idempotency and the Protected Boundary

1. Run the same `SELECT AI AGENT` request again.

2. Count the controlled escalation rows.

    ```sql
    <copy>
    SELECT entity_id AS signal_id,
           COUNT(*) AS escalation_rows
    FROM agent_actions
    WHERE agent_name = 'FINANCE_V2_RISK_AGENT'
      AND action_type = 'ESCALATE_REVIEW'
    GROUP BY entity_id
    ORDER BY entity_id;
    </copy>
    ```

    **Expected result:** Each signal has at most one escalation row. The escalation function reports that a record already exists instead of inserting a duplicate.

The agent's language-model reasoning does not grant database privileges. Its possible actions remain limited to the two registered Oracle function tools.

## Acknowledgements

* **Source Pattern** - AI4U, *Why Agents Beat Zero-Shot Prompts*, *What Is an Agent?*, and *Tools, Safety, and Control*
* **Finance Source** - Seer Bank Finance LiveStack
* **Contributor** - Linda Foinding, Principal Database Product Manager
* **Last Updated By/Date** - Oracle Database Product Management, July 2026
