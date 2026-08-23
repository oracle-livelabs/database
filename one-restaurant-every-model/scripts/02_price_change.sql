-- SQL twin of 02_price_change.mongo.js: same change, same deliberate miss.
--
-- The type test is load-bearing. Oracle's SQL/JSON path `==` compares LOOSELY,
-- so a bare `?(@.item_id == 1000)` also matches s_104's STRING "1000" and
-- quietly updates all five stores -- the opposite of the lesson. mongosh's
-- arrayFilter { "i.item_id": 1000 } is strict, so it matches four. Adding
-- `@.item_id.type() == "number"` makes this door behave like that one.
UPDATE "stores" s
SET    s.data = JSON_TRANSFORM(s.data,
         SET '$.menus[*].categories[*].items[*]?(@.item_id.type() == "number" && @.item_id == 1000).price' = 1399
         IGNORE ON MISSING);
COMMIT;

-- STATE CHECK: four stores at 1399; s_104's drifted string copy untouched at
-- its local premium of 1499
SELECT s.data."_id".string() AS store_id, jt.price
FROM   "stores" s,
       JSON_TABLE(s.data, '$.menus[*].categories[*].items[*]'
         COLUMNS (item_id VARCHAR2(10) PATH '$.item_id',
                  price   NUMBER       PATH '$.price')) jt
WHERE  jt.item_id = '1000'
ORDER  BY store_id;
