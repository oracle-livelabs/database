# Get Started

## Introduction

This section sets up the local workshop environment for the rest of the lab. You’ll install the container stack that sets up Oracle AI Database Free, ORDS, and Fusabase for you.

### Objectives

In this lab, you will:

- Install Docker or Podman.
- Download the workshop stack from GitHub.
- Start the workshop environment.
- Check that the database and ORDS are running.


Estimated Time: 15 minutes

### Prerequisites

This lab assumes you have:

- Successfully completed all previous labs.

## Task 1: Understand what this lab sets up

1. This lab sets up the local Fusabase environment for the rest of the workshop.

    - Oracle AI Database Free stores your workshop data.
    - ORDS provides the backend endpoint the SDK will use.
    - The Fusabase console becomes available after the stack is running.


## Task 2: Install Docker or Podman

1. For this workshop, the fastest path is to use the runtime you already have working. If you are starting from scratch, Docker is the simplest default.

2. If you chose Docker, install it now.

    - Windows: [Docker Desktop for Windows](https://docs.docker.com/desktop/setup/install/windows-install/)
    - macOS: [Docker Desktop for Mac](https://docs.docker.com/desktop/setup/install/mac-install/)
    - Linux: [Docker Desktop for Linux](https://docs.docker.com/desktop/setup/install/linux/) or [Docker Engine with the Compose plugin](https://docs.docker.com/engine/install/)

    If you are on Windows, make sure WSL 2 is available before you continue.

3. If you chose Podman, install it now.

    - Windows, macOS, and Linux: [Podman installation](https://podman.io/docs/installation)
    - If you are on macOS or Windows, initialize and start a Podman machine before you continue.

    ```bash
    <copy>podman machine init
    podman machine start</copy>
    ```

4. Make sure your chosen runtime is ready before you move on.

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
    <copy>docker version</copy>
    ```

    </div>
    <div class="tab-panel panel-check-podman">

    Run this command if you installed Podman.

    ```bash
    <copy>podman version</copy>
    ```

    On macOS or Windows, also confirm that `podman machine list` shows a running machine.

    </div>
  </div>

5. You should have Docker or Podman installed before continuing to task 3.

    ![Podman version output in the terminal after the runtime is installed successfully](images/task-1-runtime-ready.png =40%x*)

## Task 3: Download the demo environment for Oracle Backend for Firebase Anywhere

1. Open a terminal where you want to save the workshop files.

2. Create a new directory for the workshop files and move into it.

    ```bash
    <copy>mkdir obfa-workshop
    cd obfa-workshop</copy>
    ```

3. Clone the repository that contains the Oracle Backend for Firebase Anywhere demo environment.

    ```bash
    <copy>git clone https://github.com/KillianLynch/fusabase-compose.git</copy>
    ```

4. Move into the cloned repository directory.

    ```bash
    <copy>cd fusabase-compose</copy>
    ```

5. Confirm that the repository includes the files and folders used by the demo environment.

    You should have:

    - `compose.yml`
    - `oracle/`
    - `ords_entrypoint.d/`

    The stack uses the folders listed above together with `compose.yml`.

    ![The fusabase-compose directory showing compose.yaml and the supporting folders for the Oracle Backend for Firebase Anywhere demo environment](images/task-3-demo-files-terminal.png =30%x*)

## Task 4: Start the demo environment

1. Make sure you are in the `fusabase-compose` directory.

2. Run the workshop startup command.

  <style>
  .runtime-tabs {
    margin: 1rem 0;
    max-width: 42rem;
    margin-left: 4rem;
  }
  .runtime-tabs input[type="radio"] {
    display: none;
  }
  .runtime-tabs label {
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
  .runtime-tabs .tab-panel {
    display: none;
    margin-top: 0.85rem;
    border: 1px solid #d9dfe8;
    border-radius: 14px;
    padding: 1rem;
    background: #fbfcfe;
    box-shadow: 0 1px 2px rgba(15, 23, 42, 0.05);
  }
  .runtime-tabs .tab-panel p {
    margin-top: 0;
  }
  .runtime-tabs .tab-panel pre {
    margin-bottom: 0;
  }
  #tab-docker:checked ~ .label-docker,
  #tab-podman:checked ~ .label-podman {
    background: #c74634;
    border-color: #c74634;
    color: #ffffff;
  }
  #tab-docker:checked ~ .panel-docker,
  #tab-podman:checked ~ .panel-podman {
    display: block;
  }
  </style>

  <div class="runtime-tabs">
    <input type="radio" id="tab-docker" name="runtime-tab" checked>
    <input type="radio" id="tab-podman" name="runtime-tab">
    <label for="tab-docker" class="label-docker">Docker</label>
    <label for="tab-podman" class="label-podman">Podman</label>
    <div class="tab-panel panel-docker">

    Use this command if you installed Docker.

    ```bash
    <copy>docker compose up -d</copy>
    ```

    </div>
    <div class="tab-panel panel-podman">

    Use this command if you installed Podman.

    ```bash
    <copy>podman compose up -d</copy>
    ```

    </div>
  </div>

3. Wait for the stack to finish starting before you continue.

    **On the first run, this may take 1 to 2 minutes, depending on your Wi-Fi speed**, while the images download and the services finish initializing. Right now, the compose file is setting up Oracle AI Database Free, ORDS, and configuring Fusabase for the workshop.

    > Note: To learn more about Fusabase configuration, read about it in the docs. [ADD LINK]

## Task 5: Confirm the stack is running

1. After the compose has finished, check the status with the command below.

  <style>
  .runtime-status-tabs {
    margin: 1rem 0;
    max-width: 42rem;
    margin-left: 4rem;
  }
  .runtime-status-tabs input[type="radio"] {
    display: none;
  }
  .runtime-status-tabs label {
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
  .runtime-status-tabs .tab-panel {
    display: none;
    margin-top: 0.85rem;
    border: 1px solid #d9dfe8;
    border-radius: 14px;
    padding: 1rem;
    background: #fbfcfe;
    box-shadow: 0 1px 2px rgba(15, 23, 42, 0.05);
  }
  .runtime-status-tabs .tab-panel p {
    margin-top: 0;
  }
  .runtime-status-tabs .tab-panel pre {
    margin-bottom: 0;
  }
  #tab-status-docker:checked ~ .label-status-docker,
  #tab-status-podman:checked ~ .label-status-podman {
    background: #c74634;
    border-color: #c74634;
    color: #ffffff;
  }
  #tab-status-docker:checked ~ .panel-status-docker,
  #tab-status-podman:checked ~ .panel-status-podman {
    display: block;
  }
  </style>

  <div class="runtime-status-tabs">
    <input type="radio" id="tab-status-docker" name="runtime-status-tab" checked>
    <input type="radio" id="tab-status-podman" name="runtime-status-tab">
    <label for="tab-status-docker" class="label-status-docker">Docker</label>
    <label for="tab-status-podman" class="label-status-podman">Podman</label>
    <div class="tab-panel panel-status-docker">

    ```bash
    <copy>docker ps</copy>
    ```

    </div>
    <div class="tab-panel panel-status-podman">

    ```bash
    <copy>podman ps</copy>
    ```

    </div>
  </div>

2. When the services show as running, open the Oracle Backend for Firebase Anywhere console in your browser.

    ```text
    <copy>http://localhost:8080</copy>
    ```

    ![Oracle Backend for Firebase Anywhere console home page at localhost 8080](images/task-4-console-home.png =85%x*)

    > If the page does not load right away, wait another 30 seconds and try again.

3. Once the console opens, move on to the next lab to create your first project.

## Appendix

1. The compose file creates the workshop users for you during startup.

    Local workshop credentials:

    - Username: **`testuser`**
    - Password: **`testpwd`**

    The compose file also creates these local accounts:

    - `baasdba` / `baas`
    - `sys` / `Welcome12345`
    - `system` / `Welcome12345`
    - `pdbadmin` / `Welcome12345`

    These credentials are provided only for local development and testing in this workshop. Do not use this setup or these passwords in production.

You may now **proceed to the next lab**.

## Acknowledgements

* **Author** - Killian Lynch, Senior Product Manager, Oracle AI Database
* **Contributors** -
* **Last Updated By/Date** - Killian Lynch, May 2026
