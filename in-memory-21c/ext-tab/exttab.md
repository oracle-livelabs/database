# In-Memory External Tables

## Introduction

Watch a preview video of creating In-Memory Column Store

[YouTube video](youtube:U9BmS53KuGs)

Watch the video below for a walk through of the In-Memory External Tables lab:

[In-Memory Expressions](videohub:1_ohs9hpw0)

*Estimated Lab Time:* 10 Minutes.

### Objectives

-   Learn how to enable In-Memory on the Oracle Database
-   Perform various queries on the In-Memory Column Store

### Prerequisites
This lab assumes you have:
- A Free Tier, Paid or LiveLabs Oracle Cloud account
- You have completed:
    - Get Started with noVNC Remote Desktop
    - Lab: Initialize Environment
    - Lab: Setting up the In-Memory Column Store

**NOTE:** *When doing Copy/Paste using the convenient* **Copy** *function used throughout the guide, you must hit the* **ENTER** *key after pasting. Otherwise the last line will remain in the buffer until you hit* **ENTER!**

### Background

Oracle Database introduced support for populating external tables in the IM column store in Oracle Database Release 18c. Enhancements were made in Oracle Database 21c to support partitioned external tables and hybrid partitioned tables. If you missed what a hybrid partitioned table is, they were introduced in Oracle Database 19c, it is a table that has both internal and external partitions. With external table support Database In-Memory can populate data without first having to load it into Oracle Database. For many customers this is a great benefit because they only need to run analytics on some external data and they don't need that data to reside permanently in Oracle Database. It also allows them to combine analytic queries with other internal database data using all of the tools available with Oracle Database.

In this lab you will see how external tables, partitioned external tables and hybrid partitioned tables work with Database In-Memory.

## Task 1: Verify Directory Definitions

In this Lab we will be populating external data from a local directory and we will need to define a database directory to use in our external table definitions to point the database to our external data.

Let's switch to the ext-tab folder and log back in to the PDB:

```
<copy>
cd /home/oracle/labs/inmemory/ext-tab
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

1. Let's query the database to see if the EXT_DIR directory has been created.

		Run the script *01\_ext\_dir.sql*

		```
		<copy>
		@01_ext_dir.sql
		</copy>    
		```

		or run the queries below.  

		```
		<copy>
		col owner            format a10;
		col directory_name   format a10;
		col directory_path   format a30;
		select * from all_directories where directory_name = 'EXT_DIR';
		</copy>
		```

		Query result:

		```
		SQL> @01_ext_dir.sql
		Connected.
		SQL>
		SQL> -- External table query
		SQL> col owner            format a10;
		SQL> col directory_name   format a10;
		SQL> col directory_path   format a30;
		SQL> select * from all_directories where directory_name = 'EXT_DIR';

		OWNER      DIRECTORY_ DIRECTORY_PATH                 ORIGIN_CON_ID
		---------- ---------- ------------------------------ -------------
		SYS        EXT_DIR    /home/oracle/labs/inmemory/Lab             3
													08-ExtTab/ext_tables


		SQL>
		```

2. First we will define an external table.

		Run the script *02\_create\_ext.sql*

		```
		<copy>
		@02_create_ext.sql
		</copy>    
		```

		or run the queries below.  

		```
		<copy>
		drop table ext_cust;
		create table ext_cust
		( custkey number, name varchar2(25), address varchar2(26), city varchar2(24), nation varchar2(19) )
		organization external
		( type oracle_loader
			default directory ext_dir
			access parameters (
			records delimited by newline
			fields terminated by '%'
			missing field values are null
				( custkey, name, address, city, nation ) )
			location ('ext_cust.csv') )
		reject limit unlimited;
		set lines 80
		desc ext_cust
		set lines 150
		</copy>
		```

		Query result:

		```
		SQL> @02_create_ext.sql
		Connected.
		SQL>
		SQL> -- Create external table
		SQL>
		SQL> drop table ext_cust;

		Table dropped.

		SQL>
		SQL> create table ext_cust
			2  ( custkey number, name varchar2(25), address varchar2(26), city varchar2(24), nation varchar2(19) )
			3  organization external
			4  ( type oracle_loader
			5    default directory ext_dir
			6    access parameters (
			7      records delimited by newline
			8      fields terminated by '%'
			9      missing field values are null
		 10      ( custkey, name, address, city, nation ) )
		 11    location ('ext_cust.csv') )
		 12  reject limit unlimited;

		Table created.

		SQL>
		SQL> set lines 80
		SQL> desc ext_cust
		 Name                                      Null?    Type
		 ----------------------------------------- -------- ----------------------------
		 CUSTKEY                                            NUMBER
		 NAME                                               VARCHAR2(25)
		 ADDRESS                                            VARCHAR2(26)
		 CITY                                               VARCHAR2(24)
		 NATION                                             VARCHAR2(19)

		SQL>
		```

3. Now let's query our external table and see what the performance is like. Note that we haven't populated the table in the IM column store we will be reading the external table records from the disk file.

		Run the script *03\_ext\_query.sql*

		```
		<copy>
		@03_ext_query.sql
		</copy>    
		```

		or run the statements below:

		```
		<copy>
		set timing on
		select nation, count(*) from ext_cust group by nation;
		set timing off
		pause Hit enter ...
		select * from table(dbms_xplan.display_cursor());
		pause Hit enter ...
		@../imstats.sql
		</copy>
		```

		Query result:

		```
		SQL> @03_ext_query.sql
		Connected.
		SQL>
		SQL> -- External table query
		SQL>
		SQL> select nation, count(*) from ext_cust group by nation;

		NATION                COUNT(*)
		------------------- ----------
		CHINA                     2427
		RUSSIA                    2463
		JAPAN                     2413
		ALGERIA                   2360
		VIETNAM                   2344

		Elapsed: 00:00:00.13
		SQL>

		SQL> set echo off
		Hit enter ...


		PLAN_TABLE_OUTPUT
		------------------------------------------------------------------------------------------------------------------------------------------------------
		SQL_ID  f8nvparhc77p4, child number 0
		-------------------------------------
		select nation, count(*) from ext_cust group by nation

		Plan hash value: 323550240

		----------------------------------------------------------------------------------------
		| Id  | Operation                   | Name     | Rows  | Bytes | Cost (%CPU)| Time     |
		----------------------------------------------------------------------------------------
		|   0 | SELECT STATEMENT            |          |       |       |   345 (100)|          |
		|   1 |  HASH GROUP BY              |          |   102K|  1096K|   345   (2)| 00:00:01 |
		|   2 |   EXTERNAL TABLE ACCESS FULL| EXT_CUST |   102K|  1096K|   341   (1)| 00:00:01 |
		----------------------------------------------------------------------------------------


		14 rows selected.

		Hit enter ...


		NAME                                                              VALUE
		-------------------------------------------------- --------------------
		CPU used by this session                                             14
		physical reads                                                       49
		session logical reads                                              1858
		session pga memory                                             21367032

		SQL>
		```

4. Now let's populate the external table in the IM column store.

		Run the script *04\_pop\_ext.sql*

		```
		<copy>
		@04_pop_ext.sql
		</copy>    
		```

		or run the queries below.

		```
		<copy>
		alter table ext_cust inmemory;
		exec dbms_inmemory.populate(USER,'EXT_CUST');
		</copy>
		```

		Query result:

		```
		SQL> @04_pop_ext.sql
		Connected.
		SQL>
		SQL> alter table ext_cust inmemory;

		Table altered.

		Elapsed: 00:00:00.01
		SQL>
		SQL> exec dbms_inmemory.populate(USER,'EXT_CUST');

		PL/SQL procedure successfully completed.

		Elapsed: 00:00:00.07
		SQL>
		```

5. Verify that the external table ext_cust table has been _populated.

		Run the script *05\_im\_populated.sql*

		```
		<copy>
		@05_im_populated.sql
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
			4  order by owner, segment_name, partition_name;

																																														In-Memory            Bytes
		OWNER      SEGMENT_NAME         PARTITION_NAME  POPULATE_STATUS        Disk Size             Size    Not Populated
		---------- -------------------- --------------- --------------- ---------------- ---------------- ----------------
		SSB        CUSTOMER                             COMPLETED             24,928,256       23,199,744                0
		SSB        DATE_DIM                             COMPLETED                122,880        1,179,648                0
		SSB        EXT_CUST                             COMPLETED                      0        1,179,648                0
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

6. Now run a query to access the inmemory external table. Note that in the query there is a command to set QUERY_REWRITE_INTEGRITY to STALE_TOLERATED. This is necessary since external tables are not automatically refreshed in the IM column store when changes to the external table are made. To resynchronize an external table in the IM column store it must be manually refreshed.

		Run the script *06\_ext\_query.sql*

		```
		<copy>
		@06_ext_query.sql
		</copy>    
		```

		or run the queries below:

		```
		<copy>
		set timing on
		-- External table query
		ALTER SESSION SET QUERY_REWRITE_INTEGRITY=stale_tolerated;
		select nation, count(*) from ext_cust group by nation;
		set timing off
		pause Hit enter ...
		select * from table(dbms_xplan.display_cursor());
		pause Hit enter ...
		@../imstats.sql
		</copy>
		```

		Query result:

		```
		SQL> @06_ext_query.sql
		Connected.
		SQL>
		SQL> -- External table query
		SQL>
		SQL> ALTER SESSION SET QUERY_REWRITE_INTEGRITY=stale_tolerated;

		Session altered.

		Elapsed: 00:00:00.00
		SQL>
		SQL> select nation, count(*) from ext_cust group by nation;

		NATION                          COUNT(*)
		------------------- --------------------
		ALGERIA                             2360
		CHINA                               2427
		JAPAN                               2413
		RUSSIA                              2463
		VIETNAM                             2344

		Elapsed: 00:00:00.15
		SQL>

		SQL> set echo off

		Hit enter ...


		PLAN_TABLE_OUTPUT
		------------------------------------------------------------------------------------------------------------------------------------------------------
		SQL_ID  f8nvparhc77p4, child number 0
		-------------------------------------
		select nation, count(*) from ext_cust group by nation

		Plan hash value: 323550240

		-------------------------------------------------------------------------------------------------
		| Id  | Operation                            | Name     | Rows  | Bytes | Cost (%CPU)| Time     |
		-------------------------------------------------------------------------------------------------
		|   0 | SELECT STATEMENT                     |          |       |       |    30 (100)|          |
		|   1 |  HASH GROUP BY                       |          |  8168 | 89848 |    30   (4)| 00:00:01 |
		|   2 |   EXTERNAL TABLE ACCESS INMEMORY FULL| EXT_CUST |  8168 | 89848 |    29   (0)| 00:00:01 |
		-------------------------------------------------------------------------------------------------


		14 rows selected.

		Hit enter ...


		NAME                                                              VALUE
		-------------------------------------------------- --------------------
		CPU used by this session                                             29
		IM scan CUs columns accessed                                          1
		IM scan CUs memcompress for query low                                 1
		IM scan CUs pcode aggregation pushdown                                1
		IM scan rows                                                      12007
		IM scan rows pcode aggregated                                     12007
		IM scan rows projected                                                5
		IM scan rows valid                                                12007
		session logical reads                                              2646
		session pga memory                                             19269880
		table scans (IM)                                                      1

		11 rows selected.

		SQL>
		```

		Note in the execution plan that is shows a "EXTERNAL TABLE ACCESS INMEMORY FULL". This verifies that an inmemory query was performed on an external table.

7. Next we will create an external partitioned table named EXT_CUST_PART.

		Run the script *07\_create\_ext\_part.sql*

		```
		<copy>
		@07_create_ext_part.sql
		</copy>    
		```

		or run the queries below:

		```
		<copy>
		drop table ext_cust_part;
		create table ext_cust_part
		(
			custkey number,
			name varchar2(25),
			address varchar2(26),
			city varchar2(24),
			nation varchar2(19)
		)
		organization external
		(
			type oracle_loader
			default directory ext_dir
			access parameters (
				records delimited by newline
				fields terminated by '%'
				missing field values are null
				(
					custkey,
					name,
					address,
					city,
					nation
				)
			)
		)
		reject limit unlimited
		partition by list (nation)
		(
			partition n1 values('RUSSIA')  location ('ext_cust_russia.csv'),
			partition n2 values('JAPAN')   location ('ext_cust_japan.csv'),
			partition n3 values('VIETNAM') location ('ext_cust_vietnam.csv'),
			partition n4 values('ALGERIA') location ('ext_cust_algeria.csv'),
			partition n5 values('CHINA')   location ('ext_cust_china.csv')
		);
		--
		col table_name format a20;
		col partition_name format a20;
		col high_value format a15;
		select TABLE_NAME, PARTITION_NAME, high_value, PARTITION_POSITION, INMEMORY
		from user_tab_partitions where table_name = 'EXT_CUST_PART';
		</copy>
		```

		Query result:

		```
		SQL> @07_create_ext_part.sql
		Connected.
		SQL>
		SQL> -- Create external table
		SQL>
		SQL> drop table ext_cust_part;

		Table dropped.

		SQL>
		SQL> create table ext_cust_part
			2  (
			3    custkey number,
			4    name varchar2(25),
			5    address varchar2(26),
			6    city varchar2(24),
			7    nation varchar2(19)
			8  )
			9  organization external
		 10  (
		 11    type oracle_loader
		 12    default directory ext_dir
		 13    access parameters (
		 14      records delimited by newline
		 15      fields terminated by '%'
		 16      missing field values are null
		 17      (
		 18        custkey,
		 19        name,
		 20        address,
		 21        city,
		 22        nation
		 23      )
		 24    )
		 25  )
		 26  reject limit unlimited
		 27  partition by list (nation)
		 28  (
		 29    partition n1 values('RUSSIA')  location ('ext_cust_russia.csv'),
		 30    partition n2 values('JAPAN')   location ('ext_cust_japan.csv'),
		 31    partition n3 values('VIETNAM') location ('ext_cust_vietnam.csv'),
		 32    partition n4 values('ALGERIA') location ('ext_cust_algeria.csv'),
		 33    partition n5 values('CHINA')   location ('ext_cust_china.csv')
		 34  );

		Table created.

		SQL>

		SQL> set lines 100
		SQL> col table_name format a20;
		SQL> col partition_name format a20;
		SQL> col high_value format a15;
		SQL> select TABLE_NAME, PARTITION_NAME, high_value, PARTITION_POSITION, INMEMORY
			2  from user_tab_partitions where table_name = 'EXT_CUST_PART';

		TABLE_NAME           PARTITION_NAME       HIGH_VALUE        PARTITION_POSITION INMEMORY
		-------------------- -------------------- --------------- -------------------- --------
		EXT_CUST_PART        N1                   'RUSSIA'                           1
		EXT_CUST_PART        N2                   'JAPAN'                            2
		EXT_CUST_PART        N3                   'VIETNAM'                          3
		EXT_CUST_PART        N4                   'ALGERIA'                          4
		EXT_CUST_PART        N5                   'CHINA'                            5

		SQL>
		```

8. Now let's populate the external partitioned table EXT_CUST_PART into the IM column store.

		Run the script *08\_pop\_ext\_part.sql*

		```
		<copy>
		@08_pop_ext_part.sql
		</copy>    
		```

		or run the queries below:

		```
		<copy>
		alter table ext_cust no inmemory;
		alter table ext_cust_part inmemory;
		exec dbms_inmemory.populate(USER,'EXT_CUST_PART');
		</copy>
		```

		Query result:

		```
		SQL> @08_pop_ext_part.sql
		Connected.
		SQL>
		SQL> alter table ext_cust no inmemory;

		Table altered.

		Elapsed: 00:00:00.01
		SQL>
		SQL> alter table ext_cust_part inmemory;

		Table altered.

		Elapsed: 00:00:00.11
		SQL>
		SQL> exec dbms_inmemory.populate(USER,'EXT_CUST_PART');

		PL/SQL procedure successfully completed.

		Elapsed: 00:00:00.92
		SQL>
		```

9. Verify that the external partitioned table EXT_CUST_PART has been populated.

		Run the script *09\_im\_populated.sql*

		```
		<copy>
		@09_im_populated.sql
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
			4  order by owner, segment_name, partition_name;

																																														In-Memory            Bytes
		OWNER      SEGMENT_NAME         PARTITION_NAME  POPULATE_STATUS        Disk Size             Size    Not Populated
		---------- -------------------- --------------- --------------- ---------------- ---------------- ----------------
		SSB        CUSTOMER                             COMPLETED             24,928,256       23,199,744                0
		SSB        DATE_DIM                             COMPLETED                122,880        1,179,648                0
		SSB        EXT_CUST_PART        N1              COMPLETED                      0        1,179,648                0
		SSB        EXT_CUST_PART        N2              COMPLETED                      0        1,179,648                0
		SSB        EXT_CUST_PART        N3              COMPLETED                      0        1,179,648                0
		SSB        EXT_CUST_PART        N4              COMPLETED                      0        1,179,648                0
		SSB        EXT_CUST_PART        N5              COMPLETED                      0        1,179,648                0
		SSB        LINEORDER            PART_1994       COMPLETED            563,601,408      585,236,480                0
		SSB        LINEORDER            PART_1995       COMPLETED            563,470,336      585,236,480                0
		SSB        LINEORDER            PART_1996       COMPLETED            565,010,432      587,333,632                0
		SSB        LINEORDER            PART_1997       COMPLETED            563,314,688      585,236,480                0
		SSB        LINEORDER            PART_1998       COMPLETED            329,015,296      342,556,672                0
		SSB        PART                                 COMPLETED             56,893,440       21,168,128                0
		SSB        SUPPLIER                             COMPLETED              1,769,472        2,228,224                0

		14 rows selected.

		SQL>
		```

10. Next we will review the definition of the external partitioned table. The data dictionary views are a little tricky when looking at all the attributes for external partitioned tables. Note that the first query shows us USER_TAB_PARTITIONS and the second query adds a join between USER_TAB_PARTITIONS and USER_XTERNAL_TAB_PARTITIONS in order to determine the INMEMORY status.

		Run the script *10\_ext\_part\_def.sql*

		```
		<copy>
		@10_ext_part_def.sql
		</copy>    
		```

		or run the queries below:

		```
		<copy>
		col table_name format a30;
		col partition_name format a20;
		col high_value format a10;
		select
			TABLE_NAME,
			PARTITION_NAME,
			high_value,
			PARTITION_POSITION,
			INMEMORY
		from
			user_tab_partitions
		where
			table_name = 'EXT_CUST_PART';
		pause Hit enter ...
		select
			tp.TABLE_NAME,
			tp.PARTITION_NAME,
			tp.HIGH_VALUE,
			tp.PARTITION_POSITION,
			DECODE(tp.INMEMORY,null,xtp.INMEMORY,tp.INMEMORY) INMEMORY
		from
			user_tab_partitions tp,
			user_xternal_tab_partitions xtp
		where
			tp.table_name = xtp.table_name(+)
			and tp.partition_name = xtp.partition_name(+)
			and tp.table_name = 'EXT_CUST_PART';
		</copy>
		```

		Query result:

		```
		SQL> @10_ext_part_def.sql
		Connected.
		SQL>
		SQL> col table_name format a30;
		SQL> col partition_name format a20;
		SQL> col high_value format a10;
		SQL> --
		SQL> select
			2    TABLE_NAME,
			3    PARTITION_NAME,
			4    high_value,
			5    PARTITION_POSITION,
			6    INMEMORY
			7  from
			8    user_tab_partitions
			9  where
		 10    table_name = 'EXT_CUST_PART';

		TABLE_NAME                     PARTITION_NAME       HIGH_VALUE   PARTITION_POSITION INMEMORY
		------------------------------ -------------------- ---------- -------------------- --------
		EXT_CUST_PART                  N1                   'RUSSIA'                      1
		EXT_CUST_PART                  N2                   'JAPAN'                       2
		EXT_CUST_PART                  N3                   'VIETNAM'                     3
		EXT_CUST_PART                  N4                   'ALGERIA'                     4
		EXT_CUST_PART                  N5                   'CHINA'                       5

		Elapsed: 00:00:00.05
		SQL>

		SQL> pause Hit enter ...

		Hit enter ...

		SQL>
		SQL> select
			2    tp.TABLE_NAME,
			3    tp.PARTITION_NAME,
			4    tp.HIGH_VALUE,
			5    tp.PARTITION_POSITION,
			6    DECODE(tp.INMEMORY,null,xtp.INMEMORY,tp.INMEMORY) INMEMORY
			7  from
			8    user_tab_partitions tp,
			9    user_xternal_tab_partitions xtp
		 10  where
		 11    tp.table_name = xtp.table_name(+)
		 12    and tp.partition_name = xtp.partition_name(+)
		 13    and tp.table_name = 'EXT_CUST_PART';

		TABLE_NAME                     PARTITION_NAME       HIGH_VALUE   PARTITION_POSITION INMEMORY
		------------------------------ -------------------- ---------- -------------------- --------
		EXT_CUST_PART                  N1                   'RUSSIA'                      1 ENABLED
		EXT_CUST_PART                  N2                   'JAPAN'                       2 ENABLED
		EXT_CUST_PART                  N3                   'VIETNAM'                     3 ENABLED
		EXT_CUST_PART                  N4                   'ALGERIA'                     4 ENABLED
		EXT_CUST_PART                  N5                   'CHINA'                       5 ENABLED

		Elapsed: 00:00:00.11
		SQL>
		```

11. Now we'll run a query to access the EXT_CUST_PART table.

		Run the script *11\_ext\_part\_query.sql*

		```
		<copy>
		@11_ext_part_query.sql
		</copy>    
		```

		or run the queries below:

		```
		<copy>
		set timing on
		ALTER SESSION SET QUERY_REWRITE_INTEGRITY=stale_tolerated;
		select nation, count(*) from EXT_CUST_PART group by nation;
		set timing off
		pause Hit enter ...
		select * from table(dbms_xplan.display_cursor());
		pause Hit enter ...
		@../imstats.sql
		</copy>
		```

		Query result:

		```
		SQL> @11_ext_part_query.sql
		Connected.
		SQL>
		SQL> -- External table query
		SQL>
		SQL> ALTER SESSION SET QUERY_REWRITE_INTEGRITY=stale_tolerated;

		Session altered.

		Elapsed: 00:00:00.01
		SQL>
		SQL> select nation, count(*) from EXT_CUST_PART group by nation;

		NATION                          COUNT(*)
		------------------- --------------------
		RUSSIA                              2463
		JAPAN                               2413
		VIETNAM                             2344
		ALGERIA                             2360
		CHINA                               2427

		Elapsed: 00:00:00.14
		SQL>

		SQL> set echo off

		Hit enter ...


		PLAN_TABLE_OUTPUT
		------------------------------------------------------------------------------------------------------------------------------------------------------
		SQL_ID  3zwzg6fyrx2zc, child number 0
		-------------------------------------
		select nation, count(*) from EXT_CUST_PART group by nation

		Plan hash value: 346892626

		-----------------------------------------------------------------------------------------------------------------------
		| Id  | Operation                             | Name          | Rows  | Bytes | Cost (%CPU)| Time     | Pstart| Pstop |
		-----------------------------------------------------------------------------------------------------------------------
		|   0 | SELECT STATEMENT                      |               |       |       |  1715 (100)|          |       |       |
		|   1 |  PARTITION LIST ALL                   |               |   510K|  5483K|  1715   (2)| 00:00:01 |     1 |     5 |
		|   2 |   HASH GROUP BY                       |               |   510K|  5483K|  1715   (2)| 00:00:01 |       |       |
		|   3 |    EXTERNAL TABLE ACCESS INMEMORY FULL| EXT_CUST_PART |   510K|  5483K|  1699   (1)| 00:00:01 |     1 |     5 |
		-----------------------------------------------------------------------------------------------------------------------


		15 rows selected.

		Hit enter ...


		NAME                                                              VALUE
		-------------------------------------------------- --------------------
		CPU used by this session                                             20
		IM scan CUs columns accessed                                          5
		IM scan CUs memcompress for query low                                 5
		IM scan CUs pcode aggregation pushdown                                5
		IM scan rows                                                      12007
		IM scan rows pcode aggregated                                     12007
		IM scan rows projected                                                5
		IM scan rows valid                                                12007
		session logical reads                                              1574
		session pga memory                                             19138808
		table scans (IM)                                                      5

		11 rows selected.

		SQL>
		```

		Again we have EXTERNAL TABLE ACCESS INMEMORY FULL, and notice the two far right columns in the execution plan, PSTART and PSTOP. The values 1 and 5 indicate that this query scanned all 5 partitions.

12. The last part of this lab will examine hybrid partitioned tables. This is a combination of both internal and external partitions. In this example we will have two internal and two external partitions. The script will create the hybrid partitioned table and then will load the 2 internal partitions from the previously loaded data.

		Run the script *12\_create\_hybrid\_part.sql*

		```
		<copy>
		@12_create\_hybrid\_part.sql
		</copy>    
		```

		or run the queries below:

		```
		<copy>
		drop table ext_cust_hybrid_part;
		create table ext_cust_hybrid_part
		(
			custkey number,
			name varchar2(25),
			address varchar2(26),
			city varchar2(24),
			nation varchar2(19)
		)
		external partition attributes
		(
			type oracle_loader
			default directory ext_dir
			access parameters (
				records delimited by newline
				fields terminated by '%'
				missing field values are null
				(
					custkey,
					name,
					address,
					city,
					nation
				)
			)
			reject limit unlimited
		)
		partition by list (nation)
		(
			partition n1 values('RUSSIA')  external location ('ext_cust_russia.csv'),
			partition n2 values('JAPAN')   external location ('ext_cust_japan.csv'),
			partition n3 values('BULGARIA'),
			partition n4 values('NORWAY')
		);
		pause Hit enter ...
		select nation, count(*) from EXT_CUST_HYBRID_PART group by nation;
		pause Hit enter ...
		insert into ext_cust_hybrid_part select * from ext_cust_bulgaria;
		insert into ext_cust_hybrid_part select * from ext_cust_norway;
		commit;
		pause Hit enter ...
		select nation, count(*) from EXT_CUST_HYBRID_PART group by nation;
		</copy>
		```

		Query result:

		```
		SQL> @12_create_hybrid_part.sql
		Connected.
		SQL>
		SQL> -- Create external table
		SQL>
		SQL> drop table ext_cust_hybrid_part;

		Table dropped.

		SQL>
		SQL> create table ext_cust_hybrid_part
			2  (
			3    custkey number,
			4    name varchar2(25),
			5    address varchar2(26),
			6    city varchar2(24),
			7    nation varchar2(19)
			8  )
			9  external partition attributes
		 10  (
		 11    type oracle_loader
		 12    default directory ext_dir
		 13    access parameters (
		 14      records delimited by newline
		 15      fields terminated by '%'
		 16      missing field values are null
		 17      (
		 18        custkey,
		 19        name,
		 20        address,
		 21        city,
		 22        nation
		 23      )
		 24    )
		 25    reject limit unlimited
		 26  )
		 27  partition by list (nation)
		 28  (
		 29    partition n1 values('RUSSIA')  external location ('ext_cust_russia.csv'),
		 30    partition n2 values('JAPAN')   external location ('ext_cust_japan.csv'),
		 31    partition n3 values('BULGARIA'),
		 32    partition n4 values('NORWAY')
		 33  );

		Table created.

		SQL>

		SQL> pause Hit enter ...

		Hit enter ...

		SQL>
		SQL> select nation, count(*) from EXT_CUST_HYBRID_PART group by nation;

		NATION                          COUNT(*)
		------------------- --------------------
		RUSSIA                              2463
		JAPAN                               2413

		SQL>
		SQL> pause Hit enter ...

		Hit enter ...

		SQL>
		SQL> insert into ext_cust_hybrid_part select * from ext_cust_bulgaria;

		2360 rows created.

		SQL> insert into ext_cust_hybrid_part select * from ext_cust_norway;

		2360 rows created.

		SQL> commit;

		Commit complete.

		SQL>
		SQL> pause Hit enter ...

		Hit enter ...

		SQL>
		SQL> select nation, count(*) from EXT_CUST_HYBRID_PART group by nation;

		NATION                          COUNT(*)
		------------------- --------------------
		RUSSIA                              2463
		JAPAN                               2413
		BULGARIA                            2360
		NORWAY                              2360

		SQL>
		```

13. Next we will populate the hybrid partitioned table into the IM column store.

		Run the script *13\_pop\_hybrid\_part.sql*

		```
		<copy>
		@13_pop_hybrid_part.sql
		</copy>    
		```

		or run the queries below:

		```
		<copy>
		alter table ext_cust_part no inmemory;
		alter table EXT_CUST_HYBRID_PART inmemory;
		exec dbms_inmemory.populate(USER,'EXT_CUST_HYBRID_PART');
		</copy>
		```

		Query result:

		```
		SQL> @13_pop_hybrid_part.sql
		Connected.
		SQL>
		SQL> alter table ext_cust_part no inmemory;

		Table altered.

		Elapsed: 00:00:00.01
		SQL>
		SQL> alter table EXT_CUST_HYBRID_PART inmemory;

		Table altered.

		Elapsed: 00:00:00.01
		SQL>
		SQL> exec dbms_inmemory.populate(USER,'EXT_CUST_HYBRID_PART');

		PL/SQL procedure successfully completed.

		Elapsed: 00:00:00.09
		SQL>
		```

14. Verify that the hybrid partitioned table EXT_CUST_HYBRID_PART has been populated.

		Run the script *14\_im\_populated.sql*

		```
		<copy>
		@14_im_populated.sql
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
		SQL> @14_im_populated.sql
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
		SSB        EXT_CUST_HYBRID_PART N1              COMPLETED                      0        1,179,648                0
		SSB        EXT_CUST_HYBRID_PART N2              COMPLETED                      0        1,179,648                0
		SSB        EXT_CUST_HYBRID_PART N3              COMPLETED              8,241,152        1,179,648                0
		SSB        EXT_CUST_HYBRID_PART N4              COMPLETED              8,241,152        1,179,648                0
		SSB        LINEORDER            PART_1994       COMPLETED            563,601,408      585,236,480                0
		SSB        LINEORDER            PART_1995       COMPLETED            563,470,336      585,236,480                0
		SSB        LINEORDER            PART_1996       COMPLETED            565,010,432      587,333,632                0
		SSB        LINEORDER            PART_1997       COMPLETED            563,314,688      585,236,480                0
		SSB        LINEORDER            PART_1998       COMPLETED            329,015,296      342,556,672                0
		SSB        PART                                 COMPLETED             56,893,440       21,168,128                0
		SSB        SUPPLIER                             COMPLETED              1,769,472        2,228,224                0

		13 rows selected.

		SQL>
		```

		Notice that two of the partitions have a 0 disk size setting (i.e. the external partitions) and two of the partitions have a disk size (i.e. the internal partitions).

15. Next we will review the definition of the hybrid partitioned table. The same issue exists for hybrid partitioned tables and the data dictionary views when viewing internal and external partitions. Note that the first query shows us USER_TAB_PARTITIONS and the second query adds a join between USER_TAB_PARTITIONS and USER_XTERNAL_TAB_PARTITIONS in order to determine the INMEMORY status.

		Run the script *15\_hybrid\_part\_def.sql*

		```
		<copy>
		@15_hybrid_part_def.sql
		</copy>    
		```

		or run the queries below:

		```
		<copy>
		col table_name format a30;
		col partition_name format a20;
		col high_value format a10;
		select
			TABLE_NAME,
			PARTITION_NAME,
			high_value,
			PARTITION_POSITION,
			INMEMORY
		from
			user_tab_partitions
		where
			table_name = 'EXT_CUST_HYBRID_PART';
		pause Hit enter ...
		select
			tp.TABLE_NAME,
			tp.PARTITION_NAME,
			tp.HIGH_VALUE,
			tp.PARTITION_POSITION,
			DECODE(tp.INMEMORY,null,xtp.INMEMORY,tp.INMEMORY) INMEMORY
		from
			user_tab_partitions tp,
			user_xternal_tab_partitions xtp
		where
			tp.table_name = xtp.table_name(+)
			and tp.partition_name = xtp.partition_name(+)
			and tp.table_name = 'EXT_CUST_HYBRID_PART';
		</copy>
		```

		Query result:

		```
		SQL> @15_hybrid_part_def.sql
		Connected.
		SQL> --
		SQL> select
			2    TABLE_NAME,
			3    PARTITION_NAME,
			4    high_value,
			5    PARTITION_POSITION,
			6    INMEMORY
			7  from
			8    user_tab_partitions
			9  where
		 10    table_name = 'EXT_CUST_HYBRID_PART';

		TABLE_NAME                     PARTITION_NAME       HIGH_VALUE   PARTITION_POSITION INMEMORY
		------------------------------ -------------------- ---------- -------------------- --------
		EXT_CUST_HYBRID_PART           N1                   'RUSSIA'                      1
		EXT_CUST_HYBRID_PART           N2                   'JAPAN'                       2
		EXT_CUST_HYBRID_PART           N3                   'BULGARIA'                    3 ENABLED
		EXT_CUST_HYBRID_PART           N4                   'NORWAY'                      4 ENABLED

		Elapsed: 00:00:00.04
		SQL>

		SQL> pause Hit enter ...

		Hit enter ...

		SQL>
		SQL> select
			2    tp.TABLE_NAME,
			3    tp.PARTITION_NAME,
			4    tp.HIGH_VALUE,
			5    tp.PARTITION_POSITION,
			6    DECODE(tp.INMEMORY,null,xtp.INMEMORY,tp.INMEMORY) INMEMORY
			7  from
			8    user_tab_partitions tp,
			9    user_xternal_tab_partitions xtp
		 10  where
		 11    tp.table_name = xtp.table_name(+)
		 12    and tp.partition_name = xtp.partition_name(+)
		 13    and tp.table_name = 'EXT_CUST_HYBRID_PART';

		TABLE_NAME                     PARTITION_NAME       HIGH_VALUE   PARTITION_POSITION INMEMORY
		------------------------------ -------------------- ---------- -------------------- --------
		EXT_CUST_HYBRID_PART           N1                   'RUSSIA'                      1 ENABLED
		EXT_CUST_HYBRID_PART           N2                   'JAPAN'                       2 ENABLED
		EXT_CUST_HYBRID_PART           N3                   'BULGARIA'                    3 ENABLED
		EXT_CUST_HYBRID_PART           N4                   'NORWAY'                      4 ENABLED

		Elapsed: 00:00:00.11
		SQL>
		```

		Notice in this query that the two internal partitions have an INMEMORY status in the USER_TAB_PARTITIONS view and the INMEMORY status for the external partitions is determined from the USER_XTERNAL_TAB_PARTITIONS view.

16. Now we'll run a query to access the EXT_CUST_HYBRID_PART table.

		Run the script *16\_hybrid\_part\_query.sql*

		```
		<copy>
		@16_hybrid_part_query.sql
		</copy>    
		```

		or run the queries below:

		```
		<copy>
		set timing on
		ALTER SESSION SET QUERY_REWRITE_INTEGRITY=stale_tolerated;
		select nation, count(*) from EXT_CUST_HYBRID_PART group by nation;
		set timing off
		pause Hit enter ...
		select * from table(dbms_xplan.display_cursor());
		pause Hit enter ...
		@../imstats.sql
		</copy>
		```

		Query result:

		```
		SQL> @16_hybrid_part_query.sql
		Connected.
		SQL>
		SQL> -- External table query
		SQL>
		SQL> ALTER SESSION SET QUERY_REWRITE_INTEGRITY=stale_tolerated;

		Session altered.

		Elapsed: 00:00:00.00
		SQL>
		SQL> select nation, count(*) from EXT_CUST_HYBRID_PART group by nation;

		NATION                          COUNT(*)
		------------------- --------------------
		RUSSIA                              2463
		JAPAN                               2413
		BULGARIA                            2360
		NORWAY                              2360

		Elapsed: 00:00:00.10
		SQL>

		SQL> set echo off

		Hit enter ...


		PLAN_TABLE_OUTPUT
		------------------------------------------------------------------------------------------------------------------------------------------------------
		SQL_ID  9xvzy9nw70fh0, child number 0
		-------------------------------------
		select nation, count(*) from EXT_CUST_HYBRID_PART group by nation

		Plan hash value: 3929300810

		---------------------------------------------------------------------------------------------------------------------------------
		| Id  | Operation                                | Name                 | Rows  | Bytes | Cost (%CPU)| Time     | Pstart| Pstop |
		---------------------------------------------------------------------------------------------------------------------------------
		|   0 | SELECT STATEMENT                         |                      |       |       |    80 (100)|          |       |       |
		|   1 |  PARTITION LIST ALL                      |                      |   180K|  1940K|    80   (4)| 00:00:01 |     1 |     4 |
		|   2 |   HASH GROUP BY                          |                      |   180K|  1940K|    80   (4)| 00:00:01 |       |       |
		|   3 |    TABLE ACCESS HYBRID PART INMEMORY FULL| EXT_CUST_HYBRID_PART |   180K|  1940K|    79   (3)| 00:00:01 |     1 |     4 |
		|   4 |     TABLE ACCESS INMEMORY FULL           | EXT_CUST_HYBRID_PART |       |       |            |          |     1 |     4 |
		---------------------------------------------------------------------------------------------------------------------------------


		16 rows selected.

		Hit enter ...


		NAME                                                              VALUE
		-------------------------------------------------- --------------------
		CPU used by this session                                             10
		IM scan CUs columns accessed                                          4
		IM scan CUs memcompress for query low                                 4
		IM scan CUs pcode aggregation pushdown                                4
		IM scan rows                                                       9596
		IM scan rows pcode aggregated                                      9596
		IM scan rows projected                                                4
		IM scan rows valid                                                 9596
		IM scan segments minmax eligible                                      2
		session logical reads                                              3340
		session logical reads - IM                                         2012
		session pga memory                                             18483448
		table scans (IM)                                                      4

		13 rows selected.

		SQL>
		```

		Now we see something a little different. We see a combination of TABLE ACCESS HYBRID PART INMEMORY FULL and TABLE ACCESS INMEMORY FULL, and notice the two far right columns in the execution plan, PSTART and PSTOP. The values 1 and 4 indicate that this query scanned all 4 partitions.

17. The final step is to run this Lab's cleanup script.

		Run the script *17\_ext\_cleanup.sql*

		```
		<copy>
		@17_ext_cleanup.sql
		</copy>    
		```

		or run the queries below:

		```
		<copy>
		alter table ext_cust no inmemory;
		alter table ext_cust_part no inmemory;
		alter table EXT_CUST_HYBRID_PART no inmemory;
		</copy>
		```

		Query result:

		```
		SQL> @17_ext_cleanup.sql
		Connected.
		SQL>
		SQL> alter table ext_cust no inmemory;

		Table altered.

		SQL> alter table ext_cust_part no inmemory;

		Table altered.

		SQL> alter table EXT_CUST_HYBRID_PART no inmemory;

		Table altered.

		SQL>
		```

## Conclusion

This lab demonstrated how Database In-Memory can optimize the access of external data, and support both external and hybrid partitioned tables.


## Acknowledgements

- **Author** - Andy Rivenes, Product Manager,  Database In-Memory
- **Contributors** -
- **Last Updated By/Date** - Andy Rivenes, August 2022
