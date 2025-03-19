# Migrate Data Using Data Pump

## Introduction

Instead of upgrading and migrating an entire database, you will try a different approach in this lab. A logical migration of your data into a brand new, empty database on Oracle Database 23ai. Using this approach, you can skip the usual upgrade and PDB conversion. Data Pump enables you to import data directly into a higher release database (and lower for that matter). Further, you can export from a non-CDB and directly into a pluggable database.

A migration with Data Pump is mostly suitable for smaller databases or when you have other changes to the database, like converting LOBs to SecureFile, character set migrations, or other schema changes.

You will perform a full export from the *FTEX* database and import into a new PDB in the *CDB23* database.

Estimated Time: 15 minutes

### Objectives

In this lab, you will:

* Prepare new PDB
* Move your data using Data Pump

### Prerequisites

None.

This lab uses the *FTEX* and *CDB23* databases. Don't do this lab at the same time as lab 11 and 13.

## Task 1: Data Pump export

You need to prepare a few things before you can start a Data Pump export.

1. Data Pump needs access to a directory where it can put dump and log file. Create a directory in the file system.

    ```
    <copy>
    mkdir -p /home/oracle/logs/migrate-using-data-pump
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
    create directory dmpdir as '/home/oracle/logs/migrate-using-data-pump';
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> create directory dmpdir as '/home/oracle/logs/migrate-using-data-pump';

    Directory created.
    ```
    </details>

5. Create a dedicated user that you can use for the Data Pump export job.

    ```
    <copy>
    create user expuser identified by expuser default tablespace users;
    grant exp_full_database to expuser;
    grant read, write on directory dmpdir to expuser;
    alter user expuser quota unlimited on users;
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> create user expuser identified by expuser default tablespace users;

    User created.

    SQL> grant exp_full_database to expuser;

    Grant succeeded.

    SQL> grant read, write on directory dmpdir to expuser;

    Grant succeeded.

    SQL> alter user expuser quota unlimited on users;

    User altered.
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
    cat /home/oracle/scripts/migrate-using-data-pump-exp.par
    </copy>
    ```

    * `dumpfile` uses the `%L` wildcard that enables Data Pump to create many dump files.
    * `filesize` splits the files into 5 GB chunks which is handy if you need to transfer the dump files to a remote system.
    * `parallel` specifies the number of parallel processes.
    * `metrics` and `logtime` print additional diagnostic information in the log file.
    * `exclude` specifies to skip database statistics.
    * `full` tells Data Pump to perform a full export containing more or less the entire database.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    directory=dmpdir
    logfile=full_exp.log
    dumpfile=full_exp_%L.dmp
    filesize=5g
    parallel=2
    metrics=yes
    logtime=all
    exclude=statistics
    full=y
    ```
    </details>

8. Start the Data Pump export. Connect as the dedicated export user, *expuser*, that you just created.

    ```
    <copy>
    expdp expuser/expuser parfile=/home/oracle/scripts/migrate-using-data-pump-exp.par
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    Export: Release 19.0.0.0.0 - Production on Tue May 28 03:23:45 2024
    Version 19.21.0.0.0

    Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.

    Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    28-MAY-24 03:23:48.178: Starting "EXPUSER"."SYS_EXPORT_FULL_01":  expuser/******** parfile=/home/oracle/scripts/migrate-using-data-pump-exp.par
    28-MAY-24 03:23:48.554: W-1 Startup took 0 seconds
    28-MAY-24 03:23:49.875: W-2 Startup took 0 seconds
    28-MAY-24 03:23:50.769: W-2 Processing object type DATABASE_EXPORT/EARLY_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA
    28-MAY-24 03:23:50.772: W-1 Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/TABLE_DATA
    28-MAY-24 03:23:51.791: W-1 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/TABLE_DATA
    28-MAY-24 03:23:51.918: W-1 Processing object type DATABASE_EXPORT/PRE_SYSTEM_IMPCALLOUT/MARKER
    28-MAY-24 03:23:51.920: W-1      Completed 1 MARKER objects in 0 seconds
    28-MAY-24 03:23:51.926: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER
    28-MAY-24 03:23:51.928: W-1      Completed 1 MARKER objects in 0 seconds
    28-MAY-24 03:23:51.969: W-1 Processing object type DATABASE_EXPORT/TABLESPACE
    28-MAY-24 03:23:52.067: W-1      Completed 3 TABLESPACE objects in 1 seconds
    28-MAY-24 03:23:52.155: W-1 Processing object type DATABASE_EXPORT/PROFILE
    28-MAY-24 03:23:52.164: W-1      Completed 1 PROFILE objects in 0 seconds
    28-MAY-24 03:23:52.206: W-1 Processing object type DATABASE_EXPORT/SCHEMA/USER
    28-MAY-24 03:23:52.209: W-1      Completed 2 USER objects in 0 seconds
    28-MAY-24 03:23:52.233: W-1 Processing object type DATABASE_EXPORT/ROLE
    28-MAY-24 03:23:52.236: W-1      Completed 1 ROLE objects in 0 seconds
    28-MAY-24 03:23:52.247: W-1 Processing object type DATABASE_EXPORT/RADM_FPTM
    28-MAY-24 03:23:52.249: W-1      Completed 1 RADM_FPTM objects in 0 seconds
    28-MAY-24 03:23:52.405: W-1 Processing object type DATABASE_EXPORT/GRANT/SYSTEM_GRANT/PROC_SYSTEM_GRANT
    28-MAY-24 03:23:52.408: W-1      Completed 6 PROC_SYSTEM_GRANT objects in 0 seconds
    28-MAY-24 03:23:52.431: W-1 Processing object type DATABASE_EXPORT/SCHEMA/GRANT/SYSTEM_GRANT
    28-MAY-24 03:23:52.439: W-1      Completed 74 SYSTEM_GRANT objects in 0 seconds
    28-MAY-24 03:23:52.454: W-1 Processing object type DATABASE_EXPORT/SCHEMA/ROLE_GRANT
    28-MAY-24 03:23:52.460: W-1      Completed 41 ROLE_GRANT objects in 0 seconds
    28-MAY-24 03:23:52.474: W-1 Processing object type DATABASE_EXPORT/SCHEMA/DEFAULT_ROLE
    28-MAY-24 03:23:52.477: W-1      Completed 4 DEFAULT_ROLE objects in 0 seconds
    28-MAY-24 03:23:52.493: W-1 Processing object type DATABASE_EXPORT/SCHEMA/ON_USER_GRANT
    28-MAY-24 03:23:52.496: W-1      Completed 18 ON_USER_GRANT objects in 0 seconds
    28-MAY-24 03:23:52.521: W-1 Processing object type DATABASE_EXPORT/SCHEMA/TABLESPACE_QUOTA
    28-MAY-24 03:23:52.524: W-1      Completed 3 TABLESPACE_QUOTA objects in 0 seconds
    28-MAY-24 03:23:52.535: W-1 Processing object type DATABASE_EXPORT/RESOURCE_COST
    28-MAY-24 03:23:52.538: W-1      Completed 1 RESOURCE_COST objects in 0 seconds
    28-MAY-24 03:23:52.595: W-1 Processing object type DATABASE_EXPORT/TRUSTED_DB_LINK
    28-MAY-24 03:23:52.597: W-1      Completed 1 TRUSTED_DB_LINK objects in 0 seconds
    28-MAY-24 03:23:52.651: W-1 Processing object type DATABASE_EXPORT/DIRECTORY/DIRECTORY
    28-MAY-24 03:23:52.654: W-1      Completed 2 DIRECTORY objects in 0 seconds
    28-MAY-24 03:23:52.847: W-1 Processing object type DATABASE_EXPORT/DIRECTORY/GRANT/OWNER_GRANT/OBJECT_GRANT
    28-MAY-24 03:23:52.850: W-1      Completed 4 OBJECT_GRANT objects in 0 seconds
    28-MAY-24 03:23:53.348: W-1 Processing object type DATABASE_EXPORT/SCHEMA/PUBLIC_SYNONYM/SYNONYM
    28-MAY-24 03:23:53.350: W-1      Completed 1 SYNONYM objects in 0 seconds
    28-MAY-24 03:23:53.775: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/PRE_SYSTEM_ACTIONS/PROCACT_SYSTEM
    28-MAY-24 03:23:53.789: W-2 Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA
    28-MAY-24 03:23:53.844: W-1      Completed 2 PROCACT_SYSTEM objects in 0 seconds
    28-MAY-24 03:23:53.971: W-2 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/PROCOBJ
    28-MAY-24 03:23:53.999: W-2      Completed 24 PROCOBJ objects in 0 seconds
    28-MAY-24 03:23:54.036: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/POST_SYSTEM_ACTIONS/PROCACT_SYSTEM
    28-MAY-24 03:23:54.394: W-1      Completed 4 PROCACT_SYSTEM objects in 0 seconds
    28-MAY-24 03:23:54.428: W-2 Processing object type DATABASE_EXPORT/SCHEMA/PROCACT_SCHEMA
    28-MAY-24 03:23:54.432: W-2      Completed 5 PROCACT_SCHEMA objects in 0 seconds
    28-MAY-24 03:23:58.695: W-2 Processing object type DATABASE_EXPORT/EARLY_OPTIONS/VIEWS_AS_TABLES/TABLE
    28-MAY-24 03:23:58.745: W-2      Completed 1 TABLE objects in 2 seconds
    28-MAY-24 03:23:58.761: W-2 Processing object type DATABASE_EXPORT/EARLY_POST_INSTANCE_IMPCALLOUT/MARKER
    28-MAY-24 03:23:58.762: W-2      Completed 1 MARKER objects in 0 seconds
    28-MAY-24 03:24:08.125: W-1 Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/VIEWS_AS_TABLES/TABLE
    28-MAY-24 03:24:08.167: W-2 Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/TABLE
    28-MAY-24 03:24:16.539: W-1      Completed 15 TABLE objects in 11 seconds
    28-MAY-24 03:24:16.600: W-1 Processing object type DATABASE_EXPORT/NORMAL_POST_INSTANCE_IMPCALLOUT/MARKER
    28-MAY-24 03:24:16.602: W-1      Completed 1 MARKER objects in 0 seconds
    28-MAY-24 03:24:17.610: W-1 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/TABLE
    28-MAY-24 03:24:18.012: W-2      Completed 17 TABLE objects in 20 seconds
    28-MAY-24 03:24:18.882: W-2 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/COMMENT
    28-MAY-24 03:24:20.263: W-2 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/INDEX/INDEX
    28-MAY-24 03:24:20.920: W-2 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/CONSTRAINT/CONSTRAINT
    28-MAY-24 03:24:20.926: W-2      Completed 22 CONSTRAINT objects in 0 seconds
    28-MAY-24 03:24:21.970: W-2 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER
    28-MAY-24 03:24:21.972: W-2      Completed 1 MARKER objects in 0 seconds
    28-MAY-24 03:24:24.130: W-2 Processing object type DATABASE_EXPORT/AUDIT
    28-MAY-24 03:24:24.173: W-2      Completed 31 AUDIT objects in 0 seconds
    28-MAY-24 03:24:24.224: W-2 Processing object type DATABASE_EXPORT/POST_SYSTEM_IMPCALLOUT/MARKER
    28-MAY-24 03:24:24.225: W-2      Completed 1 MARKER objects in 0 seconds
    28-MAY-24 03:24:24.574: W-2 . . exported "SYS"."KU$_USER_MAPPING_VIEW"               5.867 KB      24 rows in 0 seconds using external_table
    28-MAY-24 03:24:24.698: W-2 . . exported "SYS"."DAM_CONFIG_PARAM$"                   6.539 KB      14 rows in 0 seconds using direct_path
    28-MAY-24 03:24:24.715: W-2 . . exported "SYS"."TSDP_SUBPOL$"                        6.328 KB       1 rows in 0 seconds using direct_path
    28-MAY-24 03:24:24.729: W-2 . . exported "SYS"."TSDP_PARAMETER$"                     5.953 KB       1 rows in 0 seconds using direct_path
    28-MAY-24 03:24:24.743: W-2 . . exported "SYS"."TSDP_POLICY$"                        5.921 KB       1 rows in 0 seconds using direct_path
    28-MAY-24 03:24:24.790: W-2 . . exported "AUDSYS"."AUD$UNIFIED":"AUD_UNIFIED_P0"     50.95 KB       0 rows in 0 seconds using direct_path
    28-MAY-24 03:24:24.810: W-2 . . exported "SYS"."AUD$"                                23.46 KB       0 rows in 0 seconds using direct_path
    28-MAY-24 03:24:24.825: W-2 . . exported "SYS"."DAM_CLEANUP_EVENTS$"                 7.187 KB       0 rows in 0 seconds using direct_path
    28-MAY-24 03:24:24.839: W-2 . . exported "SYS"."DAM_CLEANUP_JOBS$"                   7.179 KB       0 rows in 0 seconds using direct_path
    28-MAY-24 03:24:24.841: W-2 . . exported "SYS"."TSDP_ASSOCIATION$"                       0 KB       0 rows in 0 seconds using direct_path
    28-MAY-24 03:24:24.843: W-2 . . exported "SYS"."TSDP_CONDITION$"                         0 KB       0 rows in 0 seconds using direct_path
    28-MAY-24 03:24:24.845: W-2 . . exported "SYS"."TSDP_FEATURE_POLICY$"                    0 KB       0 rows in 0 seconds using direct_path
    28-MAY-24 03:24:24.847: W-2 . . exported "SYS"."TSDP_PROTECTION$"                        0 KB       0 rows in 0 seconds using direct_path
    28-MAY-24 03:24:24.848: W-2 . . exported "SYS"."TSDP_SENSITIVE_DATA$"                    0 KB       0 rows in 0 seconds using direct_path
    28-MAY-24 03:24:24.850: W-2 . . exported "SYS"."TSDP_SENSITIVE_TYPE$"                    0 KB       0 rows in 0 seconds using direct_path
    28-MAY-24 03:24:24.852: W-2 . . exported "SYS"."TSDP_SOURCE$"                            0 KB       0 rows in 0 seconds using direct_path
    28-MAY-24 03:24:24.854: W-2 . . exported "SYSTEM"."REDO_DB"                              0 KB       0 rows in 0 seconds using direct_path
    28-MAY-24 03:24:24.856: W-2 . . exported "SYSTEM"."REDO_LOG"                             0 KB       0 rows in 0 seconds using direct_path
    28-MAY-24 03:24:24.987: W-2 . . exported "F1"."F1_LAPTIMES"                          16.98 MB  571047 rows in 0 seconds using direct_path
    28-MAY-24 03:24:25.022: W-2 . . exported "F1"."F1_RESULTS"                           1.429 MB   26439 rows in 1 seconds using direct_path
    28-MAY-24 03:24:25.052: W-2 . . exported "F1"."F1_DRIVERSTANDINGS"                   916.2 KB   34511 rows in 0 seconds using direct_path
    28-MAY-24 03:24:25.080: W-2 . . exported "F1"."F1_QUALIFYING"                        419.0 KB   10174 rows in 0 seconds using direct_path
    28-MAY-24 03:24:25.102: W-2 . . exported "F1"."F1_PITSTOPS"                          416.8 KB   10793 rows in 0 seconds using direct_path
    28-MAY-24 03:24:25.123: W-2 . . exported "F1"."F1_CONSTRUCTORSTANDINGS"              344.1 KB   13231 rows in 0 seconds using direct_path
    28-MAY-24 03:24:25.141: W-1      Completed 15 TABLE objects in 9 seconds
    28-MAY-24 03:24:25.147: W-2 . . exported "F1"."F1_CONSTRUCTORRESULTS"                225.2 KB   12465 rows in 0 seconds using direct_path
    28-MAY-24 03:24:25.169: W-2 . . exported "F1"."F1_RACES"                             131.4 KB    1125 rows in 0 seconds using direct_path
    28-MAY-24 03:24:25.187: W-2 . . exported "F1"."F1_DRIVERS"                           88.13 KB     859 rows in 0 seconds using direct_path
    28-MAY-24 03:24:25.204: W-2 . . exported "F1"."F1_CONSTRUCTORS"                      22.97 KB     212 rows in 0 seconds using direct_path
    28-MAY-24 03:24:25.222: W-2 . . exported "F1"."F1_CIRCUITS"                          17.49 KB      77 rows in 0 seconds using direct_path
    28-MAY-24 03:24:25.237: W-2 . . exported "F1"."F1_SEASONS"                           10.03 KB      75 rows in 0 seconds using direct_path
    28-MAY-24 03:24:25.253: W-2 . . exported "F1"."F1_STATUS"                            7.843 KB     139 rows in 0 seconds using direct_path
    28-MAY-24 03:24:25.269: W-2 . . exported "SYSTEM"."TRACKING_TAB"                     5.507 KB       1 rows in 0 seconds using direct_path
    28-MAY-24 03:24:25.289: W-2 . . exported "F1"."F1_SPRINTRESULTS"                     29.88 KB     280 rows in 0 seconds using direct_path
    28-MAY-24 03:24:25.474: W-1 . . exported "SYS"."AUDTAB$TBS$FOR_EXPORT"               5.960 KB       2 rows in 0 seconds using external_table
    28-MAY-24 03:24:25.480: W-1 . . exported "SYS"."DBA_SENSITIVE_DATA"                      0 KB       0 rows in 0 seconds using external_table
    28-MAY-24 03:24:25.487: W-1 . . exported "SYS"."DBA_TSDP_POLICY_PROTECTION"              0 KB       0 rows in 0 seconds using external_table
    28-MAY-24 03:24:25.491: W-1 . . exported "SYS"."FGA_LOG$FOR_EXPORT"                      0 KB       0 rows in 0 seconds using external_table
    28-MAY-24 03:24:25.533: W-1 . . exported "SYS"."NACL$_ACE_EXP"                           0 KB       0 rows in 0 seconds using external_table
    28-MAY-24 03:24:25.590: W-1 . . exported "SYS"."NACL$_HOST_EXP"                      6.914 KB       1 rows in 0 seconds using external_table
    28-MAY-24 03:24:25.593: W-1 . . exported "SYS"."NACL$_WALLET_EXP"                        0 KB       0 rows in 0 seconds using external_table
    28-MAY-24 03:24:25.597: W-1 . . exported "SYS"."SQL$TEXT_DATAPUMP"                       0 KB       0 rows in 0 seconds using external_table
    28-MAY-24 03:24:25.599: W-1 . . exported "SYS"."SQL$_DATAPUMP"                           0 KB       0 rows in 0 seconds using external_table
    28-MAY-24 03:24:25.603: W-1 . . exported "SYS"."SQLOBJ$AUXDATA_DATAPUMP"                 0 KB       0 rows in 0 seconds using external_table
    28-MAY-24 03:24:25.606: W-1 . . exported "SYS"."SQLOBJ$DATA_DATAPUMP"                    0 KB       0 rows in 0 seconds using external_table
    28-MAY-24 03:24:25.609: W-1 . . exported "SYS"."SQLOBJ$PLAN_DATAPUMP"                    0 KB       0 rows in 0 seconds using external_table
    28-MAY-24 03:24:25.611: W-1 . . exported "SYS"."SQLOBJ$_DATAPUMP"                        0 KB       0 rows in 0 seconds using external_table
    28-MAY-24 03:24:25.639: W-1 . . exported "SYSTEM"."SCHEDULER_JOB_ARGS"                   0 KB       0 rows in 0 seconds using external_table
    28-MAY-24 03:24:25.739: W-1 . . exported "SYSTEM"."SCHEDULER_PROGRAM_ARGS"           9.507 KB      12 rows in 0 seconds using external_table
    28-MAY-24 03:24:26.691: W-1      Completed 1 DATABASE_EXPORT/EARLY_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA objects in 0 seconds
    28-MAY-24 03:24:26.719: W-1      Completed 17 DATABASE_EXPORT/NORMAL_OPTIONS/TABLE_DATA objects in 0 seconds
    28-MAY-24 03:24:26.720: W-1      Completed 15 DATABASE_EXPORT/NORMAL_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA objects in 0 seconds
    28-MAY-24 03:24:26.722: W-1      Completed 15 DATABASE_EXPORT/SCHEMA/TABLE/TABLE_DATA objects in 1 seconds
    28-MAY-24 03:24:27.857: W-1 Master table "EXPUSER"."SYS_EXPORT_FULL_01" successfully loaded/unloaded
    28-MAY-24 03:24:27.860: ******************************************************************************
    28-MAY-24 03:24:27.861: Dump file set for EXPUSER.SYS_EXPORT_FULL_01 is:
    28-MAY-24 03:24:27.862:   /home/oracle/logs/migrate-using-data-pump/full_exp_01.dmp
    28-MAY-24 03:24:27.862:   /home/oracle/logs/migrate-using-data-pump/full_exp_02.dmp
    28-MAY-24 03:24:27.878: Job "EXPUSER"."SYS_EXPORT_FULL_01" successfully completed at Tue May 28 03:24:27 2024 elapsed 0 00:00:41
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

3. Create a new PDB called *PURPLE* and open it.

    ```
    <copy>
    create pluggable database purple admin user admin identified by admin;
    alter pluggable database purple open;
    alter pluggable database purple save state;
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> create pluggable database PURPLE admin user admin identified by admin;

    Pluggable database created.

    SQL> alter pluggable database purple open;

    Pluggable database altered.

    SQL>alter pluggable database purple save state;

    Pluggable database altered.
    ```
    </details>

4. Create a *USERS* tablespace in the new PDB.

    ```
    <copy>
    alter session set container=purple;
    create tablespace users datafile size 100m autoextend on next 100m maxsize 32767m;
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> alter session set container=purple;

    Session altered.

    SQL> create tablespace users datafile size 100m autoextend on next 100m maxsize 32767m;

    Tablespace created.
    ```
    </details>

## Task 3: Data Pump import

You need a few more changes to the new PDB before you can start the import.

1. Create a database directory object that points to the same operating system directory that you created in the previous task.

    ```
    <copy>
    create directory dmpdir as '/home/oracle/logs/migrate-using-data-pump';
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> create directory dmpdir as '/home/oracle/logs/migrate-using-data-pump';

    Directory created.
    ```
    </details>

2. Create a dedicated user for the Data Pump import.

    ```
    <copy>
    create user impuser identified by impuser default tablespace users;
    grant imp_full_database to impuser;
    grant read, write on directory dmpdir to impuser;
    alter user impuser quota unlimited on users;
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> create user impuser identified by impuser default tablespace users;

    User created.

    SQL> grant imp_full_database to impuser;

    Grant succeeded.

    SQL> grant read, write on directory dmpdir to impuser;

    Grant succeeded.

    SQL> alter user impuser quota unlimited on users;

    User altered.
    ```
    </details>

6. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```

3. Examine the precreated Data Pump import parameter file.

    ```
    <copy>
    cat /home/oracle/scripts/migrate-using-data-pump-imp.par
    </copy>
    ```

    * `parallel` is higher in the import. Export and import parallel settings are independent of each other. Typically, the target system is more powerful than the source system. In such a case, you can use more parallel processes to complete the import faster.
    * `metrics` and `logtime` puts additional diagnostic information into the Data Pump log file.
    * `exclude=tablespace` skips creation of tablespaces during import. We already have all tablespaces in the target PDB. Normally, pay attention when importing tablespace defintions. The data file use the same definition, including file path, as on the source database. This may lead to undesired situations.
    * `transform=lob_storage:securefile` ensures that Data Pump converts any old BasicFile LOBs to modern SecureFile LOBs during import.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    directory=dmpdir
    logfile=full_imp.log
    dumpfile=full_exp_%L.dmp
    parallel=4
    metrics=yes
    logtime=all
    exclude=tablespace
    transform=lob_storage:securefile
    ```
    </details>

4. Start the Data Pump import.

    ```
    <copy>
    impdp impuser/impuser@localhost/purple parfile=/home/oracle/scripts/migrate-using-data-pump-imp.par
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    Import: Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems on Tue May 28 03:26:43 2024
    Version 23.5.0.24.07

    Copyright (c) 1982, 2024, Oracle and/or its affiliates.  All rights reserved.

    Connected to: Oracle Database 23ai Enterprise Edition Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems
    28-MAY-24 03:26:47.767: W-1 Startup on instance 1 took 0 seconds
    28-MAY-24 03:26:48.982: W-1 Master table "IMPUSER"."SYS_IMPORT_FULL_01" successfully loaded/unloaded
    28-MAY-24 03:26:49.306: Starting "IMPUSER"."SYS_IMPORT_FULL_01":  impuser/********@localhost/purple parfile=/home/oracle/scripts/migrate-using-data-pump-imp.par
    28-MAY-24 03:26:49.377: W-1 Processing object type DATABASE_EXPORT/PRE_SYSTEM_IMPCALLOUT/MARKER/SCHEDULER
    28-MAY-24 03:26:49.400: W-1      Completed 1 SCHEDULER objects in 0 seconds
    28-MAY-24 03:26:49.402: W-1 Processing object type DATABASE_EXPORT/PRE_SYSTEM_IMPCALLOUT/MARKER/WMSYS
    28-MAY-24 03:26:49.716: W-1      Completed 1 WMSYS objects in 0 seconds
    28-MAY-24 03:26:49.718: W-1 Processing object type DATABASE_EXPORT/PRE_SYSTEM_IMPCALLOUT/MARKER/DATAPUMP
    28-MAY-24 03:26:49.742: W-1      Completed 1 DATAPUMP objects in 0 seconds
    28-MAY-24 03:26:49.776: W-1      Completed 1 [internal] PRE_SYSTEM objects in 0 seconds
    28-MAY-24 03:26:49.776: W-1      Completed by worker 1 1 MARKER objects in 0 seconds
    28-MAY-24 03:26:49.789: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER/AUDIT_TRAILS
    28-MAY-24 03:26:49.874: W-1      Completed 10 AUDIT_TRAILS objects in 0 seconds
    28-MAY-24 03:26:49.876: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER/DATAPUMP
    28-MAY-24 03:26:49.879: W-1      Completed 1 DATAPUMP objects in 0 seconds
    28-MAY-24 03:26:49.881: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER/NETWORK_ACL
    28-MAY-24 03:26:49.900: W-1      Completed 3 NETWORK_ACL objects in 0 seconds
    28-MAY-24 03:26:49.901: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER/PSTDY
    28-MAY-24 03:26:49.911: W-1      Completed 2 PSTDY objects in 0 seconds
    28-MAY-24 03:26:49.912: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER/SCHEDULER
    28-MAY-24 03:26:49.930: W-1      Completed 2 SCHEDULER objects in 0 seconds
    28-MAY-24 03:26:49.932: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER/SMB
    28-MAY-24 03:26:49.959: W-1      Completed 6 SMB objects in 0 seconds
    28-MAY-24 03:26:49.961: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER/SQL_FIREWALL
    28-MAY-24 03:26:49.963: W-1      Completed 5 SQL_FIREWALL objects in 0 seconds
    28-MAY-24 03:26:49.965: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER/TSDP
    28-MAY-24 03:26:50.008: W-1      Completed 12 TSDP objects in 1 seconds
    28-MAY-24 03:26:50.016: W-1      Completed 1 [internal] PRE_INSTANCE objects in 1 seconds
    28-MAY-24 03:26:50.016: W-1      Completed by worker 1 1 MARKER objects in 1 seconds
    28-MAY-24 03:26:50.017: W-1 Processing object type DATABASE_EXPORT/PROFILE
    28-MAY-24 03:26:50.127: W-1      Completed 1 PROFILE objects in 0 seconds
    28-MAY-24 03:26:50.127: W-1      Completed by worker 1 1 PROFILE objects in 0 seconds
    28-MAY-24 03:26:50.129: W-1 Processing object type DATABASE_EXPORT/SCHEMA/USER
    28-MAY-24 03:26:50.183: W-1      Completed 2 USER objects in 0 seconds
    28-MAY-24 03:26:50.183: W-1      Completed by worker 1 2 USER objects in 0 seconds
    28-MAY-24 03:26:50.184: W-1 Processing object type DATABASE_EXPORT/ROLE
    28-MAY-24 03:26:50.232: W-1      Completed 1 ROLE objects in 0 seconds
    28-MAY-24 03:26:50.232: W-1      Completed by worker 1 1 ROLE objects in 0 seconds
    28-MAY-24 03:26:50.234: W-1 Processing object type DATABASE_EXPORT/RADM_FPTM
    28-MAY-24 03:26:50.277: W-1      Completed 1 RADM_FPTM objects in 0 seconds
    28-MAY-24 03:26:50.277: W-1      Completed by worker 1 1 RADM_FPTM objects in 0 seconds
    28-MAY-24 03:26:50.292: W-1 Processing object type DATABASE_EXPORT/GRANT/SYSTEM_GRANT/PROC_SYSTEM_GRANT/AQ
    28-MAY-24 03:26:50.332: W-1      Completed 1 AQ objects in 0 seconds
    28-MAY-24 03:26:50.334: W-1 Processing object type DATABASE_EXPORT/GRANT/SYSTEM_GRANT/PROC_SYSTEM_GRANT/RULE
    28-MAY-24 03:26:50.336: W-1      Completed 1 RULE objects in 0 seconds
    28-MAY-24 03:26:50.338: W-1 Processing object type DATABASE_EXPORT/GRANT/SYSTEM_GRANT/PROC_SYSTEM_GRANT/RMGR
    28-MAY-24 03:26:50.353: ORA-39083: Object type RMGR:PROC_SYSTEM_GRANT failed to create with error:
    ORA-29393: user EM_EXPRESS_ALL does not exist or is not logged on

    28-MAY-24 03:26:50.358: W-1      Completed 1 RMGR objects in 0 seconds
    28-MAY-24 03:26:50.360: W-1 Processing object type DATABASE_EXPORT/GRANT/SYSTEM_GRANT/PROC_SYSTEM_GRANT/SQL
    28-MAY-24 03:26:50.374: W-1      Completed 1 SQL objects in 0 seconds
    28-MAY-24 03:26:50.376: W-1 Processing object type DATABASE_EXPORT/GRANT/SYSTEM_GRANT/PROC_SYSTEM_GRANT/RULE
    28-MAY-24 03:26:50.380: W-1      Completed 2 RULE objects in 0 seconds
    28-MAY-24 03:26:50.387: W-1 Processing object type DATABASE_EXPORT/SCHEMA/GRANT/SYSTEM_GRANT
    28-MAY-24 03:26:50.505: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'DATAPATCH_ROLE' does not exist

    Failing sql is:
    GRANT ALTER SESSION TO "DATAPATCH_ROLE"

    28-MAY-24 03:26:50.505: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_BASIC' does not exist

    Failing sql is:
    GRANT CREATE SESSION TO "EM_EXPRESS_BASIC"

    28-MAY-24 03:26:50.505: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-00990: missing or invalid privilege

    Failing sql is:
    GRANT EM EXPRESS CONNECT TO "EM_EXPRESS_BASIC"

    28-MAY-24 03:26:50.505: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist

    Failing sql is:
    GRANT ADVISOR TO "EM_EXPRESS_ALL"

    28-MAY-24 03:26:50.505: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist

    Failing sql is:
    GRANT CREATE JOB TO "EM_EXPRESS_ALL"

    28-MAY-24 03:26:50.505: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist

    Failing sql is:
    GRANT ADMINISTER SQL TUNING SET TO "EM_EXPRESS_ALL"

    28-MAY-24 03:26:50.505: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist

    Failing sql is:
    GRANT ADMINISTER ANY SQL TUNING SET TO "EM_EXPRESS_ALL"

    28-MAY-24 03:26:50.505: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist

    Failing sql is:
    GRANT ADMINISTER SQL MANAGEMENT OBJECT TO "EM_EXPRESS_ALL"

    28-MAY-24 03:26:50.505: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist

    Failing sql is:
    GRANT ALTER SYSTEM TO "EM_EXPRESS_ALL"

    28-MAY-24 03:26:50.505: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist

    Failing sql is:
    GRANT CREATE TABLESPACE TO "EM_EXPRESS_ALL"

    28-MAY-24 03:26:50.505: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist

    Failing sql is:
    GRANT DROP TABLESPACE TO "EM_EXPRESS_ALL"

    28-MAY-24 03:26:50.505: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist

    Failing sql is:
    GRANT ALTER TABLESPACE TO "EM_EXPRESS_ALL"

    28-MAY-24 03:26:50.505: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist

    Failing sql is:
    GRANT GRANT ANY OBJECT PRIVILEGE TO "EM_EXPRESS_ALL"

    28-MAY-24 03:26:50.505: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist

    Failing sql is:
    GRANT GRANT ANY PRIVILEGE TO "EM_EXPRESS_ALL"

    28-MAY-24 03:26:50.505: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist

    Failing sql is:
    GRANT GRANT ANY ROLE TO "EM_EXPRESS_ALL"

    28-MAY-24 03:26:50.505: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist

    Failing sql is:
    GRANT CREATE ROLE TO "EM_EXPRESS_ALL"

    28-MAY-24 03:26:50.505: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist

    Failing sql is:
    GRANT DROP ANY ROLE TO "EM_EXPRESS_ALL"

    28-MAY-24 03:26:50.505: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist

    Failing sql is:
    GRANT ALTER ANY ROLE TO "EM_EXPRESS_ALL"

    28-MAY-24 03:26:50.505: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist

    Failing sql is:
    GRANT CREATE USER TO "EM_EXPRESS_ALL"

    28-MAY-24 03:26:50.505: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist

    Failing sql is:
    GRANT DROP USER TO "EM_EXPRESS_ALL"

    28-MAY-24 03:26:50.505: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist

    Failing sql is:
    GRANT ALTER USER TO "EM_EXPRESS_ALL"

    28-MAY-24 03:26:50.505: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist

    Failing sql is:
    GRANT CREATE PROFILE TO "EM_EXPRESS_ALL"

    28-MAY-24 03:26:50.505: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist

    Failing sql is:
    GRANT ALTER PROFILE TO "EM_EXPRESS_ALL"

    28-MAY-24 03:26:50.505: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist

    Failing sql is:
    GRANT DROP PROFILE TO "EM_EXPRESS_ALL"

    28-MAY-24 03:26:50.505: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist

    Failing sql is:
    GRANT SET CONTAINER TO "EM_EXPRESS_ALL"

    28-MAY-24 03:26:50.505: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist

    Failing sql is:
    GRANT CREATE CREDENTIAL TO "EM_EXPRESS_ALL"

    28-MAY-24 03:26:50.514: W-1      Completed 74 SYSTEM_GRANT objects in 0 seconds
    28-MAY-24 03:26:50.514: W-1      Completed by worker 1 74 SYSTEM_GRANT objects in 0 seconds
    28-MAY-24 03:26:50.522: W-1 Processing object type DATABASE_EXPORT/SCHEMA/ROLE_GRANT
    28-MAY-24 03:26:50.625: ORA-39083: Object type ROLE_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_BASIC' does not exist

    Failing sql is:
     GRANT "SELECT_CATALOG_ROLE" TO "EM_EXPRESS_BASIC"

    28-MAY-24 03:26:50.625: ORA-39083: Object type ROLE_GRANT failed to create with error:
    ORA-01919: Role 'EM_EXPRESS_ALL' does not exist.

    Failing sql is:
     GRANT "EM_EXPRESS_ALL" TO "DBA"

    28-MAY-24 03:26:50.625: ORA-39083: Object type ROLE_GRANT failed to create with error:
    ORA-01919: Role 'EM_EXPRESS_BASIC' does not exist.

    Failing sql is:
     GRANT "EM_EXPRESS_BASIC" TO "EM_EXPRESS_ALL"

    28-MAY-24 03:26:50.632: W-1      Completed 41 ROLE_GRANT objects in 0 seconds
    28-MAY-24 03:26:50.632: W-1      Completed by worker 1 41 ROLE_GRANT objects in 0 seconds
    28-MAY-24 03:26:50.634: W-1 Processing object type DATABASE_EXPORT/SCHEMA/DEFAULT_ROLE
    28-MAY-24 03:26:50.670: W-1      Completed 4 DEFAULT_ROLE objects in 0 seconds
    28-MAY-24 03:26:50.670: W-1      Completed by worker 1 4 DEFAULT_ROLE objects in 0 seconds
    28-MAY-24 03:26:50.672: W-1 Processing object type DATABASE_EXPORT/SCHEMA/ON_USER_GRANT
    28-MAY-24 03:26:50.716: ORA-39083: Object type ON_USER_GRANT failed to create with error:
    ORA-31625: Schema AUDSYS is needed to import this object, but is unaccessible
    ORA-01031: insufficient privileges

    Failing sql is:
     GRANT INHERIT PRIVILEGES ON USER "AUDSYS" TO "PUBLIC"

    28-MAY-24 03:26:50.716: ORA-39083: Object type ON_USER_GRANT failed to create with error:
    ORA-31625: Schema ORACLE_OCM is needed to import this object, but is unaccessible
    ORA-01435: user does not exist

    Failing sql is:
     GRANT INHERIT PRIVILEGES ON USER "ORACLE_OCM" TO "PUBLIC"

    28-MAY-24 03:26:50.723: W-1      Completed 18 ON_USER_GRANT objects in 0 seconds
    28-MAY-24 03:26:50.723: W-1      Completed by worker 1 18 ON_USER_GRANT objects in 0 seconds
    28-MAY-24 03:26:50.725: W-1 Processing object type DATABASE_EXPORT/SCHEMA/TABLESPACE_QUOTA
    28-MAY-24 03:26:50.764: W-1      Completed 3 TABLESPACE_QUOTA objects in 0 seconds
    28-MAY-24 03:26:50.764: W-1      Completed by worker 1 3 TABLESPACE_QUOTA objects in 0 seconds
    28-MAY-24 03:26:50.766: W-1 Processing object type DATABASE_EXPORT/RESOURCE_COST
    28-MAY-24 03:26:50.797: W-1      Completed 1 RESOURCE_COST objects in 0 seconds
    28-MAY-24 03:26:50.797: W-1      Completed by worker 1 1 RESOURCE_COST objects in 0 seconds
    28-MAY-24 03:26:50.799: W-1 Processing object type DATABASE_EXPORT/TRUSTED_DB_LINK
    28-MAY-24 03:26:50.833: W-1      Completed 1 TRUSTED_DB_LINK objects in 0 seconds
    28-MAY-24 03:26:50.833: W-1      Completed by worker 1 1 TRUSTED_DB_LINK objects in 0 seconds
    28-MAY-24 03:26:50.835: W-1 Processing object type DATABASE_EXPORT/DIRECTORY/DIRECTORY
    28-MAY-24 03:26:50.862: ORA-31684: Object type DIRECTORY:"DMPDIR" already exists

    28-MAY-24 03:26:50.868: W-1      Completed 2 DIRECTORY objects in 0 seconds
    28-MAY-24 03:26:50.868: W-1      Completed by worker 1 2 DIRECTORY objects in 0 seconds
    28-MAY-24 03:26:50.870: W-1 Processing object type DATABASE_EXPORT/DIRECTORY/GRANT/OWNER_GRANT/OBJECT_GRANT
    28-MAY-24 03:26:50.910: W-1      Completed 4 OBJECT_GRANT objects in 0 seconds
    28-MAY-24 03:26:50.910: W-1      Completed by worker 1 4 OBJECT_GRANT objects in 0 seconds
    28-MAY-24 03:26:50.912: W-1 Processing object type DATABASE_EXPORT/SCHEMA/PUBLIC_SYNONYM/SYNONYM
    28-MAY-24 03:26:50.951: W-1      Completed 1 SYNONYM objects in 0 seconds
    28-MAY-24 03:26:50.951: W-1      Completed by worker 1 1 SYNONYM objects in 0 seconds
    28-MAY-24 03:26:50.967: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/PRE_SYSTEM_ACTIONS/PROCACT_SYSTEM/LOGREP
    28-MAY-24 03:26:50.999: W-1      Completed 1 LOGREP objects in 0 seconds
    28-MAY-24 03:26:51.006: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/PRE_SYSTEM_ACTIONS/PROCACT_SYSTEM/RMGR
    28-MAY-24 03:26:51.028: W-1      Completed 1 RMGR objects in 1 seconds
    28-MAY-24 03:26:51.050: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/PROCOBJ/RMGR
    28-MAY-24 03:26:51.071: W-1      Completed 7 RMGR objects in 0 seconds
    28-MAY-24 03:26:51.073: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/PROCOBJ/SCHEDULER
    28-MAY-24 03:26:51.230: W-1      Completed 17 SCHEDULER objects in 0 seconds
    28-MAY-24 03:26:51.251: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/POST_SYSTEM_ACTIONS/PROCACT_SYSTEM/RMGR
    28-MAY-24 03:26:51.356: W-1      Completed 1 RMGR objects in 0 seconds
    28-MAY-24 03:26:51.358: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/POST_SYSTEM_ACTIONS/PROCACT_SYSTEM/SERVERM
    28-MAY-24 03:26:51.402: W-1      Completed 1 SERVERM objects in 0 seconds
    28-MAY-24 03:26:51.403: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/POST_SYSTEM_ACTIONS/PROCACT_SYSTEM/SRVR
    28-MAY-24 03:26:51.473: W-1      Completed 1 SRVR objects in 0 seconds
    28-MAY-24 03:26:51.475: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/POST_SYSTEM_ACTIONS/PROCACT_SYSTEM/SEC
    28-MAY-24 03:26:51.518: W-1      Completed 1 SEC objects in 0 seconds
    28-MAY-24 03:26:51.539: W-1 Processing object type DATABASE_EXPORT/SCHEMA/PROCACT_SCHEMA/LOGREP
    28-MAY-24 03:26:51.553: W-1      Completed 5 LOGREP objects in 0 seconds
    28-MAY-24 03:26:51.560: W-1 Processing object type DATABASE_EXPORT/EARLY_OPTIONS/VIEWS_AS_TABLES/TABLE
    28-MAY-24 03:26:52.124: W-1      Completed 1 TABLE objects in 1 seconds
    28-MAY-24 03:26:52.124: W-1      Completed by worker 1 1 TABLE objects in 1 seconds
    28-MAY-24 03:26:52.144: W-1 Processing object type DATABASE_EXPORT/EARLY_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA
    28-MAY-24 03:26:52.779: W-1 . . imported "SYS"."KU$_EXPORT_USER_MAP"                   5.9 KB      24 rows in 0 seconds using direct_path
    28-MAY-24 03:26:52.795: W-1 Processing object type DATABASE_EXPORT/EARLY_POST_INSTANCE_IMPCALLOUT/MARKER/DATAPUMP
    28-MAY-24 03:26:52.800: W-1      Completed 1 DATAPUMP objects in 0 seconds
    28-MAY-24 03:26:52.807: W-1      Completed 1 [internal] EARLY_POST_INSTANCE objects in 0 seconds
    28-MAY-24 03:26:52.807: W-1      Completed by worker 1 1 MARKER objects in 0 seconds
    28-MAY-24 03:26:52.809: W-1 Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/TABLE
    28-MAY-24 03:26:53.454: W-2 Startup on instance 1 took 1 seconds
    28-MAY-24 03:26:53.456: W-3 Startup on instance 1 took 1 seconds
    28-MAY-24 03:26:53.463: W-4 Startup on instance 1 took 1 seconds
    28-MAY-24 03:26:53.803: W-4      Completed 17 TABLE objects in 1 seconds
    28-MAY-24 03:26:53.803: W-4      Completed by worker 1 8 TABLE objects in 1 seconds
    28-MAY-24 03:26:53.803: W-4      Completed by worker 2 5 TABLE objects in 0 seconds
    28-MAY-24 03:26:53.803: W-4      Completed by worker 3 4 TABLE objects in 0 seconds
    28-MAY-24 03:26:54.811: W-1 Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/TABLE_DATA
    28-MAY-24 03:26:54.886: W-3 . . imported "SYS"."AMGT$DP$DAM_CONFIG_PARAM$"             6.5 KB      14 rows in 0 seconds using direct_path
    28-MAY-24 03:26:54.908: W-3 . . imported "SYS"."DP$TSDP_SUBPOL$"                       6.3 KB       1 rows in 0 seconds using direct_path
    28-MAY-24 03:26:54.930: W-3 . . imported "SYS"."DP$TSDP_PARAMETER$"                      6 KB       1 rows in 0 seconds using direct_path
    28-MAY-24 03:26:54.953: W-3 . . imported "SYS"."DP$TSDP_POLICY$"                       5.9 KB       1 rows in 0 seconds using direct_path
    28-MAY-24 03:26:54.957: W-3 . . imported "AUDSYS"."AMGT$DP$AUD$UNIFIED":"AUD_UNIFIED_P0"     51 KB       0 rows in 0 seconds using direct_path
    28-MAY-24 03:26:54.959: W-3 . . imported "SYS"."AMGT$DP$AUD$"                         23.5 KB       0 rows in 0 seconds using direct_path
    28-MAY-24 03:26:54.961: W-3 . . imported "SYS"."AMGT$DP$DAM_CLEANUP_EVENTS$"           7.2 KB       0 rows in 0 seconds using direct_path
    28-MAY-24 03:26:54.963: W-3 . . imported "SYS"."AMGT$DP$DAM_CLEANUP_JOBS$"             7.2 KB       0 rows in 0 seconds using direct_path
    28-MAY-24 03:26:54.965: W-3 . . imported "SYS"."DP$TSDP_ASSOCIATION$"                    0 KB       0 rows in 0 seconds using direct_path
    28-MAY-24 03:26:54.967: W-3 . . imported "SYS"."DP$TSDP_CONDITION$"                      0 KB       0 rows in 0 seconds using direct_path
    28-MAY-24 03:26:54.968: W-3 . . imported "SYS"."DP$TSDP_FEATURE_POLICY$"                 0 KB       0 rows in 0 seconds using direct_path
    28-MAY-24 03:26:54.970: W-3 . . imported "SYS"."DP$TSDP_PROTECTION$"                     0 KB       0 rows in 0 seconds using direct_path
    28-MAY-24 03:26:54.972: W-3 . . imported "SYS"."DP$TSDP_SENSITIVE_DATA$"                 0 KB       0 rows in 0 seconds using direct_path
    28-MAY-24 03:26:54.973: W-3 . . imported "SYS"."DP$TSDP_SENSITIVE_TYPE$"                 0 KB       0 rows in 0 seconds using direct_path
    28-MAY-24 03:26:54.975: W-3 . . imported "SYS"."DP$TSDP_SOURCE$"                         0 KB       0 rows in 0 seconds using direct_path
    28-MAY-24 03:26:54.977: W-3 . . imported "SYSTEM"."REDO_DB_TMP"                          0 KB       0 rows in 0 seconds using direct_path
    28-MAY-24 03:26:54.979: W-3 . . imported "SYSTEM"."REDO_LOG_TMP"                         0 KB       0 rows in 0 seconds using direct_path
    28-MAY-24 03:26:54.986: W-2 Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/VIEWS_AS_TABLES/TABLE
    28-MAY-24 03:26:55.395: W-3      Completed 13 TABLE objects in 1 seconds
    28-MAY-24 03:26:55.395: W-3      Completed by worker 1 3 TABLE objects in 1 seconds
    28-MAY-24 03:26:55.395: W-3      Completed by worker 2 6 TABLE objects in 1 seconds
    28-MAY-24 03:26:55.395: W-3      Completed by worker 3 1 TABLE objects in 1 seconds
    28-MAY-24 03:26:55.395: W-3      Completed by worker 4 3 TABLE objects in 1 seconds
    28-MAY-24 03:26:55.402: W-4 Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA
    28-MAY-24 03:26:55.436: W-1 . . imported "SYS"."AMGT$DP$AUDTAB$TBS$FOR_EXPORT"           6 KB       2 rows in 0 seconds using direct_path
    28-MAY-24 03:26:55.438: W-1 . . imported "SYS"."DP$DBA_SENSITIVE_DATA"                   0 KB       0 rows in 0 seconds using direct_path
    28-MAY-24 03:26:55.440: W-1 . . imported "SYS"."DP$DBA_TSDP_POLICY_PROTECTION"           0 KB       0 rows in 0 seconds using direct_path
    28-MAY-24 03:26:55.441: W-1 . . imported "SYS"."AMGT$DP$FGA_LOG$FOR_EXPORT"              0 KB       0 rows in 0 seconds using direct_path
    28-MAY-24 03:26:55.443: W-1 . . imported "SYS"."NACL$_ACE_IMP"                           0 KB       0 rows in 0 seconds using direct_path
    28-MAY-24 03:26:55.462: W-1 . . imported "SYS"."NACL$_HOST_IMP"                        6.9 KB       1 rows in 0 seconds using direct_path
    28-MAY-24 03:26:55.464: W-1 . . imported "SYS"."NACL$_WALLET_IMP"                        0 KB       0 rows in 0 seconds using direct_path
    28-MAY-24 03:26:55.466: W-1 . . imported "SYS"."DATAPUMP$SQL$TEXT"                       0 KB       0 rows in 0 seconds using direct_path
    28-MAY-24 03:26:55.468: W-1 . . imported "SYS"."DATAPUMP$SQL$"                           0 KB       0 rows in 0 seconds using direct_path
    28-MAY-24 03:26:55.470: W-1 . . imported "SYS"."DATAPUMP$SQLOBJ$AUXDATA"                 0 KB       0 rows in 0 seconds using direct_path
    28-MAY-24 03:26:55.472: W-1 . . imported "SYS"."DATAPUMP$SQLOBJ$DATA"                    0 KB       0 rows in 0 seconds using direct_path
    28-MAY-24 03:26:55.473: W-1 . . imported "SYS"."DATAPUMP$SQLOBJ$PLAN"                    0 KB       0 rows in 0 seconds using direct_path
    28-MAY-24 03:26:55.475: W-1 . . imported "SYS"."DATAPUMP$SQLOBJ$"                        0 KB       0 rows in 0 seconds using direct_path
    28-MAY-24 03:26:55.491: W-1 Processing object type DATABASE_EXPORT/NORMAL_POST_INSTANCE_IMPCALLOUT/MARKER/AUDIT_TRAILS
    28-MAY-24 03:26:55.729: W-1      Completed 10 AUDIT_TRAILS objects in 0 seconds
    28-MAY-24 03:26:55.731: W-1 Processing object type DATABASE_EXPORT/NORMAL_POST_INSTANCE_IMPCALLOUT/MARKER/NETWORK_ACL
    28-MAY-24 03:26:55.743: W-1      Completed 3 NETWORK_ACL objects in 0 seconds
    28-MAY-24 03:26:55.744: W-1 Processing object type DATABASE_EXPORT/NORMAL_POST_INSTANCE_IMPCALLOUT/MARKER/PSTDY
    28-MAY-24 03:26:55.782: W-1      Completed 2 PSTDY objects in 0 seconds
    28-MAY-24 03:26:55.784: W-1 Processing object type DATABASE_EXPORT/NORMAL_POST_INSTANCE_IMPCALLOUT/MARKER/SCHEDULER
    28-MAY-24 03:26:55.786: W-1      Completed 2 SCHEDULER objects in 0 seconds
    28-MAY-24 03:26:55.788: W-1 Processing object type DATABASE_EXPORT/NORMAL_POST_INSTANCE_IMPCALLOUT/MARKER/SMB
    28-MAY-24 03:26:55.809: W-1      Completed 6 SMB objects in 0 seconds
    28-MAY-24 03:26:55.811: W-1 Processing object type DATABASE_EXPORT/NORMAL_POST_INSTANCE_IMPCALLOUT/MARKER/SQL_FIREWALL
    28-MAY-24 03:26:55.813: W-1      Completed 5 SQL_FIREWALL objects in 0 seconds
    28-MAY-24 03:26:55.815: W-1 Processing object type DATABASE_EXPORT/NORMAL_POST_INSTANCE_IMPCALLOUT/MARKER/TSDP
    28-MAY-24 03:26:55.878: W-1      Completed 12 TSDP objects in 0 seconds
    28-MAY-24 03:26:55.922: W-3      Completed 1 [internal] Unknown objects in 0 seconds
    28-MAY-24 03:26:55.922: W-3      Completed by worker 1 1 MARKER objects in 0 seconds
    28-MAY-24 03:26:55.924: W-3 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/TABLE
    28-MAY-24 03:26:56.149: W-2      Completed 15 TABLE objects in 1 seconds
    28-MAY-24 03:26:56.149: W-2      Completed by worker 1 3 TABLE objects in 1 seconds
    28-MAY-24 03:26:56.149: W-2      Completed by worker 2 3 TABLE objects in 1 seconds
    28-MAY-24 03:26:56.149: W-2      Completed by worker 3 6 TABLE objects in 1 seconds
    28-MAY-24 03:26:56.149: W-2      Completed by worker 4 3 TABLE objects in 1 seconds
    28-MAY-24 03:26:56.156: W-1 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/TABLE_DATA
    28-MAY-24 03:26:56.220: W-3 . . imported "F1"."F1_RESULTS"                             1.4 MB   26439 rows in 0 seconds using direct_path
    28-MAY-24 03:26:56.277: W-3 . . imported "F1"."F1_DRIVERSTANDINGS"                   916.3 KB   34511 rows in 0 seconds using direct_path
    28-MAY-24 03:26:56.329: W-3 . . imported "F1"."F1_QUALIFYING"                          419 KB   10174 rows in 0 seconds using direct_path
    28-MAY-24 03:26:56.331: W-4 . . imported "F1"."F1_LAPTIMES"                             17 MB  571047 rows in 0 seconds using direct_path
    28-MAY-24 03:26:56.356: W-3 . . imported "F1"."F1_PITSTOPS"                          416.8 KB   10793 rows in 0 seconds using direct_path
    28-MAY-24 03:26:56.384: W-3 . . imported "F1"."F1_CONSTRUCTORSTANDINGS"              344.1 KB   13231 rows in 0 seconds using direct_path
    28-MAY-24 03:26:56.410: W-3 . . imported "F1"."F1_CONSTRUCTORRESULTS"                225.3 KB   12465 rows in 0 seconds using direct_path
    28-MAY-24 03:26:56.435: W-3 . . imported "F1"."F1_RACES"                             131.4 KB    1125 rows in 0 seconds using direct_path
    28-MAY-24 03:26:56.459: W-3 . . imported "F1"."F1_DRIVERS"                            88.1 KB     859 rows in 0 seconds using direct_path
    28-MAY-24 03:26:56.482: W-3 . . imported "F1"."F1_CONSTRUCTORS"                         23 KB     212 rows in 0 seconds using direct_path
    28-MAY-24 03:26:56.507: W-3 . . imported "F1"."F1_CIRCUITS"                           17.5 KB      77 rows in 0 seconds using direct_path
    28-MAY-24 03:26:56.530: W-3 . . imported "F1"."F1_SEASONS"                              10 KB      75 rows in 0 seconds using direct_path
    28-MAY-24 03:26:56.553: W-3 . . imported "F1"."F1_STATUS"                              7.8 KB     139 rows in 0 seconds using direct_path
    28-MAY-24 03:26:56.576: W-3 . . imported "SYSTEM"."TRACKING_TAB"                       5.5 KB       1 rows in 0 seconds using direct_path
    28-MAY-24 03:26:56.600: W-3 . . imported "F1"."F1_SPRINTRESULTS"                      29.9 KB     280 rows in 0 seconds using direct_path
    28-MAY-24 03:26:56.627: W-1 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/CONSTRAINT/CONSTRAINT
    28-MAY-24 03:26:57.385: W-3      Completed 22 CONSTRAINT objects in 1 seconds
    28-MAY-24 03:26:57.385: W-3      Completed by worker 4 22 CONSTRAINT objects in 1 seconds
    28-MAY-24 03:26:57.396: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER/AUDIT_TRAILS
    28-MAY-24 03:26:57.766: W-1      Completed 10 AUDIT_TRAILS objects in 0 seconds
    28-MAY-24 03:26:57.767: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER/DATAPUMP
    28-MAY-24 03:26:57.770: W-1      Completed 1 DATAPUMP objects in 0 seconds
    28-MAY-24 03:26:57.772: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER/NETWORK_ACL
    28-MAY-24 03:26:57.903: W-1      Completed 3 NETWORK_ACL objects in 0 seconds
    28-MAY-24 03:26:57.905: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER/PSTDY
    28-MAY-24 03:26:57.910: W-1      Completed 2 PSTDY objects in 0 seconds
    28-MAY-24 03:26:57.912: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER/SCHEDULER
    28-MAY-24 03:26:57.913: W-1      Completed 2 SCHEDULER objects in 0 seconds
    28-MAY-24 03:26:57.915: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER/SMB
    28-MAY-24 03:26:59.729: W-1      Completed 6 SMB objects in 2 seconds
    28-MAY-24 03:26:59.731: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER/SQL_FIREWALL
    28-MAY-24 03:26:59.733: W-1      Completed 5 SQL_FIREWALL objects in 0 seconds
    28-MAY-24 03:26:59.735: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER/TSDP
    28-MAY-24 03:26:59.890: W-1      Completed 12 TSDP objects in 0 seconds
    28-MAY-24 03:26:59.897: W-2      Completed 1 [internal] Unknown objects in 2 seconds
    28-MAY-24 03:26:59.897: W-2      Completed by worker 1 1 MARKER objects in 2 seconds
    28-MAY-24 03:26:59.899: W-2 Processing object type DATABASE_EXPORT/AUDIT
    28-MAY-24 03:26:59.960: W-3      Completed 31 AUDIT objects in 0 seconds
    28-MAY-24 03:26:59.960: W-3      Completed by worker 4 31 AUDIT objects in 0 seconds
    28-MAY-24 03:26:59.968: W-1 Processing object type DATABASE_EXPORT/POST_SYSTEM_IMPCALLOUT/MARKER/SCHEDULER
    28-MAY-24 03:26:59.973: W-1      Completed 1 SCHEDULER objects in 0 seconds
    28-MAY-24 03:26:59.975: W-1 Processing object type DATABASE_EXPORT/POST_SYSTEM_IMPCALLOUT/MARKER/WMSYS
    28-MAY-24 03:27:00.108: W-1      Completed 1 WMSYS objects in 1 seconds
    28-MAY-24 03:27:00.110: W-1 Processing object type DATABASE_EXPORT/POST_SYSTEM_IMPCALLOUT/MARKER/DATAPUMP
    28-MAY-24 03:27:00.131: W-1      Completed 1 DATAPUMP objects in 0 seconds
    28-MAY-24 03:27:00.138: W-2      Completed 1 [internal] Unknown objects in 1 seconds
    28-MAY-24 03:27:00.138: W-2      Completed by worker 1 1 MARKER objects in 1 seconds
    28-MAY-24 03:27:00.179: W-4      Completed 1 DATABASE_EXPORT/EARLY_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA objects in 0 seconds
    28-MAY-24 03:27:00.181: W-4      Completed 17 DATABASE_EXPORT/NORMAL_OPTIONS/TABLE_DATA objects in 0 seconds
    28-MAY-24 03:27:00.183: W-4      Completed 15 DATABASE_EXPORT/NORMAL_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA objects in 150 seconds
    28-MAY-24 03:27:00.184: W-4      Completed 15 DATABASE_EXPORT/SCHEMA/TABLE/TABLE_DATA objects in 0 seconds
    28-MAY-24 03:27:00.209: Job "IMPUSER"."SYS_IMPORT_FULL_01" completed with 33 error(s) at Tue May 28 03:27:00 2024 elapsed 0 00:00:14
    ```
    </details>

5. Examine the Data Pump log file for any critical issues. A full import usually produces a few errors or warnings, especially when going to a higher release and into a different architecture.

    * The roles `EM_EXPRESS_ALL`, `EM_EXPRESS_BASIC` and `DATAPATCH_ROLE` do not exist in Oracle Database 23ai causing the grants to fail.
    * The same applies to the `ORACLE_OCM` user.
    * An error related to traditional auditing that is desupported in Oracle Database 23ai.
    * This log file doesn't contain any critical issues.

6. Set the environment to the target database, *CDB23*, and connect.

    ```
    <copy>
    . cdb23
    sqlplus / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

7. Switch to *PURPLE* and gather dictionary statistics. Oracle recommends gathering dictionary statistics immediately after an import. 

    ```
    <copy>
    alter session set container=purple;
    exec dbms_stats.gather_schema_stats('SYS');
    exec dbms_stats.gather_schema_stats('SYSTEM');
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> alter session set container=purple;

    Session altered.

    SQL> exec dbms_stats.gather_schema_stats('SYS');

    PL/SQL procedure successfully completed.

    SQL> exec dbms_stats.gather_schema_stats('SYSTEM');

    PL/SQL procedure successfully completed.
    ```
    </details>

8. Gather database statistics. In the export, you excluded statistics, so, you need to re-gather statistics.

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

9. Verify your database has been imported. Check the number of objects in the *F1* schema.

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

10. Perform a more extensive check. Verify the actual data. Find the best race of the Danish driver, *Kevin Magnussen*.

    ```
    <copy>
    select ra.name || ' ' || ra.year as race
    from f1.f1_races ra,
         f1.f1_results re,
         f1.f1_drivers d
    where d.forename='Kevin'
        and d.surname='Magnussen'
        and re.position=2
        and d.driverid=re.driverid
        and ra.raceid=re.raceid;
    </copy>
    ```

    * *Kevin Magnussen* got on podium as runner-up in Australia 2014 - his first F1 appearance.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> select ra.name || ' ' || ra.year as race
      2  from f1.f1_races ra,
      3       f1.f1_results re,
      4       f1.f1_drivers d
      5  where d.forename='Kevin'
      6      and d.surname='Magnussen'
      7      and re.position=2
      8      and d.driverid=re.driverid
      9      and ra.raceid=re.raceid;

    RACE
    --------------------------------------------------------------------------------
    Australian Grand Prix 2014
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

Data Pump is a very versatile utility. It allows you to import data into a higher release database and even from a non-CDB into a PDB. While doing so, you can use the powerful transformation options to customize the target database to fit your exact needs.

You can avoid an in-place upgrade and PDB conversion by using Data Pump. The source database is left untouched in case a rollback is needed.

* Documentation, [Oracle Data Pump Export Modes](https://docs.oracle.com/en/database/oracle/oracle-database/23/sutil/oracle-data-pump-export-utility.html#GUID-8E497131-6B9B-4CC8-AA50-35F480CAC2C4)
* Webinar, [Data Pump Best Practices and Real World Scenarios](https://www.youtube.com/watch?v=960ToLE-ZE8)
* Slides, [Data Pump Best Practices and Real World Scenarios](https://dohdatabase.com/wp-content/uploads/2023/04/vc15_datapump_masterdeck_final.pdf)

## Acknowledgements
* **Author** - Daniel Overby Hansen
* **Contributors** - Klaus Gronau, Rodrigo Jorge, Alex Zaballa, Mike Dietrich
* **Last Updated By/Date** - Daniel Overby Hansen, July 2024