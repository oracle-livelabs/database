# Load Data into the Primary Database

## Introduction

In this lab, you will create the transaction processing schema and load data into it.

*Estimated Time:* 20 minutes

### About Oracle True Cache
Modern applications often require massive scalability in terms of both the number of connections and the amount of data that can be cached.

A popular approach is to place caches in front of the database. Those caches rely on the fact that applications often don't need to see the most current data. For example, when someone browses a flight reservation system, the system can show flight data that's one second old. When someone reserves a flight, then the system shows the most current data.

Oracle True Cache satisfies queries by using only data from its buffer cache. Like Oracle Active Data Guard, True Cache is a fully functional, read-only replication of the primary database, except that it's mostly diskless.

### Objectives


In this lab, you will:
* Create a  schema in the newly created env and create tables.
* Upload data to those tables

### Prerequisites (Optional)

This lab assumes you have:
* An Oracle Cloud account
* All previous labs successfully completed

## Task 1: Create the User and Tables

1. Open a terminal window and connect to the podman container for the primary database

    ```
    <copy>
    sudo podman exec -it prod /bin/bash
    </copy>
    ```
![primary database](https://oracle-livelabs.github.io/database/truecache/data-load/images/dataload.png " ")
2. Connect to the database as a sysdba user
    ```
    <copy>
    sqlplus / as sysdba
    </copy>
    ```

3. Show the existing pdbs in the database by using show pdbs.
    ```
    <copy>
    show pdbs;
    </copy>
    ```

4. Alter the session to log in to the PDB
    ```
    <copy>
    alter session set container=ORCLPDB1;
    </copy>
    ```

5. Execute step1 as the sysdba user. This creates the transactions user and provides the necessary permission to the transactions user.

    ```
    <copy>
    @step1.sql
    </copy>
    ```

![dataload step1](https://oracle-livelabs.github.io/database/truecache/data-load/images/dataloadstep1.png " ")

6. Exit from the sysdba session by pressing exit 
    ```
    <copy>
    exit
    </copy>
    ```
7.  Check the hostname of the linux box , by entering hostname command
     ```
    <copy>
    hostname
    </copy>
    ```
8. Logon to SALES1 service as the transaction user using the password specified in step1 in the format hostname:1521/SALES1. To view the password open the file using cat command.
    ```
    <copy>
    cat step1.sql
    </copy>
    ```
    sqlplus transactions/<***PASSWORDFROMSTEP1****>@prod:1521/SALES1

9. Execute step2 and step3 sequentially.

     ```
    <copy>
    @step2.sql
    </copy>
    ```

    ```
    <copy>
    @step3.sql
    </copy>
    ```

![dataload step3](https://oracle-livelabs.github.io/database/truecache/data-load/images/dataloadstep3.png " ")

## Task 2: Load Data into the Tables

1. Run step4 as the transactions user.

    ```
    <copy>
    @step4.sql
    </copy>
    ```
![dataload step4](https://oracle-livelabs.github.io/database/truecache/data-load/images/dataloadstep4.png " ")

2. After completing step4, you should see a commit complete message.
![dataload commit](https://oracle-livelabs.github.io/database/truecache/data-load/images/dataloadcommit.png " ")

3. Exit from the sqlplus session by entering exit 
    ```
    <copy>
    exit
    </copy>
    ```

## Task 3: Verify True Cache 

1. Open a new terminal window and connect to the podman container for true cache.
    ```
    <copy>
    sudo podman exec -i -t truedb /bin/bash
    </copy>
    ```
![dataload truecache](https://oracle-livelabs.github.io/database/truecache/data-load/images/dataloadtruecache.png " ")

2. Login to truecache as a sysdba user
     ```
    <copy>
    sqlplus / as sysdba
    </copy>
    ```
3. Set the db keep cache size.
     ```
    <copy>
    ALTER SYSTEM SET DB_KEEP_CACHE_SIZE=500M scope=both;
    </copy>
    ```
4. Exit from the sqlplus session by entering exit 
    ```
    <copy>
    exit
    </copy>
    ```
5. Login to the truecache using the transaction user using the format <truecache_hostname>:1521/SALES1_TC

sqlplus transactions/<***PASSWORDFROMSTEP1****>@truedb:1521/SALES1_TC
![dataload truecache login](https://oracle-livelabs.github.io/database/truecache/data-load/images/dataloadtruecachelogin.png " ")


6. Verify the True Cache role.
    ```
    <copy>
    SELECT DATABASE_ROLE FROM V$DATABASE;
    </copy>
    ```
![dataload truecache verify](https://oracle-livelabs.github.io/database/truecache/data-load/images/dataloadtruecacheverify.png " ")

7. Execute DBMS_CACHEUTIL.TRUE_CACHE_KEEP for the table.
     ```
    <copy>
    EXECUTE DBMS_CACHEUTIL.TRUE_CACHE_KEEP('TRANSACTIONS','ACCOUNTS')
    </copy>
    ```
![dataload truecache keep](https://oracle-livelabs.github.io/database/truecache/data-load/images/dataloadtruecachekeep.png " ")

8. Verify the tables are in keep by executing this below query
     ```
    <copy>
    set lines 200
    column owner format a20
    column OBJECT_NAME format a30
    SELECT OWNER, OBJECT_NAME FROM DBA_OBJECTS WHERE DATA_OBJECT_ID IN (SELECT DATA_OBJECT_ID FROM V$TRUE_CACHE_KEEP);
    </copy>
    ```
![dataload truecache keep verify](https://oracle-livelabs.github.io/database/truecache/data-load/images/dataloadtruecachekeepverify.png " ")

9. Exit from the sqlplus session by entering exit 
    ```
    <copy>
    exit
    </copy>
    ```

You may now proceed to the next lab.

## Learn More
[True Cache documentation for internal purposes] (https://docs-uat.us.oracle.com/en/database/oracle/oracle-database/23/odbtc/oracle-true-cache.html#GUID-147CD53B-DEA7-438C-9639-EDC18DAB114B)

## Acknowledgements
* **Authors** - Sambit Panda, Consulting Member of Technical Staff , Vivek Vishwanathan Software Developer, Oracle Database Product Management
* **Contributors** - Pankaj Chandiramani, Shefali Bhargava, Param Saini, Thirumalai Thathachary
* **Last Updated By/Date** - Sambit Panda, Consulting Member of Technical Staff, Oracle Database Product Management, August 2025
