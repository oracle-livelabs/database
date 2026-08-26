-- Lab 8 finale: graph + relational + vector in ONE statement, ONE plan tree.
WITH ring AS (
  -- GRAPH: the items customer c_5 has actually ordered - their taste profile
  SELECT DISTINCT gt.item_id
  FROM GRAPH_TABLE (order_graph
    MATCH (c IS customer)-[IS placed]->(o IS ord)-[IS contains]->(i IS item)
    WHERE c.customer_id = 'c_5'
    COLUMNS (i.item_id AS item_id)) gt
)
SELECT i.item_name, i.base_price          -- RELATIONAL: the chain catalog
FROM   ring r
  JOIN item i ON i.item_id = r.item_id
WHERE  i.active
ORDER  BY VECTOR_DISTANCE(i.desc_vec,     -- VECTOR: ranked by meaning
         VECTOR_EMBEDDING(menu_model USING 'leafy starter' AS data),
         COSINE)
FETCH FIRST 5 ROWS ONLY;

-- Read the plan. EXPLAIN PLAN and dbms_xplan.display() must run in the SAME
-- script: Database Actions gives each request its own session.
EXPLAIN PLAN FOR
WITH ring AS (
  SELECT DISTINCT gt.item_id
  FROM GRAPH_TABLE (order_graph
    MATCH (c IS customer)-[IS placed]->(o IS ord)-[IS contains]->(i IS item)
    WHERE c.customer_id = 'c_5'
    COLUMNS (i.item_id AS item_id)) gt
)
SELECT i.item_name, i.base_price
FROM   ring r JOIN item i ON i.item_id = r.item_id
WHERE  i.active
ORDER  BY VECTOR_DISTANCE(i.desc_vec,
         VECTOR_EMBEDDING(menu_model USING 'leafy starter' AS data),
         COSINE)
FETCH FIRST 5 ROWS ONLY;

SELECT * FROM dbms_xplan.display();
