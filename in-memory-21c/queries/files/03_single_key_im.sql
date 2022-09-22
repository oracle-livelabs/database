@../imlogin.sql

set pages 9999
set lines 150

set timing on
set echo on

-- In-Memory Column Store query

select  lo_orderkey, lo_custkey, lo_revenue
from    LINEORDER
where   lo_orderkey = 5000000;

set echo off
set timing off

pause Hit enter ...

select * from table(dbms_xplan.display_cursor());

