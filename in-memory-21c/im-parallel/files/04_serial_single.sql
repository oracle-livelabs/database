@../imlogin.sql

set pages 9999
set lines 150
set tab off

set timing on
set echo on

select 
  max(lo_ordtotalprice) most_expensive_order,
  sum(lo_quantity) total_items
from LINEORDER;

set echo off
set timing off

pause Hit enter ...

select * from table(dbms_xplan.display_cursor());

