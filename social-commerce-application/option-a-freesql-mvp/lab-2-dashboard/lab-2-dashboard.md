# Lab 2: Dashboard

## Introduction

This lab builds SQL KPIs that mirror the dashboard metrics used by the app.

Estimated Time: 10 minutes

### Objectives

In this lab, you will:
- Generate order, revenue, and attribution KPIs.
- Build category rollups for business reporting.
- Identify where social influence contributes to revenue.

## Task 1: Build Top-Level KPI Metrics

1. Run this SQL.

    ```
    <copy>
    SELECT COUNT(*) AS total_orders,
           ROUND(SUM(order_total), 2) AS total_revenue,
           ROUND(AVG(order_total), 2) AS avg_order_value,
           COUNT(CASE WHEN social_source_id IS NOT NULL THEN 1 END) AS social_orders
    FROM orders;
    </copy>
    ```

    <iframe
            class="freesql-embed"
            data-freesql-src="https://freesql.com/embedded/?layout=vertical&compressed_code=H4sIAAAAAAAC%252F22PywqDMBBF937FXWrRRbvtSmL6gJiAie0yiIYiSAPx8f21SaGlOLthzrkzAwCSMkoUiKi5incJconJTs2greuMG9MI36pWqIhlXcZ%252BqD2YpDj8aM4s5jmbDS%252B%252FnTe9ZnmEZXpphj8znEVySXG%252FUI7Rtv26ZLSza43uO1wluFDgNWNQb2IPyguf%252B2HDHz70VIkSoT9GWUYFeQGylMhxAgEAAA%253D%253D&code_language=SQL&code_format=false"
            height="460px"
            width="100%"
            scrolling="no"
            frameborder="0"
            allowfullscreen="true"
            name="FreeSQL Embedded Playground"
            title="FreeSQL"
            style="width: 100%; border: 1px solid #e0e0e0; border-radius: 12px; overflow: hidden;"
        >FreeSQL Embedded Playground</iframe>

2. Record `social_orders` for comparison in later labs.

## Task 2: Build Category Revenue and Social Attribution

1. Run this SQL.

    ```
    <copy>
SELECT p.category,
       COUNT(DISTINCT o.order_id) AS order_count,
       ROUND(SUM(oi.line_total), 2) AS category_revenue,
       ROUND(SUM(CASE WHEN o.social_source_id IS NOT NULL THEN oi.line_total ELSE 0 END), 2) AS social_revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY category_revenue DESC;
    </copy>
    ```

    <iframe
            class="freesql-embed"
            data-freesql-src="https://freesql.com/embedded/?layout=vertical&compressed_code=H4sIAAAAAAAC%252F22QQUvEMBCF7%252FkVc%252BzCbhGv4mFNola6iTQpsqdS0iCB2ilpKvjvzbbZpYi5veG9%252BfJG8ZJTDWNu2mA%252F0f%252FsCayPylrojBVKFyI6MEffWd%252B4bgdHBaswOA%252FhlqhigmWqPmXo8t4NtgkY2n63h%252Fslc0U03n7bYbb%252FBOlRcfh45SLyJjSu7ZsJZ29s5EKhQEgNoi5L0ItniwFexuwdcMFuxLQi8chzJU%252FrzydA8iYLkXq4YL%252FiyIFcll6bwuOm9uofPXazCROMF%252B%252BYJ53MbqPJS6z1Dk%252FnzXGJrBivLrO%252FtwDGFX0ghwOX9Beofd35lAEAAA%253D%253D&code_language=SQL&code_format=false"
            height="460px"
            width="100%"
            scrolling="no"
            frameborder="0"
            allowfullscreen="true"
            name="FreeSQL Embedded Playground"
            title="FreeSQL"
            style="width: 100%; border: 1px solid #e0e0e0; border-radius: 12px; overflow: hidden;"
        >FreeSQL Embedded Playground</iframe>

2. Identify the highest revenue category and the highest social_revenue category.

## Task 3: Check Your Understanding

```quiz
Q: Why separate category_revenue and social_revenue in one query?
* It shows both total business performance and social-attributed contribution.
- It removes the need for GROUP BY.
- It replaces order-level analytics.
> Correct. You can compare channel contribution without running multiple disconnected reports.

Q: Which metric best captures monetization efficiency?
* Average order value
- Number of SQL comments
- Count of brands in the table
> Correct. Average order value helps assess revenue quality, not just volume.
```

## Acknowledgements
* **Author** - Pat Shepherd + Codex
* **Last Updated By/Date** - Codex, April 2026
