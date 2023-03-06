@../imlogin.sql

set pages 9999
set lines 150

set timing on
set echo on
set numwidth 20

-- In-Memory query with In-Memory Aggregation enabled

select d.d_year, c.c_nation, sum(lo_revenue - lo_supplycost) profit
from   LINEORDER l, DATE_DIM d, PART p, SUPPLIER s, CUSTOMER C
where  l.lo_orderdate = d.d_datekey
and    l.lo_partkey   = p.p_partkey
and    l.lo_suppkey   = s.s_suppkey
and    l.lo_custkey   = c.c_custkey
and    s.s_region     = 'AMERICA'
and    c.c_region     = 'AMERICA'
group by d.d_year, c.c_nation
order by d.d_year, c.c_nation;

set echo off
set timing off

pause Hit enter ...

select * from table(dbms_xplan.display_cursor());

