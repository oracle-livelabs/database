/*
 * 00_setup.sql
 * Database Setup — MUST be run as ADMIN
 * Oracle AI Database 26ai Free
 *
 * Creates the LIVESTACK schema owner and grants every privilege
 * required by the application's subsequent schema scripts.
 *
 * Execution order:
 *   1. Connect as ADMIN and run this script.
 *   2. Connect as LIVESTACK and run 01_tables.sql through 08_agents.sql.
 *
 * SQLcl example:
 *   connect admin@<tns_alias>
 *   @00_setup.sql
 *   connect livestack/<password>@<tns_alias>
 *   @01_tables.sql
 *   ...
 *
 * WARNING: Change the default password before running in any shared or
 *          production environment.
 */

-- ============================================================
-- GUARD: This script must run as ADMIN
-- ============================================================
BEGIN
    IF SYS_CONTEXT('USERENV', 'SESSION_USER') != 'ADMIN' THEN
        RAISE_APPLICATION_ERROR(
            -20001,
            'This script must be run as ADMIN. ' ||
            'Current user: ' || SYS_CONTEXT('USERENV', 'SESSION_USER')
        );
    END IF;
    DBMS_OUTPUT.PUT_LINE('Connected as: ' || SYS_CONTEXT('USERENV', 'SESSION_USER'));
END;
/

-- ============================================================
-- CREATE SCHEMA OWNER: LIVESTACK
-- Idempotent — skips creation if the user already exists.
-- ============================================================
-- !! CHANGE THIS PASSWORD before deploying to a shared environment !!
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM dba_users
    WHERE username = 'LIVESTACK';

    IF v_count = 0 THEN
        EXECUTE IMMEDIATE q'[
            CREATE USER livestack
            IDENTIFIED BY "<change-this-password>"
            DEFAULT TABLESPACE data
            TEMPORARY TABLESPACE temp
            QUOTA UNLIMITED ON data
        ]';
        DBMS_OUTPUT.PUT_LINE('User LIVESTACK created.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('User LIVESTACK already exists — skipping creation.');
    END IF;
END;
/

-- ============================================================
-- CORE SESSION AND DDL PRIVILEGES
-- Covers scripts: 01_tables.sql, 02_json_collections.sql,
--                 03_graph.sql, 04_vector.sql, 05_spatial.sql
-- ============================================================
GRANT CREATE SESSION         TO livestack;  -- connect to the database
GRANT CREATE TABLE           TO livestack;  -- tables, vector columns, spatial columns
GRANT CREATE VIEW            TO livestack;  -- JSON Duality Views
GRANT CREATE SEQUENCE        TO livestack;  -- standalone sequences if needed
GRANT CREATE PROCEDURE       TO livestack;  -- procedures, functions
GRANT CREATE PACKAGE         TO livestack;  -- PL/SQL packages (06_security.sql)
GRANT CREATE TRIGGER         TO livestack;  -- triggers
GRANT CREATE TYPE            TO livestack;  -- object types / collection types
GRANT CREATE ROLE            TO livestack;  -- sc_admin, sc_analyst, etc. (06_security.sql)
GRANT CREATE JOB             TO livestack;  -- DBMS_SCHEDULER jobs if needed
GRANT UNLIMITED TABLESPACE   TO livestack;  -- unrestricted storage quota

-- ============================================================
-- CONVERGED DATABASE FEATURE GRANTS
-- ============================================================

-- JSON / SODA Collections (02_json_collections.sql)
GRANT SODA_APP               TO livestack;

-- Property Graph (03_graph.sql)
-- Grants CREATE PROPERTY GRAPH and related graph DDL/DML privileges
GRANT GRAPH_DEVELOPER        TO livestack;

-- Spatial (05_spatial.sql)
-- EXECUTE on SDO geometry packages used in constraints and operators.
-- NOTE: MDSYS table objects (e.g. SDO_COORD_REF_SYS) are already
--       granted to PUBLIC in Oracle AI Database 26ai Free and do not require an explicit grant
--       from ADMIN — attempting one raises ORA-01031.
GRANT EXECUTE ON MDSYS.SDO_GEOM TO livestack;
GRANT EXECUTE ON MDSYS.SDO_UTIL TO livestack;
GRANT EXECUTE ON MDSYS.SDO_CS   TO livestack;

-- Row-Level Security / Virtual Private Database (06_security.sql)
-- Required for DBMS_RLS.ADD_POLICY / DROP_POLICY calls
GRANT EXECUTE ON SYS.DBMS_RLS            TO livestack;

-- Unified Auditing — create audit policies (06_security.sql)
GRANT AUDIT_ADMIN            TO livestack;

-- Vector / ONNX model loading (04_vector.sql)
-- LOAD_ONNX_MODEL requires EXECUTE on DBMS_VECTOR.
-- READ,WRITE on DATA_PUMP_DIR is needed to stage the downloaded zip.
GRANT EXECUTE ON DBMS_VECTOR             TO livestack;
GRANT READ, WRITE ON DIRECTORY data_pump_dir TO livestack;

-- Select AI / AI Agent framework (07_ai_profile.sql + 08_agents.sql)
-- LiveStack uses Ollama at the application layer, but if these packages are
-- present in the target database we grant them for optional manual workflows.
BEGIN
    FOR stmt IN (
        SELECT 'GRANT EXECUTE ON DBMS_CLOUD_AI TO livestack' AS sql_stmt FROM dual UNION ALL
        SELECT 'GRANT EXECUTE ON DBMS_CLOUD_AI_AGENT TO livestack' FROM dual UNION ALL
        SELECT 'GRANT EXECUTE ON DBMS_CLOUD TO livestack' FROM dual
    ) LOOP
        BEGIN
            EXECUTE IMMEDIATE stmt.sql_stmt;
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Skipping optional AI grant: ' || stmt.sql_stmt);
        END;
    END LOOP;
END;
/

-- ============================================================
-- NETWORK ACCESS CONTROL LIST
-- Allows LIVESTACK to make outbound HTTPS calls to OCI AI
-- services invoked by Select AI (07_agents.sql).
-- ============================================================
BEGIN
    DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE(
        host => '*',
        ace  => xs$ace_type(
                    privilege_list => xs$name_list('connect', 'resolve'),
                    principal_name => 'LIVESTACK',
                    principal_type => xs_acl.ptype_db
                )
    );
    DBMS_OUTPUT.PUT_LINE('Network ACL granted to LIVESTACK.');
EXCEPTION
    WHEN OTHERS THEN
        -- ORA-44416: ACE already exists for this principal
        IF SQLCODE = -44416 THEN
            DBMS_OUTPUT.PUT_LINE('Network ACL already exists — skipping.');
        ELSE
            RAISE;
        END IF;
END;
/

-- ============================================================
-- VERIFICATION
-- ============================================================
SELECT username,
       account_status,
       default_tablespace,
       temporary_tablespace,
       profile,
       created
FROM   dba_users
WHERE  username = 'LIVESTACK';

SELECT privilege
FROM   dba_sys_privs
WHERE  grantee = 'LIVESTACK'
ORDER  BY privilege;

SELECT granted_role
FROM   dba_role_privs
WHERE  grantee = 'LIVESTACK'
ORDER  BY granted_role;

SELECT 'Setup complete.' ||
       ' Connect as LIVESTACK and run 01_tables.sql through 08_agents.sql.' AS next_step
FROM   dual;
