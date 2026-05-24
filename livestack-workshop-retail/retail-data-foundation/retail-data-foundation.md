# Retail Data Foundation

## Introduction

This lab starts the hands-on database work. You will inspect the schema that prepares the Seer Sporting Goods dataset for the rest of the LiveStack. The business point is simple: one governed Oracle Database 26ai schema can support products, customers, orders, inventory, returns data, creator signals, fulfillment geography, AI context, and audit evidence without spreading the workflow across disconnected stores.

In the LiveStack application, Data Foundation loads or restores the demo dataset and shows what gets loaded. In SQL Worksheet, you prove that the same foundation exists as database objects, views, graph metadata, vector artifacts, and PL/SQL tools.

Estimated Time: 10 minutes

### Objectives

- Confirm that the retail database objects are present.
- Inventory the object families used by later labs.
- Map the current retail application flow to Oracle Database 26ai capabilities.
- Query row counts that prove the workshop uses database data.


## Task 1: Inventory the retail object families
1. Review the related application screen before you run the SQL.

    ![Data Foundation page showing load controls and Oracle Internals](images/data-foundation-load-and-internals.png " ")

    *Figure 1: Data Foundation prepares the shared dataset and shows the Oracle capabilities behind the demo.*

2. In SQL Worksheet, run this query.

    Before you analyze retail outcomes, first prove that the shared data foundation exists. This query inventories the object families that later labs use for dashboards, search, graph, spatial, OML, Ask Data, and agent workflows.

    ```sql
    <copy>
    WITH schema_ctx AS (
      SELECT owner AS owner_name
      FROM (
        SELECT owner
        FROM all_tables
        WHERE table_name = 'ORDERS'
          AND owner IN (USER, 'LLUSER')
        ORDER BY CASE
                   WHEN owner = SYS_CONTEXT('USERENV','CURRENT_SCHEMA') THEN 1
                   WHEN owner = USER THEN 2
                   WHEN owner = 'LLUSER' THEN 3
                   ELSE 4
                 END
      )
      WHERE ROWNUM = 1
    )
    SELECT 'Core retail tables' AS "Area", COUNT(*) AS "Count"
    FROM all_tables t
    JOIN schema_ctx s ON s.owner_name = t.owner
    WHERE t.table_name IN (
        'BRANDS','PRODUCTS','FULFILLMENT_CENTERS','INVENTORY','CUSTOMERS',
        'ORDERS','ORDER_ITEMS','INFLUENCERS','SOCIAL_POSTS','POST_PRODUCT_MENTIONS',
        'DEMAND_FORECASTS','SHIPMENTS','AGENT_ACTIONS','APP_USERS','EVENT_STREAM',
        'PRODUCT_EMBEDDINGS','POST_EMBEDDINGS','SEMANTIC_MATCHES',
        'FULFILLMENT_ZONES','DEMAND_REGIONS','RETURN_REQUESTS','RETURN_DOCUMENTS'
      )
    UNION ALL
    SELECT 'Retail semantic views', COUNT(*)
    FROM all_views v
    JOIN schema_ctx s ON s.owner_name = v.owner
    WHERE v.view_name IN (
        'RETAIL_RETURNS_WORKFLOW_V','RETAIL_SIGNAL_PRODUCT_V',
        'RETAIL_ORDER_RETURN_V','RETAIL_FULFILLMENT_RISK_V','RETAIL_RETURN_WORKBENCH_V'
      )
    UNION ALL
    SELECT 'Creator influence property graph', COUNT(*)
    FROM all_property_graphs g
    JOIN schema_ctx s ON s.owner_name = g.owner
    WHERE g.graph_name = 'INFLUENCER_NETWORK'
    UNION ALL
    SELECT 'MiniLM vector artifacts', COUNT(*)
    FROM all_tab_cols c
    JOIN schema_ctx s ON s.owner_name = c.owner
    WHERE c.data_type = 'VECTOR'
      AND c.table_name IN ('PRODUCT_EMBEDDINGS','POST_EMBEDDINGS')
      AND c.column_name = 'EMBEDDING'
    UNION ALL
    SELECT 'Agent tool functions', COUNT(*)
    FROM all_objects o
    JOIN schema_ctx s ON s.owner_name = o.owner
    WHERE o.object_type = 'FUNCTION'
      AND o.object_name IN (
        'DETECT_TRENDING_PRODUCTS','CHECK_PRODUCT_INVENTORY',
        'FIND_BEST_FULFILLMENT','GET_INFLUENCER_NETWORK','LOG_AGENT_DECISION'
      );
    </copy>
    ```

    Expected output:

    | Area | Count |
    | --- | ---: |
    | Core retail tables | 22 |
    | Retail semantic views | 5 |
    | Creator influence property graph | 1 |
    | MiniLM vector artifacts | 2 |
    | Agent tool functions | 5 |
    {: title="Retail Object Inventory"}

3. The result confirms that the workshop has a retail data foundation, semantic views for natural-language grounding, a graph, MiniLM-backed vector artifacts, and PL/SQL tools.

## Task 2: Map retail outcomes to database features

1. Run this capability map.

    The workshop is not a list of random SQL examples. This map connects each retail business outcome to the Oracle Database feature that supports it, so you know what each later lab is proving.

    ```sql
    <copy>
    SELECT 'Retail command center' AS "Outcome",
           'Converged SQL over orders, inventory, returns, creators, and audit data' AS "DB Feature"
    FROM dual
        UNION ALL SELECT 'Unified order intelligence', 'JSON Relational Duality and SQL/JSON' FROM dual
    UNION ALL SELECT 'Governed regional access', 'Virtual Private Database policies' FROM dual
    UNION ALL SELECT 'Customer trend signals', 'AI Vector Search with MiniLM L12 v2 and VECTOR_DISTANCE' FROM dual
    UNION ALL SELECT 'Creator influence network', 'Property Graph and GRAPH_TABLE SQL/PGQ' FROM dual
    UNION ALL SELECT 'Intelligent fulfillment', 'Oracle Spatial SDO_GEOMETRY, GeoJSON, and distance analysis' FROM dual
    UNION ALL SELECT 'Retail OML analytics', 'DBMS_DATA_MINING models and SQL scoring functions' FROM dual
    UNION ALL SELECT 'Ask Retail Data', 'Semantic views and comments that expose governed business meaning' FROM dual
    UNION ALL SELECT 'Retail AI Agent Console', 'PL/SQL tools, JSON audit payloads, and agent action history' FROM dual;
    </copy>
    ```

    Expected output:

    | Outcome | DB Feature |
    | --- | --- |
    | Retail command center | Converged SQL over orders, inventory, returns, creators, and audit data |
    | Unified order intelligence | JSON Relational Duality and SQL/JSON |
    | Governed regional access | Virtual Private Database policies |
    | Customer trend signals | AI Vector Search with MiniLM L12 v2 and `VECTOR_DISTANCE` |
    | Creator influence network | Property Graph and `GRAPH_TABLE` SQL/PGQ |
    | Intelligent fulfillment | Oracle Spatial `SDO_GEOMETRY`, GeoJSON, and distance analysis |
    | Retail OML analytics | `DBMS_DATA_MINING` models and SQL scoring functions |
    | Ask Retail Data | Semantic views and comments that expose governed business meaning |
    | Retail AI Agent Console | PL/SQL tools, JSON audit payloads, and agent action history |
    {: title="Retail Outcomes and Database Features"}

2. This map is the mental model for the workshop. Each later lab uses SQL to prove how the database creates a visible retail outcome.

## Task 3: Count the retail data groups

1. Run this row-count query.

    Row counts prove that the exercises use a real seeded retail dataset, not static screenshots. They also give you a scale reference for later KPI, vector, graph, spatial, and OML results.

    ```sql
    <copy>
    SELECT 'Brands' AS "Data Group", COUNT(*) AS "Rows" FROM brands
    UNION ALL SELECT 'Products', COUNT(*) FROM products
    UNION ALL SELECT 'Customers', COUNT(*) FROM customers
    UNION ALL SELECT 'Orders', COUNT(*) FROM orders
    UNION ALL SELECT 'Social posts', COUNT(*) FROM social_posts
    UNION ALL SELECT 'Return requests', COUNT(*) FROM return_requests
    UNION ALL SELECT 'Return evidence documents', COUNT(*) FROM return_documents
    UNION ALL SELECT 'Agent audit actions', COUNT(*) FROM agent_actions;
    </copy>
    ```

    Expected output:

    | Data Group | Rows |
    | --- | ---: |
    | Brands | 50 |
    | Products | 187 |
    | Customers | 2000 |
    | Orders | 3000 |
    | Social posts | 5000 |
    | Return requests | 5 |
    | Return evidence documents | 7 |
    | Agent audit actions | 0 |
    {: title="Retail Data Row Counts"}

2. The counts show that the workshop schema is closely aligned with the data foundation used by the LiveStack demo application.

## Acknowledgements

* **Author** - Pat Shepherd, Senior Principal Database Product Manager
* **Last Updated By/Date** - Oracle Database Product Management, May 2026
