@../imlogin.sql

set pages 9999
set lines 150 

-- exec dbms_ilm_admin.customize_ilm(dbms_ilm_admin.POLICY_TIME, dbms_ilm_admin.ILM_POLICY_IN_DAYS);
select * from dba_ilmparameters;

alter table supplier no inmemory;
alter table supplier ilm delete_all;
alter table lineorder no inmemory;
alter table lineorder ilm delete_all;
-- exec dbms_ilm_admin.CLEAR_HEAT_MAP_ALL;

