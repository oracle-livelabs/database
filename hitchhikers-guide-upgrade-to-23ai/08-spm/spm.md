# SQL Plan Management

## Introduction

In this lab, you use SQL Plan Management to ensure that a SQL always use a good plan. When you have identified plan regressions with SQL Performance Analyzer, you can create a SQL plan baseline to ensure the optimizer chooses a plan from the baseline.

Credits: You will use scripts written by Carlos Sierra.

Estimated Time: 15 minutes

[Hitchhiker's Guide Lab 8](youtube:lwvdaM4v4tQ?start=3855)

### Objectives

In this lab, you will:
* Create SQL plan baseline for one statement
* Test the SQL plan baseline

### Prerequisites

This lab assumes:

- You have completed Lab 7: SQL Performance Analyzer

## Task 1: Create SQL Plan Baseline for one statement

In the previous lab, you found a statement that changed plan after upgrade (SQL ID *0cwuxyv314wcg*). You saw that the index path was better than a full table scan. Now, you want to create a SQL plan baseline for that SQL, so the optimizer will only consider the index plan.

1. Use the *yellow* terminal 🟨 and set the environment. Connect to the upgraded UPGR database.

    ```
    <copy>
    . cdb23
    sqlplus / as sysdba
    alter session set container=UPGR;
    </copy>

    -- Be sure to hit RETURN
    ```

3. Get a list of plans for the SQL (*0cwuxyv314wcg*).

    ```
    <copy>
    col operation format a16
    col options format a22
    col object_name format a12
    select PLAN_HASH_VALUE phv, child_number child, operation, options, object_name 
    from v$sql_plan 
    where sql_id='0cwuxyv314wcg' 
    order by 1, child_number, position desc;
    </copy>
    
    -- Be sure to hit RETURN
    ```

    * The plan with hash value *612465046* is the good plan. It uses an index access path. You want this plan in your SQL plan baseline.
    * You might see a plan that uses a full table scan. This is a bad plan. You **don't** want that in your SQL plan baseline. 

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> select PLAN_HASH_VALUE phv, child_number child, operation, options, object_name from v$sql_plan where sql_id='0cwuxyv314wcg' order by 1, child_number, position desc;
    
    PHV        CHILD OPERATION        OPTIONS                OBJECT_NAME
    ---------- ----- ---------------- ---------------------- -----------
    612465046      0 SELECT STATEMENT
    612465046      0 TABLE ACCESS     BY INDEX ROWID BATCHED CUSTOMER
    612465046      0 INDEX            RANGE SCAN             CUSTOMER_I1
    612465046      0 SORT             ORDER BY
    
    4 rows selected.
    ```
    </details>

2. Create a SQL plan baseline. You will use a script created by Carlos Sierra.

    ```
    <copy>
    @/home/oracle/scripts/spb_create.sql
    </copy>
    ```

    * When prompted for:
        - *SQL_ID* (*1*), enter *0cwuxyv314wcg*.
        - *1st Plan Hash Value*, enter *612465046*.
        - *2nd Plan Hash Value*, hit RETURN.
        - *3rd Plan Hash Value*, hit RETURN.
        - *FIXED*, hit RETURN.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> @/home/oracle/scripts/spb_create.sql
    
    PL/SQL procedure successfully completed.
    
    PL/SQL procedure successfully completed.
    
    1. Enter SQL_ID (required)
    Enter value for 1: 0cwuxyv314wcg
    
    SIGNATURE
    ----------------------------------------
    7823966832826756817
    
    X_HOST_NAME
    ----------------------------------------------------------------
    holserv1.livelabs.oraclevcn.com
    
    X_DB_NAME
    ---------
    CDB23
    
    X_CO
    ----
    NONE
    
    X_CONTAINER
    ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    UPGR
    
    SQL> @spm/spb_create.sql 0cwuxyv314wcg
    
    spb_create_cdb23_oraclevcn_com_upgr_0cwuxyv314wcg_20240813_084739.txt
    
    HOST      : holserv1.livelabs.oraclevcn.com
    DATABASE  : CDB23
    CONTAINER : UPGR
    SQL_ID    : 0cwuxyv314wcg
    SQL_HANDLE:
    SIGNATURE : 7823966832826756817
    
    EXISTING BASELINES
    ~~~~~~~~~~~~~~~~~~
    
    PLANS PERFORMANCE
    ~~~~~~~~~~~~~~~~~
    
           Plan ET Avg      ET Avg      CPU Avg     CPU Avg           BG Avg       BG Avg     Rows Avg     Rows Avg       Executions       Executions                                   ET 100th    ET 99th     ET 97th     ET 95th     CPU 100th   CPU 99th    CPU 97th    CPU 95th
     Hash Value AWR (ms)    MEM (ms)    AWR (ms)    MEM (ms)             AWR          MEM          AWR          MEM              AWR              MEM   MIN Cost   MAX Cost  NL  HJ  MJ Pctl (ms)   Pctl (ms)   Pctl (ms)   Pctl (ms)   Pctl (ms)   Pctl (ms)   Pctl (ms)   Pctl (ms)
    ----------- ----------- ----------- ----------- ----------- ------------ ------------ ------------ ------------ ---------------- ---------------- ---------- ---------- --- --- --- ----------- ----------- ----------- ----------- ----------- ----------- ----------- -----------
      612465046       1.238       1.269       0.712       0.722          254          254       12.306       12.356          147,740           75,137        255        255   0   0   0      12.411      12.411      12.411      12.411       4.434       4.434       4.434       4.434
    
    Select up to 3 plans:
    
    1st Plan Hash Value (req): 612465046
    2nd Plan Hash Value (opt):
    3rd Plan Hash Value (opt):
    
    FIXED (opt):
    
    FIX
    ---
    NO
    Plans created from memory for PHV 612465046
    
         PLANS
    ----------
             1
    
    Plans created from memory for PHV
    
         PLANS
    ----------
             0
    
    Plans created from memory for PHV
    
         PLANS
    ----------
             0
    
    SQLSET_NAME
    --------------------------------
    S_0CWUXYV314WCG
    
          FROM TABLE(DBMS_SQLTUNE.select_workload_repository (          ,           ,
                                                                        *
    ERROR at line 30:
    ORA-06550: line 30, column 69:
    PL/SQL: ORA-00936: missing expression
    ORA-06550: line 29, column 5:
    PL/SQL: SQL Statement ignored
    Help: https://docs.oracle.com/error-help/db/ora-06550/
    
    Plans created from AWR for PHVs 612465046
    
         PLANS
    ----------
    
    PLANS:0
    
    RESULTING BASELINES
    ~~~~~~~~~~~~~~~~~~~
    
    CREATED             PLAN_NAME                      ENA ACC FIX REP ADA ORIGIN                        LAST_EXECUTED       LAST_MODIFIED       DESCRIPTION
    ------------------- ------------------------------ --- --- --- --- --- ----------------------------- ------------------- ------------------- ------------------------------------------------------------------------------------------------------------------------------------------------------
    2024-08-13T08:47:46 SQL_PLAN_6t52hc6fj7bqj9b7dfa5f YES YES NO  YES NO  MANUAL-LOAD-FROM-CURSOR-CACHE                     2024-08-13T08:47:46
    
    CREATED             PLAN_NAME                      ENA ACC FIX REP ADA ORIGIN                          ET_PER_EXEC_MS  CPU_PER_EXEC_MS BUFFERS_PER_EXEC   READS_PER_EXEC    ROWS_PER_EXEC   EXECUTIONS     ELAPSED_TIME         CPU_TIME      BUFFER_GETS       DISK_READS   ROWS_PROCESSED
    ------------------- ------------------------------ --- --- --- --- --- ----------------------------- ---------------- ---------------- ---------------- ---------------- ---------------- ------------ ---------------- ---------------- ---------------- ---------------- ----------------
    2024-08-13T08:47:46 SQL_PLAN_6t52hc6fj7bqj9b7dfa5f YES YES NO  YES NO  MANUAL-LOAD-FROM-CURSOR-CACHE            1.269            0.722              254                0               12       75,137       95,320,929       54,255,810       19,049,522               27          928,409
    
    CREATED             PLAN_NAME                      ENA ACC FIX REP ADA    PLAN_ID PLAN_HASH_2  PLAN_HASH PLAN_HASH_FULL DESCRIPTION
    ------------------- ------------------------------ --- --- --- --- --- ---------- ----------- ---------- -------------- ------------------------------------------------------------------------------------------------------------------------------------------------------
    2024-08-13T08:47:46 SQL_PLAN_6t52hc6fj7bqj9b7dfa5f YES YES NO  YES NO  2608724575  2608724575  612465046     2608724575
    
    SQL PLAN BASELINES
    ~~~~~~~~~~~~~~~~~~
    Error: neither SQL handle nor plan name specified
    
    RESULTING BASELINES
    ~~~~~~~~~~~~~~~~~~~
    
    CREATED             PLAN_NAME                      ENA ACC FIX REP ADA ORIGIN                        LAST_EXECUTED       LAST_MODIFIED       DESCRIPTION
    ------------------- ------------------------------ --- --- --- --- --- ----------------------------- ------------------- ------------------- ------------------------------------------------------------------------------------------------------------------------------------------------------
    2024-08-13T08:47:46 SQL_PLAN_6t52hc6fj7bqj9b7dfa5f YES YES NO  YES NO  MANUAL-LOAD-FROM-CURSOR-CACHE                     2024-08-13T08:47:46
    
    CREATED             PLAN_NAME                      ENA ACC FIX REP ADA ORIGIN                          ET_PER_EXEC_MS  CPU_PER_EXEC_MS BUFFERS_PER_EXEC   READS_PER_EXEC    ROWS_PER_EXEC   EXECUTIONS     ELAPSED_TIME         CPU_TIME      BUFFER_GETS       DISK_READS   ROWS_PROCESSED
    ------------------- ------------------------------ --- --- --- --- --- ----------------------------- ---------------- ---------------- ---------------- ---------------- ---------------- ------------ ---------------- ---------------- ---------------- ---------------- ----------------
    2024-08-13T08:47:46 SQL_PLAN_6t52hc6fj7bqj9b7dfa5f YES YES NO  YES NO  MANUAL-LOAD-FROM-CURSOR-CACHE            1.269            0.722              254                0               12       75,137       95,320,929       54,255,810       19,049,522               27          928,409
    
    CREATED             PLAN_NAME                      ENA ACC FIX REP ADA    PLAN_ID PLAN_HASH_2  PLAN_HASH PLAN_HASH_FULL DESCRIPTION
    ------------------- ------------------------------ --- --- --- --- --- ---------- ----------- ---------- -------------- ------------------------------------------------------------------------------------------------------------------------------------------------------
    2024-08-13T08:47:46 SQL_PLAN_6t52hc6fj7bqj9b7dfa5f YES YES NO  YES NO  2608724575  2608724575  612465046     2608724575
    
    spb_create_cdb23_oraclevcn_com_upgr_0cwuxyv314wcg_20240813_084739.txt
    ```
    </details>

4. What happened in the script?
      - The script asks for an SQL ID.
      - The scripts then display all available plans for that SQL.
      - You choose the one good plan, that you want to add to a SQL plan baseline for that SQL. In a realistic scenario, there could be more good plans for an SQL. You could select more plans for the baseline.
      - Optionally, you can *fix* one of the plans. A fixed plan is always used by the optimizer. Normally, the optimizer will choose the best of the *available* plans, but if there is a *fixed* plan, the optimizer will always use that.

4. Verify that the script created a SQL plan baseline.

      ```
      <copy>
      col sql_handle format a20
      col plan_name format a30
      col enabled format a7
      col accepted format a8
      col fixed format a5
      SELECT sql_handle, plan_name, enabled, accepted, fixed FROM dba_sql_plan_baselines;
      </copy>

      -- Be sure to hit RETURN
      ```

      <details>
      <summary>*click to see the output*</summary>
      ``` text
      SQL> col sql_handle format a20
      SQL> col plan_name format a30
      SQL> col enabled format a7
      SQL> col accepted format a8
      SQL> col fixed format a5
      SQL> SELECT sql_handle, plan_name, enabled, accepted, fixed FROM dba_sql_plan_baselines;

      SQL_HANDLE           PLAN_NAME                      ENABLED ACCEPTED FIXED
      -------------------- ------------------------------ ------- -------- -----
      SQL_6c9450619d13aed1 SQL_PLAN_6t52hc6fj7bqj9b7dfa5f YES     YES      NO
      ```
      </details>

## Task 2: Test SQL Plan Baseline

Now, you have a SQL plan baseline that only contains the index plan. You now re-introduce the hack to simulate a bad optimizer. This should cause the optimizer to choose a full table scan like in the previous lab. However, there is now a SQL plan baseline in place. It forces the optimizer to choose the plan from the baseline - which uses the index plan. 

1. Re-introduce the hack to simulate a bad optimizer.

    ```
    <copy>
    alter system set optimizer_index_cost_adj=10000;
    show parameter optimizer_index_cost_adj
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> alter system set optimizer_index_cost_adj=10000;

    System altered.

    NAME                                 TYPE        VALUE
    ------------------------------------ ----------- ------------------------------
    optimizer_index_cost_adj             integer     10000
    ```
    </details>

2. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```

3. Connect as the HammerDB benchmark user
    
    ```
    <copy>
    sqlplus tpcc/tpcc@localhost/upgr
    </copy>
    ```

4. Explain the plan for SQL ID *0cwuxyv314wcg*. 

    ```
    <copy>
    explain plan for
    SELECT ROWID FROM CUSTOMER WHERE C_W_ID = :B3 AND C_D_ID = :B2 AND C_LAST =:B1 ORDER BY C_FIRST;
    select * from table(dbms_xplan.display);
    </copy>

    -- Be sure to hit RETURN
    ```

    * The optimizer chooses the index plan for the SQL. 
    * The hack that should ensure the optimizer uses a full table scan is in plan.
    * However, the SQL plan baseline restricts the optimizer to use a plan from the baseline. The only plan in the baseline is the index plan.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> explain plan for
    SELECT ROWID FROM CUSTOMER WHERE C_W_ID = :B3 AND C_D_ID = :B2 AND C_LAST =:B1 ORDER BY C_FIRST;
    select * from table(dbms_xplan.display);  2
    Explained.
    
    SQL> PLAN_TABLE_OUTPUT
    --------------------------------------------------------------------------------
    Plan hash value: 612465046
    
    | Id  | Operation                            | Name	      | Rows | Bytes | Cost (%CPU)| Time     |
    ---------------------------------------------------------------------------------
    |   0 | SELECT STATEMENT                     |             |    3 |   135 | 25408   (1)| 00:00:01 |
    |   1 |  SORT ORDER BY                       |             |    3 |   135 | 25408   (1)| 00:00:01 |
    |*  2 |   TABLE ACCESS BY INDEX ROWID BATCHED| CUSTOMER    |    3 |   135 | 25407   (1)| 00:00:01 |
    |*  3 |    INDEX RANGE SCAN                  | CUSTOMER_I1 | 3000 |       |  1001   (1)| 00:00:01 |
          
    Predicate Information (identified by operation id):
    ---------------------------------------------------
    
       2 - filter("C_LAST"=:B1)
       3 - access("C_W_ID"=TO_NUMBER(:B3) AND "C_D_ID"=TO_NUMBER(:B2))

    Note
    -----
       - SQL plan baseline "SQL_PLAN_6t52hc6fj7bqj9b7dfa5f" used for this statement
    
    20 rows selected.
    ```
    </details>

5. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```

6. Set the environment and connect to *UPGR*.

    ```
    <copy>
    . cdb23
    sqlplus / as sysdba
    alter session set container=UPGR;
    </copy>

    -- Be sure to hit RETURN
    ```    

7. Reset the optimizer hack, changing the parameter back to the default value (100).

    ```
    <copy>
    alter system reset optimizer_index_cost_adj scope=both;
    show parameter optimizer_index_cost_adj
    </copy>

    -- Be sure to hit RETURN
    ```

8. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```    

You may now *proceed to the next lab*.

## Learn More

SQL Plan Management is a preventative mechanism that enables the optimizer to automatically manage execution plans, ensuring that the database uses only known or verified plans.

SQL Plan Management uses a mechanism called a SQL plan baseline, which is a set of accepted plans that the optimizer is allowed to use for a SQL statement.

In this context, a plan includes all plan-related information (for example, SQL plan identifier, set of hints, bind values, and optimizer environment) that the optimizer needs to reproduce an execution plan. The baseline is implemented as a set of plan rows and the outlines required to reproduce the plan. An outline is a set of optimizer hints used to force a specific plan.

- My Oracle Support, [How to Load SQL Plans into SQL Plan Management (SPM) from the Automatic Workload Repository (AWR) (Doc ID 789888.1)](https://support.oracle.com/epmos/faces/DocumentDisplay?id=789888.1)

- My Oracle Support, [How to Use SQL Plan Management (SPM) – Plan Stability Worked Example (Doc ID 456518.1)](https://support.oracle.com/epmos/faces/DocumentDisplay?id=456518.1)

- Technical brief, [SQL Plan Management with Oracle Database 12c Release 2](http://www.oracle.com/technetwork/database/bi-datawarehousing/twp-sql-plan-mgmt-12c-1963237.pdf)

- Webinar, [Performance Stability Perscription #5: SQL Plan Management](https://www.youtube.com/watch?v=qCt1_Fc3JRs&t=5489s)

## Acknowledgements
* **Author** - Daniel Overby Hansen - Scripts provided by: Carlos Sierra
* **Contributors** - Klaus Gronau, Rodrigo Jorge, Alex Zaballa, Mike Dietrich
* **Last Updated By/Date** - Daniel Overby Hansen, January 2025