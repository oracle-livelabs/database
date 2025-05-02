# Checksum and Encryption

## Introduction

When you move complex data around or when you're doing full export/imports, it's common to find errors in the Data Pump log file. In this lab, you will learn about knowing ignorable errors and being able to determine whether an import was successful. 

Estimated Time: 20 Minutes

### Objectives

In this lab, you will:

* Examine log file
* Compare schemas

### Prerequisites

This lab assumes:

- You have completed Lab 7: Getting Started

## Task 1: Errors

During export and import, Data Pump may faces errors or situations that can't be resolved.

1. Use the the *yellow* terminal 🟨. If Data Pump encounters an error or face a situation it can't resolve, it will print an error to the console and into the logfile. At the end of the output, Data Pump summarizes and list the number of errors faced during the job. Examine the following Data Pump import log file.

    ```
    <copy>
    cat /home/oracle/scripts/dp-08-errors-import.log
    </copy>

    -- Be sure to hit RETURN
    ```

    * The last line says *completed with 1 error*.
    * Scroll up and you can find the details about the error.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    ;;;
    Import: Release 19.0.0.0.0 - Production on Thu May 1 08:04:59 2025
    Version 19.27.0.0.0
    
    Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.
    ;;;
    Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    01-MAY-25 08:05:01.272: ;;; **************************************************************************
    01-MAY-25 08:05:01.274: ;;; Parfile values:
    01-MAY-25 08:05:01.275: ;;;  parfile:  remap_schema=F1:F1FROM23AI
    01-MAY-25 08:05:01.277: ;;;  parfile:  logtime=all
    01-MAY-25 08:05:01.279: ;;;  parfile:  metrics=Y
    01-MAY-25 08:05:01.281: ;;;  parfile:  dumpfile=dp-10-downgrade-%L.dmp
    01-MAY-25 08:05:01.283: ;;;  parfile:  logfile=dp-10-downgrade-import.log
    01-MAY-25 08:05:01.285: ;;;  parfile:  directory=dpdir
    01-MAY-25 08:05:01.286: ;;; **************************************************************************
    01-MAY-25 08:05:01.738: W-1 Startup took 0 seconds
    01-MAY-25 08:05:02.441: W-1 Master table "DPUSER"."SYS_IMPORT_FULL_01" successfully loaded/unloaded
    01-MAY-25 08:05:02.566: Starting "DPUSER"."SYS_IMPORT_FULL_01":  dpuser/******** parfile=/home/oracle/scripts/dp-10-downgrade-import.par
    01-MAY-25 08:05:02.577: W-1 Processing object type SCHEMA_EXPORT/USER
    01-MAY-25 08:05:02.665: W-1      Completed 1 USER objects in 0 seconds
    01-MAY-25 08:05:02.665: W-1 Processing object type SCHEMA_EXPORT/SYSTEM_GRANT
    01-MAY-25 08:05:02.695: W-1      Completed 2 SYSTEM_GRANT objects in 0 seconds
    01-MAY-25 08:05:02.695: W-1 Processing object type SCHEMA_EXPORT/DEFAULT_ROLE
    01-MAY-25 08:05:02.720: W-1      Completed 1 DEFAULT_ROLE objects in 0 seconds
    01-MAY-25 08:05:02.720: W-1 Processing object type SCHEMA_EXPORT/TABLESPACE_QUOTA
    01-MAY-25 08:05:02.746: W-1      Completed 1 TABLESPACE_QUOTA objects in 0 seconds
    01-MAY-25 08:05:02.746: W-1 Processing object type SCHEMA_EXPORT/PRE_SCHEMA/PROCACT_SCHEMA
    01-MAY-25 08:05:02.836: W-1      Completed 1 PROCACT_SCHEMA objects in 0 seconds
    01-MAY-25 08:05:02.836: W-1 Processing object type SCHEMA_EXPORT/TABLE/TABLE
    01-MAY-25 08:05:03.845: ORA-39117: Type needed to create table is not included in this operation. Failing sql is:
    CREATE TABLE "F1FROM23AI"."F1_VECTORS" ("ID" NUMBER, "EMBEDDING" ***UNSUPPORTED DATA TYPE (127)***) SEGMENT CREATION IMMEDIATE PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255      NOCOMPRESS LOGGING STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645 PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT     CELL_FLASH_CACHE DEFAULT) TABLESPACE "USERS"
    01-MAY-25 08:05:03.854: W-1      Completed 15 TABLE objects in 1 seconds
    01-MAY-25 08:05:03.860: W-1 Processing object type SCHEMA_EXPORT/TABLE/TABLE_DATA
    01-MAY-25 08:05:03.919: W-1 . . imported "F1FROM23AI"."F1_CIRCUITS"                  17.81 KB      77 rows in 0 seconds using direct_path
    01-MAY-25 08:05:03.942: W-1 . . imported "F1FROM23AI"."F1_CONSTRUCTORRESULTS"        225.5 KB   12465 rows in 0 seconds using direct_path
    01-MAY-25 08:05:03.959: W-1 . . imported "F1FROM23AI"."F1_CONSTRUCTORS"              23.18 KB     212 rows in 0 seconds using direct_path
    01-MAY-25 08:05:03.980: W-1 . . imported "F1FROM23AI"."F1_CONSTRUCTORSTANDINGS"      344.4 KB   13231 rows in 0 seconds using direct_path
    01-MAY-25 08:05:03.998: W-1 . . imported "F1FROM23AI"."F1_DRIVERS"                   88.25 KB     859 rows in 0 seconds using direct_path
    01-MAY-25 08:05:04.024: W-1 . . imported "F1FROM23AI"."F1_DRIVERSTANDINGS"           916.5 KB   34511 rows in 1 seconds using direct_path
    01-MAY-25 08:05:04.173: W-1 . . imported "F1FROM23AI"."F1_LAPTIMES"                  16.98 MB  571047 rows in 0 seconds using direct_path
    01-MAY-25 08:05:04.200: W-1 . . imported "F1FROM23AI"."F1_PITSTOPS"                  417.1 KB   10793 rows in 0 seconds using direct_path
    01-MAY-25 08:05:04.221: W-1 . . imported "F1FROM23AI"."F1_QUALIFYING"                419.4 KB   10174 rows in 0 seconds using direct_path
    01-MAY-25 08:05:04.242: W-1 . . imported "F1FROM23AI"."F1_RACES"                     132.1 KB    1125 rows in 0 seconds using direct_path
    01-MAY-25 08:05:04.272: W-1 . . imported "F1FROM23AI"."F1_RESULTS"                   1.430 MB   26439 rows in 0 seconds using direct_path
    01-MAY-25 08:05:04.289: W-1 . . imported "F1FROM23AI"."F1_SEASONS"                   10.12 KB      75 rows in 0 seconds using direct_path
    01-MAY-25 08:05:04.307: W-1 . . imported "F1FROM23AI"."F1_SPRINTRESULTS"             30.53 KB     280 rows in 0 seconds using direct_path
    01-MAY-25 08:05:04.322: W-1 . . imported "F1FROM23AI"."F1_STATUS"                    7.921 KB     139 rows in 0 seconds using direct_path
    01-MAY-25 08:05:04.333: W-1 Processing object type SCHEMA_EXPORT/TABLE/CONSTRAINT/CONSTRAINT
    01-MAY-25 08:05:05.713: W-1      Completed 22 CONSTRAINT objects in 1 seconds
    01-MAY-25 08:05:05.721: W-1      Completed 14 SCHEMA_EXPORT/TABLE/TABLE_DATA objects in 1 seconds
    01-MAY-25 08:05:05.729: Job "DPUSER"."SYS_IMPORT_FULL_01" completed with 1 error(s) at Thu May 1 08:05:05 2025 elapsed 0 00:00:05    
    ```
    </details> 

2. In the below example, Data Pump fails to import an entire table. This is a critical situation that require thorough investigation. If you're doing a database migration, such errors would probably warrent a full rollback.

    ```
    01-MAY-25 08:05:02.836: W-1 Processing object type SCHEMA_EXPORT/TABLE/TABLE
    01-MAY-25 08:05:03.845: ORA-39117: Type needed to create table is not included in this operation. Failing sql is:
    CREATE TABLE "F1FROM23AI"."F1_VECTORS" ("ID" NUMBER, "EMBEDDING" ***UNSUPPORTED DATA TYPE (127)***) SEGMENT CREATION IMMEDIATE PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255      NOCOMPRESS LOGGING STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645 PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT     CELL_FLASH_CACHE DEFAULT) TABLESPACE "USERS"
    ```

3. What about this error? Data Pump faced an error while loading the rows due to the famous `ORA-01555: snapshot too old` error. If that was the only error in the import log file, you could try to load just the missing rows by telling Data Pump to include just that table (`INCLUDE=TABLE:"IN('TAB1')"`) and start by truncating it (`TABLE_EXIST_ACTION=TRUNCATE`) and load just the rows (`CONTENT=DATA_ONLY`). 

    ```
    ORA-31693: Table data object "APPUSER"."TAB1" failed to load/unload and is being skipped due to error:
    ORA-02354: error in exporting/importing data
    ORA-01555: snapshot too old: rollback segment number 25 with name "_SYSSMU25_1608416701$" too small
    ```

4. But what if the error is less severe? Imagine you have a view which references several tables using `SCHEMA1.TABLE1`. Now, you are using the remap functionality to remap the schema to *SCHEMA2*. Those hard references to the schema will cause the view to become invalid. By updating the view defintion you could easily solve the problem. 
    * This could apply to packages, functions, procedures, triggers and other PL/SQL units as well. 

5. What if Data Pump reported errors when moving statistics? Such you could easily resolve by manually gathering statistics afterward.

6. These are just examples of the errors you might encounter. In each situation, you must investigate the situation and determine whether or not it influences the integrity of the data you're moving.


## Task 2: Comparing source and target

After moving data you can perform simple checks to validate the outcome. You will try such on the *F1* schema in the *RED* PDB that you imported in lab 7. 

1. Still in the *yellow* terminal 🟨. Connect to the *RED* PDB. This is our target database.

    ```
    <copy>
    . cdb23
    sqlplus system/oracle@localhost/red
    </copy>

    -- Be sure to hit RETURN
    ```

    * The *RED* PDB contains an *F1* schema moved from the *FTEX* database.

2. Establish a database link back to the source database, *FTEX*. 

    ```
    <copy>
    create database link srclinks connect to system identified by oracle using 'localhost/ftex';
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> create database link srclink connect to system identified by oracle using 'localhost/ftex';

    Database link SRCLINK created.
    ```
    </details> 

3. Count the number of objects grouped by types in the target database and compare it to the source database.

    ```
    <copy>
    select object_type, count(*) from dba_objects where owner='F1' group by object_type
    minus
    select object_type, count(*) from dba_objects@srclink where owner='F1' group by object_type;
    </copy>

    -- Be sure to hit RETURN
    ```

    * *No rows selected* means the count of different object types matches.
    * It does not mean that that there are no differences between the source and target. 
    * This is just a simple count.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> select object_type, count(*) from dba_objects where owner='F1' group by object_type
         minus
         select object_type, count(*) from dba_objects@srclink where owner='F1' group by object_type;
    
    no rows selected
    ```
    </details>

4. Drop a table in the target to simulate that one table were lost in the migration.

    ```
    <copy>
    drop table f1.f1_drivers purge;
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> drop table f1.f1_drivers purge;
    
    Table dropped.
    ```
    </details>

5. Compare again.    

    ```
    <copy>
    select object_type, count(*) from dba_objects where owner='F1' group by object_type
    minus
    select object_type, count(*) from dba_objects@srclink where owner='F1' group by object_type;
    </copy>

    -- Be sure to hit RETURN
    ```

    * The count of tables and indexes are different in target compared to source.
    
    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> select object_type, count(*) from dba_objects where owner='F1' group by object_type
         minus
         select object_type, count(*) from dba_objects@srclink where owner='F1' group by object_type;    
    
    OBJECT_TYPE               COUNT(*)
    ----------------------- ----------
    TABLE                           13
    INDEX                           17
    ```
    </details>

6. Find out which table is missing.

    ```
    <copy>
    select table_name from dba_tables@srclink where owner='F1'
    minus
    select table_name from dba_tables where owner='F1';
    </copy>

    -- Be sure to hit RETURN
    ```

    * The query select all tables from the source and removes all the table from the target.
    * It shows that *F1\_DRIVERS* are missing. It is the table you just dropped.
    
    <details>
    <summary>*click to see the output*</summary>
    ``` text  
    TABLE_NAME
    --------------------------------------------------------------------------------
    F1_DRIVERS
    ```
    </details>

7. If you want to compare the amount of rows, you can do that too

    ```
    <copy>
    select 
       (select count(*) from f1.f1_laptimes@srclink) as source,
       (select /*+parallel*/ count(*) from f1.f1_laptimes) as target
    from dual;
    </copy>

    -- Be sure to hit RETURN
    ```

    * You can use parallel query to speed up the process, however, selects over a database link can't use parallel query.
    * For big tables it might be faster to run the query on each database, spool to a file and compare the two files.
    * Counting rows works most efficiently if the table has an index on a column with a NOT NULL constraints, like a primary key index.

    <details>
    <summary>*click to see the output*</summary>
    ``` text  
        SOURCE     TARGET
    ---------- ----------
        571047     571047
    ```
    </details>

8. The examples used in this task is not a complete guide. It should give you an idea on how you can use the data dictionary information and queries to compare your source and target environment. Comparing objects become more complicated when you have system-generated names for indexes and partitions and when you use Advanced Queueing. The latter because it creates a varying amount of objects recursively depending on how you use the queues.


## Task 3: DBMS_COMPARISON

The `DBMS_COMPARISON` allows you to compare the rows of the same table in two different databases. 

1. Still in the *yellow* terminal 🟨 and connected to the *RED* PDB from the previous task. Make a change to one of the tables in the local, or target, database.

    <copy>
    update f1.f1_constructors set name=name||'##42##' where name='Haas F1 Team';
    commit;
    </copy>

    -- Be sure to hit RETURN
    ```

    * The update appends *##42##* to the name of *Hass F1 Team*. 

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> update f1.f1_constructors set name=name||'##42##' where name='Haas F1 Team';
    
    1 row updated.
    
    SQL> commit;
    
    Commit complete.
    ```
    </details> 

2. Create a new comparison.

    <copy>
    begin
        dbms_comparison.create_comparison (
            comparison_name => 'AFTER_MIGRATION',
            schema_name => 'F1',
            object_name => 'F1_CONSTRUCTORS',
            dblink_name => 'SRCLINK',
            scan_mode => DBMS_COMPARISON.CMP_SCAN_MODE_FULL);
    end;
    /
    </copy>

    -- Be sure to hit RETURN
    ```

    * The `SCAN_MODE` is set to full because it is a small table.
    * If you have bigger tables, you can select just a sample.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> begin
            dbms_comparison.create_comparison (
                comparison_name => 'AFTER_MIGRATION',
                schema_name => 'F1',
                object_name => 'F1_CONSTRUCTORS',
                dblink_name => 'SRCLINK',
                scan_mode => DBMS_COMPARISON.CMP_SCAN_MODE_FULL);
        end;
        /  2    3    4    5    6    7    8    9
    
    PL/SQL procedure successfully completed.
    
    SQL>    
    ```
    </details> 

3. Execute the comparison, list the number of differences and the query to find the rows.

    ```
    <copy>
    set line 150
    set serveroutput on

    col constructorref format a14
    col name format a30
    col nationality format a20
    col url format a60

    declare
        l_scan_info     dbms_comparison.comparison_type;
        l_outcome       boolean;
        l_count         number;
        l_diff          number;
        l_localrowid    user_comparison_row_dif.local_rowid%type;
        l_remoterowid   user_comparison_row_dif.remote_rowid%type;
        l_scanid        user_comparison_row_dif.scan_id%type;
    begin
        l_outcome := dbms_comparison.compare (
            comparison_name => 'AFTER_MIGRATION',
            scan_info       => l_scan_info,
            perform_row_dif => true);

        if l_outcome then
            dbms_output.put_line('No differences found!');
            return;
        end if;

        dbms_output.put_line('Differences found!');
    
        select current_dif_count, count_rows into l_diff, l_count from user_comparison_scan_summary where scan_id = l_scan_info.scan_id;

        dbms_output.put_line('Total rows: ' || l_count);
        dbms_output.put_line('Diff rows:  ' || l_diff);

        select   local_rowid, remote_rowid, max(scan_id) 
        into     l_localrowid, l_remoterowid, l_scanid
        from     user_comparison_row_dif 
        where    comparison_name='AFTER_MIGRATION' 
        group by local_rowid, remote_rowid;

        dbms_output.put_line('Local row:  select * from f1.f1_constructors where rowid='''|| l_localrowid || ''';');
        dbms_output.put_line('Remote row: select * from f1.f1_constructors@srclink where rowid='''|| l_remoterowid || ''';');

    end;
    /
    </copy>

    -- Be sure to hit RETURN
    ```

    * For simplicity, the bits and pieces have been glued together in a piece of PL/SQL.
    * The code conducts a comparison and reports the differences.
    * It also lists a query to find the offending rows in the remote/source and local/target database.
    * In this case, the comparison correctly finds the one rows you changed previously. 

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    Differences found!
    Total rows: 212
    Diff rows:  1
    Local row:  select * from f1.f1_constructors where rowid='AAAG3lAAAAAAAPuAAW';
    Remote row: select * from f1.f1_constructors@srclink where rowid='AAAF6aAAEAAAAFkAAX';
    
    PL/SQL procedure successfully completed.    
    ```
    </details> 

4. Execute the two queries. Don't copy paste/from the instructions. Use the queries in your output.

    ```
    select * from f1.f1_constructors where rowid='AAAG3lAAAAAAAPuAAW';
    select * from f1.f1_constructors@srclink where rowid='AAAF6aAAEAAAAFkAAX';
    ```

    * Spot the difference. 
    * The name from the local - or target - database has *##42##* appended.
    * If you get `ORA-01410: invalid ROWID` or `ORA-01410: The ROWID is invalid.' you are using the wrong queries. Don't copy/paste from the instructions. Use the queries generated by your output.


    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> select * from f1.f1_constructors where rowid='AAAG3lAAAAAAAPuAAW';
    
    CONSTRUCTORID CONSTRUCTORREF NAME                           NATIONALITY          URL
    ------------- -------------- ------------------------------ -------------------- ------------------------------------------------------------
    210           haas           Haas F1 Team##42##             American             http://en.wikipedia.org/wiki/Haas_F1_Team
    
    SQL> select * from f1.f1_constructors@srclink where rowid='AAAF6aAAEAAAAFkAAX';
    
    CONSTRUCTORID CONSTRUCTORREF NAME                           NATIONALITY          URL
    ------------- -------------- ------------------------------ -------------------- ------------------------------------------------------------
    210           haas           Haas F1 Team                   American             http://en.wikipedia.org/wiki/Haas_F1_Team
    ```
    </details> 

## Task 4: Data Pump Log Analyzer
    Marcus D - log file analyzer

You may now *proceed to the next lab*.

## Additional information

* Webinar, [Data Pump Best Practices and Real World Scenarios, Verification and Checks when you use Data Pump](https://www.youtube.com/watch?v=960ToLE-ZE8&t=4857s)

## Acknowledgments

* **Author** - Daniel Overby Hansen
* **Contributors** - William Beauregard, Rodrigo Jorge, Mike Dietrich, Klaus Gronau, Alex Zaballa
* **Last Updated By/Date** - Daniel Overby Hansen, May 2025