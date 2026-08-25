# Create the Migration Compartment

## Introduction

In this lab, you create a dedicated OCI compartment for VMware to OLVM migration resources. A separate compartment keeps migration resources isolated from production workloads and makes cleanup easier after the migration is complete.

Estimated Time: 10 minutes

### Objectives

In this lab, you will:

* Create a dedicated migration compartment.
* Confirm the compartment is visible in the OCI Console.
* Record the compartment details for later labs.

## Task 1: Create a Dedicated Compartment

1. Sign in to the OCI Console.

2. Open the navigation menu.

3. Go to **Identity & Security**, then open **Compartments**. Select the compartment that will be the parent of the new migration compartment.

4. Click **Create Compartment**.

5. For **Name**, enter:

    ```text
    <copy>olvm-migrations</copy>
    ```

6. For **Description**, enter:

    ```text
    <copy>Compartment for VMware to OLVM migration activities.</copy>
    ```

7. For **Parent Compartment**, select the approved parent compartment.

8. Click **Create Compartment**.
    ![Migration compartment](images/create-compartment.png "Create migration compartment")

9. Refresh your browser after the compartment is created.

10. Confirm that the new compartment appears in the list before continuing.
    * Go to **Identity & Security**, then open **Compartments**.
    * Search for the Parent Compartment and look for `olvm-migrations`

11. Record the compartment details.

    ```text
    <copy>Migration compartment:
    Migration compartment OCID:
    Region:</copy>
    ```

You may now **proceed to the next lab**

## Acknowledgements

* **Author** - Mark Atkinson, Evgeny Golenkov, Andrey Sokolov, Perside Foster
* **Contributor** - Keya Balutkar
* **Last Updated By/Date** - Perside Foster, July 2026
