@../imlogin.sql

set pages 9999
set lines 150

set timing on
set echo on

alter table ext_cust inmemory;

exec dbms_inmemory.populate(USER,'EXT_CUST');

set echo off
set timing off
