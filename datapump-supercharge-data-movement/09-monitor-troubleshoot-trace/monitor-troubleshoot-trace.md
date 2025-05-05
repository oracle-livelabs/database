# Monitoring, Troubleshooting and Tracing

## Introduction

Occasionally, things don't go as planned. When that happens, you can rely on instrumentation in Data Pump that will provide you better understanding of what's going on. In this lab, you will learn ways of monitoring Data Pump and dig deeper into the details with tracing.

Estimated Time: 20 Minutes

### Objectives

In this lab, you will:

* Monitor, troubleshoot and trace

### Prerequisites

This lab assumes:

- You have completed Lab 7: Checksum and Encryption

## Task 1: Monitoring

In lab 5, you learned about the interactive console and the `STATUS` command. You also used a few views in the database. In Oracle Database 23ai, there are new views with even better details on your Data Pump jobs. 

1. Use the *yellow* terminal 🟨. Copy an existing dump file to the *DPDIR* directory.

    ```
    <copy>
    cp /home/oracle/scripts/faster-import-constraints.dmp /home/oracle/dpdir/monitoring.dmp
    </copy>
    ```

2. Examine a pre-created parameter file.

    ```
    <copy>
    cat /home/oracle/scripts/dp-09-monitor-import.par
    </copy>
    ```

    * This is a regular import.
    * Notice the `JOB_NAME` parameter. This gives the Data Pump a specific name, so you can easily attach to the Data Pump from a different session. The import will run for a while and you will attach to the job and monitor it.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    directory=dpdir
    dumpfile=monitoring.dmp
    parallel=4
    logfile=dp-09-monitor-import.log
    logtime=all
    metrics=yes
    job_name=MONITORING
    ```
    </details> 

3. Start the import.

    ```
    <copy>
    . cdb23
    impdp dpuser/oracle@localhost/red parfile=/home/oracle/scripts/dp-09-monitor-import.par
    </copy>

    -- Be sure to hit RETURN
    ```

    * Don't wait for the import to complete.
    * Leave it running in the *yellow* terminal 🟨.
    * Move on to the next step.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    Import: Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems on Fri May 2 13:28:52 2025
    Version 23.8.0.25.04
    
    Copyright (c) 1982, 2025, Oracle and/or its affiliates.  All rights reserved.
    
    Connected to: Oracle Database 23ai Enterprise Edition Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems
    
    02-MAY-25 13:28:56.316: W-1 Startup on instance 1 took 1 seconds
    02-MAY-25 13:28:57.531: W-1 Master table "DPUSER"."MONITORING" successfully loaded/unloaded
    02-MAY-25 13:28:57.797: Starting "DPUSER"."MONITORING":  dpuser/********@localhost/red parfile=/home/oracle/scripts/dp-09-monitor-import.par
    02-MAY-25 13:28:57.835: W-1 Processing object type SCHEMA_EXPORT/USER
    02-MAY-25 13:28:57.994: W-1      Completed 1 USER objects in 0 seconds
    02-MAY-25 13:28:57.994: W-1      Completed by worker 1 1 USER objects in 0 seconds
    02-MAY-25 13:28:57.996: W-1 Processing object type SCHEMA_EXPORT/SYSTEM_GRANT
    02-MAY-25 13:28:58.028: W-1      Completed 1 SYSTEM_GRANT objects in 1 seconds
    02-MAY-25 13:28:58.028: W-1      Completed by worker 1 1 SYSTEM_GRANT objects in 0 seconds
    02-MAY-25 13:28:58.030: W-1 Processing object type SCHEMA_EXPORT/ROLE_GRANT
    02-MAY-25 13:28:58.069: W-1      Completed 1 ROLE_GRANT objects in 0 seconds
    02-MAY-25 13:28:58.069: W-1      Completed by worker 1 1 ROLE_GRANT objects in 0 seconds
    02-MAY-25 13:28:58.071: W-1 Processing object type SCHEMA_EXPORT/DEFAULT_ROLE
    02-MAY-25 13:28:58.100: W-1      Completed 1 DEFAULT_ROLE objects in 0 seconds
    02-MAY-25 13:28:58.100: W-1      Completed by worker 1 1 DEFAULT_ROLE objects in 0 seconds
    02-MAY-25 13:28:58.117: W-1 Processing object type SCHEMA_EXPORT/PRE_SCHEMA/PROCACT_SCHEMA/LOGREP
    02-MAY-25 13:28:58.184: W-1      Completed 1 LOGREP objects in 0 seconds
    02-MAY-25 13:28:58.217: W-1 Processing object type SCHEMA_EXPORT/TABLE/TABLE
    02-MAY-25 13:28:58.874: W-4 Startup on instance 1 took 0 seconds
    02-MAY-25 13:28:58.887: W-3 Startup on instance 1 took 0 seconds
    02-MAY-25 13:28:58.917: W-2 Startup on instance 1 took 0 seconds
    02-MAY-25 13:28:59.045: W-1      Completed 4 TABLE objects in 1 seconds
    02-MAY-25 13:28:59.045: W-1      Completed by worker 1 1 TABLE objects in 0 seconds
    02-MAY-25 13:28:59.045: W-1      Completed by worker 2 1 TABLE objects in 1 seconds
    02-MAY-25 13:28:59.045: W-1      Completed by worker 3 1 TABLE objects in 1 seconds
    02-MAY-25 13:28:59.045: W-1      Completed by worker 4 1 TABLE objects in 0 seconds
    02-MAY-25 13:28:59.072: W-4 Processing object type SCHEMA_EXPORT/TABLE/TABLE_DATA
    ```
    </details> 

4. Now, switch to the *blue* 🟦 terminal. Connect to the same database.

    ```
    <copy>
    . cdb23
    sqlplus / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

4. Switch into the *RED* PDB and query one of the new views.

    ```
    <copy>
    alter session set container=red;
    set line 150
    col program format a60
    select program, sessionid, status 
    from   v$datapump_process_info 
    where  jobname='MONITORING';
    </copy>

    -- Be sure to hit RETURN
    ```

    * There are five Data Pump processes.
    * The control process (formerly known as the *master process*) is seen as *DM00*.
    * The four workers are seen as *DW0n*.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    PROGRAM                                                      SESSIONID  STATUS
    ------------------------------------------------------------ ---------- --------
    oracle@holserv1.livelabs.oraclevcn.com (DM00)                       366 ACTIVE
    oracle@holserv1.livelabs.oraclevcn.com (DW03)                       191 ACTIVE
    oracle@holserv1.livelabs.oraclevcn.com (DW01)                        10 ACTIVE
    oracle@holserv1.livelabs.oraclevcn.com (DW02)                        77 ACTIVE
    oracle@holserv1.livelabs.oraclevcn.com (DW00)                       428 ACTIVE
    ```
    </details> 

5. What are the current waits?

    ```
    <copy>
    col event format a40
    select waiting_session, event, dp_state_in_wait 
    from v$datapump_sessionwait_info;
    </copy>

    -- Be sure to hit RETURN
    ```

    * One process is busy during *direct path sync*. Perhaps this database doesn't use direct I/O (`FILESYSTEMIO_OPTIONS=SETALL`). 
    * The other processes are waiting for *log buffer space*. Perhaps you could tune the system by putting redo logs on faster disks, implementing more redo log groups or larger redo log members, or even importing with the `NOLOGGING` clause. You could implement the latter with `TRANSFORM=DISABLE_ARCHIVE_LOGGING:Y`.
    * Occasionally, you will find *enq: TT - contention*. This is caused by bigfile tablespace extension. You could solve that by increasing the size of the data files in advance.
    * There are additional columns in the view that can supply additional information about the wait event, like which objects it involves.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    WAITING_SESSION EVENT                                                        DP_STATE_IN_WAIT
    --------------- ------------------------------------------------------------ -------------------
    10              direct path sync                                             WAITING
    77              log buffer space                                             WAITING
    191             log buffer space                                             WAITING
    428             log buffer space                                             WAITING  
    ```
    </details> 

6. Check the details on the last of the new views.

    ```
    <copy>
    desc v$datapump_processwait_info
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    Name                                      Null?    Type
    ----------------------------------------- -------- ----------------------------
    WAITING_SESSION                                    NUMBER
    HOLDING_SESSION                                    NUMBER
    SERIAL_NUMBER                                      NUMBER
    EVENT                                              VARCHAR2(64)
    PROGRAM_WAITSESSION                                VARCHAR2(84)
    PROGRAM_HOLDINGDSESSION                            VARCHAR2(84)
    MODULE_WAITSESSION                                 VARCHAR2(64)
    MODULE_HOLDINGSESSION                              VARCHAR2(64)
    DATAPUMP_LOCKID                                    NUMBER
    CON_ID                                             NUMBER
    ```
    </details> 

7. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```

8. Switch back to the *yellow* terminal 🟨. If the job is still running, you can stop it. While you watch the Data Pump log output, hit `CTRL+C`. This takes you from the log output to the interactive console.

    ```
    CTRL+C
    ```

    * Hit `CTRL+C` only once.
    * In lab 5, *Faster Imports*, you learned how to use the interactive console.

9. Now, kill the job.

    ```
    <copy>
    kill_job
    </copy>
    ```

    * Confirm by inputting `YES`.
    * It takes a little while for Data Pump to stop the job. 

10. Drop the schema that was imported.


    ```
    <copy>
    . cdb23
    sqlplus / as sysdba<<EOF
       alter session set container=red;
       drop user constr_validate cascade;
    EOF
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL*Plus: Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems on Fri May 2 14:11:48 2025
    Version 23.8.0.25.04
    
    Copyright (c) 1982, 2025, Oracle.  All rights reserved.
    
    
    Connected to:
    Oracle Database 23ai Enterprise Edition Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems
    Version 23.8.0.25.04
    
    SQL>
    Session altered.
    
    SQL>
    User dropped.
    
    Disconnected from Oracle Database 23ai Enterprise Edition Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems
    Version 23.8.0.25.04
    ```
    </details> 

## Task 2: Control table and abort_step

The control table contains information about the data and metadata in the dump file. Plus, Data Pump uses it to keep track of the job.

1. Still in the *yellow* terminal 🟨. Start the import from task 1 again. However, this time you import just the control table from the dump file.

    ```
    <copy>
    . cdb23
    impdp dpuser/oracle@localhost/red parfile=/home/oracle/scripts/dp-09-monitor-import.par master_only=yes
    </copy>

    -- Be sure to hit RETURN
    ```

    * You use the parameter `MASTER_ONLY` to inform Data Pump to import just the control file.
    * Data Pump writes the name of the control file in the output.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    Import: Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems on Fri May 2 14:17:49 2025
    Version 23.8.0.25.04
    
    Copyright (c) 1982, 2025, Oracle and/or its affiliates.  All rights reserved.
    
    Connected to: Oracle Database 23ai Enterprise Edition Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems
    02-MAY-25 14:17:51.732: W-1 Startup on instance 1 took 0 seconds
    02-MAY-25 14:17:52.724: W-1 Master table "DPUSER"."MONITORING" successfully loaded/unloaded
    02-MAY-25 14:17:52.733: Job "DPUSER"."MONITORING" successfully completed at Fri May 2 14:17:52 2025 elapsed 0 00:00:02    
    ```
    </details> 
    
2. Connect to the database.

    ```
    <copy>
    sqlplus dpuser/oracle@localhost/red
    </copy>

    -- Be sure to hit RETURN
    ```

3. Describe the control table.

    ```
    <copy>
    desc dpuser.monitoring
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    Name                                      Null?    Type
    ----------------------------------------- -------- ----------------------------
    ABORT_STEP                                         NUMBER
    ACCESS_METHOD                                      VARCHAR2(16)
    ANCESTOR_OBJECT_NAME                               VARCHAR2(128)
    ANCESTOR_OBJECT_SCHEMA                             VARCHAR2(128)
    ANCESTOR_OBJECT_TYPE                               VARCHAR2(128)
         
    (output truncated)         
         
    VALUE_N                                            NUMBER
    VALUE_T                                            VARCHAR2(4000)
    VERSION                                            NUMBER
    WORK_ITEM                                          VARCHAR2(21)
    XML_CLOB                                           CLOB
    ```
    </details> 

4. Make a list of the object paths planned to be executed by Data Pump. 

    ```
    <copy>
    set line 150
    set pagesize 200
    col object_name format a30
    col object_type format a30
    select object_name, object_type, process_order 
    from dpuser.monitoring 
    where process_order > 0
    order by process_order;
    </copy>

    -- Be sure to hit RETURN
    ```

    * By ordering on `PROCESS_ORDER` you can get an idea on the order how Data Pump does things.
    * First, getting the schema in, then tables, then rows and finally the constraints.
    * Notice how `TABLE_DATA` starts at `PROCESS_ORDER=10`. Data Pump will start loading rows at this step.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    OBJECT_NAME                    OBJECT_TYPE                    PROCESS_ORDER
    ------------------------------ ------------------------------ -------------
    CONSTR_VALIDATE                USER                           1
    UNLIMITED TABLESPACE           SYSTEM_GRANT                   2
    DBA                            ROLE_GRANT                     3
                                   DEFAULT_ROLE                   4
                                   PROCACT_SCHEMA                 5
    T1                             TABLE                          6
    T3                             TABLE                          7
    T4                             TABLE                          8
    T2                             TABLE                          9
    T1                             TABLE_DATA                     10
                                                                  10
    T2                             TABLE_DATA                     11
                                                                  11
    T3                             TABLE_DATA                     12
                                                                  12
                                                                  13
    T4                             TABLE_DATA                     13
    C_TAB1_C01                     CONSTRAINT                     14
    
    (output truncated)
    
    C_TAB2_C17                     CONSTRAINT                     102
    C_TAB2_C06                     CONSTRAINT                     103
    C_TAB2_C12                     CONSTRAINT                     104
    C_TAB2_C02                     CONSTRAINT                     105    
    ```
    </details> 

5. Drop the control table.    

    ```
    <copy>
    drop table dpuser.monitoring purge;
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> drop table dpuser.monitoring purge;
    
    Table dropped.
    ```
    </details> 

6. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```

7. Start the import again, but stop at step 10. This is right before loading rows in the `TABLE_DATA` phase. You found this in the query on the control table using the `PROCESS_ORDER` column.

    ```
    <copy>
    . cdb23
    impdp dpuser/oracle@localhost/red parfile=/home/oracle/scripts/dp-09-monitor-import.par abort_step=10
    </copy>

    -- Be sure to hit RETURN
    ```

    * The `ABORT_STEP` parameter tells Data Pump to stop the job right before starting this phase.
    * From the output, you can see that Data Pump creates the user and tables, but stops right before loading rows.
    * If you want to stop the job right after loading the control table, you can use `ABORT_STEP=-1` instead.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    Import: Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems on Fri May 2 14:34:10 2025
    Version 23.8.0.25.04
    
    Copyright (c) 1982, 2025, Oracle and/or its affiliates.  All rights reserved.
    
    Connected to: Oracle Database 23ai Enterprise Edition Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems
    02-MAY-25 14:34:12.100: W-1 Startup on instance 1 took 1 seconds
    02-MAY-25 14:34:12.291: W-1 Master table "DPUSER"."MONITORING" successfully loaded/unloaded
    02-MAY-25 14:34:12.514: Starting "DPUSER"."MONITORING":  dpuser/********@localhost/red parfile=/home/oracle/scripts/dp-09-monitor-import.par abort_step=10
    02-MAY-25 14:34:12.549: W-1 Processing object type SCHEMA_EXPORT/USER
    02-MAY-25 14:34:12.697: W-1      Completed 1 USER objects in 0 seconds
    02-MAY-25 14:34:12.697: W-1      Completed by worker 1 1 USER objects in 0 seconds
    02-MAY-25 14:34:12.699: W-1 Processing object type SCHEMA_EXPORT/SYSTEM_GRANT
    02-MAY-25 14:34:12.726: W-1      Completed 1 SYSTEM_GRANT objects in 0 seconds
    02-MAY-25 14:34:12.726: W-1      Completed by worker 1 1 SYSTEM_GRANT objects in 0 seconds
    02-MAY-25 14:34:12.728: W-1 Processing object type SCHEMA_EXPORT/ROLE_GRANT
    02-MAY-25 14:34:12.755: W-1      Completed 1 ROLE_GRANT objects in 0 seconds
    02-MAY-25 14:34:12.755: W-1      Completed by worker 1 1 ROLE_GRANT objects in 0 seconds
    02-MAY-25 14:34:12.757: W-1 Processing object type SCHEMA_EXPORT/DEFAULT_ROLE
    02-MAY-25 14:34:12.785: W-1      Completed 1 DEFAULT_ROLE objects in 0 seconds
    02-MAY-25 14:34:12.785: W-1      Completed by worker 1 1 DEFAULT_ROLE objects in 0 seconds
    02-MAY-25 14:34:12.801: W-1 Processing object type SCHEMA_EXPORT/PRE_SCHEMA/PROCACT_SCHEMA/LOGREP
    02-MAY-25 14:34:12.848: W-1      Completed 1 LOGREP objects in 0 seconds
    02-MAY-25 14:34:12.883: W-1 Processing object type SCHEMA_EXPORT/TABLE/TABLE
    02-MAY-25 14:34:13.190: W-3 Startup on instance 1 took 1 seconds
    02-MAY-25 14:34:13.192: W-4 Startup on instance 1 took 1 seconds
    02-MAY-25 14:34:13.225: W-2 Startup on instance 1 took 1 seconds
    02-MAY-25 14:34:13.555: W-2      Completed 4 TABLE objects in 1 seconds
    02-MAY-25 14:34:13.555: W-2      Completed by worker 1 1 TABLE objects in 1 seconds
    02-MAY-25 14:34:13.555: W-2      Completed by worker 2 1 TABLE objects in 0 seconds
    02-MAY-25 14:34:13.555: W-2      Completed by worker 3 1 TABLE objects in 0 seconds
    02-MAY-25 14:34:13.555: W-2      Completed by worker 4 1 TABLE objects in 0 seconds
    02-MAY-25 14:34:13.581: W-1 Processing object type SCHEMA_EXPORT/TABLE/TABLE_DATA
    02-MAY-25 14:34:13.647: ORA-31697: aborting operation at process order number 10
    02-MAY-25 14:34:13.660: Job "DPUSER"."MONITORING" stopped due to fatal error at Fri May 2 14:34:13 2025 elapsed 0 00:00:02
    ```
    </details> 

8. The import is now partially completed. Attach to the job.

    ```
    <copy>
    . cdb23
    impdp dpuser/oracle@localhost/red attach=monitoring
    </copy>

    -- Be sure to hit RETURN
    ```

    * Scroll through the output. 
    * Data Pump is in state *IDLING*.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    Import: Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems on Fri May 2 14:34:36 2025
    Version 23.8.0.25.04
    
    Copyright (c) 1982, 2025, Oracle and/or its affiliates.  All rights reserved.
    
    Connected to: Oracle Database 23ai Enterprise Edition Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems
    
    Job: MONITORING
      Owner: DPUSER
      Operation: IMPORT
      Creator Privs: TRUE
      GUID: 34290B296DCCC2CDE063A601000AE891
      Start Time: Friday, 02 May, 2025 14:34:37
      Mode: FULL
      Instance: CDB23
      Max Parallelism: 4
      Timezone: +00:00
      Timezone version: 42
      Export timezone version: 44
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
         CLIENT_COMMAND        dpuser/********@localhost/red parfile=/home/oracle/scripts/dp-09-monitor-import.par abort_step=10
         LOGTIME               ALL
         METRICS               1
         TRACE                 0
      State: IDLING
      Bytes Processed: 0
      Current Parallelism: 4
      Job Error Count: 0
      Job heartbeat: 0
      Dump File: /home/oracle/dpdir/monitoring.dmp
    
    Worker 1 Status:
      Instance ID: 1
      Instance name: CDB23
      Host name: holserv1.livelabs.oraclevcn.com
      Object start time: Friday, 02 May, 2025 14:34:13
      Object status at: Friday, 02 May, 2025 14:34:13
      Process Name: DW00
      State: UNDEFINED
      Object Schema: CONSTR_VALIDATE
      Object Name: T4
      Object Type: SCHEMA_EXPORT/TABLE/TABLE_DATA
      Completed Objects: 1
      Completed Bytes: 400,209,328
      Worker Parallelism: 1
    
    Worker 2 Status:
      Instance ID: 1
      Instance name: CDB23
      Host name: holserv1.livelabs.oraclevcn.com
      Object start time: Friday, 02 May, 2025 14:34:13
      Object status at: Friday, 02 May, 2025 14:34:13
      Process Name: DW01
      State: UNDEFINED
      Object Schema: CONSTR_VALIDATE
      Object Name: T3
      Object Type: SCHEMA_EXPORT/TABLE/TABLE_DATA
      Completed Objects: 1
      Completed Bytes: 400,199,144
      Worker Parallelism: 1
    
    Worker 3 Status:
      Instance ID: 1
      Instance name: CDB23
      Host name: holserv1.livelabs.oraclevcn.com
      Object start time: Friday, 02 May, 2025 14:34:13
      Object status at: Friday, 02 May, 2025 14:34:13
      Process Name: DW02
      State: UNDEFINED
    
    Worker 4 Status:
      Instance ID: 1
      Instance name: CDB23
      Host name: holserv1.livelabs.oraclevcn.com
      Object start time: Friday, 02 May, 2025 14:34:13
      Object status at: Friday, 02 May, 2025 14:34:13
      Process Name: DW03
      State: UNDEFINED
      Object Schema: CONSTR_VALIDATE
      Object Name: T2
      Object Type: SCHEMA_EXPORT/TABLE/TABLE_DATA
      Completed Objects: 1
      Completed Bytes: 400,257,480
      Worker Parallelism: 1    
    ```
    </details> 

9. Use the interactive console to restart the job.    

    ```
    <copy>
    start_job
    </copy>
    ```

10. Wait a few seconds and get the latest status.
    
    ```
    <copy>
    status
    </copy>
    ```

    * Notice the state is now *EXECUTING*.
    * The workers should be busy loading rows. 
    * Run the `STATUS` command a few times and see how the *Completed rows* increases.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    Import> status
    
    Job: MONITORING
      Operation: IMPORT
      Mode: FULL
      State: EXECUTING
      Bytes Processed: 0
      Current Parallelism: 4
      Job Error Count: 0
      Job heartbeat: 1
      Dump File: /home/oracle/dpdir/monitoring.dmp
    
    Worker 1 Status:
      Instance ID: 1
      Instance name: CDB23
      Host name: holserv1.livelabs.oraclevcn.com
      Object start time: Friday, 02 May, 2025 14:35:13
      Object status at: Friday, 02 May, 2025 14:35:13
      Process Name: DW00
      State: EXECUTING
      Object Schema: CONSTR_VALIDATE
      Object Name: T1
      Object Type: SCHEMA_EXPORT/TABLE/TABLE_DATA
      Completed Objects: 1
      Completed Rows: 2,655,587
      Completed Bytes: 400,185,632
      Percent Done: 11
      Worker Parallelism: 1
    
    Worker 2 Status:
      Instance ID: 1
      Instance name: CDB23
      Host name: holserv1.livelabs.oraclevcn.com
      Object start time: Friday, 02 May, 2025 14:35:13
      Object status at: Friday, 02 May, 2025 14:35:13
      Process Name: DW01
      State: EXECUTING
      Object Schema: CONSTR_VALIDATE
      Object Name: T2
      Object Type: SCHEMA_EXPORT/TABLE/TABLE_DATA
      Completed Objects: 1
      Completed Rows: 2,655,911
      Completed Bytes: 400,257,480
      Percent Done: 11
      Worker Parallelism: 1
    
    Worker 3 Status:
      Instance ID: 1
      Instance name: CDB23
      Host name: holserv1.livelabs.oraclevcn.com
      Object start time: Friday, 02 May, 2025 14:35:13
      Object status at: Friday, 02 May, 2025 14:35:13
      Process Name: DW02
      State: EXECUTING
      Object Schema: CONSTR_VALIDATE
      Object Name: T4
      Object Type: SCHEMA_EXPORT/TABLE/TABLE_DATA
      Completed Objects: 1
      Completed Rows: 2,656,201
      Completed Bytes: 400,209,328
      Percent Done: 11
      Worker Parallelism: 1
    
    Worker 4 Status:
      Instance ID: 1
      Instance name: CDB23
      Host name: holserv1.livelabs.oraclevcn.com
      Object start time: Friday, 02 May, 2025 14:35:13
      Object status at: Friday, 02 May, 2025 14:35:13
      Process Name: DW03
      State: EXECUTING
      Object Schema: CONSTR_VALIDATE
      Object Name: T3
      Object Type: SCHEMA_EXPORT/TABLE/TABLE_DATA
      Completed Objects: 1
      Completed Rows: 2,656,269
      Completed Bytes: 400,199,144
      Percent Done: 11
      Worker Parallelism: 1    
    ```
    </details> 

11. Switch from the interactive console to the Data Pump log output.

    ```
    <copy>
    continue_client
    </copy>
    ```

    * If you wait a while, Data Pump will start to write log messages to the console.
    * Loading the rows takes a while and Data Pump doesn't write anything until all the rows are loaded.
    * If you're patient and would like to see the next log line, wait a few minutes. Otherwise, proceed to the next step.

12. Switch from the log output back to the interactive console by hitting `CTRL+C`. 

    ```
    CTRL+C
    ```

    * Hit `CTRL+C` only once. Otherwise, you will forcefully exit the Data Pump client.
    * It's safe to hit `CTRL+C`. Remember, Data Pump runs server side, so even if you kill the client, you can just attach to the job again.

13. Kill the job from the interactive console.

    ```
    <copy>
    kill_job
    </copy>
    ```

    * Confirm that you want to kill the job.

14. Drop the schema that were imported.

    ```
    <copy>
    . cdb23
    sqlplus / as sysdba<<EOF
       alter session set container=red;
       drop user constr_validate cascade;
    EOF
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL*Plus: Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems on Fri May 2 14:11:48 2025
    Version 23.8.0.25.04
    
    Copyright (c) 1982, 2025, Oracle.  All rights reserved.
    
    
    Connected to:
    Oracle Database 23ai Enterprise Edition Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems
    Version 23.8.0.25.04
    
    SQL>
    Session altered.
    
    SQL>
    User dropped.
    
    Disconnected from Oracle Database 23ai Enterprise Edition Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems
    Version 23.8.0.25.04
    ```
    </details> 

## Task 3: Tracing

Here's a good way to generate trace information to solve a specific functional or performance problem.

1. Still in the *yellow* terminal 🟨. Connect to the *FTEX* database. 

    ```
    <copy>
    . ftex
    sqlplus / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

3. Check the current AWR snap interval, set it temporarily to 15 minutes and create a new snapshot.

    ```
    <copy>
    select snap_interval from dba_hist_wr_control;
    exec dbms_workload_repository.modify_snapshot_settings(interval => 15);
    exec dbms_workload_repository.create_snapshot;
    </copy>

    -- Be sure to hit RETURN
    ```

    * Using AWR requires a license for Oracle Diagnostics Pack. 
    * If connected to a PDB, you need to set the snap interval in the root container and in the PDB.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> select snap_interval from dba_hist_wr_control;

    SNAP_INTERVAL
    ---------------------------------------------------------------------------
    +00000 01:00:00.0    
    
    SQL> exec dbms_workload_repository.modify_snapshot_settings(interval => 15);

    PL/SQL procedure successfully completed.

    SQL> exec dbms_workload_repository.create_snapshot;

    PL/SQL procedure successfully completed.
    ```
    </details>

4. Enable SQL trace for the Data Pump control and worker processes.

    ```
    <copy>
    alter system set events 'sql_trace {process: pname = dw | process: pname = dm} level=8';
    </copy>
    ```

    * If you already knew the SQL ID of the problematic statement, you could enable SQL trace for a specific SQL ID only using `ALTER SYSTEM SET EVENTS 'sql_trace[SQL: <sql-id>]'`. 

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> alter system set events 'sql_trace {process: pname = dw | process: pname = dm} level=8';

    System altered.
    ```
    </details>

5. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```  

6. Remove existing Data Pump trace files.

    ```
    <copy>
    rm /u01/app/oracle/diag/rdbms/ftex/FTEX/trace/FTEX_dw*trc
    rm /u01/app/oracle/diag/rdbms/ftex/FTEX/trace/FTEX_dm*trc
    </copy>

    -- Be sure to hit RETURN
    ```

6. Start a Data Pump job with tracing enabled.

    ```
    <copy>
    . ftex
    expdp dpuser/oracle parfile=/home/oracle/scripts/dp-09-trace-export.par trace=1FF0300
    </copy>

    -- Be sure to hit RETURN
    ```

    * The `TRACE` parameter enables Data Pump specific tracing. This is different than SQL trace.
    * The parameter file also contains `LOGTIME=ALL` and `METRICS=YES`. 
    * If you know in which phase the problem happens, you can use `ABORT_STEP` to stop Data Pump before the problematic phase. Then restart with SQL trace and Data Pump tracing enabled.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    Export: Release 19.0.0.0.0 - Production on Fri May 2 17:08:28 2025
    Version 19.27.0.0.0
    
    Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.
    
    Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    02-MAY-25 17:08:31.503: Starting "DPUSER"."SYS_EXPORT_SCHEMA_02":  dpuser/******** parfile=/home/oracle/scripts/dp-09-trace-export.par trace=1FF0300
    02-MAY-25 17:08:32.047: W-1 Startup took 1 seconds
    02-MAY-25 17:08:34.160: W-1 Processing object type SCHEMA_EXPORT/TABLE/TABLE_DATA
    02-MAY-25 17:08:34.333: W-1 Processing object type SCHEMA_EXPORT/USER
    02-MAY-25 17:08:34.394: W-1      Completed 1 USER objects in 0 seconds
    02-MAY-25 17:08:34.414: W-1 Processing object type SCHEMA_EXPORT/SYSTEM_GRANT
    02-MAY-25 17:08:34.420: W-1      Completed 2 SYSTEM_GRANT objects in 0 seconds
    02-MAY-25 17:08:34.451: W-1 Processing object type SCHEMA_EXPORT/DEFAULT_ROLE
    02-MAY-25 17:08:34.456: W-1      Completed 1 DEFAULT_ROLE objects in 0 seconds
    02-MAY-25 17:08:34.486: W-1 Processing object type SCHEMA_EXPORT/TABLESPACE_QUOTA
    02-MAY-25 17:08:34.491: W-1      Completed 1 TABLESPACE_QUOTA objects in 0 seconds
    02-MAY-25 17:08:34.652: W-1 Processing object type SCHEMA_EXPORT/PRE_SCHEMA/PROCACT_SCHEMA
    02-MAY-25 17:08:34.657: W-1      Completed 1 PROCACT_SCHEMA objects in 0 seconds
    02-MAY-25 17:08:38.154: W-1 Processing object type SCHEMA_EXPORT/TABLE/TABLE
    02-MAY-25 17:08:38.263: W-1      Completed 14 TABLE objects in 2 seconds
    02-MAY-25 17:08:41.579: W-1 Processing object type SCHEMA_EXPORT/TABLE/CONSTRAINT/CONSTRAINT
    02-MAY-25 17:08:41.594: W-1      Completed 22 CONSTRAINT objects in 1 seconds
    02-MAY-25 17:08:43.180: W-1 . . exported "F1"."F1_LAPTIMES"                          16.98 MB  571047 rows in 1 seconds using direct_path
    02-MAY-25 17:08:43.231: W-1 . . exported "F1"."F1_RESULTS"                           1.429 MB   26439 rows in 0 seconds using direct_path
    02-MAY-25 17:08:43.268: W-1 . . exported "F1"."F1_DRIVERSTANDINGS"                   916.2 KB   34511 rows in 0 seconds using direct_path
    02-MAY-25 17:08:43.301: W-1 . . exported "F1"."F1_QUALIFYING"                        419.0 KB   10174 rows in 0 seconds using direct_path
    02-MAY-25 17:08:43.335: W-1 . . exported "F1"."F1_PITSTOPS"                          416.8 KB   10793 rows in 0 seconds using direct_path
    02-MAY-25 17:08:43.369: W-1 . . exported "F1"."F1_CONSTRUCTORSTANDINGS"              344.1 KB   13231 rows in 0 seconds using direct_path
    02-MAY-25 17:08:43.401: W-1 . . exported "F1"."F1_CONSTRUCTORRESULTS"                225.2 KB   12465 rows in 0 seconds using direct_path
    02-MAY-25 17:08:43.434: W-1 . . exported "F1"."F1_RACES"                             131.4 KB    1125 rows in 0 seconds using direct_path
    02-MAY-25 17:08:43.464: W-1 . . exported "F1"."F1_DRIVERS"                           87.86 KB     859 rows in 0 seconds using direct_path
    02-MAY-25 17:08:43.495: W-1 . . exported "F1"."F1_SPRINTRESULTS"                     29.88 KB     280 rows in 0 seconds using direct_path
    02-MAY-25 17:08:43.524: W-1 . . exported "F1"."F1_CONSTRUCTORS"                      22.97 KB     212 rows in 0 seconds using direct_path
    02-MAY-25 17:08:43.554: W-1 . . exported "F1"."F1_CIRCUITS"                          17.42 KB      77 rows in 0 seconds using direct_path
    02-MAY-25 17:08:43.583: W-1 . . exported "F1"."F1_SEASONS"                           10.03 KB      75 rows in 0 seconds using direct_path
    02-MAY-25 17:08:43.613: W-1 . . exported "F1"."F1_STATUS"                            7.843 KB     139 rows in 0 seconds using direct_path
    02-MAY-25 17:08:44.618: W-1      Completed 14 SCHEMA_EXPORT/TABLE/TABLE_DATA objects in 1 seconds
    02-MAY-25 17:08:45.310: W-1 Master table "DPUSER"."SYS_EXPORT_SCHEMA_02" successfully loaded/unloaded
    02-MAY-25 17:08:45.312: ******************************************************************************
    02-MAY-25 17:08:45.313: Dump file set for DPUSER.SYS_EXPORT_SCHEMA_02 is:
    02-MAY-25 17:08:45.314:   /home/oracle/dpdir/dp-09-trace.dmp
    02-MAY-25 17:08:45.334: Job "DPUSER"."SYS_EXPORT_SCHEMA_02" successfully completed at Fri May 2 17:08:45 2025 elapsed 0 00:00:15
    ```
    </details> 

7. Reconnect to the database. 

    ```
    <copy>
    cd /home/oracle
    . ftex
    sqlplus / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

8. Create a new AWR snapshot and reset the snap interval.

    ```
    <copy>
    exec dbms_workload_repository.create_snapshot;
    exec dbms_workload_repository.modify_snapshot_settings(interval => 60);    
    </copy>

    -- Be sure to hit RETURN
    ```

    * Using AWR requires a license for Oracle Diagnostics Pack. 
    * If connected to a PDB, you need to set the snap interval in the root container and in the PDB.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> exec dbms_workload_repository.create_snapshot;

    PL/SQL procedure successfully completed.

    SQL> exec dbms_workload_repository.modify_snapshot_settings(interval => 60);

    PL/SQL procedure successfully completed.
    ```
    </details>

9. Create an AWR report.

    ```
    <copy>
    @?/rdbms/admin/awrrpt 
    </copy>
    ```

    * When prompted for *report_type* hit ENTER.
    * When prompted for *num_days* enter 1.
    * When prompted for *begin_snap* enter the Snap Id from before the Data Pump job.
    * When prompted for *end_snap* enter the Snap Id from after the Data Pump job. Most likely the highest ID.
    * When prompted for *report_name* hit ENTER.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> @?/rdbms/admin/awrrpt

    Specify the Report Type
    ~~~~~~~~~~~~~~~~~~~~~~~
    AWR reports can be generated in the following formats.	Please enter the
    name of the format at the prompt.  Default value is 'html'.
    
    'html'		HTML format (default)
    'text'		Text format
    'active-html'	Includes Performance Hub active report
    
    Enter value for report_type:
    old   1: select 'Type Specified: ',lower(nvl('&&report_type','html')) report_type from dual
    new   1: select 'Type Specified: ',lower(nvl('','html')) report_type from dual
    
    Type Specified:  html
    
    old   1: select '&&report_type' report_type_def from dual
    new   1: select 'html' report_type_def from dual
    
    
    
    old   1: select '&&view_loc' view_loc_def from dual
    new   1: select 'AWR_PDB' view_loc_def from dual
    
    
    
    Current Instance
    ~~~~~~~~~~~~~~~~
    DB Id	       DB Name	      Inst Num	     Instance	    Container Name
    -------------- -------------- -------------- -------------- --------------
     3047483553	FTEX			    1 FTEX	     ftex
    
    
    
    Instances in this Workload Repository schema
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      DB Id      Inst Num	DB Name      Instance	  Host
    ------------ ---------- ---------    ----------   ------
    * 3047483553	 1	FTEX	     FTEX	  holserv1.liv
    
    Using 3047483553 for database Id
    Using	       1 for instance number
    
    
    Specify the number of days of snapshots to choose from
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Entering the number of days (n) will result in the most recent
    (n) days of snapshots being listed.  Pressing <return> without
    specifying a number lists all completed snapshots.
    
    
    Enter value for num_days: 1
    
    Listing the last day's Completed Snapshots
    Instance     DB Name	  Snap Id	Snap Started	Snap Level
    ------------ ------------ ---------- ------------------ ----------
    
    FTEX	     FTEX		 58  02 May 2025 00:00	  1
    				 59  02 May 2025 01:00	  1
    				 60  02 May 2025 02:00	  1
    				 61  02 May 2025 03:00	  1
    				 62  02 May 2025 04:00	  1
    				 63  02 May 2025 05:00	  1
    				 64  02 May 2025 06:00	  1
    				 65  02 May 2025 07:00	  1
    				 66  02 May 2025 08:00	  1
    				 67  02 May 2025 09:00	  1
    				 68  02 May 2025 10:00	  1
    				 69  02 May 2025 11:01	  1
    				 70  02 May 2025 12:00	  1
    				 71  02 May 2025 13:00	  1
    				 72  02 May 2025 14:00	  1
    				 73  02 May 2025 15:00	  1
    				 74  02 May 2025 16:00	  1
    				 75  02 May 2025 16:57	  1
    				 76  02 May 2025 16:58	  1
    				 77  02 May 2025 16:58	  1
    				 78  02 May 2025 17:11	  1
    
    
    Specify the Begin and End Snapshot Ids
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Enter value for begin_snap: 77
    Begin Snapshot Id specified: 77
    
    Enter value for end_snap: 78
    End   Snapshot Id specified: 78
    
    
    
    Specify the Report Name
    ~~~~~~~~~~~~~~~~~~~~~~~
    The default report file name is awrrpt_1_77_78.html.  To use this name,
    press <return> to continue, otherwise enter an alternative.
    
    Enter value for report_name:

    (output truncated)

    Report written to awrrpt_1_77_78.html
    ```
    </details> 

10. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```

11. Put all files into a zip file.

    ```
    <copy>
    cd /home/oracle
    # Add AWR report
    zip -rv my-problem.zip awrrpt*.html
    # Add Data Pump log file
    zip -rv my-problem.zip dpdir/dp-09-trace-export.log
    # Add alert log
    zip -rv my-problem.zip /u01/app/oracle/diag/rdbms/ftex/FTEX/trace/alert_FTEX.log
    # Control process trace file
    zip -rv my-problem.zip $(ls /u01/app/oracle/diag/rdbms/ftex/FTEX/trace/FTEX_*dm*trc)
    # Worker trace files
    zip -rv my-problem.zip $(ls /u01/app/oracle/diag/rdbms/ftex/FTEX/trace/FTEX_*dw*trc)
    </copy>

    -- Be sure to hit RETURN
    ```

    * The zip file contains a lot of valuable tracing information. Share it with Oracle Support if needed.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ zip -rv my-problem.zip awrrpt*.html
      adding: awrrpt_1_77_78.html 	(in=1143254) (out=102585) (deflated 91%)
    total bytes=1143254, compressed=102585 -> 91% savings
    $ # Add Data Pump log file
    $ zip -rv my-problem.zip dpdir/dp-09-trace-export.log
      adding: dpdir/dp-09-trace-export.log	(in=4860) (out=1165) (deflated 76%)
    total bytes=1148114, compressed=103750 -> 91% savings
    $ # Add alert log
    $ zip -rv my-problem.zip /u01/app/oracle/diag/rdbms/ftex/FTEX/trace/alert_FTEX.log
      adding: u01/app/oracle/diag/rdbms/ftex/FTEX/trace/alert_FTEX.log 	(in=796041) (out=95066) (deflated 88%)
    total bytes=1944155, compressed=198816 -> 90% savings
    $ # Control process trace file
    $ zip -rv my-problem.zip $(ls /u01/app/oracle/diag/rdbms/ftex/FTEX/trace/FTEX_*dm*trc)
      adding: u01/app/oracle/diag/rdbms/ftex/FTEX/trace/FTEX_dm00_256420.trc .	(in=10816351) (out=1308889) (deflated 88%)
    total bytes=12760506, compressed=1507705 -> 88% savings
    $ # Worker trace files
    $ zip -rv my-problem.zip $(ls /u01/app/oracle/diag/rdbms/ftex/FTEX/trace/FTEX_*dw*trc)
      adding: u01/app/oracle/diag/rdbms/ftex/FTEX/trace/FTEX_dw00_256422.trc .	(in=19664901) (out=2261326) (deflated 89%)
    total bytes=32425407, compressed=3769031 -> 88% savings    
    ```
    </details> 

12. You enabled SQL trace before the export. Take a look at the control process trace file.

    ```
    <copy>
    grep -i "dbms_datapump.set_parameter" /u01/app/oracle/diag/rdbms/ftex/FTEX/trace/FTEX_*dm*trc
    </copy>
    ```

    * Notice how the `SET_PARAMETER` procedure is called with *TRACE* set to 33489664. Convert the value to hex, and you get *1FF0300* - the trace value you added on the command line (`TRACE=1FF0300`).
    * In lab 11, you will learn how to define jobs using `DBMS_DATAPUMP` directly. You will recognize these calls.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    KUPM:08:05:20.080: DBMS_DATAPUMP.SET_PARAMETER (hand, 'TRACE', 33489664);
    KUPM:08:05:20.183: DBMS_DATAPUMP.SET_PARAMETER (hand, 'COMMAND_LINE_CLIENT', 1);
    KUPM:08:05:20.186: DBMS_DATAPUMP.SET_PARAMETER (hand, 'CLIENT_COMMAND', 'dpuser/******** parfile=/home/oracle/scripts/dp-09-trace-export.par trace=1FF0300 ');
    KUPM:08:05:20.211: DBMS_DATAPUMP.SET_PARAMETER (hand, 'METRICS', 1);
    KUPM:08:05:20.317: DBMS_DATAPUMP.SET_PARAMETER (hand, 'LOGTIME', 'all');
    ```
    </details> 

13. Disable SQL trace.

    ```
    <copy>
    sqlplus / as sysdba<<EOF
       alter system set events 'sql_trace {process: pname = dw | process: pname = dm} level=1';
    EOF
    </copy>
    ```

You may now *proceed to the next lab*.

## Additional information

* Webinar, [Data Pump Extreme - Deep Dive with Development, Control table](https://www.youtube.com/watch?v=CUHcKHx_YvA&t=775s)

## Acknowledgments

* **Author** - Daniel Overby Hansen
* **Contributors** - William Beauregard, Rodrigo Jorge, Mike Dietrich, Klaus Gronau, Alex Zaballa
* **Last Updated By/Date** - Daniel Overby Hansen, May 2025