# Configure ORDS

## Introduction

Oracle Rest Data Service (ORDS) is a service that allows you to connect to the Oracle Database and use CRUD operations through REST calls. In this lab, you will setup ORDS to be used on the 23c Free Developer Release database. 

Estimated Time: 5 minutes


### Objectives

In this lab, you will:

- Create a new schema for ORDS
- Install ORDS on the database
- Enable the ORDS Schema and allow anonymous access

### Prerequisites

This lab assumes you have:
- An instance with 23c Free Developer Release database installed
- Access to the instance's remote desktop


## Task 1: Create a schema for ORDS


1. You will create a new user/schema for this workshop. It will host all the data for the workshop and be enabled with ORDS. First, set your environment variables. when prompted for ORACLE_SID, enter 'ora23c'.

    ```
    $ <copy>. oraenv</copy>
    ```
    ```
    <copy>ora23c</copy>
    ```

2. Make a directory and download files to be used in this workshop.

    ```
    $ <copy>cd ~</copy>
    $ <copy>mkdir json-ords</copy>
    $ <copy>cd json-ords</copy>
    $ <copy>wget https://objectstorage.us-ashburn-1.oraclecloud.com/p/VEKec7t0mGwBkJX92Jn0nMptuXIlEpJ5XJA-A6C9PymRgY2LhKbjWqHeB5rVBbaV/n/c4u04/b/livelabsfiles/o/data-management-library-files/json-ords.zip</copy>
    $ <copy>unzip json-ords.zip</copy>
    ```

2. Login to the database and sysdba and connect to the pluggable database. 

    ```
    $ <copy>sqlplus / as sysdba</copy>
    ```
    ```
    SQL> <copy>alter pluggable database pdb23c open;</copy>
    ```
    ```
    SQL> <copy>alter session set container=pdb23c;</copy>
    ```

3. In the pluggable database, create a new schema and assign the privileges needed to install and configure ORDS;

    ```
    SQL> <copy>create user janus identified by janus;</copy>
    ```
    ```
    SQL> <copy>@ords_installer_privileges.sql janus;</copy>
    ```


## Task 2: Install ORDS


1. Open a new Terminal tab by going to **File** > **New Tab**.

2. In the new tab, install ORDS on your database.

    ```
    $ <copy>ords install</copy>
    ```

3. Select 2 to configure the database pool and install ORDS. 

4. Select 2 to connect with TNS. 

5. Input the path to the TNS directory. 

    ```
    <copy>/u01/app/oracle/product/23.0.0/dbhome_1/network/admin/</copy>
    ```

6. Select 3 to use the TNS alias of the PDB23c database. 

7. Input the username and password of the schema you created. 

    ```
    Username: janus
    Password: janus
    ```

8. Press 'enter' on the following prompts to accept the default configuration parameters. 

9. Select 1 to enable all features. 

10. Select 1 to configure and start ORDS in standalone mode. 

11. Select 1 to choose HTTP as the protocol. 

12. Press 'enter' to use the default port 8080.

13. Press 'enter' to leave the APEX static resources prompt empty. 

14. Once the install completes, you will see a few lines such as the ones below, denoting that ORDS has been installed and is now running. 

    **NOTE:** You must leave this terminal open and the process running. Closing either will stop ORDS from running. 


## Task 2: Enable ORDS in the schema


1. In the other terminal window, exit out of sqlplus and login as janus on the pluggable database. 

    ```
    SQL> <copy>exit;</copy>
    ```
    ```
    $ <copy>sqlplus janus/janus@pdb23c</copy>
    ``` 

2. Execute the following commands in sqlplus to enable ORDS and allow anonymous access to SODA REST.

    ```
    SQL> <copy>exec ords.enable_schema;commit;</copy>
    ```
    ```
    SQL> <copy>exec ords.delete_privilege_mapping('oracle.soda.privilege.developer', '/soda/*');commit;</copy>
    ```

3. To confirm ORDS has been installed and is anonymously accessible, open a browser and go to: 

    ```
    <copy>http://localhost:8080/ords/janus/soda/latest</copy>
    ```

    If all steps succeeded, you should see:

    ```
    {"items":[],"hasMore":false}
    ```

You may **proceed to the next lab.**

## Learn More

- [JSON Relational Duality Blog](https://blogs.oracle.com/database/post/json-relational-duality-app-dev)
- [23c Beta Docs - TO BE CHANGED](https://docs-stage.oracle.com/en/database/oracle/oracle-database/23/index.html)

## Acknowledgements

- **Author**- William Masdon, Product Manager, Database 
- **Last Updated By/Date** - William Masdon, Product Manager, Database, March 2023
