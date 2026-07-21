# Lab 1: Set Up Your Workspace and Run the Preflight

## Introduction

You start from an **empty** Autonomous AI Database. In this lab you open the two tools you will use all session, connect standard MongoDB tooling to Oracle, and run a preflight that validates every dependency of every later lab — so any problem surfaces now, not during the finale.

Workspace convention for the whole session: **Cloud Shell (mongosh) in one browser tab, Database Actions (SQL worksheet) in another** — switches should be glances, not tab hunts.

Estimated Lab Time: 5 minutes (runs during the instructor introduction in a live session)

### Objectives

* Open Database Actions and the SQL worksheet as your schema user
* Open OCI Cloud Shell and connect `mongosh` to your database's MongoDB API endpoint
* Run the preflight and see five green PASS lines

### Prerequisites

* A running Autonomous AI Database with the MongoDB API enabled (the LiveLabs sandbox provides this; own-tenancy users run the setup kit in the workshop README first)
* Your database username and password from the reservation page

## Task 1: Open Database Actions

1. From your reservation page (or the OCI console: your database → **Database Actions**), open **Database Actions** and sign in as your schema user.

2. Open the **SQL** worksheet. Leave this tab open for the whole session — it is your relational door.

## Task 2: Connect mongosh in Cloud Shell

1. Open **Cloud Shell** from the OCI console header (`>_` icon). `mongosh` is preinstalled.

2. Build your connection string: copy your database's MongoDB API URL from **Database Actions → Related Services → Oracle Database API for MongoDB**, then substitute your username and password. It looks like this (one line):

    ```
    <copy>
    mongosh 'mongodb://USERNAME:PASSWORD@HOST.adb.REGION.oraclecloudapps.com:27017/USERNAME?authMechanism=PLAIN&authSource=$external&tls=true&retryWrites=false&loadBalanced=true'
    </copy>
    ```

    Replace `USERNAME`, `PASSWORD`, and the host with your values. If your password contains special characters, URL-encode them.

3. You should land at a `mongosh` prompt showing your schema name. Unchanged Mongo tooling, Oracle endpoint — that is the point of the whole session.

## Task 3: Run the Preflight

1. In the **SQL worksheet**, paste and run the SQL preflight (also in `scripts/00_preflight.sql`):

    ```
    <copy>
    -- PREFLIGHT: validates every dependency of Labs 2-8
    SELECT 'SQL worksheet connected as ' || USER AS check_1 FROM dual;

    SELECT 'ONNX model present: ' ||
           NVL(MAX(model_name), '*** MISSING - tell a proctor ***') AS check_2
    FROM   user_mining_models
    WHERE  model_name = 'MENU_MODEL';

    SELECT 'Application tables: ' || COUNT(*) ||
           ' (expected 0 - you are at the starting line)' AS check_3
    FROM   user_tables
    WHERE  table_name NOT LIKE 'DM$%'
    AND    table_name NOT LIKE 'SYS_%';
    </copy>
    ```

    **What you should see:** your username, `ONNX model present: MENU_MODEL`, and `Application tables: 0`. The `DM$%` filter matters — the pre-loaded embedding model keeps system backing tables that are *supposed* to be there.

2. In **mongosh**, run the non-destructive connectivity check (also in `scripts/00_preflight_mongo.js`):

    ```
    <copy>
    db.runCommand({ ping: 1 })
    </copy>
    ```

    **What you should see:** `{ ok: 1 }`. If this fails, the usual cause is the database's network access list — call a proctor now, not in Lab 5.

3. In mongosh, confirm the schema is empty:

    ```
    <copy>
    show collections
    </copy>
    ```

    **What you should see:** nothing. An empty database, two open doors. You are ready.

## Learn More

* [Oracle Database API for MongoDB — connection strings](https://docs.oracle.com/en/database/oracle/mongodb-api/mgapi/)

## Acknowledgements
* **Author** - Rick Houlihan, Field CTO, Oracle Data & AI Platform
* **Last Updated By/Date** - Rick Houlihan, July 2026
