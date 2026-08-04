-- Telco LiveStack deterministic platform handoff loader.
-- Run: sql ADMIN/<admin-password>@<service> @telco-platform-handoff-loader.sql <lluser-password> <service>
SET DEFINE ON
SET SERVEROUTPUT ON
SET SQLBLANKLINES ON

PROMPT Preparing LLUSER when the script starts as ADMIN
DECLARE
  v_current_user VARCHAR2(128);
BEGIN
  SELECT USER INTO v_current_user FROM dual;
  IF v_current_user = 'ADMIN' THEN
    EXECUTE IMMEDIATE 'ALTER USER LLUSER ACCOUNT UNLOCK';
    EXECUTE IMMEDIATE 'GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE PROCEDURE, CREATE SEQUENCE, CREATE PROPERTY GRAPH, CREATE MINING MODEL TO LLUSER';
    EXECUTE IMMEDIATE 'GRANT SELECT ON MINING MODEL ALL_MINILM_L12_V2 TO LLUSER';
  END IF;
END;
/

CONNECT LLUSER/"&1"@&2
SET DEFINE OFF

ALTER SESSION DISABLE PARALLEL DML;

DECLARE
  v_current_user VARCHAR2(128);
BEGIN
  SELECT USER INTO v_current_user FROM dual;
  IF v_current_user <> 'LLUSER' THEN
    RAISE_APPLICATION_ERROR(-20001, 'The Telco loader DDL and data section must run as LLUSER.');
  END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP PROPERTY GRAPH telecom_experience_network';
EXCEPTION WHEN OTHERS THEN IF SQLCODE NOT IN (-942, -4043, -42421) THEN RAISE; END IF;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'DROP VIEW orders_dv';
EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF;
END;
/
BEGIN
  DBMS_DATA_MINING.DROP_MODEL('NETWORK_CAPACITY_SURGE_MODEL');
EXCEPTION WHEN OTHERS THEN IF SQLCODE NOT IN (-4019, -4020, -4043, -40284) THEN RAISE; END IF;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'DROP VIEW network_capacity_surge_training_v';
EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'DROP VIEW service_orders_dv';
EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'DROP SYNONYM service_orders_dv';
EXCEPTION WHEN OTHERS THEN IF SQLCODE != -1434 THEN RAISE; END IF;
END;
/
BEGIN
  FOR x IN (
    SELECT 'SERVICE_ORDER_ITEMS' AS name FROM dual UNION ALL
    SELECT 'NETWORK_CAPACITY_SURGE_SETTINGS' FROM dual UNION ALL
    SELECT 'SERVICE_ORDERS' FROM dual UNION ALL
    SELECT 'SIGNAL_SERVICE_MATCHES' FROM dual UNION ALL
    SELECT 'SIGNAL_EMBEDDINGS' FROM dual UNION ALL
    SELECT 'SERVICE_EMBEDDINGS' FROM dual UNION ALL
    SELECT 'SUBSCRIBER_SIGNALS' FROM dual UNION ALL
    SELECT 'NETWORK_CAPACITY' FROM dual UNION ALL
    SELECT 'TELECOM_GRAPH_RELATIONSHIPS' FROM dual UNION ALL
    SELECT 'TELECOM_CASE_ENTITIES' FROM dual UNION ALL
    SELECT 'TELECOM_EXPERIENCE_CASES' FROM dual UNION ALL
    SELECT 'TELECOM_GRAPH_ENTITIES' FROM dual UNION ALL
    SELECT 'SUBSCRIBERS' FROM dual UNION ALL
    SELECT 'TELECOM_SERVICES' FROM dual UNION ALL
    SELECT 'SERVICE_LINES' FROM dual UNION ALL
    SELECT 'NETWORK_SITES' FROM dual
  ) LOOP
    BEGIN
      EXECUTE IMMEDIATE 'DROP TABLE ' || x.name || ' CASCADE CONSTRAINTS PURGE';
    EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF;
    END;
  END LOOP;
  DELETE FROM user_sdo_geom_metadata
  WHERE table_name IN ('NETWORK_SITES', 'SUBSCRIBERS');
END;
/

CREATE TABLE service_lines (
  service_line_id NUMBER PRIMARY KEY,
  service_line_name VARCHAR2(100) NOT NULL UNIQUE,
  network_program VARCHAR2(100) NOT NULL,
  headquarters_city VARCHAR2(80) NOT NULL,
  annual_service_value NUMBER(14,2) NOT NULL
);

CREATE TABLE telecom_services (
  service_id NUMBER PRIMARY KEY,
  service_line_id NUMBER NOT NULL REFERENCES service_lines(service_line_id),
  service_name VARCHAR2(160) NOT NULL,
  service_category VARCHAR2(80) NOT NULL,
  service_segment VARCHAR2(80) NOT NULL,
  monthly_value NUMBER(10,2) NOT NULL,
  service_description CLOB NOT NULL,
  is_active NUMBER(1) DEFAULT 1 NOT NULL CHECK (is_active IN (0,1))
);

CREATE TABLE network_sites (
  network_site_id NUMBER PRIMARY KEY,
  network_site_name VARCHAR2(160) NOT NULL,
  network_site_type VARCHAR2(80) NOT NULL,
  city VARCHAR2(80) NOT NULL,
  state_province VARCHAR2(80) NOT NULL,
  latitude NUMBER(10,6) NOT NULL,
  longitude NUMBER(10,6) NOT NULL,
  service_capacity_units NUMBER NOT NULL,
  current_capacity_load_pct NUMBER(5,2) NOT NULL,
  location MDSYS.SDO_GEOMETRY NOT NULL
);

CREATE TABLE network_capacity (
  capacity_id NUMBER PRIMARY KEY,
  service_id NUMBER NOT NULL REFERENCES telecom_services(service_id),
  network_site_id NUMBER NOT NULL REFERENCES network_sites(network_site_id),
  capacity_available NUMBER NOT NULL,
  capacity_reserved NUMBER NOT NULL,
  capacity_incoming NUMBER NOT NULL,
  escalation_threshold NUMBER NOT NULL,
  target_capacity_increment NUMBER NOT NULL,
  CONSTRAINT uq_network_capacity UNIQUE (service_id, network_site_id)
);

CREATE TABLE subscribers (
  subscriber_id NUMBER PRIMARY KEY,
  subscriber_name VARCHAR2(120) NOT NULL,
  city VARCHAR2(80) NOT NULL,
  state_province VARCHAR2(80) NOT NULL,
  subscriber_tier VARCHAR2(30) NOT NULL,
  service_value NUMBER(12,2) NOT NULL,
  location MDSYS.SDO_GEOMETRY NOT NULL
);

CREATE TABLE subscriber_signals (
  signal_id NUMBER PRIMARY KEY,
  signal_channel VARCHAR2(30) NOT NULL,
  signal_text CLOB NOT NULL,
  signal_time TIMESTAMP NOT NULL,
  urgency_score NUMBER(5,2) NOT NULL,
  sentiment_score NUMBER(4,3) NOT NULL,
  momentum_band VARCHAR2(20) NOT NULL,
  exposure_count NUMBER NOT NULL,
  advocate_name VARCHAR2(100),
  region VARCHAR2(80) NOT NULL
);

CREATE TABLE service_orders (
  service_order_id NUMBER PRIMARY KEY,
  subscriber_id NUMBER NOT NULL REFERENCES subscribers(subscriber_id),
  network_site_id NUMBER NOT NULL REFERENCES network_sites(network_site_id),
  source_signal_id NUMBER REFERENCES subscriber_signals(signal_id),
  service_status VARCHAR2(30) NOT NULL,
  service_value NUMBER(12,2) NOT NULL,
  dispatch_cost NUMBER(10,2) NOT NULL,
  demand_score NUMBER(5,2) NOT NULL,
  created_at TIMESTAMP NOT NULL
);

CREATE TABLE service_order_items (
  service_order_item_id NUMBER PRIMARY KEY,
  service_order_id NUMBER NOT NULL REFERENCES service_orders(service_order_id),
  service_id NUMBER NOT NULL REFERENCES telecom_services(service_id),
  quantity NUMBER NOT NULL,
  monthly_value NUMBER(10,2) NOT NULL
);

CREATE TABLE service_embeddings (
  service_id NUMBER PRIMARY KEY REFERENCES telecom_services(service_id),
  embedding_text CLOB NOT NULL,
  embedding VECTOR(384) NOT NULL,
  embedding_model VARCHAR2(80) NOT NULL
);

CREATE TABLE signal_embeddings (
  signal_id NUMBER PRIMARY KEY REFERENCES subscriber_signals(signal_id),
  embedding_text CLOB NOT NULL,
  embedding VECTOR(384) NOT NULL,
  embedding_model VARCHAR2(80) NOT NULL
);

CREATE TABLE signal_service_matches (
  signal_id NUMBER NOT NULL REFERENCES subscriber_signals(signal_id),
  service_id NUMBER NOT NULL REFERENCES telecom_services(service_id),
  similarity_score NUMBER(6,5) NOT NULL,
  match_rank NUMBER NOT NULL,
  match_method VARCHAR2(30) NOT NULL,
  PRIMARY KEY (signal_id, service_id)
);

CREATE TABLE telecom_graph_entities (
  entity_id NUMBER PRIMARY KEY,
  entity_key VARCHAR2(80) NOT NULL UNIQUE,
  display_name VARCHAR2(180) NOT NULL,
  entity_type VARCHAR2(40) NOT NULL,
  region VARCHAR2(80) NOT NULL,
  city VARCHAR2(80) NOT NULL,
  risk_score NUMBER(5,2) NOT NULL,
  experience_score NUMBER(5,2) NOT NULL,
  affected_count NUMBER NOT NULL,
  signal_count NUMBER NOT NULL,
  service_value NUMBER(14,2) NOT NULL
);

CREATE TABLE telecom_graph_relationships (
  relationship_id NUMBER PRIMARY KEY,
  from_entity NUMBER NOT NULL REFERENCES telecom_graph_entities(entity_id),
  to_entity NUMBER NOT NULL REFERENCES telecom_graph_entities(entity_id),
  relationship_type VARCHAR2(50) NOT NULL,
  strength NUMBER(4,3) NOT NULL,
  event_count NUMBER NOT NULL,
  affected_count NUMBER NOT NULL,
  CONSTRAINT uq_telecom_graph_rel UNIQUE (from_entity, to_entity, relationship_type)
);

CREATE TABLE telecom_experience_cases (
  case_id NUMBER PRIMARY KEY,
  case_ref VARCHAR2(80) NOT NULL UNIQUE,
  case_type VARCHAR2(120) NOT NULL,
  case_status VARCHAR2(30) NOT NULL,
  priority VARCHAR2(20) NOT NULL,
  risk_score NUMBER(5,2) NOT NULL,
  subscribers_affected NUMBER NOT NULL,
  service_value_at_risk NUMBER(14,2) NOT NULL
);

CREATE TABLE telecom_case_entities (
  case_id NUMBER NOT NULL REFERENCES telecom_experience_cases(case_id),
  entity_id NUMBER NOT NULL REFERENCES telecom_graph_entities(entity_id),
  role_in_case VARCHAR2(50) NOT NULL,
  confidence NUMBER(4,3) NOT NULL,
  PRIMARY KEY (case_id, entity_id, role_in_case)
);

INSERT INTO user_sdo_geom_metadata (table_name, column_name, diminfo, srid) VALUES
  ('NETWORK_SITES', 'LOCATION', MDSYS.SDO_DIM_ARRAY(MDSYS.SDO_DIM_ELEMENT('LON', -180, 180, 0.005), MDSYS.SDO_DIM_ELEMENT('LAT', -90, 90, 0.005)), 4326),
  ('SUBSCRIBERS', 'LOCATION', MDSYS.SDO_DIM_ARRAY(MDSYS.SDO_DIM_ELEMENT('LON', -180, 180, 0.005), MDSYS.SDO_DIM_ELEMENT('LAT', -90, 90, 0.005)), 4326);

CREATE INDEX idx_network_sites_spatial ON network_sites(location) INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2;
CREATE INDEX idx_subscribers_spatial ON subscribers(location) INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2;

INSERT INTO service_lines (service_line_id, service_line_name, network_program, headquarters_city, annual_service_value) VALUES
  (1, 'SignalBridge Mobile', '5G subscriber growth', 'New York', 825000000),
  (2, 'FiberPath Broadband', 'Fiber experience assurance', 'Chicago', 710000000),
  (3, 'PulsePoint 5G', 'Enterprise wireless', 'Dallas', 585000000),
  (4, 'RoamFlow Mobility', 'Roaming assurance', 'Houston', 475000000);

INSERT INTO telecom_services (service_id, service_line_id, service_name, service_category, service_segment, monthly_value, service_description, is_active) VALUES
  (101, 1, '5G Unlimited Mobile Plan', 'Mobile Service', 'Consumer Wireless', 85, 'Unlimited 5G mobile service for a family subscriber with congestion-aware network capacity planning.', 1),
  (102, 1, 'Premium International Roaming Pass', 'Roaming Services', 'Travel', 35, 'International roaming pass for subscribers travelling across high-demand airport and city corridors.', 1),
  (103, 2, 'Gigabit Fiber Install', 'Fiber Broadband', 'Residential Fiber', 120, 'Gigabit fiber installation with a scheduled field technician and residential service activation.', 1),
  (104, 2, 'Fiber Repair Appointment', 'Field Operations', 'Repair', 95, 'Fiber repair appointment for an outage, damaged line, or service-quality incident.', 1),
  (105, 3, '5G Business Consultation', '5G Services', 'Enterprise Wireless', 420, 'Private 5G consultation for an enterprise needing reliable high-capacity wireless connectivity.', 1),
  (106, 3, 'Home Wi-Fi Mesh Kit', 'Devices', 'Home Network', 180, 'Wi-Fi mesh device kit that improves home coverage after a broadband installation.', 1),
  (107, 4, 'Roaming Cost Coaching', 'Roaming Services', 'Bill Optimization', 25, 'Roaming billing support that explains international usage and reduces unexpected charges.', 1),
  (108, 1, 'Churn Risk Save Offer', 'Customer Retention', 'Save Offer', 20, 'Retention offer for a high-value subscriber at risk after an outage or repeated network-quality issue.', 1);

INSERT INTO network_sites (network_site_id, network_site_name, network_site_type, city, state_province, latitude, longitude, service_capacity_units, current_capacity_load_pct, location) VALUES
  (201, 'Hudson Yards 5G Macro Site', '5G macro site', 'New York', 'New York', 40.7540, -74.0020, 52000, 91.00, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-74.0020,40.7540,NULL),NULL,NULL)),
  (202, 'Atlanta East Fiber Hub', 'Fiber field hub', 'Atlanta', 'Georgia', 33.7490, -84.3880, 28000, 78.00, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-84.3880,33.7490,NULL),NULL,NULL)),
  (203, 'Dallas 5G Dispatch Center', 'NOC and dispatch center', 'Dallas', 'Texas', 32.7767, -96.7970, 36000, 69.00, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-96.7970,32.7767,NULL),NULL,NULL)),
  (204, 'Los Angeles Roaming Assurance Hub', 'Roaming operations hub', 'Los Angeles', 'California', 34.0522, -118.2437, 24000, 83.00, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-118.2437,34.0522,NULL),NULL,NULL)),
  (205, 'Birmingham Network Access Hub', 'Network access hub', 'Birmingham', 'Alabama', 33.5186, -86.8104, 21000, 67.00, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-86.8104,33.5186,NULL),NULL,NULL)),
  (206, 'Anchorage Service Assurance Hub', 'Service assurance hub', 'Anchorage', 'Alaska', 61.2181, -149.9003, 16000, 54.00, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-149.9003,61.2181,NULL),NULL,NULL)),
  (207, 'Phoenix 5G Capacity Hub', '5G capacity hub', 'Phoenix', 'Arizona', 33.4484, -112.0740, 31000, 81.00, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-112.0740,33.4484,NULL),NULL,NULL)),
  (208, 'Little Rock Fiber Access Hub', 'Fiber access hub', 'Little Rock', 'Arkansas', 34.7465, -92.2896, 18000, 62.00, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-92.2896,34.7465,NULL),NULL,NULL)),
  (209, 'Denver Network Edge', 'Network edge site', 'Denver', 'Colorado', 39.7392, -104.9903, 26000, 75.00, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-104.9903,39.7392,NULL),NULL,NULL)),
  (210, 'Hartford Service Hub', 'Service assurance hub', 'Hartford', 'Connecticut', 41.7658, -72.6734, 20000, 68.00, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-72.6734,41.7658,NULL),NULL,NULL)),
  (211, 'Wilmington Network Access Hub', 'Network access hub', 'Wilmington', 'Delaware', 39.7391, -75.5398, 15500, 58.00, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-75.5398,39.7391,NULL),NULL,NULL)),
  (212, 'Miami Service Assurance Hub', 'Service assurance hub', 'Miami', 'Florida', 25.7617, -80.1918, 34000, 89.00, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-80.1918,25.7617,NULL),NULL,NULL)),
  (213, 'Honolulu Network Access Hub', 'Network access hub', 'Honolulu', 'Hawaii', 21.3069, -157.8583, 18000, 64.00, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-157.8583,21.3069,NULL),NULL,NULL)),
  (214, 'Boise Network Edge', 'Network edge site', 'Boise', 'Idaho', 43.6150, -116.2023, 15000, 55.00, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-116.2023,43.6150,NULL),NULL,NULL)),
  (215, 'Chicago Fiber Core', 'Fiber core site', 'Chicago', 'Illinois', 41.8781, -87.6298, 39000, 82.00, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-87.6298,41.8781,NULL),NULL,NULL)),
  (216, 'Indianapolis Network Hub', 'Network access hub', 'Indianapolis', 'Indiana', 39.7684, -86.1581, 23000, 70.00, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-86.1581,39.7684,NULL),NULL,NULL)),
  (217, 'Des Moines Network Hub', 'Network access hub', 'Des Moines', 'Iowa', 41.5868, -93.6250, 17000, 61.00, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-93.6250,41.5868,NULL),NULL,NULL)),
  (218, 'Wichita Network Hub', 'Network access hub', 'Wichita', 'Kansas', 37.6872, -97.3301, 17500, 63.00, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-97.3301,37.6872,NULL),NULL,NULL)),
  (219, 'Louisville Fiber Hub', 'Fiber field hub', 'Louisville', 'Kentucky', 38.2527, -85.7585, 22000, 72.00, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-85.7585,38.2527,NULL),NULL,NULL)),
  (220, 'New Orleans Network Hub', 'Network access hub', 'New Orleans', 'Louisiana', 29.9511, -90.0715, 21500, 74.00, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-90.0715,29.9511,NULL),NULL,NULL)),
  (221, 'Portland Maine Access Hub', 'Network access hub', 'Portland', 'Maine', 43.6591, -70.2568, 14500, 56.00, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-70.2568,43.6591,NULL),NULL,NULL)),
  (222, 'Baltimore Network Edge', 'Network edge site', 'Baltimore', 'Maryland', 39.2904, -76.6122, 26000, 77.00, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-76.6122,39.2904,NULL),NULL,NULL)),
  (223, 'Boston Service Assurance Hub', 'Service assurance hub', 'Boston', 'Massachusetts', 42.3601, -71.0589, 32000, 80.00, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-71.0589,42.3601,NULL),NULL,NULL)),
  (224, 'Detroit Network Core', 'Network core site', 'Detroit', 'Michigan', 42.3314, -83.0458, 30000, 79.00, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-83.0458,42.3314,NULL),NULL,NULL)),
  (225, 'Minneapolis Network Hub', 'Network access hub', 'Minneapolis', 'Minnesota', 44.9778, -93.2650, 27000, 73.00, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-93.2650,44.9778,NULL),NULL,NULL)),
  (226, 'Jackson Network Hub', 'Network access hub', 'Jackson', 'Mississippi', 32.2988, -90.1848, 16000, 60.00, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-90.1848,32.2988,NULL),NULL,NULL)),
  (227, 'Kansas City Service Hub', 'Service assurance hub', 'Kansas City', 'Missouri', 39.0997, -94.5786, 25000, 71.00, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-94.5786,39.0997,NULL),NULL,NULL)),
  (228, 'Billings Network Access Hub', 'Network access hub', 'Billings', 'Montana', 45.7833, -108.5007, 13500, 51.00, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-108.5007,45.7833,NULL),NULL,NULL)),
  (229, 'Omaha Network Hub', 'Network access hub', 'Omaha', 'Nebraska', 41.2565, -95.9345, 18500, 64.00, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-95.9345,41.2565,NULL),NULL,NULL)),
  (230, 'Las Vegas 5G Capacity Hub', '5G capacity hub', 'Las Vegas', 'Nevada', 36.1699, -115.1398, 29000, 84.00, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-115.1398,36.1699,NULL),NULL,NULL)),
  (231, 'Manchester Network Hub', 'Network access hub', 'Manchester', 'New Hampshire', 42.9956, -71.4548, 15000, 57.00, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-71.4548,42.9956,NULL),NULL,NULL)),
  (232, 'Newark 5G Core Site', '5G core site', 'Newark', 'New Jersey', 40.7357, -74.1724, 33000, 86.00, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-74.1724,40.7357,NULL),NULL,NULL)),
  (233, 'Albuquerque Network Hub', 'Network access hub', 'Albuquerque', 'New Mexico', 35.0844, -106.6504, 19000, 66.00, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-106.6504,35.0844,NULL),NULL,NULL)),
  (234, 'Charlotte Service Assurance Hub', 'Service assurance hub', 'Charlotte', 'North Carolina', 35.2271, -80.8431, 32000, 78.00, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-80.8431,35.2271,NULL),NULL,NULL)),
  (235, 'Fargo Network Access Hub', 'Network access hub', 'Fargo', 'North Dakota', 46.8772, -96.7898, 14000, 53.00, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-96.7898,46.8772,NULL),NULL,NULL)),
  (236, 'Columbus Network Hub', 'Network access hub', 'Columbus', 'Ohio', 39.9612, -82.9988, 29000, 76.00, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-82.9988,39.9612,NULL),NULL,NULL)),
  (237, 'Oklahoma City Access Hub', 'Network access hub', 'Oklahoma City', 'Oklahoma', 35.4676, -97.5164, 21000, 65.00, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-97.5164,35.4676,NULL),NULL,NULL)),
  (238, 'Portland Oregon Network Hub', 'Network access hub', 'Portland', 'Oregon', 45.5152, -122.6784, 24000, 74.00, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-122.6784,45.5152,NULL),NULL,NULL)),
  (239, 'Philadelphia Network Core', 'Network core site', 'Philadelphia', 'Pennsylvania', 39.9526, -75.1652, 34000, 83.00, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-75.1652,39.9526,NULL),NULL,NULL)),
  (240, 'Providence Network Hub', 'Network access hub', 'Providence', 'Rhode Island', 41.8240, -71.4128, 15000, 62.00, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-71.4128,41.8240,NULL),NULL,NULL)),
  (241, 'Charleston Network Hub', 'Network access hub', 'Charleston', 'South Carolina', 32.7765, -79.9311, 21000, 69.00, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-79.9311,32.7765,NULL),NULL,NULL)),
  (242, 'Sioux Falls Network Hub', 'Network access hub', 'Sioux Falls', 'South Dakota', 43.5446, -96.7311, 15000, 54.00, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-96.7311,43.5446,NULL),NULL,NULL)),
  (243, 'Nashville Network Hub', 'Network access hub', 'Nashville', 'Tennessee', 36.1627, -86.7816, 27000, 77.00, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-86.7816,36.1627,NULL),NULL,NULL)),
  (244, 'Salt Lake City Network Hub', 'Network access hub', 'Salt Lake City', 'Utah', 40.7608, -111.8910, 23000, 72.00, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-111.8910,40.7608,NULL),NULL,NULL)),
  (245, 'Burlington Network Access Hub', 'Network access hub', 'Burlington', 'Vermont', 44.4759, -73.2121, 13000, 50.00, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-73.2121,44.4759,NULL),NULL,NULL)),
  (246, 'Richmond Network Core', 'Network core site', 'Richmond', 'Virginia', 37.5407, -77.4360, 28000, 79.00, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-77.4360,37.5407,NULL),NULL,NULL)),
  (247, 'Seattle Network Access Hub', 'Network access hub', 'Seattle', 'Washington', 47.6062, -122.3321, 33000, 85.00, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-122.3321,47.6062,NULL),NULL,NULL)),
  (248, 'Charleston West Virginia Hub', 'Network access hub', 'Charleston', 'West Virginia', 38.3498, -81.6326, 14000, 59.00, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-81.6326,38.3498,NULL),NULL,NULL)),
  (249, 'Milwaukee Network Hub', 'Network access hub', 'Milwaukee', 'Wisconsin', 43.0389, -87.9065, 25000, 71.00, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-87.9065,43.0389,NULL),NULL,NULL)),
  (250, 'Cheyenne Network Access Hub', 'Network access hub', 'Cheyenne', 'Wyoming', 41.1400, -104.8202, 12000, 48.00, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-104.8202,41.1400,NULL),NULL,NULL)),
  (251, 'Buffalo 5G Macro Site', '5G macro site', 'Buffalo', 'New York', 42.8864, -78.8784, 22000, 74.00, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-78.8784,42.8864,NULL),NULL,NULL)),
  (252, 'Savannah Fiber Access Hub', 'Fiber access hub', 'Savannah', 'Georgia', 32.0809, -81.0912, 18000, 71.00, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-81.0912,32.0809,NULL),NULL,NULL)),
  (253, 'Houston 5G Capacity Hub', '5G capacity hub', 'Houston', 'Texas', 29.7604, -95.3698, 33000, 82.00, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-95.3698,29.7604,NULL),NULL,NULL)),
  (254, 'San Francisco Network Edge', 'Network edge site', 'San Francisco', 'California', 37.7749, -122.4194, 31000, 88.00, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-122.4194,37.7749,NULL),NULL,NULL));

INSERT INTO network_capacity (capacity_id, service_id, network_site_id, capacity_available, capacity_reserved, capacity_incoming, escalation_threshold, target_capacity_increment) VALUES
  (301, 101, 201, 420, 380, 120, 600, 500), (302, 101, 203, 980, 240, 200, 500, 400),
  (303, 103, 202, 175, 160, 80, 300, 250), (304, 104, 202, 42, 36, 32, 80, 100),
  (305, 105, 203, 88, 62, 40, 120, 100), (306, 106, 201, 140, 95, 50, 120, 150),
  (307, 102, 204, 225, 185, 100, 300, 250), (308, 108, 203, 60, 45, 80, 100, 180);

INSERT INTO network_capacity (capacity_id, service_id, network_site_id, capacity_available, capacity_reserved, capacity_incoming, escalation_threshold, target_capacity_increment)
SELECT 3000 + network_site_id,
       101 + MOD(network_site_id, 8),
       network_site_id,
       ROUND(service_capacity_units * (100 - current_capacity_load_pct) / 100),
       ROUND(service_capacity_units * current_capacity_load_pct / 100),
       ROUND(service_capacity_units * 0.10),
       80,
       ROUND(service_capacity_units * 0.15)
FROM network_sites
WHERE network_site_id >= 205;

INSERT INTO subscribers (subscriber_id, subscriber_name, city, state_province, subscriber_tier, service_value, location) VALUES
  (401, 'Avery Chen', 'New York', 'New York', 'preferred', 1440, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-73.9857,40.7484,NULL),NULL,NULL)),
  (402, 'Morgan Patel', 'Atlanta', 'Georgia', 'vip', 2260, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-84.3900,33.7550,NULL),NULL,NULL)),
  (403, 'Jordan Williams', 'Dallas', 'Texas', 'preferred', 1880, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-96.8100,32.7900,NULL),NULL,NULL)),
  (404, 'Riley Gomez', 'Los Angeles', 'California', 'standard', 860, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-118.2500,34.0600,NULL),NULL,NULL)),
  (405, 'Taylor Brooks', 'New York', 'New York', 'vip', 3120, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-73.9700,40.7700,NULL),NULL,NULL)),
  (406, 'Casey Morgan', 'Atlanta', 'Georgia', 'standard', 720, MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-84.3600,33.7400,NULL),NULL,NULL));

INSERT INTO subscribers (subscriber_id, subscriber_name, city, state_province, subscriber_tier, service_value, location)
SELECT 10000 + network_site_id,
       'Planning subscriber - ' || city,
       city,
       state_province,
       CASE WHEN current_capacity_load_pct >= 80 THEN 'preferred' ELSE 'standard' END,
       ROUND(service_capacity_units * 0.06),
       MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(longitude + 0.015, latitude + 0.015,NULL),NULL,NULL)
FROM network_sites
WHERE network_site_id >= 205;

INSERT INTO subscriber_signals (signal_id, signal_channel, signal_text, signal_time, urgency_score, sentiment_score, momentum_band, exposure_count, advocate_name, region) VALUES
  (501, 'community_forum', 'Game-day 5G congestion is affecting families near Hudson Yards and they need capacity restored before the weekend.', TIMESTAMP '2026-07-15 09:00:00', 96, -0.620, 'mega_viral', 31200, 'Northeast Network Watch', 'Northeast'),
  (502, 'support_chat', 'Our enterprise fiber circuit is down in Atlanta and we need an urgent repair appointment.', TIMESTAMP '2026-07-15 10:30:00', 95, -0.710, 'viral', 7100, 'Enterprise Care Desk', 'Southeast'),
  (503, 'social', 'Subscribers need a clearer explanation for international roaming charges after summer travel.', TIMESTAMP '2026-07-15 11:15:00', 86, -0.280, 'viral', 12600, 'Travel Connectivity Forum', 'West'),
  (504, 'community_forum', 'Families are comparing mobile plans after repeated 5G congestion in the stadium district.', TIMESTAMP '2026-07-15 12:00:00', 90, -0.420, 'rising', 18420, 'Family Plan Advocates', 'Northeast'),
  (505, 'support_chat', 'A fiber installation was missed and the subscriber needs a new technician window.', TIMESTAMP '2026-07-15 12:40:00', 72, -0.350, 'rising', 2400, 'Field Service Care', 'Southeast'),
  (506, 'social', 'The home Wi-Fi mesh kit fixed coverage in the back rooms after our broadband install.', TIMESTAMP '2026-07-15 13:10:00', 41, 0.720, 'normal', 980, 'Connected Home Review', 'Northeast'),
  (507, 'support_chat', 'Our private 5G team needs a consultation before the manufacturing line expansion.', TIMESTAMP '2026-07-15 14:20:00', 78, 0.380, 'rising', 2900, 'Enterprise Operations', 'Central'),
  (508, 'community_forum', 'A high-value family is considering cancelling after an outage and needs a retention offer.', TIMESTAMP '2026-07-15 15:00:00', 90, -0.680, 'viral', 9700, 'Retention Escalations', 'Central'),
  (509, 'social', 'Roaming help was useful but the billing explanation should arrive before travel.', TIMESTAMP '2026-07-15 15:35:00', 58, 0.120, 'normal', 1600, 'Roam Smart Community', 'West'),
  (510, 'support_chat', '5G capacity is tight at the event venue and service activation is taking too long.', TIMESTAMP '2026-07-15 16:10:00', 92, -0.500, 'viral', 13800, 'Venue Support Team', 'Northeast'),
  (511, 'community_forum', 'Atlanta fiber subscribers need status updates while the repair crew is assigned.', TIMESTAMP '2026-07-15 17:00:00', 88, -0.460, 'rising', 6200, 'Atlanta Service Updates', 'Southeast'),
  (512, 'social', 'A family plan with unlimited mobile data is important before the school year starts.', TIMESTAMP '2026-07-15 18:20:00', 65, 0.510, 'rising', 5400, 'Family Mobile Network', 'Central');

INSERT INTO subscriber_signals (signal_id, signal_channel, signal_text, signal_time, urgency_score, sentiment_score, momentum_band, exposure_count, advocate_name, region)
SELECT 5000 + network_site_id,
       'network_alert',
       'Seer Comms is conducting a routine network-planning review for ' || city || ', ' || state_province || ' based on current site conditions.',
       TIMESTAMP '2026-07-16 09:00:00' + NUMTODSINTERVAL(network_site_id - 200, 'MINUTE'),
       ROUND(current_capacity_load_pct),
       CASE WHEN current_capacity_load_pct >= 80 THEN -0.480 ELSE -0.180 END,
       CASE WHEN current_capacity_load_pct >= 80 THEN 'rising' ELSE 'normal' END,
       ROUND(service_capacity_units * current_capacity_load_pct / 10),
       'National Service Assurance',
       state_province
FROM network_sites
WHERE network_site_id >= 205;

INSERT INTO service_orders (service_order_id, subscriber_id, network_site_id, source_signal_id, service_status, service_value, dispatch_cost, demand_score, created_at) VALUES
  (601, 401, 201, 501, 'Assigned', 85, 0, 96, TIMESTAMP '2026-07-15 09:30:00'),
  (602, 402, 202, 502, 'Routed', 95, 45, 95, TIMESTAMP '2026-07-15 10:45:00'),
  (603, 404, 204, 503, 'Completed', 25, 0, 86, TIMESTAMP '2026-07-15 11:30:00'),
  (604, 405, 201, 504, 'Scheduled', 85, 0, 90, TIMESTAMP '2026-07-15 12:10:00'),
  (605, 406, 202, 505, 'Assigned', 120, 60, 72, TIMESTAMP '2026-07-15 13:00:00'),
  (606, 401, 201, 506, 'Completed', 180, 0, 41, TIMESTAMP '2026-07-15 13:30:00'),
  (607, 403, 203, 507, 'Scheduled', 420, 0, 78, TIMESTAMP '2026-07-15 14:35:00'),
  (608, 403, 203, 508, 'Assigned', 20, 0, 90, TIMESTAMP '2026-07-15 15:20:00');

INSERT INTO service_orders (service_order_id, subscriber_id, network_site_id, source_signal_id, service_status, service_value, dispatch_cost, demand_score, created_at)
SELECT 6000 + network_site_id,
       10000 + network_site_id,
       network_site_id,
       5000 + network_site_id,
       CASE WHEN current_capacity_load_pct >= 80 THEN 'Assigned' ELSE 'Scheduled' END,
       CASE WHEN MOD(network_site_id, 2) = 0 THEN 85 ELSE 120 END,
       CASE WHEN current_capacity_load_pct >= 80 THEN 75 ELSE 30 END,
       ROUND(current_capacity_load_pct),
       TIMESTAMP '2026-07-16 10:00:00' + NUMTODSINTERVAL(network_site_id - 200, 'MINUTE')
FROM network_sites
WHERE network_site_id >= 205;

INSERT INTO service_order_items (service_order_item_id, service_order_id, service_id, quantity, monthly_value) VALUES
  (701,601,101,1,85), (702,602,104,1,95), (703,603,107,1,25), (704,604,101,1,85),
  (705,605,103,1,120), (706,606,106,1,180), (707,607,105,1,420), (708,608,108,1,20);

INSERT INTO service_order_items (service_order_item_id, service_order_id, service_id, quantity, monthly_value)
SELECT 7000 + network_site_id,
       6000 + network_site_id,
       101 + MOD(network_site_id, 8),
       1,
       CASE WHEN MOD(network_site_id, 2) = 0 THEN 85 ELSE 120 END
FROM network_sites
WHERE network_site_id >= 205;

INSERT INTO service_embeddings (service_id, embedding_text, embedding, embedding_model)
SELECT service_id, service_description,
       VECTOR_EMBEDDING(ADMIN.ALL_MINILM_L12_V2 USING service_description AS DATA),
       'ALL_MINILM_L12_V2'
FROM telecom_services;

INSERT INTO signal_embeddings (signal_id, embedding_text, embedding, embedding_model)
SELECT signal_id, signal_text,
       VECTOR_EMBEDDING(ADMIN.ALL_MINILM_L12_V2 USING signal_text AS DATA),
       'ALL_MINILM_L12_V2'
FROM subscriber_signals;

CREATE VECTOR INDEX idx_service_embeddings_vec ON service_embeddings(embedding)
  ORGANIZATION NEIGHBOR PARTITIONS WITH DISTANCE COSINE WITH TARGET ACCURACY 95;
CREATE VECTOR INDEX idx_signal_embeddings_vec ON signal_embeddings(embedding)
  ORGANIZATION NEIGHBOR PARTITIONS WITH DISTANCE COSINE WITH TARGET ACCURACY 95;

INSERT INTO signal_service_matches (signal_id, service_id, similarity_score, match_rank, match_method) VALUES
  (501,101,0.94210,1,'validated_semantic'), (502,104,0.93750,1,'validated_semantic'),
  (503,107,0.92830,1,'validated_semantic'), (504,101,0.91920,1,'validated_semantic'),
  (505,103,0.90140,1,'validated_semantic'), (506,106,0.89510,1,'validated_semantic'),
  (507,105,0.91280,1,'validated_semantic'), (508,108,0.93360,1,'validated_semantic'),
  (509,107,0.88290,1,'validated_semantic'), (510,101,0.94040,1,'validated_semantic'),
  (511,104,0.90620,1,'validated_semantic'), (512,101,0.87180,1,'validated_semantic');

INSERT INTO telecom_graph_entities (entity_id, entity_key, display_name, entity_type, region, city, risk_score, experience_score, affected_count, signal_count, service_value) VALUES
  (801,'SUB-5G-1041','Stadium district family plan cluster','subscriber','Northeast','New York',94.5,42.0,18420,88,1285000),
  (802,'SITE-NY-5G-018','Hudson Yards 5G macro site','network_site','Northeast','New York',91.0,48.0,31200,74,1880000),
  (803,'SVC-PULSE-5G','Unlimited 5G service line','service_line','Northeast','New York',87.5,55.0,22400,63,1650000),
  (804,'TEAM-COVERAGE-NE','Coverage Assurance Team Northeast','account_advocate','Northeast','New York',76.0,61.0,9200,42,740000),
  (805,'CREW-NY-RAN-4','New York RAN field crew 4','field_crew','Northeast','New York',68.0,72.0,5100,14,410000),
  (806,'OUT-EVENT-501','Game-day 5G congestion spike','outage_event','Northeast','New York',96.0,35.0,31200,118,2140000),
  (807,'CASE-CAP-501','Capacity reroute case CAP-501','support_case','Northeast','New York',93.0,41.0,30100,96,2010000),
  (808,'ENT-FIBER-7782','Metro healthcare enterprise fiber account','enterprise_account','Southeast','Atlanta',92.0,45.0,4300,51,3420000),
  (809,'SITE-ATL-FIBER-04','Atlanta east fiber hub','network_site','Southeast','Atlanta',88.0,58.0,7600,39,960000),
  (810,'OUT-FIBER-224','Fiber cut affecting enterprise corridor','outage_event','Southeast','Atlanta',95.0,38.0,7100,82,2180000),
  (811,'CASE-ROAM-109','Roaming billing surge case','support_case','West','Los Angeles',86.0,49.0,12600,59,1120000),
  (812,'SUB-FAM-5570','Family plan churn-risk subscriber cluster','subscriber','Central','Dallas',88.0,47.0,9300,61,940000);

INSERT INTO telecom_graph_entities (entity_id, entity_key, display_name, entity_type, region, city, risk_score, experience_score, affected_count, signal_count, service_value)
SELECT 8000 + network_site_id,
       'SITE-PLAN-' || network_site_id,
       network_site_name,
       'network_site',
       state_province,
       city,
       current_capacity_load_pct,
       100 - current_capacity_load_pct,
       ROUND(service_capacity_units * current_capacity_load_pct / 10),
       ROUND(current_capacity_load_pct),
       service_capacity_units * 100
FROM network_sites
WHERE network_site_id >= 205;

INSERT INTO telecom_graph_relationships (relationship_id, from_entity, to_entity, relationship_type, strength, event_count, affected_count) VALUES
  (901,801,803,'subscribes_to',0.944,18420,18420), (902,801,802,'served_by',0.921,112,18420),
  (903,801,806,'impacted_by',0.982,118,18420), (904,806,807,'escalates_case',0.965,96,30100),
  (905,807,805,'assigned_crew',0.841,18,4800), (906,804,801,'reports_signal',0.772,42,9200),
  (907,808,809,'served_by',0.902,39,4300), (908,810,808,'impacted_by',0.891,82,4300),
  (909,810,809,'service_path',0.834,15,4200), (910,811,803,'subscribes_to',0.784,53,12600),
  (911,812,803,'subscribes_to',0.908,61,9300), (912,812,807,'churn_risk_link',0.879,44,9300);

INSERT INTO telecom_experience_cases (case_id, case_ref, case_type, case_status, priority, risk_score, subscribers_affected, service_value_at_risk) VALUES
  (1001,'TEL-5G-2026-501','5G congestion spike around event venues','escalated','critical',96,31200,2140000),
  (1002,'TEL-FIBER-2026-224','Fiber outage affecting enterprise accounts','routed','critical',95,7100,2180000),
  (1003,'TEL-ROAM-2026-109','Roaming billing surge linked to travel corridors','investigating','high',86,12600,1120000);

INSERT INTO telecom_case_entities (case_id, entity_id, role_in_case, confidence) VALUES
  (1001,801,'subscriber_cluster',0.982), (1001,802,'network_site',0.965), (1001,806,'seed_signal',0.990), (1001,807,'support_case',0.975),
  (1002,808,'affected_account',0.940), (1002,809,'network_site',0.930), (1002,810,'seed_signal',0.985),
  (1003,811,'support_case',0.910);

CREATE PROPERTY GRAPH telecom_experience_network
  VERTEX TABLES (
    telecom_graph_entities KEY (entity_id) LABEL entity
      PROPERTIES (entity_id, entity_key, display_name, entity_type, region, city, risk_score, experience_score, affected_count, signal_count, service_value),
    telecom_experience_cases KEY (case_id) LABEL experience_case
      PROPERTIES (case_id, case_ref, case_type, case_status, priority, risk_score, subscribers_affected, service_value_at_risk)
  )
  EDGE TABLES (
    telecom_graph_relationships KEY (relationship_id)
      SOURCE KEY (from_entity) REFERENCES telecom_graph_entities (entity_id)
      DESTINATION KEY (to_entity) REFERENCES telecom_graph_entities (entity_id)
      LABEL related_to PROPERTIES (relationship_id, relationship_type, strength, event_count, affected_count),
    telecom_case_entities KEY (case_id, entity_id, role_in_case)
      SOURCE KEY (case_id) REFERENCES telecom_experience_cases (case_id)
      DESTINATION KEY (entity_id) REFERENCES telecom_graph_entities (entity_id)
      LABEL case_involves PROPERTIES (role_in_case, confidence)
  );

CREATE OR REPLACE VIEW network_capacity_surge_training_v AS
SELECT network_site_id AS training_case_id,
       service_capacity_units,
       current_capacity_load_pct,
       CASE
         WHEN current_capacity_load_pct >= 80 THEN 'ESCALATE'
         ELSE 'MONITOR'
       END AS escalation_label
FROM network_sites;

CREATE TABLE network_capacity_surge_settings (
  setting_name VARCHAR2(30),
  setting_value VARCHAR2(4000)
);

BEGIN
  INSERT INTO network_capacity_surge_settings (setting_name, setting_value)
  VALUES (DBMS_DATA_MINING.ALGO_NAME, DBMS_DATA_MINING.ALGO_DECISION_TREE);
END;
/

BEGIN
  DBMS_DATA_MINING.CREATE_MODEL(
    model_name          => 'NETWORK_CAPACITY_SURGE_MODEL',
    mining_function     => DBMS_DATA_MINING.CLASSIFICATION,
    data_table_name     => 'NETWORK_CAPACITY_SURGE_TRAINING_V',
    case_id_column_name => 'TRAINING_CASE_ID',
    target_column_name  => 'ESCALATION_LABEL',
    settings_table_name => 'NETWORK_CAPACITY_SURGE_SETTINGS'
  );
END;
/

CREATE OR REPLACE JSON RELATIONAL DUALITY VIEW orders_dv AS
SELECT JSON {
  '_id' : o.service_order_id,
  'subscriberId' : o.subscriber_id,
  'networkSiteId' : o.network_site_id,
  'status' : o.service_status,
  'serviceValue' : o.service_value,
  'demandScore' : o.demand_score,
  'items' : [
    SELECT JSON {
      '_id' : i.service_order_item_id,
      'serviceId' : i.service_id,
      'quantity' : i.quantity,
      'monthlyValue' : i.monthly_value
    }
    FROM service_order_items i WITH UPDATE
    WHERE i.service_order_id = o.service_order_id
  ]
}
FROM service_orders o WITH UPDATE;

COMMIT;

PROMPT Telco deterministic validation summary
SELECT 'SERVICE_LINES' AS object_name, COUNT(*) AS row_count FROM service_lines UNION ALL
SELECT 'TELECOM_SERVICES', COUNT(*) FROM telecom_services UNION ALL
SELECT 'NETWORK_SITES', COUNT(*) FROM network_sites UNION ALL
SELECT 'NETWORK_CAPACITY', COUNT(*) FROM network_capacity UNION ALL
SELECT 'SUBSCRIBERS', COUNT(*) FROM subscribers UNION ALL
SELECT 'SUBSCRIBER_SIGNALS', COUNT(*) FROM subscriber_signals UNION ALL
SELECT 'SERVICE_ORDERS', COUNT(*) FROM service_orders UNION ALL
SELECT 'SERVICE_ORDER_ITEMS', COUNT(*) FROM service_order_items UNION ALL
SELECT 'SERVICE_EMBEDDINGS', COUNT(*) FROM service_embeddings UNION ALL
SELECT 'SIGNAL_EMBEDDINGS', COUNT(*) FROM signal_embeddings UNION ALL
SELECT 'SIGNAL_SERVICE_MATCHES', COUNT(*) FROM signal_service_matches UNION ALL
SELECT 'TELECOM_GRAPH_ENTITIES', COUNT(*) FROM telecom_graph_entities UNION ALL
SELECT 'TELECOM_GRAPH_RELATIONSHIPS', COUNT(*) FROM telecom_graph_relationships UNION ALL
SELECT 'TELECOM_EXPERIENCE_CASES', COUNT(*) FROM telecom_experience_cases UNION ALL
SELECT 'TELECOM_CASE_ENTITIES', COUNT(*) FROM telecom_case_entities UNION ALL
SELECT 'NETWORK_CAPACITY_SURGE_MODEL', COUNT(*) FROM user_mining_models
WHERE model_name = 'NETWORK_CAPACITY_SURGE_MODEL' UNION ALL
SELECT 'TELCO_INVALID_OBJECTS', COUNT(*) FROM user_objects
WHERE status <> 'VALID'
  AND object_name IN (
    'SERVICE_LINES', 'TELECOM_SERVICES', 'NETWORK_SITES', 'NETWORK_CAPACITY',
    'SUBSCRIBERS', 'SUBSCRIBER_SIGNALS', 'SERVICE_ORDERS', 'SERVICE_ORDER_ITEMS',
    'SERVICE_EMBEDDINGS', 'SIGNAL_EMBEDDINGS', 'SIGNAL_SERVICE_MATCHES',
    'TELECOM_GRAPH_ENTITIES', 'TELECOM_GRAPH_RELATIONSHIPS',
    'TELECOM_EXPERIENCE_CASES', 'TELECOM_CASE_ENTITIES', 'ORDERS_DV',
    'NETWORK_CAPACITY_SURGE_TRAINING_V', 'NETWORK_CAPACITY_SURGE_MODEL',
    'TELECOM_EXPERIENCE_NETWORK'
  )
ORDER BY object_name;

SELECT VECTOR_DIMENSION_COUNT(embedding) AS embedding_dimensions,
       COUNT(*) AS service_embedding_rows
FROM service_embeddings
GROUP BY VECTOR_DIMENSION_COUNT(embedding);

SELECT object_name, object_type, status
FROM user_objects
WHERE object_name IN ('ORDERS_DV', 'TELECOM_EXPERIENCE_NETWORK')
ORDER BY object_name;

SELECT model_name, mining_function
FROM user_mining_models
WHERE model_name = 'NETWORK_CAPACITY_SURGE_MODEL';
