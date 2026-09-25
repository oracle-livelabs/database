-- Document -> canonical. Re-run safe: FK-ordered DELETEs first.
DELETE FROM item_option;
DELETE FROM extra;
DELETE FROM item_special_hours;
DELETE FROM menu_item;
DELETE FROM category;
DELETE FROM menu;
DELETE FROM item;
DELETE FROM store;

INSERT INTO store (store_id, merchant_name)
SELECT s.data."_id".string(), s.data.name.string() FROM "stores" s;

INSERT INTO menu (menu_id, store_id, menu_name, start_time, end_time)
SELECT jt.menu_id, jt.store_id, jt.menu_name, jt.st, jt.en
FROM   "stores" s,
       JSON_TABLE(s.data, '$'
         COLUMNS (
           store_id VARCHAR2(10) PATH '$._id',
           NESTED PATH '$.menus[*]'
           COLUMNS (
             menu_id   NUMBER       PATH '$.menu_id',
             menu_name VARCHAR2(50) PATH '$.name',
             st        VARCHAR2(5)  PATH '$.start_time',
             en        VARCHAR2(5)  PATH '$.end_time'))) jt;

INSERT INTO category (category_id, menu_id, category_name)
SELECT DISTINCT jt.category_id, jt.menu_id, jt.category_name
FROM   "stores" s,
       JSON_TABLE(s.data, '$.menus[*]'
         COLUMNS (
           menu_id NUMBER PATH '$.menu_id',
           NESTED PATH '$.categories[*]'
           COLUMNS (
             category_id   NUMBER       PATH '$.category_id',
             category_name VARCHAR2(50) PATH '$.name'))) jt;

-- CHAIN CATALOG: one row per item_id across the whole chain.
-- Corporate name/price = the value used by the MOST locations (mode); ties break
-- on the lowest store_id. A single location's rename must NOT become the chain
-- name -- that was the old MIN(item_name) bug.
INSERT INTO item (item_id, item_name, description, base_price)
WITH flat AS (
  SELECT TO_NUMBER(jt.item_id) AS item_id, jt.store_id,
         jt.item_name, jt.description, jt.price
  FROM   "stores" s,
         JSON_TABLE(s.data, '$'
           COLUMNS (
             store_id VARCHAR2(10) PATH '$._id',
             NESTED PATH '$.menus[*].categories[*].items[*]'
             COLUMNS (
               item_id     VARCHAR2(10)  PATH '$.item_id',
               item_name   VARCHAR2(100) PATH '$.name',
               description VARCHAR2(400) PATH '$.description',
               price       NUMBER        PATH '$.price'))) jt
), ranked_name AS (
  SELECT item_id, item_name,
         ROW_NUMBER() OVER (PARTITION BY item_id
                            ORDER BY COUNT(*) DESC, MIN(store_id)) rn
  FROM flat GROUP BY item_id, item_name
), ranked_price AS (
  SELECT item_id, price,
         ROW_NUMBER() OVER (PARTITION BY item_id
                            ORDER BY COUNT(*) DESC, MIN(store_id)) rn
  FROM flat GROUP BY item_id, price
)
SELECT n.item_id, n.item_name, MAX(f.description), p.price
FROM   ranked_name n
  JOIN ranked_price p ON p.item_id = n.item_id AND p.rn = 1
  JOIN flat f         ON f.item_id = n.item_id
WHERE  n.rn = 1
GROUP  BY n.item_id, n.item_name, p.price;

-- THE OFFERING: one row per (store menu, item). Local name/price recorded only
-- where they differ from the chain catalog; NULL means "inherit".
INSERT INTO menu_item (menu_id, item_id, category_id, display_name, price)
SELECT jt.menu_id, TO_NUMBER(jt.item_id), jt.category_id,
       CASE WHEN jt.item_name <> i.item_name  THEN jt.item_name END,
       CASE WHEN jt.price     <> i.base_price THEN jt.price     END
FROM   "stores" s,
       JSON_TABLE(s.data, '$.menus[*]'
         COLUMNS (
           menu_id NUMBER PATH '$.menu_id',
           NESTED PATH '$.categories[*]'
           COLUMNS (
             category_id NUMBER PATH '$.category_id',
             NESTED PATH '$.items[*]'
             COLUMNS (
               item_id     VARCHAR2(10)  PATH '$.item_id',
               item_name   VARCHAR2(100) PATH '$.name',
               price       NUMBER        PATH '$.price')))) jt
  JOIN item i ON i.item_id = TO_NUMBER(jt.item_id);

COMMIT;
