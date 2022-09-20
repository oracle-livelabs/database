# Establish the initial schema


## Introduction

In this lab, you will connect to the database using Cloud Shell to build the initial database schema. Then you will connect to the database using Database Actions, a browser-based tool easily accessible from the Autonomous Data Warehouse or Autonomous Transaction Processing console, to examine the data model and the sample data.

Estimated lab time: 15 minutes

### Objectives

-   Learn how to connect to your new autonomous database using Cloud Shell and Database Actions

### Prerequisites

-   This lab requires completing the previous labs in this workshop: **Getting Started** and **Provision an Autonomous Database**, in the Contents menu on the left.

## Task 1: Obtain Database Credentials

To perform a secure connection to your autonomous database, you need a database wallet which securely holds those credentials. These can be downloaded from the console of your autonomous database.
1. Click the **DB Connection** button on your database's details page.

    ![ATP console with DB Connection highlighted](./images/c1-atp-console-with-db-connection-highlighted.png " ")

2. Ensure the wallet type is Instance Wallet and click **Download Wallet**

    ![DB Connection screen with Download Wallet button highlighted](./images/c2-db-connection-screen-with-download-wallet-button-highlighted.png " ")

3. You will be prompted for a wallet password. Note that this is **not** related to the database password and is only required for particular types of client connections. You will not use this password in this lab. For this example, use the following password:

    ````
    <copy>01-NotNeededForNow</copy>
    ````

    ![Download wallet screen with password field highlighted](./images/c3-download-wallet-screen-with-password-field-highlighted.png " ")

    After entering the password and clicking the Download button, the Wallet zipfile will be downloaded to your local system. The name starts with __Wallet__ and contains the name of your database. 

    You may now close the Database Connection screen by clicking the __Close__ button.

## Task 2: Launch Cloud Shell

Oracle Cloud Infrastructure Cloud (OCI) Shell is a web browser-based terminal accessible from the Oracle Cloud Console. Cloud Shell provides access to a Linux shell with a pre-authenticated Oracle Cloud Infrastructure CLI, a pre-authenticated Ansible installation, and other valuable tools for following Oracle Cloud Infrastructure service tutorials and labs.

1. In your database's details page, click the **Cloud Shell** button at the top right. The bottom portion of the browser page should initiate a cloud shell session.

    ![Cloud Shell starting](./images/c4-cloud-shell-starting.png " ")

     After a few seconds, a Linux shell interface should be available. Most standard shell commands are available to you from Cloud Shell.

    ![Cloud shell has started](./images/c5-cloud-shell-has-started.png " ")

    You can maximise and normalise the Linux shell interface by clicking on the Arrow icons on the right side of the screen (in the green header). When maximised, the screen output will be easier to see and follow. 

    ![Icon for increasing size of Cloud Shell terminal](./images/c6-icon-to-increase-size-of-cloud-shell-terminal.png " ")

2. You will be using SQL tools from the cloud shell to create and run your performance benchmark, so you will need the database credentials you downloaded in the previous step. Click on the gear icon at the top right side of the cloud shell to reveal the **File Transfer** option, and choose **Upload**.

    ![Submenu after clicking gear icon in Cloudshell](./images/c7-submenu-after-clicking-gear-icon-in-cloudshell.png " ")

3. Drag (or click "select from your computer") the wallet file you downloaded in the previous step of this lab. Then click **Upload** to transfer the wallet file to your home directory under the cloud shell.

    ![Upload window with upload button highlighted](./images/c8-upload-window-with-upload-button-highlighted.png " ")

4. Verify the wallet has been successfully uploaded by listing the current directory in your cloud shell. The wallet file should be present in the home directory.

    ```nohighlight
    $ <copy>ls -l</copy>
    ```

    ```nohighlight
    mcdonald_c@cloudshell:~ (ap-sydney-1)$ ls -l 
    total 28
    -rw-r--r--. 1 mcdonald_c oci 26422 Sep  7 16:08 Wallet_<your database name>.zip
    ````
    Using the settings option, also available after clicking the Gear icon on the right side of the screen, you can change the font size and other attributes if needed.

 
5. Verify connectivity to your autonomous database. You will use the SQLcl command line interface to set your wallet credentials and connect to the database as the ADMIN user. Press ENTER at the last command, and enter your ADMIN password at the prompt.

    ```nohighlight
    <copy>sql /nolog</copy>
    ````

    Once logged in, set the configuration to use your uploaded wallet and connect to the database. Make sure you replace the ATPDBDESIGN name with your chosen database name:

    ```nohighlight
    <copy>set cloudconfig Wallet_ATPDBDESIGN.zip</copy>
    ````

    You can now display the TNS entries available for connection in the selected wallet file:

    ````nohighlights
    <copy>show tns</copy>
    ````

    Copy the __\_tp__ entry from the list and use it to connect to your database:

    ````
    <copy>connect admin@</copy>atpdbdesign_tp
    ```

    Use the password you choose while creating the database. If you have used the default password, you can copy it here:

    ```nohighlight
    <copy>Ora$Dev$Live2021</copy>
    ```

    After entering the password, the connection to the database should be established. The output on the screen will look like this:

    ````nohighlight
    mcdonald_c@cloudshell:~ (ap-sydney-1)$ sql /nolog

    SQLcl: Release 21.4 Production on Thu Sep 15 10:12:11 2022

    Copyright (c) 1982, 2022, Oracle.  All rights reserved.

    SQL> set cloudconfig Wallet_your-DB-name.zip
    SQL> show tns
    CLOUD CONFIG set to: Wallet_your-DB-name.zip

    TNS Lookup Locations
    --------------------

    TNS Locations Used
    ------------------
    1.  Wallet_your-DB-name.zip
    2.  /home/mcdonald_c

    Available TNS Entries
    ---------------------
    your-DB-name_HIGH
    your-DB-name_LOW
    your-DB-name_MEDIUM
    your-DB-name_TP
    your-DB-name_TPURGENT

    SQL> connect admin@your-DB-name_TP
    Password? (**********?) ****************
    Connected.

    SQL> exit
    Disconnected from Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production Version 19.16.0.1.0
    ````

6. If you have successfully logged into the database, type `exit` to leave SQLcl and return to the shell.

    ```nohighlight
    <copy>exit</copy>
    ```

## Task 3: Create the initial schema

1. Retrieve the zip file containing all of this lab's supporting files.

    ```nohighlight
    <copy>
    wget https://objectstorage.us-ashburn-1.oraclecloud.com/p/VEKec7t0mGwBkJX92Jn0nMptuXIlEpJ5XJA-A6C9PymRgY2LhKbjWqHeB5rVBbaV/n/c4u04/b/livelabsfiles/o/data-management-library-files/devlivelab.zip
    unzip devlivelab.zip
    ls -1

    </copy>
    ```

    There should be a listing of numerous files suffixed with SQL and SH. *Note that that listing may differ slightly from the output below as the lab evolves.*

    ```nohighlight
    mcdonald_c@cloudshell:~ (ap-sydney-1)$ ls -l 
    benchmark1.sh
    benchmark2.sh
    benchmark3.sh
    benchmark4.sh
    credential.sql
    devlivelab1.sql
    devlivelab2.sql
    devlivelab3.sql
    devlivelab4.sql
    devlivelab5.sql
    devlivelab6.sql
    devlivelab_bench2.sql
    devlivelab_bench.sql
    devlivelab.zip
    setup.sh
    setup.sql
    sqlp
    sql_plus
    Wallet_your-DB-name.zip
    ```

2. The file *credential.sql* is a central place where your database credentials will be stored to avoid the need to re-enter them during the benchmark continuously. Using VI, edit the file to reflect your autonomous database's password and __service names__. 

<if type="freetier">
    *If you are following this lab "to the letter, " you will likely not need to make any changes at all.*
</if>

    ```nohighlight
    <copy>vi credential.sql</copy>
    ```

    ```
    -- ====================================================
    -- Set these variables to match the details you used to create your instance
    --
    define ADMIN_USER=ADMIN
    define ADMIN_PASSWORD=Ora$Dev$Live2021
    define DB_SERVICE=your-DB-name_tp
    set cloudconfig Wallet_your-DB-name.zip
    --
    -- ====================================================
    ~                                                                                                                                                                                                                                                                                                                                                                                                                                   
    ~                                                                          
    ```

    Save your changes, and you are ready to build the initial database schema. To save, type **":wq"** while in VI.

3. Run the schema setup script. This script will connect to the database and create a schema called DEVLIVE. Note that this schema will be dropped if it already exists.

    ```nohighlight
    <copy>nohighlight
    ./setup.sh
    </copy>
    ```

    ````nohighlight
    mcdonald_c@cloudshell:~ (ap-sydney-1)$ ./setup.sh
    Unzipping wallet for sqlplus usage
    Running SQLcl to create user

    SQLcl: Release 21.4 Production on Thu Sep 08 14:29:47 2022

    Copyright (c) 1982, 2022, Oracle.  All rights reserved.

    Connecting as admin level user

    Connected.
    USER is "ADMIN"

    Dropping devlive user if it exists

    PL/SQL procedure successfully completed.

    Creating devlive user and allocating privs

    User DEVLIVE created.

    Grant succeeded.

    Grant succeeded.

    Grant succeeded.

    Grant succeeded.

    Grant succeeded.

    Testing connection

    Connected.

    If you got to here with no errors, your DEVLIVE account is ready for schema generation

    User    : devlive
    Password: Ora$Dev$Live2021

    Press Enter to continue creating the schema.
    ````

    The script will pause throughout execution to let you observe the process.  Press Enter to continue.

## Task 4: View the data model with Database Actions

Note: This step is not mandatory for your performance benchmark investigation but offers a glimpse at the web-based tools *other* than Cloud Shell to interact with your database.

Although you can connect to your autonomous database from local PC desktop tools like Oracle SQL Developer, you can conveniently access the browser-based Database Actions directly from your Autonomous Data Warehouse or Autonomous Transaction Processing console.

1. If you have maximized the CloudShell terminal, first collapse it to display the Autonomous Database details. In your database's details page, click the **Database Actions** button, and then in the Database Actions box, click **Open Database Actions**.

    ![ATP console with database actions highlighted](./images/m1-atp-console-with-database-actions-highlighted.png " ")

2. After the Database Actions have been initialised and the various actions are displayed on your screen, choose **Data Modeler** to launch the web-based data modelling tool.

    ![Database actions menu with Data Modeler option highlighted](./images/m2-database-actions-menu-with-data-modeler-option-highlighted.png " ")

    The data modeller tool with open with a blank canvas for building your database schema design.

    ![Data Modeler work sheet](./images/m3-data-modeler-web-worksheet.png " ")

3. Your database schema has already been built via the setup.sh, command you ran earlier, so you will bring that schema into the modeller to see the relationships between the tables.  From the schema drop-down at the left, choose the **DEVLIVE** schema.

    ![Data Modeler worksheet with PRODUCT_CATEGORIES table highlighted](./images/m4-data-modeler-navigator-with-product-categories-highlighted.png " ")

4. Right-click on the CUSTOMERS table and choose **Add object to diagram**.

    ![Right click menu after selecting a table](./images/m5-right-click-menu-after-table-selection.png "")

5. The CUSTOMERS table will appear on the diagram with its columns and other metadata revealed.

    ![Data Modeler worksheet after adding customers table](./images/m6-data-modeler-worksheet-after-adding-customers-table.png " ")

6. Perform the same step for each remaining table in the listing at the left. You cannot select all tables and do the action for all tables simultaneously; it needs to be done one table at a time. Don't worry about the display, as many tables will overlap.

    ![Data Modeler Diagram mess after adding all objects](./images/m7-data-modeler-model-mess-after-adding-all-tables.png " ")

   Once all tables have been imported, click the **Auto-Layout** button. The tables will be re-arranged on the diagram to form a neat relationship model. You can also drag and resize tables on the diagram to suit your preferences.

    ![Data Modeler diagram layout with Layout Wizard selected](./images/m8-data-modeler-diagram-layout-wizard-selected.png " ")

    The result will look similar to this:

    ![Data Modeler Diagram after Auto Layout wizard applied](./images/m9-data-modeler-diagram-after-auto-layout-wizard-applied.png " ")

    Close the Data Modeler window, and please **proceed to the next lab.**

## Want to Learn More?

Click [here](https://docs.oracle.com/en/cloud/paas/autonomous-data-warehouse-cloud/user/sql-developer-web.html#GUID-102845D9-6855-4944-8937-5C688939610F) for documentation on connecting with the built-in Database Actions.

## Acknowledgements

- **Author** - Connor McDonald, Database Advocate
- **Last Updated By/Date** - Robert Pastijn, September 2022