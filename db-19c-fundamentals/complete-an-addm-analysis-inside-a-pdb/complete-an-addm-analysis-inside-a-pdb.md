# Complete an ADDM analysis inside a PDB

## Introduction

Starting with Oracle Database 12c, ADDM is enabled by default in the root container of a multitenant container database (CDB). Starting with Oracle Database 19c, you can also use ADDM in a pluggable database (PDB).

In a CDB, ADDM works in the same way as it works in a non-CDB, that is, the ADDM analysis is performed each time an AWR snapshot is taken on a CDB root or a PDB, and the ADDM results are stored on the same database system where the snapshot is taken. The time period analyzed by ADDM is defined by the last two snapshots (the last hour by default).

### Objectives

In this lab, you will:
- Prepare your environment
- Run workload
- Analyze PDB1 using ADDM 
- Analyze CDB1 with ADDM
- Clean your environment

### Prerequisites
This lab assumes you have:
- Obtained and signed in to your `workshop-installed` compute instance.

## Task 1: Prepare your environment

> **NOTE:** Unless otherwise stated, all passwords will be `Ora4U_1234`. When copying and pasting a command that includes a password, please replace the word `password` with `Ora4U_1234`. This only applies to instances created through OCI Resource Manager with our provided terraform scripts.

1. Open a terminal window on the desktop.

2. Set the Oracle environment variables. At the prompt, enter CDB1.

    ```
    $ <copy>. oraenv</copy>
    CDB1
    ```
  
3. Run the `cleanup_PDBs_in_CDB1.sh` shell script to drop all PDBs in CDB1 that may have been created in other labs, and recreate PDB1. You can ignore any error messages that are caused by the script. They are expected.

    ```
    $ <copy>$HOME/labs/19cnf/cleanup_PDBs_in_CDB1.sh</copy>
    ```

4. execute the `$HOME/labs/19cnf/glogin.sh` shell script. It sets formatting for all columns selected in queries.

    ```
    $ <copy>$HOME/labs/19cnf/glogin.sh</copy>
    ```

## Task 2: Run workload

1. Let's call the current session **session 1**. Log in to PDB1 as the `SYS` user.

    ```
    $ <copy>sqlplus sys@PDB1 as sysdba</copy>
    Enter password: password
    ```
   
2. Now, open up a new terminal session, we will refer to this as **session 2**.

3. In **session 2**, set the Oracle environment variables. At the prompt, enter CDB1

    ```
    $ <copy>. oraenv</copy>
    ```

4. In **session 2**, run the workload script. This script will run until the runload file is removed.

    ```
    $ <copy>cd $HOME/labs/19cnf</copy>
    $ <copy>./start_workload.sh 1 PDB1</copy>
    ```

5. While the workload executes in **session 2**, create a snapshot in **session 1**.

    ```
    SQL> <copy>EXEC dbms_workload_repository.create_snapshot()</copy>

    PL/SQL procedure successfully completed.
    ```

6. Wait a few minutes, then create another snapshot in **session 1**.

    ```
    SQL> <copy>EXEC dbms_workload_repository.create_snapshot()</copy>

    PL/SQL procedure successfully completed.
    ```

## Task 3: Analyze PDB1 using ADDM

1. In **session 1**, create a variable `tname` to store the task name.

    ```
    SQL> <copy>VAR tname VARCHAR2(60)</copy>
    ```

2. In **session 1**, execute the ADDM task manually.

    ```
    <copy>BEGIN
     :tname := 'PDB1_analysis_mode_task';
     DBMS_ADDM.ANALYZE_DB( :tname, 1, 2);
     END;
    /</copy>

    ```

3. View the PDB report in **session 1**. You can then schedule the task repetitively. Notice that the recommendations are limited to the PDB-level. Notice the line **ADDM detected that the database type is PDB.**

    ```
    SQL> <copy>SET LONG 10000</copy>
    SQL> <copy>SET PAGESIZE 50000</copy>
    SQL> <copy>SELECT dbms_addm.get_report(:tname) FROM DUAL;</copy>

        DBMS_ADDM.GET_REPORT(:TNAME)
    --------------------------------------------------------------------
            ADDM Report for Task 'PDB1_analysis_mode_task'
            ----------------------------------------------

    Analysis Period
    ---------------
    AWR snapshot range from 1 to 2.
    Time period starts at 08-MAR-22 04.20.19 PM
    Time period ends at 08-MAR-22 04.22.27 PM

    Analysis Target
    ---------------
    Database 'CDB1' with DB ID 2334624804.
    Database version 19.0.0.0.0.
    Analysis was requested for all instances, but ADDM analyzed instance
    CDB1,
    numbered 1 and hosted at workshop-installed.livelabs.oraclevcn.com.
    See the "Additional Information" section for more information on the
    requested
    instances.
    ADDM detected that the system is a PDB.

    Activity During the Analysis Period
    -----------------------------------
    Total database time was 14 seconds.
    The average number of active sessions was .11.
    ADDM analyzed 1 of the requested 1 instances.


    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    ~~~~~~~~~~
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    ~~~~~~~~~~

    There are no findings to report.

    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    ~~~~~~~~~~
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    ~~~~~~~~~~

            Additional Information
            ----------------------

    Miscellaneous Information
    -------------------------
    There was no significant database activity to run the ADDM.



    ```

3. You can confirm that ADDM detected a PDB.

    ```
    SQL> <copy>SELECT task_name, cdb_type_detected FROM dba_addm_tasks
     WHERE  how_created = 'CMD';</copy>

        TASK_NAME                          CDB_TYPE_DETECTED
    ---------------------------------- -------------------------
    PDB1_analysis_mode_task            PDB

    ```

## Task 4: Analyze CDB1 with ADDM

1. In **session 2** remove the runload file. you must first exit the running process by pressing **Ctrl+C**.

    ```
    $ <copy>rm $HOME/labs/19cnf/runload</copy>
    ```

2. Restart the runload in **session 2**.

    ```
    $ <copy>$HOME/labs/19cnf/start_workload.sh 1 PDB1</copy>
    ```

3. In **session 1**, connect to the CDB root.

    ```
    SQL> <copy>CONNECT / AS SYSDBA</copy>
    ```

4. Create a snapshot in **session 1**.

    ```
    SQL> <copy>EXEC dbms_workload_repository.create_snapshot()</copy>
    ```

5. Wait about ten minutes, then create another snapshot.

    ```
    SQL> <copy>EXEC dbms_workload_repository.create_snapshot()</copy>
    ```

    > **NOTE:** The ADDM report requires a significant amount of database activity to provide useful recommendations, if you would not like to wait for the proper amount of database activity, you may proceed with the lab without waiting. If you would like to see recommendations, please wait. Later, if you still do not see recommendations, we have provided the steps that allow you to reset the task. We've also included the recommendations in the output of step 9 if you choose to not wait. 

6. Retrieve snapshot values to analyze. Pick the minimum and maximum snapshots. Note that the lower snap_id will be the `min` and the top value will be the `max` in step 8.

    ```
    SQL> <copy>SELECT snap_id from awr_cdb_snapshot ORDER BY snap_id DESC;</copy>

        SNAP_ID
    ----------
        4
        3
        2
        1
    ```

7. In **session 1**, create a variable `tname` to store the task name.

    ```
    SQL> <copy>VAR tname VARCHAR2(60)</copy>
    ```

8. In **session 1**, execute the ADDM task manually. **Replace the min and max values with the minimum and maximum snapshot values.**

    ```
    SQL> <copy>BEGIN
     :tname := 'CDB analysis_mode_task';
     DBMS_ADDM.ANALYZE_DB( :tname, 1, 2);
     END;
    /</copy>

    > > > >
    PL/SQL procedure successfully completed.
    ```

9. View the PDB report in **session 1**. Note that your output may not be the exact same as the following. Also note that there is no recommendation at a specific PDB level, but the analysis report elements from PDB1 that impacted the whole database performance. 

    ```
    SQL> <copy>SELECT DBMS_ADDM.GET_REPORT(:tname) FROM DUAL;</copy>

        DBMS_ADDM.GET_REPORT(:TNAME)
    --------------------------------------------------------------------
            ADDM Report for Task 'CDB analysis_mode_task'
            ---------------------------------------------

    Analysis Period
    ---------------
    AWR snapshot range from 587 to 589.
    Time period starts at 08-MAR-22 03.50.12 PM
    Time period ends at 08-MAR-22 05.14.38 PM

    Analysis Target
    ---------------
    Database 'CDB1' with DB ID 1054637460.
    Database version 19.0.0.0.0.
    Analysis was requested for all instances, but ADDM analyzed instance
    CDB1,
    numbered 1 and hosted at workshop-installed.livelabs.oraclevcn.com.
    See the "Additional Information" section for more information on the
    requested
    instances.
    ADDM detected that the database type is MULTITENANT DB.

    Activity During the Analysis Period
    -----------------------------------
    Total database time was 306 seconds.
    The average number of active sessions was .06.
    ADDM analyzed 1 of the requested 1 instances.

    Summary of Findings
    -------------------
    Description                     Active Sessions      Recommendati
    ons
                                    Percent of Activity
    ------------------------------  -------------------  ------------
    ---
    1  Session Connect and Disconnect  .01 | 18.83          1
    2  Commits and Rollbacks           0 | 6.58             2
    3  Unusual "User I/O" Wait Event   0 | 5.42             1
    4  Unusual "User I/O" Wait Event   0 | 5.24             1
    5  Hard Parse                      0 | 4.28             0
    6  Unusual "User I/O" Wait Event   0 | 3.11             1


    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    ~~~~~~~~~~
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    ~~~~~~~~~~


            Findings and Recommendations
            ----------------------------

    Finding 1: Session Connect and Disconnect
    Impact is .01 active sessions, 18.83% of total activity.
    --------------------------------------------------------
    Session connect and disconnect calls were consuming significant data
    base time.

    Recommendation 1: Application Analysis
    Estimated benefit is .01 active sessions, 18.83% of total activit
    y.
    -----------------------------------------------------------------
    --
    Action
        Investigate application logic for possible reduction of connec
    t and
        disconnect calls. For example, you might use a connection pool
    scheme in
        the middle tier.


    Finding 2: Commits and Rollbacks
    Impact is 0 active sessions, 6.58% of total activity.
    -----------------------------------------------------
    Waits on event "log file sync" while performing COMMIT and ROLLBACK
    operations
    were consuming significant database time.

    Recommendation 1: Application Analysis
    Estimated benefit is 0 active sessions, 6.58% of total activity.
    ----------------------------------------------------------------
    Action
        Investigate application logic for possible reduction in the nu
    mber of
        COMMIT operations by increasing the size of transactions.
    Rationale
        The application was performing 3920 transactions per minute wi
    th an
        average redo size of 684 bytes per transaction.

    Recommendation 2: Host Configuration
    Estimated benefit is 0 active sessions, 6.58% of total activity.
    ----------------------------------------------------------------
    Action
        Investigate the possibility of improving the performance of I/
    O to the
        online redo log files.
    Rationale

    DBMS_ADDM.GET_REPORT(:TNAME)
    --------------------------------------------------------------------
        The average size of writes to the online redo log files was 2
    K and the
        average time per write was 1 milliseconds.
    Rationale
        The total I/O throughput on redo log files was 0 K per second
    for reads
        and 48 K per second for writes.
    Rationale
        The redo log I/O throughput was divided as follows: 0% by RMAN
    and
        recovery, 100% by Log Writer, 0% by Archiver, 0% by Streams AQ
    and 0% by
        all other activity.

    Symptoms That Led to the Finding:
    ---------------------------------
        Wait class "Commit" was consuming significant database time.
        Impact is 0 active sessions, 6.58% of total activity.


    Finding 3: Unusual "User I/O" Wait Event
    Impact is 0 active sessions, 5.42% of total activity.
    -----------------------------------------------------
    Wait event "Disk file operations I/O" in wait class "User I/O" was c
    onsuming
    significant database time.

    Recommendation 1: Application Analysis
    Estimated benefit is 0 active sessions, 5.42% of total activity.
    ----------------------------------------------------------------
    Action
        Investigate the cause for high "Disk file operations I/O" wait
    s. Refer
        to Oracle's "Database Reference" for the description of this w
    ait event.

    Symptoms That Led to the Finding:
    ---------------------------------
        Wait class "User I/O" was consuming significant database time.

        Impact is .01 active sessions, 15.06% of total activity.


    Finding 4: Unusual "User I/O" Wait Event
    Impact is 0 active sessions, 5.24% of total activity.
    -----------------------------------------------------
    Wait event "Pluggable Database file copy" in wait class "User I/O" w
    as
    consuming significant database time.

    Recommendation 1: Application Analysis
    Estimated benefit is 0 active sessions, 5.24% of total activity.
    ----------------------------------------------------------------
    Action
        Investigate the cause for high "Pluggable Database file copy"
    waits.
        Refer to Oracle's "Database Reference" for the description of
    this wait
        event.

    Symptoms That Led to the Finding:
    ---------------------------------
        Wait class "User I/O" was consuming significant database time.

        Impact is .01 active sessions, 15.06% of total activity.


    Finding 5: Hard Parse
    Impact is 0 active sessions, 4.28% of total activity.
    -----------------------------------------------------
    Hard parsing of SQL statements was consuming significant database ti
    me.
    Hard parses due to cursor environment mismatch were not consuming si
    gnificant
    database time.
    Hard parsing SQL statements that encountered parse errors was not co
    nsuming
    significant database time.
    Hard parses due to literal usage and cursor invalidation were not co
    nsuming
    significant database time.

    No recommendations are available.


    Finding 6: Unusual "User I/O" Wait Event
    Impact is 0 active sessions, 3.11% of total activity.
    -----------------------------------------------------
    Wait event "external table read" in wait class "User I/O" was consum
    ing
    significant database time.

    Recommendation 1: Application Analysis
    Estimated benefit is 0 active sessions, 3.11% of total activity.
    ----------------------------------------------------------------
    Action
        Investigate the cause for high "external table read" waits. Re

    DBMS_ADDM.GET_REPORT(:TNAME)
    --------------------------------------------------------------------
    fer to
        Oracle's "Database Reference" for the description of this wait
    event.

    Symptoms That Led to the Finding:
    ---------------------------------
        Wait class "User I/O" was consuming significant database time.

        Impact is .01 active sessions, 15.06% of total activity.



    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    ~~~~~~~~~~
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    ~~~~~~~~~~

            Additional Information
            ----------------------

    Miscellaneous Information
    -------------------------
    Wait class "Application" was not consuming significant database time
    .
    Wait class "Concurrency" was not consuming significant database time
    .
    Wait class "Configuration" was not consuming significant database ti
    me.
    CPU was not a bottleneck for the instance.
    Wait class "Network" was not consuming significant database time.
    ```

10. **OPTIONAL**: If your output excludes recommendations, please delete the workload with the following command.

    ```
    SQL> <copy>EXEC DBMS_ADDM.delete('CDB analysis_mode_task');</copy>
    ```

11. **OPTIONAL**: Then, wait about ten minutes and take another snapshot.

    ```
    SQL> <copy>EXEC dbms_workload_repository.create_snapshot()</copy>
    ```

12. **OPTIONAL**: You can find the newest snapshot by executing the following query.

    ```
    SQL> <copy>SELECT snap_id from awr_cdb_snapshot ORDER BY snap_id DESC;</copy>

        SNAP_ID
    ----------
        5
        4
        3
        2
        1
    ```

13. **OPTIONAL**: In **session 1**, execute the ADDM task manually. **Replace the min and max values with the minimum and maximum snapshot values.**

    ```
    SQL> <copy>BEGIN
     :tname := 'CDB analysis_mode_task';
     DBMS_ADDM.ANALYZE_DB( :tname, min, max);
     END;
    /</copy>

    > > > >
    PL/SQL procedure successfully completed.
    ```

14. **OPTIONAL**: View the PDB report in **session 1**.

    ```
    SQL> <copy>SELECT DBMS_ADDM.GET_REPORT(:tname) FROM DUAL;</copy>
    ```

15. In **session 1**, Confirm that ADDM is analyzing a CDB.

    ```
    SQL> <copy>SELECT task_name, cdb_type_detected FROM dba_addm_tasks
     WHERE  how_created = 'CMD';</copy>

        
    TASK_NAME               CDB_TYPE_DETECTED
    ------------            ------------------------
    CDB analysis_mode_task  MULTITENANT DB
    ```

## Task 5: Clean your environment

1. In **session 2**, remove the runload

    ```
    $ <copy>rm $HOME/labs/19cnf/runload</copy>
    ```

2. You may exit **session 2**.

3. In **session 1**, exit SQL*Plus.

    ```
    SQL> <copy>EXIT;</copy>
    ```

    You may now **proceed to the next lab**.

## Learn More

* [Database 19c New Features](https://docs.oracle.com/en/database/oracle/oracle-database/19/newft/new-features.html#GUID-25B329C9-070C-4AE5-BC65-2CCF40F3C399)
* [Using ADDM in a multitenant environment](https://docs.oracle.com/en/database/oracle/oracle-database/19/tgdba/automatic-performance-diagnostics.html)

## Acknowledgements

- **Author** - Dominique Jeunot, Consulting User Assistance Developer
- **Contributors** - Matthew McDaniel, Austin Specialist Hub
- **Last Updated By/Date** - Matthew McDaniel, Austin Specialist Hub, March 3 2022