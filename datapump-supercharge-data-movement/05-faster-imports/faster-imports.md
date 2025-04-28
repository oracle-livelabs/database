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

## Task 2: Statistics
## Task 3: Constraints
## Task 4: Indexes

You may now *proceed to the next lab*.

## Additional information

* Webinar, [Data Pump Best Practices and Real World Scenarios, LOB data and Data Pump and things to know](https://www.youtube.com/watch?v=960ToLE-ZE8&t=1798s)

## Acknowledgments

* **Author** - Daniel Overby Hansen
* **Contributors** - Rodrigo Jorge, Mike Dietrich, Klaus Gronau, Alex Zaballa
* **Last Updated By/Date** - Daniel Overby Hansen, May 2025