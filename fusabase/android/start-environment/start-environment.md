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

    <details>
    <summary><b>Docker</b></summary>

    Run this command if you installed Docker.

    ```bash
    <copy>docker version</copy>
    ```

    </details>

    <details>
    <summary><b>Podman</b></summary>

    Run this command if you installed Podman.

    ```bash
    <copy>podman version</copy>
    ```

    On macOS or Windows, also confirm that `podman machine list` shows a running machine.

    </details>

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

    <details>
    <summary><b>Docker</b></summary>

    Use this command if you installed Docker.

    ```bash
    <copy>docker compose up -d</copy>
    ```

    </details>

    <details>
    <summary><b>Podman</b></summary>

    Use this command if you installed Podman.

    ```bash
    <copy>podman compose up -d</copy>
    ```

    </details>

3. Wait for the stack to finish starting before you continue.

    **On the first run, this may take 1 to 2 minutes, depending on your Wi-Fi speed**, while the images download and the services finish initializing. Right now, the compose file is setting up Oracle AI Database Free, ORDS, and configuring Fusabase for the workshop.

    > Note: To learn more about Fusabase configuration, read about it in the docs. [ADD LINK]

## Task 5: Confirm the stack is running

1. After the compose has finished, check the status with the command below.

    <details>
    <summary><b>Docker</b></summary>

    ```bash
    <copy>docker ps</copy>
    ```

    </details>

    <details>
    <summary><b>Podman</b></summary>

    ```bash
    <copy>podman ps</copy>
    ```

    </details>

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
