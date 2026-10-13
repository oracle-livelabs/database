# Build AI Applications with Oracle Autonomous AI Vector Database and Python

## Introduction

AI applications are only as useful as the information they can retrieve. Autonomous AI Vector Database helps you build semantic search, retrieval-augmented generation (RAG), and agentic applications without having to operate separate infrastructure for vectors, models, and application data.

Using the Oracle VecDB Python SDK, you can create vector tables, generate embeddings, store metadata, and search by meaning through a REST-based API. Because the service is built on Oracle Autonomous AI Database, your application benefits from managed operations, security, scalability, and the ability to keep vector data alongside the enterprise data it helps users find.

In this workshop, you build a National Parks semantic-search application step by step. You will load data from Oracle Object Storage, use auto-generated vector embeddings for park descriptions, use bring-your-own vector embeddings for park weather information, combine semantic search with metadata filters, and package retrieval as an agent context tool.

By the end of the workshop, you will have a practical Python pattern you can adapt for document search, product discovery, support knowledge bases, RAG retrieval, or agent tools. You will understand when to use auto-generated vector embeddings, when to use bring-your-own vector embeddings, and how to evolve a working prototype into a more scalable search experience.

Estimated Workshop Time: 30 minutes

### Objectives

- Install the `oracle-vecdb` Python SDK.
- Create vector tables for auto-generated vector embeddings and bring-your-own vector embeddings.
- Load JSON records.
- Run semantic search and metadata-filtered search.
- Build an agent-facing context retrieval function.


## Task 1: Review the Workshop Flow

1. Follow this sequence to build the National Parks semantic-search application:

    - **Get Started: Log In to the LiveLabs Sandbox** provides access to the workshop environment.
    - **Lab 1: Working with the Vector Database Console** retrieves the REST URL, reviews embedding models, and explores the console.
    - **Lab 2: Get Started with Oracle Machine Learning Notebooks** opens OML, creates a notebook, and runs Python paragraphs.
    - **Lab 3: Install oracle-vecdb package** installs the SDK in OML, configures the client, and tests the connection.
    - **Lab 4: Understand Models, Records, and Vector Tables** reviews models and creates tables for auto-generated vector embeddings and bring-your-own vector embeddings.
    - **Lab 5: Create Embeddings and Load Text** reads the National Parks data, loads records into the `parks` table with auto-generated vector embeddings, and generates bring-your-own vector embeddings for the `weather` table.
    - **Lab 6: Run Baseline Semantic Search** searches both vector tables and adds metadata filters.
    - **Lab 7: Build an Agent Context Tool** packages semantic search and metadata filtering as a read-only function that an agent can call.

## Learn More

- [Oracle LiveLabs](https://livelabs.oracle.com/)
- [Oracle Cloud](https://cloud.oracle.com/)

## Acknowledgements

* **Author** - Oracle LiveLabs workshop authoring team
* **Source Workshop** - Getting Started with AI Vector Search
* **Last Updated By/Date** - September 28, 2026
