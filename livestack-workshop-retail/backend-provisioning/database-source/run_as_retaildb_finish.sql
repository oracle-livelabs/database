/* Stage 4 - run as RETAILDB. Creates VPD policies, comments, PL/SQL agent tools, and readiness checks. */
SET SERVEROUTPUT ON
BEGIN
  IF SYS_CONTEXT('USERENV','SESSION_USER') = 'ADMIN' THEN
    RAISE_APPLICATION_ERROR(-20072, 'Run this script as RETAILDB, not ADMIN.');
  END IF;
END;
/
@@schema/06b_security_vpd_as_retaildb.sql
@@schema/09_safe_retail_comments.sql
@@schema/08_agent_tool_functions.sql
@@verify_retail_workshop_ready.sql
PROMPT Stage 4 complete.
