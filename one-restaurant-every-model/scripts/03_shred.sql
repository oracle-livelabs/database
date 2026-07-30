-- Lab 4: shred the "stores" collection into the canonical schema.
-- Re-run safe: FK-ordered DELETEs first (DROP IF EXISTS guards DDL; DML needs this).
-- Drift resolution is EXPLICIT and DETERMINISTIC - a migration must own these rules:
--   corporate price = MAX(price)      (corporate's latest change wins)
--   corporate name  = MIN(item_name)  (stable tie-break; local renames become overrides)
--   home category   = MIN(category_id)

DELETE FROM item_option;
DELETE FROM extra;
DELETE FROM item_special_hours;
DELETE FROM item_override;
DELETE FROM item;
DELETE FROM category;
DELETE FROM menu;
DELETE FROM store;

INSERT INTO store (store_id, merchant_name)
SELECT s.data."_id".string(), s.data.name.string()
FROM   "stores" s;

INSERT INTO menu (menu_id, store_id, menu_name)
SELECT jt.menu_id, jt.store_id, jt.menu_name
FROM   "stores" s,
       JSON_TABLE(s.data, '$'
         COLUMNS (
           store_id VARCHAR2(10) PATH '$._id',
           NESTED PATH '$.menus[*]'
           COLUMNS (
             menu_id   NUMBER       PATH '$.menu_id',
             menu_name VARCHAR2(50) PATH '$.name'))) jt;

INSERT INTO category (category_id, menu_id, category_name)
SELECT jt.category_id, jt.menu_id, jt.category_name
FROM   "stores" s,
       JSON_TABLE(s.data, '$.menus[*]'
         COLUMNS (
           menu_id NUMBER PATH '$.menu_id',
           NESTED PATH '$.categories[*]'
           COLUMNS (
             category_id   NUMBER       PATH '$.category_id',
             category_name VARCHAR2(50) PATH '$.name'))) jt;

-- One corporate row per item. TO_NUMBER normalizes s_104's string "1000"
-- on conversion - the drift is resolved BY CONSTRUCTION, per the rules above.
INSERT INTO item (item_id, category_id, item_name, description, price)
SELECT TO_NUMBER(jt.item_id),
       MIN(jt.category_id),
       MIN(jt.item_name),
       MAX(jt.description),
       MAX(jt.price)
FROM   "stores" s,
       JSON_TABLE(s.data, '$.menus[*].categories[*]'
         COLUMNS (
           category_id NUMBER PATH '$.category_id',
           NESTED PATH '$.items[*]'
           COLUMNS (
             item_id     VARCHAR2(10)  PATH '$.item_id',
             item_name   VARCHAR2(100) PATH '$.name',
             description VARCHAR2(400) PATH '$.description',
             price       NUMBER        PATH '$.price'))) jt
GROUP  BY TO_NUMBER(jt.item_id);

-- A store whose embedded name differs from the corporate name was a local
-- rename: it becomes an item_override row (s_100's "Lunch Classic").
INSERT INTO item_override (item_id, store_id, override_name)
SELECT TO_NUMBER(jt.item_id), jt.store_id, MIN(jt.item_name)
FROM   "stores" s,
       JSON_TABLE(s.data, '$'
         COLUMNS (
           store_id VARCHAR2(10) PATH '$._id',
           NESTED PATH '$.menus[*].categories[*].items[*]'
           COLUMNS (
             item_id   VARCHAR2(10)  PATH '$.item_id',
             item_name VARCHAR2(100) PATH '$.name'))) jt
WHERE  jt.item_name <> (SELECT i.item_name
                        FROM   item i
                        WHERE  i.item_id = TO_NUMBER(jt.item_id))
GROUP  BY TO_NUMBER(jt.item_id), jt.store_id;

COMMIT;

-- STATE CHECK: expect ITEMS 6, PRICE_1000 1399, OVERRIDES 1
SELECT (SELECT COUNT(*) FROM item)                       AS items,
       (SELECT price FROM item WHERE item_id = 1000)     AS price_1000,
       (SELECT COUNT(*) FROM item_override)              AS overrides
FROM   dual;
