/*
 * load_oml_models.sql
 * Creates OML feature views and persisted DBMS_DATA_MINING models.
 *
 * Run after the core retail demo data has been loaded.
 */

SET SERVEROUTPUT ON
SET DEFINE OFF

PROMPT =====================================================
PROMPT Building Oracle Machine Learning models
PROMPT =====================================================

@@refresh_social_signal_scores.sql

CREATE OR REPLACE VIEW oml_demand_training_v AS
SELECT p.product_id,
       p.category,
       p.unit_price,
       NVL(eng.total_posts, 0)       AS total_posts,
       NVL(eng.avg_sentiment, 0.5)   AS avg_sentiment,
       NVL(eng.total_likes, 0)       AS total_likes,
       NVL(eng.total_shares, 0)      AS total_shares,
       NVL(eng.total_views, 0)       AS total_views,
       NVL(eng.avg_virality, 0)      AS avg_virality,
       NVL(eng.viral_posts, 0)       AS viral_posts,
       NVL(eng.rising_posts, 0)      AS rising_posts,
       NVL(sales.units_sold, 0)      AS units_sold,
       NVL(sales.revenue, 0)         AS revenue,
       CASE
         WHEN ROUND(LEAST(99,
           NVL(eng.avg_virality, 0) * 0.45 +
           LEAST(NVL(eng.total_posts, 0), 40) * 0.9 +
           LEAST(NVL(eng.viral_posts, 0), 10) * 6 +
           LEAST(NVL(eng.rising_posts, 0), 15) * 2 +
           LEAST(NVL(eng.total_views, 0) / 2000, 25) +
           LEAST(NVL(sales.units_sold, 0), 80) * 0.2
         ), 1) >= 65 THEN 'SURGE'
         ELSE 'STABLE'
       END AS surge_label
FROM products p
LEFT JOIN (
  SELECT ppm.product_id,
         COUNT(*) AS total_posts,
         AVG(sp.sentiment_score) AS avg_sentiment,
         SUM(sp.likes_count) AS total_likes,
         SUM(sp.shares_count) AS total_shares,
         SUM(sp.views_count) AS total_views,
         AVG(sp.virality_score) AS avg_virality,
         SUM(CASE WHEN sp.momentum_flag = 'viral' THEN 1 ELSE 0 END) AS viral_posts,
         SUM(CASE WHEN sp.momentum_flag = 'rising' THEN 1 ELSE 0 END) AS rising_posts
  FROM post_product_mentions ppm
  JOIN social_posts sp ON sp.post_id = ppm.post_id
  GROUP BY ppm.product_id
) eng ON eng.product_id = p.product_id
LEFT JOIN (
  SELECT oi.product_id,
         SUM(oi.quantity) AS units_sold,
         SUM(oi.line_total) AS revenue
  FROM order_items oi
  JOIN orders o ON o.order_id = oi.order_id
  GROUP BY oi.product_id
) sales ON sales.product_id = p.product_id
WHERE p.is_active = 1;

CREATE OR REPLACE VIEW oml_customer_rfm_v AS
SELECT c.customer_id,
       NVL(c.lifetime_value, 0) AS lifetime_value,
       NVL(rfm.recency_days, 999) AS recency_days,
       NVL(rfm.frequency, 0) AS frequency,
       NVL(rfm.monetary, 0) AS monetary,
       NVL(rfm.avg_order_value, 0) AS avg_order_value,
       NVL(rfm.total_items, 0) AS total_items
FROM customers c
LEFT JOIN (
  SELECT o.customer_id,
         ROUND(SYSDATE - CAST(MAX(o.created_at) AS DATE)) AS recency_days,
         COUNT(DISTINCT o.order_id) AS frequency,
         SUM(o.order_total) AS monetary,
         AVG(o.order_total) AS avg_order_value,
         NVL(SUM(oi_cnt.item_count), 0) AS total_items
  FROM orders o
  LEFT JOIN (
    SELECT order_id, SUM(quantity) AS item_count
    FROM order_items
    GROUP BY order_id
  ) oi_cnt ON oi_cnt.order_id = o.order_id
  GROUP BY o.customer_id
) rfm ON rfm.customer_id = c.customer_id;

CREATE OR REPLACE VIEW oml_revenue_training_v AS
SELECT o.order_id,
       o.order_total AS target_revenue,
       NVL(c.customer_tier, 'standard') AS customer_tier,
       NVL(c.lifetime_value, 0) AS lifetime_value,
       NVL(rfm.recency_days, 999) AS recency_days,
       NVL(rfm.frequency, 0) AS frequency,
       NVL(rfm.monetary, 0) AS monetary,
       NVL(rfm.avg_order_value, 0) AS avg_order_value,
       NVL(items.item_count, 0) AS item_count,
       NVL(items.total_quantity, 0) AS total_quantity,
       NVL(items.avg_item_price, 0) AS avg_item_price,
       NVL(o.shipping_cost, 0) AS shipping_cost,
       NVL(o.demand_score, 0) AS demand_score,
       CASE WHEN o.social_source_id IS NOT NULL THEN 1 ELSE 0 END AS social_order_flag
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
LEFT JOIN (
  SELECT customer_id,
         ROUND(SYSDATE - CAST(MAX(created_at) AS DATE)) AS recency_days,
         COUNT(DISTINCT order_id) AS frequency,
         SUM(order_total) AS monetary,
         AVG(order_total) AS avg_order_value
  FROM orders
  GROUP BY customer_id
) rfm ON rfm.customer_id = o.customer_id
LEFT JOIN (
  SELECT order_id,
         COUNT(*) AS item_count,
         SUM(quantity) AS total_quantity,
         AVG(unit_price) AS avg_item_price
  FROM order_items
  GROUP BY order_id
) items ON items.order_id = o.order_id
WHERE o.order_total IS NOT NULL;

CREATE OR REPLACE VIEW oml_product_cluster_v AS
SELECT p.product_id,
       p.unit_price,
       NVL(p.weight_kg, 0) AS weight_kg,
       NVL(sales.units_sold, 0) AS units_sold,
       NVL(sales.revenue, 0) AS revenue,
       NVL(sales.order_count, 0) AS order_count,
       NVL(eng.total_engagement, 0) AS total_engagement,
       NVL(eng.avg_sentiment, 0.5) AS avg_sentiment,
       NVL(eng.avg_virality, 0) AS avg_virality
FROM products p
LEFT JOIN (
  SELECT oi.product_id,
         SUM(oi.quantity) AS units_sold,
         SUM(oi.line_total) AS revenue,
         COUNT(DISTINCT oi.order_id) AS order_count
  FROM order_items oi
  GROUP BY oi.product_id
) sales ON sales.product_id = p.product_id
LEFT JOIN (
  SELECT ppm.product_id,
         SUM(sp.likes_count + sp.shares_count + sp.comments_count) AS total_engagement,
         AVG(sp.sentiment_score) AS avg_sentiment,
         AVG(sp.virality_score) AS avg_virality
  FROM post_product_mentions ppm
  JOIN social_posts sp ON sp.post_id = ppm.post_id
  GROUP BY ppm.product_id
) eng ON eng.product_id = p.product_id
WHERE p.is_active = 1;

DECLARE
  PROCEDURE drop_model_if_exists(p_model_name IN VARCHAR2) IS
  BEGIN
    DBMS_DATA_MINING.DROP_MODEL(p_model_name);
    DBMS_OUTPUT.PUT_LINE('Dropped existing model ' || p_model_name || '.');
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE NOT IN (-40102, -40201) THEN
        DBMS_OUTPUT.PUT_LINE('Ignoring model drop warning for ' || p_model_name || ': ' || SQLERRM);
      END IF;
  END;

  PROCEDURE drop_table_if_exists(p_table_name IN VARCHAR2) IS
  BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE ' || p_table_name || ' PURGE';
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
        RAISE;
      END IF;
  END;
BEGIN
  drop_model_if_exists('DEMAND_SURGE_MODEL');
  drop_model_if_exists('CUSTOMER_SEGMENT_MODEL');
  drop_model_if_exists('REVENUE_PREDICT_MODEL');
  drop_model_if_exists('PRODUCT_CLUSTER_MODEL');

  drop_table_if_exists('OML_RF_SETTINGS');
  drop_table_if_exists('OML_CUSTOMER_KM_SETTINGS');
  drop_table_if_exists('OML_REVENUE_GLM_SETTINGS');
  drop_table_if_exists('OML_PRODUCT_KM_SETTINGS');
END;
/

CREATE TABLE oml_rf_settings (
  setting_name  VARCHAR2(30),
  setting_value VARCHAR2(4000)
);

INSERT INTO oml_rf_settings VALUES ('ALGO_NAME', 'ALGO_RANDOM_FOREST');
INSERT INTO oml_rf_settings VALUES ('PREP_AUTO', 'ON');
INSERT INTO oml_rf_settings VALUES ('RFOR_NUM_TREES', '50');

CREATE TABLE oml_customer_km_settings (
  setting_name  VARCHAR2(30),
  setting_value VARCHAR2(4000)
);

INSERT INTO oml_customer_km_settings VALUES ('ALGO_NAME', 'ALGO_KMEANS');
INSERT INTO oml_customer_km_settings VALUES ('PREP_AUTO', 'ON');
INSERT INTO oml_customer_km_settings VALUES ('CLUS_NUM_CLUSTERS', '4');

CREATE TABLE oml_revenue_glm_settings (
  setting_name  VARCHAR2(30),
  setting_value VARCHAR2(4000)
);

INSERT INTO oml_revenue_glm_settings VALUES ('ALGO_NAME', 'ALGO_GENERALIZED_LINEAR_MODEL');
INSERT INTO oml_revenue_glm_settings VALUES ('PREP_AUTO', 'ON');

CREATE TABLE oml_product_km_settings (
  setting_name  VARCHAR2(30),
  setting_value VARCHAR2(4000)
);

INSERT INTO oml_product_km_settings VALUES ('ALGO_NAME', 'ALGO_KMEANS');
INSERT INTO oml_product_km_settings VALUES ('PREP_AUTO', 'ON');
INSERT INTO oml_product_km_settings VALUES ('CLUS_NUM_CLUSTERS', '5');

COMMIT;

BEGIN
  DBMS_DATA_MINING.CREATE_MODEL(
    model_name          => 'DEMAND_SURGE_MODEL',
    mining_function     => DBMS_DATA_MINING.CLASSIFICATION,
    data_table_name     => 'OML_DEMAND_TRAINING_V',
    case_id_column_name => 'PRODUCT_ID',
    target_column_name  => 'SURGE_LABEL',
    settings_table_name => 'OML_RF_SETTINGS'
  );
  DBMS_OUTPUT.PUT_LINE('Created DEMAND_SURGE_MODEL.');

  DBMS_DATA_MINING.CREATE_MODEL(
    model_name          => 'CUSTOMER_SEGMENT_MODEL',
    mining_function     => DBMS_DATA_MINING.CLUSTERING,
    data_table_name     => 'OML_CUSTOMER_RFM_V',
    case_id_column_name => 'CUSTOMER_ID',
    settings_table_name => 'OML_CUSTOMER_KM_SETTINGS'
  );
  DBMS_OUTPUT.PUT_LINE('Created CUSTOMER_SEGMENT_MODEL.');

  DBMS_DATA_MINING.CREATE_MODEL(
    model_name          => 'REVENUE_PREDICT_MODEL',
    mining_function     => DBMS_DATA_MINING.REGRESSION,
    data_table_name     => 'OML_REVENUE_TRAINING_V',
    case_id_column_name => 'ORDER_ID',
    target_column_name  => 'TARGET_REVENUE',
    settings_table_name => 'OML_REVENUE_GLM_SETTINGS'
  );
  DBMS_OUTPUT.PUT_LINE('Created REVENUE_PREDICT_MODEL.');

  DBMS_DATA_MINING.CREATE_MODEL(
    model_name          => 'PRODUCT_CLUSTER_MODEL',
    mining_function     => DBMS_DATA_MINING.CLUSTERING,
    data_table_name     => 'OML_PRODUCT_CLUSTER_V',
    case_id_column_name => 'PRODUCT_ID',
    settings_table_name => 'OML_PRODUCT_KM_SETTINGS'
  );
  DBMS_OUTPUT.PUT_LINE('Created PRODUCT_CLUSTER_MODEL.');
END;
/

PROMPT OML model inventory:
SELECT model_name, mining_function, algorithm
FROM user_mining_models
WHERE model_name IN (
  'DEMAND_SURGE_MODEL',
  'CUSTOMER_SEGMENT_MODEL',
  'REVENUE_PREDICT_MODEL',
  'PRODUCT_CLUSTER_MODEL'
)
ORDER BY model_name;

PROMPT OML model build complete.
