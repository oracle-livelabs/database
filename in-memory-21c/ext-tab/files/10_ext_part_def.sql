@../imlogin.sql

set pages 9999
set lines 150

set timing on
set echo on

col table_name format a30;
col partition_name format a20;
col high_value format a10;
--
select 
  TABLE_NAME, 
  PARTITION_NAME,
  high_value,
  PARTITION_POSITION,
  INMEMORY
from
  user_tab_partitions
where 
  table_name = 'EXT_CUST_PART';

pause Hit enter ...

select
  tp.TABLE_NAME,
  tp.PARTITION_NAME,
  tp.HIGH_VALUE,
  tp.PARTITION_POSITION,
  DECODE(tp.INMEMORY,null,xtp.INMEMORY,tp.INMEMORY) INMEMORY
from
  user_tab_partitions tp,
  user_xternal_tab_partitions xtp
where
  tp.table_name = xtp.table_name(+)
  and tp.partition_name = xtp.partition_name(+)
  and tp.table_name = 'EXT_CUST_PART';

set echo off
set timing off
