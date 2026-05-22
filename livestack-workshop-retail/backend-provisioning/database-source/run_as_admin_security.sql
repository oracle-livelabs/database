/* Stage 3 - run as ADMIN after Stage 2. Creates roles and grants on RETAILDB objects. */
SET SERVEROUTPUT ON
DEFINE APP_SCHEMA_OWNER = RETAILDB
@@schema/06a_security_roles_as_admin.sql
PROMPT Stage 3 complete. Reconnect as RETAILDB and run @run_as_retaildb_finish.sql.
