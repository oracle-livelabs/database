-- CATCH-UP -> state after Lab 7 (run with SQLcl from the scripts directory).
-- Rebuilds the orders collection, the flattens, and the property graph.
@90_catchup_after_m5.sql
@06_model_bg_reload.sql
@06_orders_seed.sql
@06_graph.sql

-- STATE CHECK: expect ORDERS 40 and the graph tables populated
SELECT (SELECT COUNT(*) FROM "orders")    AS orders_loaded,
       (SELECT COUNT(*) FROM ord)         AS ord_vertices,
       (SELECT COUNT(*) FROM customer)    AS customers,
       (SELECT COUNT(*) FROM order_item)  AS order_items
FROM dual;
