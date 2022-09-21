@../imlogin.sql

set pages 999
set lines 150
set echo on
  
alter table CITY_POINTS inmemory;
  
exec dbms_inmemory.populate(USER, 'CITY_POINTS');
  
set echo off
