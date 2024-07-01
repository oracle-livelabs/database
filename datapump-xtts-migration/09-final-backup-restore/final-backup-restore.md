# Final Backup and Restore

## Introduction

It's time to complete the migration. You've done all the preparations, but now it's time for an outage while you migrate the database. When the maintenance window begins you perform a final backup and restore, plus, use Data Pump to do a full transportable export/import.

Estimated Time: 20 Minutes.

### Objectives

In this lab, you will:

* Perform final backup and restore
* Data Pump export and import

## Task 1: Final backup / restore

In a real migration, you would shut down the applications using the database. Although, there is an outage, you can still query the source database. The tablespaces are read-only, so you can't add or change data, but you can query it. 

1. The outage starts now.

2. Start the final backup. When you start the driver script with *L1F*, it performs not only the final backup, but it also sets the tablespaces in *read-only* mode and starts a Data Pump full transportable export. 

    ```
    <copy>
    . ftex
    cd /home/oracle/m5
    ./dbmig_driver_m5.sh L1F
    </copy>

    -- Be sure to hit RETURN
    ```

    * You start the driver script with the argument *L1F*.
    * When prompted for *system password*, enter *ftexuser*. The password of the user you created in a previous lab. 
    * Before starting the backup, the script sets the tablespaces read-only. 
    * After the backup, the script starts Data Pump to perform a full transportable export. 
    * Notice how Data Pump lists at names of the data files needed for the migration in the end of the output. 
    * In addition, it lists the names of the Data Pump dump files. 

        <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ ./dbmig_driver_m5.sh L1F
    Properties file found, sourcing.
    LOG and CMD directories found
    2024-07-01 07:28:36 - 1719818916674: Requested L1F backup for pid 23922.  Using DISK destination, 4 channels and 64G section size.
    2024-07-01 07:28:36 - 1719818916681: Performing L1F backup for pid 23922
    ============================================
    Enter the system password to perform read only tablespaces
    
    Connected successfully
    Oracle authentication successful
    
    Tablespace altered.
    
    RMAN> 2> 3> 4> RMAN> RMAN> 2> 3> 4> 5> 6> 7> 8> 9> 10> 11> 12> 13> RMAN>
    2024-07-01 07:28:52 - 1719818932659: No errors or warnings found in backup log file for pid 23922
    2024-07-01 07:28:52 - 1719818932675: Manually copy restore script to destination
    2024-07-01 07:28:52 - 1719818932678:  => /home/oracle/m5/cmd/restore_L1F_FTEX_240701072836.cmd
    
    Export: Release 19.0.0.0.0 - Production on Mon Jul 1 07:28:52 2024
    Version 19.21.0.0.0
    
    Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.
    
    Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    01-JUL-24 07:28:57.725: Starting "FTEXUSER"."SYS_EXPORT_FULL_01":  FTEXUSER/********@localhost/ftex parfile=/home/oracle/m5/cmd/    exp_FTEX_240701072836_xtts.par
    01-JUL-24 07:28:58.722: W-1 Startup took 1 seconds
    01-JUL-24 07:29:02.472: W-1 Processing object type DATABASE_EXPORT/EARLY_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA
    01-JUL-24 07:29:03.672: W-1 Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/TABLE_DATA
    01-JUL-24 07:29:04.672: W-1 Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA
    01-JUL-24 07:29:05.577: W-1 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/TABLE_DATA
    01-JUL-24 07:29:08.238: W-1 Processing object type DATABASE_EXPORT/PLUGTS_FULL/FULL/PLUGTS_TABLESPACE
    01-JUL-24 07:29:08.284: W-1      Completed  PLUGTS_TABLESPACE objects in  seconds
    01-JUL-24 07:29:08.356: W-1 Processing object type DATABASE_EXPORT/PLUGTS_FULL/PLUGTS_BLK
    01-JUL-24 07:29:08.488: W-1      Completed 1 PLUGTS_BLK objects in 0 seconds
    01-JUL-24 07:29:08.925: W-1 Processing object type DATABASE_EXPORT/END_PLUGTS_BLK
    01-JUL-24 07:29:08.940: W-1      Completed 1 PLUGTS_BLK objects in 0 seconds
    01-JUL-24 07:29:08.966: W-1 Processing object type DATABASE_EXPORT/PRE_SYSTEM_IMPCALLOUT/MARKER
    01-JUL-24 07:29:08.969: W-1      Completed 1 MARKER objects in 0 seconds
    01-JUL-24 07:29:08.979: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER
    01-JUL-24 07:29:08.982: W-1      Completed 1 MARKER objects in 0 seconds
    01-JUL-24 07:29:09.047: W-1 Processing object type DATABASE_EXPORT/TABLESPACE
    01-JUL-24 07:29:09.059: W-1      Completed 2 TABLESPACE objects in 0 seconds
    01-JUL-24 07:29:09.182: W-1 Processing object type DATABASE_EXPORT/PROFILE
    01-JUL-24 07:29:09.186: W-1      Completed 1 PROFILE objects in 0 seconds
    01-JUL-24 07:29:09.230: W-1 Processing object type DATABASE_EXPORT/SCHEMA/USER
    01-JUL-24 07:29:09.235: W-1      Completed 3 USER objects in 0 seconds
    01-JUL-24 07:29:09.282: W-1 Processing object type DATABASE_EXPORT/RADM_FPTM
    01-JUL-24 07:29:09.286: W-1      Completed 1 RADM_FPTM objects in 0 seconds
    01-JUL-24 07:29:09.480: W-1 Processing object type DATABASE_EXPORT/GRANT/SYSTEM_GRANT/PROC_SYSTEM_GRANT
    01-JUL-24 07:29:09.485: W-1      Completed 6 PROC_SYSTEM_GRANT objects in 0 seconds
    01-JUL-24 07:29:09.540: W-1 Processing object type DATABASE_EXPORT/SCHEMA/GRANT/SYSTEM_GRANT
    01-JUL-24 07:29:09.560: W-1      Completed 73 SYSTEM_GRANT objects in 0 seconds
    01-JUL-24 07:29:09.584: W-1 Processing object type DATABASE_EXPORT/SCHEMA/ROLE_GRANT
    01-JUL-24 07:29:09.602: W-1      Completed 41 ROLE_GRANT objects in 0 seconds
    01-JUL-24 07:29:09.623: W-1 Processing object type DATABASE_EXPORT/SCHEMA/DEFAULT_ROLE
    01-JUL-24 07:29:09.628: W-1      Completed 5 DEFAULT_ROLE objects in 0 seconds
    01-JUL-24 07:29:09.651: W-1 Processing object type DATABASE_EXPORT/SCHEMA/ON_USER_GRANT
    01-JUL-24 07:29:09.655: W-1      Completed 3 ON_USER_GRANT objects in 0 seconds
    01-JUL-24 07:29:09.694: W-1 Processing object type DATABASE_EXPORT/SCHEMA/TABLESPACE_QUOTA
    01-JUL-24 07:29:09.699: W-1      Completed 4 TABLESPACE_QUOTA objects in 0 seconds
    01-JUL-24 07:29:09.716: W-1 Processing object type DATABASE_EXPORT/RESOURCE_COST
    01-JUL-24 07:29:09.721: W-1      Completed 1 RESOURCE_COST objects in 0 seconds
    01-JUL-24 07:29:09.804: W-1 Processing object type DATABASE_EXPORT/TRUSTED_DB_LINK
    01-JUL-24 07:29:09.808: W-1      Completed 1 TRUSTED_DB_LINK objects in 0 seconds
    01-JUL-24 07:29:09.879: W-1 Processing object type DATABASE_EXPORT/DIRECTORY/DIRECTORY
    01-JUL-24 07:29:09.884: W-1      Completed 1 DIRECTORY objects in 0 seconds
    01-JUL-24 07:29:10.087: W-1 Processing object type DATABASE_EXPORT/DIRECTORY/GRANT/OWNER_GRANT/OBJECT_GRANT
    01-JUL-24 07:29:10.092: W-1      Completed 2 OBJECT_GRANT objects in 1 seconds
    01-JUL-24 07:29:11.032: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/PRE_SYSTEM_ACTIONS/PROCACT_SYSTEM
    01-JUL-24 07:29:11.105: W-1      Completed 2 PROCACT_SYSTEM objects in 1 seconds
    01-JUL-24 07:29:11.308: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/PROCOBJ
    01-JUL-24 07:29:11.318: W-1      Completed 23 PROCOBJ objects in 0 seconds
    01-JUL-24 07:29:11.809: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/POST_SYSTEM_ACTIONS/PROCACT_SYSTEM
    01-JUL-24 07:29:11.849: W-1      Completed 3 PROCACT_SYSTEM objects in 0 seconds
    01-JUL-24 07:29:12.364: W-1 Processing object type DATABASE_EXPORT/SCHEMA/PROCACT_SCHEMA
    01-JUL-24 07:29:12.370: W-1      Completed 6 PROCACT_SCHEMA objects in 1 seconds
    01-JUL-24 07:29:23.613: W-1 Processing object type DATABASE_EXPORT/EARLY_OPTIONS/VIEWS_AS_TABLES/TABLE
    01-JUL-24 07:29:23.644: W-1      Completed 1 TABLE objects in 4 seconds
    01-JUL-24 07:29:23.684: W-1 Processing object type DATABASE_EXPORT/EARLY_POST_INSTANCE_IMPCALLOUT/MARKER
    01-JUL-24 07:29:23.687: W-1      Completed 1 MARKER objects in 0 seconds
    01-JUL-24 07:29:41.291: W-1 Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/TABLE
    01-JUL-24 07:29:58.448: W-1      Completed 41 TABLE objects in 35 seconds
    01-JUL-24 07:30:02.874: W-1 Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/VIEWS_AS_TABLES/TABLE
    01-JUL-24 07:30:18.108: W-1      Completed 17 TABLE objects in 18 seconds
    01-JUL-24 07:30:18.696: W-1 Processing object type DATABASE_EXPORT/NORMAL_POST_INSTANCE_IMPCALLOUT/MARKER
    01-JUL-24 07:30:18.791: W-1      Completed 1 MARKER objects in 1 seconds
    01-JUL-24 07:30:23.327: W-1 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/TABLE
    01-JUL-24 07:30:39.947: W-1      Completed 16 TABLE objects in 20 seconds
    01-JUL-24 07:30:40.845: W-1 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/COMMENT
    01-JUL-24 07:30:42.895: W-1 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/INDEX/INDEX
    01-JUL-24 07:30:42.955: W-1      Completed 1 INDEX objects in 1 seconds
    01-JUL-24 07:30:43.998: W-1 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/CONSTRAINT/CONSTRAINT
    01-JUL-24 07:30:44.016: W-1      Completed 22 CONSTRAINT objects in 1 seconds
    01-JUL-24 07:30:45.331: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER
    01-JUL-24 07:30:45.334: W-1      Completed 1 MARKER objects in 0 seconds
    01-JUL-24 07:30:48.567: W-1 Processing object type DATABASE_EXPORT/AUDIT_UNIFIED/AUDIT_POLICY_ENABLE
    01-JUL-24 07:30:48.639: W-1      Completed 2 AUDIT_POLICY_ENABLE objects in 0 seconds
    01-JUL-24 07:30:48.749: W-1 Processing object type DATABASE_EXPORT/POST_SYSTEM_IMPCALLOUT/MARKER
    01-JUL-24 07:30:48.751: W-1      Completed 1 MARKER objects in 0 seconds
    01-JUL-24 07:30:49.642: W-1 . . exported "SYS"."KU$_USER_MAPPING_VIEW"               5.906 KB      26 rows in 1 seconds using external_table
    01-JUL-24 07:30:50.637: W-1 . . exported "AUDSYS"."AUD$UNIFIED":"SYS_P261"           4.871 MB    2839 rows in 0 seconds using direct_path
    01-JUL-24 07:30:50.681: W-1 . . exported "SYSTEM"."REDO_DB"                          25.59 KB       1 rows in 0 seconds using direct_path
    01-JUL-24 07:30:50.780: W-1 . . exported "WMSYS"."WM$WORKSPACES_TABLE$"              12.10 KB       1 rows in 0 seconds using direct_path
    01-JUL-24 07:30:50.877: W-1 . . exported "WMSYS"."WM$HINT_TABLE$"                    9.984 KB      97 rows in 0 seconds using direct_path
    01-JUL-24 07:30:50.905: W-1 . . exported "WMSYS"."WM$WORKSPACE_PRIV_TABLE$"          7.078 KB      11 rows in 0 seconds using direct_path
    01-JUL-24 07:30:50.928: W-1 . . exported "SYS"."DAM_CONFIG_PARAM$"                   6.531 KB      14 rows in 0 seconds using direct_path
    01-JUL-24 07:30:50.953: W-1 . . exported "SYS"."TSDP_SUBPOL$"                        6.328 KB       1 rows in 0 seconds using direct_path
    01-JUL-24 07:30:50.978: W-1 . . exported "WMSYS"."WM$NEXTVER_TABLE$"                 6.375 KB       1 rows in 0 seconds using direct_path
    01-JUL-24 07:30:51.013: W-1 . . exported "WMSYS"."WM$ENV_VARS$"                      6.015 KB       3 rows in 1 seconds using direct_path
    01-JUL-24 07:30:51.029: W-1 . . exported "SYS"."TSDP_PARAMETER$"                     5.953 KB       1 rows in 0 seconds using direct_path
    01-JUL-24 07:30:51.054: W-1 . . exported "SYS"."TSDP_POLICY$"                        5.921 KB       1 rows in 0 seconds using direct_path
    01-JUL-24 07:30:51.080: W-1 . . exported "WMSYS"."WM$VERSION_HIERARCHY_TABLE$"       5.984 KB       1 rows in 0 seconds using direct_path
    01-JUL-24 07:30:51.106: W-1 . . exported "WMSYS"."WM$EVENTS_INFO$"                   5.812 KB      12 rows in 0 seconds using direct_path
    01-JUL-24 07:30:51.186: W-1 . . exported "AUDSYS"."AUD$UNIFIED":"AUD_UNIFIED_P0"     50.95 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:30:51.221: W-1 . . exported "AUDSYS"."AUD$UNIFIED":"SYS_P321"           57.10 KB      11 rows in 0 seconds using direct_path
    01-JUL-24 07:30:51.253: W-1 . . exported "SYS"."AUD$"                                23.46 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:30:51.276: W-1 . . exported "SYS"."DAM_CLEANUP_EVENTS$"                 7.187 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:30:51.300: W-1 . . exported "SYS"."DAM_CLEANUP_JOBS$"                   7.171 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:30:51.304: W-1 . . exported "SYS"."TSDP_ASSOCIATION$"                       0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:30:51.307: W-1 . . exported "SYS"."TSDP_CONDITION$"                         0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:30:51.311: W-1 . . exported "SYS"."TSDP_FEATURE_POLICY$"                    0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:30:51.315: W-1 . . exported "SYS"."TSDP_PROTECTION$"                        0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:30:51.319: W-1 . . exported "SYS"."TSDP_SENSITIVE_DATA$"                    0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:30:51.323: W-1 . . exported "SYS"."TSDP_SENSITIVE_TYPE$"                    0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:30:51.328: W-1 . . exported "SYS"."TSDP_SOURCE$"                            0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:30:51.332: W-1 . . exported "SYSTEM"."REDO_LOG"                             0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:30:51.336: W-1 . . exported "WMSYS"."WM$BATCH_COMPRESSIBLE_TABLES$"         0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:30:51.342: W-1 . . exported "WMSYS"."WM$CONSTRAINTS_TABLE$"                 0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:30:51.346: W-1 . . exported "WMSYS"."WM$CONS_COLUMNS$"                      0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:30:51.350: W-1 . . exported "WMSYS"."WM$LOCKROWS_INFO$"                     0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:30:51.354: W-1 . . exported "WMSYS"."WM$MODIFIED_TABLES$"                   0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:30:51.358: W-1 . . exported "WMSYS"."WM$MP_GRAPH_WORKSPACES_TABLE$"         0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:30:51.363: W-1 . . exported "WMSYS"."WM$MP_PARENT_WORKSPACES_TABLE$"        0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:30:51.366: W-1 . . exported "WMSYS"."WM$NESTED_COLUMNS_TABLE$"              0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:30:51.369: W-1 . . exported "WMSYS"."WM$RESOLVE_WORKSPACES_TABLE$"          0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:30:51.374: W-1 . . exported "WMSYS"."WM$RIC_LOCKING_TABLE$"                 0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:30:51.379: W-1 . . exported "WMSYS"."WM$RIC_TABLE$"                         0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:30:51.383: W-1 . . exported "WMSYS"."WM$RIC_TRIGGERS_TABLE$"                0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:30:51.390: W-1 . . exported "WMSYS"."WM$UDTRIG_DISPATCH_PROCS$"             0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:30:51.398: W-1 . . exported "WMSYS"."WM$UDTRIG_INFO$"                       0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:30:51.401: W-1 . . exported "WMSYS"."WM$VERSION_TABLE$"                     0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:30:51.404: W-1 . . exported "WMSYS"."WM$VT_ERRORS_TABLE$"                   0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:30:51.407: W-1 . . exported "WMSYS"."WM$WORKSPACE_SAVEPOINTS_TABLE$"        0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:30:52.450: W-1 . . exported "SYS"."AUDTAB$TBS$FOR_EXPORT"               5.960 KB       2 rows in 1 seconds using external_table
    01-JUL-24 07:30:52.838: W-1 . . exported "SYS"."DBA_SENSITIVE_DATA"                      0 KB       0 rows in 0 seconds using external_table
    01-JUL-24 07:30:53.104: W-1 . . exported "SYS"."DBA_TSDP_POLICY_PROTECTION"              0 KB       0 rows in 0 seconds using external_table
    01-JUL-24 07:30:53.246: W-1 . . exported "SYS"."FGA_LOG$FOR_EXPORT"                      0 KB       0 rows in 0 seconds using external_table
    01-JUL-24 07:30:53.249: W-1 . . exported "SYS"."NACL$_ACE_EXP"                           0 KB       0 rows in 0 seconds using external_table
    01-JUL-24 07:30:53.253: W-1 . . exported "SYS"."NACL$_HOST_EXP"                      6.914 KB       1 rows in 0 seconds using external_table
    01-JUL-24 07:30:53.256: W-1 . . exported "SYS"."NACL$_WALLET_EXP"                        0 KB       0 rows in 0 seconds using external_table
    01-JUL-24 07:30:53.258: W-1 . . exported "SYS"."SQL$TEXT_DATAPUMP"                       0 KB       0 rows in 0 seconds using external_table
    01-JUL-24 07:30:53.260: W-1 . . exported "SYS"."SQL$_DATAPUMP"                           0 KB       0 rows in 0 seconds using external_table
    01-JUL-24 07:30:53.263: W-1 . . exported "SYS"."SQLOBJ$AUXDATA_DATAPUMP"                 0 KB       0 rows in 0 seconds using external_table
    01-JUL-24 07:30:53.265: W-1 . . exported "SYS"."SQLOBJ$DATA_DATAPUMP"                    0 KB       0 rows in 0 seconds using external_table
    01-JUL-24 07:30:53.267: W-1 . . exported "SYS"."SQLOBJ$PLAN_DATAPUMP"                    0 KB       0 rows in 0 seconds using external_table
    01-JUL-24 07:30:53.269: W-1 . . exported "SYS"."SQLOBJ$_DATAPUMP"                        0 KB       0 rows in 0 seconds using external_table
    01-JUL-24 07:30:53.271: W-1 . . exported "SYSTEM"."SCHEDULER_JOB_ARGS"                   0 KB       0 rows in 0 seconds using external_table
    01-JUL-24 07:30:53.273: W-1 . . exported "SYSTEM"."SCHEDULER_PROGRAM_ARGS"               0 KB       0 rows in 0 seconds using external_table
    01-JUL-24 07:30:53.927: W-1 . . exported "WMSYS"."WM$EXP_MAP"                        7.718 KB       3 rows in 0 seconds using external_table
    01-JUL-24 07:30:53.930: W-1 . . exported "WMSYS"."WM$METADATA_MAP"                       0 KB       0 rows in 0 seconds using external_table
    01-JUL-24 07:30:57.348: W-1      Completed 1 DATABASE_EXPORT/EARLY_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA objects in 1 seconds
    01-JUL-24 07:30:57.541: W-1      Completed 43 DATABASE_EXPORT/NORMAL_OPTIONS/TABLE_DATA objects in 1 seconds
    01-JUL-24 07:30:57.823: W-1      Completed 17 DATABASE_EXPORT/NORMAL_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA objects in 2 seconds
    01-JUL-24 07:30:59.351: W-1 Master table "FTEXUSER"."SYS_EXPORT_FULL_01" successfully loaded/unloaded
    01-JUL-24 07:30:59.400: ******************************************************************************
    01-JUL-24 07:30:59.402: Dump file set for FTEXUSER.SYS_EXPORT_FULL_01 is:
    01-JUL-24 07:30:59.403:   /home/oracle/m5/m5dir/exp_FTEX_240701072836.dmp
    01-JUL-24 07:30:59.403: ******************************************************************************
    01-JUL-24 07:30:59.404: Datafiles required for transportable tablespace USERS:
    01-JUL-24 07:30:59.409:   /u02/oradata/FTEX/datafile/o1_mf_users_m7ro96bm_.dbf
    01-JUL-24 07:30:59.439: Job "FTEXUSER"."SYS_EXPORT_FULL_01" successfully completed at Mon Jul 1 07:30:59 2024 elapsed 0 00:02:04
    
    
    BACKUP_TYPE	     INPUT_BYTES(MB) OUTPUT_BYTES(MB) STATUS		      START_TIME	  END_TIME	      ELAPSED_TIME(Min)
    -------------------- --------------- ---------------- ----------------------- ------------------- ------------------- -----------------
    DATAFILE FULL		  20.7421875	      .390625 COMPLETED 	      07/01/2024:07:28:50 07/01/2024:07:28:52		    .03    
    ```
    </details>

3. Restore the backup.

    ```
    <copy>
    cd cmd
    export L1FSCRIPT=$(ls -tr restore_L1F* | tail -1) 
    cd /home/oracle/m5
    . cdb23
    rman target "sys/oracle@'localhost/violet'" cmdfile=/home/oracle/m5/cmd/$L1FSCRIPT
    </copy>

    -- Be sure to hit RETURN
    ```

    * Restoring the final backup is just like the other restore operations. 
    * The only difference is that the tablespaces are set read-only so the SCN of the data files matches the SCN at which you run the Data Pump transportable export.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ cd cmd
    $ export L1FSCRIPT=$(ls -tr restore_L1F* | tail -1)
    $ cd /home/oracle/m5
    $ . cdb23
    $ rman target "sys/oracle@'localhost/violet'" cmdfile=/home/oracle/m5/cmd/$L1FSCRIPT
    
    Recovery Manager: Release 23.0.0.0.0 - Production on Mon Jul 1 07:33:46 2024
    Version 23.4.0.24.05
    
    Copyright (c) 1982, 2024, Oracle and/or its affiliates.  All rights reserved.
    
    connected to target database: CDB23:VIOLET (DBID=2191807622)
    
    RMAN> SPOOL LOG TO log/restore_L1F_FTEX_240701072836.log;
    2> SPOOL TRACE TO log/restore_L1F_FTEX_240701072836.trc;
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
    14> '/home/oracle/m5/rman/L1F_FTEX_USERS_1173166131_5_1';}    
    ```
    </details>

## Task 2: Data Pump import

1. Examine the import driver script. For the Data Pump transportable import you use the import driver script `impdp.sh`. It's located in the script base folder. Normally, you need to fill in information about your target database, but in this lab it is done for you.

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
    
2. Start the import driver script.

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

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ cd m5dir
    $ export DMPFILE=$(ls -tr exp_FTEX*dmp | tail -1)
    $ cd ../log
    $ export L1FLOGFILE=$(ls -tr restore_L1F*log | tail -1)
    $ cd ..
    $ echo $DMPFILE
    exp_FTEX_240701072836.dmp
    $ echo $L1FLOGFILE
    restore_L1F_FTEX_240701072836.log
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

5. Examine the Data Pump parameter file.

    ```
    <copy>
    cat $(ls -tr imp_CDB23*xtts.par | tail -1)
    </copy>
    ```

    * If you need to make any changes to the Data Pump parameter file, you must edit the import driver script, *impdp.sh*, and make the changes there. 
    * The script generates a new parameter file each time you execute it. Any changes made to the parameter file is lost.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ cat $(ls -tr imp_CDB23*xtts.par | tail -1)
    userid='system@localhost/violet'
    dumpfile=exp_FTEX_240621100752.dmp
    directory=M5DIR
    LOGTIME=ALL
    TRACE=0
    PARALLEL=4
    LOGFILE=imp_CDB23_240621101933_xtts.log
    METRICS=YES
    ENCRYPTION_PWD_PROMPT=NO
    TRANSPORT_DATAFILES=
    '/u01/app/oracle/oradata/CDB23/1677972AFD1B4805E065000000000001/datafile/o1_mf_users_m7bhc8p0_.dbf'
    ```
    </details>

6. Since you verified the contents of the Data Pump parameter file, you can now start the real import. Re-use the `impdp.sh` command line but switch to *run* mode. 

    ```
    <copy>
    ./impdp.sh $DMPFILE log/$L1FLOGFILE run N
    </copy>
    ```

    * When prompted for a password, enter *oracle*.
    * You connect as *SYSTEM* for the import.
    * The import runs for a few minutes. 

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ ./impdp.sh $DMPFILE log/$L1FLOGFILE run N
    Running in Run mode
    
    Restore point created.
    
    
    NAME                    SCN    TIME                            GUA STORAGE_SIZE
    ----------------------- ------ ------------------------------- --- ------------
    BEFORE_IMP_240701074406 920349 01-JUL-24 07.44.06.000000000 AM YES 209715200
    
    
    Import: Release 23.0.0.0.0 - Production on Mon Jul 1 07:44:07 2024
    Version 23.4.0.24.05
    
    Copyright (c) 1982, 2024, Oracle and/or its affiliates.  All rights reserved.
    Password:
    
    Connected to: Oracle Database 23ai Enterprise Edition Release 23.0.0.0.0 - Production
    01-JUL-24 07:44:18.433: W-1 Startup on instance 1 took 1 seconds
    01-JUL-24 07:44:19.905: W-1 Master table "SYSTEM"."SYS_IMPORT_TRANSPORTABLE_01" successfully loaded/unloaded
    01-JUL-24 07:44:20.340: Starting "SYSTEM"."SYS_IMPORT_TRANSPORTABLE_01":  system/********@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)    (HOST=localhost)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=VIOLET))) parfile=imp_CDB23_240701074406_xtts.par
    01-JUL-24 07:44:20.461: W-1 Processing object type DATABASE_EXPORT/PRE_SYSTEM_IMPCALLOUT/MARKER/SCHEDULER
    01-JUL-24 07:44:20.500: W-1      Completed 1 SCHEDULER objects in 0 seconds
    01-JUL-24 07:44:20.503: W-1 Processing object type DATABASE_EXPORT/PRE_SYSTEM_IMPCALLOUT/MARKER/WMSYS
    01-JUL-24 07:44:20.981: W-1      Completed 1 WMSYS objects in 0 seconds
    01-JUL-24 07:44:20.984: W-1 Processing object type DATABASE_EXPORT/PRE_SYSTEM_IMPCALLOUT/MARKER/DATAPUMP
    01-JUL-24 07:44:21.026: W-1      Completed 1 DATAPUMP objects in 1 seconds
    01-JUL-24 07:44:21.080: W-1      Completed 1 [internal] PRE_SYSTEM objects in 1 seconds
    01-JUL-24 07:44:21.080: W-1      Completed by worker 1 1 MARKER objects in 1 seconds
    01-JUL-24 07:44:21.102: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER/AUDIT_TRAILS
    01-JUL-24 07:44:21.227: W-1      Completed 10 AUDIT_TRAILS objects in 0 seconds
    01-JUL-24 07:44:21.231: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER/DATAPUMP
    01-JUL-24 07:44:21.238: W-1      Completed 1 DATAPUMP objects in 0 seconds
    01-JUL-24 07:44:21.242: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER/NETWORK_ACL
    01-JUL-24 07:44:21.281: W-1      Completed 3 NETWORK_ACL objects in 0 seconds
    01-JUL-24 07:44:21.285: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER/PSTDY
    01-JUL-24 07:44:21.303: W-1      Completed 2 PSTDY objects in 0 seconds
    01-JUL-24 07:44:21.308: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER/SCHEDULER
    01-JUL-24 07:44:21.337: W-1      Completed 2 SCHEDULER objects in 0 seconds
    01-JUL-24 07:44:21.342: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER/SMB
    01-JUL-24 07:44:21.390: W-1      Completed 6 SMB objects in 0 seconds
    01-JUL-24 07:44:21.395: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER/SQL_FIREWALL
    01-JUL-24 07:44:21.398: W-1      Completed 5 SQL_FIREWALL objects in 0 seconds
    01-JUL-24 07:44:21.402: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER/TSDP
    01-JUL-24 07:44:21.485: W-1      Completed 12 TSDP objects in 0 seconds
    01-JUL-24 07:44:21.489: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER/WMSYS
    01-JUL-24 07:44:21.603: W-1      Completed 53 WMSYS objects in 0 seconds
    01-JUL-24 07:44:21.615: W-1      Completed 1 [internal] PRE_INSTANCE objects in 0 seconds
    01-JUL-24 07:44:21.615: W-1      Completed by worker 1 1 MARKER objects in 0 seconds
    01-JUL-24 07:44:21.618: W-1 Processing object type DATABASE_EXPORT/PLUGTS_FULL/PLUGTS_BLK
    01-JUL-24 07:44:21.833: W-1      Completed 1 PLUGTS_BLK objects in 0 seconds
    01-JUL-24 07:44:21.833: W-1      Completed by worker 1 1 PLUGTS_BLK objects in 0 seconds
    01-JUL-24 07:44:21.836: W-1 Processing object type DATABASE_EXPORT/TABLESPACE
    01-JUL-24 07:44:21.904: ORA-31684: Object type TABLESPACE:"UNDOTBS1" already exists
    
    01-JUL-24 07:44:21.904: ORA-31684: Object type TABLESPACE:"TEMP" already exists
    
    01-JUL-24 07:44:21.920: W-1      Completed 2 TABLESPACE objects in 0 seconds
    01-JUL-24 07:44:21.920: W-1      Completed by worker 1 2 TABLESPACE objects in 0 seconds
    01-JUL-24 07:44:21.934: W-1 Processing object type DATABASE_EXPORT/PROFILE
    01-JUL-24 07:44:21.989: W-1      Completed 1 PROFILE objects in 0 seconds
    01-JUL-24 07:44:21.989: W-1      Completed by worker 1 1 PROFILE objects in 0 seconds
    01-JUL-24 07:44:21.992: W-1 Processing object type DATABASE_EXPORT/SCHEMA/USER
    01-JUL-24 07:44:22.082: W-1      Completed 3 USER objects in 1 seconds
    01-JUL-24 07:44:22.082: W-1      Completed by worker 1 3 USER objects in 1 seconds
    01-JUL-24 07:44:22.086: W-1 Processing object type DATABASE_EXPORT/RADM_FPTM
    01-JUL-24 07:44:22.132: ORA-39083: Object type RADM_FPTM failed to create with error:
    ORA-01843: An invalid month was specified.
    
    Failing sql is:
    BEGIN DBMS_REDACT.UPDATE_FULL_REDACTION_VALUES(number_val => 0,binfloat_val => 0.000000,bindouble_val => 0.000000,char_val => ' ',    varchar_val => ' ',nchar_val => ' ',nvarchar_val => ' ',date_val => '01-01-2001 00:00:00',ts_val => '01-JAN-01 01.00.00.000000 AM',    tswtz_val => '01-JAN-01 01.00.00.000000 AM +00:00');END;
    
    01-JUL-24 07:44:22.143: W-1      Completed 1 RADM_FPTM objects in 0 seconds
    01-JUL-24 07:44:22.143: W-1      Completed by worker 1 1 RADM_FPTM objects in 0 seconds
    01-JUL-24 07:44:22.167: W-1 Processing object type DATABASE_EXPORT/GRANT/SYSTEM_GRANT/PROC_SYSTEM_GRANT/RULE
    01-JUL-24 07:44:22.202: W-1      Completed 1 RULE objects in 0 seconds
    01-JUL-24 07:44:22.206: W-1 Processing object type DATABASE_EXPORT/GRANT/SYSTEM_GRANT/PROC_SYSTEM_GRANT/AQ
    01-JUL-24 07:44:22.225: W-1      Completed 1 AQ objects in 0 seconds
    01-JUL-24 07:44:22.228: W-1 Processing object type DATABASE_EXPORT/GRANT/SYSTEM_GRANT/PROC_SYSTEM_GRANT/RMGR
    01-JUL-24 07:44:22.247: ORA-39083: Object type RMGR:PROC_SYSTEM_GRANT failed to create with error:
    ORA-29393: user EM_EXPRESS_ALL does not exist or is not logged on
    
    01-JUL-24 07:44:22.253: W-1      Completed 1 RMGR objects in 0 seconds
    01-JUL-24 07:44:22.256: W-1 Processing object type DATABASE_EXPORT/GRANT/SYSTEM_GRANT/PROC_SYSTEM_GRANT/SQL
    01-JUL-24 07:44:22.276: W-1      Completed 1 SQL objects in 0 seconds
    01-JUL-24 07:44:22.279: W-1 Processing object type DATABASE_EXPORT/GRANT/SYSTEM_GRANT/PROC_SYSTEM_GRANT/RULE
    01-JUL-24 07:44:22.286: W-1      Completed 2 RULE objects in 0 seconds
    01-JUL-24 07:44:22.297: W-1 Processing object type DATABASE_EXPORT/SCHEMA/GRANT/SYSTEM_GRANT
    01-JUL-24 07:44:22.459: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'DATAPATCH_ROLE' does not exist
    
    Failing sql is:
    GRANT ALTER SESSION TO "DATAPATCH_ROLE"
    
    01-JUL-24 07:44:22.459: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_BASIC' does not exist
    
    Failing sql is:
    GRANT CREATE SESSION TO "EM_EXPRESS_BASIC"
    
    01-JUL-24 07:44:22.459: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-00990: missing or invalid privilege
    
    Failing sql is:
    GRANT EM EXPRESS CONNECT TO "EM_EXPRESS_BASIC"
    
    01-JUL-24 07:44:22.459: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT ADVISOR TO "EM_EXPRESS_ALL"
    
    01-JUL-24 07:44:22.459: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT CREATE JOB TO "EM_EXPRESS_ALL"
    
    01-JUL-24 07:44:22.459: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT ADMINISTER SQL TUNING SET TO "EM_EXPRESS_ALL"
    
    01-JUL-24 07:44:22.459: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT ADMINISTER ANY SQL TUNING SET TO "EM_EXPRESS_ALL"
    
    01-JUL-24 07:44:22.459: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT ADMINISTER SQL MANAGEMENT OBJECT TO "EM_EXPRESS_ALL"
    
    01-JUL-24 07:44:22.459: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT ALTER SYSTEM TO "EM_EXPRESS_ALL"
    
    01-JUL-24 07:44:22.459: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT CREATE TABLESPACE TO "EM_EXPRESS_ALL"
    
    01-JUL-24 07:44:22.459: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT DROP TABLESPACE TO "EM_EXPRESS_ALL"
    
    01-JUL-24 07:44:22.459: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT ALTER TABLESPACE TO "EM_EXPRESS_ALL"
    
    01-JUL-24 07:44:22.459: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT GRANT ANY OBJECT PRIVILEGE TO "EM_EXPRESS_ALL"
    
    01-JUL-24 07:44:22.459: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT GRANT ANY PRIVILEGE TO "EM_EXPRESS_ALL"
    
    01-JUL-24 07:44:22.459: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT GRANT ANY ROLE TO "EM_EXPRESS_ALL"
    
    01-JUL-24 07:44:22.459: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT CREATE ROLE TO "EM_EXPRESS_ALL"
    
    01-JUL-24 07:44:22.459: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT DROP ANY ROLE TO "EM_EXPRESS_ALL"
    
    01-JUL-24 07:44:22.459: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT ALTER ANY ROLE TO "EM_EXPRESS_ALL"
    
    01-JUL-24 07:44:22.459: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT CREATE USER TO "EM_EXPRESS_ALL"
    
    01-JUL-24 07:44:22.459: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT DROP USER TO "EM_EXPRESS_ALL"
    
    01-JUL-24 07:44:22.459: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT ALTER USER TO "EM_EXPRESS_ALL"
    
    01-JUL-24 07:44:22.459: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT CREATE PROFILE TO "EM_EXPRESS_ALL"
    
    01-JUL-24 07:44:22.459: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT ALTER PROFILE TO "EM_EXPRESS_ALL"
    
    01-JUL-24 07:44:22.459: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT DROP PROFILE TO "EM_EXPRESS_ALL"
    
    01-JUL-24 07:44:22.459: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT SET CONTAINER TO "EM_EXPRESS_ALL"
    
    01-JUL-24 07:44:22.472: W-1      Completed 73 SYSTEM_GRANT objects in 0 seconds
    01-JUL-24 07:44:22.472: W-1      Completed by worker 1 73 SYSTEM_GRANT objects in 0 seconds
    01-JUL-24 07:44:22.475: W-1 Processing object type DATABASE_EXPORT/SCHEMA/ROLE_GRANT
    01-JUL-24 07:44:22.627: ORA-39083: Object type ROLE_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_BASIC' does not exist
    
    Failing sql is:
     GRANT "SELECT_CATALOG_ROLE" TO "EM_EXPRESS_BASIC"
    
    01-JUL-24 07:44:22.627: ORA-39083: Object type ROLE_GRANT failed to create with error:
    ORA-01919: Role 'EM_EXPRESS_ALL' does not exist.
    
    Failing sql is:
     GRANT "EM_EXPRESS_ALL" TO "DBA"
    
    01-JUL-24 07:44:22.627: ORA-39083: Object type ROLE_GRANT failed to create with error:
    ORA-01919: Role 'EM_EXPRESS_BASIC' does not exist.
    
    Failing sql is:
     GRANT "EM_EXPRESS_BASIC" TO "EM_EXPRESS_ALL"
    
    01-JUL-24 07:44:22.638: W-1      Completed 41 ROLE_GRANT objects in 0 seconds
    01-JUL-24 07:44:22.638: W-1      Completed by worker 1 41 ROLE_GRANT objects in 0 seconds
    01-JUL-24 07:44:22.641: W-1 Processing object type DATABASE_EXPORT/SCHEMA/DEFAULT_ROLE
    01-JUL-24 07:44:22.694: W-1      Completed 5 DEFAULT_ROLE objects in 0 seconds
    01-JUL-24 07:44:22.694: W-1      Completed by worker 1 5 DEFAULT_ROLE objects in 0 seconds
    01-JUL-24 07:44:22.698: W-1 Processing object type DATABASE_EXPORT/SCHEMA/ON_USER_GRANT
    01-JUL-24 07:44:22.747: W-1      Completed 3 ON_USER_GRANT objects in 0 seconds
    01-JUL-24 07:44:22.747: W-1      Completed by worker 1 3 ON_USER_GRANT objects in 0 seconds
    01-JUL-24 07:44:22.750: W-1 Processing object type DATABASE_EXPORT/SCHEMA/TABLESPACE_QUOTA
    01-JUL-24 07:44:22.807: W-1      Completed 4 TABLESPACE_QUOTA objects in 0 seconds
    01-JUL-24 07:44:22.807: W-1      Completed by worker 1 4 TABLESPACE_QUOTA objects in 0 seconds
    01-JUL-24 07:44:22.811: W-1 Processing object type DATABASE_EXPORT/RESOURCE_COST
    01-JUL-24 07:44:22.855: W-1      Completed 1 RESOURCE_COST objects in 0 seconds
    01-JUL-24 07:44:22.855: W-1      Completed by worker 1 1 RESOURCE_COST objects in 0 seconds
    01-JUL-24 07:44:22.858: W-1 Processing object type DATABASE_EXPORT/TRUSTED_DB_LINK
    01-JUL-24 07:44:22.907: W-1      Completed 1 TRUSTED_DB_LINK objects in 0 seconds
    01-JUL-24 07:44:22.907: W-1      Completed by worker 1 1 TRUSTED_DB_LINK objects in 0 seconds
    01-JUL-24 07:44:22.911: W-1 Processing object type DATABASE_EXPORT/DIRECTORY/DIRECTORY
    01-JUL-24 07:44:22.945: ORA-31684: Object type DIRECTORY:"M5DIR" already exists
    
    01-JUL-24 07:44:22.956: W-1      Completed 1 DIRECTORY objects in 0 seconds
    01-JUL-24 07:44:22.956: W-1      Completed by worker 1 1 DIRECTORY objects in 0 seconds
    01-JUL-24 07:44:22.960: W-1 Processing object type DATABASE_EXPORT/DIRECTORY/GRANT/OWNER_GRANT/OBJECT_GRANT
    01-JUL-24 07:44:23.014: W-1      Completed 2 OBJECT_GRANT objects in 1 seconds
    01-JUL-24 07:44:23.014: W-1      Completed by worker 1 2 OBJECT_GRANT objects in 1 seconds
    01-JUL-24 07:44:23.036: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/PRE_SYSTEM_ACTIONS/PROCACT_SYSTEM/LOGREP
    01-JUL-24 07:44:23.083: W-1      Completed 1 LOGREP objects in 0 seconds
    01-JUL-24 07:44:23.086: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/PRE_SYSTEM_ACTIONS/PROCACT_SYSTEM/RMGR
    01-JUL-24 07:44:23.131: W-1      Completed 1 RMGR objects in 0 seconds
    01-JUL-24 07:44:23.162: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/PROCOBJ/RMGR
    01-JUL-24 07:44:23.189: W-1      Completed 6 RMGR objects in 0 seconds
    01-JUL-24 07:44:23.192: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/PROCOBJ/SCHEDULER
    01-JUL-24 07:44:23.426: W-1      Completed 17 SCHEDULER objects in 0 seconds
    01-JUL-24 07:44:23.458: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/POST_SYSTEM_ACTIONS/PROCACT_SYSTEM/SRVR
    01-JUL-24 07:44:23.570: W-1      Completed 1 SRVR objects in 0 seconds
    01-JUL-24 07:44:23.573: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/POST_SYSTEM_ACTIONS/PROCACT_SYSTEM/RMGR
    01-JUL-24 07:44:23.713: W-1      Completed 1 RMGR objects in 0 seconds
    01-JUL-24 07:44:23.716: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/POST_SYSTEM_ACTIONS/PROCACT_SYSTEM/SEC
    01-JUL-24 07:44:23.772: W-1      Completed 1 SEC objects in 0 seconds
    01-JUL-24 07:44:23.802: W-1 Processing object type DATABASE_EXPORT/SCHEMA/PROCACT_SCHEMA/LOGREP
    01-JUL-24 07:44:23.826: W-1      Completed 6 LOGREP objects in 0 seconds
    01-JUL-24 07:44:23.838: W-1 Processing object type DATABASE_EXPORT/EARLY_OPTIONS/VIEWS_AS_TABLES/TABLE
    01-JUL-24 07:44:24.686: W-1      Completed 1 TABLE objects in 1 seconds
    01-JUL-24 07:44:24.686: W-1      Completed by worker 1 1 TABLE objects in 1 seconds
    01-JUL-24 07:44:24.715: W-1 Processing object type DATABASE_EXPORT/EARLY_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA
    01-JUL-24 07:44:24.852: W-1 . . imported "SYS"."KU$_EXPORT_USER_MAP"                   5.9 KB      26 rows in 0 seconds using direct_path
    01-JUL-24 07:44:24.874: W-1 Processing object type DATABASE_EXPORT/EARLY_POST_INSTANCE_IMPCALLOUT/MARKER/DATAPUMP
    01-JUL-24 07:44:24.904: W-1      Completed 1 DATAPUMP objects in 0 seconds
    01-JUL-24 07:44:24.916: W-1      Completed 1 [internal] EARLY_POST_INSTANCE objects in 0 seconds
    01-JUL-24 07:44:24.916: W-1      Completed by worker 1 1 MARKER objects in 0 seconds
    01-JUL-24 07:44:24.919: W-1 Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/TABLE
    01-JUL-24 07:44:25.903: W-3 Startup on instance 1 took 1 seconds
    01-JUL-24 07:44:25.927: W-2 Startup on instance 1 took 1 seconds
    01-JUL-24 07:44:25.954: W-4 Startup on instance 1 took 0 seconds
    01-JUL-24 07:44:27.086: W-1      Completed 41 TABLE objects in 3 seconds
    01-JUL-24 07:44:27.086: W-1      Completed by worker 1 10 TABLE objects in 2 seconds
    01-JUL-24 07:44:27.086: W-1      Completed by worker 2 10 TABLE objects in 2 seconds
    01-JUL-24 07:44:27.086: W-1      Completed by worker 3 10 TABLE objects in 2 seconds
    01-JUL-24 07:44:27.086: W-1      Completed by worker 4 11 TABLE objects in 1 seconds
    01-JUL-24 07:44:27.098: W-4 Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/TABLE_DATA
    01-JUL-24 07:44:27.218: W-1 . . imported "WMSYS"."E$HINT_TABLE$"                        10 KB      97 rows in 0 seconds using direct_path
    01-JUL-24 07:44:27.263: W-1 . . imported "WMSYS"."E$WORKSPACE_PRIV_TABLE$"             7.1 KB      11 rows in 0 seconds using direct_path
    01-JUL-24 07:44:27.310: W-1 . . imported "SYS"."AMGT$DP$DAM_CONFIG_PARAM$"             6.5 KB      14 rows in 0 seconds using direct_path
    01-JUL-24 07:44:27.357: W-1 . . imported "SYS"."DP$TSDP_SUBPOL$"                       6.3 KB       1 rows in 0 seconds using direct_path
    01-JUL-24 07:44:27.405: W-1 . . imported "WMSYS"."E$NEXTVER_TABLE$"                    6.4 KB       1 rows in 0 seconds using direct_path
    01-JUL-24 07:44:27.465: W-3 . . imported "AUDSYS"."AMGT$DP$AUD$UNIFIED":"SYS_P261"     4.9 MB    2839 rows in 0 seconds using direct_path
    01-JUL-24 07:44:27.479: W-1 . . imported "WMSYS"."E$ENV_VARS$"                           6 KB       3 rows in 0 seconds using direct_path
    01-JUL-24 07:44:27.524: W-3 . . imported "SYSTEM"."REDO_DB_TMP"                       25.6 KB       1 rows in 0 seconds using direct_path
    01-JUL-24 07:44:27.541: W-1 . . imported "SYS"."DP$TSDP_PARAMETER$"                      6 KB       1 rows in 0 seconds using direct_path
    01-JUL-24 07:44:27.569: W-1 . . imported "SYS"."DP$TSDP_POLICY$"                       5.9 KB       1 rows in 0 seconds using direct_path
    01-JUL-24 07:44:27.608: W-1 . . imported "WMSYS"."E$VERSION_HIERARCHY_TABLE$"            6 KB       1 rows in 0 seconds using direct_path
    01-JUL-24 07:44:27.645: W-1 . . imported "WMSYS"."E$EVENTS_INFO$"                      5.8 KB      12 rows in 0 seconds using direct_path
    01-JUL-24 07:44:27.655: W-1 . . imported "AUDSYS"."AMGT$DP$AUD$UNIFIED":"AUD_UNIFIED_P0"     51 KB       0 rows in 0 seconds using     direct_path
    01-JUL-24 07:44:27.703: W-1 . . imported "AUDSYS"."AMGT$DP$AUD$UNIFIED":"SYS_P321"    57.1 KB      11 rows in 0 seconds using direct_path
    01-JUL-24 07:44:27.710: W-1 . . imported "SYS"."AMGT$DP$AUD$"                         23.5 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:44:27.714: W-1 . . imported "SYS"."AMGT$DP$DAM_CLEANUP_EVENTS$"           7.2 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:44:27.717: W-1 . . imported "SYS"."AMGT$DP$DAM_CLEANUP_JOBS$"             7.2 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:44:27.721: W-1 . . imported "SYS"."DP$TSDP_ASSOCIATION$"                    0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:44:27.725: W-1 . . imported "SYS"."DP$TSDP_CONDITION$"                      0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:44:27.728: W-1 . . imported "SYS"."DP$TSDP_FEATURE_POLICY$"                 0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:44:27.732: W-1 . . imported "SYS"."DP$TSDP_PROTECTION$"                     0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:44:27.736: W-1 . . imported "SYS"."DP$TSDP_SENSITIVE_DATA$"                 0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:44:27.740: W-1 . . imported "SYS"."DP$TSDP_SENSITIVE_TYPE$"                 0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:44:27.744: W-1 . . imported "SYS"."DP$TSDP_SOURCE$"                         0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:44:27.747: W-1 . . imported "SYSTEM"."REDO_LOG_TMP"                         0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:44:27.751: W-1 . . imported "WMSYS"."E$BATCH_COMPRESSIBLE_TABLES$"          0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:44:27.755: W-1 . . imported "WMSYS"."E$CONSTRAINTS_TABLE$"                  0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:44:27.759: W-1 . . imported "WMSYS"."E$CONS_COLUMNS$"                       0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:44:27.762: W-1 . . imported "WMSYS"."E$LOCKROWS_INFO$"                      0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:44:27.766: W-1 . . imported "WMSYS"."E$MODIFIED_TABLES$"                    0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:44:27.770: W-1 . . imported "WMSYS"."E$MP_GRAPH_WORKSPACES_TABLE$"          0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:44:27.774: W-1 . . imported "WMSYS"."E$MP_PARENT_WORKSPACES_TABLE$"         0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:44:27.777: W-1 . . imported "WMSYS"."E$NESTED_COLUMNS_TABLE$"               0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:44:27.779: W-1 . . imported "WMSYS"."E$RESOLVE_WORKSPACES_TABLE$"           0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:44:27.782: W-1 . . imported "WMSYS"."E$RIC_LOCKING_TABLE$"                  0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:44:27.784: W-1 . . imported "WMSYS"."E$RIC_TABLE$"                          0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:44:27.787: W-1 . . imported "WMSYS"."E$RIC_TRIGGERS_TABLE$"                 0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:44:27.789: W-1 . . imported "WMSYS"."E$UDTRIG_DISPATCH_PROCS$"              0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:44:27.792: W-1 . . imported "WMSYS"."E$UDTRIG_INFO$"                        0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:44:27.794: W-1 . . imported "WMSYS"."E$VERSION_TABLE$"                      0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:44:27.797: W-1 . . imported "WMSYS"."E$VT_ERRORS_TABLE$"                    0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:44:27.801: W-1 . . imported "WMSYS"."E$WORKSPACE_SAVEPOINTS_TABLE$"         0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:44:27.804: W-2 . . imported "WMSYS"."E$WORKSPACES_TABLE$"                12.1 KB       1 rows in 0 seconds using external_table
    01-JUL-24 07:44:27.818: W-4 Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/VIEWS_AS_TABLES/TABLE
    01-JUL-24 07:44:28.410: W-3      Completed 15 TABLE objects in 1 seconds
    01-JUL-24 07:44:28.410: W-3      Completed by worker 1 4 TABLE objects in 1 seconds
    01-JUL-24 07:44:28.410: W-3      Completed by worker 2 4 TABLE objects in 1 seconds
    01-JUL-24 07:44:28.410: W-3      Completed by worker 3 4 TABLE objects in 1 seconds
    01-JUL-24 07:44:28.410: W-3      Completed by worker 4 3 TABLE objects in 1 seconds
    01-JUL-24 07:44:28.423: W-4 Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA
    01-JUL-24 07:44:28.476: W-1 . . imported "SYS"."AMGT$DP$AUDTAB$TBS$FOR_EXPORT"           6 KB       2 rows in 0 seconds using direct_path
    01-JUL-24 07:44:28.480: W-1 . . imported "SYS"."DP$DBA_SENSITIVE_DATA"                   0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:44:28.483: W-1 . . imported "SYS"."DP$DBA_TSDP_POLICY_PROTECTION"           0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:44:28.486: W-1 . . imported "SYS"."AMGT$DP$FGA_LOG$FOR_EXPORT"              0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:44:28.490: W-1 . . imported "SYS"."NACL$_ACE_IMP"                           0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:44:28.518: W-1 . . imported "SYS"."NACL$_HOST_IMP"                        6.9 KB       1 rows in 0 seconds using direct_path
    01-JUL-24 07:44:28.522: W-1 . . imported "SYS"."NACL$_WALLET_IMP"                        0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:44:28.525: W-1 . . imported "SYS"."DATAPUMP$SQL$TEXT"                       0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:44:28.528: W-1 . . imported "SYS"."DATAPUMP$SQL$"                           0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:44:28.532: W-1 . . imported "SYS"."DATAPUMP$SQLOBJ$AUXDATA"                 0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:44:28.535: W-1 . . imported "SYS"."DATAPUMP$SQLOBJ$DATA"                    0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:44:28.538: W-1 . . imported "SYS"."DATAPUMP$SQLOBJ$PLAN"                    0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:44:28.542: W-1 . . imported "SYS"."DATAPUMP$SQLOBJ$"                        0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:44:28.583: W-1 . . imported "WMSYS"."E$EXP_MAP"                           7.7 KB       3 rows in 0 seconds using direct_path
    01-JUL-24 07:44:28.586: W-1 . . imported "WMSYS"."E$METADATA_MAP"                        0 KB       0 rows in 0 seconds using direct_path
    01-JUL-24 07:44:28.612: W-1 Processing object type DATABASE_EXPORT/NORMAL_POST_INSTANCE_IMPCALLOUT/MARKER/AUDIT_TRAILS
    01-JUL-24 07:44:28.807: W-1      Completed 10 AUDIT_TRAILS objects in 0 seconds
    01-JUL-24 07:44:28.810: W-1 Processing object type DATABASE_EXPORT/NORMAL_POST_INSTANCE_IMPCALLOUT/MARKER/NETWORK_ACL
    01-JUL-24 07:44:28.828: W-1      Completed 3 NETWORK_ACL objects in 0 seconds
    01-JUL-24 07:44:28.832: W-1 Processing object type DATABASE_EXPORT/NORMAL_POST_INSTANCE_IMPCALLOUT/MARKER/PSTDY
    01-JUL-24 07:44:28.891: W-1      Completed 2 PSTDY objects in 0 seconds
    01-JUL-24 07:44:28.895: W-1 Processing object type DATABASE_EXPORT/NORMAL_POST_INSTANCE_IMPCALLOUT/MARKER/SCHEDULER
    01-JUL-24 07:44:28.898: W-1      Completed 2 SCHEDULER objects in 0 seconds
    01-JUL-24 07:44:28.901: W-1 Processing object type DATABASE_EXPORT/NORMAL_POST_INSTANCE_IMPCALLOUT/MARKER/SMB
    01-JUL-24 07:44:28.946: W-1      Completed 6 SMB objects in 0 seconds
    01-JUL-24 07:44:28.950: W-1 Processing object type DATABASE_EXPORT/NORMAL_POST_INSTANCE_IMPCALLOUT/MARKER/SQL_FIREWALL
    01-JUL-24 07:44:28.954: W-1      Completed 5 SQL_FIREWALL objects in 0 seconds
    01-JUL-24 07:44:28.957: W-1 Processing object type DATABASE_EXPORT/NORMAL_POST_INSTANCE_IMPCALLOUT/MARKER/TSDP
    01-JUL-24 07:44:29.058: W-1      Completed 12 TSDP objects in 1 seconds
    01-JUL-24 07:44:29.062: W-1 Processing object type DATABASE_EXPORT/NORMAL_POST_INSTANCE_IMPCALLOUT/MARKER/WMSYS
    01-JUL-24 07:44:29.235: W-1      Completed 53 WMSYS objects in 0 seconds
    01-JUL-24 07:44:29.300: W-3      Completed 1 [internal] Unknown objects in 1 seconds
    01-JUL-24 07:44:29.300: W-3      Completed by worker 1 1 MARKER objects in 1 seconds
    01-JUL-24 07:44:29.304: W-3 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/TABLE
    01-JUL-24 07:44:29.905: W-4      Completed 16 TABLE objects in 0 seconds
    01-JUL-24 07:44:29.905: W-4      Completed by worker 1 3 TABLE objects in 0 seconds
    01-JUL-24 07:44:29.905: W-4      Completed by worker 2 3 TABLE objects in 0 seconds
    01-JUL-24 07:44:29.905: W-4      Completed by worker 3 7 TABLE objects in 0 seconds
    01-JUL-24 07:44:29.905: W-4      Completed by worker 4 3 TABLE objects in 0 seconds
    01-JUL-24 07:44:29.964: W-1 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/INDEX/INDEX
    01-JUL-24 07:44:30.195: W-2      Completed 1 INDEX objects in 1 seconds
    01-JUL-24 07:44:30.195: W-2      Completed by worker 3 0 INDEX objects in  seconds
    01-JUL-24 07:44:30.195: W-2      Completed by worker 4 1 INDEX objects in 0 seconds
    01-JUL-24 07:44:30.198: W-2 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/CONSTRAINT/CONSTRAINT
    01-JUL-24 07:44:30.459: W-3      Completed 22 CONSTRAINT objects in 0 seconds
    01-JUL-24 07:44:30.459: W-3      Completed by worker 1 22 CONSTRAINT objects in 0 seconds
    01-JUL-24 07:44:30.462: W-3 Processing object type DATABASE_EXPORT/END_PLUGTS_BLK
    01-JUL-24 07:44:30.869: W-4      Completed 1 PLUGTS_BLK objects in 0 seconds
    01-JUL-24 07:44:30.869: W-4      Completed by worker 1 1 PLUGTS_BLK objects in 0 seconds
    01-JUL-24 07:44:30.886: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER/AUDIT_TRAILS
    01-JUL-24 07:44:31.574: W-1      Completed 10 AUDIT_TRAILS objects in 1 seconds
    01-JUL-24 07:44:31.578: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER/DATAPUMP
    01-JUL-24 07:44:31.585: W-1      Completed 1 DATAPUMP objects in 0 seconds
    01-JUL-24 07:44:31.588: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER/NETWORK_ACL
    01-JUL-24 07:44:31.793: W-1      Completed 3 NETWORK_ACL objects in 0 seconds
    01-JUL-24 07:44:31.797: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER/PSTDY
    01-JUL-24 07:44:31.809: W-1      Completed 2 PSTDY objects in 0 seconds
    01-JUL-24 07:44:31.813: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER/SCHEDULER
    01-JUL-24 07:44:31.816: W-1      Completed 2 SCHEDULER objects in 0 seconds
    01-JUL-24 07:44:31.819: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER/SMB
    01-JUL-24 07:44:34.063: W-1      Completed 6 SMB objects in 3 seconds
    01-JUL-24 07:44:34.069: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER/SQL_FIREWALL
    01-JUL-24 07:44:34.072: W-1      Completed 5 SQL_FIREWALL objects in 0 seconds
    01-JUL-24 07:44:34.076: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER/TSDP
    01-JUL-24 07:44:34.312: W-1      Completed 12 TSDP objects in 0 seconds
    01-JUL-24 07:44:34.316: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER/WMSYS
    01-JUL-24 07:44:36.070: W-1      Completed 53 WMSYS objects in 2 seconds
    01-JUL-24 07:44:36.082: W-2      Completed 1 [internal] Unknown objects in 6 seconds
    01-JUL-24 07:44:36.082: W-2      Completed by worker 1 1 MARKER objects in 6 seconds
    01-JUL-24 07:44:36.086: W-2 Processing object type DATABASE_EXPORT/AUDIT_UNIFIED/AUDIT_POLICY_ENABLE
    01-JUL-24 07:44:36.144: W-4      Completed 2 AUDIT_POLICY_ENABLE objects in 0 seconds
    01-JUL-24 07:44:36.144: W-4      Completed by worker 3 2 AUDIT_POLICY_ENABLE objects in 0 seconds
    01-JUL-24 07:44:36.157: W-1 Processing object type DATABASE_EXPORT/POST_SYSTEM_IMPCALLOUT/MARKER/SCHEDULER
    01-JUL-24 07:44:36.174: W-1      Completed 1 SCHEDULER objects in 0 seconds
    01-JUL-24 07:44:36.177: W-1 Processing object type DATABASE_EXPORT/POST_SYSTEM_IMPCALLOUT/MARKER/WMSYS
    01-JUL-24 07:44:37.880: W-1      Completed 1 WMSYS objects in 1 seconds
    01-JUL-24 07:44:37.884: W-1 Processing object type DATABASE_EXPORT/POST_SYSTEM_IMPCALLOUT/MARKER/DATAPUMP
    01-JUL-24 07:44:37.908: W-1      Completed 1 DATAPUMP objects in 0 seconds
    01-JUL-24 07:44:37.922: W-2      Completed 1 [internal] Unknown objects in 1 seconds
    01-JUL-24 07:44:37.922: W-2      Completed by worker 1 1 MARKER objects in 1 seconds
    01-JUL-24 07:44:37.984: W-3      Completed 1 DATABASE_EXPORT/EARLY_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA objects in 0 seconds
    01-JUL-24 07:44:37.988: W-3      Completed 43 DATABASE_EXPORT/NORMAL_OPTIONS/TABLE_DATA objects in 0 seconds
    01-JUL-24 07:44:37.992: W-3      Completed 17 DATABASE_EXPORT/NORMAL_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA objects in 816 seconds
    01-JUL-24 07:44:38.049: Job "SYSTEM"."SYS_IMPORT_TRANSPORTABLE_01" completed with 33 error(s) at Mon Jul 1 07:44:38 2024 elapsed 0 00:00:21    
    ```
    </details>

7. Examine the Data Pump log file for any critical issues. A FTEX import usually produces a few errors or warnings, especially when going to a higher release and into a different architecture.

    * The roles `EM_EXPRESS_ALL`, `EM_EXPRESS_BASIC` and `DATAPATCH_ROLE` do not exist in Oracle Database 23ai causing the grants to fail.
    * The same applies to the `ORACLE_OCM` user.
    * An error related to traditional auditing that is desupported in Oracle Database 23ai.
    * This log file doesn't contain any critical issues.

You may now *proceed to the next lab*.

## Acknowledgements

* **Author** - Daniel Overby Hansen
* **Contributors** - Klaus Gronau, Rodrigo Jorge, Mike Dietrich
* **Last Updated By/Date** - Daniel Overby Hansen, July 2024
