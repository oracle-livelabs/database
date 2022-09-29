@../aim_login.sql

set pages 999
set lines 200
set echo on

alter table ssb.lineorder inmemory priority high;

exec dbms_inmemory.populate('SSB','LINEORDER');

set echo off

