@../imlogin.sql

set pages 9999
set lines 150
set numwidth 16

set timing on
set echo on

-- Demonstrate an in-memory join query

SELECT /*+ NO_VECTOR_TRANSFORM */
      d.d_year, p.p_brand1,SUM(lo_revenue) rev
FROM   lineorder l,
       date_dim d,
       part p,
       supplier s
WHERE  l.lo_orderdate = d.d_datekey
AND    l.lo_partkey = p.p_partkey
AND    l.lo_suppkey = s.s_suppkey
AND    p.p_category = 'MFGR#12'
AND    s.s_region   = 'AMERICA'
AND    d.d_year     = 1997
GROUP  BY d.d_year,p.p_brand1;

set echo off
set timing off

pause Hit enter ...

select * from table(dbms_xplan.display_cursor());

pause Hit enter ...

@../imstats.sql

