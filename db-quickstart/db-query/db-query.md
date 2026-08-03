# Query the Sales History Sample Schema

## Introduction

In this lab, you will query the `Sales History (SH)` sample schema that comes with the database.

Estimated lab time: 10 minutes

### Objectives

-   Execute the `SELECT` statement to query tables in the `SH schema`
-   Use the `WHERE` clause to restrict the rows that are returned from the `SELECT` query
-   Use the `ORDER BY` clause to sort the rows that are retrieved from the `SELECT` statement

### Prerequisites

This lab requires completion of the preceding labs in the **Contents** menu on the left.

## Task 1: Query Tables

In this section, you execute the `SELECT` statement to retrieve data from tables and views. You can select rows and columns that you want to return in the output. In its simplest form, a `SELECT` statement must contain the following:
-   A `SELECT` clause, which specifies columns containing the values to be matched
-   A `FROM` clause, which specifies the table containing the columns listed in the SELECT clause

    **Syntax:**  

    ```
    SELECT {*|[DISTINCT] column|expression [alias],...} FROM <table>
    ```

    >**Note:** You need to prefix the table names with the schema name **`SH`** in your queries.

1. You can display all columns of data in a table by entering an asterisk * after the `SELECT` statement. Execute the following statement to view all rows and columns in the  `PROMOTIONS` table. Copy and paste the following query into your SQL Worksheet, and then click the **Run Statement** icon in the Worksheet toolbar.

    ```
    <copy>
    SELECT *
    FROM sh.promotions;
    </copy>
    ```

    ![Execute statement to view PROMOTIONS table](./images/select-star-from-sh.png " ")

2. You can display specific columns of data in a table by specifying the column names in the SELECT statement. View the `PROMO_NAME` and `PROMO_END_DATE` columns in the `PROMOTIONS` table. Copy and paste the following query into your SQL Worksheet, and then click the **Run Statement** icon in the Worksheet toolbar.

    ```
    <copy>SELECT promo_name, promo_end_date
    FROM sh.promotions;</copy>
    ```

    ![Execute statement to view two columns in PROMOTIONS table](./images/select-promo-name-promo-end-date-from-promotions.png " ")

## Task 2: Restrict Data

In this section, you use the `WHERE` clause to restrict the rows that are returned from the `SELECT` query. A `WHERE` clause contains a condition that must be met. It directly follows the `FROM` clause. If the condition is true, the row that meets the condition is returned.

1. Execute the following query to restrict the number of rows to where the `PROMO_SUBCATEGORY` column has a value of `radio commercial`.

    ```
    <copy>
    SELECT *
    FROM sh.promotions
    WHERE promo_subcategory='radio commercial';
    </copy>
    ```

    ![Execute a query to restrict the number of rows](./images/where-promo-subcategory-equals-radio-commercial.png " ")

## Task 3: Sort Data

In this section, you use the `ORDER BY` clause to sort the rows that are retrieved from the `SELECT` statement. You specify the column based on the rows that must be sorted. You also specify the `ASC` keyword to display rows in ascending order (default), and you specify the `DESC` keyword to display rows in descending order.

1. Execute the following `SELECT` statement to retrieve the `CUST_LAST_NAME`, `CUST_CREDIT_LIMIT`, and `CUST_YEAR_OF_BIRTH` columns of customers who live in the `Noord Holland` `CUST_STATE_PROVINCE`. Sort the rows in ascending order (default) based on the `CUST_YEAR_OF_BIRTH` column.

    ```
    <copy>
    SELECT cust_last_name, cust_credit_limit, cust_year_of_birth
    FROM   sh.customers
    WHERE  cust_state_province='Noord-Holland'
    ORDER BY cust_year_of_birth;
    </copy>
    ```

    ![Use the ORDER BY clause](./images/order-by-cust-year-of-birth.png " ")  

2. Modify the `SELECT` statement to display rows in descending order. Use the `DESC` keyword.

    ```
    <copy>
    SELECT cust_last_name, cust_credit_limit, cust_year_of_birth
    FROM   sh.customers
    WHERE  cust_state_province='Noord-Holland'
    ORDER BY cust_year_of_birth DESC;
    </copy>
    ```

  ![Display rows in descending order](./images/order-by-cust-year-of-birth-desc.png " ")  

## Task 4: Rank Data

In this section, you use the `RANK ()` function to rank the rows that are retrieved from the `SELECT` statement. You can use the RANK function as an **aggregate**  function (takes multiple rows and returns a single number) or as an **analytical** function (takes criteria and shows a number for each record).

1. Execute the following `SELECT` statement to rank the rows using RANK as an analytical function.

    ```
    <copy>SELECT channel_desc, TO_CHAR(SUM(amount_sold), '9,999,999,999') SALES$,
    RANK() OVER (ORDER BY SUM(amount_sold)) AS default_rank,
    RANK() OVER (ORDER BY SUM(amount_sold) DESC NULLS LAST) AS custom_rank
    FROM sh.sales, sh.products, sh.customers, sh.times, sh.channels, sh.countries
    WHERE sales.prod_id=products.prod_id AND sales.cust_id=customers.cust_id
    AND customers.country_id = countries.country_id AND sales.time_id=times.time_id
    AND sales.channel_id=channels.channel_id
    AND times.calendar_month_desc IN ('2000-09', '2000-10')
    AND country_iso_code='US'
    GROUP BY channel_desc;</copy>
    ```

  ![Rank the data](./images/ranking-data.png " ")  

You may now **proceed to the next lab.**

## Want to Learn More?

* [Introduction to Oracle AI Database](https://docs.oracle.com/pls/topic/lookup?ctx=en/database/oracle/oracle-database/26/cncpt&id=CNCPT-GUID-A42A6EF0-20F8-4F4B-AFF7-09C100AE581E)


## Acknowledgements

- **Author:** Lauran K. Serhal, Consulting User Assistance Developer
- **Last Updated By/Date:** Lauran K. Serhal, October 2025
