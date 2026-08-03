-- FULL RESET to the empty-schema starting line (ops / rehearsal use).
-- Leaves only the pre-loaded MENU_MODEL and its DM$ backing tables.
DROP VIEW IF EXISTS "store_menu_dv";
DROP VIEW IF EXISTS "location_item_dv";
DROP VIEW IF EXISTS pos_menu_v;
DROP PROPERTY GRAPH IF EXISTS order_graph;
DROP TABLE IF EXISTS order_item CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS ord        CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS customer   CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS query_vec  CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS item_option        CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS extra              CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS item_special_hours CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS item_override      CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS item               CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS category           CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS menu               CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS store              CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS "stores";
DROP TABLE IF EXISTS "orders";

-- STATE CHECK: expect 0
SELECT COUNT(*) AS application_tables
FROM   user_tables
WHERE  table_name NOT LIKE 'DM$%'
AND    table_name NOT LIKE 'SYS_%';
