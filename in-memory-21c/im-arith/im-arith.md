# In-Memory Optimized Arithmetic

## Introduction

Watch an introduction to Database In-Memory:

[YouTube video](youtube:P6GZaykqHwI)

Watch the video below for a walk through of the In-Memory Arithmetic lab:

[In-Memory Arithmetic](videohub:1_hk4xd1wy)

*Estimated Lab Time:* 10 Minutes.

### Objectives

-   Learn how to enable In-Memory Aritmetic

### Prerequisites
This lab assumes you have:
- A Free Tier, Paid or LiveLabs Oracle Cloud account
- You have completed:
    - Get Started with noVNC Remote Desktop
    - Lab: Initialize Environment
    - Lab: Setting up the In-Memory Column Store

**NOTE:** *When doing Copy/Paste using the convenient* **Copy** *function used throughout the guide, you must hit the* **ENTER** *key after pasting. Otherwise the last line will remain in the buffer until you hit* **ENTER!**

## Task 1: In-Memory Optimized Arithmetic

To further improve in-memory performance performance, Oracle introduced In-Memory Optimized Arithmetic in Release 18c. For tables compressed with the QUERY LOW option, NUMBER columns are encoded using an optimized format that enables native calculations in hardware. SIMD vector processing of aggregations and arithmetic operations that use this format can achieve significant performance gains. The feature is enabled when INMEMORY_OPTIMIZED_ARITHMETIC is set to ENABLE.

If you ran In-Memory Expressions lab then the performance difference will not be as dramatic as using an In-Memory Expression. However, the advantage with In-Memory Optimized Arithmetic is that it will work on all arithmetic computations without first having to create an IME. This means that the two can be used together, IMEs for common expressions and In-Memory Optimized Arithmetic for other arithmetic computations.

This lab will demonstrate how In-Memory Optimized Arithmetic works and the benefits that can be seen. Note that the query is slightly different than the one used in Lab04-IME. This was done to ensure that you will only see the advantage of In-Memory Optimized Arithmetic for this lab.

Let's switch to the im-arith folder and log back in to the PDB.

```
<copy>
cd /home/oracle/labs/inmemory/im-arith
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
[CDB1:oracle@dbhol:~/labs/inmemory]$ cd /home/oracle/labs/inmemory/im-arith
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

1. First we will run a query without In-Memory Optimized Arithmetic enabled as a baseline.

    Run the script *01\_pre\_arith.sql*

    ```
    <copy>
    @01_pre_arith.sql
    </copy>    
    ```

    or run the query below:  

    ```
    <copy>
    set timing on
    column revenue_total format 999,999,999,999,999;
    column discount_total format 999,999,999,999,999;
    select sum(lo_revenue) revenue_total,
           sum(lo_ordtotalprice - (lo_ordtotalprice*(lo_discount/100))) discount_total
    from   LINEORDER;
    set timing off
    select * from table(dbms_xplan.display_cursor());
    @../imstats.sql
    </copy>
    ```

    Query result:

    ```
    SQL> @01_pre_arith.sql
    Connected.
    SQL>
    SQL> -- In-Memory query
    SQL>
    SQL> column revenue_total format 999,999,999,999,999;
    SQL> column discount_total format 999,999,999,999,999;
    SQL> select sum(lo_revenue) revenue_total,
      2         sum(lo_ordtotalprice - (lo_ordtotalprice*(lo_discount/100))) discount_total
      3  from   LINEORDER;

           REVENUE_TOTAL       DISCOUNT_TOTAL
    -------------------- --------------------
     151,711,550,697,626  749,508,796,078,510

    Elapsed: 00:00:08.03
    SQL>
    SQL> set echo off
    Hit enter ...


    PLAN_TABLE_OUTPUT
    ------------------------------------------------------------------------------------------------------------------------------------------------------
    SQL_ID  7hfhswcqwt5dz, child number 0
    -------------------------------------
    select sum(lo_revenue) revenue_total,        sum(lo_ordtotalprice -
    (lo_ordtotalprice*(lo_discount/100))) discount_total from   LINEORDER

    Plan hash value: 4085810105

    ----------------------------------------------------------------------------------------------------------
    | Id  | Operation                    | Name      | Rows  | Bytes | Cost (%CPU)| Time     | Pstart| Pstop |
    ----------------------------------------------------------------------------------------------------------
    |   0 | SELECT STATEMENT             |           |       |       |  3754 (100)|          |       |       |
    |   1 |  SORT AGGREGATE              |           |     1 |    15 |            |          |       |       |
    |   2 |   PARTITION RANGE ALL        |           |    41M|   597M|  3754  (15)| 00:00:01 |     1 |     5 |
    |   3 |    TABLE ACCESS INMEMORY FULL| LINEORDER |    41M|   597M|  3754  (15)| 00:00:01 |     1 |     5 |
    ----------------------------------------------------------------------------------------------------------


    16 rows selected.

    Hit enter ...


    NAME                                                              VALUE
    -------------------------------------------------- --------------------
    CPU used by this session                                            798
    IM scan CUs columns accessed                                        234
    IM scan CUs memcompress for query low                                78
    IM scan CUs pcode aggregation pushdown                              156
    IM scan rows                                                   41760941
    IM scan rows pcode aggregated                                  41760941
    IM scan rows projected                                               78
    IM scan rows valid                                             41760941
    session logical reads                                            315586
    session logical reads - IM                                       315480
    session pga memory                                             18024696
    table scans (IM)                                                      5

    12 rows selected.

    SQL>
    ```

2.  The following will show the current total space used in the IM column store. In-Memory Optimized Arithmetic does use some additional space in the IM column store for the optimized number format.

    Run the script *02\_im\_usage.sql*

    ```
    <copy>
    @02_im_usage.sql
    </copy>    
    ```

    or run the statements below:

    ```
    <copy>
    column pool format a10;
    column alloc_bytes format 999,999,999,999,999
    column used_bytes format 999,999,999,999,999
    SELECT pool, alloc_bytes, used_bytes, populate_status, con_id
    FROM   v$inmemory_area;
    </copy>
    ```

    Query result:

    ```
    SQL> @02_im_usage.sql
    Connected.
    SQL> column pool format a10;
    SQL> column alloc_bytes format 999,999,999,999,999
    SQL> column used_bytes format 999,999,999,999,999
    SQL>
    SQL> -- Show total column store usage
    SQL>
    SQL> SELECT pool, alloc_bytes, used_bytes, populate_status, con_id
      2  FROM   v$inmemory_area;

    POOL                ALLOC_BYTES           USED_BYTES POPULATE_STATUS                          CON_ID
    ---------- -------------------- -------------------- -------------------------- --------------------
    1MB POOL          3,940,548,608        2,215,641,088 DONE                                          3
    64KB POOL           234,881,024            5,570,560 DONE                                          3

    SQL>
    ```

3. Next we will enable In-Memory Optimized Arithmetic and re-populate the tables to create the opimized number format.

    Run the script *03\_enable\_arith.sql*

    ```
    <copy>
    @03_enable_arith.sql
    </copy>    
    ```

    or run the query below:

    ```
    <copy>
    alter table lineorder no inmemory;
    alter table part      no inmemory;
    alter table supplier  no inmemory;
    alter table date_dim  no inmemory;
    alter system set inmemory_optimized_arithmetic = 'ENABLE' scope=both;
    alter table LINEORDER inmemory memcompress for query low;
    alter table PART      inmemory memcompress for query low;
    alter table SUPPLIER  inmemory memcompress for query low;
    alter table DATE_DIM  inmemory memcompress for query low;
    select /*+ full(LINEORDER) noparallel(LINEORDER) */ count(*) from LINEORDER;
    select /*+ full(PART) noparallel(PART) */ count(*) from PART;
    select /*+ full(CUSTOMER) noparallel(CUSTOMER) */ count(*) from CUSTOMER;
    select /*+ full(SUPPLIER) noparallel(SUPPLIER) */ count(*) from SUPPLIER;
    select /*+ full(DATE_DIM) noparallel(DATE_DIM) */ count(*) from DATE_DIM;
    </copy>
    ```

    Query result:

    ```
    SQL> @03_enable_arith.sql
    Connected.
    SQL>
    SQL> -- This script will enable In-Memory optimized arithmetic
    SQL>
    SQL> alter table lineorder no inmemory;

    Table altered.

    SQL> alter table part      no inmemory;

    Table altered.

    SQL> alter table supplier  no inmemory;

    Table altered.

    SQL> alter table date_dim  no inmemory;

    Table altered.

    SQL>
    SQL> alter system set inmemory_optimized_arithmetic = 'ENABLE' scope=both;

    System altered.

    SQL>
    SQL> alter table LINEORDER inmemory memcompress for query low;

    Table altered.

    SQL> alter table PART      inmemory memcompress for query low;

    Table altered.

    SQL> alter table SUPPLIER  inmemory memcompress for query low;

    Table altered.

    SQL> alter table DATE_DIM  inmemory memcompress for query low;

    Table altered.

    SQL>
    SQL> select /*+ full(LINEORDER) noparallel(LINEORDER) */ count(*) from LINEORDER;

                COUNT(*)
    --------------------
                41760941

    SQL> select /*+ full(PART) noparallel(PART) */ count(*) from PART;

                COUNT(*)
    --------------------
                  800000

    SQL> select /*+ full(CUSTOMER) noparallel(CUSTOMER) */ count(*) from CUSTOMER;

                COUNT(*)
    --------------------
                  300000

    SQL> select /*+ full(SUPPLIER) noparallel(SUPPLIER) */ count(*) from SUPPLIER;

                COUNT(*)
    --------------------
                   20000

    SQL> select /*+ full(DATE_DIM) noparallel(DATE_DIM) */ count(*) from DATE_DIM;

                COUNT(*)
    --------------------
                    2556

    SQL>
    ```

    Notice that the alter table inmemory statements explicitly set the MEMCOMPRESS level to QUERY LOW. This is done to ensure that the In-Memory Optimized Arithmetic number formats will be created since they are only supported for MEMCOMPRESS FOR QUERY LOW.

4. Now let's make sure that all of the segments are populated:

    Run the script *04\_im\_populated.sql*

    ```
    <copy>
    @04_im_populated.sql
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
    from   v$im_segments
    order by owner, segment_name, partition_name;
    </copy>
    ```

    Query result:

    ```
    SQL> @04_im_populated.sql
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
    SSB        CUSTOMER                             COMPLETED             24,928,256       23,199,744                0
    SSB        DATE_DIM                             COMPLETED                122,880        1,179,648                0
    SSB        LINEORDER            PART_1994       COMPLETED            563,601,408      585,236,480                0
    SSB        LINEORDER            PART_1995       COMPLETED            563,470,336      585,236,480                0
    SSB        LINEORDER            PART_1996       COMPLETED            565,010,432      587,333,632                0
    SSB        LINEORDER            PART_1997       COMPLETED            563,314,688      585,236,480                0
    SSB        LINEORDER            PART_1998       COMPLETED            329,015,296      342,556,672                0
    SSB        PART                                 COMPLETED             56,893,440       21,168,128                0
    SSB        SUPPLIER                             COMPLETED              1,769,472        2,228,224                0

    9 rows selected.

    SQL>
    ```

5. Once the objects are populated let's see how much total space was consumed.

    Run the script *05\_im\_usage.sql*

    ```
    <copy>
    @05_im_usage.sql
    </copy>    
    ```

    or run the queries below:

    ```
    <copy>
    column pool format a10;
    column alloc_bytes format 999,999,999,999,999
    column used_bytes format 999,999,999,999,999
    SELECT pool, alloc_bytes, used_bytes, populate_status, con_id
    FROM   v$inmemory_area;
    </copy>
    ```

    Query result:

    ```
    SQL> @05_im_usage.sql
    Connected.
    SQL> column pool format a10;
    SQL> column alloc_bytes format 999,999,999,999,999
    SQL> column used_bytes format 999,999,999,999,999
    SQL>
    SQL> -- Show total column store usage
    SQL>
    SQL> SELECT pool, alloc_bytes, used_bytes, populate_status, con_id
      2  FROM   v$inmemory_area;

    POOL                ALLOC_BYTES           USED_BYTES POPULATE_STATUS               CON_ID
    ---------- -------------------- -------------------- --------------- --------------------
    1MB POOL          3,940,548,608        2,727,346,176 DONE                               3
    64KB POOL           234,881,024            6,029,312 DONE                               3

    SQL>
    ```

    You can see that some additional space is used by In-Memory Optimized Arithmetic.

6. Now let's see the results.

    Run the script *06\_im\_arith.sql*

    ```
    <copy>
    @06_im_arith.sql
    </copy>    
    ```

    or run the queries below:

    ```
    <copy>
    set timing on
    column revenue_total format 999,999,999,999,999;
    column discount_total format 999,999,999,999,999;
    select sum(lo_revenue) revenue_total,
           sum(lo_ordtotalprice - (lo_ordtotalprice*(lo_discount/100))) discount_total
    from   LINEORDER;
    set timing off
    select * from table(dbms_xplan.display_cursor());
    @../imstats.sql
    </copy>
    ```

    Query result:

    ```
    SQL> @06_im_arith.sql
    Connected.
    SQL>
    SQL> -- In-Memory query
    SQL>
    SQL> column revenue_total format 999,999,999,999,999;
    SQL> column discount_total format 999,999,999,999,999;
    SQL> select sum(lo_revenue) revenue_total,
      2         sum(lo_ordtotalprice - (lo_ordtotalprice*(lo_discount/100))) discount_total
      3  from   LINEORDER;

           REVENUE_TOTAL       DISCOUNT_TOTAL
    -------------------- --------------------
     151,711,550,697,626  749,508,796,078,510

    Elapsed: 00:00:04.64
    SQL>
    SQL> set echo off
    Hit enter ...


    PLAN_TABLE_OUTPUT
    ------------------------------------------------------------------------------------------------------------------------------------------------------
    SQL_ID  7hfhswcqwt5dz, child number 0
    -------------------------------------
    select sum(lo_revenue) revenue_total,        sum(lo_ordtotalprice -
    (lo_ordtotalprice*(lo_discount/100))) discount_total from   LINEORDER

    Plan hash value: 4085810105

    ----------------------------------------------------------------------------------------------------------
    | Id  | Operation                    | Name      | Rows  | Bytes | Cost (%CPU)| Time     | Pstart| Pstop |
    ----------------------------------------------------------------------------------------------------------
    |   0 | SELECT STATEMENT             |           |       |       |  3754 (100)|          |       |       |
    |   1 |  SORT AGGREGATE              |           |     1 |    15 |            |          |       |       |
    |   2 |   PARTITION RANGE ALL        |           |    41M|   597M|  3754  (15)| 00:00:01 |     1 |     5 |
    |   3 |    TABLE ACCESS INMEMORY FULL| LINEORDER |    41M|   597M|  3754  (15)| 00:00:01 |     1 |     5 |
    ----------------------------------------------------------------------------------------------------------


    16 rows selected.

    Hit enter ...


    NAME                                                              VALUE
    -------------------------------------------------- --------------------
    CPU used by this session                                            466
    IM scan CUs columns accessed                                        234
    IM scan CUs memcompress for query low                                78
    IM scan CUs pcode aggregation pushdown                              156
    IM scan rows                                                   41760941
    IM scan rows pcode aggregated                                  41760941
    IM scan rows projected                                               78
    IM scan rows valid                                             41760941
    session logical reads                                            315586
    session logical reads - IM                                       315480
    session pga memory                                             18024696
    table scans (IM)                                                      5

    12 rows selected.

    SQL>
    ```

    Not as dramatic as an In-Memory Expression but still a substantial improvement in arithmetic computations for a very modest amount of space and it will be used automatically now that it is enabled.

## Conclusion

This lab demonstrated how In-Memory Optimized Arithmetic works. It showed you how to create them and how to determine their benefit.

You may now **proceed to the next lab**.

## Acknowledgements

- **Author** - Andy Rivenes, Product Manager,  Database In-Memory
- **Contributors** -
- **Last Updated By/Date** - Andy Rivenes, August 2022
