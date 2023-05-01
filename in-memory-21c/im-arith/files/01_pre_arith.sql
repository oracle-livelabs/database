@../imlogin.sql

set pages 9999
set lines 150

set timing on
set echo on

-- In-Memory query

column revenue_total format 999,999,999,999,999;
column discount_total format 999,999,999,999,999;
select sum(lo_revenue) revenue_total, 
       sum(lo_ordtotalprice - (lo_ordtotalprice*(lo_discount/100))) discount_total
from   LINEORDER;

set echo off
set timing off

pause Hit enter ...

select * from table(dbms_xplan.display_cursor());

pause Hit enter ...

@../imstats.sql

