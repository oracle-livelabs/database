@../imlogin.sql

-- Source: Spatial and Graph Developer's Guide
--         https://docs.oracle.com/database/121/SPATL/spatially-enabling-table.htm#SPATL1514

set echo on;

CREATE TABLE city_points (
  city_id NUMBER PRIMARY KEY,
  city_name VARCHAR2(25),
  latitude NUMBER,
  longitude NUMBER);
 
-- Original data for the table.
-- (The sample coordinates are for a random point in or near the city.)
INSERT INTO city_points (city_id, city_name, latitude, longitude)
  VALUES (1, 'Boston', 42.207905, -71.015625);
INSERT INTO city_points (city_id, city_name, latitude, longitude)
  VALUES (2, 'Raleigh', 35.634679, -78.618164);
INSERT INTO city_points (city_id, city_name, latitude, longitude)
  VALUES (3, 'San Francisco', 37.661791, -122.453613);
INSERT INTO city_points (city_id, city_name, latitude, longitude)
  VALUES (4, 'Memphis', 35.097140, -90.065918);
 
-- Add a spatial geometry column.
ALTER TABLE city_points ADD (shape SDO_GEOMETRY);

-- Update the table to populate geometry objects using existing
-- latutide and longitude coordinates.
UPDATE city_points SET shape = 
  SDO_GEOMETRY(
    2001,
    8307,
    SDO_POINT_TYPE(LONGITUDE, LATITUDE, NULL),
    NULL,
    NULL
   );

-- Update the spatial metadata.
INSERT INTO user_sdo_geom_metadata VALUES (
  'city_points',
  'SHAPE', 
  SDO_DIM_ARRAY(
    SDO_DIM_ELEMENT('Longitude',-180,180,0.5), 
    SDO_DIM_ELEMENT('Latitude',-90,90,0.5)
  ), 
  8307
);
commit;

set echo off;

