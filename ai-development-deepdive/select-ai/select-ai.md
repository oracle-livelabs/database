# Lab 5 - Select AI  

## Introduction

![image]("images/select-ai-intro.png")

Select AI enables SQL access to generative AI using Large Language Models (LLMs) and embedding models. This includes support for natural language to SQL query generation and retrieval augmented generation, among other features.

Select AI generates, runs, and explains SQL queries from user-provided natural language prompts. It automates tasks that users would otherwise perform manually using their schema metadata and a large language model (LLM) of their choice. Additionally, it facilitates retrieval augmented generation with vector stores and enables chatting with the LLM.

Here are the steps we will cover:

1. Create an AI Profile.
2. Generate summaries for each of your documents.
3. Use the Select AI 'narrate' function to generate SQL from a natural language prompt, execute the SQL and pass the results to an LLM to present a well-formed response.
4. Show the generated SQL from 'narrate'.
5. Use Select AI as a chatbot.

### **Prerequisites**
This lab assumes you have:
- All previous labs successfully completed

## Task 1: Create an AI Profile

Refer to Task 1 of the Jupyter notebook as go through this task.

Oracle AI Database 26ai uses AI profiles to facilitate and configure access to an LLM and to setup for generating, running, and explaining SQL based on natural language prompts. It also facilitates retrieval augmented generation using embedding models and vector indexes and allows for chatting with the LLM.

AI profiles include database objects that are the target for natural language queries. Metadata used from these targets can include database table names, column names, column data types, and comments.

You create and configure AI profiles using the DBMS_CLOUD_AI.CREATE_PROFILE and DBMS_CLOUD_AI.SET_PROFILE procedures.

In addition to specifying tables and views in the AI profile, you can also specify tables mapped with external tables, including those described in Query External Data with Data Catalog. This enables you to query data not just inside the database, but also data stored in a data lake's object store.

