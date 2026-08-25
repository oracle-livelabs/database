# Configure a Python Client

## Introduction

In this lab, you install the `oracle-vecdb` Python SDK. You also create a local config file and test the endpoint.

Estimated Time: 10 minutes

### Objectives

- Create a Python virtual environment.
- Install the Oracle VecDB SDK.
- Create a reusable Python client helper.
- List models and vector tables from Python.

### Prerequisites

- Autonomous AI Vector Database instance from Lab 1.
- Python 3.10 or later.

## Task 1: Create a Python Environment

1. Open a terminal in the workshop folder.

2. Create and activate a virtual environment.

    ```bash
    python -m venv .venv
    .venv\Scripts\activate
    ```

3. Install the Python dependencies.

    ```bash
    python -m pip install --upgrade pip
    python -m pip install -r files/requirements.txt
    ```

## Task 2: Configure Environment Variables

1. Copy the example environment file.

    ```bash
    copy files\.env.example .env
    ```

2. Open `.env` in an editor.

3. Replace the placeholder values with your connection details.

    ```text
    VECDB_REST_URL=https://<host>/ords/<schema>/_/db-api/stable/vecdb/
    VECDB_USERNAME=<vector-database-user>
    VECDB_PASSWORD=<password>
    VECDB_ACCESS_TOKEN=
    VECDB_EMBED_MODEL=all_MiniLM_L12_v1
    ```

4. If your environment uses OAuth, set `VECDB_ACCESS_TOKEN` and leave the user name and password blank.

## Task 3: Verify the SDK

1. Create a file named `verify.py` in the workshop folder.

    ```python
    from files.vector_client import make_client, print_items

    vecdb = make_client()

    print_items("Vector database summary", vecdb.describe_vector_database())
    print_items("Loaded models", vecdb.list_models())
    print_items("Vector tables", vecdb.list_vector_tables())
    ```

2. Run the script.

    ```bash
    python verify.py
    ```

3. Confirm that the script returns service metadata, a list of loaded models, or an empty model list.

    An empty list is fine. You will load or select a model in a later lab.

## Learn More

- Python SDK quick start in `oracle-vecdb-api-ref-1.0.0b2.zip`

## Acknowledgements

* **Author** - Oracle LiveLabs workshop authoring team
* **Last Updated By/Date** - Codex, May 28, 2026
