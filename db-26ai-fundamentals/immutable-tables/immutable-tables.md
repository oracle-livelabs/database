# Lab: Immutable Tables in Oracle AI Database 26ai

## Introduction

Audit logs have a credibility problem: anyone with enough privilege can rewrite them. An attacker an UPDATE away the evidence, and your "audit trail" proves nothing.

Immutable tables fix this at the database engine level. Once a row is inserted and committed, nobody can update or delete it. Not the table owner, not ADMIN, not anyone. Rows can only age out after a retention period you declare up front. And since release update 23.26.2, you can convert an existing regular table into an immutable one in place, with each existing row sealed at conversion time.

Why does it matter?
- Insert-only enforcement happens in the engine, below every user and privilege
- Retention rules are declared in the DDL and visible in the data dictionary
- Existing log tables can now be converted in place - no rebuild, no copy

In this lab, you'll create a tamper-proof audit trail, try (and fail) to tamper with it, and convert a regular table to immutable in place.

Estimated Lab Time: 10 minutes

### Objectives

In this lab you will:

- Create an immutable table with drop and delete retention rules
- Verify that UPDATE and DELETE are blocked for everyone, including the owner
- Convert an existing regular table into an immutable table in place (NEW in 23.26.2)
- Inspect immutable tables and row-sealing timestamps in the data dictionary

### Prerequisites

- Access to Oracle AI Database 26ai
- Basic understanding of SQL

## Task 1: Create a Tamper-Proof Audit Trail

1. Create an immutable table for security audit entries. The two retention clauses are required: NO DROP controls when the table itself may be dropped, and NO DELETE controls how long each row must survive (16 days is the minimum).

    ```sql
    <copy>
    DROP TABLE IF EXISTS app_audit CASCADE CONSTRAINTS;

    CREATE IMMUTABLE TABLE app_audit (
        entry_id NUMBER,
        username VARCHAR2(50),
        action   VARCHAR2(100),
        entry_ts TIMESTAMP DEFAULT SYSTIMESTAMP
    ) NO DROP UNTIL 0 DAYS IDLE
      NO DELETE UNTIL 16 DAYS AFTER INSERT;
    </copy>
    ```

    > **Note:** `NO DROP UNTIL 0 DAYS IDLE` keeps this lab easy to clean up - the table can be dropped as soon as it goes idle. A production audit table would use a larger value, or `NO DROP` with no qualifier to forbid dropping entirely.

2. Record some audit events. Inserts work exactly like any other table.

    ```sql
    <copy>
    INSERT INTO app_audit (entry_id, username, action) VALUES
        (1, 'ADMIN', 'Granted SELECT on payroll to JSMITH'),
        (2, 'JSMITH', 'Exported customer report'),
        (3, 'ADMIN', 'Changed password policy');

    COMMIT;
    </copy>
    ```

## Task 2: Try to Tamper With It

1. Imagine entry 2 is the one somebody wants to hide. Try to rewrite it.

    ```sql
    <copy>
    UPDATE app_audit SET action = 'Nothing suspicious here' WHERE entry_id = 2;
    </copy>
    ```

    **What you should see:**

    ```
    ORA-05715: operation not allowed on the blockchain or immutable table
    ```

2. Deleting the evidence fails the same way.

    ```sql
    <copy>
    DELETE FROM app_audit WHERE entry_id = 2;
    </copy>
    ```

    **What you should see:**
    - The same ORA-05715 error
    - You are the table owner running as ADMIN, and the engine still refuses - that's the point. TRUNCATE, ALTER, and rename are blocked the same way.

## Task 3: Convert an Existing Table In Place

Most teams already have log tables full of history. Until recently the only path to immutability was creating a new immutable table and copying the data over. Release update 23.26.2 adds in-place conversion.

1. Create an ordinary log table with some existing rows - this stands in for the table your application has been writing to for years.

    ```sql
    <copy>
    DROP TABLE IF EXISTS legacy_log CASCADE CONSTRAINTS;

    CREATE TABLE legacy_log (log_id NUMBER, message VARCHAR2(200));

    INSERT INTO legacy_log VALUES
        (1, 'System initialized'),
        (2, 'Nightly batch completed');

    COMMIT;
    </copy>
    ```

2. Convert it to an immutable table in place with the new BECOME IMMUTABLE clause.

    ```sql
    <copy>
    ALTER TABLE legacy_log BECOME IMMUTABLE
        NO DROP UNTIL 0 DAYS IDLE
        NO DELETE UNTIL 16 DAYS AFTER INSERT
        VERSION "v2";
    </copy>
    ```

    The existing rows stay exactly where they are - no copy, no outage - and the table is now insert-only.

3. Prove it: try to rewrite history.

    ```sql
    <copy>
    UPDATE legacy_log SET message = 'rewritten history' WHERE log_id = 1;
    </copy>
    ```

    **What you should see:**
    - ORA-05715 again - the converted table is just as locked down as one created immutable

4. Each row in a v2 immutable table carries a hidden, engine-managed creation timestamp. For converted tables, existing rows are sealed at conversion time.

    ```sql
    <copy>
    SELECT log_id, message, orabctab_creation_time$ AS sealed_at
    FROM legacy_log
    ORDER BY log_id;
    </copy>
    ```

    **What you should see:**
    - Both legacy rows share the same sealed\_at timestamp - the moment the ALTER TABLE ran

## Task 4: Inspect and Clean Up

1. Immutable tables and their retention rules are visible in the data dictionary.

    ```sql
    <copy>
    SELECT table_name, row_retention, table_inactivity_retention
    FROM user_immutable_tables
    ORDER BY table_name;
    </copy>
    ```

    **What you should see:**

    | TABLE_NAME | ROW_RETENTION | TABLE\_INACTIVITY\_RETENTION |
    | --- | --- | --- |
    | APP\_AUDIT | 16 | 0 |
    | LEGACY\_LOG | 16 | 0 |

2. Clean up. The drop succeeds only because we set the idle retention to 0 days. With a real retention period, even DROP would refuse.

    ```sql
    <copy>
    DROP TABLE app_audit;
    DROP TABLE legacy_log;
    </copy>
    ```

    Rows that pass their retention period don't vanish on their own. The `DBMS_IMMUTABLE_TABLE.DELETE_EXPIRED_ROWS` procedure removes them when you're ready. If you need cryptographic row chaining and signed verification on top of immutability, the same concepts extend to blockchain tables.

## Learn More

- [PL/SQL Packages and Types Reference](https://docs.oracle.com/en/database/oracle/oracle-database/26/arpls/dbms_immutable_table.html#GUID-B5F2598C-1990-4A7C-9466-A6EA5AD87AC0)
- [Database Administrator’s Guide](https://docs.oracle.com/en/database/oracle/oracle-database/26/admin/managing-tables.html#GUID-2CEEE181-1171-4C18-8604-2F26FC8EC7EA)

## Acknowledgements

- **Author** - Killian Lynch, Oracle AI Database Product Manager
- **Last Updated By/Date** - Killian Lynch, June 2026
