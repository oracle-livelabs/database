-- Run while connected as ADMIN.
-- Usage:
-- @healthcare-platform-handoff-loader.sql "<service-alias>" "<lluser-password>"
--
-- Healthcare workshop data baseline (14,796 tracked records):
--   187 care services + 5,000 quality signals + 3,000 service requests
--   + 187 service vectors + 5,000 signal vectors + 1,422 semantic matches
-- Supporting location data: 2,000 care sites and 30 logistics sites.

SET DEFINE ON
SET VERIFY OFF
WHENEVER SQLERROR EXIT SQL.SQLCODE
SPOOL healthcare_loader_validation.log

DEFINE loader_service_alias = '&1'
DEFINE loader_lluser_password = '&2'

BEGIN
  IF USER = 'ADMIN' THEN
    NULL;
  ELSE
    RAISE_APPLICATION_ERROR(-20020, 'Start the platform loader as ADMIN.');
  END IF;
END;
/

@01-admin-create-lluser.sql "&&loader_lluser_password"

GRANT CREATE SESSION TO LLUSER;

@02-lluser-create-healthcare-objects.sql "&&loader_lluser_password" "&&loader_service_alias"

SET DEFINE ON
CONNECT LLUSER/"&&loader_lluser_password"@&&loader_service_alias

BEGIN
  IF USER <> 'LLUSER' THEN
    RAISE_APPLICATION_ERROR(-20021, 'Platform loader did not finish as LLUSER.');
  END IF;
END;
/

PROMPT
PROMPT Healthcare workshop tracked-record validation
PROMPT Expected total: 14,796

COLUMN data_layer FORMAT A28
COLUMN records FORMAT 9999990

WITH layer_counts (display_order, data_layer, records) AS (
  SELECT 1, 'Care services', COUNT(*)
  FROM hc_care_services
  UNION ALL
  SELECT 2, 'Quality signals', COUNT(*)
  FROM hc_quality_signals
  UNION ALL
  SELECT 3, 'Service requests', COUNT(*)
  FROM hc_service_requests
  UNION ALL
  SELECT 4, 'Service vectors', COUNT(*)
  FROM hc_care_services
  WHERE service_embedding IS NOT NULL
  UNION ALL
  SELECT 5, 'Signal vectors', COUNT(*)
  FROM hc_quality_signals
  WHERE signal_embedding IS NOT NULL
  UNION ALL
  SELECT 6, 'Semantic matches', COUNT(*)
  FROM hc_semantic_matches
), validation_summary (display_order, data_layer, records) AS (
  SELECT display_order, data_layer, records
  FROM layer_counts
  UNION ALL
  SELECT 7, 'Total tracked records', SUM(records)
  FROM layer_counts
)
SELECT data_layer, records
FROM validation_summary
ORDER BY display_order;

PROMPT
PROMPT Supporting location-record validation

SELECT 'Care sites' AS data_layer, COUNT(*) AS records
FROM hc_care_sites
UNION ALL
SELECT 'Logistics sites', COUNT(*)
FROM hc_logistics_sites;

PROMPT
PROMPT Healthcare object validation

SELECT 'Invalid healthcare objects' AS data_layer,
       COUNT(*) AS records
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

UNDEFINE loader_lluser_password
UNDEFINE loader_service_alias
SPOOL OFF
