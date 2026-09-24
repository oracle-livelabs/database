-- Healthcare V2 Lab 4 queries
-- Every statement is read-only and uses the objects and data created by the
-- validated healthcare SQL loader.

-- Query 1: Follow the direct relational connections from the patient journey.
SELECT journey.node_id AS journey_id,
       journey.node_label AS journey,
       connected.node_id AS connected_node_id,
       connected.node_label AS connected_node,
       connected.node_type AS connected_type,
       relationship.relationship_type,
       relationship.evidence_score,
       connected.risk_score AS connected_risk
FROM hc_care_nodes journey
JOIN hc_care_edges relationship
  ON relationship.source_node_id = journey.node_id
JOIN hc_care_nodes connected
  ON connected.node_id = relationship.target_node_id
WHERE journey.node_type = 'PATIENT_JOURNEY'
ORDER BY relationship.evidence_score DESC,
         connected.node_id;

-- Query 2: Follow one- and two-hop paths with relational joins.
SELECT journey_id,
       connected_node_id,
       connected_node,
       connected_type,
       relationship_hops,
       relationship_path,
       connected_risk
FROM (
  SELECT journey.node_id AS journey_id,
         connected.node_id AS connected_node_id,
         connected.node_label AS connected_node,
         connected.node_type AS connected_type,
         1 AS relationship_hops,
         first_step.relationship_type AS relationship_path,
         connected.risk_score AS connected_risk
  FROM hc_care_nodes journey
  JOIN hc_care_edges first_step
    ON first_step.source_node_id = journey.node_id
  JOIN hc_care_nodes connected
    ON connected.node_id = first_step.target_node_id
  WHERE journey.node_type = 'PATIENT_JOURNEY'
  UNION ALL
  SELECT journey.node_id,
         connected.node_id,
         connected.node_label,
         connected.node_type,
         2,
         first_step.relationship_type || ' -> ' ||
           second_step.relationship_type,
         connected.risk_score
  FROM hc_care_nodes journey
  JOIN hc_care_edges first_step
    ON first_step.source_node_id = journey.node_id
  JOIN hc_care_nodes intermediate
    ON intermediate.node_id = first_step.target_node_id
  JOIN hc_care_edges second_step
    ON second_step.source_node_id = intermediate.node_id
  JOIN hc_care_nodes connected
    ON connected.node_id = second_step.target_node_id
  WHERE journey.node_type = 'PATIENT_JOURNEY'
)
ORDER BY relationship_hops,
         connected_risk DESC,
         connected_node_id;

-- Query 3: Return the same direct connections with SQL/PGQ.
SELECT journey_id,
       journey,
       connected_node_id,
       connected_node,
       connected_type,
       relationship_type,
       evidence_score,
       connected_risk
FROM GRAPH_TABLE (
  care_pathway_graph
  MATCH (journey IS care_node)
        -[relationship IS care_relationship]->
        (connected IS care_node)
  WHERE journey.node_type = 'PATIENT_JOURNEY'
  COLUMNS (
    journey.node_id AS journey_id,
    journey.node_label AS journey,
    connected.node_id AS connected_node_id,
    connected.node_label AS connected_node,
    connected.node_type AS connected_type,
    relationship.relationship_type AS relationship_type,
    relationship.evidence_score AS evidence_score,
    connected.risk_score AS connected_risk
  )
)
ORDER BY evidence_score DESC,
         connected_node_id;

-- Query 4: Reach connected care facts with one SQL/PGQ pattern.
SELECT DISTINCT journey_id,
       connected_node_id,
       connected_node,
       connected_type,
       connected_risk
FROM GRAPH_TABLE (
  care_pathway_graph
  MATCH (journey IS care_node)
        -[relationship IS care_relationship]->{1,2}
        (connected IS care_node)
  WHERE journey.node_type = 'PATIENT_JOURNEY'
  COLUMNS (
    journey.node_id AS journey_id,
    connected.node_id AS connected_node_id,
    connected.node_label AS connected_node,
    connected.node_type AS connected_type,
    connected.risk_score AS connected_risk
  )
)
ORDER BY connected_risk DESC,
         connected_node_id;

-- Query 5: Trace the two evidence paths that reach the quality signal.
SELECT journey,
       clinical_context,
       context_type,
       quality_signal,
       first_relationship,
       second_relationship,
       first_evidence_score,
       second_evidence_score
FROM GRAPH_TABLE (
  care_pathway_graph
  MATCH (journey IS care_node)
        -[first_step IS care_relationship]->
        (clinical_context IS care_node)
        -[second_step IS care_relationship]->
        (quality_signal IS care_node)
  WHERE journey.node_type = 'PATIENT_JOURNEY'
    AND quality_signal.node_type = 'QUALITY_SIGNAL'
  COLUMNS (
    journey.node_label AS journey,
    clinical_context.node_label AS clinical_context,
    clinical_context.node_type AS context_type,
    quality_signal.node_label AS quality_signal,
    first_step.relationship_type AS first_relationship,
    second_step.relationship_type AS second_relationship,
    first_step.evidence_score AS first_evidence_score,
    second_step.evidence_score AS second_evidence_score
  )
)
ORDER BY clinical_context;

-- Query 6: Visualize the one- and two-hop pathway in Graph Studio.
SELECT *
FROM GRAPH_TABLE (
  LLUSER.care_pathway_graph
  MATCH (journey IS care_node)
        -[relationship IS care_relationship]->{1,2}
        (connected IS care_node)
  WHERE journey.node_type = 'PATIENT_JOURNEY'
  ONE ROW PER STEP (from_node, traversed_edge, to_node)
  COLUMNS (
    VERTEX_ID(journey) AS journey_id,
    VERTEX_ID(from_node) AS from_node_id,
    EDGE_ID(traversed_edge) AS relationship_id,
    VERTEX_ID(to_node) AS connected_node_id
  )
);

-- Query 7: Visualize the two quality-signal evidence paths in Graph Studio.
SELECT *
FROM GRAPH_TABLE (
  LLUSER.care_pathway_graph
  MATCH (journey IS care_node)
        -[first_step IS care_relationship]->
        (clinical_context IS care_node)
        -[second_step IS care_relationship]->
        (quality_signal IS care_node)
  WHERE journey.node_type = 'PATIENT_JOURNEY'
    AND quality_signal.node_type = 'QUALITY_SIGNAL'
  COLUMNS (
    VERTEX_ID(journey) AS journey_id,
    EDGE_ID(first_step) AS first_step_id,
    VERTEX_ID(clinical_context) AS context_id,
    EDGE_ID(second_step) AS second_step_id,
    VERTEX_ID(quality_signal) AS signal_id
  )
);
