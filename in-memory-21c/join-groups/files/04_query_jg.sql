@../imlogin.sql

set pages 9999
set lines 150
set echo off
set timing off

-- This script will query Join Groups in the In-Memory Column Store

PROMPT USER_JOINGROUP QUERY
col joingroup_name  format a18;
col table_name      format a15;
col column_name     format a15;
--
select
  joingroup_name,
  table_name,
  column_name,
  gd_address
from
  user_joingroups
order by
  joingroup_name;

