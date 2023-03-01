@../imlogin.sql

set pages 9999
set lines 150 
set echo on
column pool format a10;
column alloc_bytes format 999,999,999,999,999
column used_bytes format 999,999,999,999,999

-- Show total column store usage 

SELECT pool, alloc_bytes, used_bytes, populate_status, con_id
FROM   v$inmemory_area;

set echo off
