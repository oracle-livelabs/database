# Getting Started

## Introduction

In this lab, you will create the prerequisites for starting a job.

Estimated Time: 10 Minutes

### Objectives

In this lab, you will:

* Create a user, a directory and other prerequisites
* Examine a Data Pump parameter file
* Start Data Pump

### Prerequisites

This lab assumes:

- You have completed Lab 1: Initialize Environment

## Task 1: Create prerequisites

A few things must be in place before you can start a Data Pump job.

1. Use the *yellow* terminal 🟨. Set the environment to *FTEX* and connect.

    ```
    <copy>
    . ftex
    sqlplus / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

2. A user may always export from or import to their own schema. But to export from or import to other schemas or the entire database, you must have additional privileges. Find the Data Pump roles.

    ```
    <copy>
    select role from dba_roles where role like '%PUMP%';
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> select role from dba_roles where role like '%PUMP%';
    
    ROLE
    --------------------------------------------------------------------------------
    DATAPUMP_EXP_FULL_DATABASE
    DATAPUMP_IMP_FULL_DATABASE
    ```
    </details> 

3. Get a list of those with the roles.

    ```
    <copy>
    col grantee format a20
    col granted_role format a30
    select grantee, granted_role from dba_role_privs where granted_role like '%PUMP%' order by 1, 2;
    </copy>

    -- Be sure to hit RETURN
    ```

    * *DBA* is a role, that's granted to the *SYSTEM* user.
    * Although *SYS* also has the Data Pump roles, you must **NEVER** use *SYS* to start Data Pump jobs. This may lead to unexpected behaviour.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> col grantee format a20
    SQL> col granted_role format a30
    SQL> select grantee, granted_role from dba_role_privs where granted_role like '%PUMP%' order by 1, 2;
    
    GRANTEE              GRANTED_ROLE
    -------------------- ------------------------------
    DBA                  DATAPUMP_EXP_FULL_DATABASE
    DBA                  DATAPUMP_IMP_FULL_DATABASE
    GSMADMIN_INTERNAL    DATAPUMP_EXP_FULL_DATABASE
    GSMADMIN_INTERNAL    DATAPUMP_IMP_FULL_DATABASE
    GSMUSER_ROLE         DATAPUMP_EXP_FULL_DATABASE
    SYS                  DATAPUMP_EXP_FULL_DATABASE
    SYS                  DATAPUMP_IMP_FULL_DATABASE
    
    7 rows selected.    
    ```
    </details> 
    
4. Create a user that you can use for Data Pump jobs.

    ```
    <copy>
    grant datapump_exp_full_database, datapump_imp_full_database to dpuser identified by oracle;
    </copy>
    ```

    * The `grant ... identified by` construct creates the user and grant privileges in one command.
    
    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> grant datapump_exp_full_database, datapump_imp_full_database to dpuser identified by oracle;
    
    Grant succeeded.
    ```
    </details> 

5. Data Pump needs a location where it can read from/write to files. You specify that using a directory object. Examine the built-in directory *DATA\_PUMP\_DIR*. 

    ```
    <copy>
    select directory_path from dba_directories where directory_name='DATA_PUMP_DIR';
    </copy>
    ```

    * Since Data Pump works on the server, the directory object refers to a location on the database server.
    * The directory path is not ideal; it defaults to a directory inside the Oracle home.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> select directory_path from dba_directories where directory_name='DATA_PUMP_DIR';
    
    DIRECTORY_PATH
    --------------------------------------------------------------------------------
    /u01/app/oracle/product/19/rdbms/log/
    ```
    </details> 

6. Create your own directory object and create the directory in the file system too.

    ```
    <copy>
    create or replace directory dpdir as '/home/oracle/dpdir';
    host mkdir /home/oracle/dpdir
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> create or replace directory dpdir as '/home/oracle/dpdir';
    
    Directory created.
    
    SQL> host mkdir /home/oracle/dpdir

    ```
    </details> 

7. Data Pump uses Advanced Queueing (AQ) to coordinate work between the control and worker processes. AQ uses the streams pool in the SGA. Check the current allocation.

    ```
    <copy>
    select bytes from v$sgainfo where name='Streams Pool Size';
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> select bytes from v$sgainfo where name='Streams Pool Size';
    
         BYTES
    ----------
             0
    ```
    </details> 

8. Automatic Shared Memory Management (ASMM) automatically will allocate memory to the streams pool when needed. However, it will resize the pool in small granules and it might affect performance of the Data Pump job. Increase the streams pool immediately.

    ```
    <copy>
    alter system set streams_pool_size=128m scope=memory;
    select bytes from v$sgainfo where name='Streams Pool Size';
    </copy>

    -- Be sure to hit RETURN
    ```

    * Normally, 128M to 256M is enough. 
    * If you frequently run Data Pump jobs, you can use `scope=both` to persist the change.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> alter system set streams_pool_size=128m scope=memory;
    
    System altered.

    SQL> select bytes from v$sgainfo where name='Streams Pool Size';
    
         BYTES
    ----------
     134217728    
    ```
    </details>     


9. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```

## Task 2: Parameter file

## Task 3: Starting Data Pump






You may now *proceed to the next lab*.

## Acknowledgments

* **Author** - Daniel Overby Hansen
* **Contributors** - Rodrigo Jorge, Mike Dietrich, Klaus Gronau, Alex Zaballa
* **Last Updated By/Date** - Daniel Overby Hansen, May 2025