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
* Demonstrate user access restrictions to a newly created table based on schema privileges.
* Explore the benefits of lock-free reservations for performance and user experience.
* Differentiate regular tables from lock-free reservation tables.

### Prerequisites

* Basic understanding of Oracle database management.
* Familiarity with SQL and database concepts such as tables, queries, and user privileges.
* Access to an Oracle database environment with appropriate permissions to create and modify users, tables, and privileges.
* An existing schema or the ability to create a new schema for testing purposes.
Note: Ensure that you have the necessary access and privileges to perform the tasks mentioned in the lab.

## Task 1: Grant Privileges to Users

Task 1 involves granting privileges to users for accessing tables within a schema. We will grant select, insert, update, and delete privileges on the inventory\_no\_reservations table to User 1 (u1) and schema privileges for select, insert, update, and delete operations to User 2 (u2) on Schema 1.

1. Login to user 1 with the username and password you selected. If you are already in an sql session you can just type `exit` to quit session.

    ```
    <copy>
    sqlplus system/Welcome123@FREEPDB1
    </copy>
    ```

    * Grant select/insert/update/delete privileges on the inventory\_no\_reservations table to u1

    ```
    <copy>
    GRANT SELECT, INSERT, UPDATE, DELETE ON s1.inventory_no_reservations TO u1;
    </copy>
    ```

2. Grant schema level privileges select/insert/update/delete to u2

    ```
    <copy>
    Grant SELECT ANY TABLE on SCHEMA s1 to u2;
    Grant INSERT ANY TABLE on SCHEMA s1 to u2;
    Grant UPDATE ANY TABLE on SCHEMA s1 to u2;
    Grant DELETE ANY TABLE on SCHEMA s1 to u2;
    </copy>
    ```

## Task 2: Test the new feature of Schema Privileges versus Select Grants by logging into Users

Schema-level privileges: are permissions that are granted to a user or a role at the schema level, allowing them to perform certain actions on all objects within that schema. These privileges are typically applied to the entire schema and are not object-specific.

SELECT grants: are more specific and are used to control read access to individual tables or views within a schema. When a user or role is granted SELECT privileges on a specific table or view, they can query the data from that particular object. SELECT grants provide a finer level of control compared to schema-level privileges, allowing administrators to restrict access to sensitive data while permitting read access to other parts of the schema.

Task 2 focuses on testing the new schema privilege feature and comparing it with select grants. User 1 will not have Schema level privileges and User 2 will. During the lab, we will log in as each user and observe their access to different tables within the schema.

By logging in as User 1, we will verify the user and attempt to query Table 1. As expected, User 1 will not be able to access the inventory\_no\_reservations table due to the absence of schema privileges. 

1.  Login to user 1.

    ```
    <copy>
    CONNECT u1/Welcome123@FREEPDB1;
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

Note: User 1 can not access this table because they do not have schema privileges feature enabled. 

However, when we log in as User 2, we will observe successful queries on Table 1 and also attempt to query the second table in the schema, inventory\_reservations.

Watch what happens next with user 2 who has schema privileges enabled:

2. Login to user 2 with the username and password you selected.

    ```
    <copy>
    CONNECT u2/Welcome123@FREEPDB1;
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

    * Login to sqlplus as sys user again. 

    ```
    <copy>
    CONNECT system/Welcome123@FREEPDB1;
    </copy>
    ```

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
    CONNECT u1/Welcome123@FREEPDB1;
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

  Notice how there is no way user 1 can access the newly created table under the schema due to not have schema level privileges which grant access to all tables. Now watch what happens with u2.

3. Login to u2

    ```
    <copy>
    CONNECT u2/Welcome123@FREEPDB1;
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

  Well done on completing the Schema Level Privileges lab! You now have a solid understanding of how to grant and manage privileges at the schema level, allowing different users varying levels of access to tables within the schema. This knowledge empowers you to implement secure and efficient access controls for your database objects. Keep leveraging schema-level privileges to ensure a well-organized and controlled database environment. Your expertise in Oracle database management is growing, and you're on your way to becoming an exceptional database administrator!

  The lab will set the stage for the next session, where we will explore the Lock-Free Reservation feature. We will update the inventory\_reservations table and examine the difference in behavior between regular tables and lock-free reservation tables. This feature addresses the issue of session hangs caused by conventional tables, where multiple commits can lead to delays.

You many now **proceed to the next lab**

## Acknowledgements

* **Author(s)** - Blake Hendricks, Database Product Manager
* **Contributor(s)** - Vasudha Krishnaswamy, Russ Lowenthal
* **Last Updated By/Date** - 6/21/2023