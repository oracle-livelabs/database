# Getting Started

## Introduction

Use this lab to open the LiveLabs reservation, access the provisioned Autonomous Database 26ai instance, and prepare SQL Worksheet for the retail exercises. The remaining labs are hands-on database exercises. You will run SQL and PL/SQL in the workshop database, not inspect source files.

Estimated Time: 5 minutes

### Objectives

In this lab, you will:

- Launch the LiveLabs workshop environment.
- Open Database Actions for Autonomous Database 26ai.
- Confirm that SQL Worksheet is ready for the retail schema.
- Find the backend setup bundle if you need to create the schema again.

## Task 1: Launch the LiveLabs environment

1. Sign in to [LiveLabs](https://livelabs.oracle.com) with your Oracle account.

2. Open this workshop, select **Start**, and select **Run on LiveLabs Sandbox**.

3. In **My Reservations**, select **Launch Workshop** for this reservation.

4. Select **View Login Info** and keep the database credentials available for the next task.

## Task 2: Open SQL Worksheet

1. In the OCI Console, open the Autonomous Database provisioned for the workshop.

2. Select **Database Actions** and open **SQL Worksheet**.

3. If the workshop schema already exists, connect as `RETAILDB` or use the SQL Worksheet user supplied by the reservation.

4. Run this check.

    ```sql
    <copy>
    SELECT USER AS "User",
           SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') AS "Schema",
           SYSTIMESTAMP AS "Checked At"
    FROM dual;
    </copy>
    ```

    Expected output (example - timestamp varies):

    | User | Schema | Checked At |
    | --- | --- | --- |
    | RETAILDB | RETAILDB | 19-MAY-26 10.30.00.000000 AM UTC |
    {: title="Connected SQL Worksheet Session"}

5. If the schema is not present, ask the instructor to run the scripts in `backend-provisioning/database-source/` in the order described in the README.

You can now continue to the retail labs.

## Acknowledgements

* **Author** - Oracle LiveLabs
* **Last Updated By/Date** - Oracle Database Product Management, May 2026
