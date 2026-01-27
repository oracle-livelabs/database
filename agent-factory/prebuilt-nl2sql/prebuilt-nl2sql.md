# Data Analysis Agent: A Pre-Built Database Agent for NL2SQL

## Introduction

In this lab session, you will learn how to create Data Analysis Agents and connect them to your data sources to safely access and get accurate interpretations of your enterprise data.

A **Data Analysis Agent** interacts with enterprise databases, understands schema structures, and automatically extracts semantic insights using LLM capabilities.

These agents are capable of generating semantic and data-relevant questions through variation analysis, providing LLM-powered explanations, and automatic visualization generation. They are integration-ready and can connect to a variety of supported structured data sources like Oracle Database 19c and above.

> Note: The screenshots in this lab use an example “Production Database” and “NATIONAL_PARKS” table for illustration purposes. You may use any database and table accessible within your environment when following these steps.

**Estimated time:** 15 minutes.

### Objectives

By the end of this lab, you will be able to:

- Set up a Data Analysis Agent and link it to a designate enterprise data source.
- Configure agent metadata to ensure accurate data representation and usability.
- Deploy the agent and interact with it to generate and interpret data-driven insights using natural language queries.

### Prerequisites

To follow this tutorial, it is suggested that you have access to an Oracle AI Database Private Agent Factory environment with permissions to add and manage Data Analysis Agents and connect to at least one structured data source.

## Task 1: Create Data Analysis Agent

In this task, you will create a custom Data Analysis Agent to work directly with your data.

1. Open Oracle AI Database Private Agent Factory and log in. In the sidebar, click the **Data Analysis Agent** section.

    ![Main dashboard of Oracle AI Database Private Agent Factory with the left navigation panel expanded. The Data Analysis Agent option under the Pre-built Agents section is highlighted, and the Get Started page is displayed with pre-built agent options and a quick start guide on the right.](images/get_started_data_analysis.png)

    ![Data Analysis Agents screen displaying a search bar and a card for creating a blank data analysis agent from scratch.](images/data_analysis.png)

2. Click the **Blank Data Analysis Agent** button. A setup form will appear, allowing you to select the data source for this agent. (Note that, at this time, Data Analysis Agents only support a single table or view for analysis)

    ![Create Data Analysis Agent screen showing step 1 of 3, allowing selection of database sources. Users can select a database and table from dropdown menus, add a new database source, and proceed to the next step or cancel. A note indicates only a single table is supported. 'Next' and 'Cancel' buttons appear at the bottom of the screen.](images/data_analysis_data_source.png)

    For this task, choose **Database Sources**, then use the "Select database" drop-down menu to pick an available enterprise database in your environment you want to work with. Similarly, select any table you would like to analyze from the "Select table" menu. Click the **Next** button to continue.

> The screenshots use an example database and table; your selections may differ based on what is available to you.

## Task 2: Fill Up Agent Details

![Create Data Analysis Agent screen showing step 2 of 3, allowing to fill up agent details. Users can review the selected sources and complete a form with fields for agent name, description an help description. 'Next' and 'Previous' buttons appear at the bottom of the screen.](images/data_analysis_config.png)

On this screen, you can configure your Data Analysis Agent with the selected sources. The setup form allows you to provide an agent name and description to help users identify it, as well as a Help Description in Markdown format. This Help Description assists the LLM in better understanding the agent's purpose, enabling it to provide more accurate and relevant answers.

For this tutorial, use information that describes your chosen data source. For example:

- **Agent Name**: [Your Agent Name] (e.g., “Sales Data Analyst”)
- **Description**: A data analysis agent for the selected data source.
- **Help Description**: A brief summary of the dataset (e.g., “A comprehensive dataset of quarterly sales results including region, product, and revenue data.”)

Click the **Next** button to continue.

You will see the Publish Agent screen, where you can review the information provided and deploy the Data Analysis Agent.

![Create Data Analysis Agent screen showing step 3 of 3, where users can review and deploy the agent before publishing. The agent summary displays the agent name, Oracle tables, and CSV files, along with the selected Oracle Table (NATIONAL_PARKS - Production database). 'Publish Agent' and 'Previous' buttons appear at the bottom of the screen.](images/data_analysis_publish_agent.png)

Click the **Publish Agent** button to proceed. Please wait a few seconds; you will be greeted with a success message. The newly created agent will then appear on the Data Analysis Agents Gallery.

![Data Analysis Agents screen displaying a search bar and a card for the National Parks Data Analyst, which is described as a data analysis agent trained on selected data sources. A button for creating a blank data analysis agent from scratch appears at the bottom.](images/data_analysis_gallery.png)

## Task 3: Interact with your Data Analysis Agent

Click on the newly created agent to open a new chat. Here, you can interact with the agent and get answers based on your source data.

When you start a chat for the first time, it may take a few moments for the agent to review and interpret the information on the database. Once complete, several interesting insights will be displayed.

![National Parks Data Analyst chat screen showing the agent interacting with user queries about national parks data. The screen displays responses with SQL queries, answer tables, and visualizations. An 'Execute Exploration' button is in the top right, and a user prompt is entered in the chat input field at the bottom.](images/data_analyst_initial_insights.png)

The agent will suggest some pertinent questions about the data and present the corresponding answers. Depending on the query, the responses may be in natural language text, visualizations, table, and regardless it will share the SQL statement used to generate the answers.

![National Parks Data Analyst chat screen showing the user asking for the top 10 states with the most parks. The agent responds with a numbered list of states and their counts. 'Execute Exploration' button is visible in the top right, and the chat input field is at the bottom.](images/data_analyst_specific_QA.png)

You can ask your own questions about the dataset with natural language, and the agent will provide an appropriate answer.

![National Parks Data Analyst chat screen showing a bar chart visualization in response to a user query. The chart displays the number of parks by state. The 'Execute Exploration' button is at the top right, and the chat input field is at the bottom.](images/data_analyst_custom_QA.png)

## Summary

This concludes the current module. You now know how to create Data Analysis Agents with your own structured data to obtain valuable insights in an air-gapped environment. The next module will further explore other features of Oracle AI Database Private Agent Factory. Continue with them so you don't miss out on new discoveries and learning opportunities. You may now **proceed to the next lab**.

## Acknowledgements

- **Author** - Emilio Perez, Member of Technical Staff, Database Applied AI
- **Last Updated By/Date** - Emilio Perez - August 2025
