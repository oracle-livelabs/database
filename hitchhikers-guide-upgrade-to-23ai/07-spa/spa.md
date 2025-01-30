# SQL Performance Analyzer

## Introduction

In this lab, you will use the SQL Performance Analyzer (SPA) that is a part of the Real Application Testing (RAT) option. You will compare statements collected before the upgrade to a simulation of these statements after upgrade. You will use the SQL Tuning Sets collected earlier in the workshop.

Estimated Time: 10 minutes

[Hitchhiker's Guide Lab 7](youtube:lwvdaM4v4tQ?start=3165)

### Objectives

In this lab, you will:
* Check statements

### Prerequisites

This lab assumes:

- You have completed Lab 6: AWR Compare Periods

## Task 1: Check statements

1. Use the *yellow* terminal. Set the environment and connect to *CDB23*, then switch to *UPGR*.

      ```
      <copy>
      . cdb23
      sqlplus / as sysdba
      alter session set container=UPGR;
      </copy>

      -- Be sure to hit RETURN
      ```

2. Check the SQL Tuning Sets and the number of statements in them:

    ```
    <copy>
    col sqlset_name format a40
    select count(*), sqlset_name 
    from dba_sqlset_statements 
    where sqlset_name like 'STS_Capture%'
    group by sqlset_name order by 2;
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> col sqlset_name format a40
    SQL> select count(*), sqlset_name 
         from dba_sqlset_statements 
         where sqlset_name like 'STS_Capture%'
         group by sqlset_name order by 2;

      COUNT(*) SQLSET_NAME
    ---------- ----------------------------------------
            31 STS_CaptureAWR
            41 STS_CaptureCursorCache
    ```
    </details>

3. The idea of the *Performance Stability Prescription* is to identify bad performance after upgrade. However, the workload in this lab runs faster in Oracle Database 23ai. To get the best benefit out of the lab, you simulate bad performance. This lab changes optimizer behavior (*optimizer\_index\_cost\_adj*) which has a negative impact on the workload.
You should imagine that this workload performs bad without any changes after upgrade to Oracle Database 23ai. 
Verify *optimizer\_index\_cost\_adj* is set to *10000*. This causes the optimizer to disregard index scans and perform full table scan. This causes bad performance.

    ```
    <copy>
    show parameter optimizer_index_cost_adj
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> show parameter optimizer_index_cost_adj

    NAME                                 TYPE        VALUE
    ------------------------------------ ----------- ------------------------------
    optimizer_index_cost_adj             integer     10000
    ```
    </details>

    If you see any **a value different from 10000** for the *optimizer\_index\_cost\_adj*, adjust it.

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

4. Analyze performance in the upgraded database. Using the workload captured in SQL Tuning Sets before the upgrade as a baseline, the database now *test executes* the workload stored in the SQL Tuning Sets, but this time in an upgraded database. Now you can see the effect of the new 23ai optimizer. First, you compare *CPU\_TIME*.

    ```
    <copy>
    @/home/oracle/scripts/spa_cpu.sql
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> @/home/oracle/scripts/spa_cpu.sql
    SQL Tuning Set does exist - will run SPA now ...
    SQL Performance Analyzer Task does not exist - will be created ...

    PL/SQL procedure successfully completed.
    ```
    </details>

    The script:
    - Convert the information from `STS_CaptureAWR` into the right format.
    - Simulate the execution of all statements in `STS_CaptureAWR`.
    - Compare before/after.
    - Report on the results based on *CPU\_TIME*.

5. Generate the HTML Report containing the results below.

    ```
    <copy>
    @/home/oracle/scripts/spa_report_cpu.sql
    </copy>
    ```
6. Then repeat this for *ELAPSED\_TIME*. First, analyze performance.

    ```
    <copy>
    @/home/oracle/scripts/spa_elapsed.sql
    </copy>
    ```

7. Next, generate a report.

    ```
    <copy>
    @/home/oracle/scripts/spa_report_elapsed.sql
    </copy>
    ```

8. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```

9. Open the two SPA reports. Put them side-by-side.

    ```
    <copy>
    firefox compare_spa_* &
    </copy>
    ```
    ![Notice that there will be two html files in scripts folder](./images/spa-compare-two-reports-23ai.png " ")

    Notice:
    * The comparison method used in the two reports - *CPU\_TIME* and *ELAPSED\_TIME*.
    * Check the *Overall Impact* metric in the two reports. The test executions show that after upgrade the database performs much worse than before upgrade. 
        - For *CPU\_TIME* there is more than 350% regression in performance.
        - For *ELAPSED\_TIME* there is around 250% regression in performance.
        - Numbers might vary in your database.
    * *Conclusion:* The workload runs much slower in the upgraded database.

10. Scroll down to *Top nn SQL ...*. The list shows the SQLs sorted by impact.

    ![recognize regressed statements and statements with plan change](./images/spa-report-top-sql-23ai.png " ")

    * The first table, on the left, shows the SQLs that are using more CPU time after upgrade. These are the red rows. 
    * The green row is a SQL using less CPU time after upgrade. 
    * The rows without a color are using the same CPU time after upgrade. The threshold in the SPA comparison is set to 2 %. Only SQLs changing more than that are highlighted.
    * All regressing SQLs (the red rows) have a plan change.
    * The second table, on the right, uses elapsed time as metric instead of CPU time.

11. In the first report, find the details on SQL ID *0cwuxyv314wcg* and see the difference in execution plans.

    ![See details on individual SQLs](./images/spa-plan-compare-23ai.png " ")

    * Notice how the plan changes. Before upgrade, the optimizer used an index to find the rows. After upgrade, the optimizer chooses a full table scan. This is a consequence of the change to *optimizer\_index\_cost\_adj*.
    * Since only a few rows are needed, an index lookup is much faster than the full table scan

12. Examine the other parts of the SPA reports.

13. Close Firefox.

14. Reconnect to the database.

      ```
      <copy>
      . cdb23
      sqlplus / as sysdba
      alter session set container=UPGR;
      </copy>

      -- Be sure to hit RETURN
      ```

15. Implement a change and re-test workload. Imagine you have found the root cause of the bad performance. In this case, you know it is *optimizer\_index\_cost\_adj*. Now, you change the parameter back to the default value (100) and repeat the test.


    ```
    <copy>
    alter system reset optimizer_index_cost_adj scope=both;
    show parameter optimizer_index_cost_adj
    </copy>

    -- Be sure to hit RETURN
    ```

    * In a real situation, you could make many other changes. Change statistics preferences, gather new statistics, toggle optimizer fixes with `DBMS_OPTIM_BUNDLE`, or many other things.

16. Re-analyze the workload based on *ELAPSED\_TIME*. This allows you to see the impact of the change on the database.

    ```
    <copy>
    @/home/oracle/scripts/spa_elapsed.sql
    </copy>
    ```

17. Generate a new report.

    ```
    <copy>
    @/home/oracle/scripts/spa_report_elapsed.sql
    </copy>
    ```

18. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```

19. Open it with Firefox.

    ```
    <copy>
    firefox $(ls -t compare_spa_runs*html | head -1) &
    </copy>
    ```

20. Find the details on SQL ID *0cwuxyv314wcg* again.

    ![No change of plans](./images/spa-change-plan-compare-23ai.png " ")

    * Notice that the plan no longer changes. Without *optimizer\_index\_cost\_adj* the optimizer chooses the same plan after upgrade. 
    * The new SPA report focuses on elapsed time. In this case, there is an improvement in the test execution (it is a green row). 

21. Close Firefox.

Normally, you would focus on the SQLs with a negative impact on your workload. The idea of such SPA runs is to accept the better plans and identify and cure the ones which are regressing.

You may now *proceed to the next lab*.

## Learn More

You can run SQL Performance Analyzer on a production system or a test system that closely resembles the production system. It's highly recommended to execute the SQL Performance Analyzer runs on a test system rather than directly on the production system.

* Documentation, [SQL Performance Analyzer](https://docs.oracle.com/en/database/oracle/oracle-database/19/ratug/introduction-to-sql-performance-analyzer.html#GUID-860FC707-B281-4D81-8B43-1E3857194A72)
* Webinar, [Performance Stability Perscription #3: SQL Performance Analyzer](https://www.youtube.com/watch?v=qCt1_Fc3JRs&t=4463s)

## Acknowledgements
* **Author** - Daniel Overby Hansen
* **Contributors** - Klaus Gronau, Rodrigo Jorge, Alex Zaballa, Mike Dietrich
* **Last Updated By/Date** - Daniel Overby Hansen, August 2024
