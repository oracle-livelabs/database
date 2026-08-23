-- CATCH-UP -> state after Lab 5 (run with SQLcl from the scripts directory).
-- Duality views created + REST-enabled; chain price at 1499; the local
-- deviations Lab 5 leaves behind present in the junction.
@90_catchup_after_m4.sql
@04_duality_views.sql

UPDATE item SET base_price = 1499 WHERE item_id = 1000;

-- Lab 5's governance probe writes a local price at Riverside. Replay it here
-- against the junction, which is where a location's own terms actually live.
MERGE INTO menu_item t
USING (SELECT m.menu_id, 1000 AS item_id, 1350 AS price
       FROM   menu m WHERE m.store_id = 's_102') s
ON (t.menu_id = s.menu_id AND t.item_id = s.item_id)
WHEN MATCHED THEN UPDATE SET t.price = s.price;
COMMIT;

-- STATE CHECK: expect BASE_PRICE_1000 1499, RIVERSIDE_1000 1350, DOCS 5
SELECT (SELECT base_price FROM item WHERE item_id = 1000) AS base_price_1000,
       (SELECT mi.price FROM menu_item mi JOIN menu m ON m.menu_id = mi.menu_id
        WHERE  m.store_id = 's_102' AND mi.item_id = 1000) AS riverside_1000,
       (SELECT COUNT(*) FROM "store_menu_dv")              AS docs
FROM dual;
