# Build a Converged Dashboard Query

## Introduction

> **Image status:** Hospitality captures for this lab are pending a deployed environment. The SQL and written checks below define what to inspect. Retained generic images are reference material, not evidence of a hospitality run. See the [image inventory](../validation/screenshots.md).

Jessica Chan is the database administrator responsible for keeping Seer Hotels’ hospitality data reliable and useful. Every morning, the guest service operations team asks her a familiar question: **which stay offer needs attention first, and which guests may need assistance or relocation?**

Jessica can see the answer taking shape in the Guest Service and Operations Dashboard, but the supporting data is spread across different forms. Service alerts and stay offer service impact are relational rows. Reservation activity is available as JSON reservation documents. The AI engineering team has also prepared vector representations of stay offer descriptions for another use case. Location information for hotel properties and demand regions is stored as spatial geometries that can be converted to GeoJSON. The data is connected by business meaning, but that does not automatically make the investigation easy to query.

In the past, Jessica might have had to maintain reporting extracts, coordinate a search index, ask an application team for reservation data, and reconcile a separate map or service-capacity system. That creates more copies of sensitive hospitality data, more security boundaries, and more opportunities for the dashboard answer and the operational detail to disagree. Her challenge is not simply finding another database feature. It is giving the guest service team one answer they can trace back to the same shared data.

Jessica sees an opportunity in Oracle AI Database's converged architecture. A converged database lets one shared database support different data models and workloads together. Relational tables and views remain the foundation, while JSON documents, vectors, spatial geometry, graphs, machine-learning, and graph results can be queried alongside them. This means Jessica can answer a question that crosses those data types without complex and expensive integration across separate systems.

In this lab, you take Jessica's role as the DBA. You will write the converged SQL query behind the Guest Service and Operations Dashboard. It combines relational service-alert data, vector search, JSON reservation data, and spatial service data in one Oracle AI Database, without separate systems or data copies.

![jessica](images/jessica.png)

### Objectives

- Explain what Oracle AI Database convergence means in a hospitality decision workflow.
- Run one query that combines relational, vector, JSON, and spatial database capabilities.
- Modify the query to investigate a different guest-service question and explain the change in results.

Estimated Time: **10 minutes**

### Hands-on Scenario

| Step                | Hospitality focus                                                                                                  |
| ---------------------| ----------------------------------------------------------------------------------------------------------------|
| Business Problem    | Business users need a quick way to find stay offer service needs, service impact, reservation activity, and service information. |
| Technical Challenge | The answer crosses service alerts, stay offer meaning, reservations, and service geography.                         |
| Persona Focus       | Jessica Chan, the DBA, builds the query that gives business users this dashboard view.                         |
| What You Will Do    | Use a single SQL statement that combines several data types.                                                   |
| Database Capability | Relational SQL, AI Vector Search, JSON Relational Duality, and Oracle Spatial work together.                   |
| Outcome             | The learner can explain convergence through a useful business result rather than a feature list.               |

Persona focus: You are Jessica Chan, the DBA. Your job is to build one shared query that gives business users a connected view of stay offer service needs and operations.

> **SQL Worksheet reminder:** Need a reminder on how to open and use the SQL Worksheet? Return to [Getting Started Task 2: Open SQL Worksheet](?lab=getting-started#Task2:OpenSQLWorksheet) for the step-by-step guide showing how to run SQL statements.

## Task 1: Run a converged service investigation

The dashboard is a starting point for the decision, not the decision itself. Run the query below to produce a compact investigation view for high-severity stay offers.

The query intentionally crosses four data models:

- **Relational:** `SERVICE_ALERTS_V`, stay offer mentions, and hospitality views calculate stay offer service needs and service impact.
- **Vector:** `OFFER_EMBEDDINGS` and `VECTOR_DISTANCE` find stay offers related by meaning to the investigation phrase.
- **JSON:** `RESERVATIONS_DV` is read as a document, and `JSON_TABLE` projects its nested line items into rows sov reservation activity can be counted.
- **Spatial:** `SDO_GEOM.SDO_DISTANCE` finds the closest hotel property to the high-demand New York Visitor Region using latitude and longitude information stored as spatial geometries that can be converted to GeoJSON.

    These are four operations in one investigation. Every row combines stay offer service needs with reservation activity, semantic relevance, and service-routing context.

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

3. Review the result as the stay offer-level data behind Jessica's dashboard. Each row combines service-alert severity, semantic match, reservation activity, and hotel location. This gives the dashboard a ranked stay offer table and the details a business user needs when deciding what to review.

    

    Each row should include all four types of data. The hospitality ranking and numeric values require a loaded dataset and have not yet been measured. A missing embedding or an empty regional property set can leave the result incomplete or empty.

Use the first row to explain the business takeaway: the service-alert severity and reservation counts show why the stay offer needs attention, the semantic match explains why it fits the question, and the service location shows where follow-up could begin. Jessica now has the query behind the dashboard's ranked stay offer table and detail view, combining relational service-alert data, vector search, JSON reservation data, and spatial distance in one result that a business user can inspect.

With separate systems, Jessica would need complex and expensive integration across a guest-service system, search service, document store, and mapping system before the dashboard could show this view. Oracle AI Database keeps these data types together, so she can build the dashboard with SQL. KPI cards and other dashboard components can use additional SQL over the same database.

> **Interpretation:** The nearest-property result is regional context shared by every row. It is not a date-specific availability check or an automatic relocation. Affected-reservation counts are alert totals and may include a reservation in more than one alert; do not read their sum as unique guests.

## Task 2: Change the investigation question

Jessica meets with a guest experience analyst to review the results at the data level before she builds the dashboard. They start with stay offers related to **room accessibility and service disruption requiring guest assistance**. Change the embedded investigation phrase to:


```text
guest arrival workload and room availability
```


Run the query again and compare the top rows.

1. Which stay offers moved into or out of the top ten?
2. Which stay offers still have high relational service impact but a lower semantic similarity to the new question?
3. Does the reservation activity make you more or less concerned about the operational impact?

The result is booked by semantic similarity first, so changing the question changes the review queue. Service impact breaks ties and keeps larger business impact near the top. The same shared query can answer a different business question without rebuilding a search index or moving the stay offer data.


## Next Steps

Next, use JSON Relational Duality to expose the same reservation data as JSON for an application while keeping SQL access for the database team.

## Acknowledgements

* **Author** - Kevin Lazarz
* **Contributor** - Eugenio Galiano
* **Last Updated By/Date** - Oracle Database Product Management, August 2026
