# Rank Nearby Operations Sites for Review

## Introduction

An urgent service request needs operational support, but the closest field-logistics site may already be constrained. Jessica asks Moon Kai, the spatial expert, to put proximity and workload evidence in the same review list.

You inspect stored point locations, then use Oracle Spatial to rank five active sites near the highest-urgency open request. The result gives Jessica a short list to discuss with a dispatcher, not a dispatch instruction.

Estimated Time: **10 minutes**

### Objectives

- Inspect service points and field sites as spatial points.
- Rank active sites by straight-line geodetic distance in kilometers.
- Explain how capacity and operational status qualify a proximity result.

### Hands-on Scenario

| Step | Energy & Utilities focus |
| --- | --- |
| Business problem | An urgent request needs support from a site that may also have capacity constraints. |
| Technical challenge | Jessica needs location and operational evidence in one result. |
| Persona focus | You follow Moon's proximity analysis and explain it to Jessica. |
| What you will see | Five active sites ranked near one urgent service point. |
| Database capability | `SDO_GEOM.SDO_DISTANCE` calculates point-to-point distance from stored geometries. |
| Outcome | A dispatcher receives candidates to investigate, with distance and capacity context. |

<details>
<summary><strong>Key terms: point geometry and geodetic proximity</strong></summary>

> - A **point geometry** stores a location. The workshop's service-point and site geometries use World Geodetic System 1984 (WGS84), identified by spatial reference identifier (SRID) `4326`.
> - **Geodetic proximity** measures separation using the geographic coordinate system. Here it is straight-line proximity, not road routing or travel time.
> - **Field-logistics capacity** describes the supply or support available for an operational response. It is not a measurement of electrical generation capacity.

</details>

> **SQL Worksheet reminder:** Return to [Getting Started Task 2](?lab=getting-started#Task2:OpenSQLWorksheet) if you need the launch and execution steps.

## Task 1: Inspect stored locations

Before calculating distance, Moon checks that both ends of the comparison have locations. These inventory queries display longitude and latitude for the first five rows with non-null geometry. They are samples, not totals.

1. Run the service-point inventory. A service point is the location associated with a customer's request.

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

2. Run the field-site inventory as a separate statement. These sites are the potential sources of operational support.

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

    **Checkpoint:** Both statements should return five rows. Read longitude and latitude as coordinates, not distance values. Task 2 uses the stored `LOCATION` geometries to calculate distance.

## Task 2: Find the closest active sites

Jessica wants one reproducible starting case. The `urgent_request` clause selects the highest-urgency request with status `pending`, `confirmed`, or `processing`; request ID breaks a tie. The main query compares its service point with every active site that has a location.

1. Run the proximity candidate query.

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

    The cross join plus `SDO_GEOM.SDO_DISTANCE` compares every eligible site in this small, fixed dataset. It performs an exact distance comparison rather than an indexed `SDO_NN` nearest-neighbor search. Spatial indexes are part of the prepared environment, but this query does not demonstrate their use for nearest-neighbor retrieval. A larger application can use an indexed nearest-neighbor pattern and then apply operational eligibility rules.

    This is straight-line geodetic proximity, not road routing or travel time. The query rounds kilometers to one decimal place before sorting on `DISTANCE_KM`; site ID breaks ties at that displayed precision.

    **Expected output pattern**

    | Column | Stable check |
    | --- | --- |
    | `DISTANCE_KM` | Nonnegative and sorted from nearest to farthest. |
    | `OPERATIONAL_STATUS` | Gives capacity or workload context. |
    | `RECOMMENDED_ACTION` | Explains the constraint that Moon should review. |

    For the prepared dataset, request `51964` is the starting case. Phoenix Meter Operations Hub appears first at about `28.3` km. All five returned sites are `Constrained`, so proximity alone does not identify an unconstrained response location.

    ![LLUSER geodetic distance query excerpt and five proximity-ranked active sites](images/nearby-active-sites.png " ")

    *The query excerpt shows `SDO_GEOM.SDO_DISTANCE` in kilometers. The result crop includes all five sites and distances; the recommended-action column is to its right in the worksheet. These are straight-line geodetic distances, not travel times.*

## Task 3: Explain the proximity evidence

1. Review the five candidate sites and state which one you would investigate first.

    > **Checkpoint:** Distance is one input, not an automatic dispatch command. A dispatcher also considers safety, crew skills, parts, service territory, workload, and current site constraints.

> **🎯 Interactive challenge:** Does the five-row result establish that any candidate is unconstrained? Recommend the first site to investigate and name one additional fact a dispatcher would need before assigning work.

<details>
<summary><strong>Challenge answer</strong></summary>

No. All five sites are `Constrained` in the prepared dataset; do not invent a no-alert candidate. Phoenix is the nearest site to investigate, but the dispatcher still needs evidence such as crew availability, appropriate skills, required parts, or service-territory eligibility. The query has not tested those conditions.

</details>

## Conclusion: Add location evidence to a service decision

Moon gave Jessica a proximity-ranked table with workload and capacity context. You calculated distance in SQL; you did not build a map, a road route, or an automatic dispatch system.

## Next Steps

Location narrows the review, but demand can create another constraint. Otto next evaluates a prepared demand model and combines its predictions with current capacity evidence.

## Acknowledgements

* **Author** - Oracle Database Product Management
* **Last Updated By/Date** - Oracle Database Product Management, September 2026
