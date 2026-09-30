# Build a Converged Dashboard Query

## Introduction

Jessica Chan is the database developer responsible for keeping Seer Utility Network’s operational data reliable and useful. Every morning, the field-operations team asks her a familiar question: **which service requests need attention first, and can the utility respond before reliability risk or capacity constraints become operational disruptions?**

Jessica can see the answer taking shape in the Energy Operations Command Center, but the supporting evidence is spread across related operational records. Service requests and urgency are relational rows. Reliability signals describe conditions that may affect those requests. Field-logistics capacity records show the availability of the services and supplies needed to respond. The data is connected by operational meaning, but that does not automatically make the investigation easy to query.

In the past, Jessica might have had to maintain reporting extracts, coordinate with field-logistics teams for capacity information, and reconcile separate operational dashboards before she could explain why a request should be reviewed. That creates more copies of operational data, more security boundaries, and more opportunities for the dashboard answer and the underlying detail to disagree. Her challenge is not simply finding another database feature. It is giving field operations one answer they can trace back to the same governed data.

Jessica sees an opportunity in Oracle AI Database’s converged architecture. A converged database lets one governed database support different data models and workloads together. Relational tables and views remain the foundation, while JSON documents, vectors, spatial geometry, graphs, and machine-learning results can be used alongside them when the operational question requires it. This reduces the need for complex integration across separate systems and data copies.

In this lab, you take Jessica’s role as the database developer. You will build the governed SQL query behind the Energy Operations Command Center. It connects service-request urgency, related reliability evidence, assigned field-logistics sites, and available capacity in one Oracle AI Database result. Later labs extend this same governed Energy & Utilities foundation with additional database capabilities.

![jessica](images/jessica.png)

### Objectives

- Summarize current service-request risk.
- Connect request urgency to field-logistics capacity.
- Explain why a converged query reduces operational data copies.

Estimated Time: **10 minutes**

### Hands-on Scenario

Jessica first verifies the command-center totals, then drills into the sites where high-priority requests and low capacity require review.

| Step | Energy & Utilities focus |
| --- | --- |
| Business Problem | Field operations need a clear way to identify service requests where urgency, reliability evidence, and capacity constraints require review. |
| Technical Challenge | The answer connects service requests, requested services, reliability signals, assigned field-logistics sites, and available capacity. |
| Persona Focus | Jessica Chan, the database developer, builds the governed query that explains the Energy Operations Command Center. |
| What You Will Do | Verify the command-center KPIs, then run one SQL query that produces a traceable operational review list. |
| Database Capability | Relational SQL joins governed Energy & Utilities views without separate reports or operational data copies. |
| Outcome | The learner can explain why a request needs review by tracing dashboard evidence back to its underlying operational rows. |





Persona focus: You are Jessica Chan, the database developer. Your job is to build the command-center review query that brings each active service request together with its related reliability signal, assigned field-logistics site, and currently available response capacity.
> **SQL Worksheet reminder:** Return to [Getting Started Task 2](?lab=getting-started#Task2:OpenSQLWorksheet) if you need the launch and execution steps.

## Task 1: Read the command-center KPIs


The dashboard is a starting point for the decision, not the decision itself. Run the query below to produce a compact operational investigation view for active service requests.

This first query establishes the relational foundation for the workshop:

- **Relational:** `EU_UTILITY_SERVICE_REQUESTS`, `EU_UTILITY_REQUEST_ITEMS`, and `EU_ASSET_CAPACITY_V` connect request urgency, related reliability evidence, assigned field-logistics sites, and available response capacity.

Later labs extend the same governed Energy & Utilities foundation with additional database capabilities:

- **JSON Relational Duality:** exposes service-request data as application-ready JSON while preserving relational access.
- **AI Vector Search:** finds utility services related by meaning to an operational investigation phrase.
- **Property Graph:** follows relationships between operational events, utility assets, and affected services.
- **Oracle Spatial:** analyzes field-service locations and operational geography.
- **Oracle Machine Learning:** classifies demand risk from historical service-request patterns.

Together, these capabilities let the utility investigate operational questions without moving governed data into separate document stores, search services, mapping platforms, graph systems, or machine-learning pipelines.





1. Open SQL Worksheet as `LLUSER`.

2. Run the query below to return the current command-center KPI summary.

    <copy>
    ```sql
    SELECT active_field_logistics_site_count,
           available_capacity_supply_units,
           pending_logistics_request_count,
           capacity_supply_alert_count,
           high_priority_alert_count,
           high_load_site_count
    FROM eu_field_logistics_kpis_v;
    ```
    </copy>
    



3. Review the result as the command-center summary behind Jessica’s dashboard. The single row combines active field-logistics sites, available capacity-supply units, pending logistics requests, capacity-supply alerts, high-priority alerts, and high-load sites.

    ![LLUSER SQL Worksheet result for the field-logistics KPI summary](images/command-center-kpis-overview.png " ")
Your numbers may differ if the workshop data changes, but the query should return one summary row.

Use the row to explain the operational takeaway: the totals show the scale of current demand and response capacity, while the alert counts show where field operations may need to investigate further. The KPI summary identifies the need for review; it does not yet identify the individual service request or assigned site behind that need.

With separate reporting extracts, request, reliability, and capacity totals could become inconsistent or require manual reconciliation. Oracle AI Database keeps the governed operational data together, so the command center and its detailed review queries can use the same database foundation. In the next task, Jessica drills into the individual service requests behind these totals and traces each request to its related reliability evidence, assigned field-logistics site, and available response capacity.

## Task 2: Build the operational review list

1. Run the detailed query.

    <copy>
    ```sql
    WITH request_services AS (
      SELECT DISTINCT i.service_request_id,
             i.service_supply_id,
             r.field_logistics_site_id
      FROM eu_utility_request_items i
      JOIN eu_utility_service_requests r
        ON r.service_request_id = i.service_request_id
    ),
    capacity_by_request AS (
      SELECT rs.service_request_id,
             MAX(CASE c.capacity_status
                   WHEN 'OUT_OF_STOCK' THEN 3
                   WHEN 'AT_RISK' THEN 2
                   WHEN 'ADEQUATE' THEN 1
                   ELSE 0
                 END) AS capacity_risk_rank,
             SUM(GREATEST(
               NVL(c.quantity_on_hand, 0) - NVL(c.quantity_reserved, 0), 0
             )) AS available_units
      FROM request_services rs
      JOIN eu_asset_capacity_v c
        ON c.utility_service_id = rs.service_supply_id
       AND c.field_logistics_site_id = rs.field_logistics_site_id
      GROUP BY rs.service_request_id
    )
    SELECT r.service_request_id,
           r.requesting_service_point_name,
           r.request_status_display_name,
           r.related_signal_label,
           ROUND(r.related_signal_criticality_score, 1) AS signal_criticality,
           ROUND(r.urgency_score, 1) AS urgency_score,
           r.field_logistics_site_name,
           CASE NVL(c.capacity_risk_rank, 0)
             WHEN 3 THEN 'OUT_OF_STOCK'
             WHEN 2 THEN 'AT_RISK'
             WHEN 1 THEN 'ADEQUATE'
             ELSE 'NO_CAPACITY_ROW'
           END AS worst_capacity_status,
           NVL(c.available_units, 0) AS available_units,
           NVL(c.capacity_risk_rank, 0) AS capacity_risk_rank
    FROM eu_utility_service_requests r
    LEFT JOIN capacity_by_request c
      ON c.service_request_id = r.service_request_id
    WHERE r.request_status IN ('pending', 'confirmed', 'processing', 'shipped')
    ORDER BY r.urgency_score DESC NULLS LAST,
             signal_criticality DESC NULLS LAST,
             r.service_request_id
    FETCH FIRST 15 ROWS ONLY;
    ```
    </copy>

2. Select one row and explain the evidence chain: request, service point, signal, assigned site, and available capacity.

    **Expected output pattern**

    | Evidence | Stable check |
    | --- | --- |
    | Request | A service request identifier and status appear. |
    | Risk | Urgency and, when present, signal criticality support the ordering. |
    | Response | The assigned site, capacity status, and available units are visible. |

> **Checkpoint:** The request identifier is the traceable key. The dashboard can summarize several capabilities, but every conclusion still leads back to governed rows in the same database.

> **🎯 Interactive challenge:** Order capacity alerts before request urgency. Compare the first three rows with the original result and explain which operational question each ordering answers.

<details>
<summary><strong>Challenge answer</strong></summary>

Use the complete alternate query below. The original ordering prioritizes request urgency; this version prioritizes the most constrained capacity evidence and uses the request identifier as a deterministic tie-breaker.

    ```sql
    WITH request_services AS (
      SELECT DISTINCT i.service_request_id,
             i.service_supply_id,
             r.field_logistics_site_id
      FROM eu_utility_request_items i
      JOIN eu_utility_service_requests r
        ON r.service_request_id = i.service_request_id
    ),
    capacity_by_request AS (
      SELECT rs.service_request_id,
             MAX(CASE c.capacity_status
                   WHEN 'OUT_OF_STOCK' THEN 3
                   WHEN 'AT_RISK' THEN 2
                   WHEN 'ADEQUATE' THEN 1
                   ELSE 0
                 END) AS capacity_risk_rank,
             SUM(GREATEST(
               NVL(c.quantity_on_hand, 0) - NVL(c.quantity_reserved, 0), 0
             )) AS available_units
      FROM request_services rs
      JOIN eu_asset_capacity_v c
        ON c.utility_service_id = rs.service_supply_id
       AND c.field_logistics_site_id = rs.field_logistics_site_id
      GROUP BY rs.service_request_id
    )
    SELECT r.service_request_id,
           r.requesting_service_point_name,
           r.request_status_display_name,
           r.related_signal_label,
           ROUND(r.related_signal_criticality_score, 1) AS signal_criticality,
           ROUND(r.urgency_score, 1) AS urgency_score,
           r.field_logistics_site_name,
           CASE NVL(c.capacity_risk_rank, 0)
             WHEN 3 THEN 'OUT_OF_STOCK'
             WHEN 2 THEN 'AT_RISK'
             WHEN 1 THEN 'ADEQUATE'
             ELSE 'NO_CAPACITY_ROW'
           END AS worst_capacity_status,
           NVL(c.available_units, 0) AS available_units,
           NVL(c.capacity_risk_rank, 0) AS capacity_risk_rank
    FROM eu_utility_service_requests r
    LEFT JOIN capacity_by_request c
      ON c.service_request_id = r.service_request_id
    WHERE r.request_status IN ('pending', 'confirmed', 'processing', 'shipped')
    ORDER BY capacity_risk_rank DESC,
             r.urgency_score DESC NULLS LAST,
             r.service_request_id
    FETCH FIRST 15 ROWS ONLY;
    ```

</details>

## Next Steps

Thomas now exposes one of those relational service requests as an application-ready JSON document.

## Acknowledgements

* **Author** - Oracle Database Product Management
* **Last Updated By/Date** - Oracle Database Product Management, September 2026
