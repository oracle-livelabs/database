# Capture and Preserve SQL

## Introduction

In this lab, you will capture and preserve SQL statements and information from the AWR. We will use this collection later on, following a performance stability method guideline.

Estimated Time: 5 minutes

### Objectives

In this lab, you will:

* Collect statements from AWR
* Compare SQL Tuning Sets

### Prerequisites

This lab assumes:

- You have completed Lab 2: Generate AWR Snapshot

## Task 1: Collect statements from AWR

Capture workload information from the workload you generated in lab 2. This time you will capture from AWR and into a different SQL Tuning Set.

1. Use the yellow terminal. Set the environment to the *UPGR* database and connect.

    ```
    <copy>
    . upgr
    sqlplus / as sysdba
    </copy>
    ```

2.  Run the capture script:

    ```
    <copy>
    @/home/oracle/scripts/capture_awr.sql
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> @/home/oracle/scripts/capture_awr.sql
    Snapshot Range between 111 and 120.
    There are 31 SQL Statements in STS_CaptureAWR.

    PL/SQL procedure successfully completed.
    ```
    </details>

    The script takes the longest-running statements from AWR and loads them into a new SQL Tuning Set. The snapshot range and the number of statements may vary. 

## Task 2: Compare SQL Tuning Sets

You can also collect statements directly from the Cursor Cache. This is more resource intense but helpful in the case of OLTP applications. Be careful when you poll the cursor cache too frequently.

You now have two SQL Tuning Sets:
- One from cursor cache (good for OLTP-like workload)
- One from AWR (good for DWH-like workload)

1. Compare the two SQL Tuning Sets.

    ```
    <copy>
    select name, owner, statement_count from dba_sqlset;
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> select name, owner, statement_count from dba_sqlset;

    NAME                     OWNER STATEMENT_COUNT
    ---------------------- ------- ---------------
    STS_CaptureAWR             SYS              31
    STS_CaptureCursorCache     SYS              38
    ```
    </details>

    It is very likely that you will get different statement counts. One of the reasons could be that often, the capture from the cursor cache will catch more statements compared to those written down from ASH (Active Session History) into AWR. And it does not play any role for the lab whether the number of statements matches the number in the screenshots or not.

2. Exit from SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```

You may now *proceed to the next lab*.

## Learn More

A SQL tuning set (STS) is a database object that you can use as input to tuning tools.
An STS includes:

- A set of SQL statements
- Associated execution context, such as a user schema, application module name and action, list of bind values, and the environment for SQL compilation of the cursor
- Associated basic execution statistics, such as elapsed time, CPU time, buffer gets, disk reads, rows processed, cursor fetches, the number of executions, the number of complete executions, optimizer cost, and the command type
- Associated execution plans and row source statistics for each SQL statement (optional)

An STS allows you to transport SQL between databases. You can export SQL tuning sets from one database to another, enabling transfer of SQL workloads between databases for remote performance diagnostics and tuning.

* Documentation, [SQL Tuning Sets](https://docs.oracle.com/en/database/oracle/oracle-database/19/tgsql/managing-sql-tuning-sets.html#GUID-DD136837-9921-4C73-ABB8-9F1DC22542C5)
* Webinar, [Performance Stability Perscription #1: Collect SQL Tuning Sets](https://www.youtube.com/watch?v=qCt1_Fc3JRs&t=3969s)

## Acknowledgements
* **Author** - Mike Dietrich, Database Product Management
* **Contributors** - Daniel Overby Hansen, Roy Swonger, Kay Malcom, Database Product Management
* **Last Updated By/Date** - Daniel Overby Hansen, July 2023
