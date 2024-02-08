# Set Up the ORDS Instances

## Introduction

This lab walks you through the steps to set up two Oracle REST Data Services (ORDS) applications, Department 1 and Department 2. These applications are created in PL/SQL and deployed using ORDS in Oracle Database. These applications participate in the XA transaction, so they are called transaction participant services.

There are 2 PDBs (pluggable database) and a catalog database running in a standalone instance of Oracle Database 23c Free to simulate the distributed transaction. Here are the details about the PDBs:

* FREE: A catalog database that the `sysdba` user can access.
* FREEPDB1: A pluggable database that contains the OTMM schema. This is connected to Department 1, an ORDS service.
* FREEPDB2 : A pluggable database that contains the OTMM schema. This is connected to Department 2, an ORDS service.

The standalone ORDS APEX service instance, runs on port 8080, and it is configured with two database pools that connect to FREEPDB1 and FREEPDB2. The ORDS service creates database pool for each PDB and exposes the REST endpoint. A single ORDS standalone service has two database connection pools connecting to different PDBs: FREEPDB1 and FREEPDB2. Department 1 and Department 2 connect to individual PDBs and the ORDS participant services expose three REST APIs, namely withdraw, deposit and get balance. The MicroTx library includes headers that enable the participant services to automatically enlist in the transaction. These microservices expose REST APIs to get the account balance and to withdraw or deposit money from a specified account. They also use resources from resource manager.

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

    Where, `[new-user-password]` is the new password that you specify for FREE, a catalog database.

## Task 2: Grant Privileges to the Schema in FREEPDB1

1. Login to FREEPDB1 using the default username and password.

    ```SQL
    <copy>
    sql sys/Passw0rd@FREEPDB1 as sysdba
    </copy>
    ```

2. Change the default password.

    ```SQL
    <copy>
    ALTER USER OTMM IDENTIFIED BY [<new-freepdb1-password>]; 
    commit;
    </copy>
    ```

    Where, `<new-freepdb1-password>` is the new password that you want to set for the `OTMM` schema user.

3. Run the following commands to grant privileges to the schema.

    ```SQL
    <copy>
    DECLARE
        l_principal VARCHAR2(20) := 'OTMM';
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
        l_principal VARCHAR2(20) := 'OTMM';
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

    Where, `OTMM` is the name of the user that can access the schema.

4. Commit the changes and exit from SQL prompt.

    ```SQL
    <copy>
    SQL> commit;
    SQL> exit;
    </copy>
    ```

## Task 3: Grant Privileges to the Schema in FREEPDB2

1. Login to FREEPDB2 using the default username and password.

    ```SQL
    <copy>
    sql sys/Passw0rd@FREEPDB2 as sysdba
    </copy>
    ```

2. Change the default password.

    ```SQL
    <copy>
    ALTER USER OTMM IDENTIFIED BY [<new-freepdb2-password>]; 
    commit;
    </copy>
    ```

    Where, `<new-freepdb2-password>` is the new password that you want to set for the `OTMM` schema user.

3. Run the following commands to grant privileges to the schema.

    ```SQL
    <copy>
    DECLARE
        l_principal VARCHAR2(20) := 'OTMM';
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
        l_principal VARCHAR2(20) := 'OTMM';
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

    Where, `OTMM` is the name of the user that can access the schema.

4. Commit the changes and exit from SQL prompt.

    ```SQL
    <copy>
    SQL> commit;
    SQL> exit;
    </copy>
    ```

## Task 4: Set Up Department 1

1. Enter the SQL Developer web URL, `http://localhost:8080/ords/sql-developer`, to access Department 1 database.
    A sign-in page for Database Actions is displayed.

2. Enter the new password that you have specified earlier, `<new-freepdb1-password>`, to access the FREEPDB1 database as `OTMM` schema user.

    The Database Actions page is displayed.

3. In the **Development** box, click **SQL**.

    ![Click on SQL](./images/click-sql.png)

4. Open the `tmmxa.sql` SQL script file which is located at `/home/oracle/OTMM/otmm-23.4.1/samples/xa/plsql/lib`.

5. Click **Run as SQL script** to run the `tmmxa.sql` SQL script file.

    ![Click Run as SQL script](./images/run-sql-script.png)

6. Open the `ordsapp.sql` SQL script file which is located at `/home/oracle/OTMM/otmm-23.4.1/samples/xa/plsql/databaseapp`.

7. In the script, search for `resManagerId` and enter a unique resource manager ID to identify the database in both the `deposit` and `withdraw` handlers.

    **Example Code**

    ```text
    <copy>
    resManagerId VARCHAR2(256):= ''DEPT1-RM''; 
    </copy>
    ```

    ```text
    <copy>
    resManagerId VARCHAR2(256):= ''DEPT1-RM'';
    </copy>
    ```

7. Click **Run as SQL script** to run the `ordsapp.sql` SQL script file.

    ![Click Run as SQL script](./images/run-sql-script.png)

8. Log out from SQL Developer.

## Task 5: Set Up Department 2

1. Enter the SQL Developer web URL, `http://localhost:8080/ords/pool2/sql-developer`, to access Department 2 database.

    A sign-in page for Database Actions is displayed.

2. Enter the new password that you have specified earlier, `<new-freepdb2-password>`, to access the FREEPDB1 database as `OTMM` schema user.

    The Database Actions page is displayed.

3. In the **Development** box, click **SQL**.

    ![Click on SQL](./images/click-sql.png)

4. Open the `tmmxa.sql` SQL script file which is located at `/home/oracle/OTMM/otmm-23.4.1/samples/xa/plsql/lib`.

5. Click **Run as SQL script** to run the script file.

    ![Click Run as SQL script](./images/run-sql-script.png)

6. Open the `ordsapp.sql` SQL script file which is located at `/home/oracle/OTMM/otmm-23.4.1/samples/xa/plsql/databaseapp`.

7. In the script, search for `resManagerId` and enter a unique resource manager ID to identify the database in both the `deposit` and `withdraw` handlers.

    **Example Code**

    ```text
    <copy>
    resManagerId VARCHAR2(256):= ''DEPT2-RM''; 
    </copy>
    ```

    ```text
    <copy>
    resManagerId VARCHAR2(256):= ''DEPT2-RM'';
    </copy>
    ```

8. Click **Run as SQL script** to run the script file.

    ![Click Run as SQL script](./images/run-sql-script.png)

9. Log out from SQL Developer.

## Task 6: Test Access to Department 1 and Department 2

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
