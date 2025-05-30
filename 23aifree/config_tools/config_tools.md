# Tools Setup

## Introduction

This lab walks you through configuring SQLcl, APEX and ORDS.

Estimated Time: 20 minutes

### Objectives

In this lab, you will:
* Configure SQLcl
* Configure APEX
* Configure ORDS
* Login to Database Actions (SQL Developer Web)

### Prerequisites

This lab assumes you have:
* Completed all previous workshops
* Have a Linux VM running Oracle Database 23ai Free Database
* Have access to a GUI on the Linux VM to run Database Actions (SQL Developer Web)

[Lab Walkthrough](videohub:1_17wvzaf1)

## Task 1: Setup SQLcl

1. Open a terminal if you don't currently have one open. To open one Click on Activities and then Terminal.

    ![Open Terminal](images/tools-1-1.png " ")


2. A newer version of java will be installed and you will need to ensure the environment variable JAVA_HOME is pointing at it. Some of the utilities require a higher version.
    ```
    <copy>
    sudo dnf install -y jdk-17.x86_64

    java -version

    echo $JAVA_HOME
    </copy>
    ```
    ![Java Install](images/tools-1-2a.png " ")

3. Install SQLcl using dnf.
    ```
    <copy>
    sudo dnf install -y sqlcl
    </copy>
    ```
    ![Download Software](images/tools-1-3new.png " ")

4. Test out SQLcl by connecting to the database. Notice the command is sql not sqlplus.
    ```
    <copy>
    sql / as sysdba
    </copy>
    ```
    ![Database Login](images/tools-1-4.png " ")

5. You can explore the database if you want. When you get done type exit. Your first few commands might take a little longer as the java environment is initializing.
    ```
    <copy>
    show pdbs
    </copy>
    ```
    ```
    <copy>
    exit
    </copy>
    ```
    ![Database Commands](images/tools-1-5.png " ")

## Task 2: Setup APEX

1. Install APEX using dnf. The first command installs apex and the second adds the images directory that will be used later. What you will also notice is this has a dependency on ORDS and install it.
    ```
    <copy>
    sudo dnf install -y oracle-apex23.1.noarch
    sudo dnf install -y oracle-apex23.1-images.noarch
    </copy>
    ```
    ![Download Software](images/tools-2-1anew.png " ")
    ![Download Software](images/tools-2-1bnew.png " ")

2. Run the install script into the <b>Pluggable</b> database. It's important that you install into the pluggable and not the container. Please review the architecture section of the APEX documentation in the additional information section for different deployment modes. This script will take about 5-7 minutes to complete.
    ```
    <copy>
    cd /opt/oracle/apex/23.1.0
    sql / as sysdba
    </copy>
    ```
    ```
    <copy>
    ALTER SESSION SET CONTAINER = FREEPDB1;
    </copy>
    ```
    ```
    <copy>  
    @apexins.sql SYSAUX SYSAUX TEMP /i/
    </copy>
    ```
    ```
    <copy>
    exit;
    </copy>
    ```
    ![Install Software](images/tools-2-2a.png " ")
    ![Install Software](images/tools-2-2b.png " ")

3. Run the change password script into the <b>Pluggable</b> database. When prompted use the values below
    - Username: Use the default ADMIN
    - Email: Use the default ADMIN
    - Password: Provide a password, I will use Welcome123#
    ```
    <copy>
    sql / as sysdba
    </copy>
    ```
    ```
    <copy>
    ALTER SESSION SET CONTAINER = FREEPDB1;
    </copy>
    ```
    ```
    <copy>
    @apxchpwd.sql
    </copy>
    ```
    ```
    <copy>
    exit;
    </copy>
    ```
    ![Password Change](images/tools-2-3.png " ")

4. Unlock and set the passwords for the various accounts in the <b>Pluggable</b> database. You will be prompted during the rest config script. I'm going to use Welcome123# for my examples but you can use any password you want.
    ```
    <copy>
    sql / as sysdba
    </copy>
    ```
    ```
    <copy>
    ALTER SESSION SET CONTAINER = FREEPDB1;
    </copy>
    ```
    ```
    <copy>
    ALTER USER APEX_PUBLIC_USER IDENTIFIED BY Welcome123# ACCOUNT UNLOCK;
    </copy>
    ```
    ```
    <copy>
    @apex_rest_config.sql
    </copy>
    ```
    ```
    <copy>
    exit;
    </copy>
    ```
    ![Change Password](images/tools-2-4.png " ")

## Task 3: Setup ORDS

1. Install ORDS using the dnf command. What you will see is that it is already installed. This happened when the images directory was installed.
    ```
    <copy>
    sudo dnf install -y ords
    </copy>
    ```
    ![Download Software](images/tools-3-1new.png " ")

2. You will need to grant the correct privileges to the hol23c user.
    ```
    <copy>
    cd /opt/oracle/ords/scripts/installer
    sql / as sysdba
    </copy>
    ```
    ```
    <copy>
    ALTER SESSION SET CONTAINER = FREEPDB1;
    </copy>
    ```
    ```
    <copy>
    @ords_installer_privileges.sql hol23c
    </copy>
    ```
    ```
    <copy>
    exit;
    </copy>
    ```
    ![Grant Privileges](images/tools-3-2new.png " ")

3. Copy the images directory from APEX to the ORDS directory
    ```
    <copy>
    cp -r /opt/oracle/apex/23.1.0/images /opt/oracle/ords
    </copy>
    ```
    ![Copying Directory](images/tools-3-3new.png " ")

4. Install ORDS answering the prompts with the following responses:
    - Installation: 2
    - Connection: 1
    - Hostname: localhost
    - Port: 1521 (Unless you used a different one)
    - Service Name: <b>FREEPDB1 (The PDB not the container)</b>
    - username: hol23c
    - password: Welcome123# (Unless you used a different one for hol23c)
    - Default tablespace: SYSAUX
    - Temporary Tablespace: TEMP
    - Features: 1 Database Actions (Enables all features)
    - Configuration: 1 Configure and Start
    - Protocol: 1 HTTP
    - HTTP port: 8080
    - Static resources location: /opt/oracle/ords/images
    ```
    <copy>
    ords --config /etc/ords/config install
    </copy>
    ```
    ![Installing Software](images/tools-3-4new.png " ")

5. After the installation has completed, the screen stops scrolling and you see the line "Oracle REST Data Services initialized" Stop ORDS by pressing CTRL-C
    ![Stop Service](images/tools-3-5.png " ")

6. Enable hol23c the ability to use ORDS.
    ```
    <copy>
    sql hol23c/Welcome123#@localhost:1521/freepdb1
    </copy>
    ```
    ```
    <copy>
    BEGIN
     ords_admin.enable_schema(
         p_enabled => TRUE,
         p_schema => 'HOL23C',
         p_url_mapping_type => 'BASE_PATH',
         p_url_mapping_pattern => 'hol23c',
         p_auto_rest_auth => NULL
     );
    commit;
    END;
    /
    </copy>
    ```
    ```
    <copy>
    exit;
    </copy>
    ```
    ![Enable Service](images/tools-3-6.png " ")

## Task 4: Login

1. Restart ORDS. Wait about 30 seconds for it to finish starting before proceeding.
    ```
    <copy>
    sudo systemctl stop ords
    sudo systemctl start ords
    </copy>
    ```
    ![Start Service](images/tools-4-1new.png " ")

2. Open a browser. If you have one currently open you can click on new window. If not click on activities and then browser.
    ![Open Browser](images/tools-4-2.png " ")

3. Navigate to SQL Developer Web by going to the following address.
    ```
    <copy>
    http://localhost:8080/ords/
    </copy>
    ```
    ![Open Web Page](images/tools-4-3.png " ")

4. Log into sql dev web as hol23c with your password. I used Welcome123#.
    ![Login](images/tools-4-4.png " ")

5. You may now **proceed to the next lab**
    ![Finshed Lab](images/tools-4-5.png " ")

## Learn More

* [Oracle SQLcl] (https://www.oracle.com/database/sqldeveloper/technologies/sqlcl)
* [Oracle Database Actions] (https://www.oracle.com/database/sqldeveloper/technologies/db-actions/)
* [Oracle APEX] (https://www.oracle.com/tools/downloads/apex-downloads)
* [Oracle APEX Installation Architecture Choices] (https://docs.oracle.com/en/database/oracle/apex/23.1/htmig/understanding-installation-choices.html#GUID-A805FD4D-6049-429D-9DD2-717C75D96E62)

## Acknowledgements
* **Author** - David Start, Database Product Management
* **Contributors** - David Start, Database Product Management
* **Last Updated By/Date** - David Start, Database Product Management, August 2023
