@../imlogin.sql

set pages 9999
set lines 150 
set echo on

-- This example assumes that the LINEORDER partition PART_1994 has not been accessed in the last 30 seconds

alter table lineorder ilm delete_all;
--
-- NOTE: This policy uses 30 days to represent 30 seconds
--
alter table lineorder ilm add policy no inmemory after 30 days of no access;

set echo off

pause Hit enter ...

col policy_name    format a11;
col object_owner   heading 'OWNER' format a10;
col object_name    format a15;
col object_type    format a15;
col inherited_from format a20;
col enabled        format a8;
col deleted        format a8;
col action_clause  format a20;

set echo on

select policy_name, object_owner, object_name, object_type, inherited_from, enabled, deleted 
from user_ilmobjects;

pause Hit enter ...

select policy_name, action_type, scope, compression_level, condition_type, condition_days,
  policy_subtype, action_clause 
from user_ilmdatamovementpolicies;

set echo off

