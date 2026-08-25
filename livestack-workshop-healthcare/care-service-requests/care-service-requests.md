# Care Service Requests with JSON Relational Duality

## Introduction

One elevated signal leads Jessica to service request `170104`. An application developer needs to show the whole request without making the team assemble several screens. The application wants one JSON document with the request and its line items. An analyst still needs rows and columns for filtering, joining, and reporting.

The same challenge appears when an online order looks like one object to a customer. The company processing it may store many related records. Its order page groups the customer, shipment, payment, and items, while structured tables protect keys, data types, and relationships.

**JSON Relational Duality** gives request `170104` both useful shapes from the same stored facts. The developer can serve one application document. Jessica can query the related request, care site, logistics site, and item rows without waiting for a second copy.

<details>
<summary><strong>Key terms: JSON, relational table, duality view, and projection</strong></summary>

> - **JSON**, or JavaScript Object Notation, is a text format for named fields, nested objects, and lists. Applications often exchange JSON through APIs. One document can carry a complete business item, such as a request and all its line items.
> - A **relational table** stores facts in rows and columns under defined rules. Keys connect related records, while data types and constraints protect the values. Tables work well for dependable joins, filters, and updates across many records.
> - A **JSON Relational Duality View** maps related table rows into one JSON document. It also defines how the document maps back to the relational model. This approach avoids a separate JSON copy that needs its own refresh process.
> - A **projection** is the shape chosen for a particular consumer. A mobile application may need nested JSON, while an analyst may prefer a flat SQL result. Both projections can describe the same request without changing the underlying facts.

</details>

![Healthcare service-request page](images/healthcare-service-request.png " ")

*Figure 1: Request 170104 appears as one JSON document in the application.*

### Objectives

- Read request 170104 as a JSON document.
- Review the same request as relational rows.
- Match the JSON line items to their source records.
- Explain why duality avoids a second document copy.

Estimated Time: **12 minutes**

### Business Scenario

| Step | Healthcare focus |
| --- | --- |
| Business Problem | An application and an analyst need the same service request in different shapes. |
| Technical Challenge | Separate relational and document copies can become inconsistent. |
| Persona Focus | An application developer serves the request while a data analyst reviews its source rows. |
| What You Will See | One request appears as JSON and as normal SQL results. |
| Database Capability | JSON Relational Duality and SQL keep document and relational access connected. |
| Outcome | The application and analyst use one governed request source. |
{: title="Service request scenario"}

**Persona focus:** You work with an application developer to serve one complete request document. At the same time, you preserve relational access to the same facts.

## Task 1: Inspect the request document

Start with the shape an application can consume.

1. Run the JSON query.

    > **SQL Worksheet reminder:** Return to [Getting Started Task 2: Open SQL Worksheet](?lab=getting-started#Task2:OpenSQLWorksheet) if you need help running SQL.

    `CARE_SERVICE_REQUESTS_DV` is the JSON Relational Duality View. Its `DATA` column presents the request document.

    `JSON_VALUE` selects request `170104` by its document ID. `JSON_SERIALIZE(... PRETTY)` formats the JSON so it is easier to read in SQL Worksheet.

    <details>
    <summary><strong>Why this matters: no synchronization job</strong></summary>

    > A separate document database would require Seer Health to copy the request, copy its line items, keep both versions current, and protect both systems.
    >
    > A duality view creates the document shape over relational tables. The JSON and SQL access paths stay connected to the same request.

    </details>

    ```sql
    <copy>SELECT JSON_SERIALIZE(data PRETTY) AS request_document
    FROM care_service_requests_dv
    WHERE JSON_VALUE(data, '$._id' RETURNING NUMBER) = 170104;</copy>
    ```

    **Expected output: Request JSON**

    ```json
    {
      "_id": 170104,
      "requestingCareSiteId": 1002,
      "requestStatus": "DELIVERED",
      "requestValue": 943.89,
      "lineItems": [
        ... 5 items ...
      ]
    }
    ```
    {: title="Request JSON"}

2. Read the document shape.

    The top fields describe the request. The `lineItems` array holds five related items. Oracle also adds a `_metadata` section used to manage the document.

    The application receives one payload. The source data still lives in relational request and item tables.

## Task 2: Review the same request with SQL

Now inspect the request in business-friendly rows.

1. Run the request summary query.

    `CARE_SERVICE_REQUESTS_V` is a governed relational view for people who analyze service requests with SQL. It joins each request to the care-site and logistics-site tables, then presents readable names and locations beside the request facts. This matters because analysts and reports can use one stable business shape without repeating the joins, exposing implementation details, or trying to remember what internal IDs mean.

    ```sql
    <copy>SELECT service_request_id,
           requesting_care_site,
           care_site_location,
           request_status,
           request_value,
           logistics_name
    FROM care_service_requests_v
    WHERE service_request_id = 170104;</copy>
    ```

    **Expected output: Request summary**

    | Request Id | Care Site | Location | Status | Value | Logistics Site |
    | ---: | --- | --- | --- | ---: | --- |
    | 170104 | Penelope Mendoza | Charlotte, NC | DELIVERED | 943.89 | Etna Midwest Specialty Warehouse |
    {: title="Request 170104 summary"}

2. Read the relational result beside the JSON document.

    The status and value are the same in both results because both access paths begin with request `170104`. The view adds Penelope Mendoza’s readable name, the Charlotte location, and the Etna logistics assignment, which are useful for a report but do not need to be repeated inside every source row.

    The important point is that the database did not create a second request for the analyst. It presented the same governed facts in a different shape. If an approved update changes the source request, both the relational view and the duality document can reflect that change instead of waiting for a copy-and-sync process.

3. Run the line-item query.

    `HC_CARE_SERVICES` is the shared service catalog behind the workshop. Each row gives a service ID a readable name, category, provider network, description, value, and embedding. Request items store that service ID instead of repeating the complete service description in every line. The foreign-key relationship also prevents a request item from pointing to a service that does not exist. The join replaces the compact ID with the name a person expects to see.

    `LINE_VALUE` is a virtual column. Oracle calculates it as quantity multiplied by unit cost.

    ```sql
    <copy>SELECT i.item_id,
           s.service_name,
           i.quantity,
           i.unit_cost,
           i.line_value
    FROM hc_request_items i
    JOIN hc_care_services s
      ON s.service_id = i.service_id
    WHERE i.request_id = 170104
    ORDER BY i.item_id;</copy>
    ```

    **Expected output: Request line items**

    | Item Id | Service | Quantity | Unit Cost | Line Value |
    | ---: | --- | ---: | ---: | ---: |
    | 4 | Digital Pathology Slide Batch | 1 | 310.00 | 310.00 |
    | 5 | Tamper-Evident Carton Batch | 2 | 95.00 | 190.00 |
    | 6 | qPCR Respiratory Panel | 1 | 185.00 | 185.00 |
    | 7 | Infusion Center Slot Bundle | 1 | 125.00 | 125.00 |
    | 8 | Infusion Center Slot Bundle - Continuity Lot 2 | 1 | 133.89 | 133.89 |
    {: title="Request line items"}

4. Compare the two access shapes.

    The five line values add up to 943.89, which matches the request value in both the summary row and JSON document.

    The application gets one useful document. The analyst can filter, join, total, and review the source rows with SQL. Both users work from the same governed request.

## Next Steps

You used JSON Relational Duality to read healthcare request data as both an application document and relational rows. For a deeper workshop about JSON Relational Duality, open the [JSON Relational Duality LiveLabs workshop](https://livelabs.oracle.com/ords/r/dbpm/livelabs/view-workshop?clear=RR,180&wid=3797).

## Acknowledgements

* **Author** - Linda Foinding, Principal Database Product Manager
* **Last Updated By/Date** - Linda Foinding, Principal Database Product Manager, August 2026
