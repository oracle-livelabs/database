# Oracle AI Database 26ai SQL Features Lab

## Introduction

Welcome to the comprehensive Oracle AI Database 26ai SQL Features lab! In this lab, you'll explore five powerful new SQL enhancements that make writing queries more efficient, readable, and less error-prone. These features represent significant improvements in Oracle AI Database 26ai that simplify common database operations and modernize SQL development.

You'll learn about:
- Enhanced DML RETURNING clause for capturing old and new values
- UUID() function for generating RFC 9562-compliant unique identifiers  
- GROUP BY ALL for simplified aggregation queries
- Direct joins for UPDATE and DELETE operations
- Non-positional INSERT syntax with SET and BY NAME clauses

Estimated Lab Time: 30 minutes

### Objective:
By the end of this lab, you will understand and be able to use these five key SQL enhancements in Oracle AI Database 26ai to write more efficient, maintainable, and secure database applications.

### Prerequisites:
- Access to Oracle AI Database 26ai
- Basic understanding of SQL concepts

## Task 1: Enhanced DML RETURNING Clause


1. Before we begin, this lab will be using Database Actions Web. If you're unfamiliar, please see the picture below for a simple explanation of the tool. You can click on the photo to enlarge it.

    ![click SQL](../new-domains/images/simple-db-actions.png =50%x*)

3. **Understanding the Enhanced RETURNING Clause:**
   
   The enhanced RETURNING clause in Oracle AI Database 26ai is a simple improvement that allows you to capture both OLD and NEW values during UPDATE operations. This is valuable for:
    - **Audit trails** - Track what values changed during updates
    - **Change monitoring** - Capture price changes, status updates, etc.
    - **Business logic** - Calculate differences without additional queries
    - **Performance** - Eliminate extra SELECT statements to check changes

   Previously, you could only capture the final values after an UPDATE. Now you can see before and after values in a single operation.

    ```
    <copy>
    DROP TABLE if exists PRODUCTS CASCADE CONSTRAINT;
    
    -- Create PRODUCTS table for demonstrating RETURNING enhancements
    CREATE TABLE PRODUCTS (
        PRODUCT_ID INT PRIMARY KEY,
        PRODUCT_NAME VARCHAR2(100),
        PRICE DECIMAL(10,2),
        LAST_UPDATED DATE
    );

    -- Insert sample data
    INSERT INTO PRODUCTS (PRODUCT_ID, PRODUCT_NAME, PRICE, LAST_UPDATED) VALUES
    (1, 'Gaming Laptop', 1299.99, SYSDATE),
    (2, 'Wireless Mouse', 49.99, SYSDATE),
    (3, 'Mechanical Keyboard', 129.99, SYSDATE),
    (4, 'Gaming Monitor', 399.99, SYSDATE),
    (5, 'Gaming Headset', 89.99, SYSDATE);
    </copy>
    ```

4. Now let's see the enhanced RETURNING clause in action. We'll increase all prices by 10% and capture both the old and new values, plus calculate the difference automatically:

    ```
    <copy>
    DECLARE
        TYPE t_product_name IS TABLE OF VARCHAR2(100);
        TYPE t_price IS TABLE OF NUMBER;
        l_product_names t_product_name;
        l_old_prices t_price;
        l_new_prices t_price;
        l_price_differences t_price;
    BEGIN
        UPDATE PRODUCTS
        SET PRICE = PRICE * 1.1,
            LAST_UPDATED = SYSDATE
        RETURNING 
            PRODUCT_NAME,
            OLD PRICE,
            NEW PRICE,
            ROUND((NEW PRICE - OLD PRICE), 2)
        BULK COLLECT INTO 
            l_product_names,
            l_old_prices,
            l_new_prices,
            l_price_differences;
            
        -- Display the results
        FOR i IN 1..l_product_names.COUNT LOOP
            DBMS_OUTPUT.PUT_LINE(
                'Product: ' || l_product_names(i) ||
                ', Old Price: $' || l_old_prices(i) ||
                ', New Price: $' || l_new_prices(i) ||
                ', Difference: $' || l_price_differences(i)
            );
        END LOOP;
    END;
    /
    </copy>
    ```

## Task 2: UUID Generation for Modern Applications

1. Oracle AI Database 26ai introduces the UUID() function that generates RFC 9562-compliant version 4 variant 1 UUIDs. These are truly random and unpredictable, unlike the traditional SYS_GUID() function.

   **Why could SYS\_GUID() be predictable?**
   SYS\_GUID() generates values using a combination of host identifier, process identifier, and a sequential component. This often results in values that increment sequentially - for example, consecutive calls might generate values where only one character changes while the rest remains identical. This predictable pattern makes SYS_GUID() unsuitable for security-sensitive applications.

   **Why is UUID() truly random?**
   UUID() generates RFC 9562-compliant version 4 UUIDs with 122 bits of cryptographic randomness (only 6 bits are reserved for version and variant identifiers). This provides 2^122 possible unique values with no predictable patterns.

3. Create a user sessions table that leverages UUID for primary keys (note that UUID() returns RAW(16) data type, which is required for UUID storage):

    ```
    <copy>
    DROP TABLE IF EXISTS user_sessions CASCADE CONSTRAINTS;

    CREATE TABLE user_sessions (
        session_id RAW(16) PRIMARY KEY,
        user_id NUMBER NOT NULL,
        session_start TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        ip_address VARCHAR2(45),
        user_agent VARCHAR2(500),
        status VARCHAR2(20) DEFAULT 'ACTIVE'
    );
    </copy>
    ```

4. Insert data and see UUID generation in action:

    ```
    <copy>
    -- Insert data with explicit UUID generation
    INSERT INTO user_sessions (session_id, user_id, ip_address, user_agent, status) 
    VALUES (UUID(), 1001, '192.168.1.100', 'Mozilla/5.0 Chrome/120.0', 'ACTIVE');

    INSERT INTO user_sessions (session_id, user_id, ip_address, user_agent, status) 
    VALUES (UUID(), 1002, '10.0.0.50', 'Mozilla/5.0 Firefox/121.0', 'ACTIVE');

    SELECT *
    FROM user_sessions;
    </copy>
    ```

## Task 3: Simplified Aggregation with GROUP BY ALL

1. The GROUP BY ALL clause eliminates the need to explicitly list all non-aggregated columns in the GROUP BY clause. Let's create sample sales data to demonstrate:

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
        (6, 'Electronics', 'Tablet', 'East', 'USA', 'Alice Brown', 'Consumer', 'February', 7, 399.99);

    COMMIT;
    </copy>
    ```

2. Now compare traditional GROUP BY with the new GROUP BY ALL:

    ```
    <copy>
    -- Traditional approach - lists everything
    SELECT PRODUCT_CATEGORY,
           PRODUCT_NAME,
           REGION,
           COUNTRY,
           SALES_REP,
           CUSTOMER_SEGMENT,
           SALE_MONTH,
           SUM(quantity * unit_price) as REVENUE,
           AVG(unit_price) as AVG_PRICE,
           COUNT(*) as TRANSACTIONS
    FROM sales_data
    GROUP BY PRODUCT_CATEGORY, PRODUCT_NAME, REGION, COUNTRY, SALES_REP, CUSTOMER_SEGMENT, SALE_MONTH
    ORDER BY PRODUCT_CATEGORY, PRODUCT_NAME, REGION;
    </copy>
    ```

3. Now use GROUP BY ALL 

    ```
    <copy>
    -- GROUP BY ALL approach - clean and concisecolumns
    SELECT PRODUCT_CATEGORY,
           PRODUCT_NAME,
           REGION,
           COUNTRY,
           SALES_REP,
           CUSTOMER_SEGMENT,
           SALE_MONTH,
           SUM(quantity * unit_price) as REVENUE,
           AVG(unit_price) as AVG_PRICE,
           COUNT(*) as TRANSACTIONS
    FROM sales_data
    GROUP BY ALL
    ORDER BY PRODUCT_CATEGORY, PRODUCT_NAME, REGION;
    </copy>
    ```

## Task 4: Direct Joins for UPDATE and DELETE

1. Oracle AI Database 26ai introduces direct joins for UPDATE and DELETE statements, making multi-table operations much simpler. Before 26ai, you had to use subqueries or complex WHERE clauses. Now you can use familiar JOIN syntax directly in UPDATE/DELETE statements. Let's create a movie streaming scenario:

    ```
    <copy>
    DROP TABLE if exists GENRES CASCADE CONSTRAINT;
    DROP TABLE if exists MOVIES CASCADE CONSTRAINT;
    
    -- Create GENRES table
    CREATE TABLE GENRES (
        GENRE_ID INT PRIMARY KEY,
        GENRE_NAME VARCHAR(50)
    );

    -- Create MOVIES table
    CREATE TABLE MOVIES (
        MOVIE_ID INT PRIMARY KEY,
        TITLE VARCHAR(100),
        GENRE_ID INT,
        RATING DECIMAL(3,1),
        FOREIGN KEY (GENRE_ID) REFERENCES GENRES(GENRE_ID)
    );

    -- Insert sample data
    INSERT INTO GENRES (GENRE_ID, GENRE_NAME) VALUES
    (1, 'Thriller'), (2, 'Horror'), (3, 'Comedy'), (4, 'Drama');

    INSERT INTO MOVIES (MOVIE_ID, TITLE, GENRE_ID, RATING) VALUES
    (1, 'The Silence of the Lambs', 1, 8.6),
    (2, 'Psycho', 2, 8.5),
    (3, 'Airplane!', 3, 7.7),
    (4, 'The Shawshank Redemption', 4, 9.3),
    (5, 'Seven', 1, 8.6),
    (6, 'A Nightmare on Elm Street', 2, 7.5),
    (7, 'Monty Python and the Holy Grail', 3, 8.2);
    </copy>
    ```

2. Before Oracle 26ai, updating rows based on conditions from other tables required subqueries:

    ```
    <copy>
    UPDATE movies 
    SET rating = rating + 0.5
    WHERE genre_id IN (
        SELECT genre_id 
        FROM genres 
        WHERE genre_name = 'Thriller'
    );
    
    -- What if we wanted to use data from the genres table in the SET clause?
    -- Traditional approach gets very complex with correlated subqueries:
    UPDATE movies m1
    SET rating = rating + 0.5,
        title = title || ' (' || (
            SELECT g.genre_name 
            FROM genres g 
            WHERE g.genre_id = m1.genre_id
        ) || ' Classic)'
    WHERE EXISTS (
        SELECT 1 
        FROM genres g 
        WHERE g.genre_id = m1.genre_id 
        AND g.genre_name = 'Thriller'
    );
    </copy>
    ```

3. **The Solution:** Oracle 26ai direct joins make this much simpler:

    ```
    <copy>
    -- Reset the titles first
    UPDATE movies SET title = REPLACE(title, ' (Thriller Classic)', '') WHERE title LIKE '%(Thriller Classic)%';
    
    -- Oracle AI Database 26ai: Direct join UPDATE - clean and intuitive
    UPDATE movies m
    SET m.rating = m.rating + 0.5,
        m.title = m.title || ' (' || g.genre_name || ' Classic)'
    FROM genres g
    WHERE m.genre_id = g.genre_id
    AND g.genre_name = 'Thriller';

    -- Check the results - notice how we can easily access both table's data
    SELECT m.title, m.rating, g.genre_name
    FROM movies m
    JOIN genres g ON m.genre_id = g.genre_id
    WHERE g.genre_name = 'Thriller';
    </copy>
    ```

4. Compare traditional vs direct join DELETE operations:

    ```
    <copy>
    -- Traditional approach: DELETE with subquery (more complex)
    DELETE FROM movies 
    WHERE genre_id IN (
        SELECT genre_id 
        FROM genres 
        WHERE genre_name = 'Horror'
    );

    -- Oracle AI Database 26ai: Direct join DELETE - clean and readable
    DELETE FROM movies m
    FROM genres g
    WHERE m.genre_id = g.genre_id
    AND g.genre_name = 'Comedy';

    -- Verify comedy movies are gone
    SELECT COUNT(*) as COMEDY_MOVIES_REMAINING
    FROM movies m
    JOIN genres g ON m.genre_id = g.genre_id
    WHERE g.genre_name = 'Comedy';
    </copy>
    ```

## Task 5: Non-Positional INSERT Enhancements

1. Oracle AI Database 26ai introduces two new INSERT syntaxes that make INSERT statements more readable and flexible. Let's create an employee table to demonstrate:

    ```
    <copy>
    DROP TABLE IF EXISTS employees CASCADE CONSTRAINTS;
    DROP TABLE IF EXISTS employees_copy CASCADE CONSTRAINTS;

    CREATE TABLE employees (
        emp_id NUMBER PRIMARY KEY,
        emp_name VARCHAR2(100),
        job_title VARCHAR2(50),
        salary NUMBER(10,2),
        department VARCHAR2(50),
        hire_date DATE
    );

    CREATE TABLE employees_copy (
        emp_id NUMBER PRIMARY KEY,
        emp_name VARCHAR2(100),
        job_title VARCHAR2(50),
        salary NUMBER(10,2),
        department VARCHAR2(50),
        hire_date DATE,
        created_date DATE DEFAULT SYSDATE  -- Additional column
    );
    </copy>
    ```

2. **INSERT INTO SET Syntax** - Similar to UPDATE syntax, more readable:

    ```
    <copy>
    -- Traditional INSERT
    INSERT INTO employees (emp_id, emp_name, job_title, salary, department, hire_date)
    VALUES (1001, 'John Smith', 'Database Administrator', 75000, 'IT', DATE '2024-01-15');

    -- New INSERT INTO SET - more readable, similar to UPDATE
    INSERT INTO employees SET
        emp_id = 1002,
        emp_name = 'Jane Doe',
        job_title = 'Senior Developer',
        salary = 85000,
        department = 'Engineering',
        hire_date = DATE '2024-02-01';

    -- Multiple rows with INSERT INTO SET (correct syntax)
    INSERT INTO employees SET
        (emp_id = 1003, emp_name = 'Bob Wilson', job_title = 'Data Analyst', 
         salary = 65000, department = 'Analytics', hire_date = DATE '2024-02-15'),
        (emp_id = 1004, emp_name = 'Alice Brown', job_title = 'Project Manager', 
         salary = 90000, department = 'IT', hire_date = DATE '2024-03-01');
    </copy>
    ```

3. **INSERT INTO BY NAME Syntax** - Matches columns by name, not position:

    ```
    <copy>
    -- Traditional INSERT requires exact column order
    INSERT INTO employees_copy (emp_id, emp_name, job_title, salary, department, hire_date)
    SELECT emp_id, emp_name, job_title, salary, department, hire_date
    FROM employees;

    -- Clear the table for BY NAME demonstration
    DELETE FROM employees_copy;

    -- INSERT INTO BY NAME - simplest approach with SELECT *
    INSERT INTO employees_copy BY NAME
    SELECT * FROM employees;

    -- Alternative: BY NAME with different column order (names match automatically)
    INSERT INTO employees_copy BY NAME
    SELECT salary,           -- Different order
           emp_name,         -- but names match
           hire_date,
           job_title,
           department,
           emp_id
    FROM employees
    WHERE emp_id > 1002;  -- Add only remaining employees

    -- Verify the data was inserted correctly
    SELECT emp_id, emp_name, job_title, created_date FROM employees_copy ORDER BY emp_id;
    </copy>
    ```

4. **Practical Benefits** - BY NAME works even with additional columns:

    ```
    <copy>
    -- Add more employees to source table
    INSERT INTO employees SET
        emp_id = 1005,
        emp_name = 'Charlie Davis',
        job_title = 'Systems Architect',
        salary = 95000,
        department = 'Architecture',
        hire_date = DATE '2024-03-15';

    -- BY NAME INSERT ignores extra columns in destination table
    INSERT INTO employees_copy BY NAME
    SELECT emp_id, emp_name, job_title, salary, department, hire_date
    FROM employees
    WHERE emp_id = 1005;

    -- Show final results
    SELECT emp_id, emp_name, job_title, salary, 
           created_date  -- This was auto-populated
    FROM employees_copy 
    WHERE emp_id = 1005;
    </copy>
    ```

## Task 6: Clean Up

1. Clean up all the tables we created during this lab:

    ```
    <copy>
    DROP TABLE IF EXISTS PRODUCTS CASCADE CONSTRAINT;
    DROP TABLE IF EXISTS user_sessions CASCADE CONSTRAINTS;
    DROP TABLE IF EXISTS sales_data CASCADE CONSTRAINTS;
    DROP TABLE IF EXISTS GENRES CASCADE CONSTRAINT;
    DROP TABLE IF EXISTS MOVIES CASCADE CONSTRAINT;
    DROP TABLE IF EXISTS employees CASCADE CONSTRAINTS;
    DROP TABLE IF EXISTS employees_copy CASCADE CONSTRAINTS;
    </copy>
    ```

## Summary

In this comprehensive lab, you've explored five major SQL enhancements in Oracle AI Database 26ai:

1. **Enhanced RETURNING Clause**: Capture both old and new values during DML operations for better auditing and change tracking
2. **UUID() Function**: Generate RFC 9562-compliant, truly random unique identifiers for modern security requirements
3. **GROUP BY ALL**: Simplify aggregation queries by automatically grouping on all non-aggregated columns
4. **Direct Joins**: Perform UPDATE and DELETE operations across multiple tables with clean, readable syntax
5. **Non-Positional INSERT**: Use SET and BY NAME clauses for more readable and flexible INSERT statements

These features collectively make Oracle AI Database 26ai more developer-friendly, reducing code complexity while improving security, maintainability, and readability of SQL applications.

## Key Benefits:
- **Reduced Code Complexity**: Less verbose syntax with GROUP BY ALL and direct joins
- **Enhanced Security**: True random UUIDs for unpredictable identifiers  
- **Better Auditing**: Enhanced RETURNING clause captures complete change information
- **Improved Maintainability**: Non-positional INSERT adapts to schema changes
- **Developer Productivity**: More intuitive syntax across all features

You may now **proceed to the next lab**

## Learn More

* [Enhanced RETURNING Clause Documentation](https://docs.oracle.com/en/database/oracle/oracle-database/23/sqlrf/UPDATE.html)
* [UUID Function Documentation](https://docs.oracle.com/en/database/oracle/oracle-database/23/nfcoa/index.html)
* [GROUP BY ALL Documentation](https://docs.oracle.com/en/database/oracle/oracle-database/23/sqlrf/SELECT.html#GUID-CFA006CA-6FF1-4972-821E-6996142A51C6)
* [Direct Joins Documentation](https://docs.oracle.com/en/database/oracle/oracle-database/23/nfcoa/application-development.html#GUID-326C2680-1D34-4615-93DF-917CB394CB73)
* [RFC 9562: Universally Unique IDentifiers](https://www.rfc-editor.org/rfc/rfc9562.html)

## Acknowledgements
* **Author** - Killian Lynch, Database Product Management
* **Last Updated By/Date** - Killian Lynch, September 2025