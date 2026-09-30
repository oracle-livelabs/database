WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
SELECT component_id,
           category,
           unit_cost,
           total_observations,
           avg_defect_rate_pct,
           major_stoppages,
           minor_stoppages,
           planned_units,
           material_value,
           review_label
    FROM oml_quality_training_v
    ORDER BY component_id
    FETCH FIRST 10 ROWS ONLY;

COMMIT;

DROP TABLE IF EXISTS otto_quality_review_settings;
    
    CREATE TABLE otto_quality_review_settings (
          setting_name  VARCHAR2(30),
          setting_value VARCHAR2(4000)
        );

    INSERT INTO otto_quality_review_settings (setting_name, setting_value)
    VALUES ('ALGO_NAME', 'ALGO_GENERALIZED_LINEAR_MODEL');

    INSERT INTO otto_quality_review_settings (setting_name, setting_value)
    VALUES ('PREP_AUTO', 'ON');

    INSERT INTO otto_quality_review_settings (setting_name, setting_value)
    VALUES ('ODMS_RANDOM_SEED', '20260604');

    COMMIT;

    DECLARE
      l_model_count NUMBER;
    BEGIN
      SELECT COUNT(*)
      INTO l_model_count
      FROM user_mining_models
      WHERE model_name = 'OTTO_QUALITY_REVIEW_MODEL';

      IF l_model_count > 0 THEN
        DBMS_DATA_MINING.DROP_MODEL('OTTO_QUALITY_REVIEW_MODEL');
      END IF;
    END;
    /

    BEGIN
      DBMS_DATA_MINING.CREATE_MODEL(
        model_name           => 'OTTO_QUALITY_REVIEW_MODEL',
        mining_function      => DBMS_DATA_MINING.CLASSIFICATION,
        data_table_name      => 'OML_QUALITY_TRAINING_V',
        case_id_column_name  => 'COMPONENT_ID',
        target_column_name   => 'REVIEW_LABEL',
        settings_table_name  => 'OTTO_QUALITY_REVIEW_SETTINGS'
      );
    END;
    /

COMMIT;

SELECT model_name,
           mining_function,
           algorithm
    FROM user_mining_models
    WHERE model_name = 'OTTO_QUALITY_REVIEW_MODEL';

COMMIT;

DROP TABLE IF EXISTS otto_quality_review_scoring_data;

    CREATE TABLE otto_quality_review_scoring_data (
      component_id    NUMBER,
      category      VARCHAR2(100),
      unit_cost    NUMBER,
      total_observations   NUMBER,
      avg_defect_rate_pct NUMBER,
      total_inspected_units   NUMBER,
      total_rejected_units  NUMBER,
      total_rework_minutes   NUMBER,
      avg_downtime_minutes  NUMBER,
      major_stoppages   NUMBER,
      minor_stoppages  NUMBER,
      planned_units    NUMBER,
      material_value       NUMBER
    );

    INSERT INTO otto_quality_review_scoring_data (
      component_id,
      category,
      unit_cost,
      total_observations,
      avg_defect_rate_pct,
      total_inspected_units,
      total_rejected_units,
      total_rework_minutes,
      avg_downtime_minutes,
      major_stoppages,
      minor_stoppages,
      planned_units,
      material_value
    )
    SELECT component_id,
           category,
           unit_cost,
           total_observations + 4,
           ROUND((total_rejected_units + 12) / (total_inspected_units + 200) * 100, 4),
           total_inspected_units + 200,
           total_rejected_units + 12,
           total_rework_minutes + 500,
           avg_downtime_minutes + 15,
           major_stoppages + 1,
           minor_stoppages + 1,
           planned_units + 3,
           material_value + (unit_cost * 3)
    FROM (
      SELECT component_id,
             category,
             unit_cost,
             total_observations,
             avg_defect_rate_pct,
             total_inspected_units,
             total_rejected_units,
             total_rework_minutes,
             avg_downtime_minutes,
             major_stoppages,
             minor_stoppages,
             planned_units,
             material_value,
             ROW_NUMBER() OVER (ORDER BY component_id) AS row_num
      FROM oml_quality_training_v
    )
    WHERE row_num <= 12;

    COMMIT;

COMMIT;

WITH scored_components AS (
      SELECT component_id,
             category,
             planned_units,
             material_value,
             total_observations,
             major_stoppages,
             minor_stoppages,
             PREDICTION(
               OTTO_QUALITY_REVIEW_MODEL USING
               category, unit_cost, total_observations, avg_defect_rate_pct,
               total_inspected_units, total_rejected_units, total_rework_minutes, avg_downtime_minutes,
               major_stoppages, minor_stoppages, planned_units, material_value
             ) AS predicted_review,
             ROUND(
               PREDICTION_PROBABILITY(
                 OTTO_QUALITY_REVIEW_MODEL,
                 'REVIEW' USING
                 category, unit_cost, total_observations, avg_defect_rate_pct,
                 total_inspected_units, total_rejected_units, total_rework_minutes, avg_downtime_minutes,
                 major_stoppages, minor_stoppages, planned_units, material_value
               ), 8
             ) AS review_score
      FROM otto_quality_review_scoring_data
    )
    SELECT so.component_id,
           so.component_name,
           scored_component.category,
           scored_component.predicted_review,
           scored_component.review_score,
           ROUND(scored_component.review_score * 100, 2) AS review_pct,
           scored_component.planned_units,
           scored_component.material_value,
           scored_component.total_observations,
           scored_component.major_stoppages,
           scored_component.minor_stoppages
    FROM scored_components scored_component
    JOIN components so
      ON so.component_id = scored_component.component_id
    ORDER BY scored_component.review_score DESC,
             so.component_id;

COMMIT;
