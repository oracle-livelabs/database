SELECT *
FROM GRAPH_TABLE (
  production_quality_network
  MATCH (src IS entity)-[e IS related_to]->{1,2}(dst IS entity)
  WHERE src.entity_key = 'PO-8841'
  ONE ROW PER STEP (v1, e1, v2)
  COLUMNS (
    vertex_id(src) AS seed_id,
    vertex_id(v1) AS v1_id,
    edge_id(e1) AS e1_id,
    vertex_id(v2) AS v2_id
  )
);
