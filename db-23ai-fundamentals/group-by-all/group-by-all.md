# Simplifying SQL with GROUP BY ALL

## Introduction

Welcome to the "Simplifying SQL with GROUP BY ALL" lab. In this lab, you will learn how to use the new GROUP BY ALL clause in Oracle Database 23ai to simplify your SQL queries. The GROUP BY ALL functionality eliminates the need to put all non-aggregated columns into the GROUP BY clause explicitly. Instead, the new ALL keyword indicates that the results should be automatically grouped by all non-aggregated columns.

Not having to repeat the non-aggregated columns in the GROUP BY clause makes writing SQL queries quicker and less error prone. Users can use the GROUP BY ALL functionality to either quickly prototype their SQL query or for quick ad-hoc queries.

Estimated Lab Time: 10 minutes

### Objective:
The objective of this lab is to familiarize you with GROUP BY ALL in Oracle Database 23ai and demonstrate its practical applications. By the end of this lab, you will be able to use GROUP BY ALL to simplify your aggregation queries and reduce redundancy in your SQL statements.

### Prerequisites:
- Access to Oracle Database 23ai.
- Basic understanding of SQL and GROUP BY clauses is helpful.

## Task 1: Understanding GROUP BY ALL

1. If you haven't done so already, from the Autonomous Database home page, **click** Database action and then **click** SQL.
    ![click SQL](../common-images/im1.png =50%x*)

    Using the ADMIN user isn't typically advised due to the high level of access and security concerns it poses. **However**, for this demo, we'll use it to simplify the setup and ensure we can show the full range of features effectively. 

2. Before we begin, this lab will be using Database Actions Web. If you're unfamiliar, please see the picture below for a simple explanation of the tool. You can click on the photo to enlarge it.

    ![click SQL](images/simple-db-actions.png =50%x*)

3. **Traditional GROUP BY Approach:**
   In traditional SQL queries with aggregation functions, you must explicitly list all non-aggregated columns from the SELECT list in the GROUP BY clause. Let's see an example using the DBA_OBJECTS view to count objects by owner, object type, and status.

    ```
    <copy>
    -- Traditional GROUP BY - notice we repeat OWNER, OBJECT_TYPE, STATUS
    SELECT OWNER, OBJECT_TYPE, STATUS, COUNT(*) as OBJECT_COUNT
    FROM DBA_OBJECTS 
    WHERE OWNER IN ('SYS', 'SYSTEM')
    GROUP BY OWNER, OBJECT_TYPE, STATUS
    ORDER BY OWNER, OBJECT_TYPE, STATUS;
    </copy>
    ```

4. **New GROUP BY ALL Approach:**
   With Oracle Database 23ai's GROUP BY ALL clause, we can simplify this query significantly. The ALL keyword automatically includes all non-aggregated columns in the grouping.

    ```
    <copy>
    -- GROUP BY ALL - no need to repeat non-aggregated columns
    SELECT OWNER, OBJECT_TYPE, STATUS, COUNT(*) as OBJECT_COUNT
    FROM DBA_OBJECTS 
    WHERE OWNER IN ('SYS', 'SYSTEM')
    GROUP BY ALL
    ORDER BY OWNER, OBJECT_TYPE, STATUS;
    </copy>
    ```

    Both queries produce identical results, but the second query is more concise and less error-prone.

## Task 2: Practical Examples with GROUP BY ALL

1. Let's create a sample table to demonstrate GROUP BY ALL with more complex scenarios.

    ```
    <copy>
    DROP TABLE IF EXISTS sales_data CASCADE CONSTRAINTS;

    CREATE TABLE sales_data (
        sale_id NUMBER,
        product_category VARCHAR2(50),
        product_name VARCHAR2(100),
        region VARCHAR2(50),
        sale_date DATE,
        quantity NUMBER,
        unit_price NUMBER(10,2)
    );
    </copy>
    ```

2. Insert sample data into our sales table.

    ```
    <copy>
    INSERT INTO sales_data VALUES (1, 'Electronics', 'Laptop', 'North', DATE '2024-01-15', 5, 999.99);
    INSERT INTO sales_data VALUES (2, 'Electronics', 'Smartphone', 'North', DATE '2024-01-16', 10, 699.99);
    INSERT INTO sales_data VALUES (3, 'Electronics', 'Laptop', 'South', DATE '2024-01-17', 3, 999.99);
    INSERT INTO sales_data VALUES (4, 'Books', 'Fiction Novel', 'North', DATE '2024-01-18', 25, 19.99);
    INSERT INTO sales_data VALUES (5, 'Books', 'Technical Manual', 'South', DATE '2024-01-19', 8, 49.99);
    INSERT INTO sales_data VALUES (6, 'Electronics', 'Tablet', 'East', DATE '2024-01-20', 7, 399.99);
    INSERT INTO sales_data VALUES (7, 'Books', 'Fiction Novel', 'East', DATE '2024-01-21', 15, 19.99);
    INSERT INTO sales_data VALUES (8, 'Electronics', 'Smartphone', 'South', DATE '2024-01-22', 12, 699.99);
    
    COMMIT;
    </copy>
    ```

3. Now let's use GROUP BY ALL to analyze sales by category and region. Notice how we don't need to repeat PRODUCT_CATEGORY and REGION in the GROUP BY clause.

    ```
    <copy>
    -- Analyze total sales and quantity by category and region
    SELECT PRODUCT_CATEGORY, 
           REGION,
           SUM(quantity * unit_price) as TOTAL_SALES,
           SUM(quantity) as TOTAL_QUANTITY,
           COUNT(*) as NUMBER_OF_TRANSACTIONS
    FROM sales_data
    GROUP BY ALL
    ORDER BY PRODUCT_CATEGORY, REGION;
    </copy>
    ```

4. Let's try a more complex example with multiple non-aggregated columns and different aggregate functions.

    ```
    <copy>
    -- Complex analysis with multiple dimensions
    SELECT PRODUCT_CATEGORY,
           PRODUCT_NAME,
           REGION,
           EXTRACT(MONTH FROM sale_date) as SALE_MONTH,
           AVG(unit_price) as AVG_PRICE,
           MAX(quantity) as MAX_QUANTITY,
           MIN(quantity) as MIN_QUANTITY,
           COUNT(*) as TRANSACTION_COUNT
    FROM sales_data
    GROUP BY ALL
    ORDER BY PRODUCT_CATEGORY, PRODUCT_NAME, REGION, SALE_MONTH;
    </copy>
    ```

## Task 3: Comparing Traditional vs GROUP BY ALL

1. Let's see the difference in query length and readability. First, the traditional approach for a complex grouping:

    ```
    <copy>
    -- Traditional approach - verbose and error-prone
    SELECT PRODUCT_CATEGORY,
           PRODUCT_NAME,
           REGION,
           TO_CHAR(sale_date, 'YYYY-MM') as SALE_MONTH,
           SUM(quantity * unit_price) as REVENUE,
           AVG(unit_price) as AVG_PRICE
    FROM sales_data
    GROUP BY PRODUCT_CATEGORY, PRODUCT_NAME, REGION, TO_CHAR(sale_date, 'YYYY-MM')
    ORDER BY PRODUCT_CATEGORY, PRODUCT_NAME, REGION, SALE_MONTH;
    </copy>
    ```

2. Now the same query using GROUP BY ALL - much cleaner:

    ```
    <copy>
    -- GROUP BY ALL approach - clean and concise
    SELECT PRODUCT_CATEGORY,
           PRODUCT_NAME,
           REGION,
           TO_CHAR(sale_date, 'YYYY-MM') as SALE_MONTH,
           SUM(quantity * unit_price) as REVENUE,
           AVG(unit_price) as AVG_PRICE
    FROM sales_data
    GROUP BY ALL
    ORDER BY PRODUCT_CATEGORY, PRODUCT_NAME, REGION, SALE_MONTH;
    </copy>
    ```

3. **Understanding the Execution Plan:**
   Behind the scenes, Oracle automatically expands GROUP BY ALL to include all non-aggregated columns. You can verify this by checking the execution plan:

    ```
    <copy>
    EXPLAIN PLAN FOR
    SELECT PRODUCT_CATEGORY, REGION, COUNT(*)
    FROM sales_data
    GROUP BY ALL;

    SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
    </copy>
    ```

## Task 4: Best Practices and Limitations

1. **When to Use GROUP BY ALL:**
   GROUP BY ALL is particularly useful for:
   - Quick prototyping and ad-hoc analysis
   - Reports with many grouping columns
   - Reducing maintenance when SELECT list changes

    ```
    <copy>
    -- Perfect use case: Many grouping columns
    SELECT OWNER, OBJECT_TYPE, STATUS, CREATED, 
           COUNT(*) as OBJECT_COUNT,
           MAX(LAST_DDL_TIME) as LATEST_MODIFICATION
    FROM DBA_OBJECTS 
    WHERE OWNER = 'SYSTEM'
    GROUP BY ALL
    ORDER BY OWNER, OBJECT_TYPE;
    </copy>
    ```

2. **Important Considerations:**
   - GROUP BY ALL only works when you have at least one aggregate function in the SELECT list
   - It automatically includes all non-aggregated columns from the SELECT list
   - The feature is available starting from Oracle Database 23ai (23.9)

    ```
    <copy>
    -- This will work - has aggregate function COUNT(*)
    SELECT PRODUCT_CATEGORY, REGION, COUNT(*)
    FROM sales_data
    GROUP BY ALL;
    </copy>
    ```

3. We can clean up our environment:

    ```
    <copy>
    DROP TABLE IF EXISTS sales_data CASCADE CONSTRAINTS;
    </copy>
    ```

## Summary

In this lab, we explored the GROUP BY ALL functionality in Oracle Database 23ai. This feature significantly simplifies SQL queries by automatically grouping by all non-aggregated columns in the SELECT list. Key benefits include:

- **Reduced Redundancy:** No need to repeat column names in both SELECT and GROUP BY clauses
- **Less Error-Prone:** Eliminates the common mistake of forgetting to include columns in GROUP BY
- **Improved Maintainability:** Changes to SELECT list don't require corresponding GROUP BY changes
- **Better Readability:** Cleaner, more concise SQL code

The GROUP BY ALL clause is particularly valuable for data analysis, reporting, and ad-hoc queries where you need to group by multiple dimensions.

You may now **proceed to the next lab**

## Learn More

* [GROUP BY ALL Documentation](https://docs.oracle.com/en/database/oracle/oracle-database/23/sqlrf/SELECT.html#GUID-CFA006CA-6FF1-4972-821E-6996142A51C6)
* [Oracle Database 23ai New Features](https://docs.oracle.com/en/database/oracle/oracle-database/23/nfcoa/index.html)

## Acknowledgements
* **Author** - Killian Lynch, Database Product Management
* **Last Updated By/Date** - Killian Lynch, August 2025