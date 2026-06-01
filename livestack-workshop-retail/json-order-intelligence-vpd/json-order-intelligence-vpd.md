# Unified Order Intelligence with JSON Duality and VPD

## Introduction

Order data serves many audiences. Application teams need document-shaped access, operations teams need relational detail, and security teams need governed access rules. In this lab, learners compare those views of the same order and verify that access control stays inside the database.Oracle AI Database keeps the order record in one place while exposing it through the shape each workflow needs. Relational tables provide ACID transactions and operational SQL.

**JSON Relational Duality** exposes the same order as an application-friendly document. Simply put, **JSON Relational Duality** as one governed order record supporting two shapes: relational tables for operations and document-style JSON for applications or APIs.

**Virtual Private Database**, or **VPD**, adds row-level security by applying database policy logic to protected tables. It is essentially a database-enforced row-level access control, so learners understand how governed order visibility stays close to the data.

In SQL Worksheet, you compare the JSON document view with relational rows and confirm that the access policy stays in the database.

Estimated Time: **10 minutes**

### Objectives

- Query a JSON Relational Duality view.
- Use SQL/JSON to extract fields from the document view.
- Compare the document view with relational order tables.
- Verify VPD policies for orders and fulfillment centers.


## Task 1: Read an order as a JSON document

Doing this shows how application teams can consume order-shaped data while the database preserves the governed source tables.

1. Review the related application screen before you run the SQL.

    ![Unified Order Intelligence order workspace](images/unified-order-intelligence-overview.png " ")

    *Figure 1: Unified Order Intelligence gives order operations a governed workspace for order, customer, and fulfillment context.*

    ![Order table and detail region from the runbook](images/order-table-detail.png " ")

    *Figure 2: The order workspace lets the user inspect relational order detail before comparing it with JSON.*

2. Run this query.

    Application teams often want an order as a JSON document, while database teams need governed relational data. A **JSON Relational Duality view** lets both needs use the same source tables. This block reads `ORDERS_DV`, then uses `JSON_SERIALIZE` to display the JSON document in SQL Worksheet. `JSON_VALUE` in the `ORDER BY` reads the document `_id` value so the output is stable.

    ```sql
    <copy>
    SELECT JSON_SERIALIZE(data RETURNING VARCHAR2(4000) PRETTY) AS "Order JSON"
    FROM orders_dv
    ORDER BY JSON_VALUE(data, '$._id' RETURNING NUMBER)
    FETCH FIRST 1 ROW ONLY;
    </copy>
    ```

3. SQL Worksheet may truncate the JSON value in the result grid. Click the eyeball icon at the right edge of the `ORDER JSON` cell to expand the value and inspect the full payload before you compare it with the excerpt.

    ![SQL Worksheet eyeball icon for expanding JSON payloads](images/sql-worksheet-json-eyeball-expand.svg " ")

    *Figure 2: Use the eyeball icon in Query Result to open the full JSON document returned by the duality view.*

4. Confirm that the expanded payload starts with the fixed order document shown here. Seeing the full payload helps you connect the document shape to what an application would receive from the same governed order data.

    Expected output excerpt:

    ```json
    {
      "_id" : 1,
      "_metadata" : { ... },
      "customerId" : 1668,
      "status" : "confirmed",
      "total" : 1139.93,
      "shippingCost" : 7.99,
      "demandScore" : 86.48,
      "createdAt" : "2026-03-17T09:17:57",
      "items" : [ ... ]
    }
    ```

**Note:** These are sample values from the current workshop dataset and may change after a refresh, seed update, or schema rebuild. Treat these values as an example of the current workshop result. Verify the live output before presenting, then explain the business takeaway: what the values reveal about retail scale, demand, revenue, inventory, fulfillment, order governance, prediction, or agent activity.

## Task 2: Extract document fields with SQL/JSON

Perform the following set of steps to show that document data can still be filtered, sorted, counted, and compared with SQL.

1. Run this query against the same duality view.

    JSON does not have to be a black box. `JSON_TABLE` turns values inside a JSON document into relational columns that SQL can filter, sort, and join. In this block, each `PATH` expression points to a field in the order document. The `$.items.size()` expression counts array elements, so you can see the number of order lines without leaving SQL.

    ```sql
    <copy>
    SELECT jt.order_id AS "Order",
           jt.status AS "Status",
           jt.order_total AS "Total",
           jt.item_count AS "Items"
    FROM orders_dv ov,
         JSON_TABLE(ov.data, '$'
           COLUMNS (
             order_id NUMBER PATH '$._id',
             status VARCHAR2(30) PATH '$.status',
             order_total NUMBER PATH '$.total',
             item_count NUMBER PATH '$.items.size()'
           )
         ) jt
    WHERE jt.order_id = 138;
    </copy>
    ```

    Expected output:

    | Order | Status | Total | Items |
    | ---: | --- | ---: | ---: |
    | 138 | processing | 169.96 | 2 |
    {: title="Order JSON Fields"}

2. JSON Duality helps application developers read order detail as a document without giving up SQL, constraints, and ACID transactions.

**Note:** These are sample values from the current workshop dataset and may change after a refresh, seed update, or schema rebuild. Treat these values as an example of the current workshop result. Verify the live output before presenting, then explain the business takeaway: what the values reveal about retail scale, demand, revenue, inventory, fulfillment, order governance, prediction, or agent activity.

## Task 3: Compare the document with relational rows

Perform the following set of steps to prove that the JSON view and the relational tables describe the same governed order.

1. Use the live Unified Order Intelligence context from Figure 1 before you run the SQL.

2. Run this relational query for order 1, the same fixed order used in the document example.

    Comparing the relational rows with the document output shows how both views describe the same business order. The PL/SQL block first sets a seeded security context so the fixed order is visible under the workshop VPD policy. The SQL then joins the order header to its line items and aggregates the line totals. The matching totals show that the document view and relational rows stay aligned.

    ```sql
    <copy>
    BEGIN
      sc_security_ctx.set_user_context('admin_jess');
    END;
    /

    SELECT o.order_id AS "Order",
           o.order_status AS "Status",
           COUNT(oi.item_id) AS "Lines",
           ROUND(SUM(oi.line_total), 2) AS "Line Total",
           ROUND(MAX(o.order_total), 2) AS "Order Total"
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.order_id = 1
    GROUP BY o.order_id, o.order_status;
    </copy>
    ```

    Expected output:

    | Order | Status | Lines | Line Total | Order Total |
    | ---: | --- | ---: | ---: | ---: |
    | 1 | confirmed | 4 | 1139.93 | 1139.93 |
    {: title="Order Totals"}

3. The document view and relational tables describe the same kind of business event. Retail teams get API-friendly JSON and database teams retain trustworthy relational evidence.

**Note:** These are sample values from the current workshop dataset and may change after a refresh, seed update, or schema rebuild. Treat these values as an example of the current workshop result. Verify the live output before presenting, then explain the business takeaway: what the values reveal about retail scale, demand, revenue, inventory, fulfillment, order governance, prediction, or agent activity.

## Task 4: Verify governed access policies

Perform the following set of steps to show that order and fulfillment visibility can be controlled in the database, not only in the application layer.

1. Run this **VPD** policy component check.

    Order and fulfillment data can be region-sensitive. VPD protects that data by attaching a policy to a table or view. The policy calls a PL/SQL function that returns a predicate, which Oracle applies to SQL automatically. This block creates a small expected list, checks the policy attachments in `ALL_POLICIES`, checks the policy functions in `USER_OBJECTS`, and returns `Ready` when both parts are present.

    ```sql
    <copy>
    WITH expected_policies AS (
      SELECT 'FULFILLMENT_CENTERS' AS table_name,
             'VPD_FC_REGION' AS policy_name,
             'VPD_FULFILLMENT_REGION' AS policy_function
      FROM dual
      UNION ALL
      SELECT 'ORDERS',
             'VPD_ORDERS_REGION',
             'VPD_ORDERS_REGION'
      FROM dual
    )
    SELECT e.table_name AS "Table",
           e.policy_name AS "Policy",
           SYS_CONTEXT('USERENV','CURRENT_SCHEMA') || '.' || e.policy_function AS "Policy Function",
           CASE
             WHEN p.policy_name IS NOT NULL AND f.status = 'VALID' THEN 'Ready'
             ELSE 'Check setup'
           END AS "Status"
    FROM expected_policies e
    LEFT JOIN all_policies p
      ON p.object_owner = SYS_CONTEXT('USERENV','CURRENT_SCHEMA')
     AND p.object_name = e.table_name
     AND p.policy_name = e.policy_name
     AND p.pf_owner = SYS_CONTEXT('USERENV','CURRENT_SCHEMA')
     AND p.function = e.policy_function
    LEFT JOIN user_objects f
      ON f.object_name = e.policy_function
     AND f.object_type = 'FUNCTION'
    ORDER BY e.policy_name;
    </copy>
    ```

    Expected output:

    | Table | Policy | Policy Function | Status |
    | --- | --- | --- | --- |
    | `FULFILLMENT_CENTERS` | `VPD_FC_REGION` | `LLUSER.VPD_FULFILLMENT_REGION` | Ready |
    | `ORDERS` | `VPD_ORDERS_REGION` | `LLUSER.VPD_ORDERS_REGION` | Ready |
    {: title="VPD Components"}

2. VPD keeps regional order and fulfillment data governed in the database. The application can switch users, but the policy logic remains close to the protected data.

3. Optional: if the workshop user owns the package, set a seeded admin context value.

    VPD policies often depend on session context, such as the current user role or region. A session context is a set of database values attached to your current connection. This optional PL/SQL block calls the workshop security package to set that context before policy-protected queries run. The application can switch context while the SQL remains unchanged.

    ```sql
    <copy>
    BEGIN
      sc_security_ctx.set_user_context('admin_jess');
    END;
    /
    </copy>
    ```

    Expected output:

    | Check | Result |
    | --- | --- |
    | Security context call | PL/SQL procedure successfully completed. |
    {: title="Security Context"}

**Note:** These are sample values from the current workshop dataset and may change after a refresh, seed update, or schema rebuild. Treat these values as an example of the current workshop result. Verify the live output before presenting, then explain the business takeaway: what the values reveal about retail scale, demand, revenue, inventory, fulfillment, order governance, prediction, or agent activity.

## Acknowledgements

* **Author** - Pat Shepherd, Senior Principal Database Product Manager
* **Contributor** - Linda Foinding, Principal Database Product Manager
* **Last Updated By/Date** - Oracle Database Product Management, May 2026
