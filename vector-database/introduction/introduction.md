# Build Python Vector Applications with Autonomous AI Vector Database

## Introduction

Autonomous AI Vector Database gives developers a vector-native service for semantic search, RAG, recommendations, and agent memory. In this workshop, you use Python to connect to a Vector Database endpoint, load sample records, generate or provide vectors, search by meaning, tune search behavior, and assemble a retrieval pipeline that can feed an LLM.

Estimated Workshop Time: 90 minutes

### Objectives

- Configure the `oracle-vecdb` Python SDK.
- Load text records with integrated embedding.
- Run semantic search and metadata-filtered search.
- Create vector indexes for approximate search.
- Build a small Python memory pattern.


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

1. Follow this sequence to build the National Parks semantic-search application:

    - **Get Started: Log In to the LiveLabs Sandbox** provides access to the workshop environment.
    - **Lab 1: Working with the Vector Database Console** retrieves the REST URL, reviews embedding models, and explores the console.
    - **Lab 2: Get Started with Oracle Machine Learning Notebooks** opens OML, creates a notebook, and runs Python paragraphs.
    - **Lab 3: Install oracle-vecdb package** installs the SDK in OML, configures the client, and tests the connection.
    - **Lab 4: Understand Models, Records, and Vector Tables** reviews models and creates integrated and bring-your-own-vector tables.
    - **Lab 5: Create Embeddings and Load Text** reads the National Parks data and loads it into the integrated `parks` table.
    - **Lab 6: Run Baseline Semantic Search** runs natural-language searches and adds metadata filters.
    - **Lab 7: Create a Query Memory Module** saves user queries and uses them to make memory-aware park searches.
    - **Lab 8: Create Indexes for Approximate Search** creates and compares approximate-search indexes.
    - **Lab 9: Use Bring-Your-Own Vectors and Metadata Filters** works with externally generated vectors and metadata filters.
    - **Lab 10: Build a Python Search API** packages the search workflow behind a reusable Python boundary.

2. Keep these workshop values nearby:

    ```text
    REST URL=<REST URL copied from the Vector Database Console>
    USER=VECTOR_USER
    PWD=<database password>
    EMBED_MODEL=all_MiniLM_L12_v2
    PAR_URL=<National Parks Object Storage PAR URL>
    ```
## Learn More

- [Oracle LiveLabs](https://livelabs.oracle.com/)
- [Oracle Cloud](https://cloud.oracle.com/)

## Acknowledgements

* **Author** - Oracle LiveLabs workshop authoring team
* **Source Workshop** - Getting Started with AI Vector Search
* **Last Updated By/Date** - Codex, May 28, 2026



