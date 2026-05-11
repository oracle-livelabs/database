# Explore the financial services data foundation

## Introduction

The data foundation connects finance-friendly views to source-owned tables. You will inspect schema order, validate object counts, and use views that make the data easier to explain.

### Objectives

- Review the schema load order.
- Query finance-friendly views.
- Verify core table counts.
- Note setup items that need environment-specific values.

Estimated Time: 12 minutes

## Task 1: Review the schema order

1. Open `database-source/schema/` or the sanitized `source-schema/` folder.

    | Step | Script | Purpose |
    | ---: | --- | --- |
    | 1 | `00_setup.sql` | Create the `LIVESTACK` schema and grants |
    | 2 | `01_tables.sql` | Create core tables and indexes |
    | 3 | `02_json_collections.sql` | Add JSON objects and duality views |
    | 4 | `03_graph.sql` | Create the influencer graph |
    | 5 | `04_vector.sql` | Create vector search objects |
    | 6 | `05_spatial.sql` | Add locations and service routing |
    | 7 | `06_security.sql` | Add roles, context, VPD, and audit policy |
    | 8 | `07_ai_profile.sql` | Add optional AI profiles with your credentials |
    | 9 | `08_agents.sql` | Add optional agent tools and teams |
    | 10 | `10_fraud_graph.sql` | Add the fraud investigation graph |
    | 11 | `11_finance_views.sql` | Add finance-friendly reporting views |

## Task 2: Query the finance views

1. List the finance views.

    ```sql
    SELECT view_name
    FROM user_views
    WHERE view_name IN (
        'FINANCE_INSTITUTIONS_V', 'FINANCE_PRODUCTS_V',
        'RISK_SIGNALS_V', 'SIGNAL_SOURCES_V',
        'CLIENT_TRANSACTIONS_V', 'SERVICE_CENTERS_V',
        'SERVICE_CAPACITY_V', 'SERVICE_ROUTES_V'
    )
    ORDER BY view_name;
    ```

    Sample result:

    | VIEW_NAME |
    | --- |
    | CLIENT_TRANSACTIONS_V |
    | FINANCE_INSTITUTIONS_V |
    | FINANCE_PRODUCTS_V |
    | RISK_SIGNALS_V |
    | SERVICE_CAPACITY_V |
    | SERVICE_CENTERS_V |
    | SERVICE_ROUTES_V |
    | SIGNAL_SOURCES_V |

## Task 3: Verify the core footprint

1. Count rows in key tables.

    ```sql
    SELECT 'CUSTOMERS' AS object_name, COUNT(*) AS row_count FROM customers
    UNION ALL SELECT 'ORDERS', COUNT(*) FROM orders
    UNION ALL SELECT 'PRODUCTS', COUNT(*) FROM products
    UNION ALL SELECT 'SOCIAL_POSTS', COUNT(*) FROM social_posts
    UNION ALL SELECT 'FULFILLMENT_CENTERS', COUNT(*) FROM fulfillment_centers
    UNION ALL SELECT 'APP_USERS', COUNT(*) FROM app_users
    ORDER BY object_name;
    ```

    Sample result:

    | OBJECT_NAME | ROW_COUNT |
    | --- | ---: |
    | APP_USERS | 5 |
    | CUSTOMERS | 120 |
    | FULFILLMENT_CENTERS | 30 |
    | ORDERS | 300 |
    | PRODUCTS | 120 |
    | SOCIAL_POSTS | 250 |

## Task 4: Check your work

1. Confirm that you know which script creates finance views.

2. Confirm that optional AI setup depends on database packages and OCI access.

## Acknowledgements

* **Author** - Oracle LiveLabs
* **Last Updated By/Date** - Oracle LiveLabs, May 2026
