# Migrate Data Using Full Transportable Export/Import

## Introduction

Instead of upgrading and migrating an entire database, you will try a different approach in this lab. A migration of your data using transportable tablespaces into a brand new, empty database on Oracle Database 23ai. Using this approach, you can skip the usual upgrade and PDB conversion. Transportable tablespaces enables you to move your data directly into a higher release database. Further, you can export from a non-CDB and directly into a pluggable database.

Transportable tablespaces works fine even on bigger databases compared to a regular export/import. However, with transportable tablespaces you don't have the same customization options.

You will use the easiest method for transportable tablespaces, Full Transportable Export/Import (FTEX), to move data from the *FTEX* database and into a new PDB in the *CDB23* database.

Estimated Time: 15 minutes

### Objectives

In this lab, you will:

* Prepare new PDB
* Move your data using FTEX

### Prerequisites

None.

This lab uses the *FTEX* and *CDB23* databases. Don't do this lab at the same time as lab 11 and 12.

## Task 1: Data Pump export

You need to prepare a few things before you can start FTEX.

1. Data Pump needs access to a directory where it can put dump and log file. Create a directory in the file system.

    ```
    <copy>
    mkdir -p /home/oracle/logs/migrate-using-ftex
    </copy>
    ```

2. Set the environment to the source database and connect.

    ```
    <copy>
    . ftex
    sqlplus / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

3. Gather dictionary statistics before starting Data Pump. Oracle recommends gathering dictionary stats before starting a Data Pump export job.

    ```
    <copy>
    exec dbms_stats.gather_schema_stats('SYS');
    exec dbms_stats.gather_schema_stats('SYSTEM');
    </copy>

    -- Be sure to hit RETURN
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

4. Create a database directory object. It must point to the directory in the operating system that you just created.

    ```
    <copy>
    create or replace directory ftexdir as '/home/oracle/logs/migrate-using-ftex';
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> create or replace directory ftexdir as '/home/oracle/logs/migrate-using-ftex';

    Directory created.
    ```
    </details>

5. Create a dedicated user that you can use for the Data Pump export job.

    ```
    <copy>
    create user ftexuser identified by ftexuser default tablespace system;
    grant exp_full_database to ftexuser;
    grant read, write on directory ftexdir to ftexuser;
    alter user ftexuser quota unlimited on system;
    </copy>

    -- Be sure to hit RETURN
    ```

    * The default user tablespace must be *SYSTEM* or *SYSAUX* because all other tablespaces will be set read-only later on. During export, Data Pump must be able to create a table in the default tablespace.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> create user ftexuser identified by ftexuser default tablespace system;

    User created.

    SQL> grant exp_full_database to ftexuser;

    Grant succeeded.

    SQL> grant read, write on directory ftexdir to ftexuser;

    Grant succeeded.

    SQL> alter user ftexuser quota unlimited on system;

    User altered.
    ```
    </details>

6. Generate a list of tablespaces to set read-only.

    ```
    <copy>
    select
       tablespace_name
    from
       dba_tablespaces
    where
       contents='PERMANENT'
       and tablespace_name not in ('SYSTEM','SYSAUX');
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> select
           tablespace_name
        from
           dba_tablespaces
        where
           contents='PERMANENT'
           and tablespace_name not in ('SYSTEM','SYSAUX');

    TABLESPACE_NAME
    ------------------------------
    USERS
    ```
    </details>

7. Set the tablespace read-only.

    ```
    <copy>
    ALTER TABLESPACE USERS READ ONLY;
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> ALTER TABLESPACE USERS READ ONLY;

    Tablespace altered.
    ```
    </details>

6. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```

7. Examine the precreated Data Pump parameter file.

    ```
    <copy>
    cat /home/oracle/scripts/migrate-using-ftex-exp.par
    </copy>
    ```

    * `dumpfile` uses the `%L` wildcard that enables Data Pump to create many dump files.
    * `filesize` splits the files into 5 GB chunks which is handy if you need to transfer the dump files to a remote system.
    * `metrics` and `logtime` print additional diagnostic information in the log file.
    * `exclude` specifies to skip database statistics. You will re-gather statistics on target.
    * `full=y` and `transportable=always` tells Data Pump to perform a full transportable export/import.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    directory=ftexdir
    logfile=ftex_exp.log
    dumpfile=ftex_exp_%L.dmp
    filesize=5g
    metrics=yes
    logtime=all
    exclude=statistics
    full=y
    transportable=always
    ```
    </details>

8. Start the Data Pump export. Connect as the dedicated export user, *ftexuser*, that you just created.

    ```
    <copy>
    expdp ftexuser/ftexuser parfile=/home/oracle/scripts/migrate-using-ftex-exp.par
    </copy>
    ```

    * In the end of the log file, Data Pump writes which data files you must use on import.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    Export: Release 19.0.0.0.0 - Production on Wed May 29 13:31:09 2024
    Version 19.21.0.0.0

    Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.

    Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    29-MAY-24 13:31:12.853: Starting "FTEXUSER"."SYS_EXPORT_FULL_01":  ftexuser/******** parfile=/home/oracle/scripts/migrate-using-ftex-exp.par
    29-MAY-24 13:31:13.540: W-1 Startup took 1 seconds
    29-MAY-24 13:31:15.094: W-2 Startup took 1 seconds
    29-MAY-24 13:31:16.400: W-1 Processing object type DATABASE_EXPORT/EARLY_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA
    29-MAY-24 13:31:17.387: W-1 Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/TABLE_DATA
    29-MAY-24 13:31:18.561: W-2 . . exported "SYS"."KU$_USER_MAPPING_VIEW"               5.867 KB      24 rows in 2 seconds using external_table
    29-MAY-24 13:31:18.719: W-2 . . exported "SYS"."DAM_CONFIG_PARAM$"                   6.539 KB      14 rows in 0 seconds using direct_path
    29-MAY-24 13:31:18.739: W-2 . . exported "SYS"."TSDP_SUBPOL$"                        6.328 KB       1 rows in 0 seconds using direct_path
    29-MAY-24 13:31:18.757: W-2 . . exported "SYS"."TSDP_PARAMETER$"                     5.953 KB       1 rows in 0 seconds using direct_path
    29-MAY-24 13:31:18.777: W-2 . . exported "SYS"."TSDP_POLICY$"                        5.921 KB       1 rows in 0 seconds using direct_path
    29-MAY-24 13:31:18.838: W-2 . . exported "AUDSYS"."AUD$UNIFIED":"AUD_UNIFIED_P0"     50.95 KB       0 rows in 0 seconds using direct_path
    29-MAY-24 13:31:18.865: W-2 . . exported "SYS"."AUD$"                                23.46 KB       0 rows in 0 seconds using direct_path
    29-MAY-24 13:31:18.883: W-2 . . exported "SYS"."DAM_CLEANUP_EVENTS$"                 7.187 KB       0 rows in 0 seconds using direct_path
    29-MAY-24 13:31:18.901: W-2 . . exported "SYS"."DAM_CLEANUP_JOBS$"                   7.179 KB       0 rows in 0 seconds using direct_path
    29-MAY-24 13:31:18.904: W-2 . . exported "SYS"."TSDP_ASSOCIATION$"                       0 KB       0 rows in 0 seconds using direct_path
    29-MAY-24 13:31:18.906: W-2 . . exported "SYS"."TSDP_CONDITION$"                         0 KB       0 rows in 0 seconds using direct_path
    29-MAY-24 13:31:18.908: W-2 . . exported "SYS"."TSDP_FEATURE_POLICY$"                    0 KB       0 rows in 0 seconds using direct_path
    29-MAY-24 13:31:18.910: W-2 . . exported "SYS"."TSDP_PROTECTION$"                        0 KB       0 rows in 0 seconds using direct_path
    29-MAY-24 13:31:18.913: W-2 . . exported "SYS"."TSDP_SENSITIVE_DATA$"                    0 KB       0 rows in 0 seconds using direct_path
    29-MAY-24 13:31:18.915: W-2 . . exported "SYS"."TSDP_SENSITIVE_TYPE$"                    0 KB       0 rows in 0 seconds using direct_path
    29-MAY-24 13:31:18.917: W-2 . . exported "SYS"."TSDP_SOURCE$"                            0 KB       0 rows in 0 seconds using direct_path
    29-MAY-24 13:31:18.920: W-2 . . exported "SYSTEM"."REDO_DB"                              0 KB       0 rows in 0 seconds using direct_path
    29-MAY-24 13:31:18.923: W-2 . . exported "SYSTEM"."REDO_LOG"                             0 KB       0 rows in 0 seconds using direct_path
    29-MAY-24 13:31:22.089: W-1 Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA
    29-MAY-24 13:31:23.090: W-1 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/TABLE_DATA
    29-MAY-24 13:31:23.756: W-2 . . exported "SYS"."AUDTAB$TBS$FOR_EXPORT"               5.960 KB       2 rows in 1 seconds using external_table
    29-MAY-24 13:31:23.764: W-2 . . exported "SYS"."DBA_SENSITIVE_DATA"                      0 KB       0 rows in 0 seconds using external_table
    29-MAY-24 13:31:23.773: W-2 . . exported "SYS"."DBA_TSDP_POLICY_PROTECTION"              0 KB       0 rows in 0 seconds using external_table
    29-MAY-24 13:31:23.777: W-2 . . exported "SYS"."FGA_LOG$FOR_EXPORT"                      0 KB       0 rows in 0 seconds using external_table
    29-MAY-24 13:31:23.827: W-2 . . exported "SYS"."NACL$_ACE_EXP"                           0 KB       0 rows in 0 seconds using external_table
    29-MAY-24 13:31:23.935: W-2 . . exported "SYS"."NACL$_HOST_EXP"                      6.914 KB       1 rows in 0 seconds using external_table
    29-MAY-24 13:31:23.939: W-2 . . exported "SYS"."NACL$_WALLET_EXP"                        0 KB       0 rows in 0 seconds using external_table
    29-MAY-24 13:31:23.943: W-2 . . exported "SYS"."SQL$TEXT_DATAPUMP"                       0 KB       0 rows in 0 seconds using external_table
    29-MAY-24 13:31:23.945: W-2 . . exported "SYS"."SQL$_DATAPUMP"                           0 KB       0 rows in 0 seconds using external_table
    29-MAY-24 13:31:23.949: W-2 . . exported "SYS"."SQLOBJ$AUXDATA_DATAPUMP"                 0 KB       0 rows in 0 seconds using external_table
    29-MAY-24 13:31:23.952: W-2 . . exported "SYS"."SQLOBJ$DATA_DATAPUMP"                    0 KB       0 rows in 0 seconds using external_table
    29-MAY-24 13:31:23.957: W-2 . . exported "SYS"."SQLOBJ$PLAN_DATAPUMP"                    0 KB       0 rows in 0 seconds using external_table
    29-MAY-24 13:31:23.959: W-2 . . exported "SYS"."SQLOBJ$_DATAPUMP"                        0 KB       0 rows in 0 seconds using external_table
    29-MAY-24 13:31:23.997: W-2 . . exported "SYSTEM"."SCHEDULER_JOB_ARGS"                   0 KB       0 rows in 0 seconds using external_table
    29-MAY-24 13:31:25.480: W-1 Processing object type DATABASE_EXPORT/PLUGTS_FULL/FULL/PLUGTS_TABLESPACE
    29-MAY-24 13:31:25.500: W-1      Completed  PLUGTS_TABLESPACE objects in  seconds
    29-MAY-24 13:31:25.531: W-1 Processing object type DATABASE_EXPORT/PLUGTS_FULL/PLUGTS_BLK
    29-MAY-24 13:31:25.565: W-1      Completed 1 PLUGTS_BLK objects in 0 seconds
    29-MAY-24 13:31:25.947: W-1 Processing object type DATABASE_EXPORT/END_PLUGTS_BLK
    29-MAY-24 13:31:25.950: W-1      Completed 1 PLUGTS_BLK objects in 0 seconds
    29-MAY-24 13:31:25.963: W-1 Processing object type DATABASE_EXPORT/PRE_SYSTEM_IMPCALLOUT/MARKER
    29-MAY-24 13:31:25.964: W-1      Completed 1 MARKER objects in 0 seconds
    29-MAY-24 13:31:25.971: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER
    29-MAY-24 13:31:25.972: W-1      Completed 1 MARKER objects in 0 seconds
    29-MAY-24 13:31:26.010: W-1 Processing object type DATABASE_EXPORT/TABLESPACE
    29-MAY-24 13:31:26.014: W-1      Completed 2 TABLESPACE objects in 1 seconds
    29-MAY-24 13:31:26.114: W-1 Processing object type DATABASE_EXPORT/PROFILE
    29-MAY-24 13:31:26.118: W-1      Completed 1 PROFILE objects in 0 seconds
    29-MAY-24 13:31:26.152: W-1 Processing object type DATABASE_EXPORT/SCHEMA/USER
    29-MAY-24 13:31:26.156: W-1      Completed 2 USER objects in 0 seconds
    29-MAY-24 13:31:26.183: W-1 Processing object type DATABASE_EXPORT/ROLE
    29-MAY-24 13:31:26.187: W-1      Completed 1 ROLE objects in 0 seconds
    29-MAY-24 13:31:26.198: W-1 Processing object type DATABASE_EXPORT/RADM_FPTM
    29-MAY-24 13:31:26.202: W-1      Completed 1 RADM_FPTM objects in 0 seconds
    29-MAY-24 13:31:26.376: W-1 Processing object type DATABASE_EXPORT/GRANT/SYSTEM_GRANT/PROC_SYSTEM_GRANT
    29-MAY-24 13:31:26.380: W-1      Completed 6 PROC_SYSTEM_GRANT objects in 0 seconds
    29-MAY-24 13:31:26.406: W-1 Processing object type DATABASE_EXPORT/SCHEMA/GRANT/SYSTEM_GRANT
    29-MAY-24 13:31:26.422: W-1      Completed 74 SYSTEM_GRANT objects in 0 seconds
    29-MAY-24 13:31:26.441: W-1 Processing object type DATABASE_EXPORT/SCHEMA/ROLE_GRANT
    29-MAY-24 13:31:26.451: W-1      Completed 41 ROLE_GRANT objects in 0 seconds
    29-MAY-24 13:31:26.467: W-1 Processing object type DATABASE_EXPORT/SCHEMA/DEFAULT_ROLE
    29-MAY-24 13:31:26.471: W-1      Completed 4 DEFAULT_ROLE objects in 0 seconds
    29-MAY-24 13:31:26.489: W-1 Processing object type DATABASE_EXPORT/SCHEMA/ON_USER_GRANT
    29-MAY-24 13:31:26.498: W-1      Completed 18 ON_USER_GRANT objects in 0 seconds
    29-MAY-24 13:31:26.526: W-1 Processing object type DATABASE_EXPORT/SCHEMA/TABLESPACE_QUOTA
    29-MAY-24 13:31:26.530: W-1      Completed 3 TABLESPACE_QUOTA objects in 0 seconds
    29-MAY-24 13:31:26.542: W-1 Processing object type DATABASE_EXPORT/RESOURCE_COST
    29-MAY-24 13:31:26.546: W-1      Completed 1 RESOURCE_COST objects in 0 seconds
    29-MAY-24 13:31:26.609: W-1 Processing object type DATABASE_EXPORT/TRUSTED_DB_LINK
    29-MAY-24 13:31:26.612: W-1      Completed 1 TRUSTED_DB_LINK objects in 0 seconds
    29-MAY-24 13:31:26.670: W-1 Processing object type DATABASE_EXPORT/DIRECTORY/DIRECTORY
    29-MAY-24 13:31:26.674: W-1      Completed 2 DIRECTORY objects in 0 seconds
    29-MAY-24 13:31:26.869: W-1 Processing object type DATABASE_EXPORT/DIRECTORY/GRANT/OWNER_GRANT/OBJECT_GRANT
    29-MAY-24 13:31:26.874: W-1      Completed 4 OBJECT_GRANT objects in 0 seconds
    29-MAY-24 13:31:27.438: W-1 Processing object type DATABASE_EXPORT/SCHEMA/PUBLIC_SYNONYM/SYNONYM
    29-MAY-24 13:31:27.442: W-1      Completed 1 SYNONYM objects in 0 seconds
    29-MAY-24 13:31:27.950: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/PRE_SYSTEM_ACTIONS/PROCACT_SYSTEM
    29-MAY-24 13:31:28.023: W-1      Completed 2 PROCACT_SYSTEM objects in 1 seconds
    29-MAY-24 13:31:28.188: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/PROCOBJ
    29-MAY-24 13:31:28.196: W-1      Completed 24 PROCOBJ objects in 0 seconds
    29-MAY-24 13:31:28.398: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/POST_SYSTEM_ACTIONS/PROCACT_SYSTEM
    29-MAY-24 13:31:28.638: W-1      Completed 4 PROCACT_SYSTEM objects in 0 seconds
    29-MAY-24 13:31:29.129: W-1 Processing object type DATABASE_EXPORT/SCHEMA/PROCACT_SCHEMA
    29-MAY-24 13:31:29.131: W-1      Completed 5 PROCACT_SCHEMA objects in 1 seconds
    29-MAY-24 13:31:33.453: W-1 Processing object type DATABASE_EXPORT/EARLY_OPTIONS/VIEWS_AS_TABLES/TABLE
    29-MAY-24 13:31:33.505: W-1      Completed 1 TABLE objects in 3 seconds
    29-MAY-24 13:31:33.541: W-1 Processing object type DATABASE_EXPORT/EARLY_POST_INSTANCE_IMPCALLOUT/MARKER
    29-MAY-24 13:31:33.545: W-1      Completed 1 MARKER objects in 0 seconds
    29-MAY-24 13:31:34.540: W-2 . . exported "SYSTEM"."SCHEDULER_PROGRAM_ARGS"           9.507 KB      12 rows in 10 seconds using external_table
    29-MAY-24 13:31:34.698: W-2 . . exported "SYSTEM"."TRACKING_TAB"                     5.507 KB       1 rows in 0 seconds using direct_path
    29-MAY-24 13:31:44.793: W-1 Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/TABLE
    29-MAY-24 13:31:57.880: W-1      Completed 17 TABLE objects in 24 seconds
    29-MAY-24 13:32:00.394: W-1 Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/VIEWS_AS_TABLES/TABLE
    29-MAY-24 13:32:10.424: W-1      Completed 15 TABLE objects in 12 seconds
    29-MAY-24 13:32:10.507: W-1 Processing object type DATABASE_EXPORT/NORMAL_POST_INSTANCE_IMPCALLOUT/MARKER
    29-MAY-24 13:32:10.508: W-1      Completed 1 MARKER objects in 0 seconds
    29-MAY-24 13:32:11.709: W-1 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/TABLE
    29-MAY-24 13:32:20.212: W-1      Completed 15 TABLE objects in 10 seconds
    29-MAY-24 13:32:20.893: W-1 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/COMMENT
    29-MAY-24 13:32:22.477: W-1 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/INDEX/INDEX
    29-MAY-24 13:32:23.307: W-1 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/CONSTRAINT/CONSTRAINT
    29-MAY-24 13:32:23.320: W-1      Completed 22 CONSTRAINT objects in 1 seconds
    29-MAY-24 13:32:24.496: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER
    29-MAY-24 13:32:24.498: W-1      Completed 1 MARKER objects in 0 seconds
    29-MAY-24 13:32:27.195: W-1 Processing object type DATABASE_EXPORT/AUDIT
    29-MAY-24 13:32:27.198: W-1      Completed 31 AUDIT objects in 0 seconds
    29-MAY-24 13:32:27.258: W-1 Processing object type DATABASE_EXPORT/POST_SYSTEM_IMPCALLOUT/MARKER
    29-MAY-24 13:32:27.260: W-1      Completed 1 MARKER objects in 0 seconds
    29-MAY-24 13:32:28.234: W-2      Completed 1 DATABASE_EXPORT/EARLY_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA objects in 2 seconds
    29-MAY-24 13:32:28.236: W-2      Completed 17 DATABASE_EXPORT/NORMAL_OPTIONS/TABLE_DATA objects in 0 seconds
    29-MAY-24 13:32:28.238: W-2      Completed 15 DATABASE_EXPORT/NORMAL_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA objects in 12 seconds
    29-MAY-24 13:32:28.240: W-2      Completed 1 DATABASE_EXPORT/SCHEMA/TABLE/TABLE_DATA objects in 0 seconds
    29-MAY-24 13:32:29.356: W-2 Master table "FTEXUSER"."SYS_EXPORT_FULL_01" successfully loaded/unloaded
    29-MAY-24 13:32:29.360: ******************************************************************************
    29-MAY-24 13:32:29.360: Dump file set for FTEXUSER.SYS_EXPORT_FULL_01 is:
    29-MAY-24 13:32:29.361:   /home/oracle/logs/migrate-using-ftex/ftex_exp_01.dmp
    29-MAY-24 13:32:29.362:   /home/oracle/logs/migrate-using-ftex/ftex_exp_02.dmp
    29-MAY-24 13:32:29.362: ******************************************************************************
    29-MAY-24 13:32:29.363: Datafiles required for transportable tablespace USERS:
    29-MAY-24 13:32:29.366:   /u02/oradata/FTEX/users01.dbf
    29-MAY-24 13:32:29.389: Job "FTEXUSER"."SYS_EXPORT_FULL_01" successfully completed at Wed May 29 13:32:29 2024 elapsed 0 00:01:18
    ```
    </details>

## Task 2: Create new PDB

You create a new, empty PDB in Oracle Database 23ai and import directly into it. This avoids the in-place upgrade and PDB conversion.

1. Set the environment to the target database, *CDB23*, and connect.
    ```
    <copy>
    . cdb23
    sqlplus / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

3. Create a new PDB called *MAROON* and open it.

    ```
    <copy>
    create pluggable database maroon admin user admin identified by admin;
    alter pluggable database maroon open;
    alter pluggable database maroon save state;
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> create pluggable database MAROON admin user admin identified by admin;

    Pluggable database created.

    SQL> alter pluggable database maroon open;

    Pluggable database altered.

    SQL>alter pluggable database maroon save state;

    Pluggable database altered.
    ```
    </details>


## Task 3: Data Pump import

You need a few more changes to the new PDB before you can start the import.

1. Create a database directory object that points to the same operating system directory that you created in the previous task. In this lab, the export and import share the same directory. This enables Data Pump to find the dump files. If you import on a remote system, you must copy the dump files.

    ```
    <copy>
    alter session set container=maroon;
    create directory ftexdir as '/home/oracle/logs/migrate-using-ftex';
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> create directory ftexdir as '/home/oracle/logs/migrate-using-ftex';

    Directory created.
    ```
    </details>

2. Create a dedicated user for the Data Pump import.

    ```
    <copy>
    create user ftexuser identified by ftexuser default tablespace system;
    grant imp_full_database to ftexuser;
    grant read, write on directory ftexdir to ftexuser;
    alter user ftexuser quota unlimited on system;
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> create user ftexuser identified by ftexuser default tablespace system;

    User created.

    SQL> grant imp_full_database to ftexuser;

    Grant succeeded.

    SQL> grant read, write on directory ftexdir to ftexuser;

    Grant succeeded.

    SQL> alter user ftexuser quota unlimited on system;

    User altered.
    ```
    </details>

3. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```

4. Make a directory for *MAROON* data files. Copy the data files from the source database to this directory.

    ```
    <copy>
    mkdir -p /u01/app/oracle/oradata/CDB23/MAROON
    cp /u02/oradata/FTEX/datafile/o1_mf_users_*.dbf /u01/app/oracle/oradata/CDB23/MAROON/users01.dbf
    </copy>

    -- Be sure to hit RETURN
    ```

5. Examine the precreated Data Pump import parameter file.

    ```
    <copy>
    cat /home/oracle/scripts/migrate-using-ftex-imp.par
    </copy>
    ```

    * `parallel` makes the import potentially much faster. Data Pump supports parallel transportable jobs from Oracle Database 21c. This means, we can use it for import, but not for export.
    * `metrics` and `logtime` puts additional diagnostic information into the Data Pump log file.
    * Certain tablespaces are excluded using `exclude=tablespace` because the PDB already have a TEMP and UNDO tablespace.
    * The *FTEXUSER* is excluded using `exclude=user` because we created it for the import already.
    * `transport_datafiles` lists all the data files from the transportable set.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    directory=ftexdir
    logfile=ftex_imp.log
    dumpfile=ftex_exp_%L.dmp
    parallel=4
    metrics=yes
    logtime=all
    exclude=tablespace:"in ('TEMP', 'UNDOTBS100')"
    exclude=user:"in ('FTEXUSER')"
    transport_datafiles=/u01/app/oracle/oradata/CDB23/MAROON/users01.dbf
    ```
    </details>

6. Start the Data Pump import.

    ```
    <copy>
    impdp ftexuser/ftexuser@localhost/maroon parfile=/home/oracle/scripts/migrate-using-ftex-imp.par
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    Import: Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems on Wed May 29 14:01:10 2024
    Version 23.5.0.24.07

    Copyright (c) 1982, 2024, Oracle and/or its affiliates.  All rights reserved.

    Connected to: Oracle Database 23ai Enterprise Edition Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems
    29-MAY-24 14:01:13.959: W-1 Startup on instance 1 took 0 seconds
    29-MAY-24 14:01:15.408: W-1 Master table "FTEXUSER"."SYS_IMPORT_TRANSPORTABLE_01" successfully loaded/unloaded
    29-MAY-24 14:01:15.943: W-1 Source time zone is +02:00 and target time zone is +00:00.
    29-MAY-24 14:01:15.946: Starting "FTEXUSER"."SYS_IMPORT_TRANSPORTABLE_01":  ftexuser/********@localhost/maroon parfile=/home/oracle/scripts/migrate-using-ftex-imp.par
    29-MAY-24 14:01:16.037: W-1 Processing object type DATABASE_EXPORT/PRE_SYSTEM_IMPCALLOUT/MARKER/SCHEDULER
    29-MAY-24 14:01:16.066: W-1      Completed 1 SCHEDULER objects in 0 seconds
    29-MAY-24 14:01:16.069: W-1 Processing object type DATABASE_EXPORT/PRE_SYSTEM_IMPCALLOUT/MARKER/WMSYS
    29-MAY-24 14:01:16.437: W-1      Completed 1 WMSYS objects in 0 seconds
    29-MAY-24 14:01:16.439: W-1 Processing object type DATABASE_EXPORT/PRE_SYSTEM_IMPCALLOUT/MARKER/DATAPUMP
    29-MAY-24 14:01:16.475: W-1      Completed 1 DATAPUMP objects in 0 seconds
    29-MAY-24 14:01:16.516: W-1      Completed 1 [internal] PRE_SYSTEM objects in 1 seconds
    29-MAY-24 14:01:16.516: W-1      Completed by worker 1 1 MARKER objects in 0 seconds
    29-MAY-24 14:01:16.533: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER/AUDIT_TRAILS
    29-MAY-24 14:01:16.647: W-1      Completed 10 AUDIT_TRAILS objects in 0 seconds
    29-MAY-24 14:01:16.650: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER/DATAPUMP
    29-MAY-24 14:01:16.654: W-1      Completed 1 DATAPUMP objects in 0 seconds
    29-MAY-24 14:01:16.656: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER/NETWORK_ACL
    29-MAY-24 14:01:16.682: W-1      Completed 3 NETWORK_ACL objects in 0 seconds
    29-MAY-24 14:01:16.685: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER/PSTDY
    29-MAY-24 14:01:16.697: W-1      Completed 2 PSTDY objects in 0 seconds
    29-MAY-24 14:01:16.699: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER/SCHEDULER
    29-MAY-24 14:01:16.723: W-1      Completed 2 SCHEDULER objects in 0 seconds
    29-MAY-24 14:01:16.726: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER/SMB
    29-MAY-24 14:01:16.766: W-1      Completed 6 SMB objects in 0 seconds
    29-MAY-24 14:01:16.769: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER/SQL_FIREWALL
    29-MAY-24 14:01:16.772: W-1      Completed 5 SQL_FIREWALL objects in 0 seconds
    29-MAY-24 14:01:16.775: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER/TSDP
    29-MAY-24 14:01:16.841: W-1      Completed 12 TSDP objects in 0 seconds
    29-MAY-24 14:01:16.853: W-1      Completed 1 [internal] PRE_INSTANCE objects in 0 seconds
    29-MAY-24 14:01:16.853: W-1      Completed by worker 1 1 MARKER objects in 0 seconds
    29-MAY-24 14:01:16.856: W-1 Processing object type DATABASE_EXPORT/PLUGTS_FULL/PLUGTS_BLK
    29-MAY-24 14:01:17.025: W-1      Completed 1 PLUGTS_BLK objects in 1 seconds
    29-MAY-24 14:01:17.025: W-1      Completed by worker 1 1 PLUGTS_BLK objects in 1 seconds
    29-MAY-24 14:01:17.027: W-1 Processing object type DATABASE_EXPORT/PROFILE
    29-MAY-24 14:01:17.078: W-1      Completed 1 PROFILE objects in 0 seconds
    29-MAY-24 14:01:17.078: W-1      Completed by worker 1 1 PROFILE objects in 0 seconds
    29-MAY-24 14:01:17.080: W-1 Processing object type DATABASE_EXPORT/SCHEMA/USER
    29-MAY-24 14:01:17.136: W-1      Completed 1 USER objects in 0 seconds
    29-MAY-24 14:01:17.136: W-1      Completed by worker 1 1 USER objects in 0 seconds
    29-MAY-24 14:01:17.138: W-1 Processing object type DATABASE_EXPORT/ROLE
    29-MAY-24 14:01:17.197: W-1      Completed 1 ROLE objects in 0 seconds
    29-MAY-24 14:01:17.197: W-1      Completed by worker 1 1 ROLE objects in 0 seconds
    29-MAY-24 14:01:17.199: W-1 Processing object type DATABASE_EXPORT/RADM_FPTM
    29-MAY-24 14:01:17.250: W-1      Completed 1 RADM_FPTM objects in 0 seconds
    29-MAY-24 14:01:17.250: W-1      Completed by worker 1 1 RADM_FPTM objects in 0 seconds
    29-MAY-24 14:01:17.269: W-1 Processing object type DATABASE_EXPORT/GRANT/SYSTEM_GRANT/PROC_SYSTEM_GRANT/AQ
    29-MAY-24 14:01:17.318: W-1      Completed 1 AQ objects in 0 seconds
    29-MAY-24 14:01:17.320: W-1 Processing object type DATABASE_EXPORT/GRANT/SYSTEM_GRANT/PROC_SYSTEM_GRANT/RULE
    29-MAY-24 14:01:17.323: W-1      Completed 1 RULE objects in 0 seconds
    29-MAY-24 14:01:17.325: W-1 Processing object type DATABASE_EXPORT/GRANT/SYSTEM_GRANT/PROC_SYSTEM_GRANT/RMGR
    29-MAY-24 14:01:17.347: ORA-39083: Object type RMGR:PROC_SYSTEM_GRANT failed to create with error:
    ORA-29393: user EM_EXPRESS_ALL does not exist or is not logged on

    29-MAY-24 14:01:17.352: W-1      Completed 1 RMGR objects in 0 seconds
    29-MAY-24 14:01:17.354: W-1 Processing object type DATABASE_EXPORT/GRANT/SYSTEM_GRANT/PROC_SYSTEM_GRANT/SQL
    29-MAY-24 14:01:17.375: W-1      Completed 1 SQL objects in 0 seconds
    29-MAY-24 14:01:17.377: W-1 Processing object type DATABASE_EXPORT/GRANT/SYSTEM_GRANT/PROC_SYSTEM_GRANT/RULE
    29-MAY-24 14:01:17.383: W-1      Completed 2 RULE objects in 0 seconds
    29-MAY-24 14:01:17.392: W-1 Processing object type DATABASE_EXPORT/SCHEMA/GRANT/SYSTEM_GRANT
    29-MAY-24 14:01:17.545: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'DATAPATCH_ROLE' does not exist

    Failing sql is:
    GRANT ALTER SESSION TO "DATAPATCH_ROLE"

    29-MAY-24 14:01:17.545: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_BASIC' does not exist

    Failing sql is:
    GRANT CREATE SESSION TO "EM_EXPRESS_BASIC"

    29-MAY-24 14:01:17.545: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-00990: missing or invalid privilege

    Failing sql is:
    GRANT EM EXPRESS CONNECT TO "EM_EXPRESS_BASIC"

    29-MAY-24 14:01:17.545: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist

    Failing sql is:
    GRANT ADVISOR TO "EM_EXPRESS_ALL"

    29-MAY-24 14:01:17.545: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist

    Failing sql is:
    GRANT CREATE JOB TO "EM_EXPRESS_ALL"

    29-MAY-24 14:01:17.545: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist

    Failing sql is:
    GRANT ADMINISTER SQL TUNING SET TO "EM_EXPRESS_ALL"

    29-MAY-24 14:01:17.545: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist

    Failing sql is:
    GRANT ADMINISTER ANY SQL TUNING SET TO "EM_EXPRESS_ALL"

    29-MAY-24 14:01:17.545: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist

    Failing sql is:
    GRANT ADMINISTER SQL MANAGEMENT OBJECT TO "EM_EXPRESS_ALL"

    29-MAY-24 14:01:17.545: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist

    Failing sql is:
    GRANT ALTER SYSTEM TO "EM_EXPRESS_ALL"

    29-MAY-24 14:01:17.545: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist

    Failing sql is:
    GRANT CREATE TABLESPACE TO "EM_EXPRESS_ALL"

    29-MAY-24 14:01:17.545: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist

    Failing sql is:
    GRANT DROP TABLESPACE TO "EM_EXPRESS_ALL"

    29-MAY-24 14:01:17.545: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist

    Failing sql is:
    GRANT ALTER TABLESPACE TO "EM_EXPRESS_ALL"

    29-MAY-24 14:01:17.545: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist

    Failing sql is:
    GRANT GRANT ANY OBJECT PRIVILEGE TO "EM_EXPRESS_ALL"

    29-MAY-24 14:01:17.545: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist

    Failing sql is:
    GRANT GRANT ANY PRIVILEGE TO "EM_EXPRESS_ALL"

    29-MAY-24 14:01:17.545: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist

    Failing sql is:
    GRANT GRANT ANY ROLE TO "EM_EXPRESS_ALL"

    29-MAY-24 14:01:17.545: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist

    Failing sql is:
    GRANT CREATE ROLE TO "EM_EXPRESS_ALL"

    29-MAY-24 14:01:17.545: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist

    Failing sql is:
    GRANT DROP ANY ROLE TO "EM_EXPRESS_ALL"

    29-MAY-24 14:01:17.545: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist

    Failing sql is:
    GRANT ALTER ANY ROLE TO "EM_EXPRESS_ALL"

    29-MAY-24 14:01:17.545: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist

    Failing sql is:
    GRANT CREATE USER TO "EM_EXPRESS_ALL"

    29-MAY-24 14:01:17.545: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist

    Failing sql is:
    GRANT DROP USER TO "EM_EXPRESS_ALL"

    29-MAY-24 14:01:17.545: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist

    Failing sql is:
    GRANT ALTER USER TO "EM_EXPRESS_ALL"

    29-MAY-24 14:01:17.545: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist

    Failing sql is:
    GRANT CREATE PROFILE TO "EM_EXPRESS_ALL"

    29-MAY-24 14:01:17.545: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist

    Failing sql is:
    GRANT ALTER PROFILE TO "EM_EXPRESS_ALL"

    29-MAY-24 14:01:17.545: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist

    Failing sql is:
    GRANT DROP PROFILE TO "EM_EXPRESS_ALL"

    29-MAY-24 14:01:17.545: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist

    Failing sql is:
    GRANT SET CONTAINER TO "EM_EXPRESS_ALL"

    29-MAY-24 14:01:17.545: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist

    Failing sql is:
    GRANT CREATE CREDENTIAL TO "EM_EXPRESS_ALL"

    29-MAY-24 14:01:17.555: W-1      Completed 74 SYSTEM_GRANT objects in 0 seconds
    29-MAY-24 14:01:17.555: W-1      Completed by worker 1 74 SYSTEM_GRANT objects in 0 seconds
    29-MAY-24 14:01:17.566: W-1 Processing object type DATABASE_EXPORT/SCHEMA/ROLE_GRANT
    29-MAY-24 14:01:17.701: ORA-39083: Object type ROLE_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_BASIC' does not exist

    Failing sql is:
     GRANT "SELECT_CATALOG_ROLE" TO "EM_EXPRESS_BASIC"

    29-MAY-24 14:01:17.701: ORA-39083: Object type ROLE_GRANT failed to create with error:
    ORA-01919: Role 'EM_EXPRESS_ALL' does not exist.

    Failing sql is:
     GRANT "EM_EXPRESS_ALL" TO "DBA"

    29-MAY-24 14:01:17.701: ORA-39083: Object type ROLE_GRANT failed to create with error:
    ORA-01919: Role 'EM_EXPRESS_BASIC' does not exist.

    Failing sql is:
     GRANT "EM_EXPRESS_BASIC" TO "EM_EXPRESS_ALL"

    29-MAY-24 14:01:17.710: W-1      Completed 41 ROLE_GRANT objects in 0 seconds
    29-MAY-24 14:01:17.710: W-1      Completed by worker 1 41 ROLE_GRANT objects in 0 seconds
    29-MAY-24 14:01:17.713: W-1 Processing object type DATABASE_EXPORT/SCHEMA/DEFAULT_ROLE
    29-MAY-24 14:01:17.757: W-1      Completed 4 DEFAULT_ROLE objects in 0 seconds
    29-MAY-24 14:01:17.757: W-1      Completed by worker 1 4 DEFAULT_ROLE objects in 0 seconds
    29-MAY-24 14:01:17.760: W-1 Processing object type DATABASE_EXPORT/SCHEMA/ON_USER_GRANT
    29-MAY-24 14:01:17.820: ORA-39083: Object type ON_USER_GRANT failed to create with error:
    ORA-31625: Schema AUDSYS is needed to import this object, but is unaccessible
    ORA-01031: insufficient privileges

    Failing sql is:
     GRANT INHERIT PRIVILEGES ON USER "AUDSYS" TO "PUBLIC"

    29-MAY-24 14:01:17.820: ORA-39083: Object type ON_USER_GRANT failed to create with error:
    ORA-31625: Schema ORACLE_OCM is needed to import this object, but is unaccessible
    ORA-01435: user does not exist

    Failing sql is:
     GRANT INHERIT PRIVILEGES ON USER "ORACLE_OCM" TO "PUBLIC"

    29-MAY-24 14:01:17.829: W-1      Completed 18 ON_USER_GRANT objects in 0 seconds
    29-MAY-24 14:01:17.829: W-1      Completed by worker 1 18 ON_USER_GRANT objects in 0 seconds
    29-MAY-24 14:01:17.832: W-1 Processing object type DATABASE_EXPORT/SCHEMA/TABLESPACE_QUOTA
    29-MAY-24 14:01:17.880: W-1      Completed 3 TABLESPACE_QUOTA objects in 0 seconds
    29-MAY-24 14:01:17.880: W-1      Completed by worker 1 3 TABLESPACE_QUOTA objects in 0 seconds
    29-MAY-24 14:01:17.883: W-1 Processing object type DATABASE_EXPORT/RESOURCE_COST
    29-MAY-24 14:01:17.923: W-1      Completed 1 RESOURCE_COST objects in 0 seconds
    29-MAY-24 14:01:17.923: W-1      Completed by worker 1 1 RESOURCE_COST objects in 0 seconds
    29-MAY-24 14:01:17.925: W-1 Processing object type DATABASE_EXPORT/TRUSTED_DB_LINK
    29-MAY-24 14:01:17.966: W-1      Completed 1 TRUSTED_DB_LINK objects in 0 seconds
    29-MAY-24 14:01:17.966: W-1      Completed by worker 1 1 TRUSTED_DB_LINK objects in 0 seconds
    29-MAY-24 14:01:17.969: W-1 Processing object type DATABASE_EXPORT/DIRECTORY/DIRECTORY
    29-MAY-24 14:01:18.010: ORA-31684: Object type DIRECTORY:"FTEXDIR" already exists

    29-MAY-24 14:01:18.020: W-1      Completed 2 DIRECTORY objects in 1 seconds
    29-MAY-24 14:01:18.020: W-1      Completed by worker 1 2 DIRECTORY objects in 1 seconds
    29-MAY-24 14:01:18.023: W-1 Processing object type DATABASE_EXPORT/DIRECTORY/GRANT/OWNER_GRANT/OBJECT_GRANT
    29-MAY-24 14:01:18.073: W-1      Completed 4 OBJECT_GRANT objects in 0 seconds
    29-MAY-24 14:01:18.073: W-1      Completed by worker 1 4 OBJECT_GRANT objects in 0 seconds
    29-MAY-24 14:01:18.075: W-1 Processing object type DATABASE_EXPORT/SCHEMA/PUBLIC_SYNONYM/SYNONYM
    29-MAY-24 14:01:18.123: W-1      Completed 1 SYNONYM objects in 0 seconds
    29-MAY-24 14:01:18.123: W-1      Completed by worker 1 1 SYNONYM objects in 0 seconds
    29-MAY-24 14:01:18.142: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/PRE_SYSTEM_ACTIONS/PROCACT_SYSTEM/LOGREP
    29-MAY-24 14:01:18.181: W-1      Completed 1 LOGREP objects in 0 seconds
    29-MAY-24 14:01:18.183: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/PRE_SYSTEM_ACTIONS/PROCACT_SYSTEM/RMGR
    29-MAY-24 14:01:18.217: W-1      Completed 1 RMGR objects in 0 seconds
    29-MAY-24 14:01:18.244: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/PROCOBJ/RMGR
    29-MAY-24 14:01:18.271: W-1      Completed 7 RMGR objects in 0 seconds
    29-MAY-24 14:01:18.273: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/PROCOBJ/SCHEDULER
    29-MAY-24 14:01:18.470: W-1      Completed 17 SCHEDULER objects in 0 seconds
    29-MAY-24 14:01:18.497: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/POST_SYSTEM_ACTIONS/PROCACT_SYSTEM/RMGR
    29-MAY-24 14:01:18.614: W-1      Completed 1 RMGR objects in 0 seconds
    29-MAY-24 14:01:18.618: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/POST_SYSTEM_ACTIONS/PROCACT_SYSTEM/SERVERM
    29-MAY-24 14:01:18.675: W-1      Completed 1 SERVERM objects in 0 seconds
    29-MAY-24 14:01:18.678: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/POST_SYSTEM_ACTIONS/PROCACT_SYSTEM/SRVR
    29-MAY-24 14:01:18.765: W-1      Completed 1 SRVR objects in 0 seconds
    29-MAY-24 14:01:18.767: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/POST_SYSTEM_ACTIONS/PROCACT_SYSTEM/SEC
    29-MAY-24 14:01:18.830: W-1      Completed 1 SEC objects in 0 seconds
    29-MAY-24 14:01:18.857: W-1 Processing object type DATABASE_EXPORT/SCHEMA/PROCACT_SCHEMA/LOGREP
    29-MAY-24 14:01:18.875: W-1      Completed 5 LOGREP objects in 0 seconds
    29-MAY-24 14:01:18.884: W-1 Processing object type DATABASE_EXPORT/EARLY_OPTIONS/VIEWS_AS_TABLES/TABLE
    29-MAY-24 14:01:19.580: W-1      Completed 1 TABLE objects in 1 seconds
    29-MAY-24 14:01:19.580: W-1      Completed by worker 1 1 TABLE objects in 1 seconds
    29-MAY-24 14:01:19.606: W-1 Processing object type DATABASE_EXPORT/EARLY_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA
    29-MAY-24 14:01:20.421: W-1 . . imported "SYS"."KU$_EXPORT_USER_MAP"                   5.9 KB      24 rows in 1 seconds using direct_path
    29-MAY-24 14:01:20.442: W-1 Processing object type DATABASE_EXPORT/EARLY_POST_INSTANCE_IMPCALLOUT/MARKER/DATAPUMP
    29-MAY-24 14:01:20.471: W-1      Completed 1 DATAPUMP objects in 0 seconds
    29-MAY-24 14:01:20.481: W-1      Completed 1 [internal] EARLY_POST_INSTANCE objects in 0 seconds
    29-MAY-24 14:01:20.481: W-1      Completed by worker 1 1 MARKER objects in 0 seconds
    29-MAY-24 14:01:20.484: W-1 Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/TABLE
    29-MAY-24 14:01:21.290: W-2 Source time zone is +02:00 and target time zone is +00:00.
    29-MAY-24 14:01:21.290: W-2 Startup on instance 1 took 1 seconds
    29-MAY-24 14:01:21.293: W-4 Source time zone is +02:00 and target time zone is +00:00.
    29-MAY-24 14:01:21.293: W-4 Startup on instance 1 took 1 seconds
    29-MAY-24 14:01:21.296: W-3 Source time zone is +02:00 and target time zone is +00:00.
    29-MAY-24 14:01:21.296: W-3 Startup on instance 1 took 1 seconds
    29-MAY-24 14:01:21.800: W-4      Completed 17 TABLE objects in 1 seconds
    29-MAY-24 14:01:21.800: W-4      Completed by worker 1 8 TABLE objects in 1 seconds
    29-MAY-24 14:01:21.800: W-4      Completed by worker 2 4 TABLE objects in 0 seconds
    29-MAY-24 14:01:21.800: W-4      Completed by worker 3 5 TABLE objects in 0 seconds
    29-MAY-24 14:01:21.810: W-1 Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/TABLE_DATA
    29-MAY-24 14:01:21.905: W-2 . . imported "SYS"."AMGT$DP$DAM_CONFIG_PARAM$"             6.5 KB      14 rows in 0 seconds using direct_path
    29-MAY-24 14:01:21.933: W-2 . . imported "SYS"."DP$TSDP_SUBPOL$"                       6.3 KB       1 rows in 0 seconds using direct_path
    29-MAY-24 14:01:21.960: W-2 . . imported "SYS"."DP$TSDP_PARAMETER$"                      6 KB       1 rows in 0 seconds using direct_path
    29-MAY-24 14:01:21.988: W-2 . . imported "SYS"."DP$TSDP_POLICY$"                       5.9 KB       1 rows in 0 seconds using direct_path
    29-MAY-24 14:01:21.993: W-2 . . imported "AUDSYS"."AMGT$DP$AUD$UNIFIED":"AUD_UNIFIED_P0"     51 KB       0 rows in 0 seconds using direct_path
    29-MAY-24 14:01:21.996: W-2 . . imported "SYS"."AMGT$DP$AUD$"                         23.5 KB       0 rows in 0 seconds using direct_path
    29-MAY-24 14:01:21.998: W-2 . . imported "SYS"."AMGT$DP$DAM_CLEANUP_EVENTS$"           7.2 KB       0 rows in 0 seconds using direct_path
    29-MAY-24 14:01:22.000: W-2 . . imported "SYS"."AMGT$DP$DAM_CLEANUP_JOBS$"             7.2 KB       0 rows in 0 seconds using direct_path
    29-MAY-24 14:01:22.003: W-2 . . imported "SYS"."DP$TSDP_ASSOCIATION$"                    0 KB       0 rows in 0 seconds using direct_path
    29-MAY-24 14:01:22.005: W-2 . . imported "SYS"."DP$TSDP_CONDITION$"                      0 KB       0 rows in 0 seconds using direct_path
    29-MAY-24 14:01:22.008: W-2 . . imported "SYS"."DP$TSDP_FEATURE_POLICY$"                 0 KB       0 rows in 0 seconds using direct_path
    29-MAY-24 14:01:22.010: W-2 . . imported "SYS"."DP$TSDP_PROTECTION$"                     0 KB       0 rows in 0 seconds using direct_path
    29-MAY-24 14:01:22.012: W-2 . . imported "SYS"."DP$TSDP_SENSITIVE_DATA$"                 0 KB       0 rows in 0 seconds using direct_path
    29-MAY-24 14:01:22.015: W-2 . . imported "SYS"."DP$TSDP_SENSITIVE_TYPE$"                 0 KB       0 rows in 0 seconds using direct_path
    29-MAY-24 14:01:22.017: W-2 . . imported "SYS"."DP$TSDP_SOURCE$"                         0 KB       0 rows in 0 seconds using direct_path
    29-MAY-24 14:01:22.019: W-2 . . imported "SYSTEM"."REDO_DB_TMP"                          0 KB       0 rows in 0 seconds using direct_path
    29-MAY-24 14:01:22.021: W-2 . . imported "SYSTEM"."REDO_LOG_TMP"                         0 KB       0 rows in 0 seconds using direct_path
    29-MAY-24 14:01:22.031: W-3 Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/VIEWS_AS_TABLES/TABLE
    29-MAY-24 14:01:22.537: W-2      Completed 13 TABLE objects in 0 seconds
    29-MAY-24 14:01:22.537: W-2      Completed by worker 1 3 TABLE objects in 0 seconds
    29-MAY-24 14:01:22.537: W-2      Completed by worker 2 1 TABLE objects in 0 seconds
    29-MAY-24 14:01:22.537: W-2      Completed by worker 3 6 TABLE objects in 0 seconds
    29-MAY-24 14:01:22.537: W-2      Completed by worker 4 3 TABLE objects in 0 seconds
    29-MAY-24 14:01:22.546: W-1 Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA
    29-MAY-24 14:01:22.594: W-4 . . imported "SYS"."AMGT$DP$AUDTAB$TBS$FOR_EXPORT"           6 KB       2 rows in 0 seconds using direct_path
    29-MAY-24 14:01:22.597: W-4 . . imported "SYS"."DP$DBA_SENSITIVE_DATA"                   0 KB       0 rows in 0 seconds using direct_path
    29-MAY-24 14:01:22.599: W-4 . . imported "SYS"."DP$DBA_TSDP_POLICY_PROTECTION"           0 KB       0 rows in 0 seconds using direct_path
    29-MAY-24 14:01:22.601: W-4 . . imported "SYS"."AMGT$DP$FGA_LOG$FOR_EXPORT"              0 KB       0 rows in 0 seconds using direct_path
    29-MAY-24 14:01:22.603: W-4 . . imported "SYS"."NACL$_ACE_IMP"                           0 KB       0 rows in 0 seconds using direct_path
    29-MAY-24 14:01:22.630: W-4 . . imported "SYS"."NACL$_HOST_IMP"                        6.9 KB       1 rows in 0 seconds using direct_path
    29-MAY-24 14:01:22.633: W-4 . . imported "SYS"."NACL$_WALLET_IMP"                        0 KB       0 rows in 0 seconds using direct_path
    29-MAY-24 14:01:22.637: W-4 . . imported "SYS"."DATAPUMP$SQL$TEXT"                       0 KB       0 rows in 0 seconds using direct_path
    29-MAY-24 14:01:22.640: W-4 . . imported "SYS"."DATAPUMP$SQL$"                           0 KB       0 rows in 0 seconds using direct_path
    29-MAY-24 14:01:22.643: W-4 . . imported "SYS"."DATAPUMP$SQLOBJ$AUXDATA"                 0 KB       0 rows in 0 seconds using direct_path
    29-MAY-24 14:01:22.646: W-4 . . imported "SYS"."DATAPUMP$SQLOBJ$DATA"                    0 KB       0 rows in 0 seconds using direct_path
    29-MAY-24 14:01:22.649: W-4 . . imported "SYS"."DATAPUMP$SQLOBJ$PLAN"                    0 KB       0 rows in 0 seconds using direct_path
    29-MAY-24 14:01:22.652: W-4 . . imported "SYS"."DATAPUMP$SQLOBJ$"                        0 KB       0 rows in 0 seconds using direct_path
    29-MAY-24 14:01:22.674: W-1 Processing object type DATABASE_EXPORT/NORMAL_POST_INSTANCE_IMPCALLOUT/MARKER/AUDIT_TRAILS
    29-MAY-24 14:01:22.995: W-1      Completed 10 AUDIT_TRAILS objects in 0 seconds
    29-MAY-24 14:01:22.998: W-1 Processing object type DATABASE_EXPORT/NORMAL_POST_INSTANCE_IMPCALLOUT/MARKER/NETWORK_ACL
    29-MAY-24 14:01:23.014: W-1      Completed 3 NETWORK_ACL objects in 1 seconds
    29-MAY-24 14:01:23.017: W-1 Processing object type DATABASE_EXPORT/NORMAL_POST_INSTANCE_IMPCALLOUT/MARKER/PSTDY
    29-MAY-24 14:01:23.063: W-1      Completed 2 PSTDY objects in 0 seconds
    29-MAY-24 14:01:23.066: W-1 Processing object type DATABASE_EXPORT/NORMAL_POST_INSTANCE_IMPCALLOUT/MARKER/SCHEDULER
    29-MAY-24 14:01:23.069: W-1      Completed 2 SCHEDULER objects in 0 seconds
    29-MAY-24 14:01:23.072: W-1 Processing object type DATABASE_EXPORT/NORMAL_POST_INSTANCE_IMPCALLOUT/MARKER/SMB
    29-MAY-24 14:01:23.101: W-1      Completed 6 SMB objects in 0 seconds
    29-MAY-24 14:01:23.104: W-1 Processing object type DATABASE_EXPORT/NORMAL_POST_INSTANCE_IMPCALLOUT/MARKER/SQL_FIREWALL
    29-MAY-24 14:01:23.107: W-1      Completed 5 SQL_FIREWALL objects in 0 seconds
    29-MAY-24 14:01:23.109: W-1 Processing object type DATABASE_EXPORT/NORMAL_POST_INSTANCE_IMPCALLOUT/MARKER/TSDP
    29-MAY-24 14:01:23.198: W-1      Completed 12 TSDP objects in 0 seconds
    29-MAY-24 14:01:23.255: W-2      Completed 1 [internal] Unknown objects in 1 seconds
    29-MAY-24 14:01:23.255: W-2      Completed by worker 1 1 MARKER objects in 1 seconds
    29-MAY-24 14:01:23.258: W-2 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/TABLE
    29-MAY-24 14:01:23.653: W-4      Completed 15 TABLE objects in 0 seconds
    29-MAY-24 14:01:23.653: W-4      Completed by worker 1 3 TABLE objects in 0 seconds
    29-MAY-24 14:01:23.653: W-4      Completed by worker 2 6 TABLE objects in 0 seconds
    29-MAY-24 14:01:23.653: W-4      Completed by worker 3 3 TABLE objects in 0 seconds
    29-MAY-24 14:01:23.653: W-4      Completed by worker 4 3 TABLE objects in 0 seconds
    29-MAY-24 14:01:23.662: W-1 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/TABLE_DATA
    29-MAY-24 14:01:23.712: W-3 . . imported "SYSTEM"."TRACKING_TAB"                       5.5 KB       1 rows in 0 seconds using direct_path
    29-MAY-24 14:01:23.745: W-4 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/CONSTRAINT/CONSTRAINT
    29-MAY-24 14:01:23.988: W-3      Completed 22 CONSTRAINT objects in 0 seconds
    29-MAY-24 14:01:23.988: W-3      Completed by worker 1 22 CONSTRAINT objects in 0 seconds
    29-MAY-24 14:01:23.991: W-3 Processing object type DATABASE_EXPORT/END_PLUGTS_BLK
    29-MAY-24 14:01:24.243: W-2      Completed 1 PLUGTS_BLK objects in 1 seconds
    29-MAY-24 14:01:24.243: W-2      Completed by worker 1 1 PLUGTS_BLK objects in 0 seconds
    29-MAY-24 14:01:24.256: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER/AUDIT_TRAILS
    29-MAY-24 14:01:24.509: W-1      Completed 10 AUDIT_TRAILS objects in 0 seconds
    29-MAY-24 14:01:24.512: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER/DATAPUMP
    29-MAY-24 14:01:24.516: W-1      Completed 1 DATAPUMP objects in 0 seconds
    29-MAY-24 14:01:24.519: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER/NETWORK_ACL
    29-MAY-24 14:01:24.692: W-1      Completed 3 NETWORK_ACL objects in 0 seconds
    29-MAY-24 14:01:24.694: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER/PSTDY
    29-MAY-24 14:01:24.703: W-1      Completed 2 PSTDY objects in 0 seconds
    29-MAY-24 14:01:24.706: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER/SCHEDULER
    29-MAY-24 14:01:24.708: W-1      Completed 2 SCHEDULER objects in 0 seconds
    29-MAY-24 14:01:24.710: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER/SMB
    29-MAY-24 14:01:26.977: W-1      Completed 6 SMB objects in 2 seconds
    29-MAY-24 14:01:26.980: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER/SQL_FIREWALL
    29-MAY-24 14:01:26.983: W-1      Completed 5 SQL_FIREWALL objects in 0 seconds
    29-MAY-24 14:01:26.985: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER/TSDP
    29-MAY-24 14:01:27.187: W-1      Completed 12 TSDP objects in 1 seconds
    29-MAY-24 14:01:27.198: W-4      Completed 1 [internal] Unknown objects in 3 seconds
    29-MAY-24 14:01:27.198: W-4      Completed by worker 1 1 MARKER objects in 3 seconds
    29-MAY-24 14:01:27.201: W-4 Processing object type DATABASE_EXPORT/AUDIT
    29-MAY-24 14:01:27.285: W-2      Completed 31 AUDIT objects in 0 seconds
    29-MAY-24 14:01:27.285: W-2      Completed by worker 3 31 AUDIT objects in 0 seconds
    29-MAY-24 14:01:27.295: W-1 Processing object type DATABASE_EXPORT/POST_SYSTEM_IMPCALLOUT/MARKER/SCHEDULER
    29-MAY-24 14:01:27.303: W-1      Completed 1 SCHEDULER objects in 0 seconds
    29-MAY-24 14:01:27.305: W-1 Processing object type DATABASE_EXPORT/POST_SYSTEM_IMPCALLOUT/MARKER/WMSYS
    29-MAY-24 14:01:27.483: W-1      Completed 1 WMSYS objects in 0 seconds
    29-MAY-24 14:01:27.486: W-1 Processing object type DATABASE_EXPORT/POST_SYSTEM_IMPCALLOUT/MARKER/DATAPUMP
    29-MAY-24 14:01:27.520: W-1      Completed 1 DATAPUMP objects in 0 seconds
    29-MAY-24 14:01:27.530: W-4      Completed 1 [internal] Unknown objects in 0 seconds
    29-MAY-24 14:01:27.530: W-4      Completed by worker 1 1 MARKER objects in 0 seconds
    29-MAY-24 14:01:27.579: W-3      Completed 1 DATABASE_EXPORT/EARLY_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA objects in 1 seconds
    29-MAY-24 14:01:27.582: W-3      Completed 17 DATABASE_EXPORT/NORMAL_OPTIONS/TABLE_DATA objects in 1 seconds
    29-MAY-24 14:01:27.585: W-3      Completed 15 DATABASE_EXPORT/NORMAL_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA objects in 1799 seconds
    29-MAY-24 14:01:27.587: W-3      Completed 1 DATABASE_EXPORT/SCHEMA/TABLE/TABLE_DATA objects in 0 seconds
    29-MAY-24 14:01:27.605: Job "FTEXUSER"."SYS_IMPORT_TRANSPORTABLE_01" completed with 33 error(s) at Wed May 29 14:01:27 2024 elapsed 0 00:00:15
    ```
    </details>

7. Examine the Data Pump log file for any critical issues. A FTEX import usually produces a few errors or warnings, especially when going to a higher release and into a different architecture.

    * The roles `EM_EXPRESS_ALL`, `EM_EXPRESS_BASIC` and `DATAPATCH_ROLE` do not exist in Oracle Database 23ai causing the grants to fail.
    * The same applies to the `ORACLE_OCM` user.
    * An error related to traditional auditing that is desupported in Oracle Database 23ai.
    * This log file doesn't contain any critical issues.

8. Set the environment to the target database, *CDB23*, and connect.

    ```
    <copy>
    . cdb23
    sqlplus / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

9. Switch to *MAROON* and gather dictionary statistics. Oracle recommends gathering dictionary statistics immediately after an import.

    ```
    <copy>
    alter session set container=maroon;
    exec dbms_stats.gather_schema_stats('SYS');
    exec dbms_stats.gather_schema_stats('SYSTEM');
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> alter session set container=maroon;

    Session altered.

    SQL> exec dbms_stats.gather_schema_stats('SYS');

    PL/SQL procedure successfully completed.

    SQL> exec dbms_stats.gather_schema_stats('SYSTEM');

    PL/SQL procedure successfully completed.
    ```
    </details>

10. Gather database statistics. In the export, you excluded statistics, so, you need to re-gather statistics.

    ```
    <copy>
    exec dbms_stats.gather_database_stats;
    </copy>
    ```

    * You could also transfer the old statistics from the source database using `DBMS_STATS`.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> exec dbms_stats.gather_database_stats;

    PL/SQL procedure successfully completed.
    ```
    </details>

11. Verify your database has been imported. Check the number of objects in the *F1* schema.

    ```
    <copy>
    select object_type, count(*) from all_objects where owner='F1' group by object_type;
    </copy>
    ```

    * There should be 14 tables and 19 indexes.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> select object_type, count(*) from all_objects where owner='F1' group by object_type;

    OBJECT_TYPE               COUNT(*)
    ----------------------- ----------
    TABLE                           14
    INDEX                           19
    ```
    </details>

12. Perform a more extensive check. Verify the actual data. Find all the races won by the legend, *Ayrton Senna*.

    ```
    <copy>
    set pagesize 100
    select ra.name || ' ' || ra.year as race
    from f1.f1_races ra,
         f1.f1_results re,
         f1.f1_drivers d
    where d.forename='Ayrton'
      and d.surname='Senna'
      and re.position=1
      and d.driverid=re.driverid
      and ra.raceid=re.raceid
    order by ra.year, ra.name;      
    </copy>

    -- Be sure to hit RETURN
    ```

    * *Ayrton Senna* won 41 races from 1985 to 1993.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> set pagesize 100
    SQL> select ra.name || ' ' || ra.year as race
      2  from f1.f1_races ra,
      3       f1.f1_results re,
      4       f1.f1_drivers d
      5  where d.forename='Ayrton'
      6    and d.surname='Senna'
      7    and re.position=1
      8    and d.driverid=re.driverid
      9    and ra.raceid=re.raceid
      10 order by ra.year, ra.name;

    RACE
    --------------------------------------------------------------------------------
    Belgian Grand Prix 1985
    Portuguese Grand Prix 1985
    Detroit Grand Prix 1986
    Spanish Grand Prix 1986
    Detroit Grand Prix 1987
    Monaco Grand Prix 1987
    Belgian Grand Prix 1988
    British Grand Prix 1988
    Canadian Grand Prix 1988
    Detroit Grand Prix 1988
    German Grand Prix 1988
    Hungarian Grand Prix 1988
    Japanese Grand Prix 1988
    San Marino Grand Prix 1988
    Belgian Grand Prix 1989
    German Grand Prix 1989
    Mexican Grand Prix 1989
    Monaco Grand Prix 1989
    San Marino Grand Prix 1989
    Spanish Grand Prix 1989
    Belgian Grand Prix 1990
    Canadian Grand Prix 1990
    German Grand Prix 1990
    Italian Grand Prix 1990
    Monaco Grand Prix 1990
    United States Grand Prix 1990
    Australian Grand Prix 1991
    Belgian Grand Prix 1991
    Brazilian Grand Prix 1991
    Hungarian Grand Prix 1991
    Monaco Grand Prix 1991
    San Marino Grand Prix 1991
    United States Grand Prix 1991
    Hungarian Grand Prix 1992
    Italian Grand Prix 1992
    Monaco Grand Prix 1992
    Australian Grand Prix 1993
    Brazilian Grand Prix 1993
    European Grand Prix 1993
    Japanese Grand Prix 1993
    Monaco Grand Prix 1993
    
    41 rows selected.
    ```
    </details>

13. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```

## Task 4: Set tablespace read-write

You might need the *FTEX* database in another lab. In a real migration, you don't need to do this.

1. Set the tablespace to *READ WRITE* again. 

    ```
    <copy>
    . ftex
    sqlplus / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

2. Set the tablespace *READ WRITE*.

    ```
    <copy>
    ALTER TABLESPACE USERS READ WRITE;
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> ALTER TABLESPACE USERS READ WRITE;

    Tablespace altered.
    ```
    </details>

11. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```

**Congratulations!** You have now moved your data into a PDB on Oracle Database 23ai

You may now *proceed to the next lab*.

## Learn More

Full Transportable Export/Import (FTEX) is a good way of moving your data. You can combine transportable tablespaces with RMAN incremental backups and move even huge databases. Further, it allows you to import data into a higher release database and even from a non-CDB into a PDB. You can even use it for cross-endian migrations by converting the data files.

You can avoid an in-place upgrade and PDB conversion by using FTEX. The source database is left untouched in case a rollback is needed.

* Documentation, [Oracle Data Pump Export Modes](https://docs.oracle.com/en/database/oracle/oracle-database/23/sutil/oracle-data-pump-export-utility.html#GUID-8E497131-6B9B-4CC8-AA50-35F480CAC2C4)
* Webinar, [Cross Platform Migration – Transportable Tablespaces to the Extreme](https://youtu.be/DwUBvjQrPxs)
* Slides, [Cross Platform Migration – Transportable Tablespaces to the Extreme](https://dohdatabase.com/wp-content/uploads/2024/03/cross-platform-migration-transportable-tablespace-to-the-extreme.pdf)

## Acknowledgements
* **Author** - Daniel Overby Hansen
* **Contributors** - Klaus Gronau, Rodrigo Jorge, Alex Zaballa, Mike Dietrich
* **Last Updated By/Date** - Daniel Overby Hansen, January 2025