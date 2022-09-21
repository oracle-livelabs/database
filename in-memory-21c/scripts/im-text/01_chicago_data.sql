@../imlogin.sql

set pages 9999
set lines 150

-- List table

col table_name   format a20;
col column_name  format a30;
col data_type    format a30;
col data_length  format 999999;
col data_default format a30 WRAPPED;
select TABLE_NAME, COLUMN_NAME, DATA_TYPE, data_length, DATA_DEFAULT from user_tab_cols 
where table_name = 'CHICAGO_DATA'
order by column_id;

