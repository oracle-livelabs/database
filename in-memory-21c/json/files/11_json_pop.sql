@../imlogin.sql

set pages 999
set lines 150
set echo on

alter table j_purchaseorder no inmemory;
  
alter table json_purchaseorder inmemory;
  
exec dbms_inmemory.populate(USER, 'JSON_PURCHASEORDER');
  
set echo off
