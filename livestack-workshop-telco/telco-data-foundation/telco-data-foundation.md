# Lab 1: Telecom Data Foundation

## Introduction

The Seer Comms data foundation gives every later lab a reliable starting point. Before network, care, field, or retention teams can act, the platform team must prove that the key evidence is present. Services, subscriber signals, service orders, network sites, forecasts, graph entities, embeddings, and audit rows all live in one schema.

Estimated Time: 10 minutes

| Operating Story | Detail |
| --- | --- |
| Business Problem | Teams need one trusted operating picture before responding to service pressure. |
| Technical Challenge | The data foundation must combine transactional, JSON, vector, graph, spatial, ML, and audit objects without copying data into disconnected stores. |
| Persona Focus | Platform engineer and database developer. |
| What You Will Learn | The schema contains the telecom domains and Oracle feature objects needed for the full operating loop. |
| Database Capability | Relational SQL, semantic views, Oracle data dictionary, VECTOR columns, JSON Duality, Spatial, Property Graph. |
| Outcome | Learners can trust the following labs because the schema has a visible governed foundation. |
{: title="What this lab covers"}

**Persona focus:** You are the platform engineer confirming that the operating story starts from a complete Oracle data foundation, not disconnected data extracts.

### Objectives

- Count core telco domains.
- Inspect semantic views that express the data in Seer Comms operating language.
- Verify feature-specific database objects.


The image below is the data foundation view. It gives a platform engineer a quick read on whether the data domains behind the telecom workflow are present before anyone trusts the downstream analysis.

![Data foundation overview](images/data-foundation-overview.png)

## How This Lab Fits the Story

You prove that the telecom data foundation is complete enough to support real operating questions. The counts show breadth. The object checks show capability. Together, they explain why later labs can move from dashboards to vector search, graph, spatial analysis, JSON documents, prediction, and audit history without switching databases.

## Scene Evidence

The image below shows the record-count checkpoint from the application. The SQL in this lab recreates that evidence so you can see how the screen is grounded in governed database rows.

![Data foundation record counts](images/data-foundation-record-counts.png)

## Task 1: Count the operating domains

1. Run this SQL block.

    This query counts the major domains that power the rest of the workshop. Each `UNION ALL` branch checks one telecom area, such as services, subscriber signals, service orders, sites, forecasts, and agent actions. Look for all domains to return rows, because missing domains would break later operating decisions.

    ```sql
    <copy>
    SELECT 'Telecom services' AS domain, COUNT(*) AS records FROM seer_comms_services_v
    UNION ALL SELECT 'Subscriber signals', COUNT(*) FROM seer_comms_subscriber_signals_v
    UNION ALL SELECT 'Service orders', COUNT(*) FROM seer_comms_service_orders_v
    UNION ALL SELECT 'Network sites', COUNT(*) FROM seer_comms_network_sites_v
    UNION ALL SELECT 'Demand forecasts', COUNT(*) FROM seer_comms_demand_forecasts_v
    UNION ALL SELECT 'AI-assisted actions', COUNT(*) FROM seer_comms_agent_actions_v
    ORDER BY domain;
    </copy>
    ```

    **Expected output: Seeded telecom data volumes**

    | Domain | Records |
    | --- | ---: |
    | AI-assisted actions | 25 |
    | Demand forecasts | 360 |
    | Network sites | 12 |
    | Service orders | 3000 |
    | Subscriber signals | 5000 |
    | Telecom services | 32 |
    {: title="Seeded telecom data volumes"}

The counts are a quick health check. You are confirming that this is not a single-table exercise: the same schema carries the service, subscriber, order, network, forecast, and agent data needed for the full operating loop. Keeping these domains together reduces reconciliation work when teams move from awareness to action.


## Task 2: Inspect telecom semantic views

1. Run this SQL block.

    This query reads `USER_VIEWS` to list the Seer Comms semantic views. The `LIKE 'SEER_COMMS%'` filter keeps the result focused on learner-facing telecom views. Look for service, signal, order, and capacity views, because those names become the stable vocabulary for later SQL.

    ```sql
    <copy>
    SELECT view_name
    FROM user_views
    WHERE view_name LIKE 'SEER_COMMS%'
    ORDER BY view_name;
    </copy>
    ```

    **Expected output: Core views for learner queries**

    | View Name |
    | --- |
    | `SEER_COMMS_AGENT_ACTIONS_V` |
    | `SEER_COMMS_NETWORK_CAPACITY_V` |
    | `SEER_COMMS_SERVICE_ORDERS_V` |
    | `SEER_COMMS_SERVICES_V` |
    | `SEER_COMMS_SUBSCRIBER_SIGNALS_V` |
    {: title="Core views for learner queries"}

Your output may include additional Seer Comms views. The important point is the naming pattern: SQL users can work in telecom language, such as service lines, subscriber signals, network capacity, and field dispatches, instead of decoding raw table names.

## Task 3: Verify Oracle feature objects

1. Run this SQL block.

    This query reads `USER_OBJECTS` for the feature objects used across the labs. The `IN` list highlights JSON Duality views, graph objects, vector tables, spatial tables, and audit tables. Look for multiple object types, because the point is a converged foundation rather than a single reporting table.

    ```sql
    <copy>
    SELECT object_type, object_name
    FROM user_objects
    WHERE object_name IN (
      'ORDERS_DV', 'PRODUCTS_INVENTORY_DV', 'TELECOM_EXPERIENCE_NETWORK',
      'PRODUCT_EMBEDDINGS', 'POST_EMBEDDINGS', 'FULFILLMENT_ZONES',
      'DEMAND_REGIONS', 'AGENT_ACTIONS'
    )
    ORDER BY object_type, object_name;
    </copy>
    ```

    **Expected output: Oracle objects behind the workshop**

    | Object Type | Object Name |
    | --- | --- |
    | JSON RELATIONAL DUALITY VIEW | `ORDERS_DV` |
    | JSON RELATIONAL DUALITY VIEW | `PRODUCTS_INVENTORY_DV` |
    | PROPERTY GRAPH | `TELECOM_EXPERIENCE_NETWORK` |
    | TABLE | `AGENT_ACTIONS` |
    | TABLE | `DEMAND_REGIONS` |
    | TABLE | `FULFILLMENT_ZONES` |
    | TABLE | `POST_EMBEDDINGS` |
    | TABLE | `PRODUCT_EMBEDDINGS` |
    {: title="Oracle objects behind the workshop"}

These objects show why the database is more than a place to store rows. The same Oracle environment holds document views, graph objects, vector artifacts, spatial tables, and audit records that later labs use to answer telecom operations questions.


## Learn More

- [Oracle Database 26ai documentation](https://docs.oracle.com/en/database/oracle/oracle-database/26/)

## Acknowledgements

- **Author** - Oracle LiveLabs Team
