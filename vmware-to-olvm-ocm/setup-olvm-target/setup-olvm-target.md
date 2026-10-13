# Set Up the OLVM Target Environment

## Introduction

In this lab, you store OLVM credentials and certificate material in Vault, create the OLVM asset source in OCM, and discover OLVM target assets.

Estimated Time: 25 minutes

### Objectives

In this lab, you will:

* Store OLVM password and certificate secrets in Vault.
* Create the OLVM asset source.
* Discover OLVM target assets.
* Confirm that target clusters, storage domains, templates, and network profiles are visible in inventory.

*VM replication to Oracle Virtualization: target-side path into Oracle Virtualization storage*
![VM Replication](./images/vm-replication.png "Show VM Replication")

## Task 1: Download Engine CA Certificate

1. Open your local browser. Navigate to the Administration Portal using the OLVM engine FQDN or public IP address:

    ```bash
    <copy>https://<olvm-fqdn>/ovirt-engine</copy>
    ```

2. On the landing page, click **Engine CA Certificate** to download it.

    ![Show OLVM welcome page showing the Engine CA Certificate](./images/olvm-welcome.png "Show OLVM welcome page showing the Engine CA Certificate")

3. Open the certificate in Notepad and copy its value.
    ![Notepad CA Certificate](./images/notepad-ca-certificate.png "Show Notepad CA Certificate")

## Task 2: Create the OLVM Asset Source

1. In the OCI Console Menu, open **Migration & Recovery**, **Cloud Migrations** then open **Discovery**.
    ![Migration Discover Menu](images/migration-discovery-menu.png "Select Migration Discover Menu")

2. Click **Create Asset Source**.
    ![Create Asset Source Menu](images/create-asset-sources-menu.png "Click Create Asset Source Menu")

3. Select **OLVM** as the source type. Enter the OLVM asset source details.

    | Field | Value |
    | --- | --- |
    | Asset source type | OLVM |
    | Name | olvm-target-01 |
    | Remote endpoint | OLVM Manager FQDN or IP |
    | Compartment | Migration |
    | Target compartment | Migration |
    | Remote connections source environment compartment | Migration |
    | Remote connections source environment | vmware-source-01 |
    | Discovery credentials | Create secret |
    | Choose compartment | MigrationSecrets |
    | Vault compartment | MigrationSecrets |
    | Vault | ocm-secrets |
    | Username | admin |
    | User password | olvm-password |
    | Confirm user password secret | olvm-password |
    | Public key certificate | Copy the CA certificate from Task 1 |

    ![OLVM Asset Source](./images/create-olvm-asset-source.png "Create OLVM Asset Source")

4. Click **Create Asset Source**.
    ![OLVM Asset Source Build](./images/olvm-asset-source-build.png "Show OLVM Asset Source Build")

5. Confirm that the asset source status is **Active**.
    ![OLVM Asset Source Status](./images/olvm-asset-source-status.png "Show OLVM Asset Source Status")

## Task 3: Discover OLVM Target Assets

1. In the OCI Console Menu, open **Migration & Recovery**, **Cloud Migrations** then open **Discovery**.
2. Click on the **olvm-target-01** Asset Source to open the OLVM asset source details page. Click **Actions** **Run Discovery**.
    ![OLVM Source Run Discovery](images/olvm-source-run-discovery.png "OLVM Source Run Discovery menu")

    ![OLVM Source Run Discovery Popup](images/olvm-source-run-discovery-popup.png "OLVM Source Run Discovery Popup")

3. Wait for the discovery job to complete.

4. In the OCI Console Menu, open **Migration & Recovery**, **Cloud Migrations** then open **Inventory**.

5. Open **Inventory assets**.
    ![OLVM Asset Inventory Menu](images/inventory-assets-menu.png "Show OLVM Asset Inventory Menu")

6. Filter for OLVM assets.
    ![OLVM Asset Inventory Filter](images/inventory-assets-filter.png "Show OLVM Asset Inventory Filter")

7. Confirm that the inventory contains the target resources needed by the migration plan.

    ```text
    <copy>OLVM cluster:
    Storage domains:
    Templates:
    Network profiles:</copy>
    ```


You may now **proceed to the next lab**

## Learn More

* [Oracle Linux Virtualization Manager documentation](https://docs.oracle.com/en/virtualization/oracle-linux-virtualization-manager/)
* [Oracle Cloud Migrations documentation](https://docs.oracle.com/en-us/iaas/Content/cloud-migration/home.htm)

## Acknowledgements

* **Author** - Mark Atkinson, Evgeny Golenkov, Andrey Sokolov, Perside Foster
* **Contributor** - Keya Balutkar
* **Last Updated By/Date** - Perside Foster, July 2026
