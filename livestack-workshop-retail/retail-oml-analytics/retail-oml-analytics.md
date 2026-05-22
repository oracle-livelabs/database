# Retail OML Analytics

## Introduction

A merchandising analytics manager, demand planner, loyalty analyst, inventory planner, or retail data science lead needs to understand which predictive signals should drive action. Predictive work loses trust when features, scoring jobs, notebooks, CSV exports, BI extracts, and operational systems drift apart.

Oracle Machine Learning keeps models close to governed retail data. Models can be trained, persisted, and scored in the database with `DBMS_DATA_MINING`, `PREDICTION`, `PREDICTION_PROBABILITY`, and `CLUSTER_ID`. In SQL Worksheet, you inspect the feature views and model scoring patterns behind the Retail OML Analytics scene.

Estimated Time: 10 minutes

### Objectives

- Verify OML feature views and mining models.
- Inspect demand, customer, revenue, and product-cluster features.
- Run deterministic model scoring when models are available.
- Connect OML outputs to inventory and merchandising action.


## Task 1: Verify OML training views and models
1. Review the related application screen before you run the SQL.

    ![Retail OML Analytics overview](images/retail-oml-analytics-overview.png " ")

    *Figure 1: Retail OML Analytics summarizes in-database predictive signals and active models.*

2. Run this view check.

    ```sql
    <copy>
    SELECT owner AS "Owner", view_name AS "View"
    FROM all_views
    WHERE owner = 'RETAILDB'
      AND view_name IN (
        'OML_DEMAND_TRAINING_V','OML_CUSTOMER_RFM_V',
        'OML_REVENUE_TRAINING_V','OML_PRODUCT_CLUSTER_V'
      )
    ORDER BY view_name;
    </copy>
    ```

    Expected output:

    | Owner | View |
    | --- | --- |
    | RETAILDB | `OML_CUSTOMER_RFM_V` |
    | RETAILDB | `OML_DEMAND_TRAINING_V` |
    | RETAILDB | `OML_PRODUCT_CLUSTER_V` |
    | RETAILDB | `OML_REVENUE_TRAINING_V` |
    {: title="OML Training Views"}

3. Run this model inventory.

    ```sql
    <copy>
    SELECT owner AS "Owner", model_name AS "Model", mining_function AS "Use", algorithm AS "Algorithm"
    FROM all_mining_models
    WHERE owner = 'RETAILDB'
      AND model_name IN (
        'DEMAND_SURGE_MODEL','CUSTOMER_SEGMENT_MODEL',
        'REVENUE_PREDICT_MODEL','PRODUCT_CLUSTER_MODEL'
      )
    ORDER BY model_name;
    </copy>
    ```

    Expected output:

    | Owner | Model | Use | Algorithm |
    | --- | --- | --- | --- |
    | RETAILDB | `CUSTOMER_SEGMENT_MODEL` | CLUSTERING | KMEANS |
    | RETAILDB | `DEMAND_SURGE_MODEL` | CLASSIFICATION | `RANDOM_FOREST` |
    | RETAILDB | `PRODUCT_CLUSTER_MODEL` | CLUSTERING | KMEANS |
    | RETAILDB | `REVENUE_PREDICT_MODEL` | REGRESSION | `GENERALIZED_LINEAR_MODEL` |
    {: title="OML Mining Models"}

## Task 2: Score demand surge risk
1. Use the live Retail OML Analytics context from Figure 1 before you run the SQL.

2. Run this scoring query.

    ```sql
    <copy>
    SELECT product_id AS "Product ID",
           category AS "Category",
           surge_label AS "Actual",
           PREDICTION(RETAILDB.DEMAND_SURGE_MODEL USING *) AS "Predicted",
           ROUND(PREDICTION_PROBABILITY(RETAILDB.DEMAND_SURGE_MODEL, 'SURGE' USING *), 4) AS "Surge Prob"
    FROM RETAILDB.oml_demand_training_v
    ORDER BY product_id
    FETCH FIRST 10 ROWS ONLY;
    </copy>
    ```

    Expected output:

    | Product ID | Category | Actual | Predicted | Surge Prob |
    | ---: | --- | --- | --- | ---: |
    | 1 | Fashion | STABLE | SURGE | 0.536 |
    | 2 | Fashion | SURGE | SURGE | 0.9713 |
    | 3 | Fashion | SURGE | SURGE | 0.998 |
    | 4 | Fashion | SURGE | SURGE | 0.9864 |
    | 5 | Fashion | SURGE | SURGE | 1 |
    | 6 | Electronics | SURGE | SURGE | 0.8053 |
    | 7 | Electronics | SURGE | SURGE | 0.9709 |
    | 8 | Electronics | SURGE | SURGE | 0.9989 |
    | 9 | Electronics | SURGE | SURGE | 0.9608 |
    | 10 | Electronics | SURGE | SURGE | 0.998 |
    {: title="Demand Surge Predictions"}

3. The model score gives the merchandising team a database-grounded way to decide whether to promote, replenish, or watch a product.

## Task 3: Inspect inventory risk from OML features
1. Use the live Retail OML Analytics context from Figure 1 before you run the SQL.

2. Run this query.

    ```sql
    <copy>
    SELECT product_name AS "Product",
           center_name AS "Center",
           quantity_on_hand AS "On Hand",
           reorder_point AS "Reorder At",
           inventory_risk AS "Risk"
    FROM RETAILDB.retail_fulfillment_risk_v r
    ORDER BY r.inventory_risk DESC, r.quantity_on_hand ASC, r.product_name
    FETCH FIRST 10 ROWS ONLY;
    </copy>
    ```

    Expected output:

    | Product | Center | On Hand | Reorder At | Risk |
    | --- | --- | ---: | ---: | --- |
    | Carbon Road Bike | Portland Pacific | 10 | 38 | `AT_RISK` |
    | Heritage Leather Belt | Indianapolis Heartland | 10 | 84 | `AT_RISK` |
    | Lavender Diffuser Set | Anchorage Alaska | 10 | 71 | `AT_RISK` |
    | PhantomCase PC Mid Tower | Minneapolis North Central | 10 | 20 | `AT_RISK` |
    | UltraWide Curved 34 | Portland Pacific | 10 | 34 | `AT_RISK` |
    | 4-Season Tent 3P | Tampa Florida | 11 | 87 | `AT_RISK` |
    | LED Festival Jacket | Nashville Central | 11 | 34 | `AT_RISK` |
    | Midnight Espresso Blend | Houston Gulf Coast | 11 | 83 | `AT_RISK` |
    | Moonbeam Highlighter | Phoenix Desert Hub | 11 | 30 | `AT_RISK` |
    | Retro Wave Tee | Philadelphia Mid-Atlantic | 11 | 49 | `AT_RISK` |
    {: title="Inventory Risk Features"}

3. The application can combine OML scores, demand forecasts, and inventory evidence in the database before presenting a risk recommendation.

## Acknowledgements

* **Author** - Oracle LiveLabs
* **Last Updated By/Date** - Oracle Database Product Management, May 2026
