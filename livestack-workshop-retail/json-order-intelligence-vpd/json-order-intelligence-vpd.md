# Unified Order Intelligence with JSON Duality and VPD

## Introduction

An ecommerce operations manager, customer service lead, order platform owner, or partner integration architect needs to understand an order from multiple angles. Retail teams often duplicate order headers, line items, customer data, fulfillment centers, shipment records, and API payloads across separate systems.

Oracle AI Database keeps the order record in one governed data platform while exposing it through the shape each workflow needs. Relational tables provide ACID transactions and operational SQL. JSON Relational Duality exposes the same order as an application-friendly document. In SQL Worksheet, you compare the JSON document view with relational rows and confirm that VPD access policy logic stays in the database.

Estimated Time: 10 minutes

### Objectives

- Query a JSON Relational Duality view.
- Use SQL/JSON to extract fields from the document view.
- Compare the document view with relational order tables.
- Verify VPD policies for orders and fulfillment centers.


## Task 1: Read an order as a JSON document
1. Review the related application screen before you run the SQL.

    ![Unified Order Intelligence order workspace](images/unified-order-intelligence-overview.png " ")

    *Figure 1: Unified Order Intelligence gives order operations a governed workspace for order, customer, and fulfillment context.*

2. Run this query.

    ```sql
    <copy>
    SELECT JSON_SERIALIZE(data RETURNING VARCHAR2(4000) PRETTY) AS "Order JSON"
    FROM RETAILDB.orders_dv
    FETCH FIRST 1 ROW ONLY;
    </copy>
    ```

    Expected output excerpt:

    | Order JSON |
    | --- |
    | `{ "_id" : 138, ...` |
    {: title="Sample Order JSON Document"}

3. SQL Worksheet may truncate a large JSON cell. If that happens, open the cell viewer or copy the cell value to inspect the full document.

## Task 2: Extract document fields with SQL/JSON

1. Run this query against the same duality view.

    ```sql
    <copy>
    SELECT jt.order_id AS "Order",
           jt.status AS "Status",
           jt.order_total AS "Total",
           jt.item_count AS "Items"
    FROM RETAILDB.orders_dv ov,
         JSON_TABLE(ov.data, '$'
           COLUMNS (
             order_id NUMBER PATH '$._id',
             status VARCHAR2(30) PATH '$.status',
             order_total NUMBER PATH '$.total',
             item_count NUMBER PATH '$.items.size()'
           )
         ) jt
    FETCH FIRST 1 ROW ONLY;
    </copy>
    ```

    Expected output:

    | Order | Status | Total | Items |
    | ---: | --- | ---: | ---: |
    | 138 | processing | 719.95 | 2 |
    {: title="Order Fields from JSON Duality"}

2. JSON Duality helps application developers read order detail as a document without giving up SQL, constraints, and ACID transactions.

## Task 3: Compare the document with relational rows
1. Use the live Unified Order Intelligence context from Figure 1 before you run the SQL.

2. Run this relational query for a sample order with line items.

    ```sql
    <copy>
    SELECT o.order_id AS "Order",
           o.order_status AS "Status",
           COUNT(oi.item_id) AS "Lines",
           ROUND(SUM(oi.line_total), 2) AS "Line Total",
           ROUND(MAX(o.order_total), 2) AS "Order Total"
    FROM RETAILDB.orders o
    JOIN RETAILDB.order_items oi ON oi.order_id = o.order_id
    WHERE o.order_id = (
      SELECT order_id FROM RETAILDB.order_items FETCH FIRST 1 ROW ONLY
    )
    GROUP BY o.order_id, o.order_status;
    </copy>
    ```

    Expected output:

    | Order | Status | Lines | Line Total | Order Total |
    | ---: | --- | ---: | ---: | ---: |
    | 1 | confirmed | 4 | 917.93 | 917.93 |
    {: title="Order Line Totals"}

3. The document view and relational tables describe the same kind of business event. Retail teams get API-friendly JSON and database teams retain trustworthy relational evidence.

## Task 4: Verify governed access policies

1. Run this VPD policy check.

    ```sql
    <copy>
    SELECT object_name AS "Table",
           policy_name AS "Policy",
           pf_owner || '.' || package || '.' || function AS "Policy Function"
    FROM all_policies
    WHERE object_owner = 'RETAILDB'
      AND policy_name IN ('VPD_ORDERS_REGION','VPD_FC_REGION')
    ORDER BY policy_name;
    </copy>
    ```

    Expected output:

    | Table | Policy | Policy Function |
    | --- | --- | --- |
    | `FULFILLMENT_CENTERS` | `VPD_FC_REGION` | `RETAILDB..VPD_FULFILLMENT_REGION` |
    | ORDERS | `VPD_ORDERS_REGION` | `RETAILDB..VPD_ORDERS_REGION` |
    {: title="VPD Policies for Retail Data"}

2. VPD keeps regional order and fulfillment data governed in the database. The application can switch users, but the policy logic remains close to the protected data.

3. Optional: if the workshop user owns the package, set a seeded admin context value.

    ```sql
    <copy>
    BEGIN
      RETAILDB.sc_security_ctx.set_user_context('admin_jess');
    END;
    /
    </copy>
    ```

    Expected output:

    | Result |
    | --- |
    | PL/SQL procedure successfully completed. |
    {: title="Security Context Procedure Result"}

## Acknowledgements

* **Author** - Oracle LiveLabs
* **Last Updated By/Date** - Oracle Database Product Management, May 2026
