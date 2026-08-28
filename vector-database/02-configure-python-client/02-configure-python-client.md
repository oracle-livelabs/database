# Lab 3: Install oracle-vecdb package

## Introduction

Install the `oracle-vecdb` package in an Oracle Machine Learning (OML) notebook. Then configure an Oracle VecDB client and test its connection.

Estimated Time: 15 minutes

### Objectives

- Install the `oracle-vecdb` package in an OML notebook.
- Configure an Oracle VecDB client with REST URL and database credentials.
- Test the connection to your vector database.

### Prerequisites

- Complete Lab 1: Working with the Vector Database Console.
- Complete Lab 2: Get Started with Oracle Machine Learning Notebooks.
- Have the REST URL and database credentials for the workshop vector database.

## Task 1: Install oracle-vecdb

In OML Notebooks, a **paragraph** is a unit of runnable code. Start it with `%python` to select the Python interpreter.

The OML Python interpreter is a managed environment. Do not install packages into its shared environment with a standard `pip install` command. This code installs the package and a compatible `typing_extensions` version in `/tmp`. It then adds `/tmp` to the current Python path. Run this paragraph again after a notebook-service restart.

1. In the `vector-database-workshop` notebook you created in Lab 2, select **Add Paragraph**.

2. Copy the following code into the new paragraph, then run it.

    <copy>
    ```python
    %python
    import importlib
    import subprocess
    import sys
    from pathlib import Path

    result = subprocess.run(
        [
            sys.executable,
            "-m",
            "pip",
            "install",
            "--target",
            "/tmp",
            "--ignore-installed",
            "oracle-vecdb",
            "typing_extensions>=4.14.0",
            "--index-url",
            "https://pypi.org/simple",
        ],
        capture_output=True,
        text=True,
    )

    if result.returncode != 0:
        raise RuntimeError(result.stderr)

    print(Path("/tmp/typing_extensions.py").exists())  # Should print True

    sys.path.insert(0, "/tmp")
    importlib.invalidate_caches()

    # Ensure the shared older copy is not reused.
    for name in list(sys.modules):
        if name == "typing_extensions" or name.startswith("pydantic"):
            sys.modules.pop(name, None)

    import typing_extensions
    ```
    </copy>

3. Confirm that the paragraph prints `True`.

4. If you are using your own Jupyter environment instead of an OML Notebook, install the package with a standard pip command.

    <copy>
    ```bash
    pip install oracle-vecdb
    ```
    </copy>

## Task 2: Configure the client

1. Add a new paragraph. Copy the following code into it and run it.

    `OracleVecDB` is the SDK client for the Vector Database REST API. `Configuration` stores its connection settings.

    <copy>
    ```python
    %python
    from oracle_vecdb import OracleVecDB, Configuration
    ```
    </copy>

2. Add another paragraph. Production applications normally load credentials from an `.env` file or secret store. For this workshop, enter the Lab 1 REST URL and database credentials directly in the paragraph.

    This workshop uses HTTP basic authentication: REST URL, username, and password. It does not use OAuth.

    <copy>
    ```python
    %python
    URL = "<REST URL copied in Lab 1>"
    USER = "VECTOR_USER"
    PWD = "<database password>"
    ```
    </copy>

3. Add a new paragraph. Copy the following code into it and run it to create the client.

    `Configuration` stores the ORDS REST endpoint and HTTP basic-authentication credentials. `OracleVecDB` uses it for SDK calls.

    <copy>
    ```python
    %python
    vecdb = OracleVecDB(
        Configuration(
            rest_url=URL,
            username=USER,
            password=PWD,
        )
    )
    ```
    </copy>

## Task 3: Test Connection

1. Add a new paragraph. Copy the following code into it and run it.

    `describe_vector_database()` returns model, table, and vector counts. A response confirms that the REST URL and credentials work.

    <copy>
    ```python
    %python
    db_stats = vecdb.describe_vector_database()
    print(
        f"Models: {db_stats.total_models} | "
        f"Tables: {db_stats.total_tables} | "
        f"Vectors: {db_stats.total_vectors:,}"
    )
    ```
    </copy>

2. Confirm that the paragraph displays the number of models, tables, and vectors in the database.

## Learn More

- [Oracle VecDB Python SDK quick start](https://docs.oracle.com/en/cloud/paas/autonomous-database/vcapi/quickstart.html)
- [Oracle VecDB Configuration reference](https://docs.oracle.com/en/cloud/paas/autonomous-vector-database/vcapi/configuration.html)
- [Use the Python interpreter in an OML Notebook paragraph](https://docs.oracle.com/en/database/oracle/machine-learning/oml-notebooks/omlug/run-python-notebook.html)

## Acknowledgements

* **Author** - Oracle LiveLabs workshop authoring team
* **Last Updated By/Date** - Codex, August 27, 2026

