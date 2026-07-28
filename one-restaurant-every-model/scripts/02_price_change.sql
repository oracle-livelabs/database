-- SQL twin of 02_price_change.mongo.js: same change, same deliberate miss.
-- The JSON path filter matches numeric item_id 1000 only - s_104's string
-- copy stays at 1299, exactly like the mongosh arrayFilter.
UPDATE "stores" s
SET    s.data = JSON_TRANSFORM(s.data,
         SET '$.menus[*].categories[*].items[*]?(@.item_id == 1000).price' = 1399
         IGNORE ON MISSING);
COMMIT;

-- STATE CHECK: four stores at 1399, s_104 drift intact at 1299
SELECT s.data."_id".string() AS store_id, jt.price
FROM   "stores" s,
       JSON_TABLE(s.data, '$.menus[*].categories[*].items[*]'
         COLUMNS (item_id VARCHAR2(10) PATH '$.item_id',
                  price   NUMBER       PATH '$.price')) jt
WHERE  jt.item_id = '1000'
ORDER  BY store_id;
