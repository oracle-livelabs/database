-- SQL twin of 04_governance_tests.mongo.js for mongosh-blocked attendees.
-- Same three probes through the SQL door; same engine, same rulebook.

-- 1. Corporate-owned field via the location view -> rejected (@noupdate)
--    (expected error: field not updatable in duality view)
UPDATE "location_item_dv" v
SET    v.data = JSON_TRANSFORM(v.data, SET '$.price' = 99)
WHERE  v.data."_id".number() = 1000;

-- 2. Location-owned override -> succeeds, lands in item_override
UPDATE "location_item_dv" v
SET    v.data = JSON_TRANSFORM(v.data, SET '$.override[0].name' = 'Lunch Classic Special')
WHERE  v.data."_id".number() = 1000;
COMMIT;

-- 3. Negative price via the updatable menu view -> ORA-02290 (CHECK price > 0)
UPDATE "store_menu_dv" v
SET    v.data = JSON_TRANSFORM(v.data,
         SET '$.menus[0].categories[0].items[0].price' = -1)
WHERE  v.data."_id".string() = 's_100';

-- STATE CHECK: the accepted write decomposed to one relational row
SELECT item_id, store_id, override_name FROM item_override;
