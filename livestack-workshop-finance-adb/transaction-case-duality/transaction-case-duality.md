# Transaction and Case Documents with JSON Relational Duality

## Introduction

Applications often need transaction data as a JSON document, while analysts need the same data as rows they can filter, join, and investigate. This lab uses **JSON Relational Duality** to return both formats from the same transaction data.

The same transaction can be returned as a JSON document for an application or queried as rows for analysis. Nothing new is added to the transaction; Oracle Database is returning the same data in two useful formats.

This matters after the dashboard lab because a KPI is not enough for review. When an analyst or application needs a specific transaction, Oracle Database can return a JSON document for the application and still let analysts query the related rows for investigation.

<details>
<summary><strong>Key terms: JSON, relational tables, JSON Relational Duality, duality view, and projection</strong></summary>

> - **JSON** is a document format that can represent a complete transaction payload, such as transaction ID, status, customer ID, totals, and line items. It is useful when an application needs one structured response.
>
> - **Relational tables** store data in rows and columns with keys, constraints, and data types. That structure helps analysts filter, aggregate, join customers to transactions, enforce data quality rules, and answer risk or operations questions with SQL.
>
> - **JSON Relational Duality** lets Oracle Database return relational data as JSON documents without copying it into a separate document database. The application gets JSON, while analysts keep SQL access to the same transaction data.
>
> - A **Duality View** is the database object that defines how relational rows are returned as a JSON document. In this lab, ORDERS_DV maps rows from ORDERS and ORDER_ITEMS into one transaction JSON document.
>
> - **Projection** means returning selected JSON fields as SQL columns. In this lab, SQL/JSON projection pulls values such as transaction ID and status from the JSON document so analysts can filter, sort, and join them in SQL.

</details>

The image below shows the **Transaction Operations** page in its JSON document view. The application can display one transaction as a nested JSON document, while operations teams can still use relational transaction, client, product, case, and service data for analysis.

![Transaction API Document View](images/transaction-json-duality.png " ")

### Objectives

- Read transaction data as a JSON document from a duality view.
- Explain why JSON Relational Duality avoids a separate document copy.
- Use SQL/JSON projection to return document fields as SQL columns for investigation.

Estimated Time: **10 minutes**

### Business Scenario

| Step | Finance focus |
| --- | --- |
| Business Problem | Application teams want transaction data as JSON, while risk teams need the same transaction data available for SQL review and controls. |
| Technical Challenge | Developers need API-friendly JSON without copying transaction records into a separate document store. |
| Persona Focus | Application developers can serve JSON payloads while database developers keep the transaction rows available for SQL access, controls, and investigation. |
| What You Will See | JSON Relational Duality exposes transaction documents without duplicating data. |
| Database Capability | Duality views and SQL/JSON functions expose JSON and relational access together. |
| Outcome | Transaction operations can serve application and analytics needs from one source. |

Persona focus: You are the application and database developer showing how Seer Bank can return transaction data as JSON while keeping the same data available for SQL analysis.

### What Is a Duality View?

A **JSON Relational Duality View** defines how relational rows appear as a JSON document. The data still lives in relational tables, with keys, constraints, SQL access, and controls. The duality view lets Oracle Database return that data as JSON.

For this lab, the workshop database already includes `ORDERS_DV`. The duality view maps relational columns into a JSON structure like this:

| JSON field | Relational source |
| --- | --- |
| `_id` | `ORDERS.ORDER_ID` |
| `customerId` | `ORDERS.CUSTOMER_ID` |
| `status` | `ORDERS.ORDER_STATUS` |
| `items[]` | Related rows from `ORDER_ITEMS` |

That mapping tells Oracle Database how to present an order row and its related line-item rows as one JSON transaction document. The application can read a transaction in the shape developers prefer for APIs, while analysts can still query the underlying rows with SQL.

Without JSON Relational Duality, teams often hand-build JSON in application code or copy transaction data into a separate document store. Here, Oracle Database can return JSON while the transaction data remains available for SQL.

## Task 1: Inspect document-shaped transactions

First, inspect the transaction data in the JSON format an application can consume directly:

1. Run this query:

    > **SQL Worksheet reminder:** Need a reminder on how to open and use the SQL Worksheet? Return to [Getting Started Task 2: Open SQL Worksheet](?lab=getting-started#Task2:OpenSQLWorksheet) for the step-by-step graphic showing where to paste and run SQL statements.

    You are viewing a transaction the way an application can consume it: as a JSON document. The SQL selects from the JSON Relational Duality view `ORDERS_DV` and uses `JSON_SERIALIZE(... PRETTY)` so SQL Worksheet displays the document shape clearly.

    <details>
    <summary><strong>Why this matters: Oracle's converged approach helps here</strong></summary>

    > In a fractured environment, the application team might keep JSON documents in one system while analysts use relational tables in another. That creates a synchronization problem: which copy is current, which one is governed, and which one should an investigation trust?
    >
    > Oracle JSON Relational Duality avoids that split. The JSON document and the relational rows are two ways of reading the same transaction data.

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

    Risk and operations teams can inspect the same transaction from two angles: JSON for the application and SQL rows for analysis.

## Task 2: Project JSON fields with SQL

Now return selected JSON fields as SQL columns so the same transaction can be reviewed in a table and joined to client data:

1. Run this SQL/JSON projection query:

    You are seeing the main advantage of JSON Relational Duality: the JSON document that works well for an application is still available for SQL analysis. The same transaction data can be returned as JSON, filtered in SQL, and joined to client data without creating another copy.

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
    WHERE JSON_VALUE(od.data, '$._id' RETURNING NUMBER) IS NOT NULL
    ORDER BY transaction_id
    FETCH FIRST 10 ROWS ONLY;
    </copy>
    ```

    **Expected output: JSON Field Projection**

    The exact email values may differ after a data refresh, but `Transaction Status` and `Client Email` should not be blank.

    | Transaction Id | Transaction Status | Client Email |
    | --- | --- | --- |
    | 1 | confirmed | jessica.parker687@example.com |
    | 2 | processing | emily.rogers707@example.com |
    | 3 | routed | kimberly.cook129@example.com |
    | 4 | completed | timothy.harris240@example.com |
    | 5 | completed | matthew.gonzalez792@example.com |
    | 6 | completed | amanda.perez1387@example.com |
    | 7 | cancelled | ava.lewis1977@example.com |
    | 8 | pending | layla.green1809@example.com |
    | 9 | confirmed | sandra.morales125@example.com |
    | 10 | processing | leo.mendoza174@example.com |


2. Review the columns returned from the JSON document.
    This query returns selected fields from the JSON document as SQL columns and joins them to client data.

    `Transaction Id` and `Transaction Status` are projected from the JSON document into the result table. The document stores the client reference as `customerId`, so the query joins back to `CUSTOMERS` to return `Client Email`.

    The business value is consistency. A developer can serve a clean transaction document to an application, while a risk analyst can still ask normal SQL questions about transaction status and customer contact details. Both users are working with the same transaction data, returned in the format each task needs.

## Next Steps

Congratulations on completing the JSON duality lab. You used JSON Relational Duality to work with finance transaction data as both application-friendly documents and SQL-queryable rows. For a deeper hands-on workshop focused on JSON in Oracle Database, open the [JSON Relational Duality LiveLabs workshop](https://livelabs.oracle.com/ords/r/dbpm/livelabs/view-workshop?clear=RR,180&wid=3797).

## Acknowledgements

* **Authors** - Pat Shepherd, Linda Foinding
* **Contributors** - Teodor Nechita
* **Last Updated By/Date** - Oracle Database Product Management, August 2026
