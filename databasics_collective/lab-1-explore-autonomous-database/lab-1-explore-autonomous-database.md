# Lab 1: Explore Oracle Autonomous Database

## Introduction

Your reservation already has the university tables and sample rows. Start by checking your connection and finding them in your schema. Autonomous Database handles patching, backups, and routine tuning.

### Objectives

You will:

- Identify your current user, schema, service, and container.
- Distinguish the database from the objects in your schema.
- Use data dictionary views to inspect your environment.
- Confirm that the four core tables are ready.

Estimated Time: 10 minutes

## Task 1: Identify your database session

1. Sign in to Database Actions with your workshop user and open the SQL Worksheet.

2. Run this query.

    ```sql
    <copy>
    SELECT SYS_CONTEXT('USERENV', 'CURRENT_USER') AS current_user,
           SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') AS current_schema,
           SYS_CONTEXT('USERENV', 'SERVICE_NAME') AS service_name,
           SYS_CONTEXT('USERENV', 'CON_NAME') AS container_name
    FROM   dual;
    </copy>
    ```

3. Read the result. Your user and schema should both be `DATABASICS`. `SERVICE_NAME` shows the service used by the worksheet. `CONTAINER_NAME` shows the pluggable database that contains your schema.

## Task 2: Inspect the database version

1. Run the following query.

    ```sql
    <copy>
    SELECT banner_full
    FROM   v$version
    WHERE  banner_full LIKE 'Oracle Database%';
    </copy>
    ```

2. Write down the database version. Some newer features depend on the version, but this workshop stays with common Oracle Database features.

## Task 3: Inspect your schema

1. List the tables that your user owns.

    ```sql
    <copy>
    SELECT table_name
    FROM   user_tables
    WHERE  table_name IN ('DEPARTMENTS', 'STUDENTS', 'COURSES', 'ENROLLMENTS')
    ORDER  BY table_name;
    </copy>
    ```

2. Count your objects by type.

    ```sql
    <copy>
    SELECT object_type, COUNT(*) AS object_count
    FROM   user_objects
    GROUP  BY object_type
    ORDER  BY object_type;
    </copy>
    ```

3. Check for objects from an earlier workshop run.

    ```sql
    <copy>
    SELECT object_type, object_name, status
    FROM   user_objects
    WHERE  object_name LIKE 'DBC\_%' ESCAPE '\'
       OR  object_name IN ('DEPARTMENTS', 'STUDENTS', 'COURSES', 'ENROLLMENTS')
    ORDER  BY object_type, object_name;
    </copy>
    ```

4. You should find the four core tables. Database Actions may also create a `DBTOOLS$EXECUTION_HISTORY` table for its own use. If a core table is missing, the reservation setup has not finished.

## Task 4: Connect the concepts

1. Review how the main layers fit together.

    | Layer | Meaning |
    | --- | --- |
    | Database | Managed data and recovery information |
    | Instance | Memory and processes that access the database |
    | CDB and PDB | A CDB hosts PDBs; your schema is inside a PDB |
    | Schema | Objects owned by one user |
    | Autonomous Database | Oracle manages the service; you manage schemas and SQL |

2. Oracle Database can run on-premises, on Exadata, through Cloud@Customer, or in the cloud. We use Autonomous Database here so you can stay focused on SQL.

3. Oracle also supports JSON, spatial, graph, and vector data. We will start with relational tables.

4. Move on when you can identify your schema, explain `USER_TABLES`, and describe what Autonomous Database manages.

## Acknowledgements

* **Author** - Ilan Gómez Guerrero
* **Last Updated By/Date** - Ilan Gómez Guerrero, November 2026
