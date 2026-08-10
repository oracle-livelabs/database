/*
 * State and Local Government LiveStack platform handoff loader
 *
 * SQLcl:
 *   sql ADMIN/<admin-password>@<service> @sled-platform-handoff-loader.sql <lluser-password> <service>
 *
 * This loader supports the seven active technical labs with a compact,
 * deterministic workshop dataset: 3 programs, 10 services, 4 access centers,
 * 6 residents, 8 service requests, and 8 resident signals. The full SLED
 * application uses a larger demonstration dataset. This loader does not create
 * Ask Data, copilot, agent, or trusted-action objects.
 */

WHENEVER SQLERROR EXIT SQL.SQLCODE
SET DEFINE ON
SET SERVEROUTPUT ON
SET FEEDBACK ON

DEFINE LLUSER_PASSWORD = '&1'
DEFINE CONNECT_IDENTIFIER = '&2'

DECLARE
  v_current_user VARCHAR2(128) := USER;
BEGIN
  IF v_current_user = 'ADMIN' THEN
    DBMS_OUTPUT.PUT_LINE('ADMIN preparation started.');
  ELSE
    RAISE_APPLICATION_ERROR(-20001, 'Run this loader from an ADMIN SQLcl session.');
  END IF;
END;
/

ALTER USER LLUSER IDENTIFIED BY &&LLUSER_PASSWORD ACCOUNT UNLOCK;
ALTER USER LLUSER QUOTA UNLIMITED ON DATA;

GRANT CREATE SESSION TO LLUSER;
GRANT CREATE TABLE TO LLUSER;
GRANT CREATE VIEW TO LLUSER;
GRANT CREATE PROCEDURE TO LLUSER;
GRANT CREATE MINING MODEL TO LLUSER;
GRANT CREATE PROPERTY GRAPH TO LLUSER;
GRANT EXECUTE ON DBMS_DATA_MINING TO LLUSER;
GRANT SELECT ON MINING MODEL ALL_MINILM_L12_V2 TO LLUSER;

CONNECT LLUSER/"&&LLUSER_PASSWORD"@"&&CONNECT_IDENTIFIER"
SET DEFINE OFF
SET SERVEROUTPUT ON
SET FEEDBACK ON

DECLARE
  v_expected_user VARCHAR2(30) := 'LLUSER';
BEGIN
  IF USER != v_expected_user THEN
    RAISE_APPLICATION_ERROR(-20002, 'DDL and seed data must run as LLUSER.');
  END IF;
  DBMS_OUTPUT.PUT_LINE('Connected as ' || USER || '.');
END;
/

BEGIN
  BEGIN
    EXECUTE IMMEDIATE 'DROP PROPERTY GRAPH influencer_network';
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -4043 THEN RAISE; END IF;
  END;

  FOR model_row IN (
    SELECT model_name
    FROM user_mining_models
    WHERE model_name IN (
      'SLED_SERVICE_DEMAND_MODEL',
      'SLED_RESIDENT_NEED_SEGMENT_MODEL',
      'SLED_SERVICE_VALUE_MODEL',
      'SLED_CASE_SIGNAL_CLUSTER_MODEL'
    )
  ) LOOP
    DBMS_DATA_MINING.DROP_MODEL(model_row.model_name);
  END LOOP;

  FOR view_row IN (
    SELECT view_name
    FROM user_views
    WHERE view_name IN (
      'SLED_PUBLIC_PROGRAMS_V','SLED_PUBLIC_SERVICES_V',
      'SLED_RESIDENT_SIGNALS_V','SLED_SIGNAL_SOURCES_V',
      'SLED_SERVICE_REQUESTS_V','SLED_SERVICE_REQUEST_LINES_V',
      'SLED_RESIDENTS_V','SLED_SERVICE_ACCESS_CENTERS_V',
      'SLED_SERVICE_CAPACITY_V','SLED_SERVICE_TASK_ROUTES_V',
      'SLED_OPERATIONS_DASHBOARD_V','OML_DEMAND_TRAINING_V',
      'OML_CUSTOMER_RFM_V','OML_COMMITMENT_VALUE_TRAINING_V',
      'OML_PRODUCT_CLUSTER_V','ORDERS_DV'
    )
  ) LOOP
    EXECUTE IMMEDIATE 'DROP VIEW ' || view_row.view_name;
  END LOOP;

  DELETE FROM user_sdo_geom_metadata
  WHERE table_name IN (
    'FULFILLMENT_CENTERS','CUSTOMERS',
    'FULFILLMENT_ZONES','DEMAND_REGIONS'
  );
  COMMIT;

  FOR table_row IN (
    SELECT table_name
    FROM user_tables
    WHERE table_name IN (
      'POST_EMBEDDINGS','PRODUCT_EMBEDDINGS',
      'BRAND_INFLUENCER_LINKS','INFLUENCER_CONNECTIONS',
      'POST_PRODUCT_MENTIONS','SHIPMENTS','FULFILLMENT_ZONES',
      'DEMAND_REGIONS','ORDER_ITEMS','ORDERS','INVENTORY',
      'SOCIAL_POSTS','INFLUENCERS','CUSTOMERS',
      'FULFILLMENT_CENTERS','PRODUCTS','BRANDS',
      'SLED_SERVICE_DEMAND_SETTINGS','SLED_RESIDENT_NEED_SETTINGS',
      'SLED_SERVICE_VALUE_SETTINGS','SLED_CASE_SIGNAL_CLUSTER_SETTINGS'
    )
  ) LOOP
    EXECUTE IMMEDIATE 'DROP TABLE ' || table_row.table_name || ' CASCADE CONSTRAINTS PURGE';
  END LOOP;
END;
/

CREATE TABLE brands (
  brand_id NUMBER PRIMARY KEY,
  brand_name VARCHAR2(120) NOT NULL,
  brand_category VARCHAR2(80),
  headquarters_city VARCHAR2(80),
  annual_revenue NUMBER(14,2),
  social_tier VARCHAR2(30),
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);

CREATE TABLE products (
  product_id NUMBER PRIMARY KEY,
  sku VARCHAR2(40) UNIQUE,
  product_name VARCHAR2(160) NOT NULL,
  description VARCHAR2(1000),
  category VARCHAR2(100),
  subcategory VARCHAR2(100),
  unit_price NUMBER(12,2),
  unit_cost NUMBER(12,2),
  weight_kg NUMBER(10,2),
  tags VARCHAR2(500),
  brand_id NUMBER REFERENCES brands(brand_id),
  is_active NUMBER(1),
  launch_date DATE,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);

CREATE TABLE fulfillment_centers (
  center_id NUMBER PRIMARY KEY,
  center_name VARCHAR2(160) NOT NULL,
  center_type VARCHAR2(30),
  address_line1 VARCHAR2(160),
  city VARCHAR2(80),
  state_province VARCHAR2(80),
  postal_code VARCHAR2(20),
  country VARCHAR2(80),
  latitude NUMBER(10,6),
  longitude NUMBER(10,6),
  capacity_units NUMBER,
  current_load_pct NUMBER(5,2),
  is_active NUMBER(1),
  operating_hours VARCHAR2(200),
  service_region_code VARCHAR2(30),
  location SDO_GEOMETRY,
  created_at TIMESTAMP
);

CREATE TABLE inventory (
  inventory_id NUMBER PRIMARY KEY,
  product_id NUMBER REFERENCES products(product_id),
  center_id NUMBER REFERENCES fulfillment_centers(center_id),
  quantity_on_hand NUMBER,
  quantity_reserved NUMBER,
  quantity_incoming NUMBER,
  reorder_point NUMBER,
  reorder_qty NUMBER,
  last_restock_date DATE,
  service_region_code VARCHAR2(30),
  updated_at TIMESTAMP
);

CREATE TABLE customers (
  customer_id NUMBER PRIMARY KEY,
  email VARCHAR2(160),
  first_name VARCHAR2(80),
  last_name VARCHAR2(80),
  city VARCHAR2(80),
  state_province VARCHAR2(80),
  postal_code VARCHAR2(20),
  country VARCHAR2(80),
  latitude NUMBER(10,6),
  longitude NUMBER(10,6),
  location SDO_GEOMETRY,
  customer_tier VARCHAR2(30),
  lifetime_value NUMBER(14,2),
  service_region_code VARCHAR2(30),
  created_at TIMESTAMP
);

CREATE TABLE orders (
  order_id NUMBER PRIMARY KEY,
  customer_id NUMBER REFERENCES customers(customer_id),
  order_status VARCHAR2(30),
  order_total NUMBER(14,2),
  shipping_cost NUMBER(12,2),
  fulfillment_center_id NUMBER REFERENCES fulfillment_centers(center_id),
  shipping_lat NUMBER(10,6),
  shipping_lon NUMBER(10,6),
  estimated_delivery TIMESTAMP,
  actual_delivery TIMESTAMP,
  social_source_id NUMBER,
  demand_score NUMBER(6,2),
  service_region_code VARCHAR2(30),
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);

CREATE TABLE order_items (
  item_id NUMBER PRIMARY KEY,
  order_id NUMBER REFERENCES orders(order_id),
  product_id NUMBER REFERENCES products(product_id),
  quantity NUMBER,
  unit_price NUMBER(12,2),
  line_total NUMBER(14,2),
  fulfilled_from NUMBER REFERENCES fulfillment_centers(center_id),
  service_region_code VARCHAR2(30)
);

CREATE TABLE influencers (
  influencer_id NUMBER PRIMARY KEY,
  handle VARCHAR2(100) UNIQUE,
  display_name VARCHAR2(160),
  platform VARCHAR2(60),
  follower_count NUMBER,
  engagement_rate NUMBER(8,4),
  influence_score NUMBER(8,2),
  niche VARCHAR2(120),
  city VARCHAR2(80),
  region VARCHAR2(80),
  service_region_code VARCHAR2(30),
  country VARCHAR2(80),
  is_verified NUMBER(1),
  created_at TIMESTAMP
);

CREATE TABLE social_posts (
  post_id NUMBER PRIMARY KEY,
  influencer_id NUMBER REFERENCES influencers(influencer_id),
  post_text VARCHAR2(2000),
  platform VARCHAR2(60),
  virality_score NUMBER(8,2),
  momentum_flag VARCHAR2(30),
  views_count NUMBER,
  likes_count NUMBER,
  shares_count NUMBER,
  comments_count NUMBER,
  sentiment_score NUMBER(8,4),
  detected_products VARCHAR2(500),
  posted_at TIMESTAMP,
  service_region_code VARCHAR2(30)
);

CREATE TABLE post_product_mentions (
  mention_id NUMBER PRIMARY KEY,
  post_id NUMBER REFERENCES social_posts(post_id),
  product_id NUMBER REFERENCES products(product_id),
  confidence_score NUMBER(8,4),
  mention_type VARCHAR2(30),
  service_region_code VARCHAR2(30)
);

CREATE TABLE shipments (
  shipment_id NUMBER PRIMARY KEY,
  order_id NUMBER REFERENCES orders(order_id),
  center_id NUMBER REFERENCES fulfillment_centers(center_id),
  carrier VARCHAR2(100),
  tracking_number VARCHAR2(100),
  ship_status VARCHAR2(30),
  distance_km NUMBER(10,2),
  estimated_hours NUMBER(10,2),
  ship_cost NUMBER(12,2),
  shipped_at TIMESTAMP,
  delivered_at TIMESTAMP,
  service_region_code VARCHAR2(30),
  created_at TIMESTAMP
);

CREATE TABLE influencer_connections (
  connection_id NUMBER PRIMARY KEY,
  from_influencer NUMBER REFERENCES influencers(influencer_id),
  to_influencer NUMBER REFERENCES influencers(influencer_id),
  connection_type VARCHAR2(30),
  strength NUMBER(4,3),
  interaction_count NUMBER,
  first_seen TIMESTAMP,
  last_interaction TIMESTAMP,
  service_region_code VARCHAR2(30)
);

CREATE TABLE brand_influencer_links (
  link_id NUMBER PRIMARY KEY,
  brand_id NUMBER REFERENCES brands(brand_id),
  influencer_id NUMBER REFERENCES influencers(influencer_id),
  relationship_type VARCHAR2(30),
  post_count NUMBER,
  avg_engagement NUMBER(8,4),
  revenue_attributed NUMBER(14,2),
  first_mention TIMESTAMP,
  last_mention TIMESTAMP,
  service_region_code VARCHAR2(30)
);

CREATE TABLE fulfillment_zones (
  zone_id NUMBER PRIMARY KEY,
  center_id NUMBER REFERENCES fulfillment_centers(center_id),
  zone_type VARCHAR2(30),
  max_delivery_hrs NUMBER(5,1),
  zone_boundary SDO_GEOMETRY,
  service_region_code VARCHAR2(30),
  created_at TIMESTAMP
);

CREATE TABLE demand_regions (
  region_id NUMBER PRIMARY KEY,
  region_name VARCHAR2(100),
  region_type VARCHAR2(30),
  boundary SDO_GEOMETRY,
  population NUMBER,
  avg_income NUMBER(12,2),
  social_density NUMBER(8,2),
  demand_index NUMBER(5,2),
  service_region_code VARCHAR2(30),
  updated_at TIMESTAMP
);

CREATE TABLE product_embeddings (
  embedding_id NUMBER PRIMARY KEY,
  product_id NUMBER REFERENCES products(product_id),
  embedding_model VARCHAR2(100),
  embedding_text CLOB,
  embedding VECTOR(384),
  created_at TIMESTAMP
);

CREATE TABLE post_embeddings (
  embedding_id NUMBER PRIMARY KEY,
  post_id NUMBER REFERENCES social_posts(post_id),
  service_region_code VARCHAR2(30),
  embedding_model VARCHAR2(100),
  embedding_text CLOB,
  embedding VECTOR(384),
  created_at TIMESTAMP
);

INSERT INTO brands (
  brand_id, brand_name, brand_category, headquarters_city,
  annual_revenue, social_tier, created_at, updated_at
) VALUES
  (1, 'Benefits Eligibility', 'Health and Human Services', 'Denver', 25000000, 'statewide', TIMESTAMP '2026-01-10 09:00:00', TIMESTAMP '2026-06-01 09:00:00'),
  (2, 'Public Works', 'Infrastructure', 'Denver', 18000000, 'statewide', TIMESTAMP '2026-01-10 09:00:00', TIMESTAMP '2026-06-01 09:00:00'),
  (3, 'Emergency and Community Support', 'Resident Support', 'Pueblo', 12000000, 'regional', TIMESTAMP '2026-01-10 09:00:00', TIMESTAMP '2026-06-01 09:00:00');

INSERT INTO products (
  product_id, sku, product_name, description, category, subcategory,
  unit_price, unit_cost, weight_kg, tags, brand_id, is_active,
  launch_date, created_at, updated_at
) VALUES
  (1, 'SVC-001', 'Medicaid Eligibility Review', 'Review benefits eligibility and correct application errors before service deadlines.', 'Benefits and Health', 'Eligibility', 12500, 7500, 1, 'benefits,eligibility,review', 1, 1, DATE '2025-01-01', TIMESTAMP '2026-01-10 09:00:00', TIMESTAMP '2026-06-01 09:00:00'),
  (2, 'SVC-002', 'SNAP Application Support', 'Help residents complete food-assistance applications and resolve missing information.', 'Benefits and Health', 'Food Assistance', 5000, 3000, 1, 'snap,benefits,application', 1, 1, DATE '2025-01-01', TIMESTAMP '2026-01-10 09:00:00', TIMESTAMP '2026-06-01 09:00:00'),
  (3, 'SVC-003', 'Benefits Appointment Scheduling', 'Schedule caseworker appointments for eligibility and benefit renewal reviews.', 'Benefits and Health', 'Appointments', 8000, 4200, 1, 'benefits,appointment,backlog', 1, 1, DATE '2025-01-01', TIMESTAMP '2026-01-10 09:00:00', TIMESTAMP '2026-06-01 09:00:00'),
  (4, 'SVC-004', 'Building Permit Inspection', 'Coordinate building permit inspections and publish the current service window.', 'Permits and Inspections', 'Inspection', 4500, 2600, 1, 'permit,inspection,scheduling', 2, 1, DATE '2025-01-01', TIMESTAMP '2026-01-10 09:00:00', TIMESTAMP '2026-06-01 09:00:00'),
  (5, 'SVC-005', 'Road Repair Request', 'Route pothole and road repair requests to public works crews.', 'Public Works', 'Roads', 6000, 3500, 1, 'roads,repair,dispatch', 2, 1, DATE '2025-01-01', TIMESTAMP '2026-01-10 09:00:00', TIMESTAMP '2026-06-01 09:00:00'),
  (6, 'SVC-006', 'Emergency Shelter Referral', 'Connect residents with emergency shelter and crisis support partners.', 'Emergency Services', 'Shelter', 3000, 1900, 1, 'emergency,shelter,referral', 3, 1, DATE '2025-01-01', TIMESTAMP '2026-01-10 09:00:00', TIMESTAMP '2026-06-01 09:00:00'),
  (7, 'SVC-007', 'Housing Assistance Intake', 'Accept housing assistance requests and coordinate eligibility documentation.', 'Housing', 'Intake', 11000, 6500, 1, 'housing,benefits,intake', 3, 1, DATE '2025-01-01', TIMESTAMP '2026-01-10 09:00:00', TIMESTAMP '2026-06-01 09:00:00'),
  (8, 'SVC-008', 'Child Care Subsidy', 'Support child care subsidy eligibility and case review.', 'Family Services', 'Subsidy', 5500, 3200, 1, 'child care,benefits,eligibility', 1, 1, DATE '2025-01-01', TIMESTAMP '2026-01-10 09:00:00', TIMESTAMP '2026-06-01 09:00:00'),
  (9, 'SVC-009', 'Water Service Restoration', 'Coordinate urgent public water restoration and resident notifications.', 'Public Works', 'Utilities', 7000, 4100, 1, 'water,restoration,urgent', 2, 1, DATE '2025-01-01', TIMESTAMP '2026-01-10 09:00:00', TIMESTAMP '2026-06-01 09:00:00'),
  (10, 'SVC-010', 'Senior Transportation', 'Arrange transportation for older residents attending public-service appointments.', 'Mobility', 'Transportation', 2000, 1200, 1, 'senior,transport,appointment', 3, 1, DATE '2025-01-01', TIMESTAMP '2026-01-10 09:00:00', TIMESTAMP '2026-06-01 09:00:00');

INSERT INTO fulfillment_centers (
  center_id, center_name, center_type, address_line1, city,
  state_province, postal_code, country, latitude, longitude,
  capacity_units, current_load_pct, is_active, operating_hours,
  service_region_code, location, created_at
) VALUES
  (1, 'Denver Human Services Hub', 'warehouse', '1200 Broadway', 'Denver', 'Colorado', '80203', 'United States', 39.7392, -104.9903, 300, 82, 1, 'Mon-Fri 08:00-17:00', 'FRONT_RANGE', SDO_GEOMETRY(2001,4326,SDO_POINT_TYPE(-104.9903,39.7392,NULL),NULL,NULL), TIMESTAMP '2026-01-10 09:00:00'),
  (2, 'Grand Junction Regional Service Center', 'distribution', '510 29 Road', 'Grand Junction', 'Colorado', '81504', 'United States', 39.0639, -108.5506, 120, 91, 1, 'Mon-Fri 08:00-17:00', 'WESTERN_SLOPE', SDO_GEOMETRY(2001,4326,SDO_POINT_TYPE(-108.5506,39.0639,NULL),NULL,NULL), TIMESTAMP '2026-01-10 09:00:00'),
  (3, 'Pueblo Community Access Center', 'micro', '215 W 10th Street', 'Pueblo', 'Colorado', '81003', 'United States', 38.2544, -104.6091, 140, 74, 1, 'Mon-Fri 08:00-17:00', 'SOUTHERN_COLORADO', SDO_GEOMETRY(2001,4326,SDO_POINT_TYPE(-104.6091,38.2544,NULL),NULL,NULL), TIMESTAMP '2026-01-10 09:00:00'),
  (4, 'Fort Collins Resident Service Center', 'store', '200 W Oak Street', 'Fort Collins', 'Colorado', '80521', 'United States', 40.5853, -105.0844, 160, 68, 1, 'Mon-Fri 08:00-17:00', 'FRONT_RANGE', SDO_GEOMETRY(2001,4326,SDO_POINT_TYPE(-105.0844,40.5853,NULL),NULL,NULL), TIMESTAMP '2026-01-10 09:00:00');

INSERT INTO customers (
  customer_id, email, first_name, last_name, city, state_province,
  postal_code, country, latitude, longitude, location, customer_tier,
  lifetime_value, service_region_code, created_at
) VALUES
  (1, 'elena.garcia@example.gov', 'Elena', 'Garcia', 'Grand Junction', 'Colorado', '81501', 'United States', 39.0700, -108.5700, SDO_GEOMETRY(2001,4326,SDO_POINT_TYPE(-108.5700,39.0700,NULL),NULL,NULL), 'priority', 34000, 'WESTERN_SLOPE', TIMESTAMP '2026-02-01 09:00:00'),
  (2, 'jordan.lee@example.gov', 'Jordan', 'Lee', 'Denver', 'Colorado', '80205', 'United States', 39.7550, -104.9700, SDO_GEOMETRY(2001,4326,SDO_POINT_TYPE(-104.9700,39.7550,NULL),NULL,NULL), 'standard', 21000, 'FRONT_RANGE', TIMESTAMP '2026-02-01 09:00:00'),
  (3, 'maya.patel@example.gov', 'Maya', 'Patel', 'Pueblo', 'Colorado', '81003', 'United States', 38.2600, -104.6200, SDO_GEOMETRY(2001,4326,SDO_POINT_TYPE(-104.6200,38.2600,NULL),NULL,NULL), 'standard', 18000, 'SOUTHERN_COLORADO', TIMESTAMP '2026-02-01 09:00:00'),
  (4, 'noah.williams@example.gov', 'Noah', 'Williams', 'Fort Collins', 'Colorado', '80524', 'United States', 40.5900, -105.0700, SDO_GEOMETRY(2001,4326,SDO_POINT_TYPE(-105.0700,40.5900,NULL),NULL,NULL), 'priority', 26000, 'FRONT_RANGE', TIMESTAMP '2026-02-01 09:00:00'),
  (5, 'sofia.martinez@example.gov', 'Sofia', 'Martinez', 'Denver', 'Colorado', '80211', 'United States', 39.7600, -105.0100, SDO_GEOMETRY(2001,4326,SDO_POINT_TYPE(-105.0100,39.7600,NULL),NULL,NULL), 'standard', 15000, 'FRONT_RANGE', TIMESTAMP '2026-02-01 09:00:00'),
  (6, 'liam.brown@example.gov', 'Liam', 'Brown', 'Montrose', 'Colorado', '81401', 'United States', 38.4783, -107.8762, SDO_GEOMETRY(2001,4326,SDO_POINT_TYPE(-107.8762,38.4783,NULL),NULL,NULL), 'priority', 29000, 'WESTERN_SLOPE', TIMESTAMP '2026-02-01 09:00:00');

INSERT INTO influencers (
  influencer_id, handle, display_name, platform, follower_count,
  engagement_rate, influence_score, niche, city, region,
  service_region_code, country, is_verified, created_at
) VALUES
  (1, '@co-benefits', 'Colorado Benefits Network', 'community', 85000, 0.081, 94, 'Benefits Eligibility', 'Denver', 'Colorado', 'FRONT_RANGE', 'United States', 1, TIMESTAMP '2026-01-15 09:00:00'),
  (2, '@western-slope-family', 'Western Slope Family Resource Alliance', 'partner', 42000, 0.074, 89, 'Family Support', 'Grand Junction', 'Colorado', 'WESTERN_SLOPE', 'United States', 1, TIMESTAMP '2026-01-15 09:00:00'),
  (3, '@county-human-services', 'County Human Services Collaborative', 'agency', 61000, 0.068, 87, 'Human Services', 'Denver', 'Colorado', 'FRONT_RANGE', 'United States', 1, TIMESTAMP '2026-01-15 09:00:00'),
  (4, '@front-range-housing', 'Front Range Housing Partnership', 'partner', 36000, 0.063, 82, 'Housing', 'Fort Collins', 'Colorado', 'FRONT_RANGE', 'United States', 1, TIMESTAMP '2026-01-15 09:00:00'),
  (5, '@emergency-coalition', 'Emergency Services Coalition', 'partner', 55000, 0.071, 86, 'Emergency Support', 'Pueblo', 'Colorado', 'SOUTHERN_COLORADO', 'United States', 1, TIMESTAMP '2026-01-15 09:00:00');

INSERT INTO social_posts (
  post_id, influencer_id, post_text, platform, virality_score,
  momentum_flag, views_count, likes_count, shares_count, comments_count,
  sentiment_score, detected_products, posted_at, service_region_code
) VALUES
  (1, 2, 'Eligibility appointments are booking three weeks out in the Western Slope.', 'caseworker', 95, 'mega_viral', 180000, 6200, 1400, 520, 0.22, 'Medicaid Eligibility Review', TIMESTAMP '2026-06-10 08:00:00', 'WESTERN_SLOPE'),
  (2, 1, 'My benefits renewal is waiting for eligibility review and I cannot get an appointment.', 'resident portal', 85, 'viral', 120000, 4100, 920, 330, 0.18, 'Benefits Appointment Scheduling', TIMESTAMP '2026-06-11 09:00:00', 'FRONT_RANGE'),
  (3, 3, 'Permit inspection scheduling is beginning to exceed the published service window.', 'call center', 60, 'rising', 45000, 900, 180, 75, 0.42, 'Building Permit Inspection', TIMESTAMP '2026-06-12 10:00:00', 'SOUTHERN_COLORADO'),
  (4, 3, 'Road repair requests are increasing after recent weather damage.', 'resident portal', 55, 'rising', 38000, 760, 140, 66, 0.45, 'Road Repair Request', TIMESTAMP '2026-06-13 11:00:00', 'FRONT_RANGE'),
  (5, 5, 'Emergency shelter referrals remain available across southern Colorado.', 'partner hotline', 40, 'steady', 22000, 500, 88, 42, 0.61, 'Emergency Shelter Referral', TIMESTAMP '2026-06-14 12:00:00', 'SOUTHERN_COLORADO'),
  (6, 4, 'Housing intake and benefits reviews need a shared appointment plan.', 'partner hotline', 82, 'viral', 98000, 3200, 700, 210, 0.27, 'Housing Assistance Intake', TIMESTAMP '2026-06-15 13:00:00', 'FRONT_RANGE'),
  (7, 2, 'Senior transportation requests are delaying scheduled eligibility visits.', 'caseworker', 70, 'rising', 67000, 1700, 360, 140, 0.33, 'Senior Transportation', TIMESTAMP '2026-06-16 14:00:00', 'WESTERN_SLOPE'),
  (8, 1, 'SNAP application support teams are resolving document questions within the current window.', 'resident portal', 65, 'rising', 51000, 1200, 240, 92, 0.58, 'SNAP Application Support', TIMESTAMP '2026-06-17 15:00:00', 'FRONT_RANGE');

INSERT INTO orders (
  order_id, customer_id, order_status, order_total, shipping_cost,
  fulfillment_center_id, shipping_lat, shipping_lon, estimated_delivery,
  actual_delivery, social_source_id, demand_score, service_region_code,
  created_at, updated_at
) VALUES
  (1, 1, 'processing', 12500, 120, 2, 39.0700, -108.5700, TIMESTAMP '2026-06-25 17:00:00', NULL, 1, 92, 'WESTERN_SLOPE', TIMESTAMP '2026-06-18 08:00:00', TIMESTAMP '2026-06-20 09:00:00'),
  (2, 2, 'pending', 8000, 80, 1, 39.7550, -104.9700, TIMESTAMP '2026-06-26 17:00:00', NULL, 2, 85, 'FRONT_RANGE', TIMESTAMP '2026-06-18 09:00:00', TIMESTAMP '2026-06-20 10:00:00'),
  (3, 3, 'confirmed', 4500, 65, 3, 38.2600, -104.6200, TIMESTAMP '2026-06-27 17:00:00', NULL, 3, 78, 'SOUTHERN_COLORADO', TIMESTAMP '2026-06-18 10:00:00', TIMESTAMP '2026-06-20 11:00:00'),
  (4, 4, 'shipped', 6000, 90, 4, 40.5900, -105.0700, TIMESTAMP '2026-06-24 17:00:00', NULL, 4, 66, 'FRONT_RANGE', TIMESTAMP '2026-06-18 11:00:00', TIMESTAMP '2026-06-20 12:00:00'),
  (5, 5, 'delivered', 3000, 50, 1, 39.7600, -105.0100, TIMESTAMP '2026-06-22 17:00:00', TIMESTAMP '2026-06-22 15:30:00', 5, 42, 'FRONT_RANGE', TIMESTAMP '2026-06-18 12:00:00', TIMESTAMP '2026-06-22 15:30:00'),
  (6, 6, 'processing', 11000, 130, 2, 38.4783, -107.8762, TIMESTAMP '2026-06-28 17:00:00', NULL, 6, 88, 'WESTERN_SLOPE', TIMESTAMP '2026-06-18 13:00:00', TIMESTAMP '2026-06-20 14:00:00'),
  (7, 1, 'pending', 2000, 45, 2, 39.0700, -108.5700, TIMESTAMP '2026-06-29 17:00:00', NULL, 7, 71, 'WESTERN_SLOPE', TIMESTAMP '2026-06-18 14:00:00', TIMESTAMP '2026-06-20 15:00:00'),
  (8, 2, 'confirmed', 3500, 55, 1, 39.7550, -104.9700, TIMESTAMP '2026-06-30 17:00:00', NULL, 8, 64, 'FRONT_RANGE', TIMESTAMP '2026-06-18 15:00:00', TIMESTAMP '2026-06-20 16:00:00');

INSERT INTO order_items (
  item_id, order_id, product_id, quantity, unit_price, line_total,
  fulfilled_from, service_region_code
) VALUES
  (1, 1, 1, 1, 12500, 12500, 2, 'WESTERN_SLOPE'),
  (2, 2, 3, 1, 8000, 8000, 1, 'FRONT_RANGE'),
  (3, 3, 4, 1, 4500, 4500, 3, 'SOUTHERN_COLORADO'),
  (4, 4, 5, 1, 6000, 6000, 4, 'FRONT_RANGE'),
  (5, 5, 6, 1, 3000, 3000, 1, 'FRONT_RANGE'),
  (6, 6, 7, 1, 11000, 11000, 2, 'WESTERN_SLOPE'),
  (7, 7, 10, 1, 2000, 2000, 2, 'WESTERN_SLOPE'),
  (8, 8, 2, 1, 3500, 3500, 1, 'FRONT_RANGE');

INSERT INTO inventory (
  inventory_id, product_id, center_id, quantity_on_hand,
  quantity_reserved, quantity_incoming, reorder_point, reorder_qty,
  last_restock_date, service_region_code, updated_at
) VALUES
  (1, 1, 1, 220, 50, 40, 80, 100, DATE '2026-06-01', 'FRONT_RANGE', TIMESTAMP '2026-06-20 08:00:00'),
  (2, 3, 1, 140, 35, 30, 60, 80, DATE '2026-06-01', 'FRONT_RANGE', TIMESTAMP '2026-06-20 08:00:00'),
  (3, 7, 1, 90, 20, 20, 40, 60, DATE '2026-06-01', 'FRONT_RANGE', TIMESTAMP '2026-06-20 08:00:00'),
  (4, 1, 2, 45, 20, 25, 30, 50, DATE '2026-06-01', 'WESTERN_SLOPE', TIMESTAMP '2026-06-20 08:00:00'),
  (5, 3, 2, 35, 15, 20, 25, 40, DATE '2026-06-01', 'WESTERN_SLOPE', TIMESTAMP '2026-06-20 08:00:00'),
  (6, 10, 2, 25, 10, 15, 20, 30, DATE '2026-06-01', 'WESTERN_SLOPE', TIMESTAMP '2026-06-20 08:00:00'),
  (7, 4, 3, 130, 30, 25, 55, 70, DATE '2026-06-01', 'SOUTHERN_COLORADO', TIMESTAMP '2026-06-20 08:00:00'),
  (8, 6, 3, 80, 20, 20, 35, 50, DATE '2026-06-01', 'SOUTHERN_COLORADO', TIMESTAMP '2026-06-20 08:00:00'),
  (9, 5, 4, 120, 25, 30, 50, 70, DATE '2026-06-01', 'FRONT_RANGE', TIMESTAMP '2026-06-20 08:00:00'),
  (10, 9, 4, 100, 20, 25, 45, 60, DATE '2026-06-01', 'FRONT_RANGE', TIMESTAMP '2026-06-20 08:00:00');

INSERT INTO post_product_mentions (
  mention_id, post_id, product_id, confidence_score,
  mention_type, service_region_code
) VALUES
  (1, 1, 1, 0.98, 'direct', 'WESTERN_SLOPE'),
  (2, 2, 3, 0.96, 'direct', 'FRONT_RANGE'),
  (3, 3, 4, 0.94, 'direct', 'SOUTHERN_COLORADO'),
  (4, 4, 5, 0.93, 'direct', 'FRONT_RANGE'),
  (5, 5, 6, 0.91, 'direct', 'SOUTHERN_COLORADO'),
  (6, 6, 7, 0.95, 'direct', 'FRONT_RANGE'),
  (7, 7, 10, 0.92, 'direct', 'WESTERN_SLOPE'),
  (8, 8, 2, 0.94, 'direct', 'FRONT_RANGE');

INSERT INTO shipments (
  shipment_id, order_id, center_id, carrier, tracking_number,
  ship_status, distance_km, estimated_hours, ship_cost,
  shipped_at, delivered_at, service_region_code, created_at
) VALUES
  (1, 1, 2, 'Western Slope Field Team', 'CO-SVC-0001', 'in_transit', 2.1, 1.0, 120, TIMESTAMP '2026-06-20 09:00:00', NULL, 'WESTERN_SLOPE', TIMESTAMP '2026-06-18 08:00:00'),
  (2, 4, 4, 'Front Range Public Works Crew', 'CO-SVC-0004', 'out_for_delivery', 4.3, 1.5, 90, TIMESTAMP '2026-06-20 12:00:00', NULL, 'FRONT_RANGE', TIMESTAMP '2026-06-18 11:00:00'),
  (3, 5, 1, 'Denver Community Response', 'CO-SVC-0005', 'delivered', 3.2, 1.0, 50, TIMESTAMP '2026-06-20 13:00:00', TIMESTAMP '2026-06-22 15:30:00', 'FRONT_RANGE', TIMESTAMP '2026-06-18 12:00:00');

INSERT INTO influencer_connections (
  connection_id, from_influencer, to_influencer, connection_type,
  strength, interaction_count, first_seen, last_interaction,
  service_region_code
) VALUES
  (1, 1, 2, 'collaborates', 0.920, 42, TIMESTAMP '2026-01-15 09:00:00', TIMESTAMP '2026-06-20 09:00:00', 'FRONT_RANGE'),
  (2, 1, 3, 'follows', 0.880, 35, TIMESTAMP '2026-01-15 09:00:00', TIMESTAMP '2026-06-20 09:00:00', 'FRONT_RANGE'),
  (3, 2, 4, 'collaborates', 0.810, 28, TIMESTAMP '2026-01-15 09:00:00', TIMESTAMP '2026-06-20 09:00:00', 'WESTERN_SLOPE'),
  (4, 3, 5, 'mentioned', 0.750, 22, TIMESTAMP '2026-01-15 09:00:00', TIMESTAMP '2026-06-20 09:00:00', 'FRONT_RANGE');

INSERT INTO brand_influencer_links (
  link_id, brand_id, influencer_id, relationship_type,
  post_count, avg_engagement, revenue_attributed,
  first_mention, last_mention, service_region_code
) VALUES
  (1, 1, 1, 'ambassador', 18, 0.081, 0, TIMESTAMP '2026-01-15 09:00:00', TIMESTAMP '2026-06-20 09:00:00', 'FRONT_RANGE'),
  (2, 1, 2, 'organic', 14, 0.074, 0, TIMESTAMP '2026-01-15 09:00:00', TIMESTAMP '2026-06-20 09:00:00', 'WESTERN_SLOPE'),
  (3, 2, 3, 'organic', 12, 0.068, 0, TIMESTAMP '2026-01-15 09:00:00', TIMESTAMP '2026-06-20 09:00:00', 'FRONT_RANGE'),
  (4, 3, 5, 'ambassador', 15, 0.071, 0, TIMESTAMP '2026-01-15 09:00:00', TIMESTAMP '2026-06-20 09:00:00', 'SOUTHERN_COLORADO');

INSERT INTO fulfillment_zones (
  zone_id, center_id, zone_type, max_delivery_hrs,
  zone_boundary, service_region_code, created_at
) VALUES
  (1, 1, 'standard', 24, SDO_GEOMETRY(2003,4326,NULL,SDO_ELEM_INFO_ARRAY(1,1003,3),SDO_ORDINATE_ARRAY(-105.30,39.50,-104.70,40.00)), 'FRONT_RANGE', TIMESTAMP '2026-01-10 09:00:00'),
  (2, 2, 'express', 8, SDO_GEOMETRY(2003,4326,NULL,SDO_ELEM_INFO_ARRAY(1,1003,3),SDO_ORDINATE_ARRAY(-109.00,38.70,-108.20,39.40)), 'WESTERN_SLOPE', TIMESTAMP '2026-01-10 09:00:00'),
  (3, 3, 'standard', 24, SDO_GEOMETRY(2003,4326,NULL,SDO_ELEM_INFO_ARRAY(1,1003,3),SDO_ORDINATE_ARRAY(-105.00,37.90,-104.20,38.60)), 'SOUTHERN_COLORADO', TIMESTAMP '2026-01-10 09:00:00'),
  (4, 4, 'overnight', 16, SDO_GEOMETRY(2003,4326,NULL,SDO_ELEM_INFO_ARRAY(1,1003,3),SDO_ORDINATE_ARRAY(-105.40,40.30,-104.70,40.90)), 'FRONT_RANGE', TIMESTAMP '2026-01-10 09:00:00');

INSERT INTO demand_regions (
  region_id, region_name, region_type, boundary, population,
  avg_income, social_density, demand_index, service_region_code,
  updated_at
) VALUES
  (1, 'Front Range', 'region', SDO_GEOMETRY(2003,4326,NULL,SDO_ELEM_INFO_ARRAY(1,1003,3),SDO_ORDINATE_ARRAY(-105.60,38.70,-104.40,41.00)), 4100000, 76000, 71, 78, 'FRONT_RANGE', TIMESTAMP '2026-06-20 08:00:00'),
  (2, 'Western Slope', 'region', SDO_GEOMETRY(2003,4326,NULL,SDO_ELEM_INFO_ARRAY(1,1003,3),SDO_ORDINATE_ARRAY(-109.10,37.00,-106.00,41.00)), 580000, 62000, 88, 91, 'WESTERN_SLOPE', TIMESTAMP '2026-06-20 08:00:00'),
  (3, 'Southern Colorado', 'region', SDO_GEOMETRY(2003,4326,NULL,SDO_ELEM_INFO_ARRAY(1,1003,3),SDO_ORDINATE_ARRAY(-106.20,37.00,-103.00,39.10)), 890000, 59000, 64, 72, 'SOUTHERN_COLORADO', TIMESTAMP '2026-06-20 08:00:00');

INSERT INTO user_sdo_geom_metadata (
  table_name, column_name, diminfo, srid
) VALUES
  ('FULFILLMENT_CENTERS', 'LOCATION', SDO_DIM_ARRAY(SDO_DIM_ELEMENT('LON',-180,180,0.005),SDO_DIM_ELEMENT('LAT',-90,90,0.005)), 4326),
  ('CUSTOMERS', 'LOCATION', SDO_DIM_ARRAY(SDO_DIM_ELEMENT('LON',-180,180,0.005),SDO_DIM_ELEMENT('LAT',-90,90,0.005)), 4326),
  ('FULFILLMENT_ZONES', 'ZONE_BOUNDARY', SDO_DIM_ARRAY(SDO_DIM_ELEMENT('LON',-180,180,0.005),SDO_DIM_ELEMENT('LAT',-90,90,0.005)), 4326),
  ('DEMAND_REGIONS', 'BOUNDARY', SDO_DIM_ARRAY(SDO_DIM_ELEMENT('LON',-180,180,0.005),SDO_DIM_ELEMENT('LAT',-90,90,0.005)), 4326);

CREATE INDEX idx_fc_spatial ON fulfillment_centers(location)
  INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2;
CREATE INDEX idx_customer_spatial ON customers(location)
  INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2;
CREATE INDEX idx_zone_spatial ON fulfillment_zones(zone_boundary)
  INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2;
CREATE INDEX idx_region_spatial ON demand_regions(boundary)
  INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2;

CREATE OR REPLACE JSON RELATIONAL DUALITY VIEW orders_dv AS
SELECT JSON {
  '_id' : o.order_id,
  'customerId' : o.customer_id,
  'status' : o.order_status,
  'total' : o.order_total,
  'routingCost' : o.shipping_cost,
  'urgencyScore' : o.demand_score,
  'createdAt' : o.created_at,
  'items' : [
    SELECT JSON {
      'itemId' : oi.item_id,
      'productId' : oi.product_id,
      'quantity' : oi.quantity,
      'serviceValue' : oi.unit_price
    }
    FROM order_items oi WITH UPDATE
    WHERE oi.order_id = o.order_id
  ]
}
FROM orders o WITH UPDATE;

CREATE PROPERTY GRAPH influencer_network
  VERTEX TABLES (
    influencers KEY (influencer_id)
      LABEL influencer
      PROPERTIES (
        influencer_id, handle, display_name, platform,
        follower_count, engagement_rate, influence_score,
        niche, city, region, is_verified
      ),
    brands KEY (brand_id)
      LABEL brand
      PROPERTIES (
        brand_id, brand_name, brand_category, social_tier
      ),
    products KEY (product_id)
      LABEL product
      PROPERTIES (
        product_id, product_name, category, unit_price
      ),
    social_posts KEY (post_id)
      LABEL social_post
      PROPERTIES (
        post_id, platform, posted_at, virality_score, momentum_flag
      )
  )
  EDGE TABLES (
    influencer_connections
      KEY (connection_id)
      SOURCE KEY (from_influencer) REFERENCES influencers (influencer_id)
      DESTINATION KEY (to_influencer) REFERENCES influencers (influencer_id)
      LABEL connects_to
      PROPERTIES (connection_type, strength, interaction_count),
    brand_influencer_links
      KEY (link_id)
      SOURCE KEY (influencer_id) REFERENCES influencers (influencer_id)
      DESTINATION KEY (brand_id) REFERENCES brands (brand_id)
      LABEL promotes
      PROPERTIES (relationship_type, post_count, avg_engagement),
    post_product_mentions
      KEY (mention_id)
      SOURCE KEY (post_id) REFERENCES social_posts (post_id)
      DESTINATION KEY (product_id) REFERENCES products (product_id)
      LABEL mentions_product
      PROPERTIES (confidence_score, mention_type)
  );

INSERT INTO product_embeddings (
  embedding_id, product_id, embedding_model,
  embedding_text, embedding, created_at
)
SELECT product_id,
       product_id,
       'all_MiniLM_L12_v2',
       product_name || '. ' || description || '. ' || tags,
       VECTOR_EMBEDDING(
         ADMIN.ALL_MINILM_L12_V2
         USING product_name || '. ' || description || '. ' || tags AS DATA
       ),
       TIMESTAMP '2026-06-20 08:00:00'
FROM products;

INSERT INTO post_embeddings (
  embedding_id, post_id, service_region_code, embedding_model,
  embedding_text, embedding, created_at
)
SELECT post_id,
       post_id,
       service_region_code,
       'all_MiniLM_L12_v2',
       post_text,
       VECTOR_EMBEDDING(
         ADMIN.ALL_MINILM_L12_V2 USING post_text AS DATA
       ),
       TIMESTAMP '2026-06-20 08:00:00'
FROM social_posts;

CREATE VECTOR INDEX idx_product_vec ON product_embeddings(embedding)
  ORGANIZATION NEIGHBOR PARTITIONS
  WITH DISTANCE COSINE
  WITH TARGET ACCURACY 95;

CREATE VECTOR INDEX idx_post_vec ON post_embeddings(embedding)
  ORGANIZATION NEIGHBOR PARTITIONS
  WITH DISTANCE COSINE
  WITH TARGET ACCURACY 95;

CREATE OR REPLACE VIEW sled_public_programs_v AS
SELECT brand_id AS program_id, brand_name AS program_name,
       brand_category AS program_category, headquarters_city,
       annual_revenue AS program_value_proxy,
       social_tier AS service_priority_tier, created_at, updated_at
FROM brands;

CREATE OR REPLACE VIEW sled_public_services_v AS
SELECT p.product_id AS service_id, p.product_name AS service_name,
       p.description AS service_description, p.category AS service_category,
       p.subcategory AS service_subcategory,
       p.unit_price AS service_value_proxy,
       p.unit_cost AS service_cost_proxy, p.tags,
       p.brand_id AS program_id, b.brand_name AS program_name,
       p.is_active, p.launch_date, p.created_at, p.updated_at
FROM products p
JOIN brands b ON b.brand_id = p.brand_id;

CREATE OR REPLACE VIEW sled_resident_signals_v AS
SELECT sp.post_id AS resident_signal_id, sp.service_region_code,
       sp.post_text AS signal_text, sp.platform AS source_channel,
       sp.virality_score AS urgency_score,
       CASE sp.momentum_flag
         WHEN 'viral' THEN 'urgent'
         WHEN 'mega_viral' THEN 'critical'
         ELSE sp.momentum_flag
       END AS urgency_band,
       sp.views_count AS reach_count,
       sp.likes_count AS acknowledgement_count,
       sp.shares_count AS escalation_count,
       sp.comments_count AS reply_count,
       sp.sentiment_score, sp.detected_products AS detected_services,
       sp.posted_at AS signal_time, sp.influencer_id AS source_id,
       i.handle AS source_handle, i.display_name AS source_name
FROM social_posts sp
LEFT JOIN influencers i ON i.influencer_id = sp.influencer_id;

CREATE OR REPLACE VIEW sled_signal_sources_v AS
SELECT influencer_id AS source_id, handle AS source_handle,
       display_name AS source_name, platform AS source_channel,
       follower_count AS community_reach, engagement_rate,
       influence_score AS source_authority_score,
       niche AS source_focus_area, city, region, service_region_code,
       country, is_verified, created_at
FROM influencers;

CREATE OR REPLACE VIEW sled_service_requests_v AS
SELECT o.order_id AS service_request_id, o.service_region_code,
       o.customer_id AS resident_id, o.order_status AS physical_request_status,
       CASE o.order_status
         WHEN 'shipped' THEN 'routed'
         WHEN 'delivered' THEN 'completed'
         WHEN 'returned' THEN 'reopened'
         WHEN 'processing' THEN 'in progress'
         ELSE o.order_status
       END AS request_status,
       o.order_total AS service_value_exposure,
       o.shipping_cost AS routing_cost_proxy,
       o.fulfillment_center_id AS service_access_center_id,
       o.shipping_lat AS service_latitude,
       o.shipping_lon AS service_longitude,
       o.estimated_delivery AS estimated_completion,
       o.actual_delivery AS actual_completion,
       o.social_source_id AS resident_signal_id,
       o.demand_score AS urgency_score, o.created_at, o.updated_at
FROM orders o;

CREATE OR REPLACE VIEW sled_service_request_lines_v AS
SELECT oi.item_id AS service_request_line_id,
       oi.service_region_code, oi.order_id AS service_request_id,
       oi.product_id AS service_id, p.product_name AS service_name,
       oi.quantity AS requested_quantity,
       oi.unit_price AS service_value_proxy,
       oi.line_total AS line_service_value,
       oi.fulfilled_from AS service_access_center_id
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id;

CREATE OR REPLACE VIEW sled_residents_v AS
SELECT customer_id AS resident_id, service_region_code,
       email AS resident_contact_email,
       first_name || ' ' || last_name AS resident_display_name,
       city, state_province, postal_code, country, latitude, longitude,
       location, customer_tier AS resident_access_tier,
       lifetime_value AS service_value_history, created_at
FROM customers;

CREATE OR REPLACE VIEW sled_service_access_centers_v AS
SELECT center_id AS service_access_center_id, service_region_code,
       center_name AS service_access_center_name,
       center_type AS physical_center_type,
       CASE center_type
         WHEN 'distribution' THEN 'Regional Service Hub'
         WHEN 'warehouse' THEN 'Service Capacity Center'
         WHEN 'micro' THEN 'Local Access Point'
         WHEN 'store' THEN 'Resident Service Counter'
         WHEN 'drop_ship' THEN 'Partner Service Point'
         ELSE center_type
       END AS service_access_center_type,
       address_line1, city, state_province, postal_code, country,
       latitude, longitude, capacity_units AS service_capacity_units,
       current_load_pct AS utilization_pct, is_active,
       operating_hours, created_at
FROM fulfillment_centers;

CREATE OR REPLACE VIEW sled_service_capacity_v AS
SELECT inventory_id AS capacity_id, service_region_code,
       product_id AS service_id, center_id AS service_access_center_id,
       quantity_on_hand AS available_capacity,
       quantity_reserved AS reserved_capacity,
       quantity_incoming AS incoming_capacity,
       reorder_point AS minimum_capacity_threshold,
       reorder_qty AS target_capacity_increment,
       last_restock_date, updated_at
FROM inventory;

CREATE OR REPLACE VIEW sled_service_task_routes_v AS
SELECT shipment_id AS service_task_route_id, service_region_code,
       order_id AS service_request_id,
       center_id AS service_access_center_id,
       carrier AS service_team, tracking_number AS route_reference,
       ship_status AS physical_route_status,
       CASE ship_status
         WHEN 'shipped' THEN 'routed'
         WHEN 'in_transit' THEN 'active route'
         WHEN 'out_for_delivery' THEN 'field response'
         WHEN 'delivered' THEN 'completed'
         ELSE ship_status
       END AS route_status,
       distance_km, estimated_hours, ship_cost AS route_cost_proxy,
       shipped_at AS routed_at, delivered_at AS completed_at, created_at
FROM shipments;

CREATE OR REPLACE VIEW sled_operations_dashboard_v AS
SELECT o.order_id AS service_request_id, o.service_region_code,
       sr.request_status, o.order_total AS service_value_exposure,
       o.demand_score AS urgency_score,
       c.customer_tier AS resident_access_tier,
       c.city AS resident_city, c.state_province AS resident_state,
       fc.center_name AS service_access_center_name,
       fc.center_type AS physical_center_type,
       p.product_id AS service_id, p.product_name AS service_name,
       p.category AS service_category,
       b.brand_id AS program_id, b.brand_name AS program_name,
       sp.post_id AS resident_signal_id,
       sp.virality_score AS signal_urgency_score,
       CASE sp.momentum_flag
         WHEN 'viral' THEN 'urgent'
         WHEN 'mega_viral' THEN 'critical'
         ELSE sp.momentum_flag
       END AS signal_urgency_band,
       o.created_at AS request_created_at
FROM orders o
JOIN sled_service_requests_v sr
  ON sr.service_request_id = o.order_id
JOIN customers c ON c.customer_id = o.customer_id
LEFT JOIN fulfillment_centers fc
  ON fc.center_id = o.fulfillment_center_id
LEFT JOIN order_items oi ON oi.order_id = o.order_id
LEFT JOIN products p ON p.product_id = oi.product_id
LEFT JOIN brands b ON b.brand_id = p.brand_id
LEFT JOIN social_posts sp ON sp.post_id = o.social_source_id;

-- Fixed thresholds create both SURGE and STABLE labels in the compact dataset.
-- This replaces the source stack rule that labels every full-dataset service SURGE.
CREATE OR REPLACE VIEW oml_demand_training_v AS
SELECT p.product_id,
       p.category,
       p.unit_price,
       NVL(AVG(sp.virality_score), 0) AS avg_virality,
       NVL(SUM(sp.views_count), 0) AS total_views,
       NVL(SUM(oi.quantity), 0) AS units_requested,
       CASE
         WHEN NVL(AVG(sp.virality_score), 0) >= 70
           OR NVL(SUM(sp.views_count), 0) >= 150000
         THEN 'SURGE'
         ELSE 'STABLE'
       END AS surge_flag
FROM products p
LEFT JOIN post_product_mentions ppm ON ppm.product_id = p.product_id
LEFT JOIN social_posts sp ON sp.post_id = ppm.post_id
LEFT JOIN order_items oi ON oi.product_id = p.product_id
WHERE p.is_active = 1
GROUP BY p.product_id, p.category, p.unit_price;

CREATE OR REPLACE VIEW oml_customer_rfm_v AS
WITH anchor_date AS (
  SELECT MAX(CAST(created_at AS DATE)) AS max_request_date FROM orders
)
SELECT c.customer_id,
       c.lifetime_value,
       ROUND(a.max_request_date - CAST(MAX(o.created_at) AS DATE)) AS recency_days,
       COUNT(o.order_id) AS frequency,
       SUM(o.order_total) AS monetary,
       AVG(o.order_total) AS avg_request_value
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
CROSS JOIN anchor_date a
GROUP BY c.customer_id, c.lifetime_value, a.max_request_date;

CREATE OR REPLACE VIEW oml_commitment_value_training_v AS
SELECT o.order_id,
       c.customer_tier,
       c.lifetime_value,
       o.demand_score,
       COUNT(oi.product_id) AS service_count,
       SUM(oi.quantity) AS total_quantity,
       AVG(oi.unit_price) AS avg_service_value,
       o.order_total AS target_commitment_value
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY o.order_id, c.customer_tier, c.lifetime_value,
         o.demand_score, o.order_total;

CREATE OR REPLACE VIEW oml_product_cluster_v AS
SELECT p.product_id,
       p.unit_price,
       p.weight_kg,
       NVL(SUM(oi.quantity), 0) AS units_requested,
       NVL(SUM(oi.line_total), 0) AS service_value,
       NVL(SUM(sp.views_count + sp.likes_count + sp.shares_count), 0)
         AS total_engagement,
       NVL(AVG(sp.virality_score), 0) AS avg_virality
FROM products p
LEFT JOIN order_items oi ON oi.product_id = p.product_id
LEFT JOIN post_product_mentions ppm ON ppm.product_id = p.product_id
LEFT JOIN social_posts sp ON sp.post_id = ppm.post_id
GROUP BY p.product_id, p.unit_price, p.weight_kg;

CREATE TABLE sled_service_demand_settings (
  setting_name VARCHAR2(30),
  setting_value VARCHAR2(4000)
);
CREATE TABLE sled_resident_need_settings (
  setting_name VARCHAR2(30),
  setting_value VARCHAR2(4000)
);
CREATE TABLE sled_service_value_settings (
  setting_name VARCHAR2(30),
  setting_value VARCHAR2(4000)
);
CREATE TABLE sled_case_signal_cluster_settings (
  setting_name VARCHAR2(30),
  setting_value VARCHAR2(4000)
);

INSERT INTO sled_service_demand_settings (
  setting_name, setting_value
) VALUES
  ('ALGO_NAME', 'ALGO_RANDOM_FOREST'),
  ('PREP_AUTO', 'ON');

INSERT INTO sled_resident_need_settings (
  setting_name, setting_value
) VALUES
  ('ALGO_NAME', 'ALGO_KMEANS'),
  ('PREP_AUTO', 'ON'),
  ('CLUS_NUM_CLUSTERS', '4');

INSERT INTO sled_service_value_settings (
  setting_name, setting_value
) VALUES
  ('ALGO_NAME', 'ALGO_GENERALIZED_LINEAR_MODEL'),
  ('PREP_AUTO', 'ON');

INSERT INTO sled_case_signal_cluster_settings (
  setting_name, setting_value
) VALUES
  ('ALGO_NAME', 'ALGO_KMEANS'),
  ('PREP_AUTO', 'ON'),
  ('CLUS_NUM_CLUSTERS', '5');

BEGIN
  DBMS_DATA_MINING.CREATE_MODEL(
    model_name => 'SLED_SERVICE_DEMAND_MODEL',
    mining_function => DBMS_DATA_MINING.CLASSIFICATION,
    data_table_name => 'OML_DEMAND_TRAINING_V',
    case_id_column_name => 'PRODUCT_ID',
    target_column_name => 'SURGE_FLAG',
    settings_table_name => 'SLED_SERVICE_DEMAND_SETTINGS'
  );

  DBMS_DATA_MINING.CREATE_MODEL(
    model_name => 'SLED_RESIDENT_NEED_SEGMENT_MODEL',
    mining_function => DBMS_DATA_MINING.CLUSTERING,
    data_table_name => 'OML_CUSTOMER_RFM_V',
    case_id_column_name => 'CUSTOMER_ID',
    settings_table_name => 'SLED_RESIDENT_NEED_SETTINGS'
  );

  DBMS_DATA_MINING.CREATE_MODEL(
    model_name => 'SLED_SERVICE_VALUE_MODEL',
    mining_function => DBMS_DATA_MINING.REGRESSION,
    data_table_name => 'OML_COMMITMENT_VALUE_TRAINING_V',
    case_id_column_name => 'ORDER_ID',
    target_column_name => 'TARGET_COMMITMENT_VALUE',
    settings_table_name => 'SLED_SERVICE_VALUE_SETTINGS'
  );

  DBMS_DATA_MINING.CREATE_MODEL(
    model_name => 'SLED_CASE_SIGNAL_CLUSTER_MODEL',
    mining_function => DBMS_DATA_MINING.CLUSTERING,
    data_table_name => 'OML_PRODUCT_CLUSTER_V',
    case_id_column_name => 'PRODUCT_ID',
    settings_table_name => 'SLED_CASE_SIGNAL_CLUSTER_SETTINGS'
  );
END;
/

COMMIT;

PROMPT State and Local Government platform loader validation summary

SELECT "Area", "Object Count", "Status"
FROM (
  SELECT 'Base tables' AS "Area",
         COUNT(*) AS "Object Count",
         CASE WHEN COUNT(*) = 21 THEN 'PASS' ELSE 'CHECK' END AS "Status"
  FROM user_tables
  WHERE table_name IN (
    'BRANDS','PRODUCTS','FULFILLMENT_CENTERS','INVENTORY',
    'CUSTOMERS','ORDERS','ORDER_ITEMS','INFLUENCERS',
    'SOCIAL_POSTS','POST_PRODUCT_MENTIONS','SHIPMENTS',
    'INFLUENCER_CONNECTIONS','BRAND_INFLUENCER_LINKS',
    'FULFILLMENT_ZONES','DEMAND_REGIONS',
    'PRODUCT_EMBEDDINGS','POST_EMBEDDINGS',
    'SLED_SERVICE_DEMAND_SETTINGS','SLED_RESIDENT_NEED_SETTINGS',
    'SLED_SERVICE_VALUE_SETTINGS','SLED_CASE_SIGNAL_CLUSTER_SETTINGS'
  )
  UNION ALL
  SELECT 'Public programs', COUNT(*),
         CASE WHEN COUNT(*) = 3 THEN 'PASS' ELSE 'CHECK' END
  FROM brands
  UNION ALL
  SELECT 'Public services', COUNT(*),
         CASE WHEN COUNT(*) = 10 THEN 'PASS' ELSE 'CHECK' END
  FROM products
  UNION ALL
  SELECT 'Service access centers', COUNT(*),
         CASE WHEN COUNT(*) = 4 THEN 'PASS' ELSE 'CHECK' END
  FROM fulfillment_centers
  UNION ALL
  SELECT 'Residents', COUNT(*),
         CASE WHEN COUNT(*) = 6 THEN 'PASS' ELSE 'CHECK' END
  FROM customers
  UNION ALL
  SELECT 'Service requests', COUNT(*),
         CASE WHEN COUNT(*) = 8 THEN 'PASS' ELSE 'CHECK' END
  FROM orders
  UNION ALL
  SELECT 'Resident signals', COUNT(*),
         CASE WHEN COUNT(*) = 8 THEN 'PASS' ELSE 'CHECK' END
  FROM social_posts
  UNION ALL
  SELECT 'Demand regions', COUNT(*),
         CASE WHEN COUNT(*) = 3 THEN 'PASS' ELSE 'CHECK' END
  FROM demand_regions
  UNION ALL
  SELECT 'SLED semantic views', COUNT(*),
         CASE WHEN COUNT(*) = 11 THEN 'PASS' ELSE 'CHECK' END
  FROM user_views
  WHERE view_name LIKE 'SLED\_%\_V' ESCAPE '\'
  UNION ALL
  SELECT 'JSON duality views', COUNT(*),
         CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'CHECK' END
  FROM user_json_duality_views
  WHERE view_name = 'ORDERS_DV'
  UNION ALL
  SELECT 'Property graphs', COUNT(*),
         CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'CHECK' END
  FROM user_property_graphs
  WHERE graph_name = 'INFLUENCER_NETWORK'
  UNION ALL
  SELECT 'Spatial metadata layers', COUNT(*),
         CASE WHEN COUNT(*) = 4 THEN 'PASS' ELSE 'CHECK' END
  FROM user_sdo_geom_metadata
  WHERE table_name IN (
    'FULFILLMENT_CENTERS','CUSTOMERS',
    'FULFILLMENT_ZONES','DEMAND_REGIONS'
  )
  UNION ALL
  SELECT 'OML models', COUNT(*),
         CASE WHEN COUNT(*) = 4 THEN 'PASS' ELSE 'CHECK' END
  FROM user_mining_models
  WHERE model_name LIKE 'SLED\_%\_MODEL' ESCAPE '\'
  UNION ALL
  SELECT 'OML demand label classes', COUNT(DISTINCT surge_flag),
         CASE
           WHEN COUNT(DISTINCT surge_flag) = 2
            AND SUM(CASE WHEN surge_flag = 'SURGE' THEN 1 ELSE 0 END) = 4
            AND SUM(CASE WHEN surge_flag = 'STABLE' THEN 1 ELSE 0 END) = 6
           THEN 'PASS' ELSE 'CHECK'
         END
  FROM oml_demand_training_v
  UNION ALL
  SELECT 'Vector rows',
         (SELECT COUNT(*) FROM product_embeddings) +
         (SELECT COUNT(*) FROM post_embeddings),
         CASE
           WHEN (SELECT COUNT(*) FROM product_embeddings) = 10
            AND (SELECT COUNT(*) FROM post_embeddings) = 8
           THEN 'PASS' ELSE 'CHECK'
         END
  FROM dual
  UNION ALL
  SELECT 'Vector dimensions', COUNT(*),
         CASE WHEN MIN(VECTOR_DIMENSION_COUNT(embedding)) = 384
              THEN 'PASS' ELSE 'CHECK' END
  FROM product_embeddings
  UNION ALL
  SELECT 'Invalid objects', COUNT(*),
         CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'CHECK' END
  FROM user_objects
  WHERE status = 'INVALID'
)
ORDER BY "Area";

PROMPT State and Local Government platform handoff loader complete.
