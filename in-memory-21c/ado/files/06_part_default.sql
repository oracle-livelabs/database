@../imlogin.sql

set pages 9999
set lines 150 
set echo on
alter table lineorder inmemory;
set echo off

col table_name                              format a10;
col partitioning_type  heading 'PART TYPE'  format a15;
col column_name        heading 'PART KEY'   format a15;
col partition_count    heading 'COUNT'      format 99999;
col status                                  format a10;
col def_inmemory                            format a20;

set echo on
select pt.TABLE_NAME, pt.PARTITIONING_TYPE, pk.column_name, pt.PARTITION_COUNT, pt.STATUS, pt.DEF_INMEMORY
from user_part_tables pt, user_part_key_columns pk
where pt.table_name = pk.name
and pt.table_name = 'LINEORDER';

exec dbms_inmemory.populate(USER, 'LINEORDER');
set echo off

