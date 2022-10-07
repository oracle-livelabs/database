@../imlogin.sql

set pages 9999
set lines 150
set numwidth 16
set timing on
set echo on

-- Buffer Cache query with the column store disabled using a NO_INMEMORY hint
-- 

SELECT /*+ NO_INMEMORY NO_VECTOR_TRANSFORM */
       SUM(lo_extendedprice * lo_discount) revenue
FROM   lineorder l,
       date_dim d
WHERE  l.lo_orderdate = d.d_datekey
AND    d.d_date='December 24, 1996';

set echo off
set timing off

pause Hit enter ...

select * from table(dbms_xplan.display_cursor());

pause Hit enter ...

@../imstats.sql

