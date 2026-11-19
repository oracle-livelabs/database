# Connect your app

## Introduction

In this lab, you will create a project and two tables, register the workshop's event app, and paste its configuration into the starter code. When you are done, your app shows the green **Connected to Fusabase** tag.

### Objectives

In this lab, you will:

- create an Oracle Backend with Supabase APIs project in the Fusabase console
- create the event and RSVP tables in SQL Editor
- register your app and copy its configuration
- install the Oracle Backend with Supabase APIs JavaScript SDK
- paste the configuration into `starter/config.js`

Estimated Time: 20 minutes

### Prerequisites

This lab assumes you have:

- Successfully completed all previous labs.
- Both Lab 1 containers running and healthy.
- Node.js 22 or later and npm.



## Task 1: Get the sample code

1. Clone the GitHub repository from your command line.

    ```bash
    <copy>git clone https://github.com/KillianLynch/fusabase-livelabs-relational-web.git gather-workshop</copy>
    ```

2. Move into the workshop root.

    ```bash
    <copy>cd gather-workshop</copy>
    ```

3. Open the project in VS Code.

    ```bash
    <copy>code .</copy>
    ```

    ![VS Code with the gather-workshop folder and learner files highlighted](images/task-1-gather-workshop-layout.png)

    You edit the app in `starter/`. The `finished/` folder holds the complete app, and `checkpoints/` holds a recovery copy for each lab.

## Task 2: Create the LiveLab project

1. Open the Fusabase console from Lab 1. If needed, open [the local ORDS landing page](http://localhost:8080/ords/_/landing), enter `testuser` as the schema/path, and open Fusabase. Sign in with username `TESTUSER` and password `testpwd`.

    ![Fusabase console sign-in with the schema path, username, and Sign in highlighted](images/task-1-sign-in.png)

2. On the Fusabase console landing page, find the **Oracle Backend with Supabase APIs** card and click **Create project**.

    ![Fusabase console with Create project highlighted in the Oracle Backend with Supabase APIs card](images/task-1-create-project.png)

3. Select **Yes, Deep Data Security is enabled**, then click **Continue**. Lab 1's stack setup enabled it for the schema.

    ![Fusabase console with the Deep Data Security confirmation and Continue highlighted](images/task-1-dds.png)

4. In **Create project**:

    - enter `LiveLab` for **Project name**
    - select **Set up using quickstart**
    - keep **Set up authentication for me** and **Set up storage for me** selected
    - click **Create Project**

    ![Fusabase console with LiveLab, quickstart, authentication, storage, and Create Project highlighted](images/task-1-quickstart.png)

    A project groups your apps and their shared services. Quickstart sets up the authentication and storage that later labs use.

5. On **Your projects**, open the `LiveLab` card marked **RELATIONAL**. You should see `LiveLab` on the project home. Keep this project selected for the rest of the lab.

    ![Fusabase console project home showing LiveLab and the Web registration button](images/task-1-project-ready.png)

## Task 3: Create the event table with SQL Editor

You'll create both tables in SQL Editor: the event table in this task and the RSVP table in Task 4.

1. In the Fusabase console, open **Database** and select the **SQL Editor** tab.

2. In the worksheet, replace any example query with the following SQL. `PRIMARY KEY` makes each event key unique, and `NOT NULL` requires a value. `COVER_PATH` allows nulls because an event cover is optional.

    ```sql
    <copy>CREATE TABLE GATHER_EVENTS (
      EVENT_ID      NUMBER(38,0) PRIMARY KEY,
      ORGANIZER_ID  VARCHAR2(255 BYTE) NOT NULL,
      TITLE         VARCHAR2(255 BYTE) NOT NULL,
      DESCRIPTION   VARCHAR2(255 BYTE) NOT NULL,
      STARTS_AT     NUMBER(38,0) NOT NULL,
      LOCATION      VARCHAR2(255 BYTE) NOT NULL,
      COVER_PATH    VARCHAR2(255 BYTE)
    );</copy>
    ```

    ![Fusabase console SQL Editor with the event table statement and Run Script highlighted](images/task-2-sql-editor.png)

3. Click **Run Script (F5)** once in the worksheet toolbar. Open **Script Output** if it isn't already selected. You should see `Table GATHER_EVENTS created.`

    ![Fusabase console Script Output confirming that GATHER_EVENTS was created](images/task-2-table-created.png)

4. Return to **Table Editor**, select **Tables**, and select `GATHER_EVENTS`. You should see seven columns, `EVENT_ID (PK)`, and zero rows. Don't use **Insert**.

    ![Fusabase console showing the empty event table with its primary key highlighted](images/task-2-empty-events.png)

## Task 4: Create the RSVP table

Each row stores one user's response to one event. A user can respond to many events, but only once per event.

1. In the Fusabase console, open **Database > SQL Editor**.

2. Replace the worksheet content with the following SQL. The composite `PRIMARY KEY` allows one response per user per event. The `FOREIGN KEY` links each response to an event in `GATHER_EVENTS`.

    ```sql
    <copy>CREATE TABLE GATHER_RSVPS (
      EVENT_ID      NUMBER(38,0) NOT NULL,
      USER_ID       VARCHAR2(255 BYTE) NOT NULL,
      DISPLAY_NAME  VARCHAR2(255 BYTE) NOT NULL,
      RSVP_STATUS   VARCHAR2(255 BYTE) NOT NULL,
      CONSTRAINT GATHER_RSVPS_PK
        PRIMARY KEY (EVENT_ID, USER_ID),
      CONSTRAINT GATHER_RSVPS_EVENT_FK
        FOREIGN KEY (EVENT_ID)
        REFERENCES GATHER_EVENTS (EVENT_ID)
    );</copy>
    ```

    ![SQL Editor showing the RSVP table definition, composite primary key, foreign key, and Run Script](images/task-4-rsvp-sql.png)

3. Click **Run Script (F5)** once. Under **Script Output**, you should see **Table GATHER_RSVPS created.**

    ![Script Output confirming that GATHER_RSVPS was created](images/task-4-rsvp-created.png)

4. Return to **Table Editor**, select **Tables**, and select `GATHER_RSVPS`. You should see four columns, `EVENT_ID (PK, FK)`, `USER_ID (PK)`, and zero rows. Don't use **Insert**.

    ![Table Editor showing the empty RSVP table and its key columns](images/task-4-rsvp-empty.png)

## Task 5: Register your app and paste its configuration

1. In the Fusabase console, return to **Overview** and click **Web**.

    ![Fusabase console project home with Web highlighted](images/task-4-web.png)

2. Enter `Gather` for **App Nickname** and click **Register App**. Gather is the name of the event app you build in this workshop.

    ![Fusabase console registration dialog with Gather and Register App highlighted](images/task-4-register-app.png)

3. At **Install SDK**, review the npm command for `@fusabase/fusabase-relational` and click **Next**. You run this command in Task 6.

    ![Fusabase console showing the SDK npm installation command and Next](images/task-4-install-sdk.png)

4. At **Configure SDK**, find the `const fusabaseConfig = {` object. Copy the property lines inside its braces, from `schema` to `auth_id`. Keep this dialog open, because you also need the separate `ords_host` value below the object.

    ![Fusabase console with the configuration properties and separate ORDS host highlighted](images/task-4-config-properties.png)

5. In your IDE, open the workshop's `starter/` folder. Copy `config.example.js`, name the copy `config.js`, and open `starter/config.js`.

    ![VS Code showing starter/config.js beside config.example.js in the Explorer](images/task-4-ide-config-file-gather.jpg)

6. Select only the placeholder property lines inside the existing `export const config = {` block, leaving the wrapper and closing `};` in place. Paste the property lines from the Fusabase console.

    ![VS Code with only the configuration property lines selected for replacement](images/task-4-ide-paste-config-gather.jpg)

    Don't paste `const fusabaseConfig =`, the Fusabase console's imports, or its `createClient` and service setup calls.

7. Return to **Configure SDK** and copy the URL from the separate `const ords_host = '…';` line. Add it as the `ords_host` property inside your object, with a comma after the preceding property. Keep the trailing `/`.

8. Compare your file with this structure:

    ```javascript
    export const config = {
      schema: "testuser",
      app_name: "Gather",
      app_type: "WEB",
      app_id: "APP_ID",
      objs_type: "base",
      backend_type: "RELATIONAL",
      project_id: "PROJECT_ID",
      storage_bucket: "STORAGE_BUCKET",
      auth_type: "base",
      auth_id: "AUTH_ID",
      ords_host: "http://localhost:8080/ords/testuser/"
    };
    ```

    Replace `APP_ID`, `PROJECT_ID`, `STORAGE_BUCKET`, and `AUTH_ID` with your values from the Fusabase console. If your `schema`, `objs_type`, `auth_type`, or host differ from this example, keep yours.

    | Property | Purpose |
    | --- | --- |
    | `schema` | Database schema containing your project data |
    | `app_name`, `app_type`, `app_id` | Your registered web app |
    | `backend_type` | Backend type; keep `RELATIONAL` |
    | `project_id` | LiveLab project you created in Task 2 |
    | `objs_type`, `storage_bucket` | Storage service and bucket for event covers |
    | `auth_type`, `auth_id` | Application-user authentication service |
    | `ords_host` | Schema-specific ORDS URL, including its trailing slash |

9. Save `starter/config.js`. Check the export wrapper, the commas, and `ords_host` inside the object against this view.

    ![VS Code showing the completed config.js structure and ORDS host inside the exported object](images/task-4-ide-config-complete-gather.jpg)

    In the Fusabase console, click **Done**.

10. To copy the configuration again, for example after you change the enabled services, open **Project settings > Applications**, select **Gather**, and expand **SDK config**.

    ![Fusabase console application settings with Applications, Gather, and SDK config highlighted](images/task-4-find-config.png)

## Task 6: Install the SDK and open your app

1. Open a terminal in the `gather-workshop` workshop root. Install the Oracle Backend with Supabase APIs JavaScript SDK with npm:

    ```bash
    npm install @fusabase/fusabase-relational
    ```

2. This workshop uses Live Server to serve the app. Install it if you don't have it:

    ```bash
    npm install -g live-server
    ```

3. Start Live Server from the workshop root:

    ```bash
    live-server --port=8000 --host=localhost
    ```

    You can also use another static HTTP server, such as `python3 -m http.server 8000`. Serve the whole workshop root so both `starter/` and `node_modules/` are reachable.

4. Open [the starter app](http://localhost:8000/starter/?ui=canvas). With your configuration saved, you should see the green **Connected to Fusabase** tag in the header. You don't need to edit `starter/actions.js` or add any initialization code.

    ![Gather Canvas layout with the green Connected to Fusabase tag and an empty event list](images/task-6-canvas-connected.png)

## Task 7: Verify the connection

The green tag means your app loaded your configuration and started the SDK client. It doesn't prove database access or permissions, which Lab 4 sets up with Grants. Don't add broad Grants to clear errors.

1. You should see the green **Connected to Fusabase** tag beside **Sign in** and an empty event list. Other buttons show a message about a later lab, which is expected.

2. Open your browser's developer console. You should see no module import, configuration, or uncaught JavaScript errors.

3. In the Fusabase console, open **Database > Table Editor**. Both tables should still have zero rows.

4. If `starter/actions.js` doesn't work after this lab, run this from the workshop root:

    ```bash
    cp checkpoints/lab-2/actions.js starter/actions.js
    ```

    Keep your own `starter/config.js`. The checkpoint doesn't create the project, tables, or keys, so complete Tasks 1–5 and the SDK install in Task 6 first.

## Troubleshooting

- **Not configured or a configuration message:** create `starter/config.js`, replace every placeholder, and check the `config` export, commas, quotes, and trailing `/` in `ords_host`. Then reload.
- **SDK module fails to load:** run `npm install @fusabase/fusabase-relational` at the workshop root. Serve that root, not only `starter/`.
- **Browser reports a CORS error:** open the app at `http://localhost:8000`. Another port or `127.0.0.1` is a different origin that the backend might not allow.
- **RSVP table creation fails:** create `GATHER_EVENTS` first, because the RSVP foreign key references it. Use the uppercase names exactly.
- **Table missing or `ORA-00955: name is already used by an existing object`:** reload **Database > Table Editor** and find the table. Don't drop it or rerun the statement.

You may now **proceed to the next lab**: [Authenticate users](../authenticate-users/authenticate-users.md).

## Acknowledgements

* **Author** - Killian Lynch, Senior Product Manager, Oracle AI Database
* **Last Updated By/Date** - Killian Lynch, November 2026
