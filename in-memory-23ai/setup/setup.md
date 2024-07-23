# Set up the In-Memory column store

## Introduction

In this lab, you will explore how to enable the In-Memory column store, populate objects and query various views to monitor Database In-Memory.

Watch the video below to get an explanation of enabling the In-Memory column store.

[Youtube video](youtube:dZ9cnIL6KKw)

Quick walk through on how to enable In-Memory.

[Setting up the In-Memory column store](videohub:1_dg318frc)

*Estimated Lab Time:* 15 Minutes.

### Objectives

-   Learn how to enable Database In-Memory and populate objects in the IM column store
-   Explore various views to monitor Database In-Memory

### Prerequisites

This lab assumes you have:
- A Free Tier, Paid or LiveLabs Oracle Cloud account
- You have completed:
    - Get Started with noVNC Remote Desktop
    - Lab: Initialize Environment

**NOTE:** *When doing Copy/Paste using the convenient* **Copy** *function used throughout the guide, you must hit the* **ENTER** *key after pasting. Otherwise the last line will remain in the buffer until you hit* **ENTER!**

## Task 1: Logging In and Enabling In-Memory

In this Lab we will explore how the In-Memory column store is enabled in Oracle Database, and then how to enable and populate objects and verify the population of those objects in the In-Memory column store.

1. Let's switch to the setup folder and log back in to the PDB:

    Reload the environment variables for **CDB1** if you exited the terminal after the previous lab
    
    ```
    <copy>. ~/.set-env-db.sh CDB1</copy>
    ```

    Connect to **PDB1**
    
    ```
    <copy>
    cd /home/oracle/labs/inmemory/setup
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
    [CDB1:oracle@dbhol:~/labs/inmemory]$ cd /home/oracle/labs/inmemory/setup
    [CDB1:oracle@dbhol:~/labs/inmemory/setup]$ sqlplus ssb/Ora_DB4U@localhost:1521/pdb1

    SQL*Plus: Release 23.0.0.0.0 - Production on Mon May 20 14:02:47 2024
    Version 23.4.0.24.05

    Copyright (c) 1982, 2024, Oracle.  All rights reserved.

    Last Successful login time: Mon May 20 2024 13:50:04 -07:00

    Connected to:
    Oracle Database 23ai Enterprise Edition Release 23.0.0.0.0 - Production
    Version 23.4.0.24.05

    SQL> set pages 9999
    SQL> set lines 150
    SQL>
    ```

2. Database In-Memory is integrated into Oracle Database 12c (12.1.0.2) and higher.  The IM column store is not enabled by default, but can be easily enabled via a few steps.  In this lab we have set the following parameters:

    Run the script *01\_show\_parms.sql*

    ```
    <copy>
    @01_show_parms.sql
    </copy>    
    ```

    or run the query below:  

    ```
    <copy>
    show parameter sga
    show parameter db_keep_cache_size
    show parameter heat_map
    show parameter inmemory_size
    show parameter inmemory_automatic_level
    </copy>
    ```

    Query result:

    ```
    SQL> @01_show_parms.sql
    Connected.
    SQL>
    SQL> -- Shows the SGA init.ora parameters
    SQL>
    SQL> show parameter sga

    NAME                                 TYPE        VALUE
    ------------------------------------ ----------- ------------------------------
    allow_group_access_to_sga            boolean     FALSE
    lock_sga                             boolean     FALSE
    pre_page_sga                         boolean     TRUE
    sga_max_size                         big integer 8G
    sga_min_size                         big integer 0
    sga_target                           big integer 0
    SQL>
    SQL> show parameter db_keep_cache_size

    NAME                                 TYPE        VALUE
    ------------------------------------ ----------- ------------------------------
    db_keep_cache_size                   big integer 3008M
    SQL>
    SQL> show parameter heat_map

    NAME                                 TYPE        VALUE
    ------------------------------------ ----------- ------------------------------
    heat_map                             string      ON
    SQL>
    SQL> show parameter inmemory_size

    NAME                                 TYPE        VALUE
    ------------------------------------ ----------- ------------------------------
    inmemory_size                        big integer 3312M
    SQL>
    SQL> show parameter inmemory_automatic_level

    NAME                                 TYPE        VALUE
    ------------------------------------ ----------- ------------------------------
    inmemory_automatic_level             string      high
    SQL>
    ```

    Since the IM column store is not enabled by default (i.e. INMEMORY\_SIZE=0), we have set it to a size that will work for this Lab.  HEAT\_MAP defaults to OFF, but it has been enabled for one of the later labs. The KEEP pool (i.e. DB\_KEEP\_CACHE\_SIZE) is set to 0 by default. We have defined it for this Lab so that you can compare the performance of objects populated in the IM column store with the same objects fully cached in the buffer cache and compare the difference in performance for yourself. We have also set SGA\_TARGET, as opposed to defining individual SGA components or MEMORY\_TARGET, in order to enable Automatic Shared Memory Management (ASMM) to enable a new feature in Database In-Memory called Automatic In-Memory Sizing.

3. Since Database In-Memory is fully integrated into Oracle Database the IM column store is allocated within the System Global Area (SGA) and can be easily displayed using normal database commands.

    Run the script *02\_show\_sga.sql*

    ```
    <copy>
    @02_show_sga.sql
    </copy>    
    ```

    or run the query below:  

    ```
    <copy>
    show sga
    </copy>
    ```

    Query result:

    ```
    SQL> @02_show_sga.sql
    Connected.
    SQL> set numwidth 20
    SQL>
    SQL> -- Show SGA memory allocation
    SQL>
    SQL> show sga

    Total System Global Area 8587393600 bytes
    Fixed Size                  5380672 bytes
    Variable Size             469762048 bytes
    Database Buffers         4630511616 bytes
    Redo Buffers                8855552 bytes
    In-Memory Area           3472883712 bytes
    SQL>
    ```

    Notice that the SGA is made up of Fixed Size, Variable Size, Database Buffers and Redo Buffers. And since we have set the INEMMORY\_SIZE parameter we also see the In-Memory Area allocated within the SGA.


4. In 23ai the In-Memory area is sub-divided into three pools: a 1MB POOL used to store actual columnar formatted data populated in the IM column store, a 64KB POOL to store metadata about the objects populated in the IM column store and a IM POOL METADATA to manage objects populated in the IM column store.  The view V$INMEMORY\_AREA shows the total memory allocated and used in the IM column store.

    Run the script *03\_im\_usage.sql*

    ```
    <copy>
    @03_im_usage.sql
    </copy>    
    ```

    or run the query below:  

    ```
    <copy>
    column pool format a10;
    column alloc_bytes format 999,999,999,999,999
    column used_bytes format 999,999,999,999,999
    SELECT pool, alloc_bytes, used_bytes, populate_status, con_id
    FROM   v$inmemory_area;
    </copy>
    ```

    Query result:

    ```
    SQL> @03_im_usage.sql
    Connected.
    SQL> column pool format a10;
    SQL> column alloc_bytes format 999,999,999,999,999
    SQL> column used_bytes format 999,999,999,999,999
    SQL>
    SQL> -- Show total column store usage
    SQL>
    SQL> SELECT pool, alloc_bytes, used_bytes, populate_status, con_id
      2  FROM   v$inmemory_area;

    POOL                      ALLOC_BYTES           USED_BYTES POPULATE_STATUS                CON_ID
    ---------------- -------------------- -------------------- -------------------------- ----------
    1MB POOL                3,288,334,336                    0 DONE                                3
    64KB POOL                 167,772,160                    0 DONE                                3
    IM POOL METADATA           16,777,216           16,777,216 DONE                                3

    SQL>
    ```

5. The following query accesses the USER_TABLES view and displays attributes of the tables in the SSB schema.  

    Run the script *04\_im\_attributes.sql*

    ```
    <copy>
    @04_im_attributes.sql
    </copy>    
    ```

    or run the query below:  

    ```
    <copy>
    column table_name format a12;
    column partition_name format a15;
    column buffer_pool format a11;
    column compression heading 'DISK|COMPRESSION' format a11;
    column compress_for format a12;
    column INMEMORY_PRIORITY heading 'INMEMORY|PRIORITY' format a10;
    column INMEMORY_DISTRIBUTE heading 'INMEMORY|DISTRIBUTE' format a12;
    column INMEMORY_COMPRESSION heading 'INMEMORY|COMPRESSION' format a14;
    select table_name, NULL as partition_name, buffer_pool, compression, compress_for, inmemory,
       inmemory_priority, inmemory_distribute, inmemory_compression
    from   user_tables
    where  table_name in ('DATE_DIM','PART','SUPPLIER','CUSTOMER')
    UNION ALL
    select table_name, partition_name, buffer_pool, compression, compress_for, inmemory,
       inmemory_priority, inmemory_distribute, inmemory_compression
    from   user_tab_partitions
    where  table_name = 'LINEORDER';
    </copy>
    ```

    Query result:

    ```
    SQL> @04_im_attributes.sql
    Connected.
    SQL>
    SQL> -- Show table attributes
    SQL>
    SQL> select table_name, NULL as partition_name, buffer_pool, compression, compress_for, inmemory,
      2         inmemory_priority, inmemory_distribute, inmemory_compression
      3  from   user_tables
      4  where  table_name in ('DATE_DIM','PART','SUPPLIER','CUSTOMER')
      5  UNION ALL
      6  select table_name, partition_name, buffer_pool, compression, compress_for, inmemory,
      7         inmemory_priority, inmemory_distribute, inmemory_compression
      8  from   user_tab_partitions
      9  where  table_name = 'LINEORDER';

                                             DISK                              INMEMORY   INMEMORY     INMEMORY
    TABLE_NAME   PARTITION_NAME  BUFFER_POOL COMPRESSION COMPRESS_FOR INMEMORY PRIORITY   DISTRIBUTE   COMPRESSION
    ------------ --------------- ----------- ----------- ------------ -------- ---------- ------------ --------------
    CUSTOMER                     KEEP        ENABLED     BASIC        ENABLED  NONE       AUTO         AUTO
    DATE_DIM                     KEEP        ENABLED     BASIC        ENABLED  NONE       AUTO         AUTO
    PART                         KEEP        ENABLED     BASIC        ENABLED  NONE       AUTO         AUTO
    SUPPLIER                     KEEP        ENABLED     BASIC        ENABLED  NONE       AUTO         AUTO
    LINEORDER    PART_1994       KEEP        ENABLED     BASIC        ENABLED  NONE       AUTO         AUTO
    LINEORDER    PART_1995       KEEP        ENABLED     BASIC        ENABLED  NONE       AUTO         AUTO
    LINEORDER    PART_1996       KEEP        ENABLED     BASIC        ENABLED  NONE       AUTO         AUTO
    LINEORDER    PART_1997       KEEP        ENABLED     BASIC        ENABLED  NONE       AUTO         AUTO
    LINEORDER    PART_1998       KEEP        ENABLED     BASIC        ENABLED  NONE       AUTO         AUTO

    9 rows selected.

    SQL>
    ```

    Note that tables enabled for inmemory will have the inmemory attribute of ENABLED. The default priority level is NONE which means that the object is not populated until it is first accessed. If the priority is set to any value other than NONE then the object will not be eligible for eviction. However, note that both the inmemory distribute and inmemory compression fields are set to AUTO. Recall that back in step 2 the parameter INMEMORY\_AUTOMATIC\_LEVEL was set to HIGH. This means that Automatic In-Memory was set to HIGH which enables all non-system objects to be eligible to be populated in the IM column store. We will talk more about this in the last lab.

6. Let's populate the IM column store by accessing the tables that are enabled for inmemory with the following queries:

    Run the script *05\_im\_start_pop.sql*

    ```
    <copy>
    @05_im_start_pop.sql
    </copy>    
    ```

    or run the query below:  

    ```
    <copy>
    select /*+ full(LINEORDER) noparallel(LINEORDER) */ count(*) from LINEORDER;     
    select /*+ full(PART) noparallel(PART) */ count(*) from PART;                    
    select /*+ full(CUSTOMER) noparallel(CUSTOMER) */ count(*) from CUSTOMER;        
    select /*+ full(SUPPLIER) noparallel(SUPPLIER) */ count(*) from SUPPLIER;        
    select /*+ full(DATE_DIM) noparallel(DATE_DIM) */ count(*) from DATE_DIM;
    </copy>
    ```

    Query result:

    ```
    SQL> @05_im_start_pop.sql
    Connected.
    SQL>
    SQL> -- Access tables enabled for in-memory to start population
    SQL>
    SQL> select /*+ full(LINEORDER) noparallel(LINEORDER) */ count(*) from LINEORDER;

                COUNT(*)
    --------------------
                41760941

    SQL> select /*+ full(PART) noparallel(PART) */ count(*) from PART;

                COUNT(*)
    --------------------
                  800000

    SQL> select /*+ full(CUSTOMER) noparallel(CUSTOMER) */ count(*) from CUSTOMER;

                COUNT(*)
    --------------------
                  300000

    SQL> select /*+ full(SUPPLIER) noparallel(SUPPLIER) */ count(*) from SUPPLIER;

                COUNT(*)
    --------------------
                   20000

    SQL> select /*+ full(DATE_DIM) noparallel(DATE_DIM) */ count(*) from DATE_DIM;

                COUNT(*)
    --------------------
                    2556

    SQL>
    ```

  Note the FULL and NOPARALLEL hints. These have been added to ensure that the table data is also read into the KEEP pool that was defined. This is only done for this Lab so that we can show you a true memory based comparison of the performance of the Database In-Memory columnar format versus the traditional row format fully cached in the buffer cache. This is not required to initiate Database In-Memory population.

7. To identify which segments have been populated into the IM column store you can query the view V$IM\_SEGMENTS.  Once the data population is complete, the BYTES\_NOT\_POPULATED attribute should be 0 for each segment.  

    Run the script *06\_im\_populated.sql*

    ```
    <copy>
    @06_im_populated.sql
    </copy>    
    ```

    or run the query below:  

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
    SSB        LINEORDER            PART_1994       COMPLETED            565,338,112      479,330,304                0
    SSB        LINEORDER            PART_1995       COMPLETED            565,354,496      479,330,304                0
    SSB        LINEORDER            PART_1996       COMPLETED            567,484,416      480,378,880                0
    SSB        LINEORDER            PART_1997       COMPLETED            564,281,344      479,330,304                0
    SSB        LINEORDER            PART_1998       COMPLETED            330,407,936      279,642,112                0
    SSB        PART                                 COMPLETED             56,893,440       16,973,824                0
    SSB        SUPPLIER                             COMPLETED              1,769,472        2,228,224                0

    9 rows selected.

    SQL>
    ```

8. Now let's check the total space usage used in the IM column store.

    Run the script *07\_im\_usage.sql*

    ```
    <copy>
    @07_im_usage.sql
    </copy>    
    ```

    or run the query below:  

    ```
    <copy>
    column pool format a16;
    column alloc_bytes format 999,999,999,999,999
    column used_bytes format 999,999,999,999,999
    column populate_status format a15;
    SELECT pool, alloc_bytes, used_bytes, populate_status, con_id
    FROM   v$inmemory_area;
    </copy>
    ```

    Query result:

    ```
    SQL> @07_im_usage.sql
    Connected.
    SQL> column pool format a16;
    SQL> column alloc_bytes format 999,999,999,999,999
    SQL> column used_bytes format 999,999,999,999,999
    SQL> column populate_status format a15;
    SQL>
    SQL> -- Show total column store usage
    SQL>
    SQL> SELECT pool, alloc_bytes, used_bytes, populate_status, con_id
      2  FROM   v$inmemory_area;

    POOL                      ALLOC_BYTES           USED_BYTES POPULATE_STATUS     CON_ID
    ---------------- -------------------- -------------------- --------------- ----------
    1MB POOL                3,288,334,336        2,235,564,032 DONE                     3
    64KB POOL                 167,772,160            6,029,312 DONE                     3
    IM POOL METADATA           16,777,216           16,777,216 DONE                     3

    SQL>
    ```

9. Lets also take a look at the current Heat Map statistics. Automatic In-Memory does not require that Heat Map be enabled, but under the covers it uses the same basic information. We will list that starting heat map statistics in this step and then we will take a look at the statistics in the last lab and compare that with how it affected AIM.  

    Run the script *08\_hm\_stats.sql*

    ```
    <copy>
    @08_hm_stats.sql
    </copy>    
    ```

    or run the query below:  

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
    SQL> @08_hm_stats.sql
    Connected.

                                                                     SEG        SEG        FULL       LOOKUP      NUM FULL NUM LOOKUP   NUM SEG
    OWNER      OBJECT_NAME          SUBOBJECT_NAME  TRACK_TIME       WRITE      READ       SCAN       SCAN            SCAN       SCAN     WRITE
    ---------- -------------------- --------------- ---------------- ---------- ---------- ---------- ---------- --------- ---------- ---------
    SSB        CUSTOMER                             06/12/2024 12:20 NO         YES        YES        NO                 1          0         0
    SSB        DATE_DIM                             06/12/2024 12:20 NO         YES        YES        NO                 1          0         0
    SSB        LINEORDER            PART_1994       06/12/2024 12:20 NO         YES        YES        NO                 1          0         0
    SSB        LINEORDER            PART_1995       06/12/2024 12:20 NO         YES        YES        NO                 1          0         0
    SSB        LINEORDER            PART_1996       06/12/2024 12:20 NO         YES        YES        NO                 1          0         0
    SSB        LINEORDER            PART_1997       06/12/2024 12:20 NO         YES        YES        NO                 1          0         0
    SSB        LINEORDER            PART_1998       06/12/2024 12:20 NO         YES        YES        NO                 1          0         0
    SSB        PART                                 06/12/2024 12:20 NO         YES        YES        NO                 1          0         0
    SSB        SUPPLIER                             06/12/2024 12:20 NO         YES        YES        NO                 1          0         0

    9 rows selected.

    SQL>
    ```

    Note that there has been 1 full table scan on each of the tables and no other activity. In Step 6 we ran a query against each table and that has been the only access so far. In the last lab we will explore heat map in more detail and what affect it has on AIM processing.

10. Exit lab

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
    Disconnected from Oracle Database 23ai Enterprise Edition Release 23.0.0.0.0 - Production
    Version 23.4.0.24.05
    [CDB1:oracle@dbhol:~/labs/inmemory/setup]$ cd ..
    [CDB1:oracle@dbhol:~/labs/inmemory]$
    ```

## Conclusion

In this lab you saw that the IM column store is configured by setting the initialization parameter INMEMORY_SIZE. The IM column store is another pool in the SGA, and once allocated it can be increased in size dynamically.

You also had an opportunity to populate and view objects in the IM column store and to see how much memory they use. In this lab we populated five tables into the IM column store, and the LINEORDER table is the largest of the tables populated with over 41 million rows. You may have noticed that it is also a partitioned table. We will be using that attribute in later labs.

Remember that the population speed depends on the CPU capacity of the system as the in-memory population is a CPU intensive operation. The more CPU and processes you allocate the faster the populations will occur.

Finally you got to see how to determine if the objects were fully populated and how much space was being consumed in the IM column store.

You may now **proceed to the next lab**.

## Acknowledgements

- **Author** - Andy Rivenes, Product Manager, Database In-Memory
- **Contributors** - Maria Colgan, Rene Fontcha
- **Last Updated By/Date** - Andy Rivenes, Product Manager, Database In-Memory, June 2024
