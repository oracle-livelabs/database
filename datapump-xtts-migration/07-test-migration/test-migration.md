# Test Migration

## Introduction

In this lab, you will test the migration. A major advantage of the M5 script is that you can do a test migration. Using the restored data files on the target system, you can perform a test migration. After that, you can flash the data files back and resume the backup/restore cycle. 

In other words, you are using the production system and the production data for a test. This is very useful. 

A few words about the test migration. 
* It requires a short outage on the source database.
* You will perform a final backup and restore. *Final* just means that you take the backup with the tablespaces in read-only mode and at the same time perform a Data Pump full transportable export.
* During testing, the tablespaces in the target database remain in *read-only* mode. This prevents any changes to the underlying data files. Thus, you can still use them for the real migration - even after testing.
* After the test, you perform additional backup/restore cycles. You re-use the restored data files on the target database.

This is an optional lab. You can skip it and move directly to lab 8. 

Estimated Time: 20 Minutes

[Next-Level Platform Migration with Cross-Platform Transportable Tablespaces - lab 7](youtube:fgyDy-QcV_o?start=1569)

### Objectives

In this optional lab, you will:

* Test the last part of the migration
* Flashback database
* Resume the backup/restore cycle

## Task 1: Perform test migration

You will test the migration by performing the final steps of the migration. However, at the end you flash back the target database and resume the backup/restore cycle.

1. Outage starts on the source database.

2. Use the *yellow* terminal 🟨. Set the environment to the source database.

    ```
    <copy>
    . ftex
    cd /home/oracle/m5
    </copy>

    -- Be sure to hit RETURN
    ```

3. Start a level 1 final backup. When you start the driver script with `L1F`, it performs not only the final backup but also sets the tablespaces in *read-only* mode and starts a Data Pump full transportable export. When prompted for *system password*, enter *ftexuser*.

    ```
    <copy>
    ./dbmig_driver_m5.sh L1F
    </copy>
    ```

    * You start the driver script with the argument *L1F*.
    * The *system password* is for the user *ftexuser*. This user is specified in the M5 properties file.
    * Before starting the backup, the script sets the tablespaces read-only. This is causing the outage.
    * After the backup, the script starts Data Pump to perform a full transportable export. 

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ ./dbmig_driver_m5.sh L1F
    Properties file found, sourcing.
    LOG and CMD directories found
    2024-07-02 19:13:39 - 1719947619535: Requested L1F backup for pid 14750.  Using DISK destination, 4 channels and 64G section size.
    2024-07-02 19:13:39 - 1719947619542: Performing L1F backup for pid 14750
    ============================================
    Enter the system password to perform read only tablespaces
    
    Connected successfully
    Oracle authentication successful
    
    Tablespace altered.
    
    RMAN> 2> 3> 4> RMAN> RMAN> 2> 3> 4> 5> 6> 7> 8> 9> 10> 11> 12> 13> RMAN>
    2024-07-02 19:13:47 - 1719947627015: No errors or warnings found in backup log file for pid 14750
    2024-07-02 19:13:47 - 1719947627032: Manually copy restore script to destination
    2024-07-02 19:13:47 - 1719947627034:  => /home/oracle/m5/cmd/restore_L1F_FTEX_240702191339.cmd
    
    Export: Release 19.0.0.0.0 - Production on Tue Jul 2 19:13:47 2024
    Version 19.21.0.0.0
    
    Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.
    
    Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    02-JUL-24 19:13:51.936: Starting "FTEXUSER"."SYS_EXPORT_FULL_01":  FTEXUSER/********@localhost/ftex parfile=/home/oracle/m5/cmd/    exp_FTEX_240702191339_xtts.par
    02-JUL-24 19:13:52.707: W-1 Startup took 0 seconds
    02-JUL-24 19:13:56.005: W-1 Processing object type DATABASE_EXPORT/EARLY_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA
    02-JUL-24 19:13:57.153: W-1 Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/TABLE_DATA
    02-JUL-24 19:13:58.225: W-1 Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA
    02-JUL-24 19:13:59.244: W-1 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/TABLE_DATA
    02-JUL-24 19:14:01.855: W-1 Processing object type DATABASE_EXPORT/PLUGTS_FULL/FULL/PLUGTS_TABLESPACE
    02-JUL-24 19:14:01.903: W-1      Completed  PLUGTS_TABLESPACE objects in  seconds
    02-JUL-24 19:14:01.945: W-1 Processing object type DATABASE_EXPORT/PLUGTS_FULL/PLUGTS_BLK
    02-JUL-24 19:14:02.052: W-1      Completed 1 PLUGTS_BLK objects in 1 seconds
    02-JUL-24 19:14:02.473: W-1 Processing object type DATABASE_EXPORT/END_PLUGTS_BLK
    02-JUL-24 19:14:02.477: W-1      Completed 1 PLUGTS_BLK objects in 0 seconds
    02-JUL-24 19:14:02.492: W-1 Processing object type DATABASE_EXPORT/PRE_SYSTEM_IMPCALLOUT/MARKER
    02-JUL-24 19:14:02.494: W-1      Completed 1 MARKER objects in 0 seconds
    02-JUL-24 19:14:02.501: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER
    02-JUL-24 19:14:02.504: W-1      Completed 1 MARKER objects in 0 seconds
    02-JUL-24 19:14:02.549: W-1 Processing object type DATABASE_EXPORT/TABLESPACE
    02-JUL-24 19:14:02.554: W-1      Completed 2 TABLESPACE objects in 0 seconds
    02-JUL-24 19:14:02.667: W-1 Processing object type DATABASE_EXPORT/PROFILE
    02-JUL-24 19:14:02.671: W-1      Completed 1 PROFILE objects in 0 seconds
    02-JUL-24 19:14:02.714: W-1 Processing object type DATABASE_EXPORT/SCHEMA/USER
    02-JUL-24 19:14:02.719: W-1      Completed 2 USER objects in 0 seconds
    02-JUL-24 19:14:02.764: W-1 Processing object type DATABASE_EXPORT/RADM_FPTM
    02-JUL-24 19:14:02.768: W-1      Completed 1 RADM_FPTM objects in 0 seconds
    02-JUL-24 19:14:02.939: W-1 Processing object type DATABASE_EXPORT/GRANT/SYSTEM_GRANT/PROC_SYSTEM_GRANT
    02-JUL-24 19:14:02.945: W-1      Completed 6 PROC_SYSTEM_GRANT objects in 0 seconds
    02-JUL-24 19:14:02.976: W-1 Processing object type DATABASE_EXPORT/SCHEMA/GRANT/SYSTEM_GRANT
    02-JUL-24 19:14:02.995: W-1      Completed 73 SYSTEM_GRANT objects in 0 seconds
    02-JUL-24 19:14:03.016: W-1 Processing object type DATABASE_EXPORT/SCHEMA/ROLE_GRANT
    02-JUL-24 19:14:03.032: W-1      Completed 41 ROLE_GRANT objects in 0 seconds
    02-JUL-24 19:14:03.050: W-1 Processing object type DATABASE_EXPORT/SCHEMA/DEFAULT_ROLE
    02-JUL-24 19:14:03.055: W-1      Completed 4 DEFAULT_ROLE objects in 0 seconds
    02-JUL-24 19:14:03.074: W-1 Processing object type DATABASE_EXPORT/SCHEMA/ON_USER_GRANT
    02-JUL-24 19:14:03.079: W-1      Completed 2 ON_USER_GRANT objects in 0 seconds
    02-JUL-24 19:14:03.114: W-1 Processing object type DATABASE_EXPORT/SCHEMA/TABLESPACE_QUOTA
    02-JUL-24 19:14:03.119: W-1      Completed 3 TABLESPACE_QUOTA objects in 0 seconds
    02-JUL-24 19:14:03.135: W-1 Processing object type DATABASE_EXPORT/RESOURCE_COST
    02-JUL-24 19:14:03.139: W-1      Completed 1 RESOURCE_COST objects in 0 seconds
    02-JUL-24 19:14:03.214: W-1 Processing object type DATABASE_EXPORT/TRUSTED_DB_LINK
    02-JUL-24 19:14:03.218: W-1      Completed 1 TRUSTED_DB_LINK objects in 0 seconds
    02-JUL-24 19:14:03.283: W-1 Processing object type DATABASE_EXPORT/DIRECTORY/DIRECTORY
    02-JUL-24 19:14:03.287: W-1      Completed 1 DIRECTORY objects in 0 seconds
    02-JUL-24 19:14:03.487: W-1 Processing object type DATABASE_EXPORT/DIRECTORY/GRANT/OWNER_GRANT/OBJECT_GRANT
    02-JUL-24 19:14:03.491: W-1      Completed 2 OBJECT_GRANT objects in 0 seconds
    02-JUL-24 19:14:04.417: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/PRE_SYSTEM_ACTIONS/PROCACT_SYSTEM
    02-JUL-24 19:14:04.492: W-1      Completed 2 PROCACT_SYSTEM objects in 0 seconds
    02-JUL-24 19:14:04.666: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/PROCOBJ
    02-JUL-24 19:14:04.676: W-1      Completed 23 PROCOBJ objects in 0 seconds
    02-JUL-24 19:14:05.118: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/POST_SYSTEM_ACTIONS/PROCACT_SYSTEM
    02-JUL-24 19:14:05.153: W-1      Completed 3 PROCACT_SYSTEM objects in 1 seconds
    02-JUL-24 19:14:05.647: W-1 Processing object type DATABASE_EXPORT/SCHEMA/PROCACT_SCHEMA
    02-JUL-24 19:14:05.652: W-1      Completed 5 PROCACT_SCHEMA objects in 0 seconds
    02-JUL-24 19:14:14.772: W-1 Processing object type DATABASE_EXPORT/EARLY_OPTIONS/VIEWS_AS_TABLES/TABLE
    02-JUL-24 19:14:14.800: W-1      Completed 1 TABLE objects in 4 seconds
    02-JUL-24 19:14:14.850: W-1 Processing object type DATABASE_EXPORT/EARLY_POST_INSTANCE_IMPCALLOUT/MARKER
    02-JUL-24 19:14:14.853: W-1      Completed 1 MARKER objects in 0 seconds
    02-JUL-24 19:14:30.675: W-1 Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/TABLE
    02-JUL-24 19:14:51.445: W-1      Completed 41 TABLE objects in 36 seconds
    02-JUL-24 19:14:54.757: W-1 Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/VIEWS_AS_TABLES/TABLE
    02-JUL-24 19:15:06.741: W-1      Completed 17 TABLE objects in 15 seconds
    02-JUL-24 19:15:06.846: W-1 Processing object type DATABASE_EXPORT/NORMAL_POST_INSTANCE_IMPCALLOUT/MARKER
    02-JUL-24 19:15:06.849: W-1      Completed 1 MARKER objects in 0 seconds
    02-JUL-24 19:15:08.408: W-1 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/TABLE
    02-JUL-24 19:15:17.514: W-1      Completed 15 TABLE objects in 11 seconds
    02-JUL-24 19:15:18.318: W-1 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/COMMENT
    02-JUL-24 19:15:20.254: W-1 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/INDEX/INDEX
    02-JUL-24 19:15:21.275: W-1 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/CONSTRAINT/CONSTRAINT
    02-JUL-24 19:15:21.301: W-1      Completed 22 CONSTRAINT objects in 1 seconds
    02-JUL-24 19:15:22.510: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER
    02-JUL-24 19:15:22.513: W-1      Completed 1 MARKER objects in 0 seconds
    02-JUL-24 19:15:25.500: W-1 Processing object type DATABASE_EXPORT/AUDIT_UNIFIED/AUDIT_POLICY_ENABLE
    02-JUL-24 19:15:25.551: W-1      Completed 2 AUDIT_POLICY_ENABLE objects in 0 seconds
    02-JUL-24 19:15:25.653: W-1 Processing object type DATABASE_EXPORT/POST_SYSTEM_IMPCALLOUT/MARKER
    02-JUL-24 19:15:25.656: W-1      Completed 1 MARKER objects in 0 seconds
    02-JUL-24 19:15:26.413: W-1 . . exported "SYS"."KU$_USER_MAPPING_VIEW"               5.882 KB      25 rows in 1 seconds using external_table
    02-JUL-24 19:15:26.808: W-1 . . exported "SYSTEM"."REDO_DB"                          25.59 KB       1 rows in 0 seconds using direct_path
    02-JUL-24 19:15:26.811: W-1 . . exported "WMSYS"."WM$WORKSPACES_TABLE$"              12.10 KB       1 rows in 0 seconds using direct_path
    02-JUL-24 19:15:27.069: W-1 . . exported "WMSYS"."WM$HINT_TABLE$"                    9.984 KB      97 rows in 0 seconds using direct_path
    02-JUL-24 19:15:27.072: W-1 . . exported "WMSYS"."WM$WORKSPACE_PRIV_TABLE$"          7.078 KB      11 rows in 1 seconds using direct_path
    02-JUL-24 19:15:27.096: W-1 . . exported "SYS"."DAM_CONFIG_PARAM$"                   6.531 KB      14 rows in 0 seconds using direct_path
    02-JUL-24 19:15:27.119: W-1 . . exported "SYS"."TSDP_SUBPOL$"                        6.328 KB       1 rows in 0 seconds using direct_path
    02-JUL-24 19:15:27.144: W-1 . . exported "WMSYS"."WM$NEXTVER_TABLE$"                 6.375 KB       1 rows in 0 seconds using direct_path
    02-JUL-24 19:15:27.168: W-1 . . exported "WMSYS"."WM$ENV_VARS$"                      6.015 KB       3 rows in 0 seconds using direct_path
    02-JUL-24 19:15:27.190: W-1 . . exported "SYS"."TSDP_PARAMETER$"                     5.953 KB       1 rows in 0 seconds using direct_path
    02-JUL-24 19:15:27.213: W-1 . . exported "SYS"."TSDP_POLICY$"                        5.921 KB       1 rows in 0 seconds using direct_path
    02-JUL-24 19:15:27.236: W-1 . . exported "WMSYS"."WM$VERSION_HIERARCHY_TABLE$"       5.984 KB       1 rows in 0 seconds using direct_path
    02-JUL-24 19:15:27.259: W-1 . . exported "WMSYS"."WM$EVENTS_INFO$"                   5.812 KB      12 rows in 0 seconds using direct_path
    02-JUL-24 19:15:27.326: W-1 . . exported "AUDSYS"."AUD$UNIFIED":"AUD_UNIFIED_P0"     50.95 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:15:27.421: W-1 . . exported "AUDSYS"."AUD$UNIFIED":"SYS_P261"           4.868 MB    2838 rows in 0 seconds using direct_path
    02-JUL-24 19:15:27.455: W-1 . . exported "AUDSYS"."AUD$UNIFIED":"SYS_P281"           55.14 KB       9 rows in 0 seconds using direct_path
    02-JUL-24 19:15:27.486: W-1 . . exported "SYS"."AUD$"                                23.46 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:15:27.509: W-1 . . exported "SYS"."DAM_CLEANUP_EVENTS$"                 7.187 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:15:27.532: W-1 . . exported "SYS"."DAM_CLEANUP_JOBS$"                   7.171 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:15:27.536: W-1 . . exported "SYS"."TSDP_ASSOCIATION$"                       0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:15:27.539: W-1 . . exported "SYS"."TSDP_CONDITION$"                         0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:15:27.543: W-1 . . exported "SYS"."TSDP_FEATURE_POLICY$"                    0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:15:27.547: W-1 . . exported "SYS"."TSDP_PROTECTION$"                        0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:15:27.550: W-1 . . exported "SYS"."TSDP_SENSITIVE_DATA$"                    0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:15:27.554: W-1 . . exported "SYS"."TSDP_SENSITIVE_TYPE$"                    0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:15:27.557: W-1 . . exported "SYS"."TSDP_SOURCE$"                            0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:15:27.560: W-1 . . exported "SYSTEM"."REDO_LOG"                             0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:15:27.564: W-1 . . exported "WMSYS"."WM$BATCH_COMPRESSIBLE_TABLES$"         0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:15:27.570: W-1 . . exported "WMSYS"."WM$CONSTRAINTS_TABLE$"                 0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:15:27.573: W-1 . . exported "WMSYS"."WM$CONS_COLUMNS$"                      0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:15:27.577: W-1 . . exported "WMSYS"."WM$LOCKROWS_INFO$"                     0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:15:27.581: W-1 . . exported "WMSYS"."WM$MODIFIED_TABLES$"                   0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:15:27.584: W-1 . . exported "WMSYS"."WM$MP_GRAPH_WORKSPACES_TABLE$"         0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:15:27.588: W-1 . . exported "WMSYS"."WM$MP_PARENT_WORKSPACES_TABLE$"        0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:15:27.592: W-1 . . exported "WMSYS"."WM$NESTED_COLUMNS_TABLE$"              0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:15:27.596: W-1 . . exported "WMSYS"."WM$RESOLVE_WORKSPACES_TABLE$"          0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:15:27.600: W-1 . . exported "WMSYS"."WM$RIC_LOCKING_TABLE$"                 0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:15:27.604: W-1 . . exported "WMSYS"."WM$RIC_TABLE$"                         0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:15:27.608: W-1 . . exported "WMSYS"."WM$RIC_TRIGGERS_TABLE$"                0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:15:27.611: W-1 . . exported "WMSYS"."WM$UDTRIG_DISPATCH_PROCS$"             0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:15:27.615: W-1 . . exported "WMSYS"."WM$UDTRIG_INFO$"                       0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:15:27.618: W-1 . . exported "WMSYS"."WM$VERSION_TABLE$"                     0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:15:27.621: W-1 . . exported "WMSYS"."WM$VT_ERRORS_TABLE$"                   0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:15:27.624: W-1 . . exported "WMSYS"."WM$WORKSPACE_SAVEPOINTS_TABLE$"        0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:15:28.150: W-1 . . exported "SYS"."AUDTAB$TBS$FOR_EXPORT"               5.960 KB       2 rows in 1 seconds using external_table
    02-JUL-24 19:15:28.153: W-1 . . exported "SYS"."DBA_SENSITIVE_DATA"                      0 KB       0 rows in 0 seconds using external_table
    02-JUL-24 19:15:28.165: W-1 . . exported "SYS"."DBA_TSDP_POLICY_PROTECTION"              0 KB       0 rows in 0 seconds using external_table
    02-JUL-24 19:15:28.171: W-1 . . exported "SYS"."FGA_LOG$FOR_EXPORT"                      0 KB       0 rows in 0 seconds using external_table
    02-JUL-24 19:15:28.230: W-1 . . exported "SYS"."NACL$_ACE_EXP"                           0 KB       0 rows in 0 seconds using external_table
    02-JUL-24 19:15:28.550: W-1 . . exported "SYS"."NACL$_HOST_EXP"                      6.914 KB       1 rows in 0 seconds using external_table
    02-JUL-24 19:15:28.555: W-1 . . exported "SYS"."NACL$_WALLET_EXP"                        0 KB       0 rows in 0 seconds using external_table
    02-JUL-24 19:15:28.560: W-1 . . exported "SYS"."SQL$TEXT_DATAPUMP"                       0 KB       0 rows in 0 seconds using external_table
    02-JUL-24 19:15:28.565: W-1 . . exported "SYS"."SQL$_DATAPUMP"                           0 KB       0 rows in 0 seconds using external_table
    02-JUL-24 19:15:28.571: W-1 . . exported "SYS"."SQLOBJ$AUXDATA_DATAPUMP"                 0 KB       0 rows in 0 seconds using external_table
    02-JUL-24 19:15:28.577: W-1 . . exported "SYS"."SQLOBJ$DATA_DATAPUMP"                    0 KB       0 rows in 0 seconds using external_table
    02-JUL-24 19:15:28.583: W-1 . . exported "SYS"."SQLOBJ$PLAN_DATAPUMP"                    0 KB       0 rows in 0 seconds using external_table
    02-JUL-24 19:15:28.588: W-1 . . exported "SYS"."SQLOBJ$_DATAPUMP"                        0 KB       0 rows in 0 seconds using external_table
    02-JUL-24 19:15:28.631: W-1 . . exported "SYSTEM"."SCHEDULER_JOB_ARGS"                   0 KB       0 rows in 0 seconds using external_table
    02-JUL-24 19:15:28.658: W-1 . . exported "SYSTEM"."SCHEDULER_PROGRAM_ARGS"               0 KB       0 rows in 0 seconds using external_table
    02-JUL-24 19:15:29.281: W-1 . . exported "WMSYS"."WM$EXP_MAP"                        7.718 KB       3 rows in 1 seconds using external_table
    02-JUL-24 19:15:29.306: W-1 . . exported "WMSYS"."WM$METADATA_MAP"                       0 KB       0 rows in 0 seconds using external_table
    02-JUL-24 19:15:32.026: W-1      Completed 1 DATABASE_EXPORT/EARLY_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA objects in 1 seconds
    02-JUL-24 19:15:32.091: W-1      Completed 43 DATABASE_EXPORT/NORMAL_OPTIONS/TABLE_DATA objects in 1 seconds
    02-JUL-24 19:15:32.094: W-1      Completed 17 DATABASE_EXPORT/NORMAL_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA objects in 2 seconds
    02-JUL-24 19:15:34.016: W-1 Master table "FTEXUSER"."SYS_EXPORT_FULL_01" successfully loaded/unloaded
    02-JUL-24 19:15:34.042: ******************************************************************************
    02-JUL-24 19:15:34.043: Dump file set for FTEXUSER.SYS_EXPORT_FULL_01 is:
    02-JUL-24 19:15:34.044:   /home/oracle/m5/m5dir/exp_FTEX_240702191339.dmp
    02-JUL-24 19:15:34.044: ******************************************************************************
    02-JUL-24 19:15:34.046: Datafiles required for transportable tablespace USERS:
    02-JUL-24 19:15:34.050:   /u02/oradata/FTEX/datafile/o1_mf_users_m7v5qtos_.dbf
    02-JUL-24 19:15:34.082: Job "FTEXUSER"."SYS_EXPORT_FULL_01" successfully completed at Tue Jul 2 19:15:34 2024 elapsed 0 00:01:44
    
    
    BACKUP_TYPE   INPUT_BYTES(MB) OUTPUT_BYTES(MB) STATUS    START_TIME          END_TIME            ELAPSED_TIME(Min)
    ------------- --------------- ---------------- --------- ------------------- ------------------- -----------------
    DATAFILE FULL 20.304687       .046875          COMPLETED 07/02/2024:19:13:45 07/02/2024:19:13:46 .01    
    ```
    </details>

3. Connect to the source database.

    ```
    <copy>
    sqlplus / as sysdba
    </copy>
    ```

4. Stop the outage by setting the tablespaces back to read-write mode.

    ```
    <copy>
    alter tablespace users read write;
    </copy>
    ```

    * As soon as the tablespaces are back in read-write mode, you can allow the users to connect to the source database again. You complete the remaining part of the test migration on the target database without affecting the source database.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> alter tablespace users read write;
    
    Tablespace altered.
    ```
    </details>

5. Exit SQL*Plus. 
    
    ```
    <copy>
    exit
    </copy>
    ```

6. Switch to the *blue* terminal 🟦. Restore the test backup.

    ```
    <copy>
    cd /home/oracle/m5/cmd
    export L1FSCRIPT=$(ls -tr restore_L1F* | tail -1) 
    . cdb23
    cd /home/oracle/m5
    rman target "sys/oracle@'localhost/violet'" cmdfile=/home/oracle/m5/cmd/$L1FSCRIPT    
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ cd /home/oracle/m5/cmd
    $ export L1FSCRIPT=$(ls -tr restore_L1F* | tail -1)
    $ . cdb23
    $ cd /home/oracle/m5
    $ rman target "sys/oracle@'localhost/violet'" cmdfile=/home/oracle/m5/cmd/$L1FSCRIPT
    
    Recovery Manager: Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems on Tue Jul 2 19:19:00 2024
    Version 23.5.0.24.07
    
    Copyright (c) 1982, 2024, Oracle and/or its affiliates.  All rights reserved.
    
    connected to target database: CDB23:VIOLET (DBID=1874382390)
    
    RMAN> SPOOL LOG TO log/restore_L1F_FTEX_240702191339.log;
    2> SPOOL TRACE TO log/restore_L1F_FTEX_240702191339.trc;
    3> SET EVENT FOR catalog_foreign_datafile_restore TO 1;
    4> SET ECHO ON;
    5> SHOW ALL;
    6> DEBUG ON;
    7> RUN
    8> {
    9> ALLOCATE CHANNEL DISK1 DEVICE TYPE DISK FORMAT '/home/oracle/m5/rman/L1F_%d_%N_%t_%s_%p';
    10> ALLOCATE CHANNEL DISK2 DEVICE TYPE DISK FORMAT '/home/oracle/m5/rman/L1F_%d_%N_%t_%s_%p';
    11> ALLOCATE CHANNEL DISK3 DEVICE TYPE DISK FORMAT '/home/oracle/m5/rman/L1F_%d_%N_%t_%s_%p';
    12> ALLOCATE CHANNEL DISK4 DEVICE TYPE DISK FORMAT '/home/oracle/m5/rman/L1F_%d_%N_%t_%s_%p';
    13> RESTORE ALL FOREIGN DATAFILES TO NEW FROM BACKUPSET
    14> '/home/oracle/m5/rman/L1F_FTEX_USERS_1173294825_5_1';}
    15>    
    ```
    </details>

7. Perform the Data Pump transportable import. In the next lab, the instructions will describe in detail what happens. However, for now, just start the import directly. When prompted for a password, enter *oracle*.

    ```
    <copy>
    cd /home/oracle/m5/log
    export L1FLOGFILE=$(ls -tr restore_L1F*log | tail -1)
    cd /home/oracle/m5/m5dir
    export DMPFILE=$(ls -tr exp_FTEX*dmp | tail -1)
    cd /home/oracle/m5
    . cdb23
    ./impdp.sh $DMPFILE log/$L1FLOGFILE run-readonly N
    </copy>

    -- Be sure to hit RETURN
    ```
  
    * The import runs as *SYSTEM*.
    * The script starts the import with the Data Pump parameter `TRANSPORTABLE=KEEP_READ_ONLY`. This performs the import but keeps the tablespaces in *read-only* mode. 
    * By keeping the tablespaces in *read-only* mode, your test won't make any changes to the data files.
    * The import runs for a few minutes. 
    * For now, you disregard any errors or warnings in the Data Pump output or log file.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ cd /home/oracle/m5/log
    $ export L1FLOGFILE=$(ls -tr restore_L1F*log | tail -1)
    $ cd /home/oracle/m5/m5dir
    $ export DMPFILE=$(ls -tr exp_FTEX*dmp | tail -1)
    $ cd ..
    $ . cdb23
    $ ./impdp.sh $DMPFILE log/$L1FLOGFILE run-readonly N
    Running in Read Only, for the final run you must flashback the database to the restore point created now
    
    Restore point created.
    
    
    NAME				SCN TIME					     GUA STORAGE_SIZE
    ------------------------ ---------- ------------------------------------------------ --- ------------
    BEFORE_IMP_240702192231      748325 02-JUL-24 07.22.31.000000000 PM		     YES    209715200
    
    
    Import: Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems on Tue Jul 2 19:22:32 2024
    Version 23.5.0.24.07
    
    Copyright (c) 1982, 2024, Oracle and/or its affiliates.  All rights reserved.
    Password:
    
    Connected to: Oracle Database 23ai Enterprise Edition Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems
    02-JUL-24 19:22:47.147: W-1 Startup on instance 1 took 1 seconds
    02-JUL-24 19:22:49.117: W-1 Master table "SYSTEM"."SYS_IMPORT_TRANSPORTABLE_01" successfully loaded/unloaded
    02-JUL-24 19:22:49.503: Starting "SYSTEM"."SYS_IMPORT_TRANSPORTABLE_01":  system/********@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)    (HOST=localhost)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=VIOLET))) parfile=imp_CDB23_240702192231_xtts.par
    02-JUL-24 19:22:49.611: W-1 Processing object type DATABASE_EXPORT/PRE_SYSTEM_IMPCALLOUT/MARKER/SCHEDULER
    02-JUL-24 19:22:49.645: W-1      Completed 1 SCHEDULER objects in 0 seconds
    02-JUL-24 19:22:49.648: W-1 Processing object type DATABASE_EXPORT/PRE_SYSTEM_IMPCALLOUT/MARKER/WMSYS
    02-JUL-24 19:22:50.089: W-1      Completed 1 WMSYS objects in 1 seconds
    02-JUL-24 19:22:50.092: W-1 Processing object type DATABASE_EXPORT/PRE_SYSTEM_IMPCALLOUT/MARKER/DATAPUMP
    02-JUL-24 19:22:50.132: W-1      Completed 1 DATAPUMP objects in 0 seconds
    02-JUL-24 19:22:50.176: W-1      Completed 1 [internal] PRE_SYSTEM objects in 1 seconds
    02-JUL-24 19:22:50.176: W-1      Completed by worker 1 1 MARKER objects in 1 seconds
    02-JUL-24 19:22:50.195: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER/AUDIT_TRAILS
    02-JUL-24 19:22:50.322: W-1      Completed 10 AUDIT_TRAILS objects in 0 seconds
    02-JUL-24 19:22:50.325: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER/DATAPUMP
    02-JUL-24 19:22:50.331: W-1      Completed 1 DATAPUMP objects in 0 seconds
    02-JUL-24 19:22:50.334: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER/NETWORK_ACL
    02-JUL-24 19:22:50.368: W-1      Completed 3 NETWORK_ACL objects in 0 seconds
    02-JUL-24 19:22:50.371: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER/PSTDY
    02-JUL-24 19:22:50.386: W-1      Completed 2 PSTDY objects in 0 seconds
    02-JUL-24 19:22:50.389: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER/SCHEDULER
    02-JUL-24 19:22:50.416: W-1      Completed 2 SCHEDULER objects in 0 seconds
    02-JUL-24 19:22:50.419: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER/SMB
    02-JUL-24 19:22:50.463: W-1      Completed 6 SMB objects in 0 seconds
    02-JUL-24 19:22:50.467: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER/SQL_FIREWALL
    02-JUL-24 19:22:50.470: W-1      Completed 5 SQL_FIREWALL objects in 0 seconds
    02-JUL-24 19:22:50.473: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER/TSDP
    02-JUL-24 19:22:50.550: W-1      Completed 12 TSDP objects in 0 seconds
    02-JUL-24 19:22:50.553: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER/WMSYS
    02-JUL-24 19:22:50.661: W-1      Completed 53 WMSYS objects in 0 seconds
    02-JUL-24 19:22:50.672: W-1      Completed 1 [internal] PRE_INSTANCE objects in 0 seconds
    02-JUL-24 19:22:50.672: W-1      Completed by worker 1 1 MARKER objects in 0 seconds
    02-JUL-24 19:22:50.675: W-1 Processing object type DATABASE_EXPORT/PLUGTS_FULL/PLUGTS_BLK
    02-JUL-24 19:22:50.867: W-1      Completed 1 PLUGTS_BLK objects in 0 seconds
    02-JUL-24 19:22:50.867: W-1      Completed by worker 1 1 PLUGTS_BLK objects in 0 seconds
    02-JUL-24 19:22:50.869: W-1 Processing object type DATABASE_EXPORT/TABLESPACE
    02-JUL-24 19:22:50.929: ORA-31684: Object type TABLESPACE:"UNDOTBS1" already exists
    
    02-JUL-24 19:22:50.929: ORA-31684: Object type TABLESPACE:"TEMP" already exists
    
    02-JUL-24 19:22:50.942: W-1      Completed 2 TABLESPACE objects in 0 seconds
    02-JUL-24 19:22:50.942: W-1      Completed by worker 1 2 TABLESPACE objects in 0 seconds
    02-JUL-24 19:22:50.954: W-1 Processing object type DATABASE_EXPORT/PROFILE
    02-JUL-24 19:22:51.015: W-1      Completed 1 PROFILE objects in 1 seconds
    02-JUL-24 19:22:51.015: W-1      Completed by worker 1 1 PROFILE objects in 1 seconds
    02-JUL-24 19:22:51.018: W-1 Processing object type DATABASE_EXPORT/SCHEMA/USER
    02-JUL-24 19:22:51.093: W-1      Completed 2 USER objects in 0 seconds
    02-JUL-24 19:22:51.093: W-1      Completed by worker 1 2 USER objects in 0 seconds
    02-JUL-24 19:22:51.096: W-1 Processing object type DATABASE_EXPORT/RADM_FPTM
    02-JUL-24 19:22:51.138: ORA-39083: Object type RADM_FPTM failed to create with error:
    ORA-01843: An invalid month was specified.
    
    Failing sql is:
    BEGIN DBMS_REDACT.UPDATE_FULL_REDACTION_VALUES(number_val => 0,binfloat_val => 0.000000,bindouble_val => 0.000000,char_val => ' ',    varchar_val => ' ',nchar_val => ' ',nvarchar_val => ' ',date_val => '01-01-2001 00:00:00',ts_val => '01-JAN-01 01.00.00.000000 AM',    tswtz_val => '01-JAN-01 01.00.00.000000 AM +00:00');END;
    
    02-JUL-24 19:22:51.148: W-1      Completed 1 RADM_FPTM objects in 0 seconds
    02-JUL-24 19:22:51.148: W-1      Completed by worker 1 1 RADM_FPTM objects in 0 seconds
    02-JUL-24 19:22:51.170: W-1 Processing object type DATABASE_EXPORT/GRANT/SYSTEM_GRANT/PROC_SYSTEM_GRANT/RULE
    02-JUL-24 19:22:51.202: W-1      Completed 1 RULE objects in 0 seconds
    02-JUL-24 19:22:51.205: W-1 Processing object type DATABASE_EXPORT/GRANT/SYSTEM_GRANT/PROC_SYSTEM_GRANT/AQ
    02-JUL-24 19:22:51.223: W-1      Completed 1 AQ objects in 0 seconds
    02-JUL-24 19:22:51.225: W-1 Processing object type DATABASE_EXPORT/GRANT/SYSTEM_GRANT/PROC_SYSTEM_GRANT/RMGR
    02-JUL-24 19:22:51.242: ORA-39083: Object type RMGR:PROC_SYSTEM_GRANT failed to create with error:
    ORA-29393: user EM_EXPRESS_ALL does not exist or is not logged on
    
    02-JUL-24 19:22:51.249: W-1      Completed 1 RMGR objects in 0 seconds
    02-JUL-24 19:22:51.252: W-1 Processing object type DATABASE_EXPORT/GRANT/SYSTEM_GRANT/PROC_SYSTEM_GRANT/SQL
    02-JUL-24 19:22:51.269: W-1      Completed 1 SQL objects in 0 seconds
    02-JUL-24 19:22:51.273: W-1 Processing object type DATABASE_EXPORT/GRANT/SYSTEM_GRANT/PROC_SYSTEM_GRANT/RULE
    02-JUL-24 19:22:51.279: W-1      Completed 2 RULE objects in 0 seconds
    02-JUL-24 19:22:51.290: W-1 Processing object type DATABASE_EXPORT/SCHEMA/GRANT/SYSTEM_GRANT
    02-JUL-24 19:22:51.443: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'DATAPATCH_ROLE' does not exist
    
    Failing sql is:
    GRANT ALTER SESSION TO "DATAPATCH_ROLE"
    
    02-JUL-24 19:22:51.443: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_BASIC' does not exist
    
    Failing sql is:
    GRANT CREATE SESSION TO "EM_EXPRESS_BASIC"
    
    02-JUL-24 19:22:51.443: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-00990: missing or invalid privilege
    
    Failing sql is:
    GRANT EM EXPRESS CONNECT TO "EM_EXPRESS_BASIC"
    
    02-JUL-24 19:22:51.443: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT ADVISOR TO "EM_EXPRESS_ALL"
    
    02-JUL-24 19:22:51.443: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT CREATE JOB TO "EM_EXPRESS_ALL"
    
    02-JUL-24 19:22:51.443: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT ADMINISTER SQL TUNING SET TO "EM_EXPRESS_ALL"
    
    02-JUL-24 19:22:51.443: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT ADMINISTER ANY SQL TUNING SET TO "EM_EXPRESS_ALL"
    
    02-JUL-24 19:22:51.443: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT ADMINISTER SQL MANAGEMENT OBJECT TO "EM_EXPRESS_ALL"
    
    02-JUL-24 19:22:51.443: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT ALTER SYSTEM TO "EM_EXPRESS_ALL"
    
    02-JUL-24 19:22:51.443: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT CREATE TABLESPACE TO "EM_EXPRESS_ALL"
    
    02-JUL-24 19:22:51.443: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT DROP TABLESPACE TO "EM_EXPRESS_ALL"
    
    02-JUL-24 19:22:51.443: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT ALTER TABLESPACE TO "EM_EXPRESS_ALL"
    
    02-JUL-24 19:22:51.443: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT GRANT ANY OBJECT PRIVILEGE TO "EM_EXPRESS_ALL"
    
    02-JUL-24 19:22:51.443: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT GRANT ANY PRIVILEGE TO "EM_EXPRESS_ALL"
    
    02-JUL-24 19:22:51.443: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT GRANT ANY ROLE TO "EM_EXPRESS_ALL"
    
    02-JUL-24 19:22:51.443: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT CREATE ROLE TO "EM_EXPRESS_ALL"
    
    02-JUL-24 19:22:51.443: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT DROP ANY ROLE TO "EM_EXPRESS_ALL"
    
    02-JUL-24 19:22:51.443: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT ALTER ANY ROLE TO "EM_EXPRESS_ALL"
    
    02-JUL-24 19:22:51.443: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT CREATE USER TO "EM_EXPRESS_ALL"
    
    02-JUL-24 19:22:51.443: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT DROP USER TO "EM_EXPRESS_ALL"
    
    02-JUL-24 19:22:51.443: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT ALTER USER TO "EM_EXPRESS_ALL"
    
    02-JUL-24 19:22:51.443: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT CREATE PROFILE TO "EM_EXPRESS_ALL"
    
    02-JUL-24 19:22:51.443: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT ALTER PROFILE TO "EM_EXPRESS_ALL"
    
    02-JUL-24 19:22:51.443: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT DROP PROFILE TO "EM_EXPRESS_ALL"
    
    02-JUL-24 19:22:51.443: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT SET CONTAINER TO "EM_EXPRESS_ALL"
    
    02-JUL-24 19:22:51.456: W-1      Completed 73 SYSTEM_GRANT objects in 0 seconds
    02-JUL-24 19:22:51.456: W-1      Completed by worker 1 73 SYSTEM_GRANT objects in 0 seconds
    02-JUL-24 19:22:51.459: W-1 Processing object type DATABASE_EXPORT/SCHEMA/ROLE_GRANT
    02-JUL-24 19:22:51.600: ORA-39083: Object type ROLE_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_BASIC' does not exist
    
    Failing sql is:
     GRANT "SELECT_CATALOG_ROLE" TO "EM_EXPRESS_BASIC"
    
    02-JUL-24 19:22:51.600: ORA-39083: Object type ROLE_GRANT failed to create with error:
    ORA-01919: Role 'EM_EXPRESS_ALL' does not exist.
    
    Failing sql is:
     GRANT "EM_EXPRESS_ALL" TO "DBA"
    
    02-JUL-24 19:22:51.600: ORA-39083: Object type ROLE_GRANT failed to create with error:
    ORA-01919: Role 'EM_EXPRESS_BASIC' does not exist.
    
    Failing sql is:
     GRANT "EM_EXPRESS_BASIC" TO "EM_EXPRESS_ALL"
    
    02-JUL-24 19:22:51.610: W-1      Completed 41 ROLE_GRANT objects in 0 seconds
    02-JUL-24 19:22:51.610: W-1      Completed by worker 1 41 ROLE_GRANT objects in 0 seconds
    02-JUL-24 19:22:51.612: W-1 Processing object type DATABASE_EXPORT/SCHEMA/DEFAULT_ROLE
    02-JUL-24 19:22:51.660: W-1      Completed 4 DEFAULT_ROLE objects in 0 seconds
    02-JUL-24 19:22:51.660: W-1      Completed by worker 1 4 DEFAULT_ROLE objects in 0 seconds
    02-JUL-24 19:22:51.662: W-1 Processing object type DATABASE_EXPORT/SCHEMA/ON_USER_GRANT
    02-JUL-24 19:22:51.706: W-1      Completed 2 ON_USER_GRANT objects in 0 seconds
    02-JUL-24 19:22:51.706: W-1      Completed by worker 1 2 ON_USER_GRANT objects in 0 seconds
    02-JUL-24 19:22:51.708: W-1 Processing object type DATABASE_EXPORT/SCHEMA/TABLESPACE_QUOTA
    02-JUL-24 19:22:51.760: W-1      Completed 3 TABLESPACE_QUOTA objects in 0 seconds
    02-JUL-24 19:22:51.760: W-1      Completed by worker 1 3 TABLESPACE_QUOTA objects in 0 seconds
    02-JUL-24 19:22:51.762: W-1 Processing object type DATABASE_EXPORT/RESOURCE_COST
    02-JUL-24 19:22:51.802: W-1      Completed 1 RESOURCE_COST objects in 0 seconds
    02-JUL-24 19:22:51.802: W-1      Completed by worker 1 1 RESOURCE_COST objects in 0 seconds
    02-JUL-24 19:22:51.805: W-1 Processing object type DATABASE_EXPORT/TRUSTED_DB_LINK
    02-JUL-24 19:22:51.851: W-1      Completed 1 TRUSTED_DB_LINK objects in 0 seconds
    02-JUL-24 19:22:51.851: W-1      Completed by worker 1 1 TRUSTED_DB_LINK objects in 0 seconds
    02-JUL-24 19:22:51.853: W-1 Processing object type DATABASE_EXPORT/DIRECTORY/DIRECTORY
    02-JUL-24 19:22:51.885: ORA-31684: Object type DIRECTORY:"M5DIR" already exists
    
    02-JUL-24 19:22:51.894: W-1      Completed 1 DIRECTORY objects in 0 seconds
    02-JUL-24 19:22:51.894: W-1      Completed by worker 1 1 DIRECTORY objects in 0 seconds
    02-JUL-24 19:22:51.897: W-1 Processing object type DATABASE_EXPORT/DIRECTORY/GRANT/OWNER_GRANT/OBJECT_GRANT
    02-JUL-24 19:22:51.945: W-1      Completed 2 OBJECT_GRANT objects in 0 seconds
    02-JUL-24 19:22:51.945: W-1      Completed by worker 1 2 OBJECT_GRANT objects in 0 seconds
    02-JUL-24 19:22:51.965: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/PRE_SYSTEM_ACTIONS/PROCACT_SYSTEM/LOGREP
    02-JUL-24 19:22:52.003: W-1      Completed 1 LOGREP objects in 1 seconds
    02-JUL-24 19:22:52.006: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/PRE_SYSTEM_ACTIONS/PROCACT_SYSTEM/RMGR
    02-JUL-24 19:22:52.050: W-1      Completed 1 RMGR objects in 0 seconds
    02-JUL-24 19:22:52.080: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/PROCOBJ/RMGR
    02-JUL-24 19:22:52.104: W-1      Completed 6 RMGR objects in 0 seconds
    02-JUL-24 19:22:52.107: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/PROCOBJ/SCHEDULER
    02-JUL-24 19:22:52.302: W-1      Completed 17 SCHEDULER objects in 0 seconds
    02-JUL-24 19:22:52.330: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/POST_SYSTEM_ACTIONS/PROCACT_SYSTEM/SRVR
    02-JUL-24 19:22:52.444: W-1      Completed 1 SRVR objects in 0 seconds
    02-JUL-24 19:22:52.447: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/POST_SYSTEM_ACTIONS/PROCACT_SYSTEM/RMGR
    02-JUL-24 19:22:52.577: W-1      Completed 1 RMGR objects in 0 seconds
    02-JUL-24 19:22:52.580: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/POST_SYSTEM_ACTIONS/PROCACT_SYSTEM/SEC
    02-JUL-24 19:22:52.629: W-1      Completed 1 SEC objects in 0 seconds
    02-JUL-24 19:22:52.657: W-1 Processing object type DATABASE_EXPORT/SCHEMA/PROCACT_SCHEMA/LOGREP
    02-JUL-24 19:22:52.676: W-1      Completed 5 LOGREP objects in 0 seconds
    02-JUL-24 19:22:52.687: W-1 Processing object type DATABASE_EXPORT/EARLY_OPTIONS/VIEWS_AS_TABLES/TABLE
    02-JUL-24 19:22:53.450: W-1      Completed 1 TABLE objects in 1 seconds
    02-JUL-24 19:22:53.450: W-1      Completed by worker 1 1 TABLE objects in 1 seconds
    02-JUL-24 19:22:53.476: W-1 Processing object type DATABASE_EXPORT/EARLY_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA
    02-JUL-24 19:22:53.597: W-1 . . imported "SYS"."KU$_EXPORT_USER_MAP"                   5.9 KB      25 rows in 0 seconds using direct_path
    02-JUL-24 19:22:53.617: W-1 Processing object type DATABASE_EXPORT/EARLY_POST_INSTANCE_IMPCALLOUT/MARKER/DATAPUMP
    02-JUL-24 19:22:53.631: W-1      Completed 1 DATAPUMP objects in 0 seconds
    02-JUL-24 19:22:53.646: W-1      Completed 1 [internal] EARLY_POST_INSTANCE objects in 0 seconds
    02-JUL-24 19:22:53.646: W-1      Completed by worker 1 1 MARKER objects in 0 seconds
    02-JUL-24 19:22:53.648: W-1 Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/TABLE
    02-JUL-24 19:22:54.355: W-4 Startup on instance 1 took 1 seconds
    02-JUL-24 19:22:54.358: W-3 Startup on instance 1 took 1 seconds
    02-JUL-24 19:22:54.416: W-2 Startup on instance 1 took 1 seconds
    02-JUL-24 19:22:56.162: W-1      Completed 41 TABLE objects in 3 seconds
    02-JUL-24 19:22:56.162: W-1      Completed by worker 1 10 TABLE objects in 2 seconds
    02-JUL-24 19:22:56.162: W-1      Completed by worker 2 11 TABLE objects in 2 seconds
    02-JUL-24 19:22:56.162: W-1      Completed by worker 3 10 TABLE objects in 2 seconds
    02-JUL-24 19:22:56.162: W-1      Completed by worker 4 10 TABLE objects in 2 seconds
    02-JUL-24 19:22:56.171: W-2 Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/TABLE_DATA
    02-JUL-24 19:22:56.292: W-4 . . imported "SYSTEM"."REDO_DB_TMP"                       25.6 KB       1 rows in 0 seconds using direct_path
    02-JUL-24 19:22:56.299: W-1 . . imported "WMSYS"."E$HINT_TABLE$"                        10 KB      97 rows in 0 seconds using direct_path
    02-JUL-24 19:22:56.336: W-1 . . imported "WMSYS"."E$WORKSPACE_PRIV_TABLE$"             7.1 KB      11 rows in 0 seconds using direct_path
    02-JUL-24 19:22:56.377: W-1 . . imported "SYS"."AMGT$DP$DAM_CONFIG_PARAM$"             6.5 KB      14 rows in 0 seconds using direct_path
    02-JUL-24 19:22:56.418: W-1 . . imported "SYS"."DP$TSDP_SUBPOL$"                       6.3 KB       1 rows in 0 seconds using direct_path
    02-JUL-24 19:22:56.456: W-1 . . imported "WMSYS"."E$NEXTVER_TABLE$"                    6.4 KB       1 rows in 0 seconds using direct_path
    02-JUL-24 19:22:56.491: W-1 . . imported "WMSYS"."E$ENV_VARS$"                           6 KB       3 rows in 0 seconds using direct_path
    02-JUL-24 19:22:56.527: W-1 . . imported "SYS"."DP$TSDP_PARAMETER$"                      6 KB       1 rows in 0 seconds using direct_path
    02-JUL-24 19:22:56.563: W-1 . . imported "SYS"."DP$TSDP_POLICY$"                       5.9 KB       1 rows in 0 seconds using direct_path
    02-JUL-24 19:22:56.598: W-1 . . imported "WMSYS"."E$VERSION_HIERARCHY_TABLE$"            6 KB       1 rows in 0 seconds using direct_path
    02-JUL-24 19:22:56.634: W-1 . . imported "WMSYS"."E$EVENTS_INFO$"                      5.8 KB      12 rows in 0 seconds using direct_path
    02-JUL-24 19:22:56.641: W-1 . . imported "AUDSYS"."AMGT$DP$AUD$UNIFIED":"AUD_UNIFIED_P0"     51 KB       0 rows in 0 seconds using     direct_path
    02-JUL-24 19:22:56.753: W-3 . . imported "WMSYS"."E$WORKSPACES_TABLE$"                12.1 KB       1 rows in 0 seconds using     external_table
    02-JUL-24 19:22:56.863: W-1 . . imported "AUDSYS"."AMGT$DP$AUD$UNIFIED":"SYS_P261"     4.9 MB    2838 rows in 0 seconds using direct_path
    02-JUL-24 19:22:56.901: W-1 . . imported "AUDSYS"."AMGT$DP$AUD$UNIFIED":"SYS_P281"    55.1 KB       9 rows in 0 seconds using direct_path
    02-JUL-24 19:22:56.905: W-1 . . imported "SYS"."AMGT$DP$AUD$"                         23.5 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:22:56.908: W-1 . . imported "SYS"."AMGT$DP$DAM_CLEANUP_EVENTS$"           7.2 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:22:56.912: W-1 . . imported "SYS"."AMGT$DP$DAM_CLEANUP_JOBS$"             7.2 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:22:56.915: W-1 . . imported "SYS"."DP$TSDP_ASSOCIATION$"                    0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:22:56.918: W-1 . . imported "SYS"."DP$TSDP_CONDITION$"                      0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:22:56.922: W-1 . . imported "SYS"."DP$TSDP_FEATURE_POLICY$"                 0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:22:56.925: W-1 . . imported "SYS"."DP$TSDP_PROTECTION$"                     0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:22:56.928: W-1 . . imported "SYS"."DP$TSDP_SENSITIVE_DATA$"                 0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:22:56.932: W-1 . . imported "SYS"."DP$TSDP_SENSITIVE_TYPE$"                 0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:22:56.935: W-1 . . imported "SYS"."DP$TSDP_SOURCE$"                         0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:22:56.939: W-1 . . imported "SYSTEM"."REDO_LOG_TMP"                         0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:22:56.942: W-1 . . imported "WMSYS"."E$BATCH_COMPRESSIBLE_TABLES$"          0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:22:56.946: W-1 . . imported "WMSYS"."E$CONSTRAINTS_TABLE$"                  0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:22:56.949: W-1 . . imported "WMSYS"."E$CONS_COLUMNS$"                       0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:22:56.952: W-1 . . imported "WMSYS"."E$LOCKROWS_INFO$"                      0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:22:56.954: W-1 . . imported "WMSYS"."E$MODIFIED_TABLES$"                    0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:22:56.958: W-1 . . imported "WMSYS"."E$MP_GRAPH_WORKSPACES_TABLE$"          0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:22:56.961: W-1 . . imported "WMSYS"."E$MP_PARENT_WORKSPACES_TABLE$"         0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:22:56.964: W-1 . . imported "WMSYS"."E$NESTED_COLUMNS_TABLE$"               0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:22:56.967: W-1 . . imported "WMSYS"."E$RESOLVE_WORKSPACES_TABLE$"           0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:22:56.970: W-1 . . imported "WMSYS"."E$RIC_LOCKING_TABLE$"                  0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:22:56.974: W-1 . . imported "WMSYS"."E$RIC_TABLE$"                          0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:22:56.977: W-1 . . imported "WMSYS"."E$RIC_TRIGGERS_TABLE$"                 0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:22:56.980: W-1 . . imported "WMSYS"."E$UDTRIG_DISPATCH_PROCS$"              0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:22:56.983: W-1 . . imported "WMSYS"."E$UDTRIG_INFO$"                        0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:22:56.986: W-1 . . imported "WMSYS"."E$VERSION_TABLE$"                      0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:22:56.989: W-1 . . imported "WMSYS"."E$VT_ERRORS_TABLE$"                    0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:22:56.992: W-1 . . imported "WMSYS"."E$WORKSPACE_SAVEPOINTS_TABLE$"         0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:22:57.005: W-2 Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/VIEWS_AS_TABLES/TABLE
    02-JUL-24 19:22:57.570: W-4      Completed 15 TABLE objects in 0 seconds
    02-JUL-24 19:22:57.570: W-4      Completed by worker 1 4 TABLE objects in 0 seconds
    02-JUL-24 19:22:57.570: W-4      Completed by worker 2 3 TABLE objects in 0 seconds
    02-JUL-24 19:22:57.570: W-4      Completed by worker 3 4 TABLE objects in 0 seconds
    02-JUL-24 19:22:57.570: W-4      Completed by worker 4 4 TABLE objects in 0 seconds
    02-JUL-24 19:22:57.581: W-3 Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA
    02-JUL-24 19:22:57.634: W-2 . . imported "SYS"."AMGT$DP$AUDTAB$TBS$FOR_EXPORT"           6 KB       2 rows in 0 seconds using direct_path
    02-JUL-24 19:22:57.648: W-2 . . imported "SYS"."DP$DBA_SENSITIVE_DATA"                   0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:22:57.651: W-2 . . imported "SYS"."DP$DBA_TSDP_POLICY_PROTECTION"           0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:22:57.654: W-2 . . imported "SYS"."AMGT$DP$FGA_LOG$FOR_EXPORT"              0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:22:57.658: W-2 . . imported "SYS"."NACL$_ACE_IMP"                           0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:22:57.679: W-2 . . imported "SYS"."NACL$_HOST_IMP"                        6.9 KB       1 rows in 0 seconds using direct_path
    02-JUL-24 19:22:57.682: W-2 . . imported "SYS"."NACL$_WALLET_IMP"                        0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:22:57.685: W-2 . . imported "SYS"."DATAPUMP$SQL$TEXT"                       0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:22:57.688: W-2 . . imported "SYS"."DATAPUMP$SQL$"                           0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:22:57.691: W-2 . . imported "SYS"."DATAPUMP$SQLOBJ$AUXDATA"                 0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:22:57.694: W-2 . . imported "SYS"."DATAPUMP$SQLOBJ$DATA"                    0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:22:57.696: W-2 . . imported "SYS"."DATAPUMP$SQLOBJ$PLAN"                    0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:22:57.699: W-2 . . imported "SYS"."DATAPUMP$SQLOBJ$"                        0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:22:57.746: W-2 . . imported "WMSYS"."E$EXP_MAP"                           7.7 KB       3 rows in 0 seconds using direct_path
    02-JUL-24 19:22:57.750: W-2 . . imported "WMSYS"."E$METADATA_MAP"                        0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:22:57.772: W-1 Processing object type DATABASE_EXPORT/NORMAL_POST_INSTANCE_IMPCALLOUT/MARKER/AUDIT_TRAILS
    02-JUL-24 19:22:57.950: W-1      Completed 10 AUDIT_TRAILS objects in 0 seconds
    02-JUL-24 19:22:57.953: W-1 Processing object type DATABASE_EXPORT/NORMAL_POST_INSTANCE_IMPCALLOUT/MARKER/NETWORK_ACL
    02-JUL-24 19:22:57.970: W-1      Completed 3 NETWORK_ACL objects in 0 seconds
    02-JUL-24 19:22:57.973: W-1 Processing object type DATABASE_EXPORT/NORMAL_POST_INSTANCE_IMPCALLOUT/MARKER/PSTDY
    02-JUL-24 19:22:58.027: W-1      Completed 2 PSTDY objects in 1 seconds
    02-JUL-24 19:22:58.031: W-1 Processing object type DATABASE_EXPORT/NORMAL_POST_INSTANCE_IMPCALLOUT/MARKER/SCHEDULER
    02-JUL-24 19:22:58.033: W-1      Completed 2 SCHEDULER objects in 0 seconds
    02-JUL-24 19:22:58.036: W-1 Processing object type DATABASE_EXPORT/NORMAL_POST_INSTANCE_IMPCALLOUT/MARKER/SMB
    02-JUL-24 19:22:58.071: W-1      Completed 6 SMB objects in 0 seconds
    02-JUL-24 19:22:58.074: W-1 Processing object type DATABASE_EXPORT/NORMAL_POST_INSTANCE_IMPCALLOUT/MARKER/SQL_FIREWALL
    02-JUL-24 19:22:58.076: W-1      Completed 5 SQL_FIREWALL objects in 0 seconds
    02-JUL-24 19:22:58.079: W-1 Processing object type DATABASE_EXPORT/NORMAL_POST_INSTANCE_IMPCALLOUT/MARKER/TSDP
    02-JUL-24 19:22:58.173: W-1      Completed 12 TSDP objects in 0 seconds
    02-JUL-24 19:22:58.176: W-1 Processing object type DATABASE_EXPORT/NORMAL_POST_INSTANCE_IMPCALLOUT/MARKER/WMSYS
    02-JUL-24 19:22:58.327: W-1      Completed 53 WMSYS objects in 0 seconds
    02-JUL-24 19:22:58.390: W-4      Completed 1 [internal] Unknown objects in 1 seconds
    02-JUL-24 19:22:58.390: W-4      Completed by worker 1 1 MARKER objects in 1 seconds
    02-JUL-24 19:22:58.393: W-4 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/TABLE
    02-JUL-24 19:22:58.876: W-1      Completed 15 TABLE objects in 0 seconds
    02-JUL-24 19:22:58.876: W-1      Completed by worker 1 3 TABLE objects in 0 seconds
    02-JUL-24 19:22:58.876: W-1      Completed by worker 2 3 TABLE objects in 0 seconds
    02-JUL-24 19:22:58.876: W-1      Completed by worker 3 3 TABLE objects in 0 seconds
    02-JUL-24 19:22:58.876: W-1      Completed by worker 4 6 TABLE objects in 0 seconds
    02-JUL-24 19:22:58.908: W-2 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/CONSTRAINT/CONSTRAINT
    02-JUL-24 19:22:59.152: W-1      Completed 22 CONSTRAINT objects in 1 seconds
    02-JUL-24 19:22:59.152: W-1      Completed by worker 4 22 CONSTRAINT objects in 1 seconds
    02-JUL-24 19:22:59.154: W-1 Processing object type DATABASE_EXPORT/END_PLUGTS_BLK
    02-JUL-24 19:22:59.317: W-3      Completed 1 PLUGTS_BLK objects in 0 seconds
    02-JUL-24 19:22:59.317: W-3      Completed by worker 1 1 PLUGTS_BLK objects in 0 seconds
    02-JUL-24 19:22:59.332: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER/AUDIT_TRAILS
    02-JUL-24 19:22:59.738: W-1      Completed 10 AUDIT_TRAILS objects in 0 seconds
    02-JUL-24 19:22:59.742: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER/DATAPUMP
    02-JUL-24 19:22:59.748: W-1      Completed 1 DATAPUMP objects in 0 seconds
    02-JUL-24 19:22:59.751: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER/NETWORK_ACL
    02-JUL-24 19:22:59.938: W-1      Completed 3 NETWORK_ACL objects in 0 seconds
    02-JUL-24 19:22:59.942: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER/PSTDY
    02-JUL-24 19:22:59.953: W-1      Completed 2 PSTDY objects in 0 seconds
    02-JUL-24 19:22:59.956: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER/SCHEDULER
    02-JUL-24 19:22:59.959: W-1      Completed 2 SCHEDULER objects in 0 seconds
    02-JUL-24 19:22:59.962: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER/SMB
    02-JUL-24 19:23:02.143: W-1      Completed 6 SMB objects in 3 seconds
    02-JUL-24 19:23:02.146: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER/SQL_FIREWALL
    02-JUL-24 19:23:02.149: W-1      Completed 5 SQL_FIREWALL objects in 0 seconds
    02-JUL-24 19:23:02.152: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER/TSDP
    02-JUL-24 19:23:02.377: W-1      Completed 12 TSDP objects in 0 seconds
    02-JUL-24 19:23:02.380: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER/WMSYS
    02-JUL-24 19:23:04.054: W-1      Completed 53 WMSYS objects in 2 seconds
    02-JUL-24 19:23:04.065: W-2      Completed 1 [internal] Unknown objects in 5 seconds
    02-JUL-24 19:23:04.065: W-2      Completed by worker 1 1 MARKER objects in 5 seconds
    02-JUL-24 19:23:04.069: W-2 Processing object type DATABASE_EXPORT/AUDIT_UNIFIED/AUDIT_POLICY_ENABLE
    02-JUL-24 19:23:04.121: W-3      Completed 2 AUDIT_POLICY_ENABLE objects in 0 seconds
    02-JUL-24 19:23:04.121: W-3      Completed by worker 4 2 AUDIT_POLICY_ENABLE objects in 0 seconds
    02-JUL-24 19:23:04.133: W-1 Processing object type DATABASE_EXPORT/POST_SYSTEM_IMPCALLOUT/MARKER/SCHEDULER
    02-JUL-24 19:23:04.143: W-1      Completed 1 SCHEDULER objects in 0 seconds
    02-JUL-24 19:23:04.146: W-1 Processing object type DATABASE_EXPORT/POST_SYSTEM_IMPCALLOUT/MARKER/WMSYS
    02-JUL-24 19:23:05.781: W-1      Completed 1 WMSYS objects in 1 seconds
    02-JUL-24 19:23:05.784: W-1 Processing object type DATABASE_EXPORT/POST_SYSTEM_IMPCALLOUT/MARKER/DATAPUMP
    02-JUL-24 19:23:05.807: W-1      Completed 1 DATAPUMP objects in 0 seconds
    02-JUL-24 19:23:05.819: W-2      Completed 1 [internal] Unknown objects in 1 seconds
    02-JUL-24 19:23:05.819: W-2      Completed by worker 1 1 MARKER objects in 1 seconds
    02-JUL-24 19:23:05.876: W-4      Completed 1 DATABASE_EXPORT/EARLY_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA objects in 0 seconds
    02-JUL-24 19:23:05.880: W-4      Completed 43 DATABASE_EXPORT/NORMAL_OPTIONS/TABLE_DATA objects in 0 seconds
    02-JUL-24 19:23:05.882: W-4      Completed 17 DATABASE_EXPORT/NORMAL_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA objects in 449 seconds
    02-JUL-24 19:23:05.920: Job "SYSTEM"."SYS_IMPORT_TRANSPORTABLE_01" completed with 33 error(s) at Tue Jul 2 19:23:05 2024 elapsed 0 00:00:20    
    ```
    </details>

## Task 2: Check database

You just finished the test migration. You can connect to the target database and see the data.

1. Still in the *blue* terminal 🟦. Connect to the target database, *CDB23*. 

    ```
    <copy>
    . cdb23
    sqlplus / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

2. Switch to *VIOLET* and check for tables in the *F1* schema.

    ```
    <copy>
    alter session set container=VIOLET;
    select table_name 
    from   all_tables 
    where  owner='F1' and table_name like 'F1_LAPTIMES%';
    select count(*)
    from   f1.f1_laptimes;
    </copy>

    -- Be sure to hit RETURN
    ```

    * You find both *F1\_LAPTIMES* and *F1\_LAPTIMES\_BACKUP*. The latter is the table you created in lab 6. 
    * You can even query the tables. 

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> alter session set container=VIOLET;

    Session altered.

    SQL> select table_name 
    from   all_tables 
    where  owner='F1' and table_name like 'F1_LAPTIMES%';

    TABLE_NAME
    ------------------
    F1_LAPTIMES
    F1_LAPTIMES_BACKUP

    SQL> select count(*)
    from   f1.f1_laptimes;

    COUNT(*)
    --------
    571047
    ```
    </details>

3. If you try to make a change, you receive an error. The tablespaces are read-only, so no changes are allowed.

    ```
    <copy>
    create table f1.f1_laptimes_will_fail as select * from f1.f1_laptimes;
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> create table f1.f1_laptimes_will_fail as select * from f1.f1_laptimes;
    create table f1.f1_laptimes_will_fail as select * from f1.f1_laptimes
                                                              *
    ERROR at line 1:
    ORA-01647: tablespace 'USERS' is read-only, cannot allocate space in it
    Help: https://docs.oracle.com/error-help/db/ora-01647/
    ```
    </details>

## Task 3: Flashback

Now that you are done testing, you use `FLASHBACK DATABASE` to undo the test import.

1. Still in the *blue* terminal 🟦. Switch to the root container and restart the database in mount mode.

    ```
    <copy>
    alter session set container=CDB$ROOT;
    shutdown immediate
    startup mount 
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> alter session set container=CDB$ROOT;
    
    Session altered.

    SQL> shutdown immediate

    Database closed.
    Database dismounted.
    ORACLE instance shut down.
    
    SQL> startup mount
    
    ORACLE instance started.
    
    Total System Global Area 4292413984 bytes
    Fixed Size                  5368352 bytes
    Variable Size             973078528 bytes
    Database Buffers         3305111552 bytes
    Redo Buffers                8855552 bytes
    Database mounted.
    ```
    </details>

2. Flashback to the restore point created by the import driver script.

    ```
    <copy>
    declare
       l_name v$restore_point.name%TYPE;
    begin
       select name into l_name from v$restore_point order by time desc fetch first 1 rows only;
       execute immediate 'flashback database to restore point ' || l_name;
    end;
    /
    </copy>

    -- Be sure to hit RETURN
    ```

    * The name of the restore point changes every time you use the import driver script.
    * The code finds the recent-most restore point and flashes back to it.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> declare
       l_name v$restore_point.name%TYPE;
    begin
       select name into l_name from v$restore_point order by time desc fetch first 1 rows only;
       execute immediate 'flashback database to restore point ' || l_name;
    end;
    /

    PL/SQL procedure successfully completed.
    ```
    </details>

3. Open the database.

    ```
    <copy>
    alter database open resetlogs;
    </copy>
    ```

    * `FLASHBACK DATABASE` requires that you open the database with resetlogs.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> alter database open resetlogs;
    
    Database altered.
    ```
    </details>

4. Switch back to *VIOLET* and verify that the tables in the *F1* schema is now gone.

    ```
    <copy>
    alter session set container=VIOLET;
    select table_name 
    from   all_tables 
    where  owner='F1' and table_name like 'F1_LAPTIMES%';
    </copy>

    -- Be sure to hit RETURN
    ```

    * The query returns no rows because you reverted the entire import with the `FLASHBACK DATABASE` command.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> alter session set container=VIOLET;

    Session altered.

    SQL> select table_name 
    from   all_tables 
    where  owner='F1' and table_name like 'F1_LAPTIMES%';    

    no rows selected.
    ```
    </details>

5. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```    

## Task 4: Proceed with backup/restore

When the test completes and you reverted the changes, you can resume the backup/restore cycle.

1. Use the *yellow* terminal 🟨. Set the environment to the source database and connect.

    ```
    <copy>
    . ftex
    sqlplus / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

2. Create a copy of one of the tables.

    ```
    <copy>
    create table f1.f1_laptimes_backup2 as select * from f1.f1_laptimes;
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> create table f1.f1_laptimes_backup2 as select * from f1.f1_laptimes;
    
    Table created.
    ```
    </details>

3. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```

4. Perform an incremental backup.

    ```
    <copy>
    . ftex
    cd /home/oracle/m5
    ./dbmig_driver_m5.sh L1
    </copy>

    -- Be sure to hit RETURN
    ```

    * Although the last backup was a *final* backup, the script just continues.
    * The backup/restore cycle is not interrupted. 

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ . ftex
    $ cd /home/oracle/m5
    $ ./dbmig_driver_m5.sh L1
    Properties file found, sourcing.
    LOG and CMD directories found
    2024-07-02 19:33:19 - 1719948799015: Requested L1 backup for pid 16440.  Using DISK destination, 4 channels and 64G section size.
    2024-07-02 19:33:19 - 1719948799023: Performing L1 backup for pid 16440
    RMAN> 2> 3> 4> RMAN> RMAN> 2> 3> 4> 5> 6> 7> 8> 9> 10> 11> 12> 13> RMAN>
    2024-07-02 19:33:23 - 1719948803607: No errors or warnings found in backup log file for pid 16440
    2024-07-02 19:33:23 - 1719948803623: Manually copy restore script to destination
    2024-07-02 19:33:23 - 1719948803626:  => /home/oracle/m5/cmd/restore_L1_FTEX_240702193318.cmd
    2024-07-02 19:33:23 - 1719948803638: Saving SCN for next backup for pid 16440
    
    BACKUP_TYPE   INPUT_BYTES(MB) OUTPUT_BYTES(MB) STATUS    START_TIME          END_TIME         ELAPSED_TIME(Min)
    ------------- --------------- ---------------- --------- ------------------- ---------------- -----------------
    DATAFILE FULL 41.3359375      20.5390625       COMPLETED 07/02/2024:19:33:21 07/02/2024:19:33:23 .03    
    ```
    </details>

5. Switch to the *blue* terminal 🟦. Restore the backup.

    ```
    <copy>
    cd /home/oracle/m5/cmd
    export L1SCRIPT=$(ls -tr restore_L1_* | tail -1) 
    cd /home/oracle/m5
    . cdb23
    rman target "sys/oracle@'localhost/violet'" cmdfile=/home/oracle/m5/cmd/$L1SCRIPT
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ cd /home/oracle/m5/cmd
    $ export L1SCRIPT=$(ls -tr restore_L1_* | tail -1)
    $ cd /home/oracle/m5
    $ . cdb23
    $ rman target "sys/oracle@'localhost/violet'" cmdfile=/home/oracle/m5/cmd/$L1SCRIPT
    
    Recovery Manager: Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems on Tue Jul 2 19:34:44 2024
    Version 23.5.0.24.07
    
    Copyright (c) 1982, 2024, Oracle and/or its affiliates.  All rights reserved.
    
    connected to target database: CDB23:VIOLET (DBID=1874382390)
    
    RMAN> SPOOL LOG TO log/restore_L1_FTEX_240702193318.log;
    2> SPOOL TRACE TO log/restore_L1_FTEX_240702193318.trc;
    3> SET EVENT FOR catalog_foreign_datafile_restore TO 1;
    4> SET ECHO ON;
    5> SHOW ALL;
    6> DEBUG ON;
    7> RUN
    8> {
    9> ALLOCATE CHANNEL DISK1 DEVICE TYPE DISK FORMAT '/home/oracle/m5/rman/L1_%d_%N_%t_%s_%p';
    10> ALLOCATE CHANNEL DISK2 DEVICE TYPE DISK FORMAT '/home/oracle/m5/rman/L1_%d_%N_%t_%s_%p';
    11> ALLOCATE CHANNEL DISK3 DEVICE TYPE DISK FORMAT '/home/oracle/m5/rman/L1_%d_%N_%t_%s_%p';
    12> ALLOCATE CHANNEL DISK4 DEVICE TYPE DISK FORMAT '/home/oracle/m5/rman/L1_%d_%N_%t_%s_%p';
    13> RESTORE ALL FOREIGN DATAFILES TO NEW FROM BACKUPSET
    14> '/home/oracle/m5/rman/L1_FTEX_USERS_1173296001_7_1';}
    15>
    ```
    </details>

6. Search the log file for any warnings or errors. 

    ```
    <copy>
    cd log
    egrep "WARN-|ORA-" $(ls -tr restore*log | tail -1)
    </copy>

    -- Be sure to hit RETURN
    ```

    * The command produces no output because the search string was not found. This means there were no warnings or errors in the log file.


You may now *proceed to the next lab*.

## Further information

During the test, you introduced a short outage on the source database. You changed the tablespaces to read-only mode on the source database while you performed the final backup, including the Data Pump transportable export. If such an outage is unacceptable, you can perform the test backup on a standby database. Thus, you avoid an outage on the primary database.

## Acknowledgments

* **Author** - Daniel Overby Hansen
* **Contributors** - Rodrigo Jorge, Mike Dietrich, Klaus Gronau, Alex Zaballa
* **Last Updated By/Date** - Daniel Overby Hansen, August 2024
