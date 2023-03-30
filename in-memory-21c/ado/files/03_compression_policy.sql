@../imlogin.sql

set pages 9999
set lines 150 
set echo on

alter table supplier ilm delete_all;
alter table supplier inmemory memcompress for query low;
-- exec dbms_inmemory.populate(USER, 'SUPPLIER');
select count(*) from supplier;
alter table supplier ilm add policy modify inmemory memcompress for capacity high after 5 days of no modification;

set echo off

pause Hit enter ...

col policy_name    format a10;
col object_owner   format a10;
col object_name    format a20;
col object_type    format a10;
col inherited_from format a20;
col enabled        format a8;
col deleted        format a8;

set echo on

select policy_name, object_owner, object_name, object_type, inherited_from, enabled, deleted 
from user_ilmobjects;

pause Hit enter ...

select policy_name, action_type, scope, compression_level, condition_type, condition_days,
  policy_subtype, action_clause 
from user_ilmdatamovementpolicies;

set echo off

