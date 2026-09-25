# Create the OLVM Migration Project

## Introduction

In this lab, you create an OCM migration project with an initial OLVM migration plan, add the discovered VMware VM, configure the replication location, and select OLVM target values.

Estimated Time: 30 minutes

### Objectives

In this lab, you will:

* Create a migration project with an initial migration plan.
* Enable OLVM migration project mode.
* Add discovered VMware assets.
* Set the replication location.
* Configure OLVM cluster, VnicProfile, and template values.

## Task 1: Start the Migration Project Wizard

1. In the OCI Console Menu, open **Migration & Recovery**,**Cloud Migrations**, **Migrations**.
    ![Migrations Menu](images/migrations-menu.png "Select Migrations Menu")

2. From **Migration projects** page click **Create migration project** button.
    ![Create migrations project button](images/create-migrations-project-button.png "Click Create migrations project  button")

3. Select **Create a migration project with initial migration plan**. Then click **Create Migration Project**.
    ![Create migrations project initial plan](images/migration-project-initial-plan.png "Select  Create migrations project initial plan")

## Task 2: Enter Basic Information

1. For **Display Name**, enter `olvm-migration-wave-01` or your migration wave name.

2. Select the **Migration** compartment.

3. Enable the **OLVM Migration Project** option.

    This option is required. Without it, the project targets OCI Compute instead of OLVM and the OLVM-specific target fields will not appear.

4. Select **No replication schedule** for a first test.

    ![Migrations project basic info](images/migration-project-basic-info.png "Create Migrations project basic info")
5. Click **Next**.

## Task 3: Add Assets

1. From **Create migration project, Assets**,  Click **Add from OCM Inventory** button
    ![Migrations project assets](images/migration-project-assets.png "Click Migrations project assets")

2. Select (checkbox) the VMware VMs from inventory that you want to include in the migration wave. Then Click **Add from OCM Inventory** button
    ![Migrations assets inventory](images/migration-assets-inventory-add.png "Add Migrations assets inventory")

3. Confirm that the selected VMs appear in the assets list.
    ![Inventory assets in list](images/invetory-assets-in-list.png "Confirm Inventory assets in list")

4. Click **Next**.

## Task 4: Set the Replication Location

1. Under **Default Replication Location**, select the target availability domain.
    ![Replication Location](images/replication-location.png "Select Replication Location")

2. Select the replication compartment **Migration**.

3. Select the replication bucket created by the prerequisites stack **data-nfs-1**. Then click the **Save** button
    ![Replication Storage](images/replication-storage.png "Select Replication Storage")

4. Confirm that all assets show the selected replication location.
    ![Asset Replication Location](images/asset-replication-location.png "Confirm Asset Replication Location")

5. Click **Next**.

## Task 5: Configure Initial Migration Plan and Target Environment

1. Enter a display name for the migration plan, such as `olvm-plan-wave-01`.

2. Select compartment **Migration**. Then select the target compartment **Migration**.

3. Select the OLVM cluster where migrated VMs will be provisioned.

4. Select the VnicProfile to assign to migrated VM network adapters.

5. Select the template to use as the base for provisioned VMs in OLVM.
    ![Configure Migration Plan and Target Environment](images/comfigure-migration-target.png "Configure Migration Plan and Target Environment")

6. Click **Submit**.

7. Confirm that the migration project and initial migration plan appear with an active status.

8. Record the project and plan names.

    ```text
    <copy>Migration project:
    Migration plan:
    Replication bucket:
    Target cluster:
    Target VnicProfile:
    Target template:</copy>
    ```

You may now **proceed to the next lab**

## Learn More

* [Create a migration project for OLVM](https://docs.oracle.com/en-us/iaas/Content/cloud-migration/cloud-migration-create-migration-project-olvm.htm)

## Acknowledgements

* **Author** - Mark Atkinson, Evgeny Golenkov, Andrey Sokolov, Perside Foster
* **Contributor** - Keya Balutkar
* **Last Updated By/Date** - Perside Foster, July 2026
