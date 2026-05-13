# Inspect transactions as rows and JSON documents

## Introduction

The Client Transactions & Cases page needs both relational control and document-shaped payloads. You will query transactions, JSON duality views, and VPD context objects.

### Objectives

- Query client transaction records.
- Read JSON duality output.
- Set demo user context for VPD-aware behavior.
- Trace orders routes to database objects.

Estimated Time: 10 minutes

## Task 1: Map order routes

1. Find order routes in `api-map.md`.

    | Route | Purpose |
    | --- | --- |
    | `/api/orders` | Returns transaction list data |
    | `/api/orders/:id` | Returns transaction detail |
    | `/api/orders/:id/duality` | Returns JSON duality output |

## Task 2: Query client transactions

1. Query the finance transaction view.

    ```sql
    SELECT transaction_id,
           client_name,
           product_name,
           transaction_status,
           transaction_total
    FROM client_transactions_v
    ORDER BY transaction_total DESC
    FETCH FIRST 10 ROWS ONLY;
    ```

## Task 3: Read JSON duality output

1. Query order documents.

    ```sql
    SELECT JSON_SERIALIZE(data PRETTY) AS order_document
    FROM orders_dv
    FETCH FIRST 2 ROWS ONLY;
    ```

## Task 4: Set demo user context

1. Set a user context for a role-aware query.

    ```sql
    BEGIN
        sc_security_ctx.set_user_context('fulfillment_west');
    END;
    /
    ```

## Task 5: Check your work

1. Confirm that VPD context comes from `sc_security_ctx`.

2. Confirm that transaction routes use Express plus Oracle SQL.

## Acknowledgements

* **Author** - Oracle LiveLabs
* **Last Updated By/Date** - Oracle LiveLabs, May 2026
