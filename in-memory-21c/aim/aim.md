# Automatic In-Memory

## Introduction

Watch a preview video of using Automatic In-Memory:

[YouTube video](youtube:pFWjl1G7uDI)

Watch the video below for a walk through of the Automatic In-Memory lab:

[Automatic In-Memory](videohub:1_ke3hxh05)

*Estimated Lab Time:* 15 Minutes.

### Objectives

-   Learn how to Automatic In-Memory (AIM) works
-   Perform various queries invoking AIM with INMEMORY\_AUTOMATIC\_LEVEL set to LOW and MEDIUM

### Prerequisites
This lab assumes you have:
- A Free Tier, Paid or LiveLabs Oracle Cloud account
- You have completed:
    - Get Started with noVNC Remote Desktop
    - Lab: Initialize Environment
    - Lab: Setting up the In-Memory Column Store

**NOTE:** *When doing Copy/Paste using the convenient* **Copy** *function used throughout the guide, you must hit the* **ENTER** *key after pasting. Otherwise the last line will remain in the buffer until you hit* **ENTER!**

## Task 1: Verify Directory Definitions

In Oracle Database 18c a feature called Automatic In-Memory (AIM) was added. The goal of AIM is to manage the contents of the IM column store based on usage. AIM initially had two levels, LOW and MEDIUM, that enabled automatic management of IM column store contents once the IM column store became full. In Oracle Database 21c a third level was added that automatically manages all non-system segments without having to first enable the objects for INMEMORY.

This Lab will explore AIM level LOW MEDIUM and they work. A new schema will be used, the AIM schema with small, medium and large tables. This will make it easier to show how AIM works as the column store experiences "memory pressure" (i.e. gets full). The LINEORDER table in the SSB schema will be used to help "fill up" the IM column store and then the AIM tables will be used to show how AIM can manage the total number of objects for maximum benefit.

Let's switch to the aim folder and log back in to the PDB:

```
<copy>
cd /home/oracle/labs/inmemory/aim
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
[CDB1:oracle@dbhol:~/labs/inmemory]$ cd /home/oracle/labs/inmemory/aim
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

1. First let's check the AIM status.

    Run the script *01\_aim\_status.sql*

    ```
    <copy>
    @01_aim_status.sql
    </copy>    
    ```

    or run the query below:  

    ```
    <copy>
    show parameters inmemory_automatic_level
    </copy>
    ```

    Query result:

    ```
    SQL> @01_aim_status.sql
    Connected.

    NAME                                 TYPE        VALUE
    ------------------------------------ ----------- ------------------------------
    inmemory_automatic_level             string      OFF
    SQL>
    ```

    The INMEMORY\_AUTOMATIC\_LEVEL parameter should be set to OFF.

2. Next we will disable all tables for INMEMORY so that we can start with a clean setup.

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
    alter table SSB.DATE_DIM no inmemory
    alter table SSB.PART no inmemory
    alter table SSB.CUSTOMER no inmemory

    PL/SQL procedure successfully completed.


    PL/SQL procedure successfully completed.

    SQL>
    ```

    Any tables that were enabled for INMEMORY are listed and have been disabled (i.e. NO INMEMORY was set).

3. Now let's verify the INMEMORY attributes for the tables in the SSB and AIM schemas.

    Run the script *03\_aim\_attributes.sql*

    ```
    <copy>
    @03_aim_attributes.sql
    </copy>    
    ```

    or run the statements below:

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
    SQL> @03_aim_attributes.sql
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

    All INMEMORY statuses should be DISABLED or blank.

4. Now we will populate the LINEORDER partitions. Since we are explicitly enabling the partitions for INMEMORY they will not be touched by AIM. These partitions will serve as a constant filler so that the IM column store is close to full. This will make it easier to ensure that the IM column store is under memory pressure. This is required for the first two levels of AIM to operate.

    Run the script *04\_pop\_ssb\_tables.sql*

    ```
    <copy>
    @04_pop_ssb_tables.sql
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
    SQL> @04_pop_ssb_tables.sql
    Connected.
    SQL>
    SQL> -- Enable tables for in-memory
    SQL>
    SQL> alter table LINEORDER inmemory priority high;

    Table altered.

    SQL>
    SQL> exec dbms_inmemory.populate('SSB','LINEORDER');

    PL/SQL procedure successfully completed.

    SQL>
    ```

5. Verify that all of the LINEORDER partitions are populated.

    Run the script *05\_im\_populated.sql*

    ```
    <copy>
    @05_im_populated.sql
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
    SQL> @05_im_populated.sql
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

6. Now let's set the INMEMORY\_AUTOMATIC\_LEVEL to LOW.

    Run the script *06\_aim\_low.sql*

    ```
    <copy>
    @06_aim_low.sql
    </copy>
    ```

    or run the query below:

    ```
    <copy>
    show parameters inmemory_automatic_level
    alter system set inmemory_automatic_level=low;
    show parameters inmemory_automatic_level
    </copy>
    ```

    Query result:

    ```
    SQL> @06_aim_low.sql
    Connected.

    NAME                                 TYPE        VALUE
    ------------------------------------ ----------- ------------------------------
    inmemory_automatic_level             string      OFF

    System altered.


    NAME                                 TYPE        VALUE
    ------------------------------------ ----------- ------------------------------
    inmemory_automatic_level             string      LOW
    SQL>
    ```

7. Enable the AIM tables for INMEMORY. These tables won't all fit in the memory that is available in the IM column store.

    Run the script *07\_aim\_im\_enable.sql*

    ```
    <copy>
    @07_aim_im_enable.sql
    </copy>
    ```

    or run the query below:

    ```
    <copy>
    alter table MEDTAB1 inmemory;
    alter table MEDTAB2 inmemory;
    alter table MEDTAB3 inmemory;
    alter table LRGTAB1 inmemory;
    alter table LRGTAB2 inmemory;
    alter table LRGTAB3 inmemory;
    alter table LRGTAB4 inmemory;
    alter table SMTAB1  inmemory;
    alter table SMTAB2  inmemory;
    alter table SMTAB3  inmemory;
    </copy>
    ```

    Query result:

    ```
    SQL> @07_aim_im_enable.sql
    Connected.
    SQL>
    SQL> alter table MEDTAB1 inmemory;

    Table altered.

    SQL> alter table MEDTAB2 inmemory;

    Table altered.

    SQL> alter table MEDTAB3 inmemory;

    Table altered.

    SQL> alter table LRGTAB1 inmemory;

    Table altered.

    SQL> alter table LRGTAB2 inmemory;

    Table altered.

    SQL> alter table LRGTAB3 inmemory;

    Table altered.

    SQL> alter table LRGTAB4 inmemory;

    Table altered.

    SQL> alter table SMTAB1  inmemory;

    Table altered.

    SQL> alter table SMTAB2  inmemory;

    Table altered.

    SQL> alter table SMTAB3  inmemory;

    Table altered.

    SQL>
    ```

8. Now we will populate the three LRGTAB tables and two MEDTAB tables. Not all of these tables will fit in the space left. This is intentional.

    Run the script *08\_pop\_aim\_tables.sql*

    ```
    <copy>
    @08_pop_aim_tables.sql
    </copy>    
    ```

    or run the queries below:

    ```
    <copy>
    select count(*) from lrgtab1;
    select count(*) from lrgtab1;

    select count(*) from lrgtab2;
    select count(*) from lrgtab2;
    select count(*) from lrgtab2;

    select count(*) from lrgtab3;
    select count(*) from medtab1;
    select count(*) from medtab1;
    select count(*) from medtab1;
    select count(*) from medtab2;
    select count(*) from medtab2;
    select count(*) from medtab2;
    </copy>
    ```

    Query result:

    ```
    SQL> @08_pop_aim_tables.sql
    Connected.
    SQL>
    SQL> select count(*) from lrgtab1;

      COUNT(*)
    ----------
       5000000

    SQL> select count(*) from lrgtab1;

     COUNT(*)
    ---------
      5000000

    SQL> select count(*) from lrgtab2;

      COUNT(*)
    ----------
       5000000

    SQL> select count(*) from lrgtab2;

      COUNT(*)
    ----------
       5000000

    SQL> select count(*) from lrgtab2;

      COUNT(*)
    ----------
       5000000

    SQL>
    SQL> select count(*) from lrgtab3;

      COUNT(*)
    ----------
       5000000

    SQL> select count(*) from medtab1;

      COUNT(*)
    ----------
        300000

    SQL> select count(*) from medtab1;

      COUNT(*)
    ----------
        300000

    SQL> select count(*) from medtab1;

      COUNT(*)
    ----------
        300000

    SQL> select count(*) from medtab2;

      COUNT(*)
    ----------
        300000

    SQL> select count(*) from medtab2;

      COUNT(*)
    ----------
        300000

    SQL> select count(*) from medtab2;

      COUNT(*)
    ----------
        300000

    SQL>
    ```

9. Review the populated segments.

    Run the script *09\_im\_populated.sql*

    ```
    <copy>
    @09_im_populated.sql
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
    SQL> @09_im_populated.sql
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
    AIM        MEDTAB1                              COMPLETED             38,322,176       24,248,320                0
    AIM        MEDTAB2                              COMPLETED             38,322,176       23,199,744                0
    SSB        LINEORDER            PART_1994       COMPLETED            563,601,408      479,330,304                0
    SSB        LINEORDER            PART_1995       COMPLETED            563,470,336      479,330,304                0
    SSB        LINEORDER            PART_1996       COMPLETED            565,010,432      480,378,880                0
    SSB        LINEORDER            PART_1997       COMPLETED            563,314,688      479,330,304                0
    SSB        LINEORDER            PART_1998       COMPLETED            329,015,296      279,642,112                0

    10 rows selected.

    SQL>
    SQL> select * from v$inmemory_area;

    POOL                       ALLOC_BYTES USED_BYTES POPULATE_STATUS     CON_ID
    -------------------------- ----------- ---------- --------------- ----------
    1MB POOL                    3252682752 3045064704 DONE                     3
    64KB POOL                    201326592    7864320 DONE                     3

    SQL>
    ```

    Note that not all of the tables are populated. You may even see an OUT OF MEMORY status for at least one of the tables. This is not unexpected. At this point we have populated tables: LRGTAB1, LRGTAB2, LRGTAB3, MEDTAB1, MEDTAB2 plus we had already populated the LINEORDER partitions PART\_1994, PART\_1995, PART\_1996, PART\_1997 and PART\_1998.  Depending on the population sequence you may see that one or more of these tables are not populated/no longer populated.

10. Now we will access the LRGTAB4 table multiple times in order to bump up its Heat Map counts to make it a candidate for population.    

    Run the script *10\_pop2\_aim\_tables.sql*

    ```
    <copy>
    @10_pop2_aim_tables.sql
    </copy>    
    ```

    or run the queries below:

    ```
    <copy>
    select count(*) from lrgtab4;
    select count(*) from lrgtab4;
    select count(*) from lrgtab4;
    select count(*) from lrgtab4;
    </copy>
    ```

    Query result:

    ```
    SQL> @10_pop2_aim_tables.sql
    Connected.
    SQL>
    SQL> select count(*) from lrgtab4;

      COUNT(*)
    ----------
       5000000

    SQL> select count(*) from lrgtab4;

      COUNT(*)
    ----------
       5000000

    SQL> select count(*) from lrgtab4;

      COUNT(*)
    ----------
       5000000

    SQL> select count(*) from lrgtab4;

      COUNT(*)
    ----------
       5000000

    SQL>
    ```

11. Review the populated segments.

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
    from   v$im_segments
    where owner not in ('AUDSYS','SYS')
    order by owner, segment_name, partition_name;
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
      4  where owner not in ('AUDSYS','SYS')
      5  order by owner, segment_name, partition_name;

                                                                                            In-Memory            Bytes
    OWNER      SEGMENT_NAME         PARTITION_NAME  POPULATE_STATUS        Disk Size             Size    Not Populated
    ---------- -------------------- --------------- --------------- ---------------- ---------------- ----------------
    AIM        LRGTAB1                              COMPLETED            575,168,512      269,156,352                0
    AIM        LRGTAB2                              COMPLETED            575,168,512      269,156,352                0
    AIM        LRGTAB4                              COMPLETED            575,242,240      269,156,352                0
    AIM        MEDTAB1                              COMPLETED             38,322,176       23,199,744                0
    AIM        MEDTAB2                              COMPLETED             38,322,176       23,199,744                0
    SSB        LINEORDER            PART_1994       COMPLETED            563,601,408      479,330,304                0
    SSB        LINEORDER            PART_1995       COMPLETED            563,470,336      479,330,304                0
    SSB        LINEORDER            PART_1996       COMPLETED            565,010,432      480,378,880                0
    SSB        LINEORDER            PART_1997       COMPLETED            563,314,688      479,330,304                0
    SSB        LINEORDER            PART_1998       COMPLETED            329,015,296      279,642,112                0

    10 rows selected.

    SQL>
    SQL> select * from v$inmemory_area;

    POOL                       ALLOC_BYTES USED_BYTES POPULATE_STATUS     CON_ID
    -------------------------- ----------- ---------- --------------- ----------
    1MB POOL                    3252682752 3044016128 DONE                     3
    64KB POOL                    201326592    7864320 DONE                     3

    SQL>
    ```

    If you wait long enough, at least two minutes, you should see the above as your result. If you run the query right away you may see that the population of LRGTAB4 ran out of memory. Since AIM runs as part of the IM background processes it can take up to two minutes before an AIM task is run once the column store is full, or under memory pressure. We waited at least two minutes and then ran the 11\_im\_populated.sql script above and we see that the LRGTAB4 table is fully populated and the LRGTAB3 table is no longer populated. In the following steps we will take a look at how this has happened.

12. Next we will review the current Heat Map statistics. Remember, AIM uses these same basic statistics to determine which are the most active segments.    

    Run the script *12\_hm\_stats.sql*

    ```
    <copy>
    @12_hm_stats.sql
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
    --
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
    SQL> @12_hm_stats.sql
    Connected.

    PL/SQL procedure successfully completed.


                                                                     SEG        SEG        FULL       LOOKUP      NUM FULL NUM LOOKUP   NUM SEG
    OWNER      OBJECT_NAME          SUBOBJECT_NAME  TRACK_TIME       WRITE      READ       SCAN       SCAN            SCAN       SCAN     WRITE
    ---------- -------------------- --------------- ---------------- ---------- ---------- ---------- ---------- --------- ---------- ---------
    AIM        LRGTAB1                              08/18/2022 04:19 NO         NO         YES        NO                 2          0         0
    AIM        LRGTAB2                              08/18/2022 04:19 NO         NO         YES        NO                 3          0         0
    AIM        LRGTAB3                              08/18/2022 04:19 NO         NO         YES        NO                 1          0         0
    AIM        LRGTAB4                              08/18/2022 04:19 NO         NO         YES        NO                 4          0         0
    AIM        MEDTAB1                              08/18/2022 04:19 NO         NO         YES        NO                 3          0         0
    AIM        MEDTAB2                              08/18/2022 04:19 NO         NO         YES        NO                 3          0         0

    6 rows selected.

    SQL>
    ```

    Notice that the table LRGTAB4 has a scan count of 4, this was done in step 10 and that the LRGTAB3 table only has a count of 1.

13. Now let's see if we can figure out what has happened with the AIM processing. First we will list the AIM tasks.

    Run the script *13\_aim\_tasks.sql*

    ```
    <copy>
    @13_aim_tasks.sql
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
    SQL> @13_aimtasks.sql
    Connected.

       TASK_ID CREATE_TIME                 STATE
    ---------- --------------------------- -------
           516 18-AUG-22 20:55:05          DONE

    SQL>
    ```

    Make note of the last task_id (there could be multiple tasks depending on whether AIM has been active). We will use this task id as input in the next step.

14. Now let's look at the AIM task details, or what actually happened.    

    Run the script *14\_aimtaskdetails.sql*

    ```
    <copy>
    @14_aimtaskdetails.sql
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
    SQL> @14_aimtaskdetails.sql
    Connected.
    Enter value for 1: 516
    old   1: select * from dba_inmemory_aimtaskdetails where task_id = &1
    new   1: select * from dba_inmemory_aimtaskdetails where task_id = 516

       TASK_ID OBJECT_OWNER    OBJECT_NAME                    SUBOBJECT_NAME                 ACTION           STATE
    ---------- --------------- ------------------------------ ------------------------------ ---------------- ----------
           516 AIM             LRGTAB1                                                       NO ACTION        DONE
           516 AIM             LRGTAB2                                                       NO ACTION        DONE
           516 AIM             LRGTAB3                                                       EVICT            DONE
           516 AIM             LRGTAB4                                                       NO ACTION        DONE
           516 AIM             MEDTAB1                                                       NO ACTION        DONE
           516 AIM             MEDTAB2                                                       NO ACTION        DONE
           516 AIM             MEDTAB3                                                       NO ACTION        DONE
           516 AIM             SMTAB1                                                        NO ACTION        DONE
           516 AIM             SMTAB2                                                        NO ACTION        DONE
           516 AIM             SMTAB3                                                        NO ACTION        DONE
           516 SSB             LINEORDER                      PART_1994                      NO ACTION        DONE

    11 rows selected.

    SQL>
    ```

    Take a look at the OBJECT\_NAME and the ACTION. Based on the Heat Map statistics does the ACTION make sense? When INMEMORY\_AUTOMATIC\_LEVEL is set to LOW only one task at a time is performed. The idea is that once a population fails, the next eligible population should occur based on the most active object. This will not necessarily be the object that triggered the population. In this case you should notice that the LRGTAB3 table was marked for eviction. LRGTAB3 was evicted since it only had a scan count of 1. You can look back at the Heat Map statistics from the previous step to verify this. The result was that the LRGTAB4 table could then be populated.

15. Now we will switch over to AIM level MEDIUM. Note that one of the big differences with INMEMORY\_AUTOMATIC\_LEVEL set to MEDIUM is that when the IM column store is under memory pressure AIM takes over controlling the population of the IM column store. AIM tasks will be run approximately every two minutes and AIM will determine which segments will be populated based on their usage statistics.

    Run the script *15\_aim\_medium.sql*

    ```
    <copy>
    @15_aim_medium.sql
    </copy>    
    ```

    or run the queries below:

    ```
    <copy>
    show parameters inmemory_automatic_level
    alter system set inmemory_automatic_level=medium;
    show parameters inmemory_automatic_level
    </copy>
    ```

    Query result:

    ```
    SQL> @15_aim_medium.sql
    Connected.

    NAME                                 TYPE        VALUE
    ------------------------------------ ----------- ------------------------------
    inmemory_automatic_level             string      LOW

    System altered.


    NAME                                 TYPE        VALUE
    ------------------------------------ ----------- ------------------------------
    inmemory_automatic_level             string      MEDIUM
    SQL>
    ```

16. Now we will access the LRGTAB3 table multiple times to increase its scan count so that it will be chosen to be re-populated. This should result in one or more evictions to make space for the more active LRGTAB3 table.

    Run the script *16\_pop\_aim\_tables.sql*

    ```
    <copy>
    @16_pop_aim_tables.sql
    </copy>    
    ```

    or run the queries below:

    ```
    <copy>
    select count(*) from lrgtab3;
    select count(*) from lrgtab3;
    select count(*) from lrgtab3;
    select count(*) from lrgtab3;
    select count(*) from lrgtab3;
    select count(*) from lrgtab3;
    </copy>
    ```

    Query result:

    ```
    SQL> @16_pop_aim_tables.sql
    Connected.
    SQL>
    SQL> select count(*) from lrgtab3;

      COUNT(*)
    ----------
       5000000

    SQL> select count(*) from lrgtab3;

      COUNT(*)
    ----------
       5000000

    SQL> select count(*) from lrgtab3;

      COUNT(*)
    ----------
       5000000

    SQL> select count(*) from lrgtab3;

      COUNT(*)
    ----------
       5000000

    SQL> select count(*) from lrgtab3;

      COUNT(*)
    ----------
       5000000

    SQL> select count(*) from lrgtab3;

      COUNT(*)
    ----------
       5000000

    SQL>
    ```

17. Review the populated segments.

    Run the script *17\_im\_populated.sql*

    ```
    <copy>
    @17_im_populated.sql
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
    SQL> @17_im_populated.sql
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
    AIM        LRGTAB3                              OUT OF MEMORY        575,168,512      187,170,816      175,472,640
    AIM        LRGTAB4                              COMPLETED            575,242,240      269,156,352                0
    AIM        MEDTAB1                              COMPLETED             38,322,176       23,199,744                0
    AIM        MEDTAB2                              COMPLETED             38,322,176       23,199,744                0
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
    1MB POOL                    3252682752 3230662656 DONE                     3
    64KB POOL                    201326592    8388608 DONE                     3

    SQL>
    ```

    Note that it may take a couple of AIM cycles before the LRGTAB3 table is re-populated in the IM column store. In fact, if you wait for a couple of cycles to complete you will find that quite a few changes will be made.

18. Let's review the current Heat Map statistics. Remember, AIM uses these statistics to determine which are the most active segments. You should now see that the LRGTAB3 table has been accessed more than other tables.   

    Run the script *18\_hm\_stats.sql*

    ```
    <copy>
    @18_hm_stats.sql
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
    --
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
    SQL> @18_hm_stats.sql
    Connected.

    PL/SQL procedure successfully completed.


                                                                     SEG        SEG        FULL       LOOKUP      NUM FULL NUM LOOKUP   NUM SEG
    OWNER      OBJECT_NAME          SUBOBJECT_NAME  TRACK_TIME       WRITE      READ       SCAN       SCAN            SCAN       SCAN     WRITE
    ---------- -------------------- --------------- ---------------- ---------- ---------- ---------- ---------- --------- ---------- ---------
    AIM        LRGTAB1                              08/18/2022 20:59 NO         NO         YES        NO                 2          0         0
    AIM        LRGTAB2                              08/18/2022 20:59 NO         NO         YES        NO                 3          0         0
    AIM        LRGTAB3                              08/18/2022 20:59 NO         NO         YES        NO                 7          0         0
    AIM        LRGTAB4                              08/18/2022 20:59 NO         NO         YES        NO                 4          0         0
    AIM        MEDTAB1                              08/18/2022 20:59 NO         NO         YES        NO                 3          0         0
    AIM        MEDTAB2                              08/18/2022 20:59 NO         NO         YES        NO                 3          0         0

    6 rows selected.

    SQL>
    ```

19. Now we will take a look at the AIM tasks and see if we can figure out what has happened. We will list the AIM tasks here and then take a look at the details in the next step. One thing to note, with INMEMORY\_AUTOMATIC\_LEVEL set to MEDIUM AIM tasks will continue to be scheduled during each IMCO cycle when under memory pressure. As mentioned above, this means that it may take a couple of cycles before an object is populated by AIM in the IM column store.

    Run the script *19\_aim\_tasks.sql*

    ```
    <copy>
    @19_aim_tasks.sql
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
    SQL> @19_aimtasks.sql
    Connected.

       TASK_ID CREATE_TIME                 STATE
    ---------- --------------------------- -------
           516 18-AUG-22 20:55:05          DONE
           517 18-AUG-22 21:15:08          DONE
           518 18-AUG-22 21:17:08          DONE

    6 rows selected.

    SQL>
    ```

    Make note of the last task_id. We will use this as input in the next step. If you wait for a couple of 2 minute cycles to complete you should be able to review all of the actions that have taken place to get the IM column store populated with the current segments.

20. Now let's look at the AIM task details, or what has actually happened up to this point.    

    Run the script *20\_aimtaskdetails.sql*

    ```
    <copy>
    @20_aimtaskdetails.sql
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
    SQL> @20_aimtaskdetails.sql
    Connected.
    Enter value for 1: 518
    old   1: select * from dba_inmemory_aimtaskdetails where task_id = &1
    new   1: select * from dba_inmemory_aimtaskdetails where task_id = 518

       TASK_ID OBJECT_OWNER    OBJECT_NAME                    SUBOBJECT_NAME                 ACTION           STATE
    ---------- --------------- ------------------------------ ------------------------------ ---------------- ----------
           518 AIM             LRGTAB1                                                       PARTIAL POPULATE DONE
           518 AIM             LRGTAB2                                                       POPULATE         DONE
           518 AIM             LRGTAB3                                                       POPULATE         DONE
           518 AIM             LRGTAB4                                                       POPULATE         DONE
           518 AIM             MEDTAB1                                                       POPULATE         DONE
           518 AIM             MEDTAB2                                                       POPULATE         DONE
           518 AIM             MEDTAB3                                                       EVICT            DONE
           518 AIM             SMTAB1                                                        EVICT            DONE
           518 AIM             SMTAB2                                                        EVICT            DONE
           518 AIM             SMTAB3                                                        EVICT            DONE
           518 SSB             LINEORDER                      PART_1994                      POPULATE         DONE

    11 rows selected.

    SQL>
    ```

    You should be able to determine from the task details when evictions and populations have occurred. Based on this you might want to re-run script 17\_im\_populated.sql from step 17 because it looks like some new changes have been made. You may also want to go back and take a look at task id 517 as well.

21. (Optional) Run the cleanup script to reset the Heat Map statistics, turn off AIM and clear the IM column store for the next Lab.

    Run the script *21\_cleanup\_aim.sql*

    ```
    <copy>
    @21_cleanup_aim.sql
    </copy>    
    ```

    or run the queries below:

    ```
    <copy>
    alter system set inmemory_automatic_level=off;
    alter table lineorder no inmemory;
    --
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
    SQL> @21_cleanup_aim.sql
    Connected.

    System altered.


    Table altered.

    alter table AIM.MEDTAB2 no inmemory
    alter table AIM.SMTAB3 no inmemory
    alter table AIM.LRGTAB3 no inmemory
    alter table AIM.LRGTAB2 no inmemory
    alter table AIM.LRGTAB1 no inmemory
    alter table AIM.SMTAB1 no inmemory
    alter table AIM.MEDTAB1 no inmemory
    alter table AIM.MEDTAB3 no inmemory
    alter table AIM.SMTAB2 no inmemory
    alter table AIM.LRGTAB4 no inmemory

    PL/SQL procedure successfully completed.


    PL/SQL procedure successfully completed.

    SQL>
    ```

## Conclusion

This lab demonstrated how Database In-Memory can automatically populate and evict segments based on their usage.

You may now **proceed to the next lab**.

## Acknowledgements

- **Author** - Andy Rivenes, Product Manager,  Database In-Memory
- **Contributors** -
- **Last Updated By/Date** - Andy Rivenes, March 2024
