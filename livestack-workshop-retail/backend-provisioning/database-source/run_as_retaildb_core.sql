/*
 * Deprecated staged setup - intentionally blocked.
 *
 * Do not use this file for learner workshop builds. The old staged path calls
 * data/load_all_data.sql and refresh_demo_dates.sql, which use random and
 * date-based generators. That makes query results drift from the lab markdown.
 *
 * Canonical deterministic setup:
 *   1. Connect as ADMIN.
 *   2. Run @retail_workshop_admin_create_all_exact_data.sql.
 *   3. Connect as LLUSER and run @verify_retail_workshop_ready.sql if needed.
 */
SET SERVEROUTPUT ON
BEGIN
  RAISE_APPLICATION_ERROR(-20073, 'Deprecated random loader path. Use @retail_workshop_admin_create_all_exact_data.sql from ADMIN for deterministic workshop data.');
END;
/
