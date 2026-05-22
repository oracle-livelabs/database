/*
 * 05_spatial.sql
 * Spatial objects for fulfillment routing and demand geography
 * Oracle 26ai — SDO_GEOMETRY, spatial indexes, routing functions
 */

-- ============================================================
-- ADD SDO_GEOMETRY COLUMNS
-- ============================================================

-- Fulfillment centers: location geometry
ALTER TABLE fulfillment_centers ADD (
    location SDO_GEOMETRY
);

-- Customers LOCATION column is defined in 01_tables.sql

-- ============================================================
-- POPULATE GEOMETRY FROM LAT/LON
-- ============================================================
UPDATE fulfillment_centers
SET location = SDO_GEOMETRY(
    2001,           -- point
    4326,           -- SRID: WGS84
    SDO_POINT_TYPE(longitude, latitude, NULL),
    NULL, NULL
)
WHERE latitude IS NOT NULL AND longitude IS NOT NULL;

UPDATE customers
SET location = SDO_GEOMETRY(
    2001, 4326,
    SDO_POINT_TYPE(longitude, latitude, NULL),
    NULL, NULL
)
WHERE latitude IS NOT NULL AND longitude IS NOT NULL;

COMMIT;

-- ============================================================
-- SPATIAL METADATA
-- ============================================================
INSERT INTO user_sdo_geom_metadata (TABLE_NAME, COLUMN_NAME, DIMINFO, SRID)
VALUES ('FULFILLMENT_CENTERS', 'LOCATION',
    SDO_DIM_ARRAY(
        SDO_DIM_ELEMENT('LON', -180, 180, 0.005),
        SDO_DIM_ELEMENT('LAT', -90, 90, 0.005)
    ), 4326);

INSERT INTO user_sdo_geom_metadata (TABLE_NAME, COLUMN_NAME, DIMINFO, SRID)
VALUES ('CUSTOMERS', 'LOCATION',
    SDO_DIM_ARRAY(
        SDO_DIM_ELEMENT('LON', -180, 180, 0.005),
        SDO_DIM_ELEMENT('LAT', -90, 90, 0.005)
    ), 4326);

COMMIT;

-- ============================================================
-- SPATIAL INDEXES
-- ============================================================
CREATE INDEX idx_fc_spatial ON fulfillment_centers(location)
    INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2;

DECLARE
    v_idx_count NUMBER;
BEGIN
    SELECT COUNT(*)
      INTO v_idx_count
      FROM user_indexes
     WHERE table_name = 'CUSTOMERS'
       AND index_name = 'IDX_CUST_SPATIAL';

    IF v_idx_count = 0 THEN
        EXECUTE IMMEDIATE 'CREATE INDEX idx_cust_spatial ON customers(location) INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2';
    END IF;
END;
/

-- ============================================================
-- FULFILLMENT ZONES (service area polygons)
-- ============================================================
CREATE TABLE fulfillment_zones (
    zone_id           NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    center_id         NUMBER NOT NULL REFERENCES fulfillment_centers(center_id),
    zone_type         VARCHAR2(30) DEFAULT 'standard'
                      CHECK (zone_type IN ('express','standard','economy','overnight')),
    max_delivery_hrs  NUMBER(5,1),
    zone_boundary     SDO_GEOMETRY,    -- polygon defining service area
    created_at        TIMESTAMP DEFAULT SYSTIMESTAMP
);

INSERT INTO user_sdo_geom_metadata (TABLE_NAME, COLUMN_NAME, DIMINFO, SRID)
VALUES ('FULFILLMENT_ZONES', 'ZONE_BOUNDARY',
    SDO_DIM_ARRAY(
        SDO_DIM_ELEMENT('LON', -180, 180, 0.005),
        SDO_DIM_ELEMENT('LAT', -90, 90, 0.005)
    ), 4326);

-- ============================================================
-- DEMAND HEATMAP REGIONS
-- ============================================================
CREATE TABLE demand_regions (
    region_id         NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    region_name       VARCHAR2(100) NOT NULL,
    region_type       VARCHAR2(30) DEFAULT 'metro'
                      CHECK (region_type IN ('metro','state','region','zip_cluster')),
    boundary          SDO_GEOMETRY,     -- polygon
    population        NUMBER(10),
    avg_income        NUMBER(10,2),
    social_density    NUMBER(8,2),      -- social posts per 1000 population
    demand_index      NUMBER(5,2) DEFAULT 50,  -- 0-100
    updated_at        TIMESTAMP DEFAULT SYSTIMESTAMP
);

INSERT INTO user_sdo_geom_metadata (TABLE_NAME, COLUMN_NAME, DIMINFO, SRID)
VALUES ('DEMAND_REGIONS', 'BOUNDARY',
    SDO_DIM_ARRAY(
        SDO_DIM_ELEMENT('LON', -180, 180, 0.005),
        SDO_DIM_ELEMENT('LAT', -90, 90, 0.005)
    ), 4326);

-- ============================================================
-- SPATIAL ROUTING FUNCTION
-- Find the N nearest fulfillment centers to a customer
-- that have the requested product in stock
-- ============================================================
CREATE OR REPLACE FUNCTION find_nearest_centers (
    p_customer_id   IN NUMBER,
    p_product_id    IN NUMBER,
    p_max_results   IN NUMBER DEFAULT 3
) RETURN SYS_REFCURSOR
AS
    v_results SYS_REFCURSOR;
BEGIN
    OPEN v_results FOR
        SELECT fc.center_id,
               fc.center_name,
               fc.city,
               fc.state_province,
               fc.center_type,
               i.quantity_on_hand,
               ROUND(SDO_GEOM.SDO_DISTANCE(
                   c.location,
                   fc.location,
                   0.005,
                   'unit=MILE'
               ), 2) AS distance_mi,
               ROUND(SDO_GEOM.SDO_DISTANCE(
                   c.location,
                   fc.location,
                   0.005,
                   'unit=MILE'
               ) / 50, 1) AS estimated_hours  -- rough estimate at 50 mph avg
        FROM customers c
        CROSS JOIN fulfillment_centers fc
        JOIN inventory i ON fc.center_id = i.center_id
                        AND i.product_id = p_product_id
        WHERE c.customer_id = p_customer_id
          AND fc.is_active = 1
          AND i.quantity_on_hand > i.quantity_reserved
        ORDER BY SDO_GEOM.SDO_DISTANCE(
            c.location, fc.location, 0.005, 'unit=MILE'
        )
        FETCH FIRST p_max_results ROWS ONLY;

    RETURN v_results;
END;
/

-- ============================================================
-- OPTIMAL FULFILLMENT: multi-item order routing
-- Finds best center(s) to fulfill an entire order,
-- balancing distance + inventory availability
-- ============================================================
CREATE OR REPLACE FUNCTION optimal_fulfillment (
    p_order_id      IN NUMBER,
    p_strategy      IN VARCHAR2 DEFAULT 'nearest'  -- 'nearest','cheapest','fastest','balanced'
) RETURN SYS_REFCURSOR
AS
    v_results SYS_REFCURSOR;
BEGIN
    OPEN v_results FOR
        WITH order_products AS (
            SELECT oi.product_id, oi.quantity
            FROM order_items oi
            WHERE oi.order_id = p_order_id
        ),
        customer_loc AS (
            SELECT c.location
            FROM orders o
            JOIN customers c ON o.customer_id = c.customer_id
            WHERE o.order_id = p_order_id
        ),
        -- Pre-compute distance as a scalar to avoid GROUP BY on SDO_GEOMETRY
        center_distances AS (
            SELECT fc.center_id,
                   fc.center_name,
                   fc.city,
                   fc.state_province,
                   ROUND(SDO_GEOM.SDO_DISTANCE(
                       cl.location, fc.location, 0.005, 'unit=MILE'
                   ), 2) AS distance_mi
            FROM fulfillment_centers fc
            CROSS JOIN customer_loc cl
            WHERE fc.is_active = 1
        ),
        center_scores AS (
            SELECT cd.center_id,
                   cd.center_name,
                   cd.city,
                   cd.state_province,
                   cd.distance_mi,
                   COUNT(DISTINCT op.product_id) AS products_available,
                   (SELECT COUNT(*) FROM order_products) AS products_needed,
                   MIN(i.quantity_on_hand - i.quantity_reserved) AS min_available
            FROM center_distances cd
            JOIN inventory i ON cd.center_id = i.center_id
            JOIN order_products op ON i.product_id = op.product_id
                                  AND (i.quantity_on_hand - i.quantity_reserved) >= op.quantity
            GROUP BY cd.center_id, cd.center_name, cd.city, cd.state_province, cd.distance_mi
        )
        SELECT center_id,
               center_name,
               city,
               state_province,
               distance_mi,
               products_available,
               products_needed,
               CASE
                   WHEN products_available = products_needed THEN 'full'
                   ELSE 'partial'
               END AS fulfillment_type,
               ROUND(
                   (products_available / products_needed * 50) +
                   (1 / (distance_mi + 1) * 50),
               2) AS optimization_score
        FROM center_scores
        ORDER BY
            CASE p_strategy
                WHEN 'nearest' THEN distance_mi
                WHEN 'balanced' THEN -1 * (
                    (products_available / products_needed * 50) +
                    (1 / (distance_mi + 1) * 50)
                )
                ELSE distance_mi
            END
        FETCH FIRST 5 ROWS ONLY;

    RETURN v_results;
END;
/

COMMIT;

SELECT 'Spatial objects created successfully' AS status FROM dual;
