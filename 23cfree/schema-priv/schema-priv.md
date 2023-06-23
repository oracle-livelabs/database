# Schema Privilege Management

## Introduction

Welcome to Lab 2: Schema Privilege Management!

In this lab, we will explore the management of schema privileges in Oracle. By granting select, insert, update, and delete privileges on specific tables to users, we can control their access within a schema. We will also examine the functionality of schema privileges versus select grants.

Join us as we dive into Schema Privilege Management, log in as different users, query tables, and observe the impact of schema privileges on access. We will create a third table to demonstrate the limitations faced by a user without schema privileges. Through this lab, you will gain a deeper understanding of schema privilege management and its implications in Oracle databases.

Estimated Time: 10 minutes

### Objectives

* Understand schema privilege management in Oracle.
* Learn to grant select, insert, update, and delete privileges on specific tables.
* Compare schema privileges with select grants and their limitations.
* Observe the impact of schema privileges on user table access.
* Compare user access capabilities with and without schema privileges.
* Verify user access by logging in as different users and querying tables.
* Demonstrate user access restrictions to a newly created table based on schema privileges.
* Explore the benefits of lock-free reservations for performance and user experience.
* Differentiate regular tables from lock-free reservation tables.
* Set the stage for future exploration of the Lock-Free Reservation feature.

### Prerequisites

* Basic understanding of Oracle database management.
* Familiarity with SQL and database concepts such as tables, queries, and user privileges.
* Access to an Oracle database environment with appropriate permissions to create and modify users, tables, and privileges.
* An existing schema or the ability to create a new schema for testing purposes.
Note: Ensure that you have the necessary access and privileges to perform the tasks mentioned in the lab.

## Task 1: Grant Privileges to Users

Task 1 involves granting privileges to users for accessing tables within a schema. We will grant select, insert, update, and delete privileges on the inventory\_no\_reservations table to User 1 (u1) and schema privileges for select, insert, update, and delete operations to User 2 (u2) on Schema 1.

1. Grant select/insert/update/delete privileges on the inventory\_no\_reservations table to u1

    ````
    <copy>
    GRANT SELECT, INSERT, UPDATE, DELETE ON s1.inventory_no_reservations TO u1;
    </copy>
    ````

2. Grant schema priveledges select/insert/update/delete to u2

    ````
    <copy>
    Grant SELECT ANY TABLE on SCHEMA s1 to u2;
    </copy>
    ````

## Task 2: Test the new feature of Schema Privileges versus Select Grants by logging into Users

Task 2 focuses on testing the new schema privilege feature and comparing it with select grants. User 1, with limited access to Table 1 and objects within the schema, will not have schema privileges enabled. User 2, on the other hand, will have schema-level access. During the lab, we will log in as each user and observe their access to different tables within the schema.

By logging in as User 1, we will verify the user and attempt to query Table 1. As expected, User 1 will not be able to access the inventory\_no\_reservations table due to the absence of schema privileges. However, when we log in as User 2, we will observe successful queries on Table 1 and also attempt to query the second table in the schema, inventory\_reservations.

1. Login to user 1

    ```
    <copy>
    sqlplus "username/password"@connect_identifier
    </copy>
    ```

* Input the following to verify user:

    ```
    <copy>
    show user
    </copy>
    ```

* Query the table 1 from the user.

    ```
    <copy>
    select * from s1.inventory_no_reservations;
    </copy>
    ```

* Query the second table from s1 schema and be mindful of what happens.

    ```
    <copy>
    select * from s1.inventory_no_reservations;
    </copy>
    ```

User 1 can not access this table because they do not have schema priveledges feature enabled. Watch what happens next with user 2 who has schema priveledges enabled.

2. Login to user 2

    ```
    <copy>
    sqlplus "username/password"@connect_identifier
    </copy>
    ```

* Input the following to verify user:

    ```
    <copy>
    show user
    </copy>
    ```

* Query the table 1 from the user.

    ```
    <copy>
    select * from s1.inventory_no_reservations;
    </copy>
    ```

* Query the second table from s1 schema and be mindful of what happens.

    ```
    <copy>
    select * from s1.inventory_reservations;
    </copy>
    ```

  Additionally, we will create a third table, inventory\_third\_table, based on the existing inventory table in Schema 1. We will insert data into this new table and observe the access permissions for User 1 and User 2. While User 2 will have access to the new table, User 1 will not, highlighting the impact of schema privileges on user access.

1. Create the third table:

    ```
    <copy>
    CREATE TABLE s1.inventory_third_table (
      id NUMBER,
      product_name VARCHAR2(50),
      quantity NUMBER,
      budget NUMBER
    );
    </copy>
    ```

* Insert Data into the Third Table

    ```
    <copy>
    INSERT INTO s1.inventory_third_table (id, product_name, quantity, budget)
    VALUES (3, 'Product E', 7, 29.99);

    INSERT INTO s1.inventory_third_table (id, product_name, quantity, budget)
    VALUES (4, 'Product F', 12, 39.99);
    </copy>
    ```

2. Login to u1

    ```
    <copy>
    sqlplus "username/password"@connect_identifier
    </copy>
    ```

* Input the following to verify user:

    ```
    <copy>
    show user
    </copy>
    ```

* Query the third table for the user.

    ```
    <copy>
    select * from s1.inventory_third_table;
    </copy>
    ```

  Notice how there is no way user 1 can access the newly created table under the schema.

3. Login to u2

    ```
    <copy>
    sqlplus "username/password"@connect_identifier
    </copy>
    ```

* Input the following to verify user:

    ```
    <copy>
    show user
    </copy>
    ```

* Query the third table for the user.

    ```
    <copy>
    select * from s1.inventory_third_table;
    </copy>
    ```

  This is awesome! We can tell that u2 is entitled to access all tables within the schema.

  The lab will set the stage for the next session, where we will explore the Lock-Free Reservation feature. We will update the inventory\_reservations table and examine the difference in behavior between regular tables and lock-free reservation tables. This feature addresses the issue of session hangs caused by conventional tables, where multiple commits can lead to delays.

You many now **proceed to the next lab**

## Acknowledgements

* **Author(s)** - Blake Hendricks, Database Product Manager
* **Contributor(s)** - Vasudha Krishnaswamy, Russ Lowenthal
* **Last Updated By/Date** - 6/21/2023