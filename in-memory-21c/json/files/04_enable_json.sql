@../imlogin.sql

set pages 999
set lines 150
  
set echo on;

alter table j_purchaseorder add constraint ensure_json check (po_document is json);
  
set echo off
  
-- List table columns

col table_name   format a20;
col column_name  format a30;
col data_type    format a30;
col data_length  format 999999;
col data_default format a30 WRAPPED;
select TABLE_NAME, COLUMN_NAME, DATA_TYPE, data_length, DATA_DEFAULT from user_tab_cols
where table_name = 'J_PURCHASEORDER'
order by column_id;

-- List constraints

col constraint_name format a20;
col search_condition format a30;
select table_name, constraint_name, constraint_type, search_condition
from user_constraints
where table_name = 'J_PURCHASEORDER';

