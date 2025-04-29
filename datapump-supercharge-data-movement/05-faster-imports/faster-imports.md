# Faster Imports

## Introduction

If you use Data Pump to migrate entire databases, you often want it to happen as fast as possible. There are several techniques that you can use with Data Pump that will speed up the import process. In this lab, you will use these techniques and see the effect of them.

Estimated Time: 20 Minutes

### Objectives

In this lab, you will:

* Use techniques to import faster

### Prerequisites

This lab assumes:

- You have completed Lab 3: Getting Started

## Task 1: SecureFile LOBs

Oracle Database stores LOBs in two formats. *SecureFile LOBs* is the newest format with a lot of advantages over the older format, *BasicFile LOBs*. Oracle recommends that you store your LOBs in SecureFile format.

1. Use the *yellow* terminal 🟨. Copy an existing dump file into the *dpdir* directory. The dump contains a schema with a table that contains a BasicFile LOB.

    ```
    <copy>
    cp /home/oracle/scripts/faster-import-lob.dmp /home/oracle/dpdir
    </copy>
    ```

2. Examine a pre-created parameter file.

    ```
    <copy>
    cat /home/oracle/scripts/dp-05-lob-basicfile.par
    </copy>
    ```

    * This is a simple import parameter file with nothing special.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    directory=dpdir
    dumpfile=faster-import-lob.dmp
    logfile=faster-import-lob-basicfile.log
    metrics=yes
    logtime=all
    parallel=4    
    ```
    </details> 

3. Set the environment to *FTEX* and import.
    
    ```
    <copy>
    . ftex
    impdp dpuser/oracle parfile=/home/oracle/scripts/dp-05-lob-basicfile.par
    </copy>

    -- Be sure to hit RETURN
    ```

    * The table *BLOBLOAD.TAB1* contains a BasicFile LOB column.
    * Notice how long it took to import the table. In the example in the instructions it took 121 seconds.
    * Also, Data Pump used direct path to load the table.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    Import: Release 19.0.0.0.0 - Production on Mon Apr 28 08:40:43 2025
    Version 19.21.0.0.0
    
    Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.
    
    Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    28-APR-25 08:40:44.879: W-1 Startup took 0 seconds
    28-APR-25 08:40:45.028: W-1 Master table "DPUSER"."SYS_IMPORT_FULL_01" successfully loaded/unloaded
    28-APR-25 08:40:45.363: Starting "DPUSER"."SYS_IMPORT_FULL_01":  dpuser/******** parfile=/home/oracle/scripts/dp-05-lob-basicfile.par
    28-APR-25 08:40:45.376: W-1 Processing object type SCHEMA_EXPORT/USER
    28-APR-25 08:40:45.444: W-1      Completed 1 USER objects in 0 seconds
    28-APR-25 08:40:45.444: W-1      Completed by worker 1 1 USER objects in 0 seconds
    28-APR-25 08:40:45.446: W-1 Processing object type SCHEMA_EXPORT/SYSTEM_GRANT
    28-APR-25 08:40:45.474: W-1      Completed 1 SYSTEM_GRANT objects in 0 seconds
    28-APR-25 08:40:45.474: W-1      Completed by worker 1 1 SYSTEM_GRANT objects in 0 seconds
    28-APR-25 08:40:45.477: W-1 Processing object type SCHEMA_EXPORT/ROLE_GRANT
    28-APR-25 08:40:45.504: W-1      Completed 1 ROLE_GRANT objects in 0 seconds
    28-APR-25 08:40:45.504: W-1      Completed by worker 1 1 ROLE_GRANT objects in 0 seconds
    28-APR-25 08:40:45.507: W-1 Processing object type SCHEMA_EXPORT/DEFAULT_ROLE
    28-APR-25 08:40:45.533: W-1      Completed 1 DEFAULT_ROLE objects in 0 seconds
    28-APR-25 08:40:45.533: W-1      Completed by worker 1 1 DEFAULT_ROLE objects in 0 seconds
    28-APR-25 08:40:45.535: W-1 Processing object type SCHEMA_EXPORT/PRE_SCHEMA/PROCACT_SCHEMA
    28-APR-25 08:40:45.576: W-1      Completed 1 PROCACT_SCHEMA objects in 0 seconds
    28-APR-25 08:40:45.576: W-1      Completed by worker 1 1 PROCACT_SCHEMA objects in 0 seconds
    28-APR-25 08:40:45.578: W-1 Processing object type SCHEMA_EXPORT/SEQUENCE/SEQUENCE
    28-APR-25 08:40:45.638: W-1      Completed 1 SEQUENCE objects in 0 seconds
    28-APR-25 08:40:45.638: W-1      Completed by worker 1 1 SEQUENCE objects in 0 seconds
    28-APR-25 08:40:45.640: W-1 Processing object type SCHEMA_EXPORT/TABLE/TABLE
    28-APR-25 08:40:45.745: W-1      Completed 1 TABLE objects in 0 seconds
    28-APR-25 08:40:45.745: W-1      Completed by worker 1 1 TABLE objects in 0 seconds
    28-APR-25 08:40:45.755: W-1 Processing object type SCHEMA_EXPORT/TABLE/TABLE_DATA
    28-APR-25 08:42:46.062: W-1 . . imported "BLOBLOAD"."TAB1"                           1.007 GB     904 rows in 121 seconds using direct_path
    28-APR-25 08:42:46.082: W-1      Completed 1 SCHEMA_EXPORT/TABLE/TABLE_DATA objects in 121 seconds
    28-APR-25 08:42:46.086: Job "DPUSER"."SYS_IMPORT_FULL_01" successfully completed at Mon Apr 28 08:42:46 2025 elapsed 0 00:02:02
    ```
    </details> 

4. Drop the schema, so you can import again.

    ```
    <copy>
    sqlplus / as sysdba<<EOF
       drop user blobload cascade;
    EOF
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL*Plus: Release 19.0.0.0.0 - Production on Mon Apr 28 08:46:50 2025
    Version 19.21.0.0.0
    
    Copyright (c) 1982, 2022, Oracle.  All rights reserved.
    
    
    Connected to:
    Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    Version 19.21.0.0.0
    
    SQL>
    User dropped.
    
    SQL> Disconnected from Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    Version 19.21.0.0.0
    ```
    </details> 

5. Examine another parameter file.

    ```
    <copy>
    cat /home/oracle/scripts/dp-05-lob-securefile.par
    </copy>
    ```

    * This is similar to the previous parameter file, except for `TRANSFORM=LOB_STORAGE:SECUREFILE`.
    * This transformation instruct Data Pump to create all LOB columns as SecureFile LOBs regardless of the original definition.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    directory=dpdir
    dumpfile=faster-import-lob.dmp
    logfile=faster-import-lob-securefile.log
    metrics=yes
    logtime=all
    parallel=4
    transform=lob_storage:securefile    
    ```
    </details> 

6. Perform another import with the changed parameter file.
    
    ```
    <copy>
    impdp dpuser/oracle parfile=/home/oracle/scripts/dp-05-lob-securefile.par
    </copy>
    ```

    * Data Pump now chooses a different access method, external table. Previously, Data Pump selected direct path. 
    * Loading data into a SecureFile LOB allows Data Pump to choose other load methods and using parallel query (PQ) processes.
    * Compare the time it took to import the table with the previous import. Importing into a SecureFile LOB is faster. In the example in the instructions, it went from 121 seconds to 80 seconds. 
    * Oracle recommends that you always convert BasicFile LOBs to SecureFile LOBs on import. It's faster and SecureFile LOBs offer superior functionality. 
    * It's safe to always add `TRANSFORM=LOB_STORAGE:SECUFILE` to your parameter files. If a LOB is already a SecureFile, Data Pump ignores the transformation.
    
    <details>
    <summary>*click to see the output*</summary>
    ``` text
    Import: Release 19.0.0.0.0 - Production on Mon Apr 28 08:49:43 2025
    Version 19.21.0.0.0
    
    Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.
    
    Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    28-APR-25 08:49:44.678: W-1 Startup took 0 seconds
    28-APR-25 08:49:44.772: W-1 Master table "DPUSER"."SYS_IMPORT_FULL_01" successfully loaded/unloaded
    28-APR-25 08:49:45.029: Starting "DPUSER"."SYS_IMPORT_FULL_01":  dpuser/******** parfile=/home/oracle/scripts/dp-05-lob-securefile.par
    28-APR-25 08:49:45.043: W-1 Processing object type SCHEMA_EXPORT/USER
    28-APR-25 08:49:45.108: W-1      Completed 1 USER objects in 0 seconds
    28-APR-25 08:49:45.108: W-1      Completed by worker 1 1 USER objects in 0 seconds
    28-APR-25 08:49:45.110: W-1 Processing object type SCHEMA_EXPORT/SYSTEM_GRANT
    28-APR-25 08:49:45.134: W-1      Completed 1 SYSTEM_GRANT objects in 0 seconds
    28-APR-25 08:49:45.134: W-1      Completed by worker 1 1 SYSTEM_GRANT objects in 0 seconds
    28-APR-25 08:49:45.136: W-1 Processing object type SCHEMA_EXPORT/ROLE_GRANT
    28-APR-25 08:49:45.162: W-1      Completed 1 ROLE_GRANT objects in 0 seconds
    28-APR-25 08:49:45.162: W-1      Completed by worker 1 1 ROLE_GRANT objects in 0 seconds
    28-APR-25 08:49:45.164: W-1 Processing object type SCHEMA_EXPORT/DEFAULT_ROLE
    28-APR-25 08:49:45.188: W-1      Completed 1 DEFAULT_ROLE objects in 0 seconds
    28-APR-25 08:49:45.188: W-1      Completed by worker 1 1 DEFAULT_ROLE objects in 0 seconds
    28-APR-25 08:49:45.190: W-1 Processing object type SCHEMA_EXPORT/PRE_SCHEMA/PROCACT_SCHEMA
    28-APR-25 08:49:45.229: W-1      Completed 1 PROCACT_SCHEMA objects in 0 seconds
    28-APR-25 08:49:45.229: W-1      Completed by worker 1 1 PROCACT_SCHEMA objects in 0 seconds
    28-APR-25 08:49:45.231: W-1 Processing object type SCHEMA_EXPORT/SEQUENCE/SEQUENCE
    28-APR-25 08:49:45.288: W-1      Completed 1 SEQUENCE objects in 0 seconds
    28-APR-25 08:49:45.288: W-1      Completed by worker 1 1 SEQUENCE objects in 0 seconds
    28-APR-25 08:49:45.290: W-1 Processing object type SCHEMA_EXPORT/TABLE/TABLE
    28-APR-25 08:49:45.392: W-1      Completed 1 TABLE objects in 0 seconds
    28-APR-25 08:49:45.392: W-1      Completed by worker 1 1 TABLE objects in 0 seconds
    28-APR-25 08:49:45.402: W-1 Processing object type SCHEMA_EXPORT/TABLE/TABLE_DATA
    28-APR-25 08:51:05.503: W-1 . . imported "BLOBLOAD"."TAB1"                           1.007 GB     904 rows in 80 seconds using external_table
    28-APR-25 08:51:05.523: W-1      Completed 1 SCHEMA_EXPORT/TABLE/TABLE_DATA objects in 80 seconds
    28-APR-25 08:51:05.528: Job "DPUSER"."SYS_IMPORT_FULL_01" successfully completed at Mon Apr 28 08:51:05 2025 elapsed 0 00:01:21    
    ```
    </details>

## Task 2: Statistics - Gather

When exporting tables or indexes Data Pump also exports the corresponding statistics. Knowing how essential statistics are for good query performance, this is a good and convenient approach. However, there are other methods to getting up-to-date statistics after import. Oracle recommends that you exclude statistics from your export and use the other methods. In this task, you will re-gather statistics after import.

1. Still in the *yellow* terminal 🟨. Examine a parameter file that excludes statistics.

    ```
    <copy>
    cat /home/oracle/scripts/dp-05-stats-export.par
    </copy>
    ```

    * `EXCLUDE=STATISTICS` excludes statistics from the export.
    * If a dump file contains statistics, you can also use the `EXCLUDE` parameter on import.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    schemas=F1
    directory=dpdir
    dumpfile=faster-import-stats-%L.dmp
    logfile=faster-import-stats-export.log
    metrics=yes
    logtime=all
    parallel=4
    reuse_dumpfiles=yes
    exclude=statistics
    ```
    </details> 
    
2. Perform the export.

    ```
    <copy>
    . ftex
    expdp dpuser/oracle parfile=/home/oracle/scripts/dp-05-stats-export.par
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    Export: Release 19.0.0.0.0 - Production on Mon Apr 28 13:29:21 2025
    Version 19.21.0.0.0
    
    Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.
    
    Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    28-APR-25 13:29:23.350: Starting "DPUSER"."SYS_EXPORT_SCHEMA_02":  dpuser/******** parfile=/home/oracle/scripts/dp-05-stats-export.par
    28-APR-25 13:29:23.566: W-1 Startup took 0 seconds
    28-APR-25 13:29:24.573: W-2 Startup took 0 seconds
    28-APR-25 13:29:24.587: W-3 Startup took 0 seconds
    28-APR-25 13:29:24.594: W-4 Startup took 0 seconds
    28-APR-25 13:29:25.068: W-4 Processing object type SCHEMA_EXPORT/USER
    28-APR-25 13:29:25.088: W-2 Processing object type SCHEMA_EXPORT/SYSTEM_GRANT
    28-APR-25 13:29:25.108: W-4      Completed 1 USER objects in 1 seconds
    28-APR-25 13:29:25.115: W-2      Completed 2 SYSTEM_GRANT objects in 0 seconds
    28-APR-25 13:29:25.136: W-2 Processing object type SCHEMA_EXPORT/DEFAULT_ROLE
    28-APR-25 13:29:25.140: W-2      Completed 1 DEFAULT_ROLE objects in 0 seconds
    28-APR-25 13:29:25.159: W-2 Processing object type SCHEMA_EXPORT/TABLESPACE_QUOTA
    28-APR-25 13:29:25.165: W-2      Completed 1 TABLESPACE_QUOTA objects in 0 seconds
    28-APR-25 13:29:25.339: W-3 Processing object type SCHEMA_EXPORT/PRE_SCHEMA/PROCACT_SCHEMA
    28-APR-25 13:29:25.357: W-3      Completed 1 PROCACT_SCHEMA objects in 0 seconds
    28-APR-25 13:29:25.513: W-1 Processing object type SCHEMA_EXPORT/TABLE/TABLE_DATA
    28-APR-25 13:29:27.228: W-3 Processing object type SCHEMA_EXPORT/TABLE/TABLE
    28-APR-25 13:29:27.351: W-3      Completed 14 TABLE objects in 2 seconds
    28-APR-25 13:29:27.966: W-4 Processing object type SCHEMA_EXPORT/TABLE/CONSTRAINT/CONSTRAINT
    28-APR-25 13:29:27.975: W-4      Completed 22 CONSTRAINT objects in 0 seconds
    28-APR-25 13:29:28.175: W-4 . . exported "F1"."F1_RESULTS"                           1.429 MB   26439 rows in 0 seconds using direct_path
    28-APR-25 13:29:28.208: W-4 . . exported "F1"."F1_DRIVERSTANDINGS"                   916.2 KB   34511 rows in 0 seconds using direct_path
    28-APR-25 13:29:28.266: W-4 . . exported "F1"."F1_QUALIFYING"                        419.0 KB   10174 rows in 0 seconds using direct_path
    28-APR-25 13:29:28.268: W-3 . . exported "F1"."F1_LAPTIMES"                          16.98 MB  571047 rows in 0 seconds using direct_path
    28-APR-25 13:29:28.294: W-4 . . exported "F1"."F1_PITSTOPS"                          416.8 KB   10793 rows in 0 seconds using direct_path
    28-APR-25 13:29:28.320: W-4 . . exported "F1"."F1_CONSTRUCTORSTANDINGS"              344.1 KB   13231 rows in 0 seconds using direct_path
    28-APR-25 13:29:28.345: W-4 . . exported "F1"."F1_CONSTRUCTORRESULTS"                225.2 KB   12465 rows in 0 seconds using direct_path
    28-APR-25 13:29:28.373: W-4 . . exported "F1"."F1_RACES"                             131.4 KB    1125 rows in 0 seconds using direct_path
    28-APR-25 13:29:28.397: W-4 . . exported "F1"."F1_DRIVERS"                           87.86 KB     859 rows in 0 seconds using direct_path
    28-APR-25 13:29:28.421: W-4 . . exported "F1"."F1_SPRINTRESULTS"                     29.88 KB     280 rows in 0 seconds using direct_path
    28-APR-25 13:29:28.445: W-4 . . exported "F1"."F1_CONSTRUCTORS"                      22.97 KB     212 rows in 0 seconds using direct_path
    28-APR-25 13:29:28.469: W-4 . . exported "F1"."F1_CIRCUITS"                          17.42 KB      77 rows in 0 seconds using direct_path
    28-APR-25 13:29:28.493: W-4 . . exported "F1"."F1_SEASONS"                           10.03 KB      75 rows in 0 seconds using direct_path
    28-APR-25 13:29:28.515: W-4 . . exported "F1"."F1_STATUS"                            7.843 KB     139 rows in 0 seconds using direct_path
    28-APR-25 13:29:29.104: W-4      Completed 14 SCHEMA_EXPORT/TABLE/TABLE_DATA objects in 0 seconds
    28-APR-25 13:29:29.752: W-4 Master table "DPUSER"."SYS_EXPORT_SCHEMA_02" successfully loaded/unloaded
    28-APR-25 13:29:29.754: ******************************************************************************
    28-APR-25 13:29:29.755: Dump file set for DPUSER.SYS_EXPORT_SCHEMA_02 is:
    28-APR-25 13:29:29.756:   /home/oracle/dpdir/faster-import-stats-01.dmp
    28-APR-25 13:29:29.757:   /home/oracle/dpdir/faster-import-stats-02.dmp
    28-APR-25 13:29:29.757:   /home/oracle/dpdir/faster-import-stats-03.dmp
    28-APR-25 13:29:29.764: Job "DPUSER"."SYS_EXPORT_SCHEMA_02" successfully completed at Mon Apr 28 13:29:29 2025 elapsed 0 00:00:07    
    ```
    </details> 

3. Verify that Data Pump did not export statistics. Examine the export log file.

    ```
    <copy>
    grep "STATISTICS" /home/oracle/dpdir/faster-import-stats-export.log    
    </copy>
    ```

    * The command returns nothing because the export log file doesn't contain any entries about statistics.
    * If statistics were included you would see lines with `TABLE_STATISTICS` or `INDEX_STATISTICS`.
 
4. Perform the import into the same database, but into a new schema. Examine the parameter file.

    ```
    <copy>
    cat /home/oracle/scripts/dp-05-stats-import.par
    </copy>
    ```

    * Since statistics were excluded from the export, there's no need to add the parameter again.
    * `REMAP_SCHEMA` imports the *F1* schema with a new name.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    directory=dpdir
    dumpfile=faster-import-stats-%L.dmp
    logfile=faster-import-stats-import.log
    metrics=yes
    logtime=all
    parallel=4
    remap_schema=F1:LAB5STATS
    ```
    </details> 

5. Start Data Pump import.

    ```
    <copy>
    . ftex
    impdp dpuser/oracle parfile=/home/oracle/scripts/dp-05-stats-import.par
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    Import: Release 19.0.0.0.0 - Production on Mon Apr 28 13:37:00 2025
    Version 19.21.0.0.0
    
    Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.
    
    Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    28-APR-25 13:37:01.631: W-1 Startup took 0 seconds
    28-APR-25 13:37:02.157: W-1 Master table "DPUSER"."SYS_IMPORT_FULL_01" successfully loaded/unloaded
    28-APR-25 13:37:02.433: Starting "DPUSER"."SYS_IMPORT_FULL_01":  dpuser/******** parfile=/home/oracle/scripts/dp-05-stats-import.par
    28-APR-25 13:37:02.447: W-1 Processing object type SCHEMA_EXPORT/USER
    28-APR-25 13:37:02.575: W-1      Completed 1 USER objects in 0 seconds
    28-APR-25 13:37:02.575: W-1      Completed by worker 1 1 USER objects in 0 seconds
    28-APR-25 13:37:02.578: W-1 Processing object type SCHEMA_EXPORT/SYSTEM_GRANT
    28-APR-25 13:37:02.621: W-1      Completed 2 SYSTEM_GRANT objects in 0 seconds
    28-APR-25 13:37:02.621: W-1      Completed by worker 1 2 SYSTEM_GRANT objects in 0 seconds
    28-APR-25 13:37:02.623: W-1 Processing object type SCHEMA_EXPORT/DEFAULT_ROLE
    28-APR-25 13:37:02.660: W-1      Completed 1 DEFAULT_ROLE objects in 0 seconds
    28-APR-25 13:37:02.660: W-1      Completed by worker 1 1 DEFAULT_ROLE objects in 0 seconds
    28-APR-25 13:37:02.662: W-1 Processing object type SCHEMA_EXPORT/TABLESPACE_QUOTA
    28-APR-25 13:37:02.703: W-1      Completed 1 TABLESPACE_QUOTA objects in 0 seconds
    28-APR-25 13:37:02.703: W-1      Completed by worker 1 1 TABLESPACE_QUOTA objects in 0 seconds
    28-APR-25 13:37:02.705: W-1 Processing object type SCHEMA_EXPORT/PRE_SCHEMA/PROCACT_SCHEMA
    28-APR-25 13:37:02.831: W-1      Completed 1 PROCACT_SCHEMA objects in 0 seconds
    28-APR-25 13:37:02.831: W-1      Completed by worker 1 1 PROCACT_SCHEMA objects in 0 seconds
    28-APR-25 13:37:02.833: W-1 Processing object type SCHEMA_EXPORT/TABLE/TABLE
    28-APR-25 13:37:03.181: W-4 Startup took 1 seconds
    28-APR-25 13:37:03.187: W-3 Startup took 1 seconds
    28-APR-25 13:37:03.227: W-2 Startup took 1 seconds
    28-APR-25 13:37:03.519: W-2      Completed 14 TABLE objects in 1 seconds
    28-APR-25 13:37:03.519: W-2      Completed by worker 1 6 TABLE objects in 1 seconds
    28-APR-25 13:37:03.519: W-2      Completed by worker 3 5 TABLE objects in 0 seconds
    28-APR-25 13:37:03.519: W-2      Completed by worker 4 3 TABLE objects in 0 seconds
    28-APR-25 13:37:03.532: W-1 Processing object type SCHEMA_EXPORT/TABLE/TABLE_DATA
    28-APR-25 13:37:03.643: W-3 . . imported "LAB5STATS"."F1_RESULTS"                    1.429 MB   26439 rows in 0 seconds using direct_path
    28-APR-25 13:37:03.702: W-3 . . imported "LAB5STATS"."F1_DRIVERSTANDINGS"            916.2 KB   34511 rows in 0 seconds using direct_path
    28-APR-25 13:37:03.749: W-3 . . imported "LAB5STATS"."F1_QUALIFYING"                 419.0 KB   10174 rows in 0 seconds using direct_path
    28-APR-25 13:37:03.751: W-4 . . imported "LAB5STATS"."F1_LAPTIMES"                   16.98 MB  571047 rows in 0 seconds using direct_path
    28-APR-25 13:37:03.777: W-3 . . imported "LAB5STATS"."F1_PITSTOPS"                   416.8 KB   10793 rows in 0 seconds using direct_path
    28-APR-25 13:37:03.803: W-3 . . imported "LAB5STATS"."F1_CONSTRUCTORSTANDINGS"       344.1 KB   13231 rows in 0 seconds using direct_path
    28-APR-25 13:37:03.829: W-3 . . imported "LAB5STATS"."F1_CONSTRUCTORRESULTS"         225.2 KB   12465 rows in 0 seconds using direct_path
    28-APR-25 13:37:03.855: W-3 . . imported "LAB5STATS"."F1_RACES"                      131.4 KB    1125 rows in 0 seconds using direct_path
    28-APR-25 13:37:03.880: W-3 . . imported "LAB5STATS"."F1_DRIVERS"                    87.86 KB     859 rows in 0 seconds using direct_path
    28-APR-25 13:37:03.904: W-3 . . imported "LAB5STATS"."F1_SPRINTRESULTS"              29.88 KB     280 rows in 0 seconds using direct_path
    28-APR-25 13:37:03.927: W-3 . . imported "LAB5STATS"."F1_CONSTRUCTORS"               22.97 KB     212 rows in 0 seconds using direct_path
    28-APR-25 13:37:03.951: W-3 . . imported "LAB5STATS"."F1_CIRCUITS"                   17.42 KB      77 rows in 0 seconds using direct_path
    28-APR-25 13:37:03.973: W-3 . . imported "LAB5STATS"."F1_SEASONS"                    10.03 KB      75 rows in 0 seconds using direct_path
    28-APR-25 13:37:03.995: W-3 . . imported "LAB5STATS"."F1_STATUS"                     7.843 KB     139 rows in 0 seconds using direct_path
    28-APR-25 13:37:04.014: W-1 Processing object type SCHEMA_EXPORT/TABLE/CONSTRAINT/CONSTRAINT
    28-APR-25 13:37:05.040: W-3      Completed 22 CONSTRAINT objects in 1 seconds
    28-APR-25 13:37:05.040: W-3      Completed by worker 4 22 CONSTRAINT objects in 1 seconds
    28-APR-25 13:37:05.054: W-2      Completed 14 SCHEMA_EXPORT/TABLE/TABLE_DATA objects in 0 seconds
    28-APR-25 13:37:05.062: Job "DPUSER"."SYS_IMPORT_FULL_01" successfully completed at Mon Apr 28 13:37:05 2025 elapsed 0 00:00:04
    ```
    </details> 

6. Connect to *FTEX*.

    ```
    <copy>
    sqlplus / as sysdba
    </copy>
    ```

7. Verify there are no statistics on the tables in the *LAB5STATS* schema.

    ```
    <copy>
    set pagesize 100
    col table_name format a30
    select table_name, last_analyzed from dba_tab_statistics where owner='LAB5STATS';
    </copy>

    -- Be sure to hit RETURN
    ```

    * The column `LAST_ANALYZED` is NULL indicating that there are no statistics.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    TABLE_NAME                     LAST_ANALYZED
    ------------------------------ ------------------
    F1_DRIVERS
    F1_LAPTIMES
    F1_CONSTRUCTORSTANDINGS
    F1_SPRINTRESULTS
    F1_STATUS
    F1_PITSTOPS
    F1_DRIVERSTANDINGS
    F1_CONSTRUCTORS
    F1_CIRCUITS
    F1_QUALIFYING
    F1_CONSTRUCTORRESULTS
    F1_RESULTS
    F1_RACES
    F1_SEASONS
    
    14 rows selected.    
    ```
    </details>

8. Gather statistics using `DBMS_STATS`.

    ```
    <copy>
    begin
        dbms_stats.gather_schema_stats(
            ownname => 'LAB5STATS',
            degree => DBMS_STATS.AUTO_DEGREE
        );
    end;
    /
    </copy>

    -- Be sure to hit RETURN
    ```

    * Using `DEGREE` set to `AUTO_DEGREE` allows the database to use more CPU.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> begin
            dbms_stats.gather_schema_stats(
                ownname => 'LAB5STATS',
                degree => DBMS_STATS.AUTO_DEGREE
            );
         end;
         /  2    3    4    5    6    7
    
    PL/SQL procedure successfully completed.
    ```
    </details>

9. Ensure that all tables now have statistics.

    ```
    <copy>
    set pagesize 100
    col table_name format a30
    select table_name, last_analyzed from dba_tab_statistics where owner='LAB5STATS';
    </copy>

    -- Be sure to hit RETURN
    ```

    * The column `LAST_ANALYZED` is now populated with the current date (28-APR-25). 
    * This indicates that these statistics were just gathered.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    TABLE_NAME                     LAST_ANALYZED
    ------------------------------ ------------------
    F1_CONSTRUCTORRESULTS          28-APR-25
    F1_SEASONS                     28-APR-25
    F1_RACES                       28-APR-25
    F1_CIRCUITS                    28-APR-25
    F1_CONSTRUCTORS                28-APR-25
    F1_CONSTRUCTORSTANDINGS        28-APR-25
    F1_SPRINTRESULTS               28-APR-25
    F1_DRIVERSTANDINGS             28-APR-25
    F1_STATUS                      28-APR-25
    F1_RESULTS                     28-APR-25
    F1_LAPTIMES                    28-APR-25
    F1_PITSTOPS                    28-APR-25
    F1_QUALIFYING                  28-APR-25
    F1_DRIVERS                     28-APR-25
    
    14 rows selected.    
    ```
    </details>    

## Task 3: Statistics - Transfer

Another option is to transfer the statistics from the source database using the `DBMS_STATS` package. Transferring statistics is much faster than exporting and importing statistics using Data Pump. 

1. Still in the *yellow* terminal 🟨 and connected to the *FTEX* database. In our lab, the source and target databases are the same. Otherwise, you should have switched to the source database now. The source tables in the *F1* schema does have statistics. 

    ```
    <copy>
    set pagesize 100
    col table_name format a30
    select table_name, last_analyzed from dba_tab_statistics where owner='F1';
    </copy>

    -- Be sure to hit RETURN
    ```

    * The column `LAST_ANALYZED` is populated with a past date.
    * This indicates that there are statistics in the source schema.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    TABLE_NAME                     LAST_ANALYZED
    ------------------------------ ------------------
    F1_CONSTRUCTORRESULTS          05-DEC-24
    F1_SEASONS                     05-DEC-24
    F1_RACES                       05-DEC-24
    F1_CIRCUITS                    05-DEC-24
    F1_CONSTRUCTORS                05-DEC-24
    F1_CONSTRUCTORSTANDINGS        05-DEC-24
    F1_SPRINTRESULTS               05-DEC-24
    F1_DRIVERSTANDINGS             05-DEC-24
    F1_STATUS                      05-DEC-24
    F1_RESULTS                     05-DEC-24
    F1_LAPTIMES                    05-DEC-24
    F1_PITSTOPS                    05-DEC-24
    F1_QUALIFYING                  05-DEC-24
    F1_DRIVERS                     05-DEC-24
    
    14 rows selected.
    ```
    </details> 

3. To transfer statistics you must create a staging table.

    ```
    <copy>
    exec dbms_stats.create_stat_table('F1', 'STATTAB');
    </copy>
    ```

    * It's convenient to create the staging table in the same schema as you're exporting.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> exec dbms_stats.create_stat_table('F1', 'STATTAB');
    
    PL/SQL procedure successfully completed.
    ```
    </details>     

4. Take the statistics from the data dictionary and store them in a transportable format in the staging table.

    ```
    <copy>
    exec dbms_stats.export_schema_stats('F1', 'STATTAB');
    </copy>
    ```

    * You can also transfer database or table stats using `EXPORT_DATABASE_STATS` and `EXPORT_TABLE_STATS`;

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> exec dbms_stats.export_schema_stats('F1', 'STATTAB');
    
    PL/SQL procedure successfully completed.
    ```
    </details>
    
5. Now, you would normally move the staging table to the target database. Since the source and target databases are the same in this lab, we can skip this part. Otherwise, you can move the staging table with a regular Data Pump export/import.
    
    * If you perform the statistics export before you use Data Pump to export the entire schema, then the staging table is included in the dump file and there's no need for a separate export.

6. In this lab, you remapped the *F1* schema to *LAB5STATS*. `DBMS_STATS` does not support this remapping functionality. But you can get an idea of the process, by deleting schema stats on *F1* and importing the statistics from the staging table. Delete all statistics in the *F1* schema.

    ```
    <copy>
    exec dbms_stats.delete_schema_stats('F1');
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> exec dbms_stats.delete_schema_stats('F1');
    
    PL/SQL procedure successfully completed.
    ```
    </details>

7. Verify there are no statistics on the tables in the *F1* schema.

    ```
    <copy>
    set pagesize 100
    col table_name format a30
    select table_name, last_analyzed from dba_tab_statistics where owner='F1';
    </copy>

    -- Be sure to hit RETURN
    ```

    * The column `LAST_ANALYZED` is NULL indicating that there are no statistics.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    TABLE_NAME                     LAST_ANALYZED
    ------------------------------ ------------------
    F1_DRIVERS
    F1_LAPTIMES
    F1_CONSTRUCTORSTANDINGS
    F1_SPRINTRESULTS
    F1_STATUS
    F1_PITSTOPS
    F1_DRIVERSTANDINGS
    F1_CONSTRUCTORS
    F1_CIRCUITS
    F1_QUALIFYING
    F1_CONSTRUCTORRESULTS
    F1_RESULTS
    F1_RACES
    F1_SEASONS
    
    14 rows selected.    
    ```
    </details>    

8. Import the schema statistics from the staging table to the data dictionary. 

    ```
    <copy>
    exec dbms_stats.import_schema_stats('F1', 'STATTAB');
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> exec dbms_stats.import_schema_stats('F1', 'STATTAB');
    
    PL/SQL procedure successfully completed.
    ```
    </details>

9. Now there are statistics again on the tables in the *F1* schema.

    ```
    <copy>
    set pagesize 100
    col table_name format a30
    select table_name, last_analyzed from dba_tab_statistics where owner='F1';
    </copy>

    -- Be sure to hit RETURN
    ```

    * The column `LAST_ANALYZED` is NULL indicating that there are no statistics.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    TABLE_NAME                     LAST_ANALYZED
    ------------------------------ ------------------
    F1_CONSTRUCTORRESULTS          05-DEC-24
    F1_SEASONS                     05-DEC-24
    F1_RACES                       05-DEC-24
    F1_CIRCUITS                    05-DEC-24
    F1_CONSTRUCTORS                05-DEC-24
    F1_CONSTRUCTORSTANDINGS        05-DEC-24
    F1_SPRINTRESULTS               05-DEC-24
    F1_DRIVERSTANDINGS             05-DEC-24
    F1_STATUS                      05-DEC-24
    F1_RESULTS                     05-DEC-24
    F1_LAPTIMES                    05-DEC-24
    F1_PITSTOPS                    05-DEC-24
    F1_QUALIFYING                  05-DEC-24
    F1_DRIVERS                     05-DEC-24
    
    14 rows selected.    
    ```
    </details>  

10. That's how you transfer statistics from one database to another. Take the statistics out of the data dictionary and store them in a staging table. Now, move that staging table to the target database using Data Pump. Finally, move the statistics from the staging table and into the data dictionary in the target database.

## Task 4: Constraints
## Task 5: Indexes

You may now *proceed to the next lab*.

## Additional information

* Webinar, [Data Pump Best Practices and Real World Scenarios, LOB data and Data Pump and things to know](https://www.youtube.com/watch?v=960ToLE-ZE8&t=1798s)
* Webinar, [Data Pump Best Practices and Real World Scenarios, Statistics and Data Pump](https://www.youtube.com/watch?v=960ToLE-ZE8&t=1117s)

## Acknowledgments

* **Author** - Daniel Overby Hansen
* **Contributors** - Rodrigo Jorge, Mike Dietrich, Klaus Gronau, Alex Zaballa
* **Last Updated By/Date** - Daniel Overby Hansen, May 2025