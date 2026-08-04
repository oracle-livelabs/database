# Data Foundation

## Introduction

Seer Comms needs one trustworthy map of the evidence behind a network-experience escalation. A high-impact congestion event can affect thousands of subscribers, place recurring revenue at risk, and force operations, service-order, and field teams to coordinate before the next peak window. You are the database developer who gives those teams a common starting point. In this lab, you inspect the Telco objects used later, so every later result has a clear home, owner, and meaning.

![Before-and-after Telco data architecture](images/telco-converged-foundation.svg " ")

The diagram contrasts a fragmented data estate with the connected foundation used here. Notice that the same operational facts can support relational SQL, JSON documents, semantic matches, graph relationships, and spatial distance without creating separate copies.

### Objectives

- Inventory the core Telco tables and database capabilities.
- Confirm the JSON, vector, graph, and spatial objects used later.

Estimated Time: **10 minutes**

### Business Scenario

| Step | Telco focus |
| --- | --- |
| Business Problem | Operations teams need one trustworthy evidence foundation. |
| Technical Challenge | Disconnected stores create copies and conflicting definitions. |
| Persona Focus | You are a database developer supporting network operations. |
| What You Will Do | Inspect the fixed object families behind the application. |
| Database Capability | Oracle catalog views and a converged database. |
| Outcome | Later decisions can be traced to governed data. |

<details>
<summary><strong>Key terms: evidence table, catalog view, UNION ALL, and converged database</strong></summary>

> - An **evidence table** stores the facts a team needs to review. In this workshop, `NETWORK_SITES`, `SUBSCRIBER_SIGNALS`, and `SERVICE_ORDERS` keep the location, customer-language, and order facts that explain a network response. Keeping those facts in Oracle means later SQL, JSON, vector, graph, and spatial work starts from the same governed source.
>
> - A **catalog view** is Oracle's built-in inventory of database objects. You use catalog views in this lab to see what is available before you build an application query or investigate an incident.
>
> - **UNION ALL** stacks the rows returned by separate `SELECT` statements into one result. Here, each `SELECT` answers one readiness question, and `UNION ALL` preserves every answer so you can read one capability checklist.
>
> - A **converged database** keeps relational, JSON, vector, graph, spatial, and machine-learning evidence connected. That reduces data copies, avoids reconciliation work, and lets Seer Comms use one security and governance model when a capacity decision must be explained.
</details>

## Task 1: Inventory the evidence layer

1. Run the inventory query.

    > **SQL Worksheet reminder:** Need a reminder on how to open and use the SQL Worksheet? Return to [Getting Started Task 2: Open SQL Worksheet](?lab=getting-started#Task2:OpenSQLWorksheet) for the step-by-step graphic showing where to paste and run SQL statements.

    In order to understand this query, read it in six short parts.

    1. The first `SELECT` counts the core Telco tables that store operational facts.
    2. The next four `SELECT` statements count the JSON duality view, property graph, vector columns, and spatial layers used by later labs.
    3. The final `SELECT` counts the Oracle Machine Learning model used for predictive service assurance.
    4. `UNION ALL` stacks those separate counts into one capability checklist without removing any result rows.

    The tables hold Telco facts; the duality view, graph, vectors, spatial metadata, and model add specialized evidence without moving those facts elsewhere.

    ```sql
    <copy>
    SELECT 'Core Telco tables' AS "Area", COUNT(*) AS "Count"
    FROM user_tables
    WHERE table_name IN ('SERVICE_LINES','TELECOM_SERVICES','NETWORK_SITES','NETWORK_CAPACITY','SUBSCRIBERS','SUBSCRIBER_SIGNALS','SERVICE_ORDERS')
    UNION ALL SELECT 'JSON duality views', COUNT(*) FROM user_json_duality_views WHERE view_name = 'ORDERS_DV'
    UNION ALL SELECT 'Property graphs', COUNT(*) FROM user_property_graphs WHERE graph_name = 'TELECOM_EXPERIENCE_NETWORK'
    UNION ALL SELECT 'Vector columns', COUNT(*) FROM user_tab_cols WHERE data_type = 'VECTOR' AND table_name IN ('SERVICE_EMBEDDINGS','SIGNAL_EMBEDDINGS')
    UNION ALL SELECT 'Spatial layers', COUNT(*) FROM user_sdo_geom_metadata WHERE table_name IN ('NETWORK_SITES','SUBSCRIBERS')
    UNION ALL SELECT 'OML models', COUNT(*) FROM user_mining_models WHERE model_name = 'NETWORK_CAPACITY_SURGE_MODEL';
    </copy>
    ```

    **Expected output: Object Inventory**

    | Area | Count |
    | --- | --- |
    | Core Telco tables | 7 |
    | JSON duality views | 1 |
    | Property graphs | 1 |
    | Vector columns | 2 |
    | Spatial layers | 2 |
    | OML models | 1 |

    Read the five rows as a capability map for the labs ahead. Each row names one object family that stays with the same Telco facts instead of moving to a separate system.

## Task 2: Count the fixed Telco evidence

1. Run the row-count query.

    This query establishes the scale used throughout the workshop. Each returned count is fixed by the deterministic handoff loader and represents a national Telco scenario, rather than a toy set of four locations. Look for broad site coverage, enough subscriber signals to support semantic search, and enough orders to show that application documents and relational analytics use the same foundation.

    ```sql
    <copy>
    SELECT 'Telecom services' AS "Evidence", COUNT(*) AS "Rows" FROM telecom_services
    UNION ALL SELECT 'Network sites', COUNT(*) FROM network_sites
    UNION ALL SELECT 'Subscribers', COUNT(*) FROM subscribers
    UNION ALL SELECT 'Subscriber signals', COUNT(*) FROM subscriber_signals
    UNION ALL SELECT 'Service orders', COUNT(*) FROM service_orders
    UNION ALL SELECT 'Graph entities', COUNT(*) FROM telecom_graph_entities;
    </copy>
    ```

    **Expected output: Data Row Counts**

    | Evidence | Rows |
    | --- | --- |
    | Telecom services | 8 |
    | Network sites | 54 |
    | Subscribers | 56 |
    | Subscriber signals | 62 |
    | Service orders | 58 |
    | Graph entities | 62 |

    Read these counts as the scale of the Seer Comms scenario, not as a generic object checklist. The next lab uses the `NETWORK_SITES` rows to turn this foundation into an operations priority.

## Acknowledgements

* **Author** - Pat Shepherd, Senior Principal Database Product Manager
* **Last Updated By/Date** - Pat Shepherd, July 2026
