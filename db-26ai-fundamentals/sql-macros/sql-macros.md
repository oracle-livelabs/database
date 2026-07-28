# Lab: SQL Macros in Oracle AI Database

## Introduction

Every team has SQL that gets copy-pasted: the tax calculation, the "current quarter" filter, the standard discount formula. Put it in a PL/SQL function and you pay a context switch on every row; leave it inline and the same expression drifts out of sync across a dozen queries.

SQL macros give you both: write the logic once as a function, and the database expands it *into your SQL text at parse time*. The optimizer sees plain SQL and your queries share one definition of the truth. Scalar macros return reusable expressions. Table macros return reusable query blocks you can put in a FROM clause.

SQL macros aren't but they remain one of the most underused features in the database so they are being highlighted here.

Why does it matter?
- One definition for business logic, expanded inline wherever it's used
- Zero PL/SQL runtime cost. Macros disappears into the SQL at parse time
- Table macros work generically across any table with the right columns

In this lab, you'll centralize a store's tax and sale-pricing rules with one scalar macro and one table macro.

Estimated Lab Time: 10 minutes

### Objectives

In this lab you will:

- Create a scalar SQL macro and use it in SELECT and WHERE clauses
- Create a table SQL macro and query it like a table
- Reuse the same table macro across different tables

### Prerequisites

- Access to Oracle AI Database 26ai
- Basic understanding of SQL and PL/SQL functions

## Task 1: Create the Catalog

1. Create a product catalog and a gift card table. Both of these two tables share a `list_price` column.

    ```sql
    <copy>
    DROP TABLE IF EXISTS sm_products CASCADE CONSTRAINTS;
    DROP TABLE IF EXISTS sm_gift_cards CASCADE CONSTRAINTS;

    CREATE TABLE sm_products (
        product_id   NUMBER PRIMARY KEY,
        product_name VARCHAR2(50) NOT NULL,
        category     VARCHAR2(30) NOT NULL,
        list_price   NUMBER(8,2)  NOT NULL
    );

    CREATE TABLE sm_gift_cards (
        card_id    NUMBER PRIMARY KEY,
        card_name  VARCHAR2(50) NOT NULL,
        list_price NUMBER(8,2)  NOT NULL
    );

    INSERT INTO sm_products VALUES
        (1, 'Mechanical Keyboard', 'Electronics', 129.99),
        (2, 'Walnut Desk Organizer', 'Office', 45.00),
        (3, 'Noise Canceling Headphones', 'Electronics', 299.00),
        (4, 'Ergonomic Footrest', 'Office', 59.50),
        (5, 'USB Microphone', 'Electronics', 89.99);

    INSERT INTO sm_gift_cards VALUES
        (1, 'Holiday Gift Card', 50.00),
        (2, 'Birthday Gift Card', 25.00);

    COMMIT;
    </copy>
    ```

## Task 2: Scalar Macros

1. The store's 8.25% tax calculation lives in a dozen reports. With macros you define it once. The function returns the *text* of the expression. That text replaces the macro call inside your SQL at parse time.

    ```sql
    <copy>
    CREATE OR REPLACE FUNCTION taxed (p NUMBER) RETURN VARCHAR2 SQL_MACRO(SCALAR) IS
    BEGIN
      RETURN q'[ROUND(p * 1.0825, 2)]';
    END;
    /
    </copy>
    ```

2. Use it like any expression. For example, in the SELECT list and in WHERE.

    ```sql
    <copy>
    SELECT product_name, list_price, taxed(list_price) AS with_tax
    FROM sm_products
    WHERE taxed(list_price) > 90
    ORDER BY list_price DESC;
    </copy>
    ```

    **What you should see:**

    | PRODUCT_NAME | LIST_PRICE | WITH_TAX |
    | --- | --- | --- |
    | Noise Canceling Headphones | 299 | 323.67 |
    | Mechanical Keyboard | 129.99 | 140.71 |
    | USB Microphone | 89.99 | 97.41 |

    - The optimizer never calls the function at runtime. The query was rewritten to `ROUND(list_price * 1.0825, 2)` before execution. When the tax rate changes, you change one function.

## Task 3: Table Macros

1. Sale pricing is the same idea at table scale. A table macro takes a table as a parameter (the `DBMS_TF.TABLE_T` type) and returns a query block.

    A table macro can use a fixed table directly in its returned query, like `FROM custsales`. This does not need a `DBMS_TF.TABLE_T` parameter, but the macro can only be used with that one table. A reusable table macro accepts a table through a `DBMS_TF.TABLE_T` parameter, allowing the same macro to work with multiple tables. This lab uses the reusable form because the same macro is queried against both `sm_products` and `sm_gift_cards`.

    For a macro that accepts tables dynamically, use `DBMS_TF.TABLE_T` and explicitly identify it as a table macro.

    ```sql
    <copy>
    CREATE OR REPLACE FUNCTION on_sale (t DBMS_TF.TABLE_T, pct NUMBER) RETURN VARCHAR2 SQL_MACRO(TABLE) IS
    BEGIN
      RETURN q'[SELECT t.*, ROUND(list_price * (1 - on_sale.pct / 100), 2) AS sale_price FROM t]';
    END;
    /
    </copy>
    ```

2. Query it like a table: the catalog at 20% off, filtered like any other FROM source.

    ```sql
    <copy>
    SELECT product_name, list_price, sale_price
    FROM on_sale(sm_products, 20)
    WHERE category = 'Electronics'
    ORDER BY sale_price DESC;
    </copy>
    ```

    **What you should see:**

    | PRODUCT_NAME | LIST_PRICE | SALE_PRICE |
    | --- | --- | --- |
    | Noise Canceling Headphones | 299 | 239.2 |
    | Mechanical Keyboard | 129.99 | 103.99 |
    | USB Microphone | 89.99 | 71.99 |

3. Here's the payoff: the same macro works on *any* table with a `list_price` column. Put the gift cards on sale at 10% off - no new code.

    ```sql
    <copy>
    SELECT card_name, list_price, sale_price
    FROM on_sale(sm_gift_cards, 10)
    ORDER BY card_id;
    </copy>
    ```

    **What you should see:**

    | CARD_NAME | LIST_PRICE | SALE_PRICE |
    | --- | --- | --- |
    | Holiday Gift Card | 50 | 45 |
    | Birthday Gift Card | 25 | 22.5 |

## Task 4: Clean Up

1. Drop the macros and tables.

    ```sql
    <copy>
    DROP FUNCTION IF EXISTS taxed;
    DROP FUNCTION IF EXISTS on_sale;
    DROP TABLE IF EXISTS sm_products CASCADE CONSTRAINTS;
    DROP TABLE IF EXISTS sm_gift_cards CASCADE CONSTRAINTS;
    </copy>
    ```

## Learn More

- [SQL_MACRO Clause - Oracle AI Database PL/SQL Language Reference](https://docs.oracle.com/en/database/oracle/oracle-database/26/lnpls/SQL_MACRO-clause.html)

## Acknowledgements

- **Author** - Killian Lynch, Oracle AI Database Product Manager
- **Last Updated By/Date** - Killian Lynch, June 2026
