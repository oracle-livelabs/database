# Check Your Understanding

## Introduction

This quiz reviews the core concepts from the Oracle AI Database Private Agent Factory workshop. Complete the scored questions to confirm your understanding of Agent Factory capabilities, pre-built agents, templates, and the Agent Builder experience.

Estimated Time: 10 minutes

### Objectives

In this lab, you will:

* Review the main purpose of Oracle AI Database Private Agent Factory
* Distinguish the roles of pre-built agents
* Confirm how templates accelerate agent development
* Identify the function of MCP Servers in an agentic flow
* Recognize how Agent Builder combines inputs, data, and prompts

### Prerequisites

Complete the previous workshop labs before taking this quiz.

```quiz-config
passing: 75
badge: images/paf-badge.png
```

## Task 1: Complete the quiz

1. Review the questions before you submit your answers.

2. Complete all scored quiz blocks below. You need 75% or higher to pass.

    ```quiz score
    Q: What is the main value of Oracle AI Database Private Agent Factory?
    * It provides a no-code way to build and deploy AI agents close to enterprise data and actions
    - It replaces all large language models with rule-based automation
    - It only supports agents that run on local laptops without cloud services
    - It is limited to document search with no support for agent workflows
    > Oracle AI Database Private Agent Factory helps teams build and deploy AI agents quickly while keeping data, tools, and services in a secure, converged environment.
    ```

    ```quiz score
    Q: What is the key difference between the Knowledge Agent and the Data Analysis Agent?
    * The Knowledge Agent works over unstructured content with grounded answers and citations, while the Data Analysis Agent works over structured data with SQL, tables, and visualizations
    - The Knowledge Agent is only for OCI administration, while the Data Analysis Agent is only for REST APIs
    - The Knowledge Agent creates templates, while the Data Analysis Agent builds MCP Servers
    - The Knowledge Agent is for image generation, while the Data Analysis Agent is for network security
    > The workshop shows that the Knowledge Agent answers questions across documents and cites sources, while the Data Analysis Agent reasons over structured data and returns SQL-driven insights.
    ```

    ```quiz score
    Q: Why does Agent Factory provide templates in the Template Gallery?
    * To let users bootstrap sophisticated agent flows quickly and then customize them with minimal configuration
    - To prevent users from modifying any part of an agent after import
    - To force every agent to use the same data source and the same model
    - To replace the need for prompts, tools, and publishing
    > Templates speed development by giving users a working starting point that they can inspect, adapt, and publish instead of building every flow from scratch.
    ```

    ```quiz score
    Q: In the Market Sync Agent example, what role do MCP Servers play?
    * They act as tools that agent-compatible systems can call to retrieve relevant external data
    - They store screenshots and PDFs for the Knowledge Agent
    - They replace the prompt and become the main user interface
    - They are only used to rename agents before publishing
    > MCP Servers extend an agent with tool access. In the template example, they provide external pricing data that the agent can use when responding to portfolio questions.
    ```

    ```quiz score
    Q: In the Agent Builder lab, why is a Prompt node placed between the chat input, SQL query output, and the Agent?
    * It combines user input and retrieved data into structured context that the agent can use to answer accurately
    - It removes the need to connect the agent to any output component
    - It forces the agent to respond without using any database content
    - It only changes the color of the flow so users can read it more easily
    > The Prompt node assembles the user request with the SQL query results so the agent receives both the question and the supporting data in one grounded prompt.
    ```

## Acknowledgements

**Authors** Linda Foinding, Principal Product Manager, Database Product Management

**Last Updated Date** - Linda Foinding, March, 2026
