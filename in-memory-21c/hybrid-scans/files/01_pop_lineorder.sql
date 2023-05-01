@../imlogin.sql

set pages 9999
set lines 150 
set echo on

alter table lineorder no inmemory;

alter table lineorder modify partition part_1996 inmemory;

exec dbms_inmemory.populate(USER, 'LINEORDER', 'PART_1996');

set echo off

