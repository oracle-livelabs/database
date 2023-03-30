# Automatic Data Optimization (ADO)

## Introduction

Watch a preview video of creating In-Memory Column Store

[YouTube video](youtube:U9BmS53KuGs)

Watch the video below for a walk through of the Automatic Data Optimization lab:

[Automatic Data Optimization](videohub:1_ohs9hpw0)

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

In Oracle Database 12.1 Automatic Data Optimization (ADO) was introduced. ADO was part of the Advanced Compression Option and provided a Heat Map feature that could be used in conjunction with policies to manage the compression and data movement based on usage and time. ADO provided an automated way to implement Information Lifecycle Management within Oracle Database. In Oracle Database 12.2 Database In-Memory support was added to ADO. New policies were added to allow enabling and disabling objects for in-memory.

This lab will show you how ADO works with Database In-Memory.

## Task 1: Verify Directory Definitions

In this Lab we will be populating external data from a local directory and we will need to define a database directory to use in our external table definitions to point the database to our external data.

Let's switch to the ado folder and log back in to the PDB:

```
<copy>
cd /home/oracle/labs/inmemory/Lab12-ado
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
[CDB1:oracle@dbhol:~/labs/inmemory]$ cd /home/oracle/labs/inmemory/ado
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

1. To enable ADO Heat Map must be enabled. This has already been done and we will show you the setting. In addition by default ADO policies are evaluated in terms of days. For this lab we will change that to seconds so that we can see our policies in action.

		Run the script *01\_ado\_setup.sql*

		```
		<copy>
		@01_ado_setup.sql
		</copy>    
		```

		or run the query below:  

		```
		<copy>
		show parameters heat_map
		col name format a20;
		select * from dba_ilmparameters;
		exec dbms_ilm_admin.customize_ilm(dbms_ilm_admin.POLICY_TIME, dbms_ilm_admin.ILM_POLICY_IN_SECONDS);
		select * from dba_ilmparameters;
		</copy>
		```

		Query result:

		```
		SQL> @01_ado_setup.sql
		Connected.
		SQL>
		SQL> show parameters heat_map

		NAME                                 TYPE        VALUE
		------------------------------------ ----------- ------------------------------
		heat_map                             string      ON
		SQL>
		SQL> col name format a20;
		SQL> select * from dba_ilmparameters;

		NAME                      VALUE
		-------------------- ----------
		ENABLED                       1
		RETENTION TIME               30
		JOB LIMIT                     2
		EXECUTION MODE                2
		EXECUTION INTERVAL           15
		TBS PERCENT USED             85
		TBS PERCENT FREE             25
		POLICY TIME                   0

		8 rows selected.

		SQL>
		SQL> exec dbms_ilm_admin.customize_ilm(dbms_ilm_admin.POLICY_TIME, dbms_ilm_admin.ILM_POLICY_IN_SECONDS);

		PL/SQL procedure successfully completed.

		SQL>
		SQL> select * from dba_ilmparameters;

		NAME                      VALUE
		-------------------- ----------
		ENABLED                       1
		RETENTION TIME               30
		JOB LIMIT                     2
		EXECUTION MODE                2
		EXECUTION INTERVAL           15
		TBS PERCENT USED             85
		TBS PERCENT FREE             25
		POLICY TIME                   1

		8 rows selected.

		SQL>
		```

		Note that the POLICY TIME has been changed from 0 (i.e. DAYS) to 1 (i.e. SECONDS).

2. Since Heat Map has been enabled it has been tracking the activity in the database during this LiveLabs session. We will take a look at what has been captured.

		Run the script *02\_hm\_stats.sql*

		```
		<copy>
		@02_hm_stats.sql
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
			and o.owner = 'SSB'
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
		SQL> @02_hm_stats.sql
		Connected.

		no rows selected

		SQL>
		```

		One of the key changes in Heat Map for Database In-Memory was the addition of "counts". That is the number of scans, reads and writes.

3. In this step we are going to create a policy for the SUPPLIER table to compress the table to CAPACITY HIGH after 5 days of no modification. Remember that we have changed the evaluation of days to seconds, this means 5 days will be converted to 5 seconds. We will then list information about the policy in the view USER_ILMOBJECTS and USER_ILMDATAMOVEMENTPOLICIES.

		Run the script *03\_compression\_policy.sql*

		```
		<copy>
		@03_compression_policy.sql
		</copy>    
		```

		or run the statements below:

		```
		<copy>
		alter table supplier ilm delete_all;
		alter table supplier inmemory memcompress for query low;
		select count(*) from supplier;
		alter table supplier ilm add policy modify inmemory memcompress for capacity high after 5 days of no modification;
		--
		col policy_name    format a10;
		col object_owner   format a10;
		col object_name    format a20;
		col object_type    format a10;
		col inherited_from format a20;
		col enabled        format a8;
		col deleted        format a8;
		select policy_name, object_owner, object_name, object_type, inherited_from,
			enabled, deleted
		from user_ilmobjects;
		--
		select policy_name, action_type, scope, compression_level, condition_type, condition_days,
			policy_subtype, action_clause
		from user_ilmdatamovementpolicies;
		</copy>
		```

		Query result:

		```
		SQL> @03_compression_policy.sql
		Connected.
		SQL>
		SQL> alter table supplier ilm delete_all;

		Table altered.

		SQL> alter table supplier inmemory memcompress for query low;

		Table altered.

		SQL> select count(*) from supplier;

			COUNT(*)
		----------
				 20000

		SQL> alter table supplier ilm add policy modify inmemory memcompress for capacity high after 5 days of no modification;

		Table altered.

		SQL>
		SQL> set echo off
		Hit enter ...

		SQL>
		SQL> select policy_name, object_owner, object_name, object_type, inherited_from, enabled, deleted
			2  from user_ilmobjects;

		POLICY_NAM OBJECT_OWN OBJECT_NAME          OBJECT_TYP INHERITED_FROM       ENABLED  DELETED
		---------- ---------- -------------------- ---------- -------------------- -------- --------
		P107       SSB        SUPPLIER             TABLE      POLICY NOT INHERITED YES      NO

		SQL>
		SQL> pause Hit enter ...

		Hit enter ...

		SQL>
		SQL> select policy_name, action_type, scope, compression_level, condition_type, condition_days,
			2    policy_subtype, action_clause
			3  from user_ilmdatamovementpolicies;

		POLICY_NAM ACTION_TYPE SCOPE   COMPRESSION_LEVEL              CONDITION_TYPE         CONDITION_DAYS POLICY_SUB
		---------- ----------- ------- ------------------------------ ---------------------- -------------- ----------
		ACTION_CLAUSE
		--------------------------------------------------------------------------------
		P107       COMPRESSION SEGMENT MEMCOMPRESS FOR CAPACITY HIGH  LAST MODIFICATION TIME              5 INMEMORY
		inmemory memcompress for capacity high


		SQL>
		```

4. Verify that the SUPPLIER table has been populated.

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
		SSB        PART                                 COMPLETED             56,893,440       18,022,400                0
		SSB        SUPPLIER                             COMPLETED              1,769,472        2,228,224                0

		SQL>
		```

5. ADO policies are evaluated on a daily basis in the Maintenance Window. For our Lab we will go ahead and manually submit a job to evaluate our policy. We will then query the views USER_ILMTASKS AND USER_ILMEVALUATIONDETAILS to see the results.

		Run the script *05\_evaluate\_policy.sql*

		```
		<copy>
		@05_evaluate_policy.sql
		</copy>
		```

		or run the queries below:

		```
		<copy>
		exec dbms_ilm.flush_all_segments;
		--
		col table_name                               format a15;
		col inmemory_priority    heading priority    format a8;
		col inmemory_compression heading compression format a17;
		select table_name, inmemory, inmemory_priority, inmemory_compression
		from user_tables where table_name = 'SUPPLIER';
		</copy>
		```

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
		order by owner, segment_name, partition_name;
		</copy>
		```

		```
		<copy>
		col policy_name   new_value pnam  format a10;
		select policy_name from user_ilmobjects where object_name = 'SUPPLIER';
		--
		variable v_execid number;
		declare
			v_execid number;
		begin
			DBMS_ILM.EXECUTE_ILM (
				owner => 'SSB',
				object_name => 'SUPPLIER',
				task_id   => :v_execid,
				policy_name => '&pnam',
				execution_mode => dbms_ilm.ilm_execution_online);
		end;
		/
		--
		col start_time      format a30;
		col completion_time format a30;
		select task_id, state, start_time, completion_time
		from user_ilmtasks where task_id = :v_execid;
		--
		select task_id,policy_name,selected_for_execution
		from user_ilmevaluationdetails
		where task_id = :v_execid;
		</copy>
		```

		```
		<copy>
		select table_name, inmemory, inmemory_priority, inmemory_compression
		from user_tables where table_name = 'SUPPLIER';
		</copy>
		```

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
		order by owner, segment_name, partition_name;
		</copy>
		```

		Query results:

		```
		SQL> @05_evaluate_policy.sql
		Connected.
		SQL>
		SQL> exec dbms_ilm.flush_all_segments;

		PL/SQL procedure successfully completed.

		SQL>
		SQL> select table_name, inmemory, inmemory_priority, inmemory_compression
			2  from user_tables where table_name = 'SUPPLIER';

		TABLE_NAME      INMEMORY priority compression
		--------------- -------- -------- -----------------
		SUPPLIER        ENABLED  NONE     FOR QUERY LOW

		SQL>
		SQL> set echo off

																																														In-Memory            Bytes
		OWNER      SEGMENT_NAME         PARTITION_NAME  POPULATE_STATUS        Disk Size             Size    Not Populated
		---------- -------------------- --------------- --------------- ---------------- ---------------- ----------------
		SSB        CUSTOMER                             COMPLETED             24,928,256       23,199,744                0
		SSB        DATE_DIM                             COMPLETED                122,880        1,179,648                0
		SSB        PART                                 COMPLETED             56,893,440       18,022,400                0
		SSB        SUPPLIER                             COMPLETED              1,769,472        2,228,224                0

		Hit enter ...

		SQL> col policy_name   new_value pnam  format a10;
		SQL> select policy_name from user_ilmobjects
			2  where object_name = 'SUPPLIER' and object_type = 'TABLE';

		POLICY_NAM
		----------
		P107

		SQL>
		SQL> variable v_execid number;
		SQL>
		SQL> declare
			2  v_execid number;
			3  begin
			4  DBMS_ILM.EXECUTE_ILM (
			5     owner => 'SSB',
			6     object_name => 'SUPPLIER',
			7     task_id   => :v_execid,
			8     policy_name => '&pnam',
			9     execution_mode => dbms_ilm.ilm_execution_online);
		 10  end;
		 11  /
		old   8:    policy_name => '&pnam',
		new   8:    policy_name => 'P107',

		PL/SQL procedure successfully completed.

		SQL> set echo off

		Hit enter ...


			 TASK_ID STATE     START_TIME                     COMPLETION_TIME
		---------- --------- ------------------------------ ------------------------------
					 702 COMPLETED 16-AUG-22 10.42.48.722413 PM   16-AUG-22 10.42.49.523918 PM


			 TASK_ID POLICY_NAM SELECTED_FOR_EXECUTION
		---------- ---------- ------------------------------------------
					 702 P107       SELECTED FOR EXECUTION


		TABLE_NAME      INMEMORY priority compression
		--------------- -------- -------- -----------------
		SUPPLIER        ENABLED  NONE     FOR CAPACITY HIGH


																																														In-Memory            Bytes
		OWNER      SEGMENT_NAME         PARTITION_NAME  POPULATE_STATUS        Disk Size             Size    Not Populated
		---------- -------------------- --------------- --------------- ---------------- ---------------- ----------------
		SSB        CUSTOMER                             COMPLETED             24,928,256       23,199,744                0
		SSB        DATE_DIM                             COMPLETED                122,880        1,179,648                0
		SSB        PART                                 COMPLETED             56,893,440       18,022,400                0
		SSB        SUPPLIER                             COMPLETED              1,769,472        1,179,648                0

		SQL>
		```

		A lot of things are going on in this step. First we show you the current compression for the SUPPLIER table (i.e. MEMCOMPRESS FOR QUERY LOW). Then we show you how much space it consumes in the IM column store for that compression level. Next we show you the policy, manually have the policy evaluated (normally this happens automatically, but for this Lab we don't want to wait around for that to happen), and then show you the results of the evaluation. Then we show you the new compression level. If the policy was evaluated correctly it should now be MEMCOMPRESS FOR CAPACITY HIGH. And lastly we show you how much space is now being consumed by the SUPPLIER table at the higher compression level.

6. Now we will take a look at an EVICTION policy. For this we are going to use the LINEORDER table. Since it is partitioned it makes an excellent example. It is common to want the most current partition(s) to be populated in the IM column store for business critical analytic queries, but after some amount of time older partitions are no longer needed. The following steps will show how the eviction of older partitions can be automated with ADO policies.

		First however, we are going to review the LINEORDER table. We want to make sure that all 5 partitions are enabled for in-memory and you might make note of the default in-memory status (i.e. DEF_INMEMORY).

		Run the script *06\_part\_default.sql*

		```
		<copy>
		@06_part_default.sql
		</copy>    
		```

		or run the queries below:

		```
		<copy>
		alter table lineorder inmemory;
		col table_name                              format a10;
		col column_name        heading 'PART KEY'   format a15;
		col partition_count    heading 'COUNT'      format 99999;
		col status                                  format a10;
		col def_inmemory                            format a20;
		select pt.TABLE_NAME, pt.PARTITIONING_TYPE, pk.column_name,
			pt.PARTITION_COUNT, pt.STATUS, pt.DEF_INMEMORY
		from user_part_tables pt, user_part_key_columns pk
		where pt.table_name = pk.name
		and pt.table_name = 'LINEORDER';
		exec dbms_inmemory.populate(USER, 'LINEORDER');
		</copy>
		```

		Query result:

		```
		SQL> @06_part_default.sql
		Connected.
		SQL> alter table lineorder inmemory;

		Table altered.

		SQL> set echo off
		SQL> select pt.TABLE_NAME, pt.PARTITIONING_TYPE, pk.column_name, pt.PARTITION_COUNT, pt.STATUS, pt.DEF_INMEMORY
			2  from user_part_tables pt, user_part_key_columns pk
			3  where pt.table_name = pk.name
			4  and pt.table_name = 'LINEORDER';

		TABLE_NAME PART TYPE       PART KEY         COUNT STATUS     DEF_INMEMORY
		---------- --------------- --------------- ------ ---------- --------------------
		LINEORDER  RANGE           LO_ORDERDATE         5 VALID      ENABLED

		SQL>
		SQL> exec dbms_inmemory.populate(USER, 'LINEORDER');

		PL/SQL procedure successfully completed.

		SQL>
		```

		You should see that the LINEORDER table is RANGE partitioned on the LO_ORDERDATE column and has 5 partitions with a default inmemory status of ENABLED. This means that when new partitions are created they will default to being enabled for inmemory.

7. Verify that the LINEORDER partitions have been populated.

		Run the script *07\_im\_populated.sql*

		```
		<copy>
		@07_im_populated.sql
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
		SSB        CUSTOMER                             COMPLETED             24,928,256       23,199,744                0
		SSB        DATE_DIM                             COMPLETED                122,880        1,179,648                0
		SSB        LINEORDER            PART_1994       COMPLETED            563,601,408      479,330,304                0
		SSB        LINEORDER            PART_1995       COMPLETED            563,470,336      479,330,304                0
		SSB        LINEORDER            PART_1996       COMPLETED            565,010,432      480,378,880                0
		SSB        LINEORDER            PART_1997       COMPLETED            563,314,688      479,330,304                0
		SSB        LINEORDER            PART_1998       COMPLETED            329,015,296      279,642,112                0
		SSB        PART                                 COMPLETED             56,893,440       18,022,400                0
		SSB        SUPPLIER                             COMPLETED              1,769,472        1,179,648                0

		9 rows selected.

		SQL>
		```

8. Next we need to generate some Heat Map statistics to ensure that we have "current" partitions and "older" partitions so that our policy can be correctly evaluated based on our expected scenario.

		Run the script *08\_gen\_hm\_stats.sql*

		```
		<copy>
		@08_gen_hm_stats.sql
		</copy>    
		```

		or run the queries below:

		```
		<copy>
		set serveroutput on;
		declare
			v_part_date  date   := to_date('01/01/1995','MM/DD/YYYY');
			v_part_count number := 4;
			v_increment  pls_integer := 12;
			v_monthcnt   pls_integer := 0;
			v_query_cnt  pls_integer := 5;
			v_totprice   number;
		begin
			for j in 1..v_part_count loop
				dbms_output.put_line('j: ' || j);
				dbms_output.put_line('data between: ' || to_char(add_months( v_part_date, v_monthcnt), 'MM/DD/YYYY') || ' and ' ||
					to_char( add_months( v_part_date + 30, v_monthcnt + 11), 'MM/DD/YYYY') );
				--
				for h in 1..(j * v_query_cnt) loop
					dbms_output.put_line('Query count h: ' || h || ' for '|| to_char( add_months( v_part_date, v_monthcnt ), 'MM/DD/YYYY' ) );
					select sum(lo_ordtotalprice) into v_totprice
					from lineorder lo
					where lo_orderdate between add_months( v_part_date, v_monthcnt ) and add_months( v_part_date + 30, v_monthcnt + 11 );
				end loop;
				--
				v_monthcnt := v_monthcnt + v_increment;
			end loop;
		end;
		/
		--
		exec dbms_ilm.flush_all_segments;
		</copy>
		```

		Query result:

		```
		SQL> @08_gen_hm_stats.sql
		Connected.
		j: 1
		data between: 01/01/1995 and 12/31/1995
		Query count h: 1 for 01/01/1995
		Query count h: 2 for 01/01/1995
		Query count h: 3 for 01/01/1995
		Query count h: 4 for 01/01/1995
		Query count h: 5 for 01/01/1995
		j: 2
		data between: 01/01/1996 and 12/31/1996
		Query count h: 1 for 01/01/1996
		Query count h: 2 for 01/01/1996
		Query count h: 3 for 01/01/1996
		Query count h: 4 for 01/01/1996
		Query count h: 5 for 01/01/1996
		Query count h: 6 for 01/01/1996
		Query count h: 7 for 01/01/1996
		Query count h: 8 for 01/01/1996
		Query count h: 9 for 01/01/1996
		Query count h: 10 for 01/01/1996
		j: 3
		data between: 01/01/1997 and 12/31/1997
		Query count h: 1 for 01/01/1997
		Query count h: 2 for 01/01/1997
		Query count h: 3 for 01/01/1997
		Query count h: 4 for 01/01/1997
		Query count h: 5 for 01/01/1997
		Query count h: 6 for 01/01/1997
		Query count h: 7 for 01/01/1997
		Query count h: 8 for 01/01/1997
		Query count h: 9 for 01/01/1997
		Query count h: 10 for 01/01/1997
		Query count h: 11 for 01/01/1997
		Query count h: 12 for 01/01/1997
		Query count h: 13 for 01/01/1997
		Query count h: 14 for 01/01/1997
		Query count h: 15 for 01/01/1997
		j: 4
		data between: 01/01/1998 and 12/31/1998
		Query count h: 1 for 01/01/1998
		Query count h: 2 for 01/01/1998
		Query count h: 3 for 01/01/1998
		Query count h: 4 for 01/01/1998
		Query count h: 5 for 01/01/1998
		Query count h: 6 for 01/01/1998
		Query count h: 7 for 01/01/1998
		Query count h: 8 for 01/01/1998
		Query count h: 9 for 01/01/1998
		Query count h: 10 for 01/01/1998
		Query count h: 11 for 01/01/1998
		Query count h: 12 for 01/01/1998
		Query count h: 13 for 01/01/1998
		Query count h: 14 for 01/01/1998
		Query count h: 15 for 01/01/1998
		Query count h: 16 for 01/01/1998
		Query count h: 17 for 01/01/1998
		Query count h: 18 for 01/01/1998
		Query count h: 19 for 01/01/1998
		Query count h: 20 for 01/01/1998

		PL/SQL procedure successfully completed.

		SQL> exec dbms_ilm.flush_all_segments;

		PL/SQL procedure successfully completed.

		SQL> 
		```

9. Verify that Heat Map statistics have been generated.

		Run the script *09\_hm\_stats.sql*

		```
		<copy>
		@09_hm_stats.sql
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
			and o.owner = 'SSB'
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
		SQL> @09_hm_stats.sql
		Connected.

																																		 SEG        SEG        FULL       LOOKUP      NUM FULL NUM LOOKUP   NUM SEG
		OWNER      OBJECT_NAME          SUBOBJECT_NAME  TRACK_TIME       WRITE      READ       SCAN       SCAN            SCAN       SCAN     WRITE
		---------- -------------------- --------------- ---------------- ---------- ---------- ---------- ---------- --------- ---------- ---------
		SSB        SUPPLIER                             08/16/2022 22:42 NO         NO         YES        NO                 1          0         0
		SSB        LINEORDER            PART_1995       08/16/2022 22:48 NO         YES        YES        NO                 4          0         0
		SSB        LINEORDER            PART_1995       08/16/2022 22:48 NO         NO         YES        NO                 1          0         0
		SSB        LINEORDER            PART_1996       08/16/2022 22:48 NO         NO         YES        NO                 1          0         0
		SSB        LINEORDER            PART_1996       08/16/2022 22:48 NO         YES        YES        NO                 9          0         0
		SSB        LINEORDER            PART_1997       08/16/2022 22:48 NO         NO         YES        NO                 1          0         0
		SSB        LINEORDER            PART_1997       08/16/2022 22:48 NO         YES        YES        NO                14          0         0
		SSB        LINEORDER            PART_1998       08/16/2022 22:48 NO         NO         YES        NO                 1          0         0
		SSB        LINEORDER            PART_1998       08/16/2022 22:48 NO         YES        YES        NO                19          0         0

		9 rows selected.

		SQL>
		```

		You should note that the "Num Full Scan" column now has counts in descending order of partition date , that is 1998 has the most scans and 1995 has the least, and also notice that PART_1994 is missing. This is because it had no activity.

10. Now we will create our eviction policy for the LINEORDER table. This policy will alter a partition to be NO INMEMORY after 300 days of no access, effectively evicting the partition from the IM column store.

		Run the script *10\_evict\_policy.sql*

		```
		<copy>
		@10_evict_policy.sql
		</copy>    
		```

		or run the queries below:

		```
		<copy>
		alter table lineorder ilm delete_all;
		alter table lineorder ilm add policy no inmemory after 300 days of no access;
		</copy>
		```

		```
		<copy>
		col policy_name    format a11;
		col object_owner   heading 'OWNER' format a10;
		col object_name    format a15;
		col object_type    format a15;
		col inherited_from format a20;
		col enabled        format a8;
		col deleted        format a8;
		col action_clause  format a20;
		select policy_name, object_owner, object_name, object_type, inherited_from, enabled, deleted
		from user_ilmobjects;
		--
		select policy_name, action_type, scope, compression_level, condition_type, condition_days,
			policy_subtype, action_clause
		from user_ilmdatamovementpolicies;
		</copy>
		```

		Query result:

		```
		SQL> @10_evict_policy.sql
		Connected.
		SQL>
		SQL> -- This example assumes that the LINEORDER partition PART_1994 has not been accessed in the last 30 seconds
		SQL>
		SQL> alter table lineorder ilm delete_all;

		Table altered.

		SQL> --
		SQL> -- NOTE: This policy uses 30 days to represent 30 seconds
		SQL> --
		SQL> alter table lineorder ilm add policy no inmemory after 30 days of no access;

		Table altered.

		SQL>
		SQL> set echo off
		Hit enter ...

		SQL>
		SQL> select policy_name, object_owner, object_name, object_type, inherited_from, enabled, deleted
			2  from user_ilmobjects;

		POLICY_NAME OWNER      OBJECT_NAME     OBJECT_TYPE     INHERITED_FROM       ENABLED  DELETED
		----------- ---------- --------------- --------------- -------------------- -------- --------
		P107        SSB        SUPPLIER        TABLE           POLICY NOT INHERITED NO       NO
		P108        SSB        LINEORDER       TABLE           POLICY NOT INHERITED YES      NO
		P108        SSB        LINEORDER       TABLE PARTITION TABLE                YES      NO
		P108        SSB        LINEORDER       TABLE PARTITION TABLE                YES      NO
		P108        SSB        LINEORDER       TABLE PARTITION TABLE                YES      NO
		P108        SSB        LINEORDER       TABLE PARTITION TABLE                YES      NO
		P108        SSB        LINEORDER       TABLE PARTITION TABLE                YES      NO

		7 rows selected.

		SQL>
		SQL> pause Hit enter ...

		Hit enter ...

		SQL>
		SQL> select policy_name, action_type, scope, compression_level, condition_type, condition_days,
			2    policy_subtype, action_clause
			3  from user_ilmdatamovementpolicies;

		POLICY_NAME ACTION_TYPE SCOPE   COMPRESSION_LEVEL              CONDITION_TYPE         CONDITION_DAYS POLICY_SUB ACTION_CLAUSE
		----------- ----------- ------- ------------------------------ ---------------------- -------------- ---------- --------------------
		P107        COMPRESSION SEGMENT MEMCOMPRESS FOR CAPACITY HIGH  LAST MODIFICATION TIME              5 INMEMORY   inmemory memcompress
																																																										 for capacity high

		P108        EVICT       SEGMENT                                LAST ACCESS TIME                   30 INMEMORY   no inmemory

		SQL>
		```

		Notice that for the LINEORDER table there is one policy name but multiple policy definitions. We created the policy at the table level and all of the partitions inherited that policy definition. The second query shows us that the policy has an action of EVICT.

11. Now we will run a manual evaluation of the policy, again because we don't want to wait around for the automatic evaluation. First we will look at the current contents of the IM column store, then invoke the policy evaluation, review the results and lastly review again review the contents of the IM column store.

		Run the script *11\_evaluate\_policy.sql*

		```
		<copy>
		@11_evaluate_policy.sql
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
		order by owner, segment_name, partition_name;    
		</copy>
		```

		```
		<copy>
		col policy_name   new_value pnam  format a10;
		select policy_name from user_ilmobjects
		where object_name = 'LINEORDER' and object_type = 'TABLE';

		variable v_execid number;
		declare
			v_execid number;
		begin
		DBMS_ILM.EXECUTE_ILM (
			 owner => 'SSB',
			 object_name => 'LINEORDER',
			 task_id   => :v_execid,
			 policy_name => '&pnam',
			 execution_mode => dbms_ilm.ilm_execution_online);
		end;
		/
		col start_time      format a30;
		col completion_time format a30;
		select task_id, state, start_time, completion_time
		from user_ilmtasks where task_id = :v_execid;
		--
		select task_id,policy_name,selected_for_execution
		from user_ilmevaluationdetails
		where task_id = :v_execid;
		</copy>
		```

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
		order by owner, segment_name, partition_name;
		</copy>
		```

		Query result:

		```
		SQL> @11_evaluate_policy.sql
		Connected.

																																														In-Memory            Bytes
		OWNER      SEGMENT_NAME         PARTITION_NAME  POPULATE_STATUS        Disk Size             Size    Not Populated
		---------- -------------------- --------------- --------------- ---------------- ---------------- ----------------
		SSB        CUSTOMER                             COMPLETED             24,928,256       23,199,744                0
		SSB        DATE_DIM                             COMPLETED                122,880        1,179,648                0
		SSB        LINEORDER            PART_1994       COMPLETED            563,601,408      479,330,304                0
		SSB        LINEORDER            PART_1995       COMPLETED            563,470,336      479,330,304                0
		SSB        LINEORDER            PART_1996       COMPLETED            565,010,432      480,378,880                0
		SSB        LINEORDER            PART_1997       COMPLETED            563,314,688      479,330,304                0
		SSB        LINEORDER            PART_1998       COMPLETED            329,015,296      279,642,112                0
		SSB        PART                                 COMPLETED             56,893,440       18,022,400                0
		SSB        SUPPLIER                             COMPLETED              1,769,472        1,179,648                0

		9 rows selected.

		Hit enter ...


		POLICY_NAM
		----------
		P108

		SQL>
		SQL> variable v_execid number;
		SQL>
		SQL> declare
			2  v_execid number;
			3  begin
			4  DBMS_ILM.EXECUTE_ILM (
			5     owner => 'SSB',
			6     object_name => 'LINEORDER',
			7     task_id   => :v_execid,
			8     policy_name => '&pnam',
			9     execution_mode => dbms_ilm.ilm_execution_online);
		 10  end;
		 11  /
		old   8:    policy_name => '&pnam',
		new   8:    policy_name => 'P108',

		PL/SQL procedure successfully completed.

		SQL>

		SQL> set echo off

		Hit enter ...


			 TASK_ID STATE     START_TIME                     COMPLETION_TIME
		---------- --------- ------------------------------ ------------------------------
					 703 COMPLETED 16-AUG-22 10.52.03.500612 PM   16-AUG-22 10.52.03.867963 PM


			 TASK_ID POLICY_NAM SELECTED_FOR_EXECUTION
		---------- ---------- ------------------------------------------
					 703 P108       SELECTED FOR EXECUTION
					 703 P108       PRECONDITION NOT SATISFIED
					 703 P108       PRECONDITION NOT SATISFIED
					 703 P108       PRECONDITION NOT SATISFIED
					 703 P108       PRECONDITION NOT SATISFIED


																																														In-Memory            Bytes
		OWNER      SEGMENT_NAME         PARTITION_NAME  POPULATE_STATUS        Disk Size             Size    Not Populated
		---------- -------------------- --------------- --------------- ---------------- ---------------- ----------------
		SSB        CUSTOMER                             COMPLETED             24,928,256       23,199,744                0
		SSB        DATE_DIM                             COMPLETED                122,880        1,179,648                0
		SSB        LINEORDER            PART_1995       COMPLETED            563,470,336      479,330,304                0
		SSB        LINEORDER            PART_1996       COMPLETED            565,010,432      480,378,880                0
		SSB        LINEORDER            PART_1997       COMPLETED            563,314,688      479,330,304                0
		SSB        LINEORDER            PART_1998       COMPLETED            329,015,296      279,642,112                0
		SSB        PART                                 COMPLETED             56,893,440       18,022,400                0
		SSB        SUPPLIER                             COMPLETED              1,769,472        1,179,648                0

		8 rows selected.

		SQL>
		```

		You should see that all 5 LINEORDER partitions are populated. Then the policy is evaluated and the results shown. Notice that only one policy met the criteria (i.e. SELECTED FOR EXECUTION). And lastly you should see that PART_1994 is no longer populated in the IM column store.

12. (Optional) You can run remove the changes made during this lab by running the following script.    

		Run the script *12\_cleanup\_ado.sql*

		```
		<copy>
		@12_cleanup_ado.sql
		</copy>    
		```

		or run the queries below:

		```
		<copy>
		-- exec dbms_ilm_admin.customize_ilm(dbms_ilm_admin.POLICY_TIME, dbms_ilm_admin.ILM_POLICY_IN_DAYS);
		select * from dba_ilmparameters;
		alter table supplier no inmemory;
		alter table supplier ilm delete_all;
		alter table lineorder no inmemory;
		alter table lineorder ilm delete_all;
		-- exec dbms_ilm_admin.CLEAR_HEAT_MAP_ALL;
		</copy>
		```

		Query result:

		```
		SQL> @12_cleanup_ado.sql
		Connected.

		NAME                      VALUE
		-------------------- ----------
		ENABLED                       1
		RETENTION TIME               30
		JOB LIMIT                     2
		EXECUTION MODE                2
		EXECUTION INTERVAL           15
		TBS PERCENT USED             85
		TBS PERCENT FREE             25
		POLICY TIME                   1

		8 rows selected.


		Table altered.


		Table altered.


		Table altered.


		Table altered.

		SQL>
		```

## Conclusion

This lab demonstrated how Database In-Memory with Automatic Data Optimization can be used to manage the contents of the IM column store. It showed an example of a rolling window partitioning environment where the most current partitions are populated and older, less active partitions are evicted which is a common scenario in Data Warehousing environments.

You may now **proceed to the next lab**.

## Acknowledgements

- **Author** - Andy Rivenes, Product Manager,  Database In-Memory
- **Contributors** -
- **Last Updated By/Date** - Andy Rivenes, August 2022
