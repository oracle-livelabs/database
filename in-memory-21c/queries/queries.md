# In-Memory Queries

## Introduction
Watch a preview video of querying the In-Memory Column Store

[](youtube:U9BmS53KuGs)

Watch the video below for a walk through of the In-memory Queries lab.
[In-Memory Queries](videohub:1_ohs9hpw0)

### Objectives

-   Perform various queries on the In-Memory Column Store

### Prerequisites
This lab assumes you have:
- A Free Tier, Paid or LiveLabs Oracle Cloud account
- You have completed:
    - Lab: Prepare Setup (*Free-tier* and *Paid Tenants* only)
    - Lab: Environment Setup
    - Lab: Initialize Environment

**NOTE:** *When doing Copy/Paste using the convenient* **Copy** *function used throughout the guide, you must hit the* **ENTER** *key after pasting. Otherwise the last line will remain in the buffer until you hit* **ENTER!**

## Task 1: Querying the In-Memory Column Store

Now that you’ve gotten familiar with the IM column store let’s look at the benefits of using it. You will execute a series of queries against the large fact table LINEORDER, in both the buffer cache and the IM column store, to demonstrate the different ways the IM column store can improve query performance above and beyond the basic performance benefits of accessing data in memory only.

Let's switch to the queries folder and log back in to the PDB.

```
<copy>
cd /home/oracle/labs/inmemory/queries
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

```
[CDB1:oracle@dbhol:~/labs/inmemory]$ cd /home/oracle/labs/inmemory/queries
[CDB1:oracle@dbhol:~/labs/inmemory/queries]$ sqlplus ssb/Ora_DB4U@localhost:1521/pdb1

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

1. Let's begin with a simple query:  *What is the most expensive order and total quantity we have received to date?*  There are no indexes or views set up for this so the execution plan will be to do a full table scan of the LINEORDER table.  Note the elapsed time.

    Run the script *01\_im\_query\_stats.sql*

    ```
    <copy>
    @01_im_query_stats.sql
    </copy>    
    ```

    or run the query below:

    ```
    <copy>
    set timing on
    select
      max(lo_ordtotalprice) most_expensive_order,
      sum(lo_quantity) total_items
    from LINEORDER;
    set timing off
    select * from table(dbms_xplan.display_cursor());
      @../imstats.sql
        </copy>
    ```

    Query result:

    ```
    SQL> @01_im_query_stats.sql
    Connected.
    SQL>
    SQL> -- In-Memory query
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

    Hit enter ...


    NAME                                                              VALUE
    -------------------------------------------------- --------------------
    CPU used by this session                                             21
    IM scan CUs columns accessed                                        156
    IM scan CUs memcompress for query low                                78
    IM scan CUs pcode aggregation pushdown                              156
    IM scan rows                                                   41760941
    IM scan rows pcode aggregated                                  41760941
    IM scan rows projected                                               78
    IM scan rows valid                                             41760941
    physical reads                                                      259
    session logical reads                                            320580
    session logical reads - IM                                       315480
    session pga memory                                             18942200
    table scans (IM)                                                      5

    13 rows selected.

    SQL>
    ```

    The execution plan shows that we performed a TABLE ACCESS INMEMORY FULL of the LINEORDER table.

2. Now we will run the same query using the buffer cache. Remember that the LINEORDER table has been fully cached in the KEEP pool. You will notice that we have added a hint called *NO\_INMEMORY*. This will tell the optimizer not to access the data from the IM column store. Compare the query run time with the time from Step 1.

    Run the script *02\_buffer\_query\_stats.sql*

    ```
    <copy>
    @02_buffer_query_stats.sql
    </copy>    
    ```

    or run the query below:

    ```
    <copy>
    set timing on
    select /*+ NO_INMEMORY */
     max(lo_ordtotalprice) most_expensive_order,
      sum(lo_quantity) total_items
    from LINEORDER;
    set timing off
    select * from table(dbms_xplan.display_cursor());
    @../imstats.sql
    </copy>
    ```

    Query result:

    ```
    SQL> @02_buffer_query_stats.sql
    Connected.
    SQL>
    SQL> -- Buffer Cache query with the column store disabled via NO_INMEMORY hint
    SQL>
    SQL> select /*+ NO_INMEMORY */
      2    max(lo_ordtotalprice) most_expensive_order,
      3    sum(lo_quantity) total_items
      4  from LINEORDER;

    MOST_EXPENSIVE_ORDER          TOTAL_ITEMS
    -------------------- --------------------
                57346348           1064978115

    Elapsed: 00:00:04.58
    SQL>
    SQL> set echo off
    Hit enter ...


    PLAN_TABLE_OUTPUT
    ------------------------------------------------------------------------------------------------------------------------------------------------------
    SQL_ID  ar655fzccnk1c, child number 0
    -------------------------------------
    select /*+ NO_INMEMORY */   max(lo_ordtotalprice) most_expensive_order,
      sum(lo_quantity) total_items from LINEORDER

    Plan hash value: 4085810105

    --------------------------------------------------------------------------------------------------
    | Id  | Operation            | Name      | Rows  | Bytes | Cost (%CPU)| Time     | Pstart| Pstop |
    --------------------------------------------------------------------------------------------------
    |   0 | SELECT STATEMENT     |           |       |       | 86470 (100)|          |       |       |
    |   1 |  SORT AGGREGATE      |           |     1 |     9 |            |          |       |       |
    |   2 |   PARTITION RANGE ALL|           |    41M|   358M| 86470   (1)| 00:00:04 |     1 |     5 |
    |   3 |    TABLE ACCESS FULL | LINEORDER |    41M|   358M| 86470   (1)| 00:00:04 |     1 |     5 |
    --------------------------------------------------------------------------------------------------


    16 rows selected.

    Hit enter ...


    NAME                                                              VALUE
    -------------------------------------------------- --------------------
    CPU used by this session                                            462
    IM scan segments disk                                                 5
    session logical reads                                            315628
    session pga memory                                             18680056

    SQL>
    ```   

    As you can see the query executed extremely quickly in both cases because this is purely an in-memory scan. However, the performance of the query against the IM column store was significantly faster than the traditional buffer cache - why?  

    The IM column store only has to scan two columns - LO\_ORDTOTALPRICE and LO\_QUANTITY - while the row store has to scan all of the columns in each of the rows until it reaches the LO\_ORDTOTALPRICE and LO\_QUANTITY columns. The IM column store also benefits from the fact that the data is compressed so the volume of data scanned is much less.  Finally, the column format can take advantage of SIMD vector processing (Single Instruction processing Multiple Data values). Instead of evaluating each entry in the column one at a time, SIMD vector processing allows a set of column values to be evaluated together in a single CPU instruction.

    The execution plan shows that the optimizer has chosen an in-memory scan, but to confirm that the IM column store was used, we need to examine the session level statistics. Notice that in the in-memory query several IM statistics show up (for this lab we have only displayed some key statistics – there are lots more!). The only one we are really interested in now is the "IM scan rows".

    IM scan rows: Number of in-memory rows scanned.

    As our query did a full table scan of the LINEORDER table, that session statistic shows that we scanned approximately 41 million rows from the IM column store. Notice that in the second buffer cache query that statistic does not show up. Only one in-memory statistic shows up, "IM scan segments disk" with a value of 1. This means that even though the LINEORDER table is in the IM column store (IM segment) we actually scan that segment outside of the column store from the buffer cache. Since we fully cached the tables in the KEEP pool we are making a memory to memory comparison, and in this case we can verify that the query did no physical IO (if a small number of physical IOs show then try running it again to ensure that it is fully cached in the KEEP pool).

3. Let's look for a specific order in the LINEORDER table based on the order key. Typically, a full table scan is not an efficient execution plan when looking for a specific entry in a table, but there are some things going on in the execution plan that we will take a look at.

    Run the script *03\_single\_key\_im.sql*

    ```
    <copy>
    @03_single_key_im.sql
    </copy>    
    ```

    or run the query below:

    ```
    <copy>
    set timing on
    select  lo_orderkey, lo_custkey, lo_revenue
    from    LINEORDER
    where   lo_orderkey = 5000000;
    set timing off
    select * from table(dbms_xplan.display_cursor());
    @../imstats.sql
    </copy>
    ```

    Query result:

    ```
    SQL> @03_single_key_im.sql
    Connected.
    SQL>
    SQL> -- In-Memory Column Store query
    SQL>
    SQL> select  lo_orderkey, lo_custkey, lo_revenue
      2  from    LINEORDER
      3  where   lo_orderkey = 5000000;

             LO_ORDERKEY           LO_CUSTKEY           LO_REVENUE
    -------------------- -------------------- --------------------
                 5000000                48647              2456268

    Elapsed: 00:00:00.01
    SQL>
    SQL> set echo off
    Hit enter ...


    PLAN_TABLE_OUTPUT
    ------------------------------------------------------------------------------------------------------------------------------------------------------
    SQL_ID  513g163sj3cv2, child number 0
    -------------------------------------
    select  lo_orderkey, lo_custkey, lo_revenue from    LINEORDER where
    lo_orderkey = 5000000

    Plan hash value: 2881531378

    ---------------------------------------------------------------------------------------------------------
    | Id  | Operation                   | Name      | Rows  | Bytes | Cost (%CPU)| Time     | Pstart| Pstop |
    ---------------------------------------------------------------------------------------------------------
    |   0 | SELECT STATEMENT            |           |       |       |  3435 (100)|          |       |       |
    |   1 |  PARTITION RANGE ALL        |           |     4 |    68 |  3435   (7)| 00:00:01 |     1 |     5 |
    |*  2 |   TABLE ACCESS INMEMORY FULL| LINEORDER |     4 |    68 |  3435   (7)| 00:00:01 |     1 |     5 |
    ---------------------------------------------------------------------------------------------------------

    Predicate Information (identified by operation id):
    ---------------------------------------------------

       2 - inmemory("LO_ORDERKEY"=5000000)
           filter("LO_ORDERKEY"=5000000)


    21 rows selected.

    SQL>
    ```

    Notice that in the Predicate Information of the execution plan you see both "inmemory" and "filter". This indicates that the filter predicate (i.e. "LO_ORDERKEY"=5000000) was "pushed" into the scan of the LINEORDER table rather than having to be evaluated after the value was retrieved. This is one of the significant ways that Database In-Memory speeds up queries.

    ```
    Predicate Information (identified by operation id):
    ---------------------------------------------------

       2 - inmemory("LO_ORDERKEY"=5000000)
           filter("LO_ORDERKEY"=5000000)
    ```

4. Let's run the same query in the row format. Typically, a full table scan is not an efficient execution plan when looking for a specific entry in a table, but not all columns are going to be indexed. If we don't have an index how long does it take to run this query in the row store versus the column store?

    Run the script *04\_single\_key\_buffer.sql*

    ```
    <copy>
    @04_single_key_buffer.sql
    </copy>    
    ```

    or run the query below:

    ```
    <copy>
    set timing on
    select /*+ NO_INMEMORY */
      lo_orderkey, lo_custkey, lo_revenue
    from    LINEORDER
    where   lo_orderkey = 5000000;
    set timing off
    select * from table(dbms_xplan.display_cursor());
    </copy>
    ```

    Query result:

    ```
    SQL> @04_single_key_buffer.sql
    Connected.
    SQL>
    SQL> -- Buffer Cache query with the column store disables via INMEMORY_QUERY parameter
    SQL>
    SQL> select /*+ NO_INMEMORY */
      2          lo_orderkey, lo_custkey, lo_revenue
      3  from    LINEORDER
      4  where   lo_orderkey = 5000000;

             LO_ORDERKEY           LO_CUSTKEY           LO_REVENUE
    -------------------- -------------------- --------------------
                 5000000                48647              2456268

    Elapsed: 00:00:02.35
    SQL>
    SQL> set echo off
    Hit enter ...


    PLAN_TABLE_OUTPUT
    ------------------------------------------------------------------------------------------------------------------------------------------------------
    SQL_ID  4rcm8pc7xktun, child number 0
    -------------------------------------
    select /*+ NO_INMEMORY */         lo_orderkey, lo_custkey, lo_revenue
    from    LINEORDER where   lo_orderkey = 5000000

    Plan hash value: 2881531378

    -------------------------------------------------------------------------------------------------
    | Id  | Operation           | Name      | Rows  | Bytes | Cost (%CPU)| Time     | Pstart| Pstop |
    -------------------------------------------------------------------------------------------------
    |   0 | SELECT STATEMENT    |           |       |       | 86258 (100)|          |       |       |
    |   1 |  PARTITION RANGE ALL|           |     4 |    68 | 86258   (1)| 00:00:04 |     1 |     5 |
    |*  2 |   TABLE ACCESS FULL | LINEORDER |     4 |    68 | 86258   (1)| 00:00:04 |     1 |     5 |
    -------------------------------------------------------------------------------------------------

    Predicate Information (identified by operation id):
    ---------------------------------------------------

       2 - filter("LO_ORDERKEY"=5000000)


    20 rows selected.

    SQL>
    ```

    Notice that in the Predicate Information of the execution plan you only see "filter". This indicates that the filter predicate (i.e. "LO_ORDERKEY"=5000000) was evaluated after the value was retrieved. This is another advantage of Database In-Memory, being able to do filtering during the scan of the data.

    ```
    Predicate Information (identified by operation id):
    ---------------------------------------------------

       2 - filter("LO_ORDERKEY"=5000000)
    ```

5. Think indexing lo\_orderkey would provide the same performance as the IM column store? There is an invisible index already created on the lo\_orderkey column of the LINEORDER table. By using the parameter OPTIMIZER\_USE\_INVISIBLE\_INDEXES we can compare the performance of the IM column store to using an index. Let's see how well the index performs.

    Run the script *05\_\index\_comparison.sql*

    ```
    <copy>
    @05_index_comparison.sql
    </copy>    
    ```

    or run the query below:  

    ```
    <copy>
    alter session set optimizer_use_invisible_indexes=true;
    set timing on
    Select  /* With index */ lo_orderkey, lo_custkey, lo_revenue
    From    LINEORDER
    Where   lo_orderkey = 5000000;
    set timing off
    select * from table(dbms_xplan.display_cursor());
    alter session set optimizer_use_invisible_indexes=false;
    </copy>
    ```

    Query result:

    ```
    SQL> @05_index_comparison.sql
    Connected.
    SQL>
    SQL> -- Show query using an index based on cost
    SQL>
    SQL> -- Enable the use of invisible indexes
    SQL>
    SQL> alter session set optimizer_use_invisible_indexes=true;

    Session altered.

    SQL>
    SQL> set timing on
    SQL>
    SQL> Select  /* With index */ lo_orderkey, lo_custkey, lo_revenue
      2  From    LINEORDER
      3  Where   lo_orderkey = 5000000;

             LO_ORDERKEY           LO_CUSTKEY           LO_REVENUE
    -------------------- -------------------- --------------------
                 5000000                48647              2456268

    Elapsed: 00:00:00.03
    SQL>
    SQL> set timing off
    SQL>
    SQL> pause Hit enter ...
    Hit enter ...

    SQL>
    SQL> select * from table(dbms_xplan.display_cursor());

    PLAN_TABLE_OUTPUT
    ------------------------------------------------------------------------------------------------------------------------------------------------------
    SQL_ID  8kgqurq43dgq1, child number 0
    -------------------------------------
    Select  /* With index */ lo_orderkey, lo_custkey, lo_revenue From
    LINEORDER Where   lo_orderkey = 5000000

    Plan hash value: 3247970186

    ---------------------------------------------------------------------------------------------------------------------------
    | Id  | Operation                                  | Name         | Rows  | Bytes | Cost (%CPU)| Time     | Pstart| Pstop |
    ---------------------------------------------------------------------------------------------------------------------------
    |   0 | SELECT STATEMENT                           |              |       |       |    12 (100)|          |       |       |
    |   1 |  PARTITION RANGE ALL                       |              |     4 |    68 |    12   (0)| 00:00:01 |     1 |     5 |
    |   2 |   TABLE ACCESS BY LOCAL INDEX ROWID BATCHED| LINEORDER    |     4 |    68 |    12   (0)| 00:00:01 |     1 |     5 |
    |*  3 |    INDEX RANGE SCAN                        | LINEORDER_I2 |     4 |       |    11   (0)| 00:00:01 |     1 |     5 |
    ---------------------------------------------------------------------------------------------------------------------------

    Predicate Information (identified by operation id):
    ---------------------------------------------------

       3 - access("LO_ORDERKEY"=5000000)


    21 rows selected.

    SQL>
    SQL> alter session set optimizer_use_invisible_indexes=false;

    Session altered.

    SQL>
    ```

    Notice that in the execution plan an INDEX RANGE SCAN was performed on the LINEORDER_I2 index. This is another big benefit of the way that Oracle implemented Database In-Memory. The optimizer, based on cost, is able to determine the most efficient way to access data. In this example, with an appropriate index available, the optimizer decided it was more efficient to use the index. This is why no application SQL has to be changed to use Database In-Memory and also why Database In-Memory can be used in mixed workload environments (i.e. transactions and analytics together).

6. What if you don't have an index that the optimizer can use, but you have populated your data in the IM column store. Will performance suffer? Another feature of Database In-Memory is called In-Memory Storage Indexes. We're going to repeat the query from Step 3, but this time we're going to include a bit more information to see if we can figure out what is going on under the covers.

    Run the script *06\_storage\_index.sql*

    ```
    <copy>
    @06_storage_index.sql
    </copy>    
    ```

    or run the query below:  

    ```
    <copy>
    set timing on
    select  lo_orderkey, lo_custkey, lo_revenue
    from    LINEORDER
    where   lo_orderkey = 5000000;
    set timing off
    select * from table(dbms_xplan.display_cursor());
    @../imstats.sql
    </copy>
    ```

    Query result:

    ```
    SQL> @06_storage_index.sql
    Connected.
    SQL>
    SQL> -- Demonstrate the use of In-Memory Storage Indexes
    SQL>
    SQL> select  lo_orderkey, lo_custkey, lo_revenue
      2  from    LINEORDER
      3  where   lo_orderkey = 5000000;

             LO_ORDERKEY           LO_CUSTKEY           LO_REVENUE
    -------------------- -------------------- --------------------
                 5000000                48647              2456268

    Elapsed: 00:00:00.01
    SQL>
    SQL> set echo off
    Hit enter ...


    PLAN_TABLE_OUTPUT
    ------------------------------------------------------------------------------------------------------------------------------------------------------
    SQL_ID  513g163sj3cv2, child number 0
    -------------------------------------
    select  lo_orderkey, lo_custkey, lo_revenue from    LINEORDER where
    lo_orderkey = 5000000

    Plan hash value: 2881531378

    ---------------------------------------------------------------------------------------------------------
    | Id  | Operation                   | Name      | Rows  | Bytes | Cost (%CPU)| Time     | Pstart| Pstop |
    ---------------------------------------------------------------------------------------------------------
    |   0 | SELECT STATEMENT            |           |       |       |  3435 (100)|          |       |       |
    |   1 |  PARTITION RANGE ALL        |           |     4 |    68 |  3435   (7)| 00:00:01 |     1 |     5 |
    |*  2 |   TABLE ACCESS INMEMORY FULL| LINEORDER |     4 |    68 |  3435   (7)| 00:00:01 |     1 |     5 |
    ---------------------------------------------------------------------------------------------------------

    Predicate Information (identified by operation id):
    ---------------------------------------------------

       2 - inmemory("LO_ORDERKEY"=5000000)
           filter("LO_ORDERKEY"=5000000)


    21 rows selected.

    Hit enter ...


    NAME                                                              VALUE
    -------------------------------------------------- --------------------
    CPU used by this session                                              4
    IM scan CUs columns accessed                                          8
    IM scan CUs memcompress for query low                                78
    IM scan CUs pruned                                                   72
    IM scan rows                                                   41760941
    IM scan rows projected                                                1
    IM scan rows valid                                              3194241
    IM scan segments minmax eligible                                     78
    session logical reads                                            315586
    session logical reads - IM                                       315480
    session pga memory                                             17959160
    table scans (IM)                                                      5

    12 rows selected.

    SQL>
    ```

    Note that we are now back to an inmemory query. This time we included the session statistics for the query. Take note of two key statistics. The first is "IM scan CUs memcompress for query low". This tells us how many IMCUs the data is populated into. The second important statistic is "IM scan CUs pruned". Notice that this number is almost as large as the total number of IMCUs. This means that Database In-Memory was able to avoid scanning almost all of the data. This is because at population time In-Memory storage indexes are created for each set of column values in each IMCU with the MIN and MAX values. During the scan these MIN and MAX values can be compared with filter predicates and can possibly result in not having to scan the actual columnar data thereby improving performance. After all, the fastest way to do something is to not do it at all.  

7. Analytical queries typically have more than one WHERE clause predicate. What happens when there are multiple single column predicates on a table? Traditionally you would create a multi-column index. Can storage indexes compete with that?  

    Let’s change our query to look for a specific line item in an order and monitor the session statistics:

    Run the script *07\_multi\_preds.sql*

    ```
    <copy>
    @07_multi_preds.sql
    </copy>    
    ```

    or run the query below:  

    ```
    <copy>
    set timing on
    select  lo_orderkey, lo_custkey, lo_revenue
    from    LINEORDER
    where    lo_custkey = 5641
    and      lo_shipmode = 'SHIP'
    and      lo_orderpriority = '5-LOW';
    set timing off
    select * from table(dbms_xplan.display_cursor());
    @../imstats.sql
    </copy>
    ```

    Query result:

    ```
    SQL> @07_multi_preds.sql
    Connected.
    SQL>
    SQL> -- In-Memory query
    SQL>
    SQL> select  lo_orderkey, lo_custkey, lo_revenue
      2  from    LINEORDER
      3  where    lo_custkey = 5641
      4  and      lo_shipmode = 'SHIP'
      5  and      lo_orderpriority = '5-LOW';

             LO_ORDERKEY           LO_CUSTKEY           LO_REVENUE
    -------------------- -------------------- --------------------
                16925125                 5641              5711620
                16925125                 5641              6400967
                18139779                 5641              4508300
                27479847                 5641              7247038
                27479847                 5641              4341522
                22534688                 5641               705728
                22534688                 5641              3400905
                28390534                 5641               486770
                59428583                 5641              6083192
                59428583                 5641              3904048
                40154336                 5641              3052806
                13644419                 5641              3786727
                51805731                 5641              4164048

    13 rows selected.

    Elapsed: 00:00:00.05
    SQL>
    SQL> set echo off
    Hit enter ...


    PLAN_TABLE_OUTPUT
    ------------------------------------------------------------------------------------------------------------------------------------------------------
    SQL_ID  gcrg8wtsj5wxh, child number 0
    -------------------------------------
    select  lo_orderkey, lo_custkey, lo_revenue from    LINEORDER where
    lo_custkey = 5641 and      lo_shipmode = 'SHIP' and
    lo_orderpriority = '5-LOW'

    Plan hash value: 2881531378

    ---------------------------------------------------------------------------------------------------------
    | Id  | Operation                   | Name      | Rows  | Bytes | Cost (%CPU)| Time     | Pstart| Pstop |
    ---------------------------------------------------------------------------------------------------------
    |   0 | SELECT STATEMENT            |           |       |       |  3281 (100)|          |       |       |
    |   1 |  PARTITION RANGE ALL        |           |     6 |   264 |  3281   (3)| 00:00:01 |     1 |     5 |
    |*  2 |   TABLE ACCESS INMEMORY FULL| LINEORDER |     6 |   264 |  3281   (3)| 00:00:01 |     1 |     5 |
    ---------------------------------------------------------------------------------------------------------

    Predicate Information (identified by operation id):
    ---------------------------------------------------

       2 - inmemory(("LO_CUSTKEY"=5641 AND "LO_SHIPMODE"='SHIP' AND "LO_ORDERPRIORITY"='5-LOW'))
           filter(("LO_CUSTKEY"=5641 AND "LO_SHIPMODE"='SHIP' AND "LO_ORDERPRIORITY"='5-LOW'))


    22 rows selected.

    Hit enter ...


    NAME                                                              VALUE
    -------------------------------------------------- --------------------
    CPU used by this session                                              7
    IM scan CUs columns accessed                                        170
    IM scan CUs memcompress for query low                                78
    IM scan rows                                                   41760941
    IM scan rows projected                                               13
    IM scan rows valid                                             41760941
    IM scan segments minmax eligible                                     78
    physical reads                                                       14
    session logical reads                                            315684
    session logical reads - IM                                       315480
    session pga memory                                             18286840
    table scans (IM)                                                      5

    12 rows selected.

    SQL>
    ```   

    In this example you can see in the Predicate Information section that multiple filter predicates were included in the "inmemory" function. Database In-Memory is not limited to pushing only single predicates into a scan.  There is another important statistic that can be used to measure how much work is saved by pushing predicates into the scan. Notice the statistic "IM scan rows projected". The value is 13 which is precisely the number of rows returned by the query. This statistic shows that even though we scanned 41 million rows we only returned 13 rows. That is another reason Database In-Memory is so much faster than the row store.


8. Let’s get a bit more complicated and see what happens when we have more complex where clause predicates that include multiple columns and subselects. The query this time is to determine which of the expensive bulk orders generated the least amount of revenue for the company when shipped by truck.

    Run the script *08\_multi\_col.sql*

    ```
    <copy>
    @08_multi_col.sql
    </copy>    
    ```

    or run the query below:  

    ```
    <copy>
    set timing on
    select lo_orderkey, lo_revenue
    From   LINEORDER
    Where  lo_revenue = (Select min(lo_revenue)
                         From LINEORDER
                         Where lo_supplycost = (Select max(lo_supplycost)
                                                From  LINEORDER
                                                Where lo_quantity > 10)
                         And lo_shipmode LIKE 'TRUCK%'
                         And lo_discount between 2 and 5
                        );
    set timing off
    select * from table(dbms_xplan.display_cursor());
    @../imstats.sql
      </copy>
    ```

    Query result:

    ```
    SQL> @08_multi_col.sql
    Connected.
    SQL>
    SQL> -- In-Memory query
    SQL>
    SQL> Select lo_orderkey, lo_revenue
      2  From   LINEORDER
      3  Where  lo_revenue = (Select min(lo_revenue)
      4                       From LINEORDER
      5                       Where lo_supplycost = (Select max(lo_supplycost)
      6                                              From  LINEORDER
      7                                              Where lo_quantity > 10)
      8                       And lo_shipmode LIKE 'TRUCK%'
      9                       And lo_discount between 2 and 5
     10                      );

             LO_ORDERKEY           LO_REVENUE
    -------------------- --------------------
                 5335335               199404
                 3842596               199404
                21888516               199404
                49976640               199404

    Elapsed: 00:00:00.06
    SQL>
    SQL> set echo off
    Hit enter ...


    PLAN_TABLE_OUTPUT
    ------------------------------------------------------------------------------------------------------------------------------------------------------
    SQL_ID  bnysz8dqbamnd, child number 0
    -------------------------------------
    Select lo_orderkey, lo_revenue From   LINEORDER Where  lo_revenue =
    (Select min(lo_revenue)                      From LINEORDER
             Where lo_supplycost = (Select max(lo_supplycost)
                                  From  LINEORDER
                      Where lo_quantity > 10)                      And
    lo_shipmode LIKE 'TRUCK%'                      And lo_discount between
    2 and 5                     )

    Plan hash value: 230990116

    ---------------------------------------------------------------------------------------------------------------
    | Id  | Operation                         | Name      | Rows  | Bytes | Cost (%CPU)| Time     | Pstart| Pstop |
    ---------------------------------------------------------------------------------------------------------------
    |   0 | SELECT STATEMENT                  |           |       |       | 11416 (100)|          |       |       |
    |   1 |  PARTITION RANGE ALL              |           |     7 |    84 |  3697  (14)| 00:00:01 |     1 |     5 |
    |*  2 |   TABLE ACCESS INMEMORY FULL      | LINEORDER |     7 |    84 |  3697  (14)| 00:00:01 |     1 |     5 |
    |   3 |    SORT AGGREGATE                 |           |     1 |    25 |            |          |       |       |
    |   4 |     PARTITION RANGE ALL           |           |    75 |  1875 |  4022  (21)| 00:00:01 |     1 |     5 |
    |*  5 |      TABLE ACCESS INMEMORY FULL   | LINEORDER |    75 |  1875 |  4022  (21)| 00:00:01 |     1 |     5 |
    |   6 |       SORT AGGREGATE              |           |     1 |     8 |            |          |       |       |
    |   7 |        PARTITION RANGE ALL        |           |    33M|   254M|  3697  (14)| 00:00:01 |     1 |     5 |
    |*  8 |         TABLE ACCESS INMEMORY FULL| LINEORDER |    33M|   254M|  3697  (14)| 00:00:01 |     1 |     5 |
    ---------------------------------------------------------------------------------------------------------------

    Predicate Information (identified by operation id):
    ---------------------------------------------------

       2 - inmemory("LO_REVENUE"=)
           filter("LO_REVENUE"=)
       5 - inmemory(("LO_SHIPMODE" LIKE 'TRUCK%' AND "LO_DISCOUNT"<=5 AND "LO_DISCOUNT">=2 AND
                  "LO_SUPPLYCOST"=))
           filter(("LO_SHIPMODE" LIKE 'TRUCK%' AND "LO_DISCOUNT"<=5 AND "LO_DISCOUNT">=2 AND
                  "LO_SUPPLYCOST"=))
       8 - inmemory("LO_QUANTITY">10)
           filter("LO_QUANTITY">10)


    38 rows selected.

    Hit enter ...


    NAME                                                              VALUE
    -------------------------------------------------- --------------------
    CPU used by this session                                              8
    IM scan CUs columns accessed                                        379
    IM scan CUs memcompress for query low                               234
    IM scan CUs pcode aggregation pushdown                               81
    IM scan CUs pruned                                                   32
    IM scan rows                                                  125282823
    IM scan rows pcode aggregated                                  33408482
    IM scan rows projected                                               85
    IM scan rows valid                                            108087449
    IM scan segments minmax eligible                                    234
    physical reads                                                        2
    session logical reads                                            946598
    session logical reads - IM                                       946440
    session pga memory                                             18155768
    table scans (IM)                                                     15

    15 rows selected.

    SQL>
    ```  

    Even with the all of these complex predicates the optimizer chose an in-memory query, showing that for large scan operations it is the most efficient approach.

9. Exit lab

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
    [CDB1:oracle@dbhol:~/labs/inmemory/queries]$ cd ..
    [CDB1:oracle@dbhol:~/labs/inmemory]$
    ```

## Conclusion

In this lab you had an opportunity to try out Oracle’s In-Memory performance claims with queries that run against a table with over 41 million rows, the LINEORDER table, which resides in both the IM column store and the buffer cache KEEP pool. From a very simple aggregation, to more complex queries with multiple columns and filter predicates, the IM column store was able to out perform the buffer cache queries. Remember both sets of queries are executing completely within memory, so that’s quite an impressive improvement.

These significant performance improvements are possible because of Oracle’s unique in-memory columnar format that allows us to only scan the columns we need and to take full advantage of SIMD vector processing. We also got a little help from our new in-memory storage indexes, which allow us to prune out unnecessary data. Remember that with the IM column store, every column has a storage index that is automatically maintained for you.

You may now **proceed to the next lab**.

## Acknowledgements

- **Author** - Andy Rivenes, Product Manager, Database In-Memory
- **Contributors** - Maria Colgan, Distinguished Product Manager
- **Last Updated By/Date** - Andy Rivenes, August 2022
