# Agent Builder: Build Agents From Scratch

## Introduction

In this lab session, you will learn how to leverage the Agent Builder within Oracle AI Database Private Agent Factory to accelerate your workflow with minimal setup.

**Estimated time:** 10 minutes.

### Objectives

By the end of this lab, you will be able to:

- Familiarize yourself with the Agent Builder to visually design, assemble, and automate new workflows using diverse components.
- Gain hands-on experience in creating, testing, and refining your own workflows tailored to specific business needs.

### Prerequisites

To follow this tutorial, you need access to an Oracle AI Database Private Agent Factory environment with the necessary permissions to use Agent Builder tools. You should also have access to at least one data file (such as a PDF) and an LLM configuration that is available in your environment.

> Note: Screenshots in this tutorial use example files and configurations for illustration purposes. When following along, use resources that are available in your environment.


## Explore the agent builder

The Agent Builder enables you to design, orchestrate, and automate complex processes by combining modular components, such as language models, data connectors, APIs, and specialized agents, without the need for extensive programming.

With the Agent Builder, you can visually construct workflows by connecting nodes that represent specific actions, tools, or data sources using a straightforward drag-and-drop interface. This feature allows you to build intelligent workflows using components like LLMs, chat agents, and data processing tools. You can also define agents that autonomously perform tasks, make decisions, or interact with systems based on your workflows.

Workflows created with the Agent Builder can be seamlessly integrated with enterprise systems, third-party services, cloud APIs, and databases. They are reusable and can easily be modified to meet varying business requirements.

The following table explores the various types of nodes you can use in the Agent Builder to create custom workflows. You may mix and match them to tailor workflows to your specific goals.

| Type | Description |
|--|--|
| Language Model | *vLLM*: Node leveraging the vLLM (virtualized Large Language Model) system for fast, efficient LLM inference. |
| Agents | - *vLLM Agent*: Node utilizing a vLLM instance to carry out instructions, answer questions, or facilitate complex workflows. <br>- *OCI Agent*: Node connected to Oracle Cloud Infrastructure (OCI) services, enabling use of models served by Gen AI Services. |
| Tools | *MCP Server*: Specialized node for interfacing with AI models using the Model Context Protocol (MCP). (SSE Only) |
| Inputs | - *Chat Input*: Designed for conversational user input in a chat-based interface. <br>- *Text Input*: Receives plain text input directly from the user. <br>- *Prompt*: For defining or modifying textual instructions sent to a language model. |
| Outputs | - *Chat Output*: Renders or returns model/agent responses in a chat interface. |
| Data | - *Read CSV*: Imports and parses CSV files for batch or tabular data processing. <br>- *File Upload*: Allows users to upload files for processing or analysis. <br>- *SQL Query*: Executes SQL statements against databases; returns results for workflow use. |

## Create a custom workflow

In this task you will create a simple workflow to gain hands-on experience with the Agent Builder interface and its capabilities.

1. **Open Oracle AI Database Private Agent Factory and log in.**
    In the sidebar, click **Agent Builder**.

    ![Main dashboard of Oracle AI Database Private Agent Factory with the left navigation panel expanded. The Agent Builder option under the Utilities section is highlighted, and the Get Started page is displayed with pre-built agent options and a quick start guide on the right.](images/get_started_agent_builder.png)

    ![Agent Builder screen showing a components panel on the left with categories such as Language Model, Agents, Tools, Inputs, Outputs, and Data. The main workspace area is blank, and 'Playground' and 'Publish' buttons are in the upper right corner.](images/agent_builder.png)

2. Add nodes.

    On the left side of the canvas, you will find the available nodes. Drag an Agent node (such as OCI Agent or vLLM Agent) onto the canvas. Configure it with an LLM configuration name from your environment.

    ![Agent Builder screen showing step 2, adding an Agent node. A red arrow curves from the  Agent option in the components panel on the left to a newly added Agent node on the workspace. The node configuration panel displays fields for configuration, tools, custom instructions, prompt, and temperature.](images/step2.png)

    On the top left corner of the canvas type a name for the workflow, such as "Scientific Paper Summarizer".

3. Connect nodes.

    Repeat the process and add a **Chat Output** node. On the Chat Output node, click on the blue edge and drag it until it connects with the right edge of the OCI/vLLM Agent node edge, as shown below.

    ![Agent Builder screen showing step 3, adding and connecting a Chat Output node to the workflow. A red arrow connects the Message output of the Agent node to the Message input of the Chat Output node, with both nodes visible and highlighted connection points.](images/step3a.png)

    If you need to remove a connection between two nodes, simply click the connecting line and press Delete on you keyboard.

    Add a **Chat Input** node as well, but do not connect it for now.

    ![Agent Builder screen showing an arrow from the Chat Input component in the left panel to a newly placed Chat Input node in the workspace. The workflow contains three nodes: Chat Input, Agent, and Chat Output, with the Agent connected to the Chat Output.](images/step3b.png)

4. Enrich prompts.

    As previously mentioned, the Prompt node allows you to enrich the instructions provided to the AI.

    Add a **Prompt** node and enter instructions in the text box. If you wish to add variable information, encapsulate it in curly braces; this will automatically add a connection edge to the node once saved. Example:

    >Given the provided text, extract all key information and important details. Use this information to automatically generate a easy to understand summary.
    Provided text : {{user_input}}

    ![Agent Builder screen showing step 4a, adding a Prompt node to the workflow. A red arrow points from the Prompt component in the left panel to a newly created Prompt node placed between the Chat Input and Agent nodes in the workspace. The Prompt node features a template input and save button.](images/step4a.png)

    ![Agent Builder screen showing step 4b, with a Prompt node added between the Chat Input and Agent nodes. The Prompt node contains a filled-in template field describing instructions to generate an easy-to-understand summary, including a variable for user input.](images/step4b.png)

    ![Agent Builder screen showing step 4c, a canvas displaying a workflow with File Upload, Prompt, Agent, and Chat Output nodes. The Prompt node receives input from both the File Upload and Chat Input nodes, and its output is connected to the Prompt input of the Agent. Path connections and active connection points are highlighted in the workflow.](images/step4c.png)

    Connect the nodes as illustrated so that the Chat Input feeds into the Prompt, which feeds into the agent node, which connects to the Chat Output.

    ![Agent Builder screen showing step 4d, with the Chat Input node connected to the Prompt node, the Prompt node connected to the Agent node, and the Agent node connected to the Chat Output node. Arrows indicate the workflow sequence through all nodes, and the Prompt template field is populated with summary instructions and a user input variable.](images/step4d.png)

5. Save and test.

    Save the workflow by clicking the **Save** button in the top-right corner of the canvas. You can test the workflow before publishing it by clicking **Playground**. In the Playground, you may use test text or sample data relevant to your organization for input.

    ![Scientific Paper Summarizer custom flow screen showing a message that the new custom flow has been created. The main area prompts the user to start using the custom flow by typing a message, with options to start a new chat or go back to the builder. The chat input field is visible at the bottom.](images/step5a.png)

    ![Scientific Paper Summarizer custom flow test screen showing a user input and the Custom Flow Agent's response with a summary and key points about the data source used. The interface includes options to start a new chat or go back to the builder, and the chat input field is visible at the bottom.](images/step5b.png)


## Acknowledgements

- **Author** - Emilio Perez, Member of Technical Staff, Database Applied AI
- **Last Updated By/Date** - Emilio Perez - August 2025
