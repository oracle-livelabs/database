@../imlogin.sql

set pages 9999
set lines 150
set tab off

set echo on

-- IMDS requires at least CPU_COUNT>=24 and a RESOURCE_MANAGER_PLAN
--
alter session set "_inmemory_dynamic_scans"=force;
--
set timing on
select
  max(lo_ordtotalprice) most_expensive_order,
  sum(lo_quantity) total_items
from
  LINEORDER;

set echo off
set timing off

pause Hit enter ...

select * from table(dbms_xplan.display_cursor());

pause Hit enter ...

@../imstats.sql

