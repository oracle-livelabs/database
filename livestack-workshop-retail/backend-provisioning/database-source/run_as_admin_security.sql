/*
 * Deprecated staged setup - intentionally blocked.
 *
 * Do not use this file for learner workshop builds. The canonical deterministic
 * setup is retail_workshop_admin_create_all_exact_data.sql, run as ADMIN.
 */
SET SERVEROUTPUT ON
BEGIN
  RAISE_APPLICATION_ERROR(-20075, 'Deprecated staged security path. Use @retail_workshop_admin_create_all_exact_data.sql from ADMIN for deterministic workshop setup.');
END;
/
