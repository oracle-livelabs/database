# Lab: DATEDIFF, DATEADD, and Calendar Functions in Oracle AI Database 26ai

## Introduction

"How many days between these two dates?" is one of the oldest questions in SQL, and until now Oracle answered it with subtraction, MONTHS\_BETWEEN, and a bit of arithmetic. 

Oracle AI Database 26ai (23.26.1) adds DATEDIFF, TIMESTAMPDIFF, and DATEADD, plus a family of calendar functions (CALENDAR\_\*, FISCAL\_\*, and RETAIL\_\*) that answer time-dimension questions like "which quarter is this?" or "when does this month end?" without format-mask tricks.

Why does it matter?
- Week, quarter, and month logic becomes a function call instead of TO_CHAR gymnastics
- Fiscal and retail calendars are built in. No more calendar dimension tables for simple cases

In this lab, you'll analyze order shipping data the way an operations team would: shipping delays, SLA deadlines, and quarterly rollups.

Estimated Lab Time: 10 minutes

### Objectives

In this lab you will:

- Calculate date differences with DATEDIFF and TIMESTAMPDIFF
- Compute SLA deadlines with DATEADD
- Roll up data by quarter and week with calendar functions
- Compare calendar and fiscal year views of the same dates

### Prerequisites

- Access to Oracle AI Database 26ai (23.26.1 or later)
- Basic understanding of SQL and date arithmetic

## Task 1: Create the Shipping Dataset

1. Create and populate a small orders table with order and ship dates.

    ```sql
    <copy>
    DROP TABLE IF EXISTS ship_orders CASCADE CONSTRAINTS;

    CREATE TABLE ship_orders (
        order_id     NUMBER PRIMARY KEY,
        customer     VARCHAR2(50) NOT NULL,
        order_total  NUMBER(8,2)  NOT NULL,
        ordered_date DATE         NOT NULL,
        shipped_date DATE
    );

    INSERT INTO ship_orders VALUES
        (1, 'Harper Co',    1200.00, DATE '2026-01-12', DATE '2026-01-15'),
        (2, 'Birch Labs',    450.50, DATE '2026-02-03', DATE '2026-02-12'),
        (3, 'Cedar Retail', 2890.00, DATE '2026-03-28', DATE '2026-04-02'),
        (4, 'Harper Co',     760.25, DATE '2026-04-14', DATE '2026-04-16'),
        (5, 'Maple Goods',  1515.75, DATE '2026-05-22', DATE '2026-05-30'),
        (6, 'Birch Labs',    320.00, DATE '2026-06-01', DATE '2026-06-04'),
        (7, 'Cedar Retail',  980.40, DATE '2026-06-08', NULL);

    COMMIT;
    </copy>
    ```

    **What you should see:**
    - 7 orders spread across the first half of 2026
    - Order 7 hasn't shipped yet (NULL shipped\_date)

## Task 2: Date Differences with DATEDIFF

1. How long did each order take to ship, and how old is each order? DATEDIFF takes the unit first, then the two dates.

    ```sql
    <copy>
    SELECT order_id, customer,
           DATEDIFF(DAY, ordered_date, shipped_date) AS days_to_ship,
           DATEDIFF(DAY, ordered_date, SYSDATE) AS days_since_order
    FROM ship_orders
    ORDER BY order_id;
    </copy>
    ```

    **What you should see:**
    - Shipping took between 2 and 9 days; order 7 shows NULL because it hasn't shipped
    - `days_since_order` counts up from each order date to today, so your values will differ from your neighbor's tomorrow

2. The same pattern works at any granularity. TIMESTAMPDIFF is a synonym that's handy when you think in timestamps.

    ```sql
    <copy>
    SELECT TIMESTAMPDIFF(HOUR, TIMESTAMP '2026-06-12 08:00:00', TIMESTAMP '2026-06-12 17:30:00') AS shift_hours,
           TIMESTAMPDIFF(MINUTE, TIMESTAMP '2026-06-12 08:00:00', TIMESTAMP '2026-06-12 08:45:30') AS minutes_elapsed,
           DATEDIFF(YEAR, DATE '1977-05-25', SYSDATE) AS years_since;
    </copy>
    ```

    **What you should see:**
    - A 9 hour shift, 45 elapsed minutes, and however many years it's been since May 25, 1977
    - Units include YEAR, QUARTER, MONTH, WEEK, DAY, HOUR, MINUTE, and SECOND

## Task 3: SLA Deadlines with DATEADD

1. Your shipping SLA is 5 days. Compute each order's deadline and label the result.

    ```sql
    <copy>
    SELECT order_id, customer, ordered_date, shipped_date,
           DATEADD(DAY, 5, ordered_date) AS ship_by,
           CASE WHEN shipped_date > DATEADD(DAY, 5, ordered_date) THEN 'LATE'
                WHEN shipped_date IS NULL THEN 'PENDING'
                ELSE 'ON TIME' END AS sla_status
    FROM ship_orders
    ORDER BY order_id;
    </copy>
    ```

    **What you should see:**
    - Orders 2 and 5 missed the 5-day window (LATE)
    - Order 7 is PENDING; everything else shipped ON TIME

## Task 4: Calendar Rollups

1. Roll revenue up by quarter. CALENDAR\_QUARTER returns a ready-to-display label without TO\_CHAR format masks.

    ```sql
    <copy>
    SELECT CALENDAR_QUARTER(ordered_date) AS quarter,
           COUNT(*) AS orders,
           SUM(order_total) AS revenue
    FROM ship_orders
    GROUP BY CALENDAR_QUARTER(ordered_date)
    ORDER BY quarter;
    </copy>
    ```

    **What you should see:**

    | QUARTER | ORDERS | REVENUE |
    | --- | --- | --- |
    | Q1-2026 | 3 | 4540.5 |
    | Q2-2026 | 4 | 3576.4 |

2. The calendar family also navigates within periods: week numbers, month-end billing dates, quarter boundaries.

    ```sql
    <copy>
    SELECT order_id, ordered_date,
           CALENDAR_WEEK_OF_YEAR(ordered_date) AS week_no,
           CALENDAR_MONTH_END_DATE(ordered_date) AS bill_at_month_end,
           CALENDAR_QUARTER_START_DATE(ordered_date) AS quarter_opened
    FROM ship_orders
    WHERE order_id <= 3
    ORDER BY order_id;
    </copy>
    ```

    **What you should see:**
    - Week numbers (2, 5, 13), each order's month-end date, and the quarter start (01-JAN-26 for all three)

3. Companies rarely run on the calendar year. Pass a fiscal year start date to any FISCAL\_\* function and the same orders land in different quarters.

    ```sql
    <copy>
    SELECT order_id, ordered_date,
           CALENDAR_QUARTER(ordered_date) AS calendar_qtr,
           FISCAL_QUARTER(ordered_date, DATE '2025-07-01') AS fiscal_qtr,
           FISCAL_YEAR(ordered_date, DATE '2025-07-01') AS fiscal_year
    FROM ship_orders
    WHERE order_id IN (1, 5)
    ORDER BY order_id;
    </copy>
    ```

    **What you should see:**

    | ORDER_ID | ORDERED_DATE | CALENDAR_QTR | FISCAL_QTR | FISCAL_YEAR |
    | --- | --- | --- | --- | --- |
    | 1 | 12-JAN-26 | Q1-2026 | Q3-FY2026 | FY2026 |
    | 5 | 22-MAY-26 | Q2-2026 | Q4-FY2026 | FY2026 |

    - January is Q1 of the calendar year but Q3 of a July-start fiscal year
    - A matching RETAIL\_\* family handles 4-4-5 retail calendars the same way

4. What if your reporting periods aren't calendar periods at all? TIME\_BUCKET slices time into fixed-width buckets of any size, anchored to an origin date you choose. Roll revenue into two-month buckets:

    ```sql
    <copy>
    SELECT TIME_BUCKET(ordered_date, INTERVAL '2' MONTH, DATE '2026-01-01') AS bucket_start,
           COUNT(*) AS orders,
           SUM(order_total) AS revenue
    FROM ship_orders
    GROUP BY TIME_BUCKET(ordered_date, INTERVAL '2' MONTH, DATE '2026-01-01')
    ORDER BY bucket_start;
    </copy>
    ```

    **What you should see:**

    | BUCKET_START | ORDERS | REVENUE |
    | --- | --- | --- |
    | 01-JAN-26 | 2 | 1650.5 |
    | 01-MAR-26 | 2 | 3650.25 |
    | 01-MAY-26 | 3 | 2816.15 |

    Buckets work at any width. Here's each order placed into 14-day "sprints", showing both ends of its bucket:

    ```sql
    <copy>
    SELECT order_id, ordered_date,
           TIME_BUCKET(ordered_date, INTERVAL '14' DAY, DATE '2026-01-01') AS sprint_start,
           TIME_BUCKET(ordered_date, INTERVAL '14' DAY, DATE '2026-01-01', END) AS sprint_end
    FROM ship_orders
    WHERE order_id <= 3
    ORDER BY order_id;
    </copy>
    ```

    **What you should see:**
    - Each order tagged with the start and end of its own 14-day window, all anchored to January 1

5. Clean up.

    ```sql
    <copy>
    DROP TABLE IF EXISTS ship_orders CASCADE CONSTRAINTS;
    </copy>
    ```

## Learn More

- [DATEDIFF - Database Development Guide](https://docs.oracle.com/en/database/oracle/oracle-database/26/adfns/advanced-sql-extensions-calendar-and-aggregation-filters.html#GUID-2934E548-F90C-4296-8CDB-FD6F95EE1523)
- [Oracle AI Database New Features - Calendar Functions](https://docs.oracle.com/en/database/oracle/oracle-database/26/nfcoa/appdev_sql.html#GUID-87610-1)

## Acknowledgements

- **Author** - Killian Lynch, Oracle AI Database Product Manager
- **Last Updated By/Date** - Killian Lynch, June 2026
