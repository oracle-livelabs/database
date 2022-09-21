@../imlogin.sql

set pages 9999
set lines 150

set timing on
set echo on
set numwidth 20

-- In-Memory Column Store query

Select lo_shipmode, sum(lo_ordtotalprice),
       sum(lo_ordtotalprice - (lo_ordtotalprice*(lo_discount/100)) + lo_tax) discount_price
From   LINEORDER
group by
  lo_shipmode;

set echo off
set timing off

pause Hit enter ...

select * from table(dbms_xplan.display_cursor());

pause Hit enter ...

@../imstats.sql

