@../imlogin.sql

set pages 999
set lines 150
set echo on
  
alter table CHICAGO_DATA no inmemory;

show parameter max_string_size

show parameter inmemory_expression

show parameter inmemory_virtual_columns

pause Hit enter ...

ALTER TABLE CHICAGO_DATA INMEMORY TEXT (description);

alter table CHICAGO_DATA inmemory;
  
exec dbms_inmemory.populate(USER, 'CHICAGO_DATA');
  
set echo off
