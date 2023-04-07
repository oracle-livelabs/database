@../imlogin.sql

set pages 9999
set lines 150
set timing on
set echo on

-- Create spatial index

CREATE INDEX city_points_i1 ON city_points (shape)
   INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2;

-- Spatial query

SELECT city_name 
FROM city_points c 
where 
 sdo_filter(c.shape, 
            sdo_geometry(2001,8307,sdo_point_type(-122.453613,37.661791,null),null,null)
           ) = 'TRUE'; 

set echo off
set timing off

pause Hit enter ...

select * from table(dbms_xplan.display_cursor());

-- Drop spatial index

drop INDEX city_points_i1;

