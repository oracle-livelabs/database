@../imlogin.sql

set pages 9999
set lines 150 

--
-- Create a most active to least active hierarchy for LINEORDER partitions
--
set serveroutput on;
declare
  v_part_date  date   := to_date('01/01/1995','MM/DD/YYYY');
  v_part_count number := 4;
  v_increment  pls_integer := 12;
  v_monthcnt   pls_integer := 0;
  v_query_cnt  pls_integer := 5;
  v_totprice   number;
begin
  for j in 1..v_part_count loop
    dbms_output.put_line('j: ' || j);
    dbms_output.put_line('data between: ' || to_char(add_months( v_part_date, v_monthcnt), 'MM/DD/YYYY') || ' and ' ||
      to_char( add_months( v_part_date + 30, v_monthcnt + 11), 'MM/DD/YYYY') );
    --
    for h in 1..(j * v_query_cnt) loop
      dbms_output.put_line('Query count h: ' || h || ' for '|| to_char( add_months( v_part_date, v_monthcnt ), 'MM/DD/YYYY' ) );
      select sum(lo_ordtotalprice) into v_totprice
      from lineorder lo
      where lo_orderdate between add_months( v_part_date, v_monthcnt ) and add_months( v_part_date + 30, v_monthcnt + 11 );
    end loop;
    --
    v_monthcnt := v_monthcnt + v_increment;
  end loop;
end;
/
--
set echo on
exec dbms_ilm.flush_all_segments;
set echo off

