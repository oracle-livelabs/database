@../imlogin.sql

set pages 999
set lines 200

alter system set inmemory_automatic_level=off;
alter table lineorder no inmemory;

@02_disable_tables.sql

