# Apply and rollback AHF updates

## Introduction

In this lab, you will learn how to apply metadata and framework updates to AHF, roll back to the previous timestamp, and clean up backup files.

Estimated Time: 30 minutes

### Objectives

In this lab, you will:
* Apply AHF metadata and framework updates
* Query AHF metadata and framework updates
* Rollback AHF metadata and framework updates
* Cleanup backup directories used for AHF metadata and framework updates

### Prerequisites

* You must have installed AHF version 22.1.1 to apply AHF framework and metadata updates.
* AHF install user privileges to run the **applyupdate**, **queryupdate**, **rollbackupdate**, and **deleteupdatebackup** commands.

## Task 1: Apply AHF metadata and framework updates

Run the **ahfctl applyupdate** command to update metadata and framework files from the zip file provided.

Run the **ahfctl queryupdate** command to check if an update was applied. To get a list of all the metadata and framework updates applied, use the **-all** option. To query a metadata or framework update with a specific update ID, use the **-updateid** option.

>**Note:** **ahf\_data\_update ID/timestamp.zip** identifies a metadata update file and **ahf_update ID/timestamp.zip** identifies a framework update file.

1. To check if the installed version is 22.1.1:

    ```
    <copy>
    tfactl print status
    </copy>
    ```
    Command output:

    ```
    .-------------------------------------------------------------------------------------------------------------.
    | Host                 | Status of TFA | PID   | Port  | Version    | Build ID             | Inventory Status |
    +----------------------+---------------+-------+-------+------------+----------------------+------------------+
    | ll46863-instance-ahf | RUNNING       | 83199 | 20707 | 22.1.1.0.0 | 22110020220516195917 | COMPLETE         |
    '----------------------+---------------+-------+-------+------------+----------------------+------------------'
    ```
2. To apply metadata updates:

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
    >**Note:** You cannot apply framework updates because framework update zip files are not included in this workshop. The following example is provided solely for informational purposes.

    To apply framework update:

    ```
    ahfctl applyupdate -updatefile ahf_33687033.zip
    ```
    Command output:
    ```
    Updated file /opt/oracle.ahf/ahf/lib/ahfcomponents.pyc
    Updated file /opt/oracle.ahf/ahf/lib/ahfparser.pyc
    Updated file /opt/oracle.ahf/ahf/lib/ahfpatch.pyc
    Updated file /opt/oracle.ahf/ahf/lib/ahfctl.pyc
    Updated file /opt/oracle.ahf/exachk/messages/framework_messages.json
    Updated file /opt/oracle.ahf/exachk/lib/utils.pyc
    Updated file /opt/oracle.ahf/exachk/lib/constant.pyc
    Updated file /opt/oracle.ahf/exachk/messages/ahfmessages.json
    Updated file /opt/oracle.ahf/exachk/lib/gen_apply_patch.pyc
    Updated file /opt/oracle.ahf/ahf/bin/uninstallahf.sh
    Updated file /opt/oracle.ahf/exachk/exachk.pyc
    Updated file /opt/oracle.ahf/ahf/scripts/ahf_upgrade.pyc
    Updated file /opt/oracle.ahf/exachk/lib/ahf_metadata.pyc

    AHF metadata updating of file ahf_33687033.zip completed

    Updated to 22.1.0.1 from 22.1.0

    AHF framework update fixes 33687033, 33161400, 33687046, 33687061, 33687041
    ```

3. To query all the metadata and framework updates applied:

    ```
    <copy>
    ahfctl queryupdate -all
    </copy>
    ```
    Command output:
    ```
    AHF Metadata Update: 20220602
    Status: Applied
    Applied on: Wed Jul  6 15:45:02 2022
    ```

## Task 2: Rollback AHF metadata and framework updates

Run the **ahfctl rollbackupdate** command with the **-updateid** option to rollback the updates with a specific update ID. If you do not specify the update ID, then AHF rolls back to the previous state by default.

>**Note:** All the backup directories used for applying updates will also be deleted as part of rollback.

1. To rollback metadata updates:

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

## Task 3: Cleanup backup directories used for AHF metadata and framework updates

Run the **ahfctl deleteupdatebackup** command to delete the backup directories used for AHF metadata and framework updates.

>**Note:**
- If you delete backup directories for a specific update ID, then you cannot rollback to that specific update ID.
- Repeat Task 1: Apply AHF metadata and framework updates if you have performed Task 2: Rollback AHF metadata and framework and updates, and then proceed with the following steps.
- **Backup directory in non-Exadata systems:** /opt/oracle.ahf/data/work/<font color=#f80000><b>.orachk</b></font>\_patch\_directory</br>
**Backup directory in Exadata systems:** /opt/oracle.ahf/data/work/<font color=#f80000><b>.exachk</b></font>\_patch\_directory

1. To view the list of backup directories in the patch/update directory:

    ```
    <copy>
    ls -la /opt/oracle.ahf/data/work/.orachk_patch_directory
    </copy>
    ```
    Command output:

    ```
    drwxr-xr-x. 4 root root      196 Jul  6 15:51 .
    drwxr-x--x. 3 root root       37 Jul  6 15:43 ..
    drwxr-xr-x. 2 root root      141 Jul  6 15:51 .20220602_metadata_bkp
    drwxr-xr-x. 2 root root      141 Jul  6 15:45 .base_dat_20220602
    -r--r--r--. 1 root root   877505 Jul  6 15:51 .check_messages.dat.production
    -r--r--r--. 1 root root 75877931 Jul  6 15:50 .collections.dat.production
    -r--r--r--. 1 root root 10660569 Jul  6 15:51 .rules.dat.production
    -r--r--r--. 1 root root     8311 Jul  6 15:51 .versions.dat.production

    ```

2. To delete a backup directory with a specific timestamp:

    ```
    ahfctl deleteupdatebackup -updateid 20220602

    ```
    Command output:

    ```
    Removing current timestamp: 20220602 backup directory not allowed, Please use ahfctl rollback update -h.
    ```

    If the timestamp is not current, then the expected output would be similar to the following:

    <pre>
    Deleting backup directories will not allow you to rollback metadata to 20220602 in the future. Do you want to continue? [y/n][y]: <font color=#f80000><i><b>Y</i></b></font>
    Deleted metadata backup directory for: /opt/oracle.ahf/data/work/.orachk_patch_directory/.20220602_metadata_bkp
    </pre>

## Learn More

* [ahfctl applyupdate](https://docs.oracle.com/en/engineered-systems/health-diagnostics/autonomous-health-framework/ahfug/ahfctl-applyupdate.html#GUID-1C582851-0138-419D-8CBC-D9F83B97A6AC)
* [ahfctl queryupdate](https://docs.oracle.com/en/engineered-systems/health-diagnostics/autonomous-health-framework/ahfug/ahfctl-queryupdate.html#GUID-C02F4087-184F-4EF7-B94F-8987F9E192B2)
* [ahfctl rollbackupdate](https://docs.oracle.com/en/engineered-systems/health-diagnostics/autonomous-health-framework/ahfug/ahfctl-rollbackupdate.html#GUID-63CC64FF-3D4D-425B-9484-6237D3AC3FD0)
* [ahfctl deleteupdatebackup](https://docs.oracle.com/en/engineered-systems/health-diagnostics/autonomous-health-framework/ahfug/ahfctl-deletebackup.html#GUID-154BA5AA-40EF-45BF-8154-B4000718A35D)

## Acknowledgements
* **Author** - Nirmal Kumar
* **Contributors** -  Sarahi Partida, Robert Pastijn, Girdhari Ghantiyala, Anuradha Chepuri
* **Last Updated By/Date** - Nirmal Kumar, July 2022
