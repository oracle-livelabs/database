@../imlogin.sql

set pages 9999
set lines 150

set timing on
set echo on

-- In-Memory query

select sum(lo_revenue) from lineorder where LO_ORDERDATE = to_date('19960102','YYYYMMDD')
and lo_quantity > 40 and lo_shipmode = 'AIR';

set echo off
set timing off

pause Hit enter ...

select * from table(dbms_xplan.display_cursor());

pause Hit enter ...

@../imstats.sql

