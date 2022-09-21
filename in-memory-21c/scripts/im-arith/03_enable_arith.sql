@../imlogin.sql

set pages 9999
set lines 150
set echo on

-- This script will enable In-Memory optimized arithmetic

alter table lineorder no inmemory;
alter table part      no inmemory;
alter table supplier  no inmemory;
alter table date_dim  no inmemory;

alter system set inmemory_optimized_arithmetic = 'ENABLE' scope=both;

alter table LINEORDER inmemory memcompress for query low;
alter table PART      inmemory memcompress for query low;
alter table SUPPLIER  inmemory memcompress for query low;
alter table DATE_DIM  inmemory memcompress for query low;

select /*+ full(LINEORDER) noparallel(LINEORDER) */ count(*) from LINEORDER;     
select /*+ full(PART) noparallel(PART) */ count(*) from PART;                    
select /*+ full(CUSTOMER) noparallel(CUSTOMER) */ count(*) from CUSTOMER;        
select /*+ full(SUPPLIER) noparallel(SUPPLIER) */ count(*) from SUPPLIER;        
select /*+ full(DATE_DIM) noparallel(DATE_DIM) */ count(*) from DATE_DIM; 

set echo off

