/*
 * refresh_demo_dates.sql
 * Re-anchors bundled demo activity dates to the current deployment window.
 *
 * The demo uses rolling windows such as "last 30 days" and "next forecast".
 * This keeps restored or persisted demo data fresh after redeploys without
 * changing custom imported datasets.
 */

SET SERVEROUTPUT ON
SET DEFINE OFF

PROMPT =====================================================
PROMPT Refreshing demo data date window
PROMPT =====================================================

DECLARE
  v_current_anchor TIMESTAMP;
  v_target_anchor  TIMESTAMP := SYSTIMESTAMP - INTERVAL '15' MINUTE;
  v_delta_seconds  NUMBER;
  v_delta_days     NUMBER;

  FUNCTION demo_dataset_active RETURN BOOLEAN IS
    v_source VARCHAR2(20);
  BEGIN
    SELECT active_source
    INTO v_source
    FROM app_dataset_state
    WHERE state_id = 1;

    RETURN LOWER(v_source) = 'demo';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN TRUE;
    WHEN OTHERS THEN
      IF SQLCODE = -942 THEN
        RETURN TRUE;
      END IF;
      RAISE;
  END;

  PROCEDURE shift_ts(p_table_name IN VARCHAR2, p_column_name IN VARCHAR2) IS
  BEGIN
    EXECUTE IMMEDIATE
      'UPDATE ' || p_table_name ||
      ' SET ' || p_column_name || ' = ' || p_column_name ||
      ' + NUMTODSINTERVAL(:delta_seconds, ''SECOND'')' ||
      ' WHERE ' || p_column_name || ' IS NOT NULL'
      USING v_delta_seconds;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
        RAISE;
      END IF;
  END;

  PROCEDURE shift_date(p_table_name IN VARCHAR2, p_column_name IN VARCHAR2) IS
  BEGIN
    EXECUTE IMMEDIATE
      'UPDATE ' || p_table_name ||
      ' SET ' || p_column_name || ' = ' || p_column_name || ' + :delta_days' ||
      ' WHERE ' || p_column_name || ' IS NOT NULL'
      USING v_delta_days;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
        RAISE;
      END IF;
  END;
BEGIN
  IF NOT demo_dataset_active THEN
    DBMS_OUTPUT.PUT_LINE('Active dataset is custom; skipping demo date refresh.');
    RETURN;
  END IF;

  SELECT MAX(activity_at)
  INTO v_current_anchor
  FROM (
    SELECT MAX(CAST(created_at AS TIMESTAMP)) AS activity_at FROM orders
    UNION ALL
    SELECT MAX(posted_at) AS activity_at FROM social_posts
    UNION ALL
    SELECT MAX(requested_at) AS activity_at FROM return_requests
    UNION ALL
    SELECT MAX(created_at) AS activity_at FROM agent_actions
  );

  IF v_current_anchor IS NULL THEN
    DBMS_OUTPUT.PUT_LINE('No dated demo activity found; skipping demo date refresh.');
    RETURN;
  END IF;

  v_delta_seconds := ROUND((CAST(v_target_anchor AS DATE) - CAST(v_current_anchor AS DATE)) * 86400);
  v_delta_days := v_delta_seconds / 86400;

  IF ABS(v_delta_seconds) < 60 THEN
    DBMS_OUTPUT.PUT_LINE('Demo date window is already current.');
    RETURN;
  END IF;

  shift_ts('brands', 'created_at');
  shift_ts('brands', 'updated_at');
  shift_ts('products', 'created_at');
  shift_ts('products', 'updated_at');
  shift_date('products', 'launch_date');
  shift_ts('fulfillment_centers', 'created_at');
  shift_ts('customers', 'created_at');
  shift_ts('influencers', 'created_at');
  shift_ts('social_posts', 'posted_at');
  shift_ts('social_posts', 'processed_at');
  shift_ts('social_posts', 'created_at');
  shift_ts('post_product_mentions', 'created_at');
  shift_ts('orders', 'created_at');
  shift_ts('orders', 'updated_at');
  shift_date('orders', 'estimated_delivery');
  shift_date('orders', 'actual_delivery');
  shift_date('inventory', 'last_restock_date');
  shift_ts('inventory', 'updated_at');
  shift_ts('shipments', 'shipped_at');
  shift_ts('shipments', 'delivered_at');
  shift_ts('shipments', 'created_at');
  shift_date('demand_forecasts', 'forecast_date');
  shift_ts('demand_forecasts', 'created_at');
  shift_ts('demand_regions', 'updated_at');
  shift_ts('influencer_connections', 'first_seen');
  shift_ts('influencer_connections', 'last_interaction');
  shift_ts('brand_influencer_links', 'first_mention');
  shift_ts('brand_influencer_links', 'last_mention');
  shift_date('return_policy_clauses', 'effective_start');
  shift_date('return_policy_clauses', 'effective_end');
  shift_ts('return_policy_clauses', 'created_at');
  shift_ts('return_requests', 'requested_at');
  shift_ts('return_requests', 'created_at');
  shift_ts('return_requests', 'updated_at');
  shift_ts('return_documents', 'created_at');
  shift_ts('return_events', 'created_at');
  shift_ts('return_decisions', 'created_at');
  shift_ts('event_stream', 'created_at');
  shift_ts('agent_actions', 'executed_at');
  shift_ts('agent_actions', 'created_at');

  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Demo dates shifted by ' || ROUND(v_delta_days, 4) || ' day(s).');
END;
/
