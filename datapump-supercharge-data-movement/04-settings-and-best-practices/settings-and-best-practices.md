# Best Practices and Other Settings

## Introduction

In this lab, you will see some best practices that will help you get more out of Data Pump. In addition, you will use some of the settings in Data Pump.

Estimated Time: 15 Minutes

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
    37777295;DATAPUMP BUNDLE PATCH 19.27.0.0.0
    37499406;OJVM RELEASE UPDATE: 19.27.0.0.250415 (37499406)
    37642901;Database Release Update : 19.27.0.0.250415 (37642901)
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

    * The `DUMPFILE` parameter now contains `%L`. Data Pump now creates multiple dump files (when needed) and generates unique file names. In earlier versions of Data Pump, you would use `%U` instead.
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
    * If one worker process is using parallel query processes (PQ), you will see fewer worker processes being active.
    * The parallel degree on export and on import is completely independent. You can export with `PARALLEL=4` and import with `PARALLEL=16` - even if you just have four dump files.
    * You can even import in parallel when you have just one dump file.
    * To avoid bottlenecks during parallel export, be sure to allow multiple dump files using the `%L` wildcard discussed above.
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

    -- Be sure to hit RETURN
    ```

    * Data Pump jobs - both export and import - are querying the data dictionary massively. 
    * To avoid issues with poorly performing SQLs ensure that the dictionary statistics are current.
    * Statistics on user-owned objects are normally not essential for Data Pump jobs. 
    * Oracle recommends gathering dictionary statistics before an export, before an import and immediately after an import.
    * You can also use `DBMS_STATS.GATHER_DICTIONARY_STATS`, but the Data Pump product management team recommends gathering schema statistics instead.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
     SQL*Plus: Release 19.0.0.0.0 - Production on Sat Apr 26 07:36:46 2025
     Version 19.27.0.0.0
     
     Copyright (c) 1982, 2022, Oracle.  All rights reserved.
     
     
     Connected to:
     Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
     Version 19.27.0.0.0
     
     SQL>   2    3    4    5
     
     PL/SQL procedure successfully completed.
     
     Disconnected from Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
     Version 19.27.0.0.0
    ```
    </details>  

6. Start an export.

    ```
    <copy>
    . ftex
    expdp dpuser/oracle parfile=/home/oracle/scripts/dp-04-bp-3.par
    </copy>

    -- Be sure to hit RETURN
    ```

    * Notice the enhanced diagnostics information in the log file. 
    * Each line is prefixed with a timestamp.
    * Multiple workers were employed. Each line tells you which worker did the job, notice the *W-1*, *W-2*, *W-3* and *W-4* labels.
    * During export of rows, you can also see that the *direct\_path* method was selected for all tables. 
    * In the end of the output, you can also see that Data Pump created a total of 24 dump files.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ .ftex
    $ rm /home/oracle/dpdir/*dmp
    $ expdp dpuser/oracle parfile=/home/oracle/scripts/dp-04-bp-3.par
    
    Export: Release 19.0.0.0.0 - Production on Sat Apr 26 07:43:05 2025
    Version 19.27.0.0.0
    
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
    * There are around 24 dump files. Your number might vary a little.

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
    * `JOB_NAME` assigns a custom name to the Data Pump job, so you can easily distinguish between the log files. You will learn more about `JOB_NAME` later on.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ cat /home/oracle/scripts/dp-04-comp-med.par
    schemas=f1
    directory=dpdir
    logfile=dp-04-comp-med-export.log
    metrics=yes
    logtime=all
    dumpfile=dp-04-comp-med-%L.dmp
    reuse_dumpfiles=yes
    filesize=1M
    parallel=4
    job_name=MEDIUM_COMPRESSION
    compression=all
    compression_algorithm=medium
    ```
    </details> 

2. Compare no compression with different algorithms, medium and high. Start three exports with different settings.

    ```
    <copy>
    . ftex
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
    $ expdp dpuser/oracle parfile=/home/oracle/scripts/dp-04-comp-no.par
    
    Export: Release 19.0.0.0.0 - Production on Sat May 3 06:12:52 2025
    Version 19.27.0.0.0
    
    Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.
    
    Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    03-MAY-25 06:12:54.554: Starting "DPUSER"."NO_COMPRESSION":  dpuser/******** parfile=/home/oracle/scripts/dp-04-comp-no.par
    03-MAY-25 06:12:54.940: W-1 Startup took 0 seconds
    03-MAY-25 06:12:56.218: W-3 Startup took 1 seconds
    03-MAY-25 06:12:56.232: W-4 Startup took 1 seconds
    03-MAY-25 06:12:56.255: W-2 Startup took 1 seconds
    03-MAY-25 06:12:56.655: W-4 Processing object type SCHEMA_EXPORT/TABLE/INDEX/STATISTICS/INDEX_STATISTICS
    03-MAY-25 06:12:56.710: W-3 Processing object type SCHEMA_EXPORT/TABLE/STATISTICS/TABLE_STATISTICS
    03-MAY-25 06:12:56.726: W-2 Processing object type SCHEMA_EXPORT/USER
    03-MAY-25 06:12:56.733: W-4      Completed 19 INDEX_STATISTICS objects in 0 seconds
    03-MAY-25 06:12:56.737: W-1 Processing object type SCHEMA_EXPORT/TABLE/TABLE_DATA
    03-MAY-25 06:12:56.739: W-3      Completed 14 TABLE_STATISTICS objects in 0 seconds
    03-MAY-25 06:12:56.742: W-2      Completed 1 USER objects in 0 seconds
    03-MAY-25 06:12:56.761: W-3 Processing object type SCHEMA_EXPORT/SYSTEM_GRANT
    03-MAY-25 06:12:56.763: W-3      Completed 2 SYSTEM_GRANT objects in 0 seconds
    03-MAY-25 06:12:56.769: W-1 Processing object type SCHEMA_EXPORT/DEFAULT_ROLE
    03-MAY-25 06:12:56.784: W-3 Processing object type SCHEMA_EXPORT/TABLESPACE_QUOTA
    03-MAY-25 06:12:56.786: W-3      Completed 1 TABLESPACE_QUOTA objects in 0 seconds
    03-MAY-25 06:12:56.790: W-1      Completed 1 DEFAULT_ROLE objects in 0 seconds
    03-MAY-25 06:12:56.986: W-3 Processing object type SCHEMA_EXPORT/PRE_SCHEMA/PROCACT_SCHEMA
    03-MAY-25 06:12:56.989: W-3      Completed 1 PROCACT_SCHEMA objects in 0 seconds
    03-MAY-25 06:12:58.968: W-3 Processing object type SCHEMA_EXPORT/TABLE/TABLE
    03-MAY-25 06:12:59.199: W-3      Completed 14 TABLE objects in 2 seconds
    03-MAY-25 06:12:59.617: W-4 Processing object type SCHEMA_EXPORT/STATISTICS/MARKER
    03-MAY-25 06:12:59.812: W-4      Completed 1 MARKER objects in 3 seconds
    03-MAY-25 06:13:00.291: W-4 . . exported "F1"."F1_RESULTS"                           1.429 MB   26439 rows in 0 seconds using direct_path
    03-MAY-25 06:13:00.329: W-4 . . exported "F1"."F1_DRIVERSTANDINGS"                   916.2 KB   34511 rows in 0 seconds using direct_path
    03-MAY-25 06:13:00.350: W-4 . . exported "F1"."F1_QUALIFYING"                        419.0 KB   10174 rows in 0 seconds using direct_path
    03-MAY-25 06:13:00.381: W-4 . . exported "F1"."F1_PITSTOPS"                          416.8 KB   10793 rows in 0 seconds using direct_path
    03-MAY-25 06:13:00.402: W-4 . . exported "F1"."F1_CONSTRUCTORSTANDINGS"              344.1 KB   13231 rows in 0 seconds using direct_path
    03-MAY-25 06:13:00.420: W-4 . . exported "F1"."F1_CONSTRUCTORRESULTS"                225.2 KB   12465 rows in 0 seconds using direct_path
    03-MAY-25 06:13:00.440: W-4 . . exported "F1"."F1_RACES"                             131.4 KB    1125 rows in 0 seconds using direct_path
    03-MAY-25 06:13:00.463: W-4 . . exported "F1"."F1_DRIVERS"                           87.86 KB     859 rows in 0 seconds using direct_path
    03-MAY-25 06:13:00.481: W-4 . . exported "F1"."F1_SPRINTRESULTS"                     29.88 KB     280 rows in 0 seconds using direct_path
    03-MAY-25 06:13:00.517: W-4 . . exported "F1"."F1_CONSTRUCTORS"                      22.97 KB     212 rows in 0 seconds using direct_path
    03-MAY-25 06:13:00.534: W-3 . . exported "F1"."F1_LAPTIMES"                          16.98 MB  571047 rows in 0 seconds using direct_path
    03-MAY-25 06:13:00.538: W-4 . . exported "F1"."F1_CIRCUITS"                          17.42 KB      77 rows in 0 seconds using direct_path
    03-MAY-25 06:13:00.553: W-4 . . exported "F1"."F1_SEASONS"                           10.03 KB      75 rows in 0 seconds using direct_path
    03-MAY-25 06:13:00.569: W-4 . . exported "F1"."F1_STATUS"                            7.843 KB     139 rows in 0 seconds using direct_path
    03-MAY-25 06:13:00.639: W-1 Processing object type SCHEMA_EXPORT/TABLE/CONSTRAINT/CONSTRAINT
    03-MAY-25 06:13:00.649: W-1      Completed 22 CONSTRAINT objects in 1 seconds
    03-MAY-25 06:13:01.311: W-2      Completed 14 SCHEMA_EXPORT/TABLE/TABLE_DATA objects in 0 seconds
    03-MAY-25 06:13:01.915: W-2 Master table "DPUSER"."NO_COMPRESSION" successfully loaded/unloaded
    03-MAY-25 06:13:01.917: ******************************************************************************
    03-MAY-25 06:13:01.917: Dump file set for DPUSER.NO_COMPRESSION is:
    03-MAY-25 06:13:01.919:   /home/oracle/dpdir/dp-04-comp-no-01.dmp
    03-MAY-25 06:13:01.919:   /home/oracle/dpdir/dp-04-comp-no-02.dmp
    03-MAY-25 06:13:01.919:   /home/oracle/dpdir/dp-04-comp-no-03.dmp
    03-MAY-25 06:13:01.919:   /home/oracle/dpdir/dp-04-comp-no-04.dmp
    03-MAY-25 06:13:01.920:   /home/oracle/dpdir/dp-04-comp-no-05.dmp
    03-MAY-25 06:13:01.920:   /home/oracle/dpdir/dp-04-comp-no-06.dmp
    03-MAY-25 06:13:01.920:   /home/oracle/dpdir/dp-04-comp-no-07.dmp
    03-MAY-25 06:13:01.920:   /home/oracle/dpdir/dp-04-comp-no-08.dmp
    03-MAY-25 06:13:01.920:   /home/oracle/dpdir/dp-04-comp-no-09.dmp
    03-MAY-25 06:13:01.920:   /home/oracle/dpdir/dp-04-comp-no-10.dmp
    03-MAY-25 06:13:01.921:   /home/oracle/dpdir/dp-04-comp-no-11.dmp
    03-MAY-25 06:13:01.921:   /home/oracle/dpdir/dp-04-comp-no-12.dmp
    03-MAY-25 06:13:01.921:   /home/oracle/dpdir/dp-04-comp-no-13.dmp
    03-MAY-25 06:13:01.921:   /home/oracle/dpdir/dp-04-comp-no-14.dmp
    03-MAY-25 06:13:01.921:   /home/oracle/dpdir/dp-04-comp-no-15.dmp
    03-MAY-25 06:13:01.922:   /home/oracle/dpdir/dp-04-comp-no-16.dmp
    03-MAY-25 06:13:01.922:   /home/oracle/dpdir/dp-04-comp-no-17.dmp
    03-MAY-25 06:13:01.922:   /home/oracle/dpdir/dp-04-comp-no-18.dmp
    03-MAY-25 06:13:01.922:   /home/oracle/dpdir/dp-04-comp-no-19.dmp
    03-MAY-25 06:13:01.922:   /home/oracle/dpdir/dp-04-comp-no-20.dmp
    03-MAY-25 06:13:01.922:   /home/oracle/dpdir/dp-04-comp-no-21.dmp
    03-MAY-25 06:13:01.923:   /home/oracle/dpdir/dp-04-comp-no-22.dmp
    03-MAY-25 06:13:01.923:   /home/oracle/dpdir/dp-04-comp-no-23.dmp
    03-MAY-25 06:13:01.923:   /home/oracle/dpdir/dp-04-comp-no-24.dmp
    03-MAY-25 06:13:01.923:   /home/oracle/dpdir/dp-04-comp-no-25.dmp
    03-MAY-25 06:13:01.939: Job "DPUSER"."NO_COMPRESSION" successfully completed at Sat May 3 06:13:01 2025 elapsed 0 00:00:08
    
    [FTEX:oracle@holserv1:~/dpdir]$     expdp dpuser/oracle parfile=/home/oracle/scripts/dp-04-comp-med.par
    
    Export: Release 19.0.0.0.0 - Production on Sat May 3 06:13:03 2025
    Version 19.27.0.0.0
    
    Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.
    
    Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    03-MAY-25 06:13:05.874: Starting "DPUSER"."MEDIUM_COMPRESSION":  dpuser/******** parfile=/home/oracle/scripts/dp-04-comp-med.par
    03-MAY-25 06:13:06.260: W-1 Startup took 1 seconds
    03-MAY-25 06:13:07.451: W-2 Startup took 0 seconds
    03-MAY-25 06:13:07.464: W-4 Startup took 0 seconds
    03-MAY-25 06:13:07.470: W-3 Startup took 0 seconds
    03-MAY-25 06:13:07.898: W-4 Processing object type SCHEMA_EXPORT/TABLE/INDEX/STATISTICS/INDEX_STATISTICS
    03-MAY-25 06:13:07.951: W-2 Processing object type SCHEMA_EXPORT/TABLE/STATISTICS/TABLE_STATISTICS
    03-MAY-25 06:13:07.964: W-4      Completed 19 INDEX_STATISTICS objects in 0 seconds
    03-MAY-25 06:13:07.968: W-2      Completed 14 TABLE_STATISTICS objects in 0 seconds
    03-MAY-25 06:13:07.979: W-4 Processing object type SCHEMA_EXPORT/SYSTEM_GRANT
    03-MAY-25 06:13:07.981: W-4      Completed 2 SYSTEM_GRANT objects in 0 seconds
    03-MAY-25 06:13:07.990: W-3 Processing object type SCHEMA_EXPORT/USER
    03-MAY-25 06:13:08.002: W-3      Completed 1 USER objects in 1 seconds
    03-MAY-25 06:13:08.011: W-4 Processing object type SCHEMA_EXPORT/DEFAULT_ROLE
    03-MAY-25 06:13:08.015: W-4      Completed 1 DEFAULT_ROLE objects in 0 seconds
    03-MAY-25 06:13:08.028: W-4 Processing object type SCHEMA_EXPORT/TABLESPACE_QUOTA
    03-MAY-25 06:13:08.031: W-4      Completed 1 TABLESPACE_QUOTA objects in 0 seconds
    03-MAY-25 06:13:08.237: W-4 Processing object type SCHEMA_EXPORT/PRE_SCHEMA/PROCACT_SCHEMA
    03-MAY-25 06:13:08.240: W-4      Completed 1 PROCACT_SCHEMA objects in 0 seconds
    03-MAY-25 06:13:08.247: W-1 Processing object type SCHEMA_EXPORT/TABLE/TABLE_DATA
    03-MAY-25 06:13:10.382: W-1 Processing object type SCHEMA_EXPORT/TABLE/TABLE
    03-MAY-25 06:13:10.490: W-1      Completed 14 TABLE objects in 2 seconds
    03-MAY-25 06:13:10.817: W-2 Processing object type SCHEMA_EXPORT/STATISTICS/MARKER
    03-MAY-25 06:13:10.985: W-2      Completed 1 MARKER objects in 3 seconds
    03-MAY-25 06:13:11.473: W-2 . . exported "F1"."F1_RESULTS"                           564.8 KB   26439 rows in 0 seconds using direct_path
    03-MAY-25 06:13:11.500: W-2 . . exported "F1"."F1_DRIVERSTANDINGS"                   284.7 KB   34511 rows in 0 seconds using direct_path
    03-MAY-25 06:13:11.540: W-2 . . exported "F1"."F1_QUALIFYING"                        167.0 KB   10174 rows in 0 seconds using direct_path
    03-MAY-25 06:13:11.571: W-2 . . exported "F1"."F1_PITSTOPS"                          172.7 KB   10793 rows in 0 seconds using direct_path
    03-MAY-25 06:13:11.594: W-2 . . exported "F1"."F1_CONSTRUCTORSTANDINGS"              108.2 KB   13231 rows in 0 seconds using direct_path
    03-MAY-25 06:13:11.613: W-2 . . exported "F1"."F1_CONSTRUCTORRESULTS"                78.46 KB   12465 rows in 0 seconds using direct_path
    03-MAY-25 06:13:11.635: W-2 . . exported "F1"."F1_RACES"                             28.92 KB    1125 rows in 0 seconds using direct_path
    03-MAY-25 06:13:11.649: W-2 . . exported "F1"."F1_DRIVERS"                           33.72 KB     859 rows in 0 seconds using direct_path
    03-MAY-25 06:13:11.668: W-2 . . exported "F1"."F1_SPRINTRESULTS"                     12.46 KB     280 rows in 0 seconds using direct_path
    03-MAY-25 06:13:11.686: W-2 . . exported "F1"."F1_CONSTRUCTORS"                      9.554 KB     212 rows in 0 seconds using direct_path
    03-MAY-25 06:13:11.704: W-2 . . exported "F1"."F1_CIRCUITS"                          8.625 KB      77 rows in 0 seconds using direct_path
    03-MAY-25 06:13:11.721: W-2 . . exported "F1"."F1_SEASONS"                           5.054 KB      75 rows in 0 seconds using direct_path
    03-MAY-25 06:13:11.742: W-2 . . exported "F1"."F1_STATUS"                            5.835 KB     139 rows in 0 seconds using direct_path
    03-MAY-25 06:13:11.746: W-4 . . exported "F1"."F1_LAPTIMES"                          6.212 MB  571047 rows in 0 seconds using direct_path
    03-MAY-25 06:13:11.866: W-1 Processing object type SCHEMA_EXPORT/TABLE/CONSTRAINT/CONSTRAINT
    03-MAY-25 06:13:11.882: W-1      Completed 22 CONSTRAINT objects in 1 seconds
    03-MAY-25 06:13:12.555: W-4      Completed 14 SCHEMA_EXPORT/TABLE/TABLE_DATA objects in 0 seconds
    03-MAY-25 06:13:13.116: W-4 Master table "DPUSER"."MEDIUM_COMPRESSION" successfully loaded/unloaded
    03-MAY-25 06:13:13.118: ******************************************************************************
    03-MAY-25 06:13:13.119: Dump file set for DPUSER.MEDIUM_COMPRESSION is:
    03-MAY-25 06:13:13.120:   /home/oracle/dpdir/dp-04-comp-med-01.dmp
    03-MAY-25 06:13:13.120:   /home/oracle/dpdir/dp-04-comp-med-02.dmp
    03-MAY-25 06:13:13.121:   /home/oracle/dpdir/dp-04-comp-med-03.dmp
    03-MAY-25 06:13:13.121:   /home/oracle/dpdir/dp-04-comp-med-04.dmp
    03-MAY-25 06:13:13.121:   /home/oracle/dpdir/dp-04-comp-med-05.dmp
    03-MAY-25 06:13:13.121:   /home/oracle/dpdir/dp-04-comp-med-06.dmp
    03-MAY-25 06:13:13.121:   /home/oracle/dpdir/dp-04-comp-med-07.dmp
    03-MAY-25 06:13:13.122:   /home/oracle/dpdir/dp-04-comp-med-08.dmp
    03-MAY-25 06:13:13.122:   /home/oracle/dpdir/dp-04-comp-med-09.dmp
    03-MAY-25 06:13:13.122:   /home/oracle/dpdir/dp-04-comp-med-10.dmp
    03-MAY-25 06:13:13.122:   /home/oracle/dpdir/dp-04-comp-med-11.dmp
    03-MAY-25 06:13:13.135: Job "DPUSER"."MEDIUM_COMPRESSION" successfully completed at Sat May 3 06:13:13 2025 elapsed 0 00:00:08
    
    [FTEX:oracle@holserv1:~/dpdir]$     expdp dpuser/oracle parfile=/home/oracle/scripts/dp-04-comp-high.par
    
    Export: Release 19.0.0.0.0 - Production on Sat May 3 06:13:23 2025
    Version 19.27.0.0.0
    
    Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.
    
    Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    03-MAY-25 06:13:25.438: Starting "DPUSER"."HIGH_COMPRESSION":  dpuser/******** parfile=/home/oracle/scripts/dp-04-comp-high.par
    03-MAY-25 06:13:25.852: W-1 Startup took 0 seconds
    03-MAY-25 06:13:27.106: W-2 Startup took 1 seconds
    03-MAY-25 06:13:27.120: W-3 Startup took 1 seconds
    03-MAY-25 06:13:27.152: W-4 Startup took 1 seconds
    03-MAY-25 06:13:27.500: W-1 Processing object type SCHEMA_EXPORT/TABLE/TABLE_DATA
    03-MAY-25 06:13:27.546: W-3 Processing object type SCHEMA_EXPORT/TABLE/INDEX/STATISTICS/INDEX_STATISTICS
    03-MAY-25 06:13:27.548: W-2 Processing object type SCHEMA_EXPORT/TABLE/STATISTICS/TABLE_STATISTICS
    03-MAY-25 06:13:27.605: W-1 Processing object type SCHEMA_EXPORT/USER
    03-MAY-25 06:13:27.612: W-2      Completed 14 TABLE_STATISTICS objects in 0 seconds
    03-MAY-25 06:13:27.615: W-3      Completed 19 INDEX_STATISTICS objects in 0 seconds
    03-MAY-25 06:13:27.620: W-1      Completed 1 USER objects in 0 seconds
    03-MAY-25 06:13:27.621: W-4 Processing object type SCHEMA_EXPORT/SYSTEM_GRANT
    03-MAY-25 06:13:27.634: W-4      Completed 2 SYSTEM_GRANT objects in 0 seconds
    03-MAY-25 06:13:27.638: W-1 Processing object type SCHEMA_EXPORT/DEFAULT_ROLE
    03-MAY-25 06:13:27.641: W-1      Completed 1 DEFAULT_ROLE objects in 0 seconds
    03-MAY-25 06:13:27.651: W-4 Processing object type SCHEMA_EXPORT/TABLESPACE_QUOTA
    03-MAY-25 06:13:27.655: W-4      Completed 1 TABLESPACE_QUOTA objects in 0 seconds
    03-MAY-25 06:13:27.841: W-3 Processing object type SCHEMA_EXPORT/PRE_SCHEMA/PROCACT_SCHEMA
    03-MAY-25 06:13:27.844: W-3      Completed 1 PROCACT_SCHEMA objects in 0 seconds
    03-MAY-25 06:13:30.086: W-1 Processing object type SCHEMA_EXPORT/TABLE/TABLE
    03-MAY-25 06:13:30.624: W-2 Processing object type SCHEMA_EXPORT/STATISTICS/MARKER
    03-MAY-25 06:13:30.827: W-2      Completed 1 MARKER objects in 3 seconds
    03-MAY-25 06:13:31.244: W-1      Completed 14 TABLE objects in 3 seconds
    03-MAY-25 06:13:32.035: W-3 Processing object type SCHEMA_EXPORT/TABLE/CONSTRAINT/CONSTRAINT
    03-MAY-25 06:13:32.075: W-3      Completed 22 CONSTRAINT objects in 2 seconds
    03-MAY-25 06:13:32.248: W-4 . . exported "F1"."F1_RESULTS"                           449.3 KB   26439 rows in 1 seconds using direct_path
    03-MAY-25 06:13:32.502: W-4 . . exported "F1"."F1_DRIVERSTANDINGS"                   228.6 KB   34511 rows in 0 seconds using direct_path
    03-MAY-25 06:13:32.609: W-4 . . exported "F1"."F1_QUALIFYING"                        139.6 KB   10174 rows in 0 seconds using direct_path
    03-MAY-25 06:13:32.706: W-4 . . exported "F1"."F1_PITSTOPS"                            139 KB   10793 rows in 0 seconds using direct_path
    03-MAY-25 06:13:32.798: W-4 . . exported "F1"."F1_CONSTRUCTORSTANDINGS"              88.67 KB   13231 rows in 0 seconds using direct_path
    03-MAY-25 06:13:32.872: W-4 . . exported "F1"."F1_CONSTRUCTORRESULTS"                65.96 KB   12465 rows in 0 seconds using direct_path
    03-MAY-25 06:13:32.896: W-4 . . exported "F1"."F1_RACES"                             23.91 KB    1125 rows in 0 seconds using direct_path
    03-MAY-25 06:13:32.917: W-4 . . exported "F1"."F1_DRIVERS"                           30.44 KB     859 rows in 0 seconds using direct_path
    03-MAY-25 06:13:32.939: W-4 . . exported "F1"."F1_SPRINTRESULTS"                     11.27 KB     280 rows in 0 seconds using direct_path
    03-MAY-25 06:13:32.957: W-4 . . exported "F1"."F1_CONSTRUCTORS"                      9.226 KB     212 rows in 0 seconds using direct_path
    03-MAY-25 06:13:32.975: W-4 . . exported "F1"."F1_CIRCUITS"                          8.445 KB      77 rows in 0 seconds using direct_path
    03-MAY-25 06:13:32.993: W-4 . . exported "F1"."F1_SEASONS"                               5 KB      75 rows in 0 seconds using direct_path
    03-MAY-25 06:13:33.009: W-4 . . exported "F1"."F1_STATUS"                            5.765 KB     139 rows in 1 seconds using direct_path
    03-MAY-25 06:13:34.883: W-2 . . exported "F1"."F1_LAPTIMES"                          4.893 MB  571047 rows in 3 seconds using direct_path
    03-MAY-25 06:13:35.555: W-4      Completed 14 SCHEMA_EXPORT/TABLE/TABLE_DATA objects in 3 seconds
    03-MAY-25 06:13:36.192: W-4 Master table "DPUSER"."HIGH_COMPRESSION" successfully loaded/unloaded
    03-MAY-25 06:13:36.194: ******************************************************************************
    03-MAY-25 06:13:36.194: Dump file set for DPUSER.HIGH_COMPRESSION is:
    03-MAY-25 06:13:36.195:   /home/oracle/dpdir/dp-04-comp-high-01.dmp
    03-MAY-25 06:13:36.196:   /home/oracle/dpdir/dp-04-comp-high-02.dmp
    03-MAY-25 06:13:36.196:   /home/oracle/dpdir/dp-04-comp-high-03.dmp
    03-MAY-25 06:13:36.196:   /home/oracle/dpdir/dp-04-comp-high-04.dmp
    03-MAY-25 06:13:36.196:   /home/oracle/dpdir/dp-04-comp-high-05.dmp
    03-MAY-25 06:13:36.196:   /home/oracle/dpdir/dp-04-comp-high-06.dmp
    03-MAY-25 06:13:36.197:   /home/oracle/dpdir/dp-04-comp-high-07.dmp
    03-MAY-25 06:13:36.197:   /home/oracle/dpdir/dp-04-comp-high-08.dmp
    03-MAY-25 06:13:36.197:   /home/oracle/dpdir/dp-04-comp-high-09.dmp
    03-MAY-25 06:13:36.210: Job "DPUSER"."HIGH_COMPRESSION" successfully completed at Sat May 3 06:13:36 2025 elapsed 0 00:00:12
    ```
    </details> 

3. Check the runtime of the exports.

    ```
    <copy>
    cd /home/oracle/dpdir
    grep "Job" dp-04-comp-*log
    </copy>

    -- Be sure to hit RETURN
    ```

    * Check the elapsed time at the end of each line. 
    * How much slower was the job with medium and high compression compared to no compression?
    * In the example in the instructions, the job with no compression ran for 10 seconds, so did the one with medium compression.
    * Using high compression caused the job to run for 3 seconds more - but that's also a 30 % increase.
    * Medium gives a good compression ratio without affecting the runtime significantly.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    dp-04-comp-high-export.log:03-MAY-25 06:13:36.210: Job "DPUSER"."HIGH_COMPRESSION" successfully completed at Sat May 3 06:13:36 2025 elapsed 0 00:00:12
    dp-04-comp-med-export.log:03-MAY-25 06:13:13.135: Job "DPUSER"."MEDIUM_COMPRESSION" successfully completed at Sat May 3 06:13:13 2025 elapsed 0 00:00:08
    dp-04-comp-no-export.log:03-MAY-25 06:13:01.939: Job "DPUSER"."NO_COMPRESSION" successfully completed at Sat May 3 06:13:01 2025 elapsed 0 00:00:08
    ```
    </details> 

3. Check the size of the dump files.

    ```
    <copy>
    echo "No compression: "$(du -ch dp-04-comp-no-*.dmp | tail -1 | cut -f 1)
    echo "Medium compression: "$(du -ch dp-04-comp-med-*.dmp | tail -1 | cut -f 1)
    echo "High compression: "$(du -ch dp-04-comp-high*.dmp | tail -1 | cut -f 1)
    cd
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
    No compression: 22M
    Medium compression: 7.9M
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
    expdp dpuser/oracle parfile=/home/oracle/scripts/dp-04-consistent.par
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ . ftex
    $ expdp dpuser/oracle parfile=/home/oracle/scripts/dp-04-consistent.par
    
    Export: Release 19.0.0.0.0 - Production on Mon Apr 28 05:25:51 2025
    Version 19.27.0.0.0
    
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
* **Contributors** - William Beauregard, Rodrigo Jorge, Mike Dietrich, Klaus Gronau, Alex Zaballa
* **Last Updated By/Date** - Daniel Overby Hansen, May 2025