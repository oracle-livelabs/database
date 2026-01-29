# Lab 2.2: Installing the Private Agent Factory from Source

## Introduction

In this lab session, you will learn how to install and deploy Oracle AI Database Private Agent Factory, a no-code platform that enables business users and engineers to rapidly deploy intelligent agents, without writing a single line of code. The platform enables enterprises to launch smart assistants by leveraging Pre-built Agents, Custom-built Agents and End-to-end Workflows.

> **Note:** The tasks in this lab are optional as each contains the deployment instructions for each of the supported platforms. You may choose and follow the task that best suits your environment.

**Estimated time:** 10 minutes.

### Objectives

By the end of this lab, you will be able to:

- Download the installation kit to your environment.
- Deploy the Oracle AI Database Private Agent Factory application.
- Access the Oracle AI Database Private Agent Factory application using a web browser.

### Prerequisites

- Access to an Oracle Pluggable Database (PDB) with SYSDBA credentials.

You will need one of the following environments:

- An Oracle Linux 8 (OL8) Virtual Machine (VM) with sudo privileges and at least 60 GB of available disk space.
- A MacOS device with at least 60 GB of available disk space.
- Access to an OCI tenancy user allowed to deploy VM from Marketplace.

## (Optional) Task 1: Linux systems installation

### Download Linux installation kit

Download the kit from the official Oracle website Visit the [download page](https://www.oracle.com/database/technologies/private-agent-factory-downloads.html#) to get the installation kit.

![Screenshot of the Oracle AI Database Private Agent Factory kit download webpage, showing a description of the platform, download links for Linux X86-64 and ARM 64 installers, and brief details about each option and its compatibility.](images/download-page-a.png)

You may select the option that best suits your working environment:

- The Linux ARM 64-bit platform installer kit `applied_ai_arm64.tar.gz`.
- The Linux x86-64 platform installer kit `applied_ai.tar.gz`.

After selecting your platform, review and accept the License Agreement and click download.

![Screenshot of the Oracle Software Delivery Cloud page for downloading Oracle AI Database Private Agent Factory. The user can select platforms (Linux x86-64 or Linux ARM 64-bit), accept the license agreement, and choose software version 25.3.0.0.0 to download.](images/download-page-b.png)

### Set up staging environment

The staging location is a specified directory used to store build artifacts (such as executables and configuration files) needed to create Podman images for the application, and it also includes a Makefile to manage the entire deployment lifecycle. Please note that this directory should not be located on an NFS mount.

1. Create the staging location and copy the downloaded kit to the staging location.

    ```bash
    mkdir <staging_location>
    cd <staging_location>
    cp <path to installation kit> .
    ```

2. Extract the installation kit in the staging location.

   - For ARM 64:

    ```bash
    <copy>
    tar xzf applied_ai_arm64.tar.gz
    </copy>
    ```

   - For Linux X86-64:

    ```bash
    <copy>
    tar xzf applied_ai.tar.gz
    </copy>
    ```

    Before you begin the installation process, if you are inside a corporate VPN, make sure to make sure to configure any required proxies to connect externally.

    ```bash
    export http_proxy=<your-http-proxy>;
    export https_proxy=<your-https-proxy>;
    export no_proxy=<your-domain>;
    export HTTP_PROXY=<your-http-proxy>;
    export HTTPS_PROXY=<your-https-proxy>;
    export NO_PROXY=<your-domain>;
    ```

### Run Interactive Installer

The `interactive_install.sh` script, included in the installation kit, automates nearly all setup tasks, including environment configuration, dependency installation, and application deployment.

> **Caution:** Run the installation as a non-root user. Podman, a critical component, must be set up and used in rootless mode for Agent Factory installations. Do not perform the installation or deployment steps as the root user.

This file will be present in the staging location once you extract the kit.

1. Run the Interactive Installer

   Now that the kit is unpacked, execute the `interactive_install.sh` script from within the same directory.

   ```bash
   bash interactive_install.sh --reset (Required if previously installed)
   bash interactive_install.sh
   ```

2. When the interactive installer prompts you, select the option that best suits your environment:

   ```
   Are you on a corporate network that requires an HTTP/HTTPS proxy? (y/N): y
   Enter 1 if you are on a Standard Oracle Linux machine or 2 if you are on OCI: <user_number_choice>
   Enter your Linux username: <user_linux_username>
   Does your default /tmp directory have insufficient space (< 100GB)? (y/N): y
   [INFO] You can get a token from https://container-registry.oracle.com/
   Username: <email_registered_on_container_registry>
   Password: <token_from_container_registry>
   Do you want to proceed with the manual database setup? (y/N): y
   [WARNING] Step 1: Create the database user.
   Enter the DB username you wish to create: <your_db_user>
   Enter the password for the new DB user: <your_db_user_password>
   [INFO] Run these SQL commands as a SYSDBA user on your PDB (Pluggable Database):
   ----------------------------------------------------
   CREATE USER <your_db_user> IDENTIFIED BY <your_db_user_password> DEFAULT TABLESPACE USERS QUOTA unlimited ON USERS;
   GRANT CONNECT, RESOURCE, CREATE TABLE, CREATE SYNONYM, CREATE DATABASE LINK, CREATE ANY INDEX, INSERT ANY TABLE, CREATE SEQUENCE, CREATE TRIGGER, CREATE USER, DROP USER TO <your_db_user>;
   GRANT CREATE SESSION TO <your_db_user> WITH ADMIN OPTION;
   GRANT READ, WRITE ON DIRECTORY DATA_PUMP_DIR TO <your_db_user>;
   GRANT SELECT ON V_$PARAMETER TO <your_db_user>;
   exit;
   ----------------------------------------------------
   Press [Enter] to continue to the next step...
   Select installation mode:
   1) prod
   2) quickstart
   Enter choice (1 or 2): 1
   You selected Production mode. Confirm? (yes/no): yes
   ```

   The following output indicates that the installation was completed successfully.

   ![Successful Prod Installation](images/prod-installation-output.png "Successful Prod Installation")

Once the installation script finishes successfully, you can access the application at the URL `https://<hostname>:8080/studio/` provided by the script and complete the remaining configuration through your web browser.

You may skip the other tasks and proceed to the next lab.

## (Optional) Task 2: Mac systems installation

### Download Mac installation kit

Download the kit from the official Oracle website Visit the [download page](https://www.oracle.com/database/technologies/private-agent-factory-downloads.html#) to get the installation kit.

![Screenshot of the Oracle AI Database Private Agent Factory kit download webpage, showing a description of the platform, download links for Linux X86-64 and ARM 64 installers, and brief details about each option and its compatibility.](images/download-page-a.png)

You may select the option that best suits your working environment:

- The installer kit for Apple Silicon (M-series) Mac: `applied_ai_arm64.tar.gz`.
- The installer kit for Intel-based Mac systems: `applied_ai.tar.gz`.

After selecting your platform, review and accept the License Agreement and click download.

![Screenshot of the Oracle Software Delivery Cloud page for downloading Oracle AI Database Private Agent Factory. The user can select platforms (Linux x86-64 or Linux ARM 64-bit), accept the license agreement, and choose software version 25.3.0.0.0 to download.](images/download-page-b.png)

### Set up staging environment

The staging location is a specified directory used to store build artifacts (such as executables and configuration files) needed to create Podman images for the application, and it also includes a Makefile to manage the entire deployment lifecycle. Please note that this directory should not be located on an NFS mount.

1. Create the staging location and copy the downloaded kit to the staging location.

    ```bash
    mkdir <staging_location>
    cd <staging_location>
    cp <path to installation kit> .
    ```

2. Extract the installation kit in the staging location.

   - For Apple M-Series Mac:

    ```bash
    <copy>
    tar xzf applied_ai_arm64.tar.gz
    </copy>
    ```

   - For Intel Mac:

    ```bash
    <copy>
    tar xzf applied_ai.tar.gz
    </copy>
    ```

    Before you begin the installation process, if you are inside a corporate VPN, make sure to make sure to configure any required proxies to connect externally.

    ```bash
    export http_proxy=<your-http-proxy>;
    export https_proxy=<your-https-proxy>;
    export no_proxy=<your-domain>;
    export HTTP_PROXY=<your-http-proxy>;
    export HTTPS_PROXY=<your-https-proxy>;
    export NO_PROXY=<your-domain>;
    ```

### Run Interactive Installer

The `interactive_install.sh` script, included in the installation kit, automates nearly all setup tasks, including environment configuration, dependency installation, and application deployment.

> **Caution:** Run the installation as a non-root user. Podman, a critical component, must be set up and used in rootless mode for Agent Factory installations. Do not perform the installation or deployment steps as the root user.

This file will be present in the staging location once you extract the kit.

1. Run the Interactive Installer

   Now that the kit is unpacked, execute the `interactive_install.sh` script from within the same directory.

   ```bash
   bash interactive_install.sh --reset (Required if previously installed)
   bash interactive_install.sh
   ```

2. When the interactive installer prompts you, select the option that best suits your environment:

   ```
   Are you on a corporate network that requires an HTTP/HTTPS proxy? (y/N): y
   Do you want to use the default specs? (Y/n): y
   Do you want to proceed with the manual database setup? (y/N): y
   [WARNING] Step 1: Create the database user.
   Enter the DB username you wish to create: <your_db_user>
   Enter the password for the new DB user: <your_db_user_password>
   [INFO] Run these SQL commands as a SYSDBA user on your PDB (Pluggable Database):
   ----------------------------------------------------
   CREATE USER <your_db_user> IDENTIFIED BY <your_db_user_password> DEFAULT TABLESPACE USERS QUOTA unlimited ON USERS;
   GRANT CONNECT, RESOURCE, CREATE TABLE, CREATE SYNONYM, CREATE DATABASE LINK, CREATE ANY INDEX, INSERT ANY TABLE, CREATE SEQUENCE, CREATE TRIGGER, CREATE USER, DROP USER TO <your_db_user>;
   GRANT CREATE SESSION TO <your_db_user> WITH ADMIN OPTION;
   GRANT READ, WRITE ON DIRECTORY DATA_PUMP_DIR TO <your_db_user>;
   GRANT SELECT ON V_$PARAMETER TO <your_db_user>;
   exit;
   ----------------------------------------------------
   Press [Enter] to continue to the next step...
   Select installation mode:
   1) prod
   2) quickstart
   Enter choice (1 or 2): 1
   You selected Production mode. Confirm? (yes/no): yes
   ```

   The following output indicates that the installation was completed successfully.

   ![Successful Prod Installation](images/prod-installation-output.png "Successful Prod Installation")

Once the installation script finishes successfully, you can access the application at the URL `https://<hostname>:8080/studio/` provided by the script and complete the remaining configuration through your web browser.


***

**Next Steps:** You may now **proceed to the next lab**

## Acknowledgements

- **Authors** 
* Emilio Perez, Member of Technical Staff, Database Applied AI
* Allen Hosler, Principal Product Manager, Database Applied AI

- **Last Updated Date** - January, 2026
