-- Connects as LLUSER, recreates the healthcare workshop objects, and validates them.
-- Usage: @02-lluser-create-healthcare-objects.sql "<lluser-password>" "<service-alias>"

SET DEFINE ON
SET VERIFY OFF
SET SERVEROUTPUT ON
SET SQLFORMAT ANSICONSOLE
WHENEVER SQLERROR EXIT SQL.SQLCODE

DEFINE lluser_password = '&1'
DEFINE service_alias = '&2'

CONNECT LLUSER/"&&lluser_password"@&&service_alias

BEGIN
  IF USER <> 'LLUSER' THEN
    RAISE_APPLICATION_ERROR(
      -20010,
      'Healthcare objects must be created as LLUSER. Current user: ' || USER
    );
  END IF;
  DBMS_OUTPUT.PUT_LINE('Connected as LLUSER.');
END;
/

SET DEFINE OFF

BEGIN
  EXECUTE IMMEDIATE 'DROP PROPERTY GRAPH care_pathway_graph';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE NOT IN (-4043, -4091, -42421) THEN
      RAISE;
    END IF;
END;
/

BEGIN
  DBMS_DATA_MINING.DROP_MODEL('CARE_DEMAND_RISK_MODEL', TRUE);
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE NOT IN (-40102, -40104, -4043) THEN
      RAISE;
    END IF;
END;
/

BEGIN
  FOR object_name IN (
    SELECT column_value
    FROM TABLE(sys.odcivarchar2list(
      'CARE_SERVICE_REQUESTS_DV',
      'HEALTHCARE_COMMAND_CENTER_V',
      'HEALTHCARE_AGENT_ACTIONS_V',
      'CARE_DEMAND_FORECASTS_V',
      'CARE_SERVICE_REQUESTS_V',
      'CARE_LOGISTICS_SITES_V',
      'QUALITY_CAPACITY_SIGNALS_V',
      'CARE_SERVICES_V'
    ))
  ) LOOP
    BEGIN
      EXECUTE IMMEDIATE 'DROP VIEW ' || object_name.column_value;
    EXCEPTION
      WHEN OTHERS THEN
        IF SQLCODE <> -942 THEN
          RAISE;
        END IF;
    END;
  END LOOP;
END;
/

BEGIN
  FOR table_name IN (
    SELECT column_value
    FROM TABLE(sys.odcivarchar2list(
      'HC_MODEL_SETTINGS',
      'HC_DEMAND_TRAINING',
      'HC_AGENT_ACTIONS',
      'HC_CARE_EDGES',
      'HC_CARE_NODES',
      'HC_DEMAND_FORECASTS',
      'HC_REQUEST_ITEMS',
      'HC_SERVICE_REQUESTS',
      'HC_LOGISTICS_SITES',
      'HC_CARE_SITES',
      'HC_SEMANTIC_MATCHES',
      'HC_QUALITY_SIGNALS',
      'HC_CARE_SERVICES'
    ))
  ) LOOP
    BEGIN
      EXECUTE IMMEDIATE
        'DROP TABLE ' || table_name.column_value || ' CASCADE CONSTRAINTS PURGE';
    EXCEPTION
      WHEN OTHERS THEN
        IF SQLCODE <> -942 THEN
          RAISE;
        END IF;
    END;
  END LOOP;
END;
/

CREATE TABLE hc_care_services (
  service_id         NUMBER PRIMARY KEY,
  service_name       VARCHAR2(160) NOT NULL,
  category           VARCHAR2(80) NOT NULL,
  provider_network   VARCHAR2(120) NOT NULL,
  description        VARCHAR2(1000) NOT NULL,
  unit_value         NUMBER(12,2) NOT NULL,
  service_embedding  VECTOR(384, FLOAT32)
);

CREATE TABLE hc_quality_signals (
  signal_id          NUMBER PRIMARY KEY,
  signal_type        VARCHAR2(60) NOT NULL,
  criticality        VARCHAR2(20) NOT NULL,
  source_name        VARCHAR2(120) NOT NULL,
  signal_text        VARCHAR2(1000) NOT NULL,
  network_impact     VARCHAR2(20) NOT NULL,
  next_step          VARCHAR2(120) NOT NULL,
  posted_at          DATE NOT NULL,
  service_id         NUMBER NOT NULL REFERENCES hc_care_services(service_id),
  signal_embedding   VECTOR(384, FLOAT32)
);

CREATE TABLE hc_semantic_matches (
  match_id           NUMBER PRIMARY KEY,
  service_id         NUMBER NOT NULL REFERENCES hc_care_services(service_id),
  signal_id          NUMBER NOT NULL REFERENCES hc_quality_signals(signal_id),
  similarity_score   NUMBER(6,4) NOT NULL
);

CREATE TABLE hc_care_sites (
  care_site_id       NUMBER PRIMARY KEY,
  care_site_name     VARCHAR2(160) NOT NULL,
  city               VARCHAR2(80) NOT NULL,
  state_code         VARCHAR2(2) NOT NULL,
  region             VARCHAR2(80) NOT NULL,
  site_segment       VARCHAR2(40) NOT NULL,
  followup_risk      NUMBER(5,2) NOT NULL,
  location           MDSYS.SDO_GEOMETRY NOT NULL
);

CREATE TABLE hc_logistics_sites (
  logistics_site_id  NUMBER PRIMARY KEY,
  logistics_name     VARCHAR2(180) NOT NULL,
  city               VARCHAR2(80) NOT NULL,
  state_code         VARCHAR2(2) NOT NULL,
  service_supported  VARCHAR2(160) NOT NULL,
  capacity_units     NUMBER NOT NULL,
  pending_requests   NUMBER NOT NULL,
  active_alerts      NUMBER NOT NULL,
  current_load_pct   NUMBER(5,2) NOT NULL,
  site_status        VARCHAR2(20) NOT NULL,
  location           MDSYS.SDO_GEOMETRY NOT NULL
);

CREATE TABLE hc_service_requests (
  request_id         NUMBER PRIMARY KEY,
  care_site_id       NUMBER NOT NULL REFERENCES hc_care_sites(care_site_id),
  logistics_site_id  NUMBER NOT NULL REFERENCES hc_logistics_sites(logistics_site_id),
  request_status     VARCHAR2(30) NOT NULL,
  request_value      NUMBER(12,2) NOT NULL,
  logistics_cost     NUMBER(10,2) NOT NULL,
  demand_score       NUMBER(5,2) NOT NULL,
  created_at         DATE NOT NULL
);

CREATE TABLE hc_request_items (
  item_id            NUMBER PRIMARY KEY,
  request_id         NUMBER NOT NULL REFERENCES hc_service_requests(request_id),
  service_id         NUMBER NOT NULL REFERENCES hc_care_services(service_id),
  quantity           NUMBER NOT NULL,
  unit_cost          NUMBER(10,2) NOT NULL,
  line_value         NUMBER(12,2)
    GENERATED ALWAYS AS (quantity * unit_cost) VIRTUAL
);

CREATE TABLE hc_demand_forecasts (
  forecast_id        NUMBER PRIMARY KEY,
  service_id         NUMBER NOT NULL REFERENCES hc_care_services(service_id),
  region             VARCHAR2(80) NOT NULL,
  forecast_date      DATE NOT NULL,
  predicted_demand   NUMBER NOT NULL,
  demand_risk_factor NUMBER(6,2) NOT NULL
);

CREATE TABLE hc_care_nodes (
  node_id            NUMBER PRIMARY KEY,
  node_type          VARCHAR2(40) NOT NULL,
  node_label         VARCHAR2(180) NOT NULL,
  risk_score         NUMBER(5,2) NOT NULL,
  pathway_volume     NUMBER NOT NULL
);

CREATE TABLE hc_care_edges (
  edge_id            NUMBER PRIMARY KEY,
  source_node_id     NUMBER NOT NULL REFERENCES hc_care_nodes(node_id),
  target_node_id     NUMBER NOT NULL REFERENCES hc_care_nodes(node_id),
  relationship_type  VARCHAR2(60) NOT NULL,
  evidence_score     NUMBER(5,2) NOT NULL
);

CREATE TABLE hc_agent_actions (
  action_id          NUMBER PRIMARY KEY,
  action_type        VARCHAR2(40) NOT NULL,
  team_name          VARCHAR2(80) NOT NULL,
  prompt_text        VARCHAR2(500) NOT NULL,
  result_summary     VARCHAR2(500) NOT NULL,
  tool_name          VARCHAR2(80) NOT NULL,
  confidence         NUMBER(5,2) NOT NULL,
  action_status      VARCHAR2(20) NOT NULL,
  created_at         DATE NOT NULL
);

CREATE TABLE hc_demand_training (
  training_id        NUMBER PRIMARY KEY,
  current_requests   NUMBER NOT NULL,
  signal_count       NUMBER NOT NULL,
  capacity_ratio     NUMBER(6,3) NOT NULL,
  critical_alerts    NUMBER NOT NULL,
  risk_flag          VARCHAR2(4) NOT NULL
);

CREATE TABLE hc_model_settings (
  setting_name       VARCHAR2(30),
  setting_value      VARCHAR2(4000)
);

INSERT INTO hc_care_services
  (service_id, service_name, category, provider_network, description, unit_value)
VALUES
  (1, 'Infusion Center Slot Bundle - Continuity Lot 2', 'Specialty Care',
   'Regional Oncology Network',
   'Oncology infusion center slot capacity with continuity scheduling and staffing coverage.',
   640.00),
  (2, 'Infusion Center Slot Bundle - Continuity Lot 3', 'Specialty Care',
   'Regional Oncology Network',
   'Oncology infusion capacity package for expanded treatment schedules and chair availability.',
   675.00),
  (3, 'Infusion Center Slot Bundle', 'Specialty Care',
   'Regional Oncology Network',
   'Standard infusion center scheduling capacity for oncology service lines.',
   590.00),
  (4, 'qPCR Respiratory Panel', 'Diagnostics',
   'BioPure Diagnostics',
   'Rapid respiratory diagnostics panel used by care sites during seasonal demand peaks.',
   185.00),
  (5, 'mRNA LNP Clinical Batch', 'Specialty Care',
   'NorthStar Health System',
   'Clinical batch requiring cold-chain capacity, quality monitoring, and coordinated delivery.',
   1250.00),
  (6, 'Bed Capacity Surge Playbook', 'Care Operations',
   'CarePath Clinics',
   'Operational service for bed capacity planning, escalation, and patient-flow coordination.',
   420.00),
  (7, 'Tamper-Evident Carton Batch', 'Quality and Safety',
   'QualityBridge Advisory',
   'Packaging batch monitored for quality variation, chain of custody, and service continuity.',
   95.00),
  (8, 'Digital Pathology Slide Batch', 'Diagnostics',
   'Community Health Partners',
   'Digital pathology service batch for diagnostic review and specialty-care coordination.',
   310.00);

-- Expand the curated services to the 187-service baseline documented by the
-- current Seer Health demo. The first eight records remain stable for labs.
INSERT INTO hc_care_services
  (service_id, service_name, category, provider_network, description, unit_value)
SELECT 8 + LEVEL,
       'Regional Care Service ' || LPAD(8 + LEVEL, 3, '0'),
       CASE MOD(LEVEL, 5)
         WHEN 0 THEN 'Specialty Care'
         WHEN 1 THEN 'Diagnostics'
         WHEN 2 THEN 'Care Operations'
         WHEN 3 THEN 'Quality and Safety'
         ELSE 'Pharmacy Support'
       END,
       'Seer Health Partner Network ' || LPAD(1 + MOD(LEVEL - 1, 25), 2, '0'),
       'Routine healthcare service catalog entry used for network planning, availability, and governed reporting.',
       150 + MOD(LEVEL * 37, 1100)
FROM dual
CONNECT BY LEVEL <= 179;
COMMIT;

INSERT INTO hc_quality_signals
  (signal_id, signal_type, criticality, source_name, signal_text,
   network_impact, next_step, posted_at, service_id)
VALUES
  (101, 'Capacity Alert', 'CRITICAL', 'Oncology Capacity Desk',
   'Oncology infusion slot capacity is constrained across Northeast treatment sites.',
   'HIGH', 'Review care-site capacity', DATE '2026-05-20', 1),
  (102, 'Capacity Alert', 'HIGH', 'Regional Oncology Network',
   'Additional infusion chair and staffing coverage is needed for continuity schedules.',
   'HIGH', 'Route capacity follow-up', DATE '2026-05-19', 2),
  (103, 'Cold Chain Bulletin', 'CRITICAL', 'Formulation Tracker',
   'Biologics cold-chain excursion risk affects the mRNA LNP clinical batch.',
   'HIGH', 'Check logistics impact', DATE '2026-05-21', 5),
  (104, 'Supply Quality Notice', 'HIGH', 'QualityBridge Advisory',
   'Tamper-evident carton variation requires a quality review before distribution.',
   'MEDIUM', 'Open quality review', DATE '2026-05-18', 7),
  (105, 'Diagnostic Capacity', 'MEDIUM', 'BioPure Diagnostics',
   'Respiratory panel demand is increasing near Miami care sites.',
   'MEDIUM', 'Check regional supply', DATE '2026-05-17', 4),
  (106, 'Patient Flow Alert', 'HIGH', 'CarePath Clinics',
   'Bed capacity surge conditions are affecting follow-up scheduling.',
   'HIGH', 'Review surge playbook', DATE '2026-05-16', 6),
  (107, 'Specialty Review', 'MEDIUM', 'Community Health Partners',
   'Digital pathology review capacity is tightening for specialty-care requests.',
   'MEDIUM', 'Review diagnostic queue', DATE '2026-05-15', 8),
  (108, 'Capacity Alert', 'LOW', 'Regional Oncology Network',
   'Infusion center schedule remains stable in the Midwest region.',
   'LOW', 'Continue monitoring', DATE '2026-05-14', 3);

-- Expand to 5,000 deterministic signal bulletins. Exactly 474 signals are
-- CRITICAL or HIGH after the five curated elevated signals above are included.
INSERT INTO hc_quality_signals
  (signal_id, signal_type, criticality, source_name, signal_text,
   network_impact, next_step, posted_at, service_id)
SELECT 108 + LEVEL,
       CASE MOD(LEVEL, 4)
         WHEN 0 THEN 'Capacity Alert'
         WHEN 1 THEN 'Quality Review'
         WHEN 2 THEN 'Access Bulletin'
         ELSE 'Supply Readiness'
       END,
       CASE
         WHEN LEVEL <= 234 THEN 'CRITICAL'
         WHEN LEVEL <= 469 THEN 'HIGH'
         WHEN MOD(LEVEL, 2) = 0 THEN 'MEDIUM'
         ELSE 'LOW'
       END,
       'Seer Health Monitoring Source ' || LPAD(1 + MOD(LEVEL - 1, 120), 3, '0'),
       'Routine network monitoring bulletin ' || LPAD(LEVEL, 4, '0') ||
       ' covering service readiness, quality review, access, and supply coordination.',
       CASE WHEN LEVEL <= 469 THEN 'HIGH' ELSE 'MEDIUM' END,
       CASE WHEN LEVEL <= 469 THEN 'Review operating evidence' ELSE 'Continue monitoring' END,
       DATE '2026-01-01' + MOD(LEVEL - 1, 140),
       1 + MOD(LEVEL - 1, 156)
FROM dual
CONNECT BY LEVEL <= 4992;

COMMIT;

-- The application tracks 1,422 precomputed service-to-signal matches as a
-- separate analytical layer. These rows make that documented layer explicit.
INSERT INTO hc_semantic_matches
  (match_id, service_id, signal_id, similarity_score)
SELECT LEVEL,
       1 + MOD(LEVEL - 1, 187),
       101 + MOD(LEVEL - 1, 5000),
       ROUND(0.5500 + MOD(LEVEL * 17, 4000) / 10000, 4)
FROM dual
CONNECT BY LEVEL <= 1422;
COMMIT;

INSERT INTO hc_care_sites
  (care_site_id, care_site_name, city, state_code, region,
   site_segment, followup_risk, location)
VALUES
  (1001, 'Miami Oncology Care Center', 'Miami', 'FL', 'Southeast',
   'Loyal', 0.18,
   MDSYS.SDO_GEOMETRY(2001, 4326, MDSYS.SDO_POINT_TYPE(-80.1918, 25.7617, NULL), NULL, NULL)),
  (1002, 'Penelope Mendoza', 'Charlotte', 'NC', 'Southeast',
   'Promising', 0.34,
   MDSYS.SDO_GEOMETRY(2001, 4326, MDSYS.SDO_POINT_TYPE(-80.8431, 35.2271, NULL), NULL, NULL)),
  (1003, 'New York Metro Infusion Center', 'New York', 'NY', 'Northeast Corridor',
   'Loyal', 0.22,
   MDSYS.SDO_GEOMETRY(2001, 4326, MDSYS.SDO_POINT_TYPE(-74.0060, 40.7128, NULL), NULL, NULL)),
  (1004, 'Bay Area Specialty Care Site', 'San Francisco', 'CA', 'Bay Area (SF)',
   'Potential', 0.47,
   MDSYS.SDO_GEOMETRY(2001, 4326, MDSYS.SDO_POINT_TYPE(-122.4194, 37.7749, NULL), NULL, NULL)),
  (1005, 'Los Angeles Diagnostic Center', 'Los Angeles', 'CA', 'Los Angeles Basin',
   'New Site', 0.55,
   MDSYS.SDO_GEOMETRY(2001, 4326, MDSYS.SDO_POINT_TYPE(-118.2437, 34.0522, NULL), NULL, NULL));

-- The source application contains 2,000 care-site records. Generated sites
-- are placed away from the curated Miami spatial example so its ranking stays stable.
INSERT INTO hc_care_sites
  (care_site_id, care_site_name, city, state_code, region,
   site_segment, followup_risk, location)
SELECT 1005 + LEVEL,
       'Regional Care Site ' || LPAD(1005 + LEVEL, 4, '0'),
       'Central City',
       CASE MOD(LEVEL, 4) WHEN 0 THEN 'IL' WHEN 1 THEN 'MO' WHEN 2 THEN 'KS' ELSE 'IA' END,
       'Central Network',
       CASE MOD(LEVEL, 4) WHEN 0 THEN 'Loyal' WHEN 1 THEN 'Promising' WHEN 2 THEN 'Potential' ELSE 'New Site' END,
       ROUND(0.10 + MOD(LEVEL * 7, 75) / 100, 2),
       MDSYS.SDO_GEOMETRY(
         2001,
         4326,
         MDSYS.SDO_POINT_TYPE(-96 + MOD(LEVEL, 20) / 10, 39 + MOD(LEVEL, 15) / 10, NULL),
         NULL,
         NULL
       )
FROM dual
CONNECT BY LEVEL <= 1995;
COMMIT;

INSERT INTO hc_logistics_sites
  (logistics_site_id, logistics_name, city, state_code, service_supported,
   capacity_units, pending_requests, active_alerts, current_load_pct,
   site_status, location)
VALUES
  (201, 'Hialeah Import Compliance Site', 'Hialeah', 'FL',
   'qPCR Respiratory Panel', 250000, 32, 4, 61.5, 'ACTIVE',
   MDSYS.SDO_GEOMETRY(2001, 4326, MDSYS.SDO_POINT_TYPE(-80.2781, 25.8576, NULL), NULL, NULL)),
  (202, 'Concord Southeast Micro Site', 'Concord', 'NC',
   'Infusion Center Slot Bundle', 80000, 18, 2, 52.0, 'ACTIVE',
   MDSYS.SDO_GEOMETRY(2001, 4326, MDSYS.SDO_POINT_TYPE(-80.5795, 35.4088, NULL), NULL, NULL)),
  (203, 'Romulus Great Lakes Bioprocess Hub', 'Romulus', 'MI',
   'mRNA LNP Clinical Batch', 200000, 26, 7, 73.0, 'ACTIVE',
   MDSYS.SDO_GEOMETRY(2001, 4326, MDSYS.SDO_POINT_TYPE(-83.3963, 42.2223, NULL), NULL, NULL)),
  (204, 'Etna Midwest Specialty Warehouse', 'Lebanon', 'TN',
   'Digital Pathology Slide Batch', 250000, 14, 1, 45.0, 'ACTIVE',
   MDSYS.SDO_GEOMETRY(2001, 4326, MDSYS.SDO_POINT_TYPE(-86.2911, 36.2081, NULL), NULL, NULL)),
  (205, 'Aurora Mountain West Repack Hub', 'Aurora', 'CO',
   'Tamper-Evident Carton Batch', 200000, 21, 5, 68.5, 'ACTIVE',
   MDSYS.SDO_GEOMETRY(2001, 4326, MDSYS.SDO_POINT_TYPE(-104.8319, 39.7294, NULL), NULL, NULL));

INSERT INTO hc_logistics_sites
  (logistics_site_id, logistics_name, city, state_code, service_supported,
   capacity_units, pending_requests, active_alerts, current_load_pct,
   site_status, location)
SELECT 205 + LEVEL,
       'Seer Health Logistics Site ' || LPAD(205 + LEVEL, 3, '0'),
       'Central City',
       CASE MOD(LEVEL, 4) WHEN 0 THEN 'IL' WHEN 1 THEN 'MO' WHEN 2 THEN 'KS' ELSE 'IA' END,
       'Regional Care Service ' || LPAD(9 + MOD(LEVEL - 1, 179), 3, '0'),
       100000 + LEVEL * 5000,
       8 + MOD(LEVEL * 3, 35),
       MOD(LEVEL, 7),
       35 + MOD(LEVEL * 3, 45),
       'ACTIVE',
       MDSYS.SDO_GEOMETRY(
         2001,
         4326,
         MDSYS.SDO_POINT_TYPE(-97 + MOD(LEVEL, 12) / 10, 38 + MOD(LEVEL, 10) / 10, NULL),
         NULL,
         NULL
       )
FROM dual
CONNECT BY LEVEL <= 25;
COMMIT;

INSERT INTO hc_service_requests
  (request_id, care_site_id, logistics_site_id, request_status,
   request_value, logistics_cost, demand_score, created_at)
VALUES
  (170101, 1001, 201, 'PROCESSING', 555.00, 48.00, 84.00, DATE '2026-05-18'),
  (170102, 1003, 203, 'CONFIRMED', 2500.00, 175.00, 92.00, DATE '2026-05-19'),
  (170103, 1004, 205, 'SHIPPED', 475.00, 95.00, 73.00, DATE '2026-05-20'),
  (170104, 1002, 204, 'DELIVERED', 943.89, 82.50, 64.00, DATE '2026-05-21'),
  (170105, 1005, 202, 'PENDING', 1260.00, 110.00, 88.00, DATE '2026-05-22'),
  (170106, 1001, 201, 'DELIVERED', 370.00, 42.00, 51.00, DATE '2026-05-23');

-- Expand to 3,000 service requests and a tracked value of 4,210,943.89.
INSERT INTO hc_service_requests
  (request_id, care_site_id, logistics_site_id, request_status,
   request_value, logistics_cost, demand_score, created_at)
SELECT 170106 + LEVEL,
       1001 + MOD(LEVEL - 1, 2000),
       201 + MOD(LEVEL - 1, 30),
       CASE MOD(LEVEL, 5)
         WHEN 0 THEN 'DELIVERED'
         WHEN 1 THEN 'PROCESSING'
         WHEN 2 THEN 'CONFIRMED'
         WHEN 3 THEN 'SHIPPED'
         ELSE 'PENDING'
       END,
       CASE WHEN LEVEL <= 2993 THEN 1404.00 ELSE 2668.00 END,
       35 + MOD(LEVEL * 11, 145),
       40 + MOD(LEVEL * 7, 60),
       DATE '2025-08-01' + MOD(LEVEL - 1, 296)
FROM dual
CONNECT BY LEVEL <= 2994;
COMMIT;

INSERT INTO hc_request_items
  (item_id, request_id, service_id, quantity, unit_cost)
VALUES
  (1, 170101, 4, 3, 185.00),
  (2, 170102, 5, 2, 1250.00),
  (3, 170103, 7, 5, 95.00),
  (4, 170104, 8, 1, 310.00),
  (5, 170104, 7, 2, 95.00),
  (6, 170104, 4, 1, 185.00),
  (7, 170104, 3, 1, 125.00),
  (8, 170104, 1, 1, 133.89),
  (9, 170105, 6, 3, 420.00),
  (10, 170106, 4, 2, 185.00);
COMMIT;

INSERT INTO hc_demand_forecasts
  (forecast_id, service_id, region, forecast_date,
   predicted_demand, demand_risk_factor)
VALUES
  (1, 5, 'Northeast Corridor', DATE '2026-05-25', 2578, 2.06),
  (2, 5, 'New York Metro', DATE '2026-05-25', 2310, 1.94),
  (3, 5, 'Los Angeles Basin', DATE '2026-05-25', 2140, 1.82),
  (4, 5, 'Bay Area (SF)', DATE '2026-05-25', 1980, 1.74),
  (5, 6, 'New York Metro', DATE '2026-05-25', 1810, 1.68),
  (6, 1, 'Northeast Corridor', DATE '2026-05-25', 1650, 1.61),
  (7, 4, 'Southeast', DATE '2026-05-25', 1430, 1.47),
  (8, 8, 'Los Angeles Basin', DATE '2026-05-25', 1190, 1.31);
COMMIT;

INSERT INTO hc_care_nodes
  (node_id, node_type, node_label, risk_score, pathway_volume)
VALUES
  (1, 'CONDITION', 'Sepsis', 0.82, 44),
  (2, 'CARE_GAP', 'Readmission Risk', 0.91, 37),
  (3, 'PATIENT_JOURNEY', 'Patient 1001 - Sepsis Readmission Risk', 0.94, 12),
  (4, 'CARE_GAP', '48-Hour Follow-Up', 0.76, 22),
  (5, 'ENCOUNTER', 'Inpatient Encounter 4412', 0.71, 18),
  (6, 'QUALITY_SIGNAL', 'Central Line Infection Risk', 0.79, 9),
  (7, 'CARE_TEAM', 'Nurse Care Team', 0.28, 31),
  (8, 'MEDICATION', 'Piperacillin/Tazobactam', 0.35, 16),
  (9, 'PROVIDER', 'Dr. Hannah Lee - Hospitalist', 0.24, 28);
COMMIT;

INSERT INTO hc_care_edges
  (edge_id, source_node_id, target_node_id, relationship_type, evidence_score)
VALUES
  (1, 3, 1, 'HAS_CONDITION', 0.96),
  (2, 3, 2, 'HAS_CARE_GAP', 0.94),
  (3, 3, 5, 'HAS_ENCOUNTER', 0.99),
  (4, 5, 4, 'REQUIRES_FOLLOW_UP', 0.88),
  (5, 5, 7, 'SUPPORTED_BY', 0.91),
  (6, 5, 8, 'TREATED_WITH', 0.87),
  (7, 5, 9, 'ATTENDED_BY', 0.95),
  (8, 2, 6, 'ASSOCIATED_SIGNAL', 0.78),
  (9, 1, 6, 'ASSOCIATED_SIGNAL', 0.81);
COMMIT;

INSERT INTO hc_agent_actions
  (action_id, action_type, team_name, prompt_text, result_summary,
   tool_name, confidence, action_status, created_at)
VALUES
  (1, 'CHAT_QUERY', 'CARE_LOGISTICS_AGENT',
   'Find nearest compliant care logistics site with qPCR Respiratory Panel for a care site in Miami.',
   'Hialeah Import Compliance Site is the nearest active site with the requested diagnostic panel.',
   'CARE_LOGISTICS_SQL', 0.90, 'COMPLETED', DATE '2026-05-23'),
  (2, 'SIGNAL_REVIEW', 'QUALITY_SIGNAL_AGENT',
   'Review cold-chain excursion risk for the mRNA LNP Clinical Batch.',
   'Critical cold-chain signal routed to logistics impact review.',
   'QUALITY_SIGNAL_SQL', 0.88, 'REVIEWED', DATE '2026-05-22'),
  (3, 'REQUEST_REVIEW', 'SERVICE_REQUEST_AGENT',
   'Summarize care service request 170104.',
   'Delivered request with three line items and a documented logistics assignment.',
   'SERVICE_REQUEST_SQL', 0.93, 'PENDING', DATE '2026-05-21');
COMMIT;

INSERT INTO hc_demand_training
  (training_id, current_requests, signal_count, capacity_ratio,
   critical_alerts, risk_flag)
VALUES
  (1, 8, 2, 1.40, 0, 'LOW'),
  (2, 11, 3, 1.25, 0, 'LOW'),
  (3, 14, 5, 1.10, 1, 'LOW'),
  (4, 17, 6, 0.98, 1, 'HIGH'),
  (5, 21, 8, 0.90, 2, 'HIGH'),
  (6, 24, 9, 0.82, 3, 'HIGH'),
  (7, 7, 1, 1.55, 0, 'LOW'),
  (8, 13, 4, 1.18, 0, 'LOW'),
  (9, 19, 7, 0.94, 2, 'HIGH'),
  (10, 28, 12, 0.72, 4, 'HIGH'),
  (11, 10, 2, 1.32, 0, 'LOW'),
  (12, 23, 10, 0.79, 3, 'HIGH');
COMMIT;

INSERT INTO hc_model_settings
  (setting_name, setting_value)
VALUES
  ('ALGO_NAME', 'ALGO_GENERALIZED_LINEAR_MODEL'),
  ('PREP_AUTO', 'ON');
COMMIT;

UPDATE hc_care_services
SET service_embedding =
  VECTOR_EMBEDDING(ADMIN.ALL_MINILM_L12_V2 USING description AS DATA);

UPDATE hc_quality_signals
SET signal_embedding =
  VECTOR_EMBEDDING(ADMIN.ALL_MINILM_L12_V2 USING signal_text AS DATA);

CREATE OR REPLACE VIEW care_services_v AS
SELECT service_id,
       service_name,
       category,
       provider_network,
       description,
       unit_value,
       service_embedding
FROM hc_care_services;

CREATE OR REPLACE VIEW quality_capacity_signals_v AS
SELECT s.signal_id,
       s.signal_type,
       s.criticality,
       s.source_name,
       s.signal_text,
       s.network_impact,
       s.next_step,
       s.posted_at,
       c.service_id,
       c.service_name,
       c.category,
       s.signal_embedding
FROM hc_quality_signals s
JOIN hc_care_services c
  ON c.service_id = s.service_id;

CREATE OR REPLACE VIEW care_logistics_sites_v AS
SELECT logistics_site_id,
       logistics_name,
       city,
       state_code,
       service_supported,
       capacity_units,
       pending_requests,
       active_alerts,
       current_load_pct,
       site_status,
       location
FROM hc_logistics_sites;

CREATE OR REPLACE VIEW care_service_requests_v AS
SELECT r.request_id AS service_request_id,
       s.care_site_name AS requesting_care_site,
       s.city || ', ' || s.state_code AS care_site_location,
       r.request_status,
       r.request_value,
       r.logistics_cost,
       r.demand_score,
       l.logistics_name,
       r.created_at
FROM hc_service_requests r
JOIN hc_care_sites s
  ON s.care_site_id = r.care_site_id
JOIN hc_logistics_sites l
  ON l.logistics_site_id = r.logistics_site_id;

CREATE OR REPLACE VIEW care_demand_forecasts_v AS
SELECT f.forecast_id,
       s.service_name,
       s.category,
       f.region,
       f.forecast_date,
       f.predicted_demand,
       f.demand_risk_factor
FROM hc_demand_forecasts f
JOIN hc_care_services s
  ON s.service_id = f.service_id;

CREATE OR REPLACE VIEW healthcare_agent_actions_v AS
SELECT action_id,
       action_type,
       team_name,
       prompt_text,
       result_summary,
       tool_name,
       confidence,
       action_status,
       created_at
FROM hc_agent_actions;

CREATE OR REPLACE VIEW healthcare_command_center_v AS
SELECT
  (SELECT COUNT(*) FROM hc_service_requests) AS service_requests,
  (SELECT SUM(request_value) FROM hc_service_requests) AS tracked_service_value,
  (SELECT COUNT(*) FROM hc_quality_signals
    WHERE criticality IN ('CRITICAL', 'HIGH')) AS elevated_signals,
  (SELECT COUNT(DISTINCT service_id) FROM hc_quality_signals) AS watched_services,
  (SELECT COUNT(*) FROM hc_agent_actions
    WHERE action_status = 'COMPLETED') AS completed_agent_actions;

CREATE OR REPLACE JSON RELATIONAL DUALITY VIEW care_service_requests_dv AS
SELECT JSON {
  '_id'                  : r.request_id,
  'requestingCareSiteId' : r.care_site_id,
  'requestStatus'        : r.request_status,
  'requestValue'         : r.request_value,
  'logisticsCost'        : r.logistics_cost,
  'demandScore'          : r.demand_score,
  'createdAt'            : r.created_at,
  'lineItems' : [
    SELECT JSON {
      'lineItemId'      : i.item_id,
      'serviceSupplyId' : i.service_id,
      'quantity'        : i.quantity,
      'unitCost'        : i.unit_cost,
      'lineValue'       : i.line_value
    }
    FROM hc_request_items i WITH UPDATE
    WHERE i.request_id = r.request_id
  ]
}
FROM hc_service_requests r WITH UPDATE;

CREATE PROPERTY GRAPH care_pathway_graph
  VERTEX TABLES (
    hc_care_nodes
      KEY (node_id)
      LABEL care_node
      PROPERTIES (node_id, node_type, node_label, risk_score, pathway_volume)
  )
  EDGE TABLES (
    hc_care_edges
      KEY (edge_id)
      SOURCE KEY (source_node_id) REFERENCES hc_care_nodes (node_id)
      DESTINATION KEY (target_node_id) REFERENCES hc_care_nodes (node_id)
      LABEL care_relationship
      PROPERTIES (edge_id, relationship_type, evidence_score)
  );

DELETE FROM user_sdo_geom_metadata
WHERE table_name IN ('HC_CARE_SITES', 'HC_LOGISTICS_SITES');

INSERT INTO user_sdo_geom_metadata
  (table_name, column_name, diminfo, srid)
VALUES
  ('HC_CARE_SITES', 'LOCATION',
   MDSYS.SDO_DIM_ARRAY(
     MDSYS.SDO_DIM_ELEMENT('LONGITUDE', -180, 180, 0.005),
     MDSYS.SDO_DIM_ELEMENT('LATITUDE', -90, 90, 0.005)
   ),
   4326),
  ('HC_LOGISTICS_SITES', 'LOCATION',
   MDSYS.SDO_DIM_ARRAY(
     MDSYS.SDO_DIM_ELEMENT('LONGITUDE', -180, 180, 0.005),
     MDSYS.SDO_DIM_ELEMENT('LATITUDE', -90, 90, 0.005)
   ),
   4326);

CREATE INDEX hc_care_sites_spx
ON hc_care_sites(location)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2;

CREATE INDEX hc_logistics_sites_spx
ON hc_logistics_sites(location)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2;

BEGIN
  DBMS_DATA_MINING.CREATE_MODEL(
    model_name          => 'CARE_DEMAND_RISK_MODEL',
    mining_function     => DBMS_DATA_MINING.CLASSIFICATION,
    data_table_name     => 'HC_DEMAND_TRAINING',
    case_id_column_name => 'TRAINING_ID',
    target_column_name  => 'RISK_FLAG',
    settings_table_name => 'HC_MODEL_SETTINGS'
  );
END;
/

COMMIT;

COLUMN component FORMAT A30
COLUMN result FORMAT 9999990

SELECT 'Care services' AS component, COUNT(*) AS result
FROM hc_care_services
UNION ALL
SELECT 'Quality signals', COUNT(*)
FROM hc_quality_signals
UNION ALL
SELECT 'Service vectors', COUNT(*)
FROM hc_care_services
WHERE service_embedding IS NOT NULL
UNION ALL
SELECT 'Signal vectors', COUNT(*)
FROM hc_quality_signals
WHERE signal_embedding IS NOT NULL
UNION ALL
SELECT 'Semantic matches', COUNT(*)
FROM hc_semantic_matches
UNION ALL
SELECT 'Care sites', COUNT(*)
FROM hc_care_sites
UNION ALL
SELECT 'Logistics sites', COUNT(*)
FROM hc_logistics_sites
UNION ALL
SELECT 'Service requests', COUNT(*)
FROM hc_service_requests
UNION ALL
SELECT 'Care graph nodes', COUNT(*)
FROM hc_care_nodes
UNION ALL
SELECT 'Care graph edges', COUNT(*)
FROM hc_care_edges
UNION ALL
SELECT 'Demand forecasts', COUNT(*)
FROM hc_demand_forecasts
UNION ALL
SELECT 'Agent actions', COUNT(*)
FROM hc_agent_actions
UNION ALL
SELECT 'Invalid objects', COUNT(*)
FROM user_objects
WHERE status = 'INVALID'
  AND (
    object_name LIKE 'HC\_%' ESCAPE '\'
    OR object_name IN (
      'CARE_PATHWAY_GRAPH',
      'CARE_SERVICE_REQUESTS_DV',
      'CARE_SERVICES_V',
      'QUALITY_CAPACITY_SIGNALS_V',
      'CARE_LOGISTICS_SITES_V',
      'CARE_SERVICE_REQUESTS_V',
      'CARE_DEMAND_FORECASTS_V',
      'HEALTHCARE_AGENT_ACTIONS_V',
      'HEALTHCARE_COMMAND_CENTER_V',
      'CARE_DEMAND_RISK_MODEL'
    )
  );

SELECT SYS_CONTEXT('USERENV', 'SESSION_USER') AS schema_user,
       COUNT(*) AS mining_models
FROM user_mining_models;

UNDEFINE lluser_password
UNDEFINE service_alias
