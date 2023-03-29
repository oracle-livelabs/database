@../imlogin.sql

set pages 9999
set lines 150

set echo on

-- Create external table 

drop table ext_cust_part;

create table ext_cust_part
(
  custkey number,
  name varchar2(25),
  address varchar2(26),
  city varchar2(24),
  nation varchar2(19)
)
organization external
(
  type oracle_loader
  default directory ext_dir
  access parameters (
    records delimited by newline
    fields terminated by '%'
    missing field values are null
    (
      custkey,
      name,
      address,
      city,
      nation
    )
  )
)
reject limit unlimited
partition by list (nation)
(
  partition n1 values('RUSSIA')  location ('ext_cust_russia.csv'),
  partition n2 values('JAPAN')   location ('ext_cust_japan.csv'),
  partition n3 values('VIETNAM') location ('ext_cust_vietnam.csv'),
  partition n4 values('ALGERIA') location ('ext_cust_algeria.csv'),
  partition n5 values('CHINA')   location ('ext_cust_china.csv')
);

set lines 100
col table_name format a20;
col partition_name format a20;
col high_value format a15;
select TABLE_NAME, PARTITION_NAME, high_value, PARTITION_POSITION, INMEMORY
from user_tab_partitions where table_name = 'EXT_CUST_PART';

set echo off

