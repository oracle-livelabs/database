# Optimize the Design for Concurrency

## Introduction

In this lab, you will continue to modify the physical design to improve benchmark performance without changing the application code.

Estimated lab time: 15 minutes

### Prerequisites

-   This lab requires completing the preceding labs in the Contents menu on the left.

## Task 1: Run Benchmark3 via Cloud Shell

1. Using Cloud Shell, run the benchmark3 shell script.

    If you are already in the home directory, you can skip the initial CD command.

    ```
    <copy>
    cd ~
    ./benchmark3.sh
    </copy>
    ```

    The script will connect to your autonomous database and rebuilds the schema from scratch.  The only elements presented verbosely on screen are those changed from the initial baseline.

    You may have noticed the element _enq: SQ contention_ from the previous benchmark. This performance inhibitor occurs when multiple sessions attempt to manage the dictionary objects for sequences. They are all competing for exclusive access to an internal table which contains the current sequence number. The number of times a session must access this internal object be reduced by increasing the cache size. Consider raising the cache size above the default for any high-activity sequence.

    ![how the changes in Sequence caching in benchmark 3](./images/c1-sequence-cache-changes.png " ")

    Every index you create in a database schema adds to the overhead of creating rows. Of course, this is not to say that all indexes can be dropped because they are vital for query performance and declarative data integrity, such as primary keys and unique constraints. Similarly, foreign key indexes are essential, but it is easy to go "overboard" and adopt an index on _every_ column involved in a foreign key relation back to the parent table. In early versions of the Oracle Database, this was best practice because there were locking implications associated with any DML (insert, update, delete) on columns that were also foreign keys.

    However, many of these locking concerns have been removed in recent versions. Foreign indexes to reduce locks are only required for the scenarios when you might modify the _parent table primary key_ (e.g. update it or delete the row). If this will never be the case, then the justification for a foreign key index falls back to that of the reason for _any_ index, namely, is there is a use case where it will improve query performance.

    Since a customer will likely want to query their orders in our database schema, we will be _keeping_ the foreign key index that links ORDERS to CUSTOMERS. However, it is unlikely (for this lab scenario) that there will be queries exclusively on just the product ID, or if there were, they are likely to be analytic style queries (e.g. total sales by product for the year) and thus an index on PRODUCT\_ID on the ORDER\_ITEMS table is probably superfluous. Similarly, it is doubtful that we would ever delete the associated orders if we wanted to delete a product entirely from the shop catalogue.  The product would be flagged as no longer available so that the orders would remain in the database for financial reporting.

    Thus the index linking ORDER\_ITEMS to PRODUCT will _not_ be retained because it is just an inhibitor of performance without any justifiable benefit.

    ![Indexes which are created for foreign keys](./images/c2-indexes-which-are-created.png " ")

    Remember your goal should always be to have *just enough indexes*

    The script will load the rest of the schema and launch the benchmark without further input required.

    ![Sessions are ready for benchmark start](./images/c3-sessions-ready-for-benchmark-start.png " ")

    The eight sessions will be launched, and the initiating commit will occur automatically. Thus you need to wait for the benchmark to complete.

## Task 2: Review the Results

1. The benchmark will produce a similar performance summary to the previous executions.

    ![The results for Benchmark 3](./images/c4-benchmark3-results.png " ")

    As mentioned earlier, your results will be different, but using the results in the image above, you can observe that the revised design has lifted the caching sizes for the critical sequences and eliminated unnecessary indexes:

    - Throughput has improved **4452** transactions per second (up from 2609)
    - Elapsed time per session has improved to **18** seconds (down from 31)
    - CPU time is still at only **48** per cent of the total benchmark time

    The performance benefits are excellent, but the CPU utilisation is still approximately half of the machine capacity, which suggests there are still benefits to be found by adjusting the design.

2. If you have not done so already, press Enter to exit the benchmark.


## Task 3: Final benchmark

1. Using Cloud Shell, run the benchmark4 shell script. This is the final set of changes to the database design to improve performance.

    If you are already in the home directory, you can skip the initial CD command.

    ```
    <copy>
    cd ~
    ./benchmark4.sh
    </copy>
    ```

    The script will connect to your autonomous database and rebuilds the schema from scratch.  The only elements presented verbosely on screen are those changed from the initial baseline.

    From the previous benchmark, components _gc index operation_and _buffer busy waits_ indicate that multiple sessions compete for common memory blocks. A block is the fundamental Oracle database storage unit for tables and indexes. As sessions try to insert rows into the database rapidly, common blocks are being competed for in memory.

    By utilising the _Partitioning_ facilities available in the Oracle Database, a single database object (such as a table or index) can be split into multiple physical objects in the database. This distributes competition for the blocks across multiple physical objects, thus reducing contention and allowing for more excellent performance.

    ![Tables with partitioning are created](./images/c5-creation-of-partitioned-tables.png " ")

    In this example, hash partitioning is used to split tables into equal-sized segments to distribute contention for blocks. Indexes can be split like-wise, and often, indexes are the best candidates for partitioning to ease contention, even if the underlying table is not partitioned. Index entries must be stored in key order, so for index keys that are always ascending (e.g. sequence values or timestamps), there is a greater risk of contention for the leading index blocks. Hash partitioning a primary or unique key index can often be the ideal solution.

    The script will pause when it has rebuilt the schema back to the state and is ready to launch the benchmark. The eight sessions will be launched, and the initiating commit will occur automatically. Thus you need to wait for the benchmark to complete.

## Task 4: Review the results

1. The benchmark will produce a similar performance summary to the previous executions.

    ![Benchmark results after partitioning the tables](./images/c6-benchmark3-results-with-partitioned-tables.png " ")

    As mentioned earlier, your results will be different, but using the results in the image above, you can observe that the revised design has lifted the caching sizes for the critical sequences and eliminated unnecessary indexes:

    - Throughput has improved **7338** transactions per second (up from 4452)
    - Elapsed time per session has improved to **10** seconds (down from 18)
    - CPU time is now at only **84** per cent of the total benchmark time

    The performance benefits are excellent, but the CPU utilisation is still approximately half of the machine capacity, which suggests there are still benefits to be found by adjusting the design.

    If you have not done so already, press Enter to exit the benchmark.

## Summary ##

Take a minute to review the gains made by simply optimising the database design to suit the required workload. Remember that in this lab, _no changes_ were made to the server configuration, and _no changes_ were made to the application code that ran the benchmark. Yet even with no changes, consider the performance benefits obtained from the initial baseline benchmark to the final design:

- From **1524** transactions per second to **7338** transactions per second (480%)
- **52** seconds average elapsed time per session to 10 seconds. (520%)

If you prefer to think of this reverse, an existing workload will use five times less server resources, ultimately equating to your business cost savings.

Similarly, notice that the final benchmark was predominantly CPU bound. Whilst being CPU-bound may sound like a bad thing, being able to utilise _all_ of your CPU without hindrance means that you are getting the best return on your Cloud investment and also is a strong indicator that if you choose to scale up your infrastructure (either manually or via AutoScale) then you will obtain performance benefits rather than hit performance bottlenecks.

**Congratulations! You have completed all labs**


## Want to Learn More?

For more information on the [caching](https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/CREATE-SEQUENCE.html#GUID-E9C78A8C-615A-4757-B2A8-5E6EFB130571) of sequences. Also [indexes](https://docs.oracle.com/en/database/oracle/oracle-database/19/admin/managing-indexes.html#GUID-E4149397-FF37-4367-A12F-675433715904) and their relationship to [foreign keys](https://docs.oracle.com/en/database/oracle/oracle-database/19/cncpt/data-integrity.html#GUID-6A89FF39-AD42-4399-BD1B-E51ECEE50B4E). If you are new partitioning, there is an [introductory](https://asktom.oracle.com/partitioning-for-developers.htm) series, or refer to the standard [documentation](https://docs.oracle.com/en/database/oracle/oracle-database/19/vldbg/)

## Acknowledgements

- **Author** - Connor McDonald, Database Advocate
- **Last Updated By/Date** - Robert Pastijn, September 2022
