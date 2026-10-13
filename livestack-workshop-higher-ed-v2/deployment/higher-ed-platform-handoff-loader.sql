/*
  Seer Higher Education workshop loader for an unused Higher Education namespace in LLUSER.
  Run as ADMIN with: @load_seer_higher_ed.sql <lluser-password> <service-alias>
  Platform setup creates LLUSER, loads ADMIN.ALL_MINILM_L12_V2,
  and configures an enabled GENAI profile for LLUSER before this loader.
  Existing non-Higher Education tables are preserved. The loader refuses
  Higher Education object-name collisions before grants or data changes.
  Lab 1: request case view, duality view, signal vectors, campus locations.
  Lab 2: request 990101 is reserved for the learner to insert through JSON.
  Lab 3: SUPPORT_RESOURCES.RESOURCE_EMBEDDING is reserved for the learner.
  Lab 4: STUDENT_SUPPORT_NETWORK is a SQL property graph over entity/link tables.
  Lab 5: SRID 4326 campus points and service-area polygons are registered and indexed.
  Lab 6: 40 aggregate training rows; the learner creates the OML model.
  Labs 7-8: existing GENAI profile is restricted to three aggregate views.
*/
SET DEFINE ON
SET VERIFY OFF
SET ECHO OFF
SET SERVEROUTPUT ON
SET SQLBLANKLINES ON
SET SQLFORMAT ANSICONSOLE
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
DEFINE lluser_password = '&1'
DEFINE service_alias = '&2'
BEGIN
  IF USER <> 'ADMIN' THEN
    RAISE_APPLICATION_ERROR(-20001, 'Start the Seer Higher Education loader as ADMIN.');
  END IF;
END;
/
DECLARE
  l_count PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_count FROM dba_users WHERE username = 'LLUSER';
  IF l_count <> 1 THEN
    RAISE_APPLICATION_ERROR(-20002, 'Create LLUSER before running the loader.');
  END IF;
  SELECT COUNT(*) INTO l_count FROM dba_objects
   WHERE owner = 'ADMIN' AND object_name = 'ALL_MINILM_L12_V2'
     AND object_type = 'MINING MODEL' AND status = 'VALID';
  IF l_count <> 1 THEN
    RAISE_APPLICATION_ERROR(-20003, 'The ADMIN embedding model is missing or invalid.');
  END IF;
  SELECT COUNT(*) INTO l_count FROM dba_objects
   WHERE owner = 'LLUSER' AND (
      object_name LIKE 'STUDENT_SUPPORT_%'
      OR object_name LIKE 'THOMAS_STUDENT_%'
      OR object_name LIKE 'THOMAS_ADVISING_%'
      OR object_name LIKE 'NINA_STUDENT_SUPPORT_%'
      OR object_name IN (
        'ACADEMIC_PROGRAMS', 'STUDENTS', 'COURSE_SECTIONS', 'ENROLLMENTS',
        'SUPPORT_RESOURCES', 'CAMPUS_SUPPORT_CENTERS', 'CAMPUS_SERVICE_AREAS',
        'PROGRAM_SUPPORT_OVERVIEW_V', 'CAMPUS_SUPPORT_CAPACITY_V',
        'COURSE_SECTION_CAPACITY_V', 'COURSE_SECTIONS_LOCATION_SIDX',
        'SUPPORT_REQUESTS_ORIGIN_SIDX', 'CAMPUS_CENTERS_LOCATION_SIDX',
        'CAMPUS_AREAS_BOUNDARY_SIDX'));
  IF l_count > 0 THEN
    RAISE_APPLICATION_ERROR(-20005, 'Higher Education objects already exist in LLUSER. Existing data is preserved.');
  END IF;
END;
/
GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE PROCEDURE,
      CREATE SEQUENCE, CREATE TRIGGER, CREATE TYPE, CREATE MINING MODEL,
      CREATE SYNONYM, CREATE JOB, CREATE PROPERTY GRAPH TO LLUSER;
GRANT RESOURCE, OML_DEVELOPER, GRAPH_DEVELOPER TO LLUSER;
GRANT EXECUTE ON DBMS_CLOUD TO LLUSER;
GRANT EXECUTE ON DBMS_CLOUD_AI TO LLUSER;
GRANT EXECUTE ON DBMS_CLOUD_AI_AGENT TO LLUSER;
GRANT EXECUTE ON DBMS_DATA_MINING TO LLUSER;
GRANT EXECUTE ON DBMS_VECTOR TO LLUSER;
GRANT EXECUTE ON MDSYS.SDO_GEOM TO LLUSER;
GRANT EXECUTE ON MDSYS.SDO_UTIL TO LLUSER;
GRANT EXECUTE ON MDSYS.SDO_CS TO LLUSER;
GRANT SELECT ON MINING MODEL ADMIN.ALL_MINILM_L12_V2 TO LLUSER;
ALTER USER LLUSER GRANT CONNECT THROUGH "GRAPH$PROXY_USER";
ALTER USER LLUSER GRANT CONNECT THROUGH "SPATIAL$PROXY_USER";

CONNECT LLUSER/"&&lluser_password"@&&service_alias
UNDEFINE lluser_password
UNDEFINE service_alias
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
SET DEFINE OFF
DECLARE
  l_count PLS_INTEGER;
BEGIN
  IF USER <> 'LLUSER' THEN
    RAISE_APPLICATION_ERROR(-20004, 'Higher Education objects must be owned by LLUSER.');
  END IF;
  SELECT COUNT(*) INTO l_count FROM user_objects
   WHERE object_name LIKE 'STUDENT_SUPPORT_%'
      OR object_name LIKE 'THOMAS_STUDENT_%'
      OR object_name LIKE 'THOMAS_ADVISING_%'
      OR object_name LIKE 'NINA_STUDENT_SUPPORT_%'
      OR object_name IN (
        'ACADEMIC_PROGRAMS', 'STUDENTS', 'COURSE_SECTIONS', 'ENROLLMENTS',
        'SUPPORT_RESOURCES', 'CAMPUS_SUPPORT_CENTERS', 'CAMPUS_SERVICE_AREAS',
        'PROGRAM_SUPPORT_OVERVIEW_V', 'CAMPUS_SUPPORT_CAPACITY_V',
        'COURSE_SECTION_CAPACITY_V', 'COURSE_SECTIONS_LOCATION_SIDX',
        'SUPPORT_REQUESTS_ORIGIN_SIDX', 'CAMPUS_CENTERS_LOCATION_SIDX',
        'CAMPUS_AREAS_BOUNDARY_SIDX');
  IF l_count > 0 THEN
    RAISE_APPLICATION_ERROR(-20005, 'Higher Education objects already exist in LLUSER. Existing data is preserved.');
  END IF;
  SELECT COUNT(*) INTO l_count FROM user_sdo_geom_metadata
   WHERE table_name IN (
     'COURSE_SECTIONS', 'STUDENT_SUPPORT_REQUESTS',
     'CAMPUS_SUPPORT_CENTERS', 'CAMPUS_SERVICE_AREAS');
  IF l_count > 0 THEN
    RAISE_APPLICATION_ERROR(-20006, 'Higher Education spatial metadata already exists in LLUSER.');
  END IF;
  SELECT COUNT(*) INTO l_count FROM user_cloud_ai_profiles
   WHERE UPPER(profile_name) = 'GENAI' AND UPPER(status) = 'ENABLED';
  IF l_count <> 1 THEN
    RAISE_APPLICATION_ERROR(-20009, 'An enabled GENAI profile is required before loading.');
  END IF;
END;
/
PROMPT Creating Seer Higher Education workshop objects
CREATE TABLE academic_programs (
  program_id NUMBER PRIMARY KEY,
  program_name VARCHAR2(150), college_name VARCHAR2(150),
  campus_id NUMBER, campus_name VARCHAR2(100)
);
CREATE TABLE students (
  student_id NUMBER PRIMARY KEY,
  student_key VARCHAR2(30) UNIQUE, preferred_name VARCHAR2(100),
  program_id NUMBER, campus_id NUMBER,
  CONSTRAINT students_program_fk FOREIGN KEY(program_id) REFERENCES academic_programs(program_id)
);
CREATE TABLE course_sections (
  section_id NUMBER PRIMARY KEY, course_code VARCHAR2(30), course_title VARCHAR2(150),
  term_code VARCHAR2(30), campus_id NUMBER, campus_name VARCHAR2(100),
  seat_capacity NUMBER, enrollment_count NUMBER, location SDO_GEOMETRY
);
CREATE TABLE enrollments (
  enrollment_id NUMBER PRIMARY KEY, student_id NUMBER, section_id NUMBER,
  term_code VARCHAR2(30), enrollment_status VARCHAR2(30),
  CONSTRAINT enrollment_student_fk FOREIGN KEY(student_id) REFERENCES students(student_id),
  CONSTRAINT enrollment_section_fk FOREIGN KEY(section_id) REFERENCES course_sections(section_id)
);
CREATE TABLE support_resources (
  resource_id NUMBER PRIMARY KEY, resource_name VARCHAR2(120), resource_type VARCHAR2(60),
  description VARCHAR2(1000), campus_id NUMBER, campus_name VARCHAR2(100), is_active NUMBER(1)
);
CREATE TABLE student_support_requests (
  request_id NUMBER PRIMARY KEY, student_id NUMBER, request_type VARCHAR2(60),
  request_status VARCHAR2(30), priority_score NUMBER, campus_id NUMBER,
  campus_name VARCHAR2(100), service_center_id NUMBER, preferred_channel VARCHAR2(40),
  follow_up_window VARCHAR2(40), origin_location SDO_GEOMETRY,
  request_context JSON, recommended_resource_id NUMBER, term_code VARCHAR2(30),
  created_at TIMESTAMP,
  CONSTRAINT support_request_student_fk FOREIGN KEY(student_id) REFERENCES students(student_id),
  CONSTRAINT support_request_resource_fk FOREIGN KEY(recommended_resource_id) REFERENCES support_resources(resource_id)
);
CREATE TABLE student_support_updates (
  update_id NUMBER PRIMARY KEY, request_id NUMBER, update_text VARCHAR2(1000),
  updated_at TIMESTAMP, visibility VARCHAR2(30),
  CONSTRAINT support_update_request_fk FOREIGN KEY(request_id) REFERENCES student_support_requests(request_id)
);
CREATE TABLE campus_support_centers (
  center_id NUMBER PRIMARY KEY, center_name VARCHAR2(120), campus_id NUMBER,
  campus_name VARCHAR2(100), center_type VARCHAR2(60), capacity_visits_per_week NUMBER,
  current_load_pct NUMBER, is_active NUMBER(1), latitude NUMBER, longitude NUMBER,
  location SDO_GEOMETRY
);
CREATE TABLE campus_service_areas (
  area_id NUMBER PRIMARY KEY, campus_id NUMBER, campus_name VARCHAR2(100),
  area_name VARCHAR2(100), boundary SDO_GEOMETRY, demand_index NUMBER
);
CREATE TABLE student_support_network_entities (
  entity_id NUMBER PRIMARY KEY, entity_key VARCHAR2(60) UNIQUE, display_name VARCHAR2(150),
  entity_type VARCHAR2(40), academic_program VARCHAR2(150), campus_name VARCHAR2(100),
  priority_score NUMBER, open_request_count NUMBER
);
CREATE TABLE student_support_network_links (
  link_id NUMBER PRIMARY KEY, from_entity_id NUMBER, to_entity_id NUMBER,
  relationship_type VARCHAR2(60), evidence_score NUMBER, academic_term VARCHAR2(30),
  CONSTRAINT graph_link_from_fk FOREIGN KEY(from_entity_id) REFERENCES student_support_network_entities(entity_id),
  CONSTRAINT graph_link_to_fk FOREIGN KEY(to_entity_id) REFERENCES student_support_network_entities(entity_id)
);
INSERT INTO academic_programs VALUES(10,'Applied Mathematics','School of Science',1,'Harbor Campus');
INSERT INTO academic_programs VALUES(20,'Environmental Studies','School of Arts and Sciences',1,'Harbor Campus');
INSERT INTO academic_programs VALUES(30,'Public Policy','School of Civic Studies',2,'Riverside Campus');
INSERT INTO students VALUES(1001,'STU-1001','Alex Rivera',10,1);
INSERT INTO students VALUES(1002,'STU-1002','Sam Lee',20,1);
INSERT INTO students VALUES(1003,'STU-1003','Morgan Chen',10,1);
INSERT INTO students VALUES(1004,'STU-1004','Taylor Kim',30,2);
INSERT INTO course_sections VALUES(501,'MATH-201','Applied Calculus','2026FA',1,'Harbor Campus',28,24,SDO_GEOMETRY(2001,4326,SDO_POINT_TYPE(-73.985,40.735,NULL),NULL,NULL));
INSERT INTO course_sections VALUES(502,'ENVS-210','Urban Ecology','2026FA',1,'Harbor Campus',24,18,SDO_GEOMETRY(2001,4326,SDO_POINT_TYPE(-73.982,40.738,NULL),NULL,NULL));
INSERT INTO course_sections VALUES(503,'POL-105','Public Institutions','2026FA',2,'Riverside Campus',30,25,SDO_GEOMETRY(2001,4326,SDO_POINT_TYPE(-73.985,40.735,NULL),NULL,NULL));
INSERT INTO enrollments VALUES(1,1001,501,'2026FA','ENROLLED');
INSERT INTO enrollments VALUES(2,1002,502,'2026FA','ENROLLED');
INSERT INTO enrollments VALUES(3,1003,501,'2026FA','ENROLLED');
INSERT INTO enrollments VALUES(4,1004,503,'2026FA','ENROLLED');
INSERT INTO support_resources VALUES(1,'Peer Tutoring Studio','Tutoring','Peer tutors help students plan study sessions and review course concepts in a quiet learning space.',1,'Harbor Campus',1);
INSERT INTO support_resources VALUES(2,'Academic Advising Hub','Advising','Advisors help students explore degree plans, course selection, and campus resources.',1,'Harbor Campus',1);
INSERT INTO support_resources VALUES(3,'Student Wellness Center','Wellness','Private student wellness consultations and referrals to campus services.',1,'Harbor Campus',1);
INSERT INTO support_resources VALUES(4,'Riverside Learning Commons','Tutoring','Drop-in tutoring and group study space for students at Riverside Campus.',2,'Riverside Campus',1);
INSERT INTO student_support_requests VALUES(9001,1001,'Tutoring','OPEN',82,1,'Harbor Campus',1,'Email','This week',SDO_GEOMETRY(2001,4326,SDO_POINT_TYPE(-73.986,40.736,NULL),NULL,NULL),JSON_OBJECT('courseCode' VALUE 'MATH-201','topic' VALUE 'Study planning' RETURNING JSON),1,'2026FA',SYSTIMESTAMP-4);
INSERT INTO student_support_requests VALUES(9002,1002,'Advising','OPEN',74,1,'Harbor Campus',2,'Portal','Two days',SDO_GEOMETRY(2001,4326,SDO_POINT_TYPE(-73.983,40.737,NULL),NULL,NULL),JSON_OBJECT('courseCode' VALUE 'ENVS-210','topic' VALUE 'Course planning' RETURNING JSON),2,'2026FA',SYSTIMESTAMP-2);
INSERT INTO student_support_requests VALUES(9003,1003,'Tutoring','IN_PROGRESS',63,1,'Harbor Campus',1,'Email','This week',SDO_GEOMETRY(2001,4326,SDO_POINT_TYPE(-73.984,40.739,NULL),NULL,NULL),JSON_OBJECT('courseCode' VALUE 'MATH-201','topic' VALUE 'Exam preparation' RETURNING JSON),1,'2026FA',SYSTIMESTAMP-6);
INSERT INTO student_support_requests VALUES(9004,1004,'Tutoring','OPEN',67,2,'Riverside Campus',3,'Portal','This week',SDO_GEOMETRY(2001,4326,SDO_POINT_TYPE(-73.981,40.739,NULL),NULL,NULL),JSON_OBJECT('courseCode' VALUE 'POL-105','topic' VALUE 'Writing support' RETURNING JSON),4,'2026FA',SYSTIMESTAMP-1);
INSERT INTO student_support_updates VALUES(1,9001,'Student asked about a peer tutoring appointment.',SYSTIMESTAMP-3,'STAFF');
INSERT INTO student_support_updates VALUES(2,9002,'Advisor shared course planning resources.',SYSTIMESTAMP-1,'STAFF');
INSERT INTO campus_support_centers VALUES(1,'Harbor Peer Learning Center',1,'Harbor Campus','TUTORING',160,72,1,40.735,-73.985,SDO_GEOMETRY(2001,4326,SDO_POINT_TYPE(-73.985,40.735,NULL),NULL,NULL));
INSERT INTO campus_support_centers VALUES(2,'Harbor Advising Hub',1,'Harbor Campus','ADVISING',120,84,1,40.738,-73.982,SDO_GEOMETRY(2001,4326,SDO_POINT_TYPE(-73.982,40.738,NULL),NULL,NULL));
INSERT INTO campus_support_centers VALUES(3,'Riverside Learning Commons',2,'Riverside Campus','TUTORING',140,66,1,40.739,-73.981,SDO_GEOMETRY(2001,4326,SDO_POINT_TYPE(-73.981,40.739,NULL),NULL,NULL));
ALTER TABLE student_support_requests ADD CONSTRAINT support_request_center_fk FOREIGN KEY (service_center_id) REFERENCES campus_support_centers(center_id);
INSERT INTO campus_service_areas VALUES(101,1,'Harbor Campus','North Quad',SDO_GEOMETRY(2003,4326,NULL,SDO_ELEM_INFO_ARRAY(1,1003,1),SDO_ORDINATE_ARRAY(-73.990,40.730,-73.980,40.730,-73.980,40.745,-73.990,40.745,-73.990,40.730)),78);
INSERT INTO campus_service_areas VALUES(102,1,'Harbor Campus','Harbor Commons',SDO_GEOMETRY(2003,4326,NULL,SDO_ELEM_INFO_ARRAY(1,1003,1),SDO_ORDINATE_ARRAY(-73.985,40.734,-73.975,40.734,-73.975,40.744,-73.985,40.744,-73.985,40.734)),89);
INSERT INTO campus_service_areas VALUES(201,2,'Riverside Campus','Riverside Green',SDO_GEOMETRY(2003,4326,NULL,SDO_ELEM_INFO_ARRAY(1,1003,1),SDO_ORDINATE_ARRAY(-73.990,40.730,-73.980,40.730,-73.980,40.745,-73.990,40.745,-73.990,40.730)),64);
INSERT INTO student_support_network_entities VALUES(1001,'STU-1001','Alex Rivera','STUDENT','Applied Mathematics','Harbor Campus',82,1);
INSERT INTO student_support_network_entities VALUES(1002,'STU-1002','Sam Lee','STUDENT','Environmental Studies','Harbor Campus',74,1);
INSERT INTO student_support_network_entities VALUES(1003,'STU-1003','Morgan Chen','STUDENT','Applied Mathematics','Harbor Campus',63,1);
INSERT INTO student_support_network_entities VALUES(1501,'SEC-MATH-201','MATH-201 Section 01','COURSE_SECTION','Applied Mathematics','Harbor Campus',NULL,NULL);
INSERT INTO student_support_network_entities VALUES(1502,'SEC-ENVS-210','ENVS-210 Section 01','COURSE_SECTION','Environmental Studies','Harbor Campus',NULL,NULL);
INSERT INTO student_support_network_entities VALUES(1601,'SERVICE-TUTORING-01','Peer Tutoring Studio','SUPPORT_SERVICE',NULL,'Harbor Campus',NULL,NULL);
INSERT INTO student_support_network_entities VALUES(1602,'ADV-JORDAN-01','Casey Jordan','ADVISOR',NULL,'Harbor Campus',NULL,NULL);
INSERT INTO student_support_network_links VALUES(1,1001,1501,'ENROLLED_IN',1,'2026FA');
INSERT INTO student_support_network_links VALUES(2,1003,1501,'ENROLLED_IN',1,'2026FA');
INSERT INTO student_support_network_links VALUES(3,1002,1502,'ENROLLED_IN',1,'2026FA');
INSERT INTO student_support_network_links VALUES(4,1001,1601,'REQUESTED',0.92,'2026FA');
INSERT INTO student_support_network_links VALUES(5,1002,1601,'REQUESTED',0.87,'2026FA');
INSERT INTO student_support_network_links VALUES(6,1001,1602,'SUPPORTED_BY',0.9,'2026FA');
INSERT INTO student_support_network_links VALUES(7,1501,1001,'HAS_STUDENT',1,'2026FA');
INSERT INTO student_support_network_links VALUES(8,1501,1003,'HAS_STUDENT',1,'2026FA');
INSERT INTO student_support_network_links VALUES(9,1601,1001,'SERVES',0.92,'2026FA');
INSERT INTO student_support_network_links VALUES(10,1601,1002,'SERVES',0.87,'2026FA');
CREATE VIEW student_support_cases_v AS
SELECT r.request_id, s.student_key, p.program_name, r.request_type,
       r.request_status, r.priority_score,
       TRUNC(SYSDATE - CAST(r.created_at AS DATE)) AS open_days,
       r.campus_id, r.campus_name, r.recommended_resource_id
FROM student_support_requests r
JOIN students s ON s.student_id=r.student_id
JOIN academic_programs p ON p.program_id=s.program_id;
CREATE VIEW student_support_demand_training_v AS
SELECT 'COHORT-' || TO_CHAR(level,'FM000') AS cohort_term_id,
       CASE WHEN MOD(level,3)=0 THEN 'Riverside Campus' ELSE 'Harbor Campus' END campus_name,
       CASE MOD(level,3) WHEN 0 THEN 'Public Policy' WHEN 1 THEN 'Applied Mathematics' ELSE 'Environmental Studies' END program_name,
       CASE WHEN MOD(level,2)=0 THEN '2025FA' ELSE '2026SP' END term_code,
       80 + MOD(level*7,120) enrolled_students,
       8 + MOD(level*11,45) open_requests,
       6 + MOD(level*5,38) prior_term_requests,
       45 + MOD(level*13,45) avg_priority_score,
       2 + MOD(level*3,20) median_wait_days,
       CASE WHEN MOD(level,2)=0 THEN 'SURGE' ELSE 'STABLE' END demand_surge_label
FROM dual CONNECT BY level <= 40;
CREATE VIEW program_support_overview_v AS
SELECT r.campus_name, p.program_name, r.term_code,
       COUNT(CASE WHEN r.request_type='Tutoring' AND r.request_status='OPEN' THEN 1 END) open_tutoring_requests
FROM student_support_requests r JOIN students s ON s.student_id=r.student_id
JOIN academic_programs p ON p.program_id=s.program_id
GROUP BY r.campus_name,p.program_name,r.term_code;
CREATE VIEW campus_support_capacity_v AS
SELECT c.campus_name,c.center_name,c.center_type,c.current_load_pct,c.capacity_visits_per_week,
       COUNT(CASE WHEN r.request_status='OPEN' THEN 1 END) open_requests
FROM campus_support_centers c LEFT JOIN student_support_requests r ON r.service_center_id=c.center_id
GROUP BY c.campus_name,c.center_name,c.center_type,c.current_load_pct,c.capacity_visits_per_week;
CREATE VIEW course_section_capacity_v AS
SELECT campus_name, course_code, course_title, term_code, seat_capacity, enrollment_count,
       seat_capacity-enrollment_count available_seats
FROM course_sections;
CREATE TABLE student_support_signal_embeddings (
  request_id NUMBER PRIMARY KEY, embedding VECTOR(384),
  CONSTRAINT signal_request_fk FOREIGN KEY(request_id) REFERENCES student_support_requests(request_id)
);
INSERT INTO student_support_signal_embeddings (request_id,embedding)
SELECT request_id, VECTOR_EMBEDDING(ADMIN.ALL_MINILM_L12_V2 USING
       request_type || ' student request: ' || JSON_VALUE(request_context,'$.topic') AS DATA)
FROM student_support_requests;
COMMIT;


PROMPT Creating the student-support duality view and property graph
CREATE OR REPLACE JSON RELATIONAL DUALITY VIEW student_support_requests_dv AS
SELECT JSON {
    '_id'               : r.request_id,
    'studentId'         : r.student_id,
    'requestType'       : r.request_type,
    'status'            : r.request_status,
    'priorityScore'     : r.priority_score,
    'preferredChannel'  : r.preferred_channel,
    'followUpWindow'    : r.follow_up_window,
    'context'           : r.request_context,
    'createdAt'         : r.created_at,
    'updates' : [
        SELECT JSON {
            'updateId' : u.update_id,
            'message'  : u.update_text,
            'updatedAt': u.updated_at,
            'visibility': u.visibility
        }
        FROM student_support_updates u WITH INSERT UPDATE
        WHERE u.request_id = r.request_id
    ]
}
FROM student_support_requests r WITH INSERT UPDATE;
CREATE PROPERTY GRAPH student_support_network
  VERTEX TABLES (
    student_support_network_entities KEY (entity_id)
      LABEL entity
      PROPERTIES (
        entity_id, entity_key, display_name, entity_type,
        academic_program, campus_name, priority_score, open_request_count
      )
  )
  EDGE TABLES (
    student_support_network_links KEY (link_id)
      SOURCE KEY (from_entity_id)
        REFERENCES student_support_network_entities (entity_id)
      DESTINATION KEY (to_entity_id)
        REFERENCES student_support_network_entities (entity_id)
      LABEL connected_to
      PROPERTIES (relationship_type, evidence_score, academic_term)
  );
PROMPT Registering and indexing campus spatial layers
INSERT INTO user_sdo_geom_metadata (table_name, column_name, diminfo, srid)
VALUES ('COURSE_SECTIONS', 'LOCATION',
  MDSYS.SDO_DIM_ARRAY(MDSYS.SDO_DIM_ELEMENT('Longitude', -180, 180, 0.005),
                      MDSYS.SDO_DIM_ELEMENT('Latitude', -90, 90, 0.005)), 4326);
INSERT INTO user_sdo_geom_metadata (table_name, column_name, diminfo, srid)
VALUES ('STUDENT_SUPPORT_REQUESTS', 'ORIGIN_LOCATION',
  MDSYS.SDO_DIM_ARRAY(MDSYS.SDO_DIM_ELEMENT('Longitude', -180, 180, 0.005),
                      MDSYS.SDO_DIM_ELEMENT('Latitude', -90, 90, 0.005)), 4326);
INSERT INTO user_sdo_geom_metadata (table_name, column_name, diminfo, srid)
VALUES ('CAMPUS_SUPPORT_CENTERS', 'LOCATION',
  MDSYS.SDO_DIM_ARRAY(MDSYS.SDO_DIM_ELEMENT('Longitude', -180, 180, 0.005),
                      MDSYS.SDO_DIM_ELEMENT('Latitude', -90, 90, 0.005)), 4326);
INSERT INTO user_sdo_geom_metadata (table_name, column_name, diminfo, srid)
VALUES ('CAMPUS_SERVICE_AREAS', 'BOUNDARY',
  MDSYS.SDO_DIM_ARRAY(MDSYS.SDO_DIM_ELEMENT('Longitude', -180, 180, 0.005),
                      MDSYS.SDO_DIM_ELEMENT('Latitude', -90, 90, 0.005)), 4326);
COMMIT;
CREATE INDEX course_sections_location_sidx ON course_sections(location)
  INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2;
CREATE INDEX support_requests_origin_sidx ON student_support_requests(origin_location)
  INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2;
CREATE INDEX campus_centers_location_sidx ON campus_support_centers(location)
  INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2;
CREATE INDEX campus_areas_boundary_sidx ON campus_service_areas(boundary)
  INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2;

PROMPT Restricting the existing GENAI profile to aggregate Higher Education views
BEGIN
  DBMS_CLOUD_AI.SET_ATTRIBUTE(
    profile_name => 'GENAI',
    attribute_name => 'object_list',
    attribute_value => '[{"owner":"LLUSER","name":"PROGRAM_SUPPORT_OVERVIEW_V"},' ||
                       '{"owner":"LLUSER","name":"CAMPUS_SUPPORT_CAPACITY_V"},' ||
                       '{"owner":"LLUSER","name":"COURSE_SECTION_CAPACITY_V"}]'
  );
  DBMS_CLOUD_AI.SET_PROFILE('GENAI');
END;
/

PROMPT Checking Higher Education data and lab prerequisites
DECLARE
  l_count NUMBER;
  PROCEDURE require_count(p_actual NUMBER, p_expected NUMBER, p_message VARCHAR2) IS
  BEGIN
    IF p_actual <> p_expected THEN
      RAISE_APPLICATION_ERROR(-20010, p_message || ': expected ' || p_expected || ', found ' || p_actual);
    END IF;
  END;
BEGIN
  SELECT COUNT(*) INTO l_count FROM students;
  require_count(l_count, 4, 'Student seed count');
  SELECT COUNT(*) INTO l_count FROM student_support_requests;
  require_count(l_count, 4, 'Support-request seed count');
  SELECT COUNT(*) INTO l_count FROM student_support_requests WHERE request_id = 990101;
  require_count(l_count, 0, 'Leave request 990101 for Lab 2');
  SELECT COUNT(*) INTO l_count FROM student_support_signal_embeddings;
  require_count(l_count, 4, 'Signal embedding count');
  SELECT COUNT(*) INTO l_count FROM student_support_signal_embeddings
   WHERE VECTOR_DIMENSION_COUNT(embedding) <> 384;
  require_count(l_count, 0, 'Signal embedding dimension');
  SELECT COUNT(*) INTO l_count FROM user_tab_columns
   WHERE table_name = 'SUPPORT_RESOURCES' AND column_name = 'RESOURCE_EMBEDDING';
  require_count(l_count, 0, 'Leave resource embedding column for Lab 3');
  SELECT COUNT(*) INTO l_count FROM student_support_demand_training_v;
  require_count(l_count, 40, 'Demand-training row count');
  SELECT COUNT(*) INTO l_count FROM student_support_requests_dv;
  require_count(l_count, 4, 'Request duality document count');
  SELECT COUNT(*) INTO l_count FROM (
    SELECT SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(location, 0.005) AS valid FROM course_sections
    UNION ALL
    SELECT SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(origin_location, 0.005) FROM student_support_requests
    UNION ALL
    SELECT SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(location, 0.005) FROM campus_support_centers
    UNION ALL
    SELECT SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(boundary, 0.005) FROM campus_service_areas
  ) WHERE valid <> 'TRUE' OR valid IS NULL;
  require_count(l_count, 0, 'Campus geometry validation');
  SELECT COUNT(*) INTO l_count FROM GRAPH_TABLE (
    student_support_network
    MATCH (a IS entity)-[e IS connected_to]->(b IS entity)
    WHERE a.entity_key = 'STU-1001'
    COLUMNS (b.entity_key AS linked_entity)
  );
  IF l_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20011, 'Student graph seed has no outgoing relationships.');
  END IF;
  SELECT COUNT(*) INTO l_count FROM user_objects
   WHERE status = 'INVALID' AND object_name IN (
     'STUDENT_SUPPORT_CASES_V', 'STUDENT_SUPPORT_DEMAND_TRAINING_V',
     'PROGRAM_SUPPORT_OVERVIEW_V', 'CAMPUS_SUPPORT_CAPACITY_V',
     'COURSE_SECTION_CAPACITY_V', 'STUDENT_SUPPORT_REQUESTS_DV',
     'STUDENT_SUPPORT_NETWORK');
  require_count(l_count, 0, 'Invalid workshop view or graph');
  DBMS_OUTPUT.PUT_LINE('Higher Education relational, vector, JSON, graph, spatial, and OML prerequisites passed.');
END;
/
COMMIT;
PROMPT SEER_HIGHER_ED_HANDOFF_LOADER_COMPLETE
EXIT SUCCESS
