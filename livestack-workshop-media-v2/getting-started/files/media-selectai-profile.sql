-- Replace <GENAI_COMPARTMENT_OCID> with the authorized OCI compartment.
-- Confirm region/model availability, then run as LLUSER after ADMIN setup.
-- Uses existing OCI policy; no signing key or password is embedded.
-- Refuses to overwrite an existing SEER_MEDIA_PROFILE.
SET DEFINE OFF
SET VERIFY OFF
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
DECLARE
  l_count PLS_INTEGER;
BEGIN
  IF USER <> 'LLUSER' THEN
    RAISE_APPLICATION_ERROR(-20001, 'Run this script as LLUSER.');
  END IF;
  IF '<GENAI_COMPARTMENT_OCID>' LIKE '<%' THEN
    RAISE_APPLICATION_ERROR(-20004, 'Replace the compartment placeholder before running.');
  END IF;
  SELECT COUNT(*) INTO l_count FROM user_cloud_ai_profiles
  WHERE profile_name = 'SEER_MEDIA_PROFILE';
  IF l_count <> 0 THEN
    RAISE_APPLICATION_ERROR(-20003, 'SEER_MEDIA_PROFILE already exists; inspect it instead of replacing it.');
  END IF;
  DBMS_CLOUD_AI.CREATE_PROFILE(
    profile_name => 'SEER_MEDIA_PROFILE',
    description => 'Media content assets, campaign orders, audience signals, distribution capacity and creator relationships',
    status => 'ENABLED',
    attributes => '{
      "provider": "oci",
      "credential_name": "OCI$RESOURCE_PRINCIPAL",
      "region": "us-chicago-1",
      "oci_compartment_id": "<GENAI_COMPARTMENT_OCID>",
      "model": "meta.llama-3.3-70b-instruct",
      "enforce_object_list": true,
      "comments": true,
      "conversation": true,
      "object_list": [
        {"owner": "LLUSER", "name": "MEDIA_CONTENT_ASSETS_V"},
        {"owner": "LLUSER", "name": "MEDIA_CAMPAIGN_ORDERS_V"},
        {"owner": "LLUSER", "name": "MEDIA_AUDIENCE_SIGNALS_V"},
        {"owner": "LLUSER", "name": "MEDIA_DISTRIBUTION_CAPACITY_V"},
        {"owner": "LLUSER", "name": "MEDIA_CREATOR_RELATIONSHIPS_V"}
      ]
    }');
END;
/

SELECT profile_name, status FROM user_cloud_ai_profiles
WHERE profile_name = 'SEER_MEDIA_PROFILE';

SELECT attribute_name, attribute_value FROM user_cloud_ai_profile_attributes
WHERE profile_name = 'SEER_MEDIA_PROFILE' ORDER BY attribute_name;

-- A successful profile creation alone does not prove model access.
-- The following calls test the configured provider using the lab's seeded data.
SELECT COUNT(*) AS expected_content_asset_count FROM media_content_assets_v;

SELECT DBMS_CLOUD_AI.GENERATE(
  prompt => 'Count all rows in MEDIA_CONTENT_ASSETS_V without filters or joins.',
  profile_name => 'SEER_MEDIA_PROFILE', action => 'showsql') AS generated_sql
FROM dual;

SELECT DBMS_CLOUD_AI.GENERATE(
  prompt => 'Count all rows in MEDIA_CONTENT_ASSETS_V without filters or joins.',
  profile_name => 'SEER_MEDIA_PROFILE', action => 'runsql') AS query_result
FROM dual;
