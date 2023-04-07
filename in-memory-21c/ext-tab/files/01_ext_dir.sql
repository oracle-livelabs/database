@../imlogin.sql

--
-- Requires external directory ext_dir at
--   /home/oracle/labs/inmemory/ext-tab/ext_tables
--

set pages 9999
set lines 150

--
-- Unpopulate LINEORDER to make room in the IM column store
--

set echo on

alter table lineorder no inmemory;

set echo off

-- External table query
col owner            format a10;
col directory_name   format a10;
col directory_path   format a45;

set echo on

create or replace directory ext_dir as '/home/oracle/labs/inmemory/ext-tab/ext_tables';

select * from all_directories where directory_name = 'EXT_DIR';

set echo off
