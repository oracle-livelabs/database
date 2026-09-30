# Fixing SQL Statements by Using Automatic SQL Diagnosis and Repair

## Introduction

Oracle Database enables the user to diagnose a SQL statements for poor performance. It also, gives recommendations to improve the performance by changing the SQL statement. The implementation is easy and automated, as the result of SQL Repair Advisor. This can be implemented after a SQL statement fails with a critical error, ORA-00600 error. After implementation, the applied SQL patch circumvents failure in future events by causing the query optimizer to choose an alternate execution plan. 

The SQL Repair Advisor is run by creating and executing a diagnostic task using the `CREATE_DIAGNOSIS_TASK` and `EXECUTE_DIAGNOSIS_TASK` respectively. This reproduces the critical error and then attempts to produce a workaround in the form of a SQL patch. First, one must identify the problem SQL statement. Then, one must create a diagnostic task and execute it. Lastly, one will report the diagnostic task, apply the patch, and then, test the patch. 

In order to remove the patch, `DBMS_SQLDIAG.DROP_SQL_PATCH` can be implemented with the patch name. The patch name can be queried using the view `DBA_SQL_PATCHES` or obtained from the explain plan section.

### Objectives

In this lab, you will:
* Clean up PDBs and Format Tables
* Execute Poor Performing SQL Statement
* Diagnose SQL Statement and Determine Recommendations
* Verify Recommendations and Implement
* Test Implementation
* Find and Implement Patches
* Clean up Schema

### Prerequisites

This lab assumes you have:
* Obtained and signed in to your `workshop-installed` compute instance.


## Task 1: Clean up PDBs and Format Tables

1.	Execute the /home/oracle/labs/admin/cleanup_PDBs.sh shell script. The shell script drops all PDBs that may have been created by any of the practices in ORCL, and finally re-creates PDB1. You are in Session1.
     
     ```
     $ <copy>$HOME/labs/19cnf/cleanup_PDBs_in_CDB1.sh</copy>
     
     ...

     $
     ```


2.	Before starting the practice, execute the $HOME/labs/DIAG/glogin.sh shell script. It sets formatting for all columns selected in queries.

     ```
     $ <copy>$HOME/labs/19cnf/glogin.sh</copy>
     
     ...

     $
     ```

3.	Execute the /home/oracle/labs/19cnf/table.sh shell script. The shell script creates and loads the DIAG.TAB1 table, and creates an index on the table, in PDB1.
    
    ```
    $ <copy>$HOME/labs/19cnf/table.sh</copy>

    ...

    $
    ```

## Task 2: Execute Poor Performing SQL Statement

4.	Log in to PDB1 as DIAG and execute the query. The SQL statement executes with a poor performance.
    
     ```
     $ <copy>sqlplus system@PDB1</copy> 

     ...

     ```

     ```
     Enter password: <copy>Ora4U_1234</copy>

     ...
     SQL>
     ```

     ```
     SQL> <copy>SELECT /*+ FULL(a) FULL (b) */ sum(a.num),sum(b.num),count(*) FROM tab1 a,diag.tab1 b WHERE a.id = b.id and a.id = 100;</copy>

     ...

     SUM(A.NUM) SUM(B.NUM)   COUNT(*)
     ---------- ---------- ----------
       100        100          1

     SQL> 
     ```

## Task 3: Diagnose SQL Statement and Determine Recommendations

5.	Call the function to diagnose and automatically implement the recommendations to improve performance of the SQL statement.

     ```
     SQL> <copy>DESC dbms_sqldiag</copy>

     ...

     FUNCTION SQL_DIAGNOSE_AND_REPAIR RETURNS NUMBER
     Argument Name                Type                In/Out Default?
     ---------------------------- ------------------- ------ -------
     SQL_ID                       VARCHAR2            IN
     PLAN_HASH_VALUE              NUMBER              IN     DEFAULT
     SCOPE                        VARCHAR2            IN     DEFAULT
     TIME_LIMIT                   NUMBER              IN     DEFAULT
     PROBLEM_TYPE                 NUMBER              IN     DEFAULT
     AUTO_APPLY_PATCH             VARCHAR2            IN     DEFAULT

     SQL> 
     ```

     ```
     SQL> <copy> SET SERVEROUTPUT ON
         VAR incident_id NUMBER
         DECLARE
         recom_count number(10);
         BEGIN
             :incident_id := dbms_sqldiag.sql_diagnose_and_repair(
                          sql_text => 'SELECT /*+ FULL(a) FULL (b) */ sum(a.num),sum(b.num),count(*) FROM tab1 a,diag.tab1 b WHERE a.id = b.id and a.id = 100',
                 problem_type => DBMS_SQLDIAG.PROBLEM_TYPE_PERFORMANCE,
                 time_limit => 1000,
                 scope=>DBMS_SQLDIAG.SCOPE_COMPREHENSIVE,
                 auto_apply_patch => 'YES');
             select count(*) into recom_count from dba_advisor_recommendations where task_name = to_char(:incident_id);
             dbms_output.put_line ( recom_count || ' recommendations generated for incident '||:incident_id);
     end;
     /
     </copy>
     1 recommendations generated for incident 48653
      2    3    4    5    6    7    8    9   10   11   12   13   
     
     ...

     PL/SQL procedure successfully completed.

     SQL>
     ```

6.	Find the recommendations generated from the diagnosis.
     ```
     SQL> <copy> SELECT finding_id, type FROM dba_advisor_recommendations 
     WHERE  task_name = to_char(:incident_id);</copy>
     2

     ...

      FINDING_ID TYPE
      ---------- ------------------------------
         1 EVOLVE PLAN
     
     SQL>
     ```
7.	Report the details of the recommendations.
     ```
     SQL> <copy>VAR b_report CLOB</copy>
     
     ...

     SQL>
     ```
     
     ```
     SQL> <code>DECLARE
       v_tname  VARCHAR2(32767);
     BEGIN
       v_tname   := '48653';
      :b_report := dbms_sqldiag.report_diagnosis_task(v_tname);
     END;
     /
      </code>
       2    3    4    5    6    7  
     
     ...

     PL/SQL procedure successfully completed.
     
     SQL> 
     ```

     ```
     SQL> <copy> DECLARE
      v_len   NUMBER(10);
       v_offset NUMBER(10) :=1;
       v_amount  NUMBER(10) :=10000;
     BEGIN
      v_len := DBMS_LOB.getlength(:b_report);
      WHILE (v_offset < v_len)
      LOOP
     DBMS_OUTPUT.PUT_LINE(DBMS_LOB.SUBSTR(:b_report,v_amount,v_offset));
         v_offset := v_offset + v_amount;
       END LOOP;
     END;
     /</copy>
       2    3    4    5    6    7    8    9   10   11   12   13 

     ...

     GENERAL INFORMATION
     SECTION
     ------------------------------------------------------------
     -------------------
     Tuning Task Name   : 48653
     Tuning Task Owner  :
     SYSTEM
     Workload Type      : Single SQL Statement
     Scope
     : COMPREHENSIVE
     Time Limit(seconds): 1000
     Completion Status  :
     COMPLETED
     Started at         : 01/19/2022 17:35:19
     Completed at
     : 01/19/2022
     17:35:19

     ----------------------------------------------------------
     ---------------------
     Schema Name   : SYSTEM
     Container Name:
     PDB1
     SQL ID        : 3p8dvvjvuk51w
     SQL Text      : SELECT /*+
     FULL(a) FULL (b) */ sum(a.num),sum(b.num),count(*)

     FROM diag.tab1 a,diag.tab1 b WHERE a.id = b.id and a.id =
     100

     ---------------------------------------------------------------
     ----------------
     FINDINGS SECTION (1
     finding)
     -----------------------------------------------------------
     --------------------

     1- SQL Profile Finding (see explain plans
     section
     below)
     --------------------------------------------------------
       A
     potentially better execution plan was found for this statement.


     Recommendation (estimated benefit: 99.84%)

     ------------------------------------------
       - A manually-created
     SQL profile is present on the system.
        Name:
     SYS_SQLPROF_017e736843fa0000
         Status: ENABLED

      Validation
     results
       ------------------
       The SQL profile was tested by
     executing both its plan and the original plan
       and measuring their
     respective execution statistics. A plan may have been
       only
     partially executed if the other could be run to completion in less
     time.

                                Original Plan  With SQL Profile  %
     Improved
                                -------------  ----------------
     ----------
      Completion Status:            COMPLETE
     COMPLETE
       Elapsed Time (s):             .003897           .000014
     99.64 %
       CPU Time (s):                 .003882           .000014
     99.63 %
       User I/O Time (s):                  0                 0 

     Buffer Gets:                     3772                 6      99.84
     %
       Physical Read Requests:             0                 0 

     Physical Write Requests:            0                 0 
       Physical
     Read Bytes:                0                 0 
       Physical Write
     Bytes:               0                 0 
       Rows Processed:
     1                 1 
       Fetches:                            1
     1 
       Executions:                         1                 1 


     Notes
       -----
       1. Statistics for the original plan were averaged
     over 10 executions.
       1. Statistics for the SQL profile plan were
     averaged over 10
     executions.

     -------------------------------------------------------
     ------------------------


     PL/SQL procedure successfully completed.

     SQL>
     ```

## Task 4: Verify Recommendations and Implement

8.	Check the SQL profile automatically created by the diagnosis and repair function.
     ```
     SQL> <copy>SELECT sql_text, status FROM dba_sql_profiles;</copy>

     ...

     SQL_TEXT                                              STATUS
     ----------------------------------------------------- ----------
     select /*+ FULL(a) FULL (b) */ sum(a.num),sum(b.num), ENABLED
     count(*) from tab1 a,diag.tab1 b where a.id = b.id 
     and a.id = 100


     SQL>
     ```

9.	Verify that the poor performing SQL statement is now using the SQL profile.

     ```
     SQL> <copy>EXPLAIN PLAN FOR SELECT /*+ FULL(a) FULL (b) */ sum(a.num),sum(b.num),count(*) FROM diag.tab1 a,diag.tab1 b WHERE a.id = b.id and a.id = 100;</copy>

     ...

     Explained.

     SQL>
     ```
     
     ```
     SQL> <copy>SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);</copy>

     ...

     PLAN_TABLE_OUTPUT
     ----------------------------------------------------------------
     Plan hash value: 3082937155
     ----------------------------------------------------------------
     | Id  | Operation                              | Name   | Rows  | By tes | Cost (%CPU)| Time     |
     ----------------------------------------------------------------
     |   0 | SELECT STATEMENT                       |        |     1 | 20 |     4   (0)| 00:00:01 |
     |   1 |  SORT AGGREGATE                        |        |     1 | 20 |            |          |
     |   2 |   MERGE JOIN CARTESIAN                 |        |     1 | 20 |     4   (0)| 00:00:01 |
     |   3 |    TABLE ACCESS BY INDEX ROWID BATCHED | TAB1   |     1 | 10 |     2   (0)| 00:00:01 |
     |*  4 |     INDEX RANGE SCAN                   | TAB1_I |     1 |    |     1   (0)| 00:00:01 |
     |   5 |    BUFFER SORT                         |        |     1 | 10 |     2   (0)| 00:00:01 |
     |   6 |     TABLE ACCESS BY INDEX ROWID BATCHED| TAB1   |     1 | 10 |     2   (0)| 00:00:01 |
     |*  7 |      INDEX RANGE SCAN                  | TAB1_I |     1 |    |     1   (0)| 00:00:01 |
     ----------------------------------------------------------------Predicate Information (identified by operation id):
     ---------------------------------------------------
        4 - access("A"."ID"=100)
        7 - access("B"."ID"=100)

     Hint Report (identified by operation id / Query Block Name / Object Alias):

     Total hints for statement: 2 (U - Unused (2))
     ----------------------------------------------------------------    
       3 -  SEL$1 / A@SEL$1
             U -  FULL(a) / rejected by IGNORE_OPTIM_EMBEDDED_HINTS

       6 -  SEL$1 / B@SEL$1
             U -  FULL (b) / rejected by IGNORE_OPTIM_EMBEDDED_HINTS

     Note
     -----
       - SQL profile "SYS_SQLPROF_0166b07518cc0001" used for this statement


     22 rows selected.

     SQL> 
     ```

10.	Call the function on the poor performing SQL statement. 

    Q2/ What happens if you ask the diagnosis function to explore all alternative plans for the SQL query?

     ```
     SQL> <copy> DECLARE
     BEGIN
       :incident_id := dbms_sqldiag.sql_diagnose_and_repair(
           sql_text => ' SELECT /*+ FULL(a) FULL (b) */ sum(a.num),sum(b.num),count(*) FROM diag.tab1 a,diag.   tab1 b WHERE a.id = b.id and a.id = 100',
          problem_type => DBMS_SQLDIAG.PROBLEM_TYPE_ALT_PLAN_GEN,
          auto_apply_patch => 'YES');
     END;
     /</copy>
      2    3    4    5    6    7    8 

     ...

     DECLARE
     *
     ERROR at line 1:
     ORA-20001: '5' - invalid problem type
     ORA-06512: at "SYS.DBMS_SQLDIAG_INTERNAL", line 587
     ORA-06512: at "SYS.DBMS_SQLDIAG", line 391
     ORA-06512: at "SYS.DBMS_SQLDIAG", line 2454
     ORA-06512: at line 3


     SQL>
     ```

    A2/ The problem type PROBLEM_TYPE_ALT_PLAN_GEN refers to the constant 5 (refer task 5). As there are no other plans in DBA_SQL_PLAN_BASELINES for the same query, the function cannot satisfy the condition to find alternate plans.

## Task 5: Test Implementation

11.	You now test a failing SQL statement for which SQL Diagnose and Repair provides and implements a patch. Execute the /home/oracle/labs/DIAG/crash_delete.sql SQL script. The SQL statement fails with an ORA-00600 error. Press Enter after each pause.

     ```
     SQL><copy>CONNECT system@PDB1</copy>
     ```

     ... 

     ```
     Enter password: <copy>Ora4U_1234</copy>
     Connected.

     ...

     SQL>
     ```


     ```
     SQL> <copy>$HOME/oracle/labs/19cnf/crash_delete.sql</copy>
     
     ...

     SQL>
     SQL> -- This example generates a workaround for a crash. This bug has already
     SQL> -- been fixed but we toggle the bug fix using an underscore parameter
     SQL> -- which uses the (internal) feature called bug fix control.
     SQL> -- This script will pause periodically to allow you to read the comments
     SQL> -- and see the output of the previous command on the screen. Just press
     SQL> -- return to make the demo resume.
     SQL>
     SQL> pause

     SQL>
     SQL> -- To begin the demo we will create the user diag and grant
     SQL> -- advisor privileges to him.
     SQL>
     SQL> pause

     SQL>
     SQL> grant connect, resource, dba, query rewrite, unlimited tablespace to diag identified by password;

     Grant succeeded.

     SQL>
     SQL> alter user diag account unlock;

     User altered.

     SQL>
     SQL> -- Next we need to create and populate the table used by the demo.
     SQL> -- We will also create an index on the table;
     SQL>
     SQL> pause

     SQL> connect diag/password@PDB1;
     Connected.
     SQL>
     SQL> drop table simple_table;
     drop table simple_table
               *
     ERROR at line 1:
     ORA-00942: table or view does not exist


     SQL>
     SQL> create table simple_table(a varchar(40), b number, c varchar(240), d varchar(240));

     Table created.

     SQL>
     SQL> create index tc on simple_table(b, d, a);

     Index created.

     SQL>
     SQL> insert into simple_table values('a', 1, 'b', 'c');

     1 row created.

     SQL> insert into simple_table values('a', 1, 'x', 'c');

     1 row created.

     SQL> insert into simple_table values('e', 2, 'f', 'g');

     1 row created.

     SQL>
     SQL> -- In order to crash the system we need to switch off the code line that
     SQL> -- normal protects against this type of crash. We can switch off the code
     SQL> -- using the (internal) feature called bug fix control.
     SQL>
     SQL> pause

     SQL>
     SQL> -- switch the code
     SQL> alter system set "_fix_control"="5868490:OFF";

     System altered.

     SQL> -- alter session set optimizer_dynamic_sampling = 0;
     SQL>
     SQL> -- Now that the code line has been switched off lets get the execution
     SQL> -- plan for a simple delete statement.
     SQL>
     SQL> pause

     SQL>
     SQL> --- explain the plan
     SQL> explain plan for delete
      2    /*+
      3        USE_HASH_AGGREGATION(@"SEL$80F8B8C6")
      4        USE_HASH(@"SEL$80F8B8C6" "T1"@"DEL$1")
      5        LEADING(@"SEL$80F8B8C6" "T2"@"SEL$1" "T1"@"DEL$1")
      6        FULL(@"SEL$80F8B8C6" "T1"@"DEL$1")
      7        FULL(@"SEL$80F8B8C6" "T2"@"SEL$1")
      8        OUTLINE(@"DEL$1")
      9        OUTLINE(@"SEL$1")
     10        OUTLINE(@"SEL$AD0B6B07")
     11        OUTLINE(@"SEL$7D4DB4AA")
     12        UNNEST(@"SEL$1")
     13        OUTLINE(@"SEL$75B5BFA2")
     14        MERGE(@"SEL$7D4DB4AA")
     15        OUTLINE_LEAF(@"SEL$80F8B8C6")
     16        ALL_ROWS
     17        OPT_PARAM('_optimizer_cost_model' 'fixed')
     18        DB_VERSION('11.1.0.7')
     19        OPTIMIZER_FEATURES_ENABLE('11.1.0.7')
     20        NO_INDEX(@"SEL$1" "T2"@"SEL$1")
     21    */
     22  from simple_table t1 where t1.a = 'a' and rowid <> (select max(rowid) from simple_table t2 where t1.a= t2.a and t1.b = t2.b and t1.d=t2.d);

     Explained.

     SQL>
     SQL> --- display the plan
     SQL> select plan_table_output from table(dbms_xplan.display('plan_table',null));

     PLAN_TABLE_OUTPUT
     ----------------------------------------------------------------
     Plan hash value: 1481897562
     ----------------------------------------------------------------
     | Id  | Operation             | Name         | Rows  | Bytes | Cost
     (%CPU)| Time     |
     ----------------------------------------------------------------|   0 | DELETE STATEMENT      |              |     1 |   338 |     6
       (34)| 00:00:01 |
     |   1 |  DELETE               | SIMPLE_TABLE |       |       |
          |          |
     |*  2 |   FILTER              |              |       |       |
          |          |
     |   3 |    HASH GROUP BY      |              |     1 |   338 |     6
       (34)| 00:00:01 |
     |*  4 |     HASH JOIN         |              |     1 |   338 |     5
      (20)| 00:00:01 |
     |*  5 |      TABLE ACCESS FULL| SIMPLE_TABLE |     2 |   338 |     2
        (0)| 00:00:01 |
     |*  6 |      TABLE ACCESS FULL| SIMPLE_TABLE |     2 |   338 |     2
       (0)| 00:00:01 |
     ----------------------------------------------------------------
     Predicate Information (identified by operation id):
     ---------------------------------------------------

        2 - filter(ROWID<>MAX(ROWID))
       4 - access("T1"."A"="T2"."A" AND "T1"."B"="T2"."B" AND "T1"."D"="
     T2"."D")

        5 - filter("T2"."A"='a')
        6 - filter("T1"."A"='a')

     Note
     -----
       - dynamic statistics used: dynamic sampling (level=2)

     25 rows selected.

     SQL>
     SQL> -- The plan shows that we will do a full table scan oun r.
     SQL> -- If we execute this simple system it will crash the system.
     SQL>
     SQL> Pause

     SQL> --- This statement caused the system to crash.
     SQL> delete /*+ USE_HASH_AGGREGATION(@"SEL$80F8B8C6") USE_HASH(@"SEL$80F8B8C6" "T1"@"DEL$1") LEADING(@"SEL$80F8B8C6" "T2"@"SEL$1" "T1"@"DEL$1") FULL(@"SEL$80F8B8C6" "T1"@"DEL$1") FULL(@"SEL$80F8B8C6" "T2"@"SEL$1") OUTLINE(@"DEL$1") OUTLINE(@"SEL$1") OUTLINE(@"SEL$AD0B6B07") OUTLINE(@"SEL$7D4DB4AA") UNNEST(@"SEL$1") OUTLINE(@"SEL$75B5BFA2") MERGE(@"SEL$7D4DB4AA") OUTLINE_LEAF(@"SEL$80F8B8C6") ALL_ROWS OPT_PARAM('_optimizer_cost_model' 'fixed') DB_VERSION('11.1.0.7') OPTIMIZER_FEATURES_ENABLE('11.1.0.7') NO_INDEX(@"SEL$1" "T2"@"SEL$1") */ from simple_table t1 where t1.a = 'a' and rowid <> (select max(rowid) from simple_table t2 where t1.a= t2.a and t1.b = t2.b and t1.d=t2.d);
     delete /*+ USE_HASH_AGGREGATION(@"SEL$80F8B8C6") USE_HASH(@"SEL$80F8B8C6" "T1"@"DEL$1") LEADING(@"SEL$80F8B8C6" "T2"@"SEL$1" "T1"@"DEL$1") FULL(@"SEL$80F8B8C6" "T1"@"DEL$1") FULL(@"SEL$80F8B8C6" "T2"@"SEL$1") OUTLINE(@"DEL$1") OUTLINE(@"SEL$1") OUTLINE(@"SEL$AD0B6B07") OUTLINE(@"SEL$7D4DB4AA") UNNEST(@"SEL$1") OUTLINE(@"SEL$75B5BFA2") MERGE(@"SEL$7D4DB4AA") OUTLINE_LEAF(@"SEL$80F8B8C6") ALL_ROWS OPT_PARAM('_optimizer_cost_model' 'fixed') DB_VERSION('11.1.0.7') OPTIMIZER_FEATURES_ENABLE('11.1.0.7') NO_INDEX(@"SEL$1" "T2"@"SEL$1") */ from simple_table t1 where t1.a = 'a' and rowid <> (select max(rowid) from simple_table t2 where t1.a= t2.a and t1.b = t2.b and t1.d=t2.d)
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          *
     ERROR at line 1:
     ORA-00600: internal error code, arguments: [13011], [72860],
     [4227169], [0], [4227169], [17], [], [], [], [], [], []


     SQL>
     ```

12.	Call the function to diagnose and automatically implement the patch for the failing SQL statement.
a.	Find the SQL_ID for the failing statement.

     ```
     SQL> <copy>SELECT sql_id FROM v$sql 
         WHERE  sql_text LIKE 'delete%USE_HASH%';</copy>
      2
     
     ...

     SQL_ID
     -------------
     53390wmjjqgra

     1 row selected.

     SQL>
     ```

     b.	Call the function with SQL_ID as input and the appropriate problem type. (Refer task 5).
     
     ```
     SQL> <copy>SET SERVEROUTPUT ON</copy>
     
     ...

     ```

     ```
     SQL> <copy>VAR incident_id NUMBER</copy>

     ...

     SQL>
     ```

     ```
     SQL> <copy>DECLARE
       recom_count number(10);
     BEGIN
       :incident_id := dbms_sqldiag.sql_diagnose_and_repair(
                        sql_id => '53390wmjjqgra',
                        problem_type => 4,
                        auto_apply_patch => 'YES');
        SELECT count(*) into recom_count 
        FROM   dba_advisor_recommendations 
         WHERE  task_name = to_char(:incident_id);
         dbms_output.put_line ( recom_count || ' recommendations generated for incident '||:incident_id);
     END;
     / </copy>
      2    3    4    5    6    7    8    9   10   11   12   13
     
     ...
     1 recommendations generated for incident 96043
     PL/SQL procedure successfully completed.

     SQL>
     ```

13.	Find the recommendations generated from the diagnosis.

     ```
     SQL> <copy>SELECT finding_id, type FROM dba_advisor_recommendations 
     WHERE  task_name = to_char(:incident_id);</copy>
     2

     ...

     FINDING_ID TYPE
     ---------- ------------------------------
             1 SQL PATCH

     1 row selected.

     SQL>
     ```

## Task 6: Find and Implement Patches

14.	Find the SQL patch.

     ```
     SQL> <copy>SELECT name, task_exec_name, status FROM dba_sql_patches 
     WHERE  name = to_char(:incident_id)
     AND    sql_text LIKE 'delete%';</copy>
      2   3  

     ...

     NAME                     TASK_EXEC_NAME STATUS
     ------------------------ -------------- ----------
     96043                    EXEC_1         ENABLED
 
     1 row selected.

     SQL>
     ```

     Q3/ Is the SQL patch implemented?

     ```
     SQL> <copy>EXPLAIN PLAN FOR delete
      /*+
          USE_HASH_AGGREGATION(@"SEL$80F8B8C6")
          USE_HASH(@"SEL$80F8B8C6" "T1"@"DEL$1")
          LEADING(@"SEL$80F8B8C6" "T2"@"SEL$1" "T1"@"DEL$1")
          FULL(@"SEL$80F8B8C6" "T1"@"DEL$1")
          FULL(@"SEL$80F8B8C6" "T2"@"SEL$1")
          OUTLINE(@"DEL$1")
          OUTLINE(@"SEL$1")
          OUTLINE(@"SEL$AD0B6B07")
          OUTLINE(@"SEL$7D4DB4AA")
          UNNEST(@"SEL$1")
          OUTLINE(@"SEL$75B5BFA2")
          MERGE(@"SEL$7D4DB4AA")
          OUTLINE_LEAF(@"SEL$80F8B8C6")
          ALL_ROWS
          OPT_PARAM('_optimizer_cost_model' 'fixed')
          DB_VERSION('11.1.0.7')
          OPTIMIZER_FEATURES_ENABLE('11.1.0.7')
          NO_INDEX(@"SEL$1" "T2"@"SEL$1")
       */
     from simple_table t1 where t1.a = 'a' and rowid <> (select max(rowid) from simple_table t2 where t1.a= t2.a and t1.b = t2.b and t1.d=t2.d);</copy>
     2    3    4    5    6    7    8    9   10   11   12   13   14   15   16   17   18   19   20   21   22

     ...
     
     Explained.

     SQL>
     ```

     ```
     SQL> <copy>SELECT plan_table_output 
          FROM  TABLE(dbms_xplan.display('plan_table',null));</copy>
    
     ...

     PLAN_TABLE_OUTPUT
     ----------------------------------------------------------------
     Plan hash value: 3259336479
     ----------------------------------------------------------------
     | Id  | Operation            | Name         | Rows  | Bytes | Cost (%CPU)| Time     |
     ----------------------------------------------------------------
     |   0 | DELETE STATEMENT     |              |     1 |   169 |     3  (0)| 00:00:01 |
     |   1 |  DELETE              | SIMPLE_TABLE |       |       |
     |*  2 |   FILTER             |              |       |       |
     |*  3 |    INDEX FULL SCAN   | TC           |     2 |   338 |     1  (0)| 00:00:01 |
     |   4 |    SORT AGGREGATE    |              |     1 |   169 |
     |*  5 |     TABLE ACCESS FULL| SIMPLE_TABLE |     1 |   169 |     2  (0)| 00:00:01 |
     ----------------------------------------------------------------

     Predicate Information (identified by operation id):
     ---------------------------------------------------
       2 - filter(ROWID<> (SELECT /*+ UNNEST UNNEST NO_INDEX ("T2") NO_INDEX ("T2") */ MAX(ROWID) FROM "SIMPLE_TABLE" "T2" WHERE "T
     2"."A"=:B1 AND "T2"."B"=:B2 AND "T2"."D"=:B3))
       3 - access("T1"."A"='a')
           filter("T1"."A"='a')
       5 - filter("T2"."A"=:B1 AND "T2"."B"=:B2 AND "T2"."D"=:B3)

     Hint Report (identified by operation id / Query Block Name / Object Alias):

     Total hints for statement: 7 (U - Unused (2), N - Unresolved (5))
     ----------------------------------------------------------------
        0 -  SEL$7D4DB4AA
         N -  MERGE(@"SEL$7D4DB4AA")

        0 -  SEL$80F8B8C6
             N -  FULL(@"SEL$80F8B8C6" "T1"@"DEL$1")
             N -  FULL(@"SEL$80F8B8C6" "T2"@"SEL$1")
             N -  LEADING(@"SEL$80F8B8C6" "T2"@"SEL$1" "T1"@"DEL$1")
             N -  USE_HASH(@"SEL$80F8B8C6" "T1"@"DEL$1")

       4 -  SEL$1
              U -  UNNEST(@"SEL$1") / hint overridden by NO_QUERY_TRANSFORMATION

       5 -  SEL$1 / T2@SEL$1
             U -  NO_INDEX(@"SEL$1" "T2"@"SEL$1")

     Note
     -----
       - dynamic statistics used: dynamic sampling (level=2)
       - SQL patch "96043" used for this statement

     46 rows selected.

     SQL> 
     ```

     A3/ The SQL patch is automatically implemented.
     

15.	Re-execute the failing SQL statement with the implemented patch.

     ```
     SQL> <copy>delete /*+ USE_HASH_AGGREGATION(@"SEL$80F8B8C6") USE_HASH(@"SEL$80F8B8C6" "T1"@"DEL$1") LEADING(@"SEL$80F8B8C6" "T2"@"SEL$1" "T1"@"DEL$1") FULL(@"SEL$80F8B8C6" "T1"@"DEL$1") FULL(@"SEL$80F8B8C6" "T2"@"SEL$1") OUTLINE(@"DEL$1") OUTLINE(@"SEL$1") OUTLINE(@"SEL$AD0B6B07") OUTLINE(@"SEL$7D4DB4AA") UNNEST(@"SEL$1") OUTLINE(@"SEL$75B5BFA2") MERGE(@"SEL$7D4DB4AA") OUTLINE_LEAF(@"SEL$80F8B8C6") ALL_ROWS OPT_PARAM('_optimizer_cost_model' 'fixed') DB_VERSION('11.1.0.7') OPTIMIZER_FEATURES_ENABLE('11.1.0.7') NO_INDEX(@"SEL$1" "T2"@"SEL$1") */ from simple_table t1 where t1.a = 'a' and rowid <> (select max(rowid) from simple_table t2 where t1.a= t2.a and t1.b = t2.b and t1.d=t2.d);</copy>

     ...

     1 row deleted.

     SQL>
     ```

     ```
     SQL> <copy>ROLLBACK;</copy>

     ...

     Rollback complete.

     SQL>
     ```

     ```
     SQL> <copy>EXIT</copy>

     ...
     
     $
     ```

     Observe that the statement does not fail anymore.

## Task 7: Clean up Schema

16.	Set the fix for the error back ON and clean up the DIAG schema.

     ```
     $ <copy>$HOME/oracle/labs/19cnf/cleanup_crash.sh</copy>

     ...

     $
     ```

## Learn More

- [Diagnosing and Resolving Problems](https://docs.oracle.com/en/database/oracle/oracle-database/19/admin/diagnosing-and-resolving-problems.html#GUID-2F2E3F4B-ECE3-4AF0-91B0-4CB437FB21CC)
- [SQL Diagnosability Package](https://docs.oracle.com/database/121/ARPLS/d_sqldiag.htm#ARPLS68285)

## Acknowledgements

- **Author**- Dominique Jeunot, Consulting User Assistance Developer
- **Last Updated By/Date** - Nicholas Cusato, Santa Monica Specialists Hub, January 2022