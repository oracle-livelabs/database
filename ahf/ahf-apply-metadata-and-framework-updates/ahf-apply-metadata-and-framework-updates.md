# Apply and rollback AHF updates

## Introduction

In this lab, you will learn how to apply AHF metadata and framework updates, and rollback to the previous timestamp when needed.

Estimated Time: 30 minutes

### Objectives

In this lab, you will:
* Apply AHF framework and metadata updates
* Query AHF framework and metadata updates
* Rollback AHF framework and metadata updates
* Cleanup AHF metadata backup directories

### Prerequisites

This lab assumes you have:
* AHF install user privileges to run the **applyupdate**, **queryupdate**, **rollbackupdate**, and **deleteupdatebackup** commands.

>**Note:** You must have installed 22.1.1 to apply the AHF framework and metadata updates.

## Task 1: Apply AHF metadata and framework updates

Use the **ahfctl applyupdate** command to update metadata and framework files from the zip file provided.

1. To check if the installed version is 22.1.1:

    ```
    <copy>
    tfactl print status
    </copy>
    ```
    Command output:

    ```
    .-------------------------------------------------------------------------------.
    | Host     | Status of TFA | PID    | Port  | Version    | Build ID             |
    +----------+---------------+--------+-------+------------+----------------------+
    | den02mwa | RUNNING       | 105916 | 59452 | 22.1.1.0.0 | 22100020220130232427 |
    '----------+---------------+--------+-------+------------+----------------------'
    ```
2. To apply metadata and framework updates:

    ```
    <copy>
    ahfctl applyupdate -updatefile /home/opc/Downloads/ahf_data_20220602.zip
    </copy>
    ```
    Command output:

    ```
    Updated file /opt/oracle.ahf/orachk/.cgrep/collections.dat
    Updated file /opt/oracle.ahf/orachk/rules.dat
    Updated file /opt/oracle.ahf/orachk/.cgrep/versions.dat
    Updated file /opt/oracle.ahf/orachk/messages/check_messages.json
    Data files updated to 20220602 from 20220516
    ```

3. To query the metadata updates applied:

    >**Note** You can query metadata updates using the **-all** option and the framework updates using **-updateid**.

    ```
    <copy>
    ahfctl queryupdate -all
    </copy>
    ```
    Command output:
    ```
    AHF Metadata Update: 20220602
    Status: Applied
    Applied on: Mon Jun  6 00:23:14 2022
    ```

## Task 2: Rollback AHF metadata and framework and updates

Use the **ahfctl rollbackupdate** command with the **-updateid** option to rollback the updates with a specific update ID. If you do not specify the update ID, then AHF rolls back to the previous state by default.

1. To rollback the metadata and framework updates:

    ```
    <copy>
    ahfctl rollbackupdate -updateid 20220602
    </copy>
    ```
    Command output:
    ```
    Data files with timestamp 20220602 identified. Rolling back the files to Production version 20220516
    Rolled back the data files 20220602 to Production version 20220516
    ```

## Task 3: Cleanup AHF metadata backup directories

You must not delete the backup directories randomly. Oracle recommends deleting the backup directories in the same order the updates were applied. If you delete the backup directories associated with a specific timestamp, then you will not be able to roll back to the state before the updates with that specific timestamp were applied.

Upgrading AHF using the **ahf_setup** script automatically deletes the backup directories of the previous AHF versions.

1. To view the list of backup directories in the patch/update directory:

    ```
    <copy>
    ls  /opt/oracle.ahf/data/work/.exachk_patch_directory
    </copy>
    ```
2. To delete a backup directory with a specific timestamp:

    ```
    <copy>
    ahfctl deleteupdatebackup -updateid 20220602
    </copy>
    ```
    Command output:
    ```
    Deleting backup directories will not allow you to rollback metadata to 20211228 in the future. Do you want to continue? [y/n][y]: Y
    Deleted metadata backup directory for: /opt/oracle.ahf/data/work/.exachk_patch_directory/.20211228_metadata_bkp
    ```

## Learn More

* [ahfctl applyupdate](https://docs.oracle.com/en/engineered-systems/health-diagnostics/autonomous-health-framework/ahfug/ahfctl-applyupdate.html#GUID-1C582851-0138-419D-8CBC-D9F83B97A6AC)
* [ahfctl queryupdate](https://docs.oracle.com/en/engineered-systems/health-diagnostics/autonomous-health-framework/ahfug/ahfctl-queryupdate.html#GUID-C02F4087-184F-4EF7-B94F-8987F9E192B2)
* [ahfctl rollbackupdate](https://docs.oracle.com/en/engineered-systems/health-diagnostics/autonomous-health-framework/ahfug/ahfctl-rollbackupdate.html#GUID-63CC64FF-3D4D-425B-9484-6237D3AC3FD0)
* [ahfctl deleteupdatebackup](https://docs.oracle.com/en/engineered-systems/health-diagnostics/autonomous-health-framework/ahfug/ahfctl-deletebackup.html#GUID-154BA5AA-40EF-45BF-8154-B4000718A35D)

## Acknowledgements
* **Author** - Nirmal Kumar
* **Contributors** -  Sarahi Partida, Robert Pastijn, Girdhari Ghantiyala, Anuradha Chepuri
* **Last Updated By/Date** - Nirmal Kumar, June 2022
