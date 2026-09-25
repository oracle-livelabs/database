-- Read-only readiness checks. Run as LLUSER before the lab exercises.
SELECT USER AS signed_in_user,
       SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') AS current_schema
FROM dual;

WITH required_objects (object_name) AS (
  SELECT 'MEDIA_CONTENT_ASSETS_V' FROM dual UNION ALL
  SELECT 'MEDIA_CAMPAIGN_ORDERS_V' FROM dual UNION ALL
  SELECT 'MEDIA_AUDIENCE_SIGNALS_V' FROM dual UNION ALL
  SELECT 'MEDIA_DISTRIBUTION_CAPACITY_V' FROM dual UNION ALL
  SELECT 'MEDIA_CREATOR_RELATIONSHIPS_V' FROM dual UNION ALL
  SELECT 'ORDERS_DV' FROM dual UNION ALL
  SELECT 'PRODUCTS_INVENTORY_DV' FROM dual UNION ALL
  SELECT 'PRODUCT_EMBEDDINGS' FROM dual UNION ALL
  SELECT 'INFLUENCER_NETWORK' FROM dual UNION ALL
  SELECT 'OML_DEMAND_TRAINING_V' FROM dual UNION ALL
  SELECT 'DEMAND_SURGE_MODEL' FROM dual UNION ALL
  SELECT 'SEARCH_PRODUCTS_BY_TEXT' FROM dual
)
SELECT r.object_name, NVL(o.object_type, 'MISSING') AS object_type,
       NVL(o.status, 'MISSING') AS object_status
FROM required_objects r
LEFT JOIN user_objects o ON o.object_name = r.object_name
ORDER BY r.object_name;

SELECT product_id, content_asset, studio_or_label, content_category,
       campaign_value_proxy
FROM media_content_assets_v WHERE product_id = 1;
-- Expected: 1 / Midnight Harbor Premiere Window / Aurora Studios / Film / 24.99

SELECT 'content_assets' AS check_name, COUNT(*) AS actual_count, 187 AS initial_expected
FROM products
UNION ALL SELECT 'campaign_orders', COUNT(*), 3000 FROM orders
UNION ALL SELECT 'campaign_order_items', COUNT(*), 8981 FROM order_items
UNION ALL SELECT 'audience_accounts', COUNT(*), 2000 FROM customers
UNION ALL SELECT 'audience_signals', COUNT(*), 5000 FROM social_posts
UNION ALL SELECT 'studios_and_labels', COUNT(*), 50 FROM brands
UNION ALL SELECT 'creators', COUNT(*), 483 FROM influencers
UNION ALL SELECT 'distribution_hubs', COUNT(*), 30 FROM fulfillment_centers
UNION ALL SELECT 'demand_regions', COUNT(*), 20 FROM demand_regions;

SELECT COUNT(*) AS prepared_content_vectors,
       NVL(SUM(CASE WHEN embedding IS NOT NULL THEN 1 ELSE 0 END), 0) AS nonnull_content_vectors
FROM product_embeddings;
SELECT COUNT(*) AS active_content_assets FROM products WHERE is_active = 1;
-- These three counts should match. Source vectors are 384 dimensional.
SELECT VECTOR_DIMENSION_COUNT(embedding) AS dimensions, COUNT(*) AS vector_count
FROM product_embeddings
GROUP BY VECTOR_DIMENSION_COUNT(embedding);

SELECT owner, model_name, mining_function
FROM all_mining_models
WHERE owner = 'ADMIN' AND model_name = 'ALL_MINILM_L12_V2';
SELECT model_name, mining_function, algorithm
FROM user_mining_models
WHERE model_name IN ('DEMAND_SURGE_MODEL', 'CUSTOMER_SEGMENT_MODEL',
                     'REVENUE_PREDICT_MODEL', 'PRODUCT_CLUSTER_MODEL')
ORDER BY model_name;
SELECT surge_label, COUNT(*) AS content_assets
FROM oml_demand_training_v GROUP BY surge_label ORDER BY surge_label;

SELECT region_name FROM demand_regions
WHERE region_name IN ('Northeast Streaming Corridor', 'Florida Family Watch Zone');

-- Hosted UI roles. GRAPH_DEVELOPER is granted by the loader; the facilitator
-- must additionally grant OML_DEVELOPER for the optional AutoML UI exercise.
-- Expected: both roles after hosted UI preparation and a fresh LLUSER login.
SELECT role FROM session_roles
WHERE role IN ('GRAPH_DEVELOPER', 'OML_DEVELOPER')
ORDER BY role;

-- Hosted AI configuration is separate from the supplied data loader.
-- An enabled profile and provider access must be checked in Labs 7 and 8.
SELECT owner, object_name, object_type
FROM all_objects
WHERE object_type = 'PACKAGE'
  AND object_name IN ('DBMS_CLOUD_AI', 'DBMS_CLOUD_AI_AGENT')
ORDER BY object_name;

-- An empty result is normal until the facilitator configures Labs 7 and 8.
-- A resource-principal credential belongs to ADMIN, so USER_CREDENTIALS is
-- not the readiness test for that authentication method. No provider calls here.
SELECT table_schema, table_name, grantee, privilege, grantable
FROM all_tab_privs
WHERE table_schema = 'ADMIN'
  AND table_name = 'OCI$RESOURCE_PRINCIPAL'
  AND grantee = USER
  AND privilege = 'EXECUTE';
