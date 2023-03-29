@../imlogin.sql

set pages 9999
set lines 150
set echo on

-- This script will create Join Groups in the In-Memory Column Store

alter table lineorder no inmemory;
alter table part      no inmemory;
alter table supplier  no inmemory;
alter table date_dim  no inmemory;

CREATE INMEMORY JOIN GROUP lineorder_jg1 ( lineorder(lo_orderdate), date_dim(d_datekey));
CREATE INMEMORY JOIN GROUP lineorder_jg2 ( lineorder(lo_partkey), part(p_partkey));
CREATE INMEMORY JOIN GROUP lineorder_jg3 ( lineorder(lo_suppkey), supplier(s_suppkey));

alter table LINEORDER inmemory;
alter table PART      inmemory;
alter table SUPPLIER  inmemory;
alter table DATE_DIM  inmemory;

select /*+ full(LINEORDER) noparallel(LINEORDER) */ count(*) from LINEORDER;     
select /*+ full(PART) noparallel(PART) */ count(*) from PART;                    
select /*+ full(CUSTOMER) noparallel(CUSTOMER) */ count(*) from CUSTOMER;        
select /*+ full(SUPPLIER) noparallel(SUPPLIER) */ count(*) from SUPPLIER;        
select /*+ full(DATE_DIM) noparallel(DATE_DIM) */ count(*) from DATE_DIM; 

set echo off

