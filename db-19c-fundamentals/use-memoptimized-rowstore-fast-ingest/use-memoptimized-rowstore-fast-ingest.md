# Use Memoptimized Rowstore - Fast Ingest

## Introduction

The fast ingest functionality of Memoptimized Rowstore enables fast data inserts into an Oracle Database from applications, such as Internet of Things (IoT) applications that ingest small, high volume transactions with a minimal amount of transactional overhead. The insert operations that use fast ingest temporarily buffer the data in the large pool before writing it to disk in bulk in a deferred, asynchronous manner.

Using the rich analytical features of Oracle Database, you can now perform data analysis more effectively by easily integrating data from high-frequency data streaming applications with your existing application data.

In this practice, you will see how Memoptimized Rowstore - Fast Ingest deferred inserts are handled in the SGA and on disk through the Space Management Coordinator (SMCO) and Wxxx worker background processes, and how deferred inserted rows are different from conventional inserts.

Estimated Time: 15 minutes

### Objectives

In this lab, you will:
* Prepare your environment
* Create a table in PDB1 to have rows inserted as deferred inserts.
* Observe how space is allocated for fast ingest writes
* Observe SMCO behavior
* Observe how constraints are evaulated on tables that have rows inserted as deferred inserts.
* Clean your environment

### Prerequisites

This lab assumes you have:
- Obtained and signed in to your `workshop-installed` compute instance.

## Task 1: Prepare your environment

> **NOTE:** Unless otherwise stated, all passwords will be `Ora4U_1234`. When copying and pasting a command that includes a password, please replace the word `password` with `Ora4U_1234`. This only applies to instances created through OCI Resource Manager with our provided terraform scripts.

1. Open a terminal window on the desktop.

2. Set the Oracle environment variables. At the prompt, enter CDB1.

    ```
    $ <copy>. oraenv</copy>
    CDB1
    ```
  
3. Run the `cleanup_PDBs_in_CDB1.sh` shell script to drop all PDBs in CDB1 that may have been created in other labs, and recreate PDB1. You can ignore any error messages that are caused by the script. They are expected.

    ```
    $ <copy>$HOME/labs/19cnf/cleanup_PDBs_in_CDB1.sh</copy>
    ```

4. Execute the `$HOME/labs/19cnf/glogin.sh` shell script. It sets formatting for all columns selected in queries.

    ```
    $ <copy>$HOME/labs/19cnf/glogin.sh</copy>
    ```

5. If PDB1 is not open, open it. First, log into CDB1

    ```
    $ <copy>sqlplus / as sysdba</copy>
    ```

6. Open PDB1.

    ```
    SQL> <copy>ALTER PLUGGABLE DATABASE PDB1 OPEN;</copy>
    ```

7. Exit SQL*Plus.

    ```
    SQL> <copy>EXIT;</copy>
    ```

## Task 2: Create a table in PDB1 to have rows inserted as deferred inserts.

Create the HR.MEMOPTWRITES table in PDB1 to have rows inserted as deferred inserts. You will also ensure that the table data is written to the space allocated for fast ingest writes in the large pool in the shared pool area before being written to disk.

1. Log into SQL*Plus as `system`

    ```
    $ <copy>sqlplus system@PDB1</copy>
    Enter password: password
    ```

2. Create a table called `hr.memoptwrites` with the `MEMOPTIMIZE FOR WRITE` attribute.

    ```
    SQL> <copy>CREATE TABLE hr.memoptwrites 
        (c1 NUMBER, c2 VARCHAR2(12)) MEMOPTIMIZE FOR WRITE;</copy>
    2   
    *
    ERROR at line 1:
    ORA-62145: MEMOPTIMIZE FOR WRITE feature not allowed on segment
    with deferred storage.
    ```

    By default, an object created like a table does not have a segment created until a first row is inserted. `MEMOPTIMIZE FOR WRITE` tables require a segment created before the first row is inserted.

## Task 3: Observe how space is allocated for fast ingest writes

1. View the `deferred_segment_creation` startup parameter.

    ```
    SQL> <copy>SHOW PARAMETER deferred_segment_creation</copy>            

    NAME                            TYPE        VALUE
    ------------------------------- ----------- --------------------
    deferred_segment_creation       Boolean     TRUE

    ```
  
2. Disable `deferred_segment_creation`.

    ```
    SQL> <copy>ALTER SYSTEM SET deferred_segment_creation = FALSE 
                      SCOPE=BOTH;</copy>
    2
    System altered.
    ```

3. Attempt to create `hr.memoptwrites`.

    ```
    SQL> <copy>CREATE TABLE hr.memoptwrites
        (c1 NUMBER, c2 VARCHAR2(12)) MEMOPTIMIZE FOR WRITE;</copy>
    2
    Table created.
    ```

4. Verify that `MEMOPTIMIZE FOR WRITE` is set.

    ```
    SQL> <copy>SELECT memoptimize_read Mem_read, 
            memoptimize_write Mem_write  
     FROM   dba_tables 
     WHERE  table_name = 'MEMOPTWRITES';</copy>

      2   3   4
      MEM_READ MEM_WRIT
      -------- --------
      DISABLED ENABLED

    ```

5. Check to see if the space allocated for fast ingest writes in the large pool is initialized.

    ```
    SQL> <copy>SELECT * FROM V$MEMOPTIMIZE_WRITE_AREA;</copy>

    
   
    TOTAL_SIZE USED_SPACE FREE_SPACE NUM_WRITES NUM_WRITERS     CON_ID
    ---------- ---------- ---------- ---------- ----------- ----------
      0	    0	       0	  0	      0 	 4

    ```

    The space has not been initialized yet, it will be once we insert something into the table.

6. Insert a row into the table so that the row goes to the space allocated for fast ingest writes in the large pool.

    ```
    SQL> <copy>INSERT /*+ MEMOPTIMIZE_WRITE */ INTO hr.memoptwrites 
            VALUES (1, 'Memoptwrites');</copy>
    2
    1 row created.

    ```

7. Commit the insert.

    ```
    SQL> <copy>COMMIT;</copy>

    Commit complete.
    ```

8. View how many bytes are being consumed by the space allocated for fast ingest writes in the large pool.

    ```
    SQL> <copy>SELECT * FROM V$MEMOPTIMIZE_WRITE_AREA;</copy>

    TOTAL_SIZE USED_SPACE FREE_SPACE NUM_WRITES NUM_WRITERS     CON_ID
    ---------- ---------- ---------- ---------- ----------- ----------
    2154823680    164400  2153610784	  0	      1 	 4
    ```

  Here's a reference as to what the various columns store:
  `TOTAL_SIZE` refers to the total amount of memory allocated for fast ingest data in the large pool.
  `USED_SPACE` refers to the total amount of memory **currently used** by fast ingest data data in the large pool.
  `FREE_SPACE` refers to the total amount of memory **currently free** for storing fast ingest data in the large pool.
  `NUM_WRITES` refers to the number of fast ingest insert operations for which data is still in the large pool and is yet to be written to disk.
  `NUM_WRITES` refers to the number of clients currently using fast ingest for inserting data into the database.
  `CON_ID` refers to The ID of the container to which the data pertains. Possible values include:
  * 0: This value is used for rows containing data that pertain to the entire CDB. This value is also used for rows in non-CDBs.
  * 1: This value is used for rows containing data that pertain to only the root.
  * n: Where n is the applicable container ID for the rows containing data.

  By default, 2 gigabytes are allocated from the large pool. If there is not enough space, the allocation is attempted again with a half the size. This process will continue until the allocation has been retried with a target size of 256 megabytes. If it fails at 256 megabytes, fast ingest writes in the large pool will be disabled until the instance is restarted.

## Task 4: Observe SMCO behavior

1. Create another terminal session, which we'll call **session 2**.

2. Set the Oracle environment variables. At the prompt, enter **CDB1**.

    ```
    $ <copy>. oraenv</copy>
    CDB1
    ```

3. Log in to PDB1 as `SYS`.

    ```
    $ <copy>sqlplus sys@PDB1 as sysdba</copy> 
    Enter password: password
    ```

4. Insert data into PDB1.

    ```
    SQL> <copy>@$HOME/labs/19cnf/insert.sql</copy>
    ```

5. In **session 1**, Check the memory consumption in `V$MEMOPTIMIZED_WRITE_AREA`. Notice how the same amount of space is used even when using two writers. 

    ```
    SQL> <copy>SELECT * FROM V$MEMOPTIMIZE_WRITE_AREA;</copy>

    TOTAL_SIZE USED_SPACE FREE_SPACE NUM_WRITES NUM_WRITERS     CON_ID
    ---------- ---------- ---------- ---------- ----------- ----------
    2154823680    1212896 2153610784	  0	      2 	 4

    ```

6. In **session 1**, list the statistics about memoptimized writes. Notice how only one row has been written in session 1.

    ```
    SQL> <copy>SELECT display_name, value FROM v$mystat m, v$statname n 
     WHERE  m.statistic# = n.statistic# 
     AND    display_name IN ( 'memopt w rows written', 
                              'memopt w rows flushed');
                              </copy> 

        DISPLAY_NAME							      VALUE
    ---------------------------------------------------------------- ----------
    memopt w rows written						  1
    memopt w rows flushed						  0

    ```

7. In **session 2**, list the statistics about memoptimized writes. Notice how thirty-three rows were written in session 2.

    ```
    <copy>
    SELECT display_name, value FROM v$mystat m, v$statname n 
     WHERE  m.statistic# = n.statistic# 
     AND    display_name IN ( 'memopt w rows written', 
                              'memopt w rows flushed'); 
    </copy>

        DISPLAY_NAME                            VALUE
    ---------------------------------- ----------
    memopt w rows written                      33
    memopt w rows flushed                       0

    ```

8. Wait a few minutes, then query `V$MEMOPTIMIZE_WRITE_AREA` in **session 2**.

    ```
    SQL> <copy>SELECT * FROM V$MEMOPTIMIZE_WRITE_AREA;</copy>

        TOTAL_SIZE USED_SPACE FREE_SPACE NUM_WRITES NUM_WRITERS     CON_ID
    ---------- ---------- ---------- ---------- ----------- ----------
    2154823680     164400 2154659280	  0	      2 	 4


    ```

    The background processes, w000 - w999 workers, which have SMCO as the coordinator process, flush the data from the space allocated for fast ingest writes in the large pool to data files after 1MB worth of writes (per session per object) or after 60 seconds.

9. Read the contents of of `V$MEMOPTIMIZE_WRITE_AREA`.

    ```
    SQL> <copy>SELECT distinct c1 FROM hr.memoptwrites;</copy>

          C1
    ----------
      6
      1
      2
      4
      5
      3

    6 rows selected.

    ```

10. In **session 1**, execute the `$HOME/labs/19cnf/insert_before_flush.sql` SQL script to insert and commit more rows into the `HR.MEMOPTWRITES` table.

    ```
    SQL> <copy>@$HOME/labs/19cnf/insert_before_flush.sql</copy>
    ```

11. In **session 2**, check to see if `HR` can see all the rows inserted in **session 1**.

    ```
    SQL> <copy>SELECT distinct c1 FROM hr.memoptwrites;</copy>

     C1
    ----------
      6
      1
      2
      4
      5
      3
    ```

    No. Any buffered data in the space allocated for fast ingest writes in the large pool cannot be read by any session, including the writer, until the background process sweep is complete, even if the data was committed.

12. In **session 1**, either wait for the background process to flush the space allocated for fast ingest writes in the large pool data or manually flush the data from space allocated for fast ingest writes in the large pool to disk.

    ```
    SQL> <copy>EXEC DBMS_MEMOPTIMIZE_ADMIN.WRITES_FLUSH</copy>

    PL/SQL procedure successfully completed.

    ```

13. In **session 2**, check if `HR` can view the inserted rows.

    ```
    SQL> <copy>SELECT distinct c1 FROM hr.memoptwrites;</copy>

        C1
    ----------
            6
            1
            7
            2
            8
            11
            4
            5
            10
            3
            9

    11 rows selected.

    ```

## Task 5: Observe how constraints are evaulated on tables that have rows inserted as deferred inserts. 

1. In **session 2**, create the HR.MEMOPTW table in PDB1 to have rows inserted as deferred inserts and a check constraint on C1. The values must be within the range of 1 to 10.

    ```
    SQL> <copy>CREATE TABLE hr.memoptw 
        ( c1 NUMBER(3), c2 VARCHAR2(12),
          CONSTRAINT CC_CHECK CHECK (c1 BETWEEN 1 AND 10)) 
         MEMOPTIMIZE FOR WRITE;</copy>
        
    ```

2. In **session 2**, attempt to insert rows into the table by executing the following command.

    ```
    SQL> <copy>INSERT /*+ MEMOPTIMIZE_WRITE */ INTO hr.memoptw 
            VALUES (0,'Memoptw');</copy>

    ERROR at line 1:
    ORA-02290: check constraint (HR.CC_CHECK) violated

    ```

    The constraint is evaluated without looking at the existing data on disk and, therefore, is still honored in the foreground process.

3. In **session 2**, create the `HR.MEMOPTW2` table in PDB1 to have rows inserted as deferred inserts and a `UNIQUE` constrant on `C2`.

    ```
    SQL> <copy>CREATE TABLE hr.memoptw2 
        (c1 NUMBER(3), c2 VARCHAR2(12) CONSTRAINT un_c2 UNIQUE) 
         MEMOPTIMIZE FOR WRITE;</copy>

    Table created.
    ```

4. In **session 2**, insert rows with the same value for `C2` into the table by executing the following command. Note that the inserts successfully complete. However, let's check if these have been written to disk.

    ```
    SQL> <copy>INSERT /*+ MEMOPTIMIZE_WRITE */ INTO hr.memoptw2 
     VALUES (0,'Memoptw');</copy>
      2
    1 row created.

    SQL> <copy>INSERT /*+ MEMOPTIMIZE_WRITE */ INTO hr.memoptw2 
        VALUES (1,'Memoptw');</copy>
      2
    1 row created.


    ```

5. In **session 1**, flush the data from the space allocated for fast ingest writes in the large pool to disk.

    ```
    SQL> <copy>EXEC DBMS_MEMOPTIMIZE_ADMIN.WRITES_FLUSH</copy>

    PL/SQL procedure successfully completed.

    ```

6. In **session 2**, commit the insert.

    ```
    SQL> <copy>COMMIT;</copy>

    Commit complete. 
    ```

7. In **session 2**, check and see if the data was successfully written to disk.

    ```
    SQL> <copy>SELECT * FROM hr.memoptw2;</copy>

                C1 C2
    ---------- ------------
            0 Memoptw

    ```

    The data was not written to the disk. The UNIQUE constraint is evaluated when the insert is written to disk. As such, the second row is not inserted when the data is written to disk from the space allocated for fast ingest writes in the large pool.

8. You may exit both **session 1** and **session 2**.

    ```
    SQL> <copy>EXIT</copy>
    ```

## Task 6: Clean your environment

1. Exit SQL*Plus.

    ```
    SQL> <copy>EXIT</copy>
    ```

2. Execute the following script to recreate the PDBs in CDB1.

    ```
    $ <copy>$HOME/labs/19cnf/cleanup_PDBs_in_CDB1.sh</copy>
    ```

    You may now **proceed to the next lab**.


## Learn More

* [Database 19c New Features](https://docs.oracle.com/en/database/oracle/oracle-database/19/newft/new-features.html#GUID-F63F251F-C11C-447D-874C-B711E0842F9D)
* [V$MEMOPTIMIZE\_WRITE\_AREA](https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/V-MEMOPTIMIZE_WRITE_AREA.html#GUID-C6904827-0F5B-436B-8C2D-0E487EB8BE70)

## Acknowledgements

- **Author** - Dominique Jeunot, Consulting User Assistance Developer
- **Contributors** - Matthew McDaniel, Austin Specialist Hub
- **Last Updated By/Date** - Matthew McDaniel, Austin Specialist Hub, March 3 2022