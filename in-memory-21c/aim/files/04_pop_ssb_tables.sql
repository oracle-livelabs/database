@../imlogin.sql

set pages 9999
set lines 150
set echo on

-- Enable tables for in-memory

alter table LINEORDER inmemory priority high;

exec dbms_inmemory.populate('SSB','LINEORDER');

set echo off

