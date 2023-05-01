@../imlogin.sql

alter table lineorder no inmemory;
alter table lineorder inmemory;
exec dbms_inmemory.populate(USER, 'LINEORDER');

