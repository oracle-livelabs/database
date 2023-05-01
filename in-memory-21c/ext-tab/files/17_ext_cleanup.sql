@../imlogin.sql

set pages 9999
set lines 150

set echo on

alter table ext_cust no inmemory;
alter table ext_cust_part no inmemory;
alter table EXT_CUST_HYBRID_PART no inmemory;

drop table ext_cust purge;
drop table ext_cust_part purge;
drop table EXT_CUST_HYBRID_PART purge;

set echo off

