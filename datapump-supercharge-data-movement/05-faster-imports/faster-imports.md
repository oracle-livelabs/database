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

    * It takes 2-3 minutes to perform the import.
    * The table *BLOBLOAD.TAB1* contains a BasicFile LOB column.
    * The replacement for BasicFile LOB is SecureFile LOB. SecureFile LOB was introduced in Oracle Database 11g Release 1 in 2007. 
    * Since Oracle Database 12.1, Oracle has listed BasicFile LOB as deprecated. Yet, it is not uncommon to still find them around even today.
    * Notice how long it took to import the table. In the example in the instructions, it took 121 seconds.
    * Also, Data Pump used direct path to load the table.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    Import: Release 19.0.0.0.0 - Production on Mon Apr 28 08:40:43 2025
    Version 19.27.0.0.0
    
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
    Version 19.27.0.0.0
    
    Copyright (c) 1982, 2022, Oracle.  All rights reserved.
    
    
    Connected to:
    Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    Version 19.27.0.0.0
    
    SQL>
    User dropped.
    
    SQL> Disconnected from Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    Version 19.27.0.0.0
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
    * Loading data into a SecureFile LOB allows Data Pump to choose other load methods and use parallel query (PQ) processes.
    * Compare the time it took to import the table with the previous import. Importing into a SecureFile LOB is faster. In the example in the instructions, it went from 121 seconds to 80 seconds. 
    * Oracle recommends that you always convert BasicFile LOBs to SecureFile LOBs on import. It's faster and SecureFile LOBs offer superior functionality. 
    * It's safe to always add `TRANSFORM=LOB_STORAGE:SECUREFILE` to your parameter files. If a LOB is already a SecureFile, Data Pump ignores the transformation.
    
    <details>
    <summary>*click to see the output*</summary>
    ``` text
    Import: Release 19.0.0.0.0 - Production on Mon Apr 28 08:49:43 2025
    Version 19.27.0.0.0
    
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

7. Clean up.

    ```
    <copy>
    sqlplus / as sysdba<<EOF
       drop user blobload cascade;
    EOF
    </copy>

    -- Be sure to hit RETURN
    ```    

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
    reuse_dumpfiles=yes
    logfile=faster-import-stats-export.log
    metrics=yes
    logtime=all
    parallel=4
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
    Version 19.27.0.0.0
    
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
    Version 19.27.0.0.0
    
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

    * Using `DEGREE=AUTO_DEGREE` allows the database to gather statistics using parallel query. 
    * This uses more CPU but may speed it up significantly.

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

1. Still in the *yellow* terminal 🟨 and connected to the *FTEX* database. In this lab, the source and target databases are the same. Otherwise, you should have switched to the source database now. The source tables in the *F1* schema does have statistics. 

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

    * The date in `LAST_ANALYZED` indicates that there are statistics.

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

10. Clean up.

    ```
    <copy>
    exec dbms_stats.drop_stat_table('F1', 'STATTAB');
    </copy>
    ```

11. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```

11. That's how you transfer statistics from one database to another. Take the statistics out of the data dictionary and store them in a staging table. Now, move that staging table to the target database using Data Pump. Finally, move the statistics from the staging table and into the data dictionary in the target database.

## Task 4: Constraints

Constraints are used to enforce data quality and is often used extensively. A constraint is by default in *validated* state. This means that database guarantees that all data meets the constraint defintion. When Data Pump adds a validated constraint during import, the database full scans the table. You can save a lot of time by adding the constraint as *not validated*. Adding a not validated constraint is an instant data dictionary change and doesn't require a full scan. 

1. Use the *yellow* terminal 🟨. In the lab, you can find a dump file containing a schema with four tables. Each table has million rows and 23 constraints. Copy the dump file to the *DPDIR* directory.

    ```
    <copy>
    cp /home/oracle/scripts/faster-import-constraints.dmp /home/oracle/dpdir
    </copy>
    ```

2. Examine a pre-created parameter file.

    ```
    <copy>
    cat /home/oracle/scripts/dp-05-import-validate.par
    </copy>
    ```

    * This is a regular import.
    * Notice the `JOB_NAME` parameter. This gives the Data Pump a specific name, so you can easily attach to the Data Pump from a different session. The import will run for a while and you will attach to the job and monitor it.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    directory=dpdir
    dumpfile=faster-import-constraints.dmp
    parallel=4
    logfile=faster-import-constraints-import-validate.log
    logtime=all
    metrics=yes
    job_name=constr_validate
    ```
    </details> 

3. Start the import.

    ```
    <copy>
    . ftex
    impdp dpuser/oracle parfile=/home/oracle/scripts/dp-05-import-validate.par
    </copy>

    -- Be sure to hit RETURN
    ```

    * Don't wait for the import to complete.
    * Leave it running in the *yellow* terminal 🟨.
    * Move on with the next step.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    Import: Release 19.0.0.0.0 - Production on Wed Apr 30 17:09:10 2025
    Version 19.27.0.0.0
    
    Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.
    
    Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    30-APR-25 17:09:13.051: W-1 Startup took 1 seconds
    30-APR-25 17:09:13.779: W-1 Master table "DPUSER"."CONSTR_VALIDATE" successfully loaded/unloaded
    30-APR-25 17:09:13.892: Starting "DPUSER"."CONSTR_VALIDATE":  dpuser/******** parfile=/home/oracle/scripts/dp-05-import-valite.par
    30-APR-25 17:09:13.901: W-1 Processing object type SCHEMA_EXPORT/USER
    30-APR-25 17:09:13.974: W-1      Completed 1 USER objects in 0 seconds
    30-APR-25 17:09:13.974: W-1      Completed by worker 1 1 USER objects in 0 seconds
    30-APR-25 17:09:13.975: W-1 Processing object type SCHEMA_EXPORT/SYSTEM_GRANT
    30-APR-25 17:09:13.998: W-1      Completed 1 SYSTEM_GRANT objects in 0 seconds
    30-APR-25 17:09:13.998: W-1      Completed by worker 1 1 SYSTEM_GRANT objects in 0 seconds
    30-APR-25 17:09:13.999: W-1 Processing object type SCHEMA_EXPORT/ROLE_GRANT
    30-APR-25 17:09:14.021: W-1      Completed 1 ROLE_GRANT objects in 0 seconds
    30-APR-25 17:09:14.021: W-1      Completed by worker 1 1 ROLE_GRANT objects in 0 seconds
    30-APR-25 17:09:14.023: W-1 Processing object type SCHEMA_EXPORT/DEFAULT_ROLE
    30-APR-25 17:09:14.042: W-1      Completed 1 DEFAULT_ROLE objects in 0 seconds
    30-APR-25 17:09:14.042: W-1      Completed by worker 1 1 DEFAULT_ROLE objects in 0 seconds
    30-APR-25 17:09:14.043: W-1 Processing object type SCHEMA_EXPORT/PRE_SCHEMA/PROCACT_SCHEMA
    30-APR-25 17:09:14.137: W-1      Completed 1 PROCACT_SCHEMA objects in 0 seconds
    30-APR-25 17:09:14.137: W-1      Completed by worker 1 1 PROCACT_SCHEMA objects in 0 seconds
    30-APR-25 17:09:14.138: W-1 Processing object type SCHEMA_EXPORT/TABLE/TABLE
    30-APR-25 17:09:14.516: W-2 Startup took 0 seconds
    30-APR-25 17:09:14.530: W-3 Startup took 0 seconds
    30-APR-25 17:09:14.533: W-4 Startup took 0 seconds
    30-APR-25 17:09:14.613: W-3      Completed 4 TABLE objects in 0 seconds
    30-APR-25 17:09:14.613: W-3      Completed by worker 1 3 TABLE objects in 0 seconds
    30-APR-25 17:09:14.613: W-3      Completed by worker 2 1 TABLE objects in 0 seconds
    30-APR-25 17:09:14.624: W-4 Processing object type SCHEMA_EXPORT/TABLE/TABLE_DATA
    ```
    </details> 


4. Now, switch to the *blue* 🟦 terminal. Attach another Data Pump session to the running job.

    ```
    <copy>
    . ftex
    impdp dpuser/oracle attach=CONSTR_VALIDATE
    </copy>

    -- Be sure to hit RETURN
    ```

    * Notice the `ATTACH` parameter which contains the job name that you specified in the import parameter file.
    * You're now in the *interactive console*.
    * It's a separate session but connected to the running import in the *yellow* terminal 🟨.
    * Scroll through the output and familiarize yourself with the information.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    Import: Release 19.0.0.0.0 - Production on Wed Apr 30 17:09:21 2025
    Version 19.27.0.0.0
    
    Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.
    
    Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    
    Job: CONSTR_VALIDATE
      Owner: DPUSER
      Operation: IMPORT
      Creator Privs: TRUE
      GUID: 3402F9CFC76C4E47E063A601000A9500
      Start Time: Wednesday, 30 April, 2025 17:09:12
      Mode: FULL
      Instance: FTEX
      Max Parallelism: 4
      Timezone: +00:00
      Timezone version: 44
      Endianness: LITTLE
      NLS character set: AL32UTF8
      NLS NCHAR character set: AL16UTF16
      EXPORT Job Parameters:
      Parameter Name      Parameter Value:
         CLIENT_COMMAND        dpuser/******** schemas=constr_validate compression=all directory=dpdir dumpfile=faster-import-constraints.dmp exclude=statistics reuse_dumpfiles=yes     logfile=faster-import-constraints-export.log logtime=all metrics=yes
         COMPRESSION           ALL
         LOGTIME               ALL
         METRICS               1
         TRACE                 0
      IMPORT Job Parameters:
      Parameter Name      Parameter Value:
         CLIENT_COMMAND        dpuser/******** parfile=/home/oracle/scripts/dp-05-import-valite.par
         LOGTIME               ALL
         METRICS               1
         TRACE                 0
      State: EXECUTING
      Bytes Processed: 0
      Current Parallelism: 4
      Job Error Count: 0
      Job heartbeat: 1
      Dump File: /home/oracle/dpdir/faster-import-constraints.dmp
    
    Worker 1 Status:
      Instance ID: 1
      Instance name: FTEX
      Host name: holserv1.livelabs.oraclevcn.com
      Object start time: Wednesday, 30 April, 2025 17:09:14
      Object status at: Wednesday, 30 April, 2025 17:09:14
      Process Name: DW00
      State: EXECUTING
      Object Schema: CONSTR_VALIDATE
      Object Name: T1
      Object Type: SCHEMA_EXPORT/TABLE/TABLE_DATA
      Completed Objects: 1
      Completed Bytes: 400,185,632
      Worker Parallelism: 1
    
    Worker 2 Status:
      Instance ID: 1
      Instance name: FTEX
      Host name: holserv1.livelabs.oraclevcn.com
      Object start time: Wednesday, 30 April, 2025 17:09:14
      Object status at: Wednesday, 30 April, 2025 17:09:14
      Process Name: DW01
      State: EXECUTING
      Object Schema: CONSTR_VALIDATE
      Object Name: T2
      Object Type: SCHEMA_EXPORT/TABLE/TABLE_DATA
      Completed Objects: 1
      Completed Bytes: 400,257,480
      Worker Parallelism: 1
    
    Worker 3 Status:
      Instance ID: 1
      Instance name: FTEX
      Host name: holserv1.livelabs.oraclevcn.com
      Object start time: Wednesday, 30 April, 2025 17:09:14
      Object status at: Wednesday, 30 April, 2025 17:09:14
      Process Name: DW02
      State: EXECUTING
      Object Schema: CONSTR_VALIDATE
      Object Name: T3
      Object Type: SCHEMA_EXPORT/TABLE/TABLE_DATA
      Completed Objects: 1
      Completed Bytes: 400,199,144
      Worker Parallelism: 1
    
    Worker 4 Status:
      Instance ID: 1
      Instance name: FTEX
      Host name: holserv1.livelabs.oraclevcn.com
      Object start time: Wednesday, 30 April, 2025 17:09:14
      Object status at: Wednesday, 30 April, 2025 17:09:14
      Process Name: DW03
      State: EXECUTING
      Object Schema: CONSTR_VALIDATE
      Object Name: T4
      Object Type: SCHEMA_EXPORT/TABLE/TABLE_DATA
      Completed Objects: 1
      Completed Bytes: 400,209,328
      Worker Parallelism: 1
    
    Import>    
    ```
    </details> 

5. Get a list of commands.

    ```
    <copy>
    help
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    ------------------------------------------------------------------------------
    
    The following commands are valid while in interactive mode.
    Note: abbreviations are allowed.
    
    CONTINUE_CLIENT
    Return to logging mode. Job will be restarted if idle.
    
    EXIT_CLIENT
    Quit client session and leave job running.
    
    HELP
    Summarize interactive commands.
    
    KILL_JOB
    Detach and delete job.
    
    PARALLEL
    Change the number of active workers for current job.
    
    START_JOB
    Start or resume current job.
    Valid keywords are: SKIP_CURRENT.
    
    STATUS
    Frequency (secs) job status is to be monitored where
    the default [0] will show new status when available.
    
    STOP_JOB
    Orderly shutdown of job execution and exits the client.
    Valid keywords are: IMMEDIATE.
    
    STOP_WORKER
    Stops a hung or stuck worker.
    
    TRACE
    Set trace/debug flags for the current job.    
    ```
    </details> 

6. Get a status of the running job.

    ```
    <copy>
    status
    </copy>
    ```

    * Notice that each worker is processing a different table. 
    * Repeat the `STATUS` command a few times and notice *Completed Rows* increasing.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    Job: CONSTR_VALIDATE
      Operation: IMPORT
      Mode: FULL
      State: EXECUTING
      Bytes Processed: 0
      Current Parallelism: 4
      Job Error Count: 0
      Job heartbeat: 2
      Dump File: /home/oracle/dpdir/faster-import-constraints.dmp
    
    Worker 1 Status:
      Instance ID: 1
      Instance name: FTEX
      Host name: holserv1.livelabs.oraclevcn.com
      Object start time: Wednesday, 30 April, 2025 17:09:14
      Object status at: Wednesday, 30 April, 2025 17:09:14
      Process Name: DW00
      State: EXECUTING
      Object Schema: CONSTR_VALIDATE
      Object Name: T1
      Object Type: SCHEMA_EXPORT/TABLE/TABLE_DATA
      Completed Objects: 1
      Completed Rows: 3,981,428
      Completed Bytes: 400,185,632
      Percent Done: 17
      Worker Parallelism: 1
    
    Worker 2 Status:
      Instance ID: 1
      Instance name: FTEX
      Host name: holserv1.livelabs.oraclevcn.com
      Object start time: Wednesday, 30 April, 2025 17:09:14
      Object status at: Wednesday, 30 April, 2025 17:09:14
      Process Name: DW01
      State: EXECUTING
      Object Schema: CONSTR_VALIDATE
      Object Name: T2
      Object Type: SCHEMA_EXPORT/TABLE/TABLE_DATA
      Completed Objects: 1
      Completed Rows: 3,981,425
      Completed Bytes: 400,257,480
      Percent Done: 17
      Worker Parallelism: 1
    
    Worker 3 Status:
      Instance ID: 1
      Instance name: FTEX
      Host name: holserv1.livelabs.oraclevcn.com
      Object start time: Wednesday, 30 April, 2025 17:09:14
      Object status at: Wednesday, 30 April, 2025 17:09:14
      Process Name: DW02
      State: EXECUTING
      Object Schema: CONSTR_VALIDATE
      Object Name: T3
      Object Type: SCHEMA_EXPORT/TABLE/TABLE_DATA
      Completed Objects: 1
      Completed Rows: 3,982,197
      Completed Bytes: 400,199,144
      Percent Done: 17
      Worker Parallelism: 1
    
    Worker 4 Status:
      Instance ID: 1
      Instance name: FTEX
      Host name: holserv1.livelabs.oraclevcn.com
      Object start time: Wednesday, 30 April, 2025 17:09:14
      Object status at: Wednesday, 30 April, 2025 17:09:14
      Process Name: DW03
      State: EXECUTING
      Object Schema: CONSTR_VALIDATE
      Object Name: T4
      Object Type: SCHEMA_EXPORT/TABLE/TABLE_DATA
      Completed Objects: 1
      Completed Rows: 3,982,202
      Completed Bytes: 400,209,328
      Percent Done: 17
      Worker Parallelism: 1    
    ```
    </details> 

7. Increase the parallel degree to six.

    ```
    <copy>
    parallel=6
    </copy>
    ```

8. Use the `STATUS` command see how many workers are active. 
    
    ```
    <copy>
    status
    </copy>
    ```

    * There are still only four active workers, even though you raised the parallel degree.
    * Spend a moment to think about the reason.

    <details>
    <summary>*click to see the answer*</summary>
    ``` text
    In the dump file there are only four tables. Each of the four original workers are busy working on the tables. One table is only processed by one worker, so the extra two workers wouldn't make a difference. So, Data Pump doesn't use the resources to start them.
    Had there been more tables, the workers would immediately be started and assigned to a table.
    ```
    </details> 

9. Switch back to the *yellow* terminal 🟨. Data Pump should be processing `SCHEMA_EXPORT/TABLE/TABLE_DATA`. That's import of rows and you just saw how the `STATUS` command could give more detailed information.

10. In this exercise, the job name is *CONSTR\_VALIDATE*. You used the parameter `JOB_NAME` to set it. See if you can find the name in the Data Pump output.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    30-APR-25 17:09:13.779: W-1 Master table "DPUSER"."CONSTR_VALIDATE" successfully loaded/unloaded
    30-APR-25 17:09:13.892: Starting "DPUSER"."CONSTR_VALIDATE":  dpuser/******** parfile=/home/oracle/scripts/dp-05-import-valite.par
    ```
    </details> 

    * If you don't give a job a specific name, Data Pump generates one for you.
    * You can still attach to the job from a different session.

11. After a while Data Pump is done processing rows. It will move on to process constraints. This happens in `SCHEMA_EXPORT/TABLE/CONSTRAINT/CONSTRAINT`. 

    * If your job is not there yet, then wait a little while. 
    * Alternative, move to the *blue* 🟦 terminal and use the `STATUS` command. There are around 23 million rows to load.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    30-APR-25 17:09:14.624: W-4 Processing object type SCHEMA_EXPORT/TABLE/TABLE_DATA
    30-APR-25 17:13:47.914: W-4 . . imported "CONSTR_VALIDATE"."T4"                      381.6 MB 23312384 rows in 273 seconds using direct_path
    30-APR-25 17:13:51.251: W-1 . . imported "CONSTR_VALIDATE"."T1"                      381.6 MB 23312384 rows in 277 seconds using direct_path
    30-APR-25 17:13:51.313: W-2 . . imported "CONSTR_VALIDATE"."T2"                      381.7 MB 23312384 rows in 276 seconds using direct_path
    30-APR-25 17:13:51.453: W-3 . . imported "CONSTR_VALIDATE"."T3"                      381.6 MB 23312384 rows in 277 seconds using direct_path
    30-APR-25 17:13:51.466: W-1 Processing object type SCHEMA_EXPORT/TABLE/CONSTRAINT/CONSTRAINT
    ```
    </details>    

12. When Data Pump is processing constraints (`SCHEMA_EXPORT/TABLE/CONSTRAINT/CONSTRAINT`) switch to the *blue* 🟦 terminal.

13. Get a new status.

    ```
    <copy>
    status
    </copy>
    ```

    * When Data Pump processes constraints the work is done by only one worker. 
    * All other workers are idle. Their state is *WORK WAITING*. 
    * When Data Pump adds a constraint, the database will perform a full scan to ensure the column has no bad data. This full scan can't use parallel query.
    * So, one worker is processing constraints and each constraint uses no parallel query.
    * This is the reason why it might take very long to add constraints.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    Import> status
    
    Job: CONSTR_VALIDATE
      Operation: IMPORT
      Mode: FULL
      State: EXECUTING
      Bytes Processed: 1,600,851,584
      Percent Done: 14
      Current Parallelism: 6
      Job Error Count: 0
      Job heartbeat: 2
      Dump File: /home/oracle/dpdir/faster-import-constraints.dmp
    
    Worker 1 Status:
      Instance ID: 1
      Instance name: FTEX
      Host name: holserv1.livelabs.oraclevcn.com
      Access method: direct_path
      Object start time: Wednesday, 30 April, 2025 17:13:51
      Object status at: Wednesday, 30 April, 2025 17:13:51
      Process Name: DW00
      State: WORK WAITING
    
    Worker 2 Status:
      Instance ID: 1
      Instance name: FTEX
      Host name: holserv1.livelabs.oraclevcn.com
      Object start time: Wednesday, 30 April, 2025 17:13:51
      Object status at: Wednesday, 30 April, 2025 17:13:51
      Process Name: DW01
      State: EXECUTING
      Object Schema: CONSTR_VALIDATE
      Object Name: C_TAB1_C01
      Object Type: SCHEMA_EXPORT/TABLE/CONSTRAINT/CONSTRAINT
      Worker Parallelism: 1
    
    Worker 3 Status:
      Instance ID: 1
      Instance name: FTEX
      Host name: holserv1.livelabs.oraclevcn.com
      Access method: direct_path
      Object start time: Wednesday, 30 April, 2025 17:13:51
      Object status at: Wednesday, 30 April, 2025 17:13:51
      Process Name: DW02
      State: WORK WAITING
    
    Worker 4 Status:
      Instance ID: 1
      Instance name: FTEX
      Host name: holserv1.livelabs.oraclevcn.com
      Access method: direct_path
      Object start time: Wednesday, 30 April, 2025 17:13:47
      Object status at: Wednesday, 30 April, 2025 17:13:51
      Process Name: DW03
      State: WORK WAITING    
    ```
    </details> 

14. Exit from the interactive console. 

    ```
    <copy>
    exit
    </copy>
    ```
    
15. Switch back to the *yellow* terminal 🟨. It usually takes a few minutes to add the constraints. Wait for the job to complete.

    * It took almost 5 minutes to import the table data.
    * In addition, it took 3 three minutes to add constraints.
    * If you move bigger data sets with more constraints, it can take hours to add the constraints.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    Import: Release 19.0.0.0.0 - Production on Wed Apr 30 17:09:10 2025
    Version 19.27.0.0.0
    
    Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.
    
    Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    30-APR-25 17:09:13.051: W-1 Startup took 1 seconds
    30-APR-25 17:09:13.779: W-1 Master table "DPUSER"."CONSTR_VALIDATE" successfully loaded/unloaded
    30-APR-25 17:09:13.892: Starting "DPUSER"."CONSTR_VALIDATE":  dpuser/******** parfile=/home/oracle/scripts/dp-05-import-valite.par
    30-APR-25 17:09:13.901: W-1 Processing object type SCHEMA_EXPORT/USER
    30-APR-25 17:09:13.974: W-1      Completed 1 USER objects in 0 seconds
    30-APR-25 17:09:13.974: W-1      Completed by worker 1 1 USER objects in 0 seconds
    30-APR-25 17:09:13.975: W-1 Processing object type SCHEMA_EXPORT/SYSTEM_GRANT
    30-APR-25 17:09:13.998: W-1      Completed 1 SYSTEM_GRANT objects in 0 seconds
    30-APR-25 17:09:13.998: W-1      Completed by worker 1 1 SYSTEM_GRANT objects in 0 seconds
    30-APR-25 17:09:13.999: W-1 Processing object type SCHEMA_EXPORT/ROLE_GRANT
    30-APR-25 17:09:14.021: W-1      Completed 1 ROLE_GRANT objects in 0 seconds
    30-APR-25 17:09:14.021: W-1      Completed by worker 1 1 ROLE_GRANT objects in 0 seconds
    30-APR-25 17:09:14.023: W-1 Processing object type SCHEMA_EXPORT/DEFAULT_ROLE
    30-APR-25 17:09:14.042: W-1      Completed 1 DEFAULT_ROLE objects in 0 seconds
    30-APR-25 17:09:14.042: W-1      Completed by worker 1 1 DEFAULT_ROLE objects in 0 seconds
    30-APR-25 17:09:14.043: W-1 Processing object type SCHEMA_EXPORT/PRE_SCHEMA/PROCACT_SCHEMA
    30-APR-25 17:09:14.137: W-1      Completed 1 PROCACT_SCHEMA objects in 0 seconds
    30-APR-25 17:09:14.137: W-1      Completed by worker 1 1 PROCACT_SCHEMA objects in 0 seconds
    30-APR-25 17:09:14.138: W-1 Processing object type SCHEMA_EXPORT/TABLE/TABLE
    30-APR-25 17:09:14.516: W-2 Startup took 0 seconds
    30-APR-25 17:09:14.530: W-3 Startup took 0 seconds
    30-APR-25 17:09:14.533: W-4 Startup took 0 seconds
    30-APR-25 17:09:14.613: W-3      Completed 4 TABLE objects in 0 seconds
    30-APR-25 17:09:14.613: W-3      Completed by worker 1 3 TABLE objects in 0 seconds
    30-APR-25 17:09:14.613: W-3      Completed by worker 2 1 TABLE objects in 0 seconds
    30-APR-25 17:09:14.624: W-4 Processing object type SCHEMA_EXPORT/TABLE/TABLE_DATA
    30-APR-25 17:13:47.914: W-4 . . imported "CONSTR_VALIDATE"."T4"                      381.6 MB 23312384 rows in 273 seconds using direct_path
    30-APR-25 17:13:51.251: W-1 . . imported "CONSTR_VALIDATE"."T1"                      381.6 MB 23312384 rows in 277 seconds using direct_path
    30-APR-25 17:13:51.313: W-2 . . imported "CONSTR_VALIDATE"."T2"                      381.7 MB 23312384 rows in 276 seconds using direct_path
    30-APR-25 17:13:51.453: W-3 . . imported "CONSTR_VALIDATE"."T3"                      381.6 MB 23312384 rows in 277 seconds using direct_path
    30-APR-25 17:13:51.466: W-1 Processing object type SCHEMA_EXPORT/TABLE/CONSTRAINT/CONSTRAINT
    30-APR-25 17:16:35.025: W-3      Completed 92 CONSTRAINT objects in 164 seconds
    30-APR-25 17:16:35.025: W-3      Completed by worker 2 92 CONSTRAINT objects in 164 seconds
    30-APR-25 17:16:35.035: W-4      Completed 4 SCHEMA_EXPORT/TABLE/TABLE_DATA objects in 277 seconds
    30-APR-25 17:16:35.071: Job "DPUSER"."CONSTR_VALIDATE" successfully completed at Wed Apr 30 17:16:35 2025 elapsed 0 00:07:23    
    ```
    </details> 

16. There is a Data Pump transformation that allows you to add the constraints as *NOT VALIDATED* instead of *VALIDATED*. This can reduce the time it takes to add constraints from minutes or hours to just seconds. Examine a pre-created parameter file.

    ```
    <copy>
    cat /home/oracle/scripts/dp-05-import-novalidate.par
    </copy>
    ```

    * You allow Data Pump to transform constraints using the parameter `TRANSFORM=CONSTRAINT_NOVALIDATE:Y`.
    * This feature requires 19.27 or higher including the Data Pump Bundle Patch.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    directory=dpdir
    dumpfile=faster-import-constraints.dmp
    parallel=4
    logfile=faster-import-constraints-import-novalidate.log
    logtime=all
    metrics=yes
    job_name=constr_novalidate
    transform=constraint_novalidate:y
    ```
    </details> 

17. Drop the schema, so you can import again.

    ```
    <copy>
    . ftex
    sqlplus / as sysdba<<EOF
       drop user constr_validate cascade;
    EOF
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL*Plus: Release 19.0.0.0.0 - Production on Wed Apr 30 17:54:12 2025
    Version 19.27.0.0.0
    
    Copyright (c) 1982, 2024, Oracle.  All rights reserved.
    
    
    Connected to:
    Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    Version 19.27.0.0.0
    
    SQL>
    User dropped.
    
    SQL> Disconnected from Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    Version 19.27.0.0.0
    ```
    </details> 

18. Start the import and allow Data Pump to add the constraints as not validated.

    ```
    <copy>
    impdp dpuser/oracle parfile=/home/oracle/scripts/dp-05-import-novalidate.par
    </copy>
    ```

    * As soon as the job starts, move on with the next step.
    * Don't wait for the job to finish.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    Import: Release 19.0.0.0.0 - Production on Wed Apr 30 18:08:33 2025
    Version 19.27.0.0.0
    
    Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.
    
    Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    30-APR-25 18:08:35.330: W-1 Startup took 0 seconds
    30-APR-25 18:08:35.975: W-1 Master table "DPUSER"."CONSTR_NOVALIDATE" successfully loaded/unloaded
    30-APR-25 18:08:36.053: Starting "DPUSER"."CONSTR_NOVALIDATE":  dpuser/******** parfile=/home/oracle/scripts/dp-05-import-novalidate.par
    30-APR-25 18:08:36.064: W-1 Processing object type SCHEMA_EXPORT/USER
    30-APR-25 18:08:36.138: W-1      Completed 1 USER objects in 0 seconds
    30-APR-25 18:08:36.138: W-1      Completed by worker 1 1 USER objects in 0 seconds
    30-APR-25 18:08:36.140: W-1 Processing object type SCHEMA_EXPORT/SYSTEM_GRANT
    30-APR-25 18:08:36.165: W-1      Completed 1 SYSTEM_GRANT objects in 0 seconds
    30-APR-25 18:08:36.165: W-1      Completed by worker 1 1 SYSTEM_GRANT objects in 0 seconds
    30-APR-25 18:08:36.166: W-1 Processing object type SCHEMA_EXPORT/ROLE_GRANT
    30-APR-25 18:08:36.189: W-1      Completed 1 ROLE_GRANT objects in 0 seconds
    30-APR-25 18:08:36.189: W-1      Completed by worker 1 1 ROLE_GRANT objects in 0 seconds
    30-APR-25 18:08:36.190: W-1 Processing object type SCHEMA_EXPORT/DEFAULT_ROLE
    30-APR-25 18:08:36.210: W-1      Completed 1 DEFAULT_ROLE objects in 0 seconds
    30-APR-25 18:08:36.210: W-1      Completed by worker 1 1 DEFAULT_ROLE objects in 0 seconds
    30-APR-25 18:08:36.212: W-1 Processing object type SCHEMA_EXPORT/PRE_SCHEMA/PROCACT_SCHEMA
    30-APR-25 18:08:36.303: W-1      Completed 1 PROCACT_SCHEMA objects in 0 seconds
    30-APR-25 18:08:36.303: W-1      Completed by worker 1 1 PROCACT_SCHEMA objects in 0 seconds
    30-APR-25 18:08:36.304: W-1 Processing object type SCHEMA_EXPORT/TABLE/TABLE
    30-APR-25 18:08:36.672: W-2 Startup took 0 seconds
    30-APR-25 18:08:36.702: W-3 Startup took 0 seconds
    30-APR-25 18:08:36.710: W-4 Startup took 0 seconds
    30-APR-25 18:08:36.767: W-1      Completed 4 TABLE objects in 0 seconds
    30-APR-25 18:08:36.767: W-1      Completed by worker 1 3 TABLE objects in 0 seconds
    30-APR-25 18:08:36.767: W-1      Completed by worker 2 1 TABLE objects in 0 seconds
    30-APR-25 18:08:36.778: W-3 Processing object type SCHEMA_EXPORT/TABLE/TABLE_DATA    
    ```
    </details> 

19. Switch to the *blue* 🟦 terminal.

20. Connect to the *FTEX* database. 

    ```
    <copy>
    . ftex
    sqlplus / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

21. Get a list of running jobs.

    ```
    <copy>
    col operation format a20
    col job_mode format a20
    col state format a20
    select operation, job_mode, state, degree from dba_datapump_jobs where owner_name='DPUSER';
    </copy>

    -- Be sure to hit RETURN
    ```

    * Job mode is listed as full even though you had a schema export. In the parameter file for the import, you didn't specify anything and that starts a full export. Since is in fact just a schema import because that's what you have in the dump file.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    OPERATION            JOB_MODE             STATE                DEGREE
    -------------------- -------------------- -------------------- ----------
    IMPORT               FULL                 EXECUTING            4    
    
    1 row selected.
    ```
    </details> 

22. Get a list of Data Pump sessions.

    ```
    <copy>
    select inst_id, saddr, session_type from dba_datapump_sessions;
    </copy>
    ```

    * You started the job with parallel degree 4. 
    * Data Pump starts the control process that is listed as *MASTER*. In addition, there are four worker processes. Finally, a process for `DBMS_DATAPUMP` which you will learn about in a later lab.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    INST_ID    SADDR            SESSION_TYPE
    ---------- ---------------- --------------
    1          000000006F701888 DBMS_DATAPUMP
    1          000000006F333B68 MASTER
    1          000000006EC9C728 WORKER
    1          000000006ED37350 WORKER
    1          000000006EDC0820 WORKER
    1          000000006F5C7068 WORKER
    
    6 rows selected.    
    ```
    </details> 

23. Get a list of long running operations.

    ```
    <copy>
    set line 100
    col opname format a18
    col target_desc format a12
    col message format a50
    select opname, target_desc, message, sql_id from  v$session_longops
    where sofar != totalwork;
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    OPNAME             TARGET_DESC  MESSAGE                                            SQL_ID
    ------------------ ------------ -------------------------------------------------- -------------
    CONSTR_NOVALIDATE  IMPORT       CONSTR_NOVALIDATE: IMPORT : 0 out of 10227 MB done bn21aqz1pgytj

    1 row selected.
    ```
    </details>

24. Compare the level of information you could retrieve from the `STATUS` command in the interactiven console with that of the Data Pump views. The `STATUS` command offers much greater detail but requires a Data Pump session connected to the interactive console. Other sources of information is the `DBMS_DATAPUMP` package which has a `GET_STATUS` function. Finally, you can query the control table directly. However, the control table format is not documented and not meant for public use.

24. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```

25. Switch back to the *yellow* terminal 🟨. Wait for the Data Pump job to complete. 

    * It takes 5-6 minutes for the Data Pump job to complete.
    * Optionally, switch to the *blue* 🟦 terminal. Try to attach to the job and monitor it using the `STATUS` command.

    <details>
    <summary>*click to see the command*</summary>
    ``` text
    impdp dpuser/oracle attach=CONSTR_NOVALIDATE
    ```
    </details>     

26. When the jobs complete. Check the time it took to add constraints.

    * Look for the object type `SCHEMA_EXPORT/TABLE/CONSTRAINT/CONSTRAINT`.
    * It took 0 seconds to add all 92 constraints. 
    * Because Data Pump adds the constraints as *not validated*, the database just write the constraint defintion to the data dictionary. It does not check the table.
    * The constraints, however, are *enabled*. Even though the loaded lines were *not validated*, any new row will be enforced against the existing constraints rules.
    * In the previous import, when Data Pump added *validated* constraints, the same operation took 162 seconds.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    30-APR-25 18:13:10.621: W-1 Processing object type SCHEMA_EXPORT/TABLE/CONSTRAINT/CONSTRAINT
    30-APR-25 18:13:10.921: W-2      Completed 92 CONSTRAINT objects in 0 seconds
    30-APR-25 18:13:10.921: W-2      Completed by worker 4 92 CONSTRAINT objects in 0 seconds
    ```
    </details> 

27. It is preferable to have validated constraints. A validated constraint allows the optimizer to perform certain query optimizations. 

28. Connect to the *FTEX* database.

    ```
    <copy>
    . ftex
    sqlplus / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

29. Check the state of all the constraints.

    ```
    <copy>
    col table_name format a30
    select   table_name, validated, count(*) 
    from     all_constraints 
    where    owner='CONSTR_VALIDATE' 
    group by table_name, validated;
    </copy>

    -- Be sure to hit RETURN
    ```

    * As expected, all constraints are not validated.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    TABLE_NAME                     VALIDATED       COUNT(*)
    ------------------------------ ------------- ----------
    T4                             NOT VALIDATED         23
    T1                             NOT VALIDATED         23
    T2                             NOT VALIDATED         23
    T3                             NOT VALIDATED         23
    ```
    </details> 

30. Validate some of the constraints.

    ```
    <copy>
    set timing on
    alter table constr_validate.t1 modify constraint C_TAB1_C10 validate;
    alter table constr_validate.t1 modify constraint C_TAB1_C11 validate;
    alter table constr_validate.t1 modify constraint C_TAB1_C12 validate;
    alter table constr_validate.t1 modify constraint C_TAB1_C13 validate;
    alter table constr_validate.t1 modify constraint C_TAB1_C14 validate;
    </copy>

    -- Be sure to hit RETURN
    ```

    * It takes around two seconds to validate each of the constraints. 
    * The table is probably already in the buffer cache, but it still requires a full scan.
    * Validating an already enabled constraint does *not* require a table lock, so you can perform this operation without any outage.
    * The validation recursively runs a full table scan, that requires resources, but it's important to stress that there's no table lock.

    <details>
    <summary>*click to see the output*</summary>
    ``` text   
    SQL> alter table constr_validate.t1 modify constraint C_TAB1_C10 validate;
        
    Table altered.
    
    Elapsed: 00:00:01.90
    
    SQL> alter table constr_validate.t1 modify constraint C_TAB1_C11 validate;
        
    Table altered.
    
    Elapsed: 00:00:01.97
    
    SQL> alter table constr_validate.t1 modify constraint C_TAB1_C12 validate;

    Table altered.
    
    Elapsed: 00:00:02.12
    
    SQL> alter table constr_validate.t1 modify constraint C_TAB1_C13 validate;

    Table altered.
    
    Elapsed: 00:00:02.13

    SQL> alter table constr_validate.t1 modify constraint C_TAB1_C14 validate;
    
    Table altered.
    
    Elapsed: 00:00:01.74
    ```
    </details> 

31. When validating an already enabled constraint, you can take advantage of parallel query and do the validation much faster. Validate some more constraints.

    ```
    <copy>
    set timing on
    alter table constr_validate.t1 parallel;
    alter table constr_validate.t1 modify constraint C_TAB1_C15 validate;
    alter table constr_validate.t1 modify constraint C_TAB1_C16 validate;
    alter table constr_validate.t1 modify constraint C_TAB1_C17 validate;
    alter table constr_validate.t1 modify constraint C_TAB1_C18 validate;
    alter table constr_validate.t1 modify constraint C_TAB1_C19 validate;
    alter table constr_validate.t1 noparallel;
    </copy>

    -- Be sure to hit RETURN
    ```

    * Notice the `ALTER TABLE ... PARALLEL` command that changes the default parallel degree of the table.
    * It takes less time to perform the validation because the database can use parallel query to full scan the table.
    * Still it does *not* require a table lock.
    * Don't forget to reset the default parallel degree using `ALTER TABLE ... NOPARALLEL`. Leaving a table with a default parallel degree causes all queries to utilize parallel query which can exhaust the server.

    <details>
    <summary>*click to see the output*</summary>
    ``` text   
    SQL> alter table constr_validate.t1 parallel;
        
    Table altered.
    
    Elapsed: 00:00:00.01
    
    SQL> alter table constr_validate.t1 modify constraint C_TAB1_C15 validate;
        
    Table altered.
    
    Elapsed: 00:00:00.20
    
    SQL> alter table constr_validate.t1 modify constraint C_TAB1_C16 validate;
        
    Table altered.
    
    Elapsed: 00:00:00.22
    
    SQL> alter table constr_validate.t1 modify constraint C_TAB1_C17 validate;

    Table altered.
    
    Elapsed: 00:00:00.16
    
    SQL> alter table constr_validate.t1 modify constraint C_TAB1_C18 validate;

    Table altered.
    
    Elapsed: 00:00:00.17

    SQL> alter table constr_validate.t1 modify constraint C_TAB1_C19 validate;
    
    Table altered.
    
    Elapsed: 00:00:00.19

    SQL> alter table constr_validate.t1 noparallel;
        
    Table altered.
    
    Elapsed: 00:00:00.01
    ```
    </details> 

32. Clean up.

    ```
    <copy>
    drop user constr_validate cascade;
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> drop user constr_validate cascade;

    User dropped.
    ```
    </details> 

33. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```

34. Transforming validated constraints to not validated constraints is potentially a huge time saver. It is still adversible to validate the constraints, but you can do that after the Data Pump import while you are doing other tasks. You can even postpone the validation to a later maintenance window. You might even do it online, as it requires no table lock. 

You may now *proceed to the next lab*.

## Additional information

* Webinar, [Data Pump Best Practices and Real World Scenarios, LOB data and Data Pump and things to know](https://www.youtube.com/watch?v=960ToLE-ZE8&t=1798s)
* Webinar, [Data Pump Best Practices and Real World Scenarios, Statistics and Data Pump](https://www.youtube.com/watch?v=960ToLE-ZE8&t=1117s)
* [Speeding up Database Constraints](https://www.youtube.com/watch?v=lgFc0cduPJk&t=299s)

## Acknowledgments

* **Author** - Daniel Overby Hansen
* **Contributors** - William Beauregard, Rodrigo Jorge, Mike Dietrich, Klaus Gronau, Alex Zaballa
* **Last Updated By/Date** - Daniel Overby Hansen, May 2025