# Create and Populate In-Memory Hybrid Tables

## Introduction

Oracle Database enables the population of data from external tables into the In-Memory column store (IM column store). This allows the population of data that is not stored in Oracle Database but in source data files. Nevertheless, the population must be completed manually by executing the DBMS_INMEMORY.POPULATE procedure.

A hybrid partitioned table enables partitions to reside both in database data files (internal partitions) and in external files and sources (external partitions). You can create and query a hybrid partitioned table to utilize the benefits of partitioning with classic partitioned tables, such as pruning, on data that is contained in both internal and external partitions.

You can use the `EXTERNAL PARTITION ATTRIBUTES` clause of the `CREATE TABLE` statement to determine hybrid partitioning for a table. The partitions of the table can be external and or internal.

The `EXTERNAL PARTITION ATTRIBUTES` clause of the `CREATE TABLE` statement is defined at the table level for specifying table level external parameters in the hybrid partitioned table, such as:

* The access driver type, such as `ORACLE_LOADER`, `ORACLE_DATAPUMP`, `ORACLE_HDFS`, `ORACLE_HIVE`
* The default directory for all external partitions files
* The access parameters

The EXTERNAL clause of the PARTITION clause defines the partition as an external partition. When there is no EXTERNAL clause, the partition is an internal partition. You can specify for each external partition different attributes than the default attributes defined at the table level, such the directory.

In Oracle Database 19c, querying an in-memory enabled external table automatically initiates the population of the external data into the In-Memory column store.

### Objectives

In this lab, you will:
* Configure the In-Memory Column Store Size
* Create the Tablespaces for the Internal Partitions
* Create the Logical Directories for the External Partitions
* Create the In-Memory Hybrid Partitioned Table
* Insert Data Into the Partitions
* Determine How Data in Internal and External Partitions is Accessed
* Reset Your Environment

### Prerequisites

This lab assumes you have:
* Obtained and signed in to your `workshop-installed` compute instance.

## Task 1: Configure the In-Memory Column Store Size

> **NOTE:** Unless otherwise stated, all passwords will be `Ora4U_1234`. When copying and pasting a command that includes a password, please replace the word `password` with `Ora4U_1234`. This only applies to instances created through OCI Resource Manager with our provided terraform scripts.

1. Set the In-Memory column store size to 800M.

    ```
    $ <copy>. oraenv</copy>
    CDB1
    ```

    ```
    $ <copy>sqlplus / as sysdba</copy>

    ...
    
    SQL>
    ```

    ```
    SQL> <copy>ALTER SYSTEM SET inmemory_SIZE = 800M SCOPE=SPFILE;</copy>

    System altered.

    SQL>
    ```
2. Restart the instance and open the database.

    ```
    SQL> <copy>SHUTDOWN IMMEDIATE</copy>

    ...

    SQL>
    ```

    ```
    SQL> <copy>STARTUP</copy>

    ...

    SQL>
    ```

    ```
    SQL> <copy>ALTER PLUGGABLE DATABASE pdb1 OPEN;</copy>
    ```

## Task 2: Create the Tablespaces for the Internal Partitions

In this task, you create two tablespaces to store data of the internal partitions. One of the two tablespaces will be the default tablespace for internal partitions.

1. Log into `PDB1` as SYSTEM.

    ```
    SQL> <copy>CONNECT system / password@PDB1</copy>

    Connected.

    SQL>
    ```
2. Create the tablespaces `ts1` and `ts2` to store internal partitions of the hybrid partitioned table.

    ```
    SQL> <copy>CREATE TABLESPACE ts1 DATAFILE '/u01/app/oracle/oradata/CDB1/PDB1/ts1.dbf' SIZE 100M;</copy>

    Tablespace created.

    SQL>
    ```

    ```
    SQL> <copy>CREATE TABLESPACE ts2 DATAFILE '/u01/app/oracle/oradata/CDB1/PDB1/ts2.dbf' SIZE 100M;</copy>

    Tablespace created.

    SQL>
    ```
## Task 3: Create the Logical Directories for the External Partitions

In this task, you create the logical directories to store the source data files for external partitions.

1. Create the logical directory `CENT18` to store the source data file `cent18.dat` for the `CENT18` external partition.

    ```
    SQL> <copy>CREATE DIRECTORY cent18 AS '/home/oracle/labs/19cnf/CENT18';</copy>

    Directory created.

    SQL>
    ```

2. Create the logical directory `CENT19` to store the source data file `cent19.dat` for the `CENT19` external partition.

    ```
    SQL> <copy>CREATE DIRECTORY cent19 AS '/home/oracle/labs/19cnf/CENT19';</copy>

    Directory created.

    SQL>
    ```

3. Create the logical directory `CENT20` to store the source data file `cent20.dat` for the `CENT20` external partition.

    ```
    SQL> <copy>CREATE DIRECTORY cent20 AS '/home/oracle/labs/19cnf/CENT20';</copy>

    Directory created.

    SQL>
    ```

## Task 4: Create the In-Memory Hybrid Partitioned Table

1. Create the user that owns the in-memory hybrid partitioned table.

    ```
    SQL> <copy>CREATE USER hypt IDENTIFIED BY password;</copy>

    User created.

    SQL>
    ```
2. Grant the read and write privileges on the directories that store the source data files to the table owner.

    ```
    SQL> <copy>GRANT read, write ON DIRECTORY cent18 TO hypt;</copy>

    Grant succeeded.

    SQL>
    ```

    ```
    SQL> <copy>GRANT read, write ON DIRECTORY cent19 TO hypt;</copy>

    Grant succeeded.

    SQL>
    ```

    ```
    SQL> <copy>GRANT read, write ON DIRECTORY cent20 TO hypt;</copy>

    Grant succeeded.

    SQL>
    ```

3. Grant the `CREATE SESSION`, `CREATE TABLE`, and `UNLIMITED TABLESPACE` privileges to the table owner.

    ```
    SQL> <copy>GRANT create session, create table, unlimited tablespace TO hypt;</copy>

    Grant succeeded.

    SQL>
    ```
4. Execute the following command to create the `HYPT_INMEM_TAB` hybrid partitioned table with the following attributes:
* The table is partitioned by range on the `TIME_ID` column.
* The default tablespace for internal partitions is `TS1`.
* The default tablespace for external partitions is `CENT20`.
* The fields in the records of the external files are separated by comma ','.
* The table is partitioned into five parts:
    * Three external partitions: `CENT18` is empty for the moment; `CENT19` has the `cent19.dat` file stored in a directory other than the default, `CENT19`; `CENT20` has the `cent20.dat` file stored in the default directory.
    * Two internal partitions: `Y2000` is stored in tablespace `TS2` and `PMAX` is stored in the default tablespace `TS1`.

    ```
    SQL> <copy>CREATE TABLE hypt.hypt_inmem_tab
      (history_event NUMBER , time_id DATE) 
       TABLESPACE ts1 
       EXTERNAL PARTITION ATTRIBUTES 
       (TYPE ORACLE_LOADER 
        DEFAULT DIRECTORY cent20 
        ACCESS PARAMETERS
         (FIELDS TERMINATED BY ','
          (history_event , time_id DATE 'dd-MON-yyyy')
         )
         REJECT LIMIT UNLIMITED
        ) 
   PARTITION BY RANGE (time_id) 
   (PARTITION cent18 VALUES LESS THAN 
     (TO_DATE('01-Jan-1800','dd-MON-yyyy')) EXTERNAL,
    PARTITION cent19 VALUES LESS THAN 
     (TO_DATE('01-Jan-1900','dd-MON-yyyy')) EXTERNAL 
	                 DEFAULT DIRECTORY cent19 
				 LOCATION ('cent19.dat'),
    PARTITION cent20 VALUES LESS THAN 
     (TO_DATE('01-Jan-2000','dd-MON-yyyy')) EXTERNAL 
	                          LOCATION('cent20.dat'),
    PARTITION y2000 VALUES LESS THAN 
     (TO_DATE('01-Jan-2001','dd-MON-yyyy')) TABLESPACE ts2,
    PARTITION pmax VALUES LESS THAN (MAXVALUE))
   INMEMORY MEMCOMPRESS FOR QUERY HIGH;
    </copy>
    Table created.

    SQL>
    ```
1. Find the partitions that are defined as in-memory segments.

    ```
    SQL> <copy>SELECT partition_name, inmemory, inmemory_compression FROM dba_tab_partitions WHERE table_name = 'HYPT_INMEM_TAB';</copy>

     ...

    PARTITION_NAME  INMEMORY  INMEMORY_COMPRESS
    --------------  --------  -----------------
    CENT18          DISABLED
    CENT19          DISABLED
    CENT20          DISABLED
    PMAX            ENABLED   FOR QUERY HIGH
    Y2000           ENABLED   FOR QUERY HIGH

    SQL>
    ```
    Only internal partitions are defined as in-memory segments.

## Task 5: Insert Data Into the Partitions

1. Execute the `insert_select_bd.sql` SQL script to insert rows into the different partitions of the table and query the table.

    ```
    SQL> <copy>@/home/oracle/labs/19cnf/insert_select_bd.sql</copy>

    ...

    30 rows selected.

    SQL>
    ```
    > **Note**: Number of rows selected subject to change.
    
    The execution of the query on the table rows automatically populates the data into the `IM` column store.

2. Verify which partitions are populated into the `IM` column store.

    ```
    SQL> <copy>SELECT segment_name, partition_name, tablespace_name, populate_status FROM v$im_segments;</copy>

    ...

    SEGMENT_NAME    PARTITION_NAME TABLESPACE_NAME POPULATE_STAT
    --------------  -------------- --------------  -------------
    HYPT_INMEM_TAB  PMAX           TS1             COMPLETED
    HYPT_INMEM_TAB  Y2000          TS2             COMPLETED
    ```
    Only the partitions defined as in-memory segments are populated into the `IM` column store, and thus the internal partitions.

## Task 6: Determine How Data in Internal and External Partitions is Accessed

1. Display the execution plan for a query on all rows in the table.

    ```
    SQL> <copy>EXPLAIN PLAN FOR SELECT * FROM hypt.hypt_inmem_tab;</copy>

    Explained.

    SQL>
    ```
    ```
    SQL> <copy>SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);</copy>

    ...

    PLAN_TABLE_OUTPUT
    ------------------------------------------------------------------------------------------------------------------------------
    | Id | Operation                                | Name              | Rows | Bytes | Cost  (%CPU) | Time     | Pstart|  Pstop|
    ------------------------------------------------------------------------------------------------------------------------------
    |   0| SELECT STATEMENT                         |                   | 368K | 7917K |    778   (11)| 00:00:01 |       |       |
    |   1| PARTITION RANGE ALL                      |                   | 368K | 7917K |    778   (11)| 00:00:01 |    1  |    5  |
    |   2| TABLE ACCESS HYBRID PART INMEMORY FULL   | HYPT_INMEM_TAB    | 368K | 7917K |    778   (11)| 00:00:01 |    1  |    5  |
    |   3| TABLE ACCESS INMEMORY FULL               | HYPT_INMEM_TAB    |      |       |              |          |    1  |    5  |
    ------------------------------------------------------------------------------------------------------------------------------
    ```
    > **Note**: Table values subject to change.

2. Display the execution plan for a query on the rows of one of the internal partition in the table.

    ```
    SQL> <copy>EXPLAIN PLAN FOR SELECT * FROM hypt.hypt_inmem_tab PARTITION (PMAX);</copy>

    Explained.

    SQL>
    ```
    ```
    SQL> <copy>SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);</copy>

    ...

    PLAN_TABLE_OUTPUT
    ------------------------------------------------------------------------------------------------------------------------------
    | Id | Operation                                | Name              | Rows | Bytes | Cost  (%CPU) | Time     | Pstart|  Pstop|
    ------------------------------------------------------------------------------------------------------------------------------
    |   0| SELECT STATEMENT                         |                   | 82171 | 1765K |    25   (56)| 00:00:01 |       |       |
    |   1| PARTITION RANGE SINGLE                   |                   | 82171 | 1765K |    25   (56)| 00:00:01 |    5  |    5  |
    |   2| TABLE ACCESS INMEMORY FULL               | HYPT_INMEM_TAB    | 82171 | 1765K |    25   (56)| 00:00:01 |    5  |    5  |
    ------------------------------------------------------------------------------------------------------------------------------
    ```
    > **Note**: Table values subject to change.

3. Display the execution plan for a query on the rows of one of the external partition in the table.

    ```
    SQL> <copy>EXPLAIN PLAN FOR SELECT * FROM hypt.hypt_inmem_tab PARTITION (CENT19);</copy>

    Explained.

    SQL>
    ```
    ```
    SQL> <copy>SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);</copy>

    ...

    PLAN_TABLE_OUTPUT
    ------------------------------------------------------------------------------------------------------------------------------
    | Id | Operation                                | Name              | Rows | Bytes | Cost  (%CPU) | Time     | Pstart|  Pstop|
    ------------------------------------------------------------------------------------------------------------------------------
    |   0| SELECT STATEMENT                         |                   | 8169 | 175K |    31   (7)| 00:00:01 |       |       |
    |   1| PARTITION RANGE SINGLE                   |                   | 8169 | 175K |    31   (7)| 00:00:01 |    2  |    2  |
    |   2| EXTERNAL TABLE ACCESS FULL               | HYPT_INMEM_TAB    | 8169 | 175K |    31   (7)| 00:00:01 |    2  |    2  |
    ------------------------------------------------------------------------------------------------------------------------------
    ```
    > **Note**: Table values subject to change.

   According to the type of partition accessed and the number of partitions accessed at the same time, the operation shows either `EXTERNAL TABLE ACCESS FULL` (external partitions, not `INMEMORY`), `TABLE ACCESS INMEMORY FULL` (internal partitions, `INMEMORY`) or `HYBRID PART INMEMORY FULL` (both internal and external partitions). 

## Task 7: Reset Your Environment

1. Drop the in-memory hybrid partitioned `HYPT.HYPT_INMEM_TAB` table.

    ```
    SQL> <copy>DROP TABLE hypt.hypt_inmem_tab PURGE;</copy>

    Table dropped.

    SQL>
    ```
2. Quit the SQL session.

    ```
    SQL> <copy>EXIT</copy>
    
    ...

    $
    ```
3. Cleanup the PDBs by running the `cleanup_PDBs_in_CDB1.sh` script.

    ```
    $ <copy>sh $HOME/labs/19cnf/cleanup_PDBs_in_CDB1.sh</copy>

    ...

    $
    ```

## Learn More

- [Managing Hybrid Partitioned Tables](https://docs.oracle.com/en/database/oracle/oracle-database/19/vldbg/manage_hypt.html#GUID-ACBDB3B2-0A16-4CFD-8FF1-A57C9B3D907F)
- [Enhanced In-Memory External Table Support](https://blogs.oracle.com/in-memory/post/oracle-database-21c-enhanced-in-memory-external-table-support)

## Acknowledgements 

- **Author**- Dominique Jeunot, Consulting User Assistance Developer
- **Last Updated By/Date** - Ethan Shmargad, Santa Monica Specialists Hub, January 2022


