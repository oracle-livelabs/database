DROP PROPERTY GRAPH IF EXISTS order_graph;
DROP TABLE IF EXISTS order_item CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS ord        CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS customer   CASCADE CONSTRAINTS;

CREATE TABLE ord AS
SELECT o.data."_id".string() AS order_id,
       o.data.customer_id.string() AS customer_id,
       o.data.store_id.string()    AS store_id
FROM "orders" o;
ALTER TABLE ord ADD CONSTRAINT ord_pk PRIMARY KEY (order_id);

CREATE TABLE customer AS
SELECT DISTINCT o.data.customer_id.string() AS customer_id FROM "orders" o;
ALTER TABLE customer ADD CONSTRAINT customer_pk PRIMARY KEY (customer_id);

CREATE TABLE order_item AS
SELECT jt.order_id, jt.line_no, jt.item_id, jt.item_name
FROM "orders" o,
     JSON_TABLE(o.data, '$'
       COLUMNS (
         order_id VARCHAR2(20) PATH '$._id',
         NESTED PATH '$.items[*]'
         COLUMNS (
           line_no   FOR ORDINALITY,
           item_id   NUMBER        PATH '$.item_id',
           item_name VARCHAR2(100) PATH '$.name'))) jt;
ALTER TABLE order_item ADD CONSTRAINT order_item_pk PRIMARY KEY (order_id, line_no);
CREATE INDEX order_item_item_ix ON order_item (item_id);
CREATE INDEX ord_customer_ix    ON ord (customer_id);

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
