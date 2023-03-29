@../imlogin.sql

set pages 999
set lines 150
set echo on
  
alter table CHICAGO_DATA inmemory;
  
exec dbms_inmemory.populate(USER, 'CHICAGO_DATA');
  
set echo off
