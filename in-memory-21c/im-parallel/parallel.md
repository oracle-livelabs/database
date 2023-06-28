# In-Memory Parallel Features

## Introduction

Watch an introduction video of using Database In-Memory:

[YouTube video](youtube:P6GZaykqHwI)

Watch the video below for a walk through of the In-Memory parallel features lab:

[In-Memory Parallel](videohub:1_p53hdys3)

*Estimated Lab Time:* 10 Minutes.

### Objectives

-   Learn how to use parallelization with Database In-Memory
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

Database In-Memory has always supported parallel execution, or parallel query. In fact, parallel query is needed when distributing data in a RAC system across different RAC instances. This is how you can use Database In-Memory to scale out the IM column store. In addition to Parallel Query, a feature called In-Memory Dynamic Scans (IMDS) was introduced in Oracle Database Release 12.2 to enable in-memory scans to be dynamically parallelized at the IMCU level based on the Resource Manager. When there is additional CPU capacity special IMDS scan processors can be used to further improve in-memory scan performance.

Why, you might ask, do I need parallelization if I am using Database In-Memory? Even though Database In-Memory makes queries fast, ultimately an in-memory query is limited by CPU and memory speed since no I/O is occurring. The only way to make the query faster is to use less CPU (i.e. execute fewer instructions) or parallelize (i.e. do more things at once). Other than for RAC scale-out mentioned above, parallel query and IMDS can make queries run faster by doing multiple things at once.

In this lab you will see how these two parallelization features can be used to improve Database In-Memory performance.

## Task 1: Verify Directory Definitions

In this Lab we will be populating external data from a local directory and we will need to define a database directory to use in our external table definitions to point the database to our external data.

Let's switch to the parallel folder and log back in to the PDB:

```
<copy>
cd /home/oracle/labs/inmemory/parallel
sqlplus ssb/Ora_DB4U@localhost:1521/pdb1
</copy>
```

And adjust the sqlplus display:

```
<copy>
set pages 9999
set lines 200
</copy>
```

Query result:

```
[CDB1:oracle@dbhol:~/labs/inmemory]$ cd /home/oracle/labs/inmemory/parallel
[CDB1:oracle@dbhol:~/labs/inmemory/Lab15-Parallel]$ sqlplus ssb/Ora_DB4U@localhost:1521/pdb1

SQL*Plus: Release 21.0.0.0.0 - Production on Fri Aug 19 18:33:55 2022
Version 21.4.0.0.0

Copyright (c) 1982, 2021, Oracle.  All rights reserved.

Last Successful login time: Thu Aug 18 2022 21:37:24 +00:00

Connected to:
Oracle Database 21c Enterprise Edition Release 21.0.0.0.0 - Production
Version 21.4.0.0.0

SQL> set pages 9999
SQL> set lines 200
SQL>
```

1. This lab will be using an open source dataset from the City of Chicago. It has crime information with text items that the SSB schema, the dataset the other examples are based on, does not have.

    Run the script *01\_parallel\_status.sql*

    ```
    <copy>
    @01_parallel_status.sql
    </copy>    
    ```

    or run the statement below:  

    ```
    <copy>
    show parameters parallel
    </copy>
    ```

    Query result:

    ```
    SQL> @01_parallel_status.sql
    Connected.

    NAME                                 TYPE        VALUE
    ------------------------------------ ----------- ------------------------------
    awr_pdb_max_parallel_slaves          integer     10
    containers_parallel_degree           integer     65535
    fast_start_parallel_rollback         string      LOW
    max_datapump_parallel_per_job        string      50
    optimizer_ignore_parallel_hints      boolean     FALSE
    parallel_adaptive_multi_user         boolean     FALSE
    parallel_degree_limit                string      CPU
    parallel_degree_policy               string      MANUAL
    parallel_execution_message_size      integer     16384
    parallel_force_local                 boolean     FALSE
    parallel_instance_group              string
    parallel_max_servers                 integer     40
    parallel_min_degree                  string      1
    parallel_min_percent                 integer     0
    parallel_min_servers                 integer     4
    parallel_min_time_threshold          string      AUTO
    parallel_servers_target              integer     16
    parallel_threads_per_cpu             integer     1
    recovery_parallelism                 integer     0
    SQL>
    ```

2. Now we will populate the LINEORDER partitions. Since we are explicitly enabling the partitions for INMEMORY they will not be touched by AIM. These partitions will serve as a constant filler so that the IM column store is close to full. This will make it easier to ensure that the IM column store is under memory pressure. This is required for the first two levels of AIM to operate.

    Run the script *02\_pop\_ssb\_tables.sql*

    ```
    <copy>
    @02_pop_ssb_tables.sql
    </copy>    
    ```

    or run the queries below:

    ```
    <copy>
    alter table LINEORDER inmemory priority high;
    exec dbms_inmemory.populate('SSB','LINEORDER');
    </copy>
    ```

    Query result:

    ```
    SQL> @02_ssb_tables.sql
    Connected.
    SQL>
    SQL> alter table LINEORDER inmemory priority high;

    Table altered.

    SQL> exec dbms_inmemory.populate('SSB','LINEORDER');

    PL/SQL procedure successfully completed.

    SQL>
    ```

3. Verify that all of the LINEORDER partitions are populated.

    Run the script *03\_im\_populated.sql*

    ```
    <copy>
    @03_im_populated.sql
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
    from   v$im_segments
    where owner not in ('AUDSYS','SYS')
    order by owner, segment_name, partition_name;
    </copy>
    ```

    Query result:

    ```
    SQL> @03_im_populated.sql
    Connected.
    SQL>
    SQL> -- Query the view v$IM_SEGMENTS to shows what objects are in the column store
    SQL> -- and how much of the objects were populated. When the BYTES_NOT_POPULATED is 0
    SQL> -- it indicates the entire table was populated.
    SQL>
    SQL> select owner, segment_name, partition_name, populate_status, bytes,
      2         inmemory_size, bytes_not_populated
      3  from   v$im_segments
      4  where owner not in ('AUDSYS','SYS')
      5  order by owner, segment_name, partition_name;

                                                                                            In-Memory            Bytes
    OWNER      SEGMENT_NAME         PARTITION_NAME  POPULATE_STATUS        Disk Size             Size    Not Populated
    ---------- -------------------- --------------- --------------- ---------------- ---------------- ----------------
    SSB        LINEORDER            PART_1994       COMPLETED            563,601,408      479,330,304                0
    SSB        LINEORDER            PART_1995       COMPLETED            563,470,336      479,330,304                0
    SSB        LINEORDER            PART_1996       COMPLETED            565,010,432      480,378,880                0
    SSB        LINEORDER            PART_1997       COMPLETED            563,314,688      479,330,304                0
    SSB        LINEORDER            PART_1998       COMPLETED            329,015,296      279,642,112                0

    SQL>
    ```

    Verify that all of the LINEORDER partitions are populated before continuing on with the lab.

4. First we will run just a serial query accessing a single table.

    Run the script *04\_serial\_single.sql*

    ```
    <copy>
    @04_serial_single.sql
    </copy>    
    ```

    or run the queries below:

    ```
    <copy>
    set timing on
    select
      max(lo_ordtotalprice) most_expensive_order,
      sum(lo_quantity) total_items
    from LINEORDER;
    set timing off
    select * from table(dbms_xplan.display_cursor());
    </copy>
    ```

    Query result:

    ```
    SQL> @04_serial_single.sql
    Connected.
    SQL>
    SQL> select
      2    max(lo_ordtotalprice) most_expensive_order,
      3    sum(lo_quantity) total_items
      4  from LINEORDER;

    MOST_EXPENSIVE_ORDER TOTAL_ITEMS
    -------------------- -----------
                57346348  1064978115

    Elapsed: 00:00:00.02
    SQL>
    SQL> set echo off
    Hit enter ...


    PLAN_TABLE_OUTPUT
    ------------------------------------------------------------------------------------------------------------------------------------------------------
    SQL_ID  abxsukctvzc8u, child number 0
    -------------------------------------
    select   max(lo_ordtotalprice) most_expensive_order,   sum(lo_quantity)
    total_items from LINEORDER

    Plan hash value: 4085810105

    ----------------------------------------------------------------------------------------------------------
    | Id  | Operation                    | Name      | Rows  | Bytes | Cost (%CPU)| Time     | Pstart| Pstop |
    ----------------------------------------------------------------------------------------------------------
    |   0 | SELECT STATEMENT             |           |       |       |  3613 (100)|          |       |       |
    |   1 |  SORT AGGREGATE              |           |     1 |     9 |            |          |       |       |
    |   2 |   PARTITION RANGE ALL        |           |    41M|   358M|  3613  (12)| 00:00:01 |     1 |     5 |
    |   3 |    TABLE ACCESS INMEMORY FULL| LINEORDER |    41M|   358M|  3613  (12)| 00:00:01 |     1 |     5 |
    ----------------------------------------------------------------------------------------------------------


    16 rows selected.

    SQL>
    ```

5. Next we will run the same query as in the previous step but this will be a parallel query.

    Run the script *5\_parallel\_single.sql*

    ```
    <copy>
    @05_parallel_single.sql
    </copy>    
    ```

    or run the queries below:

    ```
    <copy>
    alter session set parallel_degree_policy=auto;
    --
    set timing on
    select
      max(lo_ordtotalprice) most_expensive_order,
      sum(lo_quantity) total_items
    from LINEORDER;
    set timing off
    select * from table(dbms_xplan.display_cursor());
    </copy>
    ```

    Query result:

    ```
    SQL> @05_parallel_single.sql
    Connected.
    SQL>
    SQL> alter session set parallel_degree_policy=auto;

    Session altered.

    SQL>
    SQL> set timing on
    SQL> select
      2    max(lo_ordtotalprice) most_expensive_order,
      3    sum(lo_quantity) total_items
      4  from LINEORDER;

    MOST_EXPENSIVE_ORDER TOTAL_ITEMS
    -------------------- -----------
                57346348  1064978115

    Elapsed: 00:00:00.07
    SQL> set timing off
    SQL> set echo off
    Hit enter ...


    PLAN_TABLE_OUTPUT
    ------------------------------------------------------------------------------------------------------------------------------------------------------
    SQL_ID  abxsukctvzc8u, child number 2
    -------------------------------------
    select   max(lo_ordtotalprice) most_expensive_order,   sum(lo_quantity)
    total_items from LINEORDER

    Plan hash value: 451961284

    ------------------------------------------------------------------------------------------------------------------------------------------
    | Id  | Operation                       | Name      | Rows  | Bytes | Cost (%CPU)| Time     | Pstart| Pstop |    TQ  |IN-OUT| PQ Distrib |
    ------------------------------------------------------------------------------------------------------------------------------------------
    |   0 | SELECT STATEMENT                |           |       |       |  2007 (100)|          |       |       |        |      |            |
    |   1 |  SORT AGGREGATE                 |           |     1 |     9 |            |          |       |       |        |      |            |
    |   2 |   PX COORDINATOR                |           |       |       |            |          |       |       |        |      |            |
    |   3 |    PX SEND QC (RANDOM)          | :TQ10000  |     1 |     9 |            |          |       |       |  Q1,00 | P->S | QC (RAND)  |
    |   4 |     SORT AGGREGATE              |           |     1 |     9 |            |          |       |       |  Q1,00 | PCWP |            |
    |   5 |      PX BLOCK ITERATOR          |           |    41M|   358M|  2007  (12)| 00:00:01 |     1 |     5 |  Q1,00 | PCWC |            |
    |*  6 |       TABLE ACCESS INMEMORY FULL| LINEORDER |    41M|   358M|  2007  (12)| 00:00:01 |     1 |     5 |  Q1,00 | PCWP |            |
    ------------------------------------------------------------------------------------------------------------------------------------------

    Predicate Information (identified by operation id):
    ---------------------------------------------------

       6 - inmemory(:Z>=:Z AND :Z<=:Z)

    Note
    -----
       - automatic DOP: Computed Degree of Parallelism is 2


    28 rows selected.

    SQL>
    ```

    Notice that we enabled the session level parameter PARALLEL\_DEGREE\_POLICY of AUTO. This enabled parallel query and the optimizer chose a degree of parallelism of 2. We still accessed the LINEORDER table in-memory but we did it using parallel query.

6. Now we will perform a serial query with a join.

    Run the script *06\_serial\_join.sql*

    ```
    <copy>
    @06_serial_join.sql
    </copy>    
    ```

    or run the queries below:

    ```
    <copy>
    set timing on
    select   /*+ NO_VECTOR_TRANSFORM */
             d.d_year, p.p_brand1, sum(lo_revenue) tot_rev, count(p.p_partkey) tot_parts
    from     lineorder l,
             date_dim d,
             part p,
             supplier s
    where    l.lo_orderdate = d.d_datekey
    and      l.lo_partkey   = p.p_partkey
    and      l.lo_suppkey   = s.s_suppkey
    and      p.p_category     = 'MFGR#12'
    and      s.s_region     = 'AMERICA'
    and      d.d_year     = 1997
    group by d.d_year, p.p_brand1;
    set timing off
    select * from table(dbms_xplan.display_cursor());
    </copy>
    ```

    Query result:

    ```
    SQL> @06_serial_join.sql
    Connected.
    SQL>
    SQL> select   /*+ NO_VECTOR_TRANSFORM */
      2           d.d_year, p.p_brand1, sum(lo_revenue) tot_rev, count(p.p_partkey) tot_parts
      3  from     lineorder l,
      4           date_dim d,
      5           part p,
      6           supplier s
      7  where    l.lo_orderdate = d.d_datekey
      8  and      l.lo_partkey   = p.p_partkey
      9  and      l.lo_suppkey   = s.s_suppkey
     10  and      p.p_category     = 'MFGR#12'
     11  and      s.s_region     = 'AMERICA'
     12  and      d.d_year     = 1997
     13  group by d.d_year, p.p_brand1;

        D_YEAR P_BRAND1     TOT_REV  TOT_PARTS
    ---------- --------- ---------- ----------
          1997 MFGR#128  6597639363       1834
          1997 MFGR#126  6213627043       1781
          1997 MFGR#1214 6630127600       1834
          1997 MFGR#1234 6695984533       1853
          1997 MFGR#122  7101221796       1959
          1997 MFGR#1217 7053041453       1963
          1997 MFGR#1221 6892277556       1911
          1997 MFGR#127  6765391794       1902
          1997 MFGR#1230 6596531127       1799
          1997 MFGR#1211 6852509575       1864
          1997 MFGR#1225 6804217225       1848
          1997 MFGR#1231 6839363437       1866
          1997 MFGR#1213 6686343443       1820
          1997 MFGR#1232 7404918843       2054
          1997 MFGR#1227 6713851455       1814
          1997 MFGR#1220 6613283998       1796
          1997 MFGR#1219 6651946261       1794
          1997 MFGR#1237 7041724061       1963
          1997 MFGR#1218 6841323272       1849
          1997 MFGR#1210 6795372926       1879
          1997 MFGR#123  6280463233       1773
          1997 MFGR#121  6409702180       1852
          1997 MFGR#1240 7056019394       1980
          1997 MFGR#1215 7079477060       1888
          1997 MFGR#124  6817087386       1877
          1997 MFGR#1224 7373166413       2027
          1997 MFGR#1212 6573951551       1792
          1997 MFGR#1233 6914572704       1871
          1997 MFGR#129  6164317597       1713
          1997 MFGR#1223 6465041111       1801
          1997 MFGR#1236 6827320374       1938
          1997 MFGR#1238 6443513085       1730
          1997 MFGR#1228 7038686432       1957
          1997 MFGR#1235 7075150948       1947
          1997 MFGR#1239 6227318243       1761
          1997 MFGR#1216 6877592440       1871
          1997 MFGR#125  6416763567       1821
          1997 MFGR#1229 6481227038       1775
          1997 MFGR#1222 6551372899       1806
          1997 MFGR#1226 7185780867       1969

    40 rows selected.

    Elapsed: 00:00:00.50
    SQL>
    SQL> set echo off
    Hit enter ...


    PLAN_TABLE_OUTPUT
    ------------------------------------------------------------------------------------------------------------------------------------------------------
    SQL_ID  3sg3ffa5xqrzb, child number 0
    -------------------------------------
    select   /*+ NO_VECTOR_TRANSFORM */          d.d_year, p.p_brand1,
    sum(lo_revenue) tot_rev, count(p.p_partkey) tot_parts from
    lineorder l,          date_dim d,          part p,          supplier s
    where    l.lo_orderdate = d.d_datekey and      l.lo_partkey   =
    p.p_partkey and      l.lo_suppkey   = s.s_suppkey and      p.p_category
        = 'MFGR#12' and      s.s_region     = 'AMERICA' and      d.d_year
      = 1997 group by d.d_year, p.p_brand1

    Plan hash value: 4224806115

    ----------------------------------------------------------------------------------------------------------------
    | Id  | Operation                          | Name      | Rows  | Bytes | Cost (%CPU)| Time     | Pstart| Pstop |
    ----------------------------------------------------------------------------------------------------------------
    |   0 | SELECT STATEMENT                   |           |       |       |  6031 (100)|          |       |       |
    |   1 |  HASH GROUP BY                     |           |  1000 | 77000 |  6031  (15)| 00:00:01 |       |       |
    |*  2 |   HASH JOIN                        |           | 98430 |  7401K|  6028  (15)| 00:00:01 |       |       |
    |   3 |    JOIN FILTER CREATE              | :BF0001   |   365 |  4380 |     7   (0)| 00:00:01 |       |       |
    |   4 |     PART JOIN FILTER CREATE        | :BF0000   |   365 |  4380 |     7   (0)| 00:00:01 |       |       |
    |*  5 |      TABLE ACCESS INMEMORY FULL    | DATE_DIM  |   365 |  4380 |     7   (0)| 00:00:01 |       |       |
    |*  6 |    HASH JOIN                       |           |   451K|    28M|  6019  (15)| 00:00:01 |       |       |
    |   7 |     JOIN FILTER CREATE             | :BF0002   |  4102 | 73836 |    69   (0)| 00:00:01 |       |       |
    |*  8 |      TABLE ACCESS INMEMORY FULL    | SUPPLIER  |  4102 | 73836 |    69   (0)| 00:00:01 |       |       |
    |*  9 |     HASH JOIN                      |           |  2216K|    99M|  5942  (15)| 00:00:01 |       |       |
    |  10 |      JOIN FILTER CREATE            | :BF0003   | 31882 |   716K|  1906   (1)| 00:00:01 |       |       |
    |* 11 |       TABLE ACCESS INMEMORY FULL   | PART      | 31882 |   716K|  1906   (1)| 00:00:01 |       |       |
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


    51 rows selected.

    SQL>
    ```

    We've seen this query before. This is the same query that is used in Lab03 step 3. Note that we used 3 Bloom filters in this query.

7. Now we will run that same query using parallel query.

    Run the script *07\_parallel\_join.sql*

    ```
    <copy>
    @07_parallel_join.sql
    </copy>    
    ```

    or run the queries below:

    ```
    <copy>
    alter session set parallel_degree_policy=auto;
    --
    set timing on
    select   /*+ NO_VECTOR_TRANSFORM */
             d.d_year, p.p_brand1, sum(lo_revenue) tot_rev, count(p.p_partkey) tot_parts
    from     lineorder l,
             date_dim d,
             part p,
             supplier s
    where    l.lo_orderdate = d.d_datekey
    and      l.lo_partkey   = p.p_partkey
    and      l.lo_suppkey   = s.s_suppkey
    and      p.p_category     = 'MFGR#12'
    and      s.s_region     = 'AMERICA'
    and      d.d_year     = 1997
    group by d.d_year, p.p_brand1;
    set timing off
    select * from table(dbms_xplan.display_cursor());
    </copy>
    ```

    Query result:

    ```
    SQL> @07_parallel_join.sql
    Connected.
    SQL> --
    SQL> alter session set parallel_degree_policy=auto;

    Session altered.

    SQL> --
    SQL> set timing on
    SQL> select   /*+ NO_VECTOR_TRANSFORM */
      2           d.d_year, p.p_brand1, sum(lo_revenue) tot_rev, count(p.p_partkey) tot_parts
      3  from     lineorder l,
      4           date_dim d,
      5           part p,
      6           supplier s
      7  where    l.lo_orderdate = d.d_datekey
      8  and      l.lo_partkey   = p.p_partkey
      9  and      l.lo_suppkey   = s.s_suppkey
     10  and      p.p_category     = 'MFGR#12'
     11  and      s.s_region     = 'AMERICA'
     12  and      d.d_year     = 1997
     13  group by d.d_year, p.p_brand1;

        D_YEAR P_BRAND1     TOT_REV  TOT_PARTS
    ---------- --------- ---------- ----------
          1997 MFGR#1234 6695984533       1853
          1997 MFGR#126  6213627043       1781
          1997 MFGR#1236 6827320374       1938
          1997 MFGR#1222 6551372899       1806
          1997 MFGR#1215 7079477060       1888
          1997 MFGR#1217 7053041453       1963
          1997 MFGR#1213 6686343443       1820
          1997 MFGR#1220 6613283998       1796
          1997 MFGR#1225 6804217225       1848
          1997 MFGR#1228 7038686432       1957
          1997 MFGR#125  6416763567       1821
          1997 MFGR#123  6280463233       1773
          1997 MFGR#1226 7185780867       1969
          1997 MFGR#1233 6914572704       1871
          1997 MFGR#1211 6852509575       1864
          1997 MFGR#1214 6630127600       1834
          1997 MFGR#1230 6596531127       1799
          1997 MFGR#129  6164317597       1713
          1997 MFGR#1216 6877592440       1871
          1997 MFGR#127  6765391794       1902
          1997 MFGR#1221 6892277556       1911
          1997 MFGR#128  6597639363       1834
          1997 MFGR#121  6409702180       1852
          1997 MFGR#1224 7373166413       2027
          1997 MFGR#122  7101221796       1959
          1997 MFGR#1210 6795372926       1879
          1997 MFGR#1239 6227318243       1761
          1997 MFGR#1231 6839363437       1866
          1997 MFGR#1223 6465041111       1801
          1997 MFGR#1212 6573951551       1792
          1997 MFGR#124  6817087386       1877
          1997 MFGR#1227 6713851455       1814
          1997 MFGR#1237 7041724061       1963
          1997 MFGR#1218 6841323272       1849
          1997 MFGR#1235 7075150948       1947
          1997 MFGR#1219 6651946261       1794
          1997 MFGR#1232 7404918843       2054
          1997 MFGR#1240 7056019394       1980
          1997 MFGR#1238 6443513085       1730
          1997 MFGR#1229 6481227038       1775

    40 rows selected.

    Elapsed: 00:00:00.27
    SQL>
    SQL> set echo off
    Hit enter ...


    PLAN_TABLE_OUTPUT
    ------------------------------------------------------------------------------------------------------------------------------------------------------
    SQL_ID  3sg3ffa5xqrzb, child number 2
    -------------------------------------
    select   /*+ NO_VECTOR_TRANSFORM */          d.d_year, p.p_brand1,
    sum(lo_revenue) tot_rev, count(p.p_partkey) tot_parts from
    lineorder l,          date_dim d,          part p,          supplier s
    where    l.lo_orderdate = d.d_datekey and      l.lo_partkey   =
    p.p_partkey and      l.lo_suppkey   = s.s_suppkey and      p.p_category
        = 'MFGR#12' and      s.s_region     = 'AMERICA' and      d.d_year
      = 1997 group by d.d_year, p.p_brand1

    Plan hash value: 1546927328

    --------------------------------------------------------------------------------------------------------------------------------------------------
    | Id  | Operation                               | Name      | Rows  | Bytes | Cost (%CPU)| Time     | Pstart| Pstop |    TQ  |IN-OUT| PQ Distrib |
    --------------------------------------------------------------------------------------------------------------------------------------------------
    |   0 | SELECT STATEMENT                        |           |       |       |  2296 (100)|          |       |       |        |      |            |
    |   1 |  PX COORDINATOR                         |           |       |       |            |          |       |       |        |      |            |
    |   2 |   PX SEND QC (RANDOM)                   | :TQ10002  |  1000 | 77000 |  2296  (21)| 00:00:01 |       |       |  Q1,02 | P->S | QC (RAND)  |
    |   3 |    HASH GROUP BY                        |           |  1000 | 77000 |  2296  (21)| 00:00:01 |       |       |  Q1,02 | PCWP |            |
    |   4 |     PX RECEIVE                          |           |  1000 | 77000 |  2296  (21)| 00:00:01 |       |       |  Q1,02 | PCWP |            |
    |   5 |      PX SEND HASH                       | :TQ10001  |  1000 | 77000 |  2296  (21)| 00:00:01 |       |       |  Q1,01 | P->P | HASH       |
    |   6 |       HASH GROUP BY                     |           |  1000 | 77000 |  2296  (21)| 00:00:01 |       |       |  Q1,01 | PCWP |            |
    |*  7 |        HASH JOIN                        |           | 97986 |  7368K|  2294  (21)| 00:00:01 |       |       |  Q1,01 | PCWP |            |
    |   8 |         JOIN FILTER CREATE              | :BF0001   |   365 |  4380 |     2   (0)| 00:00:01 |       |       |  Q1,01 | PCWP |            |
    |   9 |          PART JOIN FILTER CREATE        | :BF0000   |   365 |  4380 |     2   (0)| 00:00:01 |       |       |  Q1,01 | PCWP |            |
    |  10 |           PX RECEIVE                    |           |   365 |  4380 |     2   (0)| 00:00:01 |       |       |  Q1,01 | PCWP |            |
    |  11 |            PX SEND BROADCAST            | :TQ10000  |   365 |  4380 |     2   (0)| 00:00:01 |       |       |  Q1,00 | P->P | BROADCAST  |
    |  12 |             PX BLOCK ITERATOR           |           |   365 |  4380 |     2   (0)| 00:00:01 |       |       |  Q1,00 | PCWC |            |
    |* 13 |              TABLE ACCESS INMEMORY FULL | DATE_DIM  |   365 |  4380 |     2   (0)| 00:00:01 |       |       |  Q1,00 | PCWP |            |
    |* 14 |         HASH JOIN                       |           |   449K|    27M|  2291  (21)| 00:00:01 |       |       |  Q1,01 | PCWP |            |
    |  15 |          JOIN FILTER CREATE             | :BF0002   |  4102 | 73836 |     2   (0)| 00:00:01 |       |       |  Q1,01 | PCWP |            |
    |* 16 |           TABLE ACCESS INMEMORY FULL    | SUPPLIER  |  4102 | 73836 |     2   (0)| 00:00:01 |       |       |  Q1,01 | PCWP |            |
    |* 17 |          HASH JOIN                      |           |  2206K|    98M|  2285  (21)| 00:00:01 |       |       |  Q1,01 | PCWP |            |
    |  18 |           JOIN FILTER CREATE            | :BF0003   | 31738 |   712K|    50  (22)| 00:00:01 |       |       |  Q1,01 | PCWP |            |
    |* 19 |            TABLE ACCESS INMEMORY FULL   | PART      | 31738 |   712K|    50  (22)| 00:00:01 |       |       |  Q1,01 | PCWP |            |
    |  20 |           JOIN FILTER USE               | :BF0001   |    41M|   955M|  2164  (18)| 00:00:01 |       |       |  Q1,01 | PCWP |            |
    |  21 |            JOIN FILTER USE              | :BF0002   |    41M|   955M|  2164  (18)| 00:00:01 |       |       |  Q1,01 | PCWP |            |
    |  22 |             JOIN FILTER USE             | :BF0003   |    41M|   955M|  2164  (18)| 00:00:01 |       |       |  Q1,01 | PCWP |            |
    |  23 |              PX BLOCK ITERATOR ADAPTIVE |           |    41M|   955M|  2164  (18)| 00:00:01 |:BF0000|:BF0000|  Q1,01 | PCWC |            |
    |* 24 |               TABLE ACCESS INMEMORY FULL| LINEORDER |    41M|   955M|  2164  (18)| 00:00:01 |:BF0000|:BF0000|  Q1,01 | PCWP |            |
    --------------------------------------------------------------------------------------------------------------------------------------------------

    Predicate Information (identified by operation id):
    ---------------------------------------------------

       7 - access("L"."LO_ORDERDATE"="D"."D_DATEKEY")
      13 - inmemory(:Z>=:Z AND :Z<=:Z AND "D"."D_YEAR"=1997)
           filter("D"."D_YEAR"=1997)
      14 - access("L"."LO_SUPPKEY"="S"."S_SUPPKEY")
      16 - inmemory("S"."S_REGION"='AMERICA')
           filter("S"."S_REGION"='AMERICA')
      17 - access("L"."LO_PARTKEY"="P"."P_PARTKEY")
      19 - inmemory("P"."P_CATEGORY"='MFGR#12')
           filter("P"."P_CATEGORY"='MFGR#12')
      24 - inmemory(:Z>=:Z AND :Z<=:Z AND SYS_OP_BLOOM_FILTER_LIST(SYS_OP_BLOOM_FILTER(:BF0003,"L"."LO_PARTKEY"),SYS_OP_BLOOM_FILTER(:BF0002,"
                  L"."LO_SUPPKEY"),SYS_OP_BLOOM_FILTER(:BF0001,"L"."LO_ORDERDATE")))
           filter(SYS_OP_BLOOM_FILTER_LIST(SYS_OP_BLOOM_FILTER(:BF0003,"L"."LO_PARTKEY"),SYS_OP_BLOOM_FILTER(:BF0002,"L"."LO_SUPPKEY"),SYS_OP_
                  BLOOM_FILTER(:BF0001,"L"."LO_ORDERDATE")))

    Note
    -----
       - dynamic statistics used: dynamic sampling (level=AUTO (SYSTEM))
       - automatic DOP: Computed Degree of Parallelism is 2


    64 rows selected.

    SQL>
    ```

    Now we see quite a bit more complicated execution plan, but the bottom line is that even with parallel query enabled we still see all of the in-memory optimizations used. Specifically the use of three Bloom filters to optimize the hash joins allowing them to be effectively turned in to scan and filter operations. Except no it can be done in parallel!

8. The same applies to In-Memory Aggregation, or Vector Group By. First we will run a serial vector group by query.

    Run the script *08\_serial\_vgb.sql*

    ```
    <copy>
    @08_serial_vgb.sql
    </copy>    
    ```

    or run the queries below:

    ```
    <copy>
    set timing on
    select
             d.d_year, p.p_brand1, sum(lo_revenue) tot_rev, count(p.p_partkey) tot_parts
    from     lineorder l,
             date_dim d,
             part p,
             supplier s
    where    l.lo_orderdate = d.d_datekey
    and      l.lo_partkey   = p.p_partkey
    and      l.lo_suppkey   = s.s_suppkey
    and      p.p_category     = 'MFGR#12'
    and      s.s_region     = 'AMERICA'
    and      d.d_year     = 1997
    group by d.d_year, p.p_brand1;
    set echo off
    set timing off
    select * from table(dbms_xplan.display_cursor());
    </copy>
    ```

    Query result:

    ```
    SQL> @08_serial_vgb.sql
    Connected.
    SQL>
    SQL> select
      2           d.d_year, p.p_brand1, sum(lo_revenue) tot_rev, count(p.p_partkey) tot_parts
      3  from     lineorder l,
      4           date_dim d,
      5           part p,
      6           supplier s
      7  where    l.lo_orderdate = d.d_datekey
      8  and      l.lo_partkey   = p.p_partkey
      9  and      l.lo_suppkey   = s.s_suppkey
     10  and      p.p_category     = 'MFGR#12'
     11  and      s.s_region     = 'AMERICA'
     12  and      d.d_year     = 1997
     13  group by d.d_year, p.p_brand1;

        D_YEAR P_BRAND1     TOT_REV  TOT_PARTS
    ---------- --------- ---------- ----------
          1997 MFGR#1210 6795372926       1879
          1997 MFGR#122  7101221796       1959
          1997 MFGR#1211 6852509575       1864
          1997 MFGR#1229 6481227038       1775
          1997 MFGR#1212 6573951551       1792
          1997 MFGR#125  6416763567       1821
          1997 MFGR#1216 6877592440       1871
          1997 MFGR#126  6213627043       1781
          1997 MFGR#1223 6465041111       1801
          1997 MFGR#1238 6443513085       1730
          1997 MFGR#1234 6695984533       1853
          1997 MFGR#1220 6613283998       1796
          1997 MFGR#121  6409702180       1852
          1997 MFGR#1233 6914572704       1871
          1997 MFGR#1222 6551372899       1806
          1997 MFGR#1226 7185780867       1969
          1997 MFGR#1215 7079477060       1888
          1997 MFGR#1217 7053041453       1963
          1997 MFGR#1218 6841323272       1849
          1997 MFGR#1224 7373166413       2027
          1997 MFGR#1225 6804217225       1848
          1997 MFGR#123  6280463233       1773
          1997 MFGR#1227 6713851455       1814
          1997 MFGR#124  6817087386       1877
          1997 MFGR#1214 6630127600       1834
          1997 MFGR#1228 7038686432       1957
          1997 MFGR#1219 6651946261       1794
          1997 MFGR#127  6765391794       1902
          1997 MFGR#1235 7075150948       1947
          1997 MFGR#1236 6827320374       1938
          1997 MFGR#1232 7404918843       2054
          1997 MFGR#1240 7056019394       1980
          1997 MFGR#1221 6892277556       1911
          1997 MFGR#1230 6596531127       1799
          1997 MFGR#1213 6686343443       1820
          1997 MFGR#1239 6227318243       1761
          1997 MFGR#129  6164317597       1713
          1997 MFGR#128  6597639363       1834
          1997 MFGR#1237 7041724061       1963
          1997 MFGR#1231 6839363437       1866

    40 rows selected.

    Elapsed: 00:00:00.20
    SQL>
    SQL> set echo off
    Hit enter ...


    PLAN_TABLE_OUTPUT
    ------------------------------------------------------------------------------------------------------------------------------------------------------
    SQL_ID  48mj8cqjnr5yn, child number 0
    -------------------------------------
    select          d.d_year, p.p_brand1, sum(lo_revenue) tot_rev,
    count(p.p_partkey) tot_parts from     lineorder l,          date_dim d,
             part p,          supplier s where    l.lo_orderdate =
    d.d_datekey and      l.lo_partkey   = p.p_partkey and      l.lo_suppkey
      = s.s_suppkey and      p.p_category     = 'MFGR#12' and
    s.s_region     = 'AMERICA' and      d.d_year     = 1997 group by
    d.d_year, p.p_brand1

    Plan hash value: 2709540680

    ---------------------------------------------------------------------------------------------------------------------------------------
    | Id  | Operation                                | Name                       | Rows  | Bytes | Cost (%CPU)| Time     | Pstart| Pstop |
    ---------------------------------------------------------------------------------------------------------------------------------------
    |   0 | SELECT STATEMENT                         |                            |       |       |  4002 (100)|          |       |       |
    |   1 |  TEMP TABLE TRANSFORMATION               |                            |       |       |            |          |       |       |
    |   2 |   LOAD AS SELECT (CURSOR DURATION MEMORY)| SYS_TEMP_0FD9D68FC_2427914 |       |       |            |          |       |       |
    |   3 |    HASH GROUP BY                         |                            |     1 |    16 |     2  (50)| 00:00:01 |       |       |
    |   4 |     KEY VECTOR CREATE BUFFERED           | :KV0000                    |     1 |    16 |     1   (0)| 00:00:01 |       |       |
    |*  5 |      TABLE ACCESS INMEMORY FULL          | DATE_DIM                   |   365 |  4380 |     1   (0)| 00:00:01 |       |       |
    |   6 |   LOAD AS SELECT (CURSOR DURATION MEMORY)| SYS_TEMP_0FD9D68FA_2427914 |       |       |            |          |       |       |
    |   7 |    HASH GROUP BY                         |                            |  1000 | 27000 |    93  (24)| 00:00:01 |       |       |
    |   8 |     KEY VECTOR CREATE BUFFERED           | :KV0001                    |  1000 | 27000 |    91  (22)| 00:00:01 |       |       |
    |*  9 |      TABLE ACCESS INMEMORY FULL          | PART                       | 31882 |   716K|    91  (22)| 00:00:01 |       |       |
    |  10 |   LOAD AS SELECT (CURSOR DURATION MEMORY)| SYS_TEMP_0FD9D68FB_2427914 |       |       |            |          |       |       |
    |  11 |    HASH GROUP BY                         |                            |     1 |    22 |     4  (25)| 00:00:01 |       |       |
    |  12 |     KEY VECTOR CREATE BUFFERED           | :KV0002                    |     1 |    22 |     3   (0)| 00:00:01 |       |       |
    |* 13 |      TABLE ACCESS INMEMORY FULL          | SUPPLIER                   |  4102 | 73836 |     3   (0)| 00:00:01 |       |       |
    |  14 |   HASH GROUP BY                          |                            |   500 | 49500 |  3903  (18)| 00:00:01 |       |       |
    |* 15 |    HASH JOIN                             |                            |   500 | 49500 |  3902  (18)| 00:00:01 |       |       |
    |  16 |     VIEW                                 | VW_VT_80F21617             |   500 | 19000 |  3895  (18)| 00:00:01 |       |       |
    |  17 |      VECTOR GROUP BY                     |                            |   500 | 18000 |  3895  (18)| 00:00:01 |       |       |
    |  18 |       HASH GROUP BY                      |                            |   500 | 18000 |  3895  (18)| 00:00:01 |       |       |
    |  19 |        KEY VECTOR USE                    | :KV0000                    | 98430 |  3460K|  3895  (18)| 00:00:01 |       |       |
    |  20 |         KEY VECTOR USE                   | :KV0002                    |   451K|    13M|  3895  (18)| 00:00:01 |       |       |
    |  21 |          KEY VECTOR USE                  | :KV0001                    |  2216K|    59M|  3895  (18)| 00:00:01 |       |       |
    |  22 |           PARTITION RANGE ITERATOR       |                            |    41M|   955M|  3895  (18)| 00:00:01 |:KV0000|:KV0000|
    |* 23 |            TABLE ACCESS INMEMORY FULL    | LINEORDER                  |    41M|   955M|  3895  (18)| 00:00:01 |:KV0000|:KV0000|
    |  24 |     MERGE JOIN CARTESIAN                 |                            |  1000 | 61000 |     7   (0)| 00:00:01 |       |       |
    |  25 |      MERGE JOIN CARTESIAN                |                            |     1 |    38 |     4   (0)| 00:00:01 |       |       |
    |  26 |       TABLE ACCESS FULL                  | SYS_TEMP_0FD9D68FC_2427914 |     1 |    16 |     2   (0)| 00:00:01 |       |       |
    |  27 |       BUFFER SORT                        |                            |     1 |    22 |     2   (0)| 00:00:01 |       |       |
    |  28 |        TABLE ACCESS FULL                 | SYS_TEMP_0FD9D68FB_2427914 |     1 |    22 |     2   (0)| 00:00:01 |       |       |
    |  29 |      BUFFER SORT                         |                            |  1000 | 23000 |     5   (0)| 00:00:01 |       |       |
    |  30 |       TABLE ACCESS FULL                  | SYS_TEMP_0FD9D68FA_2427914 |  1000 | 23000 |     3   (0)| 00:00:01 |       |       |
    ---------------------------------------------------------------------------------------------------------------------------------------

    Predicate Information (identified by operation id):
    ---------------------------------------------------

       5 - inmemory("D"."D_YEAR"=1997)
           filter("D"."D_YEAR"=1997)
       9 - inmemory("P"."P_CATEGORY"='MFGR#12')
           filter("P"."P_CATEGORY"='MFGR#12')
      13 - inmemory("S"."S_REGION"='AMERICA')
           filter("S"."S_REGION"='AMERICA')
      15 - access("ITEM_10"=INTERNAL_FUNCTION("C0") AND "ITEM_12"=INTERNAL_FUNCTION("C0") AND "ITEM_11"=INTERNAL_FUNCTION("C0"))
      23 - inmemory((SYS_OP_KEY_VECTOR_FILTER("L"."LO_PARTKEY",:KV0001) AND SYS_OP_KEY_VECTOR_FILTER("L"."LO_SUPPKEY",:KV0002) AND
                  SYS_OP_KEY_VECTOR_FILTER("L"."LO_ORDERDATE",:KV0000)))
           filter((SYS_OP_KEY_VECTOR_FILTER("L"."LO_PARTKEY",:KV0001) AND SYS_OP_KEY_VECTOR_FILTER("L"."LO_SUPPKEY",:KV0002) AND
                  SYS_OP_KEY_VECTOR_FILTER("L"."LO_ORDERDATE",:KV0000)))

    Note
    -----
       - vector transformation used for this statement


    67 rows selected.

    SQL>
    ```

9. Now let's see if parallel query can be used with vector group by.

    Run the script *09\_parallel\_vgb.sql*

    ```
    <copy>
    @09_parallel_vgb.sql
    </copy>    
    ```

    or run the queries below:

    ```
    <copy>
    alter session set parallel_degree_policy=auto;
    --
    set timing on
    select
             d.d_year, p.p_brand1, sum(lo_revenue) tot_rev, count(p.p_partkey) tot_parts
    from     lineorder l,
             date_dim d,
             part p,
             supplier s
    where    l.lo_orderdate = d.d_datekey
    and      l.lo_partkey   = p.p_partkey
    and      l.lo_suppkey   = s.s_suppkey
    and      p.p_category     = 'MFGR#12'
    and      s.s_region     = 'AMERICA'
    and      d.d_year     = 1997
    group by d.d_year, p.p_brand1;
    set timing off
    select * from table(dbms_xplan.display_cursor());
    </copy>
    ```

    Query result:

    ```
    SQL> @09_parallel_vgb.sql
    Connected.
    SQL>
    SQL> alter session set parallel_degree_policy=auto;

    Session altered.

    SQL> alter session set parallel_min_time_threshold=0;

    Session altered.

    SQL>
    SQL> set timing on
    SQL> select
      2           d.d_year, p.p_brand1, sum(lo_revenue) tot_rev, count(p.p_partkey) tot_parts
      3  from     lineorder l,
      4           date_dim d,
      5           part p,
      6           supplier s
      7  where    l.lo_orderdate = d.d_datekey
      8  and      l.lo_partkey   = p.p_partkey
      9  and      l.lo_suppkey   = s.s_suppkey
     10  and      p.p_category     = 'MFGR#12'
     11  and      s.s_region     = 'AMERICA'
     12  and      d.d_year     = 1997
     13  group by d.d_year, p.p_brand1;

        D_YEAR P_BRAND1     TOT_REV  TOT_PARTS
    ---------- --------- ---------- ----------
          1997 MFGR#1223 6465041111       1801
          1997 MFGR#1238 6443513085       1730
          1997 MFGR#1217 7053041453       1963
          1997 MFGR#1229 6481227038       1775
          1997 MFGR#126  6213627043       1781
          1997 MFGR#1234 6695984533       1853
          1997 MFGR#1222 6551372899       1806
          1997 MFGR#1240 7056019394       1980
          1997 MFGR#1210 6795372926       1879
          1997 MFGR#1233 6914572704       1871
          1997 MFGR#1226 7185780867       1969
          1997 MFGR#1239 6227318243       1761
          1997 MFGR#1227 6713851455       1814
          1997 MFGR#1214 6630127600       1834
          1997 MFGR#1236 6827320374       1938
          1997 MFGR#1212 6573951551       1792
          1997 MFGR#125  6416763567       1821
          1997 MFGR#1216 6877592440       1871
          1997 MFGR#121  6409702180       1852
          1997 MFGR#124  6817087386       1877
          1997 MFGR#1219 6651946261       1794
          1997 MFGR#1211 6852509575       1864
          1997 MFGR#1215 7079477060       1888
          1997 MFGR#1221 6892277556       1911
          1997 MFGR#127  6765391794       1902
          1997 MFGR#1228 7038686432       1957
          1997 MFGR#1220 6613283998       1796
          1997 MFGR#1224 7373166413       2027
          1997 MFGR#1235 7075150948       1947
          1997 MFGR#1218 6841323272       1849
          1997 MFGR#1232 7404918843       2054
          1997 MFGR#129  6164317597       1713
          1997 MFGR#1225 6804217225       1848
          1997 MFGR#1230 6596531127       1799
          1997 MFGR#1237 7041724061       1963
          1997 MFGR#1231 6839363437       1866
          1997 MFGR#1213 6686343443       1820
          1997 MFGR#122  7101221796       1959
          1997 MFGR#123  6280463233       1773
          1997 MFGR#128  6597639363       1834

    40 rows selected.

    Elapsed: 00:00:00.16
    SQL>
    SQL> set echo off
    Hit enter ...


    PLAN_TABLE_OUTPUT
    --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    SQL_ID  48mj8cqjnr5yn, child number 3
    -------------------------------------
    select          d.d_year, p.p_brand1, sum(lo_revenue) tot_rev,
    count(p.p_partkey) tot_parts from     lineorder l,          date_dim d,
             part p,          supplier s where    l.lo_orderdate =
    d.d_datekey and      l.lo_partkey   = p.p_partkey and      l.lo_suppkey
      = s.s_suppkey and      p.p_category     = 'MFGR#12' and
    s.s_region     = 'AMERICA' and      d.d_year     = 1997 group by
    d.d_year, p.p_brand1

    Plan hash value: 1460983996

    ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
    | Id  | Operation                                  | Name                       | Rows  | Bytes | Cost (%CPU)| Time     | Pstart| Pstop |    TQ  |IN-OUT| PQ Distrib |
    ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
    |   0 | SELECT STATEMENT                           |                            |       |       |  2229 (100)|          |       |       |        |      |            |
    |   1 |  TEMP TABLE TRANSFORMATION                 |                            |       |       |            |          |       |       |        |      |            |
    |   2 |   LOAD AS SELECT (CURSOR DURATION MEMORY)  | SYS_TEMP_0FD9D6908_2427914 |       |       |            |          |       |       |        |      |            |
    |   3 |    PX COORDINATOR                          |                            |       |       |            |          |       |       |        |      |            |
    |   4 |     PX SEND QC (RANDOM)                    | :TQ10001                   |     1 |    16 |     3  (34)| 00:00:01 |       |       |  Q1,01 | P->S | QC (RAND)  |
    |   5 |      HASH GROUP BY                         |                            |     1 |    16 |     3  (34)| 00:00:01 |       |       |  Q1,01 | PCWP |            |
    |   6 |       PX RECEIVE                           |                            |     1 |    16 |     2   (0)| 00:00:01 |       |       |  Q1,01 | PCWP |            |
    |   7 |        PX SEND HASH                        | :TQ10000                   |     1 |    16 |     2   (0)| 00:00:01 |       |       |  Q1,00 | P->P | HASH       |
    |   8 |         KEY VECTOR CREATE BUFFERED         | :KV0000                    |     1 |    16 |     2   (0)| 00:00:01 |       |       |  Q1,00 | PCWC |            |
    |   9 |          PX BLOCK ITERATOR                 |                            |   365 |  4380 |     2   (0)| 00:00:01 |       |       |  Q1,00 | PCWC |            |
    |* 10 |           TABLE ACCESS INMEMORY FULL       | DATE_DIM                   |   365 |  4380 |     2   (0)| 00:00:01 |       |       |  Q1,00 | PCWP |            |
    |  11 |   LOAD AS SELECT (CURSOR DURATION MEMORY)  | SYS_TEMP_0FD9D6906_2427914 |       |       |            |          |       |       |        |      |            |
    |  12 |    PX COORDINATOR                          |                            |       |       |            |          |       |       |        |      |            |
    |  13 |     PX SEND QC (RANDOM)                    | :TQ20001                   |  1000 | 27000 |    52  (25)| 00:00:01 |       |       |  Q2,01 | P->S | QC (RAND)  |
    |  14 |      HASH GROUP BY                         |                            |  1000 | 27000 |    52  (25)| 00:00:01 |       |       |  Q2,01 | PCWP |            |
    |  15 |       PX RECEIVE                           |                            |  1000 | 27000 |    50  (22)| 00:00:01 |       |       |  Q2,01 | PCWP |            |
    |  16 |        PX SEND HASH                        | :TQ20000                   |  1000 | 27000 |    50  (22)| 00:00:01 |       |       |  Q2,00 | P->P | HASH       |
    |  17 |         KEY VECTOR CREATE BUFFERED         | :KV0001                    |  1000 | 27000 |    50  (22)| 00:00:01 |       |       |  Q2,00 | PCWC |            |
    |  18 |          PX BLOCK ITERATOR                 |                            | 31738 |   712K|    50  (22)| 00:00:01 |       |       |  Q2,00 | PCWC |            |
    |* 19 |           TABLE ACCESS INMEMORY FULL       | PART                       | 31738 |   712K|    50  (22)| 00:00:01 |       |       |  Q2,00 | PCWP |            |
    |  20 |   LOAD AS SELECT (CURSOR DURATION MEMORY)  | SYS_TEMP_0FD9D6907_2427914 |       |       |            |          |       |       |        |      |            |
    |  21 |    PX COORDINATOR                          |                            |       |       |            |          |       |       |        |      |            |
    |  22 |     PX SEND QC (RANDOM)                    | :TQ30001                   |     1 |    22 |     3  (34)| 00:00:01 |       |       |  Q3,01 | P->S | QC (RAND)  |
    |  23 |      HASH GROUP BY                         |                            |     1 |    22 |     3  (34)| 00:00:01 |       |       |  Q3,01 | PCWP |            |
    |  24 |       PX RECEIVE                           |                            |     1 |    22 |     2   (0)| 00:00:01 |       |       |  Q3,01 | PCWP |            |
    |  25 |        PX SEND HASH                        | :TQ30000                   |     1 |    22 |     2   (0)| 00:00:01 |       |       |  Q3,00 | P->P | HASH       |
    |  26 |         KEY VECTOR CREATE BUFFERED         | :KV0002                    |     1 |    22 |     2   (0)| 00:00:01 |       |       |  Q3,00 | PCWC |            |
    |  27 |          PX BLOCK ITERATOR                 |                            |  4102 | 73836 |     2   (0)| 00:00:01 |       |       |  Q3,00 | PCWC |            |
    |* 28 |           TABLE ACCESS INMEMORY FULL       | SUPPLIER                   |  4102 | 73836 |     2   (0)| 00:00:01 |       |       |  Q3,00 | PCWP |            |
    |  29 |   PX COORDINATOR                           |                            |       |       |            |          |       |       |        |      |            |
    |  30 |    PX SEND QC (RANDOM)                     | :TQ40002                   |   500 | 49500 |  2170  (18)| 00:00:01 |       |       |  Q4,02 | P->S | QC (RAND)  |
    |* 31 |     HASH JOIN BUFFERED                     |                            |   500 | 49500 |  2170  (18)| 00:00:01 |       |       |  Q4,02 | PCWP |            |
    |* 32 |      HASH JOIN                             |                            |   500 | 38000 |  2168  (18)| 00:00:01 |       |       |  Q4,02 | PCWP |            |
    |  33 |       TABLE ACCESS FULL                    | SYS_TEMP_0FD9D6907_2427914 |     1 |    22 |     2   (0)| 00:00:01 |       |       |  Q4,02 | PCWP |            |
    |* 34 |       HASH JOIN                            |                            |   500 | 27000 |  2166  (18)| 00:00:01 |       |       |  Q4,02 | PCWP |            |
    |  35 |        TABLE ACCESS FULL                   | SYS_TEMP_0FD9D6908_2427914 |     1 |    16 |     2   (0)| 00:00:01 |       |       |  Q4,02 | PCWP |            |
    |  36 |        VIEW                                | VW_VT_80F21617             |   500 | 19000 |  2164  (18)| 00:00:01 |       |       |  Q4,02 | PCWP |            |
    |  37 |         HASH GROUP BY                      |                            |   500 | 18000 |  2164  (18)| 00:00:01 |       |       |  Q4,02 | PCWP |            |
    |  38 |          PX RECEIVE                        |                            |   500 | 18000 |  2164  (18)| 00:00:01 |       |       |  Q4,02 | PCWP |            |
    |  39 |           PX SEND HASH                     | :TQ40000                   |   500 | 18000 |  2164  (18)| 00:00:01 |       |       |  Q4,00 | P->P | HASH       |
    |  40 |            VECTOR GROUP BY                 |                            |   500 | 18000 |  2164  (18)| 00:00:01 |       |       |  Q4,00 | PCWP |            |
    |  41 |             HASH GROUP BY                  |                            |   500 | 18000 |  2164  (18)| 00:00:01 |       |       |  Q4,00 | PCWP |            |
    |  42 |              KEY VECTOR USE                | :KV0000                    | 98430 |  3460K|  2164  (18)| 00:00:01 |       |       |  Q4,00 | PCWC |            |
    |  43 |               KEY VECTOR USE               | :KV0002                    |   451K|    13M|  2164  (18)| 00:00:01 |       |       |  Q4,00 | PCWC |            |
    |  44 |                KEY VECTOR USE              | :KV0001                    |  2216K|    59M|  2164  (18)| 00:00:01 |       |       |  Q4,00 | PCWC |            |
    |  45 |                 PX BLOCK ITERATOR          |                            |    41M|   955M|  2164  (18)| 00:00:01 |:KV0000|:KV0000|  Q4,00 | PCWC |            |
    |* 46 |                  TABLE ACCESS INMEMORY FULL| LINEORDER                  |    41M|   955M|  2164  (18)| 00:00:01 |:KV0000|:KV0000|  Q4,00 | PCWP |            |
    |  47 |      PX RECEIVE                            |                            |  1000 | 23000 |     2   (0)| 00:00:01 |       |       |  Q4,02 | PCWP |            |
    |  48 |       PX SEND BROADCAST                    | :TQ40001                   |  1000 | 23000 |     2   (0)| 00:00:01 |       |       |  Q4,01 | P->P | BROADCAST  |
    |  49 |        PX BLOCK ITERATOR                   |                            |  1000 | 23000 |     2   (0)| 00:00:01 |       |       |  Q4,01 | PCWC |            |
    |* 50 |         TABLE ACCESS FULL                  | SYS_TEMP_0FD9D6906_2427914 |  1000 | 23000 |     2   (0)| 00:00:01 |       |       |  Q4,01 | PCWP |            |
    ----------------------------------------------------------------------------------------------------------------------------------------------------------------------

    Predicate Information (identified by operation id):
    ---------------------------------------------------

      10 - inmemory(:Z>=:Z AND :Z<=:Z AND "D"."D_YEAR"=1997)
           filter("D"."D_YEAR"=1997)
      19 - inmemory(:Z>=:Z AND :Z<=:Z AND "P"."P_CATEGORY"='MFGR#12')
           filter("P"."P_CATEGORY"='MFGR#12')
      28 - inmemory(:Z>=:Z AND :Z<=:Z AND "S"."S_REGION"='AMERICA')
           filter("S"."S_REGION"='AMERICA')
      31 - access("ITEM_12"=INTERNAL_FUNCTION("C0"))
      32 - access("ITEM_11"=INTERNAL_FUNCTION("C0"))
      34 - access("ITEM_10"=INTERNAL_FUNCTION("C0"))
      46 - inmemory(:Z>=:Z AND :Z<=:Z AND (SYS_OP_KEY_VECTOR_FILTER("L"."LO_PARTKEY",:KV0001) AND SYS_OP_KEY_VECTOR_FILTER("L"."LO_SUPPKEY",:KV0002) AND
                  SYS_OP_KEY_VECTOR_FILTER("L"."LO_ORDERDATE",:KV0000)))
           filter((SYS_OP_KEY_VECTOR_FILTER("L"."LO_PARTKEY",:KV0001) AND SYS_OP_KEY_VECTOR_FILTER("L"."LO_SUPPKEY",:KV0002) AND
                  SYS_OP_KEY_VECTOR_FILTER("L"."LO_ORDERDATE",:KV0000)))
      50 - access(:Z>=:Z AND :Z<=:Z)

    Note
    -----
       - dynamic statistics used: dynamic sampling (level=AUTO (SYSTEM))
       - automatic DOP: Computed Degree of Parallelism is 2
       - vector transformation used for this statement


    92 rows selected.

    SQL>
    ```

    We see that even a vector group by can take advantage of parallel query.

10. Lastly, let's see how In-Memory Dynamic Scans, or IMDS, works with in-memory queries.

    Run the script *10\_imds.sql*

    ```
    <copy>
    @10_imds.sql
    </copy>    
    ```

    or run the queries below:

    ```
    <copy>
    -- IMDS requires at least CPU_COUNT>=24 and a RESOURCE_MANAGER_PLAN
    -- The following forces IMDS to be used for this example
    --
    alter session set "_inmemory_dynamic_scans"=force;
    --
    set timing on
    select
      max(lo_ordtotalprice) most_expensive_order,
      sum(lo_quantity) total_items
    from
      LINEORDER;
    set timing off
    select * from table(dbms_xplan.display_cursor());
    @../imstats.sql
    </copy>
    ```

    Query result:

    ```
    SQL> @10_imds.sql
    Connected.
    SQL>
    SQL> -- IMDS requires at least CPU_COUNT>=24 and a RESOURCE_MANAGER_PLAN
    SQL> -- The following forces IMDS to be used for this example
    SQL> --
    SQL> alter session set "_inmemory_dynamic_scans"=force;

    Session altered.

    SQL> --
    SQL> set timing on
    SQL> select
      2    max(lo_ordtotalprice) most_expensive_order,
      3    sum(lo_quantity) total_items
      4  from
      5    LINEORDER;

    MOST_EXPENSIVE_ORDER TOTAL_ITEMS
    -------------------- -----------
                57346348  1064978115

    Elapsed: 00:00:00.02
    SQL>
    SQL> set echo off
    Hit enter ...


    PLAN_TABLE_OUTPUT
    ------------------------------------------------------------------------------------------------------------------------------------------------------
    SQL_ID  axwk4brk4uz29, child number 0
    -------------------------------------
    select   max(lo_ordtotalprice) most_expensive_order,   sum(lo_quantity)
    total_items from   LINEORDER

    Plan hash value: 4085810105

    ----------------------------------------------------------------------------------------------------------
    | Id  | Operation                    | Name      | Rows  | Bytes | Cost (%CPU)| Time     | Pstart| Pstop |
    ----------------------------------------------------------------------------------------------------------
    |   0 | SELECT STATEMENT             |           |       |       |  3613 (100)|          |       |       |
    |   1 |  SORT AGGREGATE              |           |     1 |     9 |            |          |       |       |
    |   2 |   PARTITION RANGE ALL        |           |    41M|   358M|  3613  (12)| 00:00:01 |     1 |     5 |
    |   3 |    TABLE ACCESS INMEMORY FULL| LINEORDER |    41M|   358M|  3613  (12)| 00:00:01 |     1 |     5 |
    ----------------------------------------------------------------------------------------------------------


    16 rows selected.

    Hit enter ...


    NAME                                                              VALUE
    -------------------------------------------------- --------------------
    CPU used by this session                                              7
    IM scan (dynamic) multi-threaded scans                                1
    IM scan (dynamic) rows                                         41760941
    IM scan CUs columns accessed                                        156
    IM scan CUs memcompress for query low                                78
    IM scan CUs pcode aggregation pushdown                              156
    IM scan rows                                                   41760941
    IM scan rows pcode aggregated                                  41760941
    IM scan rows projected                                                3
    IM scan rows valid                                             41760941
    physical reads                                                        3
    session logical reads                                            316043
    session logical reads - IM                                       315480
    session pga memory                                             18811128
    table scans (IM)                                                      5

    15 rows selected.

    SQL>
    ```

    In the statistics section at the bottom you will see two statistics that start with "IM scan (dynamic)". This tells you that IMDS was used. The nice thing with IMDS is that is does not preclude the use of other features, including parallel query.

## Conclusion

This lab demonstrated how Database In-Memory can optimize the access of external data, and support both external and hybrid partitioned tables.

You may now **proceed to the next lab**.

## Acknowledgements

- **Author** - Andy Rivenes, Product Manager,  Database In-Memory
- **Contributors** -
- **Last Updated By/Date** - Andy Rivenes, August 2022
