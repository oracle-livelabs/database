# Lab: UUID Generation in Oracle AI Database 26ai

## Introduction

When you build apps, you need unique IDs for sessions, API tokens, user data, and database records. Sequential IDs (1, 2, 3...) are predictable - if someone gets session ID 100, they can guess that sessions 99 and 101 exist. The older SYS_GUID() function looks random but has predictable patterns because it combines your server's hostname, process ID, and a counter.

Oracle AI Database 26ai's UUID() function generates truly random identifiers with 122 bits of randomness. There's no pattern to exploit and no way to guess other values.

In this lab, you'll generate secure UUIDs, build a session management table, and see how UUID() compares to SYS_GUID().

Estimated Lab Time: 10 minutes

### Objectives

- Generate random UUIDs using the UUID() function
- Convert between RAW and string UUID formats
- Create tables with UUID primary keys for session management
- Compare UUID() with SYS_GUID() to understand the security improvements

### Prerequisites

- Access to Oracle AI Database 26ai
- Basic understanding of SQL and primary keys

## Task 1: Generate UUIDs and Convert Formats

A UUID (Universally Unique Identifier) is a 128-bit random value. The UUID() function generates RFC 9562-compliant version 4 UUIDs with 122 bits of randomness - that's 5.3 undecillion possible values. You could create UUIDs every second for 100 years and never create a duplicate.

1. Generate UUIDs and convert between RAW and string formats.

    ```sql
    <copy>
    -- Generate a UUID in RAW format (used for database storage)
    SELECT UUID() AS raw_format;

    -- Convert the same UUID to both RAW and string formats
    WITH generated_uuid AS (
        SELECT UUID() AS uuid_value
    )
    SELECT
        uuid_value AS raw_format,
        RAW_TO_UUID(uuid_value) AS string_format
    FROM generated_uuid;

    -- Convert a string UUID back to RAW format for database storage
    SELECT UUID_TO_RAW('48a8b091-2587-4fd4-bf04-877d259793de') AS raw_format;
    </copy>
    ```

    **What you should see:**
    - UUID() returns RAW(16) - 16 bytes that are efficient for database storage
    - RAW\_TO\_UUID() converts to string format: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` (36 characters)
    - String format is best for REST APIs and displaying to users
    - UUID\_TO\_RAW() converts strings back to RAW format (accepts various formats with/without hyphens)


    ![create tables](images/uuid.png =40%x*)


## Task 2: Build a Session Management System

User sessions are targets for attackers. If session IDs are predictable (like sequential numbers), attackers can hijack sessions by guessing valid IDs. With UUID-based session IDs, this attack would be virtually impossible.

1. Create a session table and insert sessions with UUID identifiers. Be sure to run each statement, or click the 'Run Script' button on SQL Developer Web

    ```sql
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

    -- Insert sessions using UUID() for secure session identifiers
    INSERT INTO user_sessions (session_id, user_id, ip_address, user_agent)
    VALUES (UUID(), 1001, '192.168.1.100', 'Mozilla/5.0 Chrome/120.0'),
           (UUID(), 1002, '10.0.0.50', 'Mozilla/5.0 Firefox/121.0'),
           (UUID(), 1001, '192.168.1.105', 'Mozilla/5.0 Safari/17.0 Mobile');
    </copy>
    ```

    **What you should see:**
    - Table created with session_id as RAW(16) PRIMARY KEY
    - UUID() is called directly in INSERT statements
    - Each UUID is completely unique and unpredictable
    - User 1001 has two sessions (desktop and mobile)

2. View the sessions and their unique identifiers.

    ```sql
    <copy>
    SELECT
        RAW_TO_UUID(session_id) AS session_id,
        user_id,
        session_start,
        ip_address
    FROM user_sessions
    ORDER BY session_start;
    </copy>
    ```

    **What you should see:**
    - Three sessions with completely unique session IDs
    - Each UUID is unpredictable - no patterns to exploit
    - User 1001 has two sessions (desktop and mobile)

## Task 3: Return UUIDs to Your App

When building REST APIs or web apps, you need to return the generated UUID back to your application code. Use the RETURNING clause to capture the UUID immediately after insertion.

1. Insert a session and return the UUID to your application.

    ```sql
    <copy>
    DECLARE
        v_session_id RAW(16);
    BEGIN
        -- Insert and capture the UUID in one operation
        INSERT INTO user_sessions (session_id, user_id, ip_address, user_agent)
        VALUES (UUID(), 1004, '203.0.113.45', 'Mozilla/5.0 Chrome/120.0')
        RETURNING session_id INTO v_session_id;

        -- Return the UUID to the application (as hexadecimal)
        DBMS_OUTPUT.PUT_LINE('Session Token: ' || RAWTOHEX(v_session_id));

        COMMIT;
    END;
    /
    </copy>
    ```

    **What you should see:**
    - Session inserted and UUID captured in one step
    - UUID returned as hexadecimal for your application to use


## Task 4: Compare SYS_GUID() and UUID()

Before Oracle AI Database 26ai, you might have used SYS\_GUID() for unique IDs. But SYS\_GUID() has predictable patterns because it combines your server's hostname, process ID, and a counter. UUID() is truly random with 122 bits of randomness.

1. Compare SYS\_GUID() and UUID() side by side.

    ```sql
    <copy>
    DROP TABLE IF EXISTS id_comparison CASCADE CONSTRAINTS;

    CREATE TABLE id_comparison (
        sys_guid_id RAW(16) NOT NULL,
        uuid_id RAW(16) NOT NULL
    );

    -- Insert test data with both functions
    INSERT INTO id_comparison (sys_guid_id, uuid_id)
    VALUES (SYS_GUID(), UUID()),
           (SYS_GUID(), UUID()),
           (SYS_GUID(), UUID()),
           (SYS_GUID(), UUID()),
           (SYS_GUID(), UUID());

    -- Compare the patterns
    SELECT
        RAWTOHEX(sys_guid_id) AS sys_guid_hex,
        RAWTOHEX(uuid_id) AS uuid_hex
    FROM id_comparison;
    </copy>
    ```

    **What you should see:**
    - SYS\_GUID() values share a common prefix - the first 20+ characters are often identical
    - Only the last few characters of SYS\_GUID() change between values
    - UUID() values are completely different with no predictable pattern
    - If an attacker gets one SYS\_GUID(), they can predict nearby values
    - UUID() gives attackers no information about other identifiers



**You've learned how to use UUID() to generate unique identifiers:**
- Generated UUIDs and converted between RAW(16) storage and string formats
- Built a session management table with UUID primary keys
- Used the RETURNING clause to capture UUIDs for your application
- Compared UUID() with SYS_GUID() to see the security improvements

The UUID() function generates RFC 9562-compliant version 4 UUIDs with 122 bits of randomness. Use UUIDs for session tokens, API keys, and any identifiers exposed to users where unpredictability is critical.

## Learn More

- [Oracle Database SQL Language Reference - UUID Function](https://docs.oracle.com/en/database/oracle/oracle-database/26/sqlrf/uuid.html#SQLRF-GUID-2A0ECCC2-3DA1-442F-AC9D-A6FE643F381D)
- [RFC 9562 - Universally Unique IDentifiers (UUIDs)](https://www.rfc-editor.org/rfc/rfc9562.html)
- [Oracle Database Security Guide](https://docs.oracle.com/en/database/oracle/oracle-database/26/dbseg/)

## Acknowledgements

- **Author** - Killian Lynch, Oracle AI Database Product Manager
- **Last Updated By/Date** - Killian Lynch, November 2025
