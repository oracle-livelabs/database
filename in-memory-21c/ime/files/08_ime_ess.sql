@../imlogin.sql

set pages 9999
set lines 150
set numwidth 25
set trimspool on
set tab off

set echo on

-- Expression Statistics Store query

col owner format a6;
col table_name format a15;
col expression_text format a70;
col evaluation_count format 9999999999999999;

select
--  owner,
  table_name,
--  expression_id,
  evaluation_count,
  fixed_cost,
  expression_text
from
  dba_expression_statistics
where
  owner = 'SSB' and
  table_name = 'LINEORDER' and
  snapshot = 'LATEST'
order by
  evaluation_count desc;

--
-- Use the following to capture IM Expressions:
-- dbms_inmemory_admin.ime_capture_expressions('CURRENT');
--
set echo off

