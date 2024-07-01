# Create Target Database

## Introduction

In this lab, you create a new, empty pluggable database in *CDB23*. The database will run on Oracle Database 23ai. You perform a series of checks and preparations to ensure the database is fit for the migration.

Estimated Time: 10 Minutes.

### Objectives

In this lab, you will:

* Execute a number of checks
* Create new, empty PDB
* Determine whether PDB is fit for migration
* Make required and recommended preparations

## Task 1: Check CDB

In contrast to the source database, the target CDB is on Oracle Database 23ai. This means there are no minimum requirements to the Release Update. Nor, is there a requirement for the Data Pump Bundle Patch. However, Oracle recommends that you install the latest Release Update in the target database prior to the migration.

1. Set the environment to the target CDB, *CDB23*, and connect.

    ```
    <copy>
    . cdb23
    sqlplus / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

2. Ensure that the database is *Enterprise Edition*. Transportable tablespaces is only supported on this edition.

    ```
    <copy>
    select banner from v$version;
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    BANNER
    --------------------------------------------------------------------------------
    Oracle Database 23ai Enterprise Edition Release 23.0.0.0.0 - Production
    ```
    </details>    

3. Ensure `compatible` setting in target CDB is same or higher than the source database.

    ```
    <copy>
    col value format a20
    select value from v$parameter where name='compatible';
    </copy>

    -- Be sure to hit RETURN
    ```

    * Source database `compatible` setting is *19.0.0*.
    * Target database is *23.0.0* which means the database raises `compatible` setting of the tablespaces on plug-in.
    * Raising `compatible` as part of a migration is typically not a problem.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    VALUE
    --------------------    
    23.0.0
    ```
    </details>  

4. Allocate memory for the streams pool. Just like in the source database, Oracle recommends pre-allocating memory and setting a minimum size of the streams pool. It is used by Advanced Queueing during Data Pump jobs.

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
    /u01/app/oracle/oradata
    ```
    </details>      

4. Ensure the PDB uses the same character set as the source database. 

    ```
    <copy>
    select value from nls_database_parameters where parameter='NLS_CHARACTERSET';
    </copy>
    ```
    * The source database uses character set *AL32UTF8*. 
    * Transportable tablespaces require the target database uses the same or compatible character set. 
    * However, Oracle recommend that you use the same character set. That is the safer and easier approach.
    * In some situations, it is possible to migrate to a different character set, if it is a strict binary superset of the source database. In such situation, additional considerations come into play.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
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
    * Oracle recommend that you use the same timezone file version as in the source database.   
    * If your data doesn't use the data type *TIMESTAMP WITH TIMEZONE* you can completely disregard this check.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
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
    DBTIME
    ------
    +00:00
    ```
    </details>

## Task 3: Prepare for migration

A few more changes are needed on the target database. Plus, Oracle has a few recommendations that help ensuring a smooth migration.

1. Create a directory object that points to the file system directory you created in a previous lab. Data Pump needs this directory for the import.

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
    exec dbms_stats.gather_schema_stats('SYS');
    exec dbms_stats.gather_schema_stats('SYSTEM');
    </copy>
    
    --Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> exec dbms_stats.gather_schema_stats('SYS');

    PL/SQL procedure successfully completed.

    SQL> exec dbms_stats.gather_schema_stats('SYSTEM');

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

## Acknowledgements

* **Author** - Daniel Overby Hansen
* **Contributors** - Klaus Gronau, Rodrigo Jorge, Mike Dietrich
* **Last Updated By/Date** - Daniel Overby Hansen, July 2024
