# Build a PeopleSoft Absence Agent

## Introduction

PeopleSoft users may ask about absence policy before they ask about their own eligibility. In this lab, you will combine a published Knowledge Agent with a URL Crawler that reads an approved public policy site. A Condition node will route policy and eligibility questions, and a Text Combiner will assemble the response.

The workflow can query a curated leave-balance view or call an approved validation wrapper for a specific employee request. Database and PL/SQL access support the policy-aware experience rather than serve as its primary lesson.

Estimated Time: 25 minutes

### Objectives

In this lab, you will:

- Reuse a published Knowledge Agent as a node in a custom workflow.
- Crawl an approved public policy site for current lab content.
- Route policy and eligibility questions with a Condition node.
- Combine policy guidance and employee-specific evidence with a Text Combiner.
- Use database or PL/SQL tools only for an approved eligibility check.

### Prerequisites

This lab assumes you have:

- Access to Oracle AI Database Private Agent Factory 26.7 with an LLM configured.
- Permission to create and test custom Agent Builder workflows.
- A published Knowledge Agent configured with approved PeopleSoft absence policy content.
- A lab-provided public policy site that Agent Factory can reach without credentials.
- A saved PeopleSoft demo source with read access to curated leave-balance views.
- Optional `EXECUTE` access to an SME-approved absence validation wrapper.
- PeopleSoft SME confirmation of the policies, routing rules, objects, and expected results.

## Task 1: Compose the Policy-Aware Workflow

1. Open Agent Builder and create a custom workflow for the PeopleSoft absence scenario.

2. Add the Knowledge Agent and URL Crawler nodes for approved policy content.

3. Add a Condition node to route policy questions and employee-specific eligibility questions.

4. Add a Text Combiner and the supporting Oracle Database or PL/SQL tool.

    > **Note:** URL Crawler accesses only reachable same-site pages and does not send credentials. Use a public lab site rather than an authenticated PeopleSoft site.

## Task 2: Test Policy and Eligibility Routing

1. Save the workflow and open it in the Agent Builder playground.

2. Submit a policy-aware prompt using this syntax:

    ```
    <copy>Explain the demo parental-leave policy, then check eligibility for employee [employee ID].</copy>
    ```

3. Verify that the workflow retrieves policy context before it uses employee-specific data.

4. Confirm that the final response separates policy guidance from the eligibility result.

## Learn More

- [Knowledge Agent and URL Crawler Nodes](https://docs.oracle.com/en/database/oracle/agent-factory/26.7/paias/agent-builder-components.html)
- [Knowledge Agents](https://docs.oracle.com/en/database/oracle/agent-factory/26.7/paias/create-knowledge-agent.html)
- [Agent Builder](https://docs.oracle.com/en/database/oracle/agent-factory/26.7/paias/agent-builder.html)

## Acknowledgements

* **Author** - Kumar G. Varun, Lead Principal Product Manager
* **Contributors** - PeopleSoft SME, TODO
* **Last Updated By/Date** - Kumar G. Varun, August 28, 2026
* **Source** - [Oracle AI Database Private Agent Factory 26.7 Agent Builder Components](https://docs.oracle.com/en/database/oracle/agent-factory/26.7/paias/agent-builder-components.html)
