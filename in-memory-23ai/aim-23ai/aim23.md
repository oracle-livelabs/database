# Automatic In-Memory Level High

## Introduction

Watch the video below to get an overview of Automatic In-Memory:

[YouTube video](youtube:pFWjl1G7uDI)

Watch the video below for a quick walk-through of this lab.
[Automatic In-Memory High](videohub:1_0rzwly4i)

*Estimated Lab Time:* 15 Minutes.

### Objectives

-   Learn how Automatic In-Memory (AIM) level HIGH works
-   Perform various queries invoking AIM with INMEMORY\_AUTOMATIC\_LEVEL set to HIGH

### Prerequisites

This lab assumes you have:
- LiveLabs Oracle Cloud account
- You have completed:
    - Lab: Initialize Environment
    - Lab: Setting up the In-Memory Column Store

**NOTE:** *When doing Copy/Paste using the convenient* **Copy** *function used throughout the guide, you must hit the* **ENTER** *key after pasting. Otherwise the last line will remain in the buffer until you hit* **ENTER!**

## Task 1: AIM Level High

In Oracle Database 18c a feature called Automatic In-Memory (AIM) was added. The goal of AIM is to manage the contents of the IM column store based on usage. AIM initially had two levels, LOW and MEDIUM, that enabled automatic management of IM column store contents once the IM column store became full. In Oracle Database 21c a third level was added that automatically manages all non-system segments without having to first enable the objects for in-memory.

This Lab will explore the new AIM level HIGH and how it works. We will also take a look at two new features in Oracle Database 23ai, Automatic Enablement of In-Memory Performance Features and Automatic In-Memory Sizing. Note that AIM works as the column store experiences "memory pressure" (i.e. gets full). The SSB schema will be used to help "fill up" the IM column store and then other schema objects will help show how AIM can manage the total number of objects for maximum benefit.

Let's switch to the aim23 folder and log back in to the PDB:

```
<copy>
cd /home/oracle/workshops/inmemory/aim23
sqlplus /nolog
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
[oracle@livelabs aim23]$ cd /home/oracle/labs/inmemory/aim23
[oracle@livelabs aim23]$ sqlplus /nolog

SQL*Plus: Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems on Mon Aug 12 16:50:16 2024
Version 23.5.0.24.07

Copyright (c) 1982, 2024, Oracle.  All rights reserved.

SQL> set pages 9999
SQL> set lines 150
SQL>
```

1. First let's see whether any Automatic In-Memory Performance features were created during the lab:

    Run the script *01\_auto\_im\_features.sql*

    ```
    <copy>
    @01_auto_im_features.sql
    </copy>    
    ```

    or run the query below:  

    ```
    <copy>
    set lines 150
    set pages 9999
    set tab off
    --
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
    SQL> @01_auto_im_features.sql
    Connected.

                                                    opt   bloom vector join  create
    OWNER_NAME TABLE_NAME      COLUMN_NAME          arith opt   opt    group date
    ---------- --------------- -------------------- ----- ----- ------ ----- -------------------
    SSB        LINEORDER       LO_PARTKEY           N     Y     N      N     08/09/2024 18:32:05
    SSB        LINEORDER       LO_SUPPKEY           N     Y     N      N     08/09/2024 18:32:05
    SSB        LINEORDER       LO_ORDERDATE         N     Y     N      N     08/09/2024 18:32:05
    SSB        LINEORDER       LO_CUSTKEY           N     Y     N      N     08/09/2024 18:32:05

    SQL>
    ```

    Note that Bloom filter optimizations have been created. The Automatic In-Memory performance feature relies on two components, Auto STS to capture SQL statements and the Auto In-Memory Task to evaluate whether it is beneficial to create In-Memory performance features. Both of these tasks run in the Auto Task framework and evaluate the SQL that has been run over time. Note that if the IM column store is under memory pressure, that is it is full enought that there are population errors and objects need to be evicted, then AIM pauses the Auto In-Memory task.

2. Next we will run an IM Activity Report to see if we can determine why AIM created the performance features that we saw in step 1.

    Run the script *02\_auto\_im\_activity.sql*

    ```
    <copy>
    @02_auto_im_activity.sql
    </copy>    
    ```

    or run the query below:  

    ```
    <copy>
    set tab off
    set long 2000000
    set lines 250
    set pages 9999
    --
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
    Connected.
    REPORT SUMMARY
    -------------------------------------------------------------------------------
    Start time                            : 08-AUG-2024 21:12:52 
    End time                              : 09-AUG-2024 21:12:52 
    No. of times auto task scheduled      : 1428                 
    Statements Analyzed                   : 15                   
    IM Performance Candidates Identified  : 5                    
    Statements Verified                   : 3                    
    IM Performance Candidates Accepted    : 4                    
    -------------------------------------------------------------------------------

    REPORT DETAILS
    -------------------------------------------------------------------------------

    FEATURE NAME: Optimized Arithmetic
    -------------------------------------------------------------------------------

    Delta Elapsed time  : -12.62 
    Delta CPU time      : -12.66

    -------------------------------------------------------------------------------

    CANDIDATES:
    ---------------------------------------------------------------
    | Table Name | Column Name | Frequency | Monitored | Accepted |
    ---------------------------------------------------------------
    | LINEORDER  | LO_REVENUE  |        39 |           | FALSE    |
    ---------------------------------------------------------------

    Target
    SQLs
    ----------------------

    ---------------------------------------------------------------------------------
    | SQL ID        | B_Elapsed | A_Elapsed | B_CPU  | A_CPU  | Elapsed(%) | CPU(%)
    |
    ---------------------------------------------------------------------------------
    | 6ygn2wqbv5syt |     95006 |     96426 |  94924 |  96365 |      -1.49 |  -1.52 |
    | 6ygn2wqbv5syt |     55713 |     96426 |  55701 |  96365 |     -73.08 |    -73 |
    | 6ygn2wqbv5syt |     58839 |     96426 |  58815 |  96365 |     -63.88 | -63.84 |
    | 6ygn2wqbv5syt |     55561 |     96426 |  55476 |  96365 |     -73.55 | -73.71 |
    | 6ygn2wqbv5syt |     58238 |     96426 |  58241 |  96365 |     -65.57 | -65.46 |
    | 6ygn2wqbv5syt |     56040 |     96426 |  56032 |  96365 |     -72.07 | -71.98 |
    | 6ygn2wqbv5syt |     55674 |     96426 |  55699 |  96365 |      -73.2 | -73.01 |
    | 6ygn2wqbv5syt |     55162 |     96426 |  55135 |  96365 |     -74.81 | -74.78 |
    | 6ygn2wqbv5syt |     56104 |     96426 |  56039 |  96365 |     -71.87 | -71.96 |
    | 6ygn2wqbv5syt |     55587 |     96426 |  55595 |  96365 |     -73.47 | -73.33 |
    | 6ygn2wqbv5syt |     55398 |     96426 |  55374 |  96365 |     -74.06 | -74.03 |
    | 6ygn2wqbv5syt |     54916 |     96426 |  54921 |  96365 |     -75.59 | -75.46 |
    | 6ygn2wqbv5syt |     55892 |     96426 |  55927 |  96365 |     -72.52 |  -72.3 |
    | bgm86vz7ghjsj |    639868 |    640720 | 639758 | 640874 |       -.13 |   -.17 |
    | bgm86vz7ghjsj |    570041 |    640720 | 569768 | 640874 |      -12.4 | -12.48 |
    | bgm86vz7ghjsj |    748612 |    640720 | 748538 | 640874 |      14.41 |  14.38 |
    | bgm86vz7ghjsj |    573420 |    640720 | 572888 | 640874 |     -11.74 | -11.87 |
    | bgm86vz7ghjsj |    583802 |    640720 | 583836 | 640874 |      -9.75 |  -9.77 |
    | bgm86vz7ghjsj |    598300 |    640720 | 597806 | 640874 |      -7.09 |   -7.2 |
    | bgm86vz7ghjsj |    582059 |    640720 | 581842 | 640874 |     -10.08 | -10.15 |
    | bgm86vz7ghjsj |    575907 |    640720 | 575763 | 640874 |     -11.25 | -11.31 |
    | bgm86vz7ghjsj |    569430 |    640720 | 568818 | 640874 |     -12.52 | -12.67 |
    | bgm86vz7ghjsj |    570474 |    640720 | 570852 | 640874 |     -12.31 | -12.27 |
    | bgm86vz7ghjsj |    570703 |    640720 | 570871 | 640874 |     -12.27 | -12.26 |
    | bgm86vz7ghjsj |    578863 |    640720 | 578872 | 640874 |     -10.69 | -10.71 |
    | bgm86vz7ghjsj |    579699 |    640720 | 579818 | 640874 |     -10.53 | -10.53 |
    ---------------------------------------------------------------------------------

    FEATURE NAME: Bloom Filter Optimization
    -------------------------------------------------------------------------------
     Delta Elapsed time  : 3.42 
     Delta CPU time : 3.36 
    -------------------------------------------------------------------------------

    CANDIDATES:
    ----------------------------------------------------------------
    | Table Name | Column Name  | Frequency | Monitored | Accepted
    |
    ----------------------------------------------------------------
    | LINEORDER  | LO_CUSTKEY   |        26 |           | TRUE     |
    | LINEORDER  | LO_ORDERDATE |        39 |           | TRUE     |
    | LINEORDER  | LO_PARTKEY   |        13 |           | TRUE     |
    | LINEORDER  | LO_SUPPKEY   |        26 |           | TRUE     |
    ----------------------------------------------------------------

    Target
    SQLs
    ----------------------

    ---------------------------------------------------------------------------------
    | SQL ID        | B_Elapsed | A_Elapsed | B_CPU  | A_CPU  | Elapsed(%) | CPU(%)
    |
    ---------------------------------------------------------------------------------
    | 6ygn2wqbv5syt |     95006 |     55453 |  94924 |  55484 |      41.63 |  41.55 |
    | 6ygn2wqbv5syt |     55713 |     55453 |  55701 |  55484 |        .47 |    .39 |
    | 6ygn2wqbv5syt |     58839 |     55453 |  58815 |  55484 |       5.75 |   5.66 |
    | 6ygn2wqbv5syt |     55561 |     55453 |  55476 |  55484 |        .19 |   -.01 |
    | 6ygn2wqbv5syt |     58238 |     55453 |  58241 |  55484 |       4.78 |   4.73 |
    | 6ygn2wqbv5syt |     56040 |     55453 |  56032 |  55484 |       1.05 |    .98 |
    | 6ygn2wqbv5syt |     55674 |     55453 |  55699 |  55484 |         .4 |    .39 |
    | 6ygn2wqbv5syt |     55162 |     55453 |  55135 |  55484 |       -.53 |   -.63 |
    | 6ygn2wqbv5syt |     56104 |     55453 |  56039 |  55484 |       1.16 |    .99 |
    | 6ygn2wqbv5syt |     55587 |     55453 |  55595 |  55484 |        .24 |     .2 |
    | 6ygn2wqbv5syt |     55398 |     55453 |  55374 |  55484 |        -.1 |    -.2 |
    | 6ygn2wqbv5syt |     54916 |     55453 |  54921 |  55484 |       -.98 |  -1.03 |
    | 6ygn2wqbv5syt |     55892 |     55453 |  55927 |  55484 |        .79 |    .79 |
    | b2jysvyzbss5p |      2651 |      2710 |   2639 |   2751 |      -2.23 |  -4.24 |
    | b2jysvyzbss5p |      2945 |      2710 |   2974 |   2751 |       7.98 |    7.5 |
    | b2jysvyzbss5p |      3239 |      2710 |   3189 |   2751 |      16.33 |  13.73 |
    | b2jysvyzbss5p |      2740 |      2710 |   2751 |   2751 |       1.09 |      0 |
    | b2jysvyzbss5p |      2858 |      2710 |   2862 |   2751 |       5.18 |   3.88 |
    | b2jysvyzbss5p |      2783 |      2710 |   2751 |   2751 |       2.62 |      0 |
    | b2jysvyzbss5p |      2686 |      2710 |   2642 |   2751 |       -.89 |  -4.13 |
    | b2jysvyzbss5p |      2694 |      2710 |   2752 |   2751 |       -.59 |    .04 |
    | b2jysvyzbss5p |      2637 |      2710 |   2530 |   2751 |      -2.77 |  -8.74 |
    | b2jysvyzbss5p |      2715 |      2710 |   2748 |   2751 |        .18 |   -.11 |
    | b2jysvyzbss5p |      2649 |      2710 |   2642 |   2751 |       -2.3 |  -4.13 |
    | b2jysvyzbss5p |      2701 |      2710 |   2640 |   2751 |       -.33 |   -4.2 |
    | b2jysvyzbss5p |      2691 |      2710 |   2751 |   2751 |       -.71 |      0 |
    | bgm86vz7ghjsj |    639868 |    576657 | 639758 | 576863 |       9.88 |   9.83 |
    | bgm86vz7ghjsj |    570041 |    576657 | 569768 | 576863 |      -1.16 |  -1.25 |
    | bgm86vz7ghjsj |    748612 |    576657 | 748538 | 576863 |      22.97 |  22.93 |
    | bgm86vz7ghjsj |    573420 |    576657 | 572888 | 576863 |       -.56 |   -.69 |
    | bgm86vz7ghjsj |    583802 |    576657 | 583836 | 576863 |       1.22 |   1.19 |
    | bgm86vz7ghjsj |    598300 |    576657 | 597806 | 576863 |       3.62 |    3.5 |
    | bgm86vz7ghjsj |    582059 |    576657 | 581842 | 576863 |        .93 |    .86 |
    | bgm86vz7ghjsj |    575907 |    576657 | 575763 | 576863 |       -.13 |   -.19 |
    | bgm86vz7ghjsj |    569430 |    576657 | 568818 | 576863 |      -1.27 |  -1.41 |
    | bgm86vz7ghjsj |    570474 |    576657 | 570852 | 576863 |      -1.08 |  -1.05 |
    | bgm86vz7ghjsj |    570703 |    576657 | 570871 | 576863 |      -1.04 |  -1.05 |
    | bgm86vz7ghjsj |    578863 |    576657 | 578872 | 576863 |        .38 |    .35 |
    | bgm86vz7ghjsj |    579699 |    576657 | 579818 | 576863 |        .52 |    .51 |
    ---------------------------------------------------------------------------------

    PL/SQL procedure successfully completed.

    SQL>
    ```

    This report details the IM performance features that were evaluated, whether candidate features were accepted or not, and the SQL statements that were used to evaluate any benefit.

3. Now lets look at the .

    Run the script *03\_aim\_attributes.sql*

    ```
    <copy>
    @03_aim_attributes.sql
    </copy>    
    ```

    or run the queries below:

    ```
    <copy>
    column owner format a15;
    column table_name format a30;
    column partition_name format a15;
    column inmemory format a10;
    column INMEMORY_PRIORITY heading 'INMEMORY|PRIORITY' format a10;
    column INMEMORY_DISTRIBUTE heading 'INMEMORY|DISTRIBUTE' format a12;
    column INMEMORY_COMPRESSION heading 'INMEMORY|COMPRESSION' format a14;
    set echo on

    -- Show table attributes

    select owner, table_name, NULL as partition_name, inmemory,
       inmemory_priority, inmemory_distribute, inmemory_compression
    from   dba_tables
    where  inmemory_compression = 'AUTO'
    and    owner IN ('AIM','SSB')
    UNION ALL
    select table_owner as owner, table_name, partition_name, inmemory,
           inmemory_priority, inmemory_distribute, inmemory_compression
    from   dba_tab_partitions
    where  inmemory_compression = 'AUTO'
    and    owner IN ('AIM','SSB')
    order by owner, table_name, partition_name;

    set echo off
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
      4  where  inmemory_compression = 'AUTO'
      5  and    owner IN ('AIM','SSB')
      6  UNION ALL
      7  select table_owner as owner, table_name, partition_name, inmemory,
      8         inmemory_priority, inmemory_distribute, inmemory_compression
      9  from   dba_tab_partitions
     10  where inmemory_compression = 'AUTO'
     11  and    table_owner IN ('AIM','SSB')
     12  order by owner, table_name, partition_name;

                                                                              INMEMORY   INMEMORY     INMEMORY
    OWNER           TABLE_NAME                     PARTITION_NAME  INMEMORY   PRIORITY   DISTRIBUTE   COMPRESSION
    --------------- ------------------------------ --------------- ---------- ---------- ------------ --------------
    AIM             LRGTAB1                                        ENABLED    NONE       AUTO         AUTO
    AIM             LRGTAB2                                        ENABLED    NONE       AUTO         AUTO
    AIM             LRGTAB3                                        ENABLED    NONE       AUTO         AUTO
    AIM             MEDTAB1                                        ENABLED    NONE       AUTO         AUTO
    AIM             MEDTAB2                                        ENABLED    NONE       AUTO         AUTO
    AIM             MEDTAB3                                        ENABLED    NONE       AUTO         AUTO
    AIM             SMTAB1                                         ENABLED    NONE       AUTO         AUTO
    AIM             SMTAB2                                         ENABLED    NONE       AUTO         AUTO
    AIM             SMTAB3                                         ENABLED    NONE       AUTO         AUTO
    SSB             CHICAGO_DATA                                   ENABLED    NONE       AUTO         AUTO
    SSB             CUSTOMER                                       ENABLED    NONE       AUTO         AUTO
    SSB             DATE_DIM                                       ENABLED    NONE       AUTO         AUTO
    SSB             EXT_CUST_BULGARIA                              ENABLED    NONE       AUTO         AUTO
    SSB             EXT_CUST_NORWAY                                ENABLED    NONE       AUTO         AUTO
    SSB             JSON_PURCHASEORDER                             ENABLED    NONE       AUTO         AUTO
    SSB             J_PURCHASEORDER                                ENABLED    NONE       AUTO         AUTO
    SSB             LINEORDER                      PART_1994       ENABLED    NONE       AUTO         AUTO
    SSB             LINEORDER                      PART_1995       ENABLED    NONE       AUTO         AUTO
    SSB             LINEORDER                      PART_1996       ENABLED    NONE       AUTO         AUTO
    SSB             LINEORDER                      PART_1997       ENABLED    NONE       AUTO         AUTO
    SSB             LINEORDER                      PART_1998       ENABLED    NONE       AUTO         AUTO
    SSB             PART                                           ENABLED    NONE       AUTO         AUTO
    SSB             SUPPLIER                                       ENABLED    NONE       AUTO         AUTO
    SSB             SUPP_EXTRA                                     ENABLED    NONE       AUTO         AUTO

    24 rows selected.

    SQL> 
    SQL> set echo off
    ```

    Note the inmemory status of the AIM and SSB schema tables. Note that they are all enabled since AIM level is set to high.

4. Now lets look at what objects are populated.

    Run the script *04\_im\_populated.sql*

    ```
    <copy>
    @04_im_populated.sql
    </copy>    
    ```

    or run the queries below:

    ```
    <copy>    
    column owner format a15;
    column segment_name format a30;
    column partition_name format a15;
    column populate_status format a15;
    column bytes heading 'Disk Size' format 999,999,999,999;
    column inmemory_size heading 'In-Memory|Size' format 999,999,999,999;
    column bytes_not_populated heading 'Bytes|Not Populated' format 999,999,999,999;
    column pool format a20;
    column alloc_bytes format 999,999,999,999,999;
    column used_bytes format 999,999,999,999,999;
    column populate_status format a15;
    set echo on

    -- Query the view v$IM_SEGMENTS to shows what objects are in the column store
    -- and how much of the objects were populated. When the BYTES_NOT_POPULATED is 0 
    -- it indicates the entire table was populated. 

    select owner, segment_name, partition_name, populate_status, bytes, 
           inmemory_size, bytes_not_populated 
    from   v$im_segments
    where owner not in ('AUDSYS','SYS')
    order by owner, segment_name, partition_name;

    SELECT pool, alloc_bytes, used_bytes, populate_status, con_id
    FROM   v$inmemory_area;
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
    OWNER           SEGMENT_NAME                   PARTITION_NAME  POPULATE_STATUS        Disk Size             Size    Not Populated
    --------------- ------------------------------ --------------- --------------- ---------------- ---------------- ----------------
    SSB             CUSTOMER                                       COMPLETED             24,928,256       23,199,744                0
    SSB             DATE_DIM                                       COMPLETED                122,880        1,179,648                0
    SSB             LINEORDER                      PART_1994       COMPLETED            571,842,560      504,299,520                0
    SSB             LINEORDER                      PART_1995       COMPLETED            571,711,488      500,105,216                0
    SSB             LINEORDER                      PART_1996       COMPLETED            573,251,584      499,056,640                0
    SSB             LINEORDER                      PART_1997       COMPLETED            571,555,840      503,250,944                0
    SSB             LINEORDER                      PART_1998       COMPLETED            337,256,448      292,159,488                0
    SSB             PART                                           COMPLETED             56,893,440       16,973,824                0
    SSB             SUPPLIER                                       COMPLETED              1,769,472        2,228,224                0
    SSB             SUPP_EXTRA                                     COMPLETED                 24,576        1,179,648                0

    10 rows selected.

    SQL> 
    SQL> SELECT pool, alloc_bytes, used_bytes, populate_status, con_id
      2  FROM   v$inmemory_area;

    POOL                          ALLOC_BYTES           USED_BYTES POPULATE_STATUS     CON_ID
    -------------------- -------------------- -------------------- --------------- ----------
    1MB POOL                    3,070,230,528        2,338,324,480 DONE                     3
    64KB POOL                     134,217,728            5,308,416 DONE                     3
    IM POOL METADATA               16,777,216           16,777,216 DONE                     3

    SQL> 
    ```
5. Now we will AIM tables in order to fill the column store and show how AIM will manage the IM column store by populating the objects that will get the most benefit and evicting objects to make room for the new objects.    

    Run the script *05\_pop\_aim\_tables.sql*

    ```
    <copy>
    @05_pop_aim_tables.sql
    </copy>    
    ```

    or run the queries below:

    ```
    <copy>
    select count(*) from aim.lrgtab1;
    select count(*) from aim.lrgtab1;

    select count(*) from aim.lrgtab2;
    select count(*) from aim.lrgtab2;
    select count(*) from aim.lrgtab2;

    select count(*) from aim.lrgtab3;
    select count(*) from aim.medtab1;
    select count(*) from aim.medtab1;
    select count(*) from aim.medtab1;
    select count(*) from aim.medtab2;
    select count(*) from aim.medtab2;
    select count(*) from aim.medtab2;

    select count(*) from aim.lrgtab3;
    select count(*) from aim.lrgtab3;
    </copy>
    ```

    Query result:

    ```
    SQL> @05_pop_aim_tables.sql
    Connected.
    SQL> 
    SQL> select count(*) from aim.lrgtab1;

      COUNT(*)
    ----------
       5000000

    SQL> select count(*) from aim.lrgtab1;

      COUNT(*)
    ----------
       5000000

    SQL> 
    SQL> select count(*) from aim.lrgtab2;

      COUNT(*)
    ----------
       5000000

    SQL> select count(*) from aim.lrgtab2;

      COUNT(*)
    ----------
       5000000

    SQL> select count(*) from aim.lrgtab2;

      COUNT(*)
    ----------
       5000000

    SQL> 
    SQL> select count(*) from aim.lrgtab3;

      COUNT(*)
    ----------
       5000000

    SQL> select count(*) from aim.medtab1;

      COUNT(*)
    ----------
        300000

    SQL> select count(*) from aim.medtab1;

      COUNT(*)
    ----------
        300000

    SQL> select count(*) from aim.medtab1;

      COUNT(*)
    ----------
        300000

    SQL> select count(*) from aim.medtab2;

      COUNT(*)
    ----------
        300000

    SQL> select count(*) from aim.medtab2;

      COUNT(*)
    ----------
        300000

    SQL> select count(*) from aim.medtab2;

      COUNT(*)
    ----------
        300000

    SQL> 
    SQL> select count(*) from aim.lrgtab3;

      COUNT(*)
    ----------
       5000000

    SQL> select count(*) from aim.lrgtab3;

      COUNT(*)
    ----------
       5000000

    SQL> 
    ```

6. In this step we will review the populated segments. You may want to run this step multiple times to observe the progress of the population.

    Run the script *06\_im\_populated.sql*

    ```
    <copy>
    @06_im_populated.sql
    </copy>    
    ```

    or run the queries below:

    ```
    <copy>
    column owner format a15;
    column segment_name format a30;
    column partition_name format a15;
    column populate_status format a15;
    column bytes heading 'Disk Size' format 999,999,999,999;
    column inmemory_size heading 'In-Memory|Size' format 999,999,999,999;
    column bytes_not_populated heading 'Bytes|Not Populated' format 999,999,999,999;
    column pool format a20;
    column alloc_bytes format 999,999,999,999,999;
    column used_bytes format 999,999,999,999,999;
    column populate_status format a15;

    -- Query the view v$IM_SEGMENTS to shows what objects are in the column store
    -- and how much of the objects were populated. When the BYTES_NOT_POPULATED is 0 
    -- it indicates the entire table was populated. 

    select owner, segment_name, partition_name, populate_status, bytes, 
           inmemory_size, bytes_not_populated 
    from   v$im_segments
    where owner not in ('AUDSYS','SYS')
    order by owner, segment_name, partition_name;

    SELECT pool, alloc_bytes, used_bytes, populate_status, con_id
    FROM   v$inmemory_area;
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
      4  where owner not in ('AUDSYS','SYS')
      5  order by owner, segment_name, partition_name;

                                                                                                           In-Memory            Bytes
    OWNER           SEGMENT_NAME                   PARTITION_NAME  POPULATE_STATUS        Disk Size             Size    Not Populated
    --------------- ------------------------------ --------------- --------------- ---------------- ---------------- ----------------
    AIM             LRGTAB1                                        COMPLETED            575,168,512      269,156,352                0
    AIM             LRGTAB2                                        OUT OF MEMORY        575,168,512      127,467,520      314,818,560
    AIM             LRGTAB3                                        COMPLETED            575,168,512      270,204,928                0
    AIM             MEDTAB1                                        COMPLETED             38,322,176       23,199,744                0
    AIM             MEDTAB2                                        COMPLETED             38,322,176       23,199,744                0
    ORDS_METADATA   ORDS_SCHEMAS                                   COMPLETED                 40,960        1,179,648                0
    ORDS_METADATA   ORDS_URL_MAPPINGS                              COMPLETED                 40,960        1,179,648                0
    ORDS_METADATA   SEC_KEYS                                       COMPLETED                 40,960        1,179,648                0
    SSB             CUSTOMER                                       COMPLETED             24,928,256       23,199,744                0
    SSB             DATE_DIM                                       COMPLETED                122,880        1,179,648                0
    SSB             LINEORDER                      PART_1994       COMPLETED            571,842,560      504,299,520                0
    SSB             LINEORDER                      PART_1995       COMPLETED            571,711,488      500,105,216                0
    SSB             LINEORDER                      PART_1996       COMPLETED            573,251,584      499,056,640                0
    SSB             LINEORDER                      PART_1997       COMPLETED            571,555,840      503,250,944                0
    SSB             LINEORDER                      PART_1998       COMPLETED            337,256,448      292,159,488                0
    SSB             PART                                           COMPLETED             56,893,440       16,973,824                0
    SSB             SUPPLIER                                       COMPLETED              1,769,472        2,228,224                0
    SSB             SUPP_EXTRA                                     COMPLETED                 24,576        1,179,648                0

    18 rows selected.

    SQL> 
    SQL> SELECT pool, alloc_bytes, used_bytes, populate_status, con_id
      2  FROM   v$inmemory_area;

    POOL                          ALLOC_BYTES           USED_BYTES POPULATE_STATUS     CON_ID
    -------------------- -------------------- -------------------- --------------- ----------
    1MB POOL                    3,070,230,528        3,052,404,736 DONE                     3
    64KB POOL                     134,217,728            7,995,392 DONE                     3
    IM POOL METADATA               16,777,216           16,777,216 DONE                     3

    SQL> 
    ```

7. Now we will increase the full table scan count for the AIM table MEDTAB3 in order to get AIM to populate that table over other "less popular" tables already populated in the IM column store.

    Run the script *07\_pop\_aim\_tables2.sql*

    ```
    <copy>
    @07_pop_aim_tables2.sql
    </copy>    
    ```

    or run the queries below:

    ```
    <copy>
    select count(*) from aim.medtab3;
    select count(*) from aim.medtab3;
    select count(*) from aim.medtab3;
    select count(*) from aim.medtab3;
    select count(*) from aim.medtab3;
    select count(*) from aim.medtab3;
    select count(*) from aim.medtab3;
    select count(*) from aim.medtab3;
    </copy>
    ```

    Query result:

    ```
    SQL> @07_pop_aim_tables2.sql
    Connected.
    SQL> 
    SQL> select count(*) from aim.medtab3;

      COUNT(*)
    ----------
        300000

    SQL> select count(*) from aim.medtab3;

      COUNT(*)
    ----------
        300000

    SQL> select count(*) from aim.medtab3;

      COUNT(*)
    ----------
        300000

    SQL> select count(*) from aim.medtab3;

      COUNT(*)
    ----------
        300000

    SQL> select count(*) from aim.medtab3;

      COUNT(*)
    ----------
        300000

    SQL> select count(*) from aim.medtab3;

      COUNT(*)
    ----------
        300000

    SQL> select count(*) from aim.medtab3;

      COUNT(*)
    ----------
        300000

    SQL> select count(*) from aim.medtab3;

      COUNT(*)
    ----------
        300000

    SQL> 
    ```

8. Now we will again look at the populated segments and see if anything has changed. You may want to run this step multiple times to observe the progress of the population.

    Run the script *08\_im\_populated.sql*

    ```
    <copy>
    @08_im_populated.sql
    </copy>    
    ```

    or run the queries below:

    ```
    <copy>
    column owner format a15;
    column segment_name format a30;
    column partition_name format a15;
    column populate_status format a15;
    column bytes heading 'Disk Size' format 999,999,999,999;
    column inmemory_size heading 'In-Memory|Size' format 999,999,999,999;
    column bytes_not_populated heading 'Bytes|Not Populated' format 999,999,999,999;
    column pool format a20;
    column alloc_bytes format 999,999,999,999,999;
    column used_bytes format 999,999,999,999,999;
    column populate_status format a15;

    -- Query the view v$IM_SEGMENTS to shows what objects are in the column store
    -- and how much of the objects were populated. When the BYTES_NOT_POPULATED is 0 
    -- it indicates the entire table was populated. 

    select owner, segment_name, partition_name, populate_status, bytes, 
           inmemory_size, bytes_not_populated 
    from   v$im_segments
    where owner not in ('AUDSYS','SYS')
    order by owner, segment_name, partition_name;

    SELECT pool, alloc_bytes, used_bytes, populate_status, con_id
    FROM   v$inmemory_area;
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
    OWNER           SEGMENT_NAME                   PARTITION_NAME  POPULATE_STATUS        Disk Size             Size    Not Populated
    --------------- ------------------------------ --------------- --------------- ---------------- ---------------- ----------------
    AIM             LRGTAB1                                        OUT OF MEMORY        575,168,512       96,862,208      373,014,528
    AIM             LRGTAB2                                        COMPLETED            575,168,512      275,709,952                0
    AIM             LRGTAB3                                        COMPLETED            575,168,512      270,204,928                0
    AIM             MEDTAB1                                        COMPLETED             38,322,176       23,199,744                0
    AIM             MEDTAB2                                        COMPLETED             38,322,176       23,199,744                0
    AIM             MEDTAB3                                        COMPLETED             38,322,176       24,248,320                0
    ORDS_METADATA   ORDS_SCHEMAS                                   COMPLETED                 40,960        1,179,648                0
    ORDS_METADATA   ORDS_URL_MAPPINGS                              COMPLETED                 40,960        1,179,648                0
    ORDS_METADATA   SEC_KEYS                                       COMPLETED                 40,960        1,179,648                0
    SSB             CUSTOMER                                       COMPLETED             24,928,256       23,199,744                0
    SSB             DATE_DIM                                       COMPLETED                122,880        1,179,648                0
    SSB             LINEORDER                      PART_1994       COMPLETED            571,842,560      504,299,520                0
    SSB             LINEORDER                      PART_1995       COMPLETED            571,711,488      500,105,216                0
    SSB             LINEORDER                      PART_1996       COMPLETED            573,251,584      499,056,640                0
    SSB             LINEORDER                      PART_1997       COMPLETED            571,555,840      503,250,944                0
    SSB             LINEORDER                      PART_1998       COMPLETED            337,256,448      292,159,488                0
    SSB             PART                                           COMPLETED             56,893,440       16,973,824                0
    SSB             SUPPLIER                                       COMPLETED              1,769,472        2,228,224                0
    SSB             SUPP_EXTRA                                     COMPLETED                 24,576        1,179,648                0

    19 rows selected.

    SQL> 
    SQL> SELECT pool, alloc_bytes, used_bytes, populate_status, con_id
      2  FROM   v$inmemory_area;

    POOL                          ALLOC_BYTES           USED_BYTES POPULATE_STATUS     CON_ID
    -------------------- -------------------- -------------------- --------------- ----------
    1MB POOL                    3,070,230,528        3,052,404,736 DONE                     3
    64KB POOL                     134,217,728            8,192,000 DONE                     3
    IM POOL METADATA               16,777,216           16,777,216 DONE                     3

    SQL> 
    ```

9. Now let's see if we can figure out what has happened with the AIM processing. This script will first capture the maximum AIM task id and will then list the task details for the last 20 tasks. It will exclude the tasks that have an action of 'NO ACTION' to make the list a bit shorter and easier to read.

    Run the script *09\_aim\_actions.sql*

    ```
    <copy>
    @09_aim_actions.sql
    </copy>    
    ```

    or run the queries below:

    ```
    <copy>
    set head off;
    set echo off;
    set verify off;
    set term off;
    column max_id new_value max_id format 99999999;
    select max(task_id) max_id
    from dba_inmemory_aimtasks;
    set term on;
    set head on;
    --
    col object_owner format a15;
    col object_name format a30;
    col subobject_name format a30;
    select * from dba_inmemory_aimtaskdetails
    where task_id between &&max_id-20 and &&max_id
    and object_owner not in ('SYS','AUDSYS')
    -- and action != 'NO ACTION'
    order by task_id, object_owner, object_name, subobject_name, action;
    set verify on;
    undefine max_id;
    set echo on;
    </copy>
    ```

    Query result:

    ```
    SQL> @09_aim_actions.sql
    Connected.

       TASK_ID OBJECT_OWNER    OBJECT_NAME                    SUBOBJECT_NAME                 ACTION           STATE
    ---------- --------------- ------------------------------ ------------------------------ ---------------- ----------
          2977 AIM             LRGTAB1                                                       POPULATE         DONE
          2977 AIM             LRGTAB2                                                       EVICT            DONE
          2977 AIM             LRGTAB3                                                       POPULATE         DONE
          2977 AIM             MEDTAB1                                                       POPULATE         DONE
          2977 AIM             MEDTAB2                                                       POPULATE         DONE
          2977 ORDS_METADATA   ORDS_SCHEMAS                                                  POPULATE         DONE
          2977 ORDS_METADATA   ORDS_URL_MAPPINGS                                             POPULATE         DONE
          2977 ORDS_METADATA   SEC_KEYS                                                      POPULATE         DONE
          2977 SH              DR$SUP_TEXT_IDX$B                                             POPULATE         FAILED
          2977 SH              DR$SUP_TEXT_IDX$C                                             POPULATE         FAILED
          2977 SSB             CUSTOMER                                                      POPULATE         DONE
          2977 SSB             DATE_DIM                                                      POPULATE         DONE
          2977 SSB             LINEORDER                      PART_1994                      POPULATE         DONE
          2977 SSB             LINEORDER                      PART_1995                      POPULATE         DONE
          2977 SSB             LINEORDER                      PART_1996                      POPULATE         DONE
          2977 SSB             LINEORDER                      PART_1997                      POPULATE         DONE
          2977 SSB             LINEORDER                      PART_1998                      POPULATE         DONE
          2977 SSB             PART                                                          POPULATE         DONE
          2977 SSB             SUPPLIER                                                      POPULATE         DONE
          2977 SSB             SUPP_EXTRA                                                    POPULATE         DONE
          2978 AIM             LRGTAB1                                                       POPULATE         DONE
          2978 AIM             LRGTAB2                                                       EVICT            DONE
          2978 AIM             LRGTAB3                                                       POPULATE         DONE
          2978 AIM             MEDTAB1                                                       POPULATE         DONE
          2978 AIM             MEDTAB2                                                       POPULATE         DONE
          2978 ORDS_METADATA   ORDS_SCHEMAS                                                  POPULATE         DONE
          2978 ORDS_METADATA   ORDS_URL_MAPPINGS                                             POPULATE         DONE
          2978 ORDS_METADATA   SEC_KEYS                                                      POPULATE         DONE
          2978 SH              DR$SUP_TEXT_IDX$B                                             POPULATE         FAILED
          2978 SH              DR$SUP_TEXT_IDX$C                                             POPULATE         FAILED
          2978 SSB             CUSTOMER                                                      POPULATE         DONE
          2978 SSB             DATE_DIM                                                      POPULATE         DONE
          2978 SSB             LINEORDER                      PART_1994                      POPULATE         DONE
          2978 SSB             LINEORDER                      PART_1995                      POPULATE         DONE
          2978 SSB             LINEORDER                      PART_1996                      POPULATE         DONE
          2978 SSB             LINEORDER                      PART_1997                      POPULATE         DONE
          2978 SSB             LINEORDER                      PART_1998                      POPULATE         DONE
          2978 SSB             PART                                                          POPULATE         DONE
          2978 SSB             SUPPLIER                                                      POPULATE         DONE
          2978 SSB             SUPP_EXTRA                                                    POPULATE         DONE
          2979 AIM             LRGTAB1                                                       POPULATE         DONE
          2979 AIM             LRGTAB2                                                       EVICT            DONE
          2979 AIM             LRGTAB3                                                       POPULATE         DONE
          2979 AIM             MEDTAB1                                                       POPULATE         DONE
          2979 AIM             MEDTAB2                                                       POPULATE         DONE
          2979 ORDS_METADATA   ORDS_SCHEMAS                                                  POPULATE         DONE
          2979 ORDS_METADATA   ORDS_URL_MAPPINGS                                             POPULATE         DONE
          2979 ORDS_METADATA   SEC_KEYS                                                      POPULATE         DONE
          2979 SH              DR$SUP_TEXT_IDX$B                                             POPULATE         FAILED
          2979 SH              DR$SUP_TEXT_IDX$C                                             POPULATE         FAILED
          2979 SSB             CUSTOMER                                                      POPULATE         DONE
          2979 SSB             DATE_DIM                                                      POPULATE         DONE
          2979 SSB             LINEORDER                      PART_1994                      POPULATE         DONE
          2979 SSB             LINEORDER                      PART_1995                      POPULATE         DONE
          2979 SSB             LINEORDER                      PART_1996                      POPULATE         DONE
          2979 SSB             LINEORDER                      PART_1997                      POPULATE         DONE
          2979 SSB             LINEORDER                      PART_1998                      POPULATE         DONE
          2979 SSB             PART                                                          POPULATE         DONE
          2979 SSB             SUPPLIER                                                      POPULATE         DONE
          2979 SSB             SUPP_EXTRA                                                    POPULATE         DONE
          2980 AIM             LRGTAB1                                                       POPULATE         DONE
          2980 AIM             LRGTAB2                                                       EVICT            DONE
          2980 AIM             LRGTAB3                                                       POPULATE         DONE
          2980 AIM             MEDTAB1                                                       POPULATE         DONE
          2980 AIM             MEDTAB2                                                       POPULATE         DONE
          2980 ORDS_METADATA   ORDS_SCHEMAS                                                  POPULATE         DONE
          2980 ORDS_METADATA   ORDS_URL_MAPPINGS                                             POPULATE         DONE
          2980 ORDS_METADATA   SEC_KEYS                                                      POPULATE         DONE
              2980 SH              DR$SUP_TEXT_IDX$B                                             POPULATE         FAILED
          2980 SH              DR$SUP_TEXT_IDX$C                                             POPULATE         FAILED
          2980 SSB             CUSTOMER                                                      POPULATE         DONE
          2980 SSB             DATE_DIM                                                      POPULATE         DONE
          2980 SSB             LINEORDER                      PART_1994                      POPULATE         DONE
          2980 SSB             LINEORDER                      PART_1995                      POPULATE         DONE
          2980 SSB             LINEORDER                      PART_1996                      POPULATE         DONE
          2980 SSB             LINEORDER                      PART_1997                      POPULATE         DONE
          2980 SSB             LINEORDER                      PART_1998                      POPULATE         DONE
          2980 SSB             PART                                                          POPULATE         DONE
          2980 SSB             SUPPLIER                                                      POPULATE         DONE
          2980 SSB             SUPP_EXTRA                                                    POPULATE         DONE
          2981 AIM             LRGTAB1                                                       PARTIAL POPULATE DONE
          2981 AIM             LRGTAB2                                                       POPULATE         DONE
          2981 AIM             LRGTAB3                                                       POPULATE         DONE
          2981 AIM             MEDTAB1                                                       POPULATE         DONE
          2981 AIM             MEDTAB2                                                       POPULATE         DONE
          2981 AIM             MEDTAB3                                                       POPULATE         DONE
          2981 ORDS_METADATA   ORDS_SCHEMAS                                                  POPULATE         DONE
          2981 ORDS_METADATA   ORDS_URL_MAPPINGS                                             POPULATE         DONE
          2981 ORDS_METADATA   SEC_KEYS                                                      POPULATE         DONE
          2981 SH              DR$SUP_TEXT_IDX$B                                             POPULATE         FAILED
          2981 SH              DR$SUP_TEXT_IDX$C                                             POPULATE         FAILED
          2981 SSB             CUSTOMER                                                      POPULATE         DONE
          2981 SSB             DATE_DIM                                                      POPULATE         DONE
          2981 SSB             LINEORDER                      PART_1994                      POPULATE         DONE
          2981 SSB             LINEORDER                      PART_1995                      POPULATE         DONE
          2981 SSB             LINEORDER                      PART_1996                      POPULATE         DONE
          2981 SSB             LINEORDER                      PART_1997                      POPULATE         DONE
          2981 SSB             LINEORDER                      PART_1998                      POPULATE         DONE
          2981 SSB             PART                                                          POPULATE         DONE
          2981 SSB             SUPPLIER                                                      POPULATE         DONE
          2981 SSB             SUPP_EXTRA                                                    POPULATE         DONE

    101 rows selected.

    SQL>
    ```

Note that the tasks are being run approximately every 2 minutes. AIM tasks will be scheduled during each IMCO cycle, which is approximately every 2 minutes, when the IM column store is under memory pressure. This means that it may take a couple of cycles, or task ids, before an object is populated by AIM in the IM column store.

10. Let's take a look at the Heat Map statistics for the segments. Although Heat Map is not used directly by AIM, and does not have to be enabled for AIM to work, it does give us an easy way to look at the usage statistics that AIM does base its decisions on.

    Run the script *10\_hm\_stats.sql*

    ```
    <copy>
    @10_hm_stats.sql
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
    SQL> @10_hm_stats.sql
    SQL> set echo off

                                                                     SEG        SEG        FULL       LOOKUP      NUM FULL NUM LOOKUP   NUM SEG
    OWNER      OBJECT_NAME          SUBOBJECT_NAME  TRACK_TIME       WRITE      READ       SCAN       SCAN            SCAN       SCAN     WRITE
    ---------- -------------------- --------------- ---------------- ---------- ---------- ---------- ---------- --------- ---------- ---------
    ORDS_METAD ORDS_SCHEMAS                         08/08/2024 21:42 NO         YES        YES        NO                 1          0         0
    ATA

    ORDS_METAD ORDS_URL_MAPPINGS                    08/08/2024 21:42 NO         YES        YES        NO                 1          0         0
    ATA

    ORDS_METAD SEC_KEYS                             08/08/2024 21:42 NO         YES        YES        NO                 1          0         0
    ATA

    SYS        WRM$_SNAPSHOT        WRM$_SNAPSHOT_1 08/08/2024 22:42 NO         YES        YES        YES                1          1         0
                                    483964345_26

    SYS        WRM$_SNAPSHOT_PK     WRM$_SNAPSHOT_1 08/08/2024 22:42 NO         YES        NO         YES                0          1         0
                                    483964345_26

    SYS        WRM$_SNAPSHOT        WRM$_SNAPSHOT_1 08/09/2024 00:42 NO         YES        NO         YES                0          7         0
                                    483964345_52

    SH         DR$SUP_TEXT_IDX$B                    08/09/2024 05:42 NO         YES        YES        NO                 3          0         0
    SH         DR$SUP_TEXT_IDX$C                    08/09/2024 05:42 NO         YES        YES        NO                 3          0         0
    SSB        CUSTOMER                             08/09/2024 17:56 NO         YES        YES        NO               416          0         0
    SSB        DATE_DIM                             08/09/2024 17:56 NO         YES        YES        NO               816          0         0
    SSB        LINEORDER            PART_1994       08/09/2024 17:56 NO         YES        YES        NO              2593          0         0
    SSB        LINEORDER            PART_1995       08/09/2024 17:56 NO         YES        YES        NO              2577          0         0
    SSB        LINEORDER            PART_1996       08/09/2024 17:56 NO         YES        YES        NO              2552          0         0
    SSB        LINEORDER            PART_1997       08/09/2024 17:56 NO         YES        YES        NO              2559          0         0
    SSB        LINEORDER            PART_1998       08/09/2024 17:56 NO         YES        YES        NO              2410          0         0
    SSB        PART                                 08/09/2024 17:56 NO         YES        YES        NO               815          0         0
    SSB        SUPPLIER                             08/09/2024 17:56 NO         YES        YES        NO               811          0         0
    SSB        SUPP_EXTRA                           08/09/2024 19:56 NO         YES        YES        NO                 2          0         0
    AIM        LRGTAB1                              08/09/2024 21:18 NO         YES        YES        NO                 2          0         0
    AIM        LRGTAB2                              08/09/2024 21:18 NO         YES        YES        NO                 3          0         0
    AIM        LRGTAB3                              08/09/2024 21:18 NO         YES        YES        NO                 3          0         0
    AIM        MEDTAB1                              08/09/2024 21:18 NO         YES        YES        NO                 3          0         0
    AIM        MEDTAB2                              08/09/2024 21:18 NO         YES        YES        NO                 3          0         0
    AIM        MEDTAB3                              08/09/2024 21:18 NO         YES        YES        NO                 8          0         0
    ORDS_METAD ORDS_SCHEMAS                         08/09/2024 21:18 NO         YES        YES        NO                 1          0         0
    ATA

    ORDS_METAD ORDS_URL_MAPPINGS                    08/09/2024 21:18 NO         YES        YES        NO                 1          0         0
    ATA

    ORDS_METAD SEC_KEYS                             08/09/2024 21:18 NO         YES        YES        NO                 1          0         0
    ATA


    27 rows selected.

    SQL>
    ```

    Note that your values may be different than what is shown above. The values shown will be based on the usage that has occurred in your database.

11. And finally, let's look at what has been happening with Automatic In-Memory Sizing. This feature is part of Automatic Shared Memory Management or ASMM, and is enabled when SGA_TARGET is set and IM_AUTOMATIC_LEVEL is set to HIGH.

    Run the script *11\_sga\_sizing.sql*

    ```
    <copy>
    @11_sga_sizing.sql
    </copy>    
    ```

    or run the queries below:

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
      start_time;
    </copy>
    ```

    Query result:

    ```
    SQL> @11_sga_sizing.sql
    Connected.

    COMPONENT            OPER_TYPE     OPER_MODE PARAMETER             INITIAL_SIZE TARGET_SIZE FINAL_SIZE START_TIME          END_TIME
    -------------------- ------------- --------- --------------------- ------------ ----------- ---------- ------------------- -------------------
    In-Memory Area       STATIC                  _datamemory_area_size            0  2936012800 2936012800 08/09/2024 16:56:49 08/09/2024 16:56:49
    DEFAULT buffer cache INITIALIZING            db_cache_size           1929379840  1929379840 1929379840 08/09/2024 16:56:49 08/09/2024 16:56:49
    DEFAULT buffer cache STATIC                  db_cache_size                    0  1929379840 1929379840 08/09/2024 16:56:49 08/09/2024 16:56:49
    DEFAULT buffer cache SHRINK        IMMEDIATE db_cache_size           1929379840  1795162112 1795162112 08/09/2024 16:56:50 08/09/2024 16:56:50
    DEFAULT buffer cache SHRINK        IMMEDIATE db_cache_size           1795162112  1778384896 1778384896 08/09/2024 16:57:04 08/09/2024 16:57:04
    DEFAULT buffer cache SHRINK        IMMEDIATE db_cache_size           1778384896  1761607680 1761607680 08/09/2024 17:05:54 08/09/2024 17:05:54
    DEFAULT buffer cache SHRINK        DEFERRED  db_cache_size           1761607680  1493172224 1493172224 08/09/2024 17:06:28 08/09/2024 17:06:28
    In-Memory Area       GROW          DEFERRED  _datamemory_area_size   2936012800  3204448256 3204448256 08/09/2024 17:06:28 08/09/2024 17:06:28
    DEFAULT buffer cache SHRINK        IMMEDIATE db_cache_size           1493172224  1476395008 1476395008 08/09/2024 17:06:45 08/09/2024 17:06:45
    DEFAULT buffer cache SHRINK        IMMEDIATE db_cache_size           1476395008  1459617792 1459617792 08/09/2024 17:07:11 08/09/2024 17:07:11
    DEFAULT buffer cache SHRINK        DEFERRED  db_cache_size           1459617792  1426063360 1426063360 08/09/2024 17:08:28 08/09/2024 17:08:28
    In-Memory Area       GROW          DEFERRED  _datamemory_area_size   3204448256  3238002688 3238002688 08/09/2024 17:08:28 08/09/2024 17:08:28
    DEFAULT buffer cache SHRINK        DEFERRED  db_cache_size           1426063360  1409286144 1409286144 08/09/2024 18:00:01 08/09/2024 18:00:01
    DEFAULT buffer cache SHRINK        DEFERRED  db_cache_size           1409286144  1392508928 1392508928 08/09/2024 18:41:04 08/09/2024 18:41:04
    DEFAULT buffer cache SHRINK        IMMEDIATE db_cache_size           1392508928  1375731712 1375731712 08/09/2024 18:57:04 08/09/2024 18:57:04
    DEFAULT buffer cache SHRINK        IMMEDIATE db_cache_size           1375731712  1358954496 1358954496 08/09/2024 18:59:08 08/09/2024 18:59:08
    DEFAULT buffer cache SHRINK        DEFERRED  db_cache_size           1358954496  1342177280 1342177280 08/09/2024 19:11:37 08/09/2024 19:11:37

    17 rows selected.

    SQL> 
    ```

## Conclusion

This lab demonstrated how the new INMEMORY\_AUTOMATIC\_LEVEL = HIGH feature works and how AIM level high can enable the automatic management of the contents of IM column store. This means no more having to try and figure out which objects would get the most benefit from being populated. Now the database will do it for you. We also showed that AIM can now enable IM performance features automatically based on usasge and how the IM column store can be resized automatically based on workload requirements as part of Automatic Shared Memory Management.

You may now **proceed to the next lab**.

## Acknowledgements

- **Author** - Andy Rivenes, Product Manager,  Database In-Memory
- **Contributors** -
- **Last Updated By/Date** - Andy Rivenes, July 2024
