# Connect to Your Environment and Run the Preflight

## Introduction

You start from an **empty** Autonomous AI Database. In this lab you open the two tools you will use all session — the **SQL worksheet** in Database Actions and **Cloud Shell** with the MongoDB shell — and run a preflight that checks every dependency of every later lab, so problems surface now rather than during the finale.

Workspace convention for the whole session: **Cloud Shell (mongosh) in one browser tab, Database Actions (SQL worksheet) in another** — switching should be a glance, not a tab hunt.

Estimated Lab Time: 10 minutes

### Objectives

In this lab, you will:

* Navigate the OCI console to your database and open the SQL worksheet
* Open Cloud Shell and install the MongoDB shell (`mongosh`)
* Connect `mongosh` to your database's MongoDB API endpoint
* Run the preflight and confirm you are at the starting line

### Prerequisites

* An Autonomous AI Database with the MongoDB API enabled
  * **LiveLabs sandbox:** provisioned for you — your username, password, and compartment are on the reservation page ("View Login Info")
  * **Your own tenancy / Free Trial:** the instance you created in the previous lab

## Task 1: Open Database Actions and the SQL Worksheet

1. Sign in to the **Oracle Cloud Console** (`cloud.oracle.com`).

    * **LiveLabs sandbox:** use the username and password from your reservation page. You will be prompted to change the password on first sign-in.
    * **Your own tenancy:** sign in as usual.

2. Check your **region** in the top-right corner of the console. It must match the region your database was created in — for a LiveLabs sandbox, the region shown on your reservation page.

    ![Region selector in the upper-right corner of the console](images/region.png " ")

3. Click the **navigation menu** in the upper-left corner, choose **Oracle AI Database**, then **Autonomous AI Database**.

4. Set the **compartment** in the left-hand *List scope* panel — this is the step most people miss, and an empty list is almost always the wrong compartment:

    * **LiveLabs sandbox:** choose the compartment named on your reservation page (it looks like `LL#####-COMPARTMENT`).

        ![LiveLabs compartment selection](images/livelabs-compartment.png " ")

    * **Your own tenancy:** choose the compartment you created the database in.

        ![Compartment picker in the List scope panel](images/compartments.png " ")

5. Click the **display name** of your database to open its details page.

    ![Database display name in the list](images/database-name.png " ")

6. Click the **Database actions** button, then choose **SQL**.

    ![Database actions button on the database details page](images/dbactions-button.png " ")

    ![Choosing SQL from the Database actions menu](images/dbactions-menu-sql.png " ")

    **What you should see:** the SQL worksheet, with your username shown at the top right. Leave this browser tab open for the whole workshop — it is your relational door.

    > If you are asked to sign in again, use your **database** username and password (the LiveLabs sandbox reservation page lists them), not your cloud account.

## Task 2: Open Cloud Shell and Install the MongoDB Shell

`mongosh` is MongoDB's own shell. It is **not** preinstalled in Cloud Shell, so you will install it into your home directory — no admin rights, no software on your laptop, about a minute.

> **NOTE:** MongoDB Shell is a tool provided by MongoDB Inc. Oracle is not associated with MongoDB Inc. and has no control over the software. These instructions are provided to help you learn about the Oracle Database API for MongoDB. Download links may change without notice — see [the MongoDB download page](https://www.mongodb.com/try/download/shell) for current versions.

1. In the console header (top-right, between the region name and the notification bell), click the **Developer tools** icon — a small terminal glyph — and choose **Cloud Shell** from the menu that drops down. A terminal panel opens across the bottom of the browser window.

    ![Developer tools icon in the console header, with Cloud Shell in the drop-down menu](images/cloud-shell-menu.png " ")

    **What you should see:** a black terminal panel, then a `username@cloudshell:~ (region)$` prompt after a few seconds. The first launch in a tenancy can take a minute while the machine is created.

    > **If the panel says "Policy missing" or sits on "Creating your Oracle Cloud Shell machine…":** Cloud Shell must be enabled for your tenancy, and your Cloud Shell session region must match the region you are working in (check the region name in the panel's header bar). On a LiveLabs sandbox, tell a proctor. Everything in this workshop that uses `mongosh` can also be driven from a `mongosh` installed on your own laptop against the same endpoint.

2. Download and unpack the MongoDB shell, then put it on your `PATH`:

    ```
    <copy>
    cd ~
    curl -LO https://downloads.mongodb.com/compass/mongosh-2.3.8-linux-x64.tgz
    tar xzf mongosh-2.3.8-linux-x64.tgz
    export PATH=~/mongosh-2.3.8-linux-x64/bin:$PATH
    mongosh --version
    </copy>
    ```

    **What you should see:** `2.3.8` printed by the last command.

    > The `export PATH` line lasts for this Cloud Shell session. If your session restarts, run it again — or append it to `~/.bashrc` to make it permanent.

## Task 3: Connect mongosh to Your Database

1. Get your MongoDB API URL. Go back to the browser tab with your **database details page**, open the **Tool configuration** tab, and find **Oracle Database API for MongoDB**. Click **Copy** next to its access URL.

    The URL looks like this — note the two placeholders it arrives with:

    ```
    mongodb://[user:password@]HOST.adb.REGION.oraclecloudapps.com:27017/[user]?authMechanism=PLAIN&authSource=$external&tls=true&retryWrites=false&loadBalanced=true
    ```

2. Edit the URL in a text editor before using it:

    * Replace `[user:password@]` with your database username and password, e.g. `RESTO:MyPassword123@`
    * Replace `[user]` in the middle with the same username, e.g. `RESTO`
    * Remove the square brackets entirely

    **IMPORTANT:** if your password contains any of the characters `/ : ? # [ ] @`, URL-encode them:

    | Character | Encode as |
    | :---: | :---: |
    | `/` | `%2F` |
    | `:` | `%3A` |
    | `#` | `%23` |
    | `[` | `%5B` |
    | `]` | `%5D` |
    | `@` | `%40` |

3. In **Cloud Shell**, run `mongosh` with your edited URL in **single quotes**:

    ```
    <copy>
    mongosh 'mongodb://USERNAME:PASSWORD@HOST.adb.REGION.oraclecloudapps.com:27017/USERNAME?authMechanism=PLAIN&authSource=$external&tls=true&retryWrites=false&loadBalanced=true'
    </copy>
    ```

    **What you should see:** a `mongosh` prompt showing your schema name. Unchanged MongoDB tooling, Oracle endpoint — that is the point of this entire workshop.

    > If the connection hangs or is refused, the usual cause is the database's network access list. Ask a proctor now rather than in Lab 5.

## Task 4: Run the Preflight

1. In the **SQL worksheet**, paste and run this preflight as a script (also in `scripts/00_preflight.sql`):

    ```
    <copy>
    SELECT 'SQL worksheet connected as ' || USER AS check_1 FROM dual;

    SELECT 'Embedding model: ' ||
           NVL(MAX(model_name), 'not loaded yet - Lab 7 loads it') AS check_2
    FROM   user_mining_models
    WHERE  model_name = 'MENU_MODEL';

    SELECT 'Workshop tables already present: ' || COUNT(*) ||
           ' of 8 (a fresh schema shows 0)' AS check_3
    FROM   user_tables
    WHERE  table_name IN ('STORE','MENU','CATEGORY','ITEM','EXTRA',
                          'ITEM_OPTION','ITEM_SPECIAL_HOURS','ITEM_OVERRIDE');
    </copy>
    ```

    **What you should see:** your username, an embedding-model line (either `MENU_MODEL` if your environment already has it, or `not loaded yet` — both are fine, Lab 7 loads it), and a table count. A fresh schema shows `0`; if yours shows more, you are re-running the workshop and every script below drops and recreates what it needs.

2. In **mongosh**, run the connectivity check (also in `scripts/00_preflight_mongo.js`):

    ```
    <copy>
    db.runCommand({ ping: 1 })
    </copy>
    ```

    **What you should see:** `{ ok: 1 }`.

3. Still in mongosh, confirm the schema is empty:

    ```
    <copy>
    show collections
    </copy>
    ```

    **What you should see:** nothing at all. An empty database, two open doors. You are ready.

## Learn More

* [Oracle Database API for MongoDB documentation](https://docs.oracle.com/en/database/oracle/mongodb-api/)
* [Using Oracle Cloud Infrastructure Cloud Shell](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/cloudshellintro.htm)
* [MongoDB Shell downloads](https://www.mongodb.com/try/download/shell)

## Acknowledgements
* **Author** - Rick Houlihan, Field CTO, Oracle Data & AI Platform
* **Last Updated By/Date** - Rick Houlihan, July 2026
