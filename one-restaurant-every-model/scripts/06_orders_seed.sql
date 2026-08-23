-- SQL twin of 06_orders_seed.mongo.js -- the SAME 40 orders, generated from
-- the same fixture. Customers belong to ORDERING COHORTS: GRAPH_TABLE matches
-- co-orders through a shared CUSTOMER, so undifferentiated customers would
-- collapse "people who ordered X also ordered Y" into "Y is popular".
-- Line items snapshot the catalog price at the moment of sale.
CREATE JSON COLLECTION TABLE IF NOT EXISTS "orders";
DELETE FROM "orders";

INSERT INTO "orders" (data) VALUES
('{"_id":"ord_8001","customer_id":"c_1","store_id":"s_100","cohort":"classic","status":"closed","opened_at":"2026-07-20T12:01:00Z","items":[{"item_id":1000,"name":"Classic Cheeseburger","price":1299},{"item_id":1002,"name":"French Fries","price":499}],"total":1798}');
INSERT INTO "orders" (data) VALUES
('{"_id":"ord_8002","customer_id":"c_1","store_id":"s_101","cohort":"classic","status":"closed","opened_at":"2026-07-20T12:02:00Z","items":[{"item_id":1000,"name":"Classic Cheeseburger","price":1299},{"item_id":1002,"name":"French Fries","price":499}],"total":1798}');
INSERT INTO "orders" (data) VALUES
('{"_id":"ord_8003","customer_id":"c_1","store_id":"s_102","cohort":"classic","status":"closed","opened_at":"2026-07-20T12:03:00Z","items":[{"item_id":1000,"name":"Classic Cheeseburger","price":1299},{"item_id":1002,"name":"French Fries","price":499}],"total":1798}');
INSERT INTO "orders" (data) VALUES
('{"_id":"ord_8004","customer_id":"c_1","store_id":"s_104","cohort":"classic","status":"closed","opened_at":"2026-07-20T12:04:00Z","items":[{"item_id":1000,"name":"Classic Cheeseburger","price":1299},{"item_id":1003,"name":"Garden Salad","price":899}],"total":2198}');
INSERT INTO "orders" (data) VALUES
('{"_id":"ord_8005","customer_id":"c_2","store_id":"s_101","cohort":"classic","status":"closed","opened_at":"2026-07-20T12:05:00Z","items":[{"item_id":1000,"name":"Classic Cheeseburger","price":1299},{"item_id":1002,"name":"French Fries","price":499}],"total":1798}');
INSERT INTO "orders" (data) VALUES
('{"_id":"ord_8006","customer_id":"c_2","store_id":"s_102","cohort":"classic","status":"closed","opened_at":"2026-07-20T12:06:00Z","items":[{"item_id":1000,"name":"Classic Cheeseburger","price":1299},{"item_id":1002,"name":"French Fries","price":499}],"total":1798}');
INSERT INTO "orders" (data) VALUES
('{"_id":"ord_8007","customer_id":"c_2","store_id":"s_104","cohort":"classic","status":"closed","opened_at":"2026-07-20T12:07:00Z","items":[{"item_id":1000,"name":"Classic Cheeseburger","price":1299},{"item_id":1002,"name":"French Fries","price":499}],"total":1798}');
INSERT INTO "orders" (data) VALUES
('{"_id":"ord_8008","customer_id":"c_2","store_id":"s_100","cohort":"classic","status":"closed","opened_at":"2026-07-20T12:08:00Z","items":[{"item_id":1000,"name":"Classic Cheeseburger","price":1299},{"item_id":1003,"name":"Garden Salad","price":899}],"total":2198}');
INSERT INTO "orders" (data) VALUES
('{"_id":"ord_8009","customer_id":"c_3","store_id":"s_102","cohort":"classic","status":"closed","opened_at":"2026-07-20T12:09:00Z","items":[{"item_id":1000,"name":"Classic Cheeseburger","price":1299},{"item_id":1002,"name":"French Fries","price":499}],"total":1798}');
INSERT INTO "orders" (data) VALUES
('{"_id":"ord_8010","customer_id":"c_3","store_id":"s_104","cohort":"classic","status":"closed","opened_at":"2026-07-20T12:10:00Z","items":[{"item_id":1000,"name":"Classic Cheeseburger","price":1299},{"item_id":1002,"name":"French Fries","price":499}],"total":1798}');
INSERT INTO "orders" (data) VALUES
('{"_id":"ord_8011","customer_id":"c_3","store_id":"s_100","cohort":"classic","status":"closed","opened_at":"2026-07-20T12:11:00Z","items":[{"item_id":1000,"name":"Classic Cheeseburger","price":1299},{"item_id":1002,"name":"French Fries","price":499}],"total":1798}');
INSERT INTO "orders" (data) VALUES
('{"_id":"ord_8012","customer_id":"c_3","store_id":"s_101","cohort":"classic","status":"closed","opened_at":"2026-07-20T12:12:00Z","items":[{"item_id":1000,"name":"Classic Cheeseburger","price":1299},{"item_id":1003,"name":"Garden Salad","price":899}],"total":2198}');
INSERT INTO "orders" (data) VALUES
('{"_id":"ord_8013","customer_id":"c_4","store_id":"s_104","cohort":"classic","status":"closed","opened_at":"2026-07-20T12:13:00Z","items":[{"item_id":1000,"name":"Classic Cheeseburger","price":1299},{"item_id":1002,"name":"French Fries","price":499}],"total":1798}');
INSERT INTO "orders" (data) VALUES
('{"_id":"ord_8014","customer_id":"c_4","store_id":"s_100","cohort":"classic","status":"closed","opened_at":"2026-07-20T12:14:00Z","items":[{"item_id":1000,"name":"Classic Cheeseburger","price":1299},{"item_id":1002,"name":"French Fries","price":499}],"total":1798}');
INSERT INTO "orders" (data) VALUES
('{"_id":"ord_8015","customer_id":"c_4","store_id":"s_101","cohort":"classic","status":"closed","opened_at":"2026-07-20T12:15:00Z","items":[{"item_id":1000,"name":"Classic Cheeseburger","price":1299},{"item_id":1002,"name":"French Fries","price":499}],"total":1798}');
INSERT INTO "orders" (data) VALUES
('{"_id":"ord_8016","customer_id":"c_4","store_id":"s_102","cohort":"classic","status":"closed","opened_at":"2026-07-20T12:16:00Z","items":[{"item_id":1000,"name":"Classic Cheeseburger","price":1299},{"item_id":1003,"name":"Garden Salad","price":899}],"total":2198}');
INSERT INTO "orders" (data) VALUES
('{"_id":"ord_8017","customer_id":"c_5","store_id":"s_101","cohort":"veggie","status":"closed","opened_at":"2026-07-20T12:17:00Z","items":[{"item_id":1004,"name":"Black Bean Chipotle Burger","price":1199},{"item_id":1003,"name":"Garden Salad","price":899}],"total":2098}');
INSERT INTO "orders" (data) VALUES
('{"_id":"ord_8018","customer_id":"c_5","store_id":"s_103","cohort":"veggie","status":"closed","opened_at":"2026-07-20T12:18:00Z","items":[{"item_id":1004,"name":"Black Bean Chipotle Burger","price":1199},{"item_id":1003,"name":"Garden Salad","price":899}],"total":2098}');
INSERT INTO "orders" (data) VALUES
('{"_id":"ord_8019","customer_id":"c_5","store_id":"s_101","cohort":"veggie","status":"closed","opened_at":"2026-07-20T12:19:00Z","items":[{"item_id":1004,"name":"Black Bean Chipotle Burger","price":1199},{"item_id":1003,"name":"Garden Salad","price":899}],"total":2098}');
INSERT INTO "orders" (data) VALUES
('{"_id":"ord_8020","customer_id":"c_5","store_id":"s_103","cohort":"veggie","status":"closed","opened_at":"2026-07-20T12:20:00Z","items":[{"item_id":1004,"name":"Black Bean Chipotle Burger","price":1199},{"item_id":1002,"name":"French Fries","price":499}],"total":1698}');
INSERT INTO "orders" (data) VALUES
('{"_id":"ord_8021","customer_id":"c_6","store_id":"s_103","cohort":"veggie","status":"closed","opened_at":"2026-07-20T12:21:00Z","items":[{"item_id":1004,"name":"Black Bean Chipotle Burger","price":1199},{"item_id":1003,"name":"Garden Salad","price":899}],"total":2098}');
INSERT INTO "orders" (data) VALUES
('{"_id":"ord_8022","customer_id":"c_6","store_id":"s_101","cohort":"veggie","status":"closed","opened_at":"2026-07-20T12:22:00Z","items":[{"item_id":1004,"name":"Black Bean Chipotle Burger","price":1199},{"item_id":1003,"name":"Garden Salad","price":899}],"total":2098}');
INSERT INTO "orders" (data) VALUES
('{"_id":"ord_8023","customer_id":"c_6","store_id":"s_103","cohort":"veggie","status":"closed","opened_at":"2026-07-20T12:23:00Z","items":[{"item_id":1004,"name":"Black Bean Chipotle Burger","price":1199},{"item_id":1003,"name":"Garden Salad","price":899}],"total":2098}');
INSERT INTO "orders" (data) VALUES
('{"_id":"ord_8024","customer_id":"c_6","store_id":"s_101","cohort":"veggie","status":"closed","opened_at":"2026-07-20T12:24:00Z","items":[{"item_id":1004,"name":"Black Bean Chipotle Burger","price":1199},{"item_id":1002,"name":"French Fries","price":499}],"total":1698}');
INSERT INTO "orders" (data) VALUES
('{"_id":"ord_8025","customer_id":"c_7","store_id":"s_101","cohort":"veggie","status":"closed","opened_at":"2026-07-20T12:25:00Z","items":[{"item_id":1004,"name":"Black Bean Chipotle Burger","price":1199},{"item_id":1003,"name":"Garden Salad","price":899}],"total":2098}');
INSERT INTO "orders" (data) VALUES
('{"_id":"ord_8026","customer_id":"c_7","store_id":"s_103","cohort":"veggie","status":"closed","opened_at":"2026-07-20T12:26:00Z","items":[{"item_id":1004,"name":"Black Bean Chipotle Burger","price":1199},{"item_id":1003,"name":"Garden Salad","price":899}],"total":2098}');
INSERT INTO "orders" (data) VALUES
('{"_id":"ord_8027","customer_id":"c_7","store_id":"s_101","cohort":"veggie","status":"closed","opened_at":"2026-07-20T12:27:00Z","items":[{"item_id":1004,"name":"Black Bean Chipotle Burger","price":1199},{"item_id":1003,"name":"Garden Salad","price":899}],"total":2098}');
INSERT INTO "orders" (data) VALUES
('{"_id":"ord_8028","customer_id":"c_7","store_id":"s_103","cohort":"veggie","status":"closed","opened_at":"2026-07-20T12:28:00Z","items":[{"item_id":1004,"name":"Black Bean Chipotle Burger","price":1199},{"item_id":1002,"name":"French Fries","price":499}],"total":1698}');
INSERT INTO "orders" (data) VALUES
('{"_id":"ord_8029","customer_id":"c_8","store_id":"s_100","cohort":"indulgent","status":"closed","opened_at":"2026-07-20T12:29:00Z","items":[{"item_id":1001,"name":"Bacon Double Stack","price":1599},{"item_id":1006,"name":"Chocolate Malt Shake","price":599}],"total":2198}');
INSERT INTO "orders" (data) VALUES
('{"_id":"ord_8030","customer_id":"c_8","store_id":"s_101","cohort":"indulgent","status":"closed","opened_at":"2026-07-20T12:30:00Z","items":[{"item_id":1001,"name":"Bacon Double Stack","price":1599},{"item_id":1006,"name":"Chocolate Malt Shake","price":599}],"total":2198}');
INSERT INTO "orders" (data) VALUES
('{"_id":"ord_8031","customer_id":"c_8","store_id":"s_100","cohort":"indulgent","status":"closed","opened_at":"2026-07-20T12:31:00Z","items":[{"item_id":1001,"name":"Bacon Double Stack","price":1599},{"item_id":1006,"name":"Chocolate Malt Shake","price":599}],"total":2198}');
INSERT INTO "orders" (data) VALUES
('{"_id":"ord_8032","customer_id":"c_8","store_id":"s_101","cohort":"indulgent","status":"closed","opened_at":"2026-07-20T12:32:00Z","items":[{"item_id":1001,"name":"Bacon Double Stack","price":1599},{"item_id":1002,"name":"French Fries","price":499}],"total":2098}');
INSERT INTO "orders" (data) VALUES
('{"_id":"ord_8033","customer_id":"c_9","store_id":"s_101","cohort":"indulgent","status":"closed","opened_at":"2026-07-20T12:33:00Z","items":[{"item_id":1001,"name":"Bacon Double Stack","price":1599},{"item_id":1006,"name":"Chocolate Malt Shake","price":599}],"total":2198}');
INSERT INTO "orders" (data) VALUES
('{"_id":"ord_8034","customer_id":"c_9","store_id":"s_100","cohort":"indulgent","status":"closed","opened_at":"2026-07-20T12:34:00Z","items":[{"item_id":1001,"name":"Bacon Double Stack","price":1599},{"item_id":1006,"name":"Chocolate Malt Shake","price":599}],"total":2198}');
INSERT INTO "orders" (data) VALUES
('{"_id":"ord_8035","customer_id":"c_9","store_id":"s_101","cohort":"indulgent","status":"closed","opened_at":"2026-07-20T12:35:00Z","items":[{"item_id":1001,"name":"Bacon Double Stack","price":1599},{"item_id":1006,"name":"Chocolate Malt Shake","price":599}],"total":2198}');
INSERT INTO "orders" (data) VALUES
('{"_id":"ord_8036","customer_id":"c_9","store_id":"s_100","cohort":"indulgent","status":"closed","opened_at":"2026-07-20T12:36:00Z","items":[{"item_id":1001,"name":"Bacon Double Stack","price":1599},{"item_id":1002,"name":"French Fries","price":499}],"total":2098}');
INSERT INTO "orders" (data) VALUES
('{"_id":"ord_8037","customer_id":"c_10","store_id":"s_100","cohort":"indulgent","status":"closed","opened_at":"2026-07-20T12:37:00Z","items":[{"item_id":1001,"name":"Bacon Double Stack","price":1599},{"item_id":1006,"name":"Chocolate Malt Shake","price":599}],"total":2198}');
INSERT INTO "orders" (data) VALUES
('{"_id":"ord_8038","customer_id":"c_10","store_id":"s_101","cohort":"indulgent","status":"closed","opened_at":"2026-07-20T12:38:00Z","items":[{"item_id":1001,"name":"Bacon Double Stack","price":1599},{"item_id":1006,"name":"Chocolate Malt Shake","price":599}],"total":2198}');
INSERT INTO "orders" (data) VALUES
('{"_id":"ord_8039","customer_id":"c_10","store_id":"s_100","cohort":"indulgent","status":"closed","opened_at":"2026-07-20T12:39:00Z","items":[{"item_id":1001,"name":"Bacon Double Stack","price":1599},{"item_id":1006,"name":"Chocolate Malt Shake","price":599}],"total":2198}');
INSERT INTO "orders" (data) VALUES
('{"_id":"ord_8040","customer_id":"c_10","store_id":"s_101","cohort":"indulgent","status":"closed","opened_at":"2026-07-20T12:40:00Z","items":[{"item_id":1001,"name":"Bacon Double Stack","price":1599},{"item_id":1002,"name":"French Fries","price":499}],"total":2098}');
COMMIT;

-- STATE CHECK: expect 40
SELECT COUNT(*) AS orders_loaded FROM "orders";
