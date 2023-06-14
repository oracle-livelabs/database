# Lab 1: Setup - User Creation and Table Initialization

In this lab, we will focus on setting up the necessary components for our Oracle database environment. We will create two users, User 1 and User 2, and initialize two tables under Schema 1.

By following the instructions provided, you will complete the setup process and have the necessary users and tables ready for further exploration in the Oracle live lab. Let's dive in and get started with Lab 1!

Estimated Time: 10 minutes

### Prerequisites

In order to do this workshop you need
* An Oracle 23c Free Developer Release Database or one running in a LiveLabs environment

### Objectives

* Create two users, User 1 and User 2, for the Oracle database environment.
* Initialize two tables under Schema 1: inventory\_no\_reservations and inventory\_reservations.
* Create the inventory\_no\_reservations table with the following columns: id, product\_name, quantity, and budget.
* Create the inventory\_reservations table with the following columns: id, product\_name, quantity, budget (reservable), and a minimum_balance constraint.
* Insert data into the inventory\_no\_reservations table with two rows: Product A and Product B.
* Insert data into the inventory\_reservations table with two rows: Product C and Product D.

##
## Task 1: Create Users

Task 1 involves creating the users. By executing the provided SQL statements, we will create User 1 and User 2, each with their respective passwords. These users will be used for various tasks in the upcoming labs.

1. Create two users

* Create user 1 and user 2

    ```
    <copy>
    CREATE USER u1 IDENTIFIED BY password1;

    CREATE USER u2 IDENTIFIED BY password2;
    </copy>
    ```

## Task 2: Create two tables under Schema 1

Moving on to Task 2, we will create two tables under Schema 1. The first table, inventory\_no\_reservations, will serve as a normal table without any special features. The second table, inventory\_reservations, will be created with lock-free reservations. This feature enables efficient management of reservations for specific columns, and we will bind it to the 'budget' column in our case.

1. Create the first table. Table 1 would be inventory\_no\_reservations (normal table)

    ```
    <copy>
    CREATE TABLE s1.inventory_no_reservations (
      id NUMBER PRIMARY KEY,
      product_name VARCHAR2(50),
      quantity NUMBER,
      budget NUMBER
    );
    </copy>
    ```

2. Create a second table with lock-free reservations. Table 2 would be inventory\_reservations (lock free reservation table)

* Modify the `CREATE TABLE` command to enable lock-free reservation as follows:  

    ```
    <copy>
    Create_table_command::={relational_table | object_table | XMLType_table }
    Relational_table::= CREATE TABLE [ schema. ] table …;
    relational_properties::= [ column_definition ] 
    column_definition::= column_name datatype reservable [CONSTRAINT constraint_name check_constraint]
    </copy>
    ```

* Create the table with the reservable keyword to enable lock free reservations to a specific column. In this case we bind it to the `budget` variable.

    ```
    <copy>
    CREATE TABLE s1.inventory_reservations (
      id NUMBER PRIMARY KEY,
      product_name VARCHAR2(50),
      quantity NUMBER,
      budget NUMBER reservable CONSTRAINT minimum_balance CHECK (budget >= 400)

    );
    </copy>
    ```

## Task 3: Insert a few rows into each

Task 3 focuses on inserting a few rows into each of the tables we created. We will insert data into the inventory\_no\_reservations table and the inventory\_reservations table. This step will provide us with initial data to work with in the subsequent labs.

1. Insert data into the first table:

* Inserting rows into inventory\_no\_reservations table

    ```
    <copy>
    INSERT INTO s1.inventory_no_reservations (id, product_name, quantity, budget)
    VALUES (1, 'Product A', 10, 700);
    commit;
    </copy>
    ```

    ```
    <copy>
    INSERT INTO s1.inventory_no_reservations (id, product_name, quantity, budget)
    VALUES (2, 'Product B', 5, 200);
    commit;
    </copy>
    ```

2. Insert data into the second table:

* Inserting rows into inventory\_reservations table

    ```
    <copy>
    INSERT INTO s1.inventory_reservations (id, product_name, quantity, budget)
    VALUES (1, 'Product C', 8, 700);
    </copy>
    ```

    ```
    <copy>
    INSERT INTO s1.inventory_reservations (id, product_name, quantity, budget)
    VALUES (2, 'Product D', 3, 200);
    </copy>
    ```

You many now **proceed to the next lab**