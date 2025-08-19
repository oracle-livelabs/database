# Recover a dropped table using flashback drop

## Introduction
This lab shows you how to perform Flashback Drop on a dropped table in an Oracle Database.

Estimated Time: 10 minutes

### About flashback drop
Oracle Database's Flashback Drop enables you to reverse the effects of dropping (deleting) a table, restoring the dropped table to the Oracle Database along with dependent objects such as indexes and triggers. This feature stores dropped objects in a recycle bin, from which you can retrieve them until the recycle bin is purged, either explicitly or because space is needed.

As with Flashback Table, you can use Flashback Drop while the Oracle Database is open. Also, you can perform the flashback without undoing changes to objects not affected by the Flashback Drop operation. Flashback Table is more convenient than forms of media recovery that require taking the Oracle Database offline and restoring files from backup.

>**Note:** A table must reside in a locally managed tablespace so that you can recover the table using Flashback Drop. Also, you cannot recover tables in the SYSTEM tablespaces with Flashback Drop, regardless of the tablespace type.

### Objectives
-   Drop a table
-   Recover the dropped table

### Prerequisites
This lab assumes you have:
-   An Oracle Cloud account
-   Completed all previous labs successfully


## Task 1: Drop a table
The Oracle Database moves the dropped table to the recycle bin. Such tables can be retrieved using the Flashback Drop feature.

1. Start the SQL\*Plus prompt and connect as `sysdba` user;
    ```
    $ <copy>./sqlplus / as sysdba</copy>
    ```

2. Switch to the PDB container. For this lab, `pdb1` is used.

    ```
    SQL> <copy>alter session set container=pdb1;</copy>
    ```
    Output:
    ```
    Session altered.
    ```

3. Delete the table.

    ```
    SQL> <copy>drop table appuser.regions;</copy>
    ```
    Output:
    ```
    Table dropped.
    ```

4. Query the table. You can see that you got an error because the table was deleted.

    ```
    SQL> <copy>select * from appuser.regions;</copy>
    ```
    Output:
    ```
    select * from appuser.regions                           
    ERROR at line 1:
    ORA-00942: table or view "APPUSER"."REGIONS" does not exist
    Help: https://docs.oracle.com/error-help/db/ora-00942/
    ```


## Task 2: Recover the dropped table

1. Recover the deleted table.
    ```
    SQL> <copy>flashback table appuser.regions to before drop;</copy>
    ```
    Output:
    ```
    Flashback complete.
    ```

2. Query the table to verify that the data has been restored.
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
    Output:
    ```
    Disconnected from Oracle Database 23ai Enterprise Edition Release 23.0.0.0.0 - Production
    Version 23.4.0.24.05
    ```

**Congratulations!** You have successfully completed this workshop on **Backup and Recovery Operations for Oracle Database 23ai**.


## Acknowledgements
- **Author**: Suresh Mohan, Database User Assistance Development Team
- **Contributors**: Suresh Rajan, Manish Garodia, Subhash Chandra, Ramya P
- **Last Updated By & Date**: Suresh Mohan, October 2024

