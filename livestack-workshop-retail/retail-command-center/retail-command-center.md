# Retail Command Center

## Introduction

The Retail Command Center is built for a retail operations leader, merchandising analyst, or digital commerce manager who needs a daily operating view of the business. Dashboards like this are difficult when orders, fulfillment, customer signals, product demand, returns exposure, analytics, and agent activity live in separate systems.

Oracle AI Database helps by keeping operational, analytical, JSON, in-memory, and AI-ready data close to the same governed data foundation. In the application, the page brings together live retail KPIs, customer signal velocity, revenue category detail, and product-level evidence. In SQL Worksheet, you inspect the database queries that make those views possible.

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

    ```sql
    <copy>
    SELECT
      (SELECT COUNT(*) FROM RETAILDB.orders) AS "Total Orders",
      (SELECT NVL(ROUND(SUM(order_total), 2), 0) FROM RETAILDB.orders) AS "Retail Revenue",
      (SELECT COUNT(*) FROM RETAILDB.return_requests WHERE status <> 'Closed') AS "Open Returns",
      (SELECT NVL(ROUND(SUM(return_value), 2), 0) FROM RETAILDB.return_requests WHERE status <> 'Closed') AS "Return Exposure",
      (SELECT COUNT(*) FROM RETAILDB.social_posts WHERE momentum_flag IN ('viral','mega_viral')) AS "Demand Spikes",
      (SELECT COUNT(*) FROM RETAILDB.agent_actions) AS "Agent Actions"
    FROM dual;
    </copy>
    ```

    Expected output:

    | Total Orders | Retail Revenue | Open Returns | Return Exposure | Demand Spikes | Agent Actions |
    | ---: | ---: | ---: | ---: | ---: | ---: |
    | 3000 | 4235872.01 | 5 | 934.93 | 511 | 0 |
    {: title="Retail Command Center KPI Query"}

3. These metrics create the daily triage view. The user can see revenue, demand, return exposure, and agent activity without waiting for copied data or a separate dashboard mart.

## Task 2: Review trending products
1. Use the live Retail Command Center context from Figure 1 before you run the SQL.

2. Run the database version of the command center trending-products query.

    ```sql
    <copy>
    SELECT p.product_name AS "Product",
           b.brand_name AS "Brand",
           COUNT(DISTINCT ppm.post_id) AS "Mentions",
           SUM(sp.views_count) AS "Views",
           ROUND(AVG(sp.virality_score), 2) AS "Avg Momentum",
           MAX(sp.momentum_flag) AS "Peak Momentum"
    FROM RETAILDB.products p
    JOIN RETAILDB.brands b ON p.brand_id = b.brand_id
    JOIN RETAILDB.post_product_mentions ppm ON p.product_id = ppm.product_id
    JOIN RETAILDB.social_posts sp ON ppm.post_id = sp.post_id
    WHERE sp.posted_at >= (SELECT MAX(posted_at) FROM RETAILDB.social_posts) - INTERVAL '7' DAY
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
    {: title="Trending Product Evidence"}

3. A high-ranking product may represent a sales opportunity, an inventory risk, a merchandising action, or a signal that deserves deeper analysis in the Customer Trend Signals lab.

## Task 3: Connect product detail screens to database evidence

1. Use the live Retail Command Center context from Figure 1 as the visual anchor for product details and JSON Duality patterns. The app view is document-oriented, but the source of truth remains Oracle Database.

## Task 4: Review revenue by category

1. Run the category revenue query.

    ```sql
    <copy>
    SELECT p.category AS "Category",
           COUNT(DISTINCT o.order_id) AS "Orders",
           ROUND(SUM(oi.quantity * oi.unit_price), 2) AS "Revenue",
           COUNT(DISTINCT CASE WHEN o.social_source_id IS NOT NULL THEN o.order_id END) AS "Social-Driven Orders"
    FROM RETAILDB.order_items oi
    JOIN RETAILDB.products p ON oi.product_id = p.product_id
    JOIN RETAILDB.orders o ON oi.order_id = o.order_id
    WHERE o.created_at >= (SELECT MAX(created_at) FROM RETAILDB.orders) - INTERVAL '30' DAY
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
    {: title="Revenue by Category"}

2. The command center shows why converged data matters. Operational orders, social demand signals, inventory context, and AI-assisted actions can start from one governed database foundation.

## Acknowledgements

* **Author** - Oracle LiveLabs
* **Last Updated By/Date** - Oracle Database Product Management, May 2026
