@../imlogin.sql

set pages 9999
set lines 150

set timing on
set echo on

-- JSON query

col costcenter format a20;
col revenue format 999,999,999,999;
SELECT json_value(po_document, '$.CostCenter') as costcenter,
       sum(round(jt.UnitPrice * jt.Quantity)) as revenue
  FROM j_purchaseorder po,
       json_table(po.po_document
         COLUMNS (NESTED LineItems[*]
                    COLUMNS (ItemNumber NUMBER,
                             UnitPrice PATH Part.UnitPrice,
                             Quantity NUMBER)
                 )
       ) AS "JT" 
  group by json_value(po_document, '$.CostCenter')
  order by revenue desc;

set echo off
set timing off

pause Hit enter ...

select * from table(dbms_xplan.display_cursor());

pause Hit enter ...

@../imstats.sql

