# Lab 1: Explore Oracle Autonomous Database

## Introduction

Before you create anything, take a quick look at the database you are using. Autonomous Database handles patching, backups, and routine tuning. You will focus on your schema, SQL, and data.

### Objectives

You will:

- Identify your current user, schema, service, and container.
- Distinguish the database from the objects in your schema.
- Use data dictionary views to inspect your environment.
- Confirm whether workshop objects already exist.

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

3. Read the result. Your user and schema will normally have the same name. `SERVICE_NAME` shows the service used by the worksheet. `CONTAINER_NAME` shows the pluggable database that contains your schema.

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
    ORDER  BY object_type, object_name;
    </copy>
    ```

4. If the last query returns rows, your instructor may have prepared the schema already. Ask whether you are using demo-ready mode. Do not remove the objects unless your instructor asks you to reset the workshop schema.

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

* **Author** - Oracle University Program
* **Last Updated By/Date** - Oracle University Program, October 2026
