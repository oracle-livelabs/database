# Build a JSON Application Model

## Introduction

Thomas Brune, SEER HIGHTECH’s application developer, needs production-order JSON documents for web and mobile screens, including order lines and optional app fields.

Jessica, the DBA, helps him compare JSON columns, JSON collections, and JSON Relational Duality Views while retaining SQL access, transactions, and database controls.

![Thomas introduces the JSON production-order application lab](images/thomas.png)

<details>
<summary><strong>Key terms: JSON columns, JSON collections, and JSON Relational Duality</strong></summary>

> - A **JSON column** stores flexible attributes alongside a table’s typed columns, keys, and constraints.
>
> - A **JSON collection** stores documents in a `JSON`-typed `DATA` column, with a top-level `_id` identifying each document.
>
> - **JSON Relational Duality** exposes relational rows as JSON documents without a separate copy. The rows retain their database constraints.
>

</details>

Here is the document Thomas’s screen needs:

```json
{
  "_id": 513063,
  "customerSiteId": 1,
  "plantId": 1,
  "scheduledStart": "2026-09-22",
  "dueDate": "2026-09-24",
  "status": "released",
  "items": [
    { "componentId": 1, "quantity": 2, "unitCost": 125.00 }
  ]
}
```

### Objectives

- Store flexible application attributes as JSON in a relational table.
- Create and query a JSON Collection Table of production order documents.
- Read and update relational production order data through `PRODUCTION_ORDERS_DV`.
- Compare the three JSON approaches and choose the right one for an application feature.

Estimated Time: **10 minutes**

> **SQL Worksheet reminder:** See [Getting Started Task 2: Open SQL Worksheet](?lab=getting-started#Task2:OpenSQLWorksheet) for the steps to paste and run SQL.

On a repeat run, reuse `THOMAS_APP_DATA` and `THOMAS_PRODUCTION_ORDER_DOCS` and skip their CREATE and INSERT statements in Tasks 1 and 2. The duality view may already allow inserts, and order `900001` may already be released; Task 5 preserves an existing order.

## Task 1: Store flexible application data as JSON

Thomas adds a native `JSON` column for optional screen and production-tracking settings. The production order rows already exist in the workshop database.

1. Create the application-data table and add one sample document.

    ```sql
    <copy>
    CREATE TABLE thomas_app_data (
        production_order_id  NUMBER PRIMARY KEY,
        app_data  JSON NOT NULL
    );

    INSERT INTO thomas_app_data (production_order_id, app_data)
    SELECT production_order_id,
           JSON_OBJECT(
               'screen'    VALUE 'production_order-detail',
               'showTotal' VALUE 'true' FORMAT JSON,
               'features'  VALUE JSON_ARRAY('live-status', 'delivery-requirements')
               RETURNING JSON
           )
    FROM (
        SELECT production_order_id
        FROM production_orders
        ORDER BY production_order_id
        FETCH FIRST 1 ROW ONLY
    );

    COMMIT;
    </copy>
    ```

2. Read values from the JSON column.

    ```sql
    <copy>
    SELECT production_order_id,
           JSON_VALUE(app_data, '$.screen') AS screen_name,
           JSON_VALUE(app_data, '$.showTotal' RETURNING BOOLEAN) AS show_total,
           JSON_QUERY(app_data, '$.features') AS app_features
    FROM thomas_app_data;
    </copy>
    ```

    `PRODUCTION_ORDER_ID` remains a relational key. `APP_DATA` can change as the application changes. Thomas can query both with SQL in one table.

## Task 2: Create a JSON Collection Table

Next, Thomas creates a JSON Collection Table. Each row holds a document in `DATA`, identified by `_id`.

1. Create the collection and add the sample production order document.

    ```sql
    <copy>
    CREATE JSON COLLECTION TABLE thomas_production_order_docs
    WITH ETAG;

    INSERT INTO thomas_production_order_docs (data)
    SELECT JSON_OBJECT(
               '_id'        VALUE r.production_order_id,
               'customerSiteId' VALUE r.customer_site_id,
               'plantId' VALUE r.plant_id,
               'scheduledStart' VALUE TO_CHAR(r.scheduled_start, 'YYYY-MM-DD'),
               'dueDate' VALUE TO_CHAR(r.due_date, 'YYYY-MM-DD'),
               'status'     VALUE r.order_status,
               'items'      VALUE (
                   SELECT JSON_ARRAYAGG(
                              JSON_OBJECT(
                                  'orderLineId'    VALUE rn.order_line_id,
                                  'componentId' VALUE rn.component_id,
                                  'quantity'  VALUE rn.quantity,
                                  'unitCost' VALUE rn.unit_cost
                                  RETURNING JSON
                              ) ORDER BY rn.order_line_id RETURNING JSON
                          )
                   FROM production_order_lines rn
                   WHERE rn.production_order_id = r.production_order_id
               ) FORMAT JSON
               RETURNING JSON
           )
    FROM production_orders r
    JOIN thomas_app_data t ON t.production_order_id = r.production_order_id;

    COMMIT;
    </copy>
    ```

    `WITH ETAG` adds `_metadata.etag`, which changes when the document changes. An application can submit the tag it last read with an update to detect concurrent changes and avoid overwriting a newer version.

2. Query the collection as documents.

    ```sql
    <copy>
    SELECT JSON_SERIALIZE(data PRETTY) AS production_order_document
    FROM thomas_production_order_docs
    WHERE JSON_VALUE(data, '$._id' RETURNING NUMBER) =
          (SELECT production_order_id FROM thomas_app_data);
    </copy>
    ```

    This collection stores its own documents, separate from `PRODUCTION_ORDERS` and `PRODUCTION_ORDER_LINES`. Both document APIs and SQL can read `DATA`.

## Task 3: Read a customer site document from relational data

Thomas now reads a document assembled from the existing relational production order and its lines.

1. Run this query:

    ```sql
    <copy>
    SELECT data AS production_order_document
    FROM production_orders_dv
    FETCH FIRST 1 ROW ONLY;
    </copy>
    ```

    ![JSON production-order document returned from the duality view](images/sql-duality-document.png)

    **Expected output:** One JSON production-order document with an `items` array.

2. Expand the document in SQL Worksheet.

    Find `_id`, `customerSiteId`, `status`, totals, timestamps, and the `items` array.

    > **Note:** Find `_metadata.etag` here too; the application uses it to detect concurrent updates.

## Task 4: Enable document inserts and updates

The existing `PRODUCTION_ORDERS_DV` lets an application update production order documents. Here, you also allow inserts. Oracle still enforces the table keys and constraints. An application granted access only to the view can use only the fields and write operations that the view allows.

1. Check the current document-write capabilities.

    ```sql
    <copy>
    SELECT view_name,
           allow_insert,
           allow_update,
           allow_delete
    FROM user_json_duality_views
    WHERE view_name = 'PRODUCTION_ORDERS_DV';
    </copy>
    ```

    `PRODUCTION_ORDERS_DV` should report update enabled and insert disabled in the initial loader definition.

    Both the root `PRODUCTION_ORDERS` table and nested `PRODUCTION_ORDER_LINES` rows need insert permission to accept a new document with line items.

2. Enable insert and update for the document and its production-order lines.

    ```sql
    <copy>
    CREATE OR REPLACE JSON RELATIONAL DUALITY VIEW production_orders_dv AS
    SELECT JSON {
        '_id'         : r.production_order_id,
        'customerSiteId'  : r.customer_site_id,
        'plantId' : r.plant_id,
        'scheduledStart'     : r.scheduled_start,
        'dueDate'    : r.due_date,
        'status'      : r.order_status,
        'total'       : r.order_total,
        'setupCost': r.setup_cost,
        'priorityScore' : r.priority_score,
        'createdAt'   : r.created_at,
        'items' : [
            SELECT JSON {
                'orderLineId'    : rn.order_line_id,
                'componentId' : rn.component_id,
                'quantity'  : rn.quantity,
                'unitCost' : rn.unit_cost
            }
            FROM production_order_lines rn WITH INSERT UPDATE
            WHERE rn.production_order_id = r.production_order_id
        ]
    }
    FROM production_orders r WITH INSERT UPDATE;
    </copy>
    ```

    `PRODUCTION_ORDERS` supplies the document root; `PRODUCTION_ORDER_LINES` supplies the nested `items` array. Each `WITH INSERT UPDATE` clause enables those operations on its part of the document.

3. Run the capability query again.

    ```sql
    <copy>
    SELECT view_name,
           allow_insert,
           allow_update,
           allow_delete
    FROM user_json_duality_views
    WHERE view_name = 'PRODUCTION_ORDERS_DV';
    </copy>
    ```

    ![Duality-view insert and update settings in SQL Worksheet](images/sql-duality-contract.png)

    `PRODUCTION_ORDERS_DV` should report insert and update enabled; delete remains disabled.

## Task 5: Create and update a JSON production order

Thomas inserts one nested document, then checks the relational rows Jessica sees.

1. Insert the supplied workshop production order document.

    The `INSERT` writes through `PRODUCTION_ORDERS_DV` into relational tables. It uses reserved order ID `900001` and line ID `990001`, with customer site, plant, and component IDs all `1`.

    The loader must supply those referenced rows. The fixed dates put the due date after the scheduled start; quantity is independent of that range. On a repeat run, the `NOT EXISTS` check preserves the existing order.

    ```sql
    <copy>
    INSERT INTO production_orders_dv (data)
    SELECT JSON(
      '{
        "_id": 900001,
        "customerSiteId": 1,
        "plantId": 1,
        "scheduledStart": "2026-09-22",
        "dueDate": "2026-09-24",
        "status": "planned",
        "total": 250.00,
        "setupCost": 0,
        "items": [
          {
            "orderLineId": 990001,
            "componentId": 1,
            "quantity": 2,
            "unitCost": 125.00
          }
        ]
      }'
    )
    WHERE NOT EXISTS (
      SELECT 1
      FROM production_orders
      WHERE production_order_id = 900001
    );

    COMMIT;
    </copy>
    ```

    Expect one inserted document on the first run and zero on a repeat run.

2. Confirm the JSON document became relational rows.

    ```sql
    <copy>
    SELECT r.production_order_id AS production_order_id,
           r.order_status AS order_status,
           g.email AS contact_email,
           rn.order_line_id,
           so.component_name,
           rn.quantity,
           rn.unit_cost,
           rn.line_total
    FROM production_orders r
    JOIN customer_sites g ON g.customer_site_id = r.customer_site_id
    JOIN production_order_lines rn ON rn.production_order_id = r.production_order_id
    JOIN components so ON so.component_id = rn.component_id
    WHERE r.production_order_id = 900001;
    </copy>
    ```

    Expect order `900001`, line `990001`, two units at USD 125.00, total 250.00, and initial status `planned`. Read the email and component name from your result.

3. Update the document status through the duality view.

    This statement maps `status` to `PRODUCTION_ORDERS.ORDER_STATUS`. The view also permits updates to other exposed fields; restricting writes to status alone would require a narrower view definition.

    ```sql
    <copy>
    UPDATE production_orders_dv
    SET data = JSON_TRANSFORM(data, SET '$.status' = 'released')
    WHERE JSON_VALUE(data, '$._id' RETURNING NUMBER) = 900001;

    COMMIT;
    </copy>
    ```

4. Verify the updated relational status.

    ```sql
    <copy>
    SELECT r.production_order_id AS production_order_id,
           r.order_status AS order_status,
           rn.order_line_id,
           so.component_name,
           rn.quantity,
           rn.line_total
    FROM production_orders r
    JOIN production_order_lines rn ON rn.production_order_id = r.production_order_id
    JOIN components so ON so.component_id = rn.component_id
    WHERE r.production_order_id = 900001;
    </copy>
    ```

    ![Released production order created and updated through the duality view](images/sql-duality-released.png)

    Production order 900001 should now have status `released`, with the same order-line values.

## Task 6: Project JSON fields with SQL

Jessica extracts JSON values from `PRODUCTION_ORDERS_DV` as SQL columns, a step called **projection**, and joins them to customer site data.

1. Run this SQL/JSON projection query:

    `JSON_VALUE` extracts the order ID, status, and customer site identifier. The query joins that identifier to `CUSTOMER_SITES` to retrieve the contact email.

    ```sql
    <copy>
    SELECT JSON_VALUE(rd.data, '$._id' RETURNING NUMBER) AS production_order_id,
           JSON_VALUE(rd.data, '$.status') AS order_status,
           g.email AS contact_email
    FROM production_orders_dv rd
    JOIN customer_sites g
      ON g.customer_site_id = JSON_VALUE(rd.data, '$.customerSiteId' RETURNING NUMBER)
    WHERE JSON_VALUE(rd.data, '$._id' RETURNING NUMBER) = 900001;
    </copy>
    ```

    ![Production-order fields projected from the JSON document](images/sql-duality-projection.png)

2. Run the equivalent query against the relational tables.

    ```sql
    <copy>
    SELECT r.production_order_id AS production_order_id,
           r.order_status AS order_status,
           g.email AS contact_email
    FROM production_orders r
    JOIN customer_sites g
      ON g.customer_site_id = r.customer_site_id
    WHERE r.production_order_id = 900001;
    </copy>
    ```

    ![Matching production-order fields read from the relational tables](images/sql-duality-relational.png)

    Compare order ID `900001`, status `released`, and customer email with the JSON query. All three should match.

## Conclusion: Choose the right JSON approach

| Approach | Use it when | Thomas’s example | Storage |
| --- | --- | --- | --- |
| JSON column | A relational record needs flexible attributes. | Screen or planning settings. | A `JSON` column beside typed columns. |
| JSON Collection Table | The application owns independent documents. | Saved order drafts. | One document per `DATA` row. |
| JSON Relational Duality View | Existing relational data needs a document interface. | Read or write an order with its lines. | `PRODUCTION_ORDERS` and `PRODUCTION_ORDER_LINES`; the view defines the JSON shape. |

For the shared production-order data, Thomas chooses the duality view: the application gets JSON while Jessica retains SQL access and relational constraints.

## Acknowledgements

* **Author** - Matt Kowalik
* **Contributor** - Kevin Lazarz
* **Last Updated By/Date** - Matt Kowalik, September 2026
