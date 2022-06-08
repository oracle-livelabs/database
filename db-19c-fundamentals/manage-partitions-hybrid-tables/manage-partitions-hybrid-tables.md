# Manage Partitions in Hybrid Partitioned Tables

## Introduction
Oracle Database 12c allows partitions of a partitioned table to be created either as internal partitions in the database in Oracle data files or in external sources as external partitions.

Oracle Database 19c allows a partitioned table to hold both internal partitions and external partitions. These partitioned tables are called hybrid partitioned tables.

In this lab, you create a hybrid partitioned table with both internal and external partitions and manage the internal and external partitions.

Estimated Time: 15 minutes

### Objectives

In this lab, you will:

- Create the tablespaces for the internal partitions
- Create the logical directories for the external partitions
- Create the hybrid partitioned table
- Insert data into the partitions
- List the partitions of the hybrid partitioned table
- Add and remove external partitions
- Clean up the environment

### Prerequisites

This lab assumes you have:
- Obtained and signed in to your `workshop-installed` compute instance.

## Task 1: Create the tablespaces for the internal partitions

> **NOTE:** Unless otherwise stated, all passwords will be `Ora4U_1234`. When copying and pasting a command that includes a password, please replace the word `password` with `Ora4U_1234`. This only applies to instances created through OCI Resource Manager with our provided terraform scripts.

In this section, you create two tablespaces to store data of the internal partitions, one of the two tablespaces to be the default tablespace for internal partitions.

1. Open a terminal session.

2. Set the Oracle environment variables. When prompted, enter CDB1.

    ```
    $ <copy>. oraenv</copy>
    CDB1
    ```

3. If not open, pleae open PDB1.

    ```
    $ <copy>sqlplus / as sysdba</copy>
    Connected.
    ```

4. Open PDB1.

    ```
    SQL> <copy>ALTER PLUGGABLE DATABASE pdb1 OPEN;</copy>
    ```

5. Exit SQL*Plus.

    ```
    SQL> <copy>EXIT;</copy>
    ```

6. Log in to PDB1 as the `SYS` user.

    ```
    $ <copy>sqlplus sys/password@PDB1 as sysdba</copy>
    Connected.
    ```

7. Create the tablespaces TS1 and TS2 to store internal partitions of the hybrid partitioned table

    ```
    SQL> <copy>CREATE TABLESPACE ts1 DATAFILE '/home/oracle/labs/19cnf/ts1.dbf' SIZE 100M;</copy>
    ```
    ```
    SQL> <copy>CREATE TABLESPACE ts2 DATAFILE '/home/oracle/labs/19cnf/ts2.dbf' SIZE 100M;</copy>
    ```

## Task 2: Create the logical directories for the external partitions

In this task, you create the logical directories to store the source data files for external partitions.

1. Create the logical directory CENT18 to store the source data file cent18.dat for the CENT18 external partition.

    ```
    SQL> <copy>CREATE DIRECTORY cent18 AS '/home/oracle/labs/19cnf/CENT18';</copy>
    ```

2. Create the logical directory CENT19 to store the source data file cent19.dat for the CENT19 external partition.

    ```
    SQL> <copy>CREATE DIRECTORY cent19 AS '/home/oracle/labs/19cnf/CENT19';</copy>
    ```

3. Create the logical directory CENT20 to store the source data file cent20.dat for the CENT20 external partition.

    ```
    SQL> <copy>CREATE DIRECTORY cent20 AS '/home/oracle/labs/19cnf/CENT20';</copy>
    ```

## Task 3: Create the hybrid partitioned table

1. Create the user that owns the hybrid partitioned table.

    ```
    SQL> <copy>CREATE USER hypt IDENTIFIED BY password;</copy>
    ```

2. Grant the read and write privileges on the directories that store the source data files to the table owner.

    ```
    SQL> <copy>GRANT read, write ON DIRECTORY cent18 TO hypt;</copy>
    ```

    ```
    SQL> <copy>GRANT read, write ON DIRECTORY cent19 TO hypt;</copy>
    ```

    ```
    SQL> <copy>GRANT read, write ON DIRECTORY cent20 TO hypt;</copy>
    ```

3. Grant the CREATE SESSION, CREATE TABLE and UNLIMITED TABLESPACE privileges to the table owner.

    ```
    SQL> <copy>GRANT create session, create table, unlimited tablespace TO hypt;</copy>
    ```

4. Execute the `create_hybrid_table.sql` script to create the HYPT_TAB hybrid partitioned table with the following attributes:
    - The table is partitioned by range on the TIME_ID column.
    - The default tablespace for internal partitions is TS1.
    - The default tablespace for external partitions is CENT20.
    - The fields in the records of the external files are separated by ','.
    - The table is partitioned into five parts:
      - Three external partitions:
        - CENT18 is empty for the moment;
        - CENT19 has the `cent19.dat` file stored in another directory than the default, CENT19;
        - CENT20 has the `cent20.dat` file stored in the default directory.
      - Two internal partitions: Y2000 is stored in tablespace TS2 and PMAX is stored in the default tablespace TS1.
      
    ```
    SQL> <copy>@/home/oracle/labs/19cnf/create_hybrid_table.sql</copy>
    ```

## Task 4: Insert data into the partitions

1. Insert rows into the internal partitions of the table. Execute the `insert_bd.sql` script.

    ```
    SQL> <copy>@/home/oracle/labs/19cnf/insert_bd.sql</copy>
    ```

2. Insert a row for the date of 12 August 1997.

    ```
    SQL> <copy>INSERT INTO hypt.hypt_tab VALUES (41, to_date('12.08.1997', 'dd.mm.yyyy'));</copy>
    INSERT INTO hypt.hypt_tab
                 *
    ERROR at line 1:
    ORA-14466: Data in a read-only partition or subpartition cannot be modified.
    ```

The data can be inserted into the external partition only via the external source data file.

3. Insert the data for the date of 12 August 1997 into the appropriate external source data file.

    ```
    SQL> <copy>host echo "41,12-Aug-1997" >> /home/oracle/labs/19cnf/CENT20/cent20.dat</copy>
    ```

4. Verify that the row is readable from the appropriate external partition CENT20. The results should match the output shown below.

    ```
    SQL> <copy>SELECT history_event, TO_CHAR(time_id, 'dd-MON-yyyy')
    FROM hypt.hypt_tab PARTITION (cent20) ORDER BY 1;</copy>
   
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
               41 12-AUG-1997

    11 rows selected.
    ```

5. Append another record into the external source data file CENT19. The results should match the output shown below.

    ```
    SQL> <copy>host echo "42,12-Aug-1997" >> /home/oracle/labs/19cnf/CENT19/cent19.dat</copy>
    ```
    ```
    SQL> <copy>SELECT history_event, TO_CHAR(time_id, 'dd-MON-yyyy') FROM hypt.hypt_tab PARTITION (cent19) ORDER BY 1;</copy>

    HISTORY_EVENT TO_CHAR(TIME_ID,'DD-
    ------------- --------------------
               11 01-JAN-1876
               12 01-JAN-1815
               13 01-JAN-1828
               14 01-JAN-1837
               15 01-JAN-1849
               16 01-FEB-1859
               17 01-FEB-1896
               18 01-FEB-1897
               19 01-FEB-1898
               20 01-FEB-1898
               42 12-AUG-1997

    11 rows selected.
    ```
    Observe that the row is readable from the external partition CENT19, although the row should be stored in another partition. There is no control on the TIME_ID of the records inserted as rows into the external partitions, as it is the case for rows inserted into internal partitions.

6. Use an text editor to delete the last record inserted by the previous command.
    ```
    SQL> <copy>exit</copy>
    ```
    ```
    $ <copy>vi /home/oracle/labs/19cnf/CENT19/cent19.dat</copy>
    ```
    Once in the vi editor, press "i" and delete line containing '42 12-AUG-1997'. Press "Esc" then ":wq" and "Enter".
    Return to SQL*Plus to continue the lab.
    ```
    $ <copy>sqlplus sys/password@PDB1 as sysdba</copy>
    Connected.
    ```

7. Query the rows of the five partitions. Check that each result matches the output below for each query.

    ```
    <copy>SELECT history_event, TO_CHAR(time_id, 'dd-MON-yyyy') FROM hypt.hypt_tab PARTITION (cent18) ORDER BY 1;</copy>

    no rows selected.
    ```
    ```
    <copy>SELECT history_event, TO_CHAR(time_id, 'dd-MON-yyyy') FROM hypt.hypt_tab PARTITION (cent19) ORDER BY 1;</copy>

    HISTORY_EVENT TO_CHAR(TIME_ID,'DD-
    ------------- --------------------
               11 01-JAN-1876
               12 01-JAN-1815
               13 01-JAN-1828
               14 01-JAN-1837
               15 01-JAN-1849
               16 01-FEB-1859
               17 01-FEB-1896
               18 01-FEB-1897
               19 01-FEB-1898
               20 01-FEB-1898

    10 rows selected.
    ```
    ```
    <copy>SELECT history_event, TO_CHAR(time_id, 'dd-MON-yyyy') FROM hypt.hypt_tab PARTITION (cent20) ORDER BY 1;</copy>

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
               41 12-AUG-1997

    11 rows selected.
    ```
    ```
    <copy>SELECT history_event, TO_CHAR(time_id, 'dd-MON-yyyy') FROM hypt.hypt_tab PARTITION (y2000) ORDER BY 1;</copy>

    HISTORY_EVENT TO_CHAR(TIME_ID,'DD-
    ------------- --------------------
               21 31-DEC-2000
               22 31-OCT-2000
               23 01-FEB-2000
               24 27-MAR-2000
               25 31-MAR-2000
               26 15-APR-2000
               27 02-SEP-2000
               28 12-AUG-2000

    8 rows selected.
    ```
    ```
    <copy>SELECT history_event, TO_CHAR(time_id, 'dd-MON-yyyy') FROM hypt.hypt_tab PARTITION (pmax) ORDER BY 1;</copy>

    HISTORY_EVENT TO_CHAR(TIME_ID,'DD-
    ------------- --------------------
                29 12-AUG-2018
                30 15-SEP-2017
    ```

## Task 5: List the partitions of the hybrid partitioned table

1. Distinguish the partitioned tables from the hybrid partitioned tables. Verify the existence of the hybrid partitioned table in the `DBA_EXTERNAL_TABLES` view and its associated partitions from the `DBA_TAB_PARTITIONS` view. The results should match the output shown below.

    ```
    SQL> <copy>SELECT * FROM dba_external_tables WHERE owner = 'HYPT';</copy>

    OWNER   TABLE_NAME TYP
    ------- ---------- ---
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
    HYPT    HYPT_TAB   SYS
    ORACLE_LOADER
    SYS
    CENT20
    UNLIMITED                                CLOB
    FIELDS TERMINATED BY ','
              (history_event , time_id DATE 'dd-MON-yyyy')
    ALL        DISABLED
    ```
    Query the rows of the next partition. The results should match the output shown below.
    ```
    SQL> <copy>SELECT partition_name, high_value FROM dba_tab_partitions WHERE table_name = 'HYPT_TAB' ORDER BY 1;</copy>

    PARTITION_NAME HIGH_VALUE
    -------------- --------------------
    CENT18         TO_DATE(' 1800-01-01
                    00:00:00', 'SYYYY-M
                   M-DD HH24:MI:SS', 'N
                   LS_CALENDAR=GREGORIA

    CENT19         TO_DATE(' 1900-01-01
                    00:00:00', 'SYYYY-M
                   M-DD HH24:MI:SS', 'N
                   LS_CALENDAR=GREGORIA

    CENT20         TO_DATE(' 2000-01-01
                    00:00:00', 'SYYYY-M
                   M-DD HH24:MI:SS', 'N
                   LS_CALENDAR=GREGORIA

    PMAX           MAXVALUE
    Y2000          TO_DATE(' 2001-01-01
                    00:00:00', 'SYYYY-M
                   M-DD HH24:MI:SS', 'N
                   LS_CALENDAR=GREGORIA
    ```

## Task 6: Add and remove external partitions

 In this section, you add an external partition to the internal partitioned table `HYPT.PART_TAB` for the 17th century. The external file `cent17.dat` source data file storing historic events of the 17th century is stored in the directory /home/oracle/labs/19cnf/CENT17.

 1. Drop the hybrid partitioned table.

    ```
    SQL> <copy>DROP TABLE hypt.hypt_tab;</copy>
    ```

2. Create another partitioned table with internal partitions only.

    ```
    SQL> <copy>CREATE TABLE hypt.part_tab (history_event NUMBER , time_id DATE) TABLESPACE ts1
                  PARTITION BY RANGE (time_id)
                  (PARTITION cent18 VALUES LESS THAN (TO_DATE('01-Jan-1800','dd-MON-yyyy')) ,
                  PARTITION cent19 VALUES LESS THAN (TO_DATE('01-Jan-1900','dd-MON-yyyy')) ,
                  PARTITION cent20 VALUES LESS THAN (TO_DATE('01-Jan-2000','dd-MON-yyyy')) ,
                  PARTITION y2000 VALUES LESS THAN  (TO_DATE('01-Jan-2001','dd-MON-yyyy'))
                            TABLESPACE ts2,
                  PARTITION pmax VALUES LESS THAN (MAXVALUE));</copy>
    ```

3. Execute the `insert2.sql` SQL script to insert rows into the internal partitions of the `PART_TAB` table.

    ```
    SQL> <copy>@$HOME/labs/19cnf/insert2_bd.sql</copy>
    ```

4. Display the rows in the table. The results should match the output below.

    ```
    SQL> <copy>SELECT * FROM hypt.part_tab ORDER BY 1;</copy>

    HISTORY_EVENT TO_CHAR(TIME_ID,'DD-
    ------------- --------------------
               21 31-DEC-2000
               22 31-OCT-2000
               23 01-FEB-2000
               24 27-MAR-2000
               25 31-MAR-2000
               26 15-APR-2000
               27 02-SEP-2000
               28 12-AUG-2000
               29 12-AUG-2018
               30 15-SEP-2017

    10 rows selected.
    ```

5. Create the logical directory for the /home/oracle/labs/19ncf/CENT17 directory.

    ```
    SQL> <copy>CREATE DIRECTORY cent17 AS '/home/oracle/labs/19cnf/CENT17';</copy>
    ```

6. Grant the read and write privileges on the directory to HYPT.

    ```
    SQL> <copy>GRANT read, write ON DIRECTORY cent17 TO hypt;</copy>
    ```

7. Define the external parameters for all external partitions that might be added to the `HYPT.PART_TAB` table.

    ```
    SQL> <copy>ALTER TABLE hypt.part_tab
                   ADD EXTERNAL PARTITION ATTRIBUTES
                      (TYPE ORACLE_LOADER
                       DEFAULT DIRECTORY cent17
                       ACCESS PARAMETERS
                        (FIELDS TERMINATED BY ','
                          (history_event , time_id DATE 'dd-MON-yyyy'))
                         REJECT LIMIT UNLIMITED
                        );</copy>
    ```

8. Split the first partition to a partition limit that will be the high limit of the partition added.

    ```
    SQL> <copy>ALTER TABLE hypt.part_tab
                      SPLIT PARTITION cent18 AT (TO_DATE('01-Jan-1700','dd-MON-yyyy'))
                      INTO (PARTITION cent17 EXTERNAL LOCATION ('cent17.dat'),
                            PARTITION cent18);</copy>
    ```

9. Read the rows of the external partition. The results should match output shown below.

    ```
    SQL> <copy>SELECT history_event, TO_CHAR(time_id, 'dd-MON-yyyy') FROM hypt.part_tab PARTITION (cent17) ORDER BY 1;</copy>

    HISTORY_EVENT TO_CHAR(TIME_ID,'DD-
    ------------- --------------------
              101 01-JAN-1676
              102 01-JAN-1615
              103 01-JAN-1628
              104 01-JAN-1637
              105 01-JAN-1649
              106 01-FEB-1659
              107 01-FEB-1696
              108 01-FEB-1697
              109 01-FEB-1698
              200 01-FEB-1698

    10 rows selected.
    ```

10. The partition storing 17th century historic events is no longer required. Remove the external parameters for the hybrid partitioned that was added to the `HYPT.PART_TAB` table.

    ```
    SQL> <copy>ALTER TABLE hypt.part_tab DROP EXTERNAL PARTITION ATTRIBUTES();</copy>

    ALTER TABLE hypt.part_tab DROP EXTERNAL PARTITION ATTRIBUTES()
    *
    ERROR at line 1:
    ORA-14354: operation not supported for a hybrid-partitioned table
    ```

This command should return an error. External partitions must be dropped first before you can remove external attributes at the table level.

11. Drop the external partition from the `HYPT.PART_TAB` table. Because there is one external partition left, the attributes for the external partitions cannot be removed from the hybrid partitioned table.

    ```
    SQL> <copy>ALTER TABLE hypt.part_tab DROP PARTITION cent17;</copy>
    ```

12. Remove the external parameters for the hybrid partitioned `HYPT.PART_TAB` table.

    ```
    SQL> <copy>ALTER TABLE hypt.part_tab DROP EXTERNAL PARTITION ATTRIBUTES();</copy>
    ```

## Task 7: Clean up the environment

1. Drop the hybrid partitioned HYPT.PART_TAB table.

    ```
    SQL> <copy>DROP TABLE hypt.part_tab PURGE;</copy>
    ```

2. Exit SQL*Plus.

    ```
    SQL> <copy>EXIT;</copy>
    ```
3. Recreate PDB1.

    ```
    $ <copy>$HOME/labs/19cnf/cleanup_PDBs_in_CDB1.sh</copy>
    ```

4. Quit the session.
   
    ```
    SQL> <copy>exit</copy>
    ```

    You may now **proceed to the next lab**.


## Learn More

* [Managing Hybrid Partitioned Tables](https://docs.oracle.com/en/database/oracle/oracle-database/19/vldbg/manage_hypt.html)

## Acknowledgements
* **Author** - Dominique Jeunot, Consulting User Assistance Developer
* **Contributors** - Kherington Barley, Austin Specialist Hub
* **Last Updated By/Date** - Kherington Barley, Austin Specialist Hub, May 2022

