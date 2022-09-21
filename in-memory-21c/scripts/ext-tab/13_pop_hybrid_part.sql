@../imlogin.sql

set pages 9999
set lines 150

set timing on
set echo on

alter table ext_cust_part no inmemory;

alter table EXT_CUST_HYBRID_PART inmemory;

exec dbms_inmemory.populate(USER,'EXT_CUST_HYBRID_PART');

set echo off
set timing off
