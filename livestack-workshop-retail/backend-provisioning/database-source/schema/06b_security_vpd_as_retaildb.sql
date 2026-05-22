-- SECTION 2: RUN AS SCHEMA OWNER
-- (VPD package, function, policy, and audit policy)
-- ============================================================

-- ============================================================
-- VIRTUAL PRIVATE DATABASE (VPD) POLICIES
-- Restrict fulfillment managers to see only their region's data
-- ============================================================

-- Context package to set user's region
CREATE OR REPLACE PACKAGE sc_security_ctx AS
    PROCEDURE set_user_context(p_username IN VARCHAR2);
    FUNCTION get_region RETURN VARCHAR2;
    FUNCTION get_role RETURN VARCHAR2;
END sc_security_ctx;
/

CREATE OR REPLACE PACKAGE BODY sc_security_ctx AS
    g_region VARCHAR2(100);
    g_role   VARCHAR2(30);

    PROCEDURE set_user_context(p_username IN VARCHAR2) IS
    BEGIN
        SELECT region, role INTO g_region, g_role
        FROM app_users
        WHERE username = p_username
          AND is_active = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            g_region := NULL;
            g_role := 'viewer';
    END;

    FUNCTION get_region RETURN VARCHAR2 IS
    BEGIN
        RETURN g_region;
    END;

    FUNCTION get_role RETURN VARCHAR2 IS
    BEGIN
        RETURN g_role;
    END;
END sc_security_ctx;
/

-- VPD policy function for fulfillment center regional access
CREATE OR REPLACE FUNCTION vpd_fulfillment_region (
    p_schema IN VARCHAR2,
    p_table  IN VARCHAR2
) RETURN VARCHAR2
AS
    v_role   VARCHAR2(30);
    v_region VARCHAR2(100);
BEGIN
    v_role := sc_security_ctx.get_role();
    v_region := sc_security_ctx.get_region();

    -- Admins and analysts see everything
    IF v_role IN ('admin', 'analyst') THEN
        RETURN NULL;  -- no predicate = full access
    END IF;

    -- Fulfillment managers see their region
    IF v_role = 'fulfillment_mgr' AND v_region IS NOT NULL THEN
        RETURN 'state_province = ''' || v_region || '''';
    END IF;

    -- Default: see all active centers
    RETURN 'is_active = 1';
END;
/

-- Apply VPD policy to FULFILLMENT_CENTERS
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema   => USER,
        object_name     => 'FULFILLMENT_CENTERS',
        policy_name     => 'VPD_FC_REGION',
        function_schema => USER,
        policy_function => 'VPD_FULFILLMENT_REGION',
        statement_types => 'SELECT,UPDATE',
        update_check    => TRUE,
        enable          => TRUE
    );
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -28101 THEN  -- policy already exists
            DBMS_RLS.DROP_POLICY(USER, 'FULFILLMENT_CENTERS', 'VPD_FC_REGION');
            DBMS_RLS.ADD_POLICY(
                object_schema   => USER,
                object_name     => 'FULFILLMENT_CENTERS',
                policy_name     => 'VPD_FC_REGION',
                function_schema => USER,
                policy_function => 'VPD_FULFILLMENT_REGION',
                statement_types => 'SELECT,UPDATE',
                update_check    => TRUE,
                enable          => TRUE
            );
        ELSE
            RAISE;
        END IF;
END;
/

-- ============================================================
-- VPD policy for ORDERS table
-- Fulfillment managers see only orders routed to their region's
-- centers; admins/analysts/merchandisers/viewers see all orders.
-- ============================================================

CREATE OR REPLACE FUNCTION vpd_orders_region (
    p_schema IN VARCHAR2,
    p_table  IN VARCHAR2
) RETURN VARCHAR2
AS
    v_role   VARCHAR2(30);
    v_region VARCHAR2(100);
BEGIN
    v_role := sc_security_ctx.get_role();
    v_region := sc_security_ctx.get_region();

    -- Admins and analysts see everything
    IF v_role IN ('admin', 'analyst') THEN
        RETURN NULL;
    END IF;

    -- Fulfillment managers see orders routed to their region's centers
    IF v_role = 'fulfillment_mgr' AND v_region IS NOT NULL THEN
        RETURN 'fulfillment_center_id IN (SELECT center_id FROM fulfillment_centers WHERE state_province = ''' || v_region || ''')';
    END IF;

    -- Merchandiser / viewer: see all orders
    RETURN NULL;
END;
/

-- Apply VPD policy to ORDERS
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema   => USER,
        object_name     => 'ORDERS',
        policy_name     => 'VPD_ORDERS_REGION',
        function_schema => USER,
        policy_function => 'VPD_ORDERS_REGION',
        statement_types => 'SELECT',
        enable          => TRUE
    );
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -28101 THEN  -- policy already exists
            DBMS_RLS.DROP_POLICY(USER, 'ORDERS', 'VPD_ORDERS_REGION');
            DBMS_RLS.ADD_POLICY(
                object_schema   => USER,
                object_name     => 'ORDERS',
                policy_name     => 'VPD_ORDERS_REGION',
                function_schema => USER,
                policy_function => 'VPD_ORDERS_REGION',
                statement_types => 'SELECT',
                enable          => TRUE
            );
        ELSE
            RAISE;
        END IF;
END;
/

-- ============================================================
-- VPD POLICIES FOR GRAPH / SOCIAL DATA
-- Admins and analysts see all graph data.
-- Fulfillment managers see only influencers/posts/connections
-- in their assigned region.
-- Everyone else sees all graph data.
-- ============================================================

-- Policy function for INFLUENCERS table (region column directly)
CREATE OR REPLACE FUNCTION vpd_graph_influencers (
    p_schema IN VARCHAR2,
    p_table  IN VARCHAR2
) RETURN VARCHAR2
AS
    v_role   VARCHAR2(30);
    v_region VARCHAR2(100);
BEGIN
    v_role   := sc_security_ctx.get_role();
    v_region := sc_security_ctx.get_region();

    -- Admins and analysts see everything
    IF v_role IN ('admin', 'analyst') THEN
        RETURN NULL;
    END IF;

    -- Fulfillment managers see only their region's influencers
    IF v_role = 'fulfillment_mgr' AND v_region IS NOT NULL THEN
        RETURN 'region = ''' || v_region || '''';
    END IF;

    -- Everyone else (merchandiser, viewer) sees all
    RETURN NULL;
END;
/

-- Policy function for SOCIAL_POSTS (join through influencer_id)
CREATE OR REPLACE FUNCTION vpd_graph_social_posts (
    p_schema IN VARCHAR2,
    p_table  IN VARCHAR2
) RETURN VARCHAR2
AS
    v_role   VARCHAR2(30);
    v_region VARCHAR2(100);
BEGIN
    v_role   := sc_security_ctx.get_role();
    v_region := sc_security_ctx.get_region();

    IF v_role IN ('admin', 'analyst') THEN
        RETURN NULL;
    END IF;

    IF v_role = 'fulfillment_mgr' AND v_region IS NOT NULL THEN
        RETURN 'influencer_id IN (SELECT influencer_id FROM influencers WHERE region = ''' || v_region || ''')';
    END IF;

    RETURN NULL;
END;
/

-- Policy function for INFLUENCER_CONNECTIONS (edges between influencers)
CREATE OR REPLACE FUNCTION vpd_graph_connections (
    p_schema IN VARCHAR2,
    p_table  IN VARCHAR2
) RETURN VARCHAR2
AS
    v_role   VARCHAR2(30);
    v_region VARCHAR2(100);
BEGIN
    v_role   := sc_security_ctx.get_role();
    v_region := sc_security_ctx.get_region();

    IF v_role IN ('admin', 'analyst') THEN
        RETURN NULL;
    END IF;

    -- Fulfillment managers see connections where either endpoint is in their region
    IF v_role = 'fulfillment_mgr' AND v_region IS NOT NULL THEN
        RETURN 'from_influencer IN (SELECT influencer_id FROM influencers WHERE region = ''' || v_region || ''') '
            || 'OR to_influencer IN (SELECT influencer_id FROM influencers WHERE region = ''' || v_region || ''')';
    END IF;

    RETURN NULL;
END;
/

-- Policy function for BRAND_INFLUENCER_LINKS
CREATE OR REPLACE FUNCTION vpd_graph_brand_links (
    p_schema IN VARCHAR2,
    p_table  IN VARCHAR2
) RETURN VARCHAR2
AS
    v_role   VARCHAR2(30);
    v_region VARCHAR2(100);
BEGIN
    v_role   := sc_security_ctx.get_role();
    v_region := sc_security_ctx.get_region();

    IF v_role IN ('admin', 'analyst') THEN
        RETURN NULL;
    END IF;

    IF v_role = 'fulfillment_mgr' AND v_region IS NOT NULL THEN
        RETURN 'influencer_id IN (SELECT influencer_id FROM influencers WHERE region = ''' || v_region || ''')';
    END IF;

    RETURN NULL;
END;
/

-- Policy function for POST_PRODUCT_MENTIONS
CREATE OR REPLACE FUNCTION vpd_graph_mentions (
    p_schema IN VARCHAR2,
    p_table  IN VARCHAR2
) RETURN VARCHAR2
AS
    v_role   VARCHAR2(30);
    v_region VARCHAR2(100);
BEGIN
    v_role   := sc_security_ctx.get_role();
    v_region := sc_security_ctx.get_region();

    IF v_role IN ('admin', 'analyst') THEN
        RETURN NULL;
    END IF;

    IF v_role = 'fulfillment_mgr' AND v_region IS NOT NULL THEN
        RETURN 'post_id IN (SELECT post_id FROM social_posts WHERE influencer_id IN '
            || '(SELECT influencer_id FROM influencers WHERE region = ''' || v_region || '''))';
    END IF;

    RETURN NULL;
END;
/

-- Apply VPD policy to INFLUENCERS
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema   => USER,
        object_name     => 'INFLUENCERS',
        policy_name     => 'VPD_GRAPH_INFLUENCERS',
        function_schema => USER,
        policy_function => 'VPD_GRAPH_INFLUENCERS',
        statement_types => 'SELECT',
        enable          => TRUE
    );
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -28101 THEN
            DBMS_RLS.DROP_POLICY(USER, 'INFLUENCERS', 'VPD_GRAPH_INFLUENCERS');
            DBMS_RLS.ADD_POLICY(
                object_schema   => USER,
                object_name     => 'INFLUENCERS',
                policy_name     => 'VPD_GRAPH_INFLUENCERS',
                function_schema => USER,
                policy_function => 'VPD_GRAPH_INFLUENCERS',
                statement_types => 'SELECT',
                enable          => TRUE
            );
        ELSE
            RAISE;
        END IF;
END;
/

-- Apply VPD policy to SOCIAL_POSTS
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema   => USER,
        object_name     => 'SOCIAL_POSTS',
        policy_name     => 'VPD_GRAPH_SOCIAL_POSTS',
        function_schema => USER,
        policy_function => 'VPD_GRAPH_SOCIAL_POSTS',
        statement_types => 'SELECT',
        enable          => TRUE
    );
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -28101 THEN
            DBMS_RLS.DROP_POLICY(USER, 'SOCIAL_POSTS', 'VPD_GRAPH_SOCIAL_POSTS');
            DBMS_RLS.ADD_POLICY(
                object_schema   => USER,
                object_name     => 'SOCIAL_POSTS',
                policy_name     => 'VPD_GRAPH_SOCIAL_POSTS',
                function_schema => USER,
                policy_function => 'VPD_GRAPH_SOCIAL_POSTS',
                statement_types => 'SELECT',
                enable          => TRUE
            );
        ELSE
            RAISE;
        END IF;
END;
/

-- Apply VPD policy to INFLUENCER_CONNECTIONS
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema   => USER,
        object_name     => 'INFLUENCER_CONNECTIONS',
        policy_name     => 'VPD_GRAPH_CONNECTIONS',
        function_schema => USER,
        policy_function => 'VPD_GRAPH_CONNECTIONS',
        statement_types => 'SELECT',
        enable          => TRUE
    );
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -28101 THEN
            DBMS_RLS.DROP_POLICY(USER, 'INFLUENCER_CONNECTIONS', 'VPD_GRAPH_CONNECTIONS');
            DBMS_RLS.ADD_POLICY(
                object_schema   => USER,
                object_name     => 'INFLUENCER_CONNECTIONS',
                policy_name     => 'VPD_GRAPH_CONNECTIONS',
                function_schema => USER,
                policy_function => 'VPD_GRAPH_CONNECTIONS',
                statement_types => 'SELECT',
                enable          => TRUE
            );
        ELSE
            RAISE;
        END IF;
END;
/

-- Apply VPD policy to BRAND_INFLUENCER_LINKS
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema   => USER,
        object_name     => 'BRAND_INFLUENCER_LINKS',
        policy_name     => 'VPD_GRAPH_BRAND_LINKS',
        function_schema => USER,
        policy_function => 'VPD_GRAPH_BRAND_LINKS',
        statement_types => 'SELECT',
        enable          => TRUE
    );
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -28101 THEN
            DBMS_RLS.DROP_POLICY(USER, 'BRAND_INFLUENCER_LINKS', 'VPD_GRAPH_BRAND_LINKS');
            DBMS_RLS.ADD_POLICY(
                object_schema   => USER,
                object_name     => 'BRAND_INFLUENCER_LINKS',
                policy_name     => 'VPD_GRAPH_BRAND_LINKS',
                function_schema => USER,
                policy_function => 'VPD_GRAPH_BRAND_LINKS',
                statement_types => 'SELECT',
                enable          => TRUE
            );
        ELSE
            RAISE;
        END IF;
END;
/

-- Apply VPD policy to POST_PRODUCT_MENTIONS
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema   => USER,
        object_name     => 'POST_PRODUCT_MENTIONS',
        policy_name     => 'VPD_GRAPH_MENTIONS',
        function_schema => USER,
        policy_function => 'VPD_GRAPH_MENTIONS',
        statement_types => 'SELECT',
        enable          => TRUE
    );
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -28101 THEN
            DBMS_RLS.DROP_POLICY(USER, 'POST_PRODUCT_MENTIONS', 'VPD_GRAPH_MENTIONS');
            DBMS_RLS.ADD_POLICY(
                object_schema   => USER,
                object_name     => 'POST_PRODUCT_MENTIONS',
                policy_name     => 'VPD_GRAPH_MENTIONS',
                function_schema => USER,
                policy_function => 'VPD_GRAPH_MENTIONS',
                statement_types => 'SELECT',
                enable          => TRUE
            );
        ELSE
            RAISE;
        END IF;
END;
/

-- ============================================================
-- AUDIT POLICY (Unified Auditing)
-- Track sensitive operations on orders and agent actions
-- ============================================================
BEGIN
    EXECUTE IMMEDIATE q'[CREATE AUDIT POLICY sc_order_audit
        ACTIONS UPDATE ON orders,
                DELETE ON orders,
                INSERT ON agent_actions
        WHEN 'SYS_CONTEXT(''USERENV'', ''SESSION_USER'') != ''ADMIN'''
        EVALUATE PER SESSION]';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -46358 THEN
            DBMS_OUTPUT.PUT_LINE('Audit policy SC_ORDER_AUDIT already exists - skipping.');
        ELSE
            RAISE;
        END IF;
END;
/

-- Enable the audit policy (uncomment when ready)
-- AUDIT POLICY sc_order_audit;

COMMIT;

SELECT 'Security objects created successfully' AS status FROM dual;
