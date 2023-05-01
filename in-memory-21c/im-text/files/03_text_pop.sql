@../imlogin.sql

set pages 999
set lines 150
set echo on

--
-- Unpopulate LINEORDER to make room in the IM column store
--

alter table lineorder no inmemory;
  
alter table CHICAGO_DATA inmemory;
exec dbms_inmemory.populate(USER, 'CHICAGO_DATA');
  
set echo off
