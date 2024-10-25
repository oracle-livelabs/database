# Create Target Database

## Introduction

In this lab, you create a new, empty pluggable database in *CDB23*. The database will run on Oracle Database 23ai. You perform a series of checks and preparations to ensure the database is fit for the migration.

Estimated Time: 10 Minutes

[Next-Level Platform Migration with Cross-Platform Transportable Tablespaces - lab 3](youtube:fgyDy-QcV_o?start=535)

### Objectives

In this lab, you will:

* Execute a number of checks
* Create a new, empty PDB
* Determine whether PDB is fit for migration
* Make required and recommended preparations

## Task 1: Check CDB

In contrast to the source database, the target CDB is on Oracle Database 23ai. This means there are no minimum requirements for the Release Update. Nor is there a requirement for the Data Pump Bundle Patch. However, Oracle recommends that you install the latest Release Update in the target database prior to the migration.

1. Use the *blue* terminal 🟦. Set the environment to the target CDB, *CDB23*, and connect.

    ```
    <copy>
    . cdb23
    sqlplus / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

2. Ensure that the database is *Enterprise Edition*. Transportable tablespaces is only supported in this edition.

    ```
    <copy>
    set line 100
    col banner format a100
    select banner from v$version;
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> set line 100
    SQL> col banner format a100
    SQL> select banner from v$version;

    BANNER
    ----------------------------------------------------------------------------------------------------
    Oracle Database 23ai Enterprise Edition Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems
    ```
    </details>    

3. Ensure the `compatible` setting in the target CDB is same or higher than the source database.

    ```
    <copy>
    col value format a20
    select value from v$parameter where name='compatible';
    </copy>

    -- Be sure to hit RETURN
    ```

    * The source database `compatible` setting is *19.0.0*.
    * The target database is *23.0.0*, which means the database raises `compatible` setting of the tablespaces on plug-in.
    * Raising `compatible` as part of a migration is typically not a problem, because transportable tablespaces does not allow you to go back to a previous release of Oracle Database.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> col value format a20
    SQL> select value from v$parameter where name='compatible';

    VALUE
    --------------------    
    23.0.0
    ```
    </details>  

4. Check the size of the streams pool. 

    ```
    <copy>
    select value from v$parameter where name='streams_pool_size';
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> select value from v$parameter where name='streams_pool_size';
    
    VALUE
    --------------------
    0
    ```
    </details> 

5. It's currently set to *0* which means there is no minimum size for the streams pool. Just like in the source database, allocate 128 MB of shared memory to the pool. It can still grow beyond that if needed.

    ```
    <copy>
    alter system set streams_pool_size=128M scope=both;
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> alter system set streams_pool_size=128M scope=both;
    
    System altered.
    ```
    </details> 

## Task 2: Create PDB

1. Create a new PDB.

    ```
    <copy>
    create pluggable database violet admin user admin identified by admin;
    alter pluggable database violet open;
    alter pluggable database violet save state;
    </copy>
    
    --Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> create pluggable database violet admin user admin identified by admin;

    Pluggable database created.

    SQL> alter pluggable database violet open;

    Pluggable database altered.

    SQL> alter pluggable database violet save state;

    Pluggable database altered.
    ```
    </details>  

2. Switch to the new PDB, *violet*. 

    ```
    <copy>
    alter session set container=violet;
    </copy>
    ```

3. Ensure the PDB uses Oracle Managed Files (OMF). This is a requirement of the M5 script. 

    ```
    <copy>
    col value format a30
    select value from v$parameter where name='db_create_file_dest';
    </copy>
    
    --Be sure to hit RETURN
    ```

    * The parameter is set to a path in the file system. The database uses OMF.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> col value format a30
    SQL> select value from v$parameter where name='db_create_file_dest';
    
    VALUE
    ------------------------------
    /u02/oradata
    ```
    </details>      

4. Ensure the PDB uses the same character set as the source database. 

    ```
    <copy>
    select value from nls_database_parameters where parameter='NLS_CHARACTERSET';
    </copy>
    ```
    * The source database uses the character set *AL32UTF8*. 
    * Transportable tablespaces require the target database to use the same or compatible character set. 
    * However, Oracle recommends that you use the same character set. That is the safer and easier approach.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> select value from nls_database_parameters where parameter='NLS_CHARACTERSET';

    VALUE
    --------------------
    AL32UTF8
    ```
    </details>      

5. Ensure the target database uses the same timezone file version as the source database. This is a requirement of transportable tablespaces.

    ```
    <copy>
    select version from v$timezone_file;
    </copy>
    ```

    * The source database uses timezone file version *42*.
    * You migrate using full transportable export/import (FTEX). Technically speaking, FTEX has the capability of migrating to a higher timezone file version. But Data Pump needs to convert all relevant timezone data (columns of type *TIMESTAMP WITH TIMEZONE*) to the new timezone file version. Depending on the amount of data, this can take many hours.
    * Oracle recommends that you use the same timezone file version as in the source database.   
    * If your data doesn't use the data type *TIMESTAMP WITH TIMEZONE* you can completely disregard this check.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> select version from v$timezone_file;

    VERSION
    ----------
    42
    ```
    </details>      

6. Ensure the target database is set to the same timezone. This is a requirement of transportable tablespaces.

    ```
    <copy>
    select dbtimezone from v$instance;
    </copy>
    ```

    * The source database is set to timezone *+00:00*.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> select dbtimezone from v$instance;

    DBTIME
    ------
    +00:00
    ```
    </details>

## Task 3: Prepare for migration

A few more changes are needed on the target database. Plus, Oracle has a few recommendations that help ensuring a smooth migration.

1. Ensure you are still in *VIOLET*.

    ```
    <copy>
    show con_name
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> show con_name

    CON_NAME
    ------------------------------
    VIOLET
    ```
    </details>

2. Create a directory object that points to the file system directory you created in a previous lab. Data Pump needs this directory for the import.

    ```
    <copy>
    create directory m5dir as '/home/oracle/m5/m5dir';
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> create directory m5dir as '/home/oracle/m5/m5dir';
    
    Directory created.
    ```
    </details>

3. Gather dictionary statistics before starting Data Pump. Oracle recommends gathering dictionary stats before starting a Data Pump export job.

    ```
    <copy>
    exec dbms_stats.gather_schema_stats(ownname=>'SYS', degree=>DBMS_STATS.AUTO_DEGREE);
    exec dbms_stats.gather_schema_stats(ownname=>'SYSTEM', degree=>DBMS_STATS.AUTO_DEGREE);
    </copy>
    
    --Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> exec dbms_stats.gather_schema_stats(ownname=>'SYS', degree=>DBMS_STATS.AUTO_DEGREE);

    PL/SQL procedure successfully completed.

    SQL> exec dbms_stats.gather_schema_stats(ownname=>'SYSTEM', degree=>DBMS_STATS.AUTO_DEGREE);

    PL/SQL procedure successfully completed.
    ```
    </details>

4. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```

You may now *proceed to the next lab*.

## Further information

Oracle recommends migrating to the same database character set. In some situations, it is possible to migrate to a different character set, if it is a strict binary superset of the source database. In such a situation, additional considerations come into play. You can review the [documentation](https://docs.oracle.com/en//database/oracle/oracle-database/19/spmds/general-limitations-on-transporting-data.html#GUID-28800719-6CB9-4A71-95DD-4B61AA603173) for details. 

## Acknowledgments

* **Author** - Daniel Overby Hansen
* **Contributors** - Rodrigo Jorge, Mike Dietrich, Klaus Gronau, Alex Zaballa
* **Last Updated By/Date** - Daniel Overby Hansen, August 2024
