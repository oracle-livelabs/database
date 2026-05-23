/* Stage 1 - run as ADMIN. Creates or refreshes the RETAILDB schema owner. */
SET SERVEROUTPUT ON
DEFINE APP_SCHEMA_USER = RETAILDB
DEFINE APP_SCHEMA_PASSWORD = REPLACE_WITH_STRONG_RETAILDB_PASSWORD
@@schema/00_setup.sql
PROMPT Stage 1 complete. Upload all_MiniLM_L12_v2.onnx to DATA_PUMP_DIR if it is not already present, then connect as RETAILDB and run @run_as_retaildb_core.sql.
