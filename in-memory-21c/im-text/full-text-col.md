# In-Memory Full Text Columns

## Introduction

Watch a demo of using In-Memory Full Text Columns:

[YouTube video](youtube:hrGefjpMLeY)

Watch the video below for a walk through of the In-Memory Full Text Columns lab:

[In-Memory Full Text Columns](videohub:1_0vnj781i)

*Estimated Lab Time:* 10 Minutes.

### Objectives

- Learn how to enable In-Memory on the Oracle Database
- Perform various queries on the In-Memory Column Store

### Prerequisites

This lab assumes you have:

- A Free Tier, Paid or LiveLabs Oracle Cloud account
- You have completed:
    - Get Started with noVNC Remote Desktop
    - Lab: Initialize Environment
    - Lab: Setting up the In-Memory Column Store

**NOTE:** *When doing Copy/Paste using the convenient* **Copy** *function used throughout the guide, you must hit the* **ENTER** *key after pasting. Otherwise the last line will remain in the buffer until you hit* **ENTER!**

### Background

Oracle Database 21c introduced a new feature called In-Memory Full Text Columns. Prior to 21c Database In-Memory didn't support predicates for non-scalar documents. In other words, if you were using domain indexes for an Oracle full text index, XML Search Index, or JSON Search Index then we didn't populate those in the IM column store. This limited the speed with which you could search on non-scalar type data. Now in Oracle Database 21c Database In-Memory supports the ability to store, or populate, these types of domain-specific indexes. The In-Memory Full Text feature supports the following data types:

-	CHAR
-	VARCHAR2
-	CLOB
-	BLOB
-	JSON

This means that for queries that use CONTAINS() and JSON_TEXTCONTAINS(), Database In-Memory can now push those operators into the scan of the in-memory columnar data as SQL predicates just as we push other predicates and aggregations into the in-memory scan.

In this lab you will see how In-Memory Full Text Columns are setup and how to make use of them.

## Task 1: Verify Directory Definitions

In this Lab we will be populating external data from a local directory and we will need to define a database directory to use in our external table definitions to point the database to our external data.

Let's switch to the text folder and log back in to the PDB:

```
<copy>
cd /home/oracle/labs/inmemory/text
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
[CDB1:oracle@dbhol:~/labs/inmemory]$ cd /home/oracle/labs/inmemory/text
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

1.  This lab will be using an open source dataset from the City of Chicago. It has crime information with text items that the SSB schema, the dataset the other examples are based on, does not have.

    Run the script *01\_chicago\_data.sql*

    ```
    <copy>
    @01_chicago_data.sql
    </copy>    
    ```

    or run the queries below.  

    ```
    <copy>
    col table_name   format a20;
    col column_name  format a30;
    col data_type    format a30;
    col data_length  format 999999;
    col data_default format a30 WRAPPED;
    select TABLE_NAME, COLUMN_NAME, DATA_TYPE, data_length, DATA_DEFAULT
    from user_tab_cols
    where table_name = 'CHICAGO_DATA'
    order by column_id;
    </copy>
    ```

    Query result:

    ```
    SQL> @01_chicago_data.sql
    Connected.

    TABLE_NAME           COLUMN_NAME                    DATA_TYPE                      DATA_LENGTH DATA_DEFAULT
    -------------------- ------------------------------ ------------------------------ ----------- ------------------------------
    CHICAGO_DATA         ID                             NUMBER                                  22
    CHICAGO_DATA         CASE_NUMBER                    VARCHAR2                                 8
    CHICAGO_DATA         C_DATE                         VARCHAR2                                30
    CHICAGO_DATA         BLOCK                          VARCHAR2                                35
    CHICAGO_DATA         IUCR                           VARCHAR2                                10
    CHICAGO_DATA         PRIMARY_TYPE                   VARCHAR2                                40
    CHICAGO_DATA         DESCRIPTION                    VARCHAR2                               100
    CHICAGO_DATA         LOCATION_DESC                  VARCHAR2                               100
    CHICAGO_DATA         ARREST                         VARCHAR2                                20
    CHICAGO_DATA         DOMESTIC                       VARCHAR2                                20
    CHICAGO_DATA         BEAT                           VARCHAR2                                20
    CHICAGO_DATA         DISTRICT                       VARCHAR2                                20
    CHICAGO_DATA         WARD                           NUMBER                                  22
    CHICAGO_DATA         COMMUNITY                      VARCHAR2                                20
    CHICAGO_DATA         FBI_CODE                       VARCHAR2                                20
    CHICAGO_DATA         X_COORD                        NUMBER                                  22
    CHICAGO_DATA         Y_COORD                        NUMBER                                  22
    CHICAGO_DATA         C_YEAR                         NUMBER                                  22
    CHICAGO_DATA         UPDATED_ON                     VARCHAR2                                30
    CHICAGO_DATA         LATTITUDE                      NUMBER                                  22
    CHICAGO_DATA         LONGITUDE                      NUMBER                                  22
    CHICAGO_DATA         LOCATION                       VARCHAR2                                40

    22 rows selected.

    SQL>
    ```

2.  Next we will run a query accessing the CHICAGO_DATA table looking for a count of all descriptions in district 009 that have the word "BATTERY" in the description.

    Run the script *02\_text\_query.sql*

    ```
    <copy>
    @02_text_query.sql
    </copy>    
    ```

    or run the queries below.  

    ```
    <copy>
    set timing on
    col description format a65;
    select description, count(*) from chicago_data
    where district = '009' and description like '%BATTERY%'
    group by description;
    set timing off
    pause Hit enter ...
    select * from table(dbms_xplan.display_cursor());
    pause Hit enter ...
    @../imstats.sql
    </copy>
    ```

    Query result:

    ```
    SQL> @02_text_query.sql
    Connected.
    SQL>
    SQL> select description, count(*) from chicago_data
      2  where district = '009' and description like '%BATTERY%'
      3  group by description;

    DESCRIPTION                                                         COUNT(*)
    ----------------------------------------------------------------- ----------
    DOMESTIC BATTERY SIMPLE                                                27137
    AGGRAVATED DOMESTIC BATTERY                                               62
    AGGRAVATED DOMESTIC BATTERY: OTHER DANG WEAPON                          1055
    AGGRAVATED DOMESTIC BATTERY: KNIFE/CUTTING INST                          553
    AGGRAVATED DOMESTIC BATTERY: HANDS/FIST/FEET SERIOUS INJURY              287
    AGGRAVATED DOMESTIC BATTERY: HANDGUN                                       4
    AGGRAVATED DOMESTIC BATTERY: OTHER FIREARM                                 1

    7 rows selected.

    Elapsed: 00:00:00.92
    SQL>
    SQL> set echo off
    Hit enter ...


    PLAN_TABLE_OUTPUT
    ------------------------------------------------------------------------------------------------------------------------------------------------------
    SQL_ID  3qy7rz5sttjtr, child number 0
    -------------------------------------
    select description, count(*) from chicago_data where district = '009'
    and description like '%BATTERY%' group by description

    Plan hash value: 3393334649

    -----------------------------------------------------------------------------------
    | Id  | Operation          | Name         | Rows  | Bytes | Cost (%CPU)| Time     |
    -----------------------------------------------------------------------------------
    |   0 | SELECT STATEMENT   |              |       |       | 38429 (100)|          |
    |   1 |  HASH GROUP BY     |              |   380 |  8360 | 38429   (1)| 00:00:02 |
    |*  2 |   TABLE ACCESS FULL| CHICAGO_DATA | 16930 |   363K| 38428   (1)| 00:00:02 |
    -----------------------------------------------------------------------------------

    Predicate Information (identified by operation id):
    ---------------------------------------------------

       2 - filter(("DISTRICT"='009' AND "DESCRIPTION" LIKE '%BATTERY%' AND
                  "DESCRIPTION" IS NOT NULL))


    21 rows selected.

    Hit enter ...


    NAME                                                              VALUE
    -------------------------------------------------- --------------------
    CPU used by this session                                             91
    physical reads                                                   141004
    session logical reads                                            145265
    session pga memory                                             18876664

    SQL>
    ```

3. Now let's populate the CHICAGO_DATA table in the IM column store.

    Run the script *03\_text\_pop.sql*

    ```
    <copy>
    @03_text_pop.sql
    </copy>    
    ```

    or run the statements below:

    ```
    <copy>
    alter table CHICAGO_DATA inmemory;
    exec dbms_inmemory.populate(USER, 'CHICAGO_DATA');
    </copy>
    ```

    ```
    SQL> @03_text_pop.sql
    Connected.
    SQL>
    SQL> alter table CHICAGO_DATA inmemory;

    Table altered.

    SQL>
    SQL> exec dbms_inmemory.populate(USER, 'CHICAGO_DATA');

    PL/SQL procedure successfully completed.

    SQL>
    ```

4. Verify that the CHICAGO_DATA table has been populated.

    Run the script *04\_im\_populated.sql*

    ```
    <copy>
    @04_im_populated.sql
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
    SSB        CHICAGO_DATA                         COMPLETED          1,153,146,880      626,917,376                0

    SQL>
    ```

5. Now we will run the same query that will access the CHICAGO_DATA table in the IM column store.

    Run the script *05\_im\_text\_query.sql*

    ```
    <copy>
    @05_im_text_query.sql
    </copy>    
    ```

    or run the queries below:

    ```
    <copy>
    set timing on
    col description format a65;
    select description, count(*) from chicago_data
    where district = '009' and description like '%BATTERY%'
    group by description;
    set timing off
    pause Hit enter ...
    select * from table(dbms_xplan.display_cursor());
    pause Hit enter ...
    @../imstats.sql
    </copy>
    ```

    Query result:

    ```
    SQL> @05_im_text_query.sql
    Connected.
    SQL>
    SQL> select description, count(*) from chicago_data
      2  where district = '009' and description like '%BATTERY%'
      3  group by description;

    DESCRIPTION                                                                   COUNT(*)
    ----------------------------------------------------------------- --------------------
    DOMESTIC BATTERY SIMPLE                                                          27137
    AGGRAVATED DOMESTIC BATTERY                                                         62
    AGGRAVATED DOMESTIC BATTERY: OTHER DANG WEAPON                                    1055
    AGGRAVATED DOMESTIC BATTERY: KNIFE/CUTTING INST                                    553
    AGGRAVATED DOMESTIC BATTERY: HANDS/FIST/FEET SERIOUS INJURY                        287
    AGGRAVATED DOMESTIC BATTERY: HANDGUN                                                 4
    AGGRAVATED DOMESTIC BATTERY: OTHER FIREARM                                           1

    7 rows selected.

    Elapsed: 00:00:00.03
    SQL>
    SQL> set echo off

    Hit enter ...


    PLAN_TABLE_OUTPUT
    ------------------------------------------------------------------------------------------------------------------------------------------------------
    SQL_ID  3qy7rz5sttjtr, child number 0
    -------------------------------------
    select description, count(*) from chicago_data where district = '009'
    and description like '%BATTERY%' group by description

    Plan hash value: 3393334649

    --------------------------------------------------------------------------------------------
    | Id  | Operation                   | Name         | Rows  | Bytes | Cost (%CPU)| Time     |
    --------------------------------------------------------------------------------------------
    |   0 | SELECT STATEMENT            |              |       |       |  1513 (100)|          |
    |   1 |  HASH GROUP BY              |              |   380 |  8360 |  1513   (7)| 00:00:01 |
    |*  2 |   TABLE ACCESS INMEMORY FULL| CHICAGO_DATA | 16930 |   363K|  1511   (7)| 00:00:01 |
    --------------------------------------------------------------------------------------------

    Predicate Information (identified by operation id):
    ---------------------------------------------------

       2 - inmemory(("DISTRICT"='009' AND "DESCRIPTION" LIKE '%BATTERY%' AND
                  "DESCRIPTION" IS NOT NULL))
           filter(("DISTRICT"='009' AND "DESCRIPTION" LIKE '%BATTERY%' AND
                  "DESCRIPTION" IS NOT NULL))


    23 rows selected.

    Hit enter ...


    NAME                                                              VALUE
    -------------------------------------------------- --------------------
    CPU used by this session                                              5
    IM scan CUs columns accessed                                         26
    IM scan CUs memcompress for query low                                13
    IM scan CUs pcode aggregation pushdown                               13
    IM scan rows                                                    6821896
    IM scan rows pcode aggregated                                     29099
    IM scan rows projected                                               63
    IM scan rows valid                                              6821896
    IM scan segments minmax eligible                                     13
    session logical reads                                            140858
    session logical reads - IM                                       140765
    session pga memory                                             17828088
    table scans (IM)                                                      1

    13 rows selected.

    SQL>
    ```

    You should see that the access path is now "TABLE ACCESS INMEMORY FULL" and that the DISTRICT and DESCRIPTION predicates have been pushed into the in-memory scan (i.e. notice the Predicate Information section).

6. Now let's enable an In-Memory Full Text Query. We will verify the required parameters, these have already been setup and were used in previous labs, and then we will enable the DESCRIPTION column as a Full Text column by specifying the "INMEMORY TEXT" keywords and then re-populate the CHICAGO_DATA table.

    Run the script *06\_fulltext\_pop.sql*

    ```
    <copy>
    @06_fulltext_pop.sql
    </copy>    
    ```

    or run the queries below:

    ```
    <copy>
    alter table CHICAGO_DATA no inmemory;
    show parameter max_string_size
    show parameter inmemory_expression
    show parameter inmemory_virtual_columns
    pause Hit enter ...
    ALTER TABLE CHICAGO_DATA INMEMORY TEXT (description);
    alter table CHICAGO_DATA inmemory;
    exec dbms_inmemory.populate(USER, 'CHICAGO_DATA');
    </copy>
    ```

    Query result:

    ```
    SQL> @06_fulltext_pop.sql
    Connected.
    SQL> 
    SQL> alter table CHICAGO_DATA no inmemory;

    Table altered.

    SQL> 
    SQL> show parameter max_string_size

    NAME                                 TYPE        VALUE
    ------------------------------------ ----------- ------------------------------
    max_string_size                      string      EXTENDED
    SQL> 
    SQL> show parameter inmemory_expression

    NAME                                 TYPE        VALUE
    ------------------------------------ ----------- ------------------------------
    inmemory_expressions_usage           string      ENABLE
    SQL> 
    SQL> show parameter inmemory_virtual_columns

    NAME                                 TYPE        VALUE
    ------------------------------------ ----------- ------------------------------
    inmemory_virtual_columns             string      enable
    SQL> 
    SQL> pause Hit enter ...
    Hit enter ...

    SQL> 
    SQL> ALTER TABLE CHICAGO_DATA INMEMORY TEXT (description);

    Table altered.

    SQL> 
    SQL> alter table CHICAGO_DATA inmemory;

    Table altered.

    SQL> 
    SQL> exec dbms_inmemory.populate(USER, 'CHICAGO_DATA');

    PL/SQL procedure successfully completed.

    SQL> 
    ```

7. Verify that the CHICAGO_DATA has been re-populated.

    Run the script *07\_im\_populated.sql*

    ```
    <copy>
    @07_im_populated.sql
    </copy>
    ```

    or run the queries below.

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
    SQL> @07_im_populated.sql
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
    SSB        CHICAGO_DATA                         COMPLETED          1,153,146,880      723,910,656                0

    SQL> 
    ```

8. Since the In-Memory Full Text Query feature leverages In-Memory Expressions (IME) under the covers let's go ahead and take a look at the IME and how much space it consumes. Don't forget that with In-Memory Full Text Query an on-disk context index is not needed.

    Run the script *08\_fulltext\_ime.sql*

    ```
    <copy>
    @08_fulltext_ime.sql
    </copy>    
    ```

    or run the queries below:

    ```
    <copy>
    col table_name format a15;
    col column_name format a35;
    col data_type format a10;
    col data_length format 999999999999;
    col data_default format a40 word_wrapped;
    select
      table_name, column_name, data_type, DATA_LENGTH, DATA_DEFAULT
    from user_tab_cols
    where table_name = 'CHICAGO_DATA'
    and column_name like 'SYS%';
    pause Hit enter ...
    @../Lab04-IME/05_ime_usage.sql
    </copy>
    ```

    Query result:

    ```
    SQL> @08_fulltext_ime.sql
    Connected.

    TABLE_NAME      COLUMN_NAME                         DATA_TYPE    DATA_LENGTH DATA_DEFAULT
    --------------- ----------------------------------- ---------- ------------- ----------------------------------------
    CHICAGO_DATA    SYS_IME_IVDX_F7B841D57A9D4FEABF1084 RAW                32767 SYS_CTX_MKIVIDX("DESCRIPTION" RETURNING
                    3E3480A9FF                                                   RAW(32767))


    Elapsed: 00:00:00.21
    Hit enter ...

    Connected.
    SQL> 
    SQL> -- This query displays what objects are in the In-Memory Column Store
    SQL> 
    SQL> select
      2    o.owner,
      3    o.object_name,
      4    o.subobject_name as partition_name,
      5    i.column_name,
      6    count(*) t_imeu,
      7    sum(i.length)/1024/1024 space
      8  from
      9    v$im_imecol_cu i,
     10    dba_objects o
     11  where
     12    i.objd = o.object_id
     13  group by
     14    o.owner,
     15    o.object_name,
     16    o.subobject_name,
     17    i.column_name;

                                    Partition            Column            Total         Used
    Owner      Object               Name                 Name              IMEUs    Space(MB)
    ---------- -------------------- -------------------- --------------- ------- ------------
    SSB        CHICAGO_DATA                              SYS_IME_IVDX_F7       5           44
                                                         B841D57A9D4FEAB
                                                         F10843E3480A9FF


    Elapsed: 00:00:00.24
    SQL> 
    ```

9. Now we will run the query from step 5 but we will change the LIKE to a CONTAINS so that we can take advantage the In-Memory Full Text column.

    Run the script *09\_im\_fulltext\_query.sql*

    ```
    <copy>
    @09_im_fulltext_query.sql
    </copy>    
    ```

    or run the queries below:

    ```
    <copy>
    set timing on
    col description format a65;
    select description, count(*) from chicago_data
    where district = '009'
    and CONTAINS(description, 'BATTERY', 1) > 0
    group by description;
    set timing off
    pause Hit enter ...
    select * from table(dbms_xplan.display_cursor());
    pause Hit enter ...
    @../imstats.sql
    </copy>
    ```

    Query result:

    ```
    SQL> @09_im_fulltext_query.sql
    Connected.
    SQL> 
    SQL> select description, count(*) from chicago_data
      2  where district = '009'
      3  and CONTAINS(description, 'BATTERY', 1) > 0
      4  group by description;

    DESCRIPTION                                                         COUNT(*)
    ----------------------------------------------------------------- ----------
    DOMESTIC BATTERY SIMPLE                                                27137
    AGGRAVATED DOMESTIC BATTERY                                               62
    AGGRAVATED DOMESTIC BATTERY: OTHER DANG WEAPON                          1055
    AGGRAVATED DOMESTIC BATTERY: KNIFE/CUTTING INST                          553
    AGGRAVATED DOMESTIC BATTERY: HANDS/FIST/FEET SERIOUS INJURY              287
    AGGRAVATED DOMESTIC BATTERY: HANDGUN                                       4
    AGGRAVATED DOMESTIC BATTERY: OTHER FIREARM                                 1

    7 rows selected.

    Elapsed: 00:00:00.25
    SQL> 

    SQL> set echo off

    Hit enter ...


    PLAN_TABLE_OUTPUT
    ------------------------------------------------------------------------------------------------------------------------------------------------------
    SQL_ID  d8zhhkmga6wr9, child number 0
    -------------------------------------
    select description, count(*) from chicago_data where district = '009'
    and CONTAINS(description, 'BATTERY', 1) > 0 group by description

    Plan hash value: 3393334649

    --------------------------------------------------------------------------------------------
    | Id  | Operation                   | Name         | Rows  | Bytes | Cost (%CPU)| Time     |
    --------------------------------------------------------------------------------------------
    |   0 | SELECT STATEMENT            |              |       |       |  1504 (100)|          |
    |   1 |  HASH GROUP BY              |              |   380 | 82460 |  1504   (6)| 00:00:01 |
    |*  2 |   TABLE ACCESS INMEMORY FULL| CHICAGO_DATA | 16930 |  3587K|  1503   (6)| 00:00:01 |
    --------------------------------------------------------------------------------------------

    Predicate Information (identified by operation id):
    ---------------------------------------------------

       2 - inmemory(("DISTRICT"='009' AND SYS_CTX_CONTAINS2("DESCRIPTION" , 'BATTERY' ,
                  SYS_CTX_MKIVIDX("DESCRIPTION" RETURNING RAW(32767)))>0))
           filter(("DISTRICT"='009' AND SYS_CTX_CONTAINS2("DESCRIPTION" , 'BATTERY' ,
                  SYS_CTX_MKIVIDX("DESCRIPTION" RETURNING RAW(32767)))>0))


    23 rows selected.

    Hit enter ...


    NAME                                                              VALUE
    -------------------------------------------------- --------------------
    CPU used by this session                                             49
    IM scan CUs columns accessed                                         10
    IM scan CUs memcompress for query low                                 5
    IM scan EU rows                                                 6821896
    IM scan EUs columns accessed                                          5
    IM scan EUs memcompress for query low                                 5
    IM scan rows                                                    6821896
    IM scan rows projected                                            29099
    IM scan rows valid                                              6821896
    IM scan segments minmax eligible                                      5
    physical reads                                                       37
    session logical reads                                            148825
    session logical reads - IM                                       140765
    session pga memory                                             19925240
    table scans (IM)                                                      1

    15 rows selected.

    SQL> 
    ```

10. (Optional) You can run remove the changes made during this lab by running the following script.    

    Run the script *10\_text\_cleanup.sql*

    ```
    <copy>
    10_text_cleanup.sql
    </copy>    
    ```

    or run the queries below:

    ```
    <copy>
    alter table chicago_data no inmemory text (description);
    alter table chicago_data no inmemory;
    </copy>
    ```

    Query result:

    ```
    SQL> @10_text_cleanup.sql
    Connected.

    Table altered.


    Table altered.

    SQL>
    ```

## Conclusion

This lab demonstrated how Database In-Memory can optimize the access of external data, and support both external and hybrid partitioned tables.

You may now **proceed to the next lab**.

## Acknowledgements

- **Author** - Andy Rivenes, Product Manager,  Database In-Memory
- **Contributors** -
- **Last Updated By/Date** - Andy Rivenes, August 2022