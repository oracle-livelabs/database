# Provision an Autonomous AI Vector Database

## Introduction

In this lab, you create or identify the Autonomous AI Vector Database for the Python app. You also test console and REST access.

Estimated Time: 10 minutes

### Objectives

- Provision an Autonomous AI Vector Database.
- Record the vector database REST URL.
- Confirm that a vector database user can access the service.

### Prerequisites

- Oracle Cloud account with rights to create Autonomous AI Vector Database resources.
- Access to the compartment and region where the workshop database will run.

## Task 1: Create the Database Instance

1. In the Oracle Cloud Console, open the navigation menu.

2. Go to **Analytics and AI**, then select **Autonomous AI Vector Database**.

3. Click **Create Autonomous AI Vector Database**.

4. Enter a display name and database name.

    Use a name that is easy to recognize during the workshop, such as:

    ```text
    vecdbpython
    ```

5. Create the initial Autonomous AI Vector Database user.

    Record the user name and password. You will use this account from Python in later labs.

6. Submit the create request and wait until the lifecycle state is available.

## Task 2: Open the Vector Database Console

1. Open the database details page.

2. Launch the Vector Database Console or Database Actions entry point for the database.

3. Sign in with the vector database user you created during provisioning.

4. Confirm that the console shows vector-specific tasks such as models, vector tables, and query playground capabilities.

## Task 3: Record Connection Values

1. Build the REST URL for the vector database service.

    The Python SDK and REST API use this URL shape:

    ```text
    https://<host>/ords/<schema>/_/db-api/stable/vecdb/
    ```

2. Record the following values in a local note.

    ```text
    VECDB_REST_URL=<your-vector-database-rest-url>
    VECDB_USERNAME=<your-vector-database-user>
    VECDB_PASSWORD=<password>
    ```

3. If your environment uses OAuth, record a bearer token instead of a password.

    ```text
    VECDB_ACCESS_TOKEN=<bearer-token>
    ```

## Learn More

- Oracle Autonomous AI Vector Database docs
- Oracle REST Data Services OAuth docs

## Acknowledgements

* **Author** - Oracle LiveLabs workshop authoring team
* **Last Updated By/Date** - Codex, May 28, 2026
