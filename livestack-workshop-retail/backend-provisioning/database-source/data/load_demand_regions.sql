/*
 * load_demand_regions.sql
 * Seed data for DEMAND_REGIONS table
 *
 * WHY THIS WAS EMPTY:
 * The demand_regions table was designed in 05_spatial.sql (schema creation)
 * but this INSERT script was never written and never included in load_all_data.sql.
 * The table requires SDO_GEOMETRY polygon boundaries for each US metro region —
 * these are simple rectangular bounding-box polygons approximating each metro area.
 *
 * demand_regions captures geographic market segments with:
 *   - SDO_GEOMETRY boundary polygon (WGS84 / SRID 4326)
 *   - population, avg_income, social_density
 *   - demand_index (0-100, Oracle AI-scored)
 *
 * Used by: Demand Forecasting page, Fulfillment Map heat overlays
 *
 * Run after 05_spatial.sql schema creation and after customers are loaded.
 */

SET SERVEROUTPUT ON
SET DEFINE OFF

PROMPT Loading demand regions...

-- Helper: SDO polygon from bounding box (lon_min, lat_min, lon_max, lat_max)
-- SDO_GEOMETRY type 2003 = 2D polygon
-- Exterior ring winding: counter-clockwise in WGS84

INSERT INTO demand_regions (region_name, region_type, boundary, population, avg_income, social_density, demand_index)
VALUES (
  'New York Metro', 'metro',
  SDO_GEOMETRY(
    2003, 4326, NULL,
    SDO_ELEM_INFO_ARRAY(1, 1003, 1),
    SDO_ORDINATE_ARRAY(
      -74.3, 40.4,   -- SW
      -73.6, 40.4,   -- SE
      -73.6, 41.0,   -- NE
      -74.3, 41.0,   -- NW
      -74.3, 40.4    -- close
    )
  ),
  20140000, 82000, 18.4, 91
);

INSERT INTO demand_regions (region_name, region_type, boundary, population, avg_income, social_density, demand_index)
VALUES (
  'Los Angeles Basin', 'metro',
  SDO_GEOMETRY(
    2003, 4326, NULL,
    SDO_ELEM_INFO_ARRAY(1, 1003, 1),
    SDO_ORDINATE_ARRAY(
      -118.7, 33.7,
      -117.6, 33.7,
      -117.6, 34.3,
      -118.7, 34.3,
      -118.7, 33.7
    )
  ),
  13200000, 68000, 22.1, 87
);

INSERT INTO demand_regions (region_name, region_type, boundary, population, avg_income, social_density, demand_index)
VALUES (
  'Chicago Metro', 'metro',
  SDO_GEOMETRY(
    2003, 4326, NULL,
    SDO_ELEM_INFO_ARRAY(1, 1003, 1),
    SDO_ORDINATE_ARRAY(
      -88.4, 41.4,
      -87.5, 41.4,
      -87.5, 42.2,
      -88.4, 42.2,
      -88.4, 41.4
    )
  ),
  9500000, 65000, 14.7, 78
);

INSERT INTO demand_regions (region_name, region_type, boundary, population, avg_income, social_density, demand_index)
VALUES (
  'Dallas-Fort Worth', 'metro',
  SDO_GEOMETRY(
    2003, 4326, NULL,
    SDO_ELEM_INFO_ARRAY(1, 1003, 1),
    SDO_ORDINATE_ARRAY(
      -97.5, 32.5,
      -96.5, 32.5,
      -96.5, 33.2,
      -97.5, 33.2,
      -97.5, 32.5
    )
  ),
  7700000, 63000, 13.2, 74
);

INSERT INTO demand_regions (region_name, region_type, boundary, population, avg_income, social_density, demand_index)
VALUES (
  'Houston Metro', 'metro',
  SDO_GEOMETRY(
    2003, 4326, NULL,
    SDO_ELEM_INFO_ARRAY(1, 1003, 1),
    SDO_ORDINATE_ARRAY(
      -95.8, 29.4,
      -94.9, 29.4,
      -94.9, 30.2,
      -95.8, 30.2,
      -95.8, 29.4
    )
  ),
  7200000, 60000, 12.8, 71
);

INSERT INTO demand_regions (region_name, region_type, boundary, population, avg_income, social_density, demand_index)
VALUES (
  'Washington DC Metro', 'metro',
  SDO_GEOMETRY(
    2003, 4326, NULL,
    SDO_ELEM_INFO_ARRAY(1, 1003, 1),
    SDO_ORDINATE_ARRAY(
      -77.5, 38.6,
      -76.8, 38.6,
      -76.8, 39.1,
      -77.5, 39.1,
      -77.5, 38.6
    )
  ),
  6400000, 88000, 16.5, 83
);

INSERT INTO demand_regions (region_name, region_type, boundary, population, avg_income, social_density, demand_index)
VALUES (
  'Miami-South Florida', 'metro',
  SDO_GEOMETRY(
    2003, 4326, NULL,
    SDO_ELEM_INFO_ARRAY(1, 1003, 1),
    SDO_ORDINATE_ARRAY(
      -80.5, 25.5,
      -80.0, 25.5,
      -80.0, 26.3,
      -80.5, 26.3,
      -80.5, 25.5
    )
  ),
  6200000, 55000, 19.3, 80
);

INSERT INTO demand_regions (region_name, region_type, boundary, population, avg_income, social_density, demand_index)
VALUES (
  'Philadelphia Metro', 'metro',
  SDO_GEOMETRY(
    2003, 4326, NULL,
    SDO_ELEM_INFO_ARRAY(1, 1003, 1),
    SDO_ORDINATE_ARRAY(
      -75.5, 39.8,
      -74.9, 39.8,
      -74.9, 40.2,
      -75.5, 40.2,
      -75.5, 39.8
    )
  ),
  6100000, 67000, 11.9, 69
);

INSERT INTO demand_regions (region_name, region_type, boundary, population, avg_income, social_density, demand_index)
VALUES (
  'Atlanta Metro', 'metro',
  SDO_GEOMETRY(
    2003, 4326, NULL,
    SDO_ELEM_INFO_ARRAY(1, 1003, 1),
    SDO_ORDINATE_ARRAY(
      -84.8, 33.5,
      -84.0, 33.5,
      -84.0, 34.2,
      -84.8, 34.2,
      -84.8, 33.5
    )
  ),
  6100000, 62000, 15.6, 76
);

INSERT INTO demand_regions (region_name, region_type, boundary, population, avg_income, social_density, demand_index)
VALUES (
  'Phoenix Metro', 'metro',
  SDO_GEOMETRY(
    2003, 4326, NULL,
    SDO_ELEM_INFO_ARRAY(1, 1003, 1),
    SDO_ORDINATE_ARRAY(
      -112.6, 33.2,
      -111.6, 33.2,
      -111.6, 33.8,
      -112.6, 33.8,
      -112.6, 33.2
    )
  ),
  5000000, 58000, 11.4, 67
);

INSERT INTO demand_regions (region_name, region_type, boundary, population, avg_income, social_density, demand_index)
VALUES (
  'Bay Area (SF)', 'metro',
  SDO_GEOMETRY(
    2003, 4326, NULL,
    SDO_ELEM_INFO_ARRAY(1, 1003, 1),
    SDO_ORDINATE_ARRAY(
      -122.6, 37.2,
      -121.7, 37.2,
      -121.7, 38.0,
      -122.6, 38.0,
      -122.6, 37.2
    )
  ),
  4700000, 112000, 24.7, 95
);

INSERT INTO demand_regions (region_name, region_type, boundary, population, avg_income, social_density, demand_index)
VALUES (
  'Seattle Metro', 'metro',
  SDO_GEOMETRY(
    2003, 4326, NULL,
    SDO_ELEM_INFO_ARRAY(1, 1003, 1),
    SDO_ORDINATE_ARRAY(
      -122.5, 47.3,
      -121.9, 47.3,
      -121.9, 47.9,
      -122.5, 47.9,
      -122.5, 47.3
    )
  ),
  4100000, 91000, 20.3, 88
);

INSERT INTO demand_regions (region_name, region_type, boundary, population, avg_income, social_density, demand_index)
VALUES (
  'Boston Metro', 'metro',
  SDO_GEOMETRY(
    2003, 4326, NULL,
    SDO_ELEM_INFO_ARRAY(1, 1003, 1),
    SDO_ORDINATE_ARRAY(
      -71.5, 42.1,
      -70.8, 42.1,
      -70.8, 42.6,
      -71.5, 42.6,
      -71.5, 42.1
    )
  ),
  4900000, 85000, 17.8, 84
);

INSERT INTO demand_regions (region_name, region_type, boundary, population, avg_income, social_density, demand_index)
VALUES (
  'Denver Metro', 'metro',
  SDO_GEOMETRY(
    2003, 4326, NULL,
    SDO_ELEM_INFO_ARRAY(1, 1003, 1),
    SDO_ORDINATE_ARRAY(
      -105.1, 39.5,
      -104.6, 39.5,
      -104.6, 40.0,
      -105.1, 40.0,
      -105.1, 39.5
    )
  ),
  2900000, 72000, 13.9, 73
);

INSERT INTO demand_regions (region_name, region_type, boundary, population, avg_income, social_density, demand_index)
VALUES (
  'Austin Metro', 'metro',
  SDO_GEOMETRY(
    2003, 4326, NULL,
    SDO_ELEM_INFO_ARRAY(1, 1003, 1),
    SDO_ORDINATE_ARRAY(
      -97.9, 30.1,
      -97.4, 30.1,
      -97.4, 30.6,
      -97.9, 30.6,
      -97.9, 30.1
    )
  ),
  2300000, 79000, 21.5, 89
);

INSERT INTO demand_regions (region_name, region_type, boundary, population, avg_income, social_density, demand_index)
VALUES (
  'Pacific Northwest', 'region',
  SDO_GEOMETRY(
    2003, 4326, NULL,
    SDO_ELEM_INFO_ARRAY(1, 1003, 1),
    SDO_ORDINATE_ARRAY(
      -124.5, 42.0,
      -116.0, 42.0,
      -116.0, 49.0,
      -124.5, 49.0,
      -124.5, 42.0
    )
  ),
  9800000, 74000, 16.2, 77
);

INSERT INTO demand_regions (region_name, region_type, boundary, population, avg_income, social_density, demand_index)
VALUES (
  'Sun Belt South', 'region',
  SDO_GEOMETRY(
    2003, 4326, NULL,
    SDO_ELEM_INFO_ARRAY(1, 1003, 1),
    SDO_ORDINATE_ARRAY(
      -100.0, 25.0,
      -80.0,  25.0,
      -80.0,  33.0,
      -100.0, 33.0,
      -100.0, 25.0
    )
  ),
  38000000, 56000, 10.8, 65
);

INSERT INTO demand_regions (region_name, region_type, boundary, population, avg_income, social_density, demand_index)
VALUES (
  'Great Lakes Midwest', 'region',
  SDO_GEOMETRY(
    2003, 4326, NULL,
    SDO_ELEM_INFO_ARRAY(1, 1003, 1),
    SDO_ORDINATE_ARRAY(
      -92.0, 40.5,
      -80.5, 40.5,
      -80.5, 47.5,
      -92.0, 47.5,
      -92.0, 40.5
    )
  ),
  26000000, 60000, 9.3, 60
);

INSERT INTO demand_regions (region_name, region_type, boundary, population, avg_income, social_density, demand_index)
VALUES (
  'Mountain West', 'region',
  SDO_GEOMETRY(
    2003, 4326, NULL,
    SDO_ELEM_INFO_ARRAY(1, 1003, 1),
    SDO_ORDINATE_ARRAY(
      -116.0, 31.0,
      -104.0, 31.0,
      -104.0, 49.0,
      -116.0, 49.0,
      -116.0, 31.0
    )
  ),
  12000000, 64000, 11.1, 63
);

INSERT INTO demand_regions (region_name, region_type, boundary, population, avg_income, social_density, demand_index)
VALUES (
  'Northeast Corridor', 'region',
  SDO_GEOMETRY(
    2003, 4326, NULL,
    SDO_ELEM_INFO_ARRAY(1, 1003, 1),
    SDO_ORDINATE_ARRAY(
      -77.5, 37.5,
      -69.8, 37.5,
      -69.8, 45.0,
      -77.5, 45.0,
      -77.5, 37.5
    )
  ),
  55000000, 78000, 17.6, 86
);

COMMIT;
PROMPT Demand regions loaded: 20

SELECT 'demand_regions seeded: ' || COUNT(*) || ' rows' AS status FROM demand_regions;
