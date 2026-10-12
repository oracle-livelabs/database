SELECT *
FROM GRAPH_TABLE (
  production_quality_network
  MATCH (production_order IS entity) -[e IS related_to]- (material_lot IS entity)
  WHERE material_lot.entity_key = 'LOT-SEMI-91A7'
  COLUMNS (
    vertex_id(production_order) AS production_order_id,
    edge_id(e)         AS related_to_id,
    vertex_id(material_lot)  AS material_lot_id
  )
);
