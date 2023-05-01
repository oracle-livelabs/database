@../imlogin.sql

set pages 9999
set lines 150
set tab off
set echo off

-- Heat Map query

exec dbms_ilm.flush_all_segments;

col owner           format a10;
col object_name     format a20;
col subobject_name  format a15;
col track_time      format a16;
col segment_write   heading 'SEG|WRITE'       format a10;
col segment_read    heading 'SEG|READ'        format a10;
col full_scan       heading 'FULL|SCAN'       format a10;
col lookup_scan     heading 'LOOKUP|SCAN'     format a10;
col n_fts           heading 'NUM FULL|SCAN'   format 99999999;
col n_lookup        heading 'NUM LOOKUP|SCAN' format 99999999;
col n_write         heading 'NUM SEG|WRITE'   format 99999999;
--
select 
  OWNER,
  OBJECT_NAME,
  SUBOBJECT_NAME,
  to_char(TRACK_TIME,'MM/DD/YYYY HH24:MI') track_time,
  SEGMENT_WRITE,
  SEGMENT_READ,
  FULL_SCAN,
  LOOKUP_SCAN,
  N_FTS,
  N_LOOKUP,
  N_WRITE 
from
  sys."_SYS_HEAT_MAP_SEG_HISTOGRAM" h,
  dba_objects o
where
  o.object_id = h.obj#
  and track_time >= sysdate-1
order by
  track_time,
  OWNER,
  OBJECT_NAME,
  SUBOBJECT_NAME;

