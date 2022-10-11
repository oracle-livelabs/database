@../aim_login.sql

set pages 999
set lines 200
set tab off

column owner format a10;
column table_name format a20;
column partition_name format a15;
column inmemory format a10;
column INMEMORY_PRIORITY heading 'INMEMORY|PRIORITY' format a10;
column INMEMORY_DISTRIBUTE heading 'INMEMORY|DISTRIBUTE' format a12;
column INMEMORY_COMPRESSION heading 'INMEMORY|COMPRESSION' format a14;
set echo on

-- Show table attributes

select owner, table_name, NULL as partition_name, inmemory,
       inmemory_priority, inmemory_distribute, inmemory_compression
from   dba_tables
where owner in ('AIM','SSB')
UNION ALL
select table_owner as owner, table_name, partition_name, inmemory,
       inmemory_priority, inmemory_distribute, inmemory_compression
from   dba_tab_partitions
where table_owner in ('AIM','SSB')
order by owner, table_name, partition_name;

set echo off

