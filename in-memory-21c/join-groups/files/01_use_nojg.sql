@../imlogin.sql

set pages 9999
set lines 150
set numwidth 16

set timing on
set echo on

-- In-Memory Column Store query

select   /*+ NO_VECTOR_TRANSFORM monitor */
  d.d_year, sum(l.lo_revenue) rev
from
   lineorder l,
   date_dim d,
   part p,
   supplier s
where
   l.lo_orderdate = d.d_datekey
   and l.lo_partkey = p.p_partkey
   and l.lo_suppkey = s.s_suppkey
group by
  d.d_year;

set echo off
set timing off

