# Migrate with Data Pump over NFS

## Introduction

Now, after performing all the analysis, it's time to start our migration.

In this lab, we will migrate the *BLUE* PDB to the *SAPPHIRE* ADB using Data Pump using NFS share.

Data Pump using dump files, instead of DB links, has some advantages, like:

* More control over parallelism
* No source-target connection interoperability requirement

Estimated Time: 10 Minutes

### Objectives

In this lab, you will:

* Setup NFS on both source env and target ADB to share the Data Pump dump file.
* Generate a full schema export on the source database.
* Import the generated dump on the target database.

### Prerequisites

This lab assumes:

* You have completed Lab 1: Initialize Environment

## Task 1: Setup NFS server

There are multiple ways you can import a dump file in ADB. You could use Object Storage, move it to an Oracle Directory with UTL_FILE, or setup a NFS Server.

In this lab, we will setup a NFS Server that is going to be visible by both our source and target databases and use it to move and load our Data Pump dump file.

1. Use the *yellow* terminal 🟨. Ensure NFS Server is running.

    ``` bash
    <copy>
    cd

    sudo podman restart nfs-server
    </copy>

    # Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    $ sudo podman restart nfs-server
    nfs-server
    ```

    </details>

2. Mount the NFS share available at server *nfs-server:/exports* on the localhost.

    ``` bash
    <copy>
    sudo mkdir -p /nfs_mount

    grep -q "10.89.0.100 nfs-server" /etc/hosts || echo "10.89.0.100 nfs-server" | sudo tee -a /etc/hosts > /dev/null

    sudo mount -t nfs nfs-server:/exports /nfs_mount

    ls -l /nfs_mount
    </copy>

    # Be sure to hit RETURN
    ```

    * You should list one single file named *WORKING* on the NFS directory.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    $ sudo mkdir -p /nfs_mount
    $ grep -q "10.89.0.100 nfs-server" /etc/hosts || echo "10.89.0.100 nfs-server" | sudo tee -a /etc/hosts > /dev/null
    $ sudo mount -t nfs nfs-server:/exports /nfs_mount
    $ ls -l /nfs_mount
    total 0
    -rw-r--r--. 1 root root 0 Jul  1 19:13 WORKING
    ```

    </details>

## Task 2: Export the *BLUE* PDB

1. Still in the *yellow* 🟨 terminal, connect on the *BLUE* PDB to create a directory.

    ``` sql
    <copy>
    . cdb23
    sql sys/oracle@//localhost:1521/blue as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

2. Create a directory pointing to */nfs_mount*.

    ``` sql
    <copy>
    create directory nfs_dir as '/nfs_mount';
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> create directory nfs_dir as '/nfs_mount';

    Directory created.
    ```

    </details>

3. Close SQLcl.

    ``` bash
    <copy>
    exit
    </copy>
    ```

4. Export all the schemas of *BLUE* PDB.

    ``` bash
    <copy>
    expdp userid=system/oracle@//localhost:1521/blue \
       schemas=HR,PM,IX,SH,BI \
       logtime=all \
       metrics=true \
       directory=nfs_dir \
       dumpfile=schemas_export_%L.dmp \
       logfile=schemas_export.log \
       parallel=2 \
       flashback_time=systimestamp
    </copy>
    ```

    * You are performing a schema-based export of the schemas holding the data. For migrations to ADB, Oracle recommends using a schema-based approach. A full database export is not recommended.
    * *logtime* and *metrics* for a better verbose output.
    * *dumpfile=schemas\_export\_%L.dmp* and *parallel=2* to use parallelism.
    * *flashback\_time* for having a consistent data output.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    Export: Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems on Wed Jul 2 13:37:05 2025
    Version 23.9.0.25.07

    Copyright (c) 1982, 2025, Oracle and/or its affiliates.  All rights reserved.

    Connected to: Oracle Database 23ai Enterprise Edition Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems
    02-JUL-25 13:37:11.198: Starting "SYSTEM"."SYS_EXPORT_SCHEMA_01":  userid=system/********@//localhost:1521/blue schemas=HR,PM,IX,SH,BI logtime=all metrics=true directory=nfs_dir dumpfile=schemas_export_%L.dmp logfile=schemas_export.log parallel=2 flashback_time=systimestamp
    02-JUL-25 13:37:11.682: W-1 Startup on instance 1 took 0 seconds
    02-JUL-25 13:37:13.030: W-2 Startup on instance 1 took 0 seconds
    02-JUL-25 13:37:13.751: W-2 Processing object type SCHEMA_EXPORT/TABLE/INDEX/STATISTICS/INDEX_STATISTICS
    02-JUL-25 13:37:13.813: W-2      Completed 54 INDEX_STATISTICS objects in 0 seconds
    02-JUL-25 13:37:13.956: W-2 Processing object type SCHEMA_EXPORT/TABLE/INDEX/STATISTICS/BITMAP_INDEX/INDEX_STATISTICS
    02-JUL-25 13:37:13.969: W-2      Completed 15 INDEX_STATISTICS objects in 0 seconds
    02-JUL-25 13:37:14.042: W-2 Processing object type SCHEMA_EXPORT/TABLE/STATISTICS/TABLE_STATISTICS
    02-JUL-25 13:37:14.057: W-2      Completed 38 TABLE_STATISTICS objects in 1 seconds
    02-JUL-25 13:37:14.349: W-1 Processing object type SCHEMA_EXPORT/TABLE/TABLE_DATA
    02-JUL-25 13:37:14.536: W-1 Processing object type SCHEMA_EXPORT/USER
    02-JUL-25 13:37:14.573: W-1      Completed 5 USER objects in 0 seconds
    02-JUL-25 13:37:14.616: W-1 Processing object type SCHEMA_EXPORT/SYSTEM_GRANT
    02-JUL-25 13:37:14.630: W-1      Completed 44 SYSTEM_GRANT objects in 0 seconds
    02-JUL-25 13:37:14.734: W-1 Processing object type SCHEMA_EXPORT/ROLE_GRANT
    02-JUL-25 13:37:14.741: W-1      Completed 11 ROLE_GRANT objects in 0 seconds
    02-JUL-25 13:37:14.762: W-1 Processing object type SCHEMA_EXPORT/DEFAULT_ROLE
    02-JUL-25 13:37:14.767: W-1      Completed 5 DEFAULT_ROLE objects in 0 seconds
    02-JUL-25 13:37:14.808: W-1 Processing object type SCHEMA_EXPORT/TABLESPACE_QUOTA
    02-JUL-25 13:37:14.813: W-1      Completed 5 TABLESPACE_QUOTA objects in 0 seconds
    02-JUL-25 13:37:14.913: W-1 Processing object type SCHEMA_EXPORT/PRE_SCHEMA/PROCACT_SCHEMA/AQ
    02-JUL-25 13:37:15.187: W-1      Completed 2 AQ objects in 1 seconds
    02-JUL-25 13:37:15.191: W-1 Processing object type SCHEMA_EXPORT/PRE_SCHEMA/PROCACT_SCHEMA/LOGREP
    02-JUL-25 13:37:15.193: W-1      Completed 10 LOGREP objects in 0 seconds
    02-JUL-25 13:37:15.401: W-1 Processing object type SCHEMA_EXPORT/SYNONYM/SYNONYM
    02-JUL-25 13:37:15.407: W-1      Completed 8 SYNONYM objects in 0 seconds
    02-JUL-25 13:37:15.435: W-1 Processing object type SCHEMA_EXPORT/DB_LINK
    02-JUL-25 13:37:15.439: W-1      Completed 1 DB_LINK objects in 0 seconds
    02-JUL-25 13:37:16.282: W-1 Processing object type SCHEMA_EXPORT/TYPE/TYPE_SPEC
    02-JUL-25 13:37:16.288: W-1      Completed 4 TYPE objects in 1 seconds
    02-JUL-25 13:37:16.525: W-1 Processing object type SCHEMA_EXPORT/SEQUENCE/SEQUENCE
    02-JUL-25 13:37:16.531: W-1      Completed 5 SEQUENCE objects in 0 seconds
    02-JUL-25 13:37:19.762: W-2      Completed 1 [internal] STATISTICS objects in 5 seconds
    02-JUL-25 13:37:20.139: W-2 Processing object type SCHEMA_EXPORT/TABLE/GRANT/OWNER_GRANT/OBJECT_GRANT
    02-JUL-25 13:37:20.151: W-2      Completed 10 OBJECT_GRANT objects in 1 seconds
    02-JUL-25 13:37:20.284: W-2 Processing object type SCHEMA_EXPORT/TABLE/COMMENT
    02-JUL-25 13:37:20.329: W-2      Completed 127 COMMENT objects in 0 seconds
    02-JUL-25 13:37:21.490: W-2 Processing object type SCHEMA_EXPORT/PROCEDURE/PROCEDURE
    02-JUL-25 13:37:21.496: W-2      Completed 2 PROCEDURE objects in 0 seconds
    02-JUL-25 13:37:21.732: W-2 Processing object type SCHEMA_EXPORT/PROCEDURE/ALTER_PROCEDURE
    02-JUL-25 13:37:21.737: W-2      Completed 2 ALTER_PROCEDURE objects in 0 seconds
    02-JUL-25 13:37:22.117: W-1 Processing object type SCHEMA_EXPORT/TABLE/TABLE
    02-JUL-25 13:37:23.821: W-2 Processing object type SCHEMA_EXPORT/VIEW/VIEW
    02-JUL-25 13:37:23.829: W-2      Completed 8 VIEW objects in 2 seconds
    02-JUL-25 13:37:25.355: W-2 Processing object type SCHEMA_EXPORT/TABLE/INDEX/INDEX
    02-JUL-25 13:37:25.409: W-2      Completed 22 INDEX objects in 1 seconds
    02-JUL-25 13:37:28.075: W-2 Processing object type SCHEMA_EXPORT/TABLE/CONSTRAINT/CONSTRAINT
    02-JUL-25 13:37:28.088: W-2      Completed 21 CONSTRAINT objects in 3 seconds
    02-JUL-25 13:37:34.208: W-2 Processing object type SCHEMA_EXPORT/TABLE/CONSTRAINT/REF_CONSTRAINT
    02-JUL-25 13:37:34.219: W-2      Completed 20 REF_CONSTRAINT objects in 1 seconds
    02-JUL-25 13:37:34.721: W-2 Processing object type SCHEMA_EXPORT/TABLE/INDEX/BITMAP_INDEX/INDEX
    02-JUL-25 13:37:35.016: W-2      Completed 15 INDEX objects in 1 seconds
    02-JUL-25 13:37:35.136: W-2 Processing object type SCHEMA_EXPORT/TABLE/TRIGGER
    02-JUL-25 13:37:35.142: W-2      Completed 2 TRIGGER objects in 0 seconds
    02-JUL-25 13:37:49.427: W-1      Completed 35 TABLE objects in 30 seconds
    02-JUL-25 13:37:54.359: W-2 Processing object type SCHEMA_EXPORT/MATERIALIZED_VIEW
    02-JUL-25 13:37:54.365: W-2      Completed 2 MATERIALIZED_VIEW objects in 19 seconds
    02-JUL-25 13:37:54.438: W-2 Processing object type SCHEMA_EXPORT/DIMENSION
    02-JUL-25 13:37:54.444: W-2      Completed 5 DIMENSION objects in 0 seconds
    02-JUL-25 13:37:55.004: W-2 Processing object type SCHEMA_EXPORT/TABLE/POST_INSTANCE/PROCACT_INSTANCE/AQ
    02-JUL-25 13:37:55.008: W-2      Completed 30 AQ objects in 0 seconds
    02-JUL-25 13:37:55.178: W-2 Processing object type SCHEMA_EXPORT/TABLE/POST_INSTANCE/PROCDEPOBJ/RULE
    02-JUL-25 13:37:55.181: W-2      Completed 12 RULE objects in 0 seconds
    02-JUL-25 13:37:55.183: W-2 Processing object type SCHEMA_EXPORT/TABLE/POST_INSTANCE/PROCDEPOBJ/AQ
    02-JUL-25 13:37:55.185: W-2      Completed 8 AQ objects in 0 seconds
    02-JUL-25 13:37:55.565: W-2 Processing object type SCHEMA_EXPORT/POST_SCHEMA/PROCOBJ/RULE
    02-JUL-25 13:37:55.568: W-2      Completed 12 RULE objects in 0 seconds
    02-JUL-25 13:37:55.739: W-2 Processing object type SCHEMA_EXPORT/POST_SCHEMA/PROCACT_SCHEMA/AQ
    02-JUL-25 13:37:56.440: W-2      Completed 2 AQ objects in 1 seconds
    02-JUL-25 13:37:56.627: W-2 . . exported "SH"."CUSTOMERS"                             10.3 MB   55500 rows in 0 seconds using direct_path
    02-JUL-25 13:37:57.170: W-2 . . exported "PM"."PRINT_MEDIA"                          191.3 KB       4 rows in 1 seconds using external_table
    02-JUL-25 13:37:57.210: W-2 . . exported "PM"."TEXTDOCS_NESTEDTAB"                      88 KB      12 rows in 0 seconds using direct_path
    02-JUL-25 13:37:57.289: W-2 . . exported "SH"."SALES":"SALES_Q4_2001"                  2.3 MB   69749 rows in 0 seconds using direct_path
    02-JUL-25 13:37:57.353: W-2 . . exported "SH"."SALES":"SALES_Q3_1999"                  2.2 MB   67138 rows in 0 seconds using direct_path
    02-JUL-25 13:37:57.414: W-2 . . exported "SH"."SALES":"SALES_Q3_2001"                  2.1 MB   65769 rows in 0 seconds using direct_path
    02-JUL-25 13:37:57.475: W-2 . . exported "SH"."SALES":"SALES_Q2_2001"                  2.1 MB   63292 rows in 0 seconds using direct_path
    02-JUL-25 13:37:57.542: W-2 . . exported "SH"."SALES":"SALES_Q1_1999"                  2.1 MB   64186 rows in 0 seconds using direct_path
    02-JUL-25 13:37:57.601: W-2 . . exported "SH"."SALES":"SALES_Q1_2001"                    2 MB   60608 rows in 0 seconds using direct_path
    02-JUL-25 13:37:57.659: W-2 . . exported "SH"."SALES":"SALES_Q4_1999"                    2 MB   62388 rows in 0 seconds using direct_path
    02-JUL-25 13:37:57.718: W-2 . . exported "SH"."SALES":"SALES_Q1_2000"                    2 MB   62197 rows in 0 seconds using direct_path
    02-JUL-25 13:37:57.777: W-2 . . exported "SH"."SALES":"SALES_Q3_2000"                  1.9 MB   58950 rows in 0 seconds using direct_path
    02-JUL-25 13:37:57.840: W-2 . . exported "SH"."SALES":"SALES_Q4_2000"                  1.8 MB   55984 rows in 0 seconds using direct_path
    02-JUL-25 13:37:57.896: W-2 . . exported "SH"."SALES":"SALES_Q2_2000"                  1.8 MB   55515 rows in 0 seconds using direct_path
    02-JUL-25 13:37:57.952: W-2 . . exported "SH"."SALES":"SALES_Q2_1999"                  1.8 MB   54233 rows in 0 seconds using direct_path
    02-JUL-25 13:37:58.006: W-2 . . exported "SH"."SALES":"SALES_Q3_1998"                  1.6 MB   50515 rows in 1 seconds using direct_path
    02-JUL-25 13:37:58.058: W-2 . . exported "SH"."SALES":"SALES_Q4_1998"                  1.6 MB   48874 rows in 0 seconds using direct_path
    02-JUL-25 13:37:58.107: W-2 . . exported "SH"."SALES":"SALES_Q1_1998"                  1.4 MB   43687 rows in 0 seconds using direct_path
    02-JUL-25 13:37:58.154: W-2 . . exported "SH"."SALES":"SALES_Q2_1998"                  1.2 MB   35758 rows in 0 seconds using direct_path
    02-JUL-25 13:37:58.196: W-2 . . exported "SH"."SUPPLEMENTARY_DEMOGRAPHICS"           698.2 KB    4500 rows in 0 seconds using direct_path
    02-JUL-25 13:37:58.375: W-2 . . exported "IX"."STREAMS_QUEUE_TABLE"                   18.9 KB       0 rows in 0 seconds using external_table
    02-JUL-25 13:37:58.419: W-2 . . exported "SH"."TIMES"                                383.3 KB    1826 rows in 0 seconds using direct_path
    02-JUL-25 13:37:58.474: W-2 . . exported "SH"."FWEEK_PSCAT_SALES_MV"                 420.2 KB   11266 rows in 0 seconds using direct_path
    02-JUL-25 13:37:58.642: W-2 . . exported "IX"."ORDERS_QUEUETABLE"                     22.8 KB       0 rows in 0 seconds using external_table
    02-JUL-25 13:37:58.688: W-2 . . exported "SH"."COSTS":"COSTS_Q4_2001"                278.8 KB    9011 rows in 0 seconds using direct_path
    02-JUL-25 13:37:58.720: W-2 . . exported "SH"."COSTS":"COSTS_Q3_2001"                234.9 KB    7545 rows in 0 seconds using direct_path
    02-JUL-25 13:37:58.753: W-2 . . exported "SH"."COSTS":"COSTS_Q1_2001"                228.3 KB    7328 rows in 0 seconds using direct_path
    02-JUL-25 13:37:58.784: W-2 . . exported "SH"."COSTS":"COSTS_Q2_2001"                  185 KB    5882 rows in 0 seconds using direct_path
    02-JUL-25 13:37:58.816: W-2 . . exported "SH"."COSTS":"COSTS_Q1_1999"                  184 KB    5884 rows in 0 seconds using direct_path
    02-JUL-25 13:37:58.847: W-2 . . exported "SH"."COSTS":"COSTS_Q4_2000"                160.7 KB    5088 rows in 0 seconds using direct_path
    02-JUL-25 13:37:58.878: W-2 . . exported "SH"."COSTS":"COSTS_Q4_1999"                159.5 KB    5060 rows in 0 seconds using direct_path
    02-JUL-25 13:37:58.908: W-2 . . exported "SH"."COSTS":"COSTS_Q3_2000"                151.9 KB    4798 rows in 0 seconds using direct_path
    02-JUL-25 13:37:58.939: W-2 . . exported "SH"."COSTS":"COSTS_Q4_1998"                145.1 KB    4577 rows in 0 seconds using direct_path
    02-JUL-25 13:37:58.970: W-2 . . exported "SH"."COSTS":"COSTS_Q1_1998"                139.9 KB    4411 rows in 0 seconds using direct_path
    02-JUL-25 13:37:59.001: W-2 . . exported "SH"."COSTS":"COSTS_Q3_1999"                137.8 KB    4336 rows in 0 seconds using direct_path
    02-JUL-25 13:37:59.032: W-2 . . exported "SH"."COSTS":"COSTS_Q2_1999"                  133 KB    4179 rows in 0 seconds using direct_path
    02-JUL-25 13:37:59.063: W-2 . . exported "SH"."COSTS":"COSTS_Q3_1998"                131.5 KB    4129 rows in 0 seconds using direct_path
    02-JUL-25 13:37:59.094: W-2 . . exported "SH"."COSTS":"COSTS_Q2_2000"                119.4 KB    3715 rows in 0 seconds using direct_path
    02-JUL-25 13:37:59.127: W-2 . . exported "SH"."COSTS":"COSTS_Q1_2000"                  121 KB    3772 rows in 0 seconds using direct_path
    02-JUL-25 13:37:59.156: W-2 . . exported "SH"."COSTS":"COSTS_Q2_1998"                 79.9 KB    2397 rows in 0 seconds using direct_path
    02-JUL-25 13:37:59.186: W-2 . . exported "SH"."PROMOTIONS"                            59.6 KB     503 rows in 0 seconds using direct_path
    02-JUL-25 13:37:59.217: W-2 . . exported "SH"."PRODUCTS"                              27.6 KB      72 rows in 0 seconds using direct_path
    02-JUL-25 13:37:59.247: W-2 . . exported "HR"."EMPLOYEES"                             17.5 KB     107 rows in 0 seconds using direct_path
    02-JUL-25 13:37:59.275: W-2 . . exported "IX"."AQ$_STREAMS_QUEUE_TABLE_S"             12.3 KB       1 rows in 0 seconds using direct_path
    02-JUL-25 13:37:59.302: W-2 . . exported "IX"."AQ$_ORDERS_QUEUETABLE_S"               11.9 KB       4 rows in 0 seconds using direct_path
    02-JUL-25 13:37:59.330: W-2 . . exported "SH"."COUNTRIES"                             10.9 KB      23 rows in 0 seconds using direct_path
    02-JUL-25 13:37:59.479: W-2 . . exported "IX"."AQ$_ORDERS_QUEUETABLE_H"                9.8 KB       0 rows in 0 seconds using external_table
    02-JUL-25 13:37:59.619: W-2 . . exported "IX"."AQ$_ORDERS_QUEUETABLE_I"                9.3 KB       0 rows in 0 seconds using external_table
    02-JUL-25 13:37:59.655: W-2 . . exported "HR"."LOCATIONS"                              8.7 KB      23 rows in 0 seconds using direct_path
    02-JUL-25 13:37:59.684: W-2 . . exported "IX"."AQ$_ORDERS_QUEUETABLE_L"                8.4 KB       0 rows in 0 seconds using direct_path
    02-JUL-25 13:37:59.714: W-2 . . exported "SH"."CHANNELS"                               7.7 KB       5 rows in 0 seconds using direct_path
    02-JUL-25 13:37:59.742: W-2 . . exported "HR"."JOB_HISTORY"                            7.4 KB      10 rows in 0 seconds using direct_path
    02-JUL-25 13:37:59.770: W-2 . . exported "HR"."JOBS"                                   7.3 KB      19 rows in 0 seconds using direct_path
    02-JUL-25 13:37:59.798: W-2 . . exported "HR"."DEPARTMENTS"                            7.3 KB      27 rows in 0 seconds using direct_path
    02-JUL-25 13:37:59.945: W-2 . . exported "HR"."COUNTRIES"                              6.5 KB      25 rows in 0 seconds using external_table
    02-JUL-25 13:37:59.980: W-2 . . exported "SH"."CAL_MONTH_SALES_MV"                     6.5 KB      48 rows in 0 seconds using direct_path
    02-JUL-25 13:38:00.008: W-2 . . exported "HR"."REGIONS"                                5.6 KB       4 rows in 1 seconds using direct_path
    02-JUL-25 13:38:00.158: W-2 . . exported "IX"."AQ$_ORDERS_QUEUETABLE_G"               14.4 KB       0 rows in 0 seconds using external_table
    02-JUL-25 13:38:00.292: W-2 . . exported "IX"."AQ$_ORDERS_QUEUETABLE_T"                6.5 KB       0 rows in 0 seconds using external_table
    02-JUL-25 13:38:00.434: W-2 . . exported "IX"."AQ$_STREAMS_QUEUE_TABLE_C"                6 KB       0 rows in 0 seconds using external_table
    02-JUL-25 13:38:00.579: W-2 . . exported "IX"."AQ$_STREAMS_QUEUE_TABLE_G"             14.4 KB       0 rows in 0 seconds using external_table
    02-JUL-25 13:38:00.719: W-2 . . exported "IX"."AQ$_STREAMS_QUEUE_TABLE_H"              9.8 KB       0 rows in 0 seconds using external_table
    02-JUL-25 13:38:00.858: W-2 . . exported "IX"."AQ$_STREAMS_QUEUE_TABLE_I"              9.8 KB       0 rows in 0 seconds using external_table
    02-JUL-25 13:38:00.894: W-2 . . exported "IX"."AQ$_STREAMS_QUEUE_TABLE_L"              8.4 KB       0 rows in 0 seconds using direct_path
    02-JUL-25 13:38:01.038: W-2 . . exported "IX"."AQ$_STREAMS_QUEUE_TABLE_T"              6.5 KB       0 rows in 1 seconds using external_table
    02-JUL-25 13:38:01.073: W-2 . . exported "SH"."COSTS":"COSTS_1995"                     7.5 KB       0 rows in 0 seconds using direct_path
    02-JUL-25 13:38:01.099: W-2 . . exported "SH"."COSTS":"COSTS_1996"                     7.5 KB       0 rows in 0 seconds using direct_path
    02-JUL-25 13:38:01.126: W-2 . . exported "SH"."COSTS":"COSTS_H1_1997"                  7.5 KB       0 rows in 0 seconds using direct_path
    02-JUL-25 13:38:01.153: W-2 . . exported "SH"."COSTS":"COSTS_H2_1997"                  7.5 KB       0 rows in 0 seconds using direct_path
    02-JUL-25 13:38:01.181: W-2 . . exported "SH"."COSTS":"COSTS_Q1_2002"                  7.5 KB       0 rows in 0 seconds using direct_path
    02-JUL-25 13:38:01.209: W-2 . . exported "SH"."COSTS":"COSTS_Q1_2003"                  7.5 KB       0 rows in 0 seconds using direct_path
    02-JUL-25 13:38:01.237: W-2 . . exported "SH"."COSTS":"COSTS_Q2_2002"                  7.5 KB       0 rows in 0 seconds using direct_path
    02-JUL-25 13:38:01.265: W-2 . . exported "SH"."COSTS":"COSTS_Q2_2003"                  7.5 KB       0 rows in 0 seconds using direct_path
    02-JUL-25 13:38:01.292: W-2 . . exported "SH"."COSTS":"COSTS_Q3_2002"                  7.5 KB       0 rows in 0 seconds using direct_path
    02-JUL-25 13:38:01.320: W-2 . . exported "SH"."COSTS":"COSTS_Q3_2003"                  7.5 KB       0 rows in 0 seconds using direct_path
    02-JUL-25 13:38:01.348: W-2 . . exported "SH"."COSTS":"COSTS_Q4_2002"                  7.5 KB       0 rows in 0 seconds using direct_path
    02-JUL-25 13:38:01.376: W-2 . . exported "SH"."COSTS":"COSTS_Q4_2003"                  7.5 KB       0 rows in 0 seconds using direct_path
    02-JUL-25 13:38:01.404: W-2 . . exported "SH"."SALES":"SALES_1995"                       8 KB       0 rows in 0 seconds using direct_path
    02-JUL-25 13:38:01.432: W-2 . . exported "SH"."SALES":"SALES_1996"                       8 KB       0 rows in 0 seconds using direct_path
    02-JUL-25 13:38:01.460: W-2 . . exported "SH"."SALES":"SALES_H1_1997"                    8 KB       0 rows in 0 seconds using direct_path
    02-JUL-25 13:38:01.488: W-2 . . exported "SH"."SALES":"SALES_H2_1997"                    8 KB       0 rows in 0 seconds using direct_path
    02-JUL-25 13:38:01.518: W-2 . . exported "SH"."SALES":"SALES_Q1_2002"                    8 KB       0 rows in 0 seconds using direct_path
    02-JUL-25 13:38:01.547: W-2 . . exported "SH"."SALES":"SALES_Q1_2003"                    8 KB       0 rows in 0 seconds using direct_path
    02-JUL-25 13:38:01.575: W-2 . . exported "SH"."SALES":"SALES_Q2_2002"                    8 KB       0 rows in 0 seconds using direct_path
    02-JUL-25 13:38:01.603: W-2 . . exported "SH"."SALES":"SALES_Q2_2003"                    8 KB       0 rows in 0 seconds using direct_path
    02-JUL-25 13:38:01.630: W-2 . . exported "SH"."SALES":"SALES_Q3_2002"                    8 KB       0 rows in 0 seconds using direct_path
    02-JUL-25 13:38:01.658: W-2 . . exported "SH"."SALES":"SALES_Q3_2003"                    8 KB       0 rows in 0 seconds using direct_path
    02-JUL-25 13:38:01.685: W-2 . . exported "SH"."SALES":"SALES_Q4_2002"                    8 KB       0 rows in 0 seconds using direct_path
    02-JUL-25 13:38:01.711: W-2 . . exported "SH"."SALES":"SALES_Q4_2003"                    8 KB       0 rows in 0 seconds using direct_path
    02-JUL-25 13:38:10.508: W-2      Completed 89 SCHEMA_EXPORT/TABLE/TABLE_DATA objects in 5 seconds
    02-JUL-25 13:38:10.958: W-2 Master table "SYSTEM"."SYS_EXPORT_SCHEMA_01" successfully loaded/unloaded
    02-JUL-25 13:38:11.029: ******************************************************************************
    02-JUL-25 13:38:11.029: Dump file set for SYSTEM.SYS_EXPORT_SCHEMA_01 is:
    02-JUL-25 13:38:11.030:   /nfs_mount/schemas_export_01.dmp
    02-JUL-25 13:38:11.030:   /nfs_mount/schemas_export_02.dmp
    02-JUL-25 13:38:11.040: Job "SYSTEM"."SYS_EXPORT_SCHEMA_01" successfully completed at Wed Jul 2 13:38:11 2025 elapsed 0 00:01:03
    ```

    </details>

5. Verify that the dump file was generated on the NFS folder.

    ``` bash
    <copy>
    ls -l /nfs_mount
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    $ ls -l /nfs_mount
    total 48532
    -rw-r-----. 1 oracle oinstall 49623040 Jul  2 13:38 schemas_export_01.dmp
    -rw-r-----. 1 oracle oinstall    53248 Jul  2 13:38 schemas_export_02.dmp
    -rw-r--r--. 1 oracle oinstall    19094 Jul  2 13:38 schemas_export.log
    -rw-r--r--. 1 root   root            0 Jul  1 19:13 WORKING
    ```

    </details>

## Task 3: Modify profile in ADB

In this task, we will change the default profile so passwords for imported users will not expire and match the profile setting from the source database.

1. Still in the *yellow* 🟨 terminal, connect on the *SAPPHIRE* ADB to modify the default profile.

    ``` sql
    <copy>
    . adb
    sql admin/Welcome_1234@sapphire_tp
    </copy>

    -- Be sure to hit RETURN
    ```

2. Alter the profile.

    ``` sql
    <copy>
    alter profile default limit PASSWORD_LIFE_TIME unlimited;

    alter profile default limit PASSWORD_GRACE_TIME unlimited;
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> alter profile default limit PASSWORD_LIFE_TIME unlimited;

    Profile DEFAULT altered.

    SQL> alter profile default limit PASSWORD_GRACE_TIME unlimited;

    Profile DEFAULT altered.

    SQL>
    ```

    </details>

## Task 4: Share NFS with ADB

1. Create a directory pointing to *nfs-server:/exports*.

    ``` sql
    <copy>
    create directory nfs_dir as 'nfs';

    begin
      dbms_cloud_admin.attach_file_system (
          file_system_name      => 'nfs',
          file_system_location  => 'nfs-server:/exports',
          directory_name        => 'nfs_dir',
          description           => 'Source NFS for data'
      );
    end;
    /

    select * from dbms_cloud.list_files('nfs_dir');
    </copy>

    -- Be sure to hit RETURN
    ```

    * Note that the *nfs_dir* directory was created and can read the contents of the NFS share.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> create directory nfs_dir as 'nfs';

    Directory NFS_DIR created.

    SQL> begin
      2    dbms_cloud_admin.attach_file_system (
      3        file_system_name      => 'nfs',
      4        file_system_location  => 'nfs-server:/exports',
      5        directory_name        => 'nfs_dir',
      6        description           => 'Source NFS for data'
      7    );
      8  end;
      9* /

    PL/SQL procedure successfully completed.

    SQL> select * from dbms_cloud.list_files('nfs_dir');

    OBJECT_NAME                    BYTES CHECKSUM    CREATED    LAST_MODIFIED
    ________________________ ___________ ___________ __________ ______________________________________
    WORKING                            0                        01-JUL-25 07.13.46.691421000 PM GMT
    schemas_export.log             19094                        02-JUL-25 01.38.13.002012000 PM GMT
    schemas_export_01.dmp       49623040                        02-JUL-25 01.38.11.020962000 PM GMT
    schemas_export_02.dmp          53248                        02-JUL-25 01.38.11.014962000 PM GMT

    SQL>
    ```

    </details>

2. Close SQLcl.

    ``` sql
    <copy>
    exit
    </copy>
    ```

## Task 5: Import schemas in ADB

1. Still in the *yellow* 🟨 terminal, import all the 5 schemas on *SAPPHIRE* ADB.

    ``` bash
    <copy>
    . adb

    impdp userid=admin/Welcome_1234@sapphire_tpurgent \
       schemas=HR,PM,IX,SH,BI \
       logtime=all \
       metrics=true \
       directory=nfs_dir \
       dumpfile=schemas_export_%L.dmp \
       logfile=schemas_import_nfs.log \
       parallel=2
    </copy>

    # Be sure to hit RETURN
    ```

    * Note that the only error reported was with the DB Link that points to F1 schema on *RED* PDB.
    * We will learn how to fix this error later on *Lab 9: Check Sapphire Migration*.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    Import: Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems on Wed Jul 2 13:42:21 2025
    Version 23.9.0.25.07

    Copyright (c) 1982, 2025, Oracle and/or its affiliates.  All rights reserved.

    Connected to: Oracle Database 23ai Enterprise Edition Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems
    02-JUL-25 13:42:27.180: W-1 Startup on instance 1 took 1 seconds
    02-JUL-25 13:42:29.036: W-1 Master table "ADMIN"."SYS_IMPORT_SCHEMA_01" successfully loaded/unloaded
    02-JUL-25 13:42:29.666: Starting "ADMIN"."SYS_IMPORT_SCHEMA_01":  userid=admin/********@sapphire_tpurgent schemas=HR,PM,IX,SH,BI logtime=all metrics=true directory=nfs_dir dumpfile=schemas_export_%L.dmp logfile=schemas_import_nfs.log parallel=2
    02-JUL-25 13:42:29.752: W-1 Processing object type SCHEMA_EXPORT/USER
    02-JUL-25 13:42:30.084: W-1      Completed 5 USER objects in 1 seconds
    02-JUL-25 13:42:30.084: W-1      Completed by worker 1 5 USER objects in 1 seconds
    02-JUL-25 13:42:30.087: W-1 Processing object type SCHEMA_EXPORT/SYSTEM_GRANT
    02-JUL-25 13:42:30.191: W-1      Completed 44 SYSTEM_GRANT objects in 0 seconds
    02-JUL-25 13:42:30.191: W-1      Completed by worker 1 44 SYSTEM_GRANT objects in 0 seconds
    02-JUL-25 13:42:30.193: W-1 Processing object type SCHEMA_EXPORT/ROLE_GRANT
    02-JUL-25 13:42:30.283: W-1      Completed 11 ROLE_GRANT objects in 0 seconds
    02-JUL-25 13:42:30.283: W-1      Completed by worker 1 11 ROLE_GRANT objects in 0 seconds
    02-JUL-25 13:42:30.286: W-1 Processing object type SCHEMA_EXPORT/DEFAULT_ROLE
    02-JUL-25 13:42:30.357: W-1      Completed 5 DEFAULT_ROLE objects in 0 seconds
    02-JUL-25 13:42:30.357: W-1      Completed by worker 1 5 DEFAULT_ROLE objects in 0 seconds
    02-JUL-25 13:42:30.359: W-1 Processing object type SCHEMA_EXPORT/TABLESPACE_QUOTA
    02-JUL-25 13:42:30.430: W-1      Completed 5 TABLESPACE_QUOTA objects in 0 seconds
    02-JUL-25 13:42:30.430: W-1      Completed by worker 1 5 TABLESPACE_QUOTA objects in 0 seconds
    02-JUL-25 13:42:30.468: W-1 Processing object type SCHEMA_EXPORT/PRE_SCHEMA/PROCACT_SCHEMA/AQ
    02-JUL-25 13:42:30.606: W-1      Completed 1 AQ objects in 0 seconds
    02-JUL-25 13:42:30.608: W-1 Processing object type SCHEMA_EXPORT/PRE_SCHEMA/PROCACT_SCHEMA/LOGREP
    02-JUL-25 13:42:30.649: W-1      Completed 5 LOGREP objects in 0 seconds
    02-JUL-25 13:42:30.658: W-1 Processing object type SCHEMA_EXPORT/SYNONYM/SYNONYM
    02-JUL-25 13:42:30.734: W-1      Completed 8 SYNONYM objects in 0 seconds
    02-JUL-25 13:42:30.734: W-1      Completed by worker 1 8 SYNONYM objects in 0 seconds
    02-JUL-25 13:42:30.736: W-1 Processing object type SCHEMA_EXPORT/DB_LINK
    02-JUL-25 13:42:30.804: ORA-31685: Object type DB_LINK:"SH"."F1" failed due to insufficient privileges. Failing sql is:
    CREATE DATABASE LINK "F1"  CONNECT TO "F1" IDENTIFIED BY VALUES ':1'  USING '//localhost:1521/red'

    02-JUL-25 13:42:30.820: W-1      Completed 1 DB_LINK objects in 0 seconds
    02-JUL-25 13:42:30.820: W-1      Completed by worker 1 1 DB_LINK objects in 0 seconds
    02-JUL-25 13:42:30.830: W-1 Processing object type SCHEMA_EXPORT/TYPE/TYPE_SPEC
    02-JUL-25 13:42:31.073: W-1      Completed 4 TYPE objects in 1 seconds
    02-JUL-25 13:42:31.073: W-1      Completed by worker 1 4 TYPE objects in 1 seconds
    02-JUL-25 13:42:31.076: W-1 Processing object type SCHEMA_EXPORT/SEQUENCE/SEQUENCE
    02-JUL-25 13:42:31.174: W-1      Completed 5 SEQUENCE objects in 0 seconds
    02-JUL-25 13:42:31.174: W-1      Completed by worker 1 5 SEQUENCE objects in 0 seconds
    02-JUL-25 13:42:31.177: W-1 Processing object type SCHEMA_EXPORT/TABLE/TABLE
    02-JUL-25 13:42:32.255: W-2 Startup on instance 1 took 1 seconds
    02-JUL-25 13:42:40.535: W-1      Completed 35 TABLE objects in 9 seconds
    02-JUL-25 13:42:40.535: W-1      Completed by worker 1 2 TABLE objects in 1 seconds
    02-JUL-25 13:42:40.535: W-1      Completed by worker 2 33 TABLE objects in 8 seconds
    02-JUL-25 13:42:40.565: W-2 Processing object type SCHEMA_EXPORT/TABLE/TABLE_DATA
    02-JUL-25 13:42:40.750: W-1 . . imported "IX"."AQ$_STREAMS_QUEUE_TABLE_C"                6 KB       0 rows in 0 seconds using direct_path
    02-JUL-25 13:42:41.817: W-2 . . imported "SH"."SALES":"SALES_Q3_1999"                  2.2 MB   67138 rows in 1 seconds using external_table
    02-JUL-25 13:42:41.820: W-1 . . imported "HR"."REGIONS"                                5.6 KB       4 rows in 1 seconds using external_table
    02-JUL-25 13:42:41.822: W-1 . . imported "IX"."AQ$_STREAMS_QUEUE_TABLE_G"             14.4 KB       0 rows in 0 seconds using external_table
    02-JUL-25 13:42:41.824: W-1 . . imported "SH"."SALES":"SALES_1995"                       8 KB       0 rows in 0 seconds using external_table
    02-JUL-25 13:42:41.827: W-1 . . imported "SH"."SALES":"SALES_1996"                       8 KB       0 rows in 0 seconds using external_table
    02-JUL-25 13:42:41.829: W-1 . . imported "SH"."SALES":"SALES_H1_1997"                    8 KB       0 rows in 0 seconds using external_table
    02-JUL-25 13:42:41.832: W-1 . . imported "SH"."SALES":"SALES_H2_1997"                    8 KB       0 rows in 0 seconds using external_table
    02-JUL-25 13:42:42.029: W-1 . . imported "SH"."SALES":"SALES_Q1_1998"                  1.4 MB   43687 rows in 1 seconds using external_table
    02-JUL-25 13:42:42.170: W-2 . . imported "SH"."SALES":"SALES_Q4_1999"                    2 MB   62388 rows in 1 seconds using external_table
    02-JUL-25 13:42:42.238: W-1 . . imported "SH"."SALES":"SALES_Q2_1998"                  1.2 MB   35758 rows in 0 seconds using external_table
    02-JUL-25 13:42:42.410: W-1 . . imported "SH"."SALES":"SALES_Q3_1998"                  1.6 MB   50515 rows in 0 seconds using external_table
    02-JUL-25 13:42:42.512: W-2 . . imported "SH"."SALES":"SALES_Q1_2000"                    2 MB   62197 rows in 0 seconds using external_table
    02-JUL-25 13:42:42.731: W-1 . . imported "SH"."SALES":"SALES_Q4_1998"                  1.6 MB   48874 rows in 0 seconds using external_table
    02-JUL-25 13:42:42.868: W-2 . . imported "SH"."SALES":"SALES_Q2_2000"                  1.8 MB   55515 rows in 0 seconds using external_table
    02-JUL-25 13:42:43.066: W-1 . . imported "SH"."SALES":"SALES_Q1_1999"                  2.1 MB   64186 rows in 1 seconds using external_table
    02-JUL-25 13:42:43.196: W-2 . . imported "SH"."SALES":"SALES_Q3_2000"                  1.9 MB   58950 rows in 1 seconds using external_table
    02-JUL-25 13:42:43.378: W-1 . . imported "SH"."SALES":"SALES_Q2_1999"                  1.8 MB   54233 rows in 0 seconds using external_table
    02-JUL-25 13:42:43.560: W-2 . . imported "SH"."SALES":"SALES_Q4_2000"                  1.8 MB   55984 rows in 0 seconds using external_table
    02-JUL-25 13:42:43.735: W-1 . . imported "SH"."SALES":"SALES_Q4_2001"                  2.3 MB   69749 rows in 0 seconds using external_table
    02-JUL-25 13:42:43.738: W-1 . . imported "SH"."SALES":"SALES_Q2_2002"                    8 KB       0 rows in 0 seconds using external_table
    02-JUL-25 13:42:43.741: W-1 . . imported "SH"."SALES":"SALES_Q3_2002"                    8 KB       0 rows in 0 seconds using external_table
    02-JUL-25 13:42:43.743: W-1 . . imported "SH"."SALES":"SALES_Q4_2002"                    8 KB       0 rows in 0 seconds using external_table
    02-JUL-25 13:42:43.745: W-1 . . imported "SH"."SALES":"SALES_Q1_2003"                    8 KB       0 rows in 0 seconds using external_table
    02-JUL-25 13:42:43.748: W-1 . . imported "SH"."SALES":"SALES_Q2_2003"                    8 KB       0 rows in 0 seconds using external_table
    02-JUL-25 13:42:43.750: W-1 . . imported "SH"."SALES":"SALES_Q3_2003"                    8 KB       0 rows in 0 seconds using external_table
    02-JUL-25 13:42:43.752: W-1 . . imported "SH"."SALES":"SALES_Q4_2003"                    8 KB       0 rows in 0 seconds using external_table
    02-JUL-25 13:42:43.755: W-1 . . imported "IX"."AQ$_ORDERS_QUEUETABLE_G"               14.4 KB       0 rows in 0 seconds using external_table
    02-JUL-25 13:42:43.757: W-1 . . imported "IX"."AQ$_STREAMS_QUEUE_TABLE_L"              8.4 KB       0 rows in 0 seconds using external_table
    02-JUL-25 13:42:43.997: W-2 . . imported "SH"."SALES":"SALES_Q1_2001"                    2 MB   60608 rows in 0 seconds using external_table
    02-JUL-25 13:42:44.084: W-1 . . imported "HR"."COUNTRIES"                              6.5 KB      25 rows in 0 seconds using external_table
    02-JUL-25 13:42:44.247: W-1 . . imported "HR"."LOCATIONS"                              8.7 KB      23 rows in 0 seconds using external_table
    02-JUL-25 13:42:44.287: W-2 . . imported "SH"."SALES":"SALES_Q2_2001"                  2.1 MB   63292 rows in 1 seconds using external_table
    02-JUL-25 13:42:44.400: W-1 . . imported "HR"."JOB_HISTORY"                            7.4 KB      10 rows in 0 seconds using external_table
    02-JUL-25 13:42:44.402: W-1 . . imported "IX"."AQ$_ORDERS_QUEUETABLE_H"                9.8 KB       0 rows in 0 seconds using external_table
    02-JUL-25 13:42:44.405: W-1 . . imported "IX"."AQ$_STREAMS_QUEUE_TABLE_I"              9.8 KB       0 rows in 0 seconds using external_table
    02-JUL-25 13:42:44.577: W-2 . . imported "SH"."SALES":"SALES_Q3_2001"                  2.1 MB   65769 rows in 0 seconds using external_table
    02-JUL-25 13:42:44.626: W-1 . . imported "SH"."SUPPLEMENTARY_DEMOGRAPHICS"           698.2 KB    4500 rows in 0 seconds using external_table
    02-JUL-25 13:42:44.630: W-1 . . imported "IX"."AQ$_STREAMS_QUEUE_TABLE_T"              6.5 KB       0 rows in 0 seconds using external_table
    02-JUL-25 13:42:44.633: W-1 . . imported "SH"."COSTS":"COSTS_1995"                     7.5 KB       0 rows in 0 seconds using external_table
    02-JUL-25 13:42:44.636: W-1 . . imported "SH"."COSTS":"COSTS_1996"                     7.5 KB       0 rows in 0 seconds using external_table
    02-JUL-25 13:42:44.639: W-1 . . imported "SH"."COSTS":"COSTS_H1_1997"                  7.5 KB       0 rows in 0 seconds using external_table
    02-JUL-25 13:42:44.641: W-1 . . imported "SH"."COSTS":"COSTS_H2_1997"                  7.5 KB       0 rows in 0 seconds using external_table
    02-JUL-25 13:42:44.847: W-1 . . imported "SH"."COSTS":"COSTS_Q1_1998"                139.9 KB    4411 rows in 0 seconds using external_table
    02-JUL-25 13:42:45.052: W-1 . . imported "SH"."COSTS":"COSTS_Q2_1998"                 79.9 KB    2397 rows in 1 seconds using external_table
    02-JUL-25 13:42:45.109: W-2 . . imported "SH"."CUSTOMERS"                             10.3 MB   55500 rows in 1 seconds using external_table
    02-JUL-25 13:42:45.117: W-2 . . imported "IX"."AQ$_ORDERS_QUEUETABLE_I"                9.3 KB       0 rows in 0 seconds using external_table
    02-JUL-25 13:42:45.300: W-1 . . imported "SH"."COSTS":"COSTS_Q3_1998"                131.5 KB    4129 rows in 0 seconds using external_table
    02-JUL-25 13:42:45.354: W-2 . . imported "SH"."FWEEK_PSCAT_SALES_MV"                 420.2 KB   11266 rows in 0 seconds using external_table
    02-JUL-25 13:42:45.500: W-1 . . imported "SH"."COSTS":"COSTS_Q4_1998"                145.1 KB    4577 rows in 0 seconds using external_table
    02-JUL-25 13:42:45.527: W-2 . . imported "IX"."AQ$_ORDERS_QUEUETABLE_S"               11.9 KB       4 rows in 0 seconds using external_table
    02-JUL-25 13:42:45.710: W-1 . . imported "SH"."COSTS":"COSTS_Q1_1999"                  184 KB    5884 rows in 0 seconds using external_table
    02-JUL-25 13:42:45.828: W-2 . . imported "SH"."TIMES"                                383.3 KB    1826 rows in 0 seconds using external_table
    02-JUL-25 13:42:46.064: W-1 . . imported "SH"."COSTS":"COSTS_Q2_1999"                  133 KB    4179 rows in 1 seconds using external_table
    02-JUL-25 13:42:46.131: W-2 . . imported "SH"."PRODUCTS"                              27.6 KB      72 rows in 1 seconds using external_table
    02-JUL-25 13:42:46.246: W-1 . . imported "SH"."COSTS":"COSTS_Q3_1999"                137.8 KB    4336 rows in 0 seconds using external_table
    02-JUL-25 13:42:46.291: W-2 . . imported "HR"."DEPARTMENTS"                            7.3 KB      27 rows in 0 seconds using external_table
    02-JUL-25 13:42:46.446: W-2 . . imported "HR"."JOBS"                                   7.3 KB      19 rows in 0 seconds using external_table
    02-JUL-25 13:42:46.449: W-2 . . imported "IX"."STREAMS_QUEUE_TABLE"                   18.9 KB       0 rows in 0 seconds using external_table
    02-JUL-25 13:42:46.455: W-1 . . imported "SH"."COSTS":"COSTS_Q4_1999"                159.5 KB    5060 rows in 0 seconds using external_table
    02-JUL-25 13:42:46.656: W-1 . . imported "SH"."COSTS":"COSTS_Q1_2000"                  121 KB    3772 rows in 0 seconds using external_table
    02-JUL-25 13:42:46.668: W-2 . . imported "SH"."PROMOTIONS"                            59.6 KB     503 rows in 0 seconds using external_table
    02-JUL-25 13:42:46.864: W-1 . . imported "SH"."COSTS":"COSTS_Q2_2000"                119.4 KB    3715 rows in 0 seconds using external_table
    02-JUL-25 13:42:46.870: W-2 . . imported "HR"."EMPLOYEES"                             17.5 KB     107 rows in 0 seconds using external_table
    02-JUL-25 13:42:47.055: W-1 . . imported "SH"."COSTS":"COSTS_Q3_2000"                151.9 KB    4798 rows in 1 seconds using external_table
    02-JUL-25 13:42:47.249: W-1 . . imported "SH"."COSTS":"COSTS_Q4_2000"                160.7 KB    5088 rows in 0 seconds using external_table
    02-JUL-25 13:42:47.447: W-1 . . imported "SH"."COSTS":"COSTS_Q1_2001"                228.3 KB    7328 rows in 0 seconds using external_table
    02-JUL-25 13:42:47.644: W-1 . . imported "SH"."COSTS":"COSTS_Q2_2001"                  185 KB    5882 rows in 0 seconds using external_table
    02-JUL-25 13:42:47.926: W-1 . . imported "SH"."COSTS":"COSTS_Q3_2001"                234.9 KB    7545 rows in 0 seconds using external_table
    02-JUL-25 13:42:48.134: W-1 . . imported "SH"."COSTS":"COSTS_Q4_2001"                278.8 KB    9011 rows in 1 seconds using external_table
    02-JUL-25 13:42:48.137: W-1 . . imported "SH"."COSTS":"COSTS_Q1_2002"                  7.5 KB       0 rows in 0 seconds using external_table
    02-JUL-25 13:42:48.140: W-1 . . imported "SH"."COSTS":"COSTS_Q2_2002"                  7.5 KB       0 rows in 0 seconds using external_table
    02-JUL-25 13:42:48.142: W-1 . . imported "SH"."COSTS":"COSTS_Q3_2002"                  7.5 KB       0 rows in 0 seconds using external_table
    02-JUL-25 13:42:48.145: W-1 . . imported "SH"."COSTS":"COSTS_Q4_2002"                  7.5 KB       0 rows in 0 seconds using external_table
    02-JUL-25 13:42:48.148: W-1 . . imported "SH"."COSTS":"COSTS_Q1_2003"                  7.5 KB       0 rows in 0 seconds using external_table
    02-JUL-25 13:42:48.150: W-1 . . imported "SH"."COSTS":"COSTS_Q3_2003"                  7.5 KB       0 rows in 0 seconds using external_table
    02-JUL-25 13:42:48.153: W-1 . . imported "SH"."COSTS":"COSTS_Q4_2003"                  7.5 KB       0 rows in 0 seconds using external_table
    02-JUL-25 13:43:01.937: W-2 . . imported "PM"."PRINT_MEDIA"                          191.3 KB       4 rows in 15 seconds using external_table
    02-JUL-25 13:43:03.938: W-2 . . imported "PM"."TEXTDOCS_NESTEDTAB"                      88 KB      12 rows in 2 seconds using external_table
    02-JUL-25 13:43:03.940: W-2 . . imported "IX"."ORDERS_QUEUETABLE"                     22.8 KB       0 rows in 0 seconds using external_table
    02-JUL-25 13:43:03.943: W-2 . . imported "IX"."AQ$_ORDERS_QUEUETABLE_T"                6.5 KB       0 rows in 0 seconds using external_table
    02-JUL-25 13:43:03.945: W-2 . . imported "IX"."AQ$_STREAMS_QUEUE_TABLE_H"              9.8 KB       0 rows in 0 seconds using external_table
    02-JUL-25 13:43:04.167: W-2 . . imported "SH"."COUNTRIES"                             10.9 KB      23 rows in 1 seconds using external_table
    02-JUL-25 13:43:04.390: W-2 . . imported "IX"."AQ$_STREAMS_QUEUE_TABLE_S"             12.3 KB       1 rows in 0 seconds using external_table
    02-JUL-25 13:43:04.606: W-2 . . imported "SH"."CHANNELS"                               7.7 KB       5 rows in 0 seconds using external_table
    02-JUL-25 13:43:04.816: W-2 . . imported "SH"."CAL_MONTH_SALES_MV"                     6.5 KB      48 rows in 0 seconds using external_table
    02-JUL-25 13:43:04.819: W-2 . . imported "IX"."AQ$_ORDERS_QUEUETABLE_L"                8.4 KB       0 rows in 0 seconds using external_table
    02-JUL-25 13:43:04.821: W-2 . . imported "SH"."COSTS":"COSTS_Q2_2003"                  7.5 KB       0 rows in 0 seconds using external_table
    02-JUL-25 13:43:04.823: W-2 . . imported "SH"."SALES":"SALES_Q1_2002"                    8 KB       0 rows in 0 seconds using external_table
    02-JUL-25 13:43:04.886: W-1 Processing object type SCHEMA_EXPORT/TABLE/GRANT/OWNER_GRANT/OBJECT_GRANT
    02-JUL-25 13:43:05.043: W-1      Completed 10 OBJECT_GRANT objects in 1 seconds
    02-JUL-25 13:43:05.043: W-1      Completed by worker 2 10 OBJECT_GRANT objects in 1 seconds
    02-JUL-25 13:43:05.046: W-1 Processing object type SCHEMA_EXPORT/TABLE/COMMENT
    02-JUL-25 13:43:05.190: W-1      Completed 127 COMMENT objects in 0 seconds
    02-JUL-25 13:43:05.190: W-1      Completed by worker 1 47 COMMENT objects in 0 seconds
    02-JUL-25 13:43:05.190: W-1      Completed by worker 2 80 COMMENT objects in 0 seconds
    02-JUL-25 13:43:05.193: W-1 Processing object type SCHEMA_EXPORT/PROCEDURE/PROCEDURE
    02-JUL-25 13:43:05.277: W-1      Completed 2 PROCEDURE objects in 0 seconds
    02-JUL-25 13:43:05.277: W-1      Completed by worker 2 2 PROCEDURE objects in 0 seconds
    02-JUL-25 13:43:05.280: W-1 Processing object type SCHEMA_EXPORT/PROCEDURE/ALTER_PROCEDURE
    02-JUL-25 13:43:05.404: W-1      Completed 2 ALTER_PROCEDURE objects in 0 seconds
    02-JUL-25 13:43:05.404: W-1      Completed by worker 2 2 ALTER_PROCEDURE objects in 0 seconds
    02-JUL-25 13:43:05.407: W-1 Processing object type SCHEMA_EXPORT/VIEW/VIEW
    02-JUL-25 13:43:05.591: W-1      Completed 8 VIEW objects in 0 seconds
    02-JUL-25 13:43:05.591: W-1      Completed by worker 2 8 VIEW objects in 0 seconds
    02-JUL-25 13:43:05.653: W-1 Processing object type SCHEMA_EXPORT/TABLE/INDEX/INDEX
    02-JUL-25 13:43:06.646: W-2      Completed 22 INDEX objects in 1 seconds
    02-JUL-25 13:43:06.646: W-2      Completed by worker 1 11 INDEX objects in 1 seconds
    02-JUL-25 13:43:06.646: W-2      Completed by worker 2 11 INDEX objects in 1 seconds
    02-JUL-25 13:43:06.648: W-2 Processing object type SCHEMA_EXPORT/TABLE/CONSTRAINT/CONSTRAINT
    02-JUL-25 13:43:07.007: W-2      Completed 21 CONSTRAINT objects in 0 seconds
    02-JUL-25 13:43:07.007: W-2      Completed by worker 1 21 CONSTRAINT objects in 0 seconds
    02-JUL-25 13:43:07.010: W-2 Processing object type SCHEMA_EXPORT/TABLE/INDEX/STATISTICS/INDEX_STATISTICS
    02-JUL-25 13:43:07.034: W-2      Completed 54 INDEX_STATISTICS objects in 0 seconds
    02-JUL-25 13:43:07.034: W-2      Completed by worker 1 54 INDEX_STATISTICS objects in 0 seconds
    02-JUL-25 13:43:07.037: W-2 Processing object type SCHEMA_EXPORT/TABLE/CONSTRAINT/REF_CONSTRAINT
    02-JUL-25 13:43:07.258: W-2      Completed 20 REF_CONSTRAINT objects in 0 seconds
    02-JUL-25 13:43:07.258: W-2      Completed by worker 1 20 REF_CONSTRAINT objects in 0 seconds
    02-JUL-25 13:43:07.261: W-2 Processing object type SCHEMA_EXPORT/TABLE/INDEX/BITMAP_INDEX/INDEX
    02-JUL-25 13:43:08.993: W-2      Completed 15 INDEX objects in 1 seconds
    02-JUL-25 13:43:08.993: W-2      Completed by worker 1 8 INDEX objects in 1 seconds
    02-JUL-25 13:43:08.993: W-2      Completed by worker 2 7 INDEX objects in 0 seconds
    02-JUL-25 13:43:08.995: W-2 Processing object type SCHEMA_EXPORT/TABLE/INDEX/STATISTICS/BITMAP_INDEX/INDEX_STATISTICS
    02-JUL-25 13:43:09.016: W-2      Completed 15 INDEX_STATISTICS objects in 1 seconds
    02-JUL-25 13:43:09.016: W-2      Completed by worker 1 15 INDEX_STATISTICS objects in 0 seconds
    02-JUL-25 13:43:09.019: W-2 Processing object type SCHEMA_EXPORT/TABLE/TRIGGER
    02-JUL-25 13:43:09.113: W-2      Completed 2 TRIGGER objects in 0 seconds
    02-JUL-25 13:43:09.113: W-2      Completed by worker 1 2 TRIGGER objects in 0 seconds
    02-JUL-25 13:43:09.115: W-2 Processing object type SCHEMA_EXPORT/TABLE/STATISTICS/TABLE_STATISTICS
    02-JUL-25 13:43:09.137: W-2      Completed 38 TABLE_STATISTICS objects in 0 seconds
    02-JUL-25 13:43:09.137: W-2      Completed by worker 1 38 TABLE_STATISTICS objects in 0 seconds
    02-JUL-25 13:43:09.165: W-2      Completed 1 [internal] Unknown objects in 0 seconds
    02-JUL-25 13:43:09.165: W-2      Completed by worker 1 1 MARKER objects in 0 seconds
    02-JUL-25 13:43:09.167: W-2 Processing object type SCHEMA_EXPORT/MATERIALIZED_VIEW
    02-JUL-25 13:43:09.589: W-2      Completed 2 MATERIALIZED_VIEW objects in 0 seconds
    02-JUL-25 13:43:09.589: W-2      Completed by worker 1 2 MATERIALIZED_VIEW objects in 0 seconds
    02-JUL-25 13:43:09.591: W-2 Processing object type SCHEMA_EXPORT/DIMENSION
    02-JUL-25 13:43:09.672: W-2      Completed 5 DIMENSION objects in 0 seconds
    02-JUL-25 13:43:09.672: W-2      Completed by worker 1 5 DIMENSION objects in 0 seconds
    02-JUL-25 13:43:09.704: W-1 Processing object type SCHEMA_EXPORT/TABLE/POST_INSTANCE/PROCACT_INSTANCE/AQ
    02-JUL-25 13:43:10.563: W-1      Completed 15 AQ objects in 1 seconds
    02-JUL-25 13:43:10.657: W-1 Processing object type SCHEMA_EXPORT/TABLE/POST_INSTANCE/PROCDEPOBJ/RULE
    02-JUL-25 13:43:10.701: W-1      Completed 6 RULE objects in 0 seconds
    02-JUL-25 13:43:10.703: W-1 Processing object type SCHEMA_EXPORT/TABLE/POST_INSTANCE/PROCDEPOBJ/AQ
    02-JUL-25 13:43:10.892: W-1      Completed 4 AQ objects in 0 seconds
    02-JUL-25 13:43:10.932: W-1 Processing object type SCHEMA_EXPORT/POST_SCHEMA/PROCOBJ/RULE
    02-JUL-25 13:43:10.947: W-1      Completed 6 RULE objects in 0 seconds
    02-JUL-25 13:43:10.985: W-1 Processing object type SCHEMA_EXPORT/POST_SCHEMA/PROCACT_SCHEMA/AQ
    02-JUL-25 13:43:11.168: W-1      Completed 1 AQ objects in 1 seconds
    02-JUL-25 13:43:11.226: W-1      Completed 89 SCHEMA_EXPORT/TABLE/TABLE_DATA objects in 24 seconds
    02-JUL-25 13:43:11.295: Job "ADMIN"."SYS_IMPORT_SCHEMA_01" completed with 1 error(s) at Wed Jul 2 13:43:11 2025 elapsed 0 00:00:46
    ```

    </details>

You may now [*proceed to the next lab*](#next).

## Additional information

* Webinar, [Data Pump Best Practices and Real World Scenarios, Metadata](https://www.youtube.com/watch?v=CUHcKHx_YvA&t=1260s)
* Webinar, [Data Pump Best Practices and Real World Scenarios, Generate metadata with SQLFILE](https://www.youtube.com/watch?v=CUHcKHx_YvA&t=4642s)

## Acknowledgments

* **Author** - Rodrigo Jorge
* **Contributors** - William Beauregard, Daniel Overby Hansen, Mike Dietrich, Klaus Gronau, Alex Zaballa
* **Last Updated By/Date** - Rodrigo Jorge, August 2025
