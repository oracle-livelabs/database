# Getting Started

## Introduction

In this lab, you will set up your Python environment and verify your connection to Oracle Database 26ai. Every subsequent lab runs in a Jupyter notebook, so this is where you get everything working.

**Estimated Time**: 10 minutes

### Objectives

* Install the required Python packages
* Connect to Oracle Database 26ai
* Initialize the LLM provider
* Verify everything works with a quick test

### Prerequisites

* Python 3.10 or later
* Access to an Oracle Database 26ai instance (provided in your reservation)
* An OpenAI API key (or OCI GenAI credentials)

## Task 1: Install Python Dependencies

1. Open a terminal and install all required packages.

    > Run this command in your terminal (not in a notebook).

    ```bash
    <copy>
    pip install langchain langchain-core langchain-openai langgraph
    pip install langchain-oracledb oracledb
    pip install sentence-transformers
    </copy>
    ```

    >**Note:** If you are using the provided lab environment, these packages are already installed.

## Task 2: Set Up Environment Variables

1. Set your database connection details and OpenAI API key.

    > You can set these in your terminal, in a `.env` file, or directly in the notebook.

    ```bash
    <copy>
    export ORACLE_USER="AGENT_USER"
    export ORACLE_PASSWORD="your_password_here"
    export ORACLE_DSN="localhost:1521/FREEPDB1"
    export OPENAI_API_KEY="your_openai_key_here"
    export OPENAI_MODEL="gpt-4o-mini"
    </copy>
    ```

    >**Note:** Replace the placeholder values with your actual credentials from the reservation information panel.

## Task 3: Launch Jupyter and Test the Connection

1. Launch Jupyter Notebook.

    ```bash
    <copy>
    jupyter notebook
    </copy>
    ```

2. Create a new Python notebook and run the following code to verify your Oracle connection.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    import oracledb
    import os

    conn = oracledb.connect(
        user=os.getenv("ORACLE_USER", "AGENT_USER"),
        password=os.getenv("ORACLE_PASSWORD"),
        dsn=os.getenv("ORACLE_DSN", "localhost:1521/FREEPDB1"),
    )
    print(f"Connected to Oracle as: {conn.username}")
    print(f"Database version: {conn.version}")
    </copy>
    ```

    You should see output like:

    ```
    Connected to Oracle as: AGENT_USER
    Database version: 26.1.0.0.0
    ```

3. Verify the LLM connection.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    from langchain_openai import ChatOpenAI

    llm = ChatOpenAI(
        model=os.getenv("OPENAI_MODEL", "gpt-4o-mini"),
        temperature=0,
    )

    response = llm.invoke("Say hello in exactly 5 words.")
    print(response.content)
    </copy>
    ```

    You should see a 5-word greeting from the LLM.

4. Verify LangGraph is available.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    from langchain_core.tools import tool
    from langgraph.prebuilt import create_react_agent

    @tool
    def add_numbers(a: int, b: int) -> int:
        """Add two numbers together."""
        return a + b

    test_agent = create_react_agent(
        model=llm,
        tools=[add_numbers],
    )

    response = test_agent.invoke({"messages": [("user", "What is 17 + 25?")]})
    print(response["messages"][-1].content)
    </copy>
    ```

    You should see the agent correctly answer "42".

## Task 4: Create the Shared Helper Functions

Every lab in this workshop uses two helper functions for database operations. Create these now so they're available throughout.

1. Define the helper functions that all labs will use.

    > Run this cell in your Jupyter notebook. You'll copy these into each lab notebook.

    ```python
    <copy>
    def execute_sql(conn, sql, params=None, commit=False):
        """Execute SQL and optionally commit. Returns rows for SELECT."""
        with conn.cursor() as cur:
            cur.execute(sql, params or {})
            if commit:
                conn.commit()
            if sql.strip().upper().startswith("SELECT"):
                return cur.fetchall()
        return None

    def execute_ddl(conn, sql):
        """Execute DDL (CREATE, DROP, etc.)."""
        with conn.cursor() as cur:
            cur.execute(sql)
        conn.commit()

    print("Helper functions ready.")
    </copy>
    ```

## Summary

You now have a working Python environment with:

* **oracledb** connected to Oracle Database 26ai
* **LangChain + LangGraph** for building agents
* **OpenAI** (or your chosen LLM provider) for reasoning
* **Helper functions** for database operations

You are ready to build your first AI agent in Lab 1.

## Acknowledgements

* **Author** - David Start
* **Last Updated By/Date** - David Start, February 2026
