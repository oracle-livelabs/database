@../imlogin.sql

set pages 9999
set lines 150 
set tab off
column owner format a10;
column segment_name format a20;
column partition_name format a15;
column populate_status format a15;
column bytes heading 'Disk Size' format 999,999,999,999
column inmemory_size heading 'In-Memory|Size' format 999,999,999,999
column bytes_not_populated heading 'Bytes|Not Populated' format 999,999,999,999
set echo on

-- Query the view v$IM_SEGMENTS to shows what objects are in the column store
-- and how much of the objects were populated. When the BYTES_NOT_POPULATED is 0 
-- it indicates the entire table was populated. 

select owner, segment_name, partition_name, populate_status, bytes, 
       inmemory_size, bytes_not_populated 
from   v$im_segments
where owner not in ('AUDSYS','SYS')
order by owner, segment_name, partition_name;

set echo off
