@../imlogin.sql

set pages 999
set lines 150
set echo on
  
alter table j_purchaseorder inmemory;
  
exec dbms_inmemory.populate(USER, 'J_PURCHASEORDER');
  
set echo off
