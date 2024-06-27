# Post-migration Tasks

## Introduction

Now, you have migrated the database. Before going live there are a few important tasks to carry out, plus you want to perform testing on the new database. 

Estimated Time: 10 Minutes.

### Objectives

In this lab, you will:

* Perform the final tasks
* Check the outcome of the migration 

## Task 1: Final migration tasks

1. Set the environment to *CDB23* and connect.

    ```
    <copy>
    . ftex
    sqlplus / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

2. Switch to *VIOLET* and gather dictionary statistics. Oracle recommends gathering dictionary statistics immediately after an import.

    ```
    <copy>
    alter session set container=violet;
    exec dbms_stats.gather_schema_stats('SYS');
    exec dbms_stats.gather_schema_stats('SYSTEM');
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> alter session set container=violet;

    Session altered.

    SQL> exec dbms_stats.gather_schema_stats('SYS');

    PL/SQL procedure successfully completed.

    SQL> exec dbms_stats.gather_schema_stats('SYSTEM');

    PL/SQL procedure successfully completed.
    ```
    </details>

3. Gather statistics on the optimizer statistics staging table. You created this staging table in a previous lab. The migration brought it into the target database, however, before starting an import of the statistics you should gather statistics on the staging table. 

    ```
    <copy>
    exec dbms_stats.gather_table_stats('OPT_STAT_TRANSPORT', 'OPT_STATS_STG');
    </copy>
    ```

    * In the Data Pump export, you don't export any statistics. This is what you use the statistics staging table for. 
    * To ensure the import of statistics happens as fast as possible, you need to gather statistics on the staging table.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> exec dbms_stats.gather_table_stats('OPT_STAT_TRANSPORT', 'OPT_STATS_STG');

    PL/SQL procedure successfully completed.
    ```
    </details>

4. Import the statistics from the staging table into the data dictionary. 

    ```
    <copy>
    begin
        dbms_stats.import_schema_stats ( 
            ownname => 'F1',
            statown => 'OPT_STAT_TRANSPORT',
            stattab => 'OPT_STATS_STG');
    end;
    /
    </copy>
    ```
       
5. Drop the schema used for the transport of statistics. After importing the statistics, there is no use for the schema and the statistics in the transportable format. 

    ```
    <copy>
    drop user opt_stat_transport cascade;
    </copy>
    ```

## Task 2: Check migration

In this step, you would normally perform extensive testing of the new database, before deciding whether to go-live. In this lab, you do just a very simple test.

1. Ensure all data has been brought over to the target database. You check whether the table `F1.F1_LAPTIMES_BACKUP` exists. This is the table you created earlier in the lab between two incremental backups.

    ```
    <copy>
    select count(*) from f1.f1_laptimes_backup;
    </copy>
    ```

    * In a real migration, you would perform much more extensive testing. 

## Task 3: Additional post migration tasks

Once the tests complete, you shut down the source database. This ensures noone by mistake connects to the wrong database.

1. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```

2. Set the environment to the source database and connect.

    ```
    <copy>
    . ftex
    sqlplus / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

3. Shut down the source database.

    ```
    <copy>
    shutdown immediate
    </copy>
    ```

4.  Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```

5. There are other important post migration tasks, that you won't perform in this lab. For instance:
    * Start a new level 0 backup.
    * Delete the backups created by RMAN during the migration. You can do that once the new level 0 completes. 
    * Drop the guaranteed restore points created in the target database by the migration driver script. 
    * Gather fixed objects statistics once the target database has been *warmed up*. 

**Congratulations! You have now migrated your Oracle Database to a new platform!**

## Acknowledgements

* **Author** - Daniel Overby Hansen
* **Contributors** - Klaus Gronau, Rodrigo Jorge, Mike Dietrich
* **Last Updated By/Date** - Daniel Overby Hansen, July 2024
