# Transaction and Case Documents with JSON Relational Duality

## Introduction

Applications often need transaction data as a clean JSON document, while analysts still need the same data in relational form for filtering, joining, and investigation. This lab uses **JSON Relational Duality** to satisfy both needs from the same data.

Think of this as one transaction wearing two useful forms. The application gets an API-friendly document. Analysts and database developers still get governed SQL access to the underlying facts.

This matters after the dashboard lab because a KPI is not enough for review. When an analyst or application needs a specific transaction, the database can return an API-shaped document and still preserve the relational joins needed for investigation.

<details>
<summary><strong>Key terms: JSON, relational tables, JSON Relational Duality, duality view, and projection</strong></summary>

> - **JSON** is a document format that application developers often prefer for APIs because it can represent a complete business object in one payload. A transaction document can hold the transaction ID, status, customer ID, totals, and line items together, which makes it natural for web and mobile applications to request, send, and display. JSON is flexible and developer-friendly, but by itself it is not as strong as a relational model for analytics, joining across many entities, enforcing shared business rules, or asking governed SQL questions across large data sets.
>
> - **Relational tables** store data in rows and columns with defined keys, relationships, constraints, and data types. That structure is excellent for analytics because SQL can filter, aggregate, join customers to transactions, enforce data quality rules, and answer questions such as which customers, products, or cases are driving risk. Relational data is less convenient as a direct application payload than JSON, but it is much stronger for governed analysis and operational reporting.
>
> - **JSON Relational Duality** lets Oracle Database expose relational data as JSON documents without copying it into a separate document database. The application gets the document shape developers want for APIs, while analysts keep SQL access to governed relational data. That matters because the API document and the analytic rows stay synchronized as two views of the same source.
>
> - **Duality view**, often shortened to **DV**, is the database object that defines that document shape. A duality view is created with `CREATE JSON RELATIONAL DUALITY VIEW`. The definition maps relational tables and columns into a JSON structure, so the database knows how to present the same rows as a document. In this lab, `ORDERS_DV` maps transaction rows from `ORDERS` and nested line-item rows from `ORDER_ITEMS` into one transaction document.
>
> - **Projection** means presenting the same centralized data in the shape a user, application, or service needs. Oracle Database can store governed data once, then let different consumers access it as relational rows, JSON documents, spatial objects, graph relationships, vectors, or model-ready columns without extracting or synchronizing separate copies. In this lab, SQL/JSON projection means taking fields from a JSON transaction document, such as transaction ID and status, and returning them as normal SQL columns that analysts can filter, sort, and join. The same transaction data can serve an application-friendly JSON API and an analyst-friendly SQL result without moving the data into a separate document store.

</details>

The image below shows the Transaction and Case Operations page in its API document view. The application can show the same transaction as a nested JSON document for API and partner integration use cases, while operations teams still rely on relational transaction, client, product, case, and service data. In this lab, you query the duality view behind that screen to see why developers can get a JSON payload without giving up relational analytics.

![Transaction API Document View](images/transaction-json-duality.png " ")

### Objectives

- Read application-friendly transaction documents from a duality view.
- Turn an update-only duality view into an insert-and-update document API.
- Create and update a JSON transaction, then inspect its relational rows.
- Explain why JSON Relational Duality avoids a separate document copy.
- Use SQL/JSON projection to return document fields as SQL columns for investigation.

Estimated Time: **15 minutes**

### Business Scenario

| Step | Finance focus |
| --- | --- |
| Business Problem | Application teams want document-shaped transaction data, while risk teams need relational controls. |
| Technical Challenge | Developers need API-friendly JSON without copying transaction records into a separate document store. |
| Persona Focus | Application developers serve document payloads while database developers preserve relational governance and SQL access. |
| What You Will See | JSON Relational Duality exposes transaction documents without duplicating data. |
| Database Capability | Duality views and SQL/JSON functions expose JSON and relational access together. |
| Outcome | Transaction operations can serve application and analytics needs from one source. |

Persona focus: You are the application/database developer showing how Seer Bank can expose transaction documents while keeping governed relational evidence intact.

### What Is a Duality View?

A JSON Relational Duality View is a database view that defines how relational tables should appear as a JSON document. The data still lives in relational tables, with keys, constraints, SQL access, and governance. The duality view adds a document access path over that same data.

For this lab, the workshop database already includes `ORDERS_DV`. The duality view maps relational columns into a document shape like this:

| JSON field | Relational source |
| --- | --- |
| `_id` | `ORDERS.ORDER_ID` |
| `customerId` | `ORDERS.CUSTOMER_ID` |
| `status` | `ORDERS.ORDER_STATUS` |
| `items[]` | Related rows from `ORDER_ITEMS` |

That mapping tells Oracle Database how to present an order row and its related line-item rows as one JSON transaction document. The application can read a transaction in the shape developers prefer for APIs, while analysts can still query the underlying rows with SQL.

This is better than common alternatives because it avoids splitting ownership of the same transaction across systems. If teams hand-build JSON in every application service, each service can drift into its own version of the transaction shape. If teams copy transactions into a separate document database, they must synchronize data, duplicate security rules, and resolve conflicts when the document copy and relational source disagree. A duality view keeps one governed source of truth while still giving each consumer the access shape it needs.

## Task 1: Inspect document-shaped transactions

First, inspect the transaction shape an application can consume directly.

1. Run this query:

    > **SQL Worksheet reminder:** Need a reminder on how to open and use the SQL Worksheet? Return to [Getting Started Task 2: Open SQL Worksheet](?lab=getting-started#Task2:OpenSQLWorksheet) for the step-by-step graphic showing where to paste and run SQL statements.

    You are viewing a transaction the way an application can consume it: as a JSON document. The SQL selects from the JSON Relational Duality view `ORDERS_DV` and uses `JSON_SERIALIZE(... PRETTY)` so SQL Worksheet displays the document shape clearly.

    <details>
    <summary><strong>Why this matters: Oracle's converged approach helps here</strong></summary>

    > In a fractured environment, the application team might keep JSON documents in one system while analysts use relational tables in another. That creates a synchronization problem: which copy is current, which one is governed, and which one should an investigation trust?
    >
    > Oracle JSON Relational Duality avoids that split. The JSON document and the relational rows are two views of the same governed data.

    </details>

    ```sql
    <copy>
    SELECT JSON_SERIALIZE(data PRETTY) AS transaction_document
    FROM orders_dv
    ORDER BY JSON_VALUE(data, '$._id' RETURNING NUMBER)
    FETCH FIRST 1 ROW ONLY;
    </copy>
    ```

    **Expected output: Transaction Document Excerpt**

    | Transaction Document |
    | --- |
    | { "\_id" : 1, "\_metadata" : { ... }, "customerId" : 687, "status" : "confirmed", "items" : [ ... ] } |


2. Expand the document in SQL Worksheet.
    The query reads the duality view as a document source. The database constructs the JSON shape from relational data, so the application gets a transaction payload without creating a second copy of the transaction record.

    The \_id value appears in the JSON document while the source data remains relational. Fields such as `customerId`, `status`, totals, timestamps, and line items give the application a document-shaped payload without copying the transaction to a separate document database.

    This is useful because risk and operations teams can inspect the same transaction from two angles: API-ready JSON for the application and governed relational rows for analysis.

## Task 2: Enable document inserts and updates

The existing `ORDERS_DV` lets an application update an existing transaction document. In this task, you extend that contract so an application can also create a transaction document. The relational tables, keys, and constraints remain the governed source of truth.

1. Check the current document-write capabilities.

    ```sql
    <copy>
    SELECT view_name,
           allow_insert,
           allow_update,
           allow_delete
    FROM user_json_duality_views
    WHERE view_name = 'ORDERS_DV';
    </copy>
    ```

    **Expected output: Current Document Capabilities**

    | View Name | Allow Insert | Allow Update | Allow Delete |
    | --- | --- | --- | --- |
    | ORDERS\_DV | false | true | false |

    The view is currently update-enabled but does not accept a new top-level document. The root `ORDERS` table controls whether a document can be inserted, while the nested `ORDER_ITEMS` rows must also allow inserts so the document can include line items.

2. Enable insert and update for the document and its line items.

    You are changing the duality-view definition, not creating a second API store. The two `WITH INSERT UPDATE` clauses tell Oracle Database that developers can create and update the JSON document while the database continues to enforce relational keys and data types underneath.

    ```sql
    <copy>
    CREATE OR REPLACE JSON RELATIONAL DUALITY VIEW orders_dv AS
    SELECT JSON {
        '_id'         : o.order_id,
        'customerId'  : o.customer_id,
        'status'      : o.order_status,
        'total'       : o.order_total,
        'shippingCost': o.shipping_cost,
        'demandScore' : o.demand_score,
        'createdAt'   : o.created_at,
        'items' : [
            SELECT JSON {
                'itemId'    : oi.item_id,
                'productId' : oi.product_id,
                'quantity'  : oi.quantity,
                'unitPrice' : oi.unit_price
            }
            FROM order_items oi WITH INSERT UPDATE
            WHERE oi.order_id = o.order_id
        ]
    }
    FROM orders o WITH INSERT UPDATE;
    </copy>
    ```

    **Expected output: View Definition Updated**

    Oracle confirms that the duality view was created or replaced. Verify the new capabilities in the next step.

3. Run the capability query again.

    ```sql
    <copy>
    SELECT view_name,
           allow_insert,
           allow_update,
           allow_delete
    FROM user_json_duality_views
    WHERE view_name = 'ORDERS_DV';
    </copy>
    ```

    **Expected output: Document Capabilities Enabled**

    | View Name | Allow Insert | Allow Update | Allow Delete |
    | --- | --- | --- | --- |
    | ORDERS\_DV | true | true | false |

    The view can now receive a new JSON transaction document and apply a document update. This environment is temporary, so this learner-created API contract and its test transaction are removed when workshop access expires.

## Task 3: Create and update a JSON transaction

Now act as an application developer. You will create a transaction as one nested JSON document, then confirm that a database developer or analyst can immediately see the same data as structured relational rows.

1. Insert the supplied workshop transaction document.

    The document uses the reserved workshop transaction ID `900001`, customer `1`, and product `1`. It includes one nested line item. This statement is safe to run again: after the transaction exists, it inserts zero rows and preserves the existing record. On the first run, the new transaction has the status `pending`.

    ```sql
    <copy>
    INSERT INTO orders_dv (data)
    SELECT JSON(
      '{
        "_id": 900001,
        "customerId": 1,
        "status": "pending",
        "total": 25.00,
        "shippingCost": 0,
        "items": [
          {
            "itemId": 990001,
            "productId": 1,
            "quantity": 2,
            "unitPrice": 12.50
          }
        ]
      }'
    )
    FROM dual
    WHERE NOT EXISTS (
      SELECT 1
      FROM orders
      WHERE order_id = 900001
    );
    </copy>
    ```

    **Expected output: Transaction Document Created**

    On the first run, Oracle inserts one document. On later runs, the `NOT EXISTS` check returns zero rows because the workshop transaction is already present.

2. Commit the new transaction.

    This `COMMIT;` is required. It makes the inserted document and its relational rows permanent before you verify them in the next step.

    ```sql
    <copy>
    COMMIT;
    </copy>
    ```

3. Confirm the JSON document became relational rows.

    ```sql
    <copy>
    SELECT o.order_id AS transaction_id,
           o.order_status AS transaction_status,
           c.email AS client_email,
           oi.item_id,
           p.product_name,
           oi.quantity,
           oi.unit_price,
           oi.line_total
    FROM orders o
    JOIN customers c ON c.customer_id = o.customer_id
    JOIN order_items oi ON oi.order_id = o.order_id
    JOIN products p ON p.product_id = oi.product_id
    WHERE o.order_id = 900001;
    </copy>
    ```

    **Expected output: Created Transaction Rows**

    | Transaction Id | Transaction Status | Item Id | Product Name | Quantity | Unit Price | Line Total |
    | --- | --- | --- | --- | --- | --- | --- |
    | 900001 | pending | 990001 | Premium Checking Bundle | 2 | 12.5 | 25 |

4. Update the document status through the duality view.

    This update changes JSON data through `ORDERS_DV`. Oracle Database writes the matching relational `ORDERS.ORDER_STATUS` value; no application-side JSON parsing, copy, or synchronization job is required.

    ```sql
    <copy>
    UPDATE orders_dv
    SET data = JSON_TRANSFORM(data, SET '$.status' = 'confirmed')
    WHERE JSON_VALUE(data, '$._id' RETURNING NUMBER) = 900001;
    </copy>
    ```

    **Expected output: Transaction Status Updated**

    Oracle updates one document. The following query confirms that the relational order row now has status `confirmed`.

    🎯 **Interactive challenge:** Before you run the next query, predict which relational column will change and which line-item values will remain unchanged.

    <details>
    <summary><strong>Challenge answer: one document, one governed transaction</strong></summary>

    > `ORDERS.ORDER_STATUS` changes from `pending` to `confirmed`. The `ORDER_ITEMS` row stays the same because the document update changes only `status`. The application and the analyst are working with two access shapes over the same live finance data.

    </details>

5. Commit the document update.

    This `COMMIT;` is required. It permanently writes the updated JSON document and the matching `ORDERS.ORDER_STATUS` value before you verify the relational result.

    ```sql
    <copy>
    COMMIT;
    </copy>
    ```

6. Verify the updated relational status.

    ```sql
    <copy>
    SELECT o.order_id AS transaction_id,
           o.order_status AS transaction_status,
           oi.item_id,
           p.product_name,
           oi.quantity,
           oi.line_total
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    JOIN products p ON p.product_id = oi.product_id
    WHERE o.order_id = 900001;
    </copy>
    ```

    **Expected output: Updated Transaction Rows**

    | Transaction Id | Transaction Status | Item Id | Product Name | Quantity | Line Total |
    | --- | --- | --- | --- | --- | --- |
    | 900001 | confirmed | 990001 | Premium Checking Bundle | 2 | 25 |

## Task 4: Project JSON fields with SQL

Now use SQL to project document fields back into reviewable columns. In this context, "project" means pulling selected values out of the JSON document and displaying them as SQL result columns.

1. Run this SQL/JSON projection query:

    You are seeing the main advantage of JSON Relational Duality: the JSON document that works well for an application is still available for SQL analysis. The same transaction shape can be queried, filtered, and joined to governed relational data.

    The SQL uses `JSON_VALUE` to extract transaction fields from the duality document. That extraction is the projection step: it pulls out the transaction ID and status, reads the embedded customer identifier, joins that identifier to `CUSTOMERS`, and orders the result so the first transactions are easy to review.

    Without JSON Relational Duality, teams often have to choose between two awkward options. They can keep only relational tables and hand-build JSON for each application API, or they can copy transaction data into a separate document store and then worry about synchronization, security, lineage, and stale data. Duality avoids that split: the application gets JSON, while analysts still get SQL access to the same governed transaction record.

    ```sql
    <copy>
    SELECT JSON_VALUE(od.data, '$._id' RETURNING NUMBER) AS transaction_id,
           JSON_VALUE(od.data, '$.status') AS transaction_status,
           c.email AS client_email
    FROM orders_dv od
    JOIN customers c
      ON c.customer_id = JSON_VALUE(od.data, '$.customerId' RETURNING NUMBER)
    WHERE JSON_VALUE(od.data, '$._id' RETURNING NUMBER) = 900001;
    </copy>
    ```

    **Expected output: JSON Field Projection**

    | Transaction Id | Transaction Status | Client Email |
    | --- | --- | --- |
    | 900001 | confirmed | Existing customer email for customer 1 |


2. Review the columns returned from the JSON document.
    This query shows the reverse path: SQL can project fields back out of the document, meaning it can return selected JSON values as SQL columns and join them to relational customer data. That lets analysts use the same application-facing document view without giving up relational filtering, ordering, and joins.

    `Transaction Id` and `Transaction Status` are projected from the JSON document into the result table. The document stores the client reference as `customerId`, so the query joins back to `CUSTOMERS` to return `Client Email`.

    The business value is consistency. A developer can serve a clean transaction document to an application, while a risk analyst can still ask normal SQL questions about transaction status and customer contact details. Both users are working from the same source of truth.

## Next Steps

Congratulations on completing the JSON duality lab. You expanded a JSON API contract, created and updated a transaction as a document, and inspected the same governed data as relational rows. For a deeper hands-on workshop focused on JSON in Oracle Database, open the [JSON Relational Duality LiveLabs workshop](https://livelabs.oracle.com/ords/r/dbpm/livelabs/view-workshop?clear=RR,180&wid=3797).

## Acknowledgements

* **Author** - Pat Shepherd, Senior Principal Database Product Manager
* **Contributor** - Linda Foinding, Principal Database Product Manager
* **Last Updated By/Date** - Oracle Database Product Management, June 2026
