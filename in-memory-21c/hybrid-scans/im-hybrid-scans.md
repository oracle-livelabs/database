# In-Memory Hybrid Scans

## Introduction

Watch a preview video of creating In-Memory Column Store

[YouTube video](youtube:U9BmS53KuGs)

Watch the video below for a walk through of the In-Memory Spatial lab:

[In-Memory Hybrid Scans](videohub:1_ohs9hpw0)

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

Oracle Database 21c introduced a new feature called In-Memory Hybrid Scans. Prior to 21c if a table was populated and certain columns were excluded (i.e. not Populated), and those excluded columns were accessed in a query then the whole query ran from the row store. You might be asking why anyone would exclude columns from being populated? The answer is to save space. By excluding columns that are not part of analytic queries, or reporting, it is possible to save a lot of memory in the IM column store, especially if those columns are large (i.e. consume a lot of space).

With the In-Memory Hybrid Scans feature in 21c Oracle Database will run the query in-memory and then go get the projection columns, if they were excluded from being populated, from the row store. You get the best of both worlds and better performance in most cases than if you had to run the query accessing only the row store. The catch is the columns must be projection columns, that is ones that appear in the SELECT list. If the excluded columns appear in the WHERE clause then the query will have to access the row store.

In this lab you will see how In-Memory Hybrid Scans work and how to tell if your queries are using them.

## Task 1: Verify Directory Definitions

In this Lab we will be populating external data from a local directory and we will need to define a database directory to use in our external table definitions to point the database to our external data.

Let's switch to the hybrid-scans folder and log back in to the PDB:

```
<copy>
cd /home/oracle/labs/inmemory/hybrid-scans
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
[CDB1:oracle@dbhol:~/labs/inmemory]$ cd /home/oracle/labs/inmemory/hybrid-scans
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

1. This lab will use just a single partition from the LINEORDER table. Since we will be re-populating the LINEORDER table a couple of times using just one partition will make the Lab go faster. There are no restrictions requiring this, this has been done just so that you don't have to wait for the full LINEORDER table to be populated.

    Run the script *01\_pop\_lineorder.sql*

    ```
    <copy>
    @01_pop_lineorder.sql
    </copy>    
    ```

    or run the query below:  

    ```
    <copy>
    alter table lineorder no inmemory;
    alter table lineorder modify partition part_1996 inmemory;
    exec dbms_inmemory.populate(USER, 'LINEORDER', 'PART_1996');
    </copy>
    ```

    Query result:

    ```
    SQL> @01_pop_lineorder.sql
    Connected.
    SQL>
    SQL> alter table lineorder no inmemory;

    Table altered.

    SQL>
    SQL> alter table lineorder modify partition part_1996 inmemory;

    Table altered.

    SQL>
    SQL> exec dbms_inmemory.populate(USER, 'LINEORDER', 'PART_1996');

    PL/SQL procedure successfully completed.

    SQL>
    ```

2. Verify that the LINEORDER partition PART_1996 has been populated.

    Run the script *02\_im\_populated.sql*

    ```
    <copy>
    @02_im_populated.sql
    </copy>    
    ```

    or run the query below:

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
    SQL> @02_im_populated.sql
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
    SSB        LINEORDER            PART_1996       COMPLETED            565,010,432      480,378,880                0

    SQL>
    ```

    Make note of the final "In-Memory Size" of the PART_1996 partition when population is complete.

3. Now we will run a query that will only access the PART_1996 partition in the IM column store.

    Run the script *03\_im\_query.sql*

    ```
    <copy>
    @03_im_query.sql
    </copy>    
    ```

    or run the statements below:

    ```
    <copy>
    set timing on
    select sum(lo_revenue) from lineorder
    where LO_ORDERDATE = to_date('19960102','YYYYMMDD')
    and lo_quantity > 40 and lo_shipmode = 'AIR';
    set timing off
    select * from table(dbms_xplan.display_cursor());
    @../imstats.sql
    </copy>
    ```

    Query result:

    ```
    SQL> @03_im_query.sql
    Connected.
    SQL>
    SQL> -- In-Memory query
    SQL>
    SQL> select sum(lo_revenue) from lineorder where LO_ORDERDATE = to_date('19960102','YYYYMMDD')
      2  and lo_quantity > 40 and lo_shipmode = 'AIR';

    SUM(LO_REVENUE)
    ---------------
         4916833732

    Elapsed: 00:00:00.04
    SQL>
    SQL> set echo off
    Hit enter ...


    PLAN_TABLE_OUTPUT
    ------------------------------------------------------------------------------------------------------------------------------------------------------
    SQL_ID  fggskyjgy55w8, child number 0
    -------------------------------------
    select sum(lo_revenue) from lineorder where LO_ORDERDATE =
    to_date('19960102','YYYYMMDD') and lo_quantity > 40 and lo_shipmode =
    'AIR'

    Plan hash value: 944545749

    ----------------------------------------------------------------------------------------------------------
    | Id  | Operation                    | Name      | Rows  | Bytes | Cost (%CPU)| Time     | Pstart| Pstop |
    ----------------------------------------------------------------------------------------------------------
    |   0 | SELECT STATEMENT             |           |       |       |   717 (100)|          |       |       |
    |   1 |  SORT AGGREGATE              |           |     1 |    28 |            |          |       |       |
    |   2 |   PARTITION RANGE SINGLE     |           |   999 | 27972 |   717   (3)| 00:00:01 |     3 |     3 |
    |*  3 |    TABLE ACCESS INMEMORY FULL| LINEORDER |   999 | 27972 |   717   (3)| 00:00:01 |     3 |     3 |
    ----------------------------------------------------------------------------------------------------------

    Predicate Information (identified by operation id):
    ---------------------------------------------------

       3 - inmemory(("LO_ORDERDATE"=TO_DATE(' 1996-01-02 00:00:00', 'syyyy-mm-dd hh24:mi:ss') AND
                  "LO_QUANTITY">40 AND "LO_SHIPMODE"='AIR'))
           filter(("LO_ORDERDATE"=TO_DATE(' 1996-01-02 00:00:00', 'syyyy-mm-dd hh24:mi:ss') AND
                  "LO_QUANTITY">40 AND "LO_SHIPMODE"='AIR'))


    25 rows selected.

    Hit enter ...


    NAME                                                              VALUE
    -------------------------------------------------- --------------------
    CPU used by this session                                             24
    IM scan CUs columns accessed                                         68
    IM scan CUs memcompress for query low                                17
    IM scan CUs pcode aggregation pushdown                               17
    IM scan rows                                                    9126362
    IM scan rows pcode aggregated                                       749
    IM scan rows projected                                               17
    IM scan rows valid                                              9126362
    IM scan segments minmax eligible                                     17
    physical reads                                                      335
    session logical reads                                             76235
    session logical reads - IM                                        68971
    session pga memory                                             19532024
    table scans (IM)                                                      1

    14 rows selected.

    SQL>
    ```

    Note that the execution plan shows a PARTITION RANGE SINGLE and a TABLE ACCESS INMEMORY FULL and the Pstart and Pstop columns show partition 3 was accessed.

4. Now we will re-populate the same partition but with several columns excluded (i.e. no inmemory(<column list>)).

    Run the script *04\_pop\_excluded.sql*

    ```
    <copy>
    @04_pop_excluded.sql
    </copy>
    ```

    or run the query below:

    ```
    <copy>
    alter table lineorder no inmemory;
    alter table lineorder
      no inmemory (LO_ORDERPRIORITY,LO_SHIPPRIORITY,LO_EXTENDEDPRICE,LO_ORDTOTALPRICE,
      LO_DISCOUNT,LO_REVENUE,LO_SUPPLYCOST,LO_TAX,LO_COMMITDATE);
    alter table lineorder modify partition part_1996 inmemory;
    exec dbms_inmemory.populate(USER, 'LINEORDER', 'PART_1996');
    </copy>
    ```

    Query result:

    ```
    SQL> @04_pop_excluded.sql
    Connected.
    SQL>
    SQL> alter table lineorder no inmemory;

    Table altered.

    SQL>
    SQL> alter table lineorder
      2    no inmemory (LO_ORDERPRIORITY,LO_SHIPPRIORITY,LO_EXTENDEDPRICE,LO_ORDTOTALPRICE,
      3    LO_DISCOUNT,LO_REVENUE,LO_SUPPLYCOST,LO_TAX,LO_COMMITDATE);

    Table altered.

    SQL>
    SQL> alter table lineorder modify partition part_1996 inmemory;

    Table altered.

    SQL>
    SQL> exec dbms_inmemory.populate(USER, 'LINEORDER', 'PART_1996');

    PL/SQL procedure successfully completed.

    SQL>
    ```

5. Verify that the LINEORDER partition PART_1996 has been populated.

    Run the script *05\_im\_populated.sql*

    ```
    <copy>
    @05_im_populated.sql
    </copy>    
    ```

    or run the query below:

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
    SQL> @05_im_populated.sql
    Connected.
    SQL>
    SQL> set pages 9999
    SQL> set lines 150
    SQL> column owner format a10;
    SQL> column segment_name format a20;
    SQL> column partition_name format a15;
    SQL> column populate_status format a15;
    SQL> column bytes heading 'Disk Size' format 999,999,999,999
    SQL> column inmemory_size heading 'In-Memory|Size' format 999,999,999,999
    SQL> column bytes_not_populated heading 'Bytes|Not Populated' format 999,999,999,999
    SQL> set echo on
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
    SSB        LINEORDER            PART_1996       COMPLETED            565,010,432      214,040,576                0

    SQL>
    ```

    Compare the size of the "In-Memory Size" for the PART_1996 partition with the size from Step 2. You should see that the size is considerably less. This is due to excluding columns and therefore not populating them in the IM column store.

6. We can display the status of the columns with the following query.

    Run the script *06\_im\_columns.sql*

    ```
    <copy>
    @06_im_columns.sql
    </copy>    
    ```

    or run the query below:

    ```
    <copy>
    column owner format a10;
    column table_name format a20;
    column column_name format a20;
    select owner, table_name, COLUMN_NAME, INMEMORY_COMPRESSION
    from v$im_column_level
    where table_name = 'LINEORDER'
    order by table_name, segment_column_id;
    </copy>
    ```

    Query result:

    ```
    SQL> @06_im_columns.sql
    Connected.
    SQL>
    SQL> select owner, table_name, COLUMN_NAME, INMEMORY_COMPRESSION
      2  from v$im_column_level
      3  where table_name = 'LINEORDER'
      4  order by table_name, segment_column_id;

    OWNER      TABLE_NAME           COLUMN_NAME          INMEMORY_COMPRESSION
    ---------- -------------------- -------------------- --------------------------
    SSB        LINEORDER            LO_ORDERKEY          DEFAULT
    SSB        LINEORDER            LO_LINENUMBER        DEFAULT
    SSB        LINEORDER            LO_CUSTKEY           DEFAULT
    SSB        LINEORDER            LO_PARTKEY           DEFAULT
    SSB        LINEORDER            LO_SUPPKEY           DEFAULT
    SSB        LINEORDER            LO_ORDERDATE         DEFAULT
    SSB        LINEORDER            LO_ORDERPRIORITY     NO INMEMORY
    SSB        LINEORDER            LO_SHIPPRIORITY      NO INMEMORY
    SSB        LINEORDER            LO_QUANTITY          DEFAULT
    SSB        LINEORDER            LO_EXTENDEDPRICE     NO INMEMORY
    SSB        LINEORDER            LO_ORDTOTALPRICE     NO INMEMORY
    SSB        LINEORDER            LO_DISCOUNT          NO INMEMORY
    SSB        LINEORDER            LO_REVENUE           NO INMEMORY
    SSB        LINEORDER            LO_SUPPLYCOST        NO INMEMORY
    SSB        LINEORDER            LO_TAX               NO INMEMORY
    SSB        LINEORDER            LO_COMMITDATE        NO INMEMORY
    SSB        LINEORDER            LO_SHIPMODE          DEFAULT

    17 rows selected.

    SQL>
    ```

    Notice that the column INMEMORY_COMPRESSION will specify NO INMEMORY for those columns that have been excluded.

7. Now we will re-run the same query we ran in Step 3.

    Run the script *07\_hybrid\_query.sql*

    ```
    <copy>
    @07_hybrid_query.sql
    </copy>    
    ```

    or run the query below:

    ```
    <copy>
    set timing on
    select sum(lo_revenue) from lineorder
    where LO_ORDERDATE = to_date('19960102','YYYYMMDD')
    and lo_quantity > 40 and lo_shipmode = 'AIR';
    set timing off
    pause Hit enter ...
    select * from table(dbms_xplan.display_cursor());
    pause Hit enter ...
    @../imstats.sql
    </copy>
    ```

    Query result:

    ```
    SQL> @07_hybrid_query.sql
    Connected.
    SQL>
    SQL> -- In-Memory query
    SQL>
    SQL> select sum(lo_revenue) from lineorder where LO_ORDERDATE = to_date('19960102','YYYYMMDD')
      2  and lo_quantity > 40 and lo_shipmode = 'AIR';

         SUM(LO_REVENUE)
    --------------------
              4916833732

    Elapsed: 00:00:00.05
    SQL>
    SQL> set echo off
    Hit enter ...


    PLAN_TABLE_OUTPUT
    ------------------------------------------------------------------------------------------------------------------------------------------------------
    SQL_ID  fggskyjgy55w8, child number 0
    -------------------------------------
    select sum(lo_revenue) from lineorder where LO_ORDERDATE =
    to_date('19960102','YYYYMMDD') and lo_quantity > 40 and lo_shipmode =
    'AIR'

    Plan hash value: 944545749

    -------------------------------------------------------------------------------------------------------------------
    | Id  | Operation                             | Name      | Rows  | Bytes | Cost (%CPU)| Time     | Pstart| Pstop |
    -------------------------------------------------------------------------------------------------------------------
    |   0 | SELECT STATEMENT                      |           |       |       | 18955 (100)|          |       |       |
    |   1 |  SORT AGGREGATE                       |           |     1 |    28 |            |          |       |       |
    |   2 |   PARTITION RANGE SINGLE              |           |   999 | 27972 | 18955   (1)| 00:00:01 |     3 |     3 |
    |*  3 |    TABLE ACCESS INMEMORY FULL (HYBRID)| LINEORDER |   999 | 27972 | 18955   (1)| 00:00:01 |     3 |     3 |
    -------------------------------------------------------------------------------------------------------------------

    Predicate Information (identified by operation id):
    ---------------------------------------------------

       3 - filter(("LO_ORDERDATE"=TO_DATE(' 1996-01-02 00:00:00', 'syyyy-mm-dd hh24:mi:ss') AND
                  "LO_QUANTITY">40 AND "LO_SHIPMODE"='AIR'))


    23 rows selected.

    Hit enter ...


    NAME                                                              VALUE
    -------------------------------------------------- --------------------
    CPU used by this session                                              9
    IM scan CUs columns accessed                                         51
    IM scan CUs memcompress for query low                                17
    IM scan rows                                                    9126362
    IM scan rows valid                                              9126362
    physical reads                                                     5465
    session logical reads                                             69773
    session logical reads - IM                                        68971
    session pga memory                                             17893624
    table scans (IM)                                                      1

    10 rows selected.

    SQL>
    ```

    Notice that the execution plan shows a new access path: TABLE ACCESS INMEMORY FULL (HYBRID). This is how you can tell whether the query was an In-Memory Hybrid Scan.

8. Reset the LINEORDER table back to full column population and begin re-population by running the following script.

    Run the script *08\_hybrid\_cleanup.sql*

    ```
    <copy>
    @08_hybrid_cleanup.sql
    </copy>
    ```

    or run the statements below:

    ```
    <copy>
    alter table lineorder no inmemory;
    alter table lineorder inmemory;
    exec dbms_inmemory.populate(USER, 'LINEORDER');
    </copy>
    ```

    Query result:

    ```
    SQL> @08_hybrid_cleanup.sql
    Connected.

    Table altered.


    Table altered.


    PL/SQL procedure successfully completed.

    SQL> 
    ```

## Conclusion

This lab demonstrated how In-Memory Hybrid Scans work and provide another way to save space in the IM column store without sacrificing performance.

You may now **proceed to the next lab**.

## Acknowledgements

- **Author** - Andy Rivenes, Product Manager,  Database In-Memory
- **Contributors** -
- **Last Updated By/Date** - Andy Rivenes, August 2022
