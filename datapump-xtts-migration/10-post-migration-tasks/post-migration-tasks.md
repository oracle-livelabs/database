# Post-migration Tasks

## Introduction

Now, you have migrated the database. Before going live, there are a few important tasks to carry out, plus you should test the new database. 

Estimated Time: 10 Minutes

[Next-Level Platform Migration with Cross-Platform Transportable Tablespaces - lab 10](youtube:fgyDy-QcV_o?start=2722)

### Objectives

In this lab, you will:

* Perform the final tasks
* Check the outcome of the migration 

## Task 1: Final migration tasks

1. Use the *blue* terminal 🟦. Set the environment to *CDB23* and connect.

    ```
    <copy>
    . cdb23
    sqlplus / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

2. Switch to *VIOLET* and gather dictionary statistics. Oracle recommends gathering dictionary statistics immediately after an import.

    ```
    <copy>
    alter session set container=violet;
    exec dbms_stats.gather_schema_stats(ownname=>'SYS', degree=>DBMS_STATS.AUTO_DEGREE);
    exec dbms_stats.gather_schema_stats(ownname=>'SYSTEM', degree=>DBMS_STATS.AUTO_DEGREE);
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> alter session set container=violet;

    Session altered.

    SQL> exec dbms_stats.gather_schema_stats(ownname=>'SYS', degree=>DBMS_STATS.AUTO_DEGREE);

    PL/SQL procedure successfully completed.

    SQL> exec dbms_stats.gather_schema_stats(ownname=>'SYSTEM', degree=>DBMS_STATS.AUTO_DEGREE);

    PL/SQL procedure successfully completed.
    ```
    </details>

3. Gather statistics on the optimizer statistics staging table. You created this staging table in a previous lab. The migration brought it into the target database; however, before starting an import of the statistics, you should gather statistics on the staging table. 

    ```
    <copy>
    begin
       dbms_stats.gather_table_stats(
          ownname => 'OPT_STAT_TRANSPORT', 
          tabname => 'OPT_STATS_STG', 
          degree  => DBMS_STATS.AUTO_DEGREE);
    end;
    /
    </copy>
    ```

    * In the Data Pump export, you don't export any statistics. This is what you use the statistics staging table for. 
    * To ensure the import of statistics happens as fast as possible, you need to gather statistics on the staging table.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> begin
        dbms_stats.gather_table_stats(
            ownname => 'SYS',
            tabname => 'TAB$',
            degree  => DBMS_STATS.AUTO_DEGREE);
    end;
    /
      2    3    4    5    6    7
    
    PL/SQL procedure successfully completed.
    ```
    </details>

4. Verify there are no statistics on the tables in the *F1* schema.

    ```
    <copy>
    set pagesize 100
    col table_name format a25
    select table_name, num_rows, last_analyzed 
    from   dba_tab_statistics 
    where  owner='F1';
    </copy>
    ```

    * The number of rows (*NUM\_ROWS*) is missing, and so is information on when statistics were gathered (*LAST\_ANALYZED*).
    * This proves that there are *no statistics* on the tables.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> set pagesize 100
    SQL> col table_name format a25
    SQL> select table_name, num_rows, last_analyzed 
         from   dba_tab_statistics 
         where  owner='F1';

    TABLE_NAME                NUM_ROWS   LAST_ANALYZED
    ------------------------- ---------- ------------------
    F1_RACES
    F1_CONSTRUCTORRESULTS
    F1_CIRCUITS
    F1_DRIVERS
    F1_STATUS
    F1_PITSTOPS
    F1_CONSTRUCTORS
    F1_DRIVERSTANDINGS
    F1_CONSTRUCTORSTANDINGS
    F1_SPRINTRESULTS
    F1_LAPTIMES
    F1_RESULTS
    F1_LAPTIMES_BACKUP
    F1_QUALIFYING
    F1_SEASONS
    
    15 rows selected.         
    ```
    </details>

5. Import the statistics from the staging table into the data dictionary. 

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

    * The statistics staging table is already present in the target database.
    * You created the staging table in the *USERS* tablespace that was migrated to the target database.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> begin
        dbms_stats.import_schema_stats (
            ownname => 'F1',
            statown => 'OPT_STAT_TRANSPORT',
            stattab => 'OPT_STATS_STG');
    end;
    /  
    
    PL/SQL procedure successfully completed.    
    ```
    </details>    

6. Ensure there are statistics on the tables in the *F1* schema.

    ```
    <copy>
    set pagesize 100
    col table_name format a25
    select table_name, num_rows, last_analyzed 
    from   dba_tab_statistics 
    where  owner='F1';
    </copy>
    ```

    * Now, you see *NUM\_ROWS* and *LAST\_ANALYZED* for each table.
    * This proves that there are *statistics* on the tables.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> set pagesize 100
    SQL> col table_name format a25
    SQL> select table_name, num_rows, last_analyzed 
         from   dba_tab_statistics 
         where  owner='F1';

    TABLE_NAME                NUM_ROWS   LAST_ANALYZED
    ------------------------- ---------- ------------------
    F1_RACES                  1125       02-JUL-24
    F1_CONSTRUCTORRESULTS     12465      02-JUL-24
    F1_CIRCUITS               77         02-JUL-24
    F1_DRIVERS                859        02-JUL-24
    F1_STATUS                 139        02-JUL-24
    F1_PITSTOPS               10793      02-JUL-24
    F1_CONSTRUCTORS           212        02-JUL-24
    F1_DRIVERSTANDINGS        34511      02-JUL-24
    F1_CONSTRUCTORSTANDINGS   13231      02-JUL-24
    F1_SPRINTRESULTS          280        02-JUL-24
    F1_LAPTIMES               571047     02-JUL-24
    F1_RESULTS                26439      02-JUL-24
    F1_LAPTIMES_BACKUP        571047     02-JUL-24
    F1_QUALIFYING             10174      02-JUL-24
    F1_SEASONS                75         02-JUL-24
    
    15 rows selected.         
    ```
    </details>

7. Drop the schema used for the transport of statistics. After importing the statistics, there is no use for the schema and the statistics in the transportable format. 

    ```
    <copy>
    drop user opt_stat_transport cascade;
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> drop user opt_stat_transport cascade;
    
    User dropped.
    ```
    </details>

## Task 2: Check migration

In this step, you would normally perform extensive testing of the new database before deciding whether to go live. In this lab, you do just a very simple test.

1. Still in the *blue* terminal 🟦. Ensure all data has been brought over to the target database. You check whether the tables `F1.F1_LAPTIMES_BACKUP` and `F1.F1_LAPTIMES_BACKUP2` exist. These are the tables you created earlier in the labs.

    ```
    <copy>
    select count(*) from f1.f1_laptimes_backup;
    select count(*) from f1.f1_laptimes_backup2;
    </copy>
    ```

    * If you didn't complete lab 7 (Test migration), you won't find `F1.F1_LAPTIMES_BACKUP2`, and the last query will fail with `ORA-00942`.
    * In a real migration, you would perform much more extensive testing. 

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> select count(*) from f1.f1_laptimes_backup;
    
      COUNT(*)
    ----------
        571047
            
    SQL> select count(*) from f1.f1_laptimes_backup2;
    
      COUNT(*)
    ----------
        571047
    ```
    </details>

2. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```    

## Task 3: Additional post-migration tasks

Once the tests complete, you shut down the source database. This ensures no one by mistake connects to the wrong database.

1. Use the *yellow* terminal 🟨. Set the environment to the source database and connect.

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

5. There are other important post-migration tasks that you won't do in this lab. For instance:
    * Start a new level 0 backup.
    * Delete the backups created by RMAN during the migration. 
    * Drop the guaranteed restore points created in the target database by the migration driver script. 
    * Gather fixed objects statistics once the target database has been *warmed up*. 

**Congratulations! You have now migrated your Oracle Database to a new platform!**

## Acknowledgments

* **Author** - Daniel Overby Hansen
* **Contributors** - Rodrigo Jorge, Mike Dietrich, Klaus Gronau, Alex Zaballa
* **Last Updated By/Date** - Daniel Overby Hansen, August 2024
