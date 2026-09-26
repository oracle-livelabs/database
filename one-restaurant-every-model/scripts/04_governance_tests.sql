-- SQL twin of 04_governance_tests.mongo.js for mongosh-blocked attendees.
-- Same three probes through the SQL door; same engine, same rulebook.
-- The franchise rule: a LOCATION owns its display name and its price; it does
-- NOT own the chain catalog. That rule lives in the duality view annotations.

-- 1. The location changes its own local price -> ALLOWED (@update on menu_item)
UPDATE "store_menu_dv" v
SET    v.data = JSON_TRANSFORM(v.data,
         SET '$.menus[0].categories[0].items[0].price' = 13.50)
WHERE  v.data."_id".string() = 's_102';
COMMIT;

-- 2. The location tries to rewrite the CHAIN CATALOG name -> REJECTED
--    expected: ORA-40940 (field-level; ORA-40939 is its table-level sibling)
UPDATE "store_menu_dv" v
SET    v.data = JSON_TRANSFORM(v.data,
         SET '$.menus[0].categories[0].items[0].name' = 'Hijacked Burger')
WHERE  v.data."_id".string() = 's_102';

-- 3. Negative price through the document door -> ORA-02290 (CHECK price > 0),
--    wrapped in ORA-42692. The same constraint SQL hit directly in Lab 4.
UPDATE "store_menu_dv" v
SET    v.data = JSON_TRANSFORM(v.data,
         SET '$.menus[0].categories[0].items[0].price' = -1)
WHERE  v.data."_id".string() = 's_102';

-- STATE CHECK: the accepted write decomposed to one relational row.
-- Expect only local deviations - Downtown's rename and the Airport's premiums,
-- plus the 13.50 probe 1 just wrote. Everything else inherits and stores no row.
SELECT m.store_id, mi.item_id, mi.display_name, mi.price
FROM   menu_item mi JOIN menu m ON m.menu_id = mi.menu_id
WHERE  mi.display_name IS NOT NULL OR mi.price IS NOT NULL
ORDER  BY m.store_id, mi.item_id;
