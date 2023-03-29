@../imlogin.sql

set pages 9999
set lines 150
set timing on

col table_name format a15;
col column_name format a35;
col data_type format a10;
col data_length format 999999999999;
col data_default format a40 word_wrapped;
select
  table_name, column_name, data_type, DATA_LENGTH, DATA_DEFAULT
from user_tab_cols
where table_name = 'CHICAGO_DATA'
  and column_name like 'SYS%';

pause Hit enter ...

@../Lab04-IME/05_ime_usage.sql

set echo off
set timing off

