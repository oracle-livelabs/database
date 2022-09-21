@../imlogin.sql

set pages 9999
set lines 150
set numwidth 16

set timing on
set echo on

-- In-Memory Column Store query

select   /*+ NO_VECTOR_TRANSFORM monitor */
  d.d_year, sum(l.lo_revenue) rev
from
   lineorder l,
   date_dim d,
   part p,
   supplier s
where
   l.lo_orderdate = d.d_datekey
   and l.lo_partkey = p.p_partkey
   and l.lo_suppkey = s.s_suppkey
group by
  d.d_year;

set echo off
set timing off

pause Hit enter ...

select * from table(dbms_xplan.display_cursor());

set trimspool on
set trim on
set pages 0
set linesize 1000
set long 1000000
set longchunksize 1000000

PROMPT Join Group Usage: ;
PROMPT ----------------- ;
PROMPT ;

SELECT
  '   ' || encoding_hj.rowsource_id || ' - ' row_source_id,
    CASE
      WHEN encoding_hj.encodings_observed IS NULL
      AND encoding_hj.encodings_leveraged IS NOT NULL
      THEN
        'join group was leveraged on ' || encoding_hj.encodings_leveraged || ' process(es)'
      WHEN encoding_hj.encodings_observed IS NOT NULL
      AND encoding_hj.encodings_leveraged IS NULL
      THEN
        'join group was observed on ' || encoding_hj.encodings_observed || ' process(es)'
      WHEN encoding_hj.encodings_observed IS NOT NULL
      AND encoding_hj.encodings_leveraged IS NOT NULL
      THEN
        'join group was observed on ' || encoding_hj.encodings_observed || ' process(es)' || 
        ', join group was leveraged on ' || encoding_hj.encodings_leveraged || ' process(es)'
      ELSE
        'join group was NOT leveraged'
    END columnar_encoding_usage_info
FROM
  (SELECT EXTRACT(DBMS_SQL_MONITOR.REPORT_SQL_MONITOR_XML,
    q'#//operation[@name='HASH JOIN' and @parent_id]#') xmldata
   FROM   DUAL) hj_operation_data,
  XMLTABLE('/operation'
    PASSING hj_operation_data.xmldata
    COLUMNS
     "ROWSOURCE_ID"        VARCHAR2(5) PATH '@id',
     "ENCODINGS_LEVERAGED" VARCHAR2(5) PATH 'rwsstats/stat[@id="9"]',
     "ENCODINGS_OBSERVED"  VARCHAR2(5) PATH 'rwsstats/stat[@id="10"]') encoding_hj;

pause Hit enter ...

set pages 9999
@../imstats.sql

