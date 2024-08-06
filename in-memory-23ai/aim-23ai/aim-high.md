# Automatic In-Memory Level High

## Introduction
Watch the video below to get an overview of Automatic In-Memory:

[YouTube video](youtube:pFWjl1G7uDI)

Watch the video below for a quick walk-through of this lab.
[Automatic In-Memory High](videohub:1_0rzwly4i)

*Estimated Lab Time:* 15 Minutes.

### Objectives

-   Learn how Automatic In-Memory (AIM) level HIGH works
-   Perform various queries invoking AIM with INMEMORY_AUTOMATIC_LEVEL set to HIGH

### Prerequisites

This lab assumes you have:
- A Free Tier, Paid or LiveLabs Oracle Cloud account
- You have completed:
    - Get Started with noVNC Remote Desktop
    - Lab: Initialize Environment
    - Lab: Setting up the In-Memory Column Store

**NOTE:** *When doing Copy/Paste using the convenient* **Copy** *function used throughout the guide, you must hit the* **ENTER** *key after pasting. Otherwise the last line will remain in the buffer until you hit* **ENTER!**

## Task 1: AIM Level High

In Oracle Database 18c a feature called Automatic In-Memory (AIM) was added. The goal of AIM is to manage the contents of the IM column store based on usage. AIM initially had two levels, LOW and MEDIUM, that enabled automatic management of IM column store contents once the IM column store became full. In Oracle Database 21c a third level was added that automatically manages all non-system segments without having to first enable the objects for in-memory.

This Lab will explore the new AIM level HIGH and how it works. We will also take a look at two new features in Oracle Database 23ai, AIM Performance Features and Automatic In-Memory Sizing. Note that AIM works as the column store experiences "memory pressure" (i.e. gets full). The SSB schema will be used to help "fill up" the IM column store and then other schema objects will help show how AIM can manage the total number of objects for maximum benefit.

Reload the environment variables for **CDB1** if you exited the terminal after the previous lab

```
<copy>. ~/.set-env-db.sh CDB1</copy>
```

Let's switch to the aim23 folder and log back in to the PDB:

```
<copy>
cd /home/oracle/labs/inmemory/aim23
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
[CDB1:oracle@dbhol:~/labs/inmemory]$ cd /home/oracle/labs/inmemory/aim23
[CDB1:oracle@dbhol:~/labs/inmemory/aim23]$ sqlplus ssb/Ora_DB4U@localhost:1521/pdb1

SQL*Plus: Release 23.0.0.0.0 - Production on Tue Jun 4 15:31:23 2024
Version 23.4.0.24.05

Copyright (c) 1982, 2024, Oracle.  All rights reserved.

Last Successful login time: Tue Jun 4 2022 15:31:23 2024

Connected to:
Oracle Database 23ai Enterprise Edition Release 23.0.0.0.0 - Production
Version 23.4.0.24.05

SQL> set pages 9999
SQL> set lines 150
SQL>
```

1. First let's check the inmemory status of the objects in the SSB schema:

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
    AIM        LRGTAB1                              ENABLED    NONE       AUTO         AUTO
    AIM        LRGTAB2                              ENABLED    NONE       AUTO         AUTO
    AIM        LRGTAB3                              ENABLED    NONE       AUTO         AUTO
    AIM        MEDTAB1                              ENABLED    NONE       AUTO         AUTO
    AIM        MEDTAB2                              ENABLED    NONE       AUTO         AUTO
    AIM        MEDTAB3                              ENABLED    NONE       AUTO         AUTO
    AIM        SMTAB1                               ENABLED    NONE       AUTO         AUTO
    AIM        SMTAB2                               ENABLED    NONE       AUTO         AUTO
    AIM        SMTAB3                               ENABLED    NONE       AUTO         AUTO
    SSB        CHICAGO_DATA                         ENABLED    NONE       AUTO         AUTO
    SSB        CUSTOMER                             ENABLED    NONE       AUTO         AUTO
    SSB        DATE_DIM                             ENABLED    NONE       AUTO         AUTO
    SSB        EXT_CUST_BULGARIA                    ENABLED    NONE       AUTO         AUTO
    SSB        EXT_CUST_NORWAY                      ENABLED    NONE       AUTO         AUTO
    SSB        JSON_PURCHASEORDER                   ENABLED    NONE       AUTO         AUTO
    SSB        LINEORDER            PART_1994       ENABLED    NONE       AUTO         AUTO
    SSB        LINEORDER            PART_1995       ENABLED    NONE       AUTO         AUTO
    SSB        LINEORDER            PART_1996       ENABLED    NONE       AUTO         AUTO
    SSB        LINEORDER            PART_1997       ENABLED    NONE       AUTO         AUTO
    SSB        LINEORDER            PART_1998       ENABLED    NONE       AUTO         AUTO
    SSB        LINEORDER
    SSB        PART                                 ENABLED    NONE       AUTO         AUTO
    SSB        SUPPLIER                             ENABLED    NONE       AUTO         AUTO

    23 rows selected.

    SQL>
    ```

    Note the inmemory status of the tables. Here they are all enabled since AIM level is set to high.

2. Next we will take a look at what has happened with SGA sizing. With the IM Auto Sizing feature the IM column store is now part of Automatic Shared Memory Managment (ASMM). Based on our activity in this lab lets take a look at what SGA sizing operations have taken place.

    Run the script *02\_sga\_sizing.sql*

    ```
    <copy>
    @02_sga_sizing.sql
    </copy>    
    ```

    or run the query below:  

    ```
    <copy>
    column component format a20;
    column parameter format a21;
    select 
      component, oper_type, oper_mode, parameter, initial_size,
      target_size, final_size, 
      to_char(start_time,'MM/DD/YYYY HH24:MI:SS') start_time, 
      to_char(end_time,'MM/DD/YYYY HH24:MI:SS') end_time
    from 
      v$sga_resize_ops
    where
      component in ('shared_pool','DEFAULT buffer cache','In-Memory Area')
    order by
      start_time
    /
    </copy>
    ```

    Query result:

    ```
    SQL> set echo off
    SQL> @02_sga_sizing.txt
    Connected.

    COMPONENT            OPER_TYPE     OPER_MODE PARAMETER             INITIAL_SIZE TARGET_SIZE FINAL_SIZE START_TIME          END_TIME
    -------------------- ------------- --------- --------------------- ------------ ----------- ---------- ------------------- -------------------
    DEFAULT buffer cache INITIALIZING            db_cache_size           1912602624  1912602624 1912602624 06/12/2024 14:48:05 06/12/2024 14:48:05
    DEFAULT buffer cache STATIC                  db_cache_size                    0  1912602624 1912602624 06/12/2024 14:48:05 06/12/2024 14:48:05
    In-Memory Area       STATIC                  _datamemory_area_size            0  2432696320 2432696320 06/12/2024 14:48:05 06/12/2024 14:48:05
    In-Memory Area       GROW          DEFERRED  _datamemory_area_size   2432696320  2566914048 2566914048 06/12/2024 14:58:18 06/12/2024 14:58:18
    DEFAULT buffer cache SHRINK        DEFERRED  db_cache_size           1912602624  1778384896 1778384896 06/12/2024 14:58:18 06/12/2024 14:58:18
    In-Memory Area       GROW          DEFERRED  _datamemory_area_size   2566914048  2835349504 2835349504 06/12/2024 15:00:18 06/12/2024 15:00:18
    DEFAULT buffer cache SHRINK        DEFERRED  db_cache_size           1778384896  1509949440 1509949440 06/12/2024 15:00:18 06/12/2024 15:00:18

    7 rows selected.

    SQL>
    ```

    Note that now that In-Memory Area is managed as part of ASMM you see that the buffer cache is shrinking and the In-Memory Area is growing.

3. Now lets look at what objects are populated.

    Run the script *03\_im\_populated.sql*

    ```
    <copy>
    @03_im_populated.sql
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
    SQL> @03_im_populated.sql
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
    AIM        MEDTAB1                              COMPLETED             38,322,176       25,559,040                0
    AIM        MEDTAB2                              COMPLETED             38,322,176       23,199,744                0
    AIM        MEDTAB3                              COMPLETED             38,322,176       23,199,744                0
    SSB        CHICAGO_DATA                         STARTED            1,154,768,896      241,696,768      735,420,416
    SSB        CUSTOMER                             COMPLETED             24,928,256       23,199,744                0
    SSB        DATE_DIM                             COMPLETED                122,880        1,179,648                0
    SSB        LINEORDER            PART_1994       COMPLETED            565,338,112      479,330,304                0
    SSB        LINEORDER            PART_1995       COMPLETED            565,354,496      479,330,304                0
    SSB        LINEORDER            PART_1996       COMPLETED            567,484,416      480,378,880                0
    SSB        LINEORDER            PART_1997       COMPLETED            564,281,344      479,330,304                0
    SSB        LINEORDER            PART_1998       COMPLETED            330,407,936      279,642,112                0
    SSB        PART                                 COMPLETED             56,893,440       16,973,824                0
    SSB        SUPPLIER                             COMPLETED              1,769,472        2,228,224                0

    13 rows selected.

    SQL>
    SQL> select * from v$inmemory_area;

    POOL                       ALLOC_BYTES USED_BYTES POPULATE_STATUS     CON_ID
    -------------------------- ----------- ---------- --------------- ----------
    1MB POOL                    2667577344 2548039680 POPULATING               3
    64KB POOL                    134217728    7208960 POPULATING               3
    IM POOL METADATA              16777216   16777216 POPULATING               3

    SQL>
    ```

    Notice that s.

4. Now let's see if we can figure out what has happened with the AIM processing. First we will look at the tasks that are running as part of AIM.

    Run the script *04\_aim\_actions.sql*

    ```
    <copy>
    @04_aim_actions.sql
    </copy>    
    ```

    or run the queries below:

    ```
    <copy>
    set head off;
    set echo off;
    set verify off;
    set term off;
    column max_id  new_value max_id format 99999999;
    select max(task_id) max_id
    from dba_inmemory_aimtasks;
    set term on;
    --
    column max_task new_value max_task;
    accept max_task default &&max_id prompt 'Enter max task id > ';
    prompt ;
    column min_task new_value min_task;
    accept min_task default &&max_id-5 prompt 'Enter min task id > ';
    prompt ;
    set head on;
    select &&min_task min_task, &&max_task max_task from dual; 
    --
    col object_owner format a15;
    col object_name format a30;
    col subobject_name format a30;
    select * from dba_inmemory_aimtaskdetails
    where task_id between &&min_task and &&max_task
    and object_owner not in ('SYS','AUDSYS')
    -- and action != 'NO ACTION'
    order by task_id, object_owner, object_name, subobject_name, action;
    set verify on;
    set echo on;
    </copy>
    ```

    Query result:

    ```
    SQL> @04_aim_actions.sql
    Connected.
    Enter max task id >

    Enter min task id >


      MIN_TASK   MAX_TASK
    ---------- ----------
          4588       4593


       TASK_ID OBJECT_OWNER    OBJECT_NAME                    SUBOBJECT_NAME                 ACTION           STATE
    ---------- --------------- ------------------------------ ------------------------------ ---------------- ----------
          4589 AIM             LRGTAB1                                                       NO ACTION        DONE
          4589 AIM             LRGTAB2                                                       NO ACTION        DONE
          4589 AIM             LRGTAB3                                                       NO ACTION        DONE
          4589 AIM             MEDTAB1                                                       POPULATE         DONE
          4589 AIM             MEDTAB2                                                       POPULATE         DONE
          4589 AIM             MEDTAB3                                                       POPULATE         DONE
          4589 AIM             SMTAB1                                                        NO ACTION        DONE
          4589 AIM             SMTAB2                                                        NO ACTION        DONE
          4589 AIM             SMTAB3                                                        NO ACTION        DONE
          4589 SSB             CHICAGO_DATA                                                  PARTIAL POPULATE DONE
          4589 SSB             CUSTOMER                                                      POPULATE         DONE
          4589 SSB             DATE_DIM                                                      POPULATE         DONE
          4589 SSB             EXT_CUST_BULGARIA                                             NO ACTION        DONE
          4589 SSB             EXT_CUST_NORWAY                                               NO ACTION        DONE
          4589 SSB             JSON_PURCHASEORDER                                            NO ACTION        DONE
          4589 SSB             LINEORDER                      PART_1994                      POPULATE         DONE
          4589 SSB             LINEORDER                      PART_1995                      POPULATE         DONE
          4589 SSB             LINEORDER                      PART_1996                      POPULATE         DONE
          4589 SSB             LINEORDER                      PART_1997                      POPULATE         DONE
          4589 SSB             LINEORDER                      PART_1998                      POPULATE         DONE
          4589 SSB             PART                                                          POPULATE         DONE
          4589 SSB             SUPPLIER                                                      POPULATE         DONE
          4589 VECTOR          DM$P5DOC_MODEL                                                NO ACTION        DONE
          4589 VECTOR          DM$P8DOC_MODEL                                                NO ACTION        DONE
          4589 VECTOR          DM$P9DOC_MODEL                                                NO ACTION        DONE
          4589 VECTOR          DM$PADOC_MODEL                                                NO ACTION        DONE
          4589 VECTOR          SEARCH_DATA                                                   NO ACTION        DONE
          4589 VECTOR          SEARCH_DATA10K                                                NO ACTION        DONE
          4590 AIM             LRGTAB1                                                       NO ACTION        DONE
          4590 AIM             LRGTAB2                                                       NO ACTION        DONE
          4590 AIM             LRGTAB3                                                       NO ACTION        DONE
          4590 AIM             MEDTAB1                                                       POPULATE         DONE
          4590 AIM             MEDTAB2                                                       POPULATE         DONE
          4590 AIM             MEDTAB3                                                       POPULATE         DONE
          4590 AIM             SMTAB1                                                        NO ACTION        DONE
          4590 AIM             SMTAB2                                                        NO ACTION        DONE
          4590 AIM             SMTAB3                                                        NO ACTION        DONE
          4590 SSB             CHICAGO_DATA                                                  PARTIAL POPULATE DONE
          4590 SSB             CUSTOMER                                                      POPULATE         DONE
          4590 SSB             DATE_DIM                                                      POPULATE         DONE
          4590 SSB             EXT_CUST_BULGARIA                                             NO ACTION        DONE
          4590 SSB             EXT_CUST_NORWAY                                               NO ACTION        DONE
          4590 SSB             JSON_PURCHASEORDER                                            NO ACTION        DONE
          4590 SSB             LINEORDER                      PART_1994                      POPULATE         DONE
          4590 SSB             LINEORDER                      PART_1995                      POPULATE         DONE
          4590 SSB             LINEORDER                      PART_1996                      POPULATE         DONE
          4590 SSB             LINEORDER                      PART_1997                      POPULATE         DONE
          4590 SSB             LINEORDER                      PART_1998                      POPULATE         DONE
          4590 SSB             PART                                                          POPULATE         DONE
          4590 SSB             SUPPLIER                                                      POPULATE         DONE
          4590 VECTOR          DM$P5DOC_MODEL                                                NO ACTION        DONE
          4590 VECTOR          DM$P8DOC_MODEL                                                NO ACTION        DONE
          4590 VECTOR          DM$P9DOC_MODEL                                                NO ACTION        DONE
          4590 VECTOR          DM$PADOC_MODEL                                                NO ACTION        DONE
          4590 VECTOR          SEARCH_DATA                                                   NO ACTION        DONE
          4590 VECTOR          SEARCH_DATA10K                                                NO ACTION        DONE
          4591 AIM             LRGTAB1                                                       NO ACTION        DONE
          4591 AIM             LRGTAB2                                                       NO ACTION        DONE
          4591 AIM             LRGTAB3                                                       NO ACTION        DONE
          4591 AIM             MEDTAB1                                                       POPULATE         DONE
          4591 AIM             MEDTAB2                                                       POPULATE         DONE
          4591 AIM             MEDTAB3                                                       POPULATE         DONE
          4591 AIM             SMTAB1                                                        NO ACTION        DONE
          4591 AIM             SMTAB2                                                        NO ACTION        DONE
          4591 AIM             SMTAB3                                                        NO ACTION        DONE
          4591 SSB             CHICAGO_DATA                                                  PARTIAL POPULATE DONE
          4591 SSB             CUSTOMER                                                      POPULATE         DONE
          4591 SSB             DATE_DIM                                                      POPULATE         DONE
          4591 SSB             EXT_CUST_BULGARIA                                             NO ACTION        DONE
          4591 SSB             EXT_CUST_NORWAY                                               NO ACTION        DONE
          4591 SSB             JSON_PURCHASEORDER                                            NO ACTION        DONE
          4591 SSB             LINEORDER                      PART_1994                      POPULATE         DONE
          4591 SSB             LINEORDER                      PART_1995                      POPULATE         DONE
          4591 SSB             LINEORDER                      PART_1996                      POPULATE         DONE
          4591 SSB             LINEORDER                      PART_1997                      POPULATE         DONE
          4591 SSB             LINEORDER                      PART_1998                      POPULATE         DONE
          4591 SSB             PART                                                          POPULATE         DONE
          4591 SSB             SUPPLIER                                                      POPULATE         DONE
          4591 VECTOR          DM$P5DOC_MODEL                                                NO ACTION        DONE
          4591 VECTOR          DM$P8DOC_MODEL                                                NO ACTION        DONE
          4591 VECTOR          DM$P9DOC_MODEL                                                NO ACTION        DONE
          4591 VECTOR          DM$PADOC_MODEL                                                NO ACTION        DONE
          4591 VECTOR          SEARCH_DATA                                                   NO ACTION        DONE
          4591 VECTOR          SEARCH_DATA10K                                                NO ACTION        DONE
          4592 AIM             LRGTAB1                                                       NO ACTION        DONE
          4592 AIM             LRGTAB2                                                       NO ACTION        DONE
          4592 AIM             LRGTAB3                                                       NO ACTION        DONE
          4592 AIM             MEDTAB1                                                       POPULATE         DONE
          4592 AIM             MEDTAB2                                                       POPULATE         DONE
          4592 AIM             MEDTAB3                                                       POPULATE         DONE
          4592 AIM             SMTAB1                                                        NO ACTION        DONE
          4592 AIM             SMTAB2                                                        NO ACTION        DONE
          4592 AIM             SMTAB3                                                        NO ACTION        DONE
          4592 SSB             CHICAGO_DATA                                                  PARTIAL POPULATE DONE
          4592 SSB             CUSTOMER                                                      POPULATE         DONE
          4592 SSB             DATE_DIM                                                      POPULATE         DONE
          4592 SSB             EXT_CUST_BULGARIA                                             NO ACTION        DONE
          4592 SSB             EXT_CUST_NORWAY                                               NO ACTION        DONE
          4592 SSB             JSON_PURCHASEORDER                                            NO ACTION        DONE
          4592 SSB             LINEORDER                      PART_1994                      POPULATE         DONE
          4592 SSB             LINEORDER                      PART_1995                      POPULATE         DONE
          4592 SSB             LINEORDER                      PART_1996                      POPULATE         DONE
          4592 SSB             LINEORDER                      PART_1997                      POPULATE         DONE
          4592 SSB             LINEORDER                      PART_1998                      POPULATE         DONE
          4592 SSB             PART                                                          POPULATE         DONE
          4592 SSB             SUPPLIER                                                      POPULATE         DONE
          4592 VECTOR          DM$P5DOC_MODEL                                                NO ACTION        DONE
          4592 VECTOR          DM$P8DOC_MODEL                                                NO ACTION        DONE
          4592 VECTOR          DM$P9DOC_MODEL                                                NO ACTION        DONE
          4592 VECTOR          DM$PADOC_MODEL                                                NO ACTION        DONE
          4592 VECTOR          SEARCH_DATA                                                   NO ACTION        DONE
          4592 VECTOR          SEARCH_DATA10K                                                NO ACTION        DONE
          4593 AIM             LRGTAB1                                                       NO ACTION        DONE
          4593 AIM             LRGTAB2                                                       NO ACTION        DONE
          4593 AIM             LRGTAB3                                                       NO ACTION        DONE
          4593 AIM             MEDTAB1                                                       POPULATE         DONE
          4593 AIM             MEDTAB2                                                       POPULATE         DONE
          4593 AIM             MEDTAB3                                                       POPULATE         DONE
          4593 AIM             SMTAB1                                                        NO ACTION        DONE
          4593 AIM             SMTAB2                                                        NO ACTION        DONE
          4593 AIM             SMTAB3                                                        NO ACTION        DONE
          4593 SSB             CHICAGO_DATA                                                  PARTIAL POPULATE DONE
          4593 SSB             CUSTOMER                                                      POPULATE         DONE
          4593 SSB             DATE_DIM                                                      POPULATE         DONE
          4593 SSB             EXT_CUST_BULGARIA                                             NO ACTION        DONE
          4593 SSB             EXT_CUST_NORWAY                                               NO ACTION        DONE
          4593 SSB             JSON_PURCHASEORDER                                            NO ACTION        DONE
          4593 SSB             LINEORDER                      PART_1994                      POPULATE         DONE
          4593 SSB             LINEORDER                      PART_1995                      POPULATE         DONE
          4593 SSB             LINEORDER                      PART_1996                      POPULATE         DONE
          4593 SSB             LINEORDER                      PART_1997                      POPULATE         DONE
          4593 SSB             LINEORDER                      PART_1998                      POPULATE         DONE
          4593 SSB             PART                                                          POPULATE         DONE
          4593 SSB             SUPPLIER                                                      POPULATE         DONE
          4593 VECTOR          DM$P5DOC_MODEL                                                NO ACTION        DONE
          4593 VECTOR          DM$P8DOC_MODEL                                                NO ACTION        DONE
          4593 VECTOR          DM$P9DOC_MODEL                                                NO ACTION        DONE
          4593 VECTOR          DM$PADOC_MODEL                                                NO ACTION        DONE
          4593 VECTOR          SEARCH_DATA                                                   NO ACTION        DONE
          4593 VECTOR          SEARCH_DATA10K                                                NO ACTION        DONE

    140 rows selected.

    SQL>
    ```

    Make note of the last task_id. We will use this as input in the next step. Also note that the tasks are being run approximately every 2 minutes. AIM tasks will be scheduled during each IMCO cycle, which is approximately every 2 minutes, when the IM column store is under memory pressure. This means that it may take a couple of cycles before an object is populated by AIM in the IM column store.


5. Let's take a look at the Heat Map statistics for the segments. Although Heat Map is not used directly by AIM, and does not have to be enabled for AIM to work, it does give us an easy way to look at the usage statistics that AIM does base its decisions on.

    Run the script *05\_hm\_stats.sql*

    ```
    <copy>
    @05_hm_stats.sql
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
    SQL> @05_hm_stats.sql
    Connected.

                                                                     SEG        SEG        FULL       LOOKUP      NUM FULL NUM LOOKUP   NUM SEG
    OWNER      OBJECT_NAME          SUBOBJECT_NAME  TRACK_TIME       WRITE      READ       SCAN       SCAN            SCAN       SCAN     WRITE
    ---------- -------------------- --------------- ---------------- ---------- ---------- ---------- ---------- --------- ---------- ---------
    SSB        CUSTOMER                             06/12/2024 13:10 NO         YES        YES        NO                 8          0         0
    SSB        DATE_DIM                             06/12/2024 13:10 NO         YES        YES        NO                15          0         0
    SSB        LINEORDER            PART_1994       06/12/2024 13:10 NO         YES        YES        NO                26          0         0
    SSB        LINEORDER            PART_1995       06/12/2024 13:10 NO         YES        YES        NO                26          0         0
    SSB        LINEORDER            PART_1996       06/12/2024 13:10 NO         YES        YES        YES               29      24540         0
    SSB        LINEORDER            PART_1997       06/12/2024 13:10 NO         YES        YES        NO                29          0         0
    SSB        LINEORDER            PART_1998       06/12/2024 13:10 NO         YES        YES        NO                26          0         0
    SSB        LINEORDER_I1                         06/12/2024 13:10 NO         YES        NO         YES                0          1         0
    SSB        LINEORDER_I2                         06/12/2024 13:10 NO         YES        NO         YES                0          1         0
    SSB        PART                                 06/12/2024 13:10 NO         YES        YES        NO                11          0         0
    SSB        SUPPLIER                             06/12/2024 13:10 NO         YES        YES        NO                11          0         0
    AIM        MEDTAB1                              06/12/2024 15:48 NO         YES        YES        NO                 4          0         0
    AIM        MEDTAB2                              06/12/2024 15:48 NO         YES        YES        NO                 4          0         0
    AIM        MEDTAB3                              06/12/2024 15:48 NO         YES        YES        NO                 3          0         0

    14 rows selected.

    SQL>
    ```

    Note that your values may be different than what is shown above. The values shown will be based on the usage that has occurred in your database.

6. Now let's look any performance features were created by AIM.    

    Run the script *06\_auto\_im\_features.sql*

    ```
    <copy>
    @06_auto_im_features.sql
    </copy>    
    ```

    or run the queries below:

    ```
    <copy>
    col owner_name format a10;
    col table_name format a15;
    col column_name format a20;
    col optimized_arithmetic heading opt|arith format a5;
    col bloomfilter_optimization heading bloom|opt format a5;
    col vector_optimization heading vector|opt format a6;
    col join_group heading join|group format a5;
    col creation_date heading create|date;
    set lines 150
    set tab off
    select owner_name, table_name, column_name, optimized_arithmetic,
      bloomfilter_optimization, vector_optimization, join_group,
      creation_date
    from dba_aim_perf_features;
    </copy>
    ```

    Query result:

    ```
    SQL> @06_auto_im_features.sql
    Connected.

                                                    opt   bloom vector join  create
    OWNER_NAME TABLE_NAME      COLUMN_NAME          arith opt   opt    group date
    ---------- --------------- -------------------- ----- ----- ------ ----- ---------
    SSB        LINEORDER       LO_ORDERDATE         N     Y     N      N     16-MAY-24

    SQL>
    ```

    Take a look at the OBJECT_NAME and the ACTION. Now that the IM column store is under memory pressure AIM has taken over control of population and there is a lot going on. Based on usage statistics AIM will populate the objects that will result in the most benefit to queries being run. You may want to take a look at some of the other task details to get a better picture of what has happened. Also note that now that AIM is controlling population the PRIORITY level will be ignored and AIM will decide which objects to populate and which to evict.

7. Now let's run an AIM activity report and see what decisions AIM ...  

    Run the script *07\_auto\_im\_activity.sql*

    ```
    <copy>
    @07_auto_im_activity.sql
    </copy>    
    ```

    or run the queries below:

    ```
    <copy>
    set serveroutput on
    declare
      report clob := null;
    begin
      report := DBMS_AUTOIM.activity_report(level=>'DETAILED');
      dbms_output.put_line(report);
    end;
    /
    </copy>
    ```

    Query result:

    ```
    SQL> @07_auto_im_activity.sql
    Connected.
    REPORT SUMMARY
    -------------------------------------------------------------------------------
    Start time                            : 11-JUN-2024 15:58:31
    End time                              : 12-JUN-2024 15:58:31
    No. of times auto task
    scheduled      : 15
    Statements Analyzed                   : 0
    IM Performance Candidates Identified  : 0
    Statements Verified                   : 0
    IM Performance
    Candidates Accepted    :
    -------------------------------------------------------------------------------



    PL/SQL procedure successfully completed.

    SQL>
    ```

## Conclusion

This lab demonstrated how the new INMEMORY\_AUTOMATIC\_LEVEL = HIGH feature works and how AIM level high can enable the automatic management of the contents of IM column store. This means no more having to try and figure out which objects would get the most benefit from being populated. Now the database will do it for you.

You may now **proceed to the next lab**.

## Acknowledgements

- **Author** - Andy Rivenes, Product Manager,  Database In-Memory
- **Contributors** -
- **Last Updated By/Date** - Andy Rivenes, June 2024
