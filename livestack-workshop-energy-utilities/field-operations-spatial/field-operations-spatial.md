# Rank Nearby Operations Sites for Review

## Introduction

Moon Kai is the spatial expert. When an urgent service request arrives, proximity matters—but the nearest site must also be active and its capacity status must be visible. Oracle Spatial lets Moon calculate distance where service-point and logistics data already live.

Estimated Time: **10 minutes**

### Objectives

- Inspect service points and field sites as spatial points.
- Calculate distances in kilometers.
- Combine proximity with capacity and operational status.

### Hands-on Scenario

Moon finds the nearest active candidate sites for the most urgent open request, then gives the dispatcher context for a human routing decision. The calculation ranks WGS84 point-to-point proximity; it does not calculate road travel, service-territory eligibility, or dispatch feasibility.

> **SQL Worksheet reminder:** Return to [Getting Started Task 2](?lab=getting-started#Task2:OpenSQLWorksheet) if you need the launch and execution steps.

## Task 1: Inspect stored locations

1. Run the service-point inventory.

    <copy>
    ```sql
    SELECT 'SERVICE_POINT' AS location_type,
           service_point_name AS location_name,
           city,
           state_province,
           longitude,
           latitude
    FROM eu_service_points_v
    WHERE location IS NOT NULL
    ORDER BY service_point_id
    FETCH FIRST 5 ROWS ONLY;
    ```
    </copy>

2. Run the field-site inventory as a separate statement.

    <copy>
    ```sql
    SELECT 'FIELD_SITE' AS location_type,
           field_logistics_site_name AS location_name,
           city,
           state_province,
           longitude,
           latitude
    FROM eu_field_logistics_sites_v
    WHERE location IS NOT NULL
    ORDER BY field_logistics_site_id
    FETCH FIRST 5 ROWS ONLY;
    ```
    </copy>

## Task 2: Find the closest active sites

1. Run the route candidate query.

    <copy>
    ```sql
    WITH urgent_request AS (
      SELECT service_request_id,
             requesting_service_point_id,
             requesting_service_point_name,
             urgency_score
      FROM eu_utility_service_requests
      WHERE request_status IN ('pending', 'confirmed', 'processing')
      ORDER BY urgency_score DESC NULLS LAST, service_request_id
      FETCH FIRST 1 ROW ONLY
    )
    SELECT u.service_request_id,
           u.requesting_service_point_name,
           s.field_logistics_site_name,
           s.operational_status,
           s.capacity_supply_units,
           s.pending_request_count,
           ROUND(SDO_GEOM.SDO_DISTANCE(
             p.location, s.location, 0.005, 'unit=KM'
           ), 1) AS distance_km,
           s.recommended_action
    FROM urgent_request u
    JOIN eu_service_points_v p
      ON p.service_point_id = u.requesting_service_point_id
    CROSS JOIN eu_field_logistics_sites_v s
    WHERE p.location IS NOT NULL
      AND s.location IS NOT NULL
      AND s.is_active = 1
    ORDER BY distance_km, s.field_logistics_site_id
    FETCH FIRST 5 ROWS ONLY;
    ```
    </copy>

2. Identify the nearest candidate site, then review its `OPERATIONAL_STATUS`, available capacity, pending work, and recommended action before considering a dispatch decision.

    The cross join plus `SDO_GEOM.SDO_DISTANCE` keeps the calculation transparent for this small workshop dataset. It performs a straight-line geodetic proximity ranking—not road routing or travel-time calculation—and does not use the spatial index for nearest-neighbor retrieval. At production scale, use an indexed nearest-neighbor pattern such as `SDO_NN`, then apply operational eligibility rules.

    **Expected output pattern**

    | Column | Stable check |
    | --- | --- |
    | `DISTANCE_KM` | Nonnegative and sorted from nearest to farthest. |
    | `OPERATIONAL_STATUS` | Gives capacity or workload context. |
    | `RECOMMENDED_ACTION` | Explains the constraint that Moon should review. |

## Task 3: Explain the proximity evidence

1. Review the five candidate sites and state which one you would investigate first.

    > **Checkpoint:** Distance is one input, not an automatic dispatch command. A dispatcher also considers safety, crew skills, parts, service territory, workload, and current site constraints.

> **🎯 Interactive challenge:** Compare the nearest site with the first site that has no capacity alert. State which one you would send to a dispatcher for review and cite the supporting evidence.

<details>
<summary><strong>Challenge answer</strong></summary>

Use distance, operational status, available capacity, and pending work together. The nearest site is not automatically best when it cannot safely accept more work.

</details>

## Conclusion: Add location evidence to a service decision

Moon combined spatial distance with operational columns in one query. The map can visualize the result, while SQL preserves the calculation and supporting evidence.

## Next Steps

Otto combines an in-database prediction with current capacity evidence.

## Acknowledgements

* **Author** - Oracle Database Product Management
* **Last Updated By/Date** - Oracle Database Product Management, September 2026
