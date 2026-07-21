-- CATCH-UP -> state after Lab 4 (run with SQLcl from the scripts directory).
-- Collection state, canonical schema, shred, and the one-row replay.
@01_seed_stores.sql
@02_price_change.sql
@03_canonical_ddl.sql
@03_shred.sql

UPDATE item SET price = 1399 WHERE item_id = 1000;
COMMIT;

-- STATE CHECK: expect ITEMS 6, PRICE_1000 1399, OVERRIDES 1, TABLES 8
SELECT (SELECT COUNT(*) FROM item)                   AS items,
       (SELECT price FROM item WHERE item_id = 1000) AS price_1000,
       (SELECT COUNT(*) FROM item_override)          AS overrides,
       (SELECT COUNT(*) FROM user_tables
        WHERE table_name IN ('STORE','MENU','CATEGORY','ITEM','EXTRA',
                             'ITEM_OPTION','ITEM_SPECIAL_HOURS','ITEM_OVERRIDE')) AS tables_expected_8
FROM dual;
