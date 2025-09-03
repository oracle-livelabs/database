-- Create AIWORLD25 user for Oracle Database 23ai Workshop
-- This script creates a user with all necessary privileges to run workshop labs

-- Create the user
CREATE USER aiworld25 IDENTIFIED BY "OracleAIworld2025";

-- Grant basic connection and resource privileges
GRANT CONNECT, RESOURCE TO aiworld25;

-- Grant DB_DEVELOPER role (baseline for development tasks)
GRANT DB_DEVELOPER_ROLE TO aiworld25;

-- Set unlimited quota on DATA tablespace
ALTER USER aiworld25 QUOTA UNLIMITED ON DATA;

-- Essential roles for workshop features
GRANT SQL_FIREWALL_ADMIN TO aiworld25;
GRANT GRAPH_DEVELOPER TO aiworld25;
GRANT CONSOLE_DEVELOPER TO aiworld25;

-- System privileges for user and schema management
GRANT CREATE USER TO aiworld25;
GRANT DROP USER TO aiworld25;
GRANT ALTER USER TO aiworld25;
GRANT CREATE SESSION TO aiworld25;

-- Schema-level privilege management
GRANT GRANT ANY SCHEMA PRIVILEGE TO aiworld25;

-- Domain operations (23ai feature)
GRANT CREATE DOMAIN TO aiworld25;
GRANT DROP ANY DOMAIN TO aiworld25;
GRANT ALTER ANY DOMAIN TO aiworld25;

-- System operations
GRANT ALTER SYSTEM TO aiworld25;

-- DBA view access for workshop labs
GRANT SELECT ON DBA_USERS TO aiworld25;
GRANT SELECT ON DBA_SCHEMA_PRIVS TO aiworld25;
GRANT SELECT ON DBA_TAB_PRIVS TO aiworld25;
GRANT SELECT ON DBA_DATA_FILES TO aiworld25;

-- SQL Firewall specific view access 
-- Note: These views only exist when SQL Firewall is enabled
-- Run these grants manually after enabling SQL Firewall if needed:
-- GRANT SELECT ON DBA_SQL_FIREWALL_CAPTURE_LOGS TO aiworld25;
-- GRANT SELECT ON DBA_SQL_FIREWALL_ALLOWED_SQL TO aiworld25;  
-- GRANT SELECT ON DBA_SQL_FIREWALL_VIOLATIONS TO aiworld25;
-- GRANT EXECUTE ON DBMS_SQL_FIREWALL TO aiworld25;

-- Package execution privileges
GRANT EXECUTE ON DBMS_SPACE TO aiworld25;
GRANT EXECUTE ON DBMS_MLE TO aiworld25;
GRANT EXECUTE ON DBMS_OUTPUT TO aiworld25;

-- ONNX embedding model privileges for Oracle Database 23ai
GRANT EXECUTE ON DBMS_VECTOR TO aiworld25;
GRANT CREATE ANY DIRECTORY TO aiworld25;
GRANT DROP ANY DIRECTORY TO aiworld25;
GRANT READ, WRITE ON DIRECTORY DATA_PUMP_DIR TO aiworld25;

-- Graph proxy connection for Property Graph operations
ALTER USER aiworld25 GRANT CONNECT THROUGH GRAPH$PROXY_USER;

-- Enable schema for REST services (if ORDS is available)
BEGIN
  ORDS_ADMIN.ENABLE_SCHEMA(
    p_enabled => TRUE,
    p_schema => 'AIWORLD25',
    p_url_mapping_type => 'BASE_PATH',
    p_url_mapping_pattern => 'aiworld25',
    p_auto_rest_auth => FALSE
  );
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ORDS not available or already configured');
END;
/

-- Enable data sharing (if available)
BEGIN
  C##ADP$SERVICE.DBMS_SHARE.ENABLE_SCHEMA(
    SCHEMA_NAME => 'AIWORLD25',
    ENABLED => TRUE
  );
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Data sharing not available or already configured');
END;
/

-- Set default role to include all granted roles
ALTER USER aiworld25 DEFAULT ROLE ALL;

COMMIT;