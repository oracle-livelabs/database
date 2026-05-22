/*
 * 11_retail_semantic_views.sql
 * Retail-facing semantic layer for Ask Retail Data and demo narration.
 *
 * Keep physical tables and existing API routes stable. Add views and comments
 * that map business language to the inherited retail demo schema.
 */

SET SERVEROUTPUT ON

PROMPT =====================================================
PROMPT Creating Retail semantic views and comments
PROMPT =====================================================

CREATE OR REPLACE VIEW retail_returns_workflow_v AS
SELECT
  rr.return_id,
  rr.order_id,
  rr.customer_id,
  c.first_name || ' ' || c.last_name AS customer_name,
  c.customer_tier,
  c.lifetime_value,
  rr.product_id,
  p.product_name,
  p.category,
  rr.return_reason,
  rr.return_channel,
  rr.return_value,
  rr.risk_rating,
  rr.recommendation,
  rr.status,
  rr.policy_clause,
  rr.confidence_score,
  rr.requested_at,
  COUNT(rd.document_id) AS evidence_count
FROM return_requests rr
JOIN customers c ON c.customer_id = rr.customer_id
JOIN products p ON p.product_id = rr.product_id
LEFT JOIN return_documents rd ON rd.return_id = rr.return_id
GROUP BY
  rr.return_id, rr.order_id, rr.customer_id,
  c.first_name, c.last_name, c.customer_tier, c.lifetime_value,
  rr.product_id, p.product_name, p.category,
  rr.return_reason, rr.return_channel, rr.return_value,
  rr.risk_rating, rr.recommendation, rr.status,
  rr.policy_clause, rr.confidence_score, rr.requested_at;

CREATE OR REPLACE VIEW retail_signal_product_v AS
SELECT
  sp.post_id AS signal_id,
  sp.platform AS signal_channel,
  sp.momentum_flag,
  sp.virality_score,
  sp.post_text AS signal_text,
  p.product_id,
  p.product_name,
  p.category
FROM social_posts sp
LEFT JOIN post_product_mentions ppm ON ppm.post_id = sp.post_id
LEFT JOIN products p ON p.product_id = ppm.product_id;

CREATE OR REPLACE VIEW retail_order_return_v AS
SELECT
  o.order_id,
  o.customer_id,
  c.first_name || ' ' || c.last_name AS customer_name,
  c.customer_tier,
  o.order_status,
  o.order_total,
  o.created_at,
  rr.return_id,
  rr.risk_rating AS return_risk_rating,
  rr.recommendation AS return_recommendation,
  rr.status AS return_status,
  rr.return_value,
  rr.return_channel,
  rr.policy_clause
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
LEFT JOIN return_requests rr ON rr.order_id = o.order_id;

CREATE OR REPLACE VIEW retail_fulfillment_risk_v AS
SELECT
  fc.center_id,
  fc.center_name,
  fc.city,
  fc.state_province,
  p.product_id,
  p.product_name,
  p.category,
  i.quantity_on_hand,
  i.quantity_reserved,
  i.quantity_incoming,
  i.reorder_point,
  i.reorder_qty,
  CASE
    WHEN i.quantity_on_hand <= i.reorder_point THEN 'AT_RISK'
    ELSE 'ADEQUATE'
  END AS inventory_risk
FROM fulfillment_centers fc
JOIN inventory i ON i.center_id = fc.center_id
JOIN products p ON p.product_id = i.product_id;

COMMENT ON TABLE return_policy_clauses IS
  'Retail return policy clauses used to ground return recommendations, eligibility, exception handling, and review decisions.';

COMMENT ON TABLE return_requests IS
  'Retail return authorization cases scored by policy, customer history, product context, evidence, risk rating, recommendation, and status.';

COMMENT ON TABLE return_documents IS
  'Grounding evidence for return decisions, including policy clauses, product notes, image notes, warranty terms, marketplace context, and customer history snippets.';

COMMENT ON TABLE return_events IS
  'Timeline events for retail return cases, including customer contact, evidence review, agent analysis, and reviewer action.';

COMMENT ON TABLE return_decisions IS
  'Auditable return decisions and AI-assisted recommendations for retail return cases.';

COMMENT ON TABLE social_posts IS
  'Retail customer and creator signal events used for product demand, sentiment, momentum, and return-risk analysis.';

COMMENT ON TABLE influencers IS
  'Retail creators and community accounts used in the Oracle Property Graph relationship workflow.';

COMMENT ON TABLE retail_returns_workflow_v IS
  'Retail return workflow view for return exposure, policy evidence counts, customer value, risk rating, recommendation, and status.';

COMMENT ON TABLE retail_signal_product_v IS
  'Retail signal view that maps customer and creator signal events to the products they influence, including demand momentum and return-risk context.';

COMMENT ON TABLE retail_order_return_v IS
  'Retail order view with return context for Ask Retail Data and dashboard narration.';

COMMENT ON TABLE retail_fulfillment_risk_v IS
  'Retail fulfillment risk view for inventory levels, reorder points, product demand, and fulfillment center analysis.';

COMMENT ON TABLE agent_actions IS
  'Auditable AI agent actions for retail demand, fulfillment, returns, and commerce workflows, including confidence, status, entity context, and decision payload.';

COMMIT;

PROMPT Retail semantic views ready.
