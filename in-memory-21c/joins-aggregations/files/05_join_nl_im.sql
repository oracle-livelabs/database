@../imlogin.sql

set pages 9999
set lines 150

set echo on

-- Show the use of in-memory with a Nested Loops join

-- Enable the use of invisible indexes

alter session set optimizer_use_invisible_indexes=true;

-- Execute query 

set timing on

select /*+ NO_VECTOR_TRANSFORM INDEX(l, lineorder_i1) */
       sum(lo_extendedprice * lo_discount) revenue
from   LINEORDER l, DATE_DIM d
where  l.lo_orderdate = d.d_datekey
and    d.d_date='December 24, 1996';

set timing off

pause Hit enter ...

select * from table(dbms_xplan.display_cursor());

alter session set optimizer_use_invisible_indexes=false;

set echo off

