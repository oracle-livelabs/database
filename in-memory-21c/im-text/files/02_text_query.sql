@../imlogin.sql

set pages 9999
set lines 150
set timing on

-- Text query

col description format a65;
set echo on

select description, count(*) from chicago_data
where district = '009' and description like '%BATTERY%' 
group by description;

set echo off
set timing off

pause Hit enter ...

select * from table(dbms_xplan.display_cursor());

pause Hit enter ...

@../imstats.sql

