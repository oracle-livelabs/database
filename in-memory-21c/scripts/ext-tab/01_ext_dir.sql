@../imlogin.sql

set pages 9999
set lines 150

set timing on
set echo on

-- External table query
col owner            format a10;
col directory_name   format a10;
col directory_path   format a30;
select * from all_directories where directory_name = 'EXT_DIR';

set echo off
set timing off

