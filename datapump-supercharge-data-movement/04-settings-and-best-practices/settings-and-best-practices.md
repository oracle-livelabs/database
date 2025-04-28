# Best Practices and Other Settings

## Introduction

In this lab, you will see some best practices that will help you get the more out of Data Pump. In addition, you will use some of the settings in Data Pump.

Estimated Time: 10 Minutes

### Objectives

In this lab, you will:

* Apply best practices
* Use different settings

### Prerequisites

This lab assumes:

- You have completed Lab 3: Getting Started

## Task 1: Best Practices

Applying these practices will help you get more out of Data Pump and avoid some of the common mistakes. You will enhance the parameter file that you used in the previous lab.

1. Use the *yellow* terminal 🟨. Set the environment to *FTEX* and check for the Data Pump Bundle Patch.

    ```
    <copy>
    . ftex
    $ORACLE_HOME/OPatch/opatch lspatches
    </copy>

    -- Be sure to hit RETURN
    ```

    * You should be able to see a patch named *DATAPUMP BUNDLE PATCH*.
    * The Data Pump fixes usually don't come into a Release Update, but there is a bundle patch with most Data Pump fixes.
    * The Data Pump Bundle Patch contains not only a lot of functionality fixes, but also several performance fixes.
    * Oracle strongly recommends that you apply the bundle patch when working with Data Pump.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ . ftex
    $ $ORACLE_HOME/OPatch/opatch lspatches
    35648110;OJVM RELEASE UPDATE: 19.21.0.0.231017 (35648110)
    35787077;DATAPUMP BUNDLE PATCH 19.21.0.0.0
    35643107;Database Release Update : 19.21.0.0.231017 (35643107)
    29585399;OCW RELEASE UPDATE 19.3.0.0.0 (29585399)
    
    OPatch succeeded.
    ```
    </details> 

2. Add diagnostic information to the log file using the `METRICS` and `LOGTIME` parameters. Check the pre-created parameter file.

    ```
    <copy>
    cat /home/oracle/scripts/dp-04-bp-1.par
    </copy>
    ```

    * By adding `METRICS` and `LOGTIME` to your parameter file, the log file contains much more information.
    * This will help you troubleshoot issues and get a better understanding of what happens during a job.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ cat /home/oracle/scripts/dp-04-bp-1.par
    schemas=f1
    directory=dpdir
    dumpfile=f1.dmp
    logfile=f1-export.log
    metrics=yes
    logtime=all
    ```
    </details> 

3. Limit the file size and allow Data Pump to create multiple dump files.

    ```
    <copy>
    cat /home/oracle/scripts/dp-04-bp-2.par
    </copy>
    ```

    * The `DUMPFILE` parameter now contains `%L`. Data Pump now creates multiple dump files (when needed) and generates unique file names. In earlier versions of Data Pump, you would use *%U* instead.
    * Allowing Data Pump to create multiple files is essential to maximize the throughput of parallel exports.
    * `FILESIZE` tells Data Pump to split the files when reaching a certain size. The *1M* setting splits at 1 MB allowing you to neatly put your dump files on floppy disks... Just kidding, this low setting is for demonstration purposes only. Normally, you would have a much larger setting. When moving data to the cloud a `FILESIZE=5G` is normally a good setting.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ cat /home/oracle/scripts/dp-04-bp-2.par
    schemas=f1
    directory=dpdir
    logfile=f1-export.log
    metrics=yes
    logtime=all
    dumpfile=f1_%L.dmp
    filesize=1M
    ```
    </details>     

4. Perform the export in parallel.

    ```
    <copy>
    cat /home/oracle/scripts/dp-04-bp-3.par
    </copy>
    ```

    * Setting a `PARALLEL` degree allows Data Pump to spawn worker processes to speed up the process.
    * With a setting of `PARALLEL=4` Data Pump uses one control process and up to four worker processes. 
    * If one worker process is using parallel query processes (PQ), you will see less worker processes being active.
    * The parallel degree on export and on import are completely independent. You can export with `PARALLEL=4` and import with `PARALLEL=16` - even if you just have four dump files.
    * You can even import in parallel when you have just one dump file.
    * To avoid bottlenecks during parallel export, be sure to allow multiple dump files using the *%L* wildcard discussed above.
    * As a rule-of-thumb, set `PARALLEL` to twice the number of physical cores, or number of ECPUs / 4 in OCI (alternatively number of OCPUs).
    * Using `PARALLEL` requires Enterprise Edition.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ cat /home/oracle/scripts/dp-04-bp-3.par
    schemas=f1
    directory=dpdir
    logfile=f1-export.log
    metrics=yes
    logtime=all
    dumpfile=f1_%L.dmp
    filesize=1M
    parallel=4
    ```
    </details>  

5. Gather dictionary statistics before exporting.

    ```
    <copy>
    sqlplus / as sysdba<<EOF
       begin
           dbms_stats.gather_schema_stats('SYS');
           dbms_stats.gather_schema_stats('SYSTEM');
       end;
       /       
    EOF
    </copy>
    ```

    * Data Pump jobs - both export and import - are querying the data dictionary massively. 
    * To avoid issues with poor performing SQLs ensure that the dictionary statistics are current.
    * Oracle recommends gathering dictionary statistics before an export, before an import and immediately after an import.
    * You can also use `DBMS_STATS.GATHER_DICTIONARY_STATS`, but the Data Pump product management team recommends gathering schema statistics instead.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
     SQL*Plus: Release 19.0.0.0.0 - Production on Sat Apr 26 07:36:46 2025
     Version 19.21.0.0.0
     
     Copyright (c) 1982, 2022, Oracle.  All rights reserved.
     
     
     Connected to:
     Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
     Version 19.21.0.0.0
     
     SQL>   2    3    4    5
     
     PL/SQL procedure successfully completed.
     
     Disconnected from Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
     Version 19.21.0.0.0
    ```
    </details>  

6. Remove any existing dump files and start an export.

    ```
    <copy>
    . ftex
    rm /home/oracle/dpdir/*dmp
    expdp dpuser/oracle parfile=/home/oracle/scripts/dp-04-bp-3.par
    </copy>

    -- Be sure to hit RETURN
    ```

    * Notice the enhanced diagnostics information in the log file. 
    * Each line is prefixed with a timestamp.
    * Multiple workers were employed. Each line tells you which worker did the job, notice the *W-1*, *W-2*, *W-3* and *W-4* labels.
    * For table data export, you can also see the *direct\_path* method were selected for all tables. 
    * In the end of the output, you can also see that Data Pump created a total of 24 log files.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ .ftex
    $ rm /home/oracle/dpdir/*dmp
    $ expdp dpuser/oracle parfile=/home/oracle/scripts/dp-04-bp-3.par
    
    Export: Release 19.0.0.0.0 - Production on Sat Apr 26 07:43:05 2025
    Version 19.21.0.0.0
    
    Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.
    
    Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    26-APR-25 07:43:08.659: Starting "DPUSER"."SYS_EXPORT_SCHEMA_01":  dpuser/******** parfile=/home/oracle/scripts/dp-04-bp-3.par
    26-APR-25 07:43:09.065: W-1 Startup took 1 seconds
    26-APR-25 07:43:10.224: W-2 Startup took 0 seconds
    26-APR-25 07:43:10.265: W-3 Startup took 0 seconds
    26-APR-25 07:43:10.443: W-4 Startup took 0 seconds
    26-APR-25 07:43:10.500: W-1 Processing object type SCHEMA_EXPORT/TABLE/INDEX/STATISTICS/INDEX_STATISTICS
    26-APR-25 07:43:10.542: W-1      Completed 19 INDEX_STATISTICS objects in 0 seconds
    26-APR-25 07:43:10.654: W-1 Processing object type SCHEMA_EXPORT/TABLE/STATISTICS/TABLE_STATISTICS
    26-APR-25 07:43:10.660: W-1      Completed 14 TABLE_STATISTICS objects in 0 seconds
    26-APR-25 07:43:10.732: W-1 Processing object type SCHEMA_EXPORT/USER
    26-APR-25 07:43:10.737: W-1      Completed 1 USER objects in 0 seconds
    26-APR-25 07:43:10.744: W-2 Processing object type SCHEMA_EXPORT/SYSTEM_GRANT
    26-APR-25 07:43:10.768: W-2      Completed 2 SYSTEM_GRANT objects in 0 seconds
    26-APR-25 07:43:10.781: W-1 Processing object type SCHEMA_EXPORT/DEFAULT_ROLE
    26-APR-25 07:43:10.785: W-1      Completed 1 DEFAULT_ROLE objects in 0 seconds
    26-APR-25 07:43:10.802: W-1 Processing object type SCHEMA_EXPORT/TABLESPACE_QUOTA
    26-APR-25 07:43:10.807: W-1      Completed 1 TABLESPACE_QUOTA objects in 0 seconds
    26-APR-25 07:43:10.973: W-1 Processing object type SCHEMA_EXPORT/PRE_SCHEMA/PROCACT_SCHEMA
    26-APR-25 07:43:10.979: W-1      Completed 1 PROCACT_SCHEMA objects in 0 seconds
    26-APR-25 07:43:11.987: W-3 Processing object type SCHEMA_EXPORT/TABLE/TABLE_DATA
    26-APR-25 07:43:14.262: W-3 Processing object type SCHEMA_EXPORT/TABLE/TABLE
    26-APR-25 07:43:14.376: W-3      Completed 14 TABLE objects in 2 seconds
    26-APR-25 07:43:14.802: W-2 Processing object type SCHEMA_EXPORT/TABLE/CONSTRAINT/CONSTRAINT
    26-APR-25 07:43:14.812: W-2      Completed 22 CONSTRAINT objects in 1 seconds
    26-APR-25 07:43:15.496: W-4 Processing object type SCHEMA_EXPORT/STATISTICS/MARKER
    26-APR-25 07:43:15.640: W-3 . . exported "F1"."F1_RESULTS"                           1.429 MB   26439 rows in 0 seconds using direct_path
    26-APR-25 07:43:15.661: W-4      Completed 1 MARKER objects in 4 seconds
    26-APR-25 07:43:15.700: W-3 . . exported "F1"."F1_DRIVERSTANDINGS"                   916.2 KB   34511 rows in 0 seconds using direct_path
    26-APR-25 07:43:15.722: W-3 . . exported "F1"."F1_QUALIFYING"                        419.0 KB   10174 rows in 0 seconds using direct_path
    26-APR-25 07:43:15.771: W-3 . . exported "F1"."F1_PITSTOPS"                          416.8 KB   10793 rows in 0 seconds using direct_path
    26-APR-25 07:43:15.800: W-3 . . exported "F1"."F1_CONSTRUCTORSTANDINGS"              344.1 KB   13231 rows in 0 seconds using direct_path
    26-APR-25 07:43:15.832: W-3 . . exported "F1"."F1_CONSTRUCTORRESULTS"                225.2 KB   12465 rows in 0 seconds using direct_path
    26-APR-25 07:43:15.850: W-3 . . exported "F1"."F1_RACES"                             131.4 KB    1125 rows in 0 seconds using direct_path
    26-APR-25 07:43:15.876: W-3 . . exported "F1"."F1_DRIVERS"                           87.86 KB     859 rows in 0 seconds using direct_path
    26-APR-25 07:43:15.901: W-3 . . exported "F1"."F1_SPRINTRESULTS"                     29.88 KB     280 rows in 0 seconds using direct_path
    26-APR-25 07:43:15.917: W-1 . . exported "F1"."F1_LAPTIMES"                          16.98 MB  571047 rows in 0 seconds using direct_path
    26-APR-25 07:43:15.923: W-3 . . exported "F1"."F1_CONSTRUCTORS"                      22.97 KB     212 rows in 0 seconds using direct_path
    26-APR-25 07:43:15.955: W-3 . . exported "F1"."F1_CIRCUITS"                          17.42 KB      77 rows in 0 seconds using direct_path
    26-APR-25 07:43:15.978: W-3 . . exported "F1"."F1_SEASONS"                           10.03 KB      75 rows in 0 seconds using direct_path
    26-APR-25 07:43:16.001: W-3 . . exported "F1"."F1_STATUS"                            7.843 KB     139 rows in 0 seconds using direct_path
    26-APR-25 07:43:16.757: W-2      Completed 14 SCHEMA_EXPORT/TABLE/TABLE_DATA objects in 0 seconds
    26-APR-25 07:43:17.824: W-2 Master table "DPUSER"."SYS_EXPORT_SCHEMA_01" successfully loaded/unloaded
    26-APR-25 07:43:17.827: ******************************************************************************
    26-APR-25 07:43:17.827: Dump file set for DPUSER.SYS_EXPORT_SCHEMA_01 is:
    26-APR-25 07:43:17.828:   /home/oracle/dpdir/f1_01.dmp
    26-APR-25 07:43:17.829:   /home/oracle/dpdir/f1_02.dmp
    26-APR-25 07:43:17.829:   /home/oracle/dpdir/f1_03.dmp
    26-APR-25 07:43:17.830:   /home/oracle/dpdir/f1_04.dmp
    26-APR-25 07:43:17.830:   /home/oracle/dpdir/f1_05.dmp
    26-APR-25 07:43:17.830:   /home/oracle/dpdir/f1_06.dmp
    26-APR-25 07:43:17.831:   /home/oracle/dpdir/f1_07.dmp
    26-APR-25 07:43:17.831:   /home/oracle/dpdir/f1_08.dmp
    26-APR-25 07:43:17.831:   /home/oracle/dpdir/f1_09.dmp
    26-APR-25 07:43:17.831:   /home/oracle/dpdir/f1_10.dmp
    26-APR-25 07:43:17.832:   /home/oracle/dpdir/f1_11.dmp
    26-APR-25 07:43:17.832:   /home/oracle/dpdir/f1_12.dmp
    26-APR-25 07:43:17.832:   /home/oracle/dpdir/f1_13.dmp
    26-APR-25 07:43:17.833:   /home/oracle/dpdir/f1_14.dmp
    26-APR-25 07:43:17.833:   /home/oracle/dpdir/f1_15.dmp
    26-APR-25 07:43:17.833:   /home/oracle/dpdir/f1_16.dmp
    26-APR-25 07:43:17.834:   /home/oracle/dpdir/f1_17.dmp
    26-APR-25 07:43:17.834:   /home/oracle/dpdir/f1_18.dmp
    26-APR-25 07:43:17.834:   /home/oracle/dpdir/f1_19.dmp
    26-APR-25 07:43:17.835:   /home/oracle/dpdir/f1_20.dmp
    26-APR-25 07:43:17.835:   /home/oracle/dpdir/f1_21.dmp
    26-APR-25 07:43:17.836:   /home/oracle/dpdir/f1_22.dmp
    26-APR-25 07:43:17.836:   /home/oracle/dpdir/f1_23.dmp
    26-APR-25 07:43:17.836:   /home/oracle/dpdir/f1_24.dmp
    26-APR-25 07:43:17.845: Job "DPUSER"."SYS_EXPORT_SCHEMA_01" successfully completed at Sat Apr 26 07:43:17 2025 elapsed 0 00:00:10
    ```
    </details>  

7. Check the size and number of the dump files.

    ```
    <copy>
    ll /home/oracle/dpdir/f1_*dmp
    ll /home/oracle/dpdir/f1_*dmp | wc -l
    </copy>

    -- Be sure to hit RETURN
    ```

    * No file is bigger than 1 MB.
    * There are 24 dump files.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ ll /home/oracle/dpdir/f1_*dmp
    -rw-r-----. 1 oracle oinstall 1048576 Apr 26 07:43 /home/oracle/dpdir/f1_01.dmp
    -rw-r-----. 1 oracle oinstall  802816 Apr 26 07:43 /home/oracle/dpdir/f1_02.dmp
    -rw-r-----. 1 oracle oinstall 1048576 Apr 26 07:43 /home/oracle/dpdir/f1_03.dmp
    -rw-r-----. 1 oracle oinstall 1048576 Apr 26 07:43 /home/oracle/dpdir/f1_04.dmp
    -rw-r-----. 1 oracle oinstall 1048576 Apr 26 07:43 /home/oracle/dpdir/f1_05.dmp
    -rw-r-----. 1 oracle oinstall 1048576 Apr 26 07:43 /home/oracle/dpdir/f1_06.dmp
    -rw-r-----. 1 oracle oinstall 1048576 Apr 26 07:43 /home/oracle/dpdir/f1_07.dmp
    -rw-r-----. 1 oracle oinstall 1048576 Apr 26 07:43 /home/oracle/dpdir/f1_08.dmp
    -rw-r-----. 1 oracle oinstall 1048576 Apr 26 07:43 /home/oracle/dpdir/f1_09.dmp
    -rw-r-----. 1 oracle oinstall 1048576 Apr 26 07:43 /home/oracle/dpdir/f1_10.dmp
    -rw-r-----. 1 oracle oinstall 1048576 Apr 26 07:43 /home/oracle/dpdir/f1_11.dmp
    -rw-r-----. 1 oracle oinstall 1048576 Apr 26 07:43 /home/oracle/dpdir/f1_12.dmp
    -rw-r-----. 1 oracle oinstall 1048576 Apr 26 07:43 /home/oracle/dpdir/f1_13.dmp
    -rw-r-----. 1 oracle oinstall 1048576 Apr 26 07:43 /home/oracle/dpdir/f1_14.dmp
    -rw-r-----. 1 oracle oinstall 1048576 Apr 26 07:43 /home/oracle/dpdir/f1_15.dmp
    -rw-r-----. 1 oracle oinstall 1048576 Apr 26 07:43 /home/oracle/dpdir/f1_16.dmp
    -rw-r-----. 1 oracle oinstall 1044480 Apr 26 07:43 /home/oracle/dpdir/f1_17.dmp
    -rw-r-----. 1 oracle oinstall 1048576 Apr 26 07:43 /home/oracle/dpdir/f1_18.dmp
    -rw-r-----. 1 oracle oinstall 1048576 Apr 26 07:43 /home/oracle/dpdir/f1_19.dmp
    -rw-r-----. 1 oracle oinstall 1048576 Apr 26 07:43 /home/oracle/dpdir/f1_20.dmp
    -rw-r-----. 1 oracle oinstall 1048576 Apr 26 07:43 /home/oracle/dpdir/f1_21.dmp
    -rw-r-----. 1 oracle oinstall 1048576 Apr 26 07:43 /home/oracle/dpdir/f1_22.dmp
    -rw-r-----. 1 oracle oinstall  102400 Apr 26 07:43 /home/oracle/dpdir/f1_23.dmp
    -rw-r-----. 1 oracle oinstall   45056 Apr 26 07:43 /home/oracle/dpdir/f1_24.dmp
    $ ll /home/oracle/dpdir/f1_*dmp | wc -l
    24
    ```
    </details> 

## Task 2: Compression

Besides the general best practices, there are a number of useful settings. Compression reduces the size of the dump files and make it easier to transfer them to the cloud or other locations. Using compression during export requires a license for the Advanced Compression Option.

1. Still in the *yellow* terminal 🟨. Examine a parameter file with compression.

    ```
    <copy>
    cat /home/oracle/scripts/dp-04-comp-med.par
    </copy>
    ```

    * `COMPRESSION=ALL` instructs Data Pump to compress metadata and data.
    * `COMPRESSION_ALGORITHM` tells which algorithm to use. *medium* is also the default, because it often gives a good balance between compression ratio and CPU usage.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ cat /home/oracle/scripts/dp-04-comp-med.par
    schemas=f1
    directory=dpdir
    logfile=f1-export.log
    metrics=yes
    logtime=all
    dumpfile=f1_%L.dmp
    filesize=1M
    parallel=4
    job_name=MEDIUM_COMPRESSION
    compression=all
    compression_agorithm=medium
    ```
    </details> 

2. Compare no compression with different algorithms, medium and high. Start three exports with different settings.

    ```
    <copy>
    . ftex
    rm /home/oracle/dpdir/*
    expdp dpuser/oracle parfile=/home/oracle/scripts/dp-04-comp-no.par
    expdp dpuser/oracle parfile=/home/oracle/scripts/dp-04-comp-med.par
    expdp dpuser/oracle parfile=/home/oracle/scripts/dp-04-comp-high.par
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ . ftex
    $ rm /home/oracle/dpdir/*
    $ expdp dpuser/oracle parfile=/home/oracle/scripts/dp-04-comp-no.par
    
    Export: Release 19.0.0.0.0 - Production on Sat Apr 26 08:15:28 2025
    Version 19.21.0.0.0
    
    Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.
    
    Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    26-APR-25 08:15:31.395: Starting "DPUSER"."NO_COMPRESSION":  dpuser/******** parfile=/home/oracle/scripts/dp-04-comp-no.par
    26-APR-25 08:15:31.743: W-1 Startup took 0 seconds
    26-APR-25 08:15:33.058: W-2 Startup took 0 seconds
    26-APR-25 08:15:33.064: W-3 Startup took 1 seconds
    26-APR-25 08:15:33.219: W-1 Processing object type SCHEMA_EXPORT/TABLE/INDEX/STATISTICS/INDEX_STATISTICS
    26-APR-25 08:15:33.246: W-4 Startup took 0 seconds
    26-APR-25 08:15:33.260: W-1      Completed 19 INDEX_STATISTICS objects in 0 seconds
    26-APR-25 08:15:33.354: W-1 Processing object type SCHEMA_EXPORT/TABLE/STATISTICS/TABLE_STATISTICS
    26-APR-25 08:15:33.360: W-1      Completed 14 TABLE_STATISTICS objects in 0 seconds
    26-APR-25 08:15:33.446: W-1 Processing object type SCHEMA_EXPORT/USER
    26-APR-25 08:15:33.450: W-1      Completed 1 USER objects in 0 seconds
    26-APR-25 08:15:33.471: W-1 Processing object type SCHEMA_EXPORT/SYSTEM_GRANT
    26-APR-25 08:15:33.474: W-1      Completed 2 SYSTEM_GRANT objects in 0 seconds
    26-APR-25 08:15:33.508: W-1 Processing object type SCHEMA_EXPORT/DEFAULT_ROLE
    26-APR-25 08:15:33.511: W-1      Completed 1 DEFAULT_ROLE objects in 0 seconds
    26-APR-25 08:15:33.542: W-3 Processing object type SCHEMA_EXPORT/TABLESPACE_QUOTA
    26-APR-25 08:15:33.565: W-3      Completed 1 TABLESPACE_QUOTA objects in 0 seconds
    26-APR-25 08:15:33.808: W-1 Processing object type SCHEMA_EXPORT/PRE_SCHEMA/PROCACT_SCHEMA
    26-APR-25 08:15:33.813: W-1      Completed 1 PROCACT_SCHEMA objects in 0 seconds
    26-APR-25 08:15:34.676: W-2 Processing object type SCHEMA_EXPORT/TABLE/TABLE_DATA
    26-APR-25 08:15:36.925: W-2 Processing object type SCHEMA_EXPORT/TABLE/TABLE
    26-APR-25 08:15:37.050: W-2      Completed 14 TABLE objects in 2 seconds
    26-APR-25 08:15:37.518: W-1 Processing object type SCHEMA_EXPORT/TABLE/CONSTRAINT/CONSTRAINT
    26-APR-25 08:15:37.526: W-1      Completed 22 CONSTRAINT objects in 1 seconds
    26-APR-25 08:15:38.276: W-4 Processing object type SCHEMA_EXPORT/STATISTICS/MARKER
    26-APR-25 08:15:38.321: W-1 . . exported "F1"."F1_RESULTS"                           1.429 MB   26439 rows in 0 seconds using direct_path
    26-APR-25 08:15:38.364: W-1 . . exported "F1"."F1_DRIVERSTANDINGS"                   916.2 KB   34511 rows in 0 seconds using direct_path
    26-APR-25 08:15:38.390: W-1 . . exported "F1"."F1_QUALIFYING"                        419.0 KB   10174 rows in 0 seconds using direct_path
    26-APR-25 08:15:38.411: W-4      Completed 1 MARKER objects in 5 seconds
    26-APR-25 08:15:38.431: W-1 . . exported "F1"."F1_PITSTOPS"                          416.8 KB   10793 rows in 0 seconds using direct_path
    26-APR-25 08:15:38.460: W-1 . . exported "F1"."F1_CONSTRUCTORSTANDINGS"              344.1 KB   13231 rows in 0 seconds using direct_path
    26-APR-25 08:15:38.483: W-1 . . exported "F1"."F1_CONSTRUCTORRESULTS"                225.2 KB   12465 rows in 0 seconds using direct_path
    26-APR-25 08:15:38.509: W-1 . . exported "F1"."F1_RACES"                             131.4 KB    1125 rows in 0 seconds using direct_path
    26-APR-25 08:15:38.544: W-1 . . exported "F1"."F1_DRIVERS"                           87.86 KB     859 rows in 0 seconds using direct_path
    26-APR-25 08:15:38.586: W-1 . . exported "F1"."F1_SPRINTRESULTS"                     29.88 KB     280 rows in 0 seconds using direct_path
    26-APR-25 08:15:38.616: W-1 . . exported "F1"."F1_CONSTRUCTORS"                      22.97 KB     212 rows in 0 seconds using direct_path
    26-APR-25 08:15:38.645: W-1 . . exported "F1"."F1_CIRCUITS"                          17.42 KB      77 rows in 0 seconds using direct_path
    26-APR-25 08:15:38.655: W-2 . . exported "F1"."F1_LAPTIMES"                          16.98 MB  571047 rows in 0 seconds using direct_path
    26-APR-25 08:15:38.670: W-1 . . exported "F1"."F1_SEASONS"                           10.03 KB      75 rows in 0 seconds using direct_path
    26-APR-25 08:15:38.711: W-1 . . exported "F1"."F1_STATUS"                            7.843 KB     139 rows in 0 seconds using direct_path
    26-APR-25 08:15:39.436: W-2      Completed 14 SCHEMA_EXPORT/TABLE/TABLE_DATA objects in 0 seconds
    26-APR-25 08:15:40.054: W-2 Master table "DPUSER"."NO_COMPRESSION" successfully loaded/unloaded
    26-APR-25 08:15:40.057: ******************************************************************************
    26-APR-25 08:15:40.058: Dump file set for DPUSER.NO_COMPRESSION is:
    26-APR-25 08:15:40.059:   /home/oracle/dpdir/f1_nocomp_01.dmp
    26-APR-25 08:15:40.059:   /home/oracle/dpdir/f1_nocomp_02.dmp
    26-APR-25 08:15:40.060:   /home/oracle/dpdir/f1_nocomp_03.dmp
    26-APR-25 08:15:40.060:   /home/oracle/dpdir/f1_nocomp_04.dmp
    26-APR-25 08:15:40.060:   /home/oracle/dpdir/f1_nocomp_05.dmp
    26-APR-25 08:15:40.061:   /home/oracle/dpdir/f1_nocomp_06.dmp
    26-APR-25 08:15:40.061:   /home/oracle/dpdir/f1_nocomp_07.dmp
    26-APR-25 08:15:40.061:   /home/oracle/dpdir/f1_nocomp_08.dmp
    26-APR-25 08:15:40.062:   /home/oracle/dpdir/f1_nocomp_09.dmp
    26-APR-25 08:15:40.062:   /home/oracle/dpdir/f1_nocomp_10.dmp
    26-APR-25 08:15:40.062:   /home/oracle/dpdir/f1_nocomp_11.dmp
    26-APR-25 08:15:40.063:   /home/oracle/dpdir/f1_nocomp_12.dmp
    26-APR-25 08:15:40.063:   /home/oracle/dpdir/f1_nocomp_13.dmp
    26-APR-25 08:15:40.063:   /home/oracle/dpdir/f1_nocomp_14.dmp
    26-APR-25 08:15:40.064:   /home/oracle/dpdir/f1_nocomp_15.dmp
    26-APR-25 08:15:40.064:   /home/oracle/dpdir/f1_nocomp_16.dmp
    26-APR-25 08:15:40.064:   /home/oracle/dpdir/f1_nocomp_17.dmp
    26-APR-25 08:15:40.065:   /home/oracle/dpdir/f1_nocomp_18.dmp
    26-APR-25 08:15:40.065:   /home/oracle/dpdir/f1_nocomp_19.dmp
    26-APR-25 08:15:40.065:   /home/oracle/dpdir/f1_nocomp_20.dmp
    26-APR-25 08:15:40.066:   /home/oracle/dpdir/f1_nocomp_21.dmp
    26-APR-25 08:15:40.066:   /home/oracle/dpdir/f1_nocomp_22.dmp
    26-APR-25 08:15:40.066:   /home/oracle/dpdir/f1_nocomp_23.dmp
    26-APR-25 08:15:40.067:   /home/oracle/dpdir/f1_nocomp_24.dmp
    26-APR-25 08:15:40.077: Job "DPUSER"."NO_COMPRESSION" successfully completed at Sat Apr 26 08:15:40 2025 elapsed 0 00:00:10
    
    [FTEX:oracle@holserv1:~]$ expdp dpuser/oracle parfile=/home/oracle/scripts/dp-04-comp-med.par
    
    Export: Release 19.0.0.0.0 - Production on Sat Apr 26 08:15:41 2025
    Version 19.21.0.0.0
    
    Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.
    
    Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    26-APR-25 08:15:44.832: Starting "DPUSER"."MEDIUM_COMPRESSION":  dpuser/******** parfile=/home/oracle/scripts/dp-04-comp-med.par
    26-APR-25 08:15:45.210: W-1 Startup took 1 seconds
    26-APR-25 08:15:46.378: W-2 Startup took 0 seconds
    26-APR-25 08:15:46.433: W-3 Startup took 0 seconds
    26-APR-25 08:15:46.660: W-4 Startup took 0 seconds
    26-APR-25 08:15:46.843: W-1 Processing object type SCHEMA_EXPORT/TABLE/STATISTICS/TABLE_STATISTICS
    26-APR-25 08:15:46.874: W-1      Completed 14 TABLE_STATISTICS objects in 0 seconds
    26-APR-25 08:15:46.946: W-2 Processing object type SCHEMA_EXPORT/SYSTEM_GRANT
    26-APR-25 08:15:46.965: W-1 Processing object type SCHEMA_EXPORT/USER
    26-APR-25 08:15:46.967: W-1      Completed 1 USER objects in 0 seconds
    26-APR-25 08:15:46.974: W-2      Completed 2 SYSTEM_GRANT objects in 0 seconds
    26-APR-25 08:15:46.993: W-2 Processing object type SCHEMA_EXPORT/DEFAULT_ROLE
    26-APR-25 08:15:46.996: W-2      Completed 1 DEFAULT_ROLE objects in 0 seconds
    26-APR-25 08:15:47.020: W-2 Processing object type SCHEMA_EXPORT/TABLESPACE_QUOTA
    26-APR-25 08:15:47.023: W-2      Completed 1 TABLESPACE_QUOTA objects in 0 seconds
    26-APR-25 08:15:47.236: W-4 Processing object type SCHEMA_EXPORT/TABLE/INDEX/STATISTICS/INDEX_STATISTICS
    26-APR-25 08:15:47.252: W-4      Completed 19 INDEX_STATISTICS objects in 0 seconds
    26-APR-25 08:15:47.314: W-2 Processing object type SCHEMA_EXPORT/PRE_SCHEMA/PROCACT_SCHEMA
    26-APR-25 08:15:47.318: W-2      Completed 1 PROCACT_SCHEMA objects in 0 seconds
    26-APR-25 08:15:48.267: W-3 Processing object type SCHEMA_EXPORT/TABLE/TABLE_DATA
    26-APR-25 08:15:50.544: W-3 Processing object type SCHEMA_EXPORT/TABLE/TABLE
    26-APR-25 08:15:50.657: W-3      Completed 14 TABLE objects in 2 seconds
    26-APR-25 08:15:51.147: W-1 Processing object type SCHEMA_EXPORT/TABLE/CONSTRAINT/CONSTRAINT
    26-APR-25 08:15:51.156: W-1      Completed 22 CONSTRAINT objects in 1 seconds
    26-APR-25 08:15:51.753: W-4 Processing object type SCHEMA_EXPORT/STATISTICS/MARKER
    26-APR-25 08:15:52.015: W-2 . . exported "F1"."F1_RESULTS"                           563.0 KB   26439 rows in 1 seconds using direct_path
    26-APR-25 08:15:52.042: W-4      Completed 1 MARKER objects in 5 seconds
    26-APR-25 08:15:52.060: W-2 . . exported "F1"."F1_DRIVERSTANDINGS"                   282.2 KB   34511 rows in 0 seconds using direct_path
    26-APR-25 08:15:52.098: W-2 . . exported "F1"."F1_QUALIFYING"                        166.5 KB   10174 rows in 0 seconds using direct_path
    26-APR-25 08:15:52.136: W-2 . . exported "F1"."F1_PITSTOPS"                          172.5 KB   10793 rows in 0 seconds using direct_path
    26-APR-25 08:15:52.164: W-2 . . exported "F1"."F1_CONSTRUCTORSTANDINGS"              107.7 KB   13231 rows in 0 seconds using direct_path
    26-APR-25 08:15:52.194: W-2 . . exported "F1"."F1_CONSTRUCTORRESULTS"                78.28 KB   12465 rows in 0 seconds using direct_path
    26-APR-25 08:15:52.219: W-2 . . exported "F1"."F1_RACES"                             28.57 KB    1125 rows in 0 seconds using direct_path
    26-APR-25 08:15:52.247: W-2 . . exported "F1"."F1_DRIVERS"                           33.57 KB     859 rows in 0 seconds using direct_path
    26-APR-25 08:15:52.270: W-2 . . exported "F1"."F1_SPRINTRESULTS"                     12.46 KB     280 rows in 0 seconds using direct_path
    26-APR-25 08:15:52.300: W-2 . . exported "F1"."F1_CONSTRUCTORS"                      9.554 KB     212 rows in 0 seconds using direct_path
    26-APR-25 08:15:52.318: W-2 . . exported "F1"."F1_CIRCUITS"                          8.625 KB      77 rows in 0 seconds using direct_path
    26-APR-25 08:15:52.339: W-2 . . exported "F1"."F1_SEASONS"                           5.046 KB      75 rows in 0 seconds using direct_path
    26-APR-25 08:15:52.369: W-2 . . exported "F1"."F1_STATUS"                            5.835 KB     139 rows in 0 seconds using direct_path
    26-APR-25 08:15:52.409: W-3 . . exported "F1"."F1_LAPTIMES"                          6.211 MB  571047 rows in 1 seconds using direct_path
    26-APR-25 08:15:53.126: W-3      Completed 14 SCHEMA_EXPORT/TABLE/TABLE_DATA objects in 1 seconds
    26-APR-25 08:15:53.782: W-3 Master table "DPUSER"."MEDIUM_COMPRESSION" successfully loaded/unloaded
    26-APR-25 08:15:53.785: ******************************************************************************
    26-APR-25 08:15:53.785: Dump file set for DPUSER.MEDIUM_COMPRESSION is:
    26-APR-25 08:15:53.786:   /home/oracle/dpdir/f1_compmed_01.dmp
    26-APR-25 08:15:53.787:   /home/oracle/dpdir/f1_compmed_02.dmp
    26-APR-25 08:15:53.787:   /home/oracle/dpdir/f1_compmed_03.dmp
    26-APR-25 08:15:53.787:   /home/oracle/dpdir/f1_compmed_04.dmp
    26-APR-25 08:15:53.788:   /home/oracle/dpdir/f1_compmed_05.dmp
    26-APR-25 08:15:53.788:   /home/oracle/dpdir/f1_compmed_06.dmp
    26-APR-25 08:15:53.788:   /home/oracle/dpdir/f1_compmed_07.dmp
    26-APR-25 08:15:53.789:   /home/oracle/dpdir/f1_compmed_08.dmp
    26-APR-25 08:15:53.789:   /home/oracle/dpdir/f1_compmed_09.dmp
    26-APR-25 08:15:53.789:   /home/oracle/dpdir/f1_compmed_10.dmp
    26-APR-25 08:15:53.800: Job "DPUSER"."MEDIUM_COMPRESSION" successfully completed at Sat Apr 26 08:15:53 2025 elapsed 0 00:00:10
    
    [FTEX:oracle@holserv1:~]$ expdp dpuser/oracle parfile=/home/oracle/scripts/dp-04-comp-high.par
    
    Export: Release 19.0.0.0.0 - Production on Sat Apr 26 08:15:55 2025
    Version 19.21.0.0.0
    
    Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.
    
    Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    26-APR-25 08:15:58.601: Starting "DPUSER"."HIGH_COMPRESSION":  dpuser/******** parfile=/home/oracle/scripts/dp-04-comp-high.par
    26-APR-25 08:15:59.075: W-1 Startup took 1 seconds
    26-APR-25 08:16:00.239: W-2 Startup took 0 seconds
    26-APR-25 08:16:00.288: W-3 Startup took 0 seconds
    26-APR-25 08:16:00.463: W-4 Startup took 0 seconds
    26-APR-25 08:16:00.518: W-1 Processing object type SCHEMA_EXPORT/TABLE/INDEX/STATISTICS/INDEX_STATISTICS
    26-APR-25 08:16:00.595: W-1      Completed 19 INDEX_STATISTICS objects in 0 seconds
    26-APR-25 08:16:00.693: W-1 Processing object type SCHEMA_EXPORT/TABLE/STATISTICS/TABLE_STATISTICS
    26-APR-25 08:16:00.697: W-1      Completed 14 TABLE_STATISTICS objects in 0 seconds
    26-APR-25 08:16:00.751: W-2 Processing object type SCHEMA_EXPORT/USER
    26-APR-25 08:16:00.754: W-1 Processing object type SCHEMA_EXPORT/SYSTEM_GRANT
    26-APR-25 08:16:00.773: W-1      Completed 2 SYSTEM_GRANT objects in 0 seconds
    26-APR-25 08:16:00.779: W-2      Completed 1 USER objects in 0 seconds
    26-APR-25 08:16:00.799: W-2 Processing object type SCHEMA_EXPORT/DEFAULT_ROLE
    26-APR-25 08:16:00.803: W-2      Completed 1 DEFAULT_ROLE objects in 0 seconds
    26-APR-25 08:16:00.820: W-2 Processing object type SCHEMA_EXPORT/TABLESPACE_QUOTA
    26-APR-25 08:16:00.825: W-2      Completed 1 TABLESPACE_QUOTA objects in 0 seconds
    26-APR-25 08:16:00.998: W-2 Processing object type SCHEMA_EXPORT/PRE_SCHEMA/PROCACT_SCHEMA
    26-APR-25 08:16:01.002: W-2      Completed 1 PROCACT_SCHEMA objects in 0 seconds
    26-APR-25 08:16:01.974: W-3 Processing object type SCHEMA_EXPORT/TABLE/TABLE_DATA
    26-APR-25 08:16:04.298: W-3 Processing object type SCHEMA_EXPORT/TABLE/TABLE
    26-APR-25 08:16:04.398: W-3      Completed 14 TABLE objects in 2 seconds
    26-APR-25 08:16:04.677: W-1 Processing object type SCHEMA_EXPORT/TABLE/CONSTRAINT/CONSTRAINT
    26-APR-25 08:16:04.686: W-1      Completed 22 CONSTRAINT objects in 1 seconds
    26-APR-25 08:16:05.497: W-4 Processing object type SCHEMA_EXPORT/STATISTICS/MARKER
    26-APR-25 08:16:05.696: W-4      Completed 1 MARKER objects in 4 seconds
    26-APR-25 08:16:05.918: W-3 . . exported "F1"."F1_RESULTS"                           448.3 KB   26439 rows in 0 seconds using direct_path
    26-APR-25 08:16:06.154: W-3 . . exported "F1"."F1_DRIVERSTANDINGS"                   227.2 KB   34511 rows in 1 seconds using direct_path
    26-APR-25 08:16:06.289: W-3 . . exported "F1"."F1_QUALIFYING"                        139.2 KB   10174 rows in 0 seconds using direct_path
    26-APR-25 08:16:06.403: W-3 . . exported "F1"."F1_PITSTOPS"                          138.6 KB   10793 rows in 0 seconds using direct_path
    26-APR-25 08:16:06.509: W-3 . . exported "F1"."F1_CONSTRUCTORSTANDINGS"              88.28 KB   13231 rows in 0 seconds using direct_path
    26-APR-25 08:16:06.589: W-3 . . exported "F1"."F1_CONSTRUCTORRESULTS"                65.36 KB   12465 rows in 0 seconds using direct_path
    26-APR-25 08:16:06.621: W-3 . . exported "F1"."F1_RACES"                             23.69 KB    1125 rows in 0 seconds using direct_path
    26-APR-25 08:16:06.648: W-3 . . exported "F1"."F1_DRIVERS"                           30.39 KB     859 rows in 0 seconds using direct_path
    26-APR-25 08:16:06.674: W-3 . . exported "F1"."F1_SPRINTRESULTS"                     11.27 KB     280 rows in 0 seconds using direct_path
    26-APR-25 08:16:06.698: W-3 . . exported "F1"."F1_CONSTRUCTORS"                      9.226 KB     212 rows in 0 seconds using direct_path
    26-APR-25 08:16:06.721: W-3 . . exported "F1"."F1_CIRCUITS"                          8.445 KB      77 rows in 0 seconds using direct_path
    26-APR-25 08:16:06.745: W-3 . . exported "F1"."F1_SEASONS"                               5 KB      75 rows in 0 seconds using direct_path
    26-APR-25 08:16:06.767: W-3 . . exported "F1"."F1_STATUS"                            5.765 KB     139 rows in 0 seconds using direct_path
    26-APR-25 08:16:08.891: W-2 . . exported "F1"."F1_LAPTIMES"                          4.892 MB  571047 rows in 3 seconds using direct_path
    26-APR-25 08:16:09.619: W-3      Completed 14 SCHEMA_EXPORT/TABLE/TABLE_DATA objects in 3 seconds
    26-APR-25 08:16:10.317: W-3 Master table "DPUSER"."HIGH_COMPRESSION" successfully loaded/unloaded
    26-APR-25 08:16:10.320: ******************************************************************************
    26-APR-25 08:16:10.320: Dump file set for DPUSER.HIGH_COMPRESSION is:
    26-APR-25 08:16:10.321:   /home/oracle/dpdir/f1_comphigh_01.dmp
    26-APR-25 08:16:10.322:   /home/oracle/dpdir/f1_comphigh_02.dmp
    26-APR-25 08:16:10.322:   /home/oracle/dpdir/f1_comphigh_03.dmp
    26-APR-25 08:16:10.322:   /home/oracle/dpdir/f1_comphigh_04.dmp
    26-APR-25 08:16:10.323:   /home/oracle/dpdir/f1_comphigh_05.dmp
    26-APR-25 08:16:10.323:   /home/oracle/dpdir/f1_comphigh_06.dmp
    26-APR-25 08:16:10.323:   /home/oracle/dpdir/f1_comphigh_07.dmp
    26-APR-25 08:16:10.323:   /home/oracle/dpdir/f1_comphigh_08.dmp
    26-APR-25 08:16:10.332: Job "DPUSER"."HIGH_COMPRESSION" successfully completed at Sat Apr 26 08:16:10 2025 elapsed 0 00:00:13
    ```
    </details> 

3. Check the runtime of the exports.

    ```
    <copy>
    cd /home/oracle/dpdir
    grep "Job" f1*log
    </copy>

    -- Be sure to hit RETURN
    ```

    * Check the elapsed time at the end of each line.
    * The job with no compression ran for 10 seconds, so did the one with medium compression.
    * Using high compression caused the job to run for 3 seconds more - but that's also a 30 % increase.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ cd /home/oracle/dpdir
    $ grep "Job" f1*log
    f1-export-high.log:26-APR-25 08:16:10.331: Job "DPUSER"."HIGH_COMPRESSION" successfully completed at Sat Apr 26 08:16:10 2025 elapsed 0 00:00:13
    f1-export.log:26-APR-25 08:15:40.077: Job "DPUSER"."NO_COMPRESSION" successfully completed at Sat Apr 26 08:15:40 2025 elapsed 0 00:00:10
    f1-export-medium.log:26-APR-25 08:15:53.800: Job "DPUSER"."MEDIUM_COMPRESSION" successfully completed at Sat Apr 26 08:15:53 2025 elapsed 0 00:00:10
    ```
    </details> 

3. Check the size of the dump files.

    ```
    <copy>
    cd /home/oracle/dpdir
    echo "No compression: "$(du -ch f1_nocomp* | tail -1 | cut -f 1)
    echo "Medium compression: "$(du -ch f1_compmed* | tail -1 | cut -f 1)
    echo "High compression: "$(du -ch f1_comphigh* | tail -1 | cut -f 1)
    </copy>

    -- Be sure to hit RETURN
    ```

    * With no compression, the dump files take up 22 MB.
    * By using medium compression, you can reduce the size to 7.9 MB. It costs some CPU usage but didn't affect the overall runtime of the job.
    * You get the best compression ratio with high; that reduces the size to 6.3 MB but comes with much higher CPU usage that did have a significant impact on the job runtime.
    * In this example, you can clear see that the default compression algorithm (medium) gives a very good balance between CPU usage and compression ratio.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ cd /home/oracle/dpdir
    $ echo "No compression: "$(du -ch f1_nocomp* | tail -1 | cut -f 1)
    No compression: 22M
    $ echo "Medium compression: "$(du -ch f1_compmed* | tail -1 | cut -f 1)
    Medium compression: 7.9M
    $ echo "High compression: "$(du -ch f1_comphigh* | tail -1 | cut -f 1)
    High compression: 6.3M
    ```
    </details> 

4. This is not a scientific test and results may vary in other situations, but it gives an impression of the potential of compression.

5. Compression uses CPU cycles. But it also reduces the amount of I/O because less needs to be written to or read from the dump files. Often, you'll see that applying compression reduces the overall runtime of the export or import.

## Task 3: Consistent exports

Data Pump attempts to minimize the impact on the database during export. This means that each table is exported in a consistent manner, but the entire data set is not consistent. As an example, table T1 is exported at SCN 100 and all rows are from SCN 100. Table T2 is exported a little later at SCN 105, T3 at SCN 150 and so forth. If you export in a database with no users or if you plan on using Oracle GoldenGate later on, that's not a problem. But sometimes you want to export a complete, consistent data from an active database. 

1. Still in the *yellow* terminal 🟨. Examine the following parameter file.

    ```
    <copy>
    cat /home/oracle/scripts/dp-04-consistent.par
    </copy>
    ```

    * It's an export for the *F1* schema. 
    * Since there's no `FLASHBACK_TIME` or `FLASHBACK_SCN` parameter, it means that you must export from an inactive database in order to get a fully consistent data set.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    schemas=f1
    directory=dpdir
    logfile=f1-export-consistent.log
    metrics=yes
    logtime=all
    dumpfile=f1-export-consistent_%L.dmp
    ```
    </details> 

2. Add a parameter instructing Data Pump to perform a fully consistent export.

    ```
    <copy>
    echo "flashback_time=systimestamp" >> /home/oracle/scripts/dp-04-consistent.par
    cat /home/oracle/scripts/dp-04-consistent.par
    </copy>

    -- Be sure to hit RETURN
    ```

    * Setting `FLASHBACK_TIME=SYSTIMESTAMP` is an easy way to make the export fully consistent.
    * At the start of the export, Data Pump records the current SCN and extracts the rows from all the tables at that specific SCN.
    * The method uses Flashback Query which relies on *undo* information. In an active database, if the undo information is not available, you might hit `ORA-01555: snapshot too old`.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    schemas=f1
    directory=dpdir
    logfile=f1-export-consistent.log
    metrics=yes
    logtime=all
    dumpfile=f1-export-consistent_%L.dmp
    flashback_time=systimestamp
    ```
    </details> 

3. Start the export.

    ```
    <copy>
    . ftex
    rm /home/oracle/dpdir/*
    expdp dpuser/oracle parfile=/home/oracle/scripts/dp-04-consistent.par
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ . ftex
    $ rm /home/oracle/dpdir/*
    $ expdp dpuser/oracle parfile=/home/oracle/scripts/dp-04-consistent.par
    
    Export: Release 19.0.0.0.0 - Production on Mon Apr 28 05:25:51 2025
    Version 19.21.0.0.0
    
    Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.
    
    Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    28-APR-25 05:25:53.692: Starting "DPUSER"."SYS_EXPORT_SCHEMA_02":  dpuser/******** parfile=/home/oracle/scripts/dp-04-consistent.par
    28-APR-25 05:25:53.958: W-1 Startup took 0 seconds
    28-APR-25 05:25:56.216: W-1 Processing object type SCHEMA_EXPORT/TABLE/TABLE_DATA
    28-APR-25 05:25:56.358: W-1 Processing object type SCHEMA_EXPORT/TABLE/INDEX/STATISTICS/INDEX_STATISTICS
    28-APR-25 05:25:56.386: W-1      Completed 19 INDEX_STATISTICS objects in 0 seconds
    28-APR-25 05:25:56.522: W-1 Processing object type SCHEMA_EXPORT/TABLE/STATISTICS/TABLE_STATISTICS
    28-APR-25 05:25:56.528: W-1      Completed 14 TABLE_STATISTICS objects in 0 seconds
    28-APR-25 05:25:59.968: W-1 Processing object type SCHEMA_EXPORT/STATISTICS/MARKER
    28-APR-25 05:26:00.117: W-1      Completed 1 MARKER objects in 4 seconds
    28-APR-25 05:26:00.159: W-1 Processing object type SCHEMA_EXPORT/USER
    28-APR-25 05:26:00.170: W-1      Completed 1 USER objects in 0 seconds
    28-APR-25 05:26:00.190: W-1 Processing object type SCHEMA_EXPORT/SYSTEM_GRANT
    28-APR-25 05:26:00.194: W-1      Completed 2 SYSTEM_GRANT objects in 0 seconds
    28-APR-25 05:26:00.225: W-1 Processing object type SCHEMA_EXPORT/DEFAULT_ROLE
    28-APR-25 05:26:00.230: W-1      Completed 1 DEFAULT_ROLE objects in 0 seconds
    28-APR-25 05:26:00.260: W-1 Processing object type SCHEMA_EXPORT/TABLESPACE_QUOTA
    28-APR-25 05:26:00.264: W-1      Completed 1 TABLESPACE_QUOTA objects in 0 seconds
    28-APR-25 05:26:00.533: W-1 Processing object type SCHEMA_EXPORT/PRE_SCHEMA/PROCACT_SCHEMA
    28-APR-25 05:26:00.537: W-1      Completed 1 PROCACT_SCHEMA objects in 0 seconds
    28-APR-25 05:26:04.663: W-1 Processing object type SCHEMA_EXPORT/TABLE/TABLE
    28-APR-25 05:26:04.761: W-1      Completed 14 TABLE objects in 1 seconds
    28-APR-25 05:26:07.763: W-1 Processing object type SCHEMA_EXPORT/TABLE/CONSTRAINT/CONSTRAINT
    28-APR-25 05:26:07.772: W-1      Completed 22 CONSTRAINT objects in 1 seconds
    28-APR-25 05:26:09.268: W-1 . . exported "F1"."F1_LAPTIMES"                          16.98 MB  571047 rows in 0 seconds using direct_path
    28-APR-25 05:26:09.306: W-1 . . exported "F1"."F1_RESULTS"                           1.429 MB   26439 rows in 0 seconds using direct_path
    28-APR-25 05:26:09.332: W-1 . . exported "F1"."F1_DRIVERSTANDINGS"                   916.2 KB   34511 rows in 0 seconds using direct_path
    28-APR-25 05:26:09.357: W-1 . . exported "F1"."F1_QUALIFYING"                        419.0 KB   10174 rows in 0 seconds using direct_path
    28-APR-25 05:26:09.382: W-1 . . exported "F1"."F1_PITSTOPS"                          416.8 KB   10793 rows in 0 seconds using direct_path
    28-APR-25 05:26:09.406: W-1 . . exported "F1"."F1_CONSTRUCTORSTANDINGS"              344.1 KB   13231 rows in 0 seconds using direct_path
    28-APR-25 05:26:09.430: W-1 . . exported "F1"."F1_CONSTRUCTORRESULTS"                225.2 KB   12465 rows in 0 seconds using direct_path
    28-APR-25 05:26:09.455: W-1 . . exported "F1"."F1_RACES"                             131.4 KB    1125 rows in 0 seconds using direct_path
    28-APR-25 05:26:09.478: W-1 . . exported "F1"."F1_DRIVERS"                           87.86 KB     859 rows in 0 seconds using direct_path
    28-APR-25 05:26:09.502: W-1 . . exported "F1"."F1_SPRINTRESULTS"                     29.88 KB     280 rows in 0 seconds using direct_path
    28-APR-25 05:26:09.524: W-1 . . exported "F1"."F1_CONSTRUCTORS"                      22.97 KB     212 rows in 0 seconds using direct_path
    28-APR-25 05:26:09.546: W-1 . . exported "F1"."F1_CIRCUITS"                          17.42 KB      77 rows in 0 seconds using direct_path
    28-APR-25 05:26:09.568: W-1 . . exported "F1"."F1_SEASONS"                           10.03 KB      75 rows in 0 seconds using direct_path
    28-APR-25 05:26:09.589: W-1 . . exported "F1"."F1_STATUS"                            7.843 KB     139 rows in 0 seconds using direct_path
    28-APR-25 05:26:10.337: W-1      Completed 14 SCHEMA_EXPORT/TABLE/TABLE_DATA objects in 0 seconds
    28-APR-25 05:26:10.999: W-1 Master table "DPUSER"."SYS_EXPORT_SCHEMA_02" successfully loaded/unloaded
    28-APR-25 05:26:11.001: ******************************************************************************
    28-APR-25 05:26:11.002: Dump file set for DPUSER.SYS_EXPORT_SCHEMA_02 is:
    28-APR-25 05:26:11.003:   /home/oracle/dpdir/f1-export-consistent_01.dmp
    28-APR-25 05:26:11.010: Job "DPUSER"."SYS_EXPORT_SCHEMA_02" successfully completed at Mon Apr 28 05:26:11 2025 elapsed 0 00:00:18
    ```
    </details>     

4. Verify the use of `FLASHBACK_SCN` from the export log file.

    ```
    <copy>
    grep -i "flashback" /home/oracle/dpdir/f1-export-consistent.log
    </copy>
    ```

    * The Data Pump log file contains a list of all parameters used.
    * You can find the parameter `FLASHBACK_TIME=SYSTIMESTAMP`.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ grep -i "flashback" /home/oracle/dpdir/f1-export-consistent.log
    28-APR-25 05:25:52.880: ;;;  parfile:  flashback_time=systimestamp
    ```
    </details>     

You may now *proceed to the next lab*.

## Additional information

* Webinar, [Data Pump Extreme - Deep Dive with Development](https://www.youtube.com/watch?v=CUHcKHx_YvA&t=2169s)

## Acknowledgments

* **Author** - Daniel Overby Hansen
* **Contributors** - Rodrigo Jorge, Mike Dietrich, Klaus Gronau, Alex Zaballa
* **Last Updated By/Date** - Daniel Overby Hansen, May 2025