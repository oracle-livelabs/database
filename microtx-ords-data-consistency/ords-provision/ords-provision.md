# Set Up the ORDS Instances

## Introduction

This lab walks you through the steps to set up two Oracle REST Data Services (ORDS) applications, Department 1 and Department 2. These applications are created in PL/SQL and deployed using ORDS in Oracle Database. These applications participate in the XA transaction, so they are called transaction participant services.

Two PDBs, FREEPDB1 and FREEPDB2, are created in a standalone instance of Oracle Database 23c Free to simulate the distributed transaction. The standalone ORDS APEX service instance, runs on port 8080, and it is configured with two database pools that connect to FREEPDB1 and FREEPDB2. The ORDS service creates database pool for each PDB and exposes the REST endpoint. A single ORDS standalone service has two database connection pools connecting to different PDBs: FREEPDB1 and FREEPDB2. Department 1 and Department 2 connect to individual PDBs and the ORDS participant services expose three REST APIs, namely withdraw, deposit and get balance. The MicroTx library includes headers that enable the participant services to automatically enlist in the transaction. These microservices expose REST APIs to get the account balance and to withdraw or deposit money from a specified account. They also use resources from resource manager.

Estimated Time: 15 minutes

### Objectives

In this lab, you will:

* Start the Database service and ORDS service instances
* Grant privileges to the database schema
* Set Up Department 1 and Department 2 applications
* Test access to the applications

### Prerequisites

This lab assumes you have:

* An Oracle Cloud account.
* Successfully completed the previous labs:
  * Get Started
  * Lab 1: Prepare setup
  * Lab 2: Environment setup
* Logged in using remote desktop URL as an `oracle` user. If you have connected to your instance as an `opc` user through an SSH terminal using auto-generated SSH Keys, then you must switch to the `oracle` user before proceeding with the next step.

 ```text
  <copy>
  sudo su - oracle
  </copy>
  ```

## Task 1: Start the Database Service and ORDS Service Instances

1. Run the following command to verify that the Oracle Database 23c Free service instance is running.

    ```text
    <copy>
    sudo /etc/init.d/oracle-free-23c status
    </copy>
    ```

   **Example output**

    ```text
    Status of the Oracle FREE 23c service:
    LISTENER status: RUNNING
    FREE Database status: RUNNING
    ```
 
   If the Oracle Database 23c Free service instance is not in the `RUNNING` state, then run the following command to restart the service.

    ```text
    <copy>
    sudo systemctl restart oracle-free-23c
    </copy>
    ```

2. Run the following commands in a new terminal to start the Oracle REST Data Services (ORDS) standalone service. Keep this terminal window open throughout the lab.

    ```text
    <copy>
    export _JAVA_OPTIONS="-Xms8192M -Xmx8192M"
    ords --config ${ORDS_CONFIG} serve
    </copy>
    ```

3. Reset the password for the `SYS` user by logging into the catalog database with the default password.

    ```SQL
    <copy>
    sql sys/Passw0rd@FREE as sysdba
    SQL> ALTER USER SYS IDENTIFIED BY [new-user-password];
    SQL> ALTER USER SYSTEM IDENTIFIED BY [new-user-password];
    SQL> commit;
    SQL> exit;
    </copy>
    ```

    Where, `[new-user-password]` is the new password that you specify.

## Task 2: Grant Privileges to the Database Schema

1. Login to FREEPDB1 instance in Oracle Database 23c Free.

    ```text
    <copy>
    sql sys/<new-user-password>@FREEPDB1 as sysdba
    </copy>
    ```

    Where, `<new-user-password>` is the password that you have set in the previous task.

2. Run the following commands to grant privileges to the schema.

    ```SQL
    <copy>
    DECLARE
        l_principal VARCHAR2(20) := '<SCHEMA_USER_NAME>';
    begin
        DBMS_NETWORK_ACL_ADMIN.append_host_ace (
            host => '*',
            lower_port => null,
            upper_port => null,
            ace => xs$ace_type(privilege_list => xs$name_list('http'),
            principal_name => l_principal,
            principal_type => xs_acl.ptype_db));
    end;
    /
 
    DECLARE
        l_principal VARCHAR2(20) := '<SCHEMA_USER_NAME>';
    begin
        DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE(
            host => '*',
            ace  =>  xs$ace_type(privilege_list => xs$name_list('connect', 'resolve'),
            principal_name => l_principal,
            principal_type => xs_acl.ptype_db));
    end;
    /
    </copy>
    ```

    Where, `<SCHEMA_USER_NAME>` is the user name that can access the schema. Provide this value based on your environment.

3. Commit the changes and exit from SQL prompt.

    ```SQL
    <copy>
    SQL> commit;
    SQL> exit;
    </copy>
    ```

4. Login to FREEPDB2 instance in Oracle Database 23c Free.

    ```text
    <copy>
    sql sys/<new-user-password>@FREEPDB2 as sysdba
    </copy>
    ```

    Where, `<new-user-password>` is the password that you have set in the previous task.

5. Run the following commands to grant privileges to the schema.

    ```SQL
    <copy>
    DECLARE
        l_principal VARCHAR2(20) := '<SCHEMA_USER_NAME>';
    begin
        DBMS_NETWORK_ACL_ADMIN.append_host_ace (
            host => '*',
            lower_port => null,
            upper_port => null,
            ace => xs$ace_type(privilege_list => xs$name_list('http'),
            principal_name => l_principal,
            principal_type => xs_acl.ptype_db));
    end;
    /
 
    DECLARE
        l_principal VARCHAR2(20) := '<SCHEMA_USER_NAME>';
    begin
        DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE(
            host => '*',
            ace  =>  xs$ace_type(privilege_list => xs$name_list('connect', 'resolve'),
            principal_name => l_principal,
            principal_type => xs_acl.ptype_db));
    end;
    /
    </copy>
    ```

    Where, `<SCHEMA_USER_NAME>` is the user name that can access the schema. Provide this value based on your environment. Remember the user name as you will have to provide this to log in to the database.

6. Commit the changes and exit from SQL prompt.

    ```SQL
    <copy>
    SQL> commit;
    SQL> exit;
    </copy>
    ```

## Task 3: Set Up Department 1

1. Enter the SQL Developer web URL, `http://localhost:8080/ords/sql-developer`, to access Department 1 database.
    A sign-in page for Database Actions is displayed.

2. Enter the schema user name and password that you have specified in the previous tasks.

    The Database Actions page is displayed.

3. In the **Development** box, click **SQL**.

    ![Click on SQL](./images/click-sql.png)

4. Open the `tmmxa.sql` SQL script file which is located at `/home/oracle/OTMM/otmm-23.4.1/samples/xa/plsql/lib`.

5. In the script, search for `resManagerId` and enter a unique resource manager ID to identify the database in both the deposit and withdraw handlers.

    **Example Code**

    ```text
    <copy>
    resManagerId VARCHAR2(256):= ''60720954-8842-9f7c-a383-8d24e14554b6''; 
    </copy>
    ```

    ```text
    <copy>
    resManagerId VARCHAR2(256):= ''DEPT1-RM'';
    </copy>
    ```

6. Click **Run as SQL script** to run the script file.

    ![Click on SQL](./images/click-sql.png)

7. Log out from SQL Developer.


## Task 4: Set Up Department 2

1. Enter the SQL Developer web URL, `http://localhost:8080/ords/pool2/sql-developer`, to access Department 2 database.
    A sign-in page for Database Actions is displayed.

2. Enter the schema user name and password that you have specified in the previous tasks.

    The Database Actions page is displayed.

3. In the **Development** box, click **SQL**.

    ![Click on SQL](./images/click-sql.png)

4. Open the `ordsapp.sql` SQL script file which is located at `/home/oracle/OTMM/otmm-23.4.1/samples/xa/plsql/databaseapp`.

5. In the script, search for `resManagerId` and enter a unique resource manager ID to identify the database in both the `deposit` and `withdraw` handlers.

    **Example Code**

    ```text
    <copy>
    resManagerId VARCHAR2(256):= ''DEPT2-RM-Deposit''; 
    </copy>
    ```

    ```text
    <copy>
    resManagerId VARCHAR2(256):= ''DEPT2-RM- Withdraw'';
    </copy>
    ```

6. Click **Run as SQL script** to run the script file.

    ![Click on SQL](./images/click-sql.png)

7. Log out from SQL Developer.

## Task 5: Test Access to Department 1 and Department 2

Run the following commands to test access and verify that REST API calls to Department 1 and Department 2 are executed successfully.

1. Run the following command to retrieve the balance in account 1 of Department 1.

    ```text
    <copy>
    curl --location --request GET 'http://localhost:8080/ords/otmm/accounts/account1'
    </copy>
    ```

2. Run the following command to retrieve the balance in account 2 of Department 2.

    ```text
    <copy>
    curl --location --request GET 'http://localhost:8080/ords/pool2/otmm/accounts/account2'
    </copy>
    ```

You may now **proceed to the next lab.**

## Learn More

* [REST Data Services Developer's Guide](https://docs.oracle.com/en/database/oracle/oracle-rest-data-services/)

## Acknowledgements

* **Author** - Sylaja Kannan
* **Contributors** - Brijesh Kumar Deo and Bharath MC
* **Last Updated By/Date** - Sylaja Kannan, February 2024
