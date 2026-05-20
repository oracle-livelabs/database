# Investigate financial crime networks and service coverage

## Introduction

Financial investigations often need relationship analysis and location context. You will use graph and spatial SQL to inspect connected risk entities and client service coverage.

### Objectives

- Query a property graph with SQL/PGQ.
- Inspect fraud graph objects.
- Calculate nearest service centers.
- Connect graph and spatial queries to app routes.

Estimated Time: 12 minutes

## Task 1: Map graph and spatial routes

1. Review these route groups in `api-map.md`.

    | Page | Route group | Database feature |
    | --- | --- | --- |
    | Financial Crime Network | `/api/graph/*` | Property Graph and SQL/PGQ |
    | Client Service Coverage | `/api/fulfillment/*` | Oracle Spatial |

## Task 2: Query the graph

1. Run a SQL/PGQ query over the influencer network.

    ```sql
    SELECT source_handle,
           reached_handle,
           connection_type,
           strength
    FROM GRAPH_TABLE (
        influencer_network
        MATCH (src IS influencer)-[e IS connects_to]->(dst IS influencer)
        COLUMNS (
            src.handle AS source_handle,
            dst.handle AS reached_handle,
            e.connection_type AS connection_type,
            e.strength AS strength
        )
    )
    ORDER BY strength DESC
    FETCH FIRST 10 ROWS ONLY;
    ```

## Task 3: Query spatial service coverage

1. Find nearest service centers for one client.

    ```sql
    SELECT fc.center_name,
           fc.city,
           fc.state_province,
           ROUND(SDO_GEOM.SDO_DISTANCE(c.location, fc.location, 0.005, 'unit=MILE'), 2) AS miles_from_client
    FROM customers c
    CROSS JOIN fulfillment_centers fc
    WHERE c.customer_id = 1
      AND fc.is_active = 1
    ORDER BY SDO_GEOM.SDO_DISTANCE(c.location, fc.location, 0.005, 'unit=MILE')
    FETCH FIRST 5 ROWS ONLY;
    ```

## Task 4: Check your work

1. Confirm that graph queries support investigation workflows.

2. Confirm that spatial distance supports service coverage decisions.

## Acknowledgements

* **Author** - Oracle LiveLabs
* **Last Updated By/Date** - Oracle LiveLabs, May 2026
