CREATE OR REPLACE JSON RELATIONAL DUALITY VIEW production_orders_dv AS
    SELECT JSON {
        '_id'         : r.production_order_id,
        'customerSiteId'  : r.customer_site_id,
        'plantId' : r.plant_id,
        'scheduledStart'     : r.scheduled_start,
        'dueDate'    : r.due_date,
        'status'      : r.order_status,
        'total'       : r.order_total,
        'setupCost': r.setup_cost,
        'priorityScore' : r.priority_score,
        'createdAt'   : r.created_at,
        'items' : [
            SELECT JSON {
                'orderLineId'    : rn.order_line_id,
                'componentId' : rn.component_id,
                'quantity'  : rn.quantity,
                'unitCost' : rn.unit_cost
            }
            FROM production_order_lines rn WITH UPDATE
            WHERE rn.production_order_id = r.production_order_id
        ]
    }
    FROM production_orders r WITH UPDATE;

CREATE PROPERTY GRAPH production_quality_network
  VERTEX TABLES (
    trace_entities KEY (entity_id)
      LABEL entity
      PROPERTIES (
        entity_id,
        entity_key,
        display_name,
        entity_type,
        risk_score,
        risk_level,
        source_system,
        material_value,
        event_count,
        is_confirmed_defect
      ),
    quality_cases KEY (case_id)
      LABEL quality_case
      PROPERTIES (
        case_id,
        case_ref,
        case_type,
        status,
        risk_score,
        loss_amount,
        event_count
      )
  )
  EDGE TABLES (
    trace_relationships KEY (relationship_id)
      SOURCE KEY (from_entity)
        REFERENCES trace_entities (entity_id)
      DESTINATION KEY (to_entity)
        REFERENCES trace_entities (entity_id)
      LABEL related_to
      PROPERTIES (
        relationship_type,
        strength,
        event_count,
        material_value
      ),
    quality_case_entities KEY (case_entity_id)
      SOURCE KEY (case_id)
        REFERENCES quality_cases (case_id)
      DESTINATION KEY (entity_id)
        REFERENCES trace_entities (entity_id)
      LABEL contains_entity
      PROPERTIES (
        role,
        evidence_score
      )
  );

PROMPT Creating HighTech reporting and quality-training views
CREATE OR REPLACE VIEW components_v AS
SELECT component_id, component_name, plant_id, category AS component_category
FROM components;

CREATE OR REPLACE VIEW plants_v AS
SELECT plant_id, plant_name, city, state_province
FROM plants;

CREATE OR REPLACE VIEW quality_alerts_v AS
SELECT observation_id AS alert_id, severity_score, affected_orders, corrective_actions_opened
FROM quality_observations;

/* September 2026 snapshot [September 1, October 1).
   Quality observations and production lines are aggregated separately to avoid fan-out.
   MATERIAL_VALUE includes released, in_production and completed orders; excludes setup.
   Downtime is measured in minutes: major >=80; minor >=60 and <80.
   REVIEW is a synthetic label: mean defect rate >=3 percent AND at least two
   stoppages of 60 minutes or more. Otherwise STABLE. The same-window label
   demonstrates classification, not future predictive accuracy or a holdout test.
*/
CREATE OR REPLACE VIEW oml_quality_training_v AS
WITH quality_metrics AS (
  SELECT pom.component_id,
         COUNT(*) AS total_observations,
         AVG(gp.defect_rate_pct) AS avg_defect_rate_pct,
         SUM(gp.inspected_units) AS total_inspected_units,
         SUM(gp.rejected_units) AS total_rejected_units,
         SUM(gp.rework_minutes) AS total_rework_minutes,
         AVG(gp.downtime_minutes) AS avg_downtime_minutes,
         SUM(CASE WHEN gp.downtime_minutes >= 80 THEN 1 ELSE 0 END) AS major_stoppages,
         SUM(CASE WHEN gp.downtime_minutes >= 60 AND gp.downtime_minutes < 80 THEN 1 ELSE 0 END) AS minor_stoppages
  FROM observation_components pom
  JOIN quality_observations gp ON gp.observation_id = pom.observation_id
  WHERE gp.observed_at >= TIMESTAMP '2026-09-01 00:00:00'
    AND gp.observed_at < TIMESTAMP '2026-10-01 00:00:00'
  GROUP BY pom.component_id
), production_metrics AS (
  SELECT rn.component_id,
         SUM(rn.quantity) AS planned_units,
         SUM(rn.line_total) AS material_value
  FROM production_order_lines rn
  JOIN production_orders r ON r.production_order_id = rn.production_order_id
  WHERE r.order_status IN ('released', 'in_production', 'completed')
    AND r.scheduled_start >= DATE '2026-09-01'
    AND r.scheduled_start < DATE '2026-10-01'
  GROUP BY rn.component_id
)
SELECT so.component_id, so.category, so.unit_cost,
       NVL(pm.total_observations, 0) AS total_observations,
       NVL(pm.avg_defect_rate_pct, 0) AS avg_defect_rate_pct,
       NVL(pm.total_inspected_units, 0) AS total_inspected_units,
       NVL(pm.total_rejected_units, 0) AS total_rejected_units,
       NVL(pm.total_rework_minutes, 0) AS total_rework_minutes,
       NVL(pm.avg_downtime_minutes, 0) AS avg_downtime_minutes,
       NVL(pm.major_stoppages, 0) AS major_stoppages,
       NVL(pm.minor_stoppages, 0) AS minor_stoppages,
       NVL(bm.planned_units, 0) AS planned_units,
       NVL(bm.material_value, 0) AS material_value,
       CAST(CASE WHEN NVL(pm.avg_defect_rate_pct, 0) >= 3
                      AND NVL(pm.major_stoppages, 0) + NVL(pm.minor_stoppages, 0) >= 2
                 THEN 'REVIEW' ELSE 'STABLE' END AS VARCHAR2(10)) AS review_label
FROM components so
LEFT JOIN quality_metrics pm ON pm.component_id = so.component_id
LEFT JOIN production_metrics bm ON bm.component_id = so.component_id
WHERE so.is_active = 1;

PROMPT Embedding SEER HIGHTECH components with the shared 384-dimension model
-- Same model and text recipe as Lab 3; the learner adds the separate column.
INSERT INTO component_embeddings (component_id, embedding)
SELECT component_id,
       VECTOR_EMBEDDING(ADMIN.ALL_MINILM_L12_V2 USING
         component_name || '. Category: ' || category || '. Subcategory: ' || subcategory AS DATA)
FROM components;
COMMIT;

PROMPT Registering plant, customer site and electronics-region spatial layers
INSERT INTO user_sdo_geom_metadata (table_name, column_name, diminfo, srid)
VALUES ('PLANTS', 'LOCATION',
  MDSYS.SDO_DIM_ARRAY(MDSYS.SDO_DIM_ELEMENT('Longitude', -180, 180, 0.005),
                      MDSYS.SDO_DIM_ELEMENT('Latitude', -90, 90, 0.005)), 8307);
INSERT INTO user_sdo_geom_metadata (table_name, column_name, diminfo, srid)
VALUES ('CUSTOMER_SITES', 'LOCATION',
  MDSYS.SDO_DIM_ARRAY(MDSYS.SDO_DIM_ELEMENT('Longitude', -180, 180, 0.005),
                      MDSYS.SDO_DIM_ELEMENT('Latitude', -90, 90, 0.005)), 8307);
INSERT INTO user_sdo_geom_metadata (table_name, column_name, diminfo, srid)
VALUES ('DEMAND_REGIONS', 'BOUNDARY',
  MDSYS.SDO_DIM_ARRAY(MDSYS.SDO_DIM_ELEMENT('Longitude', -180, 180, 0.005),
                      MDSYS.SDO_DIM_ELEMENT('Latitude', -90, 90, 0.005)), 8307);
COMMIT;
CREATE INDEX plants_location_sidx ON plants(location)
  INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2;
CREATE INDEX customer_sites_location_sidx ON customer_sites(location)
  INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2;
CREATE INDEX demand_regions_boundary_sidx ON demand_regions(boundary)
  INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2;



