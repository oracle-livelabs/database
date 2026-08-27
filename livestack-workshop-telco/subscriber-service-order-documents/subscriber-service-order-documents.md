# Subscriber Service Orders

## Introduction

After Hudson Yards becomes the priority, the `TEL-5G-2026-501` team must understand the service action tied to the incident. Order `601` links the case's source signal to a subscriber, the Hudson Yards site, and the assigned 5G service. You are the service-order developer who must support application JSON writes while preserving relational evidence for operations. JSON Relational Duality gives both teams one governed source.

![JSON Relational Duality for service orders](images/json-duality.svg " ")

### Objectives

- Read an existing `ORDERS_DV` document and inspect its baseline write capabilities.
- Enable JSON document inserts and updates without changing the loader's update-only baseline.
- Insert and update one reserved service-order document, then verify the same change in relational rows.
- Project JSON fields back into SQL columns and join them to governed Telco records.

Estimated Time: **25 minutes**

### Business Scenario

| Step | Telco focus |
| --- | --- |
| Business Problem | Applications need to create and update a complete service-order document while operations needs SQL evidence. |
| Technical Challenge | Separate document and relational stores can drift apart or require synchronization jobs. |
| Persona Focus | You are a service-order application developer. |
| What You Will Do | Enable a writable duality-view contract, write JSON, and verify the relational effect. |
| Database Capability | JSON Relational Duality with controlled insert and update operations. |
| Outcome | One governed service order supports application JSON writes and relational analysis. |

<details>
<summary><strong>Key terms: JSON document, duality view, write capability, projection, and source of truth</strong></summary>

> - A **JSON document** is an application-friendly representation of one service order and its items. It groups the subscriber, site, status, service, and value fields that a service-order screen needs.
>
> - A **duality view** gives an application a document-shaped interface while the underlying relational rows remain queryable in SQL. In this lab, `ORDERS_DV` is the contract between the application and the service-order foundation.
>
> - A **write capability** controls whether an application can insert, update, or delete through a duality view. This lab enables insert and update while leaving delete disabled.
>
> - A **projection** reads selected JSON fields as SQL columns. It keeps application-friendly document access compatible with relational joins and analysis.
>
> - A **source of truth** is the governed record teams rely on for a consistent answer. JSON Relational Duality lets `ORDERS_DV`, `SERVICE_ORDERS`, and `SERVICE_ORDER_ITEMS` expose the same live data instead of synchronized copies.

</details>

## Task 1: Read the baseline service-order document

Start with one existing document so you can identify its root fields and nested service item before changing the view contract:

1. Project order `601` into readable fields.

    > **SQL Worksheet reminder:** Need a reminder on how to open and use the SQL Worksheet? Return to [Getting Started Task 2: Open SQL Worksheet](?lab=getting-started#Task2:OpenSQLWorksheet) for the step-by-step graphic showing where to paste and run SQL statements.

    `JSON_VALUE` reads one named value from the application-facing document. The `items[0].serviceId` path reaches the first service in the nested item array.

    ```sql
    <copy>
    SELECT JSON_VALUE(data, '$._id' RETURNING NUMBER) AS "Order ID",
           JSON_VALUE(data, '$.subscriberId' RETURNING NUMBER) AS "Subscriber ID",
           JSON_VALUE(data, '$.networkSiteId' RETURNING NUMBER) AS "Network Site ID",
           JSON_VALUE(data, '$.status' RETURNING VARCHAR2(30)) AS "Status",
           JSON_VALUE(data, '$.serviceValue' RETURNING NUMBER) AS "Monthly Value",
           JSON_VALUE(data, '$.demandScore' RETURNING NUMBER) AS "Demand Score",
           JSON_VALUE(data, '$.items[0].serviceId' RETURNING NUMBER) AS "Service ID"
    FROM orders_dv
    WHERE JSON_VALUE(data, '$._id' RETURNING NUMBER) = 601;
    </copy>
    ```

    **Expected output: Baseline Service-Order Document**

    | Order ID | Subscriber ID | Network Site ID | Status | Monthly Value | Demand Score | Service ID |
    | ---: | ---: | ---: | --- | ---: | ---: | ---: |
    | 601 | 401 | 201 | Assigned | 85 | 96 | 101 |

    The root document identifies the subscriber, site, status, and value. The nested item identifies the ordered telecom service. Both shapes come from relational service-order rows in the same database.

## Task 2: Enable document inserts and updates

Inspect the loader-created contract, then explicitly enable the two write operations required by the application exercise.

1. Check the baseline capabilities.

    `USER_JSON_DUALITY_VIEWS` reports which document operations the current view permits. The authoritative loader creates `ORDERS_DV` with update access only.

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

    **Expected output: Baseline Document Capabilities**

    | View Name | Allow Insert | Allow Update | Allow Delete |
    | --- | --- | --- | --- |
    | ORDERS\_DV | false | true | false |

    A fresh workshop begins with update access enabled. If you already completed this task, `Allow Insert` remains `true` because replacing a database view is a data definition language operation that commits automatically.

2. Enable insert and update operations for the service-order document and its nested items.

    The root mapping includes every required `SERVICE_ORDERS` column. The nested mapping includes the required `SERVICE_ID` foreign key as `serviceId`, along with the item key, quantity, and monthly value. The two `WITH INSERT UPDATE` clauses let Oracle Database map permitted JSON writes to both relational tables while continuing to enforce their constraints.

    ```sql
    <copy>
    CREATE OR REPLACE JSON RELATIONAL DUALITY VIEW orders_dv AS
    SELECT JSON {
        '_id'           : o.service_order_id,
        'subscriberId'  : o.subscriber_id,
        'networkSiteId' : o.network_site_id,
        'sourceSignalId': o.source_signal_id,
        'status'        : o.service_status,
        'serviceValue'  : o.service_value,
        'dispatchCost'  : o.dispatch_cost,
        'demandScore'   : o.demand_score,
        'createdAt'     : o.created_at,
        'items' : [
            SELECT JSON {
                'itemId'      : i.service_order_item_id,
                'serviceId'   : i.service_id,
                'quantity'    : i.quantity,
                'monthlyValue': i.monthly_value
            }
            FROM service_order_items i WITH INSERT UPDATE
            WHERE i.service_order_id = o.service_order_id
        ]
    }
    FROM service_orders o WITH INSERT UPDATE;
    </copy>
    ```

    **Expected output: View Definition Updated**

    Oracle confirms that view `ORDERS_DV` was created or replaced. If Oracle reports an error, stop and capture the complete `ORA-` message before continuing.

3. Verify the enabled capabilities.

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

    **Expected output: Document Capabilities Enabled**

    | View Name | Allow Insert | Allow Update | Allow Delete |
    | --- | --- | --- | --- |
    | ORDERS\_DV | true | true | false |

    The application can now read, create, and update a service-order document. Delete remains disabled.

## Task 3: Create and update a JSON service order

Now act as the service-order application. You will create one nested JSON document, inspect the relational rows Oracle Database creates, and update the document status through the same duality view.

> **Workshop data boundary:** The statements in this task commit reserved order `900501` and item `990501` in the current temporary workshop environment. The environment is rebuilt for the next run, so the reserved rows disappear with the workshop schema.

1. Insert the reserved Telco service-order document.

    The document uses existing subscriber `401`, Hudson Yards site `201`, source signal `501`, and 5G service `101`. `FROM dual` supplies one candidate document, while `WHERE NOT EXISTS` prevents a duplicate order if you rerun the task.

    ```sql
    <copy>
    INSERT INTO orders_dv (data)
    SELECT JSON(
      '{
        "_id": 900501,
        "subscriberId": 401,
        "networkSiteId": 201,
        "sourceSignalId": 501,
        "status": "Pending",
        "serviceValue": 85,
        "dispatchCost": 75,
        "demandScore": 96,
        "createdAt": "2026-08-26T14:30:00",
        "items": [
          {
            "itemId": 990501,
            "serviceId": 101,
            "quantity": 1,
            "monthlyValue": 85
          }
        ]
      }'
    )
    FROM dual
    WHERE NOT EXISTS (
      SELECT 1
      FROM service_orders
      WHERE service_order_id = 900501
    );

    </copy>
    ```

    **Expected output: Service-Order Document Inserted**

    Oracle inserts one document on a fresh run. A same-schema rerun may insert zero rows because the reserved order already exists.

2. Commit the insert as its own SQL Worksheet action.

    Highlight and run this command explicitly before the relational verification query.

    ```sql
    <copy>
    COMMIT;
    </copy>
    ```

    **Expected output: Commit Complete**

    Oracle reports `Commit complete.`

3. Retrieve the JSON write as relational evidence.

    This query joins the new `SERVICE_ORDERS` row to its subscriber, site, nested item, and telecom service. One document insert created the root and child rows that both the application and operations team can use.

    ```sql
    <copy>
    SELECT o.service_order_id AS "Order",
           o.service_status AS "Status",
           s.subscriber_name AS "Subscriber",
           ns.network_site_name AS "Network Site",
           i.service_order_item_id AS "Item",
           ts.service_name AS "Service",
           i.quantity AS "Quantity",
           i.monthly_value AS "Monthly Value"
    FROM service_orders o
    JOIN subscribers s
      ON s.subscriber_id = o.subscriber_id
    JOIN network_sites ns
      ON ns.network_site_id = o.network_site_id
    JOIN service_order_items i
      ON i.service_order_id = o.service_order_id
    JOIN telecom_services ts
      ON ts.service_id = i.service_id
    WHERE o.service_order_id = 900501;
    </copy>
    ```

    **Expected output: Relational Service-Order Rows**

    | Order | Status | Subscriber | Network Site | Item | Service | Quantity | Monthly Value |
    | ---: | --- | --- | --- | ---: | --- | ---: | ---: |
    | 900501 | Pending | Avery Chen | Hudson Yards 5G Macro Site | 990501 | 5G Unlimited Mobile Plan | 1 | 85 |

4. Update the document status through `ORDERS_DV`.

    `JSON_TRANSFORM` changes only the document's `status` field. Oracle Database maps that field to `SERVICE_ORDERS.SERVICE_STATUS`; the application does not need a second document copy or synchronization job.

    ```sql
    <copy>
    UPDATE orders_dv
    SET data = JSON_TRANSFORM(data, SET '$.status' = 'Assigned')
    WHERE JSON_VALUE(data, '$._id' RETURNING NUMBER) = 900501;

    </copy>
    ```

    **Expected output: Service-Order Status Updated**

    Oracle updates one document.

5. Commit the status update as its own SQL Worksheet action.

    Highlight and run this command explicitly before checking which relational values changed.

    ```sql
    <copy>
    COMMIT;
    </copy>
    ```

    **Expected output: Commit Complete**

    Oracle reports `Commit complete.`

6. 🎯 **Interactive challenge: predict the relational change.**

    Before opening the answer, decide which `SERVICE_ORDERS` column should now contain `Assigned`. Should the nested service ID, quantity, or monthly value change when the JSON update targets only `$.status`?

    <details>
    <summary><strong>Challenge answer: one document, one governed service order</strong></summary>

    **Expected output: One Root Change, Stable Service Item**

    > `SERVICE_ORDERS.SERVICE_STATUS` changes from `Pending` to `Assigned`. The `SERVICE_ORDER_ITEMS` row remains service `101`, quantity `1`, and monthly value `85` because the JSON update did not change the nested `items` array. The document and relational rows are two access shapes over the same live Telco data.

    If you need the runnable verification, use this query:

    ```sql
    <copy>
    SELECT o.service_order_id AS "Order",
           o.service_status AS "Status",
           i.service_order_item_id AS "Item",
           i.service_id AS "Service ID",
           i.quantity AS "Quantity",
           i.monthly_value AS "Monthly Value"
    FROM service_orders o
    JOIN service_order_items i
      ON i.service_order_id = o.service_order_id
    WHERE o.service_order_id = 900501;
    </copy>
    ```

    | Order | Status | Item | Service ID | Quantity | Monthly Value |
    | ---: | --- | ---: | ---: | ---: | ---: |
    | 900501 | Assigned | 990501 | 101 | 1 | 85 |

    </details>

## Task 4: Project document fields into SQL columns

Finish by querying the updated application document and joining its identifiers to relational subscriber, site, and service records.

1. Run the document-projection query.

    `JSON_VALUE` pulls the order, status, subscriber, site, and nested service identifiers from the JSON document. Those identifiers then participate in normal relational joins.

    ```sql
    <copy>
    SELECT JSON_VALUE(od.data, '$._id' RETURNING NUMBER) AS "Order",
           JSON_VALUE(od.data, '$.status') AS "Status",
           s.subscriber_name AS "Subscriber",
           ns.network_site_name AS "Network Site",
           ts.service_name AS "Service"
    FROM orders_dv od
    JOIN subscribers s
      ON s.subscriber_id = JSON_VALUE(
           od.data, '$.subscriberId' RETURNING NUMBER
         )
    JOIN network_sites ns
      ON ns.network_site_id = JSON_VALUE(
           od.data, '$.networkSiteId' RETURNING NUMBER
         )
    JOIN telecom_services ts
      ON ts.service_id = JSON_VALUE(
           od.data, '$.items[0].serviceId' RETURNING NUMBER
         )
    WHERE JSON_VALUE(od.data, '$._id' RETURNING NUMBER) = 900501;
    </copy>
    ```

    **Expected output: JSON Fields Projected as SQL**

    | Order | Status | Subscriber | Network Site | Service |
    | ---: | --- | --- | --- | --- |
    | 900501 | Assigned | Avery Chen | Hudson Yards 5G Macro Site | 5G Unlimited Mobile Plan |

    The application can create and update the service order as a document. Operations can immediately query the same root and child data with SQL and join it to subscriber, signal, service, site, graph, or spatial evidence. The reserved order remains for the rest of this workshop run and disappears when the temporary environment is rebuilt.

## Next Steps

Congratulations on completing the JSON Relational Duality lab. You enabled a read/write document contract, created and updated a Telco service order through JSON, verified the relational rows, and projected document fields into SQL. For deeper practice, open the [JSON Relational Duality LiveLabs workshop](https://livelabs.oracle.com/ords/r/dbpm/livelabs/view-workshop?clear=RR,180&wid=3797).

## Acknowledgements

* **Author** - Pat Shepherd, Senior Principal Database Product Manager
* **Last Updated By/Date** - Pat Shepherd, August 2026
