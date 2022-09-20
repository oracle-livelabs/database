# JSON

## Introduction
Watch the video below to get an overview of joins using Database In-Memory.

[](youtube:y3tQeVGuo6g)

Watch the video below for a walk through of the In-Memory and JSON.
[JSON](videohub:1_5rf7ugsx)

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

### Background

Oracle Database introduced support for JSON data in 12.1 and in Oracle Database 12c Release 2 (12.2) support was added for a binary JSON format that can be populated in the IM column store. This enables Oracle Database to leverage DBIM features and allow high performance analytics directly on JSON data. In fact, starting in Oracle Database 21c there is now support for a JSON data type, and that too can be populated in the IM column store. Note that the JSON document must smaller than 32,767 bytes to be populated in the IM column store. If it is larger than 32,767 bytes then it will be processed without the In-Memory optimization.

In this lab you will see how JSON data is supported in the IM column store prior to 21c, and also how it is supported with 21c and the new JSON data type.

## Task 1: Verify Prerequisites for Populating JSON data in the IM column store

To populate JSON data in the IM column store several database prerequisites must be setup. The following lists these prerequisites, all of which have been completed for your LiveLabs environment:

- Database compatibility set to 12.2.0 or higher
- MAX\_STRING\_SIZE set to 'EXTENDED'
- INMEMORY\_EXPRESSIONS\_USAGE set to 'STATIC\_ONLY' or 'ENABLE'
- INMEMORY\_VIRTUAL\_COLUMNS set to 'ENABLE'

JSON data columns must have 'IS JSON' check constraints prior to 21c. In 21c a check constraint is not required for columns with JSON data type, but the compatible parameter must be set to at least 20.

Let's switch to the json folder and log back in to the PDB:

```
<copy>
cd /home/oracle/labs/inmemory/json
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
[CDB1:oracle@dbhol:~/labs/inmemory]$ cd /home/oracle/labs/inmemory/json
[CDB1:oracle@dbhol:~/labs/inmemory/json]$ sqlplus ssb/Ora_DB4U@localhost:1521/pdb1

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

1. First let's verify that the database has been setup with the required prerequisites.

    Run the script *01\_json\_prereq.sql*

    ```
    <copy>
    @01_json_prereq.sql
    </copy>    
    ```

    or run the queries below.  

    ```
    <copy>
    show parameter compatible
    show parameter max_string_size
    show parameter inmemory_expressions_usage
    show parameter inmemory_virtual_columns
    </copy>
    ```

    Query result:

    ```
    SQL> @01_json_prereq.sql
    Connected.

    NAME                                 TYPE        VALUE
    ------------------------------------ ----------- ------------------------------
    compatible                           string      21.0.0
    noncdb_compatible                    boolean     FALSE

    NAME                                 TYPE        VALUE
    ------------------------------------ ----------- ------------------------------
    max_string_size                      string      EXTENDED

    NAME                                 TYPE        VALUE
    ------------------------------------ ----------- ------------------------------
    inmemory_expressions_usage           string      ENABLE

    NAME                                 TYPE        VALUE
    ------------------------------------ ----------- ------------------------------
    inmemory_virtual_columns             string      ENABLE
    SQL>
    ```

## Task 2: Populating JSON data in the IM column store prior to 21c

This task will focusing on using JSON data in the IM column store prior to 21c.

1. First we will display the J\_PURCHASEORDER table. This is the table we will be using for our examples and is the same table that is created and used in the 19c JSON Developer's Guide.

    Run the script *02\_j\_purchaseorder.sql*

    ```
    <copy>
    @02_j_purchaseorder.sql
    </copy>    
    ```

    or run the queries below.  

    ```
    <copy>
    desc J_PURCHASEORDER
    col table_name   format a20;
    col column_name  format a30;
    col data_type    format a30;
    col data_length  format 999999;
    col data_default format a30 WRAPPED;
    select TABLE_NAME, COLUMN_NAME, DATA_TYPE, data_length, DATA_DEFAULT from user_tab_cols
    where table_name = 'J_PURCHASEORDER'
    order by column_id;
    col constraint_name format a20;
    col search_condition format a30;
    select table_name, constraint_name, constraint_type, search_condition
    from user_constraints
    where table_name = 'J_PURCHASEORDER';
    </copy>
    ```

    Query result:

    ```
    SQL> @02_j_purchaseorder.sql
    Connected.
     Name                                      Null?    Type
     ----------------------------------------- -------- ----------------------------
     ID                                        NOT NULL VARCHAR2(32)
     DATE_LOADED                                        TIMESTAMP(6) WITH TIME ZONE
     PO_DOCUMENT                                        VARCHAR2(32767)


    TABLE_NAME           COLUMN_NAME                    DATA_TYPE                      DATA_LENGTH DATA_DEFAULT
    -------------------- ------------------------------ ------------------------------ ----------- ------------------------------
    J_PURCHASEORDER      ID                             VARCHAR2                                32
    J_PURCHASEORDER      DATE_LOADED                    TIMESTAMP(6) WITH TIME ZONE             13
    J_PURCHASEORDER      PO_DOCUMENT                    VARCHAR2                             32767


    TABLE_NAME           CONSTRAINT_NAME      C SEARCH_CONDITION
    -------------------- -------------------- - ------------------------------
    J_PURCHASEORDER      SYS_C0010666         C "ID" IS NOT NULL
    J_PURCHASEORDER      SYS_C0010669         P

    SQL>
    ```

2. The next step will define a check constraint on the PO\_DOCUMENT column to ensure well formed JSON and enable In-Memory optimizations on the JSON data.

    Run the script *03\_enable\_json.sql*

    ```
    <copy>
    @03_enable_json.sql
    </copy>    
    ```

    or run the statements below:

    ```
    <copy>
    alter table j_purchaseorder add constraint ensure_json check (po_document is json);
    col table_name   format a20;
    col column_name  format a30;
    col data_type    format a30;
    col data_length  format 999999;
    col data_default format a30 WRAPPED;
    select TABLE_NAME, COLUMN_NAME, DATA_TYPE, data_length, DATA_DEFAULT from user_tab_cols
    where table_name = 'J_PURCHASEORDER'
    order by column_id;
    col constraint_name format a20;
    col search_condition format a30;
    select table_name, constraint_name, constraint_type, search_condition
    from user_constraints
    where table_name = 'J_PURCHASEORDER';
    </copy>
    ```

    Query result:

    ```
    SQL> @03_enable_json.sql
    Connected.
    SQL>
    SQL> alter table j_purchaseorder add constraint ensure_json check (po_document is json);

    Table altered.

    SQL>
    SQL> set echo off

    TABLE_NAME           COLUMN_NAME                    DATA_TYPE                      DATA_LENGTH DATA_DEFAULT
    -------------------- ------------------------------ ------------------------------ ----------- ------------------------------
    J_PURCHASEORDER      ID                             VARCHAR2                                32
    J_PURCHASEORDER      DATE_LOADED                    TIMESTAMP(6) WITH TIME ZONE             13
    J_PURCHASEORDER      PO_DOCUMENT                    VARCHAR2                             32767
    J_PURCHASEORDER      SYS_IME_OSON_8E7EDEA606364F28B RAW                                  32767 OSON("PO_DOCUMENT" FORMAT JSON
                         FA94CD90D163BFC                                                            , 'ime' RETURNING RAW(32767)
                                                                                                   NULL ON ERROR)



    TABLE_NAME           CONSTRAINT_NAME      C SEARCH_CONDITION
    -------------------- -------------------- - ------------------------------
    J_PURCHASEORDER      ENSURE_JSON          C po_document is json
    J_PURCHASEORDER      SYS_C0010666         C "ID" IS NOT NULL
    J_PURCHASEORDER      SYS_C0010669         P

    SQL>
    ```

    Note that not only have we created a check constraint on the PO\_DOCUMENT column, but that has also resulted in the creation of a new virtual column that starts with the name SYS\_IME\_OSON. Oracle Database has created a special binary version of the PO\_DOCUMENT column.

4. Next we will run a query on the JSON data to show the functionality and peformance. Remember that we have not yet enabled in-memory processing for the JSON data.

    Run the script *04\_json\_query.sql*

    ```
    <copy>
    @04_json_query.sql
    </copy>    
    ```

    or run the queries below.

    ```
    <copy>
    set timing on
    col costcenter format a20;
    col revenue format 999,999,999,999;
    SELECT json_value(po_document, '$.CostCenter') as costcenter,
           sum(round(jt.UnitPrice * jt.Quantity)) as revenue
      FROM j_purchaseorder po,
           json_table(po.po_document
             COLUMNS (NESTED LineItems[*]
                        COLUMNS (ItemNumber NUMBER,
                                 UnitPrice PATH Part.UnitPrice,
                                 Quantity NUMBER)
                     )
           ) AS "JT"
      group by json_value(po_document, '$.CostCenter')
      order by revenue desc;
    set timing off
    select * from table(dbms_xplan.display_cursor());
    @../imstats.sql
    </copy>
    ```

    Query result:

    ```
    SQL> @04_json_query.sql
    Connected.
    SQL>
    SQL> -- JSON query
    SQL>
    SQL> col costcenter format a20;
    SQL> col revenue format 999,999,999,999;
    SQL> SELECT json_value(po_document, '$.CostCenter') as costcenter,
      2         sum(round(jt.UnitPrice * jt.Quantity)) as revenue
      3    FROM j_purchaseorder po,
      4         json_table(po.po_document
      5           COLUMNS (NESTED LineItems[*]
      6                      COLUMNS (ItemNumber NUMBER,
      7                               UnitPrice PATH Part.UnitPrice,
      8                               Quantity NUMBER)
      9                   )
     10         ) AS "JT"
     11    group by json_value(po_document, '$.CostCenter')
     12    order by revenue desc;

    COSTCENTER                    REVENUE
    -------------------- ----------------
    A50                       132,019,776
    A80                        98,583,488
    A30                        17,514,432
    A100                       16,452,224
    A60                        14,464,320
    A90                         8,270,720
    A20                         5,326,528
    A110                        4,631,296
    A0                          3,066,880
    A70                         3,055,808
    A10                         2,955,072
    A40                         2,773,184

    12 rows selected.

    Elapsed: 00:00:13.26
    SQL>

    SQL> set echo off

    Hit enter ...


    PLAN_TABLE_OUTPUT
    ------------------------------------------------------------------------------------------------------------------------------------------------------
    SQL_ID  am1a3j4z6tjaw, child number 0
    -------------------------------------
    SELECT json_value(po_document, '$.CostCenter') as costcenter,
    sum(round(jt.UnitPrice * jt.Quantity)) as revenue   FROM
    j_purchaseorder po,        json_table(po.po_document          COLUMNS
    (NESTED LineItems[*]                     COLUMNS (ItemNumber NUMBER,
                              UnitPrice PATH Part.UnitPrice,
                  Quantity NUMBER)                  )        ) AS "JT"
    group by json_value(po_document, '$.CostCenter')   order by revenue desc

    Plan hash value: 2970428439

    ----------------------------------------------------------------------------------------------------
    | Id  | Operation                | Name            | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
    ----------------------------------------------------------------------------------------------------
    |   0 | SELECT STATEMENT         |                 |       |       |       |  2966M(100)|          |
    |   1 |  SORT ORDER BY           |                 | 10000 |    18M|  9970G|  2966M  (1)| 32:11:33 |
    |   2 |   HASH GROUP BY          |                 | 10000 |    18M|  9970G|  2966M  (1)| 32:11:33 |
    |   3 |    NESTED LOOPS          |                 |  5227M|  9357G|       |    17M  (1)| 00:11:21 |
    |*  4 |     TABLE ACCESS FULL    | J_PURCHASEORDER |   640K|  1170M|       | 26385   (1)| 00:00:02 |
    |   5 |     JSONTABLE EVALUATION |                 |       |       |       |            |          |
    ----------------------------------------------------------------------------------------------------

    Predicate Information (identified by operation id):
    ---------------------------------------------------

       4 - filter(INTERNAL_FUNCTION("PO_DOCUMENT" /*+ LOB_BY_VALUE */ ))


    28 rows selected.

    Hit enter ...


    NAME                                                              VALUE
    -------------------------------------------------- --------------------
    CPU used by this session                                           1323
    physical reads                                                    96828
    session logical reads                                             96982
    session pga memory                                             18155768

    SQL>
    ```

5. Now we will enable the J\_PURCHASEORDER table for inmemory and populate it.

    Run the script *05\_json\_pop.sql*

    ```
    <copy>
    @05_json_pop.sql
    </copy>
    ```

    or run the queries below.

    ```
    <copy>
    alter table j_purchaseorder inmemory;
    exec dbms_inmemory.populate(USER, 'J_PURCHASEORDER');
    </copy>
    ```

    Query result:

    ```
    SQL> @05_json_pop.sql
    Connected.
    SQL>
    SQL> alter table j_purchaseorder inmemory;

    Table altered.

    SQL>
    SQL> exec dbms_inmemory.populate(USER, 'J_PURCHASEORDER');

    PL/SQL procedure successfully completed.

    SQL>
    ```

6. Verify that the J\_PURCHASEORDER table has been populated in the IM column store.

    Run the script *06\_im\_populated.sql*

    ```
    <copy>
    @06_im_populated.sql
    </copy>    
    ```

    or run the query below:

    ```
    <copy>
    olumn owner format a10;
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
    SQL> @06_im_populated.sql
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
    SSB        J_PURCHASEORDER                      COMPLETED            793,198,592    1,069,285,376                0
    SSB        LINEORDER            PART_1994       COMPLETED            563,601,408      585,236,480                0
    SSB        LINEORDER            PART_1995       COMPLETED            563,470,336      585,236,480                0
    SSB        LINEORDER            PART_1996       COMPLETED            565,010,432      587,333,632                0
    SSB        LINEORDER            PART_1997       COMPLETED            563,314,688      585,236,480                0
    SSB        LINEORDER            PART_1998       COMPLETED            329,015,296      342,556,672                0
    SSB        PART                                 COMPLETED             56,893,440       21,168,128                0
    SSB        SUPPLIER                             COMPLETED              1,769,472        2,228,224                0

    10 rows selected.

    SQL>
    ```

7. Since a virtual column was created it will be stored in the IM column store as an In-Memory Expression (IME). Let's check how much additional space the binary JSON data requires.

    Run the script *07\_ime\_usage.sql*

    ```
    <copy>
    @07_ime_usage.sql
    </copy>    
    ```

    or run the queries below:

    ```
    <copy>
    col owner          heading "Owner"          format a10;
    col object_name    heading "Object"         format a20;
    col partition_name heading "Partition|Name" format a20;
    col column_name    heading "Column|Name"    format a15;
    col t_imeu         heading "Total|IMEUs"    format 999999;
    col space          heading "Used|Space(MB)" format 999,999,999;
    select
      o.owner,
      o.object_name,
      o.subobject_name as partition_name,
      i.column_name,
      count(*) t_imeu,
      sum(i.length)/1024/1024 space
    from
      v$im_imecol_cu i,
      dba_objects o
    where
      i.objd = o.object_id
    group by
      o.owner,
      o.object_name,
      o.subobject_name,
      i.column_name;
    </copy>
    ```

    Query result:

    ```
    SQL> @07_ime_usage.sql
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
    SSB        J_PURCHASEORDER                           SYS_IME_OSON_8E      11           84
                                                         7EDEA606364F28B
                                                         FA94CD90D163BFC


    SQL>
    ```

    Not very much space, but like some of the other features that we've seen in this Lab it does require some additional space in the IM column store in-memory optimized JSON data.

8. Now let's run the JSON query again. This is the same query from step 3.

    Run the script *08\_json\_query.sql*

    ```
    <copy>
    @08_json_query.sql
    </copy>    
    ```

    or run the queries below:

    ```
    <copy>
    set timing on
    col costcenter format a20;
    col revenue format 999,999,999,999;
    SELECT json_value(po_document, '$.CostCenter') as costcenter,
           sum(round(jt.UnitPrice * jt.Quantity)) as revenue
      FROM j_purchaseorder po,
           json_table(po.po_document
             COLUMNS (NESTED LineItems[*]
                        COLUMNS (ItemNumber NUMBER,
                                 UnitPrice PATH Part.UnitPrice,
                                 Quantity NUMBER)
                     )
           ) AS "JT"
      group by json_value(po_document, '$.CostCenter')
      order by revenue desc;
    set timing off
    select * from table(dbms_xplan.display_cursor());
    @../imstats.sql
    </copy>
    ```

    Query result:

    ```
    SQL> @08_json_query.sql
    Connected.
    SQL>
    SQL> -- JSON query
    SQL>
    SQL> col costcenter format a20;
    SQL> col revenue format 999,999,999,999;
    SQL> SELECT json_value(po_document, '$.CostCenter') as costcenter,
      2         sum(round(jt.UnitPrice * jt.Quantity)) as revenue
      3    FROM j_purchaseorder po,
      4         json_table(po.po_document
      5           COLUMNS (NESTED LineItems[*]
      6                      COLUMNS (ItemNumber NUMBER,
      7                               UnitPrice PATH Part.UnitPrice,
      8                               Quantity NUMBER)
      9                   )
     10         ) AS "JT"
     11    group by json_value(po_document, '$.CostCenter')
     12    order by revenue desc;

    COSTCENTER                    REVENUE
    -------------------- ----------------
    A50                       132,019,776
    A80                        98,583,488
    A30                        17,514,432
    A100                       16,452,224
    A60                        14,464,320
    A90                         8,270,720
    A20                         5,326,528
    A110                        4,631,296
    A0                          3,066,880
    A70                         3,055,808
    A10                         2,955,072
    A40                         2,773,184

    12 rows selected.

    Elapsed: 00:00:06.22
    SQL>

    SQL> set echo off

    Hit enter ...


    PLAN_TABLE_OUTPUT
    ------------------------------------------------------------------------------------------------------------------------------------------------------
    SQL_ID  am1a3j4z6tjaw, child number 0
    -------------------------------------
    SELECT json_value(po_document, '$.CostCenter') as costcenter,
    sum(round(jt.UnitPrice * jt.Quantity)) as revenue   FROM
    j_purchaseorder po,        json_table(po.po_document          COLUMNS
    (NESTED LineItems[*]                     COLUMNS (ItemNumber NUMBER,
                              UnitPrice PATH Part.UnitPrice,
                  Quantity NUMBER)                  )        ) AS "JT"
    group by json_value(po_document, '$.CostCenter')   order by revenue desc

    Plan hash value: 2970428439

    ---------------------------------------------------------------------------------------------------------
    | Id  | Operation                     | Name            | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
    ---------------------------------------------------------------------------------------------------------
    |   0 | SELECT STATEMENT              |                 |       |       |       |  2966M(100)|          |
    |   1 |  SORT ORDER BY                |                 | 10000 |    18M|  9970G|  2966M  (1)| 32:11:32 |
    |   2 |   HASH GROUP BY               |                 | 10000 |    18M|  9970G|  2966M  (1)| 32:11:32 |
    |   3 |    NESTED LOOPS               |                 |  5227M|  9357G|       |    17M  (1)| 00:11:20 |
    |*  4 |     TABLE ACCESS INMEMORY FULL| J_PURCHASEORDER |   640K|  1170M|       |   983   (1)| 00:00:01 |
    |   5 |     JSONTABLE EVALUATION      |                 |       |       |       |            |          |
    ---------------------------------------------------------------------------------------------------------

    Predicate Information (identified by operation id):
    ---------------------------------------------------

       4 - filter(INTERNAL_FUNCTION("PO_DOCUMENT" /*+ LOB_BY_VALUE */ ))


    28 rows selected.

    Hit enter ...


    NAME                                                              VALUE
    -------------------------------------------------- --------------------
    CPU used by this session                                            624
    IM scan CUs columns accessed                                         11
    IM scan CUs memcompress for query low                                11
    IM scan EU rows                                                  640000
    IM scan EUs columns accessed                                         11
    IM scan EUs memcompress for query low                                11
    IM scan rows                                                     640000
    IM scan rows pcode aggregated                                    640000
    IM scan rows projected                                           639999
    IM scan rows valid                                               640000
    physical reads                                                        1
    session logical reads                                             96928
    session logical reads - IM                                        96826
    session pga memory                                             17828088
    table scans (IM)                                                      1

    15 rows selected.

    SQL>
    ```

## Task 3: Populating JSON data in the IM column using the JSON data type in 21c

1. Now let's switch to a new table with the PO\_DOCUMENT column defined as a JSON data type. Recall that this is new in Oracle Database 21c.

    Run the script *09\_json\_purchaseorder.sql*

    ```
    <copy>
    @09_json_purchaseorder.sql
    </copy>    
    ```

    or run the queries below:

    ```
    <copy>
    col table_name   format a20;
    col column_name  format a30;
    col data_type    format a30;
    col data_length  format 999999;
    col data_default format a30 WRAPPED;
    select TABLE_NAME, COLUMN_NAME, DATA_TYPE, data_length, DATA_DEFAULT from user_tab_cols
    where table_name = 'JSON_PURCHASEORDER'
    order by column_id;
    col table_name format a20;
    col constraint_name format a20;
    col search_condition format a30;
    select table_name, constraint_name, constraint_type, search_condition
    from user_constraints
    where table_name = 'JSON_PURCHASEORDER';
    </copy>
    ```

    Query result:

    ```
    SQL> @09_json_purchaseorder.sql
    Connected.

                         Column
    TABLE_NAME           Name                           DATA_TYPE                      DATA_LENGTH DATA_DEFAULT
    -------------------- ------------------------------ ------------------------------ ----------- ------------------------------
    JSON_PURCHASEORDER   ID                             VARCHAR2                                32
    JSON_PURCHASEORDER   DATE_LOADED                    TIMESTAMP(6) WITH TIME ZONE             13
    JSON_PURCHASEORDER   PO_DOCUMENT                    JSON                                  8200
    JSON_PURCHASEORDER   SYS_IME_OSON_142EAA20DFA84F49B RAW                                  32767 OSON("PO_DOCUMENT" FORMAT OSON
                         FE69E0834781370                                                            , 'ime' RETURNING RAW(32767)
                                                                                                   NULL ON ERROR)



    TABLE_NAME           CONSTRAINT_NAME      C SEARCH_CONDITION
    -------------------- -------------------- - ------------------------------
    JSON_PURCHASEORDER   SYS_C0010665         C "ID" IS NOT NULL
    JSON_PURCHASEORDER   SYS_C0010667         P

    SQL>
    ```

    Note that no constraint definition is required.

2. Next we will populate the JSON\_PURCHASEORDER table with the JSON data type and we will remove the previous J\_PURCHASEORDER table since we won't need it any longer.

    Run the script *10\_json\_pop.sql*

    ```
    <copy>
    @10_json_pop.sql
    </copy>    
    ```

    or run the queries below:

    ```
    <copy>
    alter table j_purchaseorder no inmemory;
    alter table json_purchaseorder inmemory;
    exec dbms_inmemory.populate(USER, 'JSON_PURCHASEORDER');
    </copy>
    ```

    Query result:

    ```
    SQL> @10_json_pop.sql
    Connected.
    SQL>
    SQL> alter table j_purchaseorder no inmemory;

    Table altered.

    SQL>
    SQL> alter table json_purchaseorder inmemory;

    Table altered.

    SQL>
    SQL> exec dbms_inmemory.populate(USER, 'JSON_PURCHASEORDER');

    PL/SQL procedure successfully completed.

    SQL>
    ```

3. Make sure that the JSON\_PURCHASEORDER table has been fully populated.

    Run the script *11\_im\_populated.sql*

    ```
    <copy>
    @11_im_populated.sql
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
    from  v$im_segments
    order by inmemory_size;
    </copy>
    ```

    Query result:

    ```
    SQL> @11_im_populated.sql
    Connected.
    SQL>
    SQL> -- Query the view v$IM_SEGMENTS to shows what objects are in the column store
    SQL> -- and how much of the objects were populated. When the BYTES_NOT_POPULATED is 0
    SQL> -- it indicates the entire table was populated.
    SQL>
    SQL> select owner, segment_name, partition_name, populate_status, bytes,
      2         inmemory_size, bytes_not_populated
      3  from   v$im_segments
      4  order by inmemory_size;

                                    Partition                                               In-Memory            Bytes
    Owner      SEGMENT_NAME         Name            POPULATE_STATUS        Disk Size             Size    Not Populated
    ---------- -------------------- --------------- --------------- ---------------- ---------------- ----------------
    SSB        DATE_DIM                             COMPLETED                122,880        1,179,648                0
    SSB        SUPPLIER                             COMPLETED              1,769,472        2,228,224                0
    SSB        PART                                 COMPLETED             56,893,440       21,168,128                0
    SSB        CUSTOMER                             COMPLETED             24,928,256       23,199,744                0
    SSB        LINEORDER            PART_1998       COMPLETED            329,015,296      342,556,672                0
    SSB        LINEORDER            PART_1995       COMPLETED            563,470,336      585,236,480                0
    SSB        LINEORDER            PART_1994       COMPLETED            563,601,408      585,236,480                0
    SSB        LINEORDER            PART_1997       COMPLETED            563,314,688      585,236,480                0
    SSB        LINEORDER            PART_1996       COMPLETED            565,010,432      587,333,632                0
    SSB        JSON_PURCHASEORDER                   COMPLETED            691,912,704      816,513,024                0

    10 rows selected.

    SQL>
    ```

4. Now we will query the JSON\_PURCHASEORDER table with the same basic query that we used in Step 7.

    Run the script *12\_json\_query.sql*

    ```
    <copy>
    @12_json_query.sql
    </copy>    
    ```

    or run the queries below:

    ```
    <copy>
    set timing on
    col costcenter format a20;
    col revenue format 999,999,999,999;
    SELECT json_value(po_document, '$.CostCenter') as costcenter,
           sum(round(jt.UnitPrice * jt.Quantity)) as revenue
      FROM json_purchaseorder po,
           json_table(po.po_document
             COLUMNS (NESTED LineItems[*]
                        COLUMNS (ItemNumber NUMBER,
                                 UnitPrice PATH Part.UnitPrice,
                                 Quantity NUMBER)
                     )
           ) AS "JT"
      group by json_value(po_document, '$.CostCenter')
      order by revenue desc;
    set timing off
    select * from table(dbms_xplan.display_cursor());
    @../imstats.sql
    </copy>
    ```

    Query result:

    ```
    SQL> @12_json_query.sql
    Connected.
    SQL>
    SQL> -- JSON query
    SQL>
    SQL> col costcenter format a20;
    SQL> col revenue format 999,999,999,999;
    SQL> SELECT json_value(po_document, '$.CostCenter') as costcenter,
      2         sum(round(jt.UnitPrice * jt.Quantity)) as revenue
      3    FROM json_purchaseorder po,
      4         json_table(po.po_document
      5           COLUMNS (NESTED LineItems[*]
      6                      COLUMNS (ItemNumber NUMBER,
      7                               UnitPrice PATH Part.UnitPrice,
      8                               Quantity NUMBER)
      9                   )
     10         ) AS "JT"
     11    group by json_value(po_document, '$.CostCenter')
     12    order by revenue desc;

    COSTCENTER                    REVENUE
    -------------------- ----------------
    A50                       132,019,776
    A80                        98,583,488
    A30                        17,514,432
    A100                       16,452,224
    A60                        14,464,320
    A90                         8,270,720
    A20                         5,326,528
    A110                        4,631,296
    A0                          3,066,880
    A70                         3,055,808
    A10                         2,955,072
    A40                         2,773,184

    12 rows selected.

    Elapsed: 00:00:06.76
    SQL>

    SQL> set echo off

    Hit enter ...


    PLAN_TABLE_OUTPUT
    ------------------------------------------------------------------------------------------------------------------------------------------------------
    SQL_ID  gbbuqa7aktrvf, child number 0
    -------------------------------------
    SELECT json_value(po_document, '$.CostCenter') as costcenter,
    sum(round(jt.UnitPrice * jt.Quantity)) as revenue   FROM
    json_purchaseorder po,        json_table(po.po_document
    COLUMNS (NESTED LineItems[*]                     COLUMNS (ItemNumber
    NUMBER,                              UnitPrice PATH Part.UnitPrice,
                             Quantity NUMBER)                  )        )
    AS "JT"   group by json_value(po_document, '$.CostCenter')   order by
    revenue desc

    Plan hash value: 2879879702

    ----------------------------------------------------------------------------------------------------
    | Id  | Operation                     | Name               | Rows  | Bytes | Cost (%CPU)| Time     |
    ----------------------------------------------------------------------------------------------------
    |   0 | SELECT STATEMENT              |                    |       |       |    17M(100)|          |
    |   1 |  SORT ORDER BY                |                    |     1 |   851 |    17M  (4)| 00:11:40 |
    |   2 |   HASH GROUP BY               |                    |     1 |   851 |    17M  (4)| 00:11:40 |
    |   3 |    NESTED LOOPS               |                    |  5227M|  4143G|    17M  (1)| 00:11:20 |
    |   4 |     TABLE ACCESS INMEMORY FULL| JSON_PURCHASEORDER |   640K|   516M|   859   (1)| 00:00:01 |
    |   5 |     JSONTABLE EVALUATION      |                    |       |       |            |          |
    ----------------------------------------------------------------------------------------------------


    24 rows selected.

    Hit enter ...


    NAME                                                              VALUE
    -------------------------------------------------- --------------------
    CPU used by this session                                            679
    IM scan CUs columns accessed                                         10
    IM scan CUs memcompress for query low                                10
    IM scan rows                                                     640000
    IM scan rows projected                                           639999
    IM scan rows valid                                               640000
    session logical reads                                             84559
    session logical reads - IM                                        84462
    session pga memory                                             17893624
    table scans (IM)                                                      1

    10 rows selected.

    SQL>
    ```

5. (Optional) - You can optionally remove the JSON table(s) from the IM column store to save space and re-run this lab if you wish.

    Run the script *13\_json\_cleanup.sql*

    ```
    <copy>
    @13_json_cleanup.sql
    </copy>    
    ```

    or run the queries below:

    ```
    <copy>
    alter table json_purchaseorder no inmemory;
    alter table j_purchaseorder drop constraint ensure_json;
    </copy>
    ```

    Query result:

    ```
    SQL> @13_json_cleanup.sql
    Connected.
    SQL>
    SQL> alter table json_purchaseorder no inmemory;

    Table altered.

    SQL>
    SQL> alter table j_purchaseorder drop constraint ensure_json;

    Table altered.

    SQL>
    ```

6. Exit lab

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
    [CDB1:oracle@dbhol:~/labs/inmemory/json]$ cd ..
    [CDB1:oracle@dbhol:~/labs/inmemory]$
    ```

## Conclusion

This lab demonstrated how Database In-Memory can optimize the access of JSON data, making it feasible to perform analytic queries on JSON data.

You may now **proceed to the next lab**.

## Acknowledgements

- **Author** - Andy Rivenes, Product Manager,  Database In-Memory
- **Contributors** -
- **Last Updated By/Date** - Andy Rivenes, August 2022
