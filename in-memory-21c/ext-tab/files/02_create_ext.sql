@../imlogin.sql

set pages 9999
set lines 150

set echo on

-- Create external table 

drop table ext_cust;

create table ext_cust
( custkey number, name varchar2(25), address varchar2(26), city varchar2(24), nation varchar2(19) )
organization external
( type oracle_loader
  default directory ext_dir
  access parameters (
    records delimited by newline
    fields terminated by '%'
    missing field values are null
    ( custkey, name, address, city, nation ) )
  location ('ext_cust.csv') )
reject limit unlimited;

set lines 80
desc ext_cust

set echo off

