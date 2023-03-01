@../imlogin.sql

set pages 9999
set lines 150 
set echo on

alter table json_purchaseorder no inmemory;

alter table j_purchaseorder drop constraint ensure_json;

set echo off
