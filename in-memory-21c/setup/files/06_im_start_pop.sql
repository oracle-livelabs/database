@../imlogin.sql

set pages 9999
set lines 150 
set echo on

-- Access tables enabled for in-memory to start population

select /*+ full(LINEORDER) noparallel(LINEORDER) */ count(*) from LINEORDER;     
select /*+ full(PART) noparallel(PART) */ count(*) from PART;                    
select /*+ full(CUSTOMER) noparallel(CUSTOMER) */ count(*) from CUSTOMER;        
select /*+ full(SUPPLIER) noparallel(SUPPLIER) */ count(*) from SUPPLIER;        
select /*+ full(DATE_DIM) noparallel(DATE_DIM) */ count(*) from DATE_DIM; 

set echo off
