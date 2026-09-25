# Getting Started

## Introduction

You use Database Actions SQL Worksheet for every learner-facing SQL task. The workshop account is `LLUSER`; your reservation supplies the password and launch URL.

Estimated Time: **5 minutes**

### Objectives

- Open the LiveLabs reservation information.
- Sign in to Database Actions as `LLUSER`.
- Verify the Energy and Utilities dataset before starting Lab 1.

## Task 1: Launch the LiveLabs environment

1. Click **View Login Info** in the LiveLabs reservation panel.
2. Copy the database password and open the supplied Database Actions URL.
3. Sign in with username `LLUSER` and the password from the reservation. Do not save the password in a script or workshop file.

> **Checkpoint:** Keep the reservation tab open. It contains the environment details you may need if your Database Actions session expires.

## Task 2: Open SQL Worksheet

1. On the Database Actions launchpad, select **SQL**.
2. Run the following connection and dataset check.

    ```sql
    SELECT USER AS "User",
           SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') AS "Schema",
           SYSTIMESTAMP AS "Checked At"
    FROM dual;

    SELECT COUNT(*) AS eu_utility_service_requests
    FROM eu_utility_service_requests;
    ```

3. Confirm that `User` and `Schema` are `LLUSER`. Confirm the request count is greater than zero.

    ![SQL Worksheet showing the LLUSER connection check](images/sql-worksheet-connection-check.png " ")

    **Expected output pattern**

    | Check | Expected evidence |
    | --- | --- |
    | Connected user | `LLUSER` |
    | Current schema | `LLUSER` |
    | Dataset | `EU_UTILITY_SERVICE_REQUESTS` count is greater than zero. |

## Task 3: Use SQL Worksheet throughout the workshop

1. Use each SQL code block's **Copy** button, then paste one block at a time into the worksheet.
2. Select the statement or block you want to run, then use **Run Statement**.
3. Review the result grid and any script output before moving to the next step.
4. Keep this browser tab open. Each lab links back to this task when a worksheet reminder is useful.

> **Troubleshooting:** If an object is missing, stop and tell the workshop facilitator. The lab loader must complete before learners begin.

## Acknowledgements

* **Author** - Oracle Database Product Management
* **Last Updated By/Date** - Oracle Database Product Management, September 2026
