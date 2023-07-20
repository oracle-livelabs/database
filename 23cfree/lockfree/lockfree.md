# Lock-Free Reservations

## Introduction

Welcome to the Final Lab: Lock-Free Reservations!

In this lab, we will explore the concept of lock-free reservations and their impact on database transactions. By performing normal updates and utilizing lock-free reservations, we will observe session behavior and the advantages of this feature. Join us as we jump into the final lab and experience the benefits of lock-free reservations in improving performance and user experience. Let's get started!

* By following the steps in this lab, we will gain insights into the behavior of sessions during normal updates and the advantages of lock-free reservations. Join us as we explore these awesome concepts and experience improved performance and user experience with lock-free reservations.

Estimated Time: 10 minutes

### Objectives

* Understand the concept of lock-free reservations and their benefits.
* Perform normal updates and observe session behavior without lock-free reservations.
* Experience session hangs caused by uncommitted changes and insufficient budget amounts.
* Explore the advantages of lock-free reservations in improving performance and user experience.
* Perform updates with lock-free reservations and observe the absence of session hangs.
* Handle session errors caused by going below the "threshold" with lock-free reservations.
* Learn how committing changes and rolling back transactions affect lock-free reservations.
* Recognize the restoration of reserved amounts in the budget column with lock-free reservations.

### Prerequisites

* Basic understanding of database concepts and transactions.
* Familiarity with SQL queries and syntax.
* Access to an Oracle database system.
* User credentials with sufficient privileges to perform updates and create tables.
* Knowledge of session behavior and transaction management.

## Task 1: Normal Update

Task 1 focuses on normal updates. By opening three windows as User 2, we will perform updates on the inventory\_no\_reservations table. In Window 1, we will decrease the budget of a record by 100 but refrain from committing the changes. In Window 2, we will attempt to update the same record by 100, resulting in a session hang due to the uncommitted changes in Window 1. Similarly, in Window 3, we will decrease the record by 200, causing another session hang. We will then commit the changes in Window 1, releasing one of the other two windows. If any freed-up window encounters an error when committing, we will take note of the error message. Note that an insufficient budget amount will cause an abort.

1. Login to u2 and Open 3 different terminal windows connected u2.

    * If you are already in the sql session just type this to connect

    ```
    <copy>
    CONNECT u2/Welcome123@FREEPDB1;
    </copy>
    ```

    * If you are out of the sql session by way of `exit` connect this way:
    ```
    <copy>
    sqlplus u2/Welcome123@FREEPDB1;
    </copy>
    ```

Once connected proceed to step 2.

2. In Window 1 update table1 (inventory\_no\_reservations) decrease a record by 100 but don’t commit

    ```
    <copy>
    UPDATE s1.inventory_no_reservations
    SET budget = budget - 100 where ID = 1;
    </copy>
    ```

3. Window 2 update table1 and decrease the same record by 100 and it shows that the session hangs. Due to the first update not being commited.

    ```
    <copy>
    UPDATE s1.inventory_no_reservations
    SET budget = budget - 100
    WHERE ID = 1;

    COMMIT;
    </copy>
    ```

4. Window 3 update the table1 and decrease the same record by 200. The session should hang again.

    ```
    <copy>
    UPDATE s1.inventory_no_reservations
    SET budget = budget - 200
    WHERE ID = 1;

    COMMIT;
    </copy>
    ```

5. In Window 1 please commit the statement below which releases one of the other two windows

    ```
    <copy>
    UPDATE s1.inventory_no_reservations
    SET budget = budget - 100
    WHERE ID = 1;

    COMMIT;
    </copy>
    ```

6. Once the last two windows are freed up, and you are able to commit, proceed to the next step. Note that the lack of concurrency to execute multiple commits simulateneously is caused by not having lock-free reservations enabled for the table.


## Task 2: Lock-Free Reservations

Task 2 introduces the concept of lock-free reservations. Using the same three windows, we will now perform updates on the inventory\_reservations table. In Window 1, we will decrease the budget of a record by 200 without committing. In Window 2, we will decrease the same record by 200, and unlike before, the session will not hang. In Window 3, we will attempt to decrease the record by 200, going below the "threshold," which will result in a session error. We will then commit the changes in Window 1 and rollback the changes in Window 2. Finally, we will run the transaction again in Window 3, which should succeed because we have restored the reserved amount in the budget column.

Note: Using the same 3 windows please `Ctrl+C` to get out of session hangs.

1. Window 1 update table 2 (inventory\_reservations) table decrease the record by 200. Do not commit.

    ```
    <copy>
    UPDATE s1.inventory_reservations
    SET budget = budget - 200 where ID = 1;

    </copy>
    ```

2. Window 2 update table 2 and decrease the same record by 200. Make sure you press `Ctrl+C` to revitalize your session.

    ```
    <copy>
    UPDATE s1.inventory_reservations
    SET budget = budget - 200
    WHERE ID = 1;

    COMMIT;
    </copy>
    ```

    * Note: Notice how the session does not hang like it did using old normal updates in the last task. This is due to the concurrency Lock-Free enables for dba user experience.

* Commit Window 1

    ```
    <copy>
    COMMIT;
    </copy>
    ```

3. In window 3 update t2 and decrease the same record by 300 going below the “threshold” and the session errors because we go below 400. In lock-free every user needs to stay above the constraint.

    ```
    <copy>
    UPDATE s1.inventory_reservations
    SET budget = budget - 300
    WHERE ID = 1;

    </copy>
    ```

4. Execute this statement in window 2 to give back the 200.

    ```
    <copy>
    UPDATE s1.inventory_reservations
    SET budget = budget + 200
    WHERE ID = 1;

    COMMIT;
    </copy>
    ```

5. Go to Window 3 and run the transaction again and it should succeed because we gave back the 200 to the reserved column, budget.

    ```
    <copy>
    UPDATE s1.inventory_reservations
    SET budget = budget - 200 where ID = 1;

    COMMIT;
    </copy>
    ```

## Acknowledgements

* **Author(s)** - Blake Hendricks, Product Manager
* **Contributor(s)** - Vasudha Krishnaswamy, Russ Lowenthal
* **Last Updated By/Date** - 7/17/2023
