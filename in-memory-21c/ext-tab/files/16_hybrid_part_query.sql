@../imlogin.sql

set pages 9999
set lines 150

set timing on
set echo on

-- External table query

ALTER SESSION SET QUERY_REWRITE_INTEGRITY=stale_tolerated;

select nation, count(*) from EXT_CUST_HYBRID_PART group by nation;

set echo off
set timing off

pause Hit enter ...

select * from table(dbms_xplan.display_cursor());

pause Hit enter ...

@../imstats.sql

