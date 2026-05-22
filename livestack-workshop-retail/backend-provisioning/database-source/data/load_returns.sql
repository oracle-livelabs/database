/*
 * load_returns.sql
 * Demo returns workload for the Retail LiveStack data foundation.
 * Safe to run repeatedly after the base social-commerce data load.
 */

SET SERVEROUTPUT ON
SET DEFINE OFF

PROMPT =====================================================
PROMPT Loading Retail LiveStack return data
PROMPT =====================================================

DELETE FROM return_decisions;
DELETE FROM return_events;
DELETE FROM return_documents;
DELETE FROM return_requests;
DELETE FROM return_policy_clauses;

INSERT INTO return_policy_clauses (policy_id, clause_code, clause_title, category, clause_text, severity) VALUES
  (1, 'POL-30DAY-UNWORN', '30-day apparel return window', 'Apparel', 'Apparel is eligible for refund within 30 days when labels are attached and the item is unworn. Damaged packaging requires manager review.', 'standard');
INSERT INTO return_policy_clauses (policy_id, clause_code, clause_title, category, clause_text, severity) VALUES
  (2, 'POL-ELECTRONICS-SEAL', 'Electronics seal and serial verification', 'Electronics', 'Electronics returns require original serial number match, intact factory seal for open-box refund, and fraud review when accessories are missing.', 'manager_review');
INSERT INTO return_policy_clauses (policy_id, clause_code, clause_title, category, clause_text, severity) VALUES
  (3, 'POL-LTV-VIP-OVERRIDE', 'VIP save-the-customer override', 'Customer Experience', 'VIP customers with high lifetime value may receive instant credit when return history is low and evidence supports carrier or product defect.', 'vip_override');
INSERT INTO return_policy_clauses (policy_id, clause_code, clause_title, category, clause_text, severity) VALUES
  (4, 'POL-REPEAT-ABUSE', 'Repeat return abuse review', 'Fraud Prevention', 'Customers with multiple high-value returns in a short window require denial or additional documentation when policy evidence is weak.', 'deny');

DECLARE
  v_parent_count NUMBER;
BEGIN
  SELECT COUNT(*)
  INTO v_parent_count
  FROM (
    SELECT o.order_id
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.customer_id IS NOT NULL
      AND oi.product_id IS NOT NULL
    GROUP BY o.order_id
  );

  IF v_parent_count < 5 THEN
    RAISE_APPLICATION_ERROR(
      -20051,
      'load_returns.sql requires at least 5 orders with line items before loading return fixtures. Found ' || v_parent_count
    );
  END IF;

  INSERT INTO return_requests (
    return_id, order_id, customer_id, product_id, return_reason, damage_description,
    return_channel, return_value, risk_rating, recommendation, status, policy_clause,
    confidence_score, requested_at, created_at, updated_at
  )
  WITH candidate_orders AS (
    SELECT
      o.order_id,
      o.customer_id,
      MIN(oi.product_id) AS product_id,
      MAX(NVL(o.order_total, 0)) AS order_total
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.customer_id IS NOT NULL
      AND oi.product_id IS NOT NULL
    GROUP BY o.order_id, o.customer_id
  ),
  fixture_parents AS (
    SELECT
      order_id,
      customer_id,
      product_id,
      order_total,
      ROW_NUMBER() OVER (ORDER BY order_total DESC, order_id) AS rn
    FROM candidate_orders
  ),
  return_fixtures AS (
    SELECT
      1 AS rn,
      'Arrived damaged' AS return_reason,
      'Customer uploaded photos showing a dented package and cracked product shell. Carrier scan shows delayed handoff at the regional hub.' AS damage_description,
      'mobile' AS return_channel,
      69.99 AS return_value,
      'Low' AS risk_rating,
      'Approve' AS recommendation,
      'Needs Review' AS status,
      'POL-LTV-VIP-OVERRIDE' AS policy_clause,
      0.94 AS confidence_score,
      INTERVAL '2' HOUR AS requested_age,
      INTERVAL '2' HOUR AS created_age,
      INTERVAL '100' MINUTE AS updated_age
    FROM dual
    UNION ALL
    SELECT
      2,
      'Size and fit issue',
      'Apparel was tried on but tags appear attached. Return was initiated 18 days after delivery from a store kiosk.',
      'store',
      179.99,
      'Medium',
      'Approve',
      'In Review',
      'POL-30DAY-UNWORN',
      0.88,
      INTERVAL '5' HOUR,
      INTERVAL '5' HOUR,
      INTERVAL '1' HOUR
    FROM dual
    UNION ALL
    SELECT
      3,
      'Missing accessories',
      'Electronics return package is missing charging cable and the serial number does not match the original outbound scan.',
      'web',
      209.97,
      'Very High',
      'Deny',
      'Needs Review',
      'POL-ELECTRONICS-SEAL',
      0.91,
      INTERVAL '11' HOUR,
      INTERVAL '11' HOUR,
      INTERVAL '20' MINUTE
    FROM dual
    UNION ALL
    SELECT
      4,
      'Wrong item shipped',
      'Customer reports receiving a different color. Fulfillment image confidence is inconclusive and the customer has two prior returns this quarter.',
      'contact_center',
      275.00,
      'High',
      'Request Info',
      'Needs Review',
      'POL-REPEAT-ABUSE',
      0.73,
      INTERVAL '1' DAY,
      INTERVAL '1' DAY,
      INTERVAL '2' HOUR
    FROM dual
    UNION ALL
    SELECT
      5,
      'Product not as described',
      'Customer cites inaccurate size chart for a preferred-tier order. Similar complaints appeared in recent product reviews.',
      'marketplace',
      199.98,
      'Medium',
      'Request Info',
      'In Review',
      'POL-30DAY-UNWORN',
      0.79,
      INTERVAL '2' DAY,
      INTERVAL '2' DAY,
      INTERVAL '4' HOUR
    FROM dual
  )
  SELECT
    rf.rn AS return_id,
    fp.order_id,
    fp.customer_id,
    fp.product_id,
    rf.return_reason,
    rf.damage_description,
    rf.return_channel,
    rf.return_value,
    rf.risk_rating,
    rf.recommendation,
    rf.status,
    rf.policy_clause,
    rf.confidence_score,
    SYSTIMESTAMP - rf.requested_age,
    SYSTIMESTAMP - rf.created_age,
    SYSTIMESTAMP - rf.updated_age
  FROM return_fixtures rf
  JOIN fixture_parents fp ON fp.rn = rf.rn;
END;
/

INSERT INTO return_documents (document_id, return_id, document_type, title, excerpt, similarity_score, source_uri) VALUES
  (1, 1, 'Policy Clause', 'VIP save-the-customer override', 'High lifetime value customer with low risk and visible carrier damage is eligible for instant credit while the claim is routed to carrier recovery.', 0.9641, 'policy://POL-LTV-VIP-OVERRIDE');
INSERT INTO return_documents VALUES
  (2, 1, 'Image Note', 'Package damage classifier', 'Vision tag: crushed_corner, cracked_shell, carrier_label_visible. Damage timestamp aligns with final-mile scan exception.', 0.9388, 'image://return/1/package', SYSTIMESTAMP);
INSERT INTO return_documents VALUES
  (3, 2, 'Policy Clause', '30-day apparel return window', 'Return inside 30 days, tags attached, unworn condition likely. Manager review only needed if hygiene seal is removed.', 0.9020, 'policy://POL-30DAY-UNWORN', SYSTIMESTAMP);
INSERT INTO return_documents VALUES
  (4, 3, 'Serial Evidence', 'Serial number mismatch', 'Inbound serial does not match outbound serial. Accessory checklist shows missing charger and adapter.', 0.9820, 'wms://serial/order/5', SYSTIMESTAMP);
INSERT INTO return_documents VALUES
  (5, 3, 'Policy Clause', 'Electronics seal and serial verification', 'Open-box electronics refund requires serial match and full accessory kit. Mismatch should be denied or escalated to fraud operations.', 0.9512, 'policy://POL-ELECTRONICS-SEAL', SYSTIMESTAMP);
INSERT INTO return_documents VALUES
  (6, 4, 'Customer History', 'Repeat high-value return cluster', 'Two prior returns in 67 days with total value above peer segment. Evidence strength is below approval threshold.', 0.8815, 'graph://customer/634/returns', SYSTIMESTAMP);
INSERT INTO return_documents VALUES
  (7, 5, 'Review Trend', 'Similar size chart complaints', 'Vector search found nine recent review snippets about inaccurate sizing for adjacent products in the same category.', 0.8621, 'vector://reviews/size-chart', SYSTIMESTAMP);

INSERT INTO return_events (event_id, return_id, event_type, event_note, actor, created_at) VALUES
  (1, 1, 'Case Created', 'Mobile return request submitted with three images and carrier scan ID.', 'customer', SYSTIMESTAMP - INTERVAL '2' HOUR);
INSERT INTO return_events VALUES
  (2, 1, 'AI Recommendation', 'Vector policy search and customer graph supported instant approval draft.', 'returns_ai_agent', SYSTIMESTAMP - INTERVAL '100' MINUTE);
INSERT INTO return_events VALUES
  (3, 2, 'Store Intake', 'Associate confirmed tags attached and routed to apparel queue.', 'store_associate', SYSTIMESTAMP - INTERVAL '4' HOUR);
INSERT INTO return_events VALUES
  (4, 3, 'Fraud Signal', 'Serial mismatch and missing accessories exceeded denial threshold.', 'returns_ai_agent', SYSTIMESTAMP - INTERVAL '45' MINUTE);
INSERT INTO return_events VALUES
  (5, 4, 'Information Request', 'Outbound packing image could not confirm color. Requesting customer photo.', 'contact_center', SYSTIMESTAMP - INTERVAL '90' MINUTE);
INSERT INTO return_events VALUES
  (6, 5, 'Review Trend Match', 'Product review vector cluster found matching fit complaints.', 'returns_ai_agent', SYSTIMESTAMP - INTERVAL '3' HOUR);

INSERT INTO return_decisions (decision_id, return_id, decision_type, decision_summary, confidence_score, created_by, created_at) VALUES
  (1, 1, 'Approve', 'Draft instant credit and carrier recovery claim. Oracle evidence shows low risk and strong damage match.', 0.94, 'returns_ai_agent', SYSTIMESTAMP - INTERVAL '90' MINUTE);
INSERT INTO return_decisions VALUES
  (2, 3, 'Deny', 'Draft denial due to serial mismatch and missing accessories under electronics policy.', 0.91, 'returns_ai_agent', SYSTIMESTAMP - INTERVAL '30' MINUTE);

COMMIT;

PROMPT Retail return requests loaded: 5
