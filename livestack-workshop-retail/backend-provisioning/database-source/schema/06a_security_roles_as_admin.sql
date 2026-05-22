/*
 * 06a_security_roles_as_admin.sql
 * Role-Based Access Control (RBAC) and Virtual Private Database (VPD)
 * Demonstrates converged security within the same database
 *
 * EXECUTION NOTE: This script is split into two sections by connection:
 *   SECTION 1 — Run as ADMIN (requires CREATE ROLE privilege)
 *   SECTION 2 - Run as the schema owner
 *
 * In Oracle AI Database 26ai Free, CREATE ROLE and cross-schema GRANTs require ADMIN.
 * The VPD package, function, policy, and audit policy run as the schema owner.
 */

-- ============================================================
-- SECTION 1: RUN AS ADMIN
-- (CREATE ROLE + GRANT privileges on the application schema)
-- ============================================================

DEFINE APP_SCHEMA_OWNER = RETAILDB

-- ============================================================
-- DATABASE ROLES
-- ============================================================

BEGIN
    EXECUTE IMMEDIATE 'CREATE ROLE sc_admin';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE != -1921 THEN RAISE; END IF;  -- role already exists
END;
/

BEGIN
    EXECUTE IMMEDIATE 'CREATE ROLE sc_analyst';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE != -1921 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'CREATE ROLE sc_fulfillment_mgr';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE != -1921 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'CREATE ROLE sc_merchandiser';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE != -1921 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'CREATE ROLE sc_viewer';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE != -1921 THEN RAISE; END IF;
END;
/

-- ============================================================
-- GRANT PRIVILEGES BY ROLE
-- (Fully qualified with schema prefix — run as ADMIN)
-- ============================================================

-- Admin: full access
GRANT SELECT, INSERT, UPDATE, DELETE ON &&APP_SCHEMA_OWNER..brands TO sc_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON &&APP_SCHEMA_OWNER..products TO sc_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON &&APP_SCHEMA_OWNER..fulfillment_centers TO sc_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON &&APP_SCHEMA_OWNER..inventory TO sc_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON &&APP_SCHEMA_OWNER..customers TO sc_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON &&APP_SCHEMA_OWNER..orders TO sc_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON &&APP_SCHEMA_OWNER..order_items TO sc_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON &&APP_SCHEMA_OWNER..influencers TO sc_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON &&APP_SCHEMA_OWNER..social_posts TO sc_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON &&APP_SCHEMA_OWNER..agent_actions TO sc_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON &&APP_SCHEMA_OWNER..app_users TO sc_admin;

-- Analyst: read all, write forecasts
GRANT SELECT ON &&APP_SCHEMA_OWNER..brands TO sc_analyst;
GRANT SELECT ON &&APP_SCHEMA_OWNER..products TO sc_analyst;
GRANT SELECT ON &&APP_SCHEMA_OWNER..orders TO sc_analyst;
GRANT SELECT ON &&APP_SCHEMA_OWNER..order_items TO sc_analyst;
GRANT SELECT ON &&APP_SCHEMA_OWNER..social_posts TO sc_analyst;
GRANT SELECT ON &&APP_SCHEMA_OWNER..influencers TO sc_analyst;
GRANT SELECT ON &&APP_SCHEMA_OWNER..inventory TO sc_analyst;
GRANT SELECT ON &&APP_SCHEMA_OWNER..fulfillment_centers TO sc_analyst;
GRANT SELECT, INSERT, UPDATE ON &&APP_SCHEMA_OWNER..demand_forecasts TO sc_analyst;
GRANT SELECT ON &&APP_SCHEMA_OWNER..agent_actions TO sc_analyst;

-- Fulfillment Manager: manage inventory and shipments
GRANT SELECT ON &&APP_SCHEMA_OWNER..products TO sc_fulfillment_mgr;
GRANT SELECT ON &&APP_SCHEMA_OWNER..orders TO sc_fulfillment_mgr;
GRANT SELECT ON &&APP_SCHEMA_OWNER..order_items TO sc_fulfillment_mgr;
GRANT SELECT, UPDATE ON &&APP_SCHEMA_OWNER..inventory TO sc_fulfillment_mgr;
GRANT SELECT, UPDATE ON &&APP_SCHEMA_OWNER..fulfillment_centers TO sc_fulfillment_mgr;
GRANT SELECT, INSERT, UPDATE ON &&APP_SCHEMA_OWNER..shipments TO sc_fulfillment_mgr;

-- Merchandiser: manage products, view social
GRANT SELECT, INSERT, UPDATE ON &&APP_SCHEMA_OWNER..brands TO sc_merchandiser;
GRANT SELECT, INSERT, UPDATE ON &&APP_SCHEMA_OWNER..products TO sc_merchandiser;
GRANT SELECT ON &&APP_SCHEMA_OWNER..social_posts TO sc_merchandiser;
GRANT SELECT ON &&APP_SCHEMA_OWNER..influencers TO sc_merchandiser;
GRANT SELECT ON &&APP_SCHEMA_OWNER..demand_forecasts TO sc_merchandiser;

-- Viewer: read-only on key tables
GRANT SELECT ON &&APP_SCHEMA_OWNER..brands TO sc_viewer;
GRANT SELECT ON &&APP_SCHEMA_OWNER..products TO sc_viewer;
GRANT SELECT ON &&APP_SCHEMA_OWNER..social_posts TO sc_viewer;
GRANT SELECT ON &&APP_SCHEMA_OWNER..influencers TO sc_viewer;

-- ============================================================
