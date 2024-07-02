# Test Migration

## Introduction

In this lab, you will test the migration. A major advantage of the M5 script is that you can do a test migration. Using the restored data files on the target system, you can perform a test migration. After that, you can flash the data files back and resume the backup/restore cycle. 

In other words, you are using the production system and the production data for a test. This is very useful. 

A few words about the test migration. 
* It requires a short outage on the source database.
* You will perform a final backup and restore. *Final* just means that you take the backup with the tablespaces in read-only mode and at the same time perform a Data Pump full transportable export.
* During testing, the tablespaces in the target database remain in *read-only* mode. Thsi prevents any changes to the underlying data files. Thus, you can still use them for the real migration - even after testing.
* After the test, you perform additional backup/restore cycles. You re-use the restored data files on the target database.

This is an optional lab. You can skip it and move directly to lab 8. 

Estimated Time: 15 Minutes.

### Objectives

In this optional lab, you will:

* Test the last part of the migration
* Flash back database
* Resume the backup/restore cycle

## Task 1: Perform test migration

You will test the migration by performing the final steps of the migration. However, at the end you flash back the target database and resume the backup/restore cycle.

1. Outage starts on the source database.

2. Set the environment to the source database and start a level 1 final backup. When you start the driver script with `L1F`, it performs not only the final backup, but it also sets the tablespaces in *read-only* mode and starts a Data Pump full transportable export. 

    ```
    <copy>
    . ftex
    cd /home/oracle/m5
    ./dbmig_driver_m5.sh L1F
    </copy>

    -- Be sure to hit RETURN
    ```

    * You start the driver script with the argument *L1F*.
    * When prompted for *system password*, enter *ftexuser*. The password of the user you created earlier in the lab. 
    * Before starting the backup, the script sets the tablespaces read-only. 
    * After the backup, the script starts Data Pump to perform a full transportable export. 

3. Connect to the source database.

    ```
    <copy>
    sqlplus / as sysdba
    </copy>
    ```

4. Stop the outage by setting the tablespaces back to read-write mode.

    ```
    <copy>
    alter tablespace users read write;
    </copy>
    ```

    * As soon as the tablespaces are back in read-write mode, you can allow the users to connect to the source database again. You complete the remaining part of the test migration on the target database without affecting the source database.

5. Exit SQL*Plus. 
    
    ```
    <copy>
    exit
    </copy>
    ```

6. Restore the test backup.

    ```
    <copy>
    cd cmd
    export L1FSCRIPT=$(ls -tr restore_L1F* | tail -1) 
    . cdb23
    cd /home/oracle/m5
    rman target "sys/oracle@'localhost/violet'" cmdfile=/home/oracle/m5/cmd/$L1FSCRIPT    
    </copy>

    -- Be sure to hit RETURN
    ```

7. Perform the Data Pump transportable import. In the next lab, the instructions will describe in detail what happens. However, for now just start the import directly.

    ```
    <copy>
    cd /home/oracle/m5/log
    export L1FLOGFILE=$(ls -tr restore_L1F*log | tail -1)
    cd /home/oracle/m5/m5dir
    export DMPFILE=$(ls -tr exp_FTEX*dmp | tail -1)
    cd ..
    . cdb23
    ./impdp.sh $DMPFILE log/$L1FLOGFILE run-readonly N
    </copy>

    -- Be sure to hit RETURN
    ```

    * The import runs for a few minutes. 
    * For now, you disregard any errors or warnings in the Data Pump output or log file.

## Task 2: Check database

1. Connect to the target database, *CDB23*. 

    ```
    <copy>
    . cdb23
    sqlplus / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

2. Switch to *VIOLET* and check for tables in the *F1* schema.

    ```
    <copy>
    alter session set container=VIOLET;
    select table_name 
    from   all_tables 
    where  owner='F1' and table_name like 'F1_LAPTIMES%';
    select count(*)
    from   f1.f1_laptimes;
    </copy>

    -- Be sure to hit RETURN
    ```

    * You find both *F1\_LAPTIMES* and *F1\_LAPTIMES\_BACKUP*. The latter is the table you created in lab 6. 
    * You can even query the tables. 

3. If you try to make a change, you receive an error. The tablespaces are read-only, so no changes are allowed.

    ```
    <copy>
    create table f1.f1_laptimes_will_fail as select * from f1.f1_laptimes;
    </copy>
    ```

## Task 3: Flash back

Now that you are done testing, you use `FLASHBACK DATABASE` to undo the test import.

1. Switch to the root container and restart the database in mount mode.

    ```
    <copy>
    alter session set container=CDB$ROOT;
    shutdown immediate
    startup mount 
    </copy>

    -- Be sure to hit RETURN
    ```

2. Flash back to the restore point created by the import driver script.

    ```
    <copy>
    declare
       l_name v$restore_point.name%TYPE;
    begin
       select name into l_name from v$restore_point order by time desc fetch first 1 rows only;
       execute immediate 'flashback database to restore point ' || l_name;
    end;
    /
    </copy>

    -- Be sure to hit RETURN
    ```

    * The name of the restore point changes every time you use the import driver script.
    * The code finds the recent-most restore point and flashes back to it.

3. Open the database.

    ```
    <copy>
    alter database open resetlogs;
    </copy>
    ```

    * `FLASHBACK DATABASE` requires that you open the database with resetlogs.

4. Switch back to *VIOLET* and verify that the tables in the *F1* schema is now gone.

    ```
    <copy>
    alter session set container=VIOLET;
    select table_name 
    from   all_tables 
    where  owner='F1' and table_name like 'F1_LAPTIMES%';
    </copy>

    -- Be sure to hit RETURN
    ```

    * The query returns no rows because you reverted the entire import with the `FLASHBACK DATABASE` command.

## Task 4: Proceed with backup/restore

When the test completes and you flashed back the changes, you can resume the backup/restore cycle.

1. Set the environment to the source database and connect.

    ```
    <copy>
    . ftex
    sqlplus / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

2. Create a copy of one of the tables.

    ```
    <copy>
    create table f1.f1_laptimes_backup2 as select * from f1.f1_laptimes;
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> create table f1.f1_laptimes_backup2 as select * from f1.f1_laptimes;
    
    Table created.
    ```
    </details>

3. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```

4. Perform an incremental backup.

    ```
    <copy>
    . ftex
    cd /home/oracle/m5
    ./dbmig_driver_m5.sh L1
    </copy>

    -- Be sure to hit RETURN
    ```

    * Although the last backup was a *final* backup, the script just continues.
    * The backup/restore cycle is not interupted. 

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    ```
    </details>

5. Restore the backup.

    ```
    <copy>
    cd cmd
    export L1SCRIPT=$(ls -tr restore_L1_* | tail -1) 
    cd /home/oracle/m5
    . cdb23
    rman target "sys/oracle@'localhost/violet'" cmdfile=/home/oracle/m5/cmd/$L1SCRIPT
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    ```
    </details>

6. Search the log file for any warnings or errors. 

    ```
    <copy>
    cd log
    egrep "WARN-|ORA-" $(ls -tr restore*log | tail -1)
    </copy>

    -- Be sure to hit RETURN
    ```

    * The command produces no output because the search string was not found. This means there were no warnings or errors in the log file.


You may now *proceed to the next lab*.

## Further information

During the test, you introduced a short outage on the source database. You changed the tablespaces to read-only mode on the source database while you performed the final backup, including the Data Pump transportable export. If such an outage is unacceptable, you can perform the test backup on a standby database. Thus, you avoid outage on the primary database.

## Acknowledgements

* **Author** - Daniel Overby Hansen
* **Contributors** - Klaus Gronau, Rodrigo Jorge, Mike Dietrich
* **Last Updated By/Date** - Daniel Overby Hansen, July 2024
