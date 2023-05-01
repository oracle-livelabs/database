@../imlogin.sql

set pages 9999
set lines 150 

set echo on

show parameters heat_map

col name format a20;
select * from dba_ilmparameters;

exec dbms_ilm_admin.customize_ilm(dbms_ilm_admin.POLICY_TIME, dbms_ilm_admin.ILM_POLICY_IN_SECONDS);

select * from dba_ilmparameters;

set echo off

