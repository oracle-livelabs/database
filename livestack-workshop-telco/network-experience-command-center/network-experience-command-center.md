# Lab 2: Network Experience Operations Center

## Introduction

A network operations leader needs to detect where subscriber demand, service orders, revenue exposure, and field work are starting to move. The command center query pattern combines current operations data without forcing the learner into separate reporting tools.

Estimated Time: 10 minutes

| Operating Story | Detail |
| --- | --- |
| Business Problem | A 5G demand surge can become a subscriber experience issue before teams agree on the operating picture. |
| Technical Challenge | Dashboards often require data copied from OSS, BSS, care, service-order, dispatch, and analytics systems. |
| Persona Focus | Network operations leader and service assurance manager. |
| What You Will Prove | Oracle SQL can combine service orders, subscriber signals, capacity, and agent actions into one command-center evidence set. |
| Database Capability | Relational SQL, semantic views, JSON-ready service context. |
| Outcome | Operators can move from KPI detection to service-level evidence. |
{: title="What this lab proves"}

**Persona focus:** You are the operations leader deciding where to focus first during the South Florida demand surge.

### Objectives

- Query command-center KPIs.
- Rank services by demand pressure.
- Connect service detail to JSON-ready evidence.


![Operations KPI cards](images/operations-kpis.png)

## How This Lab Fits the Story

You start like an operations leader: look at the whole situation first, then drill into service pressure. The KPI and pressure queries show which services deserve attention before the workflow moves into signal search.

## Scene Evidence

![Service demand pressure](images/service-demand-pressure.png)

![Service JSON Duality View](images/service-json-duality-view.png)

## Task 1: Query the command-center KPI row

1. Run this SQL block.

    This query creates the kind of summary an operations leader needs before drilling into details.

    <copy>
SELECT 'Service orders' AS metric, COUNT(*) AS value FROM seer_comms_service_orders_v
UNION ALL SELECT 'Service revenue', ROUND(SUM(service_value), 0) FROM seer_comms_service_orders_v
UNION ALL SELECT 'Subscriber signals', COUNT(*) FROM seer_comms_subscriber_signals_v
UNION ALL SELECT 'Services under pressure', COUNT(DISTINCT service_id) FROM seer_comms_signal_matches_v
UNION ALL SELECT 'Active dispatches', COUNT(*) FROM seer_comms_field_dispatch_v WHERE dispatch_status <> 'Completed'
UNION ALL SELECT 'AI-assisted interventions', COUNT(*) FROM seer_comms_agent_actions_v;
</copy>

Expected output:

| Metric | Value |
| --- | ---: |
| Service orders | 3000 |
| Service revenue | 2170000 |
| Subscriber signals | 5000 |
| Services under pressure | 32 |
| Active dispatches | 375 |
| AI-assisted interventions | 25 |
{: title="Operations center health metrics"}

This query shows why a converged data platform matters. The KPI row comes from live operational domains, not a stitched spreadsheet.

## Task 2: Find services under demand pressure

1. Run this SQL block.

    This query ranks services by the number and strength of subscriber-signal matches.

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

Expected output:

| Service Name | Service Line Name | Signal Mentions | Strongest Match | Risk Level |
| --- | --- | ---: | ---: | --- |
| Fixed Wireless Home Internet | Seer Home Broadband | 57 | 0.89 | High |
| Device Upgrade Enrollment | Seer Mobile | 55 | 0.88 | High |
| Gigabit Fiber Install | Seer Fiber | 53 | 0.87 | High |
{: title="Services with urgent subscriber signals"}


The important result is not the exact ordering. The business value is that pressure can be ranked with service, signal, and customer context still governed by Oracle.

## Task 3: Inspect one service for API-ready context

1. Run this SQL block.

    This query narrows the investigation to one service identity that later labs can reuse across access patterns.

    <copy>
SELECT service_id,
       service_name,
       service_category,
       service_segment,
       service_value_proxy
FROM seer_comms_services_v
WHERE service_name = 'Fixed Wireless Home Internet';
</copy>

Expected output:

| Service ID | Service Name | Service Category | Service Segment | Service Value Proxy |
| ---: | --- | --- | --- | ---: |
| 1001 | Fixed Wireless Home Internet | Broadband | Home Internet | 79.99 |
{: title="High-value services to monitor"}


The dashboard can start as a simple operations view, then hand the same service identity to JSON, vector, graph, spatial, ML, and agent flows in later labs.


## Learn More

- [Oracle JSON Relational Duality documentation](https://docs.oracle.com/en/database/oracle/oracle-database/26/jsnvu/)

## Acknowledgements

- **Author** - Oracle LiveLabs Team
