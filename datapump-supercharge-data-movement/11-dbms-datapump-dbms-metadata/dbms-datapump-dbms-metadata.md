# Using DBMS\_DATAPUMP

## Introduction

Normally, you use the Data Pump clients to start a job. Those clients use the Data Pump API underneath the hood. In this lab, you will try to create a Data Pump job using the API. You can also start Data Pump jobs through tools like Enterprise Manager, Zero Downtime Migration, and SQLcl. Those tools use the Data Pump API as well.

Estimated Time: 10 Minutes

### Objectives

In this lab, you will:

* Start a Data Pump job using the API

### Prerequisites

This lab assumes:

- You have completed Lab 3: Getting Started

## Task 1: Data Pump API

A lot of the Data Pump functionality is in the `DBMS_DATAPUMP` package. If you use the clients, `expdp` or `impdp`, they will generate and start the job via the package. 

1. Use the *yellow* terminal 🟨. Connect to the *FTEX* database.

    ```
    <copy>
    . ftex
    sqlplus dpuser/oracle as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

2. You start by defining a job; a schema-based export. You get a handle back from the function. You will use the handle to reference the job as you configure it.

    ```
    <copy>
    variable h1 number
    
    begin 
        :h1 := dbms_datapump.open(
            operation => 'EXPORT',
    	    job_mode => 'SCHEMA');
    end;
    /
    </copy>
    -- Be sure to hit RETURN
    ```

    * In this task, you use a SQL*Plus bind variable (`h1`). You will see it referenced using `:h1`, but you can build it entirely in PL/SQL as well. 

3. Add a filter to select only the *F1* schema.

    ```
    <copy>
    begin
        dbms_datapump.metadata_filter(
            handle => :h1,
            name => 'SCHEMA_EXPR',
            value => 'IN (''F1'')');
    end;
    /
    </copy>

    -- Be sure to hit RETURN
    ```

4. Add a dump file.  

    ```
    <copy>
    begin
        dbms_datapump.add_file(
            handle => :h1,
            filename => 'dp-11-api-%L.dmp',
            directory => 'DPDIR',
            filetype=>DBMS_DATAPUMP.KU$_FILE_TYPE_DUMP_FILE);
    end;
    /
    </copy>

    -- Be sure to hit RETURN
    ```

5. Add a log file.

    ```
    <copy>
    begin
        dbms_datapump.add_file(
            handle => :h1,
            filename => 'dp-11-api-export.log',
            directory => 'DPDIR',
            filetype=>DBMS_DATAPUMP.KU$_FILE_TYPE_LOG_FILE);
    end;
    /
    </copy>

    -- Be sure to hit RETURN
    ```

6. Set parallel degree.

    ```
    <copy>
    begin
        dbms_datapump.set_parallel(
            handle => :h1,
            degree => 4 );
    end;
    /
    </copy>

    -- Be sure to hit RETURN
    ```

7. Enable diagnostics.

    ```
    <copy>
    begin 
        dbms_datapump.set_parameter(
            handle => :h1,
            name => 'METRICS',
            value => 1);

    dbms_datapump.set_parameter(
        handle => :h1,
        name => 'LOGTIME',
        value => 'ALL');      
    end;
    /
    </copy>

    -- Be sure to hit RETURN
    ```

8. Start the job.

    ```
    <copy>
    begin
        dbms_datapump.start_job (handle => :h1);
    end;
    /
    </copy>

    -- Be sure to hit RETURN
    ```

9. Wait for the job to complete.

    ```
    <copy>
    set serverout on
    declare
        l_state VARCHAR2(20);
    begin
        dbms_datapump.wait_for_job (
            handle => :h1,
            job_state => l_state);      
        dbms_output.put_line('Final state: ' || l_state);
    end;
    /
    </copy>

    -- Be sure to hit RETURN
    ```

    * The procedure prints the final state: *STOPPED* or *COMPLETED*.
    * You could also build your own loop and query some of the Data Pump views.
    * If you get `ORA-31623: a job is not attached to this session via the specified handle` the job is already completed.

10. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```

11. Look for the Data Pump dump files and log file.

    ```
    <copy>
    ll /home/oracle/dpdir/dp-11-api*
    </copy>

    -- Be sure to hit RETURN
    ```

    * The dump files and log file are there, so that's a good sign.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    -rw-r-----. 1 oracle oinstall   794624 May  2 18:28 /home/oracle/dpdir/dp-11-api-01.dmp
    -rw-r-----. 1 oracle oinstall 17833984 May  2 18:28 /home/oracle/dpdir/dp-11-api-02.dmp
    -rw-r-----. 1 oracle oinstall  4243456 May  2 18:28 /home/oracle/dpdir/dp-11-api-03.dmp
    -rw-r--r--. 1 oracle oinstall     4607 May  2 18:28 /home/oracle/dpdir/dp-11-api-export.log
    ```
    </details> 

12. Check the result of the job.

    ```
    <copy>
    tail -1 /home/oracle/dpdir/dp-11-api-export.log
    </copy>

    -- Be sure to hit RETURN
    ```

    * The dump files and log file is there, so that's a good sign.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    02-MAY-25 18:28:13.253: Job "DPUSER"."SYS_EXPORT_SCHEMA_01" successfully completed at Fri May 2 18:28:13 2025 elapsed 0 00:00:10
    ```
    </details> 
    
13. If you need inspiration on how to use `DBMS_DATAPUMP`. You can enable SQL trace on a database and start the job via `expdp` or `impdp`. Find the matching trace file (not dm or dw trace files, but the session trace file). You will be able to see the `DBMS_DATAPUMP` calls made by `expdp` or `impdp`. This is what you did in lab 9, *Monitoring, Troubleshooting and Tracing*.


**Congratulations!** This is the end of the lab.

## Additional information

* Webinar, [Data Pump Extreme - Deep Dive with Development, Using DBMS_DATAPUMP](https://www.youtube.com/watch?v=CUHcKHx_YvA&t=5205s)

## Acknowledgments

* **Author** - Daniel Overby Hansen
* **Contributors** - William Beauregard, Rodrigo Jorge, Mike Dietrich, Klaus Gronau, Alex Zaballa
* **Last Updated By/Date** - Daniel Overby Hansen, May 2025