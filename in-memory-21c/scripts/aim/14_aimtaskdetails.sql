@../aim_login.sql

set lines 150
set pages 9999
set tab off

col object_owner format a15;
col object_name format a30;
col subobject_name format a30;
select * from dba_inmemory_aimtaskdetails where task_id = &1
and object_owner not in ('SYS','AUDSYS')
order by object_owner, object_name, subobject_name, action;

