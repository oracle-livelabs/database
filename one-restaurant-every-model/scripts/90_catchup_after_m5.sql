-- CATCH-UP -> state after Lab 5 (run with SQLcl from the scripts directory).
-- Duality views created + REST-enabled; item 1000 at 1499; override present.
@90_catchup_after_m4.sql
@04_duality_views.sql

UPDATE item SET price = 1499 WHERE item_id = 1000;

MERGE INTO item_override t
USING (SELECT 1000 AS item_id, 's_100' AS store_id, 'Lunch Classic Special' AS override_name FROM dual) s
ON (t.item_id = s.item_id)
WHEN MATCHED THEN UPDATE SET t.override_name = s.override_name
WHEN NOT MATCHED THEN INSERT (item_id, store_id, override_name)
                      VALUES (s.item_id, s.store_id, s.override_name);
COMMIT;

-- STATE CHECK: expect PRICE_1000 1499, OVERRIDE 'Lunch Classic Special', DOCS 5
SELECT (SELECT price FROM item WHERE item_id = 1000)              AS price_1000,
       (SELECT override_name FROM item_override WHERE item_id = 1000) AS override_name,
       (SELECT COUNT(*) FROM "store_menu_dv")                     AS docs
FROM dual;
