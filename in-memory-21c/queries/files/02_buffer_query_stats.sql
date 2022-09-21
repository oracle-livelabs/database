@../imlogin.sql

set pages 9999
set lines 150

set timing on
set echo on

-- Buffer Cache query with the column store disabled via NO_INMEMORY hint 

select /*+ NO_INMEMORY */
  max(lo_ordtotalprice) most_expensive_order,
  sum(lo_quantity) total_items
from LINEORDER;

set echo off
set timing off

pause Hit enter ...

select * from table(dbms_xplan.display_cursor());

pause Hit enter ...

@../imstats.sql

