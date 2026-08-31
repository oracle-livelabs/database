# Build Python Vector Applications with Autonomous AI Vector Database

## Introduction

AI applications are only as useful as the information they can retrieve. Autonomous AI Vector Database helps you build semantic search, retrieval-augmented generation (RAG), and memory-aware applications without having to operate separate infrastructure for vectors, models, and application data.

Using the Oracle VecDB Python SDK, you can create vector tables, generate embeddings, store metadata, and search by meaning through a REST-based API. Because the service is built on Oracle Autonomous AI Database, your application benefits from managed operations, security, scalability, and the ability to keep vector data alongside the enterprise data it helps users find.

In this workshop, you build a National Parks semantic-search application step by step. You will load data from Oracle Object Storage, use integrated embedding to create vectors automatically, bring your own vectors for park directions, combine semantic search with metadata filters, and compare baseline and indexed search behavior. You will also create a small query-memory module that captures prior requests and uses them to make future searches more context-aware.

By the end of the workshop, you will have a practical Python pattern you can adapt for document search, product discovery, support knowledge bases, RAG retrieval, or agent memory. You will understand when to use integrated embedding, when to supply vectors yourself, and how to evolve a working prototype into a more scalable search experience.

Estimated Workshop Time: 90 minutes

### Objectives

- Install the `oracle-vecdb` Python SDK.
- Create vector tables using integrated embedding and bring-your-own vectors.
- Load JSON records.
- Run semantic search and metadata-filtered search.
- Create vector indexes for approximate search.
- Build a small Python memory pattern.


## Task 1: Review the Workshop Flow

1. Follow this sequence to build the National Parks semantic-search application:

    - **Get Started: Log In to the LiveLabs Sandbox** provides access to the workshop environment.
    - **Lab 1: Working with the Vector Database Console** retrieves the REST URL, reviews embedding models, and explores the console.
    - **Lab 2: Get Started with Oracle Machine Learning Notebooks** opens OML, creates a notebook, and runs Python paragraphs.
    - **Lab 3: Install oracle-vecdb package** installs the SDK in OML, configures the client, and tests the connection.
    - **Lab 4: Understand Models, Records, and Vector Tables** reviews models and creates integrated and bring-your-own-vector tables.
    - **Lab 5: Create Embeddings and Load Text** reads the National Parks data and loads it into the integrated `parks` table.
    - **Lab 6: Run Baseline Semantic Search** runs natural-language searches and adds metadata filters.
    - **Lab 7: Create a Query Memory Module** saves user queries and uses them to make memory-aware park searches.
    - **Lab 8: Create Indexes for Approximate Search (Optional)** creates and compares approximate-search indexes.

## Learn More

- [Oracle LiveLabs](https://livelabs.oracle.com/)
- [Oracle Cloud](https://cloud.oracle.com/)

## Acknowledgements

* **Author** - Oracle LiveLabs workshop authoring team
* **Source Workshop** - Getting Started with AI Vector Search
* **Last Updated By/Date** - Codex, May 28, 2026



