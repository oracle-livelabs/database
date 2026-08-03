# Client Service and SLA Coverage with Oracle Spatial

## Introduction

After risk is identified, Seer Bank needs to know whether case-processing capacity is close enough to respond. This lab uses **Oracle Spatial** to answer a practical operations question: where is demand, where are the service centers, and can the bank meet its service-level agreement (SLA) commitments?

You will help a service operations leader turn location data into coverage evidence for case routing, fraud follow-up, anti-money laundering (AML) review, and SLA planning.

Risk and fraud decisions often create service work: client outreach, case routing, AML or fraud review, product review, dispute follow-up, onboarding checks, and document handling. Spatial analysis helps operations leaders avoid guessing from a map and instead measure whether case-processing capacity is near the demand region that needs support.

Every risk decision can create operational work. The bank needs to know not only what is risky, but whether the service network can respond where demand is highest.

<details>
<summary><strong>Key terms: spatial data, point, boundary, distance, GeoJSON, SLA, and case-processing capacity</strong></summary>

> - **Spatial data** describes location or shape. A service center can be stored as a point, a demand region can be stored as a boundary, and an SLA zone can be stored as an area. Spatial data lets operations teams ask location-aware questions with SQL.
>
> - A **point** is a precise map location, usually represented by longitude and latitude. In this lab, a service center point tells the database where work can be handled.
>
> - A **boundary** is a shape around an area, such as a metro region or service zone. Boundaries let the database compare where demand is located against where case-processing capacity is available.
>
> - **Distance** tells you how far one location is from another location or boundary. In service planning, distance helps answer whether a center is close enough to respond, whether case-processing capacity is practical for a region, and where routing pressure may appear.
>
> - **GeoJSON** is a JSON format for representing map features such as points, lines, and areas. Oracle can convert spatial objects into GeoJSON so the same governed geometry can support both SQL analysis and map-based application screens.
>
> - An **SLA**, or service-level agreement, is a response-time or service-level commitment. In this workshop, SLA coverage connects geography to operations: the question is not only whether a risk exists, but whether the bank has case-processing capacity near the region that needs help.
>
> - **Case-processing capacity** means the operational ability of the bank to handle finance-related work, not inventory or data-center capacity. In this lab, that work can include client outreach, fraud follow-up, AML review, dispute handling, onboarding checks, product review, or document processing. The spatial question is whether enough of that handling capacity is close to the region where demand or risk is building.

</details>

The first image below explains the spatial coverage pattern. Service centers are stored as points, demand regions are stored as boundaries, and Oracle Spatial can calculate distance and coverage so service decisions are based on measurable geography instead of visual guesswork.

![Spatial service coverage flow](images/spatial-service-coverage-flow.svg " ")

The second image is the Client Service and SLA Coverage page. It combines a map, service-center table, regional demand indicators, and case-processing capacity alerts so an operations leader can see where demand is building and whether nearby case-processing capacity is enough to respond. The SQL in this lab queries the same location and SLA data behind that screen.

![Client Service and SLA Coverage map](images/service-sla-spatial.png " ")

### Objectives

- Find service centers nearest to New York Metro.
- Inspect SLA zone coverage.

Estimated Time: **10 minutes**

### Business Scenario

| Step | Finance focus |
| --- | --- |
| Business Problem | Service leaders need to know whether case-processing capacity is close enough to high-demand regions. |
| Technical Challenge | Operations teams need location-aware decisions without moving geography, service centers, and SLA zones into separate mapping systems. |
| Persona Focus | Service operations leaders evaluate coverage; database developers show distance and SLA evidence with spatial SQL. |
| What You Will See | Spatial data can quantify distance and regional service pressure in SQL. |
| Database Capability | Oracle Spatial geometry objects (`SDO_GEOMETRY`), distance calculations (`SDO_GEOM.SDO_DISTANCE`), regions, and SLA zones support coverage analysis. |
| Outcome | Operations teams can prioritize case-processing capacity based on geography and demand. |

## Task 1: Calculate service center distance to New York Metro

Start by comparing service-center locations to the New York Metro demand region.

1. Run this spatial distance query:

    > **SQL Worksheet reminder:** Need a reminder on how to open and use the SQL Worksheet? Return to [Getting Started Task 2: Open SQL Worksheet](?lab=getting-started#Task2:OpenSQLWorksheet) for the step-by-step graphic showing where to paste and run SQL statements.

    You are measuring which service centers are closest to a high-demand region so operations can reason about response coverage.

    In order to understand this query, read it in five parts.

    1. `service_centers_v` gives you business details, such as service center name, city, and state.

    2. `fulfillment_centers` supplies the stored location for each service center. The `location` column is an `SDO_GEOMETRY` point, which is how Oracle Spatial stores a map location.

    3. `demand_regions` supplies the New York Metro boundary. The `WHERE` clause keeps the query focused on that one demand region.

    4. `SDO_GEOM.SDO_DISTANCE(fc.location, dr.boundary, 0.005, 'unit=KM')` measures the distance in kilometers between each service center point and the New York Metro boundary.

    5. `SDO_UTIL.TO_GEOJSON(fc.location)` converts the service center point into GeoJSON so a map or application screen can display the same location.

    The query orders the result by nearest distance first. That lets an operations leader see which service centers are closest to the demand region before deciding where to route case work.

    <details>
    <summary><strong>Why this matters: spatial analysis is stronger inside the database</strong></summary>

    > In a fractured environment, teams might export service-center data to a mapping tool and separately maintain demand or SLA data somewhere else. That can make maps visually useful but hard to govern, audit, or join back to operational data.
    >
    > Oracle Spatial keeps location data, service data, demand regions, and SQL analysis together. You can calculate distance and still join the result to finance and operations data in the same query.

    </details>

    ```sql
    <copy>
    SELECT sc.service_center_name,
           sc.city,
           sc.state_province,
           fc.latitude,
           fc.longitude,
           DBMS_LOB.SUBSTR(SDO_UTIL.TO_GEOJSON(fc.location), 120, 1) AS location_geojson,
           ROUND(SDO_GEOM.SDO_DISTANCE(fc.location, dr.boundary, 0.005, 'unit=KM'), 2) AS boundary_distance_km,
           dr.region_name,
           dr.demand_index
    FROM service_centers_v sc
    JOIN fulfillment_centers fc ON fc.center_id = sc.service_center_id
    CROSS JOIN demand_regions dr
    WHERE dr.region_name = 'New York Metro'
    ORDER BY SDO_GEOM.SDO_DISTANCE(fc.location, dr.boundary, 0.005, 'unit=KM')
    FETCH FIRST 10 ROWS ONLY;
    </copy>
    ```

    **Expected output: New York Service Coverage**

    | Service Center Name | City | State Province | Latitude | Longitude | Location Geojson | Boundary Distance Km | Region Name | Demand Index |
    | --- | --- | --- | --- | --- | --- | --- | --- | --- |
    | Edison Wealth Service Center | Edison | New Jersey | 40.5187 | -74.4121 | { "type": "Point", "coordinates": [-74.4121, 40.5187] } | 9.48 | New York Metro | 91 |
    | Middletown Mid-Atlantic Branch Hub | Middletown | Delaware | 39.4496 | -75.7163 | { "type": "Point", "coordinates": [-75.7163, 39.4496] } | 160.48 | New York Metro | 91 |
    | Aberdeen East Coast Banking Center | Aberdeen | Maryland | 39.5096 | -76.1641 | { "type": "Point", "coordinates": [-76.1641, 39.5096] } | 187.21 | New York Metro | 91 |
    | Fall River Northeast Service Hub | Fall River | Massachusetts | 41.7015 | -71.155 | { "type": "Point", "coordinates": [-71.155, 41.7015] } | 218.48 | New York Metro | 91 |
    | Etna Midwest Specialty Finance Desk | Etna | Ohio | 39.9576 | -82.6818 | { "type": "Point", "coordinates": [-82.6818, 39.9576] } | 713.52 | New York Metro | 91 |
    | Romulus Great Lakes Mortgage Hub | Romulus | Michigan | 42.2223 | -83.3963 | { "type": "Point", "coordinates": [-83.3963, 42.2223] } | 767.96 | New York Metro | 91 |
    | Concord Southeast Micro Branch | Concord | North Carolina | 35.4088 | -80.5795 | { "type": "Point", "coordinates": [-80.5795, 35.4088] } | 781.6 | New York Metro | 91 |
    | Plainfield Heartland Banking Hub | Plainfield | Indiana | 39.7043 | -86.3994 | { "type": "Point", "coordinates": [-86.3994, 39.7043] } | 1031.93 | New York Metro | 91 |
    | Lebanon Central Banking Center | Lebanon | Tennessee | 36.2081 | -86.2911 | { "type": "Point", "coordinates": [-86.2911, 36.2081] } | 1144.17 | New York Metro | 91 |
    | Joliet Midwest Risk Desk | Joliet | Illinois | 41.525 | -88.0817 | { "type": "Point", "coordinates": [-88.0817, 41.525] } | 1152.2 | New York Metro | 91 |


2. Review the nearest service centers.
    Start with the first row. It shows the nearest service center to the New York Metro boundary: Edison Wealth Service Center in Edison, New Jersey.

    Read the result in three parts.

    1. `Boundary Distance Km` shows how far each service center is from the demand-region boundary. A smaller distance means the center is closer to the region that needs support.

    2. `Demand Index` shows how much service pressure exists in that region. New York Metro has demand index `91`, so it is a high-demand area.

    3. `Location Geojson` shows the same service-center point in a map-friendly format. For WGS84 map data, Oracle stores coordinates as longitude first, then latitude. That is why the GeoJSON point for Edison starts with `-74.4121` before `40.5187`.

    The so what: Edison is the closest center to a high-demand region, so it is the first place an operations leader would check for available case-processing capacity. If Edison is already overloaded, the next closest centers help show where work may need to be routed next.

## Task 2: Summarize SLA zone coverage

After locating nearby service centers, summarize the response commitments attached to SLA zones.

1. Run this SLA zone summary:

    You are summarizing the service commitments that operations teams must meet after risk work creates follow-up demand. The source column is named `max_delivery_hrs`, but in this finance lab you use it as the maximum response-hour commitment for each SLA zone.

    In order to understand this query, read it in three parts.

    1. `fulfillment_zones` stores the SLA zones used for service response planning.

    2. `GROUP BY zone_type` groups zones into service levels, such as express, overnight, standard, and economy.

    3. `MIN`, `MAX`, and `AVG` summarize the response-hour commitments for each service level.

    ```sql
    <copy>
    SELECT zone_type,
           COUNT(*) AS zones,
           MIN(max_delivery_hrs) AS min_response_hrs,
           MAX(max_delivery_hrs) AS max_response_hrs,
           ROUND(AVG(max_delivery_hrs), 1) AS avg_response_hrs
    FROM fulfillment_zones
    GROUP BY zone_type
    ORDER BY avg_response_hrs;
    </copy>
    ```

    **Expected output: SLA Zone Counts**

    | Zone Type | Zones | Min Response Hrs | Max Response Hrs | Avg Response Hrs |
    | --- | --- | --- | --- | --- |
    | express | 30 | 8 | 8 | 8 |
    | overnight | 30 | 16 | 16 | 16 |
    | standard | 30 | 24 | 24 | 24 |
    | economy | 30 | 72 | 72 | 72 |


2. Compare the service levels.
    This query summarizes all SLA zones into service promises that operations leaders can compare with case urgency. It connects spatial coverage to the practical question of how quickly the bank can respond.

    The result shows how zone type maps to response-hour commitments. Express and overnight zones represent faster response promises, while standard and economy zones represent longer service windows.

    This matters because risk operations are not finished when a signal is detected. If a case requires outreach, document review, or service follow-up, the bank also needs to know whether the service network can meet the response time implied by the case priority.

## Next Steps

Congratulations on completing the spatial lab. You used spatial queries to connect demand regions, service centers, and response-time zones so operations teams can see where service capacity matters most. For a deeper hands-on workshop focused on Oracle Spatial, open the [Oracle Spatial LiveLabs workshop](https://livelabs.oracle.com/ords/r/dbpm/livelabs/view-workshop?clear=RR,180&wid=800).

## Acknowledgements

* **Author** - Pat Shepherd, Senior Principal Database Product Manager
* **Contributor** - Linda Foinding, Principal Database Product Manager
* **Last Updated By/Date** - Oracle Database Product Management, June 2026
