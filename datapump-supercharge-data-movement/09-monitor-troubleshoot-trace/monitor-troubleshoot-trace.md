# Monitoring, Troubleshooting and Tracing

## Introduction

Occasionally things doesn't go as planned. When that happens, you can rely on instrumentation in Data Pump that will provide you better understanding of what's going on. In this lab, you will learn ways of monitoring Data Pump and dig deeper into the details with tracing.

Estimated Time: 20 Minutes

### Objectives

In this lab, you will:

* Monitor, troubleshoot and trace

### Prerequisites

This lab assumes:

- You have completed Lab 7: Checksum and Encryption

## Task 1: Monitoring

In lab 5, your learned about the interactive console and the `STATUS` command. You also used a few views in the database. In Oracle Database 23ai, there are new views with even better details on your Data Pump jobs. 

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
    * Move on with the next step.

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
    * The control process (formerly known as *master process*) is seen as *DM00*.
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
    * The other processes are waiting for *log buffer space*. Perhaps you could tune the system by putting redo logs on faster disks, implement more redo log groups or larger redo log members, or even import with `NOLOGGING` clause. You could implement the latter with `TRANSFORM=DISABLE_ARCHIVE_LOGGING:Y`.
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

    * In lab 5, *Faster Imports*, you learned how to use the interactive console.

9. Now, kill the job.

    ```
    <copy>
    kill_job
    </copy>
    ```

    * Confirm by inputting `YES``
    * It takes a little while for Data Pump to stop the job. 
    * If you thing it's too slow, press `CTRL+C` again.

10. Drop the schema that were imported.


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
         
    (putput truncated)         
         
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
    * Notice how `TABLE_DATA` starts at `PROCESS_ORDER=10`.

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
    * If you want to stop the job right after loading the control table, you can use `ABORT_STEP=-1`.

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
    * Run the `STATUS` command a few times and see how *Completed rows* increases.

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

You may now *proceed to the next lab*.

## Additional information

* Webinar, [Data Pump Extreme - Deep Dive with Development, Control table](https://www.youtube.com/watch?v=CUHcKHx_YvA&t=775s)

## Acknowledgments

* **Author** - Daniel Overby Hansen
* **Contributors** - William Beauregard, Rodrigo Jorge, Mike Dietrich, Klaus Gronau, Alex Zaballa
* **Last Updated By/Date** - Daniel Overby Hansen, May 2025