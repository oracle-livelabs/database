# Connect to Your Environment and Run the Preflight

## Introduction

You start from an **empty** Autonomous AI Database. In this lab you open the two tools you will use all session — the **SQL worksheet** in Database Actions and the **MongoDB shell** on your own machine — and run a preflight that checks every dependency of every later lab, so problems surface now rather than during the finale.

Workspace convention for the whole session: **a terminal running mongosh beside a browser tab with the SQL worksheet** — switching should be a glance, not a window hunt.

Estimated Lab Time: 10 minutes

### Objectives

In this lab, you will:

* Navigate the OCI console to your database and open the SQL worksheet
* Install the MongoDB shell (`mongosh`) on your own machine
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

## Task 2: Install the MongoDB Shell on Your Local Machine

`mongosh` is MongoDB's own shell, and running the *unmodified* MongoDB tool against an Oracle endpoint is the whole point of Act I. You install it **on your own laptop** — a download and an unzip, no admin rights, about two minutes.

> **What about Cloud Shell?** If you are in **your own tenancy** and OCI Cloud Shell opens for you, it is a fine place to do this — Cloud Shell runs on Ampere, so grab the **`linux-arm64`** build and it is three lines:
>
> ```
> curl https://downloads.mongodb.com/compass/mongosh-2.9.2-linux-arm64.tgz > mongosh.tgz
> tar xvf mongosh.tgz
> cd mongosh-2.9.2-linux-arm64/bin && ./mongosh $URI
> ```
>
> On a **LiveLabs sandbox**, though, Cloud Shell does not come up: it reports "Policy missing" and then sits on *"Creating your Oracle Cloud Shell machine…"* indefinitely (reproduced on sandboxes in two different regions). That is why the local install below is the main path — it works everywhere, including on a sandbox.

> **NOTE:** MongoDB Shell is a tool provided by MongoDB Inc. Oracle is not associated with MongoDB Inc. and has no control over the software. These instructions are provided to help you learn about the Oracle Database API for MongoDB. Download links change without notice — see [the MongoDB download page](https://www.mongodb.com/try/download/shell) for current versions.

1. Open a **terminal** (macOS: Command-space, type "terminal") or **Command Prompt** (Windows: Start, type "cmd"), then make a working directory:

    ```
    <copy>
    cd ~
    mkdir mongosh-install
    cd mongosh-install
    </copy>
    ```

2. Download the build for **your** machine — copy **one** of these:

    * **Mac, Apple silicon** (M1/M2/M3/M4):

        ```
        <copy>
        curl https://downloads.mongodb.com/compass/mongosh-2.9.2-darwin-arm64.zip -o mongosh.zip
        </copy>
        ```

    * **Mac, Intel:**

        ```
        <copy>
        curl https://downloads.mongodb.com/compass/mongosh-2.9.2-darwin-x64.zip -o mongosh.zip
        </copy>
        ```

    * **Windows:**

        ```
        <copy>
        curl https://downloads.mongodb.com/compass/mongosh-2.9.2-win32-x64.zip -o mongosh.zip
        </copy>
        ```

    > Not sure which Mac you have? Apple menu → **About This Mac**. "Apple M…" means Apple silicon; "Intel" means Intel.

3. Unpack it (`tar` is built in on macOS and on Windows 10/11):

    ```
    <copy>
    mkdir -p mongosh
    tar -xf mongosh.zip -C mongosh --strip-components=1
    </copy>
    ```

4. Put it on your `PATH` and check the version.

    * **Mac:**

        ```
        <copy>
        export PATH=$PWD/mongosh/bin:$PATH
        mongosh --version
        </copy>
        ```

    * **Windows:**

        ```
        <copy>
        set PATH=%CD%\mongosh\bin;%PATH%
        mongosh --version
        </copy>
        ```

    **What you should see:** `2.9.2`.

    > That `PATH` lasts for this terminal window only. **Keep this window open for the whole workshop.** If you close it, re-run the `PATH` command from this directory.

    > **Already have MongoDB Compass?** It bundles the same `mongosh`, and its built-in shell works for every step of this workshop — skip this task and use Compass's shell wherever the guide says "in mongosh". Any other route to a working `mongosh` is equally fine; nothing here depends on how you got it.

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

3. In the **terminal where you installed mongosh**, run it with your edited URL in quotes — **single quotes on Mac**, **double quotes on Windows**:

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
* [Oracle Database API for MongoDB — connection strings](https://docs.oracle.com/en/database/oracle/mongodb-api/mgapi/overview-oracle-database-api-mongodb.html)
* [MongoDB Shell downloads](https://www.mongodb.com/try/download/shell)

## Acknowledgements
* **Author** - Rick Houlihan, Field CTO, Oracle Data & AI Platform
* **Last Updated By/Date** - Rick Houlihan, July 2026
