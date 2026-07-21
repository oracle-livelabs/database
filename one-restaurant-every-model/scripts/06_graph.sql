-- Lab 7: project a property graph over the orders collection.
-- The flattens are a PROJECTION STEP, not a second source of truth - the
-- "orders" collection remains the transaction record. Idempotent.

DROP PROPERTY GRAPH IF EXISTS order_graph;
DROP TABLE IF EXISTS order_item CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS ord        CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS customer   CASCADE CONSTRAINTS;

CREATE TABLE ord AS
SELECT o.data."_id".string()         AS order_id,
       o.data.customer_id.string()   AS customer_id,
       o.data.store_id.string()      AS store_id
FROM   "orders" o;

CREATE TABLE customer AS
SELECT DISTINCT o.data.customer_id.string() AS customer_id
FROM   "orders" o;

CREATE TABLE order_item AS
SELECT jt.order_id, jt.line_no, jt.item_id, jt.item_name
FROM   "orders" o,
       JSON_TABLE(o.data, '$'
         COLUMNS (
           order_id VARCHAR2(20) PATH '$._id',
           NESTED PATH '$.items[*]'
           COLUMNS (
             line_no   FOR ORDINALITY,
             item_id   NUMBER        PATH '$.item_id',
             item_name VARCHAR2(100) PATH '$.name'))) jt;

-- The contains edge lands on the CANONICAL item table from Lab 4:
-- the graph spans document-born data and relational truth in one declaration.
CREATE PROPERTY GRAPH order_graph
  VERTEX TABLES (
    customer KEY (customer_id),
    ord      KEY (order_id),
    item     KEY (item_id) PROPERTIES (item_id, item_name)
  )
  EDGE TABLES (
    ord AS placed KEY (order_id)
      SOURCE      KEY (customer_id) REFERENCES customer (customer_id)
      DESTINATION KEY (order_id)    REFERENCES ord (order_id)
      LABEL placed,
    order_item AS contains KEY (order_id, line_no)
      SOURCE      KEY (order_id) REFERENCES ord (order_id)
      DESTINATION KEY (item_id)  REFERENCES item (item_id)
      LABEL contains
  );

-- The recommendation: who ordered the cheeseburger also ordered...
SELECT y_name, COUNT(*) AS together
FROM GRAPH_TABLE (order_graph
  MATCH (c IS customer)-[IS placed]->(o1 IS ord)-[IS contains]->(x IS item),
        (c IS customer)-[IS placed]->(o2 IS ord)-[IS contains]->(y IS item)
  WHERE x.item_id = 1000 AND y.item_id <> 1000
  COLUMNS (y.item_name AS y_name))
GROUP BY y_name
ORDER BY together DESC
FETCH FIRST 5 ROWS ONLY;
