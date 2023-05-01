@../imlogin.sql

set pages 9999
set lines 150

set timing on
set echo on

-- External table query

select nation, count(*) from ext_cust group by nation;

set echo off
set timing off

pause Hit enter ...

select * from table(dbms_xplan.display_cursor());

pause Hit enter ...

@../imstats.sql

