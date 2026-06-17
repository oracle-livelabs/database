# Transaction and Case Documents with JSON Relational Duality

## Introduction

This lab uses **JSON Relational Duality** to inspect transaction-shaped documents over relational tables. Make the business value sharper: *Applications can consume document-style transaction payloads while analysts and database developers keep governed relational access for investigation.*

Transaction and case operations need both application-friendly documents and governed relational evidence. This lab shows how one transaction can be exposed as JSON for an application while remaining queryable with SQL for analysts and database developers.

This matters after the dashboard lab because a KPI is not enough for review. When an analyst or application needs a specific transaction, the database can return an API-shaped document and still preserve the relational joins needed for investigation.

![Transaction API Document View](images/transaction-json-duality.png " ")

### Objectives

- Read transaction documents from a duality view.
- Use SQL/JSON to project document fields.

Estimated Time: **10 minutes**

### Operating Story

| Step | Finance focus |
| --- | --- |
| Business Problem | Application teams want document-shaped transaction data, while risk teams need relational controls. |
| Technical Challenge | Developers need API-friendly JSON without copying transaction records into a separate document store. |
| Persona Focus | Application developers serve document payloads while database developers preserve relational governance and SQL access. |
| What You Will Prove | JSON Relational Duality exposes transaction documents without duplicating data. |
| Database Capability | Duality views and SQL/JSON functions expose JSON and relational access together. |
| Outcome | Transaction operations can serve application and analytics needs from one source. |

Persona focus: You are the application/database developer showing how Seer Bank can expose transaction documents while keeping governed relational evidence intact.

## Task 1: Inspect document-shaped transactions

Perform the following set of steps to inspect a document-shaped transaction from the duality view:

1. Run this query:

    ```sql
    <copy>
    SELECT JSON_SERIALIZE(data PRETTY) AS transaction_document
    FROM orders_dv
    FETCH FIRST 1 ROW ONLY;
    </copy>
    ```

    **Expected output: Transaction Document Excerpt**

    | Transaction Document |
    | --- |
    | { "\_id" : 519, "\_metadata" : { "etag" : "A373EE416A88F30340355B478ADC0179", "asof" : "00002AB7EFDA711D" }, "customerId" : 205, "status" : "cancelle... |


2. Expand the document in SQL Worksheet.
    The query reads the duality view as a document source. The database constructs the JSON shape from relational data, so the application gets a transaction payload without creating a second copy of the transaction record.

    The \_id value is stored in the JSON document while source data remains relational. Fields such as `customerId`, `status`, totals, timestamps, and line items give the application a document-shaped payload without copying the transaction to a separate document database.

    This is relevant to the workshop story because risk and operations teams can inspect the same transaction from two angles: API-ready JSON for the application and governed relational rows for analysis.

**Note:** Sample values may change after data refreshes or rebuilds. Focus on the expected result pattern and the business takeaway, not the exact values.

## Task 2: Project JSON fields with SQL

Perform the following set of steps to project JSON document fields back into SQL columns for review:

1. Run this SQL/JSON projection query:

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

    The exact email values may differ by load, but `Transaction Status` and `Client Email` should not be blank.

    | Transaction Id | Transaction Status | Client Email |
    | --- | --- | --- |
    | 1 | confirmed | client@example.com |
    | 2 | processing | client@example.com |
    | 3 | routed | client@example.com |
    | 4 | completed | client@example.com |
    | 5 | completed | client@example.com |
    | 6 | completed | client@example.com |
    | 7 | cancelled | client@example.com |
    | 8 | pending | client@example.com |
    | 9 | confirmed | client@example.com |
    | 10 | processing | client@example.com |


2. Review the columns returned from the JSON document.
    This query shows the reverse path: SQL can project fields back out of the document and join them to relational customer data. That lets analysts use the same application-facing document view without giving up relational filtering, ordering, and joins.

    `Transaction Id` and `Transaction Status` are projected from the JSON document. The document stores the client reference as `customerId`, so the query joins back to `CUSTOMERS` to return `Client Email`. This shows how the application can use document-shaped transaction data while analysts can still join to governed relational tables.

**Note:** Sample values may change after data refreshes or rebuilds. Focus on the expected result pattern and the business takeaway, not the exact values.

## Acknowledgements

* **Author** - Pat Shepherd, Senior Principal Database Product Manager
* **Contributor** - Linda Foinding, Principal Database Product Manager
* **Last Updated By/Date** - Oracle Database Product Management, June 2026
