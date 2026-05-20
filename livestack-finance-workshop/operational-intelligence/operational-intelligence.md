# Query dashboard and operational intelligence

## Introduction

The dashboard shows finance operations as metrics and charts. You will map dashboard calls to SQL that aggregates transactions, products, risk signals, and capacity.

### Objectives

- Map dashboard routes to SQL behavior.
- Query transaction and revenue metrics.
- Inspect product JSON detail.
- Note where In-Memory checks may fall back to metadata.

Estimated Time: 12 minutes

## Task 1: Map dashboard routes

1. Open `api-map.md` and find the dashboard routes.

    | Route | Database-backed behavior |
    | --- | --- |
    | `/api/dashboard/summary` | Counts orders, signals, actions, and active work |
    | `/api/dashboard/revenue-by-category` | Aggregates revenue by product category |
    | `/api/dashboard/social-velocity` | Tracks signal velocity over time |
    | `/api/dashboard/demand-map` | Supports spatial demand visualization |
    | `/api/dashboard/inmemory` | Checks In-Memory visibility or table metadata |

## Task 2: Query dashboard metrics

1. Run a summary query.

    ```sql
    SELECT
        (SELECT COUNT(*) FROM orders) AS transaction_count,
        (SELECT NVL(SUM(order_total), 0) FROM orders) AS exposure_total,
        (SELECT COUNT(*) FROM social_posts WHERE momentum_flag IN ('viral','mega_viral')) AS elevated_signals,
        (SELECT COUNT(*) FROM agent_actions) AS agent_actions_total
    FROM dual;
    ```

    Sample result:

    | TRANSACTION_COUNT | EXPOSURE_TOTAL | ELEVATED_SIGNALS | AGENT_ACTIONS_TOTAL |
    | ---: | ---: | ---: | ---: |
    | 300 | 1842500 | 42 | 18 |

## Task 3: Inspect JSON product detail

1. Query the product inventory duality view.

    ```sql
    SELECT JSON_SERIALIZE(data PRETTY) AS product_document
    FROM products_inventory_dv
    FETCH FIRST 2 ROWS ONLY;
    ```

    Sample result:

    | PRODUCT_DOCUMENT |
    | --- |
    | `{ "product_id" : 17, "product_name" : "Treasury Sweep Account", "inventory" : [ ... ] }` |

## Task 4: Check your work

1. Confirm that you can map dashboard cards to SQL aggregates.

2. Confirm that JSON duality returns app-friendly documents over relational data.

## Acknowledgements

* **Author** - Oracle LiveLabs
* **Last Updated By/Date** - Oracle LiveLabs, May 2026
