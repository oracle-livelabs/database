# Recover a dropped table using flashback drop

## Introduction
This lab shows you how to perform Flashback Drop on a dropped table in Oracle Database.

Estimated Time: 10 minutes

### About flashback drop
Oracle Database's Flashback Drop enables you to reverse the effects of dropping (deleting) a table, returning the dropped table to the Oracle Database along with dependent objects such as indexes and triggers. This feature stores dropped objects in a recycle bin, from which you can retrieve them until the recycle bin is purged, either explicitly or because space is needed.

As with Flashback Table, you can use Flashback Drop while the Oracle Database is open. Also, you can perform the flashback without undoing changes in objects not affected by the Flashback Drop operation. Flashback Table is more convenient than forms of media recovery that require taking the Oracle Database offline and restoring files from backup.

>**Note:** A table must reside in a locally managed tablespace so that you can recover the table using Flashback Drop. Also, you cannot recover tables in the `SYSTEM` tablespaces with Flashback Drop, regardless of the tablespace type.

### Objectives
- Drop a table
- Recover the dropped table

### Prerequisites
- A Free Tier, Paid or LiveLabs Oracle Cloud account.
- You have completed:
    - Lab: Prepare setup (_Free-Tier_ and _Paid Tenants_ only)
    - Lab: Initialize environment
    - Lab: Configure recovery settings
    - Lab: Configure backup settings
    - Lab: Perform and schedule backups


## Task 1: Drop a table
The Oracle Database moves the dropped table to the recycle bin. Such tables can be retrieved using the Flashback Drop feature.

In this task, you will drop the `appuser.regions` table using the following steps.

1. Start the SQL\*Plus prompt and connect as `sysdba` user;
    ```
    $ <copy>./sqlplus / as sysdba</copy>
    ```
    Output:
    ```
    SQL*Plus: Release 21.0.0.0.0 - Production on Thu Dec 16 08:10:35 2021
    Version 21.3.0.0.0

    Copyright (c) 1982, 2021, Oracle.  All rights reserved.

    Connected to:
    Oracle Database 21c Enterprise Edition Release 21.0.0.0.0 - Production
    Version 21.3.0.0.0
    ```

2. Use the following command to switch to the pluggable database container. In this lab, `pdb1` is the pluggable database.
    ```
    SQL> <copy>alter session set container=pdb1;</copy>
    ```
    Output:
    ```
    Session altered.
    ```

3. Use the following command to delete the `appuser.regions` table.
    ```
    SQL> <copy>drop table appuser.regions;</copy>
    ```
    Output:
    ```
    Table dropped.
    ```

4. Query the `appuser.regions` table. You can see that you got an error because the table was deleted.
    ```
    SQL> <copy>select * from appuser.regions;</copy>
    ```
    Output:
    ```
    select * from appuser.regions
                          *
    ERROR at line 1:
    ORA-00942: table or view does not exist
    ```


## Task 2: Recover the dropped table
In this task, you recover the `appuser.regions` table from the recycle bin using the following steps.
1. Use the following command to recover the deleted table.
    ```
    SQL> <copy>flashback table appuser.regions to before drop;</copy>
    ```
    Output:
    ```
    Flashback complete.
    ```

2. Query the `appuser.regions` table to verify that the data has been restored.
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

**Congratulations!** You have successfully completed this workshop on **Backup and Recovery Operations for Oracle Database 21c**.


## Acknowledgements
- **Author**: Suresh Mohan, Database User Assistance Development Team
- **Contributors**: Suresh Rajan, Manish Garodia, Subhash Chandra, Ramya P
- **Last Updated By & Date**: Suresh Mohan, May 2022
