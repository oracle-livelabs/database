# Review predictive risk and revenue analytics

## Introduction

The Predictive Risk & Revenue Analytics page summarizes forecast, segment, cluster, and capacity signals. You will map ML routes to SQL and note where fallback logic protects the demo.

### Objectives

- Map predictive analytics routes.
- Query demand and revenue forecast structures.
- Inspect vector cluster evidence.
- Separate source-backed analytics from optional model availability.

Estimated Time: 11 minutes

## Task 1: Map analytics routes

1. Review the ML route group in `api-map.md`.

    | Route | Purpose |
    | --- | --- |
    | `/api/ml/summary` | Returns overall analytics summary |
    | `/api/ml/demand-forecast` | Returns forecast rows |
    | `/api/ml/customer-segments` | Returns segment results |
    | `/api/ml/revenue-forecast` | Returns revenue forecast data |
    | `/api/ml/vector-clusters` | Returns vector cluster output |
    | `/api/ml/inventory-intelligence` | Returns capacity intelligence |

## Task 2: Query forecast data

1. Inspect forecast rows.

    ```sql
    SELECT product_id,
           forecast_date,
           predicted_demand,
           confidence_lower,
           confidence_upper
    FROM demand_forecasts
    ORDER BY forecast_date, product_id
    FETCH FIRST 10 ROWS ONLY;
    ```

## Task 3: Inspect vector cluster inputs

1. Count embedding tables.

    ```sql
    SELECT 'PRODUCT_EMBEDDINGS' AS object_name, COUNT(*) AS row_count FROM product_embeddings
    UNION ALL SELECT 'SIGNAL_EMBEDDINGS', COUNT(*) FROM signal_embeddings;
    ```

## Task 4: Check your work

1. Confirm that ML endpoints may use SQL fallback if persisted models are absent.

2. Confirm that vector cluster claims require embedding rows.

## Acknowledgements

* **Author** - Oracle LiveLabs
* **Last Updated By/Date** - Oracle LiveLabs, May 2026
