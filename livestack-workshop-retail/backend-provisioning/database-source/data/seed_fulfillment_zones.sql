-- ============================================================
-- seed_fulfillment_zones.sql
-- Populates fulfillment_zones with service area polygons
-- derived from active fulfillment center locations.
--
-- Uses Oracle Spatial SDO_GEOM.SDO_BUFFER to create circular
-- coverage polygons for each zone tier around each center.
--
-- Zone tiers:
--   express  —  80 km radius,  8 h max delivery
--   standard — 250 km radius, 24 h max delivery
--   economy  — 500 km radius, 72 h max delivery
--   overnight— 160 km radius, 16 h max delivery
--
-- Run once against the Oracle AI Database 26ai instance that hosts the schema.
-- Requires: fulfillment_centers populated, SDO_GEOMETRY metadata
--           registered in USER_SDO_GEOM_METADATA for 'location'.
-- ============================================================

-- Verify spatial metadata exists before proceeding
SELECT table_name, column_name, srid
FROM   user_sdo_geom_metadata
WHERE  table_name = 'FULFILLMENT_CENTERS'
  AND  column_name = 'LOCATION';

-- Clear any existing zones (idempotent re-run)
DELETE FROM fulfillment_zones;

-- Insert SDO_BUFFER polygons for each active center × each zone type
-- SDO_BUFFER(geometry, distance, tolerance, 'unit=METER')
INSERT INTO fulfillment_zones (center_id, zone_type, max_delivery_hrs, zone_boundary)
SELECT center_id, 'express', 8,
  SDO_GEOM.SDO_BUFFER(location, 80000, 1, 'unit=METER')
FROM fulfillment_centers
WHERE is_active = 1;

INSERT INTO fulfillment_zones (center_id, zone_type, max_delivery_hrs, zone_boundary)
SELECT center_id, 'overnight', 16,
  SDO_GEOM.SDO_BUFFER(location, 160000, 1, 'unit=METER')
FROM fulfillment_centers
WHERE is_active = 1;

INSERT INTO fulfillment_zones (center_id, zone_type, max_delivery_hrs, zone_boundary)
SELECT center_id, 'standard', 24,
  SDO_GEOM.SDO_BUFFER(location, 250000, 1, 'unit=METER')
FROM fulfillment_centers
WHERE is_active = 1;

INSERT INTO fulfillment_zones (center_id, zone_type, max_delivery_hrs, zone_boundary)
SELECT center_id, 'economy', 72,
  SDO_GEOM.SDO_BUFFER(location, 500000, 1, 'unit=METER')
FROM fulfillment_centers
WHERE is_active = 1;

COMMIT;

-- Register spatial metadata for the zone_boundary column
-- (required for spatial indexing; skip if already registered)
DECLARE
  v_metadata_exists NUMBER := 0;
BEGIN
  SELECT COUNT(*)
    INTO v_metadata_exists
    FROM user_sdo_geom_metadata
   WHERE table_name = 'FULFILLMENT_ZONES'
     AND column_name = 'ZONE_BOUNDARY';

  IF v_metadata_exists = 0 THEN
    INSERT INTO user_sdo_geom_metadata (table_name, column_name, diminfo, srid)
    VALUES (
      'FULFILLMENT_ZONES',
      'ZONE_BOUNDARY',
      MDSYS.SDO_DIM_ARRAY(
        MDSYS.SDO_DIM_ELEMENT('Longitude', -180, 180, 0.005),
        MDSYS.SDO_DIM_ELEMENT('Latitude',  -90,   90, 0.005)
      ),
      4326
    );
    COMMIT;
  END IF;
END;
/

-- Create R-Tree spatial index on zone_boundary
BEGIN
  EXECUTE IMMEDIATE 'DROP INDEX idx_zones_boundary';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

CREATE INDEX idx_zones_boundary
  ON fulfillment_zones (zone_boundary)
  INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2
  PARAMETERS ('layer_gtype=POLYGON');

-- Verify results
SELECT z.zone_type,
       COUNT(*)            AS zone_count,
       MIN(z.max_delivery_hrs) AS min_hrs,
       MAX(z.max_delivery_hrs) AS max_hrs
FROM   fulfillment_zones z
GROUP  BY z.zone_type
ORDER  BY min_hrs;
