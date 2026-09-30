# Build a JSON Application Model

## Introduction

Thomas Brune is an application developer at Seer Sporting Goods. He and his team are building a web and mobile shopping experience. They want fewer round trips and payloads that match the order screens and services customers use.

Thomas needs an order and its items as one JSON payload. It should include the customer identifier, order status and item details, with room for changing application settings. The data already lives in Oracle AI Database. His question is how to give the application that document shape while retaining relational keys, SQL, transactions and database controls.

Thomas asks Jessica, the DBA, to walk through three approaches. They start with a JSON value in a relational table, then a collection of application-owned documents, and finally a JSON Relational Duality View over the existing order rows. Each approach has a different ownership model; choosing one for a screen does not require choosing it for the whole application.

![Thomas Brune, application developer](images/thomas.png)

<details>
<summary><strong>Key terms: JSON columns, JSON collections, and JSON Relational Duality</strong></summary>

> - A **JSON column** stores a JSON value beside ordinary typed columns and relational keys. It suits optional settings that can evolve with the application.
> - A **JSON Collection Table** stores a set of JSON documents in its `DATA` column. A document's top-level `_id` identifies it.
> - **JSON Relational Duality** exposes existing relational rows as a JSON document. A write through an enabled duality view changes those underlying rows.
> - An **ETag** identifies a document version. An application can include the version it read when submitting an update so the database can check for an intervening change.

</details>

Thomas's order feature needs a shape such as this. The example is a document illustration; you will insert the complete workshop payload in Task 5.

```json
{
  "_id": 900001,
  "customerId": 1,
  "status": "pending",
  "items": [
    { "itemId": 990001, "productId": 1, "quantity": 2, "unitPrice": 189.99 }
  ]
}
```

### Objectives

- Store flexible application attributes in a native JSON column.
- Create and query a JSON Collection Table of order documents.
- Read, insert and update relational order data through `ORDERS_DV`.
- Compare document and relational results, then choose a JSON approach for an application feature.

Estimated Time: **15 minutes**

### Hands-on Scenario

| Step | Retail focus |
| --- | --- |
| Business Problem | Thomas's shopping application needs an order payload with its items and status together. |
| Technical Challenge | The document shape must coexist with relational keys, joins and database controls. |
| Persona Focus | Thomas tests the three JSON approaches with Jessica's database guidance. |
| What You Will See | A native JSON value, an independent document collection and a writable document over existing order rows. |
| Database Capability | Native JSON, SQL/JSON functions and JSON Relational Duality work together. |
| Outcome | Thomas can match each application feature to the right storage and access pattern. |

Persona focus: You are Thomas, working with Jessica to decide how the application should store, assemble and read customer order data.

### Thomas's three JSON choices

A JSON column holds application settings alongside a relational key. A collection holds documents the application owns. A duality view defines a document over the order tables that other teams already use. All three support SQL access in the same database, but only the duality view in this lab writes directly to the existing order rows.

> **SQL Worksheet reminder:** Need a reminder on how to open and use the SQL Worksheet? Return to [Getting Started Task 2: Open SQL Worksheet](?lab=getting-started#Task2:OpenSQLWorksheet) for the step-by-step guide showing how to run SQL statements.

## Task 1: Store flexible application data as JSON

Thomas starts with optional screen settings. The order already exists, so he stores an order key beside a native JSON value instead of adding a relational column for every new screen option.

1. Create the application-data table. Run the create-and-insert steps in Tasks 1 and 2 once in this workshop schema. If you revisit the lab, use the existing demonstration tables and continue with their read queries.

    ```sql
    <copy>
    CREATE TABLE retail_app_data (
     order_id NUMBER PRIMARY KEY,
     app_data JSON NOT NULL
    );
    </copy>
    ```

    **Expected output:** The table is created with a numeric primary key and a native JSON column.

2. Add settings for the first existing order.

    ```sql
    <copy>
    INSERT INTO retail_app_data (order_id, app_data)
    SELECT order_id,
           JSON_OBJECT('screen' VALUE 'order-detail',
                       'showTotal' VALUE 'true' FORMAT JSON,
                       'features' VALUE JSON_ARRAY('live-status','saved-delivery-address')
                       RETURNING JSON)
    FROM (SELECT order_id FROM orders ORDER BY order_id FETCH FIRST 1 ROW ONLY);
    </copy>
    ```

    **Expected output:** One row is inserted, using the existing order's key.

3. Save the row.

    ```sql
    <copy>
    COMMIT;
    </copy>
    ```

    **Expected output:** The commit completes.

4. Read the JSON values with SQL.

    ```sql
    <copy>
    SELECT order_id,
     JSON_VALUE(app_data, '$.screen') AS screen_name,
     JSON_VALUE(app_data, '$.showTotal' RETURNING BOOLEAN) AS show_total,
     JSON_QUERY(app_data, '$.features') AS app_features
    FROM retail_app_data;
    </copy>
    ```

    **Expected output: Application settings**

    | ORDER_ID | SCREEN_NAME | SHOW_TOTAL | APP_FEATURES |
    | ---: | --- | --- | --- |
    | 1 | order-detail | true | ["live-status","saved-delivery-address"] |

    `ORDER_ID` remains a relational key. `JSON_VALUE` returns scalar values, including a native Boolean, while `JSON_QUERY` returns the feature array. Thomas can change the settings document as the screen evolves.

## Task 2: Create a JSON Collection Table

Thomas next tries a document collection. Each row owns a document in `DATA`; it is separate from the source order tables. He copies one existing order so the team can compare the two approaches using familiar data.

1. Create the collection with document version tags.

    ```sql
    <copy>
    CREATE JSON COLLECTION TABLE retail_order_docs WITH ETAG;
    </copy>
    ```

    **Expected output:** The JSON Collection Table is created.

2. Assemble an order document from the existing order and its items, then insert it into the collection.

    ```sql
    <copy>
    INSERT INTO retail_order_docs (data)
    SELECT JSON_OBJECT(
     '_id' VALUE o.order_id,
     'customerId' VALUE o.customer_id,
     'status' VALUE o.order_status,
     'items' VALUE (
      SELECT JSON_ARRAYAGG(JSON_OBJECT(
       'itemId' VALUE oi.item_id,
       'productId' VALUE oi.product_id,
       'quantity' VALUE oi.quantity,
       'unitPrice' VALUE oi.unit_price RETURNING JSON)
       ORDER BY oi.item_id RETURNING JSON)
      FROM order_items oi WHERE oi.order_id=o.order_id
     ) FORMAT JSON RETURNING JSON)
    FROM orders o JOIN retail_app_data t ON t.order_id=o.order_id;
    </copy>
    ```

    **Expected output:** One document is inserted. Its nested `items` array is ordered by item ID.

3. Commit the document.

    ```sql
    <copy>
    COMMIT;
    </copy>
    ```

    **Expected output:** The commit completes.

4. Inspect the stored document.

    ```sql
    <copy>
    SELECT JSON_SERIALIZE(data RETURNING CLOB PRETTY) AS order_document
    FROM retail_order_docs
    WHERE JSON_VALUE(data, '$._id' RETURNING NUMBER)=
     (SELECT order_id FROM retail_app_data);
    </copy>
    ```

    **Expected output: Stored order document**

    | Field | Observed value |
    | --- | --- |
    | `_id` | 1 |
    | `customerId` | 1668 |
    | `status` | confirmed |
    | `items` | Four item objects, with IDs 1 through 4 |
    | `_metadata.etag` | A generated document-version value |

    `RETURNING CLOB` allows the full document to be displayed without the default short character limit. Expand the document value in SQL Worksheet to inspect the item array. The ETag value depends on the document version; do not compare its text with another learner's result.

`WITH ETAG` gives Thomas's application a version to check when it updates a document. The application must participate in that check to detect a conflicting update. Also notice the ownership boundary: a later change to `ORDERS` does not automatically refresh this copied collection document.

## Task 3: Read a customer order document from relational data

Thomas now tests the payload his order feature should consume. `ORDERS_DV` supplies a document over the existing `ORDERS` and `ORDER_ITEMS` rows.

1. Read the document for order 1.

    <details>
    <summary><strong>Why this matters to Thomas</strong></summary>

    > The order already has relational keys and line items that Jessica and other teams rely on. A duality view gives the application a nested payload over those rows. Thomas does not need to maintain an independent order copy or assemble the items with several application requests.

    </details>

    ```sql
    <copy>
    SELECT JSON_SERIALIZE(data RETURNING CLOB PRETTY) AS "Order Document"
    FROM orders_dv
    WHERE JSON_VALUE(data, '$._id' RETURNING NUMBER) = 1;
    </copy>
    ```

    **Expected output: Relational order as JSON**

    | Field | What to inspect |
    | --- | --- |
    | `_id`, `customerId`, `status` | Order 1, customer 1668 and confirmed status |
    | `total`, `shippingCost`, `demandScore`, `createdAt` | Header fields defined by the view |
    | `items` | The order's four related item rows |
    | `_metadata.etag` | The document version used for concurrency checks |

2. Expand the JSON value in SQL Worksheet and compare its shape with the collection document.

    The application sees the document contract defined by the view. Jessica still sees relational rows. The collection from Task 2 stores its own document; this duality view reads the current order and item records each time.

## Task 4: Enable document inserts and updates

The existing duality view allows updates. Thomas also needs to accept a new order with nested items. Jessica changes the view's write contract while the database continues to enforce the underlying relational keys and data types.

1. Inspect the current document capabilities.

    ```sql
    <copy>
    SELECT view_name AS "View Name",
           allow_insert AS "Allow Insert",
           allow_update AS "Allow Update",
           allow_delete AS "Allow Delete"
    FROM user_json_duality_views
    WHERE view_name = 'ORDERS_DV';
    </copy>
    ```

    **Expected output: Current document capabilities**

    | View Name | Allow Insert | Allow Update | Allow Delete |
    | --- | --- | --- | --- |
    | ORDERS_DV | false | true | false |

    If you already completed this task, insert will be enabled. The metadata reports the view's current definition.

2. Enable inserts and updates for both the root order and its nested items.

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

    **Expected output:** Oracle creates or replaces the duality view.

    The `ORDERS` row supplies the root object. Related `ORDER_ITEMS` rows supply the nested array. Both `WITH INSERT UPDATE` clauses matter: an incoming document must be able to create its header and its item rows. Deletes remain disabled through this view.

3. Inspect the capabilities again.

    ```sql
    <copy>
    SELECT view_name AS "View Name",
           allow_insert AS "Allow Insert",
           allow_update AS "Allow Update",
           allow_delete AS "Allow Delete"
    FROM user_json_duality_views
    WHERE view_name = 'ORDERS_DV';
    </copy>
    ```

    **Expected output: Document capabilities enabled**

    | View Name | Allow Insert | Allow Update | Allow Delete |
    | --- | --- | --- | --- |
    | ORDERS_DV | true | true | false |

Thomas can now submit an order document. In an application, Jessica would also grant the intended access to the view; enabling an operation in its definition does not itself grant access to another user.

## Task 5: Create and update a JSON order

Thomas tests one complete order. The application writes JSON, then Jessica checks the relational rows to confirm what changed.

1. Insert the supplied order document.

    The payload reserves order **900001** and item **990001**, using existing customer **1** and product **1**. Its first-run status is `pending`. The existence check skips the insert when that order already exists, preserving the earlier record if you revisit the exercise.

    ```sql
    <copy>
    INSERT INTO orders_dv (data)
    SELECT JSON(
      '{
        "_id": 900001,
        "customerId": 1,
        "status": "pending",
        "total": 379.98,
        "shippingCost": 0,
        "items": [
          {
            "itemId": 990001,
            "productId": 1,
            "quantity": 2,
            "unitPrice": 189.99
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

    **Expected output:** One document is inserted on the first run; zero rows are inserted when the reserved order already exists.

2. Commit the order.

    ```sql
    <copy>
    COMMIT;
    </copy>
    ```

    **Expected output:** The commit completes.

3. Read the corresponding relational order and item.

    ```sql
    <copy>
    SELECT o.order_id AS "Order",
           o.order_status AS "Status",
           c.email AS "Customer Email",
           oi.item_id AS "Item",
           p.product_name AS "Product",
           oi.quantity AS "Quantity",
           oi.unit_price AS "Unit Price",
           oi.line_total AS "Line Total"
    FROM orders o
    JOIN customers c
      ON c.customer_id = o.customer_id
    JOIN order_items oi
      ON oi.order_id = o.order_id
    JOIN products p
      ON p.product_id = oi.product_id
    WHERE o.order_id = 900001;
    </copy>
    ```

    **Expected output: Newly created relational rows**

    | Order | Status | Customer Email | Item | Product | Quantity | Unit Price | Line Total |
    | ---: | --- | --- | ---: | --- | ---: | ---: | ---: |
    | 900001 | pending | mary.smith1@example.com | 990001 | StormRunner Trail Shell | 2 | 189.99 | 379.98 |

    A repeated visit can show `confirmed` if the next update has already run. The line total is calculated from the relational quantity and unit price.

4. Confirm the order by changing the JSON status.

    ```sql
    <copy>
    UPDATE orders_dv
    SET data = JSON_TRANSFORM(data, SET '$.status' = 'confirmed')
    WHERE JSON_VALUE(data, '$._id' RETURNING NUMBER) = 900001;
    </copy>
    ```

    **Expected output:** One document is updated. `JSON_TRANSFORM` changes the selected status field; it does not replace the item array.

5. Commit the update.

    ```sql
    <copy>
    COMMIT;
    </copy>
    ```

    **Expected output:** The commit completes.

6. Predict the relational change, then inspect it. Should changing only `$.status` alter the quantity or line total?

    ```sql
    <copy>
    SELECT o.order_id AS "Order",
           o.order_status AS "Status",
           oi.item_id AS "Item",
           p.product_name AS "Product",
           oi.quantity AS "Quantity",
           oi.line_total AS "Line Total"
    FROM orders o
    JOIN order_items oi
      ON oi.order_id = o.order_id
    JOIN products p
      ON p.product_id = oi.product_id
    WHERE o.order_id = 900001;
    </copy>
    ```

    **Expected output: Updated order, unchanged item**

    | Order | Status | Item | Product | Quantity | Line Total |
    | ---: | --- | ---: | --- | ---: | ---: |
    | 900001 | confirmed | 990001 | StormRunner Trail Shell | 2 | 379.98 |

    `ORDERS.ORDER_STATUS` changed; the item values stayed the same. The document and SQL access paths address the same records, so there is no independent order copy to reconcile. This committed workshop order remains in the schema for the rest of the session.

## Task 6: Project document fields into SQL columns

Jessica still needs SQL for reporting and analysis. Here she projects selected fields from Thomas's document and joins the customer identifier to relational customer data. “Project” means returning selected document values as SQL columns.

1. Read the order ID and status from the JSON document, then join its customer ID to `CUSTOMERS`.

    ```sql
    <copy>
    SELECT JSON_VALUE(od.data, '$._id' RETURNING NUMBER) AS "Order",
           JSON_VALUE(od.data, '$.status') AS "Status",
           c.email AS "Customer Email"
    FROM orders_dv od
    JOIN customers c
      ON c.customer_id = JSON_VALUE(od.data, '$.customerId' RETURNING NUMBER)
    WHERE JSON_VALUE(od.data, '$._id' RETURNING NUMBER) = 900001;
    </copy>
    ```

    **Expected output: JSON field projection**

    | Order | Status | Customer Email |
    | ---: | --- | --- |
    | 900001 | confirmed | mary.smith1@example.com |

2. Read the same values directly from the relational tables.

    ```sql
    <copy>
    SELECT o.order_id, o.order_status, c.email
    FROM orders o JOIN customers c ON c.customer_id=o.customer_id
    WHERE o.order_id=900001;
    </copy>
    ```

    **Expected output: Equivalent relational projection**

    | ORDER_ID | ORDER_STATUS | EMAIL |
    | ---: | --- | --- |
    | 900001 | confirmed | mary.smith1@example.com |

    Compare the values despite the different column headings. Thomas can use the document shape in the application while Jessica joins and analyzes the same order with SQL.

## Conclusion: Choose the right JSON approach

Thomas does not need one JSON model for every application feature. He can choose according to who owns the data and whether the application needs a document over existing relational rows.

| Approach | Use it when | Example in Thomas's application | Where the data lives |
| --- | --- | --- | --- |
| JSON column in a relational table | A relational record needs optional or changing attributes. | Screen settings beside an order key. | A normal table with a native JSON column. |
| JSON Collection Table | The application owns a set of documents. | Saved shopping drafts whose structure can evolve. | One independent document per DATA row in the collection. |
| JSON Relational Duality View | Existing relational rows need an application document shape. | Submit an order with items and update its status. | ORDERS and ORDER_ITEMS; the view defines the document contract. |

For the order feature, `ORDERS_DV` gives Thomas the payload he needs while Jessica retains relational constraints, SQL and control of the write contract. The next question is which other products and customer orders relate to an emerging signal. Gilly will connect a plain-language search to those existing records.

## Acknowledgements

* **Author** - Kevin Lazarz
* **Contributors** - Eugenio Galiano, Pat Shepherd
* **Last Updated By/Date** - Oracle Database Product Management, September 2026
