# Lab: JOIN TO ONE in Oracle AI Database 26ai

## Introduction

Most joins follow the same pattern: you start from a "many" table (orders) and look up matching rows in a "one" table (customers). The relationship is already declared in your foreign keys - yet every query makes you spell out the ON clause again, and nothing stops you from accidentally joining in the wrong direction and silently duplicating rows.

JOIN TO ONE, new in Oracle AI Database 26ai (23.26.2), fixes both problems. It infers join conditions from your foreign keys, and it guarantees that each row from your subject table appears exactly once in the results. If a join would ever match more than one row, the database raises an error instead of quietly handing you duplicates.

Why does it matter?
- Foreign keys become the single source of truth for join conditions
- Accidental row fan-out shows
- Multi-table lookups collapse into one short FROM clause

In this lab, you'll explore JOIN TO ONE with a small online store schema: regions, customers, and orders.

Estimated Lab Time: 10 minutes

### Objectives

In this lab you will:

- Join tables with JOIN TO ONE using foreign key inference - no ON clause
- Chain lookups across multiple tables in a single JOIN TO ONE list
- See how JOIN TO ONE preserves every subject row, like an outer join
- Trigger the ORA-18640 safety net that catches non-unique joins

### Prerequisites

- Access to Oracle AI Database 26ai (23.26.2 or later)
- Basic understanding of SQL joins and foreign keys

## Task 1: Create the Store Schema

1. Create three tables connected by foreign keys: orders point to customers, and customers point to regions.

    ```sql
    <copy>
    DROP TABLE IF EXISTS store_orders CASCADE CONSTRAINTS;
    DROP TABLE IF EXISTS store_customers CASCADE CONSTRAINTS;
    DROP TABLE IF EXISTS store_regions CASCADE CONSTRAINTS;

    CREATE TABLE store_regions (
        region_id   NUMBER PRIMARY KEY,
        region_name VARCHAR2(30) NOT NULL
    );

    CREATE TABLE store_customers (
        customer_id   NUMBER PRIMARY KEY,
        customer_name VARCHAR2(50) NOT NULL,
        tier          VARCHAR2(10),
        region_id     NUMBER REFERENCES store_regions
    );

    CREATE TABLE store_orders (
        order_id    NUMBER PRIMARY KEY,
        customer_id NUMBER NOT NULL REFERENCES store_customers,
        order_total NUMBER(8,2) NOT NULL,
        order_date  DATE NOT NULL
    );

    INSERT INTO store_regions VALUES (10, 'West'), (20, 'East'), (30, 'Central');

    INSERT INTO store_customers VALUES
        (1, 'Aria Chen', 'GOLD', 10),
        (2, 'Ben Ortiz', 'SILVER', 20),
        (3, 'Cara Singh', 'GOLD', 10),
        (4, 'Dev Patel', 'BRONZE', NULL);

    INSERT INTO store_orders VALUES
        (101, 1, 250.00, DATE '2026-05-01'),
        (102, 1, 89.99,  DATE '2026-05-15'),
        (103, 2, 432.10, DATE '2026-05-20'),
        (104, 3, 75.50,  DATE '2026-06-01'),
        (105, 3, 199.00, DATE '2026-06-03'),
        (106, 2, 58.25,  DATE '2026-06-05');

    COMMIT;
    </copy>
    ```

    **What you should see:**
    - 3 regions, 4 customers, and 6 orders
    - Dev Patel has no region assigned and no orders. You'll see why in Task 3

## Task 2: Join Without an ON Clause

1. List orders with their customer details. The subject table (the one whose rows you're listing) goes in the FROM clause. The lookup table goes inside JOIN TO ONE. The database finds the join condition from the foreign key.

    ```sql
    <copy>
    SELECT o.order_id, o.order_total, c.customer_name, c.tier
    FROM   store_orders o
    JOIN TO ONE (store_customers c)
    ORDER  BY o.order_id;
    </copy>
    ```

    **What you should see:**
    - All 6 orders, each with its customer's name and tier
    - No ON clause because the `store_orders.customer_id` foreign key supplied the join condition

2. Now chain a second lookup. Orders point to customers, customers point to regions. JOIN TO ONE follows the foreign key chain through both.

    ```sql
    <copy>
    SELECT o.order_id, o.order_total, c.customer_name, r.region_name
    FROM   store_orders o
    JOIN TO ONE (store_customers c, store_regions r)
    ORDER  BY o.order_id;
    </copy>
    ```

    **What you should see:**
    - The same 6 orders, now enriched with the region name
    - Two joins, zero ON clauses. Compare that with the traditional version:

    ```sql
    <copy>
    SELECT o.order_id, o.order_total, c.customer_name, r.region_name
    FROM   store_orders o
    JOIN   store_customers c ON c.customer_id = o.customer_id
    JOIN   store_regions r   ON r.region_id   = c.region_id
    ORDER  BY o.order_id;
    </copy>
    ```

    Nut notice the traditional INNER JOIN version would silently drop rows if a foreign key column were NULL. JOIN TO ONE behaves differently, as you'll see next.

## Task 3: Every Subject Row Survives

1. List customers with their regions. Dev Patel has no region.

    ```sql
    <copy>
    SELECT c.customer_name, c.tier, r.region_name
    FROM   store_customers c
    JOIN TO ONE (store_regions r)
    ORDER  BY c.customer_id;
    </copy>
    ```

    **What you should see:**
    - All 4 customers, including Dev Patel with a NULL region
    - JOIN TO ONE works like an outer join: the subject table's rows always appear exactly once, matched or not
    - A traditional INNER JOIN would have silently dropped Dev Patel from the report

## Task 4: The Safety Net

What happens if you point JOIN TO ONE at the "many" side by mistake? Each customer has multiple orders, so joining customers TO ONE order is impossible.

1. Try it. Since there's no foreign key from customers to orders, you have to spell out the join condition with ON.

    ```sql
    <copy>
    SELECT c.customer_name, o.order_total
    FROM   store_customers c
    JOIN TO ONE (store_orders o ON o.customer_id = c.customer_id);
    </copy>
    ```

    **What you should see:**

    ```
    ORA-18640: JOIN TO ONE reached multiple rows joining to "O", resulting in a
    non-unique join
    ```

    A regular join here would have quietly returned each customer once per order.

2. Clean up.

    ```sql
    <copy>
    DROP TABLE IF EXISTS store_orders CASCADE CONSTRAINTS;
    DROP TABLE IF EXISTS store_customers CASCADE CONSTRAINTS;
    DROP TABLE IF EXISTS store_regions CASCADE CONSTRAINTS;
    </copy>
    ```

## Learn More

- [SELECT - SQL Language Reference (Joins)](https://docs.oracle.com/en/database/oracle/oracle-database/26/sqlrf/Joins.html)
- [Avoid join duplicates with modern join syntax in Oracle AI Database](https://blogs.oracle.com/sql/avoid-join-duplicates-with-modern-join-syntax-in-oracle-ai-database)

## Acknowledgements

- **Author** - Killian Lynch, Oracle AI Database Product Manager
- **Last Updated By/Date** - Killian Lynch, June 2026
