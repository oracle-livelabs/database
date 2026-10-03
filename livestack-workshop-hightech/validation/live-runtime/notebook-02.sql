SELECT DISTINCT entity_key, display_name, entity_type,
       risk_score, risk_level, material_value, source_system
FROM GRAPH_TABLE ( production_quality_network
  MATCH (seed IS entity) -[e IS related_to]->{1,2} (reached IS entity)
  WHERE seed.entity_key = 'PO-8841'
  COLUMNS (
    reached.entity_key AS entity_key,
    reached.display_name AS display_name,
    reached.entity_type AS entity_type,
    reached.risk_score AS risk_score,
    reached.risk_level AS risk_level,
    reached.material_value AS material_value,
    reached.source_system AS source_system
  )
)
ORDER BY risk_score DESC
FETCH FIRST 25 ROWS ONLY;
