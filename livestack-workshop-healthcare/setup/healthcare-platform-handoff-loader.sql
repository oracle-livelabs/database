-- Run while connected as ADMIN.
-- Usage:
-- @healthcare-platform-handoff-loader.sql "<service-alias>" "<lluser-password>"

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

SELECT 'VALIDATION SUMMARY' AS status,
       COUNT(*) AS invalid_objects
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
