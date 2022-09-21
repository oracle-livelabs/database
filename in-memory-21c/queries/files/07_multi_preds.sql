@../imlogin.sql

set pages 9999
set lines 150

set timing on
set echo on

-- In-Memory query

select  lo_orderkey, lo_custkey, lo_revenue
from    LINEORDER
where    lo_custkey = 5641
and      lo_shipmode = 'SHIP'
and      lo_orderpriority = '5-LOW';

set echo off
set timing off

pause Hit enter ...

select * from table(dbms_xplan.display_cursor());

pause Hit enter ...

@../imstats.sql

