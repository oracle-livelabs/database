# Get the Starter App

## Introduction

In this lab, you will get the starter app running locally, register a web app in the Fusabase console, and paste the generated app config into the starter app. When you are done, the app will connect to your Fusabase project and show an empty recipe list.

### Objectives

In this lab, you will:

- get the sample app from GitHub
- open the starter app in your code editor
- install the Fusabase JavaScript SDK
- start a local web server
- register a web app in the Fusabase console
- copy the generated app config into the starter app
- verify that the app connects to your project

Estimated Time: 15 minutes

### Prerequisites

This lab assumes you have:

- Successfully completed all previous labs.

## Task 1: Get the sample code

1. Clone the GitHub repository from your command line

    ```bash
    <copy>git clone https://github.com/KillianLynch/fusabase-livelabs.git</copy>
    ```

2. Move into the RecipeShare workshop root.

    ```bash
    <copy>cd fusabase-livelabs/web/recipeShare</copy>
    ```

3. Open or import the project in your code editor. This workshop shows screenshots of VS Code, but any editor is fine.

    ```bash
    <copy>code .</copy>
    ```


    ![Recipe Share starter app project opened in an editor with the main files visible in the file tree](images/task-1-starter-app-folder.png =60%x*)

## Task 2: Install the SDK and start a local web server

1. This lab uses Live Server to demo the app, **however, you can use any server you want**.

2. Live Server needs Node.js and npm. If you do not have them, install Node.js here: [Node.js](https://nodejs.org/en/download/current).

3. Install the server. 

    ```bash
    <copy>npm install -g live-server</copy>
    ```

4. Make sure your terminal is still in `fusabase-livelabs/web/recipeShare` from Task 1. Install the Fusabase JavaScript SDK before you launch the app.

    ```bash
    <copy>npm install fusabase</copy>
    ```

5. Run Live Server from `fusabase-livelabs/web/recipeShare`.

    ```bash
    <copy>live-server --port=8000 --host=localhost</copy>
    ```


6. Open the starter app in your browser.

    Use the learner app path:

    [http://localhost:8000/starter/](http://localhost:8000/starter/)

7. You now have the demo app up and running. Over the remainder of the labs, you will build out the RecipeShare app. You should see a message like "Continue with Lab 2, Task 3 in the workshop guide to connect this app to Fusabase." in the app. Continue to task three when ready.

    ![demo app home page](images/demo.png =60%x*)


> Note: if you are getting a CORS error, please read the Appendix Lab Below  

## Task 3: Register a web app and paste the config

1. Return to the Fusabase console that you left open at the end of Lab 1.


2. From the project's home page, click **Web**

    ![Fusabase Database](images/web.png =40%x*)

3. For this lab, name the app `RecipeShare` and click **Register App**.

    ![demo app home page](images/add-app.png =60%x*)


4. Because we installed the SDK in Task 2 above, click **Next**.

5. This is your app config. For this demo, **we only need the key value pairs**. Highlight those and copy them to your clipboard.

    ![Fusabase Database](images/config.gif =90%x*)

    > Note: If you've already closed out the Pop up before copying the config, you can view all of the applications you create under the **Project settings** -> **Applications**. 

    ![Fusabase Database](images/otherconfig.gif =30%x*)

    The config is what allows your app to work with Fusabase:

    - `schema` identifies the database schema that stores your project data.
    - `app_name` is the display name you gave your app when you registered it.
    - `app_type` indicates this is a web browser app (as opposed to mobile or server).
    - `app_id` uniquely identifies the browser app you just registered.
    - `objs_type` specifies the storage type for objects (dbfs = database file system).
    - `project_id` identifies the Fusabase project you created in Lab 1.
    - `storage_bucket` identifies the bucket that later labs will use for uploads.
    - `auth_type` specifies the authentication method your project uses (base = basic auth).
    - `auth_id` uniquely identifies the authentication configuration for your project.
    - `ords_host` gives the SDK the ORDS base URL for API requests.

5. Open your code editor and open the starter project file **fusabase-config.js**.

6. Copy only the key/value lines from the config object. Replace the placeholder key/value lines inside the existing `export const fusabaseConfig = {` block with the lines you copied.

    Do not copy `const fusabaseConfig =`, any `import` lines, or any SDK setup code.

    ![Fusabase Database](images/paste-config.gif =60%x*)

7. Save the file.

    If the app still shows the Lab 2 guidance banner after you refresh, or it does not load after you save, see **Appendix > Config paste troubleshooting** before continuing.

9. This is what your fusabase-config.js file should look like (with your own config)

    ![Fusabase Database](images/paste-config-still.png =40%x*)


## Task 4: Review the setup

1. You've now finished the setup. You have the demo code, the Fusabase JavaScript SDK is installed, and your demo app is connected to Fusabase.

1. Return to the browser tab where the starter app is running. If needed, open it again at [http://localhost:8000/starter/](http://localhost:8000/starter/)

2. You should now see: **Connected to Fusabase.**

    ![Fusabase Database](images/starter.png =60%x*)



3. Leave the app and the console open for the next lab.

## Appendix

### Config paste troubleshooting
If the app does not load after you paste the config, or it still shows the Lab 2 guidance banner after you refresh, check these common mistakes:

- You pasted `const fusabaseConfig =` into the object body instead of copying only the property lines.
- You pasted SDK `import` lines into `fusabase-config.js`.
- You removed `export const fusabaseConfig = {`.
- You removed the closing `};`.
- You left out a comma between properties.
- One of the required values is still blank.

1. Authorized Domains are a security feature for browser apps. They help reduce exposure by allowing browser-based access only from domains that you trust.

    In the Fusabase console, open **Project Settings**, then open **Authorized Domains**. There, you can add any authorized domains that you want to allow for your project.

    ![Fusabase Database](images/cors.png =40%x*)

If you add an authorized domain, remember that this is backed by an ORDS feature. After you change the Authorized Domains list, you must restart ORDS for the change to take effect.


4. If you have used the Compose file and you need to restart ORDS after adding an authorized domain, use the following command: 

  <style>
  .runtime-check-tabs {
    margin: 1rem 0;
    max-width: 42rem;
    margin-left: 4rem;
  }
  .runtime-check-tabs input[type="radio"] {
    display: none;
  }
  .runtime-check-tabs label {
    display: inline-block;
    padding: 0.6rem 1rem;
    margin-right: 0.35rem;
    border: 1px solid #d9dfe8;
    border-radius: 999px;
    background: #eef3f8;
    color: #1f2937;
    cursor: pointer;
    font-weight: 600;
    transition: background 0.2s ease, color 0.2s ease, border-color 0.2s ease;
  }
  .runtime-check-tabs .tab-panel {
    display: none;
    margin-top: 0.85rem;
    border: 1px solid #d9dfe8;
    border-radius: 14px;
    padding: 1rem;
    background: #fbfcfe;
    box-shadow: 0 1px 2px rgba(15, 23, 42, 0.05);
  }
  .runtime-check-tabs .tab-panel p {
    margin-top: 0;
  }
  .runtime-check-tabs .tab-panel pre {
    margin-bottom: 0;
  }
  #tab-check-docker:checked ~ .label-check-docker,
  #tab-check-podman:checked ~ .label-check-podman {
    background: #c74634;
    border-color: #c74634;
    color: #ffffff;
  }
  #tab-check-docker:checked ~ .panel-check-docker,
  #tab-check-podman:checked ~ .panel-check-podman {
    display: block;
  }
  </style>

  <div class="runtime-check-tabs">
    <input type="radio" id="tab-check-docker" name="runtime-check-tab" checked>
    <input type="radio" id="tab-check-podman" name="runtime-check-tab">
    <label for="tab-check-docker" class="label-check-docker">Docker</label>
    <label for="tab-check-podman" class="label-check-podman">Podman</label>
    <div class="tab-panel panel-check-docker">

    Run this command if you installed Docker.

    ```bash
    <copy>docker compose restart ords</copy>
    ```

    </div>
    <div class="tab-panel panel-check-podman">

    Run this command if you installed Podman.

    ```bash
    <copy>podman compose restart ords</copy>
    ```

    On macOS or Windows, also confirm that `podman machine list` shows a running machine.

    </div>
  </div>




For more detail, see the [Authorized Domains documentation for ORDS](https://docs.oracle.com/en/database/oracle/oracle-rest-data-services/25.2/orddg/migrating-mod_plsql-ords.html).

You may now **proceed to the next lab**.

## Acknowledgements

* **Author** - Killian Lynch, Senior Product Manager, Oracle AI Database
* **Contributors** - 
* **Last Updated By/Date** - Killian Lynch, April 2026
