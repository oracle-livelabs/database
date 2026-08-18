-- SQL twin of 06_orders_seed.mongo.js: the same 40 deterministic orders,
-- built by PL/SQL and inserted into the same "orders" collection table.
--
-- Customers belong to CUISINE COHORTS. GRAPH_TABLE matches co-orders through a
-- shared *customer*, not a shared order, so if every customer cycles through
-- every basket they all end up ordering everything and "people who ordered X
-- also ordered Y" collapses into "Y is the most popular item on the menu".
-- Cohorts keep the co-order neighbourhoods cuisine-coherent.
--
-- Line items snapshot item 1000 at the post-Lab-5 price of 1499.
CREATE JSON COLLECTION TABLE IF NOT EXISTS "orders";
DELETE FROM "orders";

DECLARE
  TYPE t_num IS TABLE OF NUMBER;
  TYPE t_str IS TABLE OF VARCHAR2(20);

  n PLS_INTEGER := 0;

  FUNCTION item_name(p_id NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_id
             WHEN 1000 THEN 'Classic Cheeseburger'
             WHEN 1002 THEN 'French Fries'
             WHEN 1003 THEN 'Garden Salad'
             WHEN 2001 THEN 'Szechuan Tofu Stir-Fry'
             WHEN 2002 THEN 'Beef Chow Fun'
             WHEN 3001 THEN 'Carnitas Taco Plate'
           END;
  END item_name;

  FUNCTION item_price(p_id NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN CASE p_id
             WHEN 1000 THEN 1499 WHEN 1002 THEN 499  WHEN 1003 THEN 899
             WHEN 2001 THEN 1199 WHEN 2002 THEN 1399 WHEN 3001 THEN 1099
           END;
  END item_price;

  FUNCTION item_json(p_id NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN '{"item_id":' || p_id
        || ',"name":"'   || item_name(p_id)
        || '","price":'  || item_price(p_id) || '}';
  END item_json;

  PROCEDURE seed_cohort(p_name VARCHAR2, p_cust t_str, p_a t_num, p_b t_num) IS
  BEGIN
    FOR ci IN 1 .. p_cust.COUNT LOOP
      FOR bi IN 1 .. p_a.COUNT LOOP
        n := n + 1;
        INSERT INTO "orders" (data) VALUES (
          '{"_id":"ord_'        || (8000 + n) || '",'
          || '"customer_id":"'  || p_cust(ci) || '",'
          || '"store_id":"s_10' || MOD(n - 1, 5) || '",'
          || '"cohort":"'       || p_name || '",'
          || '"status":"closed",'
          || '"opened_at":"2026-07-20T12:' || LPAD(n, 2, '0') || ':00Z",'
          || '"items":[' || item_json(p_a(bi)) || ',' || item_json(p_b(bi)) || '],'
          || '"total":'  || (item_price(p_a(bi)) + item_price(p_b(bi))) || '}');
      END LOOP;
    END LOOP;
  END seed_cohort;
BEGIN
  -- 10 customers x 4 orders = 40, generated in cohort order.
  seed_cohort('noodle', t_str('c_1','c_2','c_3'),
              t_num(2001, 2001, 2001, 2002), t_num(2002, 2002, 2002, 1003));
  seed_cohort('burger', t_str('c_4','c_5','c_6','c_7'),
              t_num(1000, 1000, 1000, 1000), t_num(1002, 1002, 1002, 1003));
  seed_cohort('taco',   t_str('c_8','c_9','c_10'),
              t_num(3001, 3001, 3001, 3001), t_num(1002, 1002, 1003, 1002));
  COMMIT;
END;
/

-- STATE CHECK: expect 40 orders
SELECT COUNT(*) AS orders_loaded FROM "orders";
