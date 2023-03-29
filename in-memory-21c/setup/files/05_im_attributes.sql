@../imlogin.sql

set pages 999
set lines 200
set tab off

column table_name format a12;
column partition_name format a15;
column buffer_pool format a11;
column compression heading 'DISK|COMPRESSION' format a11;
column compress_for format a12;
column INMEMORY_PRIORITY heading 'INMEMORY|PRIORITY' format a10;
column INMEMORY_DISTRIBUTE heading 'INMEMORY|DISTRIBUTE' format a12;
column INMEMORY_COMPRESSION heading 'INMEMORY|COMPRESSION' format a14;
set echo on

-- Show table attributes

select table_name, NULL as partition_name, buffer_pool, compression, compress_for, inmemory,
       inmemory_priority, inmemory_distribute, inmemory_compression
from   user_tables
where  table_name in ('DATE_DIM','PART','SUPPLIER','CUSTOMER')
UNION ALL
select table_name, partition_name, buffer_pool, compression, compress_for, inmemory,
       inmemory_priority, inmemory_distribute, inmemory_compression
from   user_tab_partitions
where  table_name = 'LINEORDER';

set echo off
