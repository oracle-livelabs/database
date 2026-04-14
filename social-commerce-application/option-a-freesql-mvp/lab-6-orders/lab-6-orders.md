# Lab 5: Orders

## Introduction

This lab focuses on order lifecycle analytics and JSON projections used by app and API layers.

Estimated Time: 10 minutes

### Objectives

In this lab, you will:
- Analyze order status distribution and revenue.
- Build JSON documents directly from relational order data.
- Connect social attribution to order outcomes.

## Task 1: Analyze Order Lifecycle and Attribution

This task summarizes order status performance and social-attributed demand. It is important because lifecycle visibility and attribution are core signals in the Orders experience.

1. Run this SQL.

    ```
    <copy>
    SELECT order_status,
           COUNT(*) AS orders_count,
           ROUND(SUM(order_total), 2) AS total_revenue,
           COUNT(CASE WHEN social_source_id IS NOT NULL THEN 1 END) AS social_orders
    FROM orders
    GROUP BY order_status
    ORDER BY total_revenue DESC;
    </copy>
    ```

    <iframe
            class="freesql-embed"
            data-freesql-src="https://freesql.com/embedded/?layout=vertical&compressed_code=H4sIAAAAAAAC%252F22PywqDMBBF9%252F2Ku9Sii3bblY3pAzQpiVK6EtEshGIgj35%252FNRZaobO7zJnDHQCQtKCkgja9Mo11rfM22eA7hNesirYxMrlAtum0H90KEhOUR7Iuo8XjtGufcYJ9OAupMeqlRq%252F%252ByEkmKe4XymB1N0yo1d50qhl6XCUYr8DqokA1EztQlgfrh106BelJ8BI%252F%252BTzVuuH4WD0XNlzkVMybVTXkVJLDJk0pJ28AGybzGwEAAA%253D%253D&code_language=SQL&code_format=false"
            height="460px"
            width="100%"
            scrolling="no"
            frameborder="0"
            allowfullscreen="true"
            name="FreeSQL Embedded Playground"
            title="FreeSQL"
            style="width: 100%; border: 1px solid #e0e0e0; border-radius: 12px; overflow: hidden;"
        >FreeSQL Embedded Playground</iframe>

2. Identify which status carries the highest total_revenue.

## Task 2: Build JSON Order Projections

This step transforms relational rows into API-ready JSON documents directly in SQL. That pattern matters because the demo showcases converged data access without extra transformation layers.

1. Run this SQL.

    ```
    <copy>
SELECT JSON_OBJECT(
         'orderId' VALUE o.order_id,
         'status' VALUE o.order_status,
         'total' VALUE o.order_total,
         'socialSourceId' VALUE o.social_source_id,
         'items' VALUE (
           SELECT JSON_ARRAYAGG(
                    JSON_OBJECT(
                      'productId' VALUE oi.product_id,
                      'quantity' VALUE oi.quantity,
                      'lineTotal' VALUE oi.line_total
                    )
                  )
           FROM order_items oi
           WHERE oi.order_id = o.order_id
         )
       ) AS order_doc
FROM orders o
ORDER BY o.created_at DESC
FETCH FIRST 5 ROWS ONLY;
    </copy>
    ```

    <iframe
            class="freesql-embed"
            data-freesql-src="https://freesql.com/embedded/?layout=vertical&compressed_code=H4sIAAAAAAAC%252F4VRy27DIBC88xV7cyI1vvVU9UAcnIfcIIHbyCcLAQckJ7Q2PvTv6%252FiRgpuoe0Kzs7PDLCcZSXI4cHos6frQvRcIpopsrXS9VxF84OydgI17oDTqySM1Tri2mXMG1Oc560Q1p%252FVgoGalERW3bS21v3nAy6ZvzBwYp883A55%252FAO59DzOGC7zdBoRb3U8gqOiztqqVzrNl4hELHYVjX624OOO%252BvakJejhTmYvOg8BMfMWGwO5OLdE%252FWMroG4wXvCbWafrt046wfs90ZHj1Lo7%252Bai4B81FPWYl%252B5TtlRNmGMFgXnYSstXBalcLBhvAEpSRPdpDuGc%252FhGRg9caDHrHhBqxWhyQ%252FZN1uZkgIAAA%253D%253D&code_language=SQL&code_format=false"
            height="460px"
            width="100%"
            scrolling="no"
            frameborder="0"
            allowfullscreen="true"
            name="FreeSQL Embedded Playground"
            title="FreeSQL"
            style="width: 100%; border: 1px solid #e0e0e0; border-radius: 12px; overflow: hidden;"
        >FreeSQL Embedded Playground</iframe>

2. Review how each JSON document groups order header and line-item data.

## Task 3: Check Your Understanding

Use this short review to confirm how relational and JSON patterns work together. The key takeaway is that one SQL workflow can serve both analytics and application payloads.

```quiz
Q: Why generate JSON inside SQL for orders?
* It reduces transformation work for downstream API and UI consumers.
- It disables joins.
- It replaces foreign keys.
> Correct. SQL can shape output into API-friendly documents directly.

Q: Why track social_source_id in order records?
* It enables attribution from social activity to completed revenue.
- It is only used for dashboard colors.
- It is required to create order items.
> Correct. Attribution metrics depend on this linkage.
```

## Acknowledgements
* **Author** - Pat Shepherd + Codex
* **Last Updated By/Date** - Codex, April 2026
