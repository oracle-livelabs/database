-- Facilitator setup. Run as ADMIN after reviewing existing OCI policy.
-- No OCI IAM changes, private keys, account changes, or delegation privileges.
SET DEFINE OFF
SET VERIFY OFF
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
DECLARE
  l_count PLS_INTEGER;
BEGIN
  IF USER <> 'ADMIN' THEN
    RAISE_APPLICATION_ERROR(-20001, 'Run this script as ADMIN.');
  END IF;
  SELECT COUNT(*) INTO l_count FROM dba_users WHERE username = 'LLUSER';
  IF l_count <> 1 THEN
    RAISE_APPLICATION_ERROR(-20002, 'LLUSER must already exist.');
  END IF;
  SELECT COUNT(*) INTO l_count FROM dba_credentials
  WHERE owner = 'ADMIN' AND credential_name = 'OCI$RESOURCE_PRINCIPAL';
  IF l_count = 0 THEN
    DBMS_CLOUD_ADMIN.ENABLE_RESOURCE_PRINCIPAL();
  END IF;
  SELECT COUNT(*) INTO l_count FROM dba_tab_privs
  WHERE owner = 'ADMIN' AND table_name = 'OCI$RESOURCE_PRINCIPAL'
    AND grantee = 'LLUSER' AND privilege = 'EXECUTE';
  IF l_count = 0 THEN
    DBMS_CLOUD_ADMIN.ENABLE_RESOURCE_PRINCIPAL(
      username => 'LLUSER', grant_option => FALSE);
  END IF;
END;
/

GRANT EXECUTE ON DBMS_CLOUD TO LLUSER;
GRANT EXECUTE ON DBMS_CLOUD_AI TO LLUSER;
GRANT EXECUTE ON DBMS_CLOUD_AI_AGENT TO LLUSER;

SELECT owner, credential_name, enabled
FROM dba_credentials
WHERE owner = 'ADMIN' AND credential_name = 'OCI$RESOURCE_PRINCIPAL';

SELECT owner, table_name, grantee, privilege, grantable
FROM dba_tab_privs
WHERE owner = 'ADMIN' AND table_name = 'OCI$RESOURCE_PRINCIPAL'
  AND grantee = 'LLUSER';
