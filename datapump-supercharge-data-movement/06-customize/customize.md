# Customizing Data Pump Jobs

## Introduction

Data Pump is a very versatile tool that allows you to customize the exports and imports. In this lab, you will explore some of the options.

Estimated Time: 10 Minutes

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

    * There are many fewer object paths for a table export (20) - compared to a schema export (105).
    * A table export doesn't have to create the user, grant privileges and many other things that a schema export must.

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
    * Index statistics is a dependent object path of indexes.
    * All other object paths that you normally see in a schema export are excluded.
    * Data Pump exports 20 index statistics. These come from primary key indexes (which are part of the TABLE object path) and LOB indexes.
    
    <details>
    <summary>*click to see the output*</summary>
    ``` text
    Export: Release 19.0.0.0.0 - Production on Tue Apr 29 11:47:03 2025
    Version 19.27.0.0.0
    
    Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.
    
    Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    29-APR-25 11:47:06.191: Starting "DPUSER"."SYS_EXPORT_SCHEMA_02":  dpuser/******** parfile=/home/oracle/scripts/dp-06-include-index-export.par
    29-APR-25 11:47:06.486: W-1 Startup took 0 seconds
    29-APR-25 11:47:07.148: W-1 Processing object type SCHEMA_EXPORT/TABLE/INDEX/STATISTICS/INDEX_STATISTICS
    29-APR-25 11:47:07.180: W-1      Completed 20 INDEX_STATISTICS objects in 1 seconds
    29-APR-25 11:47:08.955: W-1 Processing object type SCHEMA_EXPORT/TABLE/INDEX/INDEX
    29-APR-25 11:47:08.960: W-1      Completed 1 INDEX objects in 1 seconds
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
    Version 19.27.0.0.0
    
    Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.
    
    Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    29-APR-25 11:59:02.613: W-1 Startup took 0 seconds
    29-APR-25 11:59:03.066: W-1 Master table "DPUSER"."SYS_SQL_FILE_FULL_01" successfully loaded/unloaded
    29-APR-25 11:59:03.194: Starting "DPUSER"."SYS_SQL_FILE_FULL_01":  dpuser/******** parfile=/home/oracle/scripts/dp-06-include-index-sqlfile.par
    29-APR-25 11:59:03.217: W-1 Processing object type SCHEMA_EXPORT/TABLE/INDEX/INDEX
    29-APR-25 11:59:03.281: W-1      Completed 1 INDEX objects in 0 seconds
    29-APR-25 11:59:03.283: W-1 Processing object type SCHEMA_EXPORT/TABLE/INDEX/STATISTICS/INDEX_STATISTICS
    29-APR-25 11:59:03.289: W-1      Completed 20 INDEX_STATISTICS objects in 0 seconds
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

10. Clean up.

    ```
    <copy>
    sqlplus / as sysdba<<EOF
       drop index f1.f1_drivers_idx1;
    EOF
    </copy>
    ```

11. In Oracle Database 19c, the `EXCLUDE` and `INCLUDE` parameters are mutually exclusive. From Oracle Database 21c you can combine those parameters. Using the previous example, if you wanted to include just indexes, and exclude index statistics you could use the following parameter file.

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

12. Not only can you exclude/include an entire object path. You can also selectively exclude/include specific objects within an object path. For example, you can exclude certain, but not all users using `EXCLUDE=USER:"IN('APPUSER', 'REPORTUSER')"`. You learn more about that syntax in lab 10, *Upgrading, Downgrading and Converting*. 

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
    Version 19.27.0.0.0
    
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
    Version 19.27.0.0.0
    
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

12. Clean up.

    ```
    <copy>
    drop view f1.f1_winners;
    drop table f1.f1_champs;
    </copy>
    ```
    
13. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```

## Task 3: Content

Sometimes you just want to export or import just the metadata, or just the data. Importing metadata first, allows you to customize the schema before importing the data.

1. Still in the *yellow* terminal 🟨. Export the *F1* schema.

    ```
    <copy>
    . ftex
    expdp dpuser/oracle parfile=/home/oracle/scripts/dp-06-content-export.par
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    Export: Release 19.0.0.0.0 - Production on Wed Apr 30 09:20:15 2025
    Version 19.27.0.0.0
    
    Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.
    
    Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    30-APR-25 09:20:17.800: Starting "DPUSER"."SYS_EXPORT_SCHEMA_02":  dpuser/******** parfile=/home/oracle/scripts/dp-06-content-export.par
    30-APR-25 09:20:18.031: W-1 Startup took 0 seconds
    30-APR-25 09:20:19.997: W-1 Processing object type SCHEMA_EXPORT/TABLE/TABLE_DATA
    30-APR-25 09:20:20.141: W-1 Processing object type SCHEMA_EXPORT/USER
    30-APR-25 09:20:20.164: W-1      Completed 1 USER objects in 0 seconds
    30-APR-25 09:20:20.181: W-1 Processing object type SCHEMA_EXPORT/SYSTEM_GRANT
    30-APR-25 09:20:20.185: W-1      Completed 2 SYSTEM_GRANT objects in 0 seconds
    30-APR-25 09:20:20.213: W-1 Processing object type SCHEMA_EXPORT/DEFAULT_ROLE
    30-APR-25 09:20:20.217: W-1      Completed 1 DEFAULT_ROLE objects in 0 seconds
    30-APR-25 09:20:20.247: W-1 Processing object type SCHEMA_EXPORT/TABLESPACE_QUOTA
    30-APR-25 09:20:20.251: W-1      Completed 1 TABLESPACE_QUOTA objects in 0 seconds
    30-APR-25 09:20:20.295: W-1 Processing object type SCHEMA_EXPORT/PRE_SCHEMA/PROCACT_SCHEMA
    30-APR-25 09:20:20.299: W-1      Completed 1 PROCACT_SCHEMA objects in 0 seconds
    30-APR-25 09:20:23.038: W-1 Processing object type SCHEMA_EXPORT/TABLE/TABLE
    30-APR-25 09:20:32.761: W-1      Completed 16 TABLE objects in 11 seconds
    30-APR-25 09:20:35.587: W-1 Processing object type SCHEMA_EXPORT/VIEW/VIEW
    30-APR-25 09:20:35.592: W-1      Completed 1 VIEW objects in 2 seconds
    30-APR-25 09:20:36.607: W-1 Processing object type SCHEMA_EXPORT/TABLE/INDEX/INDEX
    30-APR-25 09:20:36.615: W-1      Completed 2 INDEX objects in 1 seconds
    30-APR-25 09:20:37.378: W-1 Processing object type SCHEMA_EXPORT/TABLE/CONSTRAINT/CONSTRAINT
    30-APR-25 09:20:37.387: W-1      Completed 22 CONSTRAINT objects in 1 seconds
    30-APR-25 09:20:38.832: W-1 . . exported "F1"."F1_LAPTIMES"                          16.98 MB  571047 rows in 0 seconds using direct_path
    30-APR-25 09:20:38.869: W-1 . . exported "F1"."F1_RESULTS"                           1.429 MB   26439 rows in 0 seconds using direct_path
    30-APR-25 09:20:38.897: W-1 . . exported "F1"."F1_DRIVERSTANDINGS"                   916.2 KB   34511 rows in 0 seconds using direct_path
    30-APR-25 09:20:38.924: W-1 . . exported "F1"."F1_QUALIFYING"                        419.0 KB   10174 rows in 0 seconds using direct_path
    30-APR-25 09:20:38.950: W-1 . . exported "F1"."F1_PITSTOPS"                          416.8 KB   10793 rows in 0 seconds using direct_path
    30-APR-25 09:20:38.974: W-1 . . exported "F1"."F1_CONSTRUCTORSTANDINGS"              344.1 KB   13231 rows in 0 seconds using direct_path
    30-APR-25 09:20:38.998: W-1 . . exported "F1"."F1_CONSTRUCTORRESULTS"                225.2 KB   12465 rows in 0 seconds using direct_path
    30-APR-25 09:20:39.026: W-1 . . exported "F1"."F1_RACES"                             131.4 KB    1125 rows in 1 seconds using direct_path
    30-APR-25 09:20:39.050: W-1 . . exported "F1"."F1_DRIVERS"                           87.86 KB     859 rows in 0 seconds using direct_path
    30-APR-25 09:20:39.071: W-1 . . exported "F1"."F1_CHAMPS"                            37.81 KB    1112 rows in 0 seconds using direct_path
    30-APR-25 09:20:39.098: W-1 . . exported "F1"."STATTAB"                              33.46 KB     154 rows in 0 seconds using direct_path
    30-APR-25 09:20:39.122: W-1 . . exported "F1"."F1_SPRINTRESULTS"                     29.88 KB     280 rows in 0 seconds using direct_path
    30-APR-25 09:20:39.145: W-1 . . exported "F1"."F1_CONSTRUCTORS"                      22.97 KB     212 rows in 0 seconds using direct_path
    30-APR-25 09:20:39.169: W-1 . . exported "F1"."F1_CIRCUITS"                          17.42 KB      77 rows in 0 seconds using direct_path
    30-APR-25 09:20:39.192: W-1 . . exported "F1"."F1_SEASONS"                           10.03 KB      75 rows in 0 seconds using direct_path
    30-APR-25 09:20:39.214: W-1 . . exported "F1"."F1_STATUS"                            7.843 KB     139 rows in 0 seconds using direct_path
    30-APR-25 09:20:39.645: W-1      Completed 16 SCHEMA_EXPORT/TABLE/TABLE_DATA objects in 1 seconds
    30-APR-25 09:20:40.190: W-1 Master table "DPUSER"."SYS_EXPORT_SCHEMA_02" successfully loaded/unloaded
    30-APR-25 09:20:40.193: ******************************************************************************
    30-APR-25 09:20:40.193: Dump file set for DPUSER.SYS_EXPORT_SCHEMA_02 is:
    30-APR-25 09:20:40.195:   /home/oracle/dpdir/dp-06-content.dmp
    30-APR-25 09:20:40.206: Job "DPUSER"."SYS_EXPORT_SCHEMA_02" successfully completed at Wed Apr 30 09:20:40 2025 elapsed 0 00:00:23   
    ```
    </details>     

2. Start by importing just the metadata of the *F1* schema and renaming it to *CONTENTDEMO*. Examine the parameter file.

    ```
    <copy>
    cat /home/oracle/scripts/dp-06-content-import-metadata.par
    </copy>
    ```

    * To import into the same database, you remap the schema to *CONTENTDEMO*.
    * Using `CONTENT=METADATA_ONLY` Data Pump creates just the metadata without importing any rows.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    directory=dpdir
    logfile=dp-06-content-import-metadata.log
    dumpfile=dp-06-content.dmp
    metrics=yes
    logtime=all
    content=metadata_only
    remap_schema=F1:CONTENTDEMO
    ```
    </details> 

3. Start a metadata import.

    ```
    <copy>
    . ftex
    impdp dpuser/oracle parfile=/home/oracle/scripts/dp-06-content-import-metadata.par
    </copy>
    
    -- Be sure to hit RETURN
    ```

    * A metadata import is usually very fast because Data Pump skips loading rows into the tables.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    Import: Release 19.0.0.0.0 - Production on Wed Apr 30 09:28:00 2025
    Version 19.27.0.0.0
    
    Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.
    
    Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    30-APR-25 09:28:02.318: W-1 Startup took 1 seconds
    30-APR-25 09:28:02.813: W-1 Master table "DPUSER"."SYS_IMPORT_FULL_02" successfully loaded/unloaded
    30-APR-25 09:28:03.093: Starting "DPUSER"."SYS_IMPORT_FULL_02":  dpuser/******** parfile=/home/oracle/scripts/dp-06-content-import-metadata.par
    30-APR-25 09:28:03.107: W-1 Processing object type SCHEMA_EXPORT/USER
    30-APR-25 09:28:03.188: W-1      Completed 1 USER objects in 0 seconds
    30-APR-25 09:28:03.188: W-1 Processing object type SCHEMA_EXPORT/SYSTEM_GRANT
    30-APR-25 09:28:03.223: W-1      Completed 2 SYSTEM_GRANT objects in 0 seconds
    30-APR-25 09:28:03.223: W-1 Processing object type SCHEMA_EXPORT/DEFAULT_ROLE
    30-APR-25 09:28:03.257: W-1      Completed 1 DEFAULT_ROLE objects in 0 seconds
    30-APR-25 09:28:03.257: W-1 Processing object type SCHEMA_EXPORT/TABLESPACE_QUOTA
    30-APR-25 09:28:03.294: W-1      Completed 1 TABLESPACE_QUOTA objects in 0 seconds
    30-APR-25 09:28:03.294: W-1 Processing object type SCHEMA_EXPORT/PRE_SCHEMA/PROCACT_SCHEMA
    30-APR-25 09:28:03.381: W-1      Completed 1 PROCACT_SCHEMA objects in 0 seconds
    30-APR-25 09:28:03.381: W-1 Processing object type SCHEMA_EXPORT/TABLE/TABLE
    30-APR-25 09:28:04.151: W-1      Completed 16 TABLE objects in 1 seconds
    30-APR-25 09:28:04.168: W-1 Processing object type SCHEMA_EXPORT/TABLE/INDEX/INDEX
    30-APR-25 09:28:04.247: W-1      Completed 2 INDEX objects in 0 seconds
    30-APR-25 09:28:04.247: W-1 Processing object type SCHEMA_EXPORT/TABLE/CONSTRAINT/CONSTRAINT
    30-APR-25 09:28:04.476: W-1      Completed 22 CONSTRAINT objects in 0 seconds
    30-APR-25 09:28:04.488: Job "DPUSER"."SYS_IMPORT_FULL_02" successfully completed at Wed Apr 30 09:28:04 2025 elapsed 0 00:00:03
    ```
    </details> 

4. Connect to the *FTEX* database.

    ```
    <copy>
    sqlplus / as sysdba
    </copy>
    ```

5. Examine the *CONTENTDEMO.F1\_DRIVERS* table.

    ```
    <copy>
    desc contentdemo.f1_drivers
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
     Name                                      Null?    Type
     ----------------------------------------- -------- ----------------------------
     DRIVERID                                  NOT NULL NUMBER(38)
     DRIVERREF                                          VARCHAR2(255)
     ORDINAL                                            NUMBER(38)
     CODE                                               VARCHAR2(3)
     FORENAME                                           VARCHAR2(255)
     SURNAME                                            VARCHAR2(255)
     DOB                                                DATE
     NATIONALITY                                        VARCHAR2(255)
     URL                                                VARCHAR2(255)    
    ```
    </details>

6. Verify it's empty.

    ```
    <copy>
    select count(*) from contentdemo.f1_drivers;
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    COUNT(*)
    --------
    0
    ```
    </details>

6. Imagine that you are importing into a Unicode database. Names of people often contain national characters which most likely take up more bytes in a Unicode character set. To avoid any truncation issues you decide to expand the *FORENAME* column to 512 bytes. Another option is to change the length semantics from `BYTE` to `CHAR`. You decide to do that on the *SURNAME* column.

    ```
    <copy>
    alter table contentdemo.f1_drivers modify forename varchar2(512);
    alter table contentdemo.f1_drivers modify surname varchar2(255 char);
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> alter table contentdemo.f1_drivers modify forename varchar2(512);
    
    Table altered.
    
    SQL> alter table contentdemo.f1_drivers modify surname varchar2(255 char);
    
    Table altered.
    ```
    </details> 

7. Check the new table definition.

    ```
    <copy>
    desc contentdemo.f1_drivers
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
     Name                                      Null?    Type
     ----------------------------------------- -------- ----------------------------
     DRIVERID                                  NOT NULL NUMBER(38)
     DRIVERREF                                          VARCHAR2(255)
     ORDINAL                                            NUMBER(38)
     CODE                                               VARCHAR2(3)
     FORENAME                                           VARCHAR2(512)
     SURNAME                                            VARCHAR2(255 CHAR)
     DOB                                                DATE
     NATIONALITY                                        VARCHAR2(255)
     URL                                                VARCHAR2(255)    
    ```
    </details>  

8. You also decide to partition the *F1\_LAPTIMES* table because it is quite large. After analysis you determine that a hash partitioning model would be effective.

    ```
    <copy>
    alter table contentdemo.f1_laptimes modify partition by hash (raceid) partitions 16;
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> alter table contentdemo.f1_laptimes modify partition by hash (raceid) partitions 16;
    
    Table altered.
    ```
    </details>  

9. Check that the table is now partitioned.

    ```
    <copy>
    select partitioned from all_tables where owner='CONTENTDEMO' and table_name='F1_LAPTIMES';
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> select partitioned from all_tables where owner='CONTENTDEMO' and table_name='F1_LAPTIMES';
    
    PAR
    ---
    YES
    ```
    </details> 

10. You can perform other customizations if needed. Just take into account that Data Pump must be able to load the rows later on. If you remove a column, it would lead to an error.

11. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```

12. Examine a parameter file that would import the rows.

    ```
    <copy>
    cat /home/oracle/scripts/dp-06-content-import-data.par
    </copy>
    ```

    * This looks similar to the other import parameter file.
    * `CONTENT=DATA_ONLY` instructs Data Pump to just load the rows. The schema and tables must exist in advance.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    directory=dpdir
    logfile=dp-06-content-import-metadata.log
    dumpfile=dp-06-content.dmp
    metrics=yes
    logtime=all
    content=data_only
    remap_schema=F1:CONTENTDEMO
    ```
    </details> 

13. Start the data import.
    
    ```
    <copy>
    . ftex
    impdp dpuser/oracle parfile=/home/oracle/scripts/dp-06-content-import-data.par
    </copy>

    -- Be sure to hit RETURN
    ```

    * Data Pump moves directly to the `SCHEMA_EXPORT/TABLE/TABLE_DATA` object path and starts loading the rows.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    Import: Release 19.0.0.0.0 - Production on Wed Apr 30 09:37:05 2025
    Version 19.27.0.0.0
    
    Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.
    
    Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    30-APR-25 09:37:07.195: W-1 Startup took 1 seconds
    30-APR-25 09:37:07.302: W-1 Master table "DPUSER"."SYS_IMPORT_FULL_02" successfully loaded/unloaded
    30-APR-25 09:37:07.598: Starting "DPUSER"."SYS_IMPORT_FULL_02":  dpuser/******** parfile=/home/oracle/scripts/dp-06-content-import-data.par
    30-APR-25 09:37:07.612: W-1 Processing object type SCHEMA_EXPORT/TABLE/TABLE_DATA
    30-APR-25 09:37:22.454: W-1 . . imported "CONTENTDEMO"."F1_LAPTIMES"                 16.98 MB  571047 rows in 2 seconds using external_table
    30-APR-25 09:37:22.692: W-1 . . imported "CONTENTDEMO"."F1_RESULTS"                  1.429 MB   26439 rows in 0 seconds using external_table
    30-APR-25 09:37:22.918: W-1 . . imported "CONTENTDEMO"."F1_DRIVERSTANDINGS"          916.2 KB   34511 rows in 0 seconds using external_table
    30-APR-25 09:37:23.099: W-1 . . imported "CONTENTDEMO"."F1_QUALIFYING"               419.0 KB   10174 rows in 1 seconds using external_table
    30-APR-25 09:37:23.281: W-1 . . imported "CONTENTDEMO"."F1_PITSTOPS"                 416.8 KB   10793 rows in 0 seconds using external_table
    30-APR-25 09:37:23.463: W-1 . . imported "CONTENTDEMO"."F1_CONSTRUCTORSTANDINGS"     344.1 KB   13231 rows in 0 seconds using external_table
    30-APR-25 09:37:23.641: W-1 . . imported "CONTENTDEMO"."F1_CONSTRUCTORRESULTS"       225.2 KB   12465 rows in 0 seconds using external_table
    30-APR-25 09:37:23.824: W-1 . . imported "CONTENTDEMO"."F1_RACES"                    131.4 KB    1125 rows in 0 seconds using external_table
    30-APR-25 09:37:23.997: W-1 . . imported "CONTENTDEMO"."F1_DRIVERS"                  87.86 KB     859 rows in 0 seconds using external_table
    30-APR-25 09:37:24.154: W-1 . . imported "CONTENTDEMO"."F1_CHAMPS"                   37.81 KB    1112 rows in 1 seconds using external_table
    30-APR-25 09:37:24.347: W-1 . . imported "CONTENTDEMO"."STATTAB"                     33.46 KB     154 rows in 0 seconds using external_table
    30-APR-25 09:37:24.524: W-1 . . imported "CONTENTDEMO"."F1_SPRINTRESULTS"            29.88 KB     280 rows in 0 seconds using external_table
    30-APR-25 09:37:24.698: W-1 . . imported "CONTENTDEMO"."F1_CONSTRUCTORS"             22.97 KB     212 rows in 0 seconds using external_table
    30-APR-25 09:37:24.874: W-1 . . imported "CONTENTDEMO"."F1_CIRCUITS"                 17.42 KB      77 rows in 0 seconds using external_table
    30-APR-25 09:37:25.037: W-1 . . imported "CONTENTDEMO"."F1_SEASONS"                  10.03 KB      75 rows in 1 seconds using external_table
    30-APR-25 09:37:25.194: W-1 . . imported "CONTENTDEMO"."F1_STATUS"                   7.843 KB     139 rows in 0 seconds using external_table
    30-APR-25 09:37:25.226: W-1      Completed 16 SCHEMA_EXPORT/TABLE/TABLE_DATA objects in 5 seconds
    30-APR-25 09:37:25.264: Job "DPUSER"."SYS_IMPORT_FULL_02" successfully completed at Wed Apr 30 09:37:25 2025 elapsed 0 00:00:19
    ```
    </details> 

14. Connect to the *FTEX* database.

    ```
    <copy>
    . ftex
    sqlplus / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

15. You changed *F1\_LAPTIMES* to a partitioned table. Gather statistics and verify that rows are loaded into different partitions.

    ```
    <copy>
    exec dbms_stats.gather_table_stats('CONTENTDEMO', 'F1_LAPTIMES');
    col partition_name format a20
    set pagesize 100
    select partition_name, num_rows 
    from   dba_tab_statistics 
    where  owner='CONTENTDEMO' and table_name='F1_LAPTIMES' and partition_name is not null;
    </copy>

    -- Be sure to hit RETURN
    ```

    * The database generates names for the different hash partitions automatically.
    * Depending on the hash key the rows are loaded into different partitions.
    * When Data Pump loaded the rows into the database, the table was already partitioned, but it didn't cause any problems.
    * There are 16 rows; one for each partition. 

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    PARTITION_NAME       NUM_ROWS
    -------------------- ----------
    SYS_P870             36642
    SYS_P871             31666
    SYS_P872             43727
    SYS_P869             30852
    SYS_P863             59015
    SYS_P858             29791
    SYS_P860             35019
    SYS_P867             31084
    SYS_P868             27658
    SYS_P865             42425
    SYS_P864             37072
    SYS_P866             33492
    SYS_P862             41367
    SYS_P859             27083
    SYS_P857             34102
    SYS_P861             30052
    
    16 rows selected.
    ```
    </details> 

16. You also expanded one column and changed the length semantics of another. Those changes didn't cause any problems either.

17. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```
You may now *proceed to the next lab*.

## Additional information

* Webinar, [Data Pump Best Practices and Real World Scenarios, Metadata](https://www.youtube.com/watch?v=CUHcKHx_YvA&t=1260s)
* Webinar, [Data Pump Best Practices and Real World Scenarios, Generate metadata with SQLFILE](https://www.youtube.com/watch?v=CUHcKHx_YvA&t=4642s)

## Acknowledgments

* **Author** - Daniel Overby Hansen
* **Contributors** - William Beauregard, Rodrigo Jorge, Mike Dietrich, Klaus Gronau, Alex Zaballa
* **Last Updated By/Date** - Daniel Overby Hansen, May 2025