# Getting Started

## Introduction

This workshop runs in a **LiveLabs Sandbox**. Provisioning automatically prepares the database, loads the HighTech data, and configures the workshop user and services. No instructor setup or manual database provisioning is needed.

Once your environment is ready, open **View Login Info** in your reservation. Use the supplied link and credentials to sign in to Database Actions as `LLUSER`, then open SQL Worksheet.

<details>
<summary><strong>Key terms: Database Actions, SQL Worksheet, and LLUSER</strong></summary>

> - **Database Actions** is the browser workspace for Oracle Database. You use it to run SQL, browse objects, load data, and open development tools without installing a desktop database client.
>
> - **SQL Worksheet** is the Database Actions tool where you paste and run SQL. It displays query results, script output, and errors.
>
> - `LLUSER` is the workshop database user and schema owner for the hands-on HighTech objects. Using the right user matters because the tables, views, models, graph objects, and functions you query are created under this schema.

</details>

Estimated Time: **5 minutes**

### Objectives

In this lab, you will:

- Launch the LiveLabs workshop environment.
- Use the reservation login information to open Database Actions.
- Confirm that SQL Worksheet is connected as the workshop schema user.

## Task 1: Launch the LiveLabs environment

Open the LiveLabs reservation for this workshop. It contains the database link and sign-in details.

1. Sign in to [LiveLabs](https://livelabs.oracle.com) with your Oracle account.

2. Open this workshop, select **Start**, and select **Run on LiveLabs Sandbox**.

3. Wait for the sandbox environment to finish provisioning. In **My Reservations**, select **Launch Workshop** for this reservation.

4. Select **View Login Info** and keep the database credentials available for the next task.

    ![Reservation Information dialog showing Terraform Outputs with Login, Password, and Login URL rows](images/reservation-login-info.svg " ")

## Task 2: Open SQL Worksheet

Open SQL Worksheet as `LLUSER`. Run each query there and review the returned table.

1. In the **Reservation Information** dialog, confirm that **1 - Login** shows `LLUSER`.

2. Select **Copy** for **2 - Password**.

    ![Reservation Information dialog with the Copy button highlighted for the Password row](images/reservation-login-copy-password.svg " ")

3. Select **Open Link** for **3 - Login URL**.

    ![Reservation Information dialog with the Open Link button highlighted for the Login URL row](images/reservation-login-open-link.svg " ")

4. On the Database Actions sign-in page, confirm that **Username** shows `LLUSER`, paste the password from the reservation information, and select **Sign in**.

    ![Database Actions login screen showing LLUSER as the selected username](images/database-actions-login-main-user.svg " ")

5. Before SQL Worksheet opens, select **Development**, then select **SQL** from the tools menu.

    ![Database Actions tools page with Development selected and SQL highlighted in the left tools menu](images/database-actions-development-sql.svg " ")

6. Use the same SQL Worksheet pattern throughout the workshop.

    - Confirm the user dropdown shows the main workshop user, usually `LLUSER`.
    - Paste each workshop SQL block into the editor.
    - Select **Run Statement** or press **Ctrl+Enter** to run the current SQL statement.
    - Review the output in **Query Result** or **Script Output**, depending on the step.
    - Use **Navigator** only when you want to inspect tables, views, or other objects.

7. Run this check.

    This check makes sure SQL Worksheet is connected as the right user before you start. `USER` shows who signed in, while `SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')` shows where table names resolve. The HighTech labs use `LLUSER`, so both values should point to the workshop schema.

    ```sql
    <copy>
    SELECT USER AS "User",
           SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') AS "Schema",
           SYSTIMESTAMP AS "Checked At";
    </copy>
    ```

    ![SQL Worksheet connection query showing the user and current schema](images/sql-connection.jpg)

    **Expected output: Connected SQL Worksheet Session**

    | User | Schema | Checked At |
    | --- | --- | --- |
    | LLUSER | LLUSER | Current SQL Worksheet timestamp |

8. You can use this same connection check whenever you want to confirm that SQL Worksheet is still running as `LLUSER`.

You can now continue to the HighTech labs.

## Acknowledgements

* **Author** - Matt Kowalik
* **Contributor** - Kevin Lazarz
* **Last Updated By/Date** - Matt Kowalik, September 2026

