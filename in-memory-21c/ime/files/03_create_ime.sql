@../imlogin.sql

set pages 9999
set lines 150

set echo on

-- Create In-Memory Column Expression

alter table lineorder no inmemory;
alter table lineorder add v1 invisible as (lo_ordtotalprice - (lo_ordtotalprice*(lo_discount/100)) + lo_tax);
alter table lineorder inmemory;
select count(*) from lineorder;

