-- SQL twin of 06_orders_seed.mongo.js: same 40 deterministic orders, built by
-- a PL/SQL loop and inserted into the same "orders" collection table.
-- Line items snapshot item 1000 at 1499; French Fries carry the co-order signal.
CREATE JSON COLLECTION TABLE IF NOT EXISTS "orders";
DELETE FROM "orders";

DECLARE
  v_items VARCHAR2(1000);
  v_total NUMBER;
BEGIN
  FOR n IN 1 .. 40 LOOP
    IF n <= 24 THEN
      v_items := '[{"item_id":1000,"name":"Classic Cheeseburger","price":1499},'
              || '{"item_id":1002,"name":"French Fries","price":499}]';
      v_total := 1998;
    ELSIF n <= 32 THEN
      v_items := '[{"item_id":1000,"name":"Classic Cheeseburger","price":1499},'
              || '{"item_id":1003,"name":"Garden Salad","price":899}]';
      v_total := 2398;
    ELSIF n <= 36 THEN
      v_items := '[{"item_id":2001,"name":"Szechuan Tofu Stir-Fry","price":1199},'
              || '{"item_id":2002,"name":"Beef Chow Fun","price":1399}]';
      v_total := 2598;
    ELSE
      v_items := '[{"item_id":3001,"name":"Carnitas Taco Plate","price":1099},'
              || '{"item_id":1002,"name":"French Fries","price":499}]';
      v_total := 1598;
    END IF;
    INSERT INTO "orders" (data) VALUES (
      '{"_id":"ord_' || (8000 + n) || '",'
      || '"customer_id":"c_' || (MOD(n - 1, 10) + 1) || '",'
      || '"store_id":"s_10' || MOD(n - 1, 5) || '",'
      || '"status":"closed",'
      || '"opened_at":"2026-07-20T12:' || LPAD(n, 2, '0') || ':00Z",'
      || '"items":' || v_items || ','
      || '"total":' || v_total || '}');
  END LOOP;
  COMMIT;
END;
/

-- STATE CHECK: expect 40
SELECT COUNT(*) AS orders_loaded FROM "orders";
