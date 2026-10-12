# Build a Converged Dashboard Query

## Introduction

Jessica Chan, Seer Hotels’ DBA, starts with the guest-service team's morning question: **which stay offers need attention first, and which guests may need assistance?**

Build her dashboard query by combining service alerts from relational tables, reservation activity from JSON, stay offer matches from vectors, and nearby hotels from spatial data.

![jessica](images/jessica.png)

### Objectives

- Explain how one database query combines the information needed for a guest-service decision.
- Run one query that combines relational, vector, JSON, and spatial database capabilities.
- Modify the query to investigate a different guest-service question and explain the change in results.

Estimated Time: **10 minutes**

> **SQL Worksheet reminder:** See [Getting Started Task 2: Open SQL Worksheet](?lab=getting-started#Task2:OpenSQLWorksheet) for the steps to paste and run SQL.

## Task 1: Run a converged service investigation

Run the query below to list stay offers with severe service alerts. Use the result to decide which offers need review.

The query combines four data types:

- **Relational:** Use `SERVICE_ALERTS_V` and links to stay offers to summarize service alerts and their impact.
- **Vector:** `OFFER_EMBEDDINGS` and `VECTOR_DISTANCE` find stay offers related by meaning to the investigation phrase.
- **JSON:** `JSON_TABLE` reads nested line items from `RESERVATIONS_DV` as rows so the query can count reservation activity.
- **Spatial:** `SDO_GEOM.SDO_DISTANCE` finds the closest hotel property to the high-demand New York Visitor Region using spatial geometries.

1. Open SQL Worksheet as `LLUSER`. 

2. Run the query (note the comments that help to locate the specific use of different data types):

    ```sql
    <copy>
    -- RELATIONAL DATA: aggregate high-severity records and join them
    -- to shared stay offer and property views.
    WITH offer_service_impact AS (
        SELECT sov.offer_id,
               sov.offer_name,
               hpv.property_name,
               sov.offer_category,
               COUNT(DISTINCT sa.alert_id) AS urgent_service_alerts,
               ROUND(AVG(sa.severity_score), 1) AS avg_severity,
               SUM(sa.affected_reservations) AS affected_reservations,
               SUM(sa.service_cases_opened) AS cases_opened
        FROM service_alerts_v sa
        JOIN post_offer_mentions pom
          ON pom.post_id = sa.alert_id
        JOIN stay_offers_v sov
          ON sov.offer_id = pom.offer_id
        JOIN hotel_properties_v hpv
          ON hpv.property_id = sov.property_id
        WHERE sa.severity_score >= 80
        GROUP BY sov.offer_id,
                 sov.offer_name,
                 hpv.property_name,
                 sov.offer_category
    ),
    -- VECTOR DATA: compare the investigation question with stored
    -- stay offer embeddings to rank stay offers by meaning, not exact wording.
    semantic_match AS (
        SELECT so.offer_id,
               ROUND(1 - VECTOR_DISTANCE(
               oe.embedding,
                   VECTOR_EMBEDDING(
                       ADMIN.ALL_MINILM_L12_V2
                       USING 'room accessibility and service disruption requiring guest assistance' AS DATA
                   ),
                   COSINE
               ), 4) AS semantic_similarity
        FROM offer_embeddings oe
        JOIN stay_offers so
          ON so.offer_id = oe.offer_id
    ),
    -- JSON DATA: read reservation documents from the duality view and
    -- project nested line items into relational rows with JSON_TABLE.
    reservation_activity AS (
        SELECT jt.offer_id,
               COUNT(DISTINCT jt.reservation_id) AS active_reservations,
               SUM(jt.room_nights) AS active_room_nights
        FROM reservations_dv rd
        CROSS APPLY JSON_TABLE(
            rd.data,
            '$'
            COLUMNS (
                reservation_id NUMBER PATH '$._id',
                reservation_status VARCHAR2(30) PATH '$.status',
                NESTED PATH '$.items[*]' COLUMNS (
                    offer_id NUMBER PATH '$.offerId',
                    room_nights NUMBER PATH '$.roomNights'
                )
            )
        ) jt
        WHERE jt.reservation_status IN ('pending', 'confirmed')
        GROUP BY jt.offer_id
    ),
    -- SPATIAL DATA: calculate the distance from each hotel-property point
    -- to the New York Visitor Region demand-region boundary.
    nearest_property AS (
        SELECT routing_property.property_name,
               routing_property.city,
               routing_property.state_province,
               dr.region_name,
               dr.demand_index,
               ROUND(
                   SDO_GEOM.SDO_DISTANCE(
                       hp.location,
                       dr.boundary,
                       0.005,
                       'unit=KM'
                   ),
                   2
               ) AS distance_to_demand_region_km
        FROM hotel_properties_v routing_property
        JOIN hotel_properties hp
          ON hp.property_id = routing_property.property_id
        CROSS JOIN demand_regions dr
        WHERE dr.region_name = 'New York Visitor Region'
          AND hp.is_active = 1
        ORDER BY SDO_GEOM.SDO_DISTANCE(
                     hp.location,
                     dr.boundary,
                     0.005,
                     'unit=KM'
                 )
        FETCH FIRST 1 ROW ONLY
    )
    -- CONVERGED RESULT: join the outputs of the four data-model operations
    -- into one dashboard investigation result.
    SELECT impact.offer_name,
           impact.property_name,
           impact.offer_category,
           impact.urgent_service_alerts,
           impact.avg_severity,
           impact.affected_reservations,
           impact.cases_opened,
           sm.semantic_similarity,
           NVL(activity.active_reservations, 0) AS active_reservations,
           NVL(activity.active_room_nights, 0) AS active_room_nights,
           nearest_hotel.property_name AS nearest_property,
           nearest_hotel.city || ', ' || nearest_hotel.state_province AS property_location,
           nearest_hotel.region_name AS demand_region,
           nearest_hotel.demand_index,
           nearest_hotel.distance_to_demand_region_km
    FROM offer_service_impact impact
    LEFT JOIN semantic_match sm
      ON sm.offer_id = impact.offer_id
    LEFT JOIN reservation_activity activity
      ON activity.offer_id = impact.offer_id
    CROSS JOIN nearest_property nearest_hotel
    -- Put stay offers closest to the investigation question first.
    -- Service impact breaks ties so the result still favors larger business impact.
    ORDER BY sm.semantic_similarity DESC NULLS LAST,
             impact.affected_reservations DESC
    FETCH FIRST 10 ROWS ONLY;
    </copy>
    ```

    ![SQL Worksheet result — dashboard](images/sql-dashboard.jpg)

3. Review the top stay offer. Compare its alert severity, semantic rank, reservation activity, and nearby hotel to explain why the team should investigate it first.

    A missing embedding or an empty regional property set can leave the result incomplete or empty.

> **Interpretation:** The nearest-property result is regional context shared by every row. It is not a date-specific availability check or an automatic relocation. Affected-reservation counts are alert totals and may include a reservation in more than one alert; do not read their sum as unique guests.

## Task 2: Change the investigation question

The analyst now wants to investigate a different concern. Replace the investigation phrase with:

```text
guest arrival workload and room availability
```

Run the query again and compare the top rows.

![Query result after changing the investigation phrase](images/sql-dashboard-followup.jpg)

1. Which stay offers moved into or out of the top ten?
2. Which stay offers still have high relational service impact but a lower semantic similarity to the new question?
3. Which offers have the most pending, confirmed or checked-in reservations that may need review?

The query sorts by similarity first, so changing the question changes the review order. Service impact breaks ties. Jessica can ask a different question using the same query and stay offer data.

## Next Steps

Next, use JSON Relational Duality to expose the same reservation data as JSON for an application while keeping SQL access for the database team.

## Application example

Explore the [LiveStack Demo Hospitality](https://livelabs.oracle.com/ords/r/dbpm/livelabs/view-workshop?wid=4525).

![LiveStack Demo Hospitality: Property Performance Command Center](images/demo-dashboard.jpg)

*LiveStack Demo Hospitality: Property Performance Command Center*

![LiveStack Demo Hospitality: Property Performance Command Center](images/demo-dashboard-charts.jpg)

*LiveStack Demo Hospitality: Property Performance Command Center*

## Acknowledgements

* **Author** - Matt Kowalik
* **Contributor** - Kevin Lazarz
* **Last Updated By/Date** - Matt Kowalik, September 2026
