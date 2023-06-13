# In-Memory Expressions

## Introduction

Watch a demo of using In-Memory Expressions:

[YouTube video](youtube:RQ5bOOQd4co)

Watch the video below for a walk through of the In-Memory Expressions lab:

[In-Memory Expressions](videohub:1_fyorhrt7)

*Estimated Lab Time:* 10 Minutes.

### Objectives

-   Learn how to enable In-Memory Expressions

### Prerequisites

This lab assumes you have:
- A Free Tier, Paid or LiveLabs Oracle Cloud account
- You have completed:
    - Get Started with noVNC Remote Desktop
    - Lab: Initialize Environment
    - Lab: Setting up the In-Memory Column Store

**NOTE:** *When doing Copy/Paste using the convenient* **Copy** *function used throughout the guide, you must hit the* **ENTER** *key after pasting. Otherwise the last line will remain in the buffer until you hit* **ENTER!**

## Task 1: In-Memory Expressions

Up until now we have been focused on the basics of Database In-Memory. We have seen that with Database In-Memory our queries have essentially generated no I/O. All of the time in the queries is consumed by CPU and memory access. Recognizing this led to the idea of finding ways to conserve CPU cycles and the addition of In-Memory Expressions. In-Memory Expressions (IME) are similar in concept to Materialized Views. The idea is to pre-compute common expressions at population time to avoid having to compute those expressions every time the expression is run.

This lab will show some examples of how much time can be saved by using In-Memory Expressions.

Let's switch to the ime folder and log back in to the PDB.

```
<copy>
cd /home/oracle/labs/inmemory/ime
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
[CDB1:oracle@dbhol:~/labs/inmemory]$ cd /home/oracle/labs/inmemory/ime
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

1. The first query will run a query with the following expression:

	```
  sum(lo_ordtotalprice - (lo_ordtotalprice*(lo_discount/100)) + lo_tax)
	```
    
	This may seem like a simplistic expression, but you may be surprised at how much time it takes to calculate that expression in comparison to the access of the data when it is populated in the IM column store.
		
  Run the script *01\_pre\_ime.sql*

	```
	<copy>
	@01_pre_ime.sql
	</copy>    
	```

	or run the query below:  

	```
	<copy>
	set timing on
	set numwidth 20
	select lo_shipmode, sum(lo_ordtotalprice),
	   sum(lo_ordtotalprice - (lo_ordtotalprice*(lo_discount/100)) + lo_tax) discount_price
	from   LINEORDER
	group by
	  lo_shipmode;
	set timing off
	select * from table(dbms_xplan.display_cursor());
	@../imstats.sql
	</copy>
	```

	Query result:

	```
	SQL> @01_pre_ime.sql
	Connected.
	SQL> set numwidth 20
	SQL>
	SQL> -- In-Memory Column Store query
	SQL>
	SQL> Select lo_shipmode, sum(lo_ordtotalprice),
		2         sum(lo_ordtotalprice - (lo_ordtotalprice*(lo_discount/100)) + lo_tax) discount_price
		3  From   LINEORDER
		4  group by
		5    lo_shipmode;

	LO_SHIPMOD SUM(LO_ORDTOTALPRICE)       DISCOUNT_PRICE
	---------- --------------------- --------------------
	AIR              112681091296143   107068358897180.63
	FOB              112639826720401   107030859534472.98
	MAIL             112693680261453   107085392524873.86
	RAIL             112734206789210   107123236454477.53
	REG AIR          112708771327068   107097637154659.13
	SHIP             112657617211563   107050645577356.64
	TRUCK            112663682726507   107052833006093.79

	7 rows selected.

	Elapsed: 00:00:06.52
	SQL>
	SQL> set echo off
	Hit enter ...


	PLAN_TABLE_OUTPUT
	------------------------------------------------------------------------------------------------------------------------------------------------------
	SQL_ID  g5rn8q8zp92tg, child number 0
	-------------------------------------
	Select lo_shipmode, sum(lo_ordtotalprice),        sum(lo_ordtotalprice
	- (lo_ordtotalprice*(lo_discount/100)) + lo_tax) discount_price From
	LINEORDER group by   lo_shipmode

	Plan hash value: 3993492462

	----------------------------------------------------------------------------------------------------------
	| Id  | Operation                    | Name      | Rows  | Bytes | Cost (%CPU)| Time     | Pstart| Pstop |
	----------------------------------------------------------------------------------------------------------
	|   0 | SELECT STATEMENT             |           |       |       |  3896 (100)|          |       |       |
	|   1 |  HASH GROUP BY               |           |     7 |   161 |  3896  (18)| 00:00:01 |       |       |
	|   2 |   PARTITION RANGE ALL        |           |    41M|   916M|  3895  (18)| 00:00:01 |     1 |     5 |
	|   3 |    TABLE ACCESS INMEMORY FULL| LINEORDER |    41M|   916M|  3895  (18)| 00:00:01 |     1 |     5 |
	----------------------------------------------------------------------------------------------------------


	17 rows selected.

	Hit enter ...


	NAME                                                              VALUE
	-------------------------------------------------- --------------------
	CPU used by this session                                            655
	IM scan CUs columns accessed                                        312
	IM scan CUs memcompress for query low                                78
	IM scan CUs pcode aggregation pushdown                              156
	IM scan rows                                                   41760941
	IM scan rows pcode aggregated                                  41760941
	IM scan rows projected                                              546
	IM scan rows valid                                             41760941
	session logical reads                                            315589
	session logical reads - IM                                       315480
	session pga memory                                             18024696
	table scans (IM)                                                      5

	12 rows selected.

	SQL>
	```

	Note how long it took to run the query. You should also see that it did a TABLE ACCESS INMEMORY FULL of the LINEORDER table.

2. Next let's take note of the amount of space that has been used in the IM column store. Nothing in life is free and In-Memory expressions do take up some space in the IM column store.

	Run the script *`02_im_usage.sql`*

	```
	<copy>
	@02_im_usage.sql
	</copy>    
	```

	or run the query below:

	```
	<copy>
	set pages 9999
	set lines 150
	column pool format a10;
	column alloc_bytes format 999,999,999,999,999
	column used_bytes format 999,999,999,999,999
	SELECT pool, alloc_bytes, used_bytes, populate_status, con_id
	FROM v$inmemory_area;
	</copy>
	```

	Query result:
	```
	SQL> @02_im_usage.sql
	Connected.
	SQL> column pool format a10;
	SQL> column alloc_bytes format 999,999,999,999,999
	SQL> column used_bytes format 999,999,999,999,999
	SQL>
	SQL> -- Show total column store usage
	SQL>
	SQL> SELECT pool, alloc_bytes, used_bytes, populate_status, con_id
		2  FROM   v$inmemory_area;
		POOL                ALLOC_BYTES           USED_BYTES POPULATE_STATUS                          CON_ID
		---------- -------------------- -------------------- -------------------------- --------------------
		1MB POOL          3,940,548,608        2,236,612,608 DONE                                          3
		64KB POOL           234,881,024            6,029,312 DONE                                          3

	SQL>
	SQL> set echo off
	SQL>
	```

3. Now we'll create an IME using the expression from Step 1 and re-populate the LINEORDER table in the IM column store to materialize the new IME. To create an IME we just need to create a virtual column for our expression. Since we won't want anyone querying the expression directly we will make it invisible. This is not a requirement.

	Note that the init.ora parameter INMEMORY_VIRTUAL_COLUMNS must be set to ENABLE. If you look back at Lab01-Setup, Step 2 you will see that we already took care of that for you.

	Run the script *03\_create\_ime.sql*

	```
	<copy>
	@03_create_ime.sql
	</copy>    
	```

	or run the query below:

	```
	<copy>
	alter table lineorder no inmemory;
	alter table lineorder add v1 invisible as (lo_ordtotalprice - (lo_ordtotalprice*(lo_discount/100)) + lo_tax);
	alter table lineorder inmemory;
	select count(*) from lineorder;
	</copy>
	```

	Query result:

	```
	SQL> @03_create_ime.sql
	Connected.
	SQL>
	SQL> -- Create In-Memory Column Expression
	SQL>
	SQL> alter table lineorder no inmemory;

	Table altered.

	SQL> alter table lineorder add v1 invisible as (lo_ordtotalprice - (lo_ordtotalprice*(lo_discount/100)) + lo_tax);

	Table altered.

	SQL> alter table lineorder inmemory;

	Table altered.

	SQL> select count(*) from lineorder;

							COUNT(*)
	--------------------
							41760941

	SQL>
	```

4. Monitor the re-population of the LINEORDER table:

	Run the script *04\_im\_populated.sql*

	```
	<copy>
	@04_im_populated.sql
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
	from v$im_segments
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
	SSB        CUSTOMER                             COMPLETED             24,928,256       23,199,744                0
	SSB        DATE_DIM                             COMPLETED                122,880        1,179,648                0
	SSB        LINEORDER            PART_1994       COMPLETED            563,601,408      660,733,952                0
	SSB        LINEORDER            PART_1995       COMPLETED            563,470,336      614,596,608                0
	SSB        LINEORDER            PART_1996       COMPLETED            565,010,432      686,948,352                0
	SSB        LINEORDER            PART_1997       COMPLETED            563,314,688      664,928,256                0
	SSB        LINEORDER            PART_1998       COMPLETED            329,015,296      350,945,280                0
	SSB        PART                                 COMPLETED             56,893,440       18,022,400                0
	SSB        SUPPLIER                             COMPLETED              1,769,472        2,228,224                0

	9 rows selected.

	SQL>

	SQL> set echo off
	SQL>
	```

	Once the LINEORDER partitions are fully populated you can continue.

5. Now we'll take a look at how much space the IME consumes in the IM column store. Recall that we defined a virtual column named V1 in Step 3 and re-populated the LINEORDER table in Step 4.

	Run the script *05\_ime\_usage.sql*

	```
	<copy>
	@05_ime_usage.sql
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
	SQL> @05_ime_usage.sql
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
	SSB        LINEORDER            PART_1998            V1                   10           62
	SSB        LINEORDER            PART_1997            V1                   17          105
	SSB        LINEORDER            PART_1996            V1                   17          106
	SSB        LINEORDER            PART_1995            V1                   17          106
	SSB        LINEORDER            PART_1994            V1                   17          106

	SQL>

	SQL> set echo off
	SQL>
	```

	Notice the "Used Space" column for each partition. This is a calculation of the space used by the IMEUs or In-Memory Expression Units that have been allocated for the IME. IMEs do not use space in the normal IMCU or In-Memory Compression Unit. When IMEs are created at least one IMEU is created for every IMCU. IMEUs, like IMCUs, are allocated from the 1MB pool.

6. Next we'll take a look at the total IM column store usage and compare that to the total space used before we created the IME. We looked at that in Step 2.

	Run the script *06\_im\_usage.sql*

	```
	<copy>
	@06_im_usage.sql
	</copy>    
	```

	or run the queries below:

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
	SQL> @06_im_usage.sql
	Connected.
	SQL> column pool format a10;
	SQL> column alloc_bytes format 999,999,999,999,999
	SQL> column used_bytes format 999,999,999,999,999
	SQL>
	SQL> -- Show total column store usage
	SQL>
	SQL> SELECT pool, alloc_bytes, used_bytes, populate_status, con_id
		2  FROM   v$inmemory_area;

	POOL                ALLOC_BYTES           USED_BYTES POPULATE_STATUS     CON_ID
	---------- -------------------- -------------------- --------------- ----------
	1MB POOL          3,252,682,752        2,965,372,928 DONE                     3
	64KB POOL           201,326,592            6,029,312 DONE                     3

	SQL>

	SQL> set echo off
	SQL>
	```

7. Now let's see how big a difference in execution time our IME makes when we execute the query from Step 1.

	Run the *script 07\_post\_ime.sql*

	```
	<copy>
	@07_post_ime.sql
	</copy>    
	```

	or run the query below:

	```
	<copy>
	set timing on
	set numwidth 20
	Select lo_shipmode, sum(lo_ordtotalprice),
		 sum(lo_ordtotalprice - (lo_ordtotalprice*(lo_discount/100)) + lo_tax) discount_price
	From   LINEORDER
	group by lo_shipmode;
	set timing off
	select * from table(dbms_xplan.display_cursor());
	@../imstats.sql
	</copy>
	```

	Query result:

	```
	SQL> @07_post_ime.sql
	Connected.
	SQL> set numwidth 20
	SQL>
	SQL> -- In-Memory Column Store query
	SQL>
	SQL> Select lo_shipmode, sum(lo_ordtotalprice),
		2         sum(lo_ordtotalprice - (lo_ordtotalprice*(lo_discount/100)) + lo_tax) discount_price
		3  From   LINEORDER
		4  group by
		5    lo_shipmode;

	LO_SHIPMOD SUM(LO_ORDTOTALPRICE)       DISCOUNT_PRICE
	---------- --------------------- --------------------
	AIR              112681091296143   107068358897180.63
	FOB              112639826720401   107030859534472.98
	MAIL             112693680261453   107085392524873.86
	RAIL             112734206789210   107123236454477.53
	REG AIR          112708771327068   107097637154659.13
	SHIP             112657617211563   107050645577356.64
	TRUCK            112663682726507   107052833006093.79

	7 rows selected.

	Elapsed: 00:00:02.34
	SQL>
	SQL> set echo off
	Hit enter ...


	PLAN_TABLE_OUTPUT
	------------------------------------------------------------------------------------------------------------------------------------------------------
	SQL_ID  g5rn8q8zp92tg, child number 0
	-------------------------------------
	Select lo_shipmode, sum(lo_ordtotalprice),        sum(lo_ordtotalprice
	- (lo_ordtotalprice*(lo_discount/100)) + lo_tax) discount_price From
	LINEORDER group by   lo_shipmode

	Plan hash value: 3993492462

	----------------------------------------------------------------------------------------------------------
	| Id  | Operation                    | Name      | Rows  | Bytes | Cost (%CPU)| Time     | Pstart| Pstop |
	----------------------------------------------------------------------------------------------------------
	|   0 | SELECT STATEMENT             |           |       |       |  4037 (100)|          |       |       |
	|   1 |  HASH GROUP BY               |           |     7 |   210 |  4037  (21)| 00:00:01 |       |       |
	|   2 |   PARTITION RANGE ALL        |           |    41M|  1194M|  4036  (21)| 00:00:01 |     1 |     5 |
	|   3 |    TABLE ACCESS INMEMORY FULL| LINEORDER |    41M|  1194M|  4036  (21)| 00:00:01 |     1 |     5 |
	----------------------------------------------------------------------------------------------------------


	17 rows selected.

	Hit enter ...


	NAME                                                              VALUE
	-------------------------------------------------- --------------------
	CPU used by this session                                            236
	IM scan CUs columns accessed                                        312
	IM scan CUs memcompress for query low                                78
	IM scan CUs pcode aggregation pushdown                              156
	IM scan EU rows                                                41760941
	IM scan EUs columns accessed                                         78
	IM scan EUs memcompress for query low                                78
	IM scan rows                                                   41760941
	IM scan rows pcode aggregated                                  41760941
	IM scan rows projected                                              546
	IM scan rows valid                                             41760941
	session logical reads                                            315588
	session logical reads - IM                                       315480
	session pga memory                                             18155768
	table scans (IM)                                                      5

	15 rows selected.

	SQL>
	```

	There is a lot going on in these queries. Notice how much faster the query ran, in about half the time. If you think about it this is pretty impressive. Once a query runs fully in-memory about the only way to speed it up further is to reduce the CPU usage or parallelize the query. After all, an in-memory query is using CPU to access memory. With In-Memory Expressions we can avoid performing the same work over and over again.

	Also notice that in the statistics section there are a whole new group of statistics. This is another way to determine if IMEs were used. In this case we see new "IM scan EU ..." statistics showing how many rows and IMEUs were scanned.

8. At this point you might be asking yourself, how can I possibly find the expressions that my application uses most frequently? Also introduced in Release 12.2 was an optimizer feature called the Expression Statistics Store or ESS. One of the purposes of the ESS is to track the most frequently used expressions. The optimizer will keep track of commonly used expressions and then the information collected can be used to populate the most used expressions in the IM column store.

	The following procedure can be used to capture expressions:

	```
	dbms_inmemory_admin.ime_capture_expressions('CURRENT').
	```
	For this step we will query the ESS and see what expressions may have been captured for the LINEORDER table.

	Run the script *08\_ime\_ess.sql*

	```
	<copy>
	@08_ime_ess.sql
	</copy>    
	```

	or run the queries below:

	```
	<copy>
	set numwidth 25
	col owner format a6;
	col table_name format a15;
	col expression_text format a70;
	col evaluation_count format 9999999999999999;
	select
		table_name,
		evaluation_count,
		fixed_cost,
		expression_text
	from
		dba_expression_statistics
	where
		owner = 'SSB' and
		table_name = 'LINEORDER' and
		snapshot = 'LATEST'
	order by
		evaluation_count desc;
	</copy>
	```

	Query result:

	```
	SQL> @08_ime_ess.sql
	Connected.
	SQL>
	SQL> -- Expression Statistics Store query
	SQL>
	SQL> col owner format a6;
	SQL> col table_name format a15;
	SQL> col expression_text format a70;
	SQL> col evaluation_count format 9999999999999999;
	SQL>
	SQL> select
		2  --  owner,
		3    table_name,
		4  --  expression_id,
		5    evaluation_count,
		6    fixed_cost,
		7    expression_text
		8  from
		9    dba_expression_statistics
	 10  where
	 11    owner = 'SSB' and
	 12    table_name = 'LINEORDER' and
	 13    snapshot = 'LATEST'
	 14  order by
	 15    evaluation_count desc;

	TABLE_NAME       EVALUATION_COUNT                FIXED_COST EXPRESSION_TEXT
	--------------- ----------------- ------------------------- ----------------------------------------------------------------------
	LINEORDER                83524172   .0000000337759769235673 "LO_QUANTITY"
	LINEORDER                83523055   .0000000337759769235673 "LO_ORDTOTALPRICE"
	LINEORDER                64249246   .0000000337759769235673 "LO_ORDERDATE"
	LINEORDER                55359838   .0000000337759769235673 "LO_REVENUE"
	LINEORDER                55156911   .0000000337759769235673 "LO_PARTKEY"
	LINEORDER                52567926   .0000000337759769235673 "LO_SUPPKEY"
	LINEORDER                46024402   .0000000337759769235673 "LO_SUPPLYCOST"
	LINEORDER                43520659   .0000000337759769235673 "LO_CUSTKEY"
	LINEORDER                 9155717   .0000000337759769235673 "LO_DISCOUNT"
	LINEORDER                 9153034   .0000000337759769235673 "LO_EXTENDEDPRICE"
	LINEORDER                 5099040     .00000168879884617836 "LO_REVENUE"-"LO_SUPPLYCOST"
	LINEORDER                 2800453     .00000844399423089182 SYS_OP_BLOOM_FILTER(:BF0002,"LO_SUPPKEY")
	LINEORDER                 2563440     .00000844399423089182 SYS_OP_BLOOM_FILTER(:BF0001,"LO_CUSTKEY")
	LINEORDER                 1700082     .00000844399423089182 "LO_PARTKEY"
	LINEORDER                 1700082     .00000844399423089182 "LO_SUPPKEY"
	LINEORDER                 1700082     .00000844399423089182 "LO_ORDERDATE"
	LINEORDER                 1699940     .00000844399423089182 "LO_CUSTKEY"
	LINEORDER                  239144     .00000844399423089182 SYS_OP_BLOOM_FILTER(:BF0001,"LO_ORDERDATE")
	LINEORDER                  237013     .00000844399423089182 SYS_OP_BLOOM_FILTER(:BF0003,"LO_PARTKEY")
	LINEORDER                   26672     .00000168879884617836 "LO_EXTENDEDPRICE"*"LO_DISCOUNT"
	LINEORDER                    2730     .00000675519538471346 "LO_ORDTOTALPRICE"-"LO_ORDTOTALPRICE"*("LO_DISCOUNT"/100)
	LINEORDER                    1326     .00000844399423089182 "LO_ORDTOTALPRICE"-"LO_ORDTOTALPRICE"*("LO_DISCOUNT"/100)+"LO_TAX"
	LINEORDER                    1108   .0000000337759769235673 "LO_SHIPMODE"
	LINEORDER                     712   .0000000337759769235673 "LO_TAX"
	LINEORDER                      21   .0000000337759769235673 "LO_ORDERKEY"
	LINEORDER                      13   .0000000337759769235673 "LO_ORDERPRIORITY"

	26 rows selected.

	SQL>
	SQL> --
	SQL> -- Use the following to capture IM Expressions:
	SQL> -- dbms_inmemory_admin.ime_capture_expressions('CURRENT');
	SQL> --
	SQL>

	 set echo off
	SQL>
	```

	Note the columns EVALUATION_COUNT and FIXED_COST. You might even see the expression we created for the IME.

9. The final step is to run this Lab's cleanup script.

	Run the script *09\_ime\_cleanup.sql*

	```
	<copy>
	@09_ime_cleanup.sql
	</copy>    
	```

	or run the queries below:

	```
	<copy>
	alter table lineorder drop column v1;
	</copy>
	```

	Query result:

	```
	SQL> @09_ime_cleanup.sql
	Connected.

	Table altered.

	SQL>

	SQL>
	```

## Conclusion

This lab described how In-Memory Expressions work, how to create them and see how much space they consume in the IM column store. The lab then showed the performance difference IMEs can provide. Remember that with objects populated in the IM column store only CPU and memory are used and significant performance gains can be made by saving CPU cycles not calculating the same expressions over and over again.

You may now **proceed to the next lab**.

## Acknowledgements

- **Author** - Andy Rivenes, Product Manager,  Database In-Memory
- **Contributors** -
- **Last Updated By/Date** - Andy Rivenes, March 2023
