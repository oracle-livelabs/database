# Getting Started

## Introduction

This lab prepares your LiveLabs environment and confirms that the SQL labs run against the expected Seer Comms schema. The workshop uses the `LLUSER` schema for the telecom views and objects that support the operating story.

Estimated Time: 10 minutes

### Objectives

In this lab, you will:

- Open Database Actions SQL Worksheet.
- Confirm that you are connected as `LLUSER`.
- Use SQL copy blocks to run repeatable verification queries.
- Confirm the Seer Comms semantic views are available.

## How This Lab Fits the Story

You prepare SQL Worksheet and confirm the schema before running any feature labs. This protects you from reading or changing the wrong database user and gives every later result a clear starting point.

## Task 1: Open SQL Worksheet

1. From your LiveLabs environment, open **Database Actions** for the Autonomous Database.
2. Open **SQL Worksheet**.
3. Connect as `LLUSER` unless your instructor gives a different workshop schema.

## Task 2: Confirm the workshop schema

1. Run this SQL block.

    This quick check prevents the most common setup issue: running the labs from the wrong schema.

    ```sql
    <copy>
    SELECT USER AS connected_user;
    </copy>
    ```

    **Expected output: Expected database user**

    | Connected User |
    | --- |
    | LLUSER |
    {: title="Expected database user"}

The remaining labs use `LLUSER` objects and semantic views. If the connected user is different, reconnect before continuing.

## Task 3: Check telco semantic views

1. Run this SQL block.

    This query lists the Seer Comms views that the remaining labs use. Treat the list as your contract for the workshop vocabulary.

    ```sql
    <copy>
    SELECT view_name
    FROM user_views
    WHERE view_name LIKE 'SEER_COMMS%'
    ORDER BY view_name;
    </copy>
    ```

    **Expected output: Views used throughout the workshop**

    | View Name |
    | --- |
    | `SEER_COMMS_AGENT_ACTIONS_V` |
    | `SEER_COMMS_COVERAGE_ZONES_V` |
    | `SEER_COMMS_CUSTOMER_EXPERIENCE_V` |
    | `SEER_COMMS_DEMAND_FORECASTS_V` |
    | `SEER_COMMS_FIELD_DISPATCH_V` |
    | `SEER_COMMS_NETWORK_CAPACITY_V` |
    | `SEER_COMMS_NETWORK_SITES_V` |
    | `SEER_COMMS_SERVICE_LINES_V` |
    | `SEER_COMMS_SERVICE_ORDERS_V` |
    | `SEER_COMMS_SERVICES_V` |
    | `SEER_COMMS_SIGNAL_MATCHES_V` |
    | `SEER_COMMS_SUBSCRIBER_SIGNALS_V` |
    {: title="Views used throughout the workshop"}

These views give the remaining labs a consistent telecom vocabulary for services, subscribers, network capacity, dispatches, signals, and agent actions.

## Acknowledgements

- **Author** - Oracle LiveLabs Team
