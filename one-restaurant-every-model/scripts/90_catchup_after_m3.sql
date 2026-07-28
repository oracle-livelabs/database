-- CATCH-UP -> state after Lab 3 (run with SQLcl from the scripts directory).
-- Produces: four stores at 1399; s_104's drifted string copy ("1000") intact
-- at 1299 - Lab 4's see-the-drift step depends on it.
@01_seed_stores.sql
@02_price_change.sql

-- STATE CHECK: expect s_100..s_103 = 1399, s_104 = 1299
SELECT s.data."_id".string() AS store_id, jt.price
FROM   "stores" s,
       JSON_TABLE(s.data, '$.menus[*].categories[*].items[*]'
         COLUMNS (item_id VARCHAR2(10) PATH '$.item_id',
                  price   NUMBER       PATH '$.price')) jt
WHERE  jt.item_id = '1000'
ORDER  BY store_id;
