# Lab 6: Subscriber Service Orders with JSON Relational Duality

## Introduction

A subscriber service order has to serve many audiences. Care teams need the customer view, field teams need dispatch details, operations teams need SQL, and applications often want JSON. JSON Relational Duality lets those groups work from the same transaction instead of separate copies.

Estimated Time: 10 minutes

| Operating Story | Detail |
| --- | --- |
| Business Problem | Care and partner teams need document-shaped order access while operations teams need relational truth. |
| Technical Challenge | Duplicating service orders into document stores creates synchronization and governance risk. |
| Persona Focus | Service operations manager, care lead, and API platform owner. |
| What You Will Learn | JSON Relational Duality can expose the same service order as relational rows and a nested JSON document. |
| Database Capability | JSON Relational Duality Views, SQL/JSON, relational constraints. |
| Outcome | The same transaction can serve operational SQL and application document access. |
{: title="What this lab covers"}

**Persona focus:** You are the API platform owner confirming that document-style service-order access does not require a separate document database.

### Objectives

- Query a service order through relational columns.
- Inspect the line items that explain order value and service mix.
- Return the same order as a JSON document for application-style access.

The image below is the service orders page. Care teams use this area to inspect order status, subscriber context, and operational value. The SQL in this lab shows how the same order can serve both operational review and application access.

![Service orders page](images/service-orders-page.png)

The concept diagram below introduces JSON Relational Duality. It shows how one Oracle transaction can appear as relational rows for analysts and as a JSON document for applications.

![Lab 6: Subscriber Service Orders with JSON Relational Duality concept diagram](images/json-duality-flow.svg)

## How This Lab Fits the Story

You inspect the service order that records operational action. The relational and JSON queries show how one transaction can support care teams, field dispatch, and API-style document access at the same time.

## Scene Evidence

Use the screenshot to orient the service-order workflow. The SQL tasks below show how one Oracle transaction can look like rows to an analyst and like a document to an application.

The image below shows the service order document view. Application teams can use this shape without forcing operations teams to give up relational truth. The SQL in this task returns the document-style representation from Oracle.

![Service order JSON document](images/service-order-json-document.png)

## Task 1: Query a service order relationally

1. Run this SQL block.

    This query starts with the traditional operational view of one service order. It selects the order identifier, subscriber, location, status, value, and dispatch cost from the service order view. Look for one clear order row that care and operations teams can discuss together.

    ```sql
    <copy>
    SELECT service_order_id, subscriber_name, city, state_province, service_status, service_value, dispatch_cost
    FROM seer_comms_service_orders_v
    WHERE service_order_id = 2870;
    </copy>
    ```

    **Expected output: Service order selected for duality review**

    | Service Order ID | Subscriber Name | City | State Province | Service Status | Service Value | Dispatch Cost |
    | ---: | --- | --- | --- | --- | ---: | ---: |
    | 2870 | Jack Hill | Portland | Oregon | Completed | 4160 | 14.99 |
    {: title="Service order selected for duality review"}

## Task 2: Inspect line items for the same order

1. Run this SQL block.

    This query verifies the detail rows that make up the order total and service mix. It joins order items to products so the result includes service names, categories, quantities, and line totals. Line items matter because they explain what the subscriber is actually receiving.

    ```sql
    <copy>
    SELECT oi.order_id AS service_order_id,
       p.product_name AS service_name,
       p.category AS service_category,
       oi.quantity,
       oi.unit_price,
       oi.line_total
    FROM order_items oi
    JOIN products p ON p.product_id = oi.product_id
    WHERE oi.order_id = 2870
    ORDER BY oi.item_id;
    </copy>
    ```

    **Expected output: Line items inside the service order**

    | Service Order ID | Service Name | Service Category | Quantity | Unit Price | Line Total |
    | ---: | --- | --- | ---: | ---: | ---: |
    | 2870 | LTE Backup Gateway | Devices | 2 | 115 | 230 |
    | 2870 | Fraud Resolution Case | Security | 2 | 45 | 90 |
    | 2870 | Edge Compute Reservation | Enterprise Connectivity | 3 | 640 | 1920 |
    {: title="Line items inside the service order"}

## Task 3: Return the service order document

1. Run this SQL block.

    This query returns the same order through the JSON document shape used by application workflows. `JSON_SERIALIZE` formats the document, and `JSON_VALUE` filters to the order you already inspected relationally. The application gets a nested order document, while Oracle preserves the relational source of truth.

    ```sql
    <copy>
    SELECT JSON_SERIALIZE(data PRETTY) AS service_order_document
    FROM orders_dv
    WHERE JSON_VALUE(data, '$._id') = '2870';
    </copy>
    ```

    **Expected output: Document view of the same service order**

    | Service Order Document |
    | --- |
    | JSON document for service order 2870 with subscriber, status, total, dispatch cost, and nested line items. |
    {: title="Document view of the same service order"}

The JSON document and relational rows come from the same Oracle transaction model. That is the practical value of JSON Relational Duality: application teams get document-style access, and operations teams keep SQL truth.



## Learn More

- See `ORACLE_REFERENCE_LINKS.md` in the supporting files directory for official Oracle documentation links.

## Acknowledgements

- **Author** - Oracle LiveLabs Team
