# Lab 7: Predictive Service Assurance with OML

## Introduction

Predictive assurance helps telecom teams understand demand surge, retention segments, service clusters, revenue forecast quality, and access risk without moving data into a separate notebook-only workflow.

Estimated Time: 10 minutes

| Operating Story | Detail |
| --- | --- |
| Business Problem | Retention and capacity teams need model signals that are explainable enough to drive action. |
| Technical Challenge | Predictions lose trust when features, scores, and operational context are separated. |
| Persona Focus | Service assurance analytics manager, churn-risk analyst, and data science lead. |
| What You Will Prove | OML scoring patterns can run close to governed telecom data and join back to operations context. |
| Database Capability | Oracle Machine Learning for SQL, `DBMS_DATA_MINING`, `PREDICTION_PROBABILITY`, `CLUSTER_ID`. |
| Outcome | Scores become operational signals for capacity, care, and retention teams. |
{: title="What this lab proves"}

**Persona focus:** You are the analytics lead translating model output into service assurance decisions.

### Objectives

- Review the LiveStack scene evidence.
- Run SQL that proves the database pattern.
- Connect the result to the next operating decision.

![Predictive assurance page](images/predictive-assurance-page.png)

![Lab 7: Predictive Service Assurance with OML concept diagram](images/oml-flow.svg)

## How This Lab Fits the Story

You look ahead after reviewing current operations. The predictive assurance queries show how service signals, customer experience, demand forecasts, and capacity can become action-oriented risk evidence.

## Scene Evidence

Use the screenshot as scene grounding. The SQL tasks below provide the exact values to verify.

![Service revenue forecast](images/service-revenue-forecast.png)

![Retention segments](images/retention-segments.png)

## Task 1: Inspect service demand signals

1. Run this SQL block.

    This query prepares model-style features from current service demand and revenue evidence.

    <copy>
SELECT s.service_name,
       COUNT(DISTINCT m.signal_id) AS recent_signal_count,
       COUNT(DISTINCT o.service_order_id) AS service_orders,
       ROUND(SUM(o.service_value), 0) AS service_value
FROM seer_comms_services_v s
LEFT JOIN seer_comms_signal_matches_v m ON m.service_id = s.service_id
LEFT JOIN seer_comms_service_orders_v o ON o.source_signal_id = m.signal_id
GROUP BY s.service_name
ORDER BY recent_signal_count DESC
FETCH FIRST 8 ROWS ONLY;
    </copy>

Expected output:

| Service Name | Recent Signal Count | Service Orders | Service Value |
| --- | ---: | ---: | ---: |
| Device Upgrade Enrollment | 107 | 260 | 67600 |
| Fixed Wireless Home Internet | 102 | 248 | 64100 |
{: title="Service demand signals for prediction"}

## Task 2: Review retention-style customer experience features

1. Run this SQL block.

    This query groups customer experience signals so retention teams can reason about segments.

    <copy>
SELECT subscriber_tier,
       COUNT(*) AS subscribers,
       ROUND(AVG(service_value), 0) AS avg_lifetime_value,
       ROUND(AVG(avg_demand_score), 2) AS avg_demand_score
FROM seer_comms_customer_experience_v
GROUP BY subscriber_tier
ORDER BY subscribers DESC;
    </copy>

Expected output:

| Subscriber Tier | Subscribers | Avg Lifetime Value | Avg Demand Score |
| --- | ---: | ---: | ---: |
| Potential | 59 | 1740 | 63.12 |
| Loyal | 10 | 6180 | 44.70 |
{: title="Subscriber tiers for assurance planning"}

## Task 3: Join predicted demand to capacity exposure

1. Run this SQL block.

    This query connects forecast demand to available network capacity, turning scores into an action list.

    <copy>
SELECT f.service_name,
       c.network_site_name,
       c.capacity_available,
       f.predicted_service_demand,
       f.signal_factor,
       CASE WHEN c.capacity_available < f.predicted_service_demand THEN 'Access risk' ELSE 'Covered' END AS access_status
FROM seer_comms_demand_forecasts_v f
JOIN seer_comms_network_capacity_v c ON c.service_id = f.service_id
WHERE f.forecast_date = (SELECT MAX(forecast_date) FROM seer_comms_demand_forecasts_v)
ORDER BY (f.predicted_service_demand - c.capacity_available) DESC
FETCH FIRST 8 ROWS ONLY;
    </copy>

Expected output:

| Service Name | Network Site Name | Capacity Available | Predicted Service Demand | Signal Factor | Access Status |
| --- | --- | ---: | ---: | ---: | --- |
| Device Upgrade Enrollment | Boston Family Plan Support Center | 13 | 141 | 1.28 | Access risk |
| Fixed Wireless Home Internet | Seattle Customer Experience Center | 23 | 139 | 1.24 | Access risk |
{: title="Access risks that need action"}




## Learn More

- See `ORACLE_REFERENCE_LINKS.md` in the supporting files directory for official Oracle documentation links.

## Acknowledgements

- **Author** - Oracle LiveLabs Team
