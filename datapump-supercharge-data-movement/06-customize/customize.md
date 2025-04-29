# Customizing Data Pump Jobs

## Introduction

Data Pump is a very versatile tool that allows you to customize the exports and imports. In this lab, you will explore som of the options.

Estimated Time: 15 Minutes

### Objectives

In this lab, you will:

* Use various options to customize a Data Pump job

### Prerequisites

This lab assumes:

- You have completed Lab 3: Getting Started

## Task 1: Excluding and including

Depending on the job mode (full, schema, tablespace, table, or tablespace), Data Pump exports and imports a number of object paths. An object path is for instance a table. An object path may contain dependent object paths. A table might also have indexes, comments, and statistics.

1. Use the *yellow* terminal 🟨. Connect to the *FTEX* database.

    ```
    <copy>
    . ftex
    sqlplus / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

2. Examine the list of object paths for a schema export/import.

    ```
    <copy>
    set line 150
    set pagesize 200
    col object_path format a55
    col comments format a85
    select object_path, comments 
    from schema_export_objects 
    where named='Y'
    order by 1;
    </copy>

    -- Be sure to hit RETURN
    ```

    * Select only those object paths that you can use in the `EXCLUDE` and `INCLUDE` parameters using the predicate `NAMED='Y'`.
    * All object paths can be part of an `INCLUDE` or `EXCLUDE` parameter.
    * There are 105 object paths.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    OBJECT_PATH                                             COMMENTS
    ------------------------------------------------------- -------------------------------------------------------------------------------------
    ALTER_FUNCTION                                          Recompile functions
    ALTER_PACKAGE_SPEC                                      Recompile package specifications
    ALTER_PROCEDURE                                         Recompile procedures
    ANALYTIC_VIEW                                           Analytic Views
    ATTRIBUTE_DIMENSION                                     Attribute Dimensions
    
    (output truncated)
    
    XS_DATA_SECURITY                                        XS Data Security Policies
    XS_SECURITY/XS_ACL                                      XS Security ACLs
    XS_SECURITY/XS_DATA_SECURITY                            XS Data Security Policies
    XS_SECURITY/XS_SECURITY_CLASS                           XS Security Classes
    XS_SECURITY_CLASS                                       XS Security Classes
    
    105 rows selected.
    ```
    </details> 

3. Examine the list of object paths for a table export/import.

    ```
    <copy>
    set line 150
    set pagesize 200
    col object_path format a55
    col comments format a85
    select object_path, comments 
    from table_export_objects 
    where named='Y'
    order by 1;
    </copy>

    -- Be sure to hit RETURN
    ```

    * There are much fewer object paths for a table export (20) - compared to a schema export (105).

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    OBJECT_PATH                                             COMMENTS
    ------------------------------------------------------- -------------------------------------------------------------------------------------
    CONSTRAINT                                              Constraints (including referential constraints)
    CONSTRAINT/REF_CONSTRAINT                               Referential constraints
    INDEX                                                   Indexes
    MATERIALIZED_ZONEMAP                                    Materialized zonemaps
    POST_INSTANCE/PROCDEPOBJ                                Instance procedural objects
         
    (output truncated)
    
    TABLE_EXPORT/TABLE/INDEX                                Indexes
    TABLE_EXPORT/TABLE/MATERIALIZED_ZONEMAP                 Materialized zonemaps
    TABLE_EXPORT/TABLE/POST_INSTANCE/PROCDEPOBJ             Instance procedural objects
    TABLE_EXPORT/TABLE/TRIGGER                              Triggers on the selected tables
    TRIGGER                                                 Triggers on the selected tables
    
    20 rows selected.
    ```
    </details> 

4. Find the number of object paths for a full export/import.

    ```
    <copy>
    select count(*) from database_export_objects where named='Y';
    </copy>
    ```

    * There are most object paths for a full export. 

    <details>
    <summary>*click to see the output*</summary>
    ``` text
      COUNT(*)
    ----------
           329
    ```
    </details> 

5. In a previous lab, you already saw how to exclude statistics from an export using `EXPORT=STATISTICS`. Use `INCLUDE` to just get the DDL of the indexes in the *F1* schema. Create an index.

    ```
    <copy>
    create index f1.f1_drivers_idx1 on f1.f1_drivers(code);
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> create index f1.f1_drivers_idx1 on f1.f1_drivers(code);
    
    Index created.
    ```
    </details> 

6. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```

7. Examine a pre-created parameter file.

    ```
    <copy>
    cat /home/oracle/scripts/dp-06-include-index-export.par
    </copy>
    ```

    * Notice the `INCLUDE` parameter.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    schemas=F1
    reuse_dumpfiles=yes
    directory=dpdir
    logfile=dp-06-include-index-export.log
    dumpfile=dp-06-include-index.dmp
    metrics=yes
    logtime=all
    include=index
    ```
    </details> 

6. Perform an export.

    ```
    <copy>
    . ftex
    expdp dpuser/oracle parfile=/home/oracle/scripts/dp-06-include-index-export.par
    </copy>

    -- Be sure to hit RETURN
    ```

    * Data Pump now only exports the index definitions and the index statistics.
    * Index statistics is an dependent object path of indexes.
    * All other object paths that you normally see in a schema export are excluded.
    * Depending on whether you performed lab 5, Data Pump only exports one or two indexes.
    * Data Pump exports 23 index statistics. These come from primary key indexes (which are part of the TABLE object path) and LOB indexes.
    
    <details>
    <summary>*click to see the output*</summary>
    ``` text
    Export: Release 19.0.0.0.0 - Production on Tue Apr 29 11:47:03 2025
    Version 19.21.0.0.0
    
    Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.
    
    Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    29-APR-25 11:47:06.191: Starting "DPUSER"."SYS_EXPORT_SCHEMA_02":  dpuser/******** parfile=/home/oracle/scripts/dp-06-include-index-export.par
    29-APR-25 11:47:06.486: W-1 Startup took 0 seconds
    29-APR-25 11:47:07.148: W-1 Processing object type SCHEMA_EXPORT/TABLE/INDEX/STATISTICS/INDEX_STATISTICS
    29-APR-25 11:47:07.180: W-1      Completed 23 INDEX_STATISTICS objects in 1 seconds
    29-APR-25 11:47:08.955: W-1 Processing object type SCHEMA_EXPORT/TABLE/INDEX/INDEX
    29-APR-25 11:47:08.960: W-1      Completed 2 INDEX objects in 1 seconds
    29-APR-25 11:47:09.630: W-1 Master table "DPUSER"."SYS_EXPORT_SCHEMA_02" successfully loaded/unloaded
    29-APR-25 11:47:09.633: ******************************************************************************
    29-APR-25 11:47:09.633: Dump file set for DPUSER.SYS_EXPORT_SCHEMA_02 is:
    29-APR-25 11:47:09.635:   /home/oracle/dpdir/dp-06-include-index.dmp
    29-APR-25 11:47:09.638: Job "DPUSER"."SYS_EXPORT_SCHEMA_02" successfully completed at Tue Apr 29 11:47:09 2025 elapsed 0 00:00:05
    ```
    </details>

7. Verify that no other DDL is present in the dump file by doing a *SQLFILE* import. A SQLFILE import generates DDL from the dump file and writes it to a text file. A SQLFILE import doesn't add any data or metadata to the database. Examine a pre-created parameter.

    ```
    <copy>
    cat /home/oracle/scripts/dp-06-include-index-sqlfile.par
    </copy>
    ```

    * Notice the `SQLFILE` parameter. This instructs Data Pump to just create the DDL and store it in a file.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    directory=dpdir
    logfile=dp-06-include-index-import.log
    dumpfile=dp-06-include-index.dmp
    metrics=yes
    logtime=all
    sqlfile=dp-06-include-index.sql
    ```
    </details> 

8. Generate the DDL from the dump file.

    ```
    <copy>
    impdp dpuser/oracle parfile=/home/oracle/scripts/dp-06-include-index-sqlfile.par
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    Import: Release 19.0.0.0.0 - Production on Tue Apr 29 11:59:01 2025
    Version 19.21.0.0.0
    
    Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.
    
    Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    29-APR-25 11:59:02.613: W-1 Startup took 0 seconds
    29-APR-25 11:59:03.066: W-1 Master table "DPUSER"."SYS_SQL_FILE_FULL_01" successfully loaded/unloaded
    29-APR-25 11:59:03.194: Starting "DPUSER"."SYS_SQL_FILE_FULL_01":  dpuser/******** parfile=/home/oracle/scripts/dp-06-include-index-sqlfile.par
    29-APR-25 11:59:03.217: W-1 Processing object type SCHEMA_EXPORT/TABLE/INDEX/INDEX
    29-APR-25 11:59:03.281: W-1      Completed 2 INDEX objects in 0 seconds
    29-APR-25 11:59:03.283: W-1 Processing object type SCHEMA_EXPORT/TABLE/INDEX/STATISTICS/INDEX_STATISTICS
    29-APR-25 11:59:03.289: W-1      Completed 23 INDEX_STATISTICS objects in 0 seconds
    29-APR-25 11:59:03.307: Job "DPUSER"."SYS_SQL_FILE_FULL_01" successfully completed at Tue Apr 29 11:59:03 2025 elapsed 0 00:00:01
    ```
    </details> 

9. Check the SQLFILE and verify there's only DDL to create indexes.

    ```
    <copy>
    cat /home/oracle/dpdir/dp-06-include-index.sql
    </copy>
    ```

    * You can find the `CREATE INDEX "F1"."F1_DRIVERS_IDX1"` statement in the file.
    * You might also see `CREATE INDEX "F1"."STATTAB"` from lab 5.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    -- CONNECT DPUSER
    ALTER SESSION SET EVENTS '10150 TRACE NAME CONTEXT FOREVER, LEVEL 1';
    ALTER SESSION SET EVENTS '10904 TRACE NAME CONTEXT FOREVER, LEVEL 1';
    ALTER SESSION SET EVENTS '25475 TRACE NAME CONTEXT FOREVER, LEVEL 1';
    ALTER SESSION SET EVENTS '10407 TRACE NAME CONTEXT FOREVER, LEVEL 1';
    ALTER SESSION SET EVENTS '10851 TRACE NAME CONTEXT FOREVER, LEVEL 1';
    ALTER SESSION SET EVENTS '22830 TRACE NAME CONTEXT FOREVER, LEVEL 192 ';
    -- new object type path: SCHEMA_EXPORT/TABLE/INDEX/INDEX
    -- CONNECT F1
    CREATE INDEX "F1"."STATTAB" ON "F1"."STATTAB" ("STATID", "TYPE", "C5", "C1", "C2", "C3", "C4", "VERSION")
      PCTFREE 10 INITRANS 2 MAXTRANS 255
      STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
      PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
      BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
      TABLESPACE "USERS" PARALLEL 1 ;
    
      ALTER INDEX "F1"."STATTAB" NOPARALLEL;
    CREATE INDEX "F1"."F1_DRIVERS_IDX1" ON "F1"."F1_DRIVERS" ("CODE")
      PCTFREE 10 INITRANS 2 MAXTRANS 255
      STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
      PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
      BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
      TABLESPACE "USERS" PARALLEL 1 ;
    
      ALTER INDEX "F1"."F1_DRIVERS_IDX1" NOPARALLEL;
    -- new object type path: SCHEMA_EXPORT/TABLE/INDEX/STATISTICS/INDEX_STATISTICS
    -- fixup virtual columns...
    -- done fixup virtual columns
    ```
    </details> 

10. In Oracle Database 19c, the `EXCLUDE` and `INCLUDE` parameters are mutually exclusive. From Oracle Database 21c you can combine those parameters. Using the previous example, if you wanted to include just indexes, and exclude index statistics you could use the following parameter file.

    ```
    schemas=F1
    reuse_dumpfiles=yes
    directory=dpdir
    logfile=dp-06-include-index-export.log
    dumpfile=dp-06-include-index.dmp
    metrics=yes
    logtime=all
    include=index
    exclude=index_statistics
    ```

    * `INCLUDE` select indexes and all dependent object paths, and `EXCLUDE` remove the index statistics.
    * Combining `INCLUDE` and `EXCLUDE` allows you to easily customize the Data Pump job.
    * Previously, you had to use `INCLUDE` on the export command, and then `EXCLUDE` on the import command.

## Task 2: Views as tables and remap table

Data Pump allows you to export a view including all the rows. On import, that view is transformed in a regular table.

1. Still in the *yellow* terminal 🟨. Connect to the *FTEX* database.

    ```
    <copy>
    . ftex
    sqlplus / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

2. Create a view showing the race winners in the *F1* schema.

    ```
    <copy>
    create or replace view f1.f1_winners as 
     select to_char(r.racedate, 'YYYY-MM-DD') as racedate,
            d.forename || ' ' || d.surname as driver_name
     from   f1.f1_drivers d,
            f1.f1_races r,
            f1.f1_results res
    where   d.driverid=res.driverid 
            and r.raceid=res.raceid
            and res.position=1;
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> create or replace view f1.f1_winners as
     select to_char(r.racedate, 'YYYY-MM-DD') as racedate,
            d.forename || ' ' || d.surname as driver_name
     from   f1.f1_drivers d,
            f1.f1_races r,
            f1.f1_results res
    where   d.driverid=res.driverid
            and r.raceid=res.raceid
            and res.position=1;  2    3    4    5    6    7    8    9
    
    View created.
    ```
    </details>

3. Show the winners.

    ```
    <copy>
    set pagesize 100    
    set line 100
    col racedate format a10
    col driver_name format a80
    select * from f1.f1_winners order by racedate;  
    </copy>

    -- Be sure to hit RETURN
    ```

    * Apparently, Max Verstappen was doing pretty good in 2023/2024.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    RACEDATE   DRIVER_NAME
    ---------- --------------------------------------------------------------------------------
    
    (output truncated)

    2022-06-12 Max Verstappen
    2022-06-19 Max Verstappen
    2022-07-03 Carlos Sainz
    2022-07-10 Charles Leclerc
    2022-07-24 Max Verstappen
    2022-07-31 Max Verstappen
    2022-08-28 Max Verstappen
    2022-09-04 Max Verstappen
    2022-09-11 Max Verstappen
    2022-10-02 Sergio Pérez
    2022-10-09 Max Verstappen
    2022-10-23 Max Verstappen
    2022-10-30 Max Verstappen
    2022-11-13 George Russell
    2022-11-20 Max Verstappen
    2023-03-05 Max Verstappen
    2023-03-19 Sergio Pérez
    2023-04-02 Max Verstappen
    2023-04-30 Sergio Pérez
    2023-05-07 Max Verstappen
    2023-05-28 Max Verstappen
    2023-06-04 Max Verstappen
    2023-06-18 Max Verstappen
    2023-07-02 Max Verstappen
    2023-07-09 Max Verstappen
    2023-07-23 Max Verstappen
    2023-07-30 Max Verstappen
    2023-08-27 Max Verstappen
    2023-09-03 Max Verstappen
    2023-09-17 Carlos Sainz
    2023-09-24 Max Verstappen
    2023-10-08 Max Verstappen
    2023-10-22 Max Verstappen
    2023-10-29 Max Verstappen
    2023-11-05 Max Verstappen
    2023-11-19 Max Verstappen
    2023-11-26 Max Verstappen
    2024-03-02 Max Verstappen
    2024-03-09 Max Verstappen
    2024-03-24 Carlos Sainz
    2024-04-07 Max Verstappen
    2024-04-21 Max Verstappen
    2024-05-05 Lando Norris
    2024-05-19 Max Verstappen
    2024-05-26 Charles Leclerc
    
    1112 rows selected.
    ```
    </details>
    
4. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```

5. Export the view as a table. Examine a pre-created parameter file.

    ```
    <copy>
    cat /home/oracle/scripts/dp-06-vat-export.par
    </copy>
    ```

    * Notice the `VIEWS_AS_TABLES` parameter. `F1_WINNERS` is the view you just created.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    directory=dpdir
    logfile=dp-06-vat-export.log
    dumpfile=dp-06-vat.dmp
    reuse_dumpfiles=yes
    metrics=yes
    logtime=all
    views_as_tables=F1.F1_WINNERS
    ```
    </details> 

6. Perform an export.

    ```
    <copy>
    . ftex
    expdp dpuser/oracle parfile=/home/oracle/scripts/dp-06-vat-export.par
    </copy>

    -- Be sure to hit RETURN
    ```

    * Notice the object path `TABLE_EXPORT/VIEWS_AS_TABLES/TABLE`.
    * Data Pump exported the view as a table including all rows.
    
    <details>
    <summary>*click to see the output*</summary>
    ``` text
    Export: Release 19.0.0.0.0 - Production on Tue Apr 29 13:01:30 2025
    Version 19.21.0.0.0
    
    Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.
    
    Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    29-APR-25 13:01:32.479: Starting "DPUSER"."SYS_EXPORT_TABLE_01":  dpuser/******** parfile=/home/oracle/scripts/dp-06-vat-export.par
    29-APR-25 13:01:32.650: W-1 Startup took 0 seconds
    29-APR-25 13:01:34.062: W-1 Processing object type TABLE_EXPORT/VIEWS_AS_TABLES/TABLE_DATA
    29-APR-25 13:01:35.677: W-1 Processing object type TABLE_EXPORT/VIEWS_AS_TABLES/TABLE
    29-APR-25 13:01:35.760: W-1      Completed 1 TABLE objects in 1 seconds
    29-APR-25 13:01:36.278: W-1 . . exported "F1"."F1_WINNERS"                           37.81 KB    1112 rows in 0 seconds using external_table
    29-APR-25 13:01:36.422: W-1      Completed 1 TABLE_EXPORT/VIEWS_AS_TABLES/TABLE_DATA objects in 0 seconds
    29-APR-25 13:01:37.055: W-1 Master table "DPUSER"."SYS_EXPORT_TABLE_01" successfully loaded/unloaded
    29-APR-25 13:01:37.057: ******************************************************************************
    29-APR-25 13:01:37.058: Dump file set for DPUSER.SYS_EXPORT_TABLE_01 is:
    29-APR-25 13:01:37.059:   /home/oracle/dpdir/dp-06-vat.dmp
    29-APR-25 13:01:37.062: Job "DPUSER"."SYS_EXPORT_TABLE_01" successfully completed at Tue Apr 29 13:01:37 2025 elapsed 0 00:00:05
    ```
    </details>

7. Import the table to the same database. Examine a pre-created parameter file.

    ```
    <copy>
    cat /home/oracle/scripts/dp-06-vat-import.par
    </copy>
    ```

    * Since `F1_WINNERS` is already in use, you use `REMAP_TABLE` to give it a new name.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    directory=dpdir
    logfile=dp-06-vat-import.log
    dumpfile=dp-06-vat.dmp
    metrics=yes
    logtime=all
    remap_table=F1_WINNERS:F1_CHAMPS
    ```
    </details> 

8. Start the import.

    ```
    <copy>
    impdp dpuser/oracle parfile=/home/oracle/scripts/dp-06-vat-import.par
    </copy>
    ```

    * You can see that the view is imported as a table and renamed to *F1\_CHAMPS*. 

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    Import: Release 19.0.0.0.0 - Production on Tue Apr 29 13:05:38 2025
    Version 19.21.0.0.0
    
    Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.
    
    Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    29-APR-25 13:05:39.520: W-1 Startup took 0 seconds
    29-APR-25 13:05:39.729: W-1 Master table "DPUSER"."SYS_IMPORT_FULL_02" successfully loaded/unloaded
    29-APR-25 13:05:39.968: Starting "DPUSER"."SYS_IMPORT_FULL_02":  dpuser/******** parfile=/home/oracle/scripts/dp-06-vat-import.par
    29-APR-25 13:05:39.982: W-1 Processing object type TABLE_EXPORT/VIEWS_AS_TABLES/TABLE
    29-APR-25 13:05:40.129: W-1      Completed 1 TABLE objects in 1 seconds
    29-APR-25 13:05:40.137: W-1 Processing object type TABLE_EXPORT/VIEWS_AS_TABLES/TABLE_DATA
    29-APR-25 13:05:40.205: W-1 . . imported "F1"."F1_CHAMPS"                            37.81 KB    1112 rows in 0 seconds using direct_path
    29-APR-25 13:05:40.217: W-1      Completed 1 TABLE_EXPORT/VIEWS_AS_TABLES/TABLE_DATA objects in 0 seconds
    29-APR-25 13:05:40.253: Job "DPUSER"."SYS_IMPORT_FULL_02" successfully completed at Tue Apr 29 13:05:40 2025 elapsed 0 00:00:01
    ```
    </details> 

9. Connect to the database.

    ```
    <copy>
    . ftex
    sqlplus / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

10. Verify that *F1\_CHAMPS* is a table. 

    ```
    <copy>
    select object_type from all_objects where owner='F1' and object_name='F1_CHAMPS';
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> select object_type from all_objects where owner='F1' and object_name='F1_CHAMPS';
    
    OBJECT_TYPE
    -----------------------
    TABLE
    ```
    </details> 

11. The table contains the same rows as the original view. 

    ```
    <copy>
    set pagesize 100    
    set line 100
    col racedate format a10
    col driver_name format a80
    select * from f1.f1_winners order by racedate;  
    </copy>

    -- Be sure to hit RETURN
    ```

    * Honestly, that's a pretty amazing winning streak.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    RACEDATE   DRIVER_NAME
    ---------- --------------------------------------------------------------------------------
    
    (output truncated)

    2022-06-12 Max Verstappen
    2022-06-19 Max Verstappen
    2022-07-03 Carlos Sainz
    2022-07-10 Charles Leclerc
    2022-07-24 Max Verstappen
    2022-07-31 Max Verstappen
    2022-08-28 Max Verstappen
    2022-09-04 Max Verstappen
    2022-09-11 Max Verstappen
    2022-10-02 Sergio Pérez
    2022-10-09 Max Verstappen
    2022-10-23 Max Verstappen
    2022-10-30 Max Verstappen
    2022-11-13 George Russell
    2022-11-20 Max Verstappen
    2023-03-05 Max Verstappen
    2023-03-19 Sergio Pérez
    2023-04-02 Max Verstappen
    2023-04-30 Sergio Pérez
    2023-05-07 Max Verstappen
    2023-05-28 Max Verstappen
    2023-06-04 Max Verstappen
    2023-06-18 Max Verstappen
    2023-07-02 Max Verstappen
    2023-07-09 Max Verstappen
    2023-07-23 Max Verstappen
    2023-07-30 Max Verstappen
    2023-08-27 Max Verstappen
    2023-09-03 Max Verstappen
    2023-09-17 Carlos Sainz
    2023-09-24 Max Verstappen
    2023-10-08 Max Verstappen
    2023-10-22 Max Verstappen
    2023-10-29 Max Verstappen
    2023-11-05 Max Verstappen
    2023-11-19 Max Verstappen
    2023-11-26 Max Verstappen
    2024-03-02 Max Verstappen
    2024-03-09 Max Verstappen
    2024-03-24 Carlos Sainz
    2024-04-07 Max Verstappen
    2024-04-21 Max Verstappen
    2024-05-05 Lando Norris
    2024-05-19 Max Verstappen
    2024-05-26 Charles Leclerc
    
    1112 rows selected.    
    ```
    </details> 

12. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```
You may now *proceed to the next lab*.

## Additional information

* Webinar, [Data Pump Best Practices and Real World Scenarios, LOB data and Data Pump and things to know](https://www.youtube.com/watch?v=960ToLE-ZE8&t=1798s)
* Webinar, [Data Pump Best Practices and Real World Scenarios, Statistics and Data Pump](https://www.youtube.com/watch?v=960ToLE-ZE8&t=1117s)

## Acknowledgments

* **Author** - Daniel Overby Hansen
* **Contributors** - Rodrigo Jorge, Mike Dietrich, Klaus Gronau, Alex Zaballa
* **Last Updated By/Date** - Daniel Overby Hansen, May 2025