# Upgrading, Downgrading and Converting

## Introduction

Data Pump can move data between different releases of Oracle Database and even between certain architectures; from non-CDB to PDB, from one character set to another, from big-endian platforms like AIX to little-endian platforms like Linux. Data Pump handles such transitions without user intervention although a character set migration would require proper analysis. In this lab, you will try some of these scenarios.

Estimated Time: 20 Minutes

### Objectives

In this lab, you will:

* Move data from a non-CDB and into a higher release PDB
* Revert such operation and go back to a lower-release non-CDB

### Prerequisites

This lab assumes:

- You have completed Lab 3: Getting Started

## Task 1: Upgrade and convert

Data Pump can move data into any higher release Oracle Database. Data Pump was introduced in Oracle Database 10g and you can export from that initial release and import directly into a PDB on Oracle Database 23ai. Using Data Pump for upgrades is normally only suited for smaller data sets, from very old releases of Oracle Database, or when you need to do some sort of data manipulation/reorganization as part of the upgrade.

1. Use the *yellow* terminal 🟨. Connect to the *FTEX* database. This database runs Oracle Database 19c.

    ```
    <copy>
    . ftex
    sqlplus / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

2. In this task, you perform a full database export. In lab 6, *Customizing Data Pump Jobs*, you looked at the object paths included in various export modes. A full export has the most object paths included. Look at the object paths that are part of a full export.

    ```
    <copy>
    set line 150
    set pagesize 100
    col object_path format a55
    col comments format a85
    select object_path, comments 
    from database_export_objects 
    order by 1;
    </copy>

    -- Be sure to hit RETURN
    ```

    * There are 561 different object paths that are part of a full export. Let me highlight some of them.
    * `AUDIT_TRAILS` and `AUDIT_UNIFIED` - Auditing polices and the audit trails
    * `DVPS` - Database Vault configuration
    * `PASSWORD_HISTORY` and `PASSWORD_VERIFY_FUNCTION` - password complexity checks and individual user password history
    * `SCHEDULER` - all scheduler jobs and auxiliary scheduler objects like programs and program arguments.
    * `SMB` - SQL Management Base which contains SQL plan baselines, SQL profiles and SQL patches.
    * `TABLESPACE` - Data Pump moves tablespace defintions. If you move from Windows to Linux be sure to use `REMAP_DATAFILE` to handle the difference in file paths.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    OBJECT_PATH                  COMMENTS
    ---------------------------- -------------------------------------------------------------------------------------
    ALTER_FUNCTION               Recompile functions
    ALTER_PACKAGE_SPEC           Recompile package specifications
    ALTER_PROCEDURE              Recompile procedures
    ANALYTIC_VIEW                Analytic Views
    AQ                           Advanced Queuing
    
    (output truncated)
    
    XS_SECURITY/XS_ROLESET       XS Security Rolesets
    XS_SECURITY/XS_ROLE_GRANT    XS Security Role Grants
    XS_SECURITY/XS_USER          XS Security Users
    XS_SECURITY_CLASS            XS Security Classes
    XS_USER                      XS Security Users
    
    561 rows selected.
    ```
    </details> 

3. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```

4. Examine a pre-created parameter file.

    ```
    <copy>
    cat /home/oracle/scripts/dp-10-upgrade-export.par
    </copy>
    ```

    * You perform a full database export using `FULL=Y`.
    
    <details>
    <summary>*click to see the output*</summary>
    ``` text
    full=y
    reuse_dumpfiles=yes
    directory=dpdir
    logfile=dp-10-upgrade-export.log
    dumpfile=dp-10-upgrade-%L.dmp
    metrics=yes
    logtime=all
    parallel=4
    exclude=statistics
    ```
    </details> 

5. Start an export.

    ```
    <copy>
    . ftex
    expdp dpuser/oracle parfile=/home/oracle/scripts/dp-10-upgrade-export.par
    </copy>

    -- Be sure to hit RETURN
    ```

    * In the previous labs, you've done most schema exports/imports. 
    * Notice how many more objects paths that Data Pump processes in a full export.
    * Data Pump also exports tables from *SYS*, *SYSTEM* and other internal, Oracle-maintained schemas.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    Export: Release 19.0.0.0.0 - Production on Thu May 1 05:37:18 2025
    Version 19.27.0.0.0
    
    Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.
    
    Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    01-MAY-25 05:37:21.205: Starting "DPUSER"."SYS_EXPORT_FULL_01":  dpuser/******** parfile=/home/oracle/scripts/dp-10-upgrade-export.par
    01-MAY-25 05:37:21.560: W-1 Startup took 0 seconds
    01-MAY-25 05:37:22.723: W-2 Startup took 0 seconds
    01-MAY-25 05:37:22.725: W-3 Startup took 0 seconds
    01-MAY-25 05:37:22.774: W-4 Startup took 0 seconds
    01-MAY-25 05:37:23.687: W-3 Processing object type DATABASE_EXPORT/EARLY_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA
    01-MAY-25 05:37:23.719: W-1 Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA
    01-MAY-25 05:37:23.759: W-4 Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/TABLE_DATA
    01-MAY-25 05:37:23.761: W-1 Processing object type DATABASE_EXPORT/PRE_SYSTEM_IMPCALLOUT/MARKER
    01-MAY-25 05:37:23.762: W-3 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER
    01-MAY-25 05:37:23.764: W-1      Completed 1 MARKER objects in 0 seconds
    01-MAY-25 05:37:23.765: W-3      Completed 1 MARKER objects in 0 seconds
    01-MAY-25 05:37:23.795: W-4 Processing object type DATABASE_EXPORT/PROFILE
    01-MAY-25 05:37:23.798: W-3 Processing object type DATABASE_EXPORT/TABLESPACE
    01-MAY-25 05:37:23.827: W-4      Completed 1 PROFILE objects in 0 seconds
    01-MAY-25 05:37:23.831: W-3      Completed 3 TABLESPACE objects in 0 seconds
    01-MAY-25 05:37:23.850: W-1 Processing object type DATABASE_EXPORT/RADM_FPTM
    01-MAY-25 05:37:23.861: W-1      Completed 1 RADM_FPTM objects in 0 seconds
    01-MAY-25 05:37:23.869: W-4 Processing object type DATABASE_EXPORT/SCHEMA/USER
    01-MAY-25 05:37:23.872: W-4      Completed 3 USER objects in 0 seconds
    01-MAY-25 05:37:23.888: W-3 Processing object type DATABASE_EXPORT/SCHEMA/GRANT/SYSTEM_GRANT
    01-MAY-25 05:37:23.889: W-4 Processing object type DATABASE_EXPORT/SCHEMA/ROLE_GRANT
    01-MAY-25 05:37:23.899: W-4      Completed 43 ROLE_GRANT objects in 0 seconds
    01-MAY-25 05:37:23.903: W-3      Completed 73 SYSTEM_GRANT objects in 0 seconds
    01-MAY-25 05:37:23.915: W-4 Processing object type DATABASE_EXPORT/SCHEMA/DEFAULT_ROLE
    01-MAY-25 05:37:23.917: W-3 Processing object type DATABASE_EXPORT/SCHEMA/ON_USER_GRANT
    01-MAY-25 05:37:23.919: W-4      Completed 3 DEFAULT_ROLE objects in 0 seconds
    01-MAY-25 05:37:23.923: W-3      Completed 3 ON_USER_GRANT objects in 0 seconds
    01-MAY-25 05:37:23.937: W-3 Processing object type DATABASE_EXPORT/SCHEMA/TABLESPACE_QUOTA
    01-MAY-25 05:37:23.940: W-3      Completed 2 TABLESPACE_QUOTA objects in 0 seconds
    01-MAY-25 05:37:23.945: W-4 Processing object type DATABASE_EXPORT/RESOURCE_COST
    01-MAY-25 05:37:23.949: W-4      Completed 1 RESOURCE_COST objects in 0 seconds
    01-MAY-25 05:37:23.976: W-4 Processing object type DATABASE_EXPORT/TRUSTED_DB_LINK
    01-MAY-25 05:37:23.979: W-4      Completed 1 TRUSTED_DB_LINK objects in 0 seconds
    01-MAY-25 05:37:23.983: W-1 Processing object type DATABASE_EXPORT/GRANT/SYSTEM_GRANT/PROC_SYSTEM_GRANT
    01-MAY-25 05:37:23.988: W-1      Completed 6 PROC_SYSTEM_GRANT objects in 0 seconds
    01-MAY-25 05:37:24.015: W-3 Processing object type DATABASE_EXPORT/DIRECTORY/DIRECTORY
    01-MAY-25 05:37:24.020: W-3      Completed 1 DIRECTORY objects in 1 seconds
    01-MAY-25 05:37:24.153: W-2 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/TABLE_DATA
    01-MAY-25 05:37:24.364: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/PRE_SYSTEM_ACTIONS/PROCACT_SYSTEM
    01-MAY-25 05:37:24.422: W-1      Completed 2 PROCACT_SYSTEM objects in 0 seconds
    01-MAY-25 05:37:24.467: W-3 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/PROCOBJ
    01-MAY-25 05:37:24.473: W-3      Completed 23 PROCOBJ objects in 0 seconds
    01-MAY-25 05:37:24.622: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/POST_SYSTEM_ACTIONS/PROCACT_SYSTEM
    01-MAY-25 05:37:24.654: W-1      Completed 3 PROCACT_SYSTEM objects in 0 seconds
    01-MAY-25 05:37:24.771: W-3 Processing object type DATABASE_EXPORT/SCHEMA/PROCACT_SCHEMA
    01-MAY-25 05:37:24.775: W-3      Completed 6 PROCACT_SCHEMA objects in 0 seconds
    01-MAY-25 05:37:24.781: W-3 Processing object type DATABASE_EXPORT/EARLY_POST_INSTANCE_IMPCALLOUT/MARKER
    01-MAY-25 05:37:24.783: W-3      Completed 1 MARKER objects in 0 seconds
    01-MAY-25 05:37:25.962: W-4 Processing object type DATABASE_EXPORT/NORMAL_POST_INSTANCE_IMPCALLOUT/MARKER
    01-MAY-25 05:37:25.965: W-4      Completed 1 MARKER objects in 0 seconds
    01-MAY-25 05:37:27.201: W-4 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/TABLE
    01-MAY-25 05:37:27.222: W-1 Processing object type DATABASE_EXPORT/EARLY_OPTIONS/VIEWS_AS_TABLES/TABLE
    01-MAY-25 05:37:27.226: W-1      Completed 1 TABLE objects in 3 seconds
    01-MAY-25 05:37:27.230: W-2 Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/VIEWS_AS_TABLES/TABLE
    01-MAY-25 05:37:27.873: W-1 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/COMMENT
    01-MAY-25 05:37:27.877: W-1      Completed 1 COMMENT objects in 0 seconds
    01-MAY-25 05:37:29.198: W-1 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/INDEX/INDEX
    01-MAY-25 05:37:29.221: W-1      Completed 7 INDEX objects in 1 seconds
    01-MAY-25 05:37:31.101: W-1 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/CONSTRAINT/CONSTRAINT
    01-MAY-25 05:37:31.437: W-1      Completed 114 CONSTRAINT objects in 2 seconds
    01-MAY-25 05:37:38.532: W-3 Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/TABLE
    01-MAY-25 05:37:38.562: W-4      Completed 19 TABLE objects in 12 seconds
    01-MAY-25 05:37:38.970: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER
    01-MAY-25 05:37:38.972: W-1      Completed 1 MARKER objects in 0 seconds
    01-MAY-25 05:37:39.676: W-2      Completed 17 TABLE objects in 14 seconds
    01-MAY-25 05:37:39.699: W-2 Processing object type DATABASE_EXPORT/AUDIT_UNIFIED/AUDIT_POLICY_ENABLE
    01-MAY-25 05:37:39.733: W-2      Completed 2 AUDIT_POLICY_ENABLE objects in 0 seconds
    01-MAY-25 05:37:39.801: W-2 Processing object type DATABASE_EXPORT/POST_SYSTEM_IMPCALLOUT/MARKER
    01-MAY-25 05:37:39.803: W-2      Completed 1 MARKER objects in 0 seconds
    01-MAY-25 05:37:39.905: W-4 . . exported "SYS"."FGA_LOG$FOR_EXPORT"                      0 KB       0 rows in 0 seconds using automatic
    01-MAY-25 05:37:39.909: W-4 . . exported "SYS"."SQL$TEXT_DATAPUMP"                       0 KB       0 rows in 0 seconds using automatic
    01-MAY-25 05:37:39.912: W-4 . . exported "SYS"."SQLOBJ$DATA_DATAPUMP"                    0 KB       0 rows in 0 seconds using automatic
    01-MAY-25 05:37:39.915: W-4 . . exported "SYS"."SQL$_DATAPUMP"                           0 KB       0 rows in 0 seconds using automatic
    01-MAY-25 05:37:39.918: W-4 . . exported "SYS"."SQLOBJ$AUXDATA_DATAPUMP"                 0 KB       0 rows in 0 seconds using automatic
    01-MAY-25 05:37:39.922: W-4 . . exported "SYS"."SQLOBJ$PLAN_DATAPUMP"                    0 KB       0 rows in 0 seconds using automatic
    01-MAY-25 05:37:39.924: W-4 . . exported "SYS"."SQLOBJ$_DATAPUMP"                        0 KB       0 rows in 0 seconds using automatic
    01-MAY-25 05:37:39.956: W-4 . . exported "SYSTEM"."SCHEDULER_JOB_ARGS"                   0 KB       0 rows in 0 seconds using automatic
    01-MAY-25 05:37:39.975: W-4 . . exported "SYSTEM"."SCHEDULER_PROGRAM_ARGS"               0 KB       0 rows in 0 seconds using automatic
    01-MAY-25 05:37:40.152: W-2 . . exported "SYS"."KU$_USER_MAPPING_VIEW"               5.898 KB      26 rows in 1 seconds using external_table
    01-MAY-25 05:37:40.268: W-4 . . exported "WMSYS"."WM$EXP_MAP"                        7.718 KB       3 rows in 0 seconds using external_table
    01-MAY-25 05:37:40.277: W-4 . . exported "WMSYS"."WM$METADATA_MAP"                       0 KB       0 rows in 0 seconds using external_table
    01-MAY-25 05:37:40.303: W-2 . . exported "AUDSYS"."AUD$UNIFIED":"SYS_P661"           7.476 MB    5395 rows in 0 seconds using direct_path
    01-MAY-25 05:37:40.305: W-2 . . exported "WMSYS"."WM$CONSTRAINTS_TABLE$"                 0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 05:37:40.328: W-2 . . exported "SYS"."AUD$"                                23.46 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 05:37:40.337: W-2 . . exported "WMSYS"."WM$LOCKROWS_INFO$"                     0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 05:37:40.339: W-2 . . exported "WMSYS"."WM$UDTRIG_INFO$"                       0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 05:37:40.370: W-2 . . exported "SYSTEM"."REDO_DB"                          25.59 KB       1 rows in 0 seconds using direct_path
    01-MAY-25 05:37:40.388: W-2 . . exported "WMSYS"."WM$WORKSPACES_TABLE$"              12.10 KB       1 rows in 0 seconds using direct_path
    01-MAY-25 05:37:40.400: W-4 . . exported "SYS"."AUDTAB$TBS$FOR_EXPORT"               5.960 KB       2 rows in 0 seconds using external_table
    01-MAY-25 05:37:40.408: W-2 . . exported "WMSYS"."WM$HINT_TABLE$"                    9.984 KB      97 rows in 0 seconds using direct_path
    01-MAY-25 05:37:40.410: W-4 . . exported "SYS"."DBA_SENSITIVE_DATA"                      0 KB       0 rows in 0 seconds using external_table
    01-MAY-25 05:37:40.417: W-4 . . exported "SYS"."DBA_TSDP_POLICY_PROTECTION"              0 KB       0 rows in 0 seconds using external_table
    01-MAY-25 05:37:40.425: W-2 . . exported "WMSYS"."WM$WORKSPACE_PRIV_TABLE$"          7.078 KB      11 rows in 0 seconds using direct_path
    01-MAY-25 05:37:40.443: W-2 . . exported "SYS"."DAM_CONFIG_PARAM$"                   6.531 KB      14 rows in 0 seconds using direct_path
    01-MAY-25 05:37:40.457: W-4 . . exported "SYS"."NACL$_ACE_EXP"                           0 KB       0 rows in 0 seconds using external_table
    01-MAY-25 05:37:40.460: W-2 . . exported "SYS"."TSDP_SUBPOL$"                        6.328 KB       1 rows in 0 seconds using direct_path
    01-MAY-25 05:37:40.480: W-2 . . exported "WMSYS"."WM$NEXTVER_TABLE$"                 6.375 KB       1 rows in 0 seconds using direct_path
    01-MAY-25 05:37:40.498: W-2 . . exported "WMSYS"."WM$ENV_VARS$"                      6.015 KB       3 rows in 0 seconds using direct_path
    01-MAY-25 05:37:40.516: W-2 . . exported "SYS"."TSDP_PARAMETER$"                     5.953 KB       1 rows in 0 seconds using direct_path
    01-MAY-25 05:37:40.534: W-2 . . exported "SYS"."TSDP_POLICY$"                        5.921 KB       1 rows in 0 seconds using direct_path
    01-MAY-25 05:37:40.546: W-4 . . exported "SYS"."NACL$_HOST_EXP"                      6.914 KB       1 rows in 0 seconds using external_table
    01-MAY-25 05:37:40.549: W-4 . . exported "SYS"."NACL$_WALLET_EXP"                        0 KB       0 rows in 0 seconds using external_table
    01-MAY-25 05:37:40.554: W-2 . . exported "WMSYS"."WM$VERSION_HIERARCHY_TABLE$"       5.984 KB       1 rows in 0 seconds using direct_path
    01-MAY-25 05:37:40.571: W-2 . . exported "WMSYS"."WM$EVENTS_INFO$"                   5.812 KB      12 rows in 0 seconds using direct_path
    01-MAY-25 05:37:40.598: W-2 . . exported "AUDSYS"."AUD$UNIFIED":"AUD_UNIFIED_P0"     50.95 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 05:37:40.616: W-2 . . exported "SYS"."DAM_CLEANUP_EVENTS$"                 7.187 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 05:37:40.634: W-2 . . exported "SYS"."DAM_CLEANUP_JOBS$"                   7.171 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 05:37:40.636: W-2 . . exported "SYS"."TSDP_ASSOCIATION$"                       0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 05:37:40.638: W-2 . . exported "SYS"."TSDP_CONDITION$"                         0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 05:37:40.640: W-2 . . exported "SYS"."TSDP_FEATURE_POLICY$"                    0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 05:37:40.643: W-2 . . exported "SYS"."TSDP_PROTECTION$"                        0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 05:37:40.645: W-2 . . exported "SYS"."TSDP_SENSITIVE_DATA$"                    0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 05:37:40.647: W-2 . . exported "SYS"."TSDP_SENSITIVE_TYPE$"                    0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 05:37:40.649: W-2 . . exported "SYS"."TSDP_SOURCE$"                            0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 05:37:40.652: W-2 . . exported "SYSTEM"."REDO_LOG"                             0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 05:37:40.655: W-2 . . exported "WMSYS"."WM$BATCH_COMPRESSIBLE_TABLES$"         0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 05:37:40.657: W-2 . . exported "WMSYS"."WM$CONS_COLUMNS$"                      0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 05:37:40.661: W-2 . . exported "WMSYS"."WM$MODIFIED_TABLES$"                   0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 05:37:40.663: W-2 . . exported "WMSYS"."WM$MP_GRAPH_WORKSPACES_TABLE$"         0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 05:37:40.666: W-2 . . exported "WMSYS"."WM$MP_PARENT_WORKSPACES_TABLE$"        0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 05:37:40.668: W-2 . . exported "WMSYS"."WM$NESTED_COLUMNS_TABLE$"              0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 05:37:40.670: W-2 . . exported "WMSYS"."WM$RESOLVE_WORKSPACES_TABLE$"          0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 05:37:40.673: W-2 . . exported "WMSYS"."WM$RIC_LOCKING_TABLE$"                 0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 05:37:40.675: W-2 . . exported "WMSYS"."WM$RIC_TABLE$"                         0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 05:37:40.677: W-2 . . exported "WMSYS"."WM$RIC_TRIGGERS_TABLE$"                0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 05:37:40.679: W-2 . . exported "WMSYS"."WM$UDTRIG_DISPATCH_PROCS$"             0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 05:37:40.682: W-2 . . exported "WMSYS"."WM$VERSION_TABLE$"                     0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 05:37:40.685: W-2 . . exported "WMSYS"."WM$VT_ERRORS_TABLE$"                   0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 05:37:40.688: W-2 . . exported "WMSYS"."WM$WORKSPACE_SAVEPOINTS_TABLE$"        0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 05:37:40.705: W-1 Processing object type DATABASE_EXPORT/SCHEMA/POST_SCHEMA/PROCACT_SCHEMA
    01-MAY-25 05:37:40.708: W-1      Completed 3 PROCACT_SCHEMA objects in 1 seconds
    01-MAY-25 05:37:50.516: W-3      Completed 41 TABLE objects in 25 seconds
    01-MAY-25 05:38:23.451: W-2 . . exported "F1"."F1_LAPTIMES"                          16.98 MB  571047 rows in 2 seconds using direct_path
    01-MAY-25 05:38:23.995: W-2 . . exported "DPUSER"."SYS_EXPORT_SCHEMA_01"             404.9 KB    1628 rows in 0 seconds using direct_path
    01-MAY-25 05:38:24.822: W-2 . . exported "F1"."F1_RESULTS"                           1.429 MB   26439 rows in 0 seconds using direct_path
    01-MAY-25 05:38:25.236: W-2 . . exported "F1"."F1_DRIVERSTANDINGS"                   916.2 KB   34511 rows in 1 seconds using direct_path
    01-MAY-25 05:38:25.572: W-2 . . exported "F1"."F1_QUALIFYING"                        419.0 KB   10174 rows in 0 seconds using direct_path
    01-MAY-25 05:38:26.189: W-2 . . exported "F1"."F1_PITSTOPS"                          416.8 KB   10793 rows in 1 seconds using direct_path
    01-MAY-25 05:38:26.501: W-2 . . exported "F1"."F1_CONSTRUCTORSTANDINGS"              344.1 KB   13231 rows in 0 seconds using direct_path
    01-MAY-25 05:38:26.831: W-2 . . exported "F1"."F1_CONSTRUCTORRESULTS"                225.2 KB   12465 rows in 0 seconds using direct_path
    01-MAY-25 05:38:26.864: W-2 . . exported "F1"."F1_RACES"                             131.4 KB    1125 rows in 0 seconds using direct_path
    01-MAY-25 05:38:26.961: W-2 . . exported "F1"."F1_DRIVERS"                           87.86 KB     859 rows in 0 seconds using direct_path
    01-MAY-25 05:38:26.982: W-2 . . exported "F1"."F1_SPRINTRESULTS"                     29.88 KB     280 rows in 0 seconds using direct_path
    01-MAY-25 05:38:27.106: W-2 . . exported "F1"."F1_CONSTRUCTORS"                      22.97 KB     212 rows in 1 seconds using direct_path
    01-MAY-25 05:38:27.308: W-2 . . exported "F1"."F1_CIRCUITS"                          17.42 KB      77 rows in 0 seconds using direct_path
    01-MAY-25 05:38:27.338: W-2 . . exported "F1"."F1_SEASONS"                           10.03 KB      75 rows in 0 seconds using direct_path
    01-MAY-25 05:38:27.357: W-2 . . exported "F1"."F1_STATUS"                            7.843 KB     139 rows in 0 seconds using direct_path
    01-MAY-25 05:38:59.532: W-1      Completed 1 DATABASE_EXPORT/EARLY_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA objects in 1 seconds
    01-MAY-25 05:38:59.534: W-1      Completed 42 DATABASE_EXPORT/NORMAL_OPTIONS/TABLE_DATA objects in 0 seconds
    01-MAY-25 05:38:59.536: W-1      Completed 17 DATABASE_EXPORT/NORMAL_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA objects in 1 seconds
    01-MAY-25 05:38:59.537: W-1      Completed 19 DATABASE_EXPORT/SCHEMA/TABLE/TABLE_DATA objects in 78 seconds
    01-MAY-25 05:39:00.340: W-1 Master table "DPUSER"."SYS_EXPORT_FULL_01" successfully loaded/unloaded
    01-MAY-25 05:39:00.342: ******************************************************************************
    01-MAY-25 05:39:00.342: Dump file set for DPUSER.SYS_EXPORT_FULL_01 is:
    01-MAY-25 05:39:00.343:   /home/oracle/dpdir/dp-10-upgrade-01.dmp
    01-MAY-25 05:39:00.344:   /home/oracle/dpdir/dp-10-upgrade-02.dmp
    01-MAY-25 05:39:00.344:   /home/oracle/dpdir/dp-10-upgrade-03.dmp
    01-MAY-25 05:39:00.344:   /home/oracle/dpdir/dp-10-upgrade-04.dmp
    01-MAY-25 05:39:00.368: Job "DPUSER"."SYS_EXPORT_FULL_01" successfully completed at Thu May 1 05:39:00 2025 elapsed 0 00:01:40
    ```
    </details>     

6. Connect to *CDB23*. This container database is on Oracle Database 23ai. 

    ```
    <copy>
    . cdb23
    sqlplus / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

7. Create a new PDB called *RUBY* and open it.

    ```
    <copy>
    create pluggable database ruby admin user admin identified by oracle;
    alter pluggable database ruby open;
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> create pluggable database ruby admin user admin identified by oracle;
    
    Pluggable database created.
    
    SQL> alter pluggable database ruby open;
    
    Pluggable database altered.
    ```
    </details> 

8. Create the prerequisites for Data Pump.

    ```
    <copy>
    alter session set container=ruby;
    create directory dpdir as '/home/oracle/dpdir';
    grant datapump_exp_full_database, datapump_imp_full_database to dpuser identified by oracle;
    alter user dpuser default tablespace system;
    alter user dpuser quota unlimited on system;
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> alter session set container=ruby;

    Session altered.

    SQL> create directory dpdir as '/home/oracle/dpdir';

    Directory created.

    SQL> grant datapump_exp_full_database, datapump_imp_full_database to dpuser identified by oracle;
    
    User created.
    
    SQL> alter user dpuser default tablespace system;

    User altered.

    SQL> alter user dpuser quota unlimited on system;

    User altered.
    ```
    </details> 

9. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```

10. Examine a pre-created parameter file.

    ```
    <copy>
    cat /home/oracle/scripts/dp-10-upgrade-import.par
    </copy>
    ```

    * Because you are doing a full import, there is a chance that some of the objects already exist.
    * You've created the *DPDIR* directory and *DPUSER* already, but they also exist in the source database. To avoid conflicts you can exclude those using `EXCLUDE=DIRECTORY:"IN('DPDIR')"` and `EXCLUDE=USER:"IN('DPUSER')"`.
    * The tablespaces *TEMP* and *UNDOTBS1* exist as well, so you can safely exclude those using `EXCLUDE=TABLESPACE:"IN('TEMP','UNDOTBS1')"`.
    * Notice the extended syntax for `EXCLUDE`. You can exclude not only an entire object path, but also just selected objects within that path using an in-list. This works for `INCLUDE` as well.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    directory=dpdir
    logfile=dp-10-upgrade-import.log
    dumpfile=dp-10-upgrade-%L.dmp
    metrics=yes
    logtime=all
    parallel=4
    exclude=tablespace:"in('TEMP','UNDOTBS1')"
    exclude=user:"in('DPUSER')"
    exclude=directory:"in('DPDIR')"
    ```
    </details> 

11. Start the import.

    ```
    <copy>
    . cdb23
    impdp dpuser/oracle@localhost/ruby parfile=/home/oracle/scripts/dp-10-upgrade-import.par
    </copy>

    -- Be sure to hit RETURN
    ```

    * Data Pump spends a while in `DATABASE_EXPORT/TABLESPACE` when it is creating tablespaces. The initial size of the data files is set to the current size in the source database. The database has to write and format all those blocks. You could avoid that by manually creating the tablespaces with the desired initial size before the import. Then, exclude the tablespace from the import using `EXCLUDE=TABLESPACE:"IN('TBS1','TBS2', 'TBS3')"`. Imagine, the size of your tablespaces is 1 TB. The database would have to write 1 TB data files during the import. That's potentially a lot of time you can save.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    Import: Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems on Thu May 1 06:56:16 2025
    Version 23.8.0.25.04
    
    Copyright (c) 1982, 2025, Oracle and/or its affiliates.  All rights reserved.
    
    Connected to: Oracle Database 23ai Enterprise Edition Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems
    01-MAY-25 06:56:19.420: W-1 Startup on instance 1 took 1 seconds
    01-MAY-25 06:56:20.577: W-1 Master table "DPUSER"."SYS_IMPORT_FULL_01" successfully loaded/unloaded
    01-MAY-25 06:56:20.968: Starting "DPUSER"."SYS_IMPORT_FULL_01":  dpuser/********@localhost/ruby parfile=/home/oracle/scripts/dp-10-upgrade-import.par
    01-MAY-25 06:56:21.041: W-1 Processing object type DATABASE_EXPORT/PRE_SYSTEM_IMPCALLOUT/MARKER/SCHEDULER
    01-MAY-25 06:56:21.062: W-1      Completed 1 SCHEDULER objects in 0 seconds
    01-MAY-25 06:56:21.064: W-1 Processing object type DATABASE_EXPORT/PRE_SYSTEM_IMPCALLOUT/MARKER/WMSYS
    01-MAY-25 06:56:21.366: W-1      Completed 1 WMSYS objects in 0 seconds
    01-MAY-25 06:56:21.368: W-1 Processing object type DATABASE_EXPORT/PRE_SYSTEM_IMPCALLOUT/MARKER/DATAPUMP
    01-MAY-25 06:56:21.394: W-1      Completed 1 DATAPUMP objects in 0 seconds
    01-MAY-25 06:56:21.426: W-1      Completed 1 [internal] PRE_SYSTEM objects in 0 seconds
    01-MAY-25 06:56:21.426: W-1      Completed by worker 1 1 MARKER objects in 0 seconds
    01-MAY-25 06:56:21.440: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER/AUDIT_TRAILS
    01-MAY-25 06:56:21.529: W-1      Completed 10 AUDIT_TRAILS objects in 0 seconds
    01-MAY-25 06:56:21.531: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER/DATAPUMP
    01-MAY-25 06:56:21.534: W-1      Completed 1 DATAPUMP objects in 0 seconds
    01-MAY-25 06:56:21.535: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER/NETWORK_ACL
    01-MAY-25 06:56:21.554: W-1      Completed 3 NETWORK_ACL objects in 0 seconds
    01-MAY-25 06:56:21.556: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER/PSTDY
    01-MAY-25 06:56:21.564: W-1      Completed 2 PSTDY objects in 0 seconds
    01-MAY-25 06:56:21.566: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER/SCHEDULER
    01-MAY-25 06:56:21.584: W-1      Completed 2 SCHEDULER objects in 0 seconds
    01-MAY-25 06:56:21.585: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER/SMB
    01-MAY-25 06:56:21.618: W-1      Completed 6 SMB objects in 0 seconds
    01-MAY-25 06:56:21.620: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER/SQL_FIREWALL
    01-MAY-25 06:56:21.622: W-1      Completed 5 SQL_FIREWALL objects in 0 seconds
    01-MAY-25 06:56:21.625: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER/TSDP
    01-MAY-25 06:56:21.667: W-1      Completed 12 TSDP objects in 0 seconds
    01-MAY-25 06:56:21.669: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER/WMSYS
    01-MAY-25 06:56:21.735: W-1      Completed 53 WMSYS objects in 0 seconds
    01-MAY-25 06:56:21.742: W-1      Completed 1 [internal] PRE_INSTANCE objects in 0 seconds
    01-MAY-25 06:56:21.742: W-1      Completed by worker 1 1 MARKER objects in 0 seconds
    01-MAY-25 06:56:21.744: W-1 Processing object type DATABASE_EXPORT/TABLESPACE
    01-MAY-25 06:58:11.119: W-1      Completed 1 TABLESPACE objects in 110 seconds
    01-MAY-25 06:58:11.119: W-1      Completed by worker 1 1 TABLESPACE objects in 110 seconds
    01-MAY-25 06:58:11.121: W-1 Processing object type DATABASE_EXPORT/PROFILE
    01-MAY-25 06:58:11.158: W-1      Completed 1 PROFILE objects in 0 seconds
    01-MAY-25 06:58:11.158: W-1      Completed by worker 1 1 PROFILE objects in 0 seconds
    01-MAY-25 06:58:11.160: W-1 Processing object type DATABASE_EXPORT/SCHEMA/USER
    01-MAY-25 06:58:11.206: W-1      Completed 1 USER objects in 0 seconds
    01-MAY-25 06:58:11.206: W-1      Completed by worker 1 1 USER objects in 0 seconds
    01-MAY-25 06:58:11.207: W-1 Processing object type DATABASE_EXPORT/RADM_FPTM
    01-MAY-25 06:58:11.246: W-1      Completed 1 RADM_FPTM objects in 0 seconds
    01-MAY-25 06:58:11.246: W-1      Completed by worker 1 1 RADM_FPTM objects in 0 seconds
    01-MAY-25 06:58:11.260: W-1 Processing object type DATABASE_EXPORT/GRANT/SYSTEM_GRANT/PROC_SYSTEM_GRANT/RULE
    01-MAY-25 06:58:11.291: W-1      Completed 1 RULE objects in 0 seconds
    01-MAY-25 06:58:11.293: W-1 Processing object type DATABASE_EXPORT/GRANT/SYSTEM_GRANT/PROC_SYSTEM_GRANT/AQ
    01-MAY-25 06:58:11.305: W-1      Completed 1 AQ objects in 0 seconds
    01-MAY-25 06:58:11.307: W-1 Processing object type DATABASE_EXPORT/GRANT/SYSTEM_GRANT/PROC_SYSTEM_GRANT/RMGR
    01-MAY-25 06:58:11.323: ORA-39083: Object type RMGR:PROC_SYSTEM_GRANT failed to create with error:
    ORA-29393: user EM_EXPRESS_ALL does not exist or is not logged on
    
    01-MAY-25 06:58:11.327: W-1      Completed 1 RMGR objects in 0 seconds
    01-MAY-25 06:58:11.329: W-1 Processing object type DATABASE_EXPORT/GRANT/SYSTEM_GRANT/PROC_SYSTEM_GRANT/SQL
    01-MAY-25 06:58:11.343: W-1      Completed 1 SQL objects in 0 seconds
    01-MAY-25 06:58:11.345: W-1 Processing object type DATABASE_EXPORT/GRANT/SYSTEM_GRANT/PROC_SYSTEM_GRANT/RULE
    01-MAY-25 06:58:11.349: W-1      Completed 2 RULE objects in 0 seconds
    01-MAY-25 06:58:11.355: W-1 Processing object type DATABASE_EXPORT/SCHEMA/GRANT/SYSTEM_GRANT
    01-MAY-25 06:58:11.465: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'DATAPATCH_ROLE' does not exist
    
    Failing sql is:
    GRANT ALTER SESSION TO "DATAPATCH_ROLE"
    
    01-MAY-25 06:58:11.465: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_BASIC' does not exist
    
    Failing sql is:
    GRANT CREATE SESSION TO "EM_EXPRESS_BASIC"
    
    01-MAY-25 06:58:11.465: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-00990: missing or invalid privilege
    
    Failing sql is:
    GRANT EM EXPRESS CONNECT TO "EM_EXPRESS_BASIC"
    
    01-MAY-25 06:58:11.465: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT ADVISOR TO "EM_EXPRESS_ALL"
    
    01-MAY-25 06:58:11.465: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT CREATE JOB TO "EM_EXPRESS_ALL"
    
    01-MAY-25 06:58:11.465: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT ADMINISTER SQL TUNING SET TO "EM_EXPRESS_ALL"
    
    01-MAY-25 06:58:11.465: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT ADMINISTER ANY SQL TUNING SET TO "EM_EXPRESS_ALL"
    
    01-MAY-25 06:58:11.465: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT ADMINISTER SQL MANAGEMENT OBJECT TO "EM_EXPRESS_ALL"
    
    01-MAY-25 06:58:11.465: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT ALTER SYSTEM TO "EM_EXPRESS_ALL"
    
    01-MAY-25 06:58:11.465: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT CREATE TABLESPACE TO "EM_EXPRESS_ALL"
    
    01-MAY-25 06:58:11.465: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT DROP TABLESPACE TO "EM_EXPRESS_ALL"
    
    01-MAY-25 06:58:11.465: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT ALTER TABLESPACE TO "EM_EXPRESS_ALL"
    
    01-MAY-25 06:58:11.465: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT GRANT ANY OBJECT PRIVILEGE TO "EM_EXPRESS_ALL"
    
    01-MAY-25 06:58:11.465: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT GRANT ANY PRIVILEGE TO "EM_EXPRESS_ALL"
    
    01-MAY-25 06:58:11.465: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT GRANT ANY ROLE TO "EM_EXPRESS_ALL"
    
    01-MAY-25 06:58:11.465: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT CREATE ROLE TO "EM_EXPRESS_ALL"
    
    01-MAY-25 06:58:11.465: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT DROP ANY ROLE TO "EM_EXPRESS_ALL"
    
    01-MAY-25 06:58:11.465: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT ALTER ANY ROLE TO "EM_EXPRESS_ALL"
    
    01-MAY-25 06:58:11.465: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT CREATE USER TO "EM_EXPRESS_ALL"
    
    01-MAY-25 06:58:11.465: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT DROP USER TO "EM_EXPRESS_ALL"
    
    01-MAY-25 06:58:11.465: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT ALTER USER TO "EM_EXPRESS_ALL"
    
    01-MAY-25 06:58:11.465: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT CREATE PROFILE TO "EM_EXPRESS_ALL"
    
    01-MAY-25 06:58:11.465: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT ALTER PROFILE TO "EM_EXPRESS_ALL"
    
    01-MAY-25 06:58:11.465: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT DROP PROFILE TO "EM_EXPRESS_ALL"
    
    01-MAY-25 06:58:11.465: ORA-39083: Object type SYSTEM_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_ALL' does not exist
    
    Failing sql is:
    GRANT SET CONTAINER TO "EM_EXPRESS_ALL"
    
    01-MAY-25 06:58:11.473: W-1      Completed 72 SYSTEM_GRANT objects in 0 seconds
    01-MAY-25 06:58:11.473: W-1      Completed by worker 1 72 SYSTEM_GRANT objects in 0 seconds
    01-MAY-25 06:58:11.482: W-1 Processing object type DATABASE_EXPORT/SCHEMA/ROLE_GRANT
    01-MAY-25 06:58:11.580: ORA-39083: Object type ROLE_GRANT failed to create with error:
    ORA-01917: user or role 'EM_EXPRESS_BASIC' does not exist
    
    Failing sql is:
     GRANT "SELECT_CATALOG_ROLE" TO "EM_EXPRESS_BASIC"
    
    01-MAY-25 06:58:11.580: ORA-39083: Object type ROLE_GRANT failed to create with error:
    ORA-01919: Role 'EM_EXPRESS_ALL' does not exist.
    
    Failing sql is:
     GRANT "EM_EXPRESS_ALL" TO "DBA"
    
    01-MAY-25 06:58:11.580: ORA-39083: Object type ROLE_GRANT failed to create with error:
    ORA-01919: Role 'EM_EXPRESS_BASIC' does not exist.
    
    Failing sql is:
     GRANT "EM_EXPRESS_BASIC" TO "EM_EXPRESS_ALL"
    
    01-MAY-25 06:58:11.587: W-1      Completed 42 ROLE_GRANT objects in 0 seconds
    01-MAY-25 06:58:11.587: W-1      Completed by worker 1 42 ROLE_GRANT objects in 0 seconds
    01-MAY-25 06:58:11.589: W-1 Processing object type DATABASE_EXPORT/SCHEMA/DEFAULT_ROLE
    01-MAY-25 06:58:11.621: W-1      Completed 2 DEFAULT_ROLE objects in 0 seconds
    01-MAY-25 06:58:11.621: W-1      Completed by worker 1 2 DEFAULT_ROLE objects in 0 seconds
    01-MAY-25 06:58:11.622: W-1 Processing object type DATABASE_EXPORT/SCHEMA/ON_USER_GRANT
    01-MAY-25 06:58:11.651: W-1      Completed 2 ON_USER_GRANT objects in 0 seconds
    01-MAY-25 06:58:11.651: W-1      Completed by worker 1 2 ON_USER_GRANT objects in 0 seconds
    01-MAY-25 06:58:11.652: W-1 Processing object type DATABASE_EXPORT/SCHEMA/TABLESPACE_QUOTA
    01-MAY-25 06:58:11.686: W-1      Completed 2 TABLESPACE_QUOTA objects in 0 seconds
    01-MAY-25 06:58:11.686: W-1      Completed by worker 1 2 TABLESPACE_QUOTA objects in 0 seconds
    01-MAY-25 06:58:11.688: W-1 Processing object type DATABASE_EXPORT/RESOURCE_COST
    01-MAY-25 06:58:11.718: W-1      Completed 1 RESOURCE_COST objects in 0 seconds
    01-MAY-25 06:58:11.718: W-1      Completed by worker 1 1 RESOURCE_COST objects in 0 seconds
    01-MAY-25 06:58:11.720: W-1 Processing object type DATABASE_EXPORT/TRUSTED_DB_LINK
    01-MAY-25 06:58:11.750: W-1      Completed 1 TRUSTED_DB_LINK objects in 0 seconds
    01-MAY-25 06:58:11.750: W-1      Completed by worker 1 1 TRUSTED_DB_LINK objects in 0 seconds
    01-MAY-25 06:58:11.764: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/PRE_SYSTEM_ACTIONS/PROCACT_SYSTEM/LOGREP
    01-MAY-25 06:58:11.796: W-1      Completed 1 LOGREP objects in 0 seconds
    01-MAY-25 06:58:11.798: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/PRE_SYSTEM_ACTIONS/PROCACT_SYSTEM/RMGR
    01-MAY-25 06:58:11.824: W-1      Completed 1 RMGR objects in 0 seconds
    01-MAY-25 06:58:11.844: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/PROCOBJ/RMGR
    01-MAY-25 06:58:11.862: W-1      Completed 6 RMGR objects in 0 seconds
    01-MAY-25 06:58:11.864: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/PROCOBJ/SCHEDULER
    01-MAY-25 06:58:11.990: W-1      Completed 17 SCHEDULER objects in 0 seconds
    01-MAY-25 06:58:12.009: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/POST_SYSTEM_ACTIONS/PROCACT_SYSTEM/SRVR
    01-MAY-25 06:58:12.085: W-1      Completed 1 SRVR objects in 0 seconds
    01-MAY-25 06:58:12.088: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/POST_SYSTEM_ACTIONS/PROCACT_SYSTEM/RMGR
    01-MAY-25 06:58:12.167: W-1      Completed 1 RMGR objects in 0 seconds
    01-MAY-25 06:58:12.169: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/POST_SYSTEM_ACTIONS/PROCACT_SYSTEM/SEC
    01-MAY-25 06:58:12.207: W-1      Completed 1 SEC objects in 0 seconds
    01-MAY-25 06:58:12.227: W-1 Processing object type DATABASE_EXPORT/SCHEMA/PROCACT_SCHEMA/LOGREP
    01-MAY-25 06:58:12.241: W-1      Completed 5 LOGREP objects in 0 seconds
    01-MAY-25 06:58:12.248: W-1 Processing object type DATABASE_EXPORT/EARLY_OPTIONS/VIEWS_AS_TABLES/TABLE
    01-MAY-25 06:58:12.899: W-1      Completed 1 TABLE objects in 0 seconds
    01-MAY-25 06:58:12.899: W-1      Completed by worker 1 1 TABLE objects in 0 seconds
    01-MAY-25 06:58:12.921: W-1 Processing object type DATABASE_EXPORT/EARLY_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA
    01-MAY-25 06:58:13.612: W-1 . . imported "SYS"."KU$_EXPORT_USER_MAP"                   5.9 KB      25 rows in 1 seconds using direct_path
    01-MAY-25 06:58:13.628: W-1 Processing object type DATABASE_EXPORT/EARLY_POST_INSTANCE_IMPCALLOUT/MARKER/DATAPUMP
    01-MAY-25 06:58:13.633: W-1      Completed 1 DATAPUMP objects in 0 seconds
    01-MAY-25 06:58:13.640: W-1      Completed 1 [internal] EARLY_POST_INSTANCE objects in 0 seconds
    01-MAY-25 06:58:13.640: W-1      Completed by worker 1 1 MARKER objects in 0 seconds
    01-MAY-25 06:58:13.641: W-1 Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/TABLE
    01-MAY-25 06:58:14.302: W-2 Startup on instance 1 took 1 seconds
    01-MAY-25 06:58:14.304: W-3 Startup on instance 1 took 1 seconds
    01-MAY-25 06:58:14.305: W-4 Startup on instance 1 took 1 seconds
    01-MAY-25 06:58:14.891: W-3      Completed 41 TABLE objects in 1 seconds
    01-MAY-25 06:58:14.891: W-3      Completed by worker 1 20 TABLE objects in 1 seconds
    01-MAY-25 06:58:14.891: W-3      Completed by worker 2 11 TABLE objects in 0 seconds
    01-MAY-25 06:58:14.891: W-3      Completed by worker 4 10 TABLE objects in 0 seconds
    01-MAY-25 06:58:14.899: W-1 Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/TABLE_DATA
    01-MAY-25 06:58:14.994: W-3 . . imported "WMSYS"."E$HINT_TABLE$"                        10 KB      97 rows in 0 seconds using direct_path
    01-MAY-25 06:58:15.028: W-3 . . imported "WMSYS"."E$WORKSPACE_PRIV_TABLE$"             7.1 KB      11 rows in 1 seconds using direct_path
    01-MAY-25 06:58:15.058: W-3 . . imported "SYS"."AMGT$DP$DAM_CONFIG_PARAM$"             6.5 KB      14 rows in 0 seconds using direct_path
    01-MAY-25 06:58:15.087: W-3 . . imported "SYS"."DP$TSDP_SUBPOL$"                       6.3 KB       1 rows in 0 seconds using direct_path
    01-MAY-25 06:58:15.119: W-3 . . imported "WMSYS"."E$NEXTVER_TABLE$"                    6.4 KB       1 rows in 0 seconds using direct_path
    01-MAY-25 06:58:15.147: W-3 . . imported "WMSYS"."E$ENV_VARS$"                           6 KB       3 rows in 0 seconds using direct_path
    01-MAY-25 06:58:15.169: W-4 . . imported "AUDSYS"."AMGT$DP$AUD$UNIFIED":"SYS_P661"     7.5 MB    5395 rows in 1 seconds using direct_path
    01-MAY-25 06:58:15.177: W-3 . . imported "SYS"."DP$TSDP_PARAMETER$"                      6 KB       1 rows in 0 seconds using direct_path
    01-MAY-25 06:58:15.210: W-3 . . imported "SYS"."DP$TSDP_POLICY$"                       5.9 KB       1 rows in 0 seconds using direct_path
    01-MAY-25 06:58:15.217: W-4 . . imported "AUDSYS"."AMGT$DP$AUD$UNIFIED":"SYS_P766"    54.9 KB       9 rows in 0 seconds using direct_path
    01-MAY-25 06:58:15.220: W-4 . . imported "WMSYS"."E$CONSTRAINTS_TABLE$"                  0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 06:58:15.222: W-4 . . imported "SYS"."AMGT$DP$AUD$"                         23.5 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 06:58:15.224: W-4 . . imported "WMSYS"."E$LOCKROWS_INFO$"                      0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 06:58:15.226: W-4 . . imported "WMSYS"."E$UDTRIG_INFO$"                        0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 06:58:15.238: W-3 . . imported "WMSYS"."E$VERSION_HIERARCHY_TABLE$"            6 KB       1 rows in 0 seconds using direct_path
    01-MAY-25 06:58:15.254: W-4 . . imported "SYSTEM"."REDO_DB_TMP"                       25.6 KB       1 rows in 0 seconds using direct_path
    01-MAY-25 06:58:15.268: W-3 . . imported "WMSYS"."E$EVENTS_INFO$"                      5.8 KB      12 rows in 0 seconds using direct_path
    01-MAY-25 06:58:15.270: W-3 . . imported "AUDSYS"."AMGT$DP$AUD$UNIFIED":"AUD_UNIFIED_P0"     51 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 06:58:15.273: W-3 . . imported "SYS"."AMGT$DP$DAM_CLEANUP_EVENTS$"           7.2 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 06:58:15.275: W-3 . . imported "SYS"."AMGT$DP$DAM_CLEANUP_JOBS$"             7.2 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 06:58:15.277: W-3 . . imported "SYS"."DP$TSDP_ASSOCIATION$"                    0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 06:58:15.280: W-3 . . imported "SYS"."DP$TSDP_CONDITION$"                      0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 06:58:15.282: W-3 . . imported "SYS"."DP$TSDP_FEATURE_POLICY$"                 0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 06:58:15.285: W-3 . . imported "SYS"."DP$TSDP_PROTECTION$"                     0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 06:58:15.287: W-3 . . imported "SYS"."DP$TSDP_SENSITIVE_DATA$"                 0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 06:58:15.289: W-3 . . imported "SYS"."DP$TSDP_SENSITIVE_TYPE$"                 0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 06:58:15.292: W-3 . . imported "SYS"."DP$TSDP_SOURCE$"                         0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 06:58:15.294: W-3 . . imported "SYSTEM"."REDO_LOG_TMP"                         0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 06:58:15.296: W-3 . . imported "WMSYS"."E$BATCH_COMPRESSIBLE_TABLES$"          0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 06:58:15.299: W-3 . . imported "WMSYS"."E$CONS_COLUMNS$"                       0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 06:58:15.301: W-3 . . imported "WMSYS"."E$MODIFIED_TABLES$"                    0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 06:58:15.303: W-3 . . imported "WMSYS"."E$MP_GRAPH_WORKSPACES_TABLE$"          0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 06:58:15.306: W-3 . . imported "WMSYS"."E$MP_PARENT_WORKSPACES_TABLE$"         0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 06:58:15.308: W-3 . . imported "WMSYS"."E$NESTED_COLUMNS_TABLE$"               0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 06:58:15.310: W-3 . . imported "WMSYS"."E$RESOLVE_WORKSPACES_TABLE$"           0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 06:58:15.312: W-3 . . imported "WMSYS"."E$RIC_LOCKING_TABLE$"                  0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 06:58:15.314: W-3 . . imported "WMSYS"."E$RIC_TABLE$"                          0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 06:58:15.316: W-3 . . imported "WMSYS"."E$RIC_TRIGGERS_TABLE$"                 0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 06:58:15.317: W-3 . . imported "WMSYS"."E$UDTRIG_DISPATCH_PROCS$"              0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 06:58:15.319: W-3 . . imported "WMSYS"."E$VERSION_TABLE$"                      0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 06:58:15.320: W-3 . . imported "WMSYS"."E$VT_ERRORS_TABLE$"                    0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 06:58:15.322: W-3 . . imported "WMSYS"."E$WORKSPACE_SAVEPOINTS_TABLE$"         0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 06:58:15.325: W-2 . . imported "WMSYS"."E$WORKSPACES_TABLE$"                12.1 KB       1 rows in 1 seconds using external_table
    01-MAY-25 06:58:15.332: W-1 Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/VIEWS_AS_TABLES/TABLE
    01-MAY-25 06:58:15.613: W-4      Completed 15 TABLE objects in 0 seconds
    01-MAY-25 06:58:15.613: W-4      Completed by worker 1 3 TABLE objects in 0 seconds
    01-MAY-25 06:58:15.613: W-4      Completed by worker 2 4 TABLE objects in 0 seconds
    01-MAY-25 06:58:15.613: W-4      Completed by worker 3 4 TABLE objects in 0 seconds
    01-MAY-25 06:58:15.613: W-4      Completed by worker 4 4 TABLE objects in 0 seconds
    01-MAY-25 06:58:15.619: W-1 Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA
    01-MAY-25 06:58:15.628: W-3 . . imported "SYS"."AMGT$DP$FGA_LOG$FOR_EXPORT"              0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 06:58:15.631: W-3 . . imported "SYS"."DATAPUMP$SQL$TEXT"                       0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 06:58:15.633: W-3 . . imported "SYS"."DATAPUMP$SQLOBJ$DATA"                    0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 06:58:15.635: W-3 . . imported "SYS"."DATAPUMP$SQL$"                           0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 06:58:15.637: W-3 . . imported "SYS"."DATAPUMP$SQLOBJ$AUXDATA"                 0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 06:58:15.639: W-3 . . imported "SYS"."DATAPUMP$SQLOBJ$PLAN"                    0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 06:58:15.641: W-3 . . imported "SYS"."DATAPUMP$SQLOBJ$"                        0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 06:58:15.688: W-3 . . imported "WMSYS"."E$EXP_MAP"                           7.7 KB       3 rows in 0 seconds using direct_path
    01-MAY-25 06:58:15.690: W-3 . . imported "WMSYS"."E$METADATA_MAP"                        0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 06:58:15.717: W-3 . . imported "SYS"."AMGT$DP$AUDTAB$TBS$FOR_EXPORT"           6 KB       2 rows in 0 seconds using direct_path
    01-MAY-25 06:58:15.719: W-3 . . imported "SYS"."DP$DBA_SENSITIVE_DATA"                   0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 06:58:15.721: W-3 . . imported "SYS"."DP$DBA_TSDP_POLICY_PROTECTION"           0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 06:58:15.723: W-3 . . imported "SYS"."NACL$_ACE_IMP"                           0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 06:58:15.749: W-3 . . imported "SYS"."NACL$_HOST_IMP"                        6.9 KB       1 rows in 0 seconds using direct_path
    01-MAY-25 06:58:15.751: W-3 . . imported "SYS"."NACL$_WALLET_IMP"                        0 KB       0 rows in 0 seconds using direct_path
    01-MAY-25 06:58:15.767: W-1 Processing object type DATABASE_EXPORT/NORMAL_POST_INSTANCE_IMPCALLOUT/MARKER/AUDIT_TRAILS
    01-MAY-25 06:58:15.910: W-1      Completed 10 AUDIT_TRAILS objects in 0 seconds
    01-MAY-25 06:58:15.912: W-1 Processing object type DATABASE_EXPORT/NORMAL_POST_INSTANCE_IMPCALLOUT/MARKER/NETWORK_ACL
    01-MAY-25 06:58:15.921: W-1      Completed 3 NETWORK_ACL objects in 0 seconds
    01-MAY-25 06:58:15.923: W-1 Processing object type DATABASE_EXPORT/NORMAL_POST_INSTANCE_IMPCALLOUT/MARKER/PSTDY
    01-MAY-25 06:58:15.971: W-1      Completed 2 PSTDY objects in 0 seconds
    01-MAY-25 06:58:15.973: W-1 Processing object type DATABASE_EXPORT/NORMAL_POST_INSTANCE_IMPCALLOUT/MARKER/SCHEDULER
    01-MAY-25 06:58:15.974: W-1      Completed 2 SCHEDULER objects in 0 seconds
    01-MAY-25 06:58:15.976: W-1 Processing object type DATABASE_EXPORT/NORMAL_POST_INSTANCE_IMPCALLOUT/MARKER/SMB
    01-MAY-25 06:58:15.996: W-1      Completed 6 SMB objects in 0 seconds
    01-MAY-25 06:58:15.997: W-1 Processing object type DATABASE_EXPORT/NORMAL_POST_INSTANCE_IMPCALLOUT/MARKER/SQL_FIREWALL
    01-MAY-25 06:58:15.999: W-1      Completed 5 SQL_FIREWALL objects in 0 seconds
    01-MAY-25 06:58:16.001: W-1 Processing object type DATABASE_EXPORT/NORMAL_POST_INSTANCE_IMPCALLOUT/MARKER/TSDP
    01-MAY-25 06:58:16.063: W-1      Completed 12 TSDP objects in 1 seconds
    01-MAY-25 06:58:16.065: W-1 Processing object type DATABASE_EXPORT/NORMAL_POST_INSTANCE_IMPCALLOUT/MARKER/WMSYS
    01-MAY-25 06:58:16.176: W-1      Completed 53 WMSYS objects in 0 seconds
    01-MAY-25 06:58:16.220: W-4      Completed 1 [internal] Unknown objects in 1 seconds
    01-MAY-25 06:58:16.220: W-4      Completed by worker 1 1 MARKER objects in 1 seconds
    01-MAY-25 06:58:16.222: W-4 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/TABLE
    01-MAY-25 06:58:16.981: W-3      Completed 15 TABLE objects in 0 seconds
    01-MAY-25 06:58:16.981: W-3      Completed by worker 1 3 TABLE objects in 0 seconds
    01-MAY-25 06:58:16.981: W-3      Completed by worker 2 3 TABLE objects in 0 seconds
    01-MAY-25 06:58:16.981: W-3      Completed by worker 3 3 TABLE objects in 0 seconds
    01-MAY-25 06:58:16.981: W-3      Completed by worker 4 6 TABLE objects in 0 seconds
    01-MAY-25 06:58:16.987: W-2 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/TABLE_DATA
    01-MAY-25 06:58:17.164: W-1 . . imported "F1"."F1_LAPTIMES"                             17 MB  571047 rows in 0 seconds using direct_path
    01-MAY-25 06:58:17.167: W-4 . . imported "DPUSER"."SYS_EXPORT_SCHEMA_01"             404.9 KB    1628 rows in 0 seconds using direct_path
    01-MAY-25 06:58:17.202: W-4 . . imported "F1"."F1_RESULTS"                             1.4 MB   26439 rows in 0 seconds using direct_path
    01-MAY-25 06:58:17.237: W-4 . . imported "F1"."F1_DRIVERSTANDINGS"                   916.3 KB   34511 rows in 0 seconds using direct_path
    01-MAY-25 06:58:17.268: W-4 . . imported "F1"."F1_QUALIFYING"                          419 KB   10174 rows in 0 seconds using direct_path
    01-MAY-25 06:58:17.299: W-4 . . imported "F1"."F1_PITSTOPS"                          416.8 KB   10793 rows in 0 seconds using direct_path
    01-MAY-25 06:58:17.332: W-4 . . imported "F1"."F1_CONSTRUCTORSTANDINGS"              344.1 KB   13231 rows in 0 seconds using direct_path
    01-MAY-25 06:58:17.363: W-4 . . imported "F1"."F1_CONSTRUCTORRESULTS"                225.3 KB   12465 rows in 0 seconds using direct_path
    01-MAY-25 06:58:17.393: W-4 . . imported "F1"."F1_RACES"                             131.4 KB    1125 rows in 0 seconds using direct_path
    01-MAY-25 06:58:17.421: W-4 . . imported "F1"."F1_DRIVERS"                            87.9 KB     859 rows in 0 seconds using direct_path
    01-MAY-25 06:58:17.449: W-4 . . imported "F1"."F1_SPRINTRESULTS"                      29.9 KB     280 rows in 0 seconds using direct_path
    01-MAY-25 06:58:17.475: W-4 . . imported "F1"."F1_CONSTRUCTORS"                         23 KB     212 rows in 0 seconds using direct_path
    01-MAY-25 06:58:17.503: W-4 . . imported "F1"."F1_CIRCUITS"                           17.4 KB      77 rows in 0 seconds using direct_path
    01-MAY-25 06:58:17.529: W-4 . . imported "F1"."F1_SEASONS"                              10 KB      75 rows in 0 seconds using direct_path
    01-MAY-25 06:58:17.556: W-4 . . imported "F1"."F1_STATUS"                              7.8 KB     139 rows in 0 seconds using direct_path
    01-MAY-25 06:58:17.563: W-3 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/COMMENT
    01-MAY-25 06:58:17.596: W-1      Completed 1 COMMENT objects in 0 seconds
    01-MAY-25 06:58:17.596: W-1      Completed by worker 2 1 COMMENT objects in 0 seconds
    01-MAY-25 06:58:17.633: W-3 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/INDEX/INDEX
    01-MAY-25 06:58:17.860: W-3      Completed 7 INDEX objects in 0 seconds
    01-MAY-25 06:58:17.860: W-3      Completed by worker 1 2 INDEX objects in 0 seconds
    01-MAY-25 06:58:17.860: W-3      Completed by worker 2 2 INDEX objects in 0 seconds
    01-MAY-25 06:58:17.860: W-3      Completed by worker 3 1 INDEX objects in 0 seconds
    01-MAY-25 06:58:17.860: W-3      Completed by worker 4 2 INDEX objects in 0 seconds
    01-MAY-25 06:58:17.862: W-3 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/CONSTRAINT/CONSTRAINT
    01-MAY-25 06:58:18.597: W-1      Completed 22 CONSTRAINT objects in 1 seconds
    01-MAY-25 06:58:18.597: W-1      Completed by worker 2 22 CONSTRAINT objects in 1 seconds
    01-MAY-25 06:58:18.609: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER/AUDIT_TRAILS
    01-MAY-25 06:58:19.163: W-1      Completed 10 AUDIT_TRAILS objects in 1 seconds
    01-MAY-25 06:58:19.166: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER/DATAPUMP
    01-MAY-25 06:58:19.169: W-1      Completed 1 DATAPUMP objects in 0 seconds
    01-MAY-25 06:58:19.171: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER/NETWORK_ACL
    01-MAY-25 06:58:19.317: W-1      Completed 3 NETWORK_ACL objects in 0 seconds
    01-MAY-25 06:58:19.319: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER/PSTDY
    01-MAY-25 06:58:19.324: W-1      Completed 2 PSTDY objects in 0 seconds
    01-MAY-25 06:58:19.326: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER/SCHEDULER
    01-MAY-25 06:58:19.328: W-1      Completed 2 SCHEDULER objects in 0 seconds
    01-MAY-25 06:58:19.331: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER/SMB
    01-MAY-25 06:58:22.005: W-1      Completed 6 SMB objects in 3 seconds
    01-MAY-25 06:58:22.007: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER/SQL_FIREWALL
    01-MAY-25 06:58:22.009: W-1      Completed 5 SQL_FIREWALL objects in 0 seconds
    01-MAY-25 06:58:22.011: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER/TSDP
    01-MAY-25 06:58:22.183: W-1      Completed 12 TSDP objects in 0 seconds
    01-MAY-25 06:58:22.185: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER/WMSYS
    01-MAY-25 06:58:23.757: W-1      Completed 53 WMSYS objects in 1 seconds
    01-MAY-25 06:58:23.765: W-4      Completed 1 [internal] Unknown objects in 5 seconds
    01-MAY-25 06:58:23.765: W-4      Completed by worker 1 1 MARKER objects in 5 seconds
    01-MAY-25 06:58:23.781: W-1 Processing object type DATABASE_EXPORT/SCHEMA/POST_SCHEMA/PROCACT_SCHEMA/LOGREP
    01-MAY-25 06:58:23.799: W-1      Completed 3 LOGREP objects in 0 seconds
    01-MAY-25 06:58:23.807: W-3 Processing object type DATABASE_EXPORT/AUDIT_UNIFIED/AUDIT_POLICY_ENABLE
    01-MAY-25 06:58:23.848: W-4      Completed 2 AUDIT_POLICY_ENABLE objects in 0 seconds
    01-MAY-25 06:58:23.848: W-4      Completed by worker 2 2 AUDIT_POLICY_ENABLE objects in 0 seconds
    01-MAY-25 06:58:23.856: W-1 Processing object type DATABASE_EXPORT/POST_SYSTEM_IMPCALLOUT/MARKER/SCHEDULER
    01-MAY-25 06:58:23.861: W-1      Completed 1 SCHEDULER objects in 0 seconds
    01-MAY-25 06:58:23.864: W-1 Processing object type DATABASE_EXPORT/POST_SYSTEM_IMPCALLOUT/MARKER/WMSYS
    01-MAY-25 06:58:25.471: W-1      Completed 1 WMSYS objects in 2 seconds
    01-MAY-25 06:58:25.473: W-1 Processing object type DATABASE_EXPORT/POST_SYSTEM_IMPCALLOUT/MARKER/DATAPUMP
    01-MAY-25 06:58:25.489: W-1      Completed 1 DATAPUMP objects in 0 seconds
    01-MAY-25 06:58:25.496: W-3      Completed 1 [internal] Unknown objects in 2 seconds
    01-MAY-25 06:58:25.496: W-3      Completed by worker 1 1 MARKER objects in 2 seconds
    01-MAY-25 06:58:25.542: W-2      Completed 1 DATABASE_EXPORT/EARLY_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA objects in 1 seconds
    01-MAY-25 06:58:25.544: W-2      Completed 43 DATABASE_EXPORT/NORMAL_OPTIONS/TABLE_DATA objects in 1 seconds
    01-MAY-25 06:58:25.547: W-2      Completed 15 DATABASE_EXPORT/NORMAL_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA objects in 0 seconds
    01-MAY-25 06:58:25.549: W-2      Completed 15 DATABASE_EXPORT/SCHEMA/TABLE/TABLE_DATA objects in 0 seconds
    01-MAY-25 06:58:25.593: Job "DPUSER"."SYS_IMPORT_FULL_01" completed with 29 error(s) at Thu May 1 06:58:25 2025 elapsed 0 00:02:07    
    ```
    </details> 

12. The import completes with errors. It is common to find import errors when moving to a different version, because the data dictionary is different and Data Pump doesn't know of these differences. In this example, some roles are missing which causes grants to fail. This is expected since these roles are removed in Oracle Database 23ai. When doing full imports, you must use the knowledge you gained in lab 8, *Determining Import Success*.

13. In this task, the database was very small and you could perform the export/import quickly. Much faster than a regular upgrade and PDB conversion. But as the size of the data increases, you will need more and more time for the export/import. At one point, it will be faster to upgrade and convert the entire database.

14. As you saw in the parameter files, it takes no special configuration to import to a higher version or from a non-CDB into a PDB. Data Pump transparently handles it.

15. Connect to the *RUBY* PDB as the *F1* schema.

    ```
    <copy>
    sqlplus F1/oracle@localhost/ruby
    </copy>
    ```

16. Examine the schema.

    ```
    <copy>
    set pagesize 100
    col table_name format a30
    select table_name from user_tables order by 1;
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    TABLE_NAME
    ------------------------------
    F1_CIRCUITS
    F1_CONSTRUCTORRESULTS
    F1_CONSTRUCTORS
    F1_CONSTRUCTORSTANDINGS
    F1_DRIVERS
    F1_DRIVERSTANDINGS
    F1_LAPTIMES
    F1_PITSTOPS
    F1_QUALIFYING
    F1_RACES
    F1_RESULTS
    F1_SEASONS
    F1_SPRINTRESULTS
    F1_STATUS
    ```
    </details> 

16. Examine the data.

    ```
    <copy>
    col name format a50
    select    c.name, count(*) 
    from      f1_races r, f1_circuits c 
    where     r.circuitid=c.circuitid 
    group by c.name 
    order by 2 desc 
    fetch first 3 rows only;
    </copy>

    -- Be sure to hit RETURN
    ```

    * *Monza*, *Monaco* and *Silverstone* are the most used circuits.
    * Monza is an extremely fast circuit that despite certain speed-reducing modifications remains the fastest circuit in F1. The fastest motorcycle races avoid Monza because it is considered too unsafe for riders.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    NAME                                                 COUNT(*)
    -------------------------------------------------- ----------
    Autodromo Nazionale di Monza                               74
    Circuit de Monaco                                          70
    Silverstone Circuit                                        59
    ```
    </details>

17. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```

## Task 2: Downgrade and back to non-CDB

Data Pump can also move data to a lower release. In contrast to moving to a higher release, going to a lower release does require a little more consideration. What will happen if you are using features that don't't exist in the lower version? You'll soon find out.

1. Still in the *yellow* terminal 🟨. Connect to the *RUBY* database as *F1*.

    ```
    <copy>
    . cdb23
    sqlplus F1/oracle@localhost/ruby
    </copy>

    -- Be sure to hit RETURN
    ```

2. Use one of the marquee features in Oracle Database 23ai - the vector data type. 

    ```
    <copy>
    create table f1_vectors (id number, embedding vector);    
    insert into f1_vectors values (1, '[10, 20, 30]');
    commit;
    col embedding format a40
    select * from f1_vectors;
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> create table f1_vectors (id number, embedding vector);
    
    Table created.
    
    SQL> insert into f1_vectors values (1, '[10, 20, 30]');
    
    1 row created.
    
    SQL> commit;
    
    Commit complete.
    
    SQL> col embedding format a40
    
    SQL> select * from f1_vectors;
    
    ID         EMBEDDING
    ---------- ----------------------------------------
    1          [1.0E+001,2.0E+001,3.0E+001]
    ```
    </details> 

3. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```

4. Examine a pre-created parameter file that exports the *F1* schema.

    ```
    <copy>
    cat /home/oracle/scripts/dp-10-downgrade-export.par
    </copy>
    ```

    * `VERSION=19` instructs Data Pump to create a dump file in a format that can be understood by Oracle Database 19c. This is required when you are exporting to a lower release.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    schemas=F1
    reuse_dumpfiles=yes
    directory=dpdir
    logfile=dp-10-downgrade-export.log
    dumpfile=dp-10-downgrade-%L.dmp
    metrics=yes
    logtime=all
    exclude=statistics
    version=19
    ```
    </details> 

5. Perform the export.

    ```
    <copy>
    . cdb23
    expdp dpuser/oracle@localhost/ruby parfile=/home/oracle/scripts/dp-10-downgrade-export.par
    </copy>

    -- Be sure to hit RETURN
    ```

    * Data Pump also exports the *F1\_VECTORS* table although it uses a feature that's new in Oracle Database 23ai.
    * The `VERSION` parameter affects only the format of the dump file. Data Pump doesn't exclude any objects based on this parameter.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    Export: Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems on Thu May 1 08:02:10 2025
    Version 23.8.0.25.04
    
    Copyright (c) 1982, 2025, Oracle and/or its affiliates.  All rights reserved.
    
    Connected to: Oracle Database 23ai Enterprise Edition Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems
    01-MAY-25 08:02:14.851: Starting "DPUSER"."SYS_EXPORT_SCHEMA_02":  dpuser/********@localhost/ruby parfile=/home/oracle/scripts/dp-10-downgrade-export.par
    01-MAY-25 08:02:15.292: W-1 Startup on instance 1 took 1 seconds
    01-MAY-25 08:02:17.259: W-1 Processing object type SCHEMA_EXPORT/TABLE/TABLE_DATA
    01-MAY-25 08:02:17.433: W-1 Processing object type SCHEMA_EXPORT/USER
    01-MAY-25 08:02:17.459: W-1      Completed 1 USER objects in 0 seconds
    01-MAY-25 08:02:17.482: W-1 Processing object type SCHEMA_EXPORT/SYSTEM_GRANT
    01-MAY-25 08:02:17.486: W-1      Completed 2 SYSTEM_GRANT objects in 0 seconds
    01-MAY-25 08:02:17.551: W-1 Processing object type SCHEMA_EXPORT/DEFAULT_ROLE
    01-MAY-25 08:02:17.555: W-1      Completed 1 DEFAULT_ROLE objects in 0 seconds
    01-MAY-25 08:02:17.582: W-1 Processing object type SCHEMA_EXPORT/TABLESPACE_QUOTA
    01-MAY-25 08:02:17.586: W-1      Completed 1 TABLESPACE_QUOTA objects in 0 seconds
    01-MAY-25 08:02:17.786: W-1 Processing object type SCHEMA_EXPORT/PRE_SCHEMA/PROCACT_SCHEMA/LOGREP
    01-MAY-25 08:02:17.788: W-1      Completed 2 LOGREP objects in 0 seconds
    01-MAY-25 08:02:22.035: W-1 Processing object type SCHEMA_EXPORT/TABLE/TABLE
    01-MAY-25 08:02:30.966: W-1      Completed 15 TABLE objects in 10 seconds
    01-MAY-25 08:02:34.747: W-1 Processing object type SCHEMA_EXPORT/TABLE/CONSTRAINT/CONSTRAINT
    01-MAY-25 08:02:34.755: W-1      Completed 22 CONSTRAINT objects in 2 seconds
    01-MAY-25 08:02:36.413: W-1 . . exported "F1"."F1_VECTORS"                             5.6 KB       1 rows in 0 seconds using direct_path
    01-MAY-25 08:02:36.435: W-1 . . exported "F1"."F1_CIRCUITS"                           17.8 KB      77 rows in 0 seconds using direct_path
    01-MAY-25 08:02:36.460: W-1 . . exported "F1"."F1_CONSTRUCTORRESULTS"                225.5 KB   12465 rows in 0 seconds using direct_path
    01-MAY-25 08:02:36.484: W-1 . . exported "F1"."F1_CONSTRUCTORS"                       23.2 KB     212 rows in 0 seconds using direct_path
    01-MAY-25 08:02:36.510: W-1 . . exported "F1"."F1_CONSTRUCTORSTANDINGS"              344.4 KB   13231 rows in 0 seconds using direct_path
    01-MAY-25 08:02:36.534: W-1 . . exported "F1"."F1_DRIVERS"                            88.3 KB     859 rows in 0 seconds using direct_path
    01-MAY-25 08:02:36.564: W-1 . . exported "F1"."F1_DRIVERSTANDINGS"                   916.5 KB   34511 rows in 0 seconds using direct_path
    01-MAY-25 08:02:36.683: W-1 . . exported "F1"."F1_LAPTIMES"                             17 MB  571047 rows in 0 seconds using direct_path
    01-MAY-25 08:02:36.712: W-1 . . exported "F1"."F1_PITSTOPS"                          417.1 KB   10793 rows in 0 seconds using direct_path
    01-MAY-25 08:02:36.740: W-1 . . exported "F1"."F1_QUALIFYING"                        419.4 KB   10174 rows in 0 seconds using direct_path
    01-MAY-25 08:02:36.766: W-1 . . exported "F1"."F1_RACES"                             132.2 KB    1125 rows in 0 seconds using direct_path
    01-MAY-25 08:02:36.799: W-1 . . exported "F1"."F1_RESULTS"                             1.4 MB   26439 rows in 0 seconds using direct_path
    01-MAY-25 08:02:36.823: W-1 . . exported "F1"."F1_SEASONS"                            10.1 KB      75 rows in 0 seconds using direct_path
    01-MAY-25 08:02:36.848: W-1 . . exported "F1"."F1_SPRINTRESULTS"                      30.5 KB     280 rows in 0 seconds using direct_path
    01-MAY-25 08:02:36.871: W-1 . . exported "F1"."F1_STATUS"                              7.9 KB     139 rows in 0 seconds using direct_path
    01-MAY-25 08:02:37.862: W-1      Completed 15 SCHEMA_EXPORT/TABLE/TABLE_DATA objects in 0 seconds
    01-MAY-25 08:02:38.095: W-1 Master table "DPUSER"."SYS_EXPORT_SCHEMA_02" successfully loaded/unloaded
    01-MAY-25 08:02:38.102: ******************************************************************************
    01-MAY-25 08:02:38.103: Dump file set for DPUSER.SYS_EXPORT_SCHEMA_02 is:
    01-MAY-25 08:02:38.103:   /home/oracle/dpdir/dp-10-downgrade-01.dmp
    01-MAY-25 08:02:38.107: Job "DPUSER"."SYS_EXPORT_SCHEMA_02" successfully completed at Thu May 1 08:02:38 2025 elapsed 0 00:00:26    
    ```
    </details> 

6. Examine a pre-created parameter file that imports and remaps the schema.

    ```
    <copy>
    cat /home/oracle/scripts/dp-10-downgrade-import.par
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    directory=dpdir
    logfile=dp-10-downgrade-import.log
    dumpfile=dp-10-downgrade-%L.dmp
    metrics=yes
    logtime=all
    remap_schema=F1:F1FROM23AI
    ```
    </details> 

7. Start the import into the *FTEX* database on Oracle Database 19c.

    ```
    <copy>
    . ftex
    impdp dpuser/oracle parfile=/home/oracle/scripts/dp-10-downgrade-import.par
    </copy>

    -- Be sure to hit RETURN
    ```

    * Because you exported to a dump file that Oracle Database 19c can understand, there are no problems reading the dump file.
    * Data Pump imports the entire schema into the lower release, except for *F1\_VECTORS*. 
    * The vector data type doesn't exist in Oracle Database 19c and it is not possible to import the table. Data Pump reports `ORA-39117`. 
    * You would need to find other means of transporting that table. You could use `VIEWS_AS_TABLES` and create a view in the source database where you tranform the vector data into other data types that you could use in the target database.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    Import: Release 19.0.0.0.0 - Production on Thu May 1 08:04:59 2025
    Version 19.27.0.0.0

    Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.

    Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    01-MAY-25 08:05:01.738: W-1 Startup took 0 seconds
    01-MAY-25 08:05:02.441: W-1 Master table "DPUSER"."SYS_IMPORT_FULL_01" successfully loaded/unloaded
    01-MAY-25 08:05:02.566: Starting "DPUSER"."SYS_IMPORT_FULL_01":  dpuser/******** parfile=/home/oracle/scripts/dp-10-downgrade-import.par
    01-MAY-25 08:05:02.577: W-1 Processing object type SCHEMA_EXPORT/USER
    01-MAY-25 08:05:02.665: W-1      Completed 1 USER objects in 0 seconds
    01-MAY-25 08:05:02.665: W-1 Processing object type SCHEMA_EXPORT/SYSTEM_GRANT
    01-MAY-25 08:05:02.695: W-1      Completed 2 SYSTEM_GRANT objects in 0 seconds
    01-MAY-25 08:05:02.695: W-1 Processing object type SCHEMA_EXPORT/DEFAULT_ROLE
    01-MAY-25 08:05:02.720: W-1      Completed 1 DEFAULT_ROLE objects in 0 seconds
    01-MAY-25 08:05:02.720: W-1 Processing object type SCHEMA_EXPORT/TABLESPACE_QUOTA
    01-MAY-25 08:05:02.746: W-1      Completed 1 TABLESPACE_QUOTA objects in 0 seconds
    01-MAY-25 08:05:02.746: W-1 Processing object type SCHEMA_EXPORT/PRE_SCHEMA/PROCACT_SCHEMA
    01-MAY-25 08:05:02.836: W-1      Completed 1 PROCACT_SCHEMA objects in 0 seconds
    01-MAY-25 08:05:02.836: W-1 Processing object type SCHEMA_EXPORT/TABLE/TABLE
    01-MAY-25 08:05:03.843: ORA-39117: Type needed to create table is not included in this operation. Failing sql is:
    CREATE TABLE "F1FROM23AI"."F1_VECTORS" ("ID" NUMBER, "EMBEDDING" ***UNSUPPORTED DATA TYPE (127)***) SEGMENT CREATION IMMEDIATE PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255  NOCOMPRESS LOGGING STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645 PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT) TABLESPACE "USERS"

    01-MAY-25 08:05:03.854: W-1      Completed 15 TABLE objects in 1 seconds
    01-MAY-25 08:05:03.860: W-1 Processing object type SCHEMA_EXPORT/TABLE/TABLE_DATA
    01-MAY-25 08:05:03.919: W-1 . . imported "F1FROM23AI"."F1_CIRCUITS"                  17.81 KB      77 rows in 0 seconds using direct_path
    01-MAY-25 08:05:03.943: W-1 . . imported "F1FROM23AI"."F1_CONSTRUCTORRESULTS"        225.5 KB   12465 rows in 0 seconds using direct_path
    01-MAY-25 08:05:03.959: W-1 . . imported "F1FROM23AI"."F1_CONSTRUCTORS"              23.18 KB     212 rows in 0 seconds using direct_path
    01-MAY-25 08:05:03.980: W-1 . . imported "F1FROM23AI"."F1_CONSTRUCTORSTANDINGS"      344.4 KB   13231 rows in 0 seconds using direct_path
    01-MAY-25 08:05:03.998: W-1 . . imported "F1FROM23AI"."F1_DRIVERS"                   88.25 KB     859 rows in 0 seconds using direct_path
    01-MAY-25 08:05:04.024: W-1 . . imported "F1FROM23AI"."F1_DRIVERSTANDINGS"           916.5 KB   34511 rows in 1 seconds using direct_path
    01-MAY-25 08:05:04.173: W-1 . . imported "F1FROM23AI"."F1_LAPTIMES"                  16.98 MB  571047 rows in 0 seconds using direct_path
    01-MAY-25 08:05:04.200: W-1 . . imported "F1FROM23AI"."F1_PITSTOPS"                  417.1 KB   10793 rows in 0 seconds using direct_path
    01-MAY-25 08:05:04.222: W-1 . . imported "F1FROM23AI"."F1_QUALIFYING"                419.4 KB   10174 rows in 0 seconds using direct_path
    01-MAY-25 08:05:04.242: W-1 . . imported "F1FROM23AI"."F1_RACES"                     132.1 KB    1125 rows in 0 seconds using direct_path
    01-MAY-25 08:05:04.272: W-1 . . imported "F1FROM23AI"."F1_RESULTS"                   1.430 MB   26439 rows in 0 seconds using direct_path
    01-MAY-25 08:05:04.289: W-1 . . imported "F1FROM23AI"."F1_SEASONS"                   10.12 KB      75 rows in 0 seconds using direct_path
    01-MAY-25 08:05:04.307: W-1 . . imported "F1FROM23AI"."F1_SPRINTRESULTS"             30.53 KB     280 rows in 0 seconds using direct_path
    01-MAY-25 08:05:04.323: W-1 . . imported "F1FROM23AI"."F1_STATUS"                    7.921 KB     139 rows in 0 seconds using direct_path
    01-MAY-25 08:05:04.333: W-1 Processing object type SCHEMA_EXPORT/TABLE/CONSTRAINT/CONSTRAINT
    01-MAY-25 08:05:05.713: W-1      Completed 22 CONSTRAINT objects in 1 seconds
    01-MAY-25 08:05:05.721: W-1      Completed 14 SCHEMA_EXPORT/TABLE/TABLE_DATA objects in 1 seconds
    01-MAY-25 08:05:05.729: Job "DPUSER"."SYS_IMPORT_FULL_01" completed with 1 error(s) at Thu May 1 08:05:05 2025 elapsed 0 00:00:05    
    ```
    </details> 
    
You may now *proceed to the next lab*.

## Additional information

* Webinar, [Fallback is your insurance, Methods: Data Pump](https://www.youtube.com/watch?v=P12UqVRzarw&t=1820s)
* Webinar, [Data Pump Best Practices and Real World Scenarios, Upgrade with Data Pump](https://www.youtube.com/watch?v=960ToLE-ZE8&t=780s)

## Acknowledgments

* **Author** - Daniel Overby Hansen
* **Contributors** - William Beauregard, Rodrigo Jorge, Mike Dietrich, Klaus Gronau, Alex Zaballa
* **Last Updated By/Date** - Daniel Overby Hansen, May 2025