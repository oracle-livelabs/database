@../imlogin.sql

set pages 9999
set lines 150
set echo on

-- Enable tables for in-memory

alter table LINEORDER inmemory;
alter table PART inmemory;
alter table CUSTOMER inmemory;
alter table SUPPLIER inmemory;
alter table DATE_DIM inmemory;

set echo off
