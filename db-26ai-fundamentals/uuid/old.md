# Lab: UUID Generation in Oracle AI Database 26ai

## Introduction

When you build web applications, you need unique IDs for sessions, API tokens, and user data. Traditional approaches have problems. Sequential IDs (1, 2, 3...) are predictable. If someone gets session ID 100, they know sessions 99 and 101 probably exist. They can try to access other users' data just by changing the number in the URL. The older SYS_GUID() function looks random, but it combines your server's hostname, process ID, and a counter. If you generate multiple values quickly, you'll see patterns. Attackers can use these patterns to predict other values.

Oracle AI Database 26ai has a UUID() function that generates truly random identifiers. Each value has 122 bits of randomness - meaning there's no pattern to exploit and no way to guess other values.

In this lab, you'll see the difference between these approaches. You'll build a session management system with UUID identifiers, and you'll learn when to use UUIDs versus sequential IDs in production applications.

Estimated Lab Time: 20 minutes

### Objective

- Understand why sequential IDs and SYS_GUID() can be insecure
- Generate random UUIDs using the UUID() function
- Convert between RAW and string UUID formats
- Create tables with UUID primary keys
- Use UUIDs for session management and API tokens
- Learn when to use UUIDs versus sequential IDs

### Prerequisites

- Access to Oracle AI Database 26ai
- Basic understanding of SQL and primary keys
- Familiarity with INSERT statements

## Understanding UUIDs

A UUID (Universally Unique Identifier) is a 128-bit random value used to identify things uniquely. Think of it like a fingerprint - no two are the same.

The UUID() function generates values that follow the RFC 9562 standard for version 4 UUIDs. This means each UUID has 122 bits of randomness (6 bits are used for version and variant identifiers). That's 5,300,000,000,000,000,000,000,000,000,000,000,000 possible values (5.3 undecillion).

In practical terms: you could generate UUIDs every second for 100 years and never come close to creating a duplicate.

## Task 1: Compare SYS_GUID() and UUID()

Before you build production tables, let's see why UUID() is better than the older SYS_GUID() function.

SYS_GUID() looks random, but it's not fully random. It combines your server's hostname, process ID, and a counter. If you generate multiple values quickly, you'll see patterns - often the first 20-24 characters stay the same and only the last few characters change.

UUID() is different. It generates fully random values, so there are no patterns to exploit.

1. Generate multiple identifiers with each function to see the difference.

    ```sql
    <copy>
    -- Generate 5 identifiers using SYS_GUID()
    SELECT 'SYS_GUID' AS function_type, SYS_GUID() AS generated_value FROM DUAL
    UNION ALL
    SELECT 'SYS_GUID', SYS_GUID() FROM DUAL
    UNION ALL
    SELECT 'SYS_GUID', SYS_GUID() FROM DUAL
    UNION ALL
    SELECT 'SYS_GUID', SYS_GUID() FROM DUAL
    UNION ALL
    SELECT 'SYS_GUID', SYS_GUID() FROM DUAL
    UNION ALL
    -- Generate 5 identifiers using UUID()
    SELECT 'UUID', UUID() FROM DUAL
    UNION ALL
    SELECT 'UUID', UUID() FROM DUAL
    UNION ALL
    SELECT 'UUID', UUID() FROM DUAL
    UNION ALL
    SELECT 'UUID', UUID() FROM DUAL
    UNION ALL
    SELECT 'UUID', UUID() FROM DUAL;
    </copy>
    ```

    **What you should see:**
    - SYS_GUID() values have identical prefixes - the first 20-24 characters are often the same
    - Only the last few characters of SYS_GUID() values change
    - UUID() values are completely different each time - no predictable patterns
    - If an attacker gets one SYS_GUID() value, they can predict nearby values
    - UUID() values give attackers no information about other values

2. Check the data type and size of each function.

    ```sql
    <copy>
    -- See the data type and length
    SELECT
        'SYS_GUID' AS function_name,
        DUMP(SYS_GUID()) AS data_type_info,
        LENGTH(SYS_GUID()) AS byte_length
    FROM DUAL
    UNION ALL
    SELECT
        'UUID',
        DUMP(UUID()),
        LENGTH(UUID())
    FROM DUAL;
    </copy>
    ```

    **What you should see:**
    - Both functions return RAW(16) - that's 16 bytes or 128 bits
    - Even though they're the same size, the internal structure is completely different
    - SYS_GUID() contains predictable components (host ID, process ID, counter)
    - UUID() contains 122 bits of randomness (version 4 variant 1 per RFC 9562)

3. Convert UUIDs between RAW and string formats.

    Oracle provides two utility functions to convert UUIDs between storage format (RAW) and human-readable format (string with hyphens).

    ```sql
    <copy>
    -- Generate a UUID and convert it to string format
    SELECT
        UUID() AS raw_format,
        RAW_TO_UUID(UUID()) AS string_format
    FROM DUAL;

    -- Convert a string UUID back to RAW format
    SELECT
        UUID_TO_RAW('48a8b091-2587-4fd4-bf04-877d259793de') AS raw_format,
        LENGTH(UUID_TO_RAW('48a8b091-2587-4fd4-bf04-877d259793de')) AS byte_length
    FROM DUAL;

    -- UUID_TO_RAW accepts various formats (mixed case, with/without hyphens)
    SELECT
        UUID_TO_RAW('48A8B091-2587-4FD4-BF04-877D259793DE') AS uppercase_with_hyphens,
        UUID_TO_RAW('48a8b09125874fd4bf04877d259793de') AS lowercase_no_hyphens,
        UUID_TO_RAW('48A8B09125874FD4BF04877D259793DE') AS uppercase_no_hyphens
    FROM DUAL;
    </copy>
    ```

    **What you should see:**
    - RAW_TO_UUID() converts RAW(16) to the standard format: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`
    - The string format is 36 characters (32 hex digits + 4 hyphens)
    - UUID_TO_RAW() accepts strings with or without hyphens
    - UUID_TO_RAW() accepts mixed case input
    - Both functions help when integrating with REST APIs that expect string UUIDs
    - The RAW(16) format is best for database storage (saves space)
    - The string format is best for application APIs and display to users

## Task 2: Create a Session Management Table

User sessions are prime targets for attackers. If session IDs are predictable, attackers can hijack legitimate user sessions by guessing valid session identifiers.

Imagine you're building a web application. Each time someone logs in, you create a new session with a unique ID. If that ID is sequential (100, 101, 102), an attacker with session 101 knows sessions 100 and 102 exist. They can try to use those session IDs to access other users' accounts.

With UUID-based session IDs, this attack is impossible. Even if an attacker gets a valid UUID, they can't predict any other valid UUIDs.

1. Create a user sessions table with UUID primary keys.

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
    </copy>
    ```

    **What you should see:**
    - The table is created successfully
    - session_id is RAW(16) - this is the data type for storing UUIDs
    - The PRIMARY KEY constraint ensures each session has a unique identifier
    - session_start automatically records when the session was created
    - ip_address and user_agent capture audit information for security monitoring

2. Verify the table structure.

    ```sql
    <copy>
    -- View the table definition
    SELECT
        column_name,
        data_type,
        data_length,
        nullable,
        data_default
    FROM user_tab_columns
    WHERE table_name = 'USER_SESSIONS'
    ORDER BY column_id;
    </copy>
    ```

    **What you should see:**
    - session_id is RAW(16) and not nullable
    - session_start has a DEFAULT of CURRENT_TIMESTAMP
    - status has a DEFAULT of 'ACTIVE'
    - This table is ready for production use

## Task 3: Generate Sessions with UUIDs

The UUID() function can be called directly in INSERT statements. Each time you call it, you get a completely unique, random value.

1. Insert multiple user sessions with different devices and browsers.

    ```sql
    <copy>
    -- Create session for user 1001 (desktop Chrome browser)
    INSERT INTO user_sessions (session_id, user_id, ip_address, user_agent, status)
    VALUES (UUID(), 1001, '192.168.1.100', 'Mozilla/5.0 Chrome/120.0', 'ACTIVE');

    -- Create session for user 1002 (desktop Firefox browser)
    INSERT INTO user_sessions (session_id, user_id, ip_address, user_agent, status)
    VALUES (UUID(), 1002, '10.0.0.50', 'Mozilla/5.0 Firefox/121.0', 'ACTIVE');

    -- Create session for user 1001 (mobile Safari browser - same user, different device)
    INSERT INTO user_sessions (session_id, user_id, ip_address, user_agent, status)
    VALUES (UUID(), 1001, '192.168.1.105', 'Mozilla/5.0 Safari/17.0 Mobile', 'ACTIVE');

    -- Create an expired session for user 1003
    INSERT INTO user_sessions (session_id, user_id, ip_address, user_agent, status)
    VALUES (UUID(), 1003, '172.16.0.23', 'Mozilla/5.0 Edge/120.0', 'EXPIRED');
    </copy>
    ```

    **What you should see:**
    - 4 rows inserted successfully
    - Each UUID() call creates a unique identifier
    - User 1001 has two active sessions (desktop and mobile)
    - Each session captures IP address and browser information
    - Sessions can have different statuses (ACTIVE, EXPIRED)

2. View all sessions and their unique identifiers.

    ```sql
    <copy>
    SELECT
        session_id,
        user_id,
        session_start,
        ip_address,
        status
    FROM user_sessions
    ORDER BY session_start;
    </copy>
    ```

    **What you should see:**
    - 4 sessions displayed with completely unique session_id values
    - Each session_id is a 16-byte RAW value shown in hexadecimal
    - User 1001 appears twice (desktop and mobile devices)
    - No two session IDs share any predictable pattern
    - Sessions are ordered by creation time

## Task 4: See How Unique UUIDs Are

You might wonder: if everyone's generating random UUIDs, will two systems ever create the same one? Let's calculate the probability.

With 122 bits of randomness, UUID() can generate 2^122 unique values. That's over 5 undecillion possible values.

1. Calculate how unlikely UUID collisions are.

    ```sql
    <copy>
    -- See how many unique UUIDs are possible
    SELECT
        'Total possible UUIDs' AS metric,
        TO_CHAR(POWER(2, 122), '9.99EEEE') AS value,
        'About 5.3 undecillion unique values' AS description
    FROM DUAL
    UNION ALL
    SELECT
        'UUIDs needed for 50% collision chance',
        TO_CHAR(POWER(2, 61), '9.99EEEE'),
        'About 2.3 quintillion'
    FROM DUAL
    UNION ALL
    SELECT
        'UUIDs per second for 100 years',
        TO_CHAR((100 * 365.25 * 24 * 60 * 60), '9.99EEEE'),
        'Only 3.15 billion'
    FROM DUAL;
    </copy>
    ```

    **What you should see:**
    - 2^122 possible UUIDs (5.3 followed by 36 zeros)
    - You would need to generate 2.3 quintillion UUIDs to have a 50% chance of creating a duplicate
    - Generating one UUID per second for 100 years only produces 3.15 billion UUIDs
    - 3.15 billion is nowhere near 2.3 quintillion
    - In practical terms: UUID collisions are impossible in production systems

## Task 5: Use UUIDs in Production Patterns

Most applications need to return the generated UUID to the application code after insertion. You can use the RETURNING clause for this.

This pattern is used in REST APIs, microservices, and web applications. The application sends data, the database generates a UUID, and the UUID is returned to the application.

**Important PL/SQL Note**: Direct variable assignment (`v_uuid := UUID()`) does not work in PL/SQL. You must use `SELECT UUID() INTO v_uuid FROM DUAL` or the RETURNING clause in DML statements.

1. Insert a session and capture the generated UUID.

    ```sql
    <copy>
    -- Insert a session and return the UUID
    DECLARE
        v_session_id RAW(16);
        v_user_id NUMBER := 1004;
    BEGIN
        INSERT INTO user_sessions (session_id, user_id, ip_address, user_agent, status)
        VALUES (UUID(), v_user_id, '203.0.113.45', 'Mozilla/5.0 Chrome/120.0', 'ACTIVE')
        RETURNING session_id INTO v_session_id;

        -- Display the generated UUID
        DBMS_OUTPUT.PUT_LINE('Generated Session ID: ' || RAWTOHEX(v_session_id));
        DBMS_OUTPUT.PUT_LINE('Length in bytes: ' || LENGTH(v_session_id));

        COMMIT;
    END;
    /
    </copy>
    ```

    **What you should see:**
    - The session is inserted successfully
    - The generated UUID is displayed in hexadecimal format
    - The length is 16 bytes (128 bits)
    - The RETURNING clause captured the UUID immediately after insertion
    - Your application code would use this UUID as the session token

2. Alternative pattern: Generate UUID using SELECT INTO.

    If you need to generate a UUID before using it in multiple places, use SELECT INTO.

    ```sql
    <copy>
    -- Generate UUID first, then use it
    DECLARE
        v_session_id RAW(16);
        v_user_id NUMBER := 1005;
    BEGIN
        -- Generate the UUID using SELECT INTO (this works)
        SELECT UUID() INTO v_session_id FROM DUAL;

        -- Now you can use the same UUID in multiple places
        INSERT INTO user_sessions (session_id, user_id, ip_address, user_agent, status)
        VALUES (v_session_id, v_user_id, '198.51.100.42', 'Mozilla/5.0 Safari/17.0', 'ACTIVE');

        -- Display it to the application
        DBMS_OUTPUT.PUT_LINE('Session ID (hex): ' || RAWTOHEX(v_session_id));
        DBMS_OUTPUT.PUT_LINE('Session ID (string): ' || RAW_TO_UUID(v_session_id));

        COMMIT;
    END;
    /
    </copy>
    ```

    **What you should see:**
    - The UUID is generated once and stored in v_session_id
    - The same UUID can be used in INSERT and for logging/display
    - RAW_TO_UUID() formats it as a standard hyphenated string
    - This pattern is useful when you need the UUID before the INSERT

3. Find all active sessions for a specific user.

    ```sql
    <copy>
    -- Find all active sessions for user 1001
    SELECT
        RAWTOHEX(session_id) AS session_id_hex,
        session_start,
        ip_address,
        user_agent,
        status,
        ROUND((SYSDATE - session_start) * 24 * 60, 2) AS minutes_active
    FROM user_sessions
    WHERE user_id = 1001
      AND status = 'ACTIVE'
    ORDER BY session_start DESC;
    </copy>
    ```

    **What you should see:**
    - Two active sessions for user 1001 (desktop and mobile)
    - Each session shows its unique hexadecimal session ID
    - Session start time for each device
    - Device information from IP address and user agent
    - How many minutes each session has been active
    - The most recent session appears first

## Task 6: Compare UUIDs with Sequential IDs

Understanding the security trade-offs between sequential IDs and UUIDs helps you make informed decisions about when to use each approach.

Sequential IDs are simple and efficient for internal use. But they're dangerous when exposed to users because they're predictable.

1. Create a table that uses both approaches.

    ```sql
    <copy>
    DROP TABLE IF EXISTS session_comparison CASCADE CONSTRAINTS;

    CREATE TABLE session_comparison (
        sequential_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
        uuid_id RAW(16) DEFAULT UUID() NOT NULL UNIQUE,
        user_id NUMBER NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

    -- Insert test data
    INSERT INTO session_comparison (user_id) VALUES (1001);
    INSERT INTO session_comparison (user_id) VALUES (1002);
    INSERT INTO session_comparison (user_id) VALUES (1003);
    INSERT INTO session_comparison (user_id) VALUES (1004);
    INSERT INTO session_comparison (user_id) VALUES (1005);
    </copy>
    ```

    **What you should see:**
    - Table created with both sequential_id and uuid_id columns
    - 5 rows inserted successfully
    - The sequential_id is generated automatically (1, 2, 3, 4, 5)
    - The uuid_id is also generated automatically using UUID()

2. Examine the difference in identifier patterns.

    ```sql
    <copy>
    SELECT
        sequential_id,
        RAWTOHEX(uuid_id) AS uuid_id_hex,
        user_id,
        created_at
    FROM session_comparison
    ORDER BY sequential_id;
    </copy>
    ```

    **What you should see:**
    - Sequential IDs: 1, 2, 3, 4, 5 (perfectly predictable)
    - UUID IDs: Each completely random with no pattern
    - If an attacker obtains session ID 3, they know sessions 1, 2, 4, and 5 likely exist
    - Sequential IDs also reveal business metrics (5 sessions created)
    - UUIDs reveal nothing about other sessions or business volume

3. See how attackers can exploit sequential IDs.

    ```sql
    <copy>
    -- Attacker obtains one valid sequential ID
    SELECT 'Obtained ID: ' || sequential_id AS attacker_knowledge,
           'Can guess nearby IDs: ' || (sequential_id - 2) || ', ' ||
           (sequential_id - 1) || ', ' || (sequential_id + 1) || ', ' ||
           (sequential_id + 2) AS attack_vector
    FROM session_comparison
    WHERE sequential_id = 3;

    -- With UUID, this attack is impossible
    SELECT 'Obtained UUID: ' || SUBSTR(RAWTOHEX(uuid_id), 1, 16) || '...' AS attacker_knowledge,
           'Cannot guess other UUIDs (2^122 possibilities)' AS attack_vector
    FROM session_comparison
    WHERE sequential_id = 3;
    </copy>
    ```

    **What you should see:**
    - With sequential ID 3, an attacker can easily guess IDs 1, 2, 4, and 5
    - With a UUID, knowing one value provides zero information about others
    - The attack vector against sequential IDs is trivial
    - The attack vector against UUIDs is impossible
    - This shows why UUIDs are necessary for any public-facing identifiers

4. Create a hybrid approach that balances security and performance.

    Many production systems use both approaches: UUIDs for external security and sequential IDs for internal efficiency.

    ```sql
    <copy>
    DROP TABLE IF EXISTS api_tokens CASCADE CONSTRAINTS;

    CREATE TABLE api_tokens (
        token_id RAW(16) PRIMARY KEY,
        internal_id NUMBER GENERATED ALWAYS AS IDENTITY,
        user_id NUMBER NOT NULL,
        token_name VARCHAR2(100),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        expires_at TIMESTAMP,
        last_used TIMESTAMP,
        status VARCHAR2(20) DEFAULT 'ACTIVE'
    );

    -- Create index on the sequential ID for range queries
    CREATE INDEX idx_api_tokens_internal ON api_tokens(internal_id);

    -- Create index on user_id for common queries
    CREATE INDEX idx_api_tokens_user ON api_tokens(user_id, status);
    </copy>
    ```

    **What you should see:**
    - Table created with both token_id (UUID) and internal_id (sequential)
    - token_id is the PRIMARY KEY (exposed to API clients)
    - internal_id is used for internal database queries
    - Indexes created for efficient querying
    - This gives you security where needed and performance where it matters

5. Insert sample API tokens and query efficiently.

    ```sql
    <copy>
    -- Insert API tokens for different users
    INSERT INTO api_tokens (token_id, user_id, token_name, expires_at)
    VALUES (UUID(), 1001, 'Production API Key', CURRENT_TIMESTAMP + INTERVAL '90' DAY);

    INSERT INTO api_tokens (token_id, user_id, token_name, expires_at)
    VALUES (UUID(), 1001, 'Development API Key', CURRENT_TIMESTAMP + INTERVAL '30' DAY);

    INSERT INTO api_tokens (token_id, user_id, token_name, expires_at)
    VALUES (UUID(), 1002, 'Mobile App Token', CURRENT_TIMESTAMP + INTERVAL '365' DAY);

    -- Query by internal ID (efficient range scan)
    SELECT internal_id, RAWTOHEX(token_id) AS token, token_name
    FROM api_tokens
    WHERE internal_id BETWEEN 1 AND 100
    ORDER BY internal_id;

    -- Query by user (using indexed column)
    SELECT RAWTOHEX(token_id) AS token, token_name, expires_at, status
    FROM api_tokens
    WHERE user_id = 1001 AND status = 'ACTIVE';
    </copy>
    ```

    **What you should see:**
    - 3 API tokens inserted successfully
    - User 1001 has two tokens (production and development)
    - Range query using internal_id is efficient
    - User query using indexed columns is fast
    - External systems use token_id for API authentication
    - Internal queries use internal_id and indexes for performance
    - No performance penalty from using UUIDs

## Task 7: Best Practices for Using UUIDs

Not every table needs UUID primary keys. Understanding when to use UUIDs versus sequential IDs helps you make informed decisions.

### When to Use UUIDs

Use UUID() when:
- Identifiers are exposed to users (session tokens, API keys, public URLs)
- Security and unpredictability are critical
- You want to prevent attackers from enumerating resources
- You need to prevent business intelligence leaks
- Distributed systems need globally unique IDs without coordination
- Merging data from multiple sources

### When to Use Sequential IDs

Use sequential IDs when:
- Identifiers are purely internal (never exposed outside the database)
- Query performance on range scans is critical
- Storage efficiency is a primary concern
- Natural ordering by creation time is desired
- The data is not security-sensitive

### Common Patterns

**Session Management**: Always use UUIDs. Session hijacking is a common attack.

**API Tokens**: Always use UUIDs. Predictable tokens are a security vulnerability.

**User IDs**: Depends on your application. If user IDs appear in URLs (`/users/123`), use UUIDs. If they're purely internal, sequential IDs are fine.

**Order Numbers**: Often use UUIDs to prevent competitors from seeing order volume.

**Internal Audit Tables**: Sequential IDs are usually fine since they're never exposed.

**Distributed Systems**: UUIDs are ideal because each node can generate IDs independently without coordination.

## Summary

You've learned how to generate secure unique identifiers with UUID(). Here's what you did:

- Compared SYS_GUID() and UUID() to see the difference between predictable and random identifiers
- Converted UUIDs between RAW(16) storage format and string display format
- Created a session management table with UUID primary keys
- Generated unique session identifiers using UUID() in INSERT statements
- Calculated UUID collision probability and saw that collisions are effectively impossible
- Used the RETURNING clause and SELECT INTO to capture generated UUIDs for application use
- Compared UUID security with sequential IDs to understand vulnerability differences
- Implemented a hybrid approach that balances security and performance

The UUID() function generates RFC 9562-compliant version 4 UUIDs with 122 bits of randomness. This eliminates predictability vulnerabilities, prevents business intelligence leaks, and enables secure distributed systems.

## Learn More

- [Oracle Database SQL Language Reference - UUID Function](https://docs.oracle.com/en/database/oracle/oracle-database/26/sqlrf/UUID.html)
- [RFC 9562 - Universally Unique IDentifiers (UUIDs)](https://www.rfc-editor.org/rfc/rfc9562.html)
- [Oracle Database Security Guide](https://docs.oracle.com/en/database/oracle/oracle-database/26/dbseg/)

## Acknowledgements

- **Author** - Killian Lynch, Oracle AI Database Product Manager
- **Last Updated By/Date** - Killian Lynch, November 2025
