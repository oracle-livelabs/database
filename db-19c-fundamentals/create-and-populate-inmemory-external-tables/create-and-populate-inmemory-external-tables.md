# Create and populate In-Memory external tables

## About this Workshop

Oracle Database 19c enables the population of data from external tables into the In-Memory column store (IM column store). This allows the population of data that is not stored in Oracle Database but in source data files. Nevertheless, the population must be completed manually by executing the `DBMS_INMEMORY.POPULATE` procedure.

In Oracle Database 19c, querying an in-memory enabled external table automatically initiates the population of the external data into the IM column store.

Estimated Time: 15 minutes


### Objectives

In this lab, you will:

- Prepare the environment
- Configure the IM Column Store Size
- Create the Logical Directories for the External Source Files
- Create the In-Memory External Table
- Query the In-Memory External Table
- Find How Data In In-Memory External Table Is Accessed
- Clean Up the Environment


### Prerequisites

This lab assumes you have:
- Obtained and signed in to your `workshop-installed` compute instance.

## Task 1: Prepare the environment

> **NOTE:** Unless otherwise stated, all passwords will be `Ora4U_1234`. When copying and pasting a command that includes a password, please replace the word `password` with `Ora4U_1234`. This only applies to instances created through OCI Resource Manager with our provided terraform scripts.

1. Open a terminal window on the desktop.

2. Set the Oracle environment variables. At the prompt, enter **CDB1**.

    ```
    $ <copy>. oraenv</copy>
    CDB1
    ```

## Task 2: Configure the IM Column Store Size

1.  Log in to the CDB root as SYS.

    ```
    $ <copy>sqlplus / AS SYSDBA</copy>

    ```

    ```
    SQL> <copy>ALTER SYSTEM SET inmemory_SIZE = 800M SCOPE=SPFILE; </copy>
    ```

2.  Restart the instance and open the database.

    ```
    SQL> <copy>SHUTDOWN IMMEDIATE</copy>
    ```

    ```
    SQL> <copy>STARTUP</copy>
    ```

    ```
    SQL> <copy>ALTER PLUGGABLE DATABASE pdb1 OPEN;</copy>
    ```

## Task 3: Create the Logical Directories for the External Source Files

In this section, you create the logical directory to store the source data files for external data files of the external table.

1. Log in to the PDB as SYSTEM.

    ```
    SQL> <copy>CONNECT system@PDB1</copy>
    Enter password: password
    ```

2.  Create the logical directory CENT20 to store the source data file cent20.dat for the CENT20 external source data file.

    ```
    SQL> <copy>CREATE DIRECTORY cent20 AS '/home/oracle/labs/19cnf/CENT20'; </copy>
    ```

## Task 4: Create the In-Memory External Table

1. Create the user that owns the in-memory hybrid partitioned table.

    ```
    SQL> <copy>CREATE USER hypt IDENTIFIED BY password;</copy>
    ```

2. Grant the read and write privileges on the directory that stores the source data file, to the table owner.

    ```
    SQL> <copy>GRANT read, write ON DIRECTORY cent20 TO hypt;</copy>
    ```

3. Grant the CREATE SESSION, CREATE TABLE, and UNLIMITED TABLESPACE privileges to the table owner.

    ```
    SQL> <copy>GRANT create session, create table, unlimited tablespace TO hypt;</copy>
    ```

4. Create the in-memory external table INMEM\_EXT\_TAB with the following attributes:
  - The table is partitioned by range on the `TIME_ID` column.
  - The default tablespace for external source data files is CENT20.
  - The fields in the records of the external files are separated by comma ','.
  - The in-memory compression is `FOR CAPACITY HIGH`.

    ```
    SQL> <copy>CREATE TABLE hypt.inmem_ext_tab (history_event NUMBER, time_id DATE)
    ORGANIZATION EXTERNAL    
        (TYPE ORACLE_LOADER DEFAULT DIRECTORY cent20
        ACCESS PARAMETERS  (FIELDS TERMINATED BY ',')
        LOCATION ('cent20.dat'))
    INMEMORY MEMCOMPRESS FOR CAPACITY HIGH;</copy>
    ```

5. Display the in-memory attributes of the external table.

    ```
    SQL> <copy>SELECT * FROM dba_external_tables WHERE owner='HYPT';</copy>

    OWNER   TABLE_NAME      TYP
    ------- --------------- ---
    TYPE_NAME
    ----------------------------------------------------------------
    DEF
    ---
    DEFAULT_DIRECTORY_NAME
    ----------------------------------------------------------------
    REJECT_LIMIT                             ACCESS_
    ---------------------------------------- -------
    ACCESS_PARAMETERS
    ----------------------------------------------------------------
    PROPERTY   INMEMORY INMEMORY_COMPRESS
    ---------- -------- -----------------
    HYPT    INMEM_EXT_TAB   SYS
    ORACLE_LOADER
    SYS
    CENT20
    0                                        CLOB
    FIELDS TERMINATED BY ','
    ALL        ENABLED  FOR CAPACITY HIGH
    ```

## Task 5: Query the In-Memory External Table

1. Query the table. Queries of in-memory external tables must have the QUERY\_REWRITE\_INTEGRITY initialization parameter set to stale_tolerated.

    ```
    SQL> <copy>ALTER SESSION SET query_rewrite_integrity=stale_tolerated;</copy>
    ```

    ```
    SQL> <copy>SELECT * FROM hypt.inmem_ext_tab ORDER BY 1;</copy>

    HISTORY_EVENT TO_CHAR(TIME_ID,'DD-
    ------------- --------------------
                1 01-JAN-1976
                2 01-JAN-1915
                3 01-JAN-1928
                4 01-JAN-1937
                5 01-JAN-1949
                6 01-FEB-1959
                7 01-FEB-1996
                8 01-FEB-1997
                9 01-FEB-1998
               10 01-FEB-1998

    10 rows selected.
    ```

2. Verify that the data is populated into the IM column store.

    ```
    SQL> <copy>SELECT segment_name, tablespace_name, populate_status
    FROM   v$im_segments;</copy>

    SEGMENT_NAME   TABLESPACE_NAME          POPULATE_STAT
    -------------- ------------------------ -------------
    INMEM_EXT_TAB  SYSTEM                   COMPLETED
    ```

    Note: Querying the in-memory external table initiates the population into the IM column store in the same way that it does for an internal table. Executing the DBMS_INMEMORY.POPULATE procedure is not required.

## Task 6: Find How Data In In-Memory External Table Is Accessed

1. Display the execution plan for a query on the in-memory external table with a degree of parallelism of 2.

    ```
    SQL> <copy> EXPLAIN PLAN FOR SELECT /*+ PARALLEL(2) */ * FROM hypt.inmem_ext_tab; </copy>
    ```

2. Read the result from the result2 text file. The EXTERNAL TABLE ACCESS INMEMORY FULL operation shows that the external data was accessed from the IM column store after having been populated automatically during the query.

    ```
    SQL> <copy>SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);</copy>
   
      PLAN_TABLE_OUTPUT
    ---------------------------------------------------------------------------------------------------------------------
    | Id | Operation                             |Name         |Rows|Bytes|Cost (%CPU)|Time    |   TQ |IN-OUT|PQ Distrib
    ---------------------------------------------------------------------------------------------------------------------
    |   0| SELECT STATEMENT                      |             |102K|2193K|  197   (5)|00:00:01|      |      |            
    |   1| PX COORDINATOR                        |             |    |     |           |        |      |      |            
    |   2|  PX SEND QC (RANDOM)                  |:TQ10000     |102K|2193K|  197   (5)|00:00:01| Q1,00| P->S |QC (RAND)  
    |   3|   PX BLOCK ITERATOR                   |             |102K|2193K|  197   (5)|00:00:01| Q1,00| PCWC |            
    |   4|    EXTERNAL TABLE ACCESS INMEMORY FULL|INMEM_EXT_TAB|102K|2193K|  197   (5)|00:00:01| Q1,00| PCWP |            
    ---------------------------------------------------------------------------------------------------------------------
    Note
    -----
      - Degree of Parallelism is 2 because of hint
    ```

## Task 7: Clean Up the Environment

1. Drop the external table `HYPT.INMEM_EXT_TAB`.

    ```
    SQL> <copy>DROP TABLE hypt.inmem_ext_tab PURGE;</copy>
    ```

2. Quit the session.

    ```
    <copy>EXIT;</copy>
    ```

  ## Acknowledgements

  - **Author** - Dominique Jeunot, Consulting User Assistance Developer
  - **Contributors** - Blake Hendricks, Austin Specialist Hub
  - **Last Updated By/Date** - Blake Hendricks, Austin Specialist Hub, January 10 2021
