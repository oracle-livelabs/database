@../imlogin.sql

set pages 999
set lines 200

-- alter table lineorder no inmemory;
alter table lineorder drop column v1;
-- exec dbms_inmemory.populate(USER,'LINEORDER');

