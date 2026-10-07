PROMPT Configuring the existing GENAI profile for HighTech
-- Preserve provider, credential, compartment and region from setup.
BEGIN
  DBMS_CLOUD_AI.SET_ATTRIBUTE(
    profile_name => 'GENAI',
    attribute_name => 'object_list',
    attribute_value => '[{"owner":"LLUSER","name":"COMPONENTS"},
                         {"owner":"LLUSER","name":"PRODUCTION_ORDERS"},
                         {"owner":"LLUSER","name":"PRODUCTION_ORDER_LINES"},
                         {"owner":"LLUSER","name":"CUSTOMER_SITES"}]');
  DBMS_CLOUD_AI.SET_PROFILE('GENAI');
END;
/

PROMPT Checking HighTech data and lab prerequisites
DECLARE
  l_count NUMBER;
  PROCEDURE require_zero(p_count NUMBER, p_message VARCHAR2) IS
  BEGIN
    IF p_count <> 0 THEN RAISE_APPLICATION_ERROR(-20010, p_message); END IF;
  END;
BEGIN
  SELECT COUNT(*) INTO l_count FROM production_orders o
  LEFT JOIN (SELECT production_order_id, SUM(line_total) AS material_total
             FROM production_order_lines GROUP BY production_order_id) l
    ON l.production_order_id = o.production_order_id
  WHERE l.production_order_id IS NULL OR l.material_total + o.setup_cost <> o.order_total;
  require_zero(l_count, 'Production order material and setup totals disagree.');
  SELECT COUNT(*) INTO l_count FROM production_order_lines l
  JOIN production_orders o ON o.production_order_id = l.production_order_id
  JOIN components c ON c.component_id = l.component_id WHERE c.plant_id <> o.plant_id;
  require_zero(l_count, 'A component is assigned to a different plant from its order.');
  SELECT COUNT(*) INTO l_count FROM quality_observations
  WHERE ABS(defect_rate_pct - rejected_units / inspected_units * 100) > 0.00001;
  require_zero(l_count, 'Defect percentages do not match inspection counts.');
  SELECT COUNT(*) INTO l_count FROM production_orders WHERE production_order_id = 900001;
  require_zero(l_count, 'Lab 2 order ID 900001 must remain unused.');
  SELECT COUNT(*) INTO l_count FROM production_order_lines WHERE order_line_id = 990001;
  require_zero(l_count, 'Lab 2 line ID 990001 must remain unused.');
  SELECT COUNT(*) INTO l_count FROM components WHERE component_id=1 AND plant_id=1 AND unit_cost=125;
  require_zero(l_count-1, 'Lab 2 requires component 1 at plant 1 with unit cost 125.');
  SELECT COUNT(*) INTO l_count FROM customer_sites WHERE customer_site_id=1;
  require_zero(l_count-1, 'Lab 2 customer site 1 is required.');
  SELECT COUNT(*) INTO l_count FROM component_embeddings;
  require_zero(l_count-192, 'Expected 192 preloaded component embeddings.');
  SELECT COUNT(*) INTO l_count FROM component_embeddings WHERE VECTOR_DIMENSION_COUNT(embedding) <> 384;
  require_zero(l_count, 'Component embeddings require 384 dimensions.');
  SELECT COUNT(*) INTO l_count FROM user_tab_columns
  WHERE table_name='COMPONENTS' AND column_name='COMPONENT_EMBEDDING';
  require_zero(l_count, 'Leave the teaching vector column for Lab 3.');
  SELECT COUNT(*) INTO l_count FROM oml_quality_training_v;
  require_zero(l_count-192, 'Expected one training row per active component.');
  SELECT COUNT(*) INTO l_count FROM oml_quality_training_v WHERE review_label='REVIEW';
  require_zero(l_count-96, 'Expected 96 synthetic REVIEW rows.');
  SELECT COUNT(*) INTO l_count FROM oml_quality_training_v WHERE review_label='STABLE';
  require_zero(l_count-96, 'Expected 96 synthetic STABLE rows.');
  SELECT COUNT(*) INTO l_count FROM (
    SELECT SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(location,0.005) AS valid FROM plants
    UNION ALL SELECT SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(location,0.005) FROM customer_sites
    UNION ALL SELECT SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(boundary,0.005) FROM demand_regions
  ) WHERE valid <> 'TRUE' OR valid IS NULL;
  require_zero(l_count, 'Invalid HighTech geometry.');
  SELECT COUNT(*) INTO l_count FROM GRAPH_TABLE (
    production_quality_network MATCH (a IS entity)-[e IS related_to]->(b IS entity)
    WHERE a.entity_key='PO-8841' COLUMNS (b.entity_key AS linked_entity)
  );
  IF l_count=0 THEN RAISE_APPLICATION_ERROR(-20011,'Production graph has no outgoing traceability records.'); END IF;
  SELECT COUNT(*) INTO l_count FROM user_objects WHERE status='INVALID' AND object_name IN (
    'COMPONENTS_V','PLANTS_V','QUALITY_ALERTS_V','OML_QUALITY_TRAINING_V','PRODUCTION_ORDERS_DV','PRODUCTION_QUALITY_NETWORK');
  require_zero(l_count, 'Invalid HighTech view or graph.');
  SELECT COUNT(*) INTO l_count FROM production_orders_dv;
  require_zero(l_count-3739, 'Expected one document per production order.');
  DBMS_OUTPUT.PUT_LINE('HighTech data, vector, spatial, duality and graph assertions passed.');
END;
/

