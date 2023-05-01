@../imlogin.sql

set pages 9999
set lines 150
set echo on

-- Create external table 

drop table ext_cust_hybrid_part;

create table ext_cust_hybrid_part
(
  custkey number,
  name varchar2(25),
  address varchar2(26),
  city varchar2(24),
  nation varchar2(19)
)
external partition attributes
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
  reject limit unlimited
)
partition by list (nation)
(
  partition n1 values('RUSSIA')  external location ('ext_cust_russia.csv'),
  partition n2 values('JAPAN')   external location ('ext_cust_japan.csv'),
  partition n3 values('BULGARIA'),
  partition n4 values('NORWAY')
);

pause Hit enter ...

select nation, count(*) from EXT_CUST_HYBRID_PART group by nation;

pause Hit enter ...

insert into ext_cust_hybrid_part select * from ext_cust_bulgaria;
insert into ext_cust_hybrid_part select * from ext_cust_norway;
commit;

pause Hit enter ...

select nation, count(*) from EXT_CUST_HYBRID_PART group by nation;

set echo off

