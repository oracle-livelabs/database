# Check Source Database

## Introduction

In this lab, you will perform a number of checks on the source database to ensure it meets the minimum requirements. Also, you will collect information that you use later on to determine if the target database is suitable for the migration.

Estimated Time: 5 Minutes.

### Objectives

In this lab, you will:

* Execute a number of checks
* Gather information

## Task 1: Check minimum requirements

The M5 script has a set of minimum requirements.

1. Set the environment to the source database, *FTEX*.

    ```
    <copy>
    . ftex
    </copy>
    ```

2. Ensure the source database is running on Oracle Database 19c, Release Update 18, or newer. Also, ensure that the Data Pump Bundle Patch is installed.

    ```
    <copy>
    cd $ORACLE_HOME
    OPatch/opatch lspatches
    </copy>

    -- Be sure to hit RETURN
    ```    

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    35648110;OJVM RELEASE UPDATE: 19.21.0.0.231017 (35648110)
    35787077;DATAPUMP BUNDLE PATCH 19.21.0.0.0
    35643107;Database Release Update : 19.21.0.0.231017 (35643107)
    29585399;OCW RELEASE UPDATE 19.3.0.0.0 (29585399)
    
    OPatch succeeded.
    ```
    </details>

3. Connect to the database.

    ```
    <copy>
    sqlplus / as sysdba
    </copy>
    ```

4. Ensure that the database is *Enterprise Edition*. Transportable tablespaces is only supported on this edition.

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
    Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    ```
    </details>    


## Task 2: Perform checks

To determine whether the target database is fit for the migration, you must gather some information.

1. Get the `compatible` setting of the source database.

    ```
    <copy>
    col value format a20
    select value from v$parameter where name='compatible';
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    19.0.0
    ```
    </details>  

2. Get the character set.

    ```
    <copy>
    select value from nls_database_parameters where parameter='NLS_CHARACTERSET';
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    VALUE
    --------------------
    AL32UTF8
    ```
    </details>      

3. Get the database timezone file version.

    ```
    <copy>
    select version from v$timezone_file;
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    VERSION
    ----------
    42
    ```
    </details>      

4. Get the database timezone setting.

    ```
    <copy>
    select dbtimezone from v$instance;
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    DBTIME
    ------
    +00:00
    ```
    </details>    

## Task 3: Prepare for migration

Oracle recommends certain changes to the source database. These changes help ensuring a smooth migration.

1. Check the size of the streams pool. Data Pump uses Advanced Queueing which heavily uses the streams pool. To avoid waits while the streams pool is expanded, it is better to expand it upfront. 

    ```
    <copy>
    select value from v$parameter where name='streams_pool_size';
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    VALUE
    --------------------
    0
    ```
    </details> 

2. It's currently set to *0* which means there is no minimum size for the streams pool. Allocate 128 MB of shared memory to the pool. It can still grow beyond that if needed.

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

3. Enable block change tracking. This dramatically reduces the time it takes to perform incremental backups.

    ```
    <copy>
    alter database enable block change tracking;
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> alter database enable block change tracking;
    
    Database altered.
    ```
    </details>     

You may now *proceed to the next lab*.

## Acknowledgements

* **Author** - Daniel Overby Hansen
* **Contributors** - Klaus Gronau, Rodrigo Jorge, Mike Dietrich
* **Last Updated By/Date** - Daniel Overby Hansen, July 2024
