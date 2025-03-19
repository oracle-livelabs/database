# Final Preparations

## Introduction

Right before the outage starts, there are a few final preparations.

Estimated Time: 5 Minutes

[Next-Level Platform Migration with Cross-Platform Transportable Tablespaces - lab 8](youtube:fgyDy-QcV_o?start=2231)

### Objectives

In this lab, you will:

* Export statistics
* Gather dictionary statistics

## Task 1: Export statistics

Although Data Pump can transfer statistics as part of a full transportable export/import, it is not the recommended approach. It is faster to transport statistics in advance using `DBMS_STAT`. 

You can export statistics before the maintenance window begins. Most likely, the statistics will not change from now on, and even if they do, such changes shouldn't make a huge difference for the optimizer.

1. Use the *yellow* terminal 🟨. Set the environment to the source database and connect.

    ```
    <copy>
    . ftex
    sqlplus / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

2. Create a schema that can hold the exported stats.

    ```
    <copy>
    create user opt_stat_transport no authentication;
    alter user opt_stat_transport quota unlimited on users;
    </copy>

    -- Be sure to hit RETURN
    ```

    * The `NO AUTHENTICATION` clause prevents anyone from logging on as this user. It is just a schema.
    * The schema must have privileges on one of the tablespaces that you migrate. In this case, it is the *USERS* tablespace.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> create user opt_stat_transport no authentication;
    
    User created.

    SQL> alter user opt_stat_transport quota unlimited on users;
    
    User altered.
    ```
    </details>

3. Create a staging table for the statistics. 

    ```
    <copy>
    begin dbms_stats.create_stat_table ( 
             ownname => 'OPT_STAT_TRANSPORT',
             stattab => 'OPT_STATS_STG',
             tblspace => 'USERS');
    end;
    /
    </copy>

    -- Be sure to hit RETURN
    ```
    
    * `ownname` is the name of the schema that holds the exported statistics.
    * `stattab` is the name of the table with the exported statistics. 
    * `tblspace` is the location of the table. Be sure to choose a tablespace that you migrate. Otherwise, you must export the table manually using Data Pump.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> begin dbms_stats.create_stat_table ( 
             ownname => 'OPT_STAT_TRANSPORT',
             stattab => 'OPT_STATS_STG',
             tblspace => 'USERS');
    end;
    /
    
    PL/SQL procedure successfully completed.
    ```
    </details>

4. Export the statistics from the data dictionary into the staging table. 

    ```
    <copy>
    begin dbms_stats.export_schema_stats ( 
             ownname => 'F1',
             statown => 'OPT_STAT_TRANSPORT',
             stattab => 'OPT_STATS_STG');
    end;
    /
    </copy>

    -- Be sure to hit RETURN
    ```
    
    * In the data dictionary, the database stores the statistics in a binary format.
    * To transport the statistics, the database converts them to a common, transportable format that can be read by any database on import.
    * `ownname` is the schema for which you want to export statistics. 
    * In the lab, there is only one schema, *F1*. In a real migration, you probably have many schemas to export. 

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> begin dbms_stats.export_schema_stats ( 
             ownname => 'F1',
             statown => 'OPT_STAT_TRANSPORT',
             stattab => 'OPT_STATS_STG');
    end;
    /
    
    PL/SQL procedure successfully completed.
    ```
    </details>
    
5. The exported statistics will sit in the *USERS* tablespace for now. Later on, you will import statistics into the target database.

## Task 2: Gather dictionary statistics

While executing an export or import job, Data Pump is querying the data dictionary heavily. To avoid any performance issues caused by inaccurate statistics, Oracle recommends gathering dictionary statistics close to the maintenance window.

1. Still in the *yellow* terminal 🟨. Gather dictionary statistics.

    ```
    <copy>
    exec dbms_stats.gather_schema_stats(ownname=>'SYS');
    exec dbms_stats.gather_schema_stats(ownname=>'SYSTEM');
    </copy>
    
    --Be sure to hit RETURN
    ```

    * Optionally, you can add `degree=>DBMS_STATS.AUTO_DEGREE` to gather statistics in parallel. Since the outage hasn't started yet, be careful about putting much load on the source database.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> exec dbms_stats.gather_schema_stats('SYS');

    PL/SQL procedure successfully completed.

    SQL> exec dbms_stats.gather_schema_stats('SYSTEM');

    PL/SQL procedure successfully completed.
    ```
    </details>

2. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```

You may now *proceed to the next lab*.

## Further information

There are other means of dealing with the statistics than using `DBMS_STATS`. Although, Oracle recommend this approach, it is worth exploring the other options to see what fits your situation.

* Webinar, Virtual Classroom #18: Cross Platform Migrations- Transportable Tablespaces to the Extreme, [Migration Best Practices - Statistics](https://www.youtube.com/watch?v=DwUBvjQrPxs)

* YouTube playlist, [Transporting statistics using DBMS_STATS ](https://www.youtube.com/playlist?list=PLIUJ4jBaPQxwrXcRIdc8m8omg1L5ZVX0U)
* Blog post, [How to Export and Import Statistics Faster Using DBMS_STATS in Parallel](https://dohdatabase.com/2023/12/18/how-to-export-and-import-statistics-faster-using-dbms_stats-in-parallel/)

## Acknowledgments

* **Author** - Daniel Overby Hansen
* **Contributors** - Rodrigo Jorge, Mike Dietrich, Klaus Gronau, Alex Zaballa
* **Last Updated By/Date** - Daniel Overby Hansen, August 2024
