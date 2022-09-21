@../imlogin.sql

set pages 9999
set lines 150

set timing on
set echo on

-- In-Memory query

Select lo_orderkey, lo_revenue
From   LINEORDER
Where  lo_revenue = (Select min(lo_revenue)
                     From LINEORDER
                     Where lo_supplycost = (Select max(lo_supplycost)
                                            From  LINEORDER
                                            Where lo_quantity > 10)
                     And lo_shipmode LIKE 'TRUCK%'
                     And lo_discount between 2 and 5
                    );

set echo off
set timing off

pause Hit enter ...

select * from table(dbms_xplan.display_cursor());

pause Hit enter ...

@../imstats.sql

