-- CATCH-UP -> state after Lab 4 (run with SQLcl from the scripts directory).
-- Collection state, canonical schema, shred, and the one-row replay.
@01_seed_stores.sql
@02_price_change.sql
@03_canonical_ddl.sql
@03_shred.sql

-- The one-row replay: corporate raises the chain price. One row, not one per
-- store - that is the whole point of the chain catalog.
UPDATE item SET base_price = 13.99 WHERE item_id = 1000;
COMMIT;

-- STATE CHECK: expect ITEMS 7, OFFERINGS 22, BASE_PRICE_1000 13.99, TABLES 8
SELECT (SELECT COUNT(*) FROM item)                        AS items,
       (SELECT COUNT(*) FROM menu_item)                   AS offerings,
       (SELECT base_price FROM item WHERE item_id = 1000) AS base_price_1000,
       (SELECT COUNT(*) FROM user_tables
        WHERE table_name IN ('STORE','MENU','CATEGORY','ITEM','MENU_ITEM','EXTRA',
                             'ITEM_OPTION','ITEM_SPECIAL_HOURS')) AS tables_expected_8
FROM dual;
