/* Stage 2 - run as RETAILDB. Creates core retail objects, data, spatial objects, vectors, returns, semantic views, and OML models. */
SET SERVEROUTPUT ON
BEGIN
  IF SYS_CONTEXT('USERENV','SESSION_USER') = 'ADMIN' THEN
    RAISE_APPLICATION_ERROR(-20071, 'Run this script as RETAILDB, not ADMIN.');
  END IF;
END;
/
@@schema/01_tables.sql
@@schema/02_json_collections.sql
@@schema/03_graph.sql
@@schema/04_vector_schema.sql
@@schema/05_spatial.sql
@@data/load_all_data.sql
@@hydrate_retail_after_data.sql
@@schema/10_returns.sql
@@data/load_returns.sql
@@schema/11_retail_semantic_views.sql
@@data/refresh_demo_dates.sql
@@data/load_oml_models.sql
@@data/seed_fulfillment_zones.sql
PROMPT Stage 2 complete. Reconnect as ADMIN and run @run_as_admin_security.sql.
