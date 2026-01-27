# Knowledge Agent: A Pre-Built RAG Agent

## Introduction

In this lab session, you will learn how to create Pre-Built RAG Agents (known as Knowledge Agents) and connect them to your data sources to safely access your enterprise data.

A **Knowledge Agent** is an AI agent that augments Vector Search & LLM capabilities with enterprise data, enabling accurate, context-rich responses by retrieving relevant information from internal knowledge bases, documents, or web-sources.

It is capable of contextual retrieval from unstructured sources and provides grounded responses traceable to enterprise-approved sources. The Knowledge Agent is integration-ready, allowing connections to internal sites, file systems, and more. It also supports un-authenticated web sources for broader knowledge retrieval.

**Estimated time:** 10 minutes.

### Objectives

By the end of this lab, you will be able to:

- Create a Knowledge Agent and define its Knowledge Base.
- Interact with a custom Knowledge Agent by asking questions and receiving responses based on your knowledge base.

### Prerequisites

To follow this tutorial, it is suggested that you have access to an Oracle AI Database Private Agent Factory environment with permissions to add and manage knowledge agents.

## Task 1: Create a Blank Knowledge Agent

In this task you will create a new blank Knowledge Agent.

1. Open Oracle AI Database Private Agent Factory and log in. In the sidebar, click the **Knowledge Agent** section.

    ![Main dashboard of Oracle AI Database Private Agent Factory with the left navigation panel expanded. The Knowledge Agent option under the Pre-built Agents section is highlighted, and the Get Started page is displayed with pre-built agent options and a quick start guide on the right.](images/get_started_kagent.png)

    ![Knowledge Agents screen displaying a search bar, a card to start from scratch and create a blank knowledge agent from scratch, and a card for the Oracle AI Database Private Agent Factory Knowledge Assistant, which is described as a knowledge base consisting of documentation for Oracle AI Database Private Agent Factory.](images/knowledge_agent.png)

2. Click **Blank Knowledge Agent**.

    You will be prompted to select a data source. You can either choose to add a Web Source or a File System. For this tutorial we will use the Web Source one created on Lab 4. This data source will be knowledge base for this agent. Click **Next** to continue.

    ![Create Knowledge Agent screen showing step 1 of 3, with options to select data sources for the agent to learn from. The Web Sources table lists available sources by name, endpoint, and status, and includes a button to add a new web source. 'Next' and 'Cancel' buttons appear at the bottom of the screen.](images/kbase_config.png)

3. The Knowledge Base Configuration setup form will be displayed. Assign an agent name and description to easily identify the agent you are creating. Click **Next**, then **Publish Agent** to continue.

    ![Create Knowledge Agent screen showing step 2 of 3, with options to create the knowledge base with selected sources, a visible data source selection and a Knowledge Base configuration form with fields for agent name and description. 'Next' and 'Previous' buttons appear at the bottom of the screen.](images/kagent_config.png)

4. Wait a few moments while the agent is being published. After that you will be able to see it on the Knowledge Agent gallery.

## Task 2: Chat with your custom Knowledge Agent

![Knowledge Agents gallery screen showing two cards: one for 'My Knowledge Agent' trained on selected documentation, and another for 'Oracle AI Database Private Agent Factory Knowledge Assistant' based on documentation for Oracle AI Database Private Agent Factory. The screen also includes a search bar and a button to create a blank knowledge agent from scratch.](images/kagent_gallery.png)

Continuing from where the last task left off, click the recently created Knowledge Agent.

![Knowledge Base Chat screen for 'My Knowledge Agent' with tabs for messages, chat history, and help. The main chat area displays the prompt 'Ask a question to your knowledge base' with a message input field at the bottom containing 'How can I help you?'.](images/kagent_chat.png)

Here, you will be able to interact with the agent by asking questions and receiving grounded answers based on the ingested data from its knowledge base.

## Summary

This concludes the current module. You now know how to create Knowledge Agents with custom knowledge bases and interact with them to get grounded, specific information in an air-gapped environment. The next module will further explore other features of Oracle AI Database Private Agent Factory. Continue with them so you don't miss out on new discoveries and learning opportunities. You may now **proceed to the next lab**.

## Acknowledgements

- **Author** - Emilio Perez, Member of Technical Staff, Database Applied AI
- **Last Updated By/Date** - Emilio Perez - August 2025
