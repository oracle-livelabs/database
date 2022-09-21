@../imlogin.sql

set pages 999
set lines 200

alter table lineorder no inmemory;
DROP INMEMORY JOIN GROUP lineorder_jg1;
DROP INMEMORY JOIN GROUP lineorder_jg2;
DROP INMEMORY JOIN GROUP lineorder_jg3;
exec dbms_inmemory.populate(USER,'LINEORDER');

