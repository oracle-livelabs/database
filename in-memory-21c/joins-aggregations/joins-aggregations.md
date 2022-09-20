# In-Memory Joins and Aggregations

## Introduction
Watch the video below to get an overview of joins using Database In-Memory.

[](youtube:y3tQeVGuo6g)

Watch the video below for a quick walk-through of this lab.
[In-Memory Joins and Aggregations](videohub:1_gx8ajh93)

### Objectives

-   Learn how to enable In-Memory on the Oracle Database
-   Perform various queries on the In-Memory Column Store

### Prerequisites
This lab assumes you have:
- A Free Tier, Paid or LiveLabs Oracle Cloud account
- You have completed:
    - Lab: Prepare Setup (*Free-tier* and *Paid Tenants* only)
    - Lab: Environment Setup
    - Lab: Initialize Environment
    - Lab: Querying the In-Memory Column Store

**NOTE:** *When doing Copy/Paste using the convenient* **Copy** *function used throughout the guide, you must hit the* **ENTER** *key after pasting. Otherwise the last line will remain in the buffer until you hit* **ENTER!**

## Task 1: In-Memory Joins and Aggregation

Up until now we have been focused on queries that scan only one table, the LINEORDER table. Let’s broaden the scope of our investigation to include joins and parallel execution. This section executes a series of queries that begin with a single join between the fact table, LINEORDER, and one or more dimension tables and works up to a 5 table join. The queries will be executed in both the buffer cache and the column store, to demonstrate the different ways the column store can improve query performance above and beyond just the basic performance benefits of scanning data in a columnar format.

Let's switch to the joins-aggr folder and log back in to the PDB:

```
<copy>
cd /home/oracle/labs/inmemory/joins-aggr
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
[CDB1:oracle@dbhol:~/labs/inmemory]$ cd /home/oracle/labs/inmemory/joins-aggr
[CDB1:oracle@dbhol:~/labs/inmemory/joins-aggr]$ sqlplus ssb/Ora_DB4U@localhost:1521/pdb1

SQL*Plus: Release 21.0.0.0.0 - Production on Fri Aug 19 18:33:55 2022
Version 21.4.0.0.0

Copyright (c) 1982, 2021, Oracle.  All rights reserved.

Last Successful login time: Thu Aug 18 2022 21:37:24 +00:00

Connected to:
Oracle Database 21c Enterprise Edition Release 21.0.0.0.0 - Production
Version 21.4.0.0.0

SQL> set pages 9999
SQL> set lines 150
SQL>
```

1. We will start by joining the LINEORDER and DATE\_DIM tables in a "What If" style query that calculates the amount of revenue increase that would have resulted from eliminating certain company-wide discounts in a given percentage range for products shipped on a given day (Christmas eve 1996).  

    Run the script *01\_join\_im.sql*

    ```
    <copy>
    @01_join_im.sql
    </copy>    
    ```

    or run the query below:  

    ```
    <copy>
    set timing on
    SELECT SUM(lo_extendedprice * lo_discount) revenue
    FROM   lineorder l, date_dim d
    WHERE  l.lo_orderdate = d.d_datekey
    AND    l.lo_discount BETWEEN 2 AND 3
    AND    l.lo_quantity < 24
    AND    d.d_date='December 24, 1996';
    set timing off
    select * from table(dbms_xplan.display_cursor());
    @../imstats.sql
    </copy>
    ```

    Query result:

    ```
    SQL> @01_join_im.sql
    Connected.
    SQL>
    SQL> -- Demonstrate an in-memory join query
    SQL>
    SQL> Select sum(lo_extendedprice * lo_discount) revenue
      2  From   LINEORDER l, DATE_DIM d
      3  Where  l.lo_orderdate = d.d_datekey
      4  And    l.lo_discount between 2 and 3
      5  And    l.lo_quantity < 24
      6  And    d.d_date='December 24, 1996';

             REVENUE
    ----------------
          9710699495

    Elapsed: 00:00:00.04
    SQL>
    SQL> set echo off
    Hit enter ...


    PLAN_TABLE_OUTPUT
    ------------------------------------------------------------------------------------------------------------------------------------------------------
    SQL_ID  b2jysvyzbss5p, child number 0
    -------------------------------------
    Select sum(lo_extendedprice * lo_discount) revenue From   LINEORDER l,
    DATE_DIM d Where  l.lo_orderdate = d.d_datekey And    l.lo_discount
    between 2 and 3 And    l.lo_quantity < 24 And    d.d_date='December 24,
    1996'

    Plan hash value: 2500197027

    ------------------------------------------------------------------------------------------------------------
    | Id  | Operation                      | Name      | Rows  | Bytes | Cost (%CPU)| Time     | Pstart| Pstop |
    ------------------------------------------------------------------------------------------------------------
    |   0 | SELECT STATEMENT               |           |       |       |  4058 (100)|          |       |       |
    |   1 |  SORT AGGREGATE                |           |     1 |    47 |            |          |       |       |
    |*  2 |   HASH JOIN                    |           |  2085 | 97995 |  4058  (21)| 00:00:01 |       |       |
    |   3 |    JOIN FILTER CREATE          | :BF0001   |     1 |    27 |     1   (0)| 00:00:01 |       |       |
    |   4 |     PART JOIN FILTER CREATE    | :BF0000   |     1 |    27 |     1   (0)| 00:00:01 |       |       |
    |*  5 |      TABLE ACCESS INMEMORY FULL| DATE_DIM  |     1 |    27 |     1   (0)| 00:00:01 |       |       |
    |   6 |    JOIN FILTER USE             | :BF0001   |  3492K|    66M|  4045  (21)| 00:00:01 |       |       |
    |   7 |     PARTITION RANGE JOIN-FILTER|           |  3492K|    66M|  4045  (21)| 00:00:01 |:BF0000|:BF0000|
    |*  8 |      TABLE ACCESS INMEMORY FULL| LINEORDER |  3492K|    66M|  4045  (21)| 00:00:01 |:BF0000|:BF0000|
    ------------------------------------------------------------------------------------------------------------

    Predicate Information (identified by operation id):
    ---------------------------------------------------

       2 - access("L"."LO_ORDERDATE"="D"."D_DATEKEY")
       5 - inmemory("D"."D_DATE"='December 24, 1996')
           filter("D"."D_DATE"='December 24, 1996')
       8 - inmemory(("L"."LO_DISCOUNT"<=3 AND "L"."LO_QUANTITY"<24 AND "L"."LO_DISCOUNT">=2 AND
                  SYS_OP_BLOOM_FILTER(:BF0001,"L"."LO_ORDERDATE")))
           filter(("L"."LO_DISCOUNT"<=3 AND "L"."LO_QUANTITY"<24 AND "L"."LO_DISCOUNT">=2 AND
                  SYS_OP_BLOOM_FILTER(:BF0001,"L"."LO_ORDERDATE")))


    34 rows selected.

    Hit enter ...


    NAME                                                              VALUE
    -------------------------------------------------- --------------------
    CPU used by this session                                              5
    IM scan CUs columns accessed                                         70
    IM scan CUs memcompress for query low                                18
    IM scan CUs pcode aggregation pushdown                               17
    IM scan rows                                                    9128918
    IM scan rows pcode aggregated                                      2131
    IM scan rows projected                                               17
    IM scan rows valid                                              9128918
    IM scan segments minmax eligible                                     18
    physical reads                                                        2
    session logical reads                                             69087
    session logical reads - IM                                        68986
    session pga memory                                             18155768
    table scans (IM)                                                      2

    14 rows selected.

    SQL>
    ```

    Database In-Memory has no problem executing a query with a join, and in fact can optimize hash joins by being able to take advantage of Bloom filters. It’s easy to identify Bloom filters in the execution plan. They will appear in two places, at creation time (i.e. JOIN FILTER CREATE) and again when they are applied (i.e. JOIN FILTER USE). Look at Id 3 and Id 6 in the plan above. You can also see what join condition was used to build the Bloom filter by looking at the predicate information under the plan.

2. Let's run the query using the buffer cache.

    Run the script *02\_join\_buffer.sql*

    ```
    <copy>
    @02_join_buffer.sql
    </copy>    
    ```

    or run the query below:

    ```
    <copy>
    set timing on
    select /*+ NO_INMEMORY NO_VECTOR_TRANSFORM */
      sum(lo_extendedprice * lo_discount) revenue
    from LINEORDER l, DATE_DIM d
    where l.lo_orderdate = d.d_datekey
    and l.lo_discount between 2 and 3
    and l.lo_quantity < 24
    and d.d_date='December 24, 1996';
    set timing off
    select * from table(dbms_xplan.display_cursor());
    @../imstats.sql
    </copy>
    ```

    Query result:

    ```
    SQL> @02_join_buffer.sql
    Connected.
    SQL>
    SQL> -- Buffer Cache query with the column store disabled using a NO_INMEMORY hint
    SQL> --
    SQL>
    SQL> SELECT /*+ NO_INMEMORY NO_VECTOR_TRANSFORM */
      2         SUM(lo_extendedprice * lo_discount) revenue
      3  FROM   lineorder l,
      4         date_dim d
      5  WHERE  l.lo_orderdate = d.d_datekey
      6  AND    d.d_date='December 24, 1996';

             REVENUE
    ----------------
        467915827233

    Elapsed: 00:00:00.85
    SQL>
    SQL> set echo off
    Hit enter ...


    PLAN_TABLE_OUTPUT
    ------------------------------------------------------------------------------------------------------------------------------------------------------
    SQL_ID  8xkbya444k6g5, child number 0
    -------------------------------------
    SELECT /*+ NO_INMEMORY NO_VECTOR_TRANSFORM */
    SUM(lo_extendedprice * lo_discount) revenue FROM   lineorder l,
    date_dim d WHERE  l.lo_orderdate = d.d_datekey AND
    d.d_date='December 24, 1996'

    Plan hash value: 2848862642

    -----------------------------------------------------------------------------------------------------------
    | Id  | Operation                     | Name      | Rows  | Bytes | Cost (%CPU)| Time     | Pstart| Pstop |
    -----------------------------------------------------------------------------------------------------------
    |   0 | SELECT STATEMENT              |           |       |       | 86646 (100)|          |       |       |
    |   1 |  SORT AGGREGATE               |           |     1 |    44 |            |          |       |       |
    |*  2 |   HASH JOIN                   |           | 24932 |  1071K| 86646   (1)| 00:00:04 |       |       |
    |   3 |    PART JOIN FILTER CREATE    | :BF0000   |     1 |    27 |     7   (0)| 00:00:01 |       |       |
    |*  4 |     TABLE ACCESS FULL         | DATE_DIM  |     1 |    27 |     7   (0)| 00:00:01 |       |       |
    |   5 |    PARTITION RANGE JOIN-FILTER|           |    41M|   677M| 86498   (1)| 00:00:04 |:BF0000|:BF0000|
    |   6 |     TABLE ACCESS FULL         | LINEORDER |    41M|   677M| 86498   (1)| 00:00:04 |:BF0000|:BF0000|
    -----------------------------------------------------------------------------------------------------------

    Predicate Information (identified by operation id):
    ---------------------------------------------------

       2 - access("L"."LO_ORDERDATE"="D"."D_DATEKEY")
       4 - filter("D"."D_DATE"='December 24, 1996')


    27 rows selected.

    Hit enter ...


    NAME                                                              VALUE
    -------------------------------------------------- --------------------
    CPU used by this session                                             89
    IM scan segments disk                                                 2
    session logical reads                                             69104
    session pga memory                                             19204344

    SQL>
    ```

    You might notice that we added a hint to specify NO\_INMEMORY. This is an easy way to tell the optimizer to not use the IM column store. You might also notice that there is a NO\_VECTOR\_TRANSFORM hint as well. Vector transformation is available when Database In-Memory is enabled, and we will cover its advantages later in this Lab. For now, we have disabled it to make it easier to compare this execution plan with the execution plan from the previous step.

3. Now let’s try a more complex query that encompasses three joins and an aggregation. This time our query will compare the revenue for different product classes, from suppliers in a certain region for the year 1997.

    Run the script *03\_3join\_im.sql*

    ```
    <copy>
    @03_3join_im.sql
    </copy>    
    ```

    or run the query below:

    ```
    <copy>
    set timing on
    SELECT /*+ NO_VECTOR_TRANSFORM */
       d.d_year, p.p_brand1,SUM(lo_revenue) rev
    FROM lineorder l,
      date_dim d,
      part p,
      supplier s
    WHERE  l.lo_orderdate = d.d_datekey
    AND    l.lo_partkey = p.p_partkey
    AND    l.lo_suppkey = s.s_suppkey
    AND    p.p_category = 'MFGR#12'
    AND    s.s_region   = 'AMERICA'
    AND    d.d_year     = 1997
    GROUP  BY d.d_year,p.p_brand1;
    set timing off
    select * from table(dbms_xplan.display_cursor());
    @../imstats.sql
    </copy>
    ```

    Query result:

    ```
    SQL> @03_3join_im.sql
    Connected.
    SQL>
    SQL> -- Demonstrate an in-memory join query
    SQL>
    SQL> SELECT /*+ NO_VECTOR_TRANSFORM */
      2        d.d_year, p.p_brand1,SUM(lo_revenue) rev
      3  FROM   lineorder l,
      4         date_dim d,
      5         part p,
      6         supplier s
      7  WHERE  l.lo_orderdate = d.d_datekey
      8  AND    l.lo_partkey = p.p_partkey
      9  AND    l.lo_suppkey = s.s_suppkey
     10  AND    p.p_category = 'MFGR#12'
     11  AND    s.s_region   = 'AMERICA'
     12  AND    d.d_year     = 1997
     13  GROUP  BY d.d_year,p.p_brand1;

              D_YEAR P_BRAND1               REV
    ---------------- --------- ----------------
                1997 MFGR#128        6597639363
                1997 MFGR#126        6213627043
                1997 MFGR#1214       6630127600
                1997 MFGR#1234       6695984533
                1997 MFGR#122        7101221796
                1997 MFGR#1217       7053041453
                1997 MFGR#1221       6892277556
                1997 MFGR#127        6765391794
                1997 MFGR#1230       6596531127
                1997 MFGR#1211       6852509575
                1997 MFGR#1225       6804217225
                1997 MFGR#1231       6839363437
                1997 MFGR#1213       6686343443
                1997 MFGR#1232       7404918843
                1997 MFGR#1227       6713851455
                1997 MFGR#1220       6613283998
                1997 MFGR#1219       6651946261
                1997 MFGR#1237       7041724061
                1997 MFGR#1218       6841323272
                1997 MFGR#1210       6795372926
                1997 MFGR#123        6280463233
                1997 MFGR#121        6409702180
                1997 MFGR#1240       7056019394
                1997 MFGR#1215       7079477060
                1997 MFGR#124        6817087386
                1997 MFGR#1224       7373166413
                1997 MFGR#1212       6573951551
                1997 MFGR#1233       6914572704
                1997 MFGR#129        6164317597
                1997 MFGR#1223       6465041111
                1997 MFGR#1236       6827320374
                1997 MFGR#1238       6443513085
                1997 MFGR#1228       7038686432
                1997 MFGR#1235       7075150948
                1997 MFGR#1239       6227318243
                1997 MFGR#1216       6877592440
                1997 MFGR#125        6416763567
                1997 MFGR#1229       6481227038
                1997 MFGR#1222       6551372899
                1997 MFGR#1226       7185780867

    40 rows selected.

    Elapsed: 00:00:00.24
    SQL>
    SQL> set echo off
    Hit enter ...


    PLAN_TABLE_OUTPUT
    ------------------------------------------------------------------------------------------------------------------------------------------------------
    SQL_ID  6ygn2wqbv5syt, child number 0
    -------------------------------------
    SELECT /*+ NO_VECTOR_TRANSFORM */       d.d_year,
    p.p_brand1,SUM(lo_revenue) rev FROM   lineorder l,        date_dim d,
         part p,        supplier s WHERE  l.lo_orderdate = d.d_datekey AND
      l.lo_partkey = p.p_partkey AND    l.lo_suppkey = s.s_suppkey AND
    p.p_category = 'MFGR#12' AND    s.s_region   = 'AMERICA' AND
    d.d_year     = 1997 GROUP  BY d.d_year,p.p_brand1

    Plan hash value: 4224806115

    ----------------------------------------------------------------------------------------------------------------
    | Id  | Operation                          | Name      | Rows  | Bytes | Cost (%CPU)| Time     | Pstart| Pstop |
    ----------------------------------------------------------------------------------------------------------------
    |   0 | SELECT STATEMENT                   |           |       |       |  4140 (100)|          |       |       |
    |   1 |  HASH GROUP BY                     |           |  1000 | 77000 |  4140  (21)| 00:00:01 |       |       |
    |*  2 |   HASH JOIN                        |           | 98430 |  7401K|  4136  (21)| 00:00:01 |       |       |
    |   3 |    JOIN FILTER CREATE              | :BF0001   |   365 |  4380 |     1   (0)| 00:00:01 |       |       |
    |   4 |     PART JOIN FILTER CREATE        | :BF0000   |   365 |  4380 |     1   (0)| 00:00:01 |       |       |
    |*  5 |      TABLE ACCESS INMEMORY FULL    | DATE_DIM  |   365 |  4380 |     1   (0)| 00:00:01 |       |       |
    |*  6 |    HASH JOIN                       |           |   451K|    28M|  4134  (21)| 00:00:01 |       |       |
    |   7 |     JOIN FILTER CREATE             | :BF0002   |  4102 | 73836 |     3   (0)| 00:00:01 |       |       |
    |*  8 |      TABLE ACCESS INMEMORY FULL    | SUPPLIER  |  4102 | 73836 |     3   (0)| 00:00:01 |       |       |
    |*  9 |     HASH JOIN                      |           |  2216K|    99M|  4123  (21)| 00:00:01 |       |       |
    |  10 |      JOIN FILTER CREATE            | :BF0003   | 31882 |   716K|    87  (19)| 00:00:01 |       |       |
    |* 11 |       TABLE ACCESS INMEMORY FULL   | PART      | 31882 |   716K|    87  (19)| 00:00:01 |       |       |
    |  12 |      JOIN FILTER USE               | :BF0001   |    41M|   955M|  3895  (18)| 00:00:01 |       |       |
    |  13 |       JOIN FILTER USE              | :BF0002   |    41M|   955M|  3895  (18)| 00:00:01 |       |       |
    |  14 |        JOIN FILTER USE             | :BF0003   |    41M|   955M|  3895  (18)| 00:00:01 |       |       |
    |  15 |         PARTITION RANGE JOIN-FILTER|           |    41M|   955M|  3895  (18)| 00:00:01 |:BF0000|:BF0000|
    |* 16 |          TABLE ACCESS INMEMORY FULL| LINEORDER |    41M|   955M|  3895  (18)| 00:00:01 |:BF0000|:BF0000|
    ----------------------------------------------------------------------------------------------------------------

    Predicate Information (identified by operation id):
    ---------------------------------------------------

       2 - access("L"."LO_ORDERDATE"="D"."D_DATEKEY")
       5 - inmemory("D"."D_YEAR"=1997)
           filter("D"."D_YEAR"=1997)
       6 - access("L"."LO_SUPPKEY"="S"."S_SUPPKEY")
       8 - inmemory("S"."S_REGION"='AMERICA')
           filter("S"."S_REGION"='AMERICA')
       9 - access("L"."LO_PARTKEY"="P"."P_PARTKEY")
      11 - inmemory("P"."P_CATEGORY"='MFGR#12')
           filter("P"."P_CATEGORY"='MFGR#12')
      16 - inmemory(SYS_OP_BLOOM_FILTER_LIST(SYS_OP_BLOOM_FILTER(:BF0003,"L"."LO_PARTKEY"),SYS_OP_BLOOM_FILT
                  ER(:BF0002,"L"."LO_SUPPKEY"),SYS_OP_BLOOM_FILTER(:BF0001,"L"."LO_ORDERDATE")))
           filter(SYS_OP_BLOOM_FILTER_LIST(SYS_OP_BLOOM_FILTER(:BF0003,"L"."LO_PARTKEY"),SYS_OP_BLOOM_FILTER
                  (:BF0002,"L"."LO_SUPPKEY"),SYS_OP_BLOOM_FILTER(:BF0001,"L"."LO_ORDERDATE")))


    50 rows selected.

    Hit enter ...


    NAME                                                              VALUE
    -------------------------------------------------- --------------------
    CPU used by this session                                             27
    IM scan CUs columns accessed                                         78
    IM scan CUs memcompress for query low                                21
    IM scan rows                                                    9920979
    IM scan rows projected                                           259319
    IM scan rows valid                                              9920979
    IM scan segments minmax eligible                                     21
    physical reads                                                        1
    session logical reads                                             76107
    session logical reads - IM                                        75940
    session pga memory                                             19335416
    table scans (IM)                                                      4

    12 rows selected.

    SQL>
    ```

    In this query, three Bloom filters have been created and applied to the scan of the LINEORDER table, one for the join to the DATE\_DIM table, one for the join to the PART table, and one for the join to the SUPPLIER table. How is Oracle able to apply three Bloom filters when normally a  join only involves two tables at a time?

    This is where Oracle’s 30 plus years of database innovation kick in. By embedding the column store into Oracle Database we can take advantage of all of the optimizations that have been added to the database. In this case, the Optimizer has switched from its typical left deep tree execution to a right deep tree execution plan using an optimization called ‘swap\_join\_inputs’. What this means for the IM column store is that we are able to generate multiple Bloom filters by scanning the three "dimension" tables before we scan the necessary columns in the "fact" table, meaning we are able to benefit by eliminating rows during the scan rather than waiting for the join to do it.


4. Now let’s execute the same query using the buffer cache.

    Run the script *04\_3join\_buffer.sql*

    ```
    <copy>
    @04_3join_buffer.sql
    </copy>    
    ```

    or run the query below:

    ```
    <copy>
    set timing on
    alter session set inmemory_query = disable;
    SELECT /*+ NO_VECTOR_TRANSFORM */
      d.d_year, p.p_brand1,SUM(lo_revenue) rev
    FROM lineorder l,
         date_dim d,
         part p,
         supplier s
    WHERE l.lo_orderdate = d.d_datekey
    AND   l.lo_partkey = p.p_partkey
    AND   l.lo_suppkey = s.s_suppkey
    AND   p.p_category = 'MFGR#12'
    AND   s.s_region   = 'AMERICA'
    AND   d.d_year     = 1997
    GROUP BY d.d_year,p.p_brand1;
    set timing off
    select * from table(dbms_xplan.display_cursor());
    @../imstats.sql
    </copy>
    ```

    Query result:

    ```
    SQL> @04_3join_buffer.sql
    Connected.
    SQL>
    SQL> alter session set inmemory_query = disable;

    Session altered.

    Elapsed: 00:00:00.00
    SQL>
    SQL> -- Demonstrate a buffer cache three way join query
    SQL>
    SQL> SELECT /*+ NO_VECTOR_TRANSFORM */
      2        d.d_year, p.p_brand1,SUM(lo_revenue) rev
      3  FROM   lineorder l,
      4         date_dim d,
      5         part p,
      6         supplier s
      7  WHERE  l.lo_orderdate = d.d_datekey
      8  AND    l.lo_partkey = p.p_partkey
      9  AND    l.lo_suppkey = s.s_suppkey
     10  AND    p.p_category = 'MFGR#12'
     11  AND    s.s_region   = 'AMERICA'
     12  AND    d.d_year     = 1997
     13  GROUP  BY d.d_year,p.p_brand1;

              D_YEAR P_BRAND1               REV
    ---------------- --------- ----------------
                1997 MFGR#128        6597639363
                1997 MFGR#126        6213627043
                1997 MFGR#1214       6630127600
                1997 MFGR#1234       6695984533
                1997 MFGR#122        7101221796
                1997 MFGR#1217       7053041453
                1997 MFGR#1221       6892277556
                1997 MFGR#127        6765391794
                1997 MFGR#1230       6596531127
                1997 MFGR#1211       6852509575
                1997 MFGR#1225       6804217225
                1997 MFGR#1231       6839363437
                1997 MFGR#1213       6686343443
                1997 MFGR#1232       7404918843
                1997 MFGR#1227       6713851455
                1997 MFGR#1220       6613283998
                1997 MFGR#1219       6651946261
                1997 MFGR#1237       7041724061
                1997 MFGR#1218       6841323272
                1997 MFGR#1210       6795372926
                1997 MFGR#123        6280463233
                1997 MFGR#121        6409702180
                1997 MFGR#1240       7056019394
                1997 MFGR#1215       7079477060
                1997 MFGR#124        6817087386
                1997 MFGR#1224       7373166413
                1997 MFGR#1212       6573951551
                1997 MFGR#1233       6914572704
                1997 MFGR#129        6164317597
                1997 MFGR#1223       6465041111
                1997 MFGR#1236       6827320374
                1997 MFGR#1238       6443513085
                1997 MFGR#1228       7038686432
                1997 MFGR#1235       7075150948
                1997 MFGR#1239       6227318243
                1997 MFGR#1216       6877592440
                1997 MFGR#125        6416763567
                1997 MFGR#1229       6481227038
                1997 MFGR#1222       6551372899
                1997 MFGR#1226       7185780867

    40 rows selected.

    Elapsed: 00:00:01.26
    SQL>
    SQL> set echo off
    Hit enter ...


    PLAN_TABLE_OUTPUT
    ------------------------------------------------------------------------------------------------------------------------------------------------------
    SQL_ID  6ygn2wqbv5syt, child number 1
    -------------------------------------
    SELECT /*+ NO_VECTOR_TRANSFORM */       d.d_year,
    p.p_brand1,SUM(lo_revenue) rev FROM   lineorder l,        date_dim d,
         part p,        supplier s WHERE  l.lo_orderdate = d.d_datekey AND
      l.lo_partkey = p.p_partkey AND    l.lo_suppkey = s.s_suppkey AND
    p.p_category = 'MFGR#12' AND    s.s_region   = 'AMERICA' AND
    d.d_year     = 1997 GROUP  BY d.d_year,p.p_brand1

    Plan hash value: 3074123985

    -------------------------------------------------------------------------------------------------------------
    | Id  | Operation                       | Name      | Rows  | Bytes | Cost (%CPU)| Time     | Pstart| Pstop |
    -------------------------------------------------------------------------------------------------------------
    |   0 | SELECT STATEMENT                |           |       |       | 88663 (100)|          |       |       |
    |   1 |  HASH GROUP BY                  |           |  1000 | 77000 | 88663   (1)| 00:00:04 |       |       |
    |*  2 |   HASH JOIN                     |           | 98430 |  7401K| 88659   (1)| 00:00:04 |       |       |
    |   3 |    PART JOIN FILTER CREATE      | :BF0000   |   365 |  4380 |     7   (0)| 00:00:01 |       |       |
    |*  4 |     TABLE ACCESS FULL           | DATE_DIM  |   365 |  4380 |     7   (0)| 00:00:01 |       |       |
    |*  5 |    HASH JOIN                    |           |   451K|    28M| 88651   (1)| 00:00:04 |       |       |
    |*  6 |     TABLE ACCESS FULL           | SUPPLIER  |  4102 | 73836 |    69   (0)| 00:00:01 |       |       |
    |*  7 |     HASH JOIN                   |           |  2216K|    99M| 88574   (1)| 00:00:04 |       |       |
    |*  8 |      TABLE ACCESS FULL          | PART      | 31882 |   716K|  1906   (1)| 00:00:01 |       |       |
    |   9 |      PARTITION RANGE JOIN-FILTER|           |    41M|   955M| 86526   (1)| 00:00:04 |:BF0000|:BF0000|
    |  10 |       TABLE ACCESS FULL         | LINEORDER |    41M|   955M| 86526   (1)| 00:00:04 |:BF0000|:BF0000|
    -------------------------------------------------------------------------------------------------------------

    Predicate Information (identified by operation id):
    ---------------------------------------------------

       2 - access("L"."LO_ORDERDATE"="D"."D_DATEKEY")
       4 - filter("D"."D_YEAR"=1997)
       5 - access("L"."LO_SUPPKEY"="S"."S_SUPPKEY")
       6 - filter("S"."S_REGION"='AMERICA')
       7 - access("L"."LO_PARTKEY"="P"."P_PARTKEY")
       8 - filter("P"."P_CATEGORY"='MFGR#12')


    37 rows selected.

    Hit enter ...


    NAME                                                              VALUE
    -------------------------------------------------- --------------------
    CPU used by this session                                            144
    IM scan segments disk                                                 4
    session logical reads                                             78647
    session pga memory                                             20318456

    SQL>
    ```

    As you can see, the IM column store continues to out-perform the buffer cache query.

5. Up until this point we have only seen hash joins used with our in-memory queries. While it is true that hash joins are a further optimization with Database In-Memory and it's ability to use Bloom filters to effectively perform the join as a scan and filter operation, but what about a nested loops join? Is it possible for Database In-Memory to work with a nested loops join? Perhaps one table is not in memory or an index access will have less cost. Let's see how that might work.

    Run the script *05\_join\_nl\_im.sql*

    ```
    <copy>
    @05_join_nl_im.sql
    </copy>    
    ```

    or run the query below:

    ```
    <copy>
    set timing on
    -- Enable the use of invisible indexes
    alter session set optimizer_use_invisible_indexes=true;
    -- Execute query
    select /*+ NO_VECTOR_TRANSFORM INDEX(l, lineorder_i1) */
       sum(lo_extendedprice * lo_discount) revenue
    from   LINEORDER l, DATE_DIM d
    where  l.lo_orderdate = d.d_datekey
    and    d.d_date='December 24, 1996';
    set timing off
    select * from table(dbms_xplan.display_cursor());
    @../imstats.sql
    </copy>
    ```

    Query result:

    ```
    SQL> @05_join_nl_im.sql
    Connected.
    SQL>
    SQL> -- Show the use of in-memory with a Nested Loops join
    SQL>
    SQL> -- Enable the use of invisible indexes
    SQL>
    SQL> alter session set optimizer_use_invisible_indexes=true;

    Session altered.

    SQL>
    SQL> -- Execute query
    SQL>
    SQL> set timing on
    SQL>
    SQL> select /*+ NO_VECTOR_TRANSFORM INDEX(l, lineorder_i1) */
      2         sum(lo_extendedprice * lo_discount) revenue
      3  from   LINEORDER l, DATE_DIM d
      4  where  l.lo_orderdate = d.d_datekey
      5  and    d.d_date='December 24, 1996';

                 REVENUE
    --------------------
            467915827233

    Elapsed: 00:00:00.07
    SQL>
    SQL> set timing off
    SQL>
    SQL> pause Hit enter ...
    Hit enter ...

    SQL>
    SQL> select * from table(dbms_xplan.display_cursor());

    PLAN_TABLE_OUTPUT
    ------------------------------------------------------------------------------------------------------------------------------------------------------
    SQL_ID  9qr4mbmr1jyx2, child number 0
    -------------------------------------
    select /*+ NO_VECTOR_TRANSFORM INDEX(l, lineorder_i1) */
    sum(lo_extendedprice * lo_discount) revenue from   LINEORDER l,
    DATE_DIM d where  l.lo_orderdate = d.d_datekey and
    d.d_date='December 24, 1996'

    Plan hash value: 48534443

    --------------------------------------------------------------------------------------------------------------------
    | Id  | Operation                           | Name         | Rows  | Bytes | Cost (%CPU)| Time     | Pstart| Pstop |
    --------------------------------------------------------------------------------------------------------------------
    |   0 | SELECT STATEMENT                    |              |       |       |  6133 (100)|          |       |       |
    |   1 |  SORT AGGREGATE                     |              |     1 |    44 |            |          |       |       |
    |   2 |   NESTED LOOPS                      |              | 24932 |  1071K|  6133   (1)| 00:00:01 |       |       |
    |   3 |    NESTED LOOPS                     |              | 24932 |  1071K|  6133   (1)| 00:00:01 |       |       |
    |*  4 |     TABLE ACCESS INMEMORY FULL      | DATE_DIM     |     1 |    27 |     1   (0)| 00:00:01 |       |       |
    |   5 |     PARTITION RANGE ITERATOR        |              | 24932 |       |    65   (0)| 00:00:01 |   KEY |   KEY |
    |*  6 |      INDEX RANGE SCAN               | LINEORDER_I1 | 24932 |       |    65   (0)| 00:00:01 |   KEY |   KEY |
    |   7 |    TABLE ACCESS BY LOCAL INDEX ROWID| LINEORDER    | 24932 |   413K|  6132   (1)| 00:00:01 |     1 |     1 |
    --------------------------------------------------------------------------------------------------------------------

    Predicate Information (identified by operation id):
    ---------------------------------------------------

       4 - inmemory("D"."D_DATE"='December 24, 1996')
           filter("D"."D_DATE"='December 24, 1996')
       6 - access("L"."LO_ORDERDATE"="D"."D_DATEKEY")

    Note
    -----
       - this is an adaptive plan


    33 rows selected.

    SQL>
    SQL> alter session set optimizer_use_invisible_indexes=false;

    Session altered.

    SQL>
    ```

    Notice that we have told the optimizer that it can use invisible indexes and we just happen to have an index that can be used on the LINEORDER table. This results in the optimizer choosing to perform a nested loops join by first accessing the DATE\_DIM table in-memory and then accessing the LINEORDER table through an index. The optimizer chooses this join, rather than a hash join, based on cost. This is another big advantage with Database In-Memory, the ability of the optimizer to choose the lowest cost methods to run queries with or without accessing object in-memory.


6. Up until this point we have been focused on joins and how the IM column store can execute them incredibly efficiently. Let’s now turn our attention to more OLAP style “What If” queries.  In this case our query examines the yearly profits from a specific region and manufacturer over our complete data set.

    Oracle has introduced a new optimizer transformation, called vector transformation. This is also known as In-Memory Aggregation and results in a new group by method called Vector Group By. This transformation is a two-part process not dissimilar to that of star transformation.  First, the dimension tables are scanned and any WHERE clause predicates are applied. A new data structure called a key vector is created based on the results of these scans. The key vector is similar to a Bloom filter as it allows the join predicates to be applied as additional filter predicates during the scan of the fact table, but it also enables us to conduct the group by or aggregation during the scan of the fact table instead of having to do it afterwards.

    The second part of the execution plan sees the results of the fact table scan being joined back to the temporary tables created as part of the scan of the dimension tables, that is defined by the lines that start with LOAD AS SELECT. These temporary tables contain the payload columns (columns needed in the select list) from the dimension table(s). In Release 12.2 and above these tables are now pure in-memory tables as evidenced by the addition of the (CURSOR DURATION MEMORY) phrase that is appended to the LOAD AS SELECT phrases. The combination of these two features dramatically improves the efficiency of a multiple table join with complex aggregations. Both features are visible in the execution plan of our queries.

    To see this in action execute the query *06\_vgb\_im.sql*

    ```
    <copy>
    @06_vgb_im.sql
    </copy>    
    ```

    or run the query below:     

    ```
    <copy>
    set timing on
    SELECT
      d.d_year, c.c_nation, sum(lo_revenue - lo_supplycost) profit
    from
      LINEORDER l, DATE_DIM d, PART p, SUPPLIER s, CUSTOMER C
    where
      l.lo_orderdate = d.d_datekey
      and l.lo_partkey = p.p_partkey
      and l.lo_suppkey = s.s_suppkey
      and l.lo_custkey = c.c_custkey
      and s.s_region = 'AMERICA'
      and c.c_region = 'AMERICA'
    group by
          d.d_year, c.c_nation
    order by
      d.d_year, c.c_nation;
    set timing off
    select * from table(dbms_xplan.display_cursor());
    </copy>
    ```

    Query result:

    ```
    SQL> @06_vgb_im.sql
    Connected.
    SQL> set numwidth 20
    SQL>
    SQL> -- In-Memory query with In-Memory Aggregation enabled
    SQL>
    SQL> select d.d_year, c.c_nation, sum(lo_revenue - lo_supplycost) profit
      2  from   LINEORDER l, DATE_DIM d, PART p, SUPPLIER s, CUSTOMER C
      3  where  l.lo_orderdate = d.d_datekey
      4  and    l.lo_partkey   = p.p_partkey
      5  and    l.lo_suppkey   = s.s_suppkey
      6  and    l.lo_custkey   = c.c_custkey
      7  and    s.s_region     = 'AMERICA'
      8  and    c.c_region     = 'AMERICA'
      9  group by d.d_year, c.c_nation
     10  order by d.d_year, c.c_nation;

                  D_YEAR C_NATION                      PROFIT
    -------------------- --------------- --------------------
                    1994 ARGENTINA               261149015641
                    1994 BRAZIL                  263808033983
                    1994 CANADA                  264598150413
                    1994 PERU                    258595600981
                    1994 UNITED STATES           265282504206
                    1995 ARGENTINA               258498976118
                    1995 BRAZIL                  269135848643
                    1995 CANADA                  264654265482
                    1995 PERU                    257451709833
                    1995 UNITED STATES           259660457396
                    1996 ARGENTINA               259361903850
                    1996 BRAZIL                  265970119048
                    1996 CANADA                  265333193889
                    1996 PERU                    260916013039
                    1996 UNITED STATES           262339293224
                    1997 ARGENTINA               261099548066
                    1997 BRAZIL                  266353055971
                    1997 CANADA                  265036379243
                    1997 PERU                    259114682243
                    1997 UNITED STATES           262208356128
                    1998 ARGENTINA               151054449013
                    1998 BRAZIL                  153632348378
                    1998 CANADA                  156899052279
                    1998 PERU                    152297126350
                    1998 UNITED STATES           153937088695

    25 rows selected.

    Elapsed: 00:00:00.73
    SQL>
    SQL> set echo off
    Hit enter ...


    PLAN_TABLE_OUTPUT
    ------------------------------------------------------------------------------------------------------------------------------------------------------
    SQL_ID  c3f4u823f89t3, child number 0
    -------------------------------------
    select d.d_year, c.c_nation, sum(lo_revenue - lo_supplycost) profit
    from   LINEORDER l, DATE_DIM d, PART p, SUPPLIER s, CUSTOMER C where
    l.lo_orderdate = d.d_datekey and    l.lo_partkey   = p.p_partkey and
    l.lo_suppkey   = s.s_suppkey and    l.lo_custkey   = c.c_custkey and
    s.s_region     = 'AMERICA' and    c.c_region     = 'AMERICA' group by
    d.d_year, c.c_nation order by d.d_year, c.c_nation

    Plan hash value: 3030148494

    ---------------------------------------------------------------------------------------------------------------------------------------
    | Id  | Operation                                | Name                       | Rows  | Bytes | Cost (%CPU)| Time     | Pstart| Pstop |
    ---------------------------------------------------------------------------------------------------------------------------------------
    |   0 | SELECT STATEMENT                         |                            |       |       |  4336 (100)|          |       |       |
    |   1 |  TEMP TABLE TRANSFORMATION               |                            |       |       |            |          |       |       |
    |   2 |   LOAD AS SELECT (CURSOR DURATION MEMORY)| SYS_TEMP_0FD9D666C_2308E0F |       |       |            |          |       |       |
    |   3 |    HASH GROUP BY                         |                            |     7 |   112 |     2  (50)| 00:00:01 |       |       |
    |   4 |     KEY VECTOR CREATE BUFFERED           | :KV0000                    |     7 |   112 |     1   (0)| 00:00:01 |       |       |
    |   5 |      TABLE ACCESS INMEMORY FULL          | DATE_DIM                   |  2556 | 30672 |     1   (0)| 00:00:01 |       |       |
    |   6 |   LOAD AS SELECT (CURSOR DURATION MEMORY)| SYS_TEMP_0FD9D6669_2308E0F |       |       |            |          |       |       |
    |   7 |    HASH GROUP BY                         |                            |     1 |     9 |   101  (30)| 00:00:01 |       |       |
    |   8 |     KEY VECTOR CREATE BUFFERED           | :KV0001                    |     1 |     9 |    76   (7)| 00:00:01 |       |       |
    |   9 |      TABLE ACCESS INMEMORY FULL          | PART                       |   800K|  3906K|    75   (6)| 00:00:01 |       |       |
    |  10 |   LOAD AS SELECT (CURSOR DURATION MEMORY)| SYS_TEMP_0FD9D666A_2308E0F |       |       |            |          |       |       |
    |  11 |    HASH GROUP BY                         |                            |     1 |    22 |     4  (25)| 00:00:01 |       |       |
    |  12 |     KEY VECTOR CREATE BUFFERED           | :KV0002                    |     1 |    22 |     3   (0)| 00:00:01 |       |       |
    |* 13 |      TABLE ACCESS INMEMORY FULL          | SUPPLIER                   |  4102 | 73836 |     3   (0)| 00:00:01 |       |       |
    |  14 |   LOAD AS SELECT (CURSOR DURATION MEMORY)| SYS_TEMP_0FD9D666B_2308E0F |       |       |            |          |       |       |
    |  15 |    HASH GROUP BY                         |                            |    25 |   950 |    40  (23)| 00:00:01 |       |       |
    |  16 |     KEY VECTOR CREATE BUFFERED           | :KV0003                    |    25 |   950 |    37  (17)| 00:00:01 |       |       |
    |* 17 |      TABLE ACCESS INMEMORY FULL          | CUSTOMER                   | 59761 |  1984K|    37  (17)| 00:00:01 |       |       |
    |  18 |   SORT GROUP BY                          |                            |    62 |  6510 |  4189  (24)| 00:00:01 |       |       |
    |* 19 |    HASH JOIN                             |                            |    62 |  6510 |  4188  (24)| 00:00:01 |       |       |
    |* 20 |     HASH JOIN                            |                            |    62 |  4712 |  4186  (24)| 00:00:01 |       |       |
    |  21 |      MERGE JOIN CARTESIAN                |                            |     7 |   329 |     6   (0)| 00:00:01 |       |       |
    |  22 |       MERGE JOIN CARTESIAN               |                            |     1 |    31 |     4   (0)| 00:00:01 |       |       |
    |  23 |        TABLE ACCESS FULL                 | SYS_TEMP_0FD9D6669_2308E0F |     1 |     9 |     2   (0)| 00:00:01 |       |       |
    |  24 |        BUFFER SORT                       |                            |     1 |    22 |     2   (0)| 00:00:01 |       |       |
    |  25 |         TABLE ACCESS FULL                | SYS_TEMP_0FD9D666A_2308E0F |     1 |    22 |     2   (0)| 00:00:01 |       |       |
    |  26 |       BUFFER SORT                        |                            |     7 |   112 |     4   (0)| 00:00:01 |       |       |
    |  27 |        TABLE ACCESS FULL                 | SYS_TEMP_0FD9D666C_2308E0F |     7 |   112 |     2   (0)| 00:00:01 |       |       |
    |  28 |      VIEW                                | VW_VT_80F21617             |    62 |  1798 |  4180  (24)| 00:00:01 |       |       |
    |  29 |       VECTOR GROUP BY                    |                            |    62 |  3100 |  4180  (24)| 00:00:01 |       |       |
    |  30 |        HASH GROUP BY                     |                            |    62 |  3100 |  4180  (24)| 00:00:01 |       |       |
    |  31 |         KEY VECTOR USE                   | :KV0000                    |  2535K|   120M|  4178  (24)| 00:00:01 |       |       |
    |  32 |          KEY VECTOR USE                  | :KV0001                    |  2535K|   111M|  4178  (24)| 00:00:01 |       |       |
    |  33 |           KEY VECTOR USE                 | :KV0003                    |  2535K|   101M|  4178  (24)| 00:00:01 |       |       |
    |  34 |            KEY VECTOR USE                | :KV0002                    |  8510K|   308M|  4178  (24)| 00:00:01 |       |       |
    |  35 |             PARTITION RANGE ITERATOR     |                            |    41M|  1354M|  4177  (24)| 00:00:01 |:KV0000|:KV0000|
    |* 36 |              TABLE ACCESS INMEMORY FULL  | LINEORDER                  |    41M|  1354M|  4177  (24)| 00:00:01 |:KV0000|:KV0000|
    |  37 |     TABLE ACCESS FULL                    | SYS_TEMP_0FD9D666B_2308E0F |    25 |   725 |     2   (0)| 00:00:01 |       |       |
    ---------------------------------------------------------------------------------------------------------------------------------------

    Predicate Information (identified by operation id):
    ---------------------------------------------------

      13 - inmemory("S"."S_REGION"='AMERICA')
           filter("S"."S_REGION"='AMERICA')
      17 - inmemory("C"."C_REGION"='AMERICA')
           filter("C"."C_REGION"='AMERICA')
      19 - access("ITEM_14"=INTERNAL_FUNCTION("C0"))
      20 - access("ITEM_12"=INTERNAL_FUNCTION("C0") AND "ITEM_13"=INTERNAL_FUNCTION("C0") AND "ITEM_15"=INTERNAL_FUNCTION("C0"))
      36 - inmemory((SYS_OP_KEY_VECTOR_FILTER("L"."LO_SUPPKEY",:KV0002) AND SYS_OP_KEY_VECTOR_FILTER("L"."LO_CUSTKEY",:KV0003) AND
                  SYS_OP_KEY_VECTOR_FILTER("L"."LO_PARTKEY",:KV0001) AND SYS_OP_KEY_VECTOR_FILTER("L"."LO_ORDERDATE",:KV0000)))
           filter((SYS_OP_KEY_VECTOR_FILTER("L"."LO_SUPPKEY",:KV0002) AND SYS_OP_KEY_VECTOR_FILTER("L"."LO_CUSTKEY",:KV0003) AND
                  SYS_OP_KEY_VECTOR_FILTER("L"."LO_PARTKEY",:KV0001) AND SYS_OP_KEY_VECTOR_FILTER("L"."LO_ORDERDATE",:KV0000)))

    Note
    -----
       - vector transformation used for this statement


    72 rows selected.

    SQL>
    ```

    Our query is more complex now and if you look closely at the execution plan you will see the creation and use of :KV000n structures which are the Key Vectors along with the Vector Group By operation.

7. To see how dramatic the difference really is we can run the same query but we will disable the vector group by operation.

    Run the script *07\_novgb\_im.sql*

    ```
    <copy>
    @07_novgb_im.sql
    </copy>    
    ```

    or run the query below:

    ```
    <copy>
    set timing on
    SELECT /*+ NO_VECTOR_TRANSFORM */
      d.d_year, c.c_nation, sum(lo_revenue - lo_supplycost) profit
    from
      LINEORDER l, DATE_DIM d, PART p, SUPPLIER s, CUSTOMER C
    where
      l.lo_orderdate = d.d_datekey
      and l.lo_partkey = p.p_partkey
      and l.lo_suppkey = s.s_suppkey
      and l.lo_custkey = c.c_custkey
      and s.s_region = 'AMERICA'
      and c.c_region = 'AMERICA'
    group by
      d.d_year, c.c_nation
    order by
      d.d_year, c.c_nation;
    set timing off
    select * from table(dbms_xplan.display_cursor());
    </copy>
    ```

    Query result:

    ```
    SQL> @07_novgb_im.sql
    Connected.
    SQL>
    SQL> -- In-Memory query with In-Memory Aggregation disabled
    SQL>
    SQL> SELECT /*+ NO_VECTOR_TRANSFORM */
      2            d.d_year, c.c_nation, sum(lo_revenue - lo_supplycost) profit
      3            From      LINEORDER l, DATE_DIM d, PART p, SUPPLIER s, CUSTOMER C
      4            Where    l.lo_orderdate = d.d_datekey
      5            And        l.lo_partkey       = p.p_partkey
      6            And        l.lo_suppkey      = s.s_suppkey
      7            And        l.lo_custkey        = c.c_custkey
      8            And        s.s_region            = 'AMERICA'
      9            And        c.c_region            = 'AMERICA'
     10            Group by d.d_year, c.c_nation
     11            Order by d.d_year, c.c_nation;

                  D_YEAR C_NATION                      PROFIT
    -------------------- --------------- --------------------
                    1994 ARGENTINA               261149015641
                    1994 BRAZIL                  263808033983
                    1994 CANADA                  264598150413
                    1994 PERU                    258595600981
                    1994 UNITED STATES           265282504206
                    1995 ARGENTINA               258498976118
                    1995 BRAZIL                  269135848643
                    1995 CANADA                  264654265482
                    1995 PERU                    257451709833
                    1995 UNITED STATES           259660457396
                    1996 ARGENTINA               259361903850
                    1996 BRAZIL                  265970119048
                    1996 CANADA                  265333193889
                    1996 PERU                    260916013039
                    1996 UNITED STATES           262339293224
                    1997 ARGENTINA               261099548066
                    1997 BRAZIL                  266353055971
                    1997 CANADA                  265036379243
                    1997 PERU                    259114682243
                    1997 UNITED STATES           262208356128
                    1998 ARGENTINA               151054449013
                    1998 BRAZIL                  153632348378
                    1998 CANADA                  156899052279
                    1998 PERU                    152297126350
                    1998 UNITED STATES           153937088695

    25 rows selected.

    Elapsed: 00:00:01.47
    SQL>
    SQL> set echo off
    Hit enter ...


    PLAN_TABLE_OUTPUT
    ------------------------------------------------------------------------------------------------------------------------------------------------------
    SQL_ID  bgm86vz7ghjsj, child number 0
    -------------------------------------
    SELECT /*+ NO_VECTOR_TRANSFORM */           d.d_year, c.c_nation,
    sum(lo_revenue - lo_supplycost) profit           From      LINEORDER l,
    DATE_DIM d, PART p, SUPPLIER s, CUSTOMER C           Where
    l.lo_orderdate = d.d_datekey           And        l.lo_partkey       =
    p.p_partkey           And        l.lo_suppkey      = s.s_suppkey
       And        l.lo_custkey        = c.c_custkey           And
    s.s_region            = 'AMERICA'           And        c.c_region
         = 'AMERICA'           Group by d.d_year, c.c_nation
    Order by d.d_year, c.c_nation

    Plan hash value: 2398965824

    ------------------------------------------------------------------------------------------------------------------------
    | Id  | Operation                          | Name      | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     | Pstart| Pstop |
    ------------------------------------------------------------------------------------------------------------------------
    |   0 | SELECT STATEMENT                   |           |       |       |       | 42874 (100)|          |       |       |
    |   1 |  SORT GROUP BY                     |           |   124 | 12772 |       | 42874   (4)| 00:00:02 |       |       |
    |*  2 |   HASH JOIN                        |           |  2535K|   249M|       | 42791   (3)| 00:00:02 |       |       |
    |   3 |    PART JOIN FILTER CREATE         | :BF0000   |  2556 | 30672 |       |     1   (0)| 00:00:01 |       |       |
    |   4 |     TABLE ACCESS INMEMORY FULL     | DATE_DIM  |  2556 | 30672 |       |     1   (0)| 00:00:01 |       |       |
    |*  5 |    HASH JOIN                       |           |  2535K|   220M|    12M| 42782   (3)| 00:00:02 |       |       |
    |   6 |     TABLE ACCESS INMEMORY FULL     | PART      |   800K|  3906K|       |    75   (6)| 00:00:01 |       |       |
    |*  7 |     HASH JOIN                      |           |  2535K|   207M|  2688K| 30295   (4)| 00:00:02 |       |       |
    |   8 |      JOIN FILTER CREATE            | :BF0001   | 59761 |  1984K|       |    37  (17)| 00:00:01 |       |       |
    |*  9 |       TABLE ACCESS INMEMORY FULL   | CUSTOMER  | 59761 |  1984K|       |    37  (17)| 00:00:01 |       |       |
    |* 10 |      HASH JOIN                     |           |  8510K|   422M|       |  4321  (26)| 00:00:01 |       |       |
    |  11 |       JOIN FILTER CREATE           | :BF0002   |  4102 | 73836 |       |     3   (0)| 00:00:01 |       |       |
    |* 12 |        TABLE ACCESS INMEMORY FULL  | SUPPLIER  |  4102 | 73836 |       |     3   (0)| 00:00:01 |       |       |
    |  13 |       JOIN FILTER USE              | :BF0001   |    41M|  1354M|       |  4177  (24)| 00:00:01 |       |       |
    |  14 |        JOIN FILTER USE             | :BF0002   |    41M|  1354M|       |  4177  (24)| 00:00:01 |       |       |
    |  15 |         PARTITION RANGE JOIN-FILTER|           |    41M|  1354M|       |  4177  (24)| 00:00:01 |:BF0000|:BF0000|
    |* 16 |          TABLE ACCESS INMEMORY FULL| LINEORDER |    41M|  1354M|       |  4177  (24)| 00:00:01 |:BF0000|:BF0000|
    ------------------------------------------------------------------------------------------------------------------------

    Predicate Information (identified by operation id):
    ---------------------------------------------------

       2 - access("L"."LO_ORDERDATE"="D"."D_DATEKEY")
       5 - access("L"."LO_PARTKEY"="P"."P_PARTKEY")
       7 - access("L"."LO_CUSTKEY"="C"."C_CUSTKEY")
       9 - inmemory("C"."C_REGION"='AMERICA')
           filter("C"."C_REGION"='AMERICA')
      10 - access("L"."LO_SUPPKEY"="S"."S_SUPPKEY")
      12 - inmemory("S"."S_REGION"='AMERICA')
           filter("S"."S_REGION"='AMERICA')
      16 - inmemory(SYS_OP_BLOOM_FILTER_LIST(SYS_OP_BLOOM_FILTER(:BF0002,"L"."LO_SUPPKEY"),SYS_OP_BLOOM_FILTER(:BF00
                  01,"L"."LO_CUSTKEY")))
           filter(SYS_OP_BLOOM_FILTER_LIST(SYS_OP_BLOOM_FILTER(:BF0002,"L"."LO_SUPPKEY"),SYS_OP_BLOOM_FILTER(:BF0001
                  ,"L"."LO_CUSTKEY")))


    52 rows selected.

    SQL>
    ```

    Notice how much slower this second query ran even though it still ran in-memory, and even took advantage of Bloom filters. This is why we say that you can expect at least a 3-8x performance improvement with In-Memory Aggregation.

8. As we mentioned earlier, with Database In-Memory enabled the optimizer can even take advantage of vector transformation when the tables are not in-memory. To see this in action execute the same query against the buffer cache.

    Run the script *08\_vgb\_buffer.sql*

    ```
    <copy>
    @08_vgb_buffer.sql
    </copy>    
    ```

    or run the query below:

    ```
    <copy>
    set timing on
    alter session set inmemory_query = disable;
    SELECT
      d.d_year, c.c_nation, sum(lo_revenue - lo_supplycost) profit
    from
      LINEORDER l, DATE_DIM d, PART p, SUPPLIER s, CUSTOMER C
    where
      l.lo_orderdate = d.d_datekey
      and l.lo_partkey = p.p_partkey
      and l.lo_suppkey = s.s_suppkey
      and l.lo_custkey = c.c_custkey
      and s.s_region = 'AMERICA'
      and c.c_region = 'AMERICA'
    group by
      d.d_year, c.c_nation
    order by
      d.d_year, c.c_nation;
    set timing off
    select * from table(dbms_xplan.display_cursor());
    </copy>
    ```

    Query result:

    ```
    SQL> @08_vgb_buffer.sql
    Connected.
    SQL>
    SQL> alter session set inmemory_query = disable;

    Session altered.

    Elapsed: 00:00:00.00
    SQL>
    SQL> -- Query with In-Memory Aggregation enabled and in-memory disabled
    SQL>
    SQL> SELECT
      2            d.d_year, c.c_nation, sum(lo_revenue - lo_supplycost) profit
      3            From      LINEORDER l, DATE_DIM d, PART p, SUPPLIER s, CUSTOMER C
      4            Where    l.lo_orderdate = d.d_datekey
      5            And        l.lo_partkey       = p.p_partkey
      6            And        l.lo_suppkey      = s.s_suppkey
      7            And        l.lo_custkey        = c.c_custkey
      8            And        s.s_region            = 'AMERICA'
      9            And        c.c_region            = 'AMERICA'
     10            Group by d.d_year, c.c_nation
     11            Order by d.d_year, c.c_nation;

                  D_YEAR C_NATION                      PROFIT
    -------------------- --------------- --------------------
                    1994 ARGENTINA               261149015641
                    1994 BRAZIL                  263808033983
                    1994 CANADA                  264598150413
                    1994 PERU                    258595600981
                    1994 UNITED STATES           265282504206
                    1995 ARGENTINA               258498976118
                    1995 BRAZIL                  269135848643
                    1995 CANADA                  264654265482
                    1995 PERU                    257451709833
                    1995 UNITED STATES           259660457396
                    1996 ARGENTINA               259361903850
                    1996 BRAZIL                  265970119048
                    1996 CANADA                  265333193889
                    1996 PERU                    260916013039
                    1996 UNITED STATES           262339293224
                    1997 ARGENTINA               261099548066
                    1997 BRAZIL                  266353055971
                    1997 CANADA                  265036379243
                    1997 PERU                    259114682243
                    1997 UNITED STATES           262208356128
                    1998 ARGENTINA               151054449013
                    1998 BRAZIL                  153632348378
                    1998 CANADA                  156899052279
                    1998 PERU                    152297126350
                    1998 UNITED STATES           153937088695

    25 rows selected.

    Elapsed: 00:00:05.55
    SQL>
    SQL> set echo off
    Hit enter ...


    PLAN_TABLE_OUTPUT
    ------------------------------------------------------------------------------------------------------------------------------------------------------
    SQL_ID  a0x06yzufd67k, child number 0
    -------------------------------------
    SELECT           d.d_year, c.c_nation, sum(lo_revenue - lo_supplycost)
    profit           From      LINEORDER l, DATE_DIM d, PART p, SUPPLIER s,
    CUSTOMER C           Where    l.lo_orderdate = d.d_datekey
    And        l.lo_partkey       = p.p_partkey           And
    l.lo_suppkey      = s.s_suppkey           And        l.lo_custkey
     = c.c_custkey           And        s.s_region            = 'AMERICA'
            And        c.c_region            = 'AMERICA'           Group by
    d.d_year, c.c_nation           Order by d.d_year, c.c_nation

    Plan hash value: 3030148494

    ---------------------------------------------------------------------------------------------------------------------------------------
    | Id  | Operation                                | Name                       | Rows  | Bytes | Cost (%CPU)| Time     | Pstart| Pstop |
    ---------------------------------------------------------------------------------------------------------------------------------------
    |   0 | SELECT STATEMENT                         |                            |       |       | 89412 (100)|          |       |       |
    |   1 |  TEMP TABLE TRANSFORMATION               |                            |       |       |            |          |       |       |
    |   2 |   LOAD AS SELECT (CURSOR DURATION MEMORY)| SYS_TEMP_0FD9D6671_2308E0F |       |       |            |          |       |       |
    |   3 |    HASH GROUP BY                         |                            |     7 |   112 |     8  (13)| 00:00:01 |       |       |
    |   4 |     KEY VECTOR CREATE BUFFERED           | :KV0000                    |     7 |   112 |     7   (0)| 00:00:01 |       |       |
    |   5 |      TABLE ACCESS FULL                   | DATE_DIM                   |  2556 | 30672 |     7   (0)| 00:00:01 |       |       |
    |   6 |   LOAD AS SELECT (CURSOR DURATION MEMORY)| SYS_TEMP_0FD9D666E_2308E0F |       |       |            |          |       |       |
    |   7 |    HASH GROUP BY                         |                            |     1 |     9 |  1924   (2)| 00:00:01 |       |       |
    |   8 |     KEY VECTOR CREATE BUFFERED           | :KV0001                    |     1 |     9 |  1899   (1)| 00:00:01 |       |       |
    |   9 |      TABLE ACCESS FULL                   | PART                       |   800K|  3906K|  1898   (1)| 00:00:01 |       |       |
    |  10 |   LOAD AS SELECT (CURSOR DURATION MEMORY)| SYS_TEMP_0FD9D666F_2308E0F |       |       |            |          |       |       |
    |  11 |    HASH GROUP BY                         |                            |     1 |    22 |    70   (2)| 00:00:01 |       |       |
    |  12 |     KEY VECTOR CREATE BUFFERED           | :KV0002                    |     1 |    22 |    69   (0)| 00:00:01 |       |       |
    |* 13 |      TABLE ACCESS FULL                   | SUPPLIER                   |  4102 | 73836 |    69   (0)| 00:00:01 |       |       |
    |  14 |   LOAD AS SELECT (CURSOR DURATION MEMORY)| SYS_TEMP_0FD9D6670_2308E0F |       |       |            |          |       |       |
    |  15 |    HASH GROUP BY                         |                            |    25 |   950 |   843   (1)| 00:00:01 |       |       |
    |  16 |     KEY VECTOR CREATE BUFFERED           | :KV0003                    |    25 |   950 |   841   (1)| 00:00:01 |       |       |
    |* 17 |      TABLE ACCESS FULL                   | CUSTOMER                   | 59761 |  1984K|   841   (1)| 00:00:01 |       |       |
    |  18 |   SORT GROUP BY                          |                            |    62 |  6510 | 86566   (1)| 00:00:04 |       |       |
    |* 19 |    HASH JOIN                             |                            |    62 |  6510 | 86565   (1)| 00:00:04 |       |       |
    |* 20 |     HASH JOIN                            |                            |    62 |  4712 | 86563   (1)| 00:00:04 |       |       |
    |  21 |      MERGE JOIN CARTESIAN                |                            |     7 |   329 |     6   (0)| 00:00:01 |       |       |
    |  22 |       MERGE JOIN CARTESIAN               |                            |     1 |    31 |     4   (0)| 00:00:01 |       |       |
    |  23 |        TABLE ACCESS FULL                 | SYS_TEMP_0FD9D666E_2308E0F |     1 |     9 |     2   (0)| 00:00:01 |       |       |
    |  24 |        BUFFER SORT                       |                            |     1 |    22 |     2   (0)| 00:00:01 |       |       |
    |  25 |         TABLE ACCESS FULL                | SYS_TEMP_0FD9D666F_2308E0F |     1 |    22 |     2   (0)| 00:00:01 |       |       |
    |  26 |       BUFFER SORT                        |                            |     7 |   112 |     4   (0)| 00:00:01 |       |       |
    |  27 |        TABLE ACCESS FULL                 | SYS_TEMP_0FD9D6671_2308E0F |     7 |   112 |     2   (0)| 00:00:01 |       |       |
    |  28 |      VIEW                                | VW_VT_80F21617             |    62 |  1798 | 86557   (1)| 00:00:04 |       |       |
    |  29 |       VECTOR GROUP BY                    |                            |    62 |  3100 | 86557   (1)| 00:00:04 |       |       |
    |  30 |        HASH GROUP BY                     |                            |    62 |  3100 | 86557   (1)| 00:00:04 |       |       |
    |  31 |         KEY VECTOR USE                   | :KV0000                    |  2535K|   120M| 86556   (1)| 00:00:04 |       |       |
    |  32 |          KEY VECTOR USE                  | :KV0001                    |  2535K|   111M| 86556   (1)| 00:00:04 |       |       |
    |  33 |           KEY VECTOR USE                 | :KV0003                    |  2535K|   101M| 86556   (1)| 00:00:04 |       |       |
    |  34 |            KEY VECTOR USE                | :KV0002                    |  8510K|   308M| 86555   (1)| 00:00:04 |       |       |
    |  35 |             PARTITION RANGE ITERATOR     |                            |    41M|  1354M| 86555   (1)| 00:00:04 |:KV0000|:KV0000|
    |* 36 |              TABLE ACCESS FULL           | LINEORDER                  |    41M|  1354M| 86555   (1)| 00:00:04 |:KV0000|:KV0000|
    |  37 |     TABLE ACCESS FULL                    | SYS_TEMP_0FD9D6670_2308E0F |    25 |   725 |     2   (0)| 00:00:01 |       |       |
    ---------------------------------------------------------------------------------------------------------------------------------------

    Predicate Information (identified by operation id):
    ---------------------------------------------------

      13 - filter("S"."S_REGION"='AMERICA')
      17 - filter("C"."C_REGION"='AMERICA')
      19 - access("ITEM_14"=INTERNAL_FUNCTION("C0"))
      20 - access("ITEM_12"=INTERNAL_FUNCTION("C0") AND "ITEM_13"=INTERNAL_FUNCTION("C0") AND "ITEM_15"=INTERNAL_FUNCTION("C0"))
      36 - filter((SYS_OP_KEY_VECTOR_FILTER("L"."LO_SUPPKEY",:KV0002) AND SYS_OP_KEY_VECTOR_FILTER("L"."LO_CUSTKEY",:KV0003) AND
                  SYS_OP_KEY_VECTOR_FILTER("L"."LO_PARTKEY",:KV0001) AND SYS_OP_KEY_VECTOR_FILTER("L"."LO_ORDERDATE",:KV0000)))

    Note
    -----
       - vector transformation used for this statement


    70 rows selected.

    SQL>
    ```

    Note that like hash joins with Bloom filters, vector group by with key vectors can be performed on row-store objects. This only requires that Database In-Memory be enabled and shows just how flexible Database In-Memory is. You don't have to have all objects populated in the IM column store. Of course, the row store objects cannot be accessed as fast as column-store objects and cannot take advantage of all of the other performance features available to IM column store scans.

9. And finally let's take a look at how our query runs in the row-store with no Database In-Memory optimizations.

    Run the script *09\_novgb\_buffer.sql*

    ```
    <copy>
    @09_novgb_buffer.sql
    </copy>    
    ```

    or run the query below:

    ```
    <copy>
    set timing on
    alter session set inmemory_query = disable;
    SELECT /*+ NO_VECTOR_TRANSFORM */
      d.d_year, c.c_nation, sum(lo_revenue - lo_supplycost) profit
    from
      LINEORDER l, DATE_DIM d, PART p, SUPPLIER s, CUSTOMER C
    where
      l.lo_orderdate = d.d_datekey
      and l.lo_partkey = p.p_partkey
      and l.lo_suppkey = s.s_suppkey
      and l.lo_custkey = c.c_custkey
      and s.s_region = 'AMERICA'
      and c.c_region = 'AMERICA'
    group by
      d.d_year, c.c_nation
    order by
    d.d_year, c.c_nation;
    set timing off
    select * from table(dbms_xplan.display_cursor());
    </copy>
    ```

    Query result:

    ```
    SQL> @09_novgb_buffer.sql
    Connected.
    SQL>
    SQL> alter session set inmemory_query = disable;

    Session altered.

    Elapsed: 00:00:00.00
    SQL>
    SQL> -- Query with In-Memory Aggregation enabled and in-memory disabled
    SQL>
    SQL> SELECT /*+ NO_VECTOR_TRANSFORM */
      2            d.d_year, c.c_nation, sum(lo_revenue - lo_supplycost) profit
      3            From      LINEORDER l, DATE_DIM d, PART p, SUPPLIER s, CUSTOMER C
      4            Where    l.lo_orderdate = d.d_datekey
      5            And        l.lo_partkey       = p.p_partkey
      6            And        l.lo_suppkey      = s.s_suppkey
      7            And        l.lo_custkey        = c.c_custkey
      8            And        s.s_region            = 'AMERICA'
      9            And        c.c_region            = 'AMERICA'
     10            Group by d.d_year, c.c_nation
     11            Order by d.d_year, c.c_nation;

                  D_YEAR C_NATION                      PROFIT
    -------------------- --------------- --------------------
                    1994 ARGENTINA               261149015641
                    1994 BRAZIL                  263808033983
                    1994 CANADA                  264598150413
                    1994 PERU                    258595600981
                    1994 UNITED STATES           265282504206
                    1995 ARGENTINA               258498976118
                    1995 BRAZIL                  269135848643
                    1995 CANADA                  264654265482
                    1995 PERU                    257451709833
                    1995 UNITED STATES           259660457396
                    1996 ARGENTINA               259361903850
                    1996 BRAZIL                  265970119048
                    1996 CANADA                  265333193889
                    1996 PERU                    260916013039
                    1996 UNITED STATES           262339293224
                    1997 ARGENTINA               261099548066
                    1997 BRAZIL                  266353055971
                    1997 CANADA                  265036379243
                    1997 PERU                    259114682243
                    1997 UNITED STATES           262208356128
                    1998 ARGENTINA               151054449013
                    1998 BRAZIL                  153632348378
                    1998 CANADA                  156899052279
                    1998 PERU                    152297126350
                    1998 UNITED STATES           153937088695

    25 rows selected.

    Elapsed: 00:00:06.72
    SQL>
    SQL> set echo off
    Hit enter ...


    PLAN_TABLE_OUTPUT
    ------------------------------------------------------------------------------------------------------------------------------------------------------
    SQL_ID  bgm86vz7ghjsj, child number 1
    -------------------------------------
    SELECT /*+ NO_VECTOR_TRANSFORM */           d.d_year, c.c_nation,
    sum(lo_revenue - lo_supplycost) profit           From      LINEORDER l,
    DATE_DIM d, PART p, SUPPLIER s, CUSTOMER C           Where
    l.lo_orderdate = d.d_datekey           And        l.lo_partkey       =
    p.p_partkey           And        l.lo_suppkey      = s.s_suppkey
       And        l.lo_custkey        = c.c_custkey           And
    s.s_region            = 'AMERICA'           And        c.c_region
         = 'AMERICA'           Group by d.d_year, c.c_nation
    Order by d.d_year, c.c_nation

    Plan hash value: 916746023

    ----------------------------------------------------------------------------------------------------------------------
    | Id  | Operation                        | Name      | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     | Pstart| Pstop |
    ----------------------------------------------------------------------------------------------------------------------
    |   0 | SELECT STATEMENT                 |           |       |       |       |   127K(100)|          |       |       |
    |   1 |  SORT GROUP BY                   |           |   124 | 12772 |       |   127K  (1)| 00:00:05 |       |       |
    |*  2 |   HASH JOIN                      |           |  2535K|   249M|       |   127K  (1)| 00:00:05 |       |       |
    |   3 |    PART JOIN FILTER CREATE       | :BF0000   |  2556 | 30672 |       |     7   (0)| 00:00:01 |       |       |
    |   4 |     TABLE ACCESS FULL            | DATE_DIM  |  2556 | 30672 |       |     7   (0)| 00:00:01 |       |       |
    |*  5 |    HASH JOIN                     |           |  2535K|   220M|    12M|   127K  (1)| 00:00:05 |       |       |
    |   6 |     TABLE ACCESS FULL            | PART      |   800K|  3906K|       |  1898   (1)| 00:00:01 |       |       |
    |*  7 |     HASH JOIN                    |           |  2535K|   207M|  2688K|   113K  (1)| 00:00:05 |       |       |
    |*  8 |      TABLE ACCESS FULL           | CUSTOMER  | 59761 |  1984K|       |   841   (1)| 00:00:01 |       |       |
    |*  9 |      HASH JOIN                   |           |  8510K|   422M|       | 86765   (1)| 00:00:04 |       |       |
    |* 10 |       TABLE ACCESS FULL          | SUPPLIER  |  4102 | 73836 |       |    69   (0)| 00:00:01 |       |       |
    |  11 |       PARTITION RANGE JOIN-FILTER|           |    41M|  1354M|       | 86555   (1)| 00:00:04 |:BF0000|:BF0000|
    |  12 |        TABLE ACCESS FULL         | LINEORDER |    41M|  1354M|       | 86555   (1)| 00:00:04 |:BF0000|:BF0000|
    ----------------------------------------------------------------------------------------------------------------------

    Predicate Information (identified by operation id):
    ---------------------------------------------------

       2 - access("L"."LO_ORDERDATE"="D"."D_DATEKEY")
       5 - access("L"."LO_PARTKEY"="P"."P_PARTKEY")
       7 - access("L"."LO_CUSTKEY"="C"."C_CUSTKEY")
       8 - filter("C"."C_REGION"='AMERICA')
       9 - access("L"."LO_SUPPKEY"="S"."S_SUPPKEY")
      10 - filter("S"."S_REGION"='AMERICA')


    42 rows selected.

    SQL>
    ```

    Compare the time from Step 7 (06\_vgb\_im.sql) to the time running the query in the row-store with no vector group by enabled. Quite a dramatic difference.

10. Exit lab

    Type commands below:  

    ```
    <copy>
    exit
    cd ..
    </copy>
    ```

    Command results:

    ```
    SQL> exit
    Disconnected from Oracle Database 21c Enterprise Edition Release 21.0.0.0.0 - Production
    Version 21.4.0.0.0
    [CDB1:oracle@dbhol:~/labs/inmemory/joins-aggr]$ cd ..
    [CDB1:oracle@dbhol:~/labs/inmemory]$
    ```


## Conclusion

This lab saw our performance comparison expanded to queries with both joins and aggregations. You had an opportunity to see just how efficiently a hash join, that is automatically converted to a Bloom filter, can be executed in the IM column store.

You also got to see just how sophisticated the Oracle Optimizer has become over the last 30 plus years, when it used a combination of complex query transformations to find the optimal execution plan for a star query.

Oracle Database adds In-Memory database functionality to existing databases, and transparently accelerates analytics by orders of magnitude while simultaneously speeding up mixed-workload OLTP. With Oracle Database In-Memory, users get immediate answers to business questions that previously took hours.

You may now **proceed to the next lab**.

## Acknowledgements

- **Author** - Andy Rivenes, Product Manager, Database In-Memory
- **Contributors** - Maria Colgan, Distinguished Product Manager
- **Last Updated By/Date** - Andy Rivenes, August 2022
