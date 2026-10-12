-- Seer Transport passenger workshop seed. Run once in a fresh, dedicated schema.
WHENEVER SQLERROR EXIT SQL.SQLCODE
SET DEFINE OFF
CREATE TABLE service_lines (
  line_id NUMBER PRIMARY KEY,
  line_name VARCHAR2(100) NOT NULL
);
CREATE TABLE transport_services (
  service_id NUMBER PRIMARY KEY,
  service_name VARCHAR2(120) NOT NULL,
  category VARCHAR2(80) NOT NULL,
  subcategory VARCHAR2(100) NOT NULL,
  fare NUMBER(10,2) NOT NULL,
  line_id NUMBER NOT NULL REFERENCES service_lines(line_id),
  region_name VARCHAR2(100) NOT NULL
);
CREATE TABLE passengers (
  passenger_id NUMBER PRIMARY KEY,
  first_name VARCHAR2(80) NOT NULL,
  last_name VARCHAR2(80) NOT NULL,
  email VARCHAR2(200) NOT NULL,
  passenger_tier VARCHAR2(30) NOT NULL,
  location MDSYS.SDO_GEOMETRY
);
CREATE TABLE bookings (
  booking_id NUMBER PRIMARY KEY,
  passenger_id NUMBER NOT NULL REFERENCES passengers(passenger_id),
  booking_status VARCHAR2(30) NOT NULL,
  booking_total NUMBER(10,2),
  service_fee NUMBER(10,2),
  demand_score NUMBER(5,2),
  created_at TIMESTAMP DEFAULT SYSTIMESTAMP
);
CREATE TABLE booking_legs (
  leg_id NUMBER PRIMARY KEY,
  booking_id NUMBER NOT NULL REFERENCES bookings(booking_id),
  service_id NUMBER NOT NULL REFERENCES transport_services(service_id),
  seats NUMBER NOT NULL,
  fare NUMBER(10,2) NOT NULL,
  leg_total NUMBER(10,2) GENERATED ALWAYS AS (seats * fare) VIRTUAL
);
CREATE TABLE disruption_signals (
  signal_id NUMBER PRIMARY KEY,
  criticality_score NUMBER NOT NULL,
  affected_passengers NUMBER NOT NULL,
  incidents_opened_count NUMBER NOT NULL
);
CREATE TABLE signal_service_mentions (
  signal_id NUMBER REFERENCES disruption_signals(signal_id),
  service_id NUMBER REFERENCES transport_services(service_id),
  PRIMARY KEY (signal_id, service_id)
);
CREATE TABLE service_embeddings (
  service_id NUMBER PRIMARY KEY REFERENCES transport_services(service_id),
  embedding VECTOR(384)
);
CREATE TABLE stations (
  station_id NUMBER PRIMARY KEY,
  station_name VARCHAR2(120) NOT NULL,
  city VARCHAR2(80) NOT NULL,
  state_province VARCHAR2(80) NOT NULL,
  latitude NUMBER NOT NULL,
  longitude NUMBER NOT NULL,
  location MDSYS.SDO_GEOMETRY,
  daily_capacity NUMBER NOT NULL,
  occupancy_pct NUMBER NOT NULL,
  is_active NUMBER(1) DEFAULT 1
);
CREATE TABLE service_regions (
  region_name VARCHAR2(100) PRIMARY KEY,
  demand_index NUMBER NOT NULL,
  boundary MDSYS.SDO_GEOMETRY
);
CREATE TABLE network_entities (
  entity_id NUMBER PRIMARY KEY,
  entity_key VARCHAR2(100) UNIQUE NOT NULL,
  display_name VARCHAR2(120) NOT NULL,
  entity_type VARCHAR2(30) NOT NULL,
  risk_score NUMBER,
  risk_level VARCHAR2(30),
  affected_capacity NUMBER,
  channel VARCHAR2(40)
);
CREATE TABLE network_relationships (
  relationship_id NUMBER PRIMARY KEY,
  from_entity NUMBER NOT NULL REFERENCES network_entities(entity_id),
  to_entity NUMBER NOT NULL REFERENCES network_entities(entity_id),
  relationship_type VARCHAR2(60) NOT NULL
);
CREATE VIEW service_lines_v AS SELECT line_id, line_name FROM service_lines;
CREATE VIEW transport_services_v AS
 SELECT service_id, service_name, category AS service_category, line_id, region_name FROM transport_services;
CREATE VIEW disruption_signals_v AS
 SELECT signal_id, criticality_score, affected_passengers, incidents_opened_count FROM disruption_signals;
CREATE VIEW stations_v AS
 SELECT station_id, station_name, city, state_province FROM stations;
INSERT INTO service_lines VALUES (1, 'Northeast Regional');
INSERT INTO service_lines VALUES (2, 'Midwest Connect');
INSERT INTO service_lines VALUES (3, 'Metro Express');
INSERT INTO transport_services VALUES (1, 'Hudson Commuter Rail', 'Rail', 'Commuter', 12.50, 1, 'New York Metro');
INSERT INTO transport_services VALUES (2, 'New York Airport Express', 'Bus', 'Airport', 18.00, 3, 'New York Metro');
INSERT INTO transport_services VALUES (3, 'Chicago Lakeshore Rail', 'Rail', 'Regional', 16.00, 2, 'Chicago Metro');
INSERT INTO transport_services VALUES (4, 'Manhattan Crosstown', 'Bus', 'Urban', 4.50, 3, 'New York Metro');
INSERT INTO transport_services VALUES (5, 'Joliet Regional Link', 'Rail', 'Commuter', 11.25, 2, 'Chicago Metro');
INSERT INTO transport_services VALUES (6, 'Queens Station Shuttle', 'Bus', 'Station', 5.00, 3, 'New York Metro');
INSERT INTO transport_services VALUES (7, 'Newark Intercity Express', 'Rail', 'Intercity', 23.00, 1, 'New York Metro');
INSERT INTO transport_services VALUES (8, 'Chicago South Loop', 'Bus', 'Urban', 4.75, 2, 'Chicago Metro');
INSERT INTO transport_services VALUES (9, 'Brooklyn Night Service', 'Bus', 'Night', 6.00, 3, 'New York Metro');
INSERT INTO transport_services VALUES (10, 'Midwest Airport Connector', 'Bus', 'Airport', 14.00, 2, 'Chicago Metro');
BEGIN
  FOR i IN 11..60 LOOP
    INSERT INTO transport_services(service_id,service_name,category,subcategory,fare,line_id,region_name)
    VALUES(i, CASE WHEN MOD(i,2)=0 THEN 'New York ' ELSE 'Chicago ' END ||
           CASE MOD(i,4) WHEN 0 THEN 'Crosstown Shuttle ' WHEN 1 THEN 'Regional Rail '
             WHEN 2 THEN 'Airport Connector ' ELSE 'Commuter Express ' END || TO_CHAR(i),
           CASE MOD(i,4) WHEN 1 THEN 'Rail' ELSE 'Bus' END,
           CASE MOD(i,4) WHEN 0 THEN 'Urban' WHEN 1 THEN 'Regional'
             WHEN 2 THEN 'Airport' ELSE 'Commuter' END,
           4 + MOD(i,22), 1 + MOD(i,3),
           CASE WHEN MOD(i,2)=0 THEN 'New York Metro' ELSE 'Chicago Metro' END);
  END LOOP;
END;
/
INSERT INTO stations VALUES (1,'New York Central','New York','NY',40.7527,-73.9772,
  MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-73.9772,40.7527,NULL),NULL,NULL),12000,72,1);
INSERT INTO stations VALUES (2,'Queens Transit Hub','Queens','NY',40.7465,-73.8915,
  MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-73.8915,40.7465,NULL),NULL,NULL),8000,68,1);
INSERT INTO stations VALUES (3,'Joliet Rail Station','Joliet','IL',41.5244,-88.0781,
  MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-88.0781,41.5244,NULL),NULL,NULL),4500,61,1);
INSERT INTO stations VALUES (16,'Chicago Union Station','Chicago','IL',41.8789,-87.6400,
  MDSYS.SDO_GEOMETRY(2001,4326,MDSYS.SDO_POINT_TYPE(-87.6400,41.8789,NULL),NULL,NULL),10000,79,1);
INSERT INTO service_regions VALUES ('New York Metro',86,
  MDSYS.SDO_GEOMETRY(2003,4326,NULL,MDSYS.SDO_ELEM_INFO_ARRAY(1,1003,1),
  MDSYS.SDO_ORDINATE_ARRAY(-74.10,40.65,-73.75,40.65,-73.75,40.90,-74.10,40.90,-74.10,40.65)));
INSERT INTO service_regions VALUES ('Chicago Metro',78,
  MDSYS.SDO_GEOMETRY(2003,4326,NULL,MDSYS.SDO_ELEM_INFO_ARRAY(1,1003,1),
  MDSYS.SDO_ORDINATE_ARRAY(-88.15,41.45,-87.50,41.45,-87.50,42.05,-88.15,42.05,-88.15,41.45)));
DECLARE
  first_names SYS.ODCIVARCHAR2LIST := SYS.ODCIVARCHAR2LIST(
    'Maya','Arjun','Sofia','Daniel','Ava','Noah','Leila','Mateo','Chloe','Omar',
    'Amara','Ethan','Priya','Lucas','Nina','Jonah','Zoe','Kai','Elena','Samir');
  last_names SYS.ODCIVARCHAR2LIST := SYS.ODCIVARCHAR2LIST('Chen','Patel','Rivera','Johnson');
BEGIN
  FOR i IN 1..80 LOOP
    INSERT INTO passengers(passenger_id,first_name,last_name,email,passenger_tier,location)
    VALUES(i,first_names(1+MOD(i-1,20)),last_names(1+TRUNC((i-1)/20)),
      'passenger'||TO_CHAR(i)||'@example.test',
      CASE WHEN MOD(i,5)=0 THEN 'Gold' ELSE 'Standard' END,
      MDSYS.SDO_GEOMETRY(2001,4326,
       MDSYS.SDO_POINT_TYPE(
         CASE WHEN MOD(i,2)=0 THEN -73.99+MOD(i,15)*0.01 ELSE -87.95+MOD(i,15)*0.02 END,
         CASE WHEN MOD(i,2)=0 THEN 40.70+MOD(i,12)*0.01 ELSE 41.60+MOD(i,12)*0.02 END,NULL),NULL,NULL));
  END LOOP;
  FOR i IN 1..180 LOOP
    INSERT INTO bookings(booking_id,passenger_id,booking_status,booking_total,service_fee,demand_score,created_at)
    VALUES(100000+i,1+MOD(i,80),CASE MOD(i,10) WHEN 0 THEN 'cancelled' ELSE 'confirmed' END,
      (4+MOD(i,22))*(1+MOD(i,3)),0,20+MOD(i,80),SYSTIMESTAMP-NUMTODSINTERVAL(MOD(i,60),'DAY'));
    INSERT INTO booking_legs(leg_id,booking_id,service_id,seats,fare)
    VALUES(200000+i,100000+i,1+MOD(i,60),1+MOD(i,3),4+MOD(i,22));
  END LOOP;
  FOR i IN 1..30 LOOP
    INSERT INTO disruption_signals VALUES(i, 60+MOD(i*7,40),15+MOD(i*23,140),1+MOD(i,5));
    INSERT INTO signal_service_mentions VALUES(i,1+MOD(i,10));
  END LOOP;
END;
/
INSERT INTO network_entities VALUES (1,'TRIP-8841','Hudson morning trip','trip',92,'HIGH',220,'rail');
INSERT INTO network_entities VALUES (2,'VEHICLE-17','Railcar set 17','vehicle',76,'HIGH',300,'fleet');
INSERT INTO network_entities VALUES (3,'STATION-NYC','New York Central','station',81,'HIGH',12000,'station');
INSERT INTO network_entities VALUES (4,'ROUTE-HUDSON','Hudson corridor','route',84,'HIGH',2000,'rail');
INSERT INTO network_entities VALUES (5,'CASE-401','Signal outage case','case',95,'HIGH',500,'operations');
INSERT INTO network_entities VALUES (6,'TRIP-8842','Hudson afternoon trip','trip',74,'HIGH',210,'rail');
INSERT INTO network_entities VALUES (7,'TRIP-8843','Queens shuttle trip','trip',63,'MEDIUM',90,'bus');
INSERT INTO network_relationships VALUES (1,1,2,'USES_VEHICLE');
INSERT INTO network_relationships VALUES (2,1,3,'CALLS_AT');
INSERT INTO network_relationships VALUES (3,1,4,'SERVES_ROUTE');
INSERT INTO network_relationships VALUES (4,4,5,'AFFECTED_BY');
INSERT INTO network_relationships VALUES (5,6,2,'USES_VEHICLE');
INSERT INTO network_relationships VALUES (6,6,3,'CALLS_AT');
INSERT INTO network_relationships VALUES (7,7,3,'CALLS_AT');
COMMIT;
CREATE VIEW oml_service_demand_training_v AS
SELECT s.service_id,s.category,s.fare,
       6+MOD(s.service_id*3,45) AS total_mentions,
       ROUND(0.25+MOD(s.service_id,7)*0.08,2) AS avg_sentiment,
       80+MOD(s.service_id*19,500) AS total_reactions,
       8+MOD(s.service_id*5,80) AS total_reshares,
       500+MOD(s.service_id*137,5000) AS total_views,
       ROUND(0.20+MOD(s.service_id,8)*0.08,2) AS avg_interest,
       2+MOD(s.service_id*2,18) AS high_interest_mentions,
       1+MOD(s.service_id*3,12) AS rising_mentions,
       10+MOD(s.service_id*17,130) AS seats_booked,
       ROUND(s.fare*(10+MOD(s.service_id*17,130)),2) AS fare_revenue,
       CASE WHEN 6+MOD(s.service_id*3,45)>=30 OR 2+MOD(s.service_id*2,18)>=14
         THEN 'SURGE' ELSE 'STABLE' END AS surge_label
FROM transport_services s;
CREATE JSON RELATIONAL DUALITY VIEW bookings_dv AS
SELECT JSON {
  '_id': b.booking_id,
  'passengerId': b.passenger_id,
  'status': b.booking_status,
  'total': b.booking_total,
  'serviceFee': b.service_fee,
  'demandScore': b.demand_score,
  'createdAt': b.created_at,
  'legs': [SELECT JSON {'legId': l.leg_id,'serviceId': l.service_id,'seats': l.seats,'fare': l.fare}
           FROM booking_legs l WITH UPDATE WHERE l.booking_id=b.booking_id]
} FROM bookings b WITH UPDATE;
CREATE PROPERTY GRAPH service_disruption_network
  VERTEX TABLES (network_entities KEY(entity_id) LABEL entity
    PROPERTIES(entity_id,entity_key,display_name,entity_type,risk_score,risk_level,affected_capacity,channel))
  EDGE TABLES (network_relationships KEY(relationship_id)
    SOURCE KEY(from_entity) REFERENCES network_entities(entity_id)
    DESTINATION KEY(to_entity) REFERENCES network_entities(entity_id)
    LABEL related_to PROPERTIES(relationship_type));
INSERT INTO service_embeddings(service_id,embedding)
SELECT service_id,
       VECTOR_EMBEDDING(ADMIN.ALL_MINILM_L12_V2 USING
         service_name || '. Category: ' || category || '. Subcategory: ' || subcategory AS DATA)
FROM transport_services;
COMMIT;
