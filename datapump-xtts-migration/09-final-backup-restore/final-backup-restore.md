# Final Backup and Restore

## Introduction

It's time to complete the migration. You've done all the preparations, but now it's time for an outage while you migrate the database. When the maintenance window begins, you perform a final backup and restore, plus, use Data Pump to do a full transportable export/import.

Estimated Time: 20 Minutes

[Next-Level Platform Migration with Cross-Platform Transportable Tablespaces - lab 9](youtube:fgyDy-QcV_o?start=2363)

![Complete the migration](./images/final-backup-restore-overview.png " ")

### Objectives

In this lab, you will:

* Perform final backup and restore
* Data Pump export and import

## Task 1: Final backup / restore

In a real migration, you would shut down the applications using the database. Although there is an outage, you can still query the source database. The tablespaces are read-only, so you can't add or change data, but you can query it. 

1. The outage starts now.

2. Use the *yellow* terminal 🟨. Start the final backup. When you start the driver script with *L1F*, it performs not only the final backup, but it also sets the tablespaces in *read-only* mode and starts a Data Pump full transportable export. When prompted for *system password*, enter *ftexuser*.

    ```
    <copy>
    . ftex
    cd /home/oracle/m5
    ./dbmig_driver_m5.sh L1F
    </copy>

    -- Be sure to hit RETURN
    ```

    * You start the driver script with the argument *L1F*.
    * The *system password* is for the user *ftexuser*. This user is specified in the M5 properties file.
    * Before starting the backup, the script sets the tablespaces read-only. 
    * After the backup, the script starts Data Pump to perform a full transportable export. 
    * The export runs for a few minutes.
    * Notice how Data Pump lists the names of the data files needed for the migration at the end of the output. 
    * In addition, it lists the names of the Data Pump dump files. 

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ . ftex
    $ cd /home/oracle/m5
    $ ./dbmig_driver_m5.sh L1F
    Properties file found, sourcing.
    LOG and CMD directories found
    2024-07-02 19:41:09 - 1719949269046: Requested L1F backup for pid 17035.  Using DISK destination, 4 channels and 64G section size.
    2024-07-02 19:41:09 - 1719949269053: Performing L1F backup for pid 17035
    ============================================
    Enter the system password to perform read only tablespaces
    
    Connected successfully
    Oracle authentication successful
    
    Tablespace altered.
    
    RMAN> 2> 3> 4> RMAN> RMAN> 2> 3> 4> 5> 6> 7> 8> 9> 10> 11> 12> 13> RMAN>
    2024-07-02 19:41:17 - 1719949277378: No errors or warnings found in backup log file for pid 17035
    2024-07-02 19:41:17 - 1719949277397: Manually copy restore script to destination
    2024-07-02 19:41:17 - 1719949277399:  => /home/oracle/m5/cmd/restore_L1F_FTEX_240702194108.cmd
    
    Export: Release 19.0.0.0.0 - Production on Tue Jul 2 19:41:17 2024
    Version 19.21.0.0.0
    
    Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.
    
    Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    02-JUL-24 19:41:21.854: Starting "FTEXUSER"."SYS_EXPORT_FULL_01":  FTEXUSER/********@localhost/ftex parfile=/home/oracle/m5/cmd/    exp_FTEX_240702194108_xtts.par
    02-JUL-24 19:41:22.809: W-1 Startup took 1 seconds
    02-JUL-24 19:41:26.168: W-1 Processing object type DATABASE_EXPORT/EARLY_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA
    02-JUL-24 19:41:27.322: W-1 Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/TABLE_DATA
    02-JUL-24 19:41:28.259: W-1 Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA
    02-JUL-24 19:41:29.116: W-1 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/TABLE_DATA
    02-JUL-24 19:41:31.558: W-1 Processing object type DATABASE_EXPORT/PLUGTS_FULL/FULL/PLUGTS_TABLESPACE
    02-JUL-24 19:41:31.580: W-1      Completed  PLUGTS_TABLESPACE objects in  seconds
    02-JUL-24 19:41:31.622: W-1 Processing object type DATABASE_EXPORT/PLUGTS_FULL/PLUGTS_BLK
    02-JUL-24 19:41:31.729: W-1      Completed 1 PLUGTS_BLK objects in 0 seconds
    02-JUL-24 19:41:32.143: W-1 Processing object type DATABASE_EXPORT/END_PLUGTS_BLK
    02-JUL-24 19:41:32.145: W-1      Completed 1 PLUGTS_BLK objects in 1 seconds
    02-JUL-24 19:41:32.161: W-1 Processing object type DATABASE_EXPORT/PRE_SYSTEM_IMPCALLOUT/MARKER
    02-JUL-24 19:41:32.163: W-1      Completed 1 MARKER objects in 0 seconds
    02-JUL-24 19:41:32.170: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER
    02-JUL-24 19:41:32.172: W-1      Completed 1 MARKER objects in 0 seconds
    02-JUL-24 19:41:32.215: W-1 Processing object type DATABASE_EXPORT/TABLESPACE
    02-JUL-24 19:41:32.220: W-1      Completed 2 TABLESPACE objects in 0 seconds
    02-JUL-24 19:41:32.329: W-1 Processing object type DATABASE_EXPORT/PROFILE
    02-JUL-24 19:41:32.333: W-1      Completed 1 PROFILE objects in 0 seconds
    02-JUL-24 19:41:32.372: W-1 Processing object type DATABASE_EXPORT/SCHEMA/USER
    02-JUL-24 19:41:32.377: W-1      Completed 3 USER objects in 0 seconds
    02-JUL-24 19:41:32.418: W-1 Processing object type DATABASE_EXPORT/RADM_FPTM
    02-JUL-24 19:41:32.423: W-1      Completed 1 RADM_FPTM objects in 0 seconds
    02-JUL-24 19:41:32.576: W-1 Processing object type DATABASE_EXPORT/GRANT/SYSTEM_GRANT/PROC_SYSTEM_GRANT
    02-JUL-24 19:41:32.582: W-1      Completed 6 PROC_SYSTEM_GRANT objects in 0 seconds
    02-JUL-24 19:41:32.611: W-1 Processing object type DATABASE_EXPORT/SCHEMA/GRANT/SYSTEM_GRANT
    02-JUL-24 19:41:32.629: W-1      Completed 73 SYSTEM_GRANT objects in 0 seconds
    02-JUL-24 19:41:32.650: W-1 Processing object type DATABASE_EXPORT/SCHEMA/ROLE_GRANT
    02-JUL-24 19:41:32.667: W-1      Completed 41 ROLE_GRANT objects in 0 seconds
    02-JUL-24 19:41:32.685: W-1 Processing object type DATABASE_EXPORT/SCHEMA/DEFAULT_ROLE
    02-JUL-24 19:41:32.690: W-1      Completed 5 DEFAULT_ROLE objects in 0 seconds
    02-JUL-24 19:41:32.709: W-1 Processing object type DATABASE_EXPORT/SCHEMA/ON_USER_GRANT
    02-JUL-24 19:41:32.714: W-1      Completed 3 ON_USER_GRANT objects in 0 seconds
    02-JUL-24 19:41:32.748: W-1 Processing object type DATABASE_EXPORT/SCHEMA/TABLESPACE_QUOTA
    02-JUL-24 19:41:32.753: W-1      Completed 4 TABLESPACE_QUOTA objects in 0 seconds
    02-JUL-24 19:41:32.768: W-1 Processing object type DATABASE_EXPORT/RESOURCE_COST
    02-JUL-24 19:41:32.773: W-1      Completed 1 RESOURCE_COST objects in 0 seconds
    02-JUL-24 19:41:32.843: W-1 Processing object type DATABASE_EXPORT/TRUSTED_DB_LINK
    02-JUL-24 19:41:32.847: W-1      Completed 1 TRUSTED_DB_LINK objects in 0 seconds
    02-JUL-24 19:41:32.915: W-1 Processing object type DATABASE_EXPORT/DIRECTORY/DIRECTORY
    02-JUL-24 19:41:32.920: W-1      Completed 1 DIRECTORY objects in 0 seconds
    02-JUL-24 19:41:33.122: W-1 Processing object type DATABASE_EXPORT/DIRECTORY/GRANT/OWNER_GRANT/OBJECT_GRANT
    02-JUL-24 19:41:33.127: W-1      Completed 2 OBJECT_GRANT objects in 1 seconds
    02-JUL-24 19:41:34.055: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/PRE_SYSTEM_ACTIONS/PROCACT_SYSTEM
    02-JUL-24 19:41:34.105: W-1      Completed 2 PROCACT_SYSTEM objects in 0 seconds
    02-JUL-24 19:41:34.276: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/PROCOBJ
    02-JUL-24 19:41:34.285: W-1      Completed 23 PROCOBJ objects in 0 seconds
    02-JUL-24 19:41:34.721: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/POST_SYSTEM_ACTIONS/PROCACT_SYSTEM
    02-JUL-24 19:41:34.755: W-1      Completed 3 PROCACT_SYSTEM objects in 0 seconds
    02-JUL-24 19:41:35.232: W-1 Processing object type DATABASE_EXPORT/SCHEMA/PROCACT_SCHEMA
    02-JUL-24 19:41:35.239: W-1      Completed 6 PROCACT_SCHEMA objects in 1 seconds
    02-JUL-24 19:41:40.668: W-1 Processing object type DATABASE_EXPORT/EARLY_OPTIONS/VIEWS_AS_TABLES/TABLE
    02-JUL-24 19:41:40.695: W-1      Completed 1 TABLE objects in 3 seconds
    02-JUL-24 19:41:40.718: W-1 Processing object type DATABASE_EXPORT/EARLY_POST_INSTANCE_IMPCALLOUT/MARKER
    02-JUL-24 19:41:40.721: W-1      Completed 1 MARKER objects in 0 seconds
    02-JUL-24 19:41:53.753: W-1 Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/TABLE
    02-JUL-24 19:42:08.131: W-1      Completed 41 TABLE objects in 27 seconds
    02-JUL-24 19:42:10.822: W-1 Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/VIEWS_AS_TABLES/TABLE
    02-JUL-24 19:42:22.299: W-1      Completed 17 TABLE objects in 14 seconds
    02-JUL-24 19:42:22.329: W-1 Processing object type DATABASE_EXPORT/NORMAL_POST_INSTANCE_IMPCALLOUT/MARKER
    02-JUL-24 19:42:22.331: W-1      Completed 1 MARKER objects in 0 seconds
    02-JUL-24 19:42:23.599: W-1 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/TABLE
    02-JUL-24 19:42:32.919: W-1      Completed 17 TABLE objects in 10 seconds
    02-JUL-24 19:42:33.638: W-1 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/COMMENT
    02-JUL-24 19:42:35.527: W-1 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/INDEX/INDEX
    02-JUL-24 19:42:35.549: W-1      Completed 1 INDEX objects in 1 seconds
    02-JUL-24 19:42:36.407: W-1 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/CONSTRAINT/CONSTRAINT
    02-JUL-24 19:42:36.424: W-1      Completed 22 CONSTRAINT objects in 1 seconds
    02-JUL-24 19:42:37.596: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER
    02-JUL-24 19:42:37.598: W-1      Completed 1 MARKER objects in 0 seconds
    02-JUL-24 19:42:40.504: W-1 Processing object type DATABASE_EXPORT/AUDIT_UNIFIED/AUDIT_POLICY_ENABLE
    02-JUL-24 19:42:40.507: W-1      Completed 2 AUDIT_POLICY_ENABLE objects in 0 seconds
    02-JUL-24 19:42:40.603: W-1 Processing object type DATABASE_EXPORT/POST_SYSTEM_IMPCALLOUT/MARKER
    02-JUL-24 19:42:40.606: W-1      Completed 1 MARKER objects in 0 seconds
    02-JUL-24 19:42:41.044: W-1 . . exported "SYS"."KU$_USER_MAPPING_VIEW"               5.906 KB      26 rows in 1 seconds using external_table
    02-JUL-24 19:42:41.324: W-1 . . exported "SYSTEM"."REDO_DB"                          25.59 KB       1 rows in 0 seconds using direct_path
    02-JUL-24 19:42:41.350: W-1 . . exported "WMSYS"."WM$WORKSPACES_TABLE$"              12.10 KB       1 rows in 0 seconds using direct_path
    02-JUL-24 19:42:41.374: W-1 . . exported "WMSYS"."WM$HINT_TABLE$"                    9.984 KB      97 rows in 0 seconds using direct_path
    02-JUL-24 19:42:41.397: W-1 . . exported "WMSYS"."WM$WORKSPACE_PRIV_TABLE$"          7.078 KB      11 rows in 0 seconds using direct_path
    02-JUL-24 19:42:41.419: W-1 . . exported "SYS"."DAM_CONFIG_PARAM$"                   6.531 KB      14 rows in 0 seconds using direct_path
    02-JUL-24 19:42:41.442: W-1 . . exported "SYS"."TSDP_SUBPOL$"                        6.328 KB       1 rows in 0 seconds using direct_path
    02-JUL-24 19:42:41.466: W-1 . . exported "WMSYS"."WM$NEXTVER_TABLE$"                 6.375 KB       1 rows in 0 seconds using direct_path
    02-JUL-24 19:42:41.489: W-1 . . exported "WMSYS"."WM$ENV_VARS$"                      6.015 KB       3 rows in 0 seconds using direct_path
    02-JUL-24 19:42:41.511: W-1 . . exported "SYS"."TSDP_PARAMETER$"                     5.953 KB       1 rows in 0 seconds using direct_path
    02-JUL-24 19:42:41.534: W-1 . . exported "SYS"."TSDP_POLICY$"                        5.921 KB       1 rows in 0 seconds using direct_path
    02-JUL-24 19:42:41.557: W-1 . . exported "WMSYS"."WM$VERSION_HIERARCHY_TABLE$"       5.984 KB       1 rows in 0 seconds using direct_path
    02-JUL-24 19:42:41.579: W-1 . . exported "WMSYS"."WM$EVENTS_INFO$"                   5.812 KB      12 rows in 0 seconds using direct_path
    02-JUL-24 19:42:41.643: W-1 . . exported "AUDSYS"."AUD$UNIFIED":"AUD_UNIFIED_P0"     50.95 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:42:41.712: W-1 . . exported "AUDSYS"."AUD$UNIFIED":"SYS_P261"           4.868 MB    2838 rows in 0 seconds using direct_path
    02-JUL-24 19:42:41.772: W-1 . . exported "AUDSYS"."AUD$UNIFIED":"SYS_P281"           59.22 KB      16 rows in 0 seconds using direct_path
    02-JUL-24 19:42:41.802: W-1 . . exported "SYS"."AUD$"                                23.46 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:42:41.824: W-1 . . exported "SYS"."DAM_CLEANUP_EVENTS$"                 7.187 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:42:41.845: W-1 . . exported "SYS"."DAM_CLEANUP_JOBS$"                   7.171 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:42:41.849: W-1 . . exported "SYS"."TSDP_ASSOCIATION$"                       0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:42:41.852: W-1 . . exported "SYS"."TSDP_CONDITION$"                         0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:42:41.854: W-1 . . exported "SYS"."TSDP_FEATURE_POLICY$"                    0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:42:41.858: W-1 . . exported "SYS"."TSDP_PROTECTION$"                        0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:42:41.863: W-1 . . exported "SYS"."TSDP_SENSITIVE_DATA$"                    0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:42:41.866: W-1 . . exported "SYS"."TSDP_SENSITIVE_TYPE$"                    0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:42:41.870: W-1 . . exported "SYS"."TSDP_SOURCE$"                            0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:42:41.872: W-1 . . exported "SYSTEM"."REDO_LOG"                             0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:42:41.875: W-1 . . exported "WMSYS"."WM$BATCH_COMPRESSIBLE_TABLES$"         0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:42:41.881: W-1 . . exported "WMSYS"."WM$CONSTRAINTS_TABLE$"                 0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:42:41.885: W-1 . . exported "WMSYS"."WM$CONS_COLUMNS$"                      0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:42:41.889: W-1 . . exported "WMSYS"."WM$LOCKROWS_INFO$"                     0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:42:41.892: W-1 . . exported "WMSYS"."WM$MODIFIED_TABLES$"                   0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:42:41.896: W-1 . . exported "WMSYS"."WM$MP_GRAPH_WORKSPACES_TABLE$"         0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:42:41.899: W-1 . . exported "WMSYS"."WM$MP_PARENT_WORKSPACES_TABLE$"        0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:42:41.903: W-1 . . exported "WMSYS"."WM$NESTED_COLUMNS_TABLE$"              0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:42:41.906: W-1 . . exported "WMSYS"."WM$RESOLVE_WORKSPACES_TABLE$"          0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:42:41.910: W-1 . . exported "WMSYS"."WM$RIC_LOCKING_TABLE$"                 0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:42:41.914: W-1 . . exported "WMSYS"."WM$RIC_TABLE$"                         0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:42:41.917: W-1 . . exported "WMSYS"."WM$RIC_TRIGGERS_TABLE$"                0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:42:41.920: W-1 . . exported "WMSYS"."WM$UDTRIG_DISPATCH_PROCS$"             0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:42:41.925: W-1 . . exported "WMSYS"."WM$UDTRIG_INFO$"                       0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:42:41.928: W-1 . . exported "WMSYS"."WM$VERSION_TABLE$"                     0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:42:41.932: W-1 . . exported "WMSYS"."WM$VT_ERRORS_TABLE$"                   0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:42:41.936: W-1 . . exported "WMSYS"."WM$WORKSPACE_SAVEPOINTS_TABLE$"        0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:42:42.415: W-1 . . exported "SYS"."AUDTAB$TBS$FOR_EXPORT"               5.960 KB       2 rows in 0 seconds using external_table
    02-JUL-24 19:42:42.425: W-1 . . exported "SYS"."DBA_SENSITIVE_DATA"                      0 KB       0 rows in 0 seconds using external_table
    02-JUL-24 19:42:42.436: W-1 . . exported "SYS"."DBA_TSDP_POLICY_PROTECTION"              0 KB       0 rows in 0 seconds using external_table
    02-JUL-24 19:42:42.441: W-1 . . exported "SYS"."FGA_LOG$FOR_EXPORT"                      0 KB       0 rows in 0 seconds using external_table
    02-JUL-24 19:42:42.496: W-1 . . exported "SYS"."NACL$_ACE_EXP"                           0 KB       0 rows in 0 seconds using external_table
    02-JUL-24 19:42:42.657: W-1 . . exported "SYS"."NACL$_HOST_EXP"                      6.914 KB       1 rows in 0 seconds using external_table
    02-JUL-24 19:42:42.661: W-1 . . exported "SYS"."NACL$_WALLET_EXP"                        0 KB       0 rows in 0 seconds using external_table
    02-JUL-24 19:42:42.667: W-1 . . exported "SYS"."SQL$TEXT_DATAPUMP"                       0 KB       0 rows in 0 seconds using external_table
    02-JUL-24 19:42:42.671: W-1 . . exported "SYS"."SQL$_DATAPUMP"                           0 KB       0 rows in 0 seconds using external_table
    02-JUL-24 19:42:42.675: W-1 . . exported "SYS"."SQLOBJ$AUXDATA_DATAPUMP"                 0 KB       0 rows in 0 seconds using external_table
    02-JUL-24 19:42:42.679: W-1 . . exported "SYS"."SQLOBJ$DATA_DATAPUMP"                    0 KB       0 rows in 0 seconds using external_table
    02-JUL-24 19:42:42.684: W-1 . . exported "SYS"."SQLOBJ$PLAN_DATAPUMP"                    0 KB       0 rows in 0 seconds using external_table
    02-JUL-24 19:42:42.688: W-1 . . exported "SYS"."SQLOBJ$_DATAPUMP"                        0 KB       0 rows in 0 seconds using external_table
    02-JUL-24 19:42:42.733: W-1 . . exported "SYSTEM"."SCHEDULER_JOB_ARGS"                   0 KB       0 rows in 0 seconds using external_table
    02-JUL-24 19:42:42.760: W-1 . . exported "SYSTEM"."SCHEDULER_PROGRAM_ARGS"               0 KB       0 rows in 0 seconds using external_table
    02-JUL-24 19:42:43.216: W-1 . . exported "WMSYS"."WM$EXP_MAP"                        7.718 KB       3 rows in 1 seconds using external_table
    02-JUL-24 19:42:43.225: W-1 . . exported "WMSYS"."WM$METADATA_MAP"                       0 KB       0 rows in 0 seconds using external_table
    02-JUL-24 19:42:44.526: W-1      Completed 1 DATABASE_EXPORT/EARLY_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA objects in 1 seconds
    02-JUL-24 19:42:44.655: W-1      Completed 43 DATABASE_EXPORT/NORMAL_OPTIONS/TABLE_DATA objects in 0 seconds
    02-JUL-24 19:42:44.657: W-1      Completed 17 DATABASE_EXPORT/NORMAL_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA objects in 1 seconds
    02-JUL-24 19:42:45.926: W-1 Master table "FTEXUSER"."SYS_EXPORT_FULL_01" successfully loaded/unloaded
    02-JUL-24 19:42:45.972: ******************************************************************************
    02-JUL-24 19:42:45.972: Dump file set for FTEXUSER.SYS_EXPORT_FULL_01 is:
    02-JUL-24 19:42:45.974:   /home/oracle/m5/m5dir/exp_FTEX_240702194108.dmp
    02-JUL-24 19:42:45.974: ******************************************************************************
    02-JUL-24 19:42:45.977: Datafiles required for transportable tablespace USERS:
    02-JUL-24 19:42:45.982:   /u02/oradata/FTEX/datafile/o1_mf_users_m7v5qtos_.dbf
    02-JUL-24 19:42:46.013: Job "FTEXUSER"."SYS_EXPORT_FULL_01" successfully completed at Tue Jul 2 19:42:46 2024 elapsed 0 00:01:26
    
    
    BACKUP_TYPE   INPUT_BYTES(MB) OUTPUT_BYTES(MB) STATUS    START_TIME          END_TIME            ELAPSED_TIME(Min)
    ------------- --------------- ---------------- --------- ------------------- ------------------- -----------------
    DATAFILE FULL 21.4921875      .390625          COMPLETED 07/02/2024:19:41:15 07/02/2024:19:41:16 .01    
    ```
    </details>

3. Switch to the *blue* terminal 🟦. Restore the backup.

    ```
    <copy>
    cd /home/oracle/m5/cmd
    export L1FSCRIPT=$(ls -tr restore_L1F* | tail -1) 
    cd /home/oracle/m5
    . cdb23
    rman target "sys/oracle@'localhost/violet'" cmdfile=/home/oracle/m5/cmd/$L1FSCRIPT
    </copy>

    -- Be sure to hit RETURN
    ```

    * Restoring the final backup is just like the other restore operations. 
    * The only difference is that the tablespaces are set read-only, so the SCN of the data files matches the SCN at which you run the Data Pump transportable export.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ cd /home/oracle/m5/cmd
    $ export L1FSCRIPT=$(ls -tr restore_L1F* | tail -1)
    $ cd /home/oracle/m5
    $ . cdb23
    $ rman target "sys/oracle@'localhost/violet'" cmdfile=/home/oracle/m5/cmd/$L1FSCRIPT
    
    Recovery Manager: Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems on Tue Jul 2 19:44:30 2024
    Version 23.5.0.24.07
    
    Copyright (c) 1982, 2024, Oracle and/or its affiliates.  All rights reserved.
    
    connected to target database: CDB23:VIOLET (DBID=1874382390)
    
    RMAN> SPOOL LOG TO log/restore_L1F_FTEX_240702194108.log;
    2> SPOOL TRACE TO log/restore_L1F_FTEX_240702194108.trc;
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
    14> '/home/oracle/m5/rman/L1F_FTEX_USERS_1173296475_8_1';}
    15>
    ```
    </details>

## Task 2: Data Pump import

1. Still in the *blue* terminal 🟦. Examine the import driver script. For the Data Pump transportable import, you use the import driver script `impdp.sh`. It's located in the script base folder. *Normally, you need to fill in information about your target database, but in this lab it is done for you*.

    ```
    <copy>
    head -22 impdp.sh
    </copy>
    ```

    * You find information about the target database as environment variables. 
    * Also, there are certain variables controlling the use of Data Pump.
    * Since you are importing into Oracle Database 23ai, you can utilize parallel import (`DATA_PUMP_PARALLEL`). This significantly speeds up the import. 

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ head -22 impdp.sh
    #!/bin/bash
    
    if [ $# -ne 4 ]; then
            echo "Please call this script using the syntax $0 "
            echo "Example: # sh impdp.sh <expdp_dumpfile> <rman_last_restore_log> [run|test|run-readonly|test-readonly] <encryption_pwd_prompt    [Y|N]>"
            exit 1
    fi
    
    #Full path to Oracle Home
    export ORACLE_HOME=/u01/app/oracle/product/23
    export PATH=$PATH:$ORACLE_HOME/bin
    #SID of the destination database
    export ORACLE_SID=CDB23
    #Connect string to destination database. If PDB, connect directly into PDB
    export ORACLE_CONNECT_STRING="(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=localhost)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=VIOLET)))"
    #Data Pump directory
    export DATA_PUMP_DIR=M5DIR
    #Data Pump parallel setting
    export DATA_PUMP_PARALLEL=4
    #Data Pump trace level. 0 to disable. 3FF0300 for transportable tablespace trace
    export DATA_PUMP_TRACE=0
    ```
    </details>
    
2. Start the import driver script. It *fails*, but informs you to add additional information.

    ```
    <copy>
    ./impdp.sh
    </copy>
    ```

    * The script informs you that you must add additional information on the command line.
    * *expdp_dumpfile* is the name of the dump file created by the full transportable export.
    * *rman\_last\_restore\_log* is the relative path to the log file from the final restore.
    * The third parameter controls the *run mode*. 
        * *test* just generates the Data Pump parameter file for the import.
        * *run* generates the parameter file and starts the import.
        * Adding *readonly* triggers the use of the Data Pump parameter `TRANSPORTABLE=KEEP_READ_ONLY` which is useful for testing.
    * *encryption\_pwd\_prompt* - set to *N* because *FTEX* is not encrypted.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ ./impdp.sh
    Please call this script using the syntax ./impdp.sh
    Example: # sh impdp.sh <expdp_dumpfile> <rman_last_restore_log> [run|test|run-readonly|test-readonly] <encryption_pwd_prompt[Y|N]>
    ```
    </details>

3. Collect the information for the import driver script.

    ```
    <copy>
    cd m5dir
    export DMPFILE=$(ls -tr exp_FTEX*dmp | tail -1)
    cd ../log
    export L1FLOGFILE=$(ls -tr restore_L1F*log | tail -1)
    cd ..
    echo $DMPFILE
    echo $L1FLOGFILE
    </copy>

    -- Be sure to hit RETURN
    ```

    * The driver script needs the name of the Data Pump dump file and the last RMAN restore log file.
    * You could find the names manually, however, for simplicity the command finds them for you and assign them to environment variables, *DMPFILE* and *L1FLOGFILE*. 

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ cd m5dir
    $ export DMPFILE=$(ls -tr exp_FTEX*dmp | tail -1)
    $ cd ../log
    $ export L1FLOGFILE=$(ls -tr restore_L1F*log | tail -1)
    $ cd ..
    $ echo $DMPFILE
    exp_FTEX_240702194108.dmp
    $ echo $L1FLOGFILE
    restore_L1F_FTEX_240702194108.log
    ```
    </details>

4. Start the import driver script in *test* mode. 

    ```
    <copy>
    . cdb23
    ./impdp.sh $DMPFILE log/$L1FLOGFILE test N
    </copy>

    -- Be sure to hit RETURN
    ```

    * This step simply generates the Data Pump import parameter file. 
    * The last *N* indicates that the database is not encrypted.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ ./impdp.sh $DMPFILE log/$L1FLOGFILE test N
    Running in test mode, check par file for correctness
    ```
    </details>

5. Examine the Data Pump parameter file.

    ```
    <copy>
    cat $(ls -tr imp_CDB23*xtts.par | tail -1)
    </copy>
    ```

    * If you need to make any changes to the Data Pump parameter file, you must edit the import driver script, *impdp.sh*, and make the changes there. 
    * The script generates a new parameter file each time you execute it. Any changes made to the parameter file are lost.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ cat $(ls -tr imp_CDB23*xtts.par | tail -1)
    userid='system@localhost/violet'
    dumpfile=exp_FTEX_240702194108.dmp
    directory=M5DIR
    LOGTIME=ALL
    TRACE=0
    PARALLEL=4
    LOGFILE=imp_CDB23_240702194602_xtts.log
    METRICS=YES
    ENCRYPTION_PWD_PROMPT=NO
    TRANSPORT_DATAFILES=
    '/u02/oradata/CDB23/1BE2D83DC43E4766E0630200000A4596/datafile/o1_mf_users_m88mg5xh_.dbf'
    ```
    </details>

6. Since you verified the contents of the Data Pump parameter file, you can now start the real import. Re-use the `impdp.sh` command line but switch to *run* mode. When prompted for a password, enter *oracle*.

    ```
    <copy>
    ./impdp.sh $DMPFILE log/$L1FLOGFILE run N
    </copy>
    ```

    * You connect as *SYSTEM* for the import.
    * The import runs for a minute or so.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ ./impdp.sh $DMPFILE log/$L1FLOGFILE run N
    Running in Run mode
    
    Restore point created.
    
    
    NAME				SCN TIME					     GUA STORAGE_SIZE
    ------------------------ ---------- ------------------------------------------------ --- ------------
    BEFORE_IMP_240702192231      748325 02-JUL-24 07.22.31.000000000 PM		     YES	    0
    BEFORE_IMP_240702194726      753907 02-JUL-24 07.47.26.000000000 PM		     YES    209715200
    
    
    Import: Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems on Tue Jul 2 19:47:26 2024
    Version 23.5.0.24.07

    Copyright (c) 1982, 2024, Oracle and/or its affiliates.  All rights reserved.
    Password:
    
    Connected to: Oracle Database 23ai Enterprise Edition Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems
    02-JUL-24 19:47:32.528: W-1 Startup on instance 1 took 1 seconds
    02-JUL-24 19:47:33.906: W-1 Master table "SYSTEM"."SYS_IMPORT_TRANSPORTABLE_01" successfully loaded/unloaded
    02-JUL-24 19:47:34.307: Starting "SYSTEM"."SYS_IMPORT_TRANSPORTABLE_01":  system/********@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)    (HOST=localhost)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=VIOLET))) parfile=imp_CDB23_240702194726_xtts.par
    02-JUL-24 19:47:34.418: W-1 Processing object type DATABASE_EXPORT/PRE_SYSTEM_IMPCALLOUT/MARKER/SCHEDULER
    02-JUL-24 19:47:34.438: W-1      Completed 1 SCHEDULER objects in 0 seconds
    02-JUL-24 19:47:34.442: W-1 Processing object type DATABASE_EXPORT/PRE_SYSTEM_IMPCALLOUT/MARKER/WMSYS
    02-JUL-24 19:47:34.846: W-1      Completed 1 WMSYS objects in 0 seconds
    02-JUL-24 19:47:34.849: W-1 Processing object type DATABASE_EXPORT/PRE_SYSTEM_IMPCALLOUT/MARKER/DATAPUMP
    02-JUL-24 19:47:34.888: W-1      Completed 1 DATAPUMP objects in 0 seconds
    02-JUL-24 19:47:34.937: W-1      Completed 1 [internal] PRE_SYSTEM objects in 0 seconds
    02-JUL-24 19:47:34.937: W-1      Completed by worker 1 1 MARKER objects in 0 seconds
    02-JUL-24 19:47:34.956: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER/AUDIT_TRAILS
    02-JUL-24 19:47:35.089: W-1      Completed 10 AUDIT_TRAILS objects in 1 seconds
    02-JUL-24 19:47:35.092: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER/DATAPUMP
    02-JUL-24 19:47:35.100: W-1      Completed 1 DATAPUMP objects in 0 seconds
    02-JUL-24 19:47:35.103: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER/NETWORK_ACL
    02-JUL-24 19:47:35.133: W-1      Completed 3 NETWORK_ACL objects in 0 seconds
    02-JUL-24 19:47:35.136: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER/PSTDY
    02-JUL-24 19:47:35.151: W-1      Completed 2 PSTDY objects in 0 seconds
    02-JUL-24 19:47:35.154: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER/SCHEDULER
    02-JUL-24 19:47:35.181: W-1      Completed 2 SCHEDULER objects in 0 seconds
    02-JUL-24 19:47:35.184: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER/SMB
    02-JUL-24 19:47:35.229: W-1      Completed 6 SMB objects in 0 seconds
    02-JUL-24 19:47:35.232: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER/SQL_FIREWALL
    02-JUL-24 19:47:35.235: W-1      Completed 5 SQL_FIREWALL objects in 0 seconds
    02-JUL-24 19:47:35.238: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER/TSDP
    02-JUL-24 19:47:35.312: W-1      Completed 12 TSDP objects in 0 seconds
    02-JUL-24 19:47:35.315: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER/WMSYS
    02-JUL-24 19:47:35.423: W-1      Completed 53 WMSYS objects in 0 seconds
    02-JUL-24 19:47:35.432: W-1      Completed 1 [internal] PRE_INSTANCE objects in 1 seconds
    02-JUL-24 19:47:35.432: W-1      Completed by worker 1 1 MARKER objects in 1 seconds
    02-JUL-24 19:47:35.435: W-1 Processing object type DATABASE_EXPORT/PLUGTS_FULL/PLUGTS_BLK
    02-JUL-24 19:47:35.631: W-1      Completed 1 PLUGTS_BLK objects in 0 seconds
    02-JUL-24 19:47:35.631: W-1      Completed by worker 1 1 PLUGTS_BLK objects in 0 seconds
    02-JUL-24 19:47:35.634: W-1 Processing object type DATABASE_EXPORT/TABLESPACE
    02-JUL-24 19:47:35.695: ORA-31684: Object type TABLESPACE:"UNDOTBS1" already exists
    
    02-JUL-24 19:47:35.695: ORA-31684: Object type TABLESPACE:"TEMP" already exists
    
    02-JUL-24 19:47:35.709: W-1      Completed 2 TABLESPACE objects in 0 seconds
    02-JUL-24 19:47:35.709: W-1      Completed by worker 1 2 TABLESPACE objects in 0 seconds
    02-JUL-24 19:47:35.723: W-1 Processing object type DATABASE_EXPORT/PROFILE
    02-JUL-24 19:47:35.772: W-1      Completed 1 PROFILE objects in 0 seconds
    02-JUL-24 19:47:35.772: W-1      Completed by worker 1 1 PROFILE objects in 0 seconds
    02-JUL-24 19:47:35.775: W-1 Processing object type DATABASE_EXPORT/SCHEMA/USER
    02-JUL-24 19:47:35.860: W-1      Completed 3 USER objects in 0 seconds
    02-JUL-24 19:47:35.860: W-1      Completed by worker 1 3 USER objects in 0 seconds
    02-JUL-24 19:47:35.864: W-1 Processing object type DATABASE_EXPORT/RADM_FPTM
    02-JUL-24 19:47:35.904: ORA-39083: Object type RADM_FPTM failed to create with error:
    ORA-01843: An invalid month was specified.
    
    Failing sql is:
    BEGIN DBMS_REDACT.UPDATE_FULL_REDACTION_VALUES(number_val => 0,binfloat_val => 0.000000,bindouble_val => 0.000000,char_val => ' ',    varchar_val => ' ',nchar_val => ' ',nvarchar_val => ' ',date_val => '01-01-2001 00:00:00',ts_val => '01-JAN-01 01.00.00.000000 AM',    tswtz_val => '01-JAN-01 01.00.00.000000 AM +00:00');END;
    
    02-JUL-24 19:47:35.914: W-1      Completed 1 RADM_FPTM objects in 0 seconds
    02-JUL-24 19:47:35.914: W-1      Completed by worker 1 1 RADM_FPTM objects in 0 seconds
    02-JUL-24 19:47:35.936: W-1 Processing object type DATABASE_EXPORT/GRANT/SYSTEM_GRANT/PROC_SYSTEM_GRANT/RULE
    02-JUL-24 19:47:35.969: W-1      Completed 1 RULE objects in 0 seconds
    02-JUL-24 19:47:35.972: W-1 Processing object type DATABASE_EXPORT/GRANT/SYSTEM_GRANT/PROC_SYSTEM_GRANT/AQ
    02-JUL-24 19:47:35.992: W-1      Completed 1 AQ objects in 0 seconds
    02-JUL-24 19:47:35.995: W-1 Processing object type DATABASE_EXPORT/GRANT/SYSTEM_GRANT/PROC_SYSTEM_GRANT/RMGR
    02-JUL-24 19:47:36.011: ORA-39083: Object type RMGR:PROC_SYSTEM_GRANT failed to create with error:
    ORA-29393: user EM_EXPRESS_ALL does not exist or is not logged on
    
    02-JUL-24 19:47:36.015: W-1      Completed 1 RMGR objects in 1 seconds
    02-JUL-24 19:47:36.018: W-1 Processing object type DATABASE_EXPORT/GRANT/SYSTEM_GRANT/PROC_SYSTEM_GRANT/SQL
    02-JUL-24 19:47:36.036: W-1      Completed 1 SQL objects in 0 seconds
    02-JUL-24 19:47:36.038: W-1 Processing object type DATABASE_EXPORT/GRANT/SYSTEM_GRANT/PROC_SYSTEM_GRANT/RULE
    02-JUL-24 19:47:36.047: W-1      Completed 2 RULE objects in 0 seconds
    02-JUL-24 19:47:36.057: W-1 Processing object type DATABASE_EXPORT/SCHEMA/GRANT/SYSTEM_GRANT
    02-JUL-24 19:47:36.214: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'DATAPATCH_ROLE' does not exist
    
    Failing sql is:
    GRANT ALTER SESSION TO "DATAPATCH_ROLE"
    
    02-JUL-24 19:47:36.214: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_BASIC' does not exist
    
    Failing sql is:
    GRANT CREATE SESSION TO "EM_EXPRESS_BASIC"
    
    02-JUL-24 19:47:36.214: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-00990: missing or invalid privilege
    
    Failing sql is:
    GRANT EM EXPRESS CONNECT TO "EM_EXPRESS_BASIC"
    
    02-JUL-24 19:47:36.214: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT ADVISOR TO "EM_EXPRESS_ALL"
    
    02-JUL-24 19:47:36.214: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT CREATE JOB TO "EM_EXPRESS_ALL"
    
    02-JUL-24 19:47:36.214: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT ADMINISTER SQL TUNING SET TO "EM_EXPRESS_ALL"
    
    02-JUL-24 19:47:36.214: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT ADMINISTER ANY SQL TUNING SET TO "EM_EXPRESS_ALL"
    
    02-JUL-24 19:47:36.214: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT ADMINISTER SQL MANAGEMENT OBJECT TO "EM_EXPRESS_ALL"
    
    02-JUL-24 19:47:36.214: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT ALTER SYSTEM TO "EM_EXPRESS_ALL"
    
    02-JUL-24 19:47:36.214: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT CREATE TABLESPACE TO "EM_EXPRESS_ALL"
    
    02-JUL-24 19:47:36.214: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT DROP TABLESPACE TO "EM_EXPRESS_ALL"
    
    02-JUL-24 19:47:36.214: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT ALTER TABLESPACE TO "EM_EXPRESS_ALL"
    
    02-JUL-24 19:47:36.214: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT GRANT ANY OBJECT PRIVILEGE TO "EM_EXPRESS_ALL"
    
    02-JUL-24 19:47:36.214: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT GRANT ANY PRIVILEGE TO "EM_EXPRESS_ALL"
    
    02-JUL-24 19:47:36.214: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT GRANT ANY ROLE TO "EM_EXPRESS_ALL"
    
    02-JUL-24 19:47:36.214: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT CREATE ROLE TO "EM_EXPRESS_ALL"
    
    02-JUL-24 19:47:36.214: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT DROP ANY ROLE TO "EM_EXPRESS_ALL"
    
    02-JUL-24 19:47:36.214: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT ALTER ANY ROLE TO "EM_EXPRESS_ALL"
    
    02-JUL-24 19:47:36.214: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT CREATE USER TO "EM_EXPRESS_ALL"
    
    02-JUL-24 19:47:36.214: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT DROP USER TO "EM_EXPRESS_ALL"
    
    02-JUL-24 19:47:36.214: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT ALTER USER TO "EM_EXPRESS_ALL"
    
    02-JUL-24 19:47:36.214: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT CREATE PROFILE TO "EM_EXPRESS_ALL"
    
    02-JUL-24 19:47:36.214: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT ALTER PROFILE TO "EM_EXPRESS_ALL"
    
    02-JUL-24 19:47:36.214: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT DROP PROFILE TO "EM_EXPRESS_ALL"
    
    02-JUL-24 19:47:36.214: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT SET CONTAINER TO "EM_EXPRESS_ALL"
    
    02-JUL-24 19:47:36.227: W-1      Completed 73 SYSTEM_GRANT objects in 0 seconds
    02-JUL-24 19:47:36.227: W-1      Completed by worker 1 73 SYSTEM_GRANT objects in 0 seconds
    02-JUL-24 19:47:36.231: W-1 Processing object type DATABASE_EXPORT/SCHEMA/ROLE_GRANT
    02-JUL-24 19:47:36.379: ORA-39083: Object type ROLE_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_BASIC' does not exist
    
    Failing sql is:
     GRANT "SELECT_CATALOG_ROLE" TO "EM_EXPRESS_BASIC"
    
    02-JUL-24 19:47:36.379: ORA-39083: Object type ROLE_GRANT failed to create with error:
    ORA-01919: Role 'EM_EXPRESS_ALL' does not exist.
    
    Failing sql is:
     GRANT "EM_EXPRESS_ALL" TO "DBA"
    
    02-JUL-24 19:47:36.379: ORA-39083: Object type ROLE_GRANT failed to create with error:
    ORA-01919: Role 'EM_EXPRESS_BASIC' does not exist.
    
    Failing sql is:
     GRANT "EM_EXPRESS_BASIC" TO "EM_EXPRESS_ALL"
    
    02-JUL-24 19:47:36.390: W-1      Completed 41 ROLE_GRANT objects in 0 seconds
    02-JUL-24 19:47:36.390: W-1      Completed by worker 1 41 ROLE_GRANT objects in 0 seconds
    02-JUL-24 19:47:36.393: W-1 Processing object type DATABASE_EXPORT/SCHEMA/DEFAULT_ROLE
    02-JUL-24 19:47:36.445: W-1      Completed 5 DEFAULT_ROLE objects in 0 seconds
    02-JUL-24 19:47:36.445: W-1      Completed by worker 1 5 DEFAULT_ROLE objects in 0 seconds
    02-JUL-24 19:47:36.448: W-1 Processing object type DATABASE_EXPORT/SCHEMA/ON_USER_GRANT
    02-JUL-24 19:47:36.496: W-1      Completed 3 ON_USER_GRANT objects in 0 seconds
    02-JUL-24 19:47:36.496: W-1      Completed by worker 1 3 ON_USER_GRANT objects in 0 seconds
    02-JUL-24 19:47:36.499: W-1 Processing object type DATABASE_EXPORT/SCHEMA/TABLESPACE_QUOTA
    02-JUL-24 19:47:36.555: W-1      Completed 4 TABLESPACE_QUOTA objects in 0 seconds
    02-JUL-24 19:47:36.555: W-1      Completed by worker 1 4 TABLESPACE_QUOTA objects in 0 seconds
    02-JUL-24 19:47:36.558: W-1 Processing object type DATABASE_EXPORT/RESOURCE_COST
    02-JUL-24 19:47:36.602: W-1      Completed 1 RESOURCE_COST objects in 0 seconds
    02-JUL-24 19:47:36.602: W-1      Completed by worker 1 1 RESOURCE_COST objects in 0 seconds
    02-JUL-24 19:47:36.605: W-1 Processing object type DATABASE_EXPORT/TRUSTED_DB_LINK
    02-JUL-24 19:47:36.653: W-1      Completed 1 TRUSTED_DB_LINK objects in 0 seconds
    02-JUL-24 19:47:36.653: W-1      Completed by worker 1 1 TRUSTED_DB_LINK objects in 0 seconds
    02-JUL-24 19:47:36.656: W-1 Processing object type DATABASE_EXPORT/DIRECTORY/DIRECTORY
    02-JUL-24 19:47:36.690: ORA-31684: Object type DIRECTORY:"M5DIR" already exists
    
    02-JUL-24 19:47:36.700: W-1      Completed 1 DIRECTORY objects in 0 seconds
    02-JUL-24 19:47:36.700: W-1      Completed by worker 1 1 DIRECTORY objects in 0 seconds
    02-JUL-24 19:47:36.703: W-1 Processing object type DATABASE_EXPORT/DIRECTORY/GRANT/OWNER_GRANT/OBJECT_GRANT
    02-JUL-24 19:47:36.754: W-1      Completed 2 OBJECT_GRANT objects in 0 seconds
    02-JUL-24 19:47:36.754: W-1      Completed by worker 1 2 OBJECT_GRANT objects in 0 seconds
    02-JUL-24 19:47:36.775: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/PRE_SYSTEM_ACTIONS/PROCACT_SYSTEM/LOGREP
    02-JUL-24 19:47:36.816: W-1      Completed 1 LOGREP objects in 0 seconds
    02-JUL-24 19:47:36.819: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/PRE_SYSTEM_ACTIONS/PROCACT_SYSTEM/RMGR
    02-JUL-24 19:47:36.856: W-1      Completed 1 RMGR objects in 0 seconds
    02-JUL-24 19:47:36.889: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/PROCOBJ/RMGR
    02-JUL-24 19:47:36.915: W-1      Completed 6 RMGR objects in 0 seconds
    02-JUL-24 19:47:36.918: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/PROCOBJ/SCHEDULER
    02-JUL-24 19:47:37.140: W-1      Completed 17 SCHEDULER objects in 1 seconds
    02-JUL-24 19:47:37.171: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/POST_SYSTEM_ACTIONS/PROCACT_SYSTEM/SRVR
    02-JUL-24 19:47:37.211: W-1      Completed 1 SRVR objects in 0 seconds
    02-JUL-24 19:47:37.214: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/POST_SYSTEM_ACTIONS/PROCACT_SYSTEM/RMGR
    02-JUL-24 19:47:37.325: W-1      Completed 1 RMGR objects in 0 seconds
    02-JUL-24 19:47:37.328: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/POST_SYSTEM_ACTIONS/PROCACT_SYSTEM/SEC
    02-JUL-24 19:47:37.380: W-1      Completed 1 SEC objects in 0 seconds
    02-JUL-24 19:47:37.409: W-1 Processing object type DATABASE_EXPORT/SCHEMA/PROCACT_SCHEMA/LOGREP
    02-JUL-24 19:47:37.430: W-1      Completed 6 LOGREP objects in 0 seconds
    02-JUL-24 19:47:37.440: W-1 Processing object type DATABASE_EXPORT/EARLY_OPTIONS/VIEWS_AS_TABLES/TABLE
    02-JUL-24 19:47:38.175: W-1      Completed 1 TABLE objects in 1 seconds
    02-JUL-24 19:47:38.175: W-1      Completed by worker 1 1 TABLE objects in 1 seconds
    02-JUL-24 19:47:38.203: W-1 Processing object type DATABASE_EXPORT/EARLY_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA
    02-JUL-24 19:47:39.058: W-1 . . imported "SYS"."KU$_EXPORT_USER_MAP"                   5.9 KB      26 rows in 1 seconds using direct_path
    02-JUL-24 19:47:39.079: W-1 Processing object type DATABASE_EXPORT/EARLY_POST_INSTANCE_IMPCALLOUT/MARKER/DATAPUMP
    02-JUL-24 19:47:39.091: W-1      Completed 1 DATAPUMP objects in 0 seconds
    02-JUL-24 19:47:39.103: W-1      Completed 1 [internal] EARLY_POST_INSTANCE objects in 0 seconds
    02-JUL-24 19:47:39.103: W-1      Completed by worker 1 1 MARKER objects in 0 seconds
    02-JUL-24 19:47:39.107: W-1 Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/TABLE
    02-JUL-24 19:47:40.078: W-2 Startup on instance 1 took 1 seconds
    02-JUL-24 19:47:40.084: W-4 Startup on instance 1 took 1 seconds
    02-JUL-24 19:47:40.091: W-3 Startup on instance 1 took 1 seconds
    02-JUL-24 19:47:41.867: W-1      Completed 41 TABLE objects in 2 seconds
    02-JUL-24 19:47:41.867: W-1      Completed by worker 1 10 TABLE objects in 1 seconds
    02-JUL-24 19:47:41.867: W-1      Completed by worker 2 11 TABLE objects in 1 seconds
    02-JUL-24 19:47:41.867: W-1      Completed by worker 3 10 TABLE objects in 0 seconds
    02-JUL-24 19:47:41.867: W-1      Completed by worker 4 10 TABLE objects in 1 seconds
    02-JUL-24 19:47:41.878: W-3 Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/TABLE_DATA
    02-JUL-24 19:47:42.017: W-4 . . imported "SYSTEM"."REDO_DB_TMP"                       25.6 KB       1 rows in 1 seconds using direct_path
    02-JUL-24 19:47:42.021: W-1 . . imported "WMSYS"."E$HINT_TABLE$"                        10 KB      97 rows in 1 seconds using direct_path
    02-JUL-24 19:47:42.055: W-1 . . imported "WMSYS"."E$WORKSPACE_PRIV_TABLE$"             7.1 KB      11 rows in 0 seconds using direct_path
    02-JUL-24 19:47:42.101: W-1 . . imported "SYS"."AMGT$DP$DAM_CONFIG_PARAM$"             6.5 KB      14 rows in 0 seconds using direct_path
    02-JUL-24 19:47:42.144: W-1 . . imported "SYS"."DP$TSDP_SUBPOL$"                       6.3 KB       1 rows in 0 seconds using direct_path
    02-JUL-24 19:47:42.183: W-1 . . imported "WMSYS"."E$NEXTVER_TABLE$"                    6.4 KB       1 rows in 0 seconds using direct_path
    02-JUL-24 19:47:42.219: W-1 . . imported "WMSYS"."E$ENV_VARS$"                           6 KB       3 rows in 0 seconds using direct_path
    02-JUL-24 19:47:42.255: W-1 . . imported "SYS"."DP$TSDP_PARAMETER$"                      6 KB       1 rows in 0 seconds using direct_path
    02-JUL-24 19:47:42.293: W-1 . . imported "SYS"."DP$TSDP_POLICY$"                       5.9 KB       1 rows in 0 seconds using direct_path
    02-JUL-24 19:47:42.331: W-1 . . imported "WMSYS"."E$VERSION_HIERARCHY_TABLE$"            6 KB       1 rows in 0 seconds using direct_path
    02-JUL-24 19:47:42.369: W-1 . . imported "WMSYS"."E$EVENTS_INFO$"                      5.8 KB      12 rows in 0 seconds using direct_path
    02-JUL-24 19:47:42.376: W-1 . . imported "AUDSYS"."AMGT$DP$AUD$UNIFIED":"AUD_UNIFIED_P0"     51 KB       0 rows in 0 seconds using     direct_path
    02-JUL-24 19:47:42.477: W-2 . . imported "WMSYS"."E$WORKSPACES_TABLE$"                12.1 KB       1 rows in 1 seconds using external_table
    02-JUL-24 19:47:42.625: W-1 . . imported "AUDSYS"."AMGT$DP$AUD$UNIFIED":"SYS_P261"     4.9 MB    2838 rows in 0 seconds using direct_path
    02-JUL-24 19:47:42.664: W-1 . . imported "AUDSYS"."AMGT$DP$AUD$UNIFIED":"SYS_P281"    59.2 KB      16 rows in 0 seconds using direct_path
    02-JUL-24 19:47:42.668: W-1 . . imported "SYS"."AMGT$DP$AUD$"                         23.5 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:47:42.671: W-1 . . imported "SYS"."AMGT$DP$DAM_CLEANUP_EVENTS$"           7.2 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:47:42.674: W-1 . . imported "SYS"."AMGT$DP$DAM_CLEANUP_JOBS$"             7.2 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:47:42.678: W-1 . . imported "SYS"."DP$TSDP_ASSOCIATION$"                    0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:47:42.680: W-1 . . imported "SYS"."DP$TSDP_CONDITION$"                      0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:47:42.684: W-1 . . imported "SYS"."DP$TSDP_FEATURE_POLICY$"                 0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:47:42.687: W-1 . . imported "SYS"."DP$TSDP_PROTECTION$"                     0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:47:42.691: W-1 . . imported "SYS"."DP$TSDP_SENSITIVE_DATA$"                 0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:47:42.694: W-1 . . imported "SYS"."DP$TSDP_SENSITIVE_TYPE$"                 0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:47:42.698: W-1 . . imported "SYS"."DP$TSDP_SOURCE$"                         0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:47:42.701: W-1 . . imported "SYSTEM"."REDO_LOG_TMP"                         0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:47:42.705: W-1 . . imported "WMSYS"."E$BATCH_COMPRESSIBLE_TABLES$"          0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:47:42.708: W-1 . . imported "WMSYS"."E$CONSTRAINTS_TABLE$"                  0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:47:42.711: W-1 . . imported "WMSYS"."E$CONS_COLUMNS$"                       0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:47:42.714: W-1 . . imported "WMSYS"."E$LOCKROWS_INFO$"                      0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:47:42.717: W-1 . . imported "WMSYS"."E$MODIFIED_TABLES$"                    0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:47:42.720: W-1 . . imported "WMSYS"."E$MP_GRAPH_WORKSPACES_TABLE$"          0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:47:42.723: W-1 . . imported "WMSYS"."E$MP_PARENT_WORKSPACES_TABLE$"         0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:47:42.725: W-1 . . imported "WMSYS"."E$NESTED_COLUMNS_TABLE$"               0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:47:42.728: W-1 . . imported "WMSYS"."E$RESOLVE_WORKSPACES_TABLE$"           0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:47:42.730: W-1 . . imported "WMSYS"."E$RIC_LOCKING_TABLE$"                  0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:47:42.732: W-1 . . imported "WMSYS"."E$RIC_TABLE$"                          0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:47:42.735: W-1 . . imported "WMSYS"."E$RIC_TRIGGERS_TABLE$"                 0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:47:42.737: W-1 . . imported "WMSYS"."E$UDTRIG_DISPATCH_PROCS$"              0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:47:42.739: W-1 . . imported "WMSYS"."E$UDTRIG_INFO$"                        0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:47:42.742: W-1 . . imported "WMSYS"."E$VERSION_TABLE$"                      0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:47:42.744: W-1 . . imported "WMSYS"."E$VT_ERRORS_TABLE$"                    0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:47:42.746: W-1 . . imported "WMSYS"."E$WORKSPACE_SAVEPOINTS_TABLE$"         0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:47:42.758: W-3 Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/VIEWS_AS_TABLES/TABLE
    02-JUL-24 19:47:43.336: W-4      Completed 15 TABLE objects in 1 seconds
    02-JUL-24 19:47:43.336: W-4      Completed by worker 1 4 TABLE objects in 1 seconds
    02-JUL-24 19:47:43.336: W-4      Completed by worker 2 4 TABLE objects in 1 seconds
    02-JUL-24 19:47:43.336: W-4      Completed by worker 3 3 TABLE objects in 1 seconds
    02-JUL-24 19:47:43.336: W-4      Completed by worker 4 4 TABLE objects in 1 seconds
    02-JUL-24 19:47:43.348: W-3 Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA
    02-JUL-24 19:47:43.403: W-2 . . imported "SYS"."AMGT$DP$AUDTAB$TBS$FOR_EXPORT"           6 KB       2 rows in 0 seconds using direct_path
    02-JUL-24 19:47:43.408: W-2 . . imported "SYS"."DP$DBA_SENSITIVE_DATA"                   0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:47:43.410: W-2 . . imported "SYS"."DP$DBA_TSDP_POLICY_PROTECTION"           0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:47:43.413: W-2 . . imported "SYS"."AMGT$DP$FGA_LOG$FOR_EXPORT"              0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:47:43.416: W-2 . . imported "SYS"."NACL$_ACE_IMP"                           0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:47:43.446: W-2 . . imported "SYS"."NACL$_HOST_IMP"                        6.9 KB       1 rows in 0 seconds using direct_path
    02-JUL-24 19:47:43.449: W-2 . . imported "SYS"."NACL$_WALLET_IMP"                        0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:47:43.452: W-2 . . imported "SYS"."DATAPUMP$SQL$TEXT"                       0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:47:43.455: W-2 . . imported "SYS"."DATAPUMP$SQL$"                           0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:47:43.458: W-2 . . imported "SYS"."DATAPUMP$SQLOBJ$AUXDATA"                 0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:47:43.462: W-2 . . imported "SYS"."DATAPUMP$SQLOBJ$DATA"                    0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:47:43.465: W-2 . . imported "SYS"."DATAPUMP$SQLOBJ$PLAN"                    0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:47:43.467: W-2 . . imported "SYS"."DATAPUMP$SQLOBJ$"                        0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:47:43.513: W-2 . . imported "WMSYS"."E$EXP_MAP"                           7.7 KB       3 rows in 0 seconds using direct_path
    02-JUL-24 19:47:43.515: W-2 . . imported "WMSYS"."E$METADATA_MAP"                        0 KB       0 rows in 0 seconds using direct_path
    02-JUL-24 19:47:43.539: W-1 Processing object type DATABASE_EXPORT/NORMAL_POST_INSTANCE_IMPCALLOUT/MARKER/AUDIT_TRAILS
    02-JUL-24 19:47:43.726: W-1      Completed 10 AUDIT_TRAILS objects in 0 seconds
    02-JUL-24 19:47:43.729: W-1 Processing object type DATABASE_EXPORT/NORMAL_POST_INSTANCE_IMPCALLOUT/MARKER/NETWORK_ACL
    02-JUL-24 19:47:43.747: W-1      Completed 3 NETWORK_ACL objects in 0 seconds
    02-JUL-24 19:47:43.750: W-1 Processing object type DATABASE_EXPORT/NORMAL_POST_INSTANCE_IMPCALLOUT/MARKER/PSTDY
    02-JUL-24 19:47:43.804: W-1      Completed 2 PSTDY objects in 0 seconds
    02-JUL-24 19:47:43.807: W-1 Processing object type DATABASE_EXPORT/NORMAL_POST_INSTANCE_IMPCALLOUT/MARKER/SCHEDULER
    02-JUL-24 19:47:43.811: W-1      Completed 2 SCHEDULER objects in 0 seconds
    02-JUL-24 19:47:43.814: W-1 Processing object type DATABASE_EXPORT/NORMAL_POST_INSTANCE_IMPCALLOUT/MARKER/SMB
    02-JUL-24 19:47:43.857: W-1      Completed 6 SMB objects in 0 seconds
    02-JUL-24 19:47:43.860: W-1 Processing object type DATABASE_EXPORT/NORMAL_POST_INSTANCE_IMPCALLOUT/MARKER/SQL_FIREWALL
    02-JUL-24 19:47:43.863: W-1      Completed 5 SQL_FIREWALL objects in 0 seconds
    02-JUL-24 19:47:43.865: W-1 Processing object type DATABASE_EXPORT/NORMAL_POST_INSTANCE_IMPCALLOUT/MARKER/TSDP
    02-JUL-24 19:47:43.966: W-1      Completed 12 TSDP objects in 0 seconds
    02-JUL-24 19:47:43.968: W-1 Processing object type DATABASE_EXPORT/NORMAL_POST_INSTANCE_IMPCALLOUT/MARKER/WMSYS
    02-JUL-24 19:47:44.131: W-1      Completed 53 WMSYS objects in 1 seconds
    02-JUL-24 19:47:44.193: W-4      Completed 1 [internal] Unknown objects in 1 seconds
    02-JUL-24 19:47:44.193: W-4      Completed by worker 1 1 MARKER objects in 1 seconds
    02-JUL-24 19:47:44.197: W-4 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/TABLE
    02-JUL-24 19:47:44.735: W-2      Completed 17 TABLE objects in 0 seconds
    02-JUL-24 19:47:44.735: W-2      Completed by worker 1 4 TABLE objects in 0 seconds
    02-JUL-24 19:47:44.735: W-2      Completed by worker 2 4 TABLE objects in 0 seconds
    02-JUL-24 19:47:44.735: W-2      Completed by worker 3 4 TABLE objects in 0 seconds
    02-JUL-24 19:47:44.735: W-2      Completed by worker 4 5 TABLE objects in 0 seconds
    02-JUL-24 19:47:44.786: W-1 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/INDEX/INDEX
    02-JUL-24 19:47:44.997: W-3      Completed 1 INDEX objects in 0 seconds
    02-JUL-24 19:47:44.997: W-3      Completed by worker 2 1 INDEX objects in 0 seconds
    02-JUL-24 19:47:44.997: W-3      Completed by worker 4 0 INDEX objects in  seconds
    02-JUL-24 19:47:45.000: W-3 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/CONSTRAINT/CONSTRAINT
    02-JUL-24 19:47:45.240: W-4      Completed 22 CONSTRAINT objects in 1 seconds
    02-JUL-24 19:47:45.240: W-4      Completed by worker 1 22 CONSTRAINT objects in 0 seconds
    02-JUL-24 19:47:45.243: W-4 Processing object type DATABASE_EXPORT/END_PLUGTS_BLK
    02-JUL-24 19:47:45.501: W-2      Completed 1 PLUGTS_BLK objects in 0 seconds
    02-JUL-24 19:47:45.501: W-2      Completed by worker 1 1 PLUGTS_BLK objects in 0 seconds
    02-JUL-24 19:47:45.516: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER/AUDIT_TRAILS
    02-JUL-24 19:47:45.989: W-1      Completed 10 AUDIT_TRAILS objects in 0 seconds
    02-JUL-24 19:47:45.993: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER/DATAPUMP
    02-JUL-24 19:47:46.000: W-1      Completed 1 DATAPUMP objects in 0 seconds
    02-JUL-24 19:47:46.004: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER/NETWORK_ACL
    02-JUL-24 19:47:46.196: W-1      Completed 3 NETWORK_ACL objects in 0 seconds
    02-JUL-24 19:47:46.199: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER/PSTDY
    02-JUL-24 19:47:46.220: W-1      Completed 2 PSTDY objects in 0 seconds
    02-JUL-24 19:47:46.224: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER/SCHEDULER
    02-JUL-24 19:47:46.227: W-1      Completed 2 SCHEDULER objects in 0 seconds
    02-JUL-24 19:47:46.231: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER/SMB
    02-JUL-24 19:47:48.421: W-1      Completed 6 SMB objects in 2 seconds
    02-JUL-24 19:47:48.425: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER/SQL_FIREWALL
    02-JUL-24 19:47:48.428: W-1      Completed 5 SQL_FIREWALL objects in 0 seconds
    02-JUL-24 19:47:48.431: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER/TSDP
    02-JUL-24 19:47:48.661: W-1      Completed 12 TSDP objects in 0 seconds
    02-JUL-24 19:47:48.663: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER/WMSYS
    02-JUL-24 19:47:50.324: W-1      Completed 53 WMSYS objects in 2 seconds
    02-JUL-24 19:47:50.337: W-3      Completed 1 [internal] Unknown objects in 5 seconds
    02-JUL-24 19:47:50.337: W-3      Completed by worker 1 1 MARKER objects in 5 seconds
    02-JUL-24 19:47:50.341: W-3 Processing object type DATABASE_EXPORT/AUDIT_UNIFIED/AUDIT_POLICY_ENABLE
    02-JUL-24 19:47:50.398: W-2      Completed 2 AUDIT_POLICY_ENABLE objects in 0 seconds
    02-JUL-24 19:47:50.398: W-2      Completed by worker 4 2 AUDIT_POLICY_ENABLE objects in 0 seconds
    02-JUL-24 19:47:50.411: W-1 Processing object type DATABASE_EXPORT/POST_SYSTEM_IMPCALLOUT/MARKER/SCHEDULER
    02-JUL-24 19:47:50.424: W-1      Completed 1 SCHEDULER objects in 0 seconds
    02-JUL-24 19:47:50.426: W-1 Processing object type DATABASE_EXPORT/POST_SYSTEM_IMPCALLOUT/MARKER/WMSYS
    02-JUL-24 19:47:52.111: W-1      Completed 1 WMSYS objects in 2 seconds
    02-JUL-24 19:47:52.113: W-1 Processing object type DATABASE_EXPORT/POST_SYSTEM_IMPCALLOUT/MARKER/DATAPUMP
    02-JUL-24 19:47:52.142: W-1      Completed 1 DATAPUMP objects in 0 seconds
    02-JUL-24 19:47:52.154: W-3      Completed 1 [internal] Unknown objects in 2 seconds
    02-JUL-24 19:47:52.154: W-3      Completed by worker 1 1 MARKER objects in 2 seconds
    02-JUL-24 19:47:52.211: W-4      Completed 1 DATABASE_EXPORT/EARLY_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA objects in 1 seconds
    02-JUL-24 19:47:52.215: W-4      Completed 43 DATABASE_EXPORT/NORMAL_OPTIONS/TABLE_DATA objects in 1 seconds
    02-JUL-24 19:47:52.218: W-4      Completed 17 DATABASE_EXPORT/NORMAL_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA objects in 301 seconds
    02-JUL-24 19:47:52.259: Job "SYSTEM"."SYS_IMPORT_TRANSPORTABLE_01" completed with 33 error(s) at Tue Jul 2 19:47:52 2024 elapsed 0 00:00:21    
    ```
    </details>

7. Examine the Data Pump log file for any critical issues. A FTEX import usually produces a few errors or warnings, especially when going to a higher release and into a different architecture.

    * The roles `EM_EXPRESS_ALL`, `EM_EXPRESS_BASIC` and `DATAPATCH_ROLE` do not exist in Oracle Database 23ai causing the grants to fail.
    * The same applies to the `ORACLE_OCM` user.
    * An error related to traditional auditing that is desupported in Oracle Database 23ai.
    * This log file doesn't contain any critical issues.

You may now *proceed to the next lab*.

## Acknowledgments

* **Author** - Daniel Overby Hansen
* **Contributors** - Rodrigo Jorge, Mike Dietrich, Klaus Gronau, Alex Zaballa
* **Last Updated By/Date** - Daniel Overby Hansen, August 2024
