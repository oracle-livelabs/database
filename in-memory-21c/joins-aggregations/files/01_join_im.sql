@../imlogin.sql

set pages 9999
set lines 150
set numwidth 16
set timing on
set echo on

-- Demonstrate an in-memory join query

Select sum(lo_extendedprice * lo_discount) revenue
From   LINEORDER l, DATE_DIM d
Where  l.lo_orderdate = d.d_datekey
And    l.lo_discount between 2 and 3
And    l.lo_quantity < 24
And    d.d_date='December 24, 1996';

set echo off
set timing off

pause Hit enter ...

select * from table(dbms_xplan.display_cursor());

pause Hit enter ...

@../imstats.sql

