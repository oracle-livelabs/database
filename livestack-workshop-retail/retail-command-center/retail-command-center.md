# Retail Command Center

## Introduction

A retail command center works only if the daily operating view is easy to trust. That gets difficult when orders, fulfillment, customer signals, product demand, returns exposure, analytics, and agent activity live in separate systems.

Oracle AI Database keeps the operational, analytical, JSON, in-memory, and AI-ready data close to the same retail schema. The application brings together live retail KPIs, customer signal velocity, revenue category detail, and product-level evidence. In SQL Worksheet, you inspect the database queries behind those views.

Estimated Time: 10 minutes

### Objectives

- Review dashboard KPIs as database-backed operating signals.
- Query trending products from social momentum and product data.
- Inspect revenue by category from orders and line items.
- Connect the command center to the downstream labs for trend, fulfillment, order, OML, Ask Data, and agent workflows.


## Task 1: Review dashboard operating metrics
1. Review the related application screen before you run the SQL.

    ![Retail Command Center dashboard with KPI cards and charts](images/command-center-dashboard.png " ")

    *Figure 1: Retail Command Center combines KPIs, customer signal velocity, revenue categories, and Oracle Internals.*

2. Run this KPI query.

    Use this query to connect the dashboard cards to trusted operational data. A **scalar subquery** is a query inside a query that returns one value, such as one count or one sum. This block selects from `DUAL`, Oracle's one-row helper table, and uses one scalar subquery per KPI. That works well for dashboard cards because each metric can come from the table that owns the evidence. Orders explain revenue, returns explain exposure, social posts explain demand spikes, and agent actions explain automation history.

    ```sql
    <copy>
    SELECT
      (SELECT COUNT(*) FROM orders) AS "Total Orders",
      (SELECT NVL(ROUND(SUM(order_total), 2), 0) FROM orders) AS "Retail Revenue",
      (SELECT COUNT(*) FROM return_requests WHERE status <> 'Closed') AS "Open Returns",
      (SELECT NVL(ROUND(SUM(return_value), 2), 0) FROM return_requests WHERE status <> 'Closed') AS "Return Exposure",
      (SELECT COUNT(*) FROM social_posts WHERE momentum_flag IN ('viral','mega_viral')) AS "Demand Spikes",
      (SELECT COUNT(*) FROM agent_actions) AS "Agent Actions"
    FROM dual;
    </copy>
    ```

    Expected output:

    | Total Orders | Retail Revenue | Open Returns | Return Exposure | Demand Spikes | Agent Actions |
    | ---: | ---: | ---: | ---: | ---: | ---: |
    | 3000 | 4235872.01 | 5 | 934.93 | 511 | 0 |
    {: title="Command Center KPIs"}

3. These metrics create the daily triage view. The user can see revenue, demand, return exposure, and agent activity without waiting for copied data or a separate dashboard mart.

## Task 2: Review trending products
1. Use the live Retail Command Center context from Figure 1 before you run the SQL.

2. Run the database version of the command center trending-products query.

    Trending products sit at the intersection of merchandising, inventory, and social engagement. This block joins four related tables: products, brands, social posts, and the bridge table that records which posts mention which products. `COUNT(DISTINCT ...)` counts unique posts, `SUM` totals views, and `AVG` calculates average momentum. The date filter keeps the result focused on recent activity by comparing each post with the latest seeded post date.

    ```sql
    <copy>
    SELECT p.product_name AS "Product",
           b.brand_name AS "Brand",
           COUNT(DISTINCT ppm.post_id) AS "Mentions",
           SUM(sp.views_count) AS "Views",
           ROUND(AVG(sp.virality_score), 2) AS "Avg Momentum",
           MAX(sp.momentum_flag) AS "Peak Momentum"
    FROM products p
    JOIN brands b ON p.brand_id = b.brand_id
    JOIN post_product_mentions ppm ON p.product_id = ppm.product_id
    JOIN social_posts sp ON ppm.post_id = sp.post_id
    WHERE sp.posted_at >= (SELECT MAX(posted_at) FROM social_posts) - INTERVAL '7' DAY
    GROUP BY p.product_id, p.product_name, b.brand_name
    ORDER BY "Avg Momentum" DESC, "Views" DESC
    FETCH FIRST 10 ROWS ONLY;
    </copy>
    ```

    Expected output:

    | Product | Brand | Mentions | Views | Avg Momentum | Peak Momentum |
    | --- | --- | ---: | ---: | ---: | --- |
    | Minimalist Wall Clock | NestCraft | 10 | 5275176 | 57.93 | viral |
    | VoidStrike Gaming Headset | DarkMatter | 4 | 1458179 | 56.98 | viral |
    | Organic Protein Bars 12pk | GoldenHarvest | 5 | 1795022 | 50.73 | viral |
    | HeadLamp 1000 Lumens | TrailBlaze | 9 | 15106505 | 49.58 | viral |
    | NovaCam Action 5K | TechNova | 8 | 2114987 | 49.06 | viral |
    | Moonbeam Highlighter | MoonGlow | 5 | 810046 | 45.27 | viral |
    | Smart Jump Rope | PeakForm | 7 | 18185236 | 43.35 | viral |
    | Resistance Pool Bands | AquaFit | 12 | 5961564 | 37.34 | viral |
    | Crescent Moon Earrings | LunaWear | 10 | 4994691 | 35.81 | viral |
    | Wireless Charging Pad Duo | RapidCharge | 10 | 20816358 | 34.19 | viral |
    {: title="Trending Products"}

3. A high-ranking product may represent a sales opportunity, an inventory risk, a merchandising action, or a signal that deserves deeper analysis in the Customer Trend Signals lab.

## Task 3: Connect product detail screens to database evidence

1. Use the live Retail Command Center context from Figure 1 as the visual anchor for product details and JSON Duality patterns.

    Product detail screens often look like documents because the application needs a compact product story: item, brand, category, inventory, demand, and signals. The important point is that the document-style screen does not require a separate document database. Later labs show how Oracle Database can expose document-shaped JSON while preserving relational tables, constraints, security policies, and SQL access.

## Task 4: Review revenue by category

1. Run the category revenue query.

    Category revenue shows where demand is turning into sales. This block joins order headers, order line items, and products. The line item table supplies quantity and price; the product table supplies category; the order table supplies date and social-source context. The `CASE WHEN` expression counts only orders with a social source, so the result compares total category revenue with orders influenced by social demand.

    ```sql
    <copy>
    SELECT p.category AS "Category",
           COUNT(DISTINCT o.order_id) AS "Orders",
           ROUND(SUM(oi.quantity * oi.unit_price), 2) AS "Revenue",
           COUNT(DISTINCT CASE WHEN o.social_source_id IS NOT NULL THEN o.order_id END) AS "Social-Driven Orders"
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.created_at >= (SELECT MAX(created_at) FROM orders) - INTERVAL '30' DAY
    GROUP BY p.category
    ORDER BY "Revenue" DESC;
    </copy>
    ```

    Expected output:

    | Category | Orders | Revenue | Social-Driven Orders |
    | --- | ---: | ---: | ---: |
    | Electronics | 542 | 652916.72 | 169 |
    | Fitness | 385 | 256676.01 | 128 |
    | Fashion | 480 | 224985.98 | 139 |
    | Sports | 56 | 216148.88 | 10 |
    | Wearables | 200 | 188785.89 | 64 |
    | Gaming | 254 | 155554.1 | 80 |
    | Audio | 292 | 152103.93 | 90 |
    | Home | 367 | 118922.61 | 106 |
    | Outdoor | 272 | 108168.95 | 90 |
    | Footwear | 251 | 74734.67 | 81 |
    | Kitchen | 159 | 33656.59 | 39 |
    | Beauty | 317 | 32378.45 | 93 |
    | Eyewear | 106 | 29828.4 | 38 |
    | Wellness | 154 | 27221.76 | 55 |
    | Beverages | 184 | 13112.29 | 62 |
    | Tools | 45 | 11039.04 | 16 |
    | Travel | 85 | 5078.35 | 28 |
    | Food | 78 | 4280.37 | 20 |
    {: title="Category Revenue"}

2. The command center shows why converged data matters. Operational orders, social demand signals, inventory context, and AI-assisted actions can start from one governed database foundation.

## Acknowledgements

* **Author** - Pat Shepherd, Senior Principal Database Product Manager
* **Contributor** - Linda Foinding, Principal Database Product Manager
* **Last Updated By/Date** - Oracle Database Product Management, May 2026
