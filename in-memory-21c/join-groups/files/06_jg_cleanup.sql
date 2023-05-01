@../imlogin.sql

set pages 999
set lines 200

alter table lineorder no inmemory;
alter table part      no inmemory;
alter table supplier  no inmemory;
alter table date_dim  no inmemory;

DROP INMEMORY JOIN GROUP lineorder_jg1;
DROP INMEMORY JOIN GROUP lineorder_jg2;
DROP INMEMORY JOIN GROUP lineorder_jg3;

alter table LINEORDER inmemory;
alter table PART      inmemory;
alter table SUPPLIER  inmemory;
alter table DATE_DIM  inmemory;

exec dbms_inmemory.populate(USER,'LINEORDER');
exec dbms_inmemory.populate(USER,'PART');
exec dbms_inmemory.populate(USER,'SUPPLIER');
exec dbms_inmemory.populate(USER,'DATE_DIM');
