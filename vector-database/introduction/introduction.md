# Build Python Vector Applications with Autonomous AI Vector Database

## Introduction

Autonomous AI Vector Database gives developers a vector-native service for semantic search, RAG, recommendations, and agent memory. In this workshop, you use Python to connect to a Vector Database endpoint, load sample records, generate or provide vectors, search by meaning, tune search behavior, and assemble a retrieval pipeline that can feed an LLM.

Estimated Workshop Time: 90 minutes

### Objectives

- Provision or access an Autonomous AI Vector Database.
- Configure the `oracle-vecdb` Python SDK.
- Load text records with integrated embedding.
- Run semantic search and metadata-filtered search.
- Create vector indexes for approximate search.
- Build a small Python search API pattern.
- Assemble retrieved context for a RAG workflow.

### Prerequisites

- Oracle Cloud account with permission to create Autonomous AI Vector Database resources.
- Python 3.10 or later on your development machine.
- Ability to install Python packages with `pip`.
- An Autonomous AI Vector Database REST endpoint in this format:

    ```text
    https://<host>/ords/<schema>/_/db-api/stable/vecdb/
    ```

- A vector database user name and password, or an OAuth bearer token.

## Task 1: Review the Workshop Flow

1. Use the following sequence to build up the application workflow:

    - Lab 1 provisions an Autonomous AI Vector Database and confirms access to the Vector Database Console.
    - Lab 2 configures the Python SDK and creates a reusable client helper.
    - Lab 3 creates vector tables and confirms model availability.
    - Lab 4 loads sample park records with integrated embedding.
    - Lab 5 runs baseline semantic search.
    - Lab 6 creates indexes and compares approximate search behavior.
    - Lab 7 maps the image-search lab to a bring-your-own-vector workflow with metadata filters.
    - Lab 8 replaces the APEX demo with a small Python API pattern.
    - Lab 9 builds a retrieval step for RAG.

2. Keep these values nearby as you work through the labs:

    ```text
    VECDB_REST_URL=https://<host>/ords/<schema>/_/db-api/stable/vecdb/
    VECDB_USERNAME=<vector-database-user>
    VECDB_PASSWORD=<password>
    VECDB_ACCESS_TOKEN=<optional-bearer-token>
    VECDB_EMBED_MODEL=all_MiniLM_L12_v1
    ```

## Learn More

- [Oracle LiveLabs](https://livelabs.oracle.com/)
- [Oracle Cloud](https://cloud.oracle.com/)

## Acknowledgements

* **Author** - Oracle LiveLabs workshop authoring team
* **Source Workshop** - Getting Started with AI Vector Search
* **Last Updated By/Date** - Codex, May 28, 2026
