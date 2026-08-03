# Lab 2: Network Experience Operations Center

## Introduction

A network operations leader needs an early read on where trouble is starting. Subscriber demand, service orders, revenue exposure, and field work all tell part of the story. This lab shows how one command-center query can bring those signals together before teams chase separate reports.

Estimated Time: 10 minutes

| Operating Story | Detail |
| --- | --- |
| Business Problem | A 5G demand surge can become a subscriber experience issue before teams agree on the operating picture. |
| Technical Challenge | Dashboards often require data copied from OSS, BSS, care, service-order, dispatch, and analytics systems. |
| Persona Focus | Network operations leader and service assurance manager. |
| What You Will Learn | Oracle SQL can combine service orders, subscriber signals, capacity, and agent actions into one command-center evidence set. |
| Database Capability | Relational SQL, semantic views, JSON-ready service context. |
| Outcome | Operators can move from KPI detection to service-level evidence. |
{: title="What this lab covers"}

**Persona focus:** You are the operations leader deciding where to focus first during the South Florida demand surge.

### Objectives

- Query command-center KPIs that summarize service pressure.
- Rank services by demand, urgency, and subscriber signal strength.
- Connect high-value service detail to downstream service-order and assurance workflows.


The image below is the operations KPI area. A network operations leader would use it to see the scale of service pressure, subscriber signals, dispatch activity, and AI-assisted interventions. The SQL in this lab explains how those cards can be traced back to governed rows.

![Operations KPI cards](images/operations-kpis.png)

## How This Lab Fits the Story

You start like an operations leader during a busy shift: scan the whole situation first, then drill into the services that need attention. The KPI and pressure queries help you decide where to look before moving into subscriber signal search.

## Scene Evidence

The image below shows service demand pressure. It helps an operations team decide which services deserve the next investigation step. The lab SQL recreates that ranking logic from service, signal, and order evidence.

![Service demand pressure](images/service-demand-pressure.png)

The image below previews the service detail handoff. Once an operator identifies a pressure service, the same service identity can flow into document, vector, graph, spatial, predictive, and agent workflows without losing context.

![Service JSON Duality View](images/service-json-duality-view.png)

## Task 1: Query the command-center KPI row

1. Run this SQL block.

    This query creates the kind of summary an operations leader needs before drilling into details. Each `UNION ALL` branch counts one operating signal, such as orders, revenue, subscriber signals, pressure services, active dispatches, and AI-assisted interventions. Look for one shared KPI set that different teams can use without reconciling separate reports.

    ```sql
    <copy>
    SELECT 'Service orders' AS metric, COUNT(*) AS value FROM seer_comms_service_orders_v
    UNION ALL SELECT 'Service revenue', ROUND(SUM(service_value), 0) FROM seer_comms_service_orders_v
    UNION ALL SELECT 'Subscriber signals', COUNT(*) FROM seer_comms_subscriber_signals_v
    UNION ALL SELECT 'Services under pressure', COUNT(DISTINCT service_id) FROM seer_comms_signal_matches_v
    UNION ALL SELECT 'Active dispatches', COUNT(*) FROM seer_comms_field_dispatch_v WHERE dispatch_status <> 'Completed'
    UNION ALL SELECT 'AI-assisted interventions', COUNT(*) FROM seer_comms_agent_actions_v;
    </copy>
    ```

    **Expected output: Operations center health metrics**

    | Metric | Value |
    | --- | ---: |
    | Service orders | 3000 |
    | Service revenue | 2170000 |
    | Subscriber signals | 5000 |
    | Services under pressure | 32 |
    | Active dispatches | 375 |
    | AI-assisted interventions | 25 |
    {: title="Operations center health metrics"}

This KPI row is the first shared operating picture. It combines service, signal, dispatch, and agent activity so different teams can react to the same numbers instead of comparing separate spreadsheets.

## Task 2: Find services under demand pressure

1. Run this SQL block.

    This query ranks services by the number and strength of subscriber-signal matches. It groups semantic matches by service, counts signal mentions, reports the strongest similarity score, and labels services as `High` or `Watch`. Look for services with many mentions and strong matches, because those are practical candidates for deeper investigation.

    ```sql
    <copy>
    SELECT service_name,
       service_line_name,
       COUNT(*) AS signal_mentions,
       ROUND(MAX(similarity_score), 3) AS strongest_match,
       CASE WHEN COUNT(*) >= 50 THEN 'High' ELSE 'Watch' END AS risk_level
    FROM seer_comms_signal_matches_v
    GROUP BY service_name, service_line_name
    ORDER BY signal_mentions DESC
    FETCH FIRST 8 ROWS ONLY;
    </copy>
    ```

    **Expected output: Services with urgent subscriber signals**

    | Service Name | Service Line Name | Signal Mentions | Strongest Match | Risk Level |
    | --- | --- | ---: | ---: | --- |
    | Fixed Wireless Home Internet | Seer Home Broadband | 57 | 0.89 | High |
    | Device Upgrade Enrollment | Seer Mobile | 55 | 0.88 | High |
    | Gigabit Fiber Install | Seer Fiber | 53 | 0.87 | High |
    {: title="Services with urgent subscriber signals"}


The exact ordering can change as data changes. The important habit is the ranking pattern: you can sort service pressure by demand and urgency while the service, signal, and customer context stays governed in Oracle.

## Task 3: Inspect one service for API-ready context

1. Run this SQL block.

    This query narrows the investigation to one service identity that later labs can reuse across access patterns. The `WHERE` clause selects `Fixed Wireless Home Internet`, and the returned service fields give the workshop a consistent handoff point. That matters because every later capability should refer to the same service definition.

    ```sql
    <copy>
    SELECT service_id,
       service_name,
       service_category,
       service_segment,
       service_value_proxy
    FROM seer_comms_services_v
    WHERE service_name = 'Fixed Wireless Home Internet';
    </copy>
    ```

    **Expected output: High-value services to monitor**

    | Service ID | Service Name | Service Category | Service Segment | Service Value Proxy |
    | ---: | --- | --- | --- | ---: |
    | 1001 | Fixed Wireless Home Internet | Broadband | Home Internet | 79.99 |
    {: title="High-value services to monitor"}


This final service row acts like a handoff token. Once you know the service that matters, later labs can use the same identity for JSON orders, vector matches, graph impact, spatial capacity, predictions, and agent actions.


## Learn More

- [Oracle JSON Relational Duality documentation](https://docs.oracle.com/en/database/oracle/oracle-database/26/jsnvu/)

## Acknowledgements

- **Author** - Oracle LiveLabs Team
