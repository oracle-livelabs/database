@../imlogin.sql

set pages 9999
set lines 150

set echo on

-- Show query using an index based on cost

-- Enable the use of invisible indexes

alter session set optimizer_use_invisible_indexes=true;

set timing on

Select  /* With index */ lo_orderkey, lo_custkey, lo_revenue
From    LINEORDER
Where   lo_orderkey = 5000000;

set timing off

pause Hit enter ...

select * from table(dbms_xplan.display_cursor());

alter session set optimizer_use_invisible_indexes=false;

set echo off
