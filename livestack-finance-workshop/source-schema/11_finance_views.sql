/*
 * 11_finance_views.sql
 * Finance-facing semantic layer for the Seer Equity Bank LiveStack.
 *
 * These views preserve the inherited physical table names used by the
 * application while giving Ask Data, demos, and SQL snippets bank-ready names.
 * Run as: LIVESTACK
 */

CREATE OR REPLACE VIEW finance_institutions_v AS
SELECT
  brand_id AS institution_id,
  brand_name AS institution_name,
  brand_category AS institution_type,
  headquarters_city,
  annual_revenue
FROM brands;

CREATE OR REPLACE VIEW finance_products_v AS
SELECT
  product_id AS financial_product_id,
  product_name AS financial_product_name,
  category AS product_category,
  subcategory,
  unit_price AS fee_or_value,
  tags,
  brand_id AS institution_id
FROM products;

CREATE OR REPLACE VIEW risk_signals_v AS
SELECT
  post_id AS signal_id,
  post_text AS signal_text,
  virality_score AS criticality_score,
  momentum_flag AS severity_band,
  views_count AS exposure_count,
  likes_count AS acknowledgement_count,
  shares_count AS escalation_count,
  comments_count AS cases_opened_count,
  posted_at AS signal_time,
  influencer_id AS source_id
FROM social_posts;

CREATE OR REPLACE VIEW signal_sources_v AS
SELECT
  influencer_id AS source_id,
  handle AS source_code,
  display_name AS source_name,
  CASE platform
    WHEN 'instagram' THEN 'SEC bulletin'
    WHEN 'tiktok' THEN 'Internal fraud alert'
    WHEN 'twitter' THEN 'OCC/FINRA notice'
    WHEN 'youtube' THEN 'Market data feed'
    WHEN 'threads' THEN 'Branch operations advisory'
    ELSE platform
  END AS source_channel,
  follower_count AS source_reach,
  influence_score AS source_authority_score
FROM influencers;

CREATE OR REPLACE VIEW client_transactions_v AS
SELECT
  order_id AS transaction_id,
  customer_id AS client_id,
  order_status AS transaction_status,
  order_total AS transaction_value,
  shipping_cost AS service_fee,
  fulfillment_center_id AS service_center_id,
  social_source_id AS risk_signal_id,
  demand_score AS urgency_score,
  created_at,
  updated_at
FROM orders;

CREATE OR REPLACE VIEW service_centers_v AS
SELECT
  center_id AS service_center_id,
  center_name AS service_center_name,
  CASE center_type
    WHEN 'distribution' THEN 'Regional Operations Hub'
    WHEN 'warehouse' THEN 'Branch Operations Hub'
    WHEN 'micro' THEN 'Advisory Office'
    WHEN 'store' THEN 'Advisory Office'
    WHEN 'drop_ship' THEN 'Partner Service Point'
    ELSE center_type
  END AS service_center_type,
  city,
  state_province,
  latitude,
  longitude,
  capacity_units AS processing_capacity,
  current_load_pct AS utilization_pct,
  is_active
FROM fulfillment_centers;

CREATE OR REPLACE VIEW service_capacity_v AS
SELECT
  inventory_id AS capacity_id,
  product_id AS financial_product_id,
  center_id AS service_center_id,
  quantity_on_hand AS available_capacity,
  quantity_reserved AS reserved_capacity,
  quantity_incoming AS incoming_capacity,
  reorder_point AS minimum_capacity_threshold,
  reorder_qty AS target_capacity_increment,
  updated_at
FROM inventory;

CREATE OR REPLACE VIEW service_routes_v AS
SELECT
  shipment_id AS route_id,
  order_id AS transaction_id,
  center_id AS service_center_id,
  carrier AS route_provider,
  tracking_number AS route_reference,
  ship_status AS service_route_status,
  distance_km,
  estimated_hours,
  ship_cost AS service_route_cost,
  routed_at,
  completed_at,
  created_at
FROM shipments;

COMMIT;

SELECT '11_finance_views.sql complete - finance semantic views created.' AS status FROM dual;
