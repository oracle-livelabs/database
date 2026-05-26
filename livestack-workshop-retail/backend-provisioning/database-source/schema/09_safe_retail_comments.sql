SET SERVEROUTPUT ON
PROMPT Adding safe retail comments used by Ask Retail Data
COMMENT ON TABLE brands IS 'Product brands sold by Seer Sporting Goods.';
COMMENT ON TABLE products IS 'Retail products with category, price, tags, and brand relationship.';
COMMENT ON TABLE fulfillment_centers IS 'Fulfillment centers and warehouses with capacity, region, and spatial location.';
COMMENT ON TABLE inventory IS 'Inventory levels for products at fulfillment centers.';
COMMENT ON TABLE customers IS 'Retail customers with address, loyalty tier, lifetime value, and spatial location.';
COMMENT ON TABLE orders IS 'Customer orders with status, revenue, demand score, fulfillment center, and optional social source.';
COMMENT ON TABLE order_items IS 'Line items within a customer order.';
COMMENT ON TABLE influencers IS 'Creators and influencers with platform, follower count, engagement rate, and influence score.';
COMMENT ON TABLE social_posts IS 'Creator and customer social posts with sentiment, virality, and momentum fields.';
COMMENT ON TABLE post_product_mentions IS 'Detected relationships between social posts and retail products.';
COMMENT ON TABLE return_requests IS 'Retail return requests with reason, channel, risk rating, recommendation, status, policy evidence, and confidence.';
COMMENT ON TABLE agent_actions IS 'Audit log of AI agent decisions and database-backed actions.';
COMMENT ON TABLE event_stream IS 'Native JSON event stream used for application and agent audit events.';
COMMIT;
