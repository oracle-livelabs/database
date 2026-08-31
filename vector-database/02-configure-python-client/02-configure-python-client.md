# Lab 3: Install oracle-vecdb package

## Introduction

Install the `oracle-vecdb` package in an Oracle Machine Learning (OML) notebook. Then configure an Oracle VecDB client and test its connection.

By the end of this lab, you will have an installed SDK, a configured `vecdb` client, and a verified REST connection that you will reuse throughout the workshop.

Throughout this workshop, create a new OML paragraph for each code block, then use the Copy button and run the paragraph. Unless stated otherwise, later paragraphs use variables created in earlier paragraphs.

Estimated Time: X

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

The OML Python interpreter is a managed environment that does not allow you to install packages in its shared environment with a standard `pip install` command. This installation paragraph does four things: it installs `oracle-vecdb` and a compatible `typing_extensions` version in `/tmp`, adds `/tmp` to the active Python path, clears incompatible shared modules, and imports the compatible package. If you shut down this notebook or its Python environment restarts, run this paragraph again.

If you run this lab in a Jupyter notebook outside OML, use the Jupyter installation step later in this task.

1. In the `vector-database-workshop` notebook you created in Lab 2, add a new Python paragraph below the test paragraph from Lab 2 and run the following code.

    ```
    <copy>
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
    </copy>
    ```

2. Confirm that the paragraph prints `True`. This verifies that the compatible `typing_extensions` file was installed in `/tmp`; a successful run without an import error confirms that the package environment is ready.

3. If you are using your own Jupyter environment instead of an OML Notebook, add a new notebook cell and run the following code.

    ```
    <copy>
    %pip install oracle-vecdb
    </copy>
    ```

## Task 2: Configure the client

OML paragraphs share state while the notebook's Python environment remains active. The import, connection settings, and `vecdb` client you create in this task remain available to later paragraphs unless the environment restarts.
1. Add a new Python paragraph and run the following code.

    `OracleVecDB` is the SDK client for the Vector Database REST API. `Configuration` stores its connection settings. This step imports the classes; it does not connect to the database yet.

    ```
    <copy>
    %python
    from oracle_vecdb import OracleVecDB, Configuration
    </copy>
    ```

2. Add a new Python paragraph and run the following code. Production applications normally load credentials from an `.env` file or secret store. For this workshop, replace each placeholder with the REST URL, username, and password you recorded in Lab 1.

    This workshop uses HTTP Basic authentication: REST URL, username, and password. It does not use OAuth. Do not include the angle brackets in your values, and do not commit real credentials to source control.

    ```
    <copy>
    %python
    URL = "<REST URL copied in Lab 1>"
    USER = "VECTOR_USER"
    PWD = "<database password>"
    </copy>
    ```

3. Add a new Python paragraph and run the following code.

    `Configuration` stores the ORDS REST endpoint and HTTP Basic-authentication credentials. `OracleVecDB` uses those settings for SDK calls. Creating this local client object does not validate the connection; Task 3 makes the first service call.

    ```
    <copy>
    %python
    vecdb = OracleVecDB(
        Configuration(
            rest_url=URL,
            username=USER,
            password=PWD,
        )
    )
    </copy>
    ```

## Task 3: Test Connection

1. Add a new Python paragraph and run the following code.

    `describe_vector_database()` makes an authenticated SDK call and returns a summary of the models, tables, and vectors visible to the connected user.

    ```
    <copy>
    %python
    db_stats = vecdb.describe_vector_database()
    print(
        f"Models: {db_stats.total_models} | "
        f"Tables: {db_stats.total_tables} | "
        f"Vectors: {db_stats.total_vectors:,}"
    )
    </copy>
    ```

2. Confirm that the paragraph displays the number of models, tables, and vectors in the database. A successful response proves that the REST URL and credentials work, even if one or more counts are zero. Keep this notebook open; Lab 4 uses the `vecdb` client to inspect models and create vector tables.

## Learn More

- [Oracle VecDB Python SDK quick start](https://docs.oracle.com/en/cloud/paas/autonomous-database/vcapi/quickstart.html)
- [Oracle VecDB Configuration reference](https://docs.oracle.com/en/cloud/paas/autonomous-vector-database/vcapi/configuration.html)
- [Use the Python interpreter in an OML Notebook paragraph](https://docs.oracle.com/en/database/oracle/machine-learning/oml-notebooks/omlug/run-python-notebook.html)

## Acknowledgements

* **Author** - Oracle LiveLabs workshop authoring team
* **Last Updated By/Date** - Codex, August 27, 2026

