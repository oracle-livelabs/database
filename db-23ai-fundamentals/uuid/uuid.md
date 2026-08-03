# Generate and Test UUID Using SQL

## Introduction

Welcome to the "Generate and Test UUID Using SQL" lab. In this lab, you will learn how to use the new UUID() function in Oracle Database 23ai to generate RFC 9562-compliant universally unique identifiers. UUID is a 128-bit universal unique identifier popularly used by applications to generate an unpredictable, random value which can be used as a primary key in a table, a transaction ID, or any form of unique identifier.

In Oracle Database 23ai, the SQL function UUID() generates a version 4 variant 1 UUID in the database per the UUID RFC 9562. The UUID generation and manipulation functions offer a compliant way of generating a random, unique, and unpredictable identifier that can be used to populate a primary key column in a database table, to uniquely identify a transaction ID (for example, for the Sessionless Transactions feature in Oracle Database 23ai), and many other purposes.

Modern applications expect to be able to generate a UUID that is unpredictable and random. All major databases and data management systems support some form of UUID generation and manipulation. The current Oracle SQL operator SYS_GUID() always produces a predictable sequence of unique identifiers which is not optimal for modern security requirements.

Estimated Lab Time: 15 minutes

### Objective:
The objective of this lab is to familiarize you with UUID generation in Oracle Database 23ai and demonstrate its practical applications. By the end of this lab, you will understand the differences between UUID() and SYS_GUID(), learn how to generate RFC 9562-compliant UUIDs, and implement UUID-based primary keys in your database tables.

### Prerequisites:
- Access to Oracle Database 23ai.
- Basic understanding of SQL and unique identifiers.

### Note on Oracle Database 23ai SQL Simplification:
This lab takes advantage of Oracle Database 23ai's ability to omit the `FROM DUAL` clause when selecting expressions or calling functions. This makes SQL more concise and readable while maintaining the same functionality.

## Task 1: Understanding UUID vs SYS_GUID

1. If you haven't done so already, from the Autonomous Database home page, **click** Database action and then **click** SQL.
    ![click SQL](../common-images/im1.png =50%x*)

    Using the ADMIN user isn't typically advised due to the high level of access and security concerns it poses. **However**, for this demo, we'll use it to simplify the setup and ensure we can show the full range of features effectively. 

2. Before we begin, this lab will be using Database Actions Web. If you're unfamiliar, please see the picture below for a simple explanation of the tool. You can click on the photo to enlarge it.

    ![click SQL](images/simple-db-actions.png =50%x*)

3. **Understanding SYS_GUID() Limitations:**
   First, let's examine the traditional SYS_GUID() function and understand why it's considered predictable. The SYS_GUID() function generates a globally unique identifier, but the sequence can be predictable.

    ```
    <copy>
    -- Generate multiple SYS_GUID values (no FROM DUAL needed in 23ai!)
    SELECT 'SYS_GUID Example' as TYPE, SYS_GUID() as IDENTIFIER
    UNION ALL
    SELECT 'SYS_GUID Example', SYS_GUID()
    UNION ALL
    SELECT 'SYS_GUID Example', SYS_GUID()
    UNION ALL
    SELECT 'SYS_GUID Example', SYS_GUID()
    UNION ALL
    SELECT 'SYS_GUID Example', SYS_GUID();
    </copy>
    ```

4. **Understanding the New UUID() Function:**
   Now let's examine the new UUID() function, which generates RFC 9562-compliant version 4 variant 1 UUIDs that are truly random and unpredictable.

    ```
    <copy>
    -- Generate multiple UUID values (leveraging 23ai's FROM DUAL omission)
    SELECT 'UUID Example' as TYPE, UUID() as IDENTIFIER
    UNION ALL
    SELECT 'UUID Example', UUID()
    UNION ALL
    SELECT 'UUID Example', UUID()
    UNION ALL
    SELECT 'UUID Example', UUID()
    UNION ALL
    SELECT 'UUID Example', UUID();
    </copy>
    ```

5. **Comparing UUID and SYS_GUID Side by Side:**
   Let's compare both functions to see the difference in their output format and characteristics.

    ```
    <copy>
    -- Compare UUID and SYS_GUID (showcasing 23ai FROM DUAL simplification)
    SELECT 
        'Traditional' as METHOD,
        SYS_GUID() as RAW_VALUE,
        RAWTOHEX(SYS_GUID()) as HEX_STRING,
        LENGTH(RAWTOHEX(SYS_GUID())) as HEX_LENGTH
    UNION ALL
    SELECT 
        'RFC 9562 UUID',
        UUID() as RAW_VALUE,
        RAWTOHEX(UUID()) as HEX_STRING,
        LENGTH(RAWTOHEX(UUID())) as HEX_LENGTH;
    </copy>
    ```

## Task 2: Working with UUID in Database Tables

1. Let's create a table that uses UUID as a primary key to demonstrate practical usage.

    ```
    <copy>
    DROP TABLE IF EXISTS user_sessions CASCADE CONSTRAINTS;

    CREATE TABLE user_sessions (
        session_id RAW(16) DEFAULT UUID() PRIMARY KEY,
        user_id NUMBER NOT NULL,
        session_start TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        session_end TIMESTAMP,
        ip_address VARCHAR2(45),
        user_agent VARCHAR2(500),
        status VARCHAR2(20) DEFAULT 'ACTIVE'
    );
    </copy>
    ```

2. Insert some sample data into our user_sessions table. Notice how the UUID is automatically generated for the primary key.

    ```
    <copy>
    -- Insert data with automatic UUID generation
    INSERT INTO user_sessions (user_id, ip_address, user_agent, status) 
    VALUES (1001, '192.168.1.100', 'Mozilla/5.0 Chrome/120.0', 'ACTIVE');

    INSERT INTO user_sessions (user_id, ip_address, user_agent, status) 
    VALUES (1002, '10.0.0.50', 'Mozilla/5.0 Firefox/121.0', 'ACTIVE');

    INSERT INTO user_sessions (user_id, ip_address, user_agent, status) 
    VALUES (1003, '172.16.0.25', 'Safari/17.2', 'INACTIVE');

    -- Insert with explicit UUID
    INSERT INTO user_sessions (session_id, user_id, ip_address, user_agent, status) 
    VALUES (UUID(), 1004, '203.0.113.45', 'Edge/120.0', 'ACTIVE');

    COMMIT;
    </copy>
    ```

3. Query the table to see the generated UUIDs and convert them to readable hex format.

    ```
    <copy>
    SELECT 
        RAWTOHEX(session_id) as SESSION_ID_HEX,
        user_id,
        session_start,
        ip_address,
        status
    FROM user_sessions
    ORDER BY session_start;
    </copy>
    ```

## Task 3: UUID Format and RFC 9562 Compliance

1. Let's examine the structure of the UUID to understand its RFC 9562 compliance. A version 4 variant 1 UUID has specific bit patterns.

    ```
    <copy>
    -- Analyze UUID structure and format
    WITH uuid_analysis AS (
        SELECT 
            UUID() as raw_uuid,
            RAWTOHEX(UUID()) as hex_uuid
        CONNECT BY LEVEL <= 5
    )
    SELECT 
        hex_uuid as FULL_UUID,
        SUBSTR(hex_uuid, 1, 8) as TIME_LOW,
        SUBSTR(hex_uuid, 9, 4) as TIME_MID,
        SUBSTR(hex_uuid, 13, 4) as TIME_HIGH_VERSION,
        SUBSTR(hex_uuid, 17, 4) as CLOCK_SEQ_VARIANT,
        SUBSTR(hex_uuid, 21, 12) as NODE,
        -- Check version (should be 4 for random UUID)
        SUBSTR(hex_uuid, 13, 1) as VERSION_DIGIT,
        -- Check variant (should be 8, 9, A, or B)
        SUBSTR(hex_uuid, 17, 1) as VARIANT_DIGIT
    FROM uuid_analysis;
    </copy>
    ```

2. Let's create a function to format UUID as a standard hyphenated string, which is the common representation.

    ```
    <copy>
    -- Format UUID in standard representation (with hyphens)
    SELECT 
        RAWTOHEX(UUID()) as RAW_HEX,
        REGEXP_REPLACE(
            RAWTOHEX(UUID()), 
            '([0-9A-F]{8})([0-9A-F]{4})([0-9A-F]{4})([0-9A-F]{4})([0-9A-F]{12})', 
            '\1-\2-\3-\4-\5'
        ) as FORMATTED_UUID
    CONNECT BY LEVEL <= 3;
    </copy>
    ```

## Task 4: Practical UUID Applications

1. **Transaction Tracking Example:**
   Create a transaction log table that uses UUID for correlation across distributed systems.

    ```
    <copy>
    DROP TABLE IF EXISTS transaction_log CASCADE CONSTRAINTS;

    CREATE TABLE transaction_log (
        transaction_id RAW(16) DEFAULT UUID() PRIMARY KEY,
        correlation_id RAW(16) DEFAULT UUID(),
        transaction_type VARCHAR2(50) NOT NULL,
        amount NUMBER(10,2),
        account_from VARCHAR2(20),
        account_to VARCHAR2(20),
        transaction_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        status VARCHAR2(20) DEFAULT 'PENDING'
    );
    </copy>
    ```

2. Insert some financial transaction records.

    ```
    <copy>
    -- Insert transaction records
    INSERT INTO transaction_log (transaction_type, amount, account_from, account_to, status) 
    VALUES ('TRANSFER', 1500.00, 'ACC001', 'ACC002', 'COMPLETED');

    INSERT INTO transaction_log (transaction_type, amount, account_from, account_to, status) 
    VALUES ('DEPOSIT', 2000.00, NULL, 'ACC001', 'COMPLETED');

    INSERT INTO transaction_log (transaction_type, amount, account_from, account_to, status) 
    VALUES ('WITHDRAWAL', 500.00, 'ACC002', NULL, 'PENDING');

    -- Create a related transaction with shared correlation_id
    DECLARE
        shared_correlation RAW(16) := UUID();
    BEGIN
        INSERT INTO transaction_log (correlation_id, transaction_type, amount, account_from, account_to, status) 
        VALUES (shared_correlation, 'TRANSFER_DEBIT', 750.00, 'ACC001', 'ACC003', 'COMPLETED');
        
        INSERT INTO transaction_log (correlation_id, transaction_type, amount, account_from, account_to, status) 
        VALUES (shared_correlation, 'TRANSFER_CREDIT', 750.00, 'ACC001', 'ACC003', 'COMPLETED');
        
        COMMIT;
    END;
    /
    </copy>
    ```

3. Query the transaction log with formatted UUIDs.

    ```
    <copy>
    SELECT 
        REGEXP_REPLACE(RAWTOHEX(transaction_id), 
                      '([0-9A-F]{8})([0-9A-F]{4})([0-9A-F]{4})([0-9A-F]{4})([0-9A-F]{12})', 
                      '\1-\2-\3-\4-\5') as TRANSACTION_ID,
        REGEXP_REPLACE(RAWTOHEX(correlation_id), 
                      '([0-9A-F]{8})([0-9A-F]{4})([0-9A-F]{4})([0-9A-F]{4})([0-9A-F]{12})', 
                      '\1-\2-\3-\4-\5') as CORRELATION_ID,
        transaction_type,
        amount,
        account_from,
        account_to,
        status,
        transaction_timestamp
    FROM transaction_log
    ORDER BY transaction_timestamp;
    </copy>
    ```

## Task 5: UUID Performance and Best Practices

1. **Indexing with UUID:**
   Let's examine how UUIDs perform as primary keys and create appropriate indexes.

    ```
    <copy>
    -- Create a larger table to test UUID performance
    DROP TABLE IF EXISTS large_uuid_test CASCADE CONSTRAINTS;

    CREATE TABLE large_uuid_test (
        id RAW(16) DEFAULT UUID() PRIMARY KEY,
        data_value VARCHAR2(100),
        created_date DATE DEFAULT SYSDATE,
        category VARCHAR2(20)
    );

    -- Create an index on category for better query performance
    CREATE INDEX idx_uuid_category ON large_uuid_test(category);
    </copy>
    ```

2. Insert bulk data to test performance characteristics.

    ```
    <copy>
    -- Insert sample data for performance testing
    INSERT INTO large_uuid_test (data_value, category)
    SELECT 
        'Sample Data ' || LEVEL,
        CASE 
            WHEN MOD(LEVEL, 4) = 0 THEN 'CATEGORY_A'
            WHEN MOD(LEVEL, 4) = 1 THEN 'CATEGORY_B'
            WHEN MOD(LEVEL, 4) = 2 THEN 'CATEGORY_C'
            ELSE 'CATEGORY_D'
        END
    CONNECT BY LEVEL <= 1000;

    COMMIT;
    </copy>
    ```

3. **UUID vs Sequential ID Comparison:**
   Let's compare UUID with traditional sequential IDs.

    ```
    <copy>
    -- Create comparison table with sequential ID
    DROP TABLE IF EXISTS sequential_id_test CASCADE CONSTRAINTS;

    CREATE TABLE sequential_id_test (
        id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
        uuid_id RAW(16) DEFAULT UUID(),
        data_value VARCHAR2(100),
        created_date DATE DEFAULT SYSDATE,
        category VARCHAR2(20)
    );

    -- Insert the same data structure
    INSERT INTO sequential_id_test (data_value, category)
    SELECT 
        'Sample Data ' || LEVEL,
        CASE 
            WHEN MOD(LEVEL, 4) = 0 THEN 'CATEGORY_A'
            WHEN MOD(LEVEL, 4) = 1 THEN 'CATEGORY_B'
            WHEN MOD(LEVEL, 4) = 2 THEN 'CATEGORY_C'
            ELSE 'CATEGORY_D'
        END
    CONNECT BY LEVEL <= 1000;

    COMMIT;
    </copy>
    ```

4. **Best Practices for UUID Usage:**
   Query both tables to understand storage and access patterns.

    ```
    <copy>
    -- Compare storage characteristics
    SELECT 
        'UUID Primary Key' as TABLE_TYPE,
        COUNT(*) as ROW_COUNT,
        AVG(LENGTH(RAWTOHEX(id))) as AVG_ID_LENGTH
    FROM large_uuid_test
    UNION ALL
    SELECT 
        'Sequential ID + UUID',
        COUNT(*),
        AVG(LENGTH(TO_CHAR(id)))
    FROM sequential_id_test;
    </copy>
    ```

## Task 6: Working with UUID in Applications

1. **Converting UUID for Application Use:**
   Applications often need UUIDs in different formats. Let's create utility queries for common conversions.

    ```
    <copy>
    -- UUID conversion utilities
    WITH uuid_examples AS (
        SELECT UUID() as raw_uuid
        CONNECT BY LEVEL <= 3
    )
    SELECT 
        -- Raw UUID (what's stored in database)
        raw_uuid as RAW_UUID,
        
        -- Hex string (32 characters)
        RAWTOHEX(raw_uuid) as HEX_STRING,
        
        -- Standard UUID format (with hyphens)
        REGEXP_REPLACE(RAWTOHEX(raw_uuid), 
                      '([0-9A-F]{8})([0-9A-F]{4})([0-9A-F]{4})([0-9A-F]{4})([0-9A-F]{12})', 
                      '\1-\2-\3-\4-\5') as STANDARD_FORMAT,
        
        -- Lowercase with hyphens (common in many systems)
        LOWER(REGEXP_REPLACE(RAWTOHEX(raw_uuid), 
                           '([0-9A-F]{8})([0-9A-F]{4})([0-9A-F]{4})([0-9A-F]{4})([0-9A-F]{12})', 
                           '\1-\2-\3-\4-\5')) as LOWERCASE_FORMAT
    FROM uuid_examples;
    </copy>
    ```

2. **UUID Validation:**
   Create a validation query to check if a UUID follows RFC 9562 version 4 variant 1 format.

    ```
    <copy>
    -- UUID validation function
    WITH test_uuids AS (
        SELECT UUID() as test_uuid
        UNION ALL
        SELECT UUID()
        UNION ALL 
        SELECT UUID()
    )
    SELECT 
        RAWTOHEX(test_uuid) as UUID_HEX,
        -- Check if it's version 4 (random)
        CASE 
            WHEN SUBSTR(RAWTOHEX(test_uuid), 13, 1) = '4' 
            THEN 'Version 4 ✓' 
            ELSE 'Not Version 4 ✗' 
        END as VERSION_CHECK,
        -- Check if it's variant 1 (RFC 4122/9562)
        CASE 
            WHEN SUBSTR(RAWTOHEX(test_uuid), 17, 1) IN ('8', '9', 'A', 'B') 
            THEN 'Variant 1 ✓' 
            ELSE 'Not Variant 1 ✗' 
        END as VARIANT_CHECK,
        -- Overall compliance
        CASE 
            WHEN SUBSTR(RAWTOHEX(test_uuid), 13, 1) = '4' 
                 AND SUBSTR(RAWTOHEX(test_uuid), 17, 1) IN ('8', '9', 'A', 'B')
            THEN 'RFC 9562 Compliant ✓'
            ELSE 'Non-Compliant ✗'
        END as RFC_COMPLIANCE
    FROM test_uuids;
    </copy>
    ```

## Task 7: Clean Up

1. Clean up the tables we created during this lab.

    ```
    <copy>
    DROP TABLE IF EXISTS user_sessions CASCADE CONSTRAINTS;
    DROP TABLE IF EXISTS transaction_log CASCADE CONSTRAINTS;
    DROP TABLE IF EXISTS large_uuid_test CASCADE CONSTRAINTS;
    DROP TABLE IF EXISTS sequential_id_test CASCADE CONSTRAINTS;
    </copy>
    ```

## Summary

In this lab, we explored the UUID() function in Oracle Database 23ai and its advantages over the traditional SYS_GUID() function. Key takeaways include:

- **RFC 9562 Compliance:** The UUID() function generates true RFC 9562-compliant version 4 variant 1 UUIDs
- **Unpredictability:** Unlike SYS_GUID(), UUID() produces truly random and unpredictable identifiers
- **Modern Standards:** UUID() meets modern security and uniqueness requirements for distributed systems
- **Practical Applications:** Perfect for primary keys, transaction IDs, correlation IDs, and session tracking
- **Format Flexibility:** Easy conversion between raw format and standard string representations

**When to Use UUID():**
- Primary keys in distributed systems
- Correlation IDs across microservices
- Session identifiers
- Transaction tracking
- Any scenario requiring unpredictable unique identifiers

**When to Consider Alternatives:**
- High-performance scenarios where sequential IDs are preferred
- Systems with strict storage requirements (UUID uses more space)
- Legacy applications that depend on predictable ordering

The UUID() function represents a significant improvement in Oracle Database 23ai's ability to generate secure, standards-compliant unique identifiers suitable for modern application architectures.

You may now **proceed to the next lab**

## Learn More

* [RFC 9562: Universally Unique IDentifiers](https://www.rfc-editor.org/rfc/rfc9562.html)
* [Oracle Database 23ai New Features](https://docs.oracle.com/en/database/oracle/oracle-database/23/nfcoa/index.html)

## Acknowledgements
* **Author** - Killian Lynch, Database Product Management
* **Last Updated By/Date** - Killian Lynch, August 2025