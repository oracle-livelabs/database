@../imlogin.sql

set pages 9999
set lines 150
set timing on

col table_name format a15;
col column_name format a45;
col data_type format a14;
col data_length format 999999999999;
col data_default format a45 word_wrapped;
select
  table_name, column_name, data_type, DATA_LENGTH, DATA_DEFAULT
from user_tab_cols
where table_name = 'CITY_POINTS'
order by column_id;

set echo off
set timing off

