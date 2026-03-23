# Simplified Aggregation with GROUP BY ALL

## Introduction

Welcome to Simplified Aggregation with GROUP BY ALL. In this lab, you'll learn about the GROUP BY ALL clause feature in Oracle AI Database 26ai. This enhancement removes the need to explicitly list all non-aggregated columns in the GROUP BY clause.

The GROUP BY ALL clause automatically groups by all columns in the SELECT list that are not part of aggregate functions, making it easier and more intuitive to write complex analytical queries that use this functionality.

Estimated Lab Time: 10 minutes

### Objective:
The goal of this lab is to help you understand and use the GROUP BY ALL clause in Oracle 26ai. By the end of this lab, you'll be able to write cleaner aggregation queries and understand when GROUP BY ALL provides the most benefit.

### Prerequisites:
- Access to Oracle AI Database 26ai
- Basic understanding of SQL GROUP BY operations is helpful

## Task 1: Understanding GROUP BY ALL

1. If you haven't done so already, from the Autonomous AI Database home page, **click** Database action and then **click** SQL.
    ![click SQL](../common-images/im1.png =50%x*)

    Using the ADMIN user isn't typically advised due to the high level of access and security concerns it poses. **However**, for this demo, we'll use it to simplify the setup and ensure we can show the full range of features effectively.

2. Before we begin, this lab will be using Database Actions Web. If you're unfamiliar, please see the picture below for a simple explanation of the tool. You can click on the photo to enlarge it.

    ![click SQL](../common-images/simple-db-actions.png =50%x*)

3. Let's create a sales dataset

    ```
    <copy>
    DROP TABLE IF EXISTS sales_data CASCADE CONSTRAINTS;

    CREATE TABLE sales_data (
        sale_id NUMBER,
        product_category VARCHAR2(50),
        product_name VARCHAR2(100),
        region VARCHAR2(50),
        country VARCHAR2(50),
        sales_rep VARCHAR2(100),
        customer_segment VARCHAR2(50),
        sale_month VARCHAR2(20),
        quantity NUMBER,
        unit_price NUMBER(10,2)
    );

    -- Insert sample data
    INSERT INTO sales_data VALUES 
        (1, 'Electronics', 'Laptop', 'North', 'USA', 'John Smith', 'Enterprise', 'January', 5, 999.99),
        (2, 'Electronics', 'Smartphone', 'North', 'USA', 'John Smith', 'Consumer', 'January', 10, 699.99),
        (3, 'Electronics', 'Laptop', 'South', 'USA', 'Jane Doe', 'Enterprise', 'January', 3, 999.99),
        (4, 'Books', 'Fiction Novel', 'North', 'Canada', 'Bob Wilson', 'Consumer', 'January', 25, 19.99),
        (5, 'Books', 'Technical Manual', 'South', 'USA', 'Jane Doe', 'Education', 'February', 8, 49.99),
        (6, 'Electronics', 'Tablet', 'East', 'USA', 'Alice Brown', 'Consumer', 'February', 7, 399.99),
        (7, 'Electronics', 'Headphones', 'North', 'USA', 'John Smith', 'Consumer', 'February', 12, 199.99),
        (8, 'Books', 'Business Guide', 'East', 'USA', 'Alice Brown', 'Enterprise', 'February', 15, 29.99),
        (9, 'Electronics', 'Smartphone', 'West', 'USA', 'Mike Johnson', 'Consumer', 'March', 8, 699.99),
        (10, 'Books', 'Science Textbook', 'South', 'USA', 'Jane Doe', 'Education', 'March', 20, 89.99);

    COMMIT;
    </copy>
    ```

## Task 2: Traditional GROUP BY vs GROUP BY ALL

1. **The Traditional Approach** - Let's create a query using the traditional GROUP BY syntax. Notice how we need to **list every non-aggregated column:**

    ```
    <copy>
    -- Traditional GROUP BY - requires listing all non-aggregated columns
    SELECT PRODUCT_CATEGORY,
           PRODUCT_NAME,
           REGION,
           COUNTRY,
           SALES_REP,
           CUSTOMER_SEGMENT,
           SALE_MONTH,
           SUM(quantity * unit_price) as TOTAL_REVENUE,
           AVG(unit_price) as AVG_UNIT_PRICE,
           COUNT(*) as TOTAL_TRANSACTIONS,
           MAX(quantity) as MAX_QUANTITY_SOLD
    FROM sales_data
    GROUP BY PRODUCT_CATEGORY, PRODUCT_NAME, REGION, COUNTRY, SALES_REP, CUSTOMER_SEGMENT, SALE_MONTH
    ORDER BY PRODUCT_CATEGORY, PRODUCT_NAME, REGION;
    </copy>
    ```

2. **The GROUP BY ALL Solution** -  Notice how much cleaner and more maintainable this syntax is. This is a small example, but you can imagine how in a production system this statement could become huge without group by all. 

    ```
    <copy>
    -- GROUP BY ALL - automatically groups by all non-aggregated columns
    SELECT PRODUCT_CATEGORY,
           PRODUCT_NAME,
           REGION,
           COUNTRY,
           SALES_REP,
           CUSTOMER_SEGMENT,
           SALE_MONTH,
           SUM(quantity * unit_price) as TOTAL_REVENUE,
           AVG(unit_price) as AVG_UNIT_PRICE,
           COUNT(*) as TOTAL_TRANSACTIONS,
           MAX(quantity) as MAX_QUANTITY_SOLD
    FROM sales_data
    GROUP BY ALL
    ORDER BY PRODUCT_CATEGORY, PRODUCT_NAME, REGION;
    </copy>
    ```

3. **Error Prevention** - GROUP BY ALL helps prevent common mistakes. Let's see what happens when we accidentally miss a column in traditional GROUP BY:

    ```
    <copy>
    -- This would cause an error in traditional GROUP BY if we missed a column
    -- Let's see with a query that would fail traditionally:
    
    -- This would error if SALES_REP was missing from GROUP BY
    -- SELECT PRODUCT_CATEGORY, REGION, SALES_REP, SUM(quantity * unit_price) as REVENUE
    -- FROM sales_data  
    -- GROUP BY PRODUCT_CATEGORY, REGION;  -- Missing SALES_REP - would cause ORA-00979
    
    -- GROUP BY ALL approach - automatically handles all non-aggregated columns
    SELECT PRODUCT_CATEGORY, 
           REGION, 
           SALES_REP, 
           SUM(quantity * unit_price) as REVENUE,
           COUNT(*) as TRANSACTIONS
    FROM sales_data  
    GROUP BY ALL  -- No risk of missing columns
    ORDER BY REVENUE DESC;
    </copy>
    ```

## Task 3: Clean Up

1. In this Lab, you learned how to use GROUP BY ALL in Oracle AI Database 26ai to simplify aggregation queries and prevent common grouping errors.

2. We can clean up from the lab by dropping our table:

    ```
    <copy>
    DROP TABLE IF EXISTS sales_data CASCADE CONSTRAINTS;
    </copy>
    ```

## Learn More

* [GROUP BY ALL Documentation](https://docs.oracle.com/en/database/oracle/oracle-database/23/sqlrf/SELECT.html#GUID-CFA006CA-6FF1-4972-821E-6996142A51C6)
* [SQL Aggregation Best Practices](https://docs.oracle.com/en/database/oracle/oracle-database/23/sqlrf/Aggregate-Functions.html)

## Acknowledgements
* **Author** - Killian Lynch, Database Product Management
* **Contributors**
* **Last Updated By/Date** - Killian Lynch, October 2025