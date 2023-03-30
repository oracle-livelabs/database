@../imlogin.sql

set pages 9999
set lines 150 
set echo on

alter table lineorder no inmemory;

alter table lineorder  
  no inmemory (LO_ORDERPRIORITY,LO_SHIPPRIORITY,LO_EXTENDEDPRICE,LO_ORDTOTALPRICE,
  LO_DISCOUNT,LO_REVENUE,LO_SUPPLYCOST,LO_TAX,LO_COMMITDATE);

alter table lineorder modify partition part_1996 inmemory;

exec dbms_inmemory.populate(USER, 'LINEORDER', 'PART_1996');

