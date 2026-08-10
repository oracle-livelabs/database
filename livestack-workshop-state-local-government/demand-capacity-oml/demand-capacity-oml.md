# Demand and Capacity Analytics with Oracle Machine Learning

## Introduction

Jessica has reviewed current requests, resident signals, partner paths, and geographic capacity. She now needs predictive evidence that helps identify which public services may face rising demand.

You are the analytics engineer supporting Jessica. You will inventory the four State and Local Government Oracle Machine Learning (OML) models, score the service-demand classification model, and compare predicted labels with the deterministic training labels.

<details>
<summary><strong>Key terms: model, feature, classification, regression, clustering, and confidence</strong></summary>

> - A **model** is a trained pattern that scores new or current data.
>
> - A **feature** is an input value, such as service demand, signal urgency, request volume, or capacity.
>
> - **Classification** predicts a category such as `SURGE` or `STABLE`.
>
> - **Regression** predicts a number, such as service value or future workload.
>
> - **Clustering** groups similar services or residents without a predefined label.
>
> - **Confidence** is the model probability associated with a prediction. It helps rank results, but it is not certainty.

</details>

The diagram follows governed service data into OML models and then back to a planning decision.

![Public-service OML scoring flow](images/demand-capacity-oml-flow.svg " ")

The SQL exposes deployed models and scores directly. The compact deterministic workshop dataset uses 10 services; the full LiveStack application uses a separate, larger demonstration dataset.

### Objectives

- Inventory the four active SLED OML models.
- Score service-demand classifications in SQL.
- Run a simple agreement check between known and predicted labels.

Estimated Time: **12 minutes**

### Business Scenario

| Step | State and local government focus |
| --- | --- |
| Business Problem | Jessica needs to know where future demand may pressure service capacity. |
| Technical Challenge | Predictions must remain connected to governed service rows and reviewable SQL. |
| Persona Focus | An analytics engineer supports statewide planning. |
| What You Will Do | Inspect model metadata, score service demand, and compare labels. |
| Database Capability | OML stores and scores models inside Oracle Database. |
| Outcome | Jessica receives predictive evidence without exporting sensitive operating data. |

**Persona focus:** You connect OML model output to the service names and demand evidence that Jessica recognizes.

## Task 1: Inventory the active OML models

Confirm which models are available before using their scores.

1. Run the model inventory query.

    > **SQL Worksheet reminder:** Need a reminder on how to open and use SQL Worksheet? Return to [Getting Started Task 2: Open SQL Worksheet](/workshops/sandbox/index.html?lab=getting-started#Task2:OpenSQLWorksheet).

    `USER_MINING_MODELS` lists OML models owned by `LLUSER`. The model names identify the public-service decision, while `MINING_FUNCTION` and `ALGORITHM` explain what kind of result the model produces.

    <details>
    <summary><strong>Why this matters: model evidence remains in the database</strong></summary>

    > Exporting service records to another machine learning platform creates more data movement and another governance boundary. OML keeps the model, input rows, SQL score, and business context close together.

    </details>

    ```sql
    <copy>
    SELECT model_name,
           mining_function,
           algorithm
    FROM user_mining_models
    WHERE model_name IN (
      'SLED_SERVICE_DEMAND_MODEL',
      'SLED_RESIDENT_NEED_SEGMENT_MODEL',
      'SLED_SERVICE_VALUE_MODEL',
      'SLED_CASE_SIGNAL_CLUSTER_MODEL'
    )
    ORDER BY model_name;
    </copy>
    ```

    **Expected output: Active SLED OML Models**

    | Model Name | Mining Function | Algorithm |
    | --- | --- | --- |
    | SLED\_CASE\_SIGNAL\_CLUSTER\_MODEL | CLUSTERING | KMEANS |
    | SLED\_RESIDENT\_NEED\_SEGMENT\_MODEL | CLUSTERING | KMEANS |
    | SLED\_SERVICE\_DEMAND\_MODEL | CLASSIFICATION | RANDOM\_FOREST |
    | SLED\_SERVICE\_VALUE\_MODEL | REGRESSION | GENERALIZED\_LINEAR\_MODEL |

2. Connect each model to a planning job.

    The classification model predicts service-demand state. The regression model estimates service value. The clustering models group residents and service signals into similar operating patterns. This lab scores the classification model because it connects directly to the capacity question from Jessica.

## Task 2: Score public-service demand

Score each service as `SURGE` or `STABLE`.

1. Run the classification query.

    `OML_DEMAND_TRAINING_V` is a saved query that packages consistent model features for each service. `PREDICTION` returns the predicted label, and `PREDICTION_PROBABILITY` returns confidence. The outer query joins `SLED_PUBLIC_SERVICES_V` so the result shows business names rather than only IDs.

    ```sql
    <copy>
    SELECT scores.service_id,
           services.service_name,
           scores.known_label,
           scores.predicted_label,
           scores.confidence
    FROM (
      SELECT product_id AS service_id,
             surge_flag AS known_label,
             PREDICTION(
               SLED_SERVICE_DEMAND_MODEL USING *
             ) AS predicted_label,
             ROUND(PREDICTION_PROBABILITY(
               SLED_SERVICE_DEMAND_MODEL USING *
             ), 4) AS confidence
      FROM oml_demand_training_v
    ) scores
    JOIN sled_public_services_v services
      ON services.service_id = scores.service_id
    ORDER BY scores.service_id;
    </copy>
    ```

    **Expected output: Service Demand Scores**

    **Format-only example:** Known labels come from deterministic sample data. Predicted labels and confidence depend on the model build and need target ADB validation before publication. The table below shows the intended result shape.

    | Service Id | Service Name | Known Label | Predicted Label | Confidence |
    | --- | --- | --- | --- | --- |
    | 1 | Medicaid Eligibility Review | SURGE | Target-dependent label | Target-dependent probability |
    | 2 | SNAP Application Support | STABLE | Target-dependent label | Target-dependent probability |
    | 3 | Benefits Appointment Scheduling | SURGE | Target-dependent label | Target-dependent probability |
    | 4 | Building Permit Inspection | STABLE | Target-dependent label | Target-dependent probability |
    | 5 | Road Repair Request | STABLE | Target-dependent label | Target-dependent probability |

2. Interpret label and confidence together.

    A `SURGE` label helps Jessica prioritize services for capacity review. Confidence ranks model support for that label. It does not authorize an intervention or establish that service capacity caused the eligibility warning.

    The model output supports planning only when Jessica combines it with the capacity, geography, and request evidence from earlier labs.

## Task 3: Check model agreement

Count how often predicted labels match the known deterministic labels.

1. Run the agreement query.

    The inner query scores each row. The outer query groups known and predicted combinations. Matching labels provide a quick learning check; mismatches show where a planner should inspect more context. This is not a full production model evaluation.

    ```sql
    <copy>
    SELECT known_label,
           predicted_label,
           COUNT(*) AS service_count
    FROM (
      SELECT surge_flag AS known_label,
             PREDICTION(
               SLED_SERVICE_DEMAND_MODEL USING *
             ) AS predicted_label
      FROM oml_demand_training_v
    )
    GROUP BY known_label, predicted_label
    ORDER BY known_label, predicted_label;
    </copy>
    ```

    **Expected output: Demand Model Agreement**

    **Format-only example:** The query returns every known and predicted label combination observed on the target system. Capture the actual groups and counts during ADB validation.

    | Known Label | Predicted Label | Service Count |
    | --- | --- | --- |
    | STABLE | STABLE or SURGE | Target-dependent count |
    | SURGE | STABLE or SURGE | Target-dependent count |

2. Use the check responsibly.

    Agreement on the sample rows confirms that the SQL scoring path is working. A production review would also test holdout data, error rates, fairness, drift, and whether the features remain appropriate for the public-service decision.

## Acknowledgements

* **Author** - Oracle LiveLabs Team
* **Last Updated By/Date** - Oracle LiveLabs Team, August 2026
