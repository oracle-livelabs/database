-- Lab 8 FINALE: graph + relational + vector in ONE statement, ONE plan tree.

WITH ring AS (
  -- GRAPH: items ordered by customers who co-ordered with customer c_1
  SELECT DISTINCT gt.item_id
  FROM GRAPH_TABLE (order_graph
    MATCH (c IS customer)-[IS placed]->(o IS ord)-[IS contains]->(i IS item)
    WHERE c.customer_id = 'c_1'
    COLUMNS (i.item_id AS item_id)) gt
)
SELECT i.item_name, i.price               -- RELATIONAL: canonical truth
FROM   ring r
  JOIN item i ON i.item_id = r.item_id
WHERE  i.active
ORDER  BY VECTOR_DISTANCE(i.desc_vec,     -- VECTOR: ranked by meaning
         VECTOR_EMBEDDING(menu_model USING 'vegan-friendly noodles' AS data),
         COSINE)
FETCH FIRST 5 ROWS ONLY;

-- One optimizer, one tree: find the graph edge scans, the ITEM access,
-- and the vector top-k STOPKEY in a single plan.
EXPLAIN PLAN FOR
WITH ring AS (
  SELECT DISTINCT gt.item_id
  FROM GRAPH_TABLE (order_graph
    MATCH (c IS customer)-[IS placed]->(o IS ord)-[IS contains]->(i IS item)
    WHERE c.customer_id = 'c_1'
    COLUMNS (i.item_id AS item_id)) gt
)
SELECT i.item_name, i.price
FROM   ring r JOIN item i ON i.item_id = r.item_id
WHERE  i.active
ORDER  BY VECTOR_DISTANCE(i.desc_vec,
         VECTOR_EMBEDDING(menu_model USING 'vegan-friendly noodles' AS data),
         COSINE)
FETCH FIRST 5 ROWS ONLY;

SELECT * FROM dbms_xplan.display();
