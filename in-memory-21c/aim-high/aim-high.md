# Automatic In-Memory High

## Introduction
Watch the video below to get an overview of using Database In-Memory.

[](youtube:y3tQeVGuo6g)

Watch the video below to learn about Automatic In-Memory High.
[](youtube:pFWjl1G7uDI)

Watch the video below for a quick walk-through of this lab.
[Automatic In-Memory High](videohub:1_0rzwly4i)

### Objectives

-   Learn how to Automatic In-Memory (AIM) level HIGH works
-   Perform various queries invoking AIM with INMEMORY_AUTOMATIC_LEVEL set to HIGH

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

In Oracle Database 18c a feature called Automatic In-Memory (AIM) was added. The goal of AIM is to manage the contents of the IM column store based on usage. AIM initially had two levels, LOW and MEDIUM, that enabled automatic management of IM column store contents once the IM column store became full. In Oracle Database 21c a third level was added that automatically manages all non-system segments without having to first enable the objects for in-memory.

This Lab will explore the new AIM level HIGH and how it works. A new schema will be used, the AIM schema with small, medium and large tables. This will make it easier to show how AIM works as the column store experiences "memory pressure" (i.e. gets full). The LINEORDER table in the SSB schema will be used to help "fill up" the IM column store and then the AIM tables will be used to show how AIM can manage the total number of objects for maximum benefit.


## Task 1: Verify Directory Definitions

In this Lab we will be populating external data from a local directory and we will need to define a database directory to use in our external table definitions to point the database to our external data.

Let's switch to the aim-high folder and log back in to the PDB:

```
<copy>
cd /home/oracle/labs/inmemory/aim-high
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
[CDB1:oracle@dbhol:~/labs/inmemory]$ cd /home/oracle/labs/inmemory/aim-high
[CDB1:oracle@dbhol:~/labs/inmemory/aim-high]$ sqlplus ssb/Ora_DB4U@localhost:1521/pdb1

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

1. First let's check the inmemory status of the objects in the SSB and AIM schemas:

    Run the script *01\_aim\_attributes.sql*

    ```
    <copy>
    @01_aim_attributes.sql
    </copy>    
    ```

    or run the query below:  

    Query result:

    ```
    SQL> @01_aim_attributes.sql
    Connected.
    SQL>
    SQL> -- Show table attributes
    SQL>
    SQL> select owner, table_name, NULL as partition_name, inmemory,
      2         inmemory_priority, inmemory_distribute, inmemory_compression
      3  from   dba_tables
      4  where owner in ('AIM','SSB')
      5  UNION ALL
      6  select table_owner as owner, table_name, partition_name, inmemory,
      7         inmemory_priority, inmemory_distribute, inmemory_compression
      8  from   dba_tab_partitions
      9  where table_owner in ('AIM','SSB')
     10  order by owner, table_name, partition_name;

                                                               INMEMORY   INMEMORY     INMEMORY
    OWNER      TABLE_NAME           PARTITION_NAME  INMEMORY   PRIORITY   DISTRIBUTE   COMPRESSION
    ---------- -------------------- --------------- ---------- ---------- ------------ --------------
    AIM        LRGTAB1                              DISABLED
    AIM        LRGTAB2                              DISABLED
    AIM        LRGTAB3                              DISABLED
    AIM        LRGTAB4                              DISABLED
    AIM        LRGTAB5                              DISABLED
    AIM        LRGTAB6                              DISABLED
    AIM        MEDTAB1                              DISABLED
    AIM        MEDTAB2                              DISABLED
    AIM        MEDTAB3                              DISABLED
    AIM        SMTAB1                               DISABLED
    AIM        SMTAB2                               DISABLED
    AIM        SMTAB3                               DISABLED
    SSB        CHICAGO_BAD                          DISABLED
    SSB        CHICAGO_DATA                         DISABLED
    SSB        CUSTOMER                             DISABLED
    SSB        DATE_DIM                             DISABLED
    SSB        EXT_CUST                             DISABLED
    SSB        EXT_CUST_BULGARIA                    DISABLED
    SSB        EXT_CUST_HYBRID_PART N1
    SSB        EXT_CUST_HYBRID_PART N2
    SSB        EXT_CUST_HYBRID_PART N3              DISABLED
    SSB        EXT_CUST_HYBRID_PART N4              DISABLED
    SSB        EXT_CUST_HYBRID_PART
    SSB        EXT_CUST_NORWAY                      DISABLED
    SSB        EXT_CUST_PART        N1
    SSB        EXT_CUST_PART        N2
    SSB        EXT_CUST_PART        N3
    SSB        EXT_CUST_PART        N4
    SSB        EXT_CUST_PART        N5
    SSB        EXT_CUST_PART
    SSB        JSON_PURCHASEORDER                   DISABLED
    SSB        J_PURCHASEORDER                      DISABLED
    SSB        LINEORDER            PART_1994       DISABLED
    SSB        LINEORDER            PART_1995       DISABLED
    SSB        LINEORDER            PART_1996       DISABLED
    SSB        LINEORDER            PART_1997       DISABLED
    SSB        LINEORDER            PART_1998       DISABLED
    SSB        LINEORDER
    SSB        PART                                 DISABLED
    SSB        SUPPLIER                             DISABLED

    40 rows selected.

    SQL>
    ```

    Note the inmemory status of the tables. Here they are all disabled, but that might not be the case in your environment.

2. Next we will verify that all of the tables are disabled for INMEMORY so that we can ensure that we will start with a clean setup.

    Run the script *02\_disable\_tables.sql*

    ```
    <copy>
    @02_disable_tables.sql
    </copy>    
    ```

    or run the query below:  

    ```
    <copy>
    declare
      v_ddl varchar2(1000);
    begin
      for tab_cursor in (
        select owner, table_name
        from   dba_tables
        where  owner not in ('AUDSYS','SYS')
        and    inmemory = 'ENABLED'
      )
      loop
        v_ddl := 'alter table '||tab_cursor.owner||'.'||tab_cursor.table_name||' no inmemory';
        dbms_output.put_line(v_ddl);
        execute immediate v_ddl;
      end loop;
      --
      for part_cursor in (
        select table_owner, table_name, partition_name
        from   dba_tab_partitions
        where  table_owner not in ('AUDSYS','SYS')
        and    inmemory = 'ENABLED'
      )
      loop
        v_ddl := 'alter table '||part_cursor.table_owner||'.'||part_cursor.table_name||
          ' modify partition '||part_cursor.partition_name||' no inmemory';
        dbms_output.put_line(v_ddl);
        execute immediate v_ddl;
      end loop;
    end;
    /
    </copy>
    ```

    Query result:

    ```
    SQL> @02_disable_tables.sql
    Connected.

    PL/SQL procedure successfully completed.


    PL/SQL procedure successfully completed.

    SQL>
    ```

3. Now we will populate the LINEORDER partitions. Since we are explicitly enabling the partitions for INMEMORY they will not be touched by AIM. These partitions will serve as a constant filler so that the IM column store is close to full. This will make it easier to ensure that the IM column store is under memory pressure. Recall that this is required for AIM to operate.

    Run the script *03\_pop\_ssb\_tables.sql*

    ```
    <copy>
    @03_pop_ssb_tables.sql
    </copy>    
    ```

    or run the queries below:

    ```
    <copy>
    alter table LINEORDER inmemory;
    exec dbms_inmemory.populate('SSB','LINEORDER');
    </copy>
    ```

    Query result:

    ```
    SQL> @03_pop_ssb_tables.sql
    Connected.
    SQL>
    SQL> alter table ssb.lineorder inmemory;

    Table altered.

    SQL> exec dbms_inmemory.populate('SSB','LINEORDER');

    PL/SQL procedure successfully completed.

    SQL>
    ```

4. Verify that all of the LINEORDER partitions are populated.

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
    where owner not in ('AUDSYS','SYS')
    order by owner, segment_name, partition_name;

    select * from v$inmemory_area;
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
    SQL> select * from v$inmemory_area;

    POOL                       ALLOC_BYTES USED_BYTES POPULATE_STATUS     CON_ID
    -------------------------- ----------- ---------- --------------- ----------
    1MB POOL                    3252682752 2192572416 DONE                     3
    64KB POOL                    201326592    5439488 DONE                     3

    SQL>
    ```

    Verify that all of the LINEORDER partitions are populated before continuing on with the lab.

5. Let's re-check the inmemory status of the objects in the SSB and AIM schemas:

    Run the script *05\_aim\_attributes.sql*

    ```
    <copy>
    @05_aim_attributes.sql
    </copy>    
    ```

    or run the query below:  

    ```
    <copy>
    column owner format a10;
    column table_name format a20;
    column partition_name format a15;
    column inmemory format a10;
    column INMEMORY_PRIORITY heading 'INMEMORY|PRIORITY' format a10;
    column INMEMORY_DISTRIBUTE heading 'INMEMORY|DISTRIBUTE' format a12;
    column INMEMORY_COMPRESSION heading 'INMEMORY|COMPRESSION' format a14;
    select owner, table_name, NULL as partition_name, inmemory,
           inmemory_priority, inmemory_distribute, inmemory_compression
    from   dba_tables
    where owner in ('AIM','SSB')
    UNION ALL
    select table_owner as owner, table_name, partition_name, inmemory,
           inmemory_priority, inmemory_distribute, inmemory_compression
    from   dba_tab_partitions
    where table_owner in ('AIM','SSB')
    order by owner, table_name, partition_name;
    </copy>
    ```

    Query result:

    ```
    SQL> @05_aim_attributes.sql
    Connected.
    SQL>
    SQL> -- Show table attributes
    SQL>
    SQL> select owner, table_name, NULL as partition_name, inmemory,
      2         inmemory_priority, inmemory_distribute, inmemory_compression
      3  from   dba_tables
      4  where owner in ('AIM','SSB')
      5  UNION ALL
      6  select table_owner as owner, table_name, partition_name, inmemory,
      7         inmemory_priority, inmemory_distribute, inmemory_compression
      8  from   dba_tab_partitions
      9  where table_owner in ('AIM','SSB')
     10  order by owner, table_name, partition_name;

                                                               INMEMORY   INMEMORY     INMEMORY
    OWNER      TABLE_NAME           PARTITION_NAME  INMEMORY   PRIORITY   DISTRIBUTE   COMPRESSION
    ---------- -------------------- --------------- ---------- ---------- ------------ --------------
    AIM        LRGTAB1                              DISABLED
    AIM        LRGTAB2                              DISABLED
    AIM        LRGTAB3                              DISABLED
    AIM        LRGTAB4                              DISABLED
    AIM        LRGTAB5                              DISABLED
    AIM        LRGTAB6                              DISABLED
    AIM        MEDTAB1                              DISABLED
    AIM        MEDTAB2                              DISABLED
    AIM        MEDTAB3                              DISABLED
    AIM        SMTAB1                               DISABLED
    AIM        SMTAB2                               DISABLED
    AIM        SMTAB3                               DISABLED
    SSB        CHICAGO_BAD                          DISABLED
    SSB        CHICAGO_DATA                         DISABLED
    SSB        CUSTOMER                             DISABLED
    SSB        DATE_DIM                             DISABLED
    SSB        EXT_CUST                             DISABLED
    SSB        EXT_CUST_BULGARIA                    DISABLED
    SSB        EXT_CUST_HYBRID_PART N1
    SSB        EXT_CUST_HYBRID_PART N2
    SSB        EXT_CUST_HYBRID_PART N3              DISABLED
    SSB        EXT_CUST_HYBRID_PART N4              DISABLED
    SSB        EXT_CUST_HYBRID_PART
    SSB        EXT_CUST_NORWAY                      DISABLED
    SSB        EXT_CUST_PART        N1
    SSB        EXT_CUST_PART        N2
    SSB        EXT_CUST_PART        N3
    SSB        EXT_CUST_PART        N4
    SSB        EXT_CUST_PART        N5
    SSB        EXT_CUST_PART
    SSB        JSON_PURCHASEORDER                   DISABLED
    SSB        J_PURCHASEORDER                      DISABLED
    SSB        LINEORDER            PART_1994       ENABLED    NONE       AUTO         FOR QUERY LOW
    SSB        LINEORDER            PART_1995       ENABLED    NONE       AUTO         FOR QUERY LOW
    SSB        LINEORDER            PART_1996       ENABLED    NONE       AUTO         FOR QUERY LOW
    SSB        LINEORDER            PART_1997       ENABLED    NONE       AUTO         FOR QUERY LOW
    SSB        LINEORDER            PART_1998       ENABLED    NONE       AUTO         FOR QUERY LOW
    SSB        LINEORDER
    SSB        PART                                 DISABLED
    SSB        SUPPLIER                             DISABLED

    40 rows selected.

    SQL>
    ```

    Notice that the LINEORDER partitions are now enabled for inmemory but all other objects have an inmemory status of blank or DISABLED.

6. Now we will enable AIM level high.

    Run the script *06\_aim\_high.sql*

    ```
    <copy>
    @06_aim_high.sql
    </copy>
    ```

    or run the query below:

    ```
    <copy>
    show parameters inmemory_automatic_level
    alter system set inmemory_automatic_level=high;
    show parameters inmemory_automatic_level
    </copy>
    ```

    Query result:

    ```
    SQL> @06_aim_high.sql
    Connected.

    NAME                                 TYPE        VALUE
    ------------------------------------ ----------- ------------------------------
    inmemory_automatic_level             string      OFF

    System altered.


    NAME                                 TYPE        VALUE
    ------------------------------------ ----------- ------------------------------
    inmemory_automatic_level             string      HIGH
    SQL>
    ```

7. Let's re-check the in-memory status of the objects in the SSB and AIM schemas:

    Run the script *07\_aim\_attributes.sql*

    ```
    <copy>
    @07_aim_attributes.sql
    </copy>    
    ```

    or run the query below:  

    ```
    <copy>
    column owner format a10;
    column table_name format a20;
    column partition_name format a15;
    column inmemory format a10;
    column INMEMORY_PRIORITY heading 'INMEMORY|PRIORITY' format a10;
    column INMEMORY_DISTRIBUTE heading 'INMEMORY|DISTRIBUTE' format a12;
    column INMEMORY_COMPRESSION heading 'INMEMORY|COMPRESSION' format a14;
    select owner, table_name, NULL as partition_name, inmemory,
           inmemory_priority, inmemory_distribute, inmemory_compression
    from   dba_tables
    where owner in ('AIM','SSB')
    UNION ALL
    select table_owner as owner, table_name, partition_name, inmemory,
           inmemory_priority, inmemory_distribute, inmemory_compression
    from   dba_tab_partitions
    where table_owner in ('AIM','SSB')
    order by owner, table_name, partition_name;
    </copy>
    ```

    Query result:

    ```
    SQL> @07_aim_attributes.sql
    Connected.
    SQL>
    SQL> -- Show table attributes
    SQL>
    SQL> select owner, table_name, NULL as partition_name, inmemory,
      2         inmemory_priority, inmemory_distribute, inmemory_compression
      3  from   dba_tables
      4  where owner in ('AIM','SSB')
      5  UNION ALL
      6  select table_owner as owner, table_name, partition_name, inmemory,
      7         inmemory_priority, inmemory_distribute, inmemory_compression
      8  from   dba_tab_partitions
      9  where table_owner in ('AIM','SSB')
     10  order by owner, table_name, partition_name;

                                                               INMEMORY   INMEMORY     INMEMORY
    OWNER      TABLE_NAME           PARTITION_NAME  INMEMORY   PRIORITY   DISTRIBUTE   COMPRESSION
    ---------- -------------------- --------------- ---------- ---------- ------------ --------------
    AIM        LRGTAB1                              ENABLED    NONE       AUTO         AUTO
    AIM        LRGTAB2                              ENABLED    NONE       AUTO         AUTO
    AIM        LRGTAB3                              ENABLED    NONE       AUTO         AUTO
    AIM        LRGTAB4                              ENABLED    NONE       AUTO         AUTO
    AIM        LRGTAB5                              ENABLED    NONE       AUTO         AUTO
    AIM        LRGTAB6                              ENABLED    NONE       AUTO         AUTO
    AIM        MEDTAB1                              ENABLED    NONE       AUTO         AUTO
    AIM        MEDTAB2                              ENABLED    NONE       AUTO         AUTO
    AIM        MEDTAB3                              ENABLED    NONE       AUTO         AUTO
    AIM        SMTAB1                               ENABLED    NONE       AUTO         AUTO
    AIM        SMTAB2                               ENABLED    NONE       AUTO         AUTO
    AIM        SMTAB3                               ENABLED    NONE       AUTO         AUTO
    SSB        CHICAGO_BAD                          ENABLED    NONE       AUTO         AUTO
    SSB        CHICAGO_DATA                         ENABLED    NONE       AUTO         AUTO
    SSB        CUSTOMER                             ENABLED    NONE       AUTO         AUTO
    SSB        DATE_DIM                             ENABLED    NONE       AUTO         AUTO
    SSB        EXT_CUST                             DISABLED
    SSB        EXT_CUST_BULGARIA                    ENABLED    NONE       AUTO         AUTO
    SSB        EXT_CUST_HYBRID_PART N1
    SSB        EXT_CUST_HYBRID_PART N2
    SSB        EXT_CUST_HYBRID_PART N3              DISABLED
    SSB        EXT_CUST_HYBRID_PART N4              DISABLED
    SSB        EXT_CUST_HYBRID_PART
    SSB        EXT_CUST_NORWAY                      ENABLED    NONE       AUTO         AUTO
    SSB        EXT_CUST_PART        N1
    SSB        EXT_CUST_PART        N2
    SSB        EXT_CUST_PART        N3
    SSB        EXT_CUST_PART        N4
    SSB        EXT_CUST_PART        N5
    SSB        EXT_CUST_PART
    SSB        JSON_PURCHASEORDER                   ENABLED    NONE       AUTO         AUTO
    SSB        J_PURCHASEORDER                      ENABLED    NONE       AUTO         AUTO
    SSB        LINEORDER            PART_1994       ENABLED    NONE       AUTO         FOR QUERY LOW
    SSB        LINEORDER            PART_1995       ENABLED    NONE       AUTO         FOR QUERY LOW
    SSB        LINEORDER            PART_1996       ENABLED    NONE       AUTO         FOR QUERY LOW
    SSB        LINEORDER            PART_1997       ENABLED    NONE       AUTO         FOR QUERY LOW
    SSB        LINEORDER            PART_1998       ENABLED    NONE       AUTO         FOR QUERY LOW
    SSB        LINEORDER
    SSB        PART                                 ENABLED    NONE       AUTO         AUTO
    SSB        SUPPLIER                             ENABLED    NONE       AUTO         AUTO

    40 rows selected.

    SQL>
    ```

    Notice that now all of the tables are enabled for inmemory and notice that all but the LINEORDER partitions have an inmemory compression level of AUTO. This is new with AIM level high.

8.  Now lets take a look at what is happening with IM column store population.

    Run the script *08\_im\_populated.sql*

    ```
    <copy>
    @08_im_populated.sql
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

    select * from v$inmemory_area;
    </copy>
    ```

    Query result:

    ```
    SQL> @08_im_populated.sql
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
    SQL> select * from v$inmemory_area;

    POOL                       ALLOC_BYTES USED_BYTES POPULATE_STATUS     CON_ID
    -------------------------- ----------- ---------- --------------- ----------
    1MB POOL                    3252682752 2192572416 DONE                     3
    64KB POOL                    201326592    5439488 DONE                     3

    SQL>
    ```

    Nothing is different yet. Remember that AIM only operates when the column store is under memory pressure and even though we have set the INMEMORY\_AUTOMATIC\_LEVEL to high, the objects still have a priority of NONE which means they have to be accessed first to be populated. The next step will take care of this.

9. Now we will access the four LRGTAB tables to get population of those tables started.    

    Run the script *09\_pop\_aim\_tables.sql*

    ```
    <copy>
    @09_pop_aim_tables.sql
    </copy>    
    ```

    or run the queries below:

    ```
    <copy>
    select count(*) from lrgtab1;
    select count(*) from lrgtab2;
    select count(*) from lrgtab3;
    select count(*) from lrgtab4;
    </copy>
    ```

    Query result:

    ```
    SQL> @09_pop_aim_tables.sql
    Connected.

      COUNT(*)
    ----------
       5000000


      COUNT(*)
    ----------
       5000000


      COUNT(*)
    ----------
       5000000


      COUNT(*)
    ----------
       5000000

    SQL>
    ```

10. In this step we will review the populated segments. You may want to run this step multiple times to observe the progress of the population.

    Run the script *10\_im\_populated.sql*

    ```
    <copy>
    @10_im_populated.sql
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

    select * from v$inmemory_area;
    </copy>
    ```

    Query result:

    ```
    SQL> @10_im_populated.sql
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
    AIM        LRGTAB1                              COMPLETED            575,168,512      269,156,352                0
    AIM        LRGTAB2                              COMPLETED            575,168,512      269,156,352                0
    AIM        LRGTAB3                              STARTED              575,168,512      241,893,376       58,490,880
    AIM        LRGTAB4                              STARTED              575,242,240       50,724,864      467,853,312
    SSB        LINEORDER            PART_1994       COMPLETED            563,601,408      479,330,304                0
    SSB        LINEORDER            PART_1995       COMPLETED            563,470,336      479,330,304                0
    SSB        LINEORDER            PART_1996       COMPLETED            565,010,432      480,378,880                0
    SSB        LINEORDER            PART_1997       COMPLETED            563,314,688      479,330,304                0
    SSB        LINEORDER            PART_1998       COMPLETED            329,015,296      279,642,112                0

    9 rows selected.

    SQL>
    SQL> select * from v$inmemory_area;

    POOL                       ALLOC_BYTES USED_BYTES POPULATE_STATUS     CON_ID
    -------------------------- ----------- ---------- --------------- ----------
    1MB POOL                    3252682752 3020947456 POPULATING               3
    64KB POOL                    201326592    7995392 POPULATING               3

    SQL>
    ```

    Now we see population taking place. The following result shows what the state of the IM column store looks like after population completes. Note that since the column store is under memory pressure and AIM control, as subsequent AIM tasks run the contents may change based on usage statistics.


    Query result:

    ```
    SQL> @10_im_populated.sql
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
    AIM        LRGTAB1                              COMPLETED            575,168,512      269,156,352                0
    AIM        LRGTAB2                              COMPLETED            575,168,512      269,156,352                0
    AIM        LRGTAB3                              COMPLETED            575,168,512      269,156,352                0
    AIM        MEDTAB1                              COMPLETED             38,322,176        9,568,256                0
    AIM        MEDTAB2                              COMPLETED             38,322,176        9,568,256                0
    SSB        CHICAGO_DATA                         OUT OF MEMORY      1,739,448,320      234,553,344      402,259,968
    SSB        LINEORDER            PART_1994       COMPLETED            563,601,408      479,330,304                0
    SSB        LINEORDER            PART_1995       COMPLETED            563,470,336      479,330,304                0
    SSB        LINEORDER            PART_1996       COMPLETED            565,010,432      480,378,880                0
    SSB        LINEORDER            PART_1997       COMPLETED            563,314,688      479,330,304                0
    SSB        LINEORDER            PART_1998       COMPLETED            329,015,296      279,642,112                0

    11 rows selected.

    SQL>
    SQL> select * from v$inmemory_area;

    POOL                       ALLOC_BYTES USED_BYTES POPULATE_STATUS     CON_ID
    -------------------------- ----------- ---------- --------------- ----------
    1MB POOL                    3252682752 3250585600 DONE                     3
    64KB POOL                    201326592    8585216 DONE                     3

    SQL>
    ```

11. Let's take a look at the Heat Map statistics for the segments.    

    Run the script *11\_hm\_stats.sql*

    ```
    <copy>
    @11_hm_stats.sql
    </copy>    
    ```

    or run the queries below:

    ```
    <copy>
    col owner           format a10;
    col object_name     format a20;
    col subobject_name  format a15;
    col track_time      format a16;
    col segment_write   heading 'SEG|WRITE'       format a10;
    col segment_read    heading 'SEG|READ'        format a10;
    col full_scan       heading 'FULL|SCAN'       format a10;
    col lookup_scan     heading 'LOOKUP|SCAN'     format a10;
    col n_fts           heading 'NUM FULL|SCAN'   format 99999999;
    col n_lookup        heading 'NUM LOOKUP|SCAN' format 99999999;
    col n_write         heading 'NUM SEG|WRITE'   format 99999999;
    select
      OWNER,
      OBJECT_NAME,
      SUBOBJECT_NAME,
      to_char(TRACK_TIME,'MM/DD/YYYY HH24:MI') track_time,
      SEGMENT_WRITE,
      SEGMENT_READ,
      FULL_SCAN,
      LOOKUP_SCAN,
      N_FTS,
      N_LOOKUP,
      N_WRITE
    from
      sys."_SYS_HEAT_MAP_SEG_HISTOGRAM" h,
      dba_objects o
    where
      o.object_id = h.obj#
      and track_time >= sysdate-1
    order by
      track_time,
      OWNER,
      OBJECT_NAME,
      SUBOBJECT_NAME;
    </copy>
    ```

    Query result:

    ```
    SQL> @11_hm_stats.sql
    Connected.

                                                                     SEG        SEG        FULL       LOOKUP      NUM FULL NUM LOOKUP   NUM SEG
    OWNER      OBJECT_NAME          SUBOBJECT_NAME  TRACK_TIME       WRITE      READ       SCAN       SCAN            SCAN       SCAN     WRITE
    ---------- -------------------- --------------- ---------------- ---------- ---------- ---------- ---------- --------- ---------- ---------
    AIM        LRGTAB1                              08/10/2022 05:41 NO         YES        YES        NO                 1          0         0
    AIM        LRGTAB2                              08/10/2022 05:41 NO         YES        YES        NO                 1          0         0
    AIM        LRGTAB3                              08/10/2022 05:41 NO         YES        YES        NO                 1          0         0
    AIM        LRGTAB4                              08/10/2022 05:41 NO         YES        YES        NO                 1          0         0
    SSB        CHICAGO_DATA                         08/10/2022 05:41 NO         YES        YES        NO                 2          0         0
    SSB        CUSTOMER                             08/10/2022 05:41 NO         YES        YES        NO                 1          0         0
    SSB        DATE_DIM                             08/10/2022 05:41 NO         YES        YES        NO                 1          0         0
    SSB        JSON_PURCHASEORDER                   08/10/2022 05:41 NO         YES        YES        NO                 1          0         0
    SSB        J_PURCHASEORDER                      08/10/2022 05:41 NO         YES        YES        NO                 1          0         0
    SSB        LINEORDER            PART_1994       08/10/2022 05:41 NO         YES        YES        NO                 1          0         0
    SSB        LINEORDER            PART_1995       08/10/2022 05:41 NO         YES        YES        NO                 1          0         0
    SSB        LINEORDER            PART_1996       08/10/2022 05:41 NO         YES        YES        NO                 1          0         0
    SSB        LINEORDER            PART_1997       08/10/2022 05:41 NO         YES        YES        NO                 1          0         0
    SSB        LINEORDER            PART_1998       08/10/2022 05:41 NO         YES        YES        NO                 1          0         0
    SSB        PART                                 08/10/2022 05:41 NO         YES        YES        NO                 1          0         0
    SSB        SUPPLIER                             08/10/2022 05:41 NO         YES        YES        NO                 1          0         0

    16 rows selected.

    SQL>
    ```

12. Now let's see if we can figure out what has happened with the AIM processing. First we will look at the tasks that are running as part of AIM.

    Run the script *12\_aim\_tasks.sql*

    ```
    <copy>
    @12_aim_tasks.sql
    </copy>    
    ```

    or run the queries below:

    ```
    <copy>
    select task_id, to_char(creation_time,'DD-MON-YY hh24:mi:ss') as create_time, state
    from dba_inmemory_aimtasks
    where creation_time > sysdate -1
    order by task_id;
    </copy>
    ```

    Query result:

    ```
    SQL> @12_aimtasks.sql
    Connected.

       TASK_ID CREATE_TIME                 STATE
    ---------- --------------------------- -------
           434 09-AUG-22 23:37:06          DONE
           484 10-AUG-22 04:46:31          DONE
           485 10-AUG-22 04:48:31          DONE
           486 10-AUG-22 05:03:49          DONE
           487 10-AUG-22 05:13:54          DONE
           488 10-AUG-22 05:15:54          DONE
           489 10-AUG-22 05:17:54          DONE
           490 10-AUG-22 05:41:24          RUNNING

    8 rows selected.

    SQL>
    ```

    Make note of the last task_id. We will use this as input in the next step. Also note that the tasks are being run approximately every 2 minutes. As was described in Lab13 on AIM level LOW and MEDIUM, AIM tasks will continue to be scheduled during each IMCO cycle when under memory pressure. Again, this means that it may take a couple of cycles before an object is populated by AIM in the IM column store.

13. Now let's look at the AIM task details, or what actually happened.    

    Run the script *13\_aimtaskdetails.sql*

    ```
    <copy>
    @13_aimtaskdetails.sql
    </copy>    
    ```

    or run the queries below:

    ```
    <copy>
    col object_owner format a15;
    col object_name format a30;
    col subobject_name format a30;
    select * from dba_inmemory_aimtaskdetails where task_id = &1
    and object_owner not in ('SYS','AUDSYS')
    order by object_owner, object_name, subobject_name, action;
    </copy>
    ```

    Query result:

    ```
    SQL> @13_aimtaskdetails.sql
    Connected.
    Enter value for 1: 490
    old   1: select * from dba_inmemory_aimtaskdetails where task_id = &1
    new   1: select * from dba_inmemory_aimtaskdetails where task_id = 490

       TASK_ID OBJECT_OWNER    OBJECT_NAME                    SUBOBJECT_NAME                 ACTION           STATE
    ---------- --------------- ------------------------------ ------------------------------ ---------------- ----------
           490 AIM             LRGTAB1                                                       NO ACTION        DONE
           490 AIM             LRGTAB2                                                       POPULATE         DONE
           490 AIM             LRGTAB3                                                       NO ACTION        DONE
           490 AIM             LRGTAB4                                                       EVICT            DONE
           490 AIM             LRGTAB5                                                       EVICT            DONE
           490 AIM             LRGTAB6                                                       EVICT            DONE
           490 AIM             MEDTAB1                                                       POPULATE         DONE
           490 AIM             MEDTAB2                                                       POPULATE         DONE
           490 AIM             MEDTAB3                                                       NO ACTION        DONE
           490 AIM             SMTAB1                                                        NO ACTION        DONE
           490 AIM             SMTAB2                                                        NO ACTION        DONE
           490 AIM             SMTAB3                                                        EVICT            DONE
           490 CHICAGO         CHICAGO_TAB                                                   EVICT            DONE
           490 SSB             CHICAGO_BAD                                                   EVICT            DONE
           490 SSB             CHICAGO_DATA                                                  POPULATE         PROCESSING
           490 SSB             CUSTOMER                                                      NO ACTION        DONE
           490 SSB             DATE_DIM                                                      NO ACTION        DONE
           490 SSB             EXT_CUST_BULGARIA                                             EVICT            DONE
           490 SSB             EXT_CUST_NORWAY                                               EVICT            DONE
           490 SSB             JSON_PURCHASEORDER                                            NO ACTION        DONE
           490 SSB             J_PURCHASEORDER                                               NO ACTION        DONE
           490 SSB             LINEORDER                      PART_1994                      POPULATE         DONE
           490 SSB             PART                                                          NO ACTION        DONE
           490 SSB             SUPPLIER                                                      NO ACTION        DONE

    24 rows selected.

    SQL>
    ```

    As a reminder, take a look at the OBJECT_NAME and the ACTION. Now that the IM column store is under memory pressure AIM has taken over control of population and there is a lot going on. Based on usage statistics AIM will populate the objects that will result in the most benefit to queries being run. You may want to take a look at some of the other task details to get a better picture of what has happened. Also note that now that AIM is controlling population the PRIORITY level will be ignored and AIM will decide which objects to populate and which to evict.

14. Now let's turn AIM off and see what happens.  

    Run the script *14\_aim\_off.sql*

    ```
    <copy>
    @14_aim_off.sql
    </copy>    
    ```

    or run the queries below:

    ```
    <copy>
    show parameters inmemory_automatic_level
    alter system set inmemory_automatic_level=off;
    show parameters inmemory_automatic_level
    </copy>
    ```

    Query result:

    ```
    SQL> @14_aim_off.sql
    Connected.

    NAME                                 TYPE        VALUE
    ------------------------------------ ----------- ------------------------------
    inmemory_automatic_level             string      HIGH

    System altered.


    NAME                                 TYPE        VALUE
    ------------------------------------ ----------- ------------------------------
    inmemory_automatic_level             string      OFF
    SQL>
    ```

15. Let's look at what has happened to the inmemory attributes.

    Run the script *15\_aim\_attributes.sql*

    ```
    <copy>
    @15_aim_attributes.sql
    </copy>    
    ```

    or run the queries below:

    ```
    <copy>
    column owner format a10;
    column table_name format a20;
    column partition_name format a15;
    column inmemory format a10;
    column INMEMORY_PRIORITY heading 'INMEMORY|PRIORITY' format a10;
    column INMEMORY_DISTRIBUTE heading 'INMEMORY|DISTRIBUTE' format a12;
    column INMEMORY_COMPRESSION heading 'INMEMORY|COMPRESSION' format a14;
    select owner, table_name, NULL as partition_name, inmemory,
           inmemory_priority, inmemory_distribute, inmemory_compression
    from   dba_tables
    where owner in ('AIM','SSB')
    UNION ALL
    select table_owner as owner, table_name, partition_name, inmemory,
           inmemory_priority, inmemory_distribute, inmemory_compression
    from   dba_tab_partitions
    where table_owner in ('AIM','SSB')
    order by owner, table_name, partition_name;
    </copy>
    ```

    Query result:

    ```
    SQL> @15_aim_attributes.sql
    Connected.
    SQL>
    SQL> -- Show table attributes
    SQL>
    SQL> select owner, table_name, NULL as partition_name, inmemory,
      2         inmemory_priority, inmemory_distribute, inmemory_compression
      3  from   dba_tables
      4  where owner in ('AIM','SSB')
      5  UNION ALL
      6  select table_owner as owner, table_name, partition_name, inmemory,
      7         inmemory_priority, inmemory_distribute, inmemory_compression
      8  from   dba_tab_partitions
      9  where table_owner in ('AIM','SSB')
     10  order by owner, table_name, partition_name;

                                                               INMEMORY   INMEMORY     INMEMORY
    OWNER      TABLE_NAME           PARTITION_NAME  INMEMORY   PRIORITY   DISTRIBUTE   COMPRESSION
    ---------- -------------------- --------------- ---------- ---------- ------------ --------------
    AIM        LRGTAB1                              DISABLED
    AIM        LRGTAB2                              DISABLED
    AIM        LRGTAB3                              DISABLED
    AIM        LRGTAB4                              DISABLED
    AIM        LRGTAB5                              DISABLED
    AIM        LRGTAB6                              DISABLED
    AIM        MEDTAB1                              DISABLED
    AIM        MEDTAB2                              DISABLED
    AIM        MEDTAB3                              DISABLED
    AIM        SMTAB1                               DISABLED
    AIM        SMTAB2                               DISABLED
    AIM        SMTAB3                               DISABLED
    SSB        CHICAGO_BAD                          DISABLED
    SSB        CHICAGO_DATA                         DISABLED
    SSB        CUSTOMER                             DISABLED
    SSB        DATE_DIM                             DISABLED
    SSB        EXT_CUST                             DISABLED
    SSB        EXT_CUST_BULGARIA                    DISABLED
    SSB        EXT_CUST_HYBRID_PART N1
    SSB        EXT_CUST_HYBRID_PART N2
    SSB        EXT_CUST_HYBRID_PART N3              DISABLED
    SSB        EXT_CUST_HYBRID_PART N4              DISABLED
    SSB        EXT_CUST_HYBRID_PART
    SSB        EXT_CUST_NORWAY                      DISABLED
    SSB        EXT_CUST_PART        N1
    SSB        EXT_CUST_PART        N2
    SSB        EXT_CUST_PART        N3
    SSB        EXT_CUST_PART        N4
    SSB        EXT_CUST_PART        N5
    SSB        EXT_CUST_PART
    SSB        JSON_PURCHASEORDER                   DISABLED
    SSB        J_PURCHASEORDER                      DISABLED
    SSB        LINEORDER            PART_1994       ENABLED    NONE       AUTO         FOR QUERY LOW
    SSB        LINEORDER            PART_1995       ENABLED    NONE       AUTO         FOR QUERY LOW
    SSB        LINEORDER            PART_1996       ENABLED    NONE       AUTO         FOR QUERY LOW
    SSB        LINEORDER            PART_1997       ENABLED    NONE       AUTO         FOR QUERY LOW
    SSB        LINEORDER            PART_1998       ENABLED    NONE       AUTO         FOR QUERY LOW
    SSB        LINEORDER
    SSB        PART                                 DISABLED
    SSB        SUPPLIER                             DISABLED

    40 rows selected.

    SQL>
    ```

    Notice that all of the objects that were enabled for inmemory when the AIM level was set to high have now been disabled. However, the LINEORDER partitions that we manually enabled are still enabled.

16. What has happened to the populated segments in the IM column store?    

    Run the script *16\_im\_populated.sql*

    ```
    <copy>
    @16_im_populated.sql
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

    select * from v$inmemory_area;
    </copy>
    ```

    Query result:

    ```
    SQL> @16_im_populated.sql
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
    SQL> select * from v$inmemory_area;

    POOL                       ALLOC_BYTES USED_BYTES POPULATE_STATUS     CON_ID
    -------------------------- ----------- ---------- --------------- ----------
    1MB POOL                    3252682752 2192572416 DONE                     3
    64KB POOL                    201326592    5439488 DONE                     3

    SQL>
    ```

    Since all of the AIM enabled objects have now been disabled for inmemory, they have also been removed from the IM column store.

17. (Optional) Run the cleanup script to reset the Heat Map statistics, turn off AIM and clear the IM column store for the next Lab.

    Run the script *17\_aim-high\_cleanup.sql*

    ```
    <copy>
    @17_aim-high_cleanup.sql
    </copy>    
    ```

    or run the queries below:

    ```
    <copy>
    alter system set inmemory_automatic_level=off;
    alter table lineorder no inmemory;
    set serveroutput on;
    declare
      v_ddl varchar2(1000);
    begin
      for tab_cursor in (
        select owner, table_name
        from   dba_tables
        where  owner not in ('AUDSYS','SYS')
        and    inmemory = 'ENABLED'
      )
      loop
        v_ddl := 'alter table '||tab_cursor.owner||'.'||tab_cursor.table_name||' no inmemory';
        dbms_output.put_line(v_ddl);
        execute immediate v_ddl;
      end loop;
      --
      for part_cursor in (
        select table_owner, table_name, partition_name
        from   dba_tab_partitions
        where  table_owner not in ('AUDSYS','SYS')
        and    inmemory = 'ENABLED'
      )
      loop
        v_ddl := 'alter table '||part_cursor.table_owner||'.'||part_cursor.table_name||
          ' modify partition '||part_cursor.partition_name||' no inmemory';
        dbms_output.put_line(v_ddl);
        execute immediate v_ddl;
      end loop;
    end;
    /
    exec dbms_ilm_admin.CLEAR_HEAT_MAP_ALL;
    </copy>
    ```

    Query result:

    ```
    SQL> @17_aim-high_cleanup.sql
    Connected.

    System altered.


    Table altered.


    PL/SQL procedure successfully completed.


    PL/SQL procedure successfully completed.

    SQL>
    ```

## Conclusion

This lab demonstrated how then new INMEMORY\_AUTOMATIC\_LEVEL = HIGH feature works and how AIM level high can enable the automatic management of the contents of IM column store. This means no more having to try and figure out which objects would get the most benefit from being populated. Now the database will do it for you.

You may now **proceed to the next lab**.

## Acknowledgements

- **Author** - Andy Rivenes, Product Manager,  Database In-Memory
- **Contributors** -
- **Last Updated By/Date** - Andy Rivenes, August 2022
