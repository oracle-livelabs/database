# Service Request Workbench with JSON Relational Duality

## Introduction

After the **Command Center** review, **Maria Santos** needs one complete **Western Slope request**. The application wants a document with the request header and nested line items, while operations analysts still need relational rows for filtering, joins, and governance.

You are the application and database developer supporting **Maria**. In this lab, you inspect the same request through a **JSON Relational Duality** view and then project its document fields into SQL columns. Both shapes come from one governed source.

<details>
<summary><strong>Key terms: JSON, relational tables, duality view, and projection</strong></summary>

> - **JSON** is a document format that can carry a complete request payload, including a header and nested service lines.
>
> - **Relational tables** store requests and line items as governed rows with keys, constraints, and joinable columns.
>
> - A **JSON Relational Duality view** maps relational rows into an application-friendly JSON document without creating a separate document copy.
>
> - **Projection** extracts selected document fields as SQL columns. It lets analysts filter and join the same data that an application consumes as JSON.

</details>

The diagram shows how `ORDERS_DV` presents one relational request and its line items as a JSON document.

![Service request JSON Relational Duality flow](images/service-request-duality-flow.svg " ")

The first application image below is the Service Request Workbench in its relational queue view. It gives Maria a reviewable list of residents, request status, service value, assigned sites, and request-line counts. Selecting a request lets the application switch between its relational details and JSON document shape. The full application screen shows more requests than the compact learner dataset, but both use the same relational-and-document pattern.

![Service Request Workbench relational queue](images/service-request-workbench.png " ")

The inherited physical name `ORDERS_DV` remains in the current stack. In the State and Local Government application, it represents public-service requests. The application displays the business alias `SERVICE_REQUESTS_DV`, while learner SQL uses the physical `ORDERS_DV` view. The next image shows the document form that the first SQL query reads.

![Service Request Workbench JSON document](images/service-request-json-duality.png " ")

### Objectives

- Read a service request as the application consumes it: one JSON document with a request header and nested service lines.
- Project selected document fields into business-readable SQL columns for analysis.
- Explain how **JSON Relational Duality** avoids a second document copy for sensitive resident-service data.

Estimated Time: **10 minutes**

### Business Scenario

| Step | State and local government focus |
| --- | --- |
| Business Problem | Maria needs a complete request record that applications and analysts can both use. |
| Technical Challenge | Teams need JSON payloads without duplicating requests into another database. |
| Persona Focus | Application and database developers support the regional request review led by Maria. |
| What You Will Do | Query `ORDERS_DV` and join projected fields to SLED semantic views. |
| Database Capability | JSON Relational Duality and SQL/JSON expose two access shapes over one source. |
| Outcome | The application gets JSON while operations retain governed relational evidence. |

**Persona focus:** You are the developer showing Maria that document access does not weaken relational control.

## Task 1: Inspect a document-shaped service request

Start with the request as the application consumes it, so the document shape is clear before you project fields into SQL.

1. Run the document query to review one complete service-request payload:

    > **SQL Worksheet reminder:** Need a reminder on how to open and use SQL Worksheet? Return to [Getting Started Task 2: Open SQL Worksheet](/workshops/sandbox/index.html?lab=getting-started#Task2:OpenSQLWorksheet).

    `ORDERS_DV` is the JSON Relational Duality view defined by the current stack. `JSON_SERIALIZE(... PRETTY)` formats the document for review. The database assembles the header from `ORDERS` and the nested `items` array from `ORDER_ITEMS`.

    <details>
    <summary><strong>Why this matters: no synchronization gap</strong></summary>

    > A separate document database would require another copy of the request, another security model, and a synchronization process. A duality view gives the application a document while the relational source remains authoritative.

    </details>

    ```sql
    <copy>
    SELECT JSON_SERIALIZE(data PRETTY) AS service_request_document
    FROM orders_dv
    WHERE JSON_VALUE(data, '$._id' RETURNING NUMBER) = 1;
    </copy>
    ```

    **Expected output: Service Request Document**

    Oracle Database adds generated `_metadata values` such as an etag and as-of token. Those values can change between executions. Focus on the validated business portion of the document below.

    | Service Request Document |
    | --- |
    | { "\_id" : 1, "customerId" : 1, "status" : "processing", "total" : 12500, "routingCost" : 120, "urgencyScore" : 92, "createdAt" : "2026-06-18T08:00:00", "items" : [ { "itemId" : 1, "productId" : 1, "quantity" : 1, "serviceValue" : 12500 } ] } |

2. Review the document shape.

    The root fields describe the request. The nested `items` array describes its service lines. Maria can review one complete payload while keys and constraints still live in the relational source.

    The relational tab below shows the same request as joined business fields. Changing the access shape does not create new records or expand Maria's authorized scope.

    ![Relational detail for the same service request](images/service-request-relational-detail.png " ")

3. 🎯 **Interactive challenge: Compare a completed request document.**

    Starting with the baseline query above, change the request ID filter from `1` to `5` to investigate a request at a different lifecycle stage. Run your revised query. Which business fields indicate whether request 5 should remain in the same active-review queue as request 1?

    **Expected output: Completed Request Document**

    The governed business fields should identify request 5 as `delivered`, with an urgency score of `42` and one nested line for product ID `6`. Generated metadata values such as the etag and as-of token can change between executions.

    <details>
    <summary><strong>Challenge answer: Use lifecycle and urgency together</strong></summary>

    > Request 5 is already `delivered` and has a lower urgency score than the baseline `processing` request, so it should not automatically receive the same active-resolution priority. Those fields support a human queue decision; they do not replace case review. Oracle AI Database 26ai keeps the JSON document, relational request rows, and operational context together, so teams can investigate without copying sensitive resident-service data into disconnected systems.

    If you need the runnable solution, use this query:

    ```sql
    <copy>
    SELECT JSON_SERIALIZE(data PRETTY) AS service_request_document
    FROM orders_dv
    WHERE JSON_VALUE(data, '$._id' RETURNING NUMBER) = 5;
    </copy>
    ```

    </details>

## Task 2: Project document fields into SQL

Now project selected JSON fields into normal SQL columns and join them to public-service context.

1. Run the projection query so Maria can compare the application document with reviewable request, resident, and service fields:

    `JSON_VALUE` extracts the request ID and resident ID. The query joins those values to `SLED_SERVICE_REQUESTS_V`, `SLED_RESIDENTS_V`, and `SLED_SERVICE_REQUEST_LINES_V`. These views hide inherited physical names and present the request in public-service language.

    ```sql
    <copy>
    SELECT JSON_VALUE(od.data, '$._id' RETURNING NUMBER) AS service_request_id,
           requests.request_status,
           residents.resident_display_name,
           lines.service_name,
           lines.requested_quantity,
           requests.service_value_exposure
    FROM orders_dv od
    JOIN sled_service_requests_v requests
      ON requests.service_request_id =
         JSON_VALUE(od.data, '$._id' RETURNING NUMBER)
    JOIN sled_residents_v residents
      ON residents.resident_id =
         JSON_VALUE(od.data, '$.customerId' RETURNING NUMBER)
    JOIN sled_service_request_lines_v lines
      ON lines.service_request_id = requests.service_request_id
    ORDER BY service_request_id
    FETCH FIRST 5 ROWS ONLY;
    </copy>
    ```

    **Expected output: Projected Request Evidence**

    | Service Request Id | Request Status | Resident Display Name | Service Name | Requested Quantity | Service Value Exposure |
    | --- | --- | --- | --- | --- | --- |
    | 1 | in progress | Elena Garcia | Medicaid Eligibility Review | 1 | 12500 |
    | 2 | pending | Jordan Lee | Benefits Appointment Scheduling | 1 | 8000 |
    | 3 | confirmed | Maya Patel | Building Permit Inspection | 1 | 4500 |
    | 4 | routed | Noah Williams | Road Repair Request | 1 | 6000 |
    | 5 | completed | Sofia Martinez | Emergency Shelter Referral | 1 | 3000 |

2. Compare the two access shapes.

    The application can read one nested document. The analyst can project and join the same request into reviewable columns. Colorado avoids duplicate ownership of sensitive resident-service data while preserving the access shape each team needs.

## Acknowledgements

* **Author** - Oracle LiveLabs Team
* **Last Updated By/Date** - Oracle LiveLabs Team, August 2026
