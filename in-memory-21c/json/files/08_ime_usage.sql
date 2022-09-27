@../imlogin.sql

set pages 9999
set lines 150 

col owner          heading "Owner"          format a10;
col object_name    heading "Object"         format a20;
col partition_name heading "Partition|Name" format a20;
col column_name    heading "Column|Name"    format a15;
col t_imeu         heading "Total|IMEUs"    format 999999;
col space          heading "Used|Space(MB)" format 999,999,999;

set echo on

-- This query displays what objects are in the In-Memory Column Store

select 
  o.owner, 
  o.object_name, 
  o.subobject_name as partition_name, 
  i.column_name, 
  count(*) t_imeu, 
  sum(i.length)/1024/1024 space
from 
  v$im_imecol_cu i,
  dba_objects o
where
  i.objd = o.object_id
group by
  o.owner, 
  o.object_name, 
  o.subobject_name, 
  i.column_name;

set echo off
