@../imlogin.sql

set pages 9999
set lines 150 

col table_name                               format a15;
col inmemory_priority    heading priority    format a8;
col inmemory_compression heading compression format a17;
set echo on

exec dbms_ilm.flush_all_segments;

select table_name, inmemory, inmemory_priority, inmemory_compression 
from user_tables where table_name = 'SUPPLIER';

set echo off

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

pause Hit enter ...

-- Manually evaluate ADO policy
set echo on
col policy_name   new_value pnam  format a10;
select policy_name from user_ilmobjects
where object_name = 'SUPPLIER' and object_type = 'TABLE';

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
set echo off

pause Hit enter ...

col start_time      format a30;
col completion_time format a30;
select task_id, state, start_time, completion_time
from user_ilmtasks where task_id = :v_execid;

select task_id,policy_name,selected_for_execution 
from user_ilmevaluationdetails
where task_id = :v_execid; 

select table_name, inmemory, inmemory_priority, inmemory_compression 
from user_tables where table_name = 'SUPPLIER';

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

