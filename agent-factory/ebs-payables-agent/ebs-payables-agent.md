# Build an EBS Payables Agent

## Introduction

EBS Payables teams need both trend analysis and invoice-level evidence. In this lab, you will embed a published Data Analysis Agent inside a custom Agent Builder workflow. The specialized agent will answer tabular questions about invoice holds, suppliers, and exception patterns.

The custom agent can use an Oracle Database tool for a targeted invoice lookup. It can also call an approved diagnostic PL/SQL wrapper when the scenario requires a governed business check. These database tools support the analysis rather than define the lab.

Estimated Time: 25 minutes

### Objectives

In this lab, you will:

- Reuse a published Data Analysis Agent as a node in a custom workflow.
- Delegate invoice-hold trend and supplier questions to the specialized agent.
- Let the custom agent choose between analytical and invoice-specific tools.
- Use read-only database evidence for a targeted follow-up question.
- Keep any diagnostic PL/SQL routine as an optional supporting tool.

### Prerequisites

This lab assumes you have:

- Access to Oracle AI Database Private Agent Factory 26.7 with an LLM configured.
- Permission to create and test custom Agent Builder workflows.
- A published Data Analysis Agent configured with approved EBS Payables demo views.
- A saved EBS demo database source with read access to invoice-level evidence.
- Optional `EXECUTE` access to an SME-approved diagnostic wrapper.
- EBS SME confirmation of the questions, objects, privileges, and expected results.

## Task 1: Compose the EBS Analysis Workflow

1. Open Agent Builder and create a custom workflow for the EBS Payables scenario.

2. Add an Agent node and connect a published Data Analysis Agent as a tool.

3. Add the saved Oracle Database tool and, if needed, the approved PL/SQL Executor tool.

    > **Note:** The Data Analysis Agent node returns answer text inside a custom workflow. Use the standalone Data Analysis Agent experience when the detailed lab needs generated visualizations.

## Task 2: Test Analytical and Targeted Questions

1. Save the workflow and open it in the Agent Builder playground.

2. Submit an analytical prompt using this syntax:

    ```
    <copy>Analyze demo invoice holds and summarize the most common hold reasons by supplier.</copy>
    ```

3. Ask the agent to investigate one demo invoice and verify that it selects the targeted database tool.

4. Confirm that the PL/SQL Executor appears only when the approved diagnostic check adds value.

## Learn More

- [Data Analysis Agent Node](https://docs.oracle.com/en/database/oracle/agent-factory/26.7/paias/agent-builder-components.html)
- [Data Analysis Agents](https://docs.oracle.com/en/database/oracle/agent-factory/26.7/paias/create-data-analysis-agent.html)
- [Agent Builder](https://docs.oracle.com/en/database/oracle/agent-factory/26.7/paias/agent-builder.html)

## Acknowledgements

* **Author** - Kumar G. Varun, Lead Principal Product Manager
* **Contributors** - E-Business Suite SME, TODO
* **Last Updated By/Date** - Kumar G. Varun, August 28, 2026
* **Source** - [Oracle AI Database Private Agent Factory 26.7 Agent Builder Components](https://docs.oracle.com/en/database/oracle/agent-factory/26.7/paias/agent-builder-components.html)
