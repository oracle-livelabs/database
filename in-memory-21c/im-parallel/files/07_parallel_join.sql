@../imlogin.sql

set pages 9999
set lines 150
set tab off

set echo on
--
alter session set parallel_degree_policy=auto;
alter session set parallel_min_degree=4;
--
set timing on
select   /*+ NO_VECTOR_TRANSFORM */ 
         d.d_year, p.p_brand1, sum(lo_revenue) tot_rev, count(p.p_partkey) tot_parts
from     lineorder l,
         date_dim d,
         part p,
         supplier s
where    l.lo_orderdate = d.d_datekey
and      l.lo_partkey   = p.p_partkey
and      l.lo_suppkey   = s.s_suppkey
and      p.p_category     = 'MFGR#12'
and      s.s_region     = 'AMERICA'
and      d.d_year     = 1997
group by d.d_year, p.p_brand1;

set echo off
set timing off

pause Hit enter ...

select * from table(dbms_xplan.display_cursor());

