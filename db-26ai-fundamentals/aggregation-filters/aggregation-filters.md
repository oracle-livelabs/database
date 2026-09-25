# Lab: Aggregation Filters in Oracle AI Database 26ai

## Introduction

Imagine you've written this query: count all the orders, but also count just the loyalty orders, and just the app orders, side by side. For years the trick was wrapping CASE expressions inside aggregates `COUNT(CASE WHEN ... THEN 1 END)` , which works, but buries the intent of the query inside a workaround.

Oracle AI Database 26ai (23.26.1) adds the SQL standard FILTER clause. You attach a WHERE condition directly to any aggregate function, and that aggregate only sees the rows that pass the condition. One table scan, many differently-filtered aggregates, and the query says exactly what it means.

Why does it matter?
- Conditional aggregates read as plain English instead of CASE gymnastics
- One pass over the data computes any number of differently-filtered metrics

In this lab, you'll analyze orders for a small coffee chain and build side-by-side metrics with FILTER.

Estimated Lab Time: 10 minutes

### Objectives

In this lab you will:

- Apply the FILTER clause to COUNT, SUM, and AVG
- Replace CASE-inside-aggregate workarounds with readable FILTER conditions
- Build pivot-style reports with multiple FILTER conditions in one query
- Use FILTER with analytic (window) functions

### Prerequisites

- Access to Oracle AI Database 26ai (23.26.1 or later)
- Basic understanding of SQL 
## Task 1: Create the Coffee Shop Dataset

1. Create and populate the orders table for two cafe locations.

    ```sql
    <copy>
    DROP TABLE IF EXISTS cafe_orders CASCADE CONSTRAINTS;

    CREATE TABLE cafe_orders (
        order_id       NUMBER PRIMARY KEY,
        location       VARCHAR2(20) NOT NULL,
        drink_type     VARCHAR2(20) NOT NULL,
        order_channel  VARCHAR2(10) NOT NULL,
        loyalty_member VARCHAR2(1)  NOT NULL,
        price          NUMBER(5,2)  NOT NULL,
        order_date     DATE         NOT NULL
    );

    INSERT INTO cafe_orders VALUES
        (1,  'Downtown', 'Latte',     'APP',     'Y', 5.50, DATE '2026-05-04'),
        (2,  'Downtown', 'Espresso',  'COUNTER', 'N', 3.25, DATE '2026-05-04'),
        (3,  'Downtown', 'Cold Brew', 'APP',     'Y', 4.75, DATE '2026-05-11'),
        (4,  'Downtown', 'Mocha',     'COUNTER', 'Y', 6.00, DATE '2026-05-18'),
        (5,  'Downtown', 'Latte',     'COUNTER', 'N', 5.50, DATE '2026-05-25'),
        (6,  'Downtown', 'Cold Brew', 'APP',     'N', 4.75, DATE '2026-06-01'),
        (7,  'Downtown', 'Latte',     'APP',     'Y', 5.50, DATE '2026-06-03'),
        (8,  'Downtown', 'Espresso',  'COUNTER', 'Y', 3.25, DATE '2026-06-08'),
        (9,  'Airport',  'Latte',     'COUNTER', 'N', 6.25, DATE '2026-05-06'),
        (10, 'Airport',  'Cold Brew', 'APP',     'Y', 5.25, DATE '2026-05-13'),
        (11, 'Airport',  'Mocha',     'COUNTER', 'N', 6.75, DATE '2026-05-20'),
        (12, 'Airport',  'Espresso',  'COUNTER', 'N', 3.75, DATE '2026-05-27'),
        (13, 'Airport',  'Latte',     'APP',     'Y', 6.25, DATE '2026-06-02'),
        (14, 'Airport',  'Mocha',     'APP',     'Y', 6.75, DATE '2026-06-05'),
        (15, 'Airport',  'Cold Brew', 'COUNTER', 'N', 5.25, DATE '2026-06-07'),
        (16, 'Airport',  'Latte',     'COUNTER', 'Y', 6.25, DATE '2026-06-09');

    COMMIT;
    </copy>
    ```

    **What you should see:**
    - 16 orders across two locations (Downtown and Airport)
    - A mix of app and counter orders, loyalty and non-loyalty customers, May and June dates

## Task 2: Your First FILTER Clause

1. Count total orders, loyalty orders, and app orders in one statement, in one pass.

    ```sql
    <copy>
    SELECT
        COUNT(*) AS total_orders,
        COUNT(*) FILTER (WHERE loyalty_member = 'Y') AS loyalty_orders,
        COUNT(*) FILTER (WHERE order_channel = 'APP') AS app_orders
    FROM cafe_orders;
    </copy>
    ```

    **What you should see:**

    | TOTAL_ORDERS | LOYALTY_ORDERS | APP_ORDERS |
    | --- | --- | --- |
    | 16 | 9 | 7 |

2. Compare with the traditional CASE workaround that produces the same numbers.

    ```sql
    <copy>
    SELECT
        COUNT(*) AS total_orders,
        COUNT(CASE WHEN loyalty_member = 'Y' THEN 1 END) AS loyalty_orders,
        COUNT(CASE WHEN order_channel = 'APP' THEN 1 END) AS app_orders
    FROM cafe_orders;
    </copy>
    ```

    **What you should see:**
    - Identical results
    - The CASE version relies on a side effect (unmatched rows become NULL, and COUNT skips NULLs). The FILTER version states the intent directly.

## Task 3: FILTER with GROUP BY

1. Build a per-location report: total revenue, app revenue, and average loyalty-member spend. That's three differently-filtered metrics from one scan.

    ```sql
    <copy>
    SELECT
        location,
        SUM(price) AS total_revenue,
        SUM(price) FILTER (WHERE order_channel = 'APP') AS app_revenue,
        ROUND(AVG(price) FILTER (WHERE loyalty_member = 'Y'), 2) AS avg_loyalty_spend
    FROM cafe_orders
    GROUP BY location
    ORDER BY location;
    </copy>
    ```

    **What you should see:**

    | LOCATION | TOTAL_REVENUE | APP_REVENUE | AVG\_LOYALTY\_SPEND |
    | --- | --- | --- | --- |
    | Airport | 46.5 | 18.25 | 6.13 |
    | Downtown | 38.5 | 20.5 | 5 |

2. Pivot months into columns. Each FILTER condition slices a different part of the data, so the report comes out in spreadsheet shape.

    ```sql
    <copy>
    SELECT
        location,
        SUM(price) FILTER (WHERE EXTRACT(MONTH FROM order_date) = 5) AS may_revenue,
        SUM(price) FILTER (WHERE EXTRACT(MONTH FROM order_date) = 6) AS june_revenue,
        COUNT(DISTINCT drink_type) FILTER (WHERE order_channel = 'APP') AS app_drink_variety
    FROM cafe_orders
    GROUP BY location
    ORDER BY location;
    </copy>
    ```

    **What you should see:**

    | LOCATION | MAY_REVENUE | JUNE_REVENUE | APP\_DRINK\_VARIETY |
    | --- | --- | --- | --- |
    | Airport | 22 | 24.5 | 3 |
    | Downtown | 25 | 13.5 | 2 |

    - FILTER composes with DISTINCT too `app_drink_variety` counts distinct drink types among app orders only

## Task 4: FILTER with Analytic Functions

1. FILTER also works when an aggregate runs as a window function. Show each order next to the total loyalty revenue of its location.

    ```sql
    <copy>
    SELECT order_id, location, price,
           SUM(price) FILTER (WHERE loyalty_member = 'Y')
                      OVER (PARTITION BY location) AS loyalty_rev_in_location
    FROM cafe_orders
    ORDER BY order_id
    FETCH FIRST 4 ROWS ONLY;
    </copy>
    ```

    **What you should see:**
    - Each Downtown order shows 25 (the loyalty-member revenue for that location) regardless of whether the row itself is a loyalty order
    - The FILTER decides which rows feed the window aggregate; the PARTITION BY decides how rows are grouped

2. Clean up.

    ```sql
    <copy>
    DROP TABLE IF EXISTS cafe_orders CASCADE CONSTRAINTS;
    </copy>
    ```

## Learn More

- [Aggregate Functions - SQL Language Reference](https://docs.oracle.com/en/database/oracle/oracle-database/26/sqlrf/Aggregate-Functions.html)
- [Oracle AI Database New Features - Aggregation Filters](https://docs.oracle.com/en/database/oracle/oracle-database/26/nfcoa/appdev_sql.html#GUID-94426-1)

## Acknowledgements

- **Author** - Killian Lynch, Oracle AI Database Product Manager
- **Last Updated By/Date** - Killian Lynch, June 2026
