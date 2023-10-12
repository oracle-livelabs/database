# In-Memory Spatial

## Introduction

Watch a demo video of using In-Memory Spatial:

<!--- [YouTube video](youtube:Cfq0ghw-m0w) --->

Watch the video below for a walk through of the In-Memory Spatial lab:

[In-Memory Spatial](videohub:1_vdm8taun)

*Estimated Lab Time:* 10 Minutes.

### Objectives

-   Learn how to enable In-Memory on the Oracle Database
-   Perform various queries on the In-Memory Column Store

### Prerequisites

This lab assumes you have:
- A Free Tier, Paid or LiveLabs Oracle Cloud account
- You have completed:
    - Get Started with noVNC Remote Desktop
    - Lab: Initialize Environment
    - Lab: Setting up the In-Memory Column Store

**NOTE:** *When doing Copy/Paste using the convenient* **Copy** *function used throughout the guide, you must hit the* **ENTER** *key after pasting. Otherwise the last line will remain in the buffer until you hit* **ENTER!**

### Background

Oracle Database 21c introduced a new feature called In-Memory Spatial. Database In-Memory now supports a spatial summary column for each spatial column in a table. Spatial summaries are stored in In-Memory formats and filter values can use SIMD vector scans and replace R-Tree Indexes for searches. This means that by using operators such as SDO_FILTER to query a table a spatial index in not required. More information is available in the Spatial Developer's Guide.

In this lab you will see how In-Memory Spatial can be enabled and how to make use of it to further increase Spatial performance.

## Task 1: Verify Directory Definitions

In this Lab we will be populating external data from a local directory and we will need to define a database directory to use in our external table definitions to point the database to our external data.

Let's switch to the spatial folder and log back in to the PDB:

```
<copy>
cd /home/oracle/labs/inmemory/spatial
sqlplus ssb/Ora_DB4U@localhost:1521/pdb1
</copy>
```

And adjust the sqlplus display:

```
<copy>
set pages 9999
set lines 150
</copy>
```

Query result:

```
[CDB1:oracle@dbhol:~/labs/inmemory]$ cd /home/oracle/labs/inmemory/spatial
[CDB1:oracle@dbhol:~/labs/inmemory/queries]$ sqlplus ssb/Ora_DB4U@localhost:1521/pdb1

SQL*Plus: Release 21.0.0.0.0 - Production on Fri Aug 19 18:33:55 2022
Version 21.7.0.0.0

Copyright (c) 1982, 2021, Oracle.  All rights reserved.

Last Successful login time: Thu Aug 18 2022 21:37:24 +00:00

Connected to:
Oracle Database 21c Enterprise Edition Release 21.0.0.0.0 - Production
Version 21.7.0.0.0

SQL> set pages 9999
SQL> set lines 150
SQL>
```

1. In this lab will be using an example from the Oracle Database 21c Spatial Developer's Guide. We will create a new table called CITY_POINTS and add a few rows corresponding to different cities with their latitude and longitude.

    Run the script *01\_city\_points.sql*

    ```
    <copy>
    @01_city_points.sql
    </copy>    
    ```

    or run the query below:  

    ```
    <copy>
    CREATE TABLE city_points (
      city_id NUMBER PRIMARY KEY,
      city_name VARCHAR2(25),
      latitude NUMBER,
      longitude NUMBER);
    -- Original data for the table.
    -- (The sample coordinates are for a random point in or near the city.)
    INSERT INTO city_points (city_id, city_name, latitude, longitude)
      VALUES (1, 'Boston', 42.207905, -71.015625);
    INSERT INTO city_points (city_id, city_name, latitude, longitude)
      VALUES (2, 'Raleigh', 35.634679, -78.618164);
    INSERT INTO city_points (city_id, city_name, latitude, longitude)
      VALUES (3, 'San Francisco', 37.661791, -122.453613);
    INSERT INTO city_points (city_id, city_name, latitude, longitude)
      VALUES (4, 'Memphis', 35.097140, -90.065918);
    -- Add a spatial geometry column.
    ALTER TABLE city_points ADD (shape SDO_GEOMETRY);
    -- Update the table to populate geometry objects using existing
    -- latutide and longitude coordinates.
    UPDATE city_points SET shape =
      SDO_GEOMETRY(
        2001,
        8307,
        SDO_POINT_TYPE(LONGITUDE, LATITUDE, NULL),
        NULL,
        NULL
      );
    -- Update the spatial metadata.
    INSERT INTO user_sdo_geom_metadata VALUES (
       'city_points',
       'SHAPE',
        SDO_DIM_ARRAY(
          SDO_DIM_ELEMENT('Longitude',-180,180,0.5),
          SDO_DIM_ELEMENT('Latitude',-90,90,0.5)
        ),
        8307
    );
    commit;
    </copy>
    ```

    Query result:

    ```
    SQL> @01_city_points.sql
    Connected.
    SQL>
    SQL> CREATE TABLE city_points (
      2    city_id NUMBER PRIMARY KEY,
      3    city_name VARCHAR2(25),
      4    latitude NUMBER,
      5    longitude NUMBER);

    Table created.

    SQL>
    SQL> -- Original data for the table.
    SQL> -- (The sample coordinates are for a random point in or near the city.)
    SQL> INSERT INTO city_points (city_id, city_name, latitude, longitude)
      2    VALUES (1, 'Boston', 42.207905, -71.015625);

    1 row created.

    SQL> INSERT INTO city_points (city_id, city_name, latitude, longitude)
      2    VALUES (2, 'Raleigh', 35.634679, -78.618164);

    1 row created.

    SQL> INSERT INTO city_points (city_id, city_name, latitude, longitude)
      2    VALUES (3, 'San Francisco', 37.661791, -122.453613);

    1 row created.

    SQL> INSERT INTO city_points (city_id, city_name, latitude, longitude)
      2    VALUES (4, 'Memphis', 35.097140, -90.065918);

    1 row created.

    SQL>
    SQL> -- Add a spatial geometry column.
    SQL> ALTER TABLE city_points ADD (shape SDO_GEOMETRY);

    Table altered.

    SQL>
    SQL> -- Update the table to populate geometry objects using existing
    SQL> -- latutide and longitude coordinates.
    SQL> UPDATE city_points SET shape =
      2    SDO_GEOMETRY(
      3      2001,
      4      8307,
      5      SDO_POINT_TYPE(LONGITUDE, LATITUDE, NULL),
      6      NULL,
      7      NULL
      8     );

    4 rows updated.

    SQL>

    SQL> -- Update the spatial metadata.
    SQL> INSERT INTO user_sdo_geom_metadata VALUES (
      2    'city_points',
      3    'SHAPE',
      4    SDO_DIM_ARRAY(
      5      SDO_DIM_ELEMENT('Longitude',-180,180,0.5),
      6      SDO_DIM_ELEMENT('Latitude',-90,90,0.5)
      7    ),
      8    8307
      9  );

    1 row created.

    SQL> commit;

    Commit complete.

    SQL>
    ```

2. Next we will list out the columns of the CITY_POINTS table to see what we created.

    Run the script *02\_desc\_city\_points.sql*

    ```
    <copy>
    @02_desc_city_points.sql
    </copy>    
    ```

    or run the query below:  

    ```
    <copy>
    col table_name   format a20;
    col column_name  format a30;
    col data_type    format a30;
    col data_length  format 999999;
    col data_default format a30 WRAPPED;
    select TABLE_NAME, COLUMN_NAME, DATA_TYPE, data_length, DATA_DEFAULT from user_tab_cols
    where table_name = 'CITY_POINTS'
    order by column_id;
    </copy>
    ```

    Query result:

    ```
    SQL> @02_desc_city_points.sql
    Connected.

    TABLE_NAME           COLUMN_NAME                    DATA_TYPE                      DATA_LENGTH DATA_DEFAULT
    -------------------- ------------------------------ ------------------------------ ----------- ------------------------------
    CITY_POINTS          CITY_ID                        NUMBER                                  22
    CITY_POINTS          CITY_NAME                      VARCHAR2                                25
    CITY_POINTS          LATITUDE                       NUMBER                                  22
    CITY_POINTS          LONGITUDE                      NUMBER                                  22
    CITY_POINTS          SHAPE                          SDO_GEOMETRY                             1
    CITY_POINTS          SYS_NC00010$                   NUMBER                                  22
    CITY_POINTS          SYS_NC00012$                   SDO_ORDINATE_ARRAY                    3752
    CITY_POINTS          SYS_NC00007$                   NUMBER                                  22
    CITY_POINTS          SYS_NC00008$                   NUMBER                                  22
    CITY_POINTS          SYS_NC00009$                   NUMBER                                  22
    CITY_POINTS          SYS_NC00011$                   SDO_ELEM_INFO_ARRAY                   3752
    CITY_POINTS          SYS_NC00006$                   NUMBER                                  22

    12 rows selected.

    SQL>
    ```

    Note that the creation of the SHAPE column has resulted in the creation of virtual columns to accommodate the SDO_GEOMETRY object type.

3. Next we will run a query that uses SDO_FILTER and SDO_GEOMETRY functions to find a city based on a location.

    Run the script *03\_query.sql*

    ```
    <copy>
    @03_query.sql
    </copy>    
    ```

    or run the statements below:

    ```
    <copy>
    set timing on
    SELECT city_name
    FROM city_points c
    where
      sdo_filter(c.shape,
        sdo_geometry(2001,8307,sdo_point_type(-122.453613,37.661791,null),null,null)
      ) = 'TRUE';
    set timing off
    pause Hit enter ...
    select * from table(dbms_xplan.display_cursor());
    pause Hit enter ...
    @../imstats.sql
    </copy>
    ```

    Query result:

    ```
    SQL> @03_query.sql
    Connected.
    SQL>
    SQL> -- Spatial query
    SQL>
    SQL> SELECT city_name
      2  FROM city_points c
      3  where
      4   sdo_filter(c.shape,
      5              sdo_geometry(2001,8307,sdo_point_type(-122.453613,37.661791,null),null,null)
      6             ) = 'TRUE';

    CITY_NAME
    -------------------------
    San Francisco

    Elapsed: 00:00:00.29
    SQL>
    SQL> set echo off
    Hit enter ...


    PLAN_TABLE_OUTPUT
    ------------------------------------------------------------------------------------------------------------------------------------------------------
    SQL_ID  6r9nkbvmyb8pb, child number 0
    -------------------------------------
    SELECT city_name FROM city_points c where  sdo_filter(c.shape,
       sdo_geometry(2001,8307,sdo_point_type(-122.453613,37.661791,null),nul
    l,null)            ) = 'TRUE'

    Plan hash value: 3912797212

    ---------------------------------------------------------------------------------
    | Id  | Operation         | Name        | Rows  | Bytes | Cost (%CPU)| Time     |
    ---------------------------------------------------------------------------------
    |   0 | SELECT STATEMENT  |             |       |       |    17 (100)|          |
    |*  1 |  TABLE ACCESS FULL| CITY_POINTS |     1 |  3849 |    17  (83)| 00:00:01 |
    ---------------------------------------------------------------------------------

    Predicate Information (identified by operation id):
    ---------------------------------------------------

       1 - filter("MDSYS"."SDO_FILTER"("C"."SHAPE","MDSYS"."SDO_GEOMETRY"(200
                  1,8307,"SDO_POINT_TYPE"((-122.453613),37.661791,NULL),NULL,NULL))='TRUE')

    Note
    -----
       - dynamic statistics used: dynamic sampling (level=2)


    25 rows selected.

    Hit enter ...


    NAME                                                              VALUE
    -------------------------------------------------- --------------------
    CPU used by this session                                             15
    physical reads                                                      320
    session logical reads                                             10820
    session pga memory                                             18811128

    SQL>
    ```

4. Now we will create a spatial index on the SHAPE column and run a query to access that index so that we can contrast that with an In-Memory Spatial index.

    Run the script *04\_spatial\_index.sql*

    ```
    <copy>
    @04_spatial_index.sql
    </copy>
    ```

    or run the query below:

    ```
    <copy>
    -- Create spatial index
    CREATE INDEX city_points_i1 ON city_points (shape)
      INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2;
    set timing on
    -- Spatial query
    SELECT city_name
    FROM city_points c
    where
      sdo_filter(c.shape,
         sdo_geometry(2001,8307,sdo_point_type(-122.453613,37.661791,null),null,null)
      ) = 'TRUE';
    set timing off
    pause Hit enter ...
    select * from table(dbms_xplan.display_cursor());
    -- Drop spatial index
    drop INDEX city_points_i1;
    </copy>
    ```

    Query result:

    ```
    SQL> @04_spatial_index.sql
    Connected.
    SQL>
    SQL> -- Create spatial index
    SQL>
    SQL> CREATE INDEX city_points_i1 ON city_points (shape)
      2     INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2;

    Index created.

    Elapsed: 00:00:00.60
    SQL>
    SQL> -- Spatial query
    SQL>
    SQL> SELECT city_name
      2  FROM city_points c
      3  where
      4   sdo_filter(c.shape,
      5              sdo_geometry(2001,8307,sdo_point_type(-122.453613,37.661791,null),null,null)
      6             ) = 'TRUE';

    CITY_NAME
    -------------------------
    San Francisco

    Elapsed: 00:00:00.04
    SQL>
    SQL> set echo off
    Hit enter ...


    PLAN_TABLE_OUTPUT
    ------------------------------------------------------------------------------------------------------------------------------------------------------
    SQL_ID  6r9nkbvmyb8pb, child number 0
    -------------------------------------
    SELECT city_name FROM city_points c where  sdo_filter(c.shape,
       sdo_geometry(2001,8307,sdo_point_type(-122.453613,37.661791,null),nul
    l,null)            ) = 'TRUE'

    Plan hash value: 2626558175

    --------------------------------------------------------------------------------------------------
    | Id  | Operation                       | Name           | Rows  | Bytes | Cost (%CPU)| Time     |
    --------------------------------------------------------------------------------------------------
    |   0 | SELECT STATEMENT                |                |       |       |     1 (100)|          |
    |   1 |  TABLE ACCESS BY INDEX ROWID    | CITY_POINTS    |     1 |  3849 |     1   (0)| 00:00:01 |
    |*  2 |   DOMAIN INDEX (SEL: 0.000000 %)| CITY_POINTS_I1 |       |       |     1   (0)| 00:00:01 |
    --------------------------------------------------------------------------------------------------

    Predicate Information (identified by operation id):
    ---------------------------------------------------

       2 - access("MDSYS"."SDO_FILTER"("C"."SHAPE","MDSYS"."SDO_GEOMETRY"(2001,8307,"SDO_POINT
                  _TYPE"((-122.453613),37.661791,NULL),NULL,NULL))='TRUE')

    Note
    -----
       - dynamic statistics used: dynamic sampling (level=2)


    26 rows selected.


    Index dropped.

    SQL>
    ```

    Notice in the execution plan the use of a "DOMAIN INDEX". That is the spatial index that was created at the beginning of the script.

5. Now we will populate the CITY_POINTS table into the IM column store. Note that we have not yet created an In-Memory Spatial index.

    Run the script *05\_im\_pop.sql*

    ```
    <copy>
    @05_im_pop.sql
    </copy>    
    ```

    or run the queries below:

    ```
    <copy>
    alter table CITY_POINTS inmemory;
    exec dbms_inmemory.populate(USER, 'CITY_POINTS');
    </copy>
    ```

    Query result:

    ```
    SQL> @05_im_pop.sql
    Connected.
    SQL>
    SQL> alter table CITY_POINTS inmemory;

    Table altered.

    SQL>
    SQL> exec dbms_inmemory.populate(USER, 'CITY_POINTS');

    PL/SQL procedure successfully completed.

    SQL>
    ```

6. Verify that the CITY_POINTS table has been populated.

    Run the script *06\_im\_populated.sql*

    ```
    <copy>
    @06_im_populated.sql
    </copy>    
    ```

    or run the queries below:

    ```
    <copy>
    column owner format a10;
    column segment_name format a20;
    column partition_name format a15;
    column populate_status format a15;
    column bytes heading 'Disk Size' format 999,999,999,999
    column inmemory_size heading 'In-Memory|Size' format 999,999,999,999
    column bytes_not_populated heading 'Bytes|Not Populated' format 999,999,999,999
    select owner, segment_name, partition_name, populate_status, bytes,
       inmemory_size, bytes_not_populated
    from v$im_segments
    order by owner, segment_name, partition_name;
    </copy>
    ```

    Query result:

    ```
    SQL> @06_im_populated.sql
    Connected.
    SQL>
    SQL> -- Query the view v$IM_SEGMENTS to shows what objects are in the column store
    SQL> -- and how much of the objects were populated. When the BYTES_NOT_POPULATED is 0
    SQL> -- it indicates the entire table was populated.
    SQL>
    SQL> select owner, segment_name, partition_name, populate_status, bytes,
      2         inmemory_size, bytes_not_populated
      3  from   v$im_segments
      4  order by owner, segment_name, partition_name;

                                                                                            In-Memory            Bytes
    OWNER      SEGMENT_NAME         PARTITION_NAME  POPULATE_STATUS        Disk Size             Size    Not Populated
    ---------- -------------------- --------------- --------------- ---------------- ---------------- ----------------
    SSB        CITY_POINTS                          COMPLETED                 40,960        1,179,648                0

    SQL>
    ```

7. Now we will run the same query from Step 3 to access the data in the IM column store.

    Run the script *07\_im\_query.sql*

    ```
    <copy>
    @07_im_query.sql
    </copy>
    ```

    or run the query below:

    ```
    <copy>
    set timing on
    SELECT city_name
    FROM city_points c
    where
      sdo_filter(c.shape,
         sdo_geometry(2001,8307,sdo_point_type(-122.453613,37.661791,null),null,null)
      ) = 'TRUE';
    set timing off
    select * from table(dbms_xplan.display_cursor());
    @../imstats.sql
    </copy>
    ```

    Query result:

    ```
    SQL> @07_im_query.sql
    Connected.
    SQL>
    SQL> -- Spatial query
    SQL>
    SQL> SELECT city_name
      2  FROM city_points c
      3  where
      4   sdo_filter(c.shape,
      5              sdo_geometry(2001,8307,sdo_point_type(-122.453613,37.661791,null),null,null)
      6             ) = 'TRUE';

    CITY_NAME
    -------------------------
    San Francisco

    Elapsed: 00:00:00.02
    SQL>
    SQL> set echo off
    Hit enter ...


    PLAN_TABLE_OUTPUT
    ------------------------------------------------------------------------------------------------------------------------------------------------------
    SQL_ID  6r9nkbvmyb8pb, child number 0
    -------------------------------------
    SELECT city_name FROM city_points c where  sdo_filter(c.shape,
       sdo_geometry(2001,8307,sdo_point_type(-122.453613,37.661791,null),nul
    l,null)            ) = 'TRUE'

    Plan hash value: 3912797212

    ------------------------------------------------------------------------------------------
    | Id  | Operation                  | Name        | Rows  | Bytes | Cost (%CPU)| Time     |
    ------------------------------------------------------------------------------------------
    |   0 | SELECT STATEMENT           |             |       |       |    14 (100)|          |
    |*  1 |  TABLE ACCESS INMEMORY FULL| CITY_POINTS |     1 |  3849 |    14  (93)| 00:00:01 |
    ------------------------------------------------------------------------------------------

    Predicate Information (identified by operation id):
    ---------------------------------------------------

       1 - filter("MDSYS"."SDO_FILTER"("C"."SHAPE","MDSYS"."SDO_GEOMETRY"(2001,8307,"S
                  DO_POINT_TYPE"((-122.453613),37.661791,NULL),NULL,NULL))='TRUE')

    Note
    -----
       - dynamic statistics used: dynamic sampling (level=2)


    25 rows selected.

    Hit enter ...


    NAME                                                              VALUE
    -------------------------------------------------- --------------------
    CPU used by this session                                              5
    IM scan CUs columns accessed                                          9
    IM scan CUs memcompress for query low                                 1
    IM scan rows                                                          4
    IM scan rows projected                                                1
    IM scan rows valid                                                    4
    session logical reads                                               987
    session logical reads - IM                                            5
    session pga memory                                             18614520
    table scans (IM)                                                      1

    10 rows selected.

    SQL>
    ```

    Note that now the execution plan shows the access path as "TABLE ACCESS INMEMORY FULL".

8. Now we will create an In-Memory Spatial index for the SHAPE column. Note the "INMEMORY SPATIAL" sub-clause to identify the SHAPE column as a spatial column. This is very important since the In-Memory Spatial feature leverages In-Memory Expressions (IME) under the covers and this is how the feature is enabled.

    Run the script *08\_im\_spatial.sql*

    ```
    <copy>
    @08_im_spatial.sql
    </copy>    
    ```

    or run the queries below:

    ```
    <copy>
    alter table CITY_POINTS no inmemory;
    alter table CITY_POINTS inmemory priority high inmemory spatial (shape);
    exec dbms_inmemory.populate(USER, 'CITY_POINTS');
    </copy>
    ```

    Query result:

    ```
    SQL> @08_im_spatial.sql
    Connected.
    SQL>
    SQL> alter table CITY_POINTS no inmemory;

    Table altered.

    SQL>
    SQL> alter table CITY_POINTS inmemory priority high inmemory spatial (shape);

    Table altered.

    SQL>
    SQL> exec dbms_inmemory.populate(USER, 'CITY_POINTS');

    PL/SQL procedure successfully completed.

    SQL>
    ```

9. Verify that the CITY_POINTS table has been re-populated.

    Run the script *09\_im\_populated.sql*

    ```
    <copy>
    @09_im_populated.sql
    </copy>    
    ```

    or run the queries below:

    ```
    <copy>
    column owner format a10;
    column segment_name format a20;
    column partition_name format a15;
    column populate_status format a15;
    column bytes heading 'Disk Size' format 999,999,999,999
    column inmemory_size heading 'In-Memory|Size' format 999,999,999,999
    column bytes_not_populated heading 'Bytes|Not Populated' format 999,999,999,999
    select owner, segment_name, partition_name, populate_status, bytes,
       inmemory_size, bytes_not_populated
    from v$im_segments
    order by owner, segment_name, partition_name;
    </copy>
    ```

    Query result:

    ```
    SQL> @09_im_populated.sql
    Connected.
    SQL>
    SQL> -- Query the view v$IM_SEGMENTS to shows what objects are in the column store
    SQL> -- and how much of the objects were populated. When the BYTES_NOT_POPULATED is 0
    SQL> -- it indicates the entire table was populated.
    SQL>
    SQL> select owner, segment_name, partition_name, populate_status, bytes,
      2         inmemory_size, bytes_not_populated
      3  from   v$im_segments
      4  order by owner, segment_name, partition_name;

                                                                                            In-Memory            Bytes
    OWNER      SEGMENT_NAME         PARTITION_NAME  POPULATE_STATUS        Disk Size             Size    Not Populated
    ---------- -------------------- --------------- --------------- ---------------- ---------------- ----------------
    SSB        CITY_POINTS                          COMPLETED                 40,960        2,228,224                0

    SQL>
    ```

10. Since the In-Memory Spatial feature leverages In-Memory Expressions (IME) under the covers let's go ahead and take a look at how the IMEs are defined. Don't forget that with In-Memory Spatial an on-disk spatial index is not required.

    Run the script *10\_spatial\_ime.sql*

    ```
    <copy>
    @10_spatial_ime.sql
    </copy>    
    ```

    or run the queries below:

    ```
    <copy>
    col table_name format a15;
    col column_name format a45;
    col data_type format a14;
    col data_length format 999999999999;
    col data_default format a45 word_wrapped;
    select
      table_name, column_name, data_type, DATA_LENGTH, DATA_DEFAULT
    from user_tab_cols
    where table_name = 'CITY_POINTS'
    order by column_id;
    </copy>
    ```

    Query result:

    ```
    SQL> @10_spatial_ime.sql
    Connected.

    TABLE_NAME      COLUMN_NAME                                   DATA_TYPE        DATA_LENGTH DATA_DEFAULT
    --------------- --------------------------------------------- -------------- ------------- ---------------------------------------------
    CITY_POINTS     CITY_ID                                       NUMBER                    22
    CITY_POINTS     CITY_NAME                                     VARCHAR2                  25
    CITY_POINTS     LATITUDE                                      NUMBER                    22
    CITY_POINTS     LONGITUDE                                     NUMBER                    22
    CITY_POINTS     SYS_NC00012$                                  SDO_ORDINATE_A          3752
                                                                  RRAY

    CITY_POINTS     SHAPE                                         SDO_GEOMETRY               1
    CITY_POINTS     SYS_NC00011$                                  SDO_ELEM_INFO_          3752
                                                                  ARRAY

    CITY_POINTS     SYS_NC00010$                                  NUMBER                    22
    CITY_POINTS     SYS_NC00009$                                  NUMBER                    22
    CITY_POINTS     SYS_NC00008$                                  NUMBER                    22
    CITY_POINTS     SYS_NC00007$                                  NUMBER                    22
    CITY_POINTS     SYS_NC00006$                                  NUMBER                    22
    CITY_POINTS     SYS_IME_SDO_1A25CA5903C34FD6BFE099651566F93E  BINARY_DOUBLE              8 SDO_GEOM_MIN_Z(SYS_OP_NOEXPAND("SHAPE"))
    CITY_POINTS     SYS_IME_SDO_9077D3180EA04F71BF69301EF4D0514A  BINARY_DOUBLE              8 SDO_GEOM_MAX_Y(SYS_OP_NOEXPAND("SHAPE"))
    CITY_POINTS     SYS_IME_SDO_4025536DFD9D4F87BFD9118983E60D35  BINARY_DOUBLE              8 SDO_GEOM_MIN_Y(SYS_OP_NOEXPAND("SHAPE"))
    CITY_POINTS     SYS_IME_SDO_CD6DE79410034FE9BF54070194D53EFA  BINARY_DOUBLE              8 SDO_GEOM_MAX_X(SYS_OP_NOEXPAND("SHAPE"))
    CITY_POINTS     SYS_IME_SDO_13655141A90F4F69BFA9C3AEAAA017E8  BINARY_DOUBLE              8 SDO_GEOM_MIN_X(SYS_OP_NOEXPAND("SHAPE"))
    CITY_POINTS     SYS_IME_SDO_FD83CD2CF0BA4F84BF9F0BD8AB20CB3C  BINARY_DOUBLE              8 SDO_GEOM_MAX_Z(SYS_OP_NOEXPAND("SHAPE"))

    18 rows selected.

    SQL>
    ```

    Note the virtual columns that are listed with the name starting with "SYS_IME". Also note in the DATA_DEFAULT column how they represent the MIN and MAX values for the X, Y and Z axis.

11. Now we will run the same query again and we will examine the execution plan for differences with the In-Memory Spatial index defined.

    Run the script *11\_spatial\_query.sql*

    ```
    <copy>
    @11_spatial_query.sql
    </copy>    
    ```

    or run the queries below:

    ```
    <copy>
    set timing on
    SELECT city_name
    FROM city_points c
    where
      sdo_filter(c.shape,
         sdo_geometry(2001,8307,sdo_point_type(-122.453613,37.661791,null),null,null)
      ) = 'TRUE';
    set timing off
    select * from table(dbms_xplan.display_cursor());
    @../imstats.sql
    </copy>
    ```

    Query result:

    ```
    SQL> @11_spatial_query.sql
    Connected.
    SQL>
    SQL> -- Spatial query
    SQL>
    SQL> SELECT city_name
      2  FROM city_points c
      3  where
      4   sdo_filter(c.shape,
      5              sdo_geometry(2001,8307,sdo_point_type(-122.453613,37.661791,null),null,null)
      6             ) = 'TRUE';

    CITY_NAME
    -------------------------
    San Francisco

    Elapsed: 00:00:00.02
    SQL>

    SQL> set echo off

    Hit enter ...


    PLAN_TABLE_OUTPUT
    ------------------------------------------------------------------------------------------------------------------------------------------------------
    SQL_ID  6r9nkbvmyb8pb, child number 0
    -------------------------------------
    SELECT city_name FROM city_points c where  sdo_filter(c.shape,
       sdo_geometry(2001,8307,sdo_point_type(-122.453613,37.661791,null),nul
    l,null)            ) = 'TRUE'

    Plan hash value: 3912797212

    ------------------------------------------------------------------------------------------
    | Id  | Operation                  | Name        | Rows  | Bytes | Cost (%CPU)| Time     |
    ------------------------------------------------------------------------------------------
    |   0 | SELECT STATEMENT           |             |       |       |    14 (100)|          |
    |*  1 |  TABLE ACCESS INMEMORY FULL| CITY_POINTS |     1 |  3849 |    14  (93)| 00:00:01 |
    ------------------------------------------------------------------------------------------

    Predicate Information (identified by operation id):
    ---------------------------------------------------

       1 - filter((SDO_GEOM_MAX_X("SHAPE")>=SDO_GEOM_MIN_X("MDSYS"."SDO_GEOMETRY"(2001
                  ,8307,"SDO_POINT_TYPE"((-122.453613),37.661791,NULL),NULL,NULL))-7.848052667402416
                  6E-008D AND SDO_GEOM_MIN_X("SHAPE")<=SDO_GEOM_MAX_X("MDSYS"."SDO_GEOMETRY"(2001,83
                  07,"SDO_POINT_TYPE"((-122.453613),37.661791,NULL),NULL,NULL))+7.8480526674024166E-
                  008D AND SDO_GEOM_MAX_Y("SHAPE")>=SDO_GEOM_MIN_Y("MDSYS"."SDO_GEOMETRY"(2001,8307,
                  "SDO_POINT_TYPE"((-122.453613),37.661791,NULL),NULL,NULL))-7.8480526674024166E-008
                  D AND SDO_GEOM_MIN_Y("SHAPE")<=SDO_GEOM_MAX_Y("MDSYS"."SDO_GEOMETRY"(2001,8307,"SD
                  O_POINT_TYPE"((-122.453613),37.661791,NULL),NULL,NULL))+7.8480526674024166E-008D
                  AND SDO_GEOM_MAX_Z("SHAPE")>=SDO_GEOM_MIN_Z("MDSYS"."SDO_GEOMETRY"(2001,8307,"SDO_
                  POINT_TYPE"((-122.453613),37.661791,NULL),NULL,NULL))-7.8480526674024166E-008D
                  AND SDO_GEOM_MIN_Z("SHAPE")<=SDO_GEOM_MAX_Z("MDSYS"."SDO_GEOMETRY"(2001,8307,"SDO_
                  POINT_TYPE"((-122.453613),37.661791,NULL),NULL,NULL))+7.8480526674024166E-008D))

    Note
    -----
       - dynamic statistics used: dynamic sampling (level=2)


    35 rows selected.

    Hit enter ...


    NAME                                                              VALUE
    -------------------------------------------------- --------------------
    CPU used by this session                                              5
    IM scan CUs columns accessed                                          9
    IM scan CUs memcompress for query low                                 1
    IM scan EU rows                                                       4
    IM scan EUs columns accessed                                          6
    IM scan EUs memcompress for query low                                 1
    IM scan rows                                                          4
    IM scan rows pcode aggregated                                         4
    IM scan rows projected                                                1
    IM scan rows valid                                                    4
    IM scan segments minmax eligible                                      1
    session logical reads                                              1125
    session logical reads - IM                                            5
    session pga memory                                             18745592
    table scans (IM)                                                      1

    15 rows selected.

    SQL>
    ```

    Notice that the "Predicate Information" has changed quite a bit. Now the virtual columns are being accessed to determine location. We also see in the statistics section that "IM scan EU..." statistics have appeared now that IMEs are being accessed.

12. (Optional) You can run remove the changes made during this lab by running the following script.

    Run the script *12\_spatial\_cleanup.sql*

    ```
    <copy>
    @12_spatial_cleanup.sql
    </copy>    
    ```

    or run the queries below:

    ```
    <copy>
    alter table city_points no inmemory;
    delete from user_sdo_geom_metadata where table_name = 'CITY_POINTS';
    commit;
    DROP TABLE city_points;
    </copy>
    ```

    Query result:

    ```
    SQL> @12_spatial_cleanup.sql
    Connected.

    Table altered.


    1 row deleted.


    Commit complete.


    Table dropped.

    SQL>
    ```

## Conclusion

This lab demonstrated how Database In-Memory can optimize the access of spatial data.

You may now **proceed to the next lab**.

## Acknowledgements

- **Author** - Andy Rivenes, Product Manager,  Database In-Memory
- **Contributors** -
- **Last Updated By/Date** - Andy Rivenes, August 2022
