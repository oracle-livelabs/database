# Rewind a table using Flashback Table

## Introduction
This lab shows you how to perform Flashback Table on a table in an Oracle Database.

Estimated Time: 10 minutes

### About Flashback Table
Oracle Database's Flashback Table enables you to rewind one or more tables to their contents at a previous time without affecting other Oracle Database objects. Thus, you can recover from logical data corruptions such as table rows added or deleted accidentally. Unlike point-in-time recovery, the Oracle Database remains available during the flashback operation.

### Objectives
-   Enable row movement on a table
-   Simulate user error
-   Perform Flashback Table operation

### Prerequisites
This lab assumes you have:
-   An Oracle Cloud account
-   Completed all previous labs successfully


## Task 1: Enable row movement on a table
Before using Flashback Table, you must ensure that row movement is enabled on the table to be flashed back or returned to a previous state. Row movement indicates that row IDs will change after the flashback occurs. This restriction exists because if an application stores row IDs before the flashback, there is no guarantee that the row IDs will correspond to the same rows after the flashback.

1. Start the SQL\*Plus prompt and connect as `sysdba` user;
    ```
    $ <copy>./sqlplus / as sysdba</copy>
    ```

2. Switch to the PDB container. For this lab, `pdb1` is used.
    ```
    SQL> <copy>alter session set container = pdb1;</copy>
    ```
    Output:
    ```
    Session altered.
    ```

3. Enable row movement on the table. For this lab, `appuser.regions` table is used.

    ```
    SQL> <copy>alter table appuser.regions enable row movement;</copy>
    ```
    Output:
    ```
    Table altered.
    ```


## Task 2: Simulate user error

1. Query the table.
    ```
    SQL> <copy>select * from appuser.regions;</copy>
    ```
    Output:
    ```
            ID NAME
    ---------- --------------------
             1 America
             2 Europe
             3 Asia
    ```

2. Get the current timestamp. You can use this timestamp value to flashback the Oracle Database to this time.
    ```
    SQL> <copy>select to_char(current_timestamp,'YYYY-MM-DD HH:MI:SS') from dual;</copy>
    ```
    Output:
    ```
    TO_CHAR(CURRENT_TIM
    ------------------- 
    2024-10-03 02:21:40
    ```

3. Simulate an user error. The following command will change the value in the `name` column to 'ORACLE' in all the rows of the table.
    ```
    SQL> <copy>update appuser.regions set name = 'ORACLE';</copy>
    ```
    Output:
    ```
    3 rows updated.
    ```

4. Commit.
    ```
    SQL> <copy>commit;</copy>
    ```
    Output:
    ```
    Commit complete.
    ```

5. Query the table again to verify that the `name` column for all the rows is updated to 'ORACLE'.

    ```
    SQL> <copy>select * from appuser.regions;</copy>
    ```
    Output:
    ```
            ID NAME
    ---------- --------------------
             1 ORACLE
             2 ORACLE
             3 ORACLE
    ```


## Task 3: Perform Flashback Table operation
In this task, you rewind the table to a point before you performed the update to simulate a user error.

1. Flashback the table to a time before you performed the update to the table.
    ```
    SQL> <copy>flashback table appuser.regions to timestamp to_timestamp('2024-10-03 02:21:40','YYYY-MM-DD HH:MI:SS');</copy>
    ```
    Output:
    ```
    Flashback complete.
    ```

2. Query the table to verify that the values in the name column have been restored.
    ```
    SQL> <copy>select * from appuser.regions;</copy>
    ```
    Output:
    ```
            ID NAME
    ---------- --------------------
             1 America
             2 Europe
             3 Asia
    ```

3. Exit the SQL\*Plus prompt.

    ```
    SQL> <copy>exit;</copy>
    ```

You may now **proceed to the next lab**.


## Acknowledgements
- **Author**: Suresh Mohan, Database User Assistance Development Team
- **Contributors**: Suresh Rajan, Manish Garodia, Subhash Chandra, Ramya P
- **Last Updated By & Date**: Suresh Mohan, October 2024
