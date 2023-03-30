@../imlogin.sql

set pages 9999
set lines 150 
column owner format a10;
column table_name format a20;
column column_name format a20;

set echo on

select owner, table_name, COLUMN_NAME, INMEMORY_COMPRESSION
from v$im_column_level
where table_name = 'LINEORDER'
order by table_name, segment_column_id;

set echo off

