# Getting Started

## Introduction

> **Image status:** This lab includes generic sign-in illustrations. It also includes the connection check captured during the manufacturing walkthrough. See the [image inventory](../validation/screenshots.md) for the source of each image.

Open your LiveLabs reservation, sign in to **Autonomous Database 26ai**, and prepare SQL Worksheet. Run the manufacturing exercises as `LLUSER`, the workshop database user.

<details>
<summary><strong>Key terms: Database Actions, SQL Worksheet, and LLUSER</strong></summary>

> - **Database Actions** is the browser workspace for Oracle Database. You use it to run SQL, browse objects, load data, and open development tools without installing a desktop database client.
>
> - **SQL Worksheet** is the Database Actions tool where you paste and run SQL. It displays query results, script output, and errors.
>
> - `LLUSER` is the workshop database user and schema owner for the hands-on manufacturing objects. Using the right user matters because the tables, views, models, graph objects, and functions you query are created under this schema.

</details>

The sign-in graphics illustrate the navigation steps. Use the connection query to verify your own manufacturing database session.

### Environment prerequisites

Before starting, the instructor must load the manufacturing dataset into `LLUSER` on Autonomous Database 26ai and check the [manufacturing schema contract](../validation/schema-contract.md). Run the supplied loader on a fresh manually provisioned database before beginning the exercises.

Required capabilities are Database Actions SQL Worksheet, Graph Studio, native JSON and duality views, Oracle Spatial, Oracle Machine Learning, access to `ADMIN.ALL_MINILM_L12_V2`, and an enabled `GENAI` profile with an approved provider. Labs 1 and 4 require preloaded embeddings and a precreated production order graph. Lab 3 creates a separate teaching vector column. Lab 8 depends on Lab 7. AutoML and the supplemental PGX notebook also need their respective services and privileges.

Both workshop navigation options currently show the sandbox launch steps below. LiveLabs green-button and tenancy provisioning still need testing. If you use a manually provisioned database, open the Database Actions URL supplied by your instructor and sign in as `LLUSER`.

Estimated Time: **5 minutes**

### Objectives

In this lab, you will:

- Launch the LiveLabs workshop environment.
- Use the reservation login information to open Database Actions.
- Confirm that SQL Worksheet is ready for the manufacturing schema.
- Confirm that SQL Worksheet is connected as the workshop schema user.

## Task 1: Launch the LiveLabs environment

Open the LiveLabs reservation for this workshop. It contains the database link and sign-in details.

1. Sign in to [LiveLabs](https://livelabs.oracle.com) with your Oracle account.

2. Open this workshop, select **Start**, and select **Run on LiveLabs Sandbox**.

3. In **My Reservations**, select **Launch Workshop** for this reservation.

4. Select **View Login Info** and keep the database credentials available for the next task.

    ![Reservation Information dialog showing Terraform Outputs with Login, Password, and Login URL rows](images/reservation-login-info.svg " ")

    *Figure 1: The Reservation Information dialog shows the `LLUSER` login, password, and Login URL for Database Actions.*

## Task 2: Open SQL Worksheet

Open SQL Worksheet as `LLUSER`. Run each query there and review the returned table.

1. In the **Reservation Information** dialog, confirm that **1 - Login** shows `LLUSER`.

2. Select **Copy** for **2 - Password**.

    ![Reservation Information dialog with the Copy button highlighted for the Password row](images/reservation-login-copy-password.svg " ")

    *Figure 2: Copy the `LLUSER` password from the Reservation Information dialog.*

3. Select **Open Link** for **3 - Login URL**.

    ![Reservation Information dialog with the Open Link button highlighted for the Login URL row](images/reservation-login-open-link.svg " ")

    *Figure 3: Use Open Link for the Login URL, then use the copied password to sign in as `LLUSER`.*

4. On the Database Actions sign-in page, confirm that **Username** shows `LLUSER`, paste the password from the reservation information, and select **Sign in**.

    ![Database Actions login screen showing LLUSER as the selected username](images/database-actions-login-main-user.svg " ")

    *Figure 4: Sign in to Database Actions as `LLUSER` with the password from the reservation information.*

5. Before SQL Worksheet opens, select **Development**, then select **SQL** from the tools menu.

    ![Database Actions tools page with Development selected and SQL highlighted in the left tools menu](images/database-actions-development-sql.svg " ")

    *Figure 5: Open SQL from the Development tools menu.*

6. Use the same SQL Worksheet pattern throughout the workshop.

    


    - Confirm the user dropdown shows the main workshop user, usually `LLUSER`.
    - Paste each workshop SQL block into the editor.
    - Select **Run Statement** or press **Ctrl+Enter** to run the current SQL statement.
    - Review the output in **Query Result** or **Script Output**, depending on the step.
    - Use **Navigator** only when you want to inspect tables, views, or other objects.

7. Run this check.

    This check makes sure SQL Worksheet is connected as the right user before you start. `USER` shows who signed in, while `SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')` shows where table names resolve. The manufacturing labs use `LLUSER`, so both values should point to the workshop schema.

    ```sql
    <copy>
    SELECT USER AS "User",
           SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') AS "Schema",
           SYSTIMESTAMP AS "Checked At";
    </copy>
    ```

    ![Live manufacturing result: connection](images/sql-connection.jpg)

    


    **Expected output: Connected SQL Worksheet Session**

    | User | Schema | Checked At |
    | --- | --- | --- |
    | LLUSER | LLUSER | Current SQL Worksheet timestamp |


8. You can use this same connection check whenever you want to confirm that SQL Worksheet is still running as `LLUSER`.

You can now continue to the manufacturing labs.

## Acknowledgements

* **Author** - Matt Kowalik
* **Contributor** - Kevin Lazarz
* **Last Updated By/Date** - Matt Kowalik, September 2026

