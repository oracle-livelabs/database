-- CATCH-UP -> state after Lab 2. Run with SQLcl from the scripts directory
-- (Cloud Shell: `sql /nolog` then connect, then @90_catchup_after_m2.sql).
-- All catch-ups are SQL so mongosh-blocked attendees can run them.
@01_seed_stores.sql

-- STATE CHECK: 5 stores; item 1000 at 1299 everywhere; s_104 drift planted
SELECT s.data."_id".string() AS store_id, jt.item_id, jt.price
FROM   "stores" s,
       JSON_TABLE(s.data, '$.menus[*].categories[*].items[*]'
         COLUMNS (item_id VARCHAR2(10) PATH '$.item_id',
                  price   NUMBER       PATH '$.price')) jt
WHERE  jt.item_id = '1000'
ORDER  BY store_id;
