/*
 * Deprecated staged setup - intentionally blocked.
 *
 * Do not use this file for learner workshop builds. The compact learner
 * setup is retail_workshop_admin_create_lab_seed.sql, run as ADMIN.
 */
SET SERVEROUTPUT ON
BEGIN
  RAISE_APPLICATION_ERROR(-20075, 'Deprecated staged security path. Use @retail_workshop_admin_create_lab_seed.sql from ADMIN for compact learner workshop setup.');
END;
/
