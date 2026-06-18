# Finance Data Foundation

## Introduction

This lab orients you to the current Seer Bank data foundation. You inspect finance semantic views, core data groups, vectors, graphs, spatial objects, OML models, and agent functions that the application uses across the rest of the workshop.

The point is to see the shape of the operating data before you start making decisions with it. Dashboard metrics, vector matches, graph paths, spatial distances, OML scores, copilot answers, and agent audit rows all connect back to this shared database foundation.

Think of this lab as the map for the rest of the journey. The same schema supports the risk dashboard, transaction API, semantic search, financial-crime graph, service coverage, prediction, governed answers, and agent action history.

Think of this lab as the readiness checkpoint before any business decision. The goal is to prove that the same schema can support the risk dashboard, transaction API, semantic search, financial-crime graph, service coverage, prediction, governed answers, and agent action history.

![Finance Data Foundation page](images/data-foundation.png " ")

### Objectives

- Review the finance semantic views.
- Check the scale of the current data.
- Map each application page to the Oracle Database 26ai capability that supports the related finance decision.

Estimated Time: **10 minutes**

### Operating Story

| Step | Finance focus |
| --- | --- |
| Business Problem | Risk, prediction, and agent workflows need a shared view of the finance data they use to make decisions. |
| Technical Challenge | Platform teams must show how the same schema supports semantic views, vectors, graphs, spatial data, OML models, and PL/SQL tools. |
| Persona Focus | Database developers and platform engineers map the foundation that business users rely on for downstream evidence. |
| What You Will Prove | The current Finance LiveStack application uses connected views and object families in one database schema. |
| Database Capability | Oracle catalog views and finance semantic views expose the governed object inventory. |
| Outcome | Every later lab can connect its result back to the same queryable finance foundation. |

Persona focus: You are the database developer showing how Seer Bank's shared foundation supports risk, operations, prediction, and AI workflows.

## Task 1: Inventory the finance object families

1. Run this inventory query to review the semantic views and database features used later in the workshop.

    ```sql
    <copy>
    SELECT 'Finance semantic views' AS "Area", COUNT(*) AS "Count"
    FROM user_views
    WHERE view_name IN (
      'FINANCE_INSTITUTIONS_V','FINANCE_PRODUCTS_V','RISK_SIGNALS_V',
      'SIGNAL_SOURCES_V','CLIENT_TRANSACTIONS_V','SERVICE_CENTERS_V',
      'SERVICE_CAPACITY_V','SERVICE_ROUTES_V'
    )
    UNION ALL
    SELECT 'Finance property graphs', COUNT(*)
    FROM user_property_graphs
    WHERE graph_name IN ('FRAUD_NETWORK','INFLUENCER_NETWORK')
    UNION ALL
    SELECT 'MiniLM vector columns', COUNT(*)
    FROM user_tab_cols
    WHERE data_type = 'VECTOR'
      AND table_name IN ('PRODUCT_EMBEDDINGS','SIGNAL_EMBEDDINGS')
    UNION ALL
    SELECT 'OML mining models', COUNT(*)
    FROM user_mining_models
    WHERE model_name IN (
      'DEMAND_SURGE_MODEL','CUSTOMER_SEGMENT_MODEL',
      'REVENUE_PREDICT_MODEL','PRODUCT_CLUSTER_MODEL'
    )
    UNION ALL
    SELECT 'Agent helper functions', COUNT(*)
    FROM user_objects
    WHERE object_type = 'FUNCTION'
      AND object_name IN (
        'DETECT_TRENDING_PRODUCTS','CHECK_PRODUCT_INVENTORY',
        'FIND_BEST_FULFILLMENT','GET_INFLUENCER_NETWORK','LOG_AGENT_DECISION'
      );
    </copy>
    ```

    **Expected output: Foundation Object Inventory**

    | Area | Count |
    | --- | --- |
    | Finance semantic views | 8 |
    | Finance property graphs | 2 |
    | MiniLM vector columns | 2 |
    | OML mining models | 4 |
    | Agent helper functions | 5 |


2. Review the counts.
    The query reads Oracle catalog views instead of application tables. That gives you a concise map of the object families behind the application workflow.

    The rows summarize the major capabilities used later: semantic views for governed SQL, property graphs for fraud reach, vector columns for semantic search, OML models for prediction, and helper functions for controlled agent actions.

    Treat this as the capability map for the workshop. Each row points to a different access pattern that will reappear in a later finance decision.

**Note:** Sample values may change after data refreshes or rebuilds. Focus on the expected result pattern and the business takeaway, not the exact values.    

## Task 2: Count the current finance data groups

Perform the following set of steps to count the current finance data groups and establish a baseline for later dashboard, search, graph, spatial, OML, and audit results:

1. Run this data group count query:

    ```sql
    <copy>
    SELECT 'Institutions' AS "Data Group", COUNT(*) AS "Rows" FROM finance_institutions_v
    UNION ALL SELECT 'Financial products', COUNT(*) FROM finance_products_v
    UNION ALL SELECT 'Risk signals', COUNT(*) FROM risk_signals_v
    UNION ALL SELECT 'Signal sources', COUNT(*) FROM signal_sources_v
    UNION ALL SELECT 'Client transactions', COUNT(*) FROM client_transactions_v
    UNION ALL SELECT 'Service centers', COUNT(*) FROM service_centers_v
    UNION ALL SELECT 'SLA zones', COUNT(*) FROM fulfillment_zones
    UNION ALL SELECT 'Demand regions', COUNT(*) FROM demand_regions
    UNION ALL SELECT 'Fraud entities', COUNT(*) FROM fraud_entities
    UNION ALL SELECT 'Fraud relationships', COUNT(*) FROM fraud_relationships;
    </copy>
    ```

    **Expected output: Finance Row Counts**

    | Data Group | Rows |
    | --- | --- |
    | Institutions | 50 |
    | Financial products | 79 |
    | Risk signals | 5000 |
    | Signal sources | 463 |
    | Client transactions | 3000 |
    | Service centers | 30 |
    | SLA zones | 120 |
    | Demand regions | 20 |
    | Fraud entities | 25 |
    | Fraud relationships | 35 |


2. Use the counts as the baseline for later labs.
    This query reads the business-facing finance views and core tables that later labs aggregate, search, traverse, score, or audit. It gives learners a concrete sense of the population behind the story before they inspect specific risk and operations results.

    These counts establish the scale of the finance scenario: products and institutions provide the business catalog, risk signals and transactions drive the dashboard, service centers and SLA zones support operations, and fraud entities plus relationships support the graph investigation.

    The exact number should not be the teaching point. Reframe this around interpretation: the baseline helps learners understand whether later results reflect data volume, filtering, or business logic.

**Note:** Sample values may change after data refreshes or rebuilds. Focus on the expected result pattern and the business takeaway, not the exact values.

## Acknowledgements

* **Author** - Pat Shepherd, Senior Principal Database Product Manager
* **Contributor** - Linda Foinding, Principal Database Product Manager
* **Last Updated By/Date** - Oracle Database Product Management, June 2026
