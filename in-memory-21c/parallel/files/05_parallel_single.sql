@../imlogin.sql

set pages 9999
set lines 150
set tab off

set echo on

alter session set parallel_degree_policy=auto;

set timing on
select 
  max(lo_ordtotalprice) most_expensive_order,
  sum(lo_quantity) total_items
from LINEORDER;
set timing off
set echo off

pause Hit enter ...

select * from table(dbms_xplan.display_cursor());

