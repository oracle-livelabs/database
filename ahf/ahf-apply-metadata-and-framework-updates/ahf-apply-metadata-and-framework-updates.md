# Apply AHF Metadata and Framework Updates

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

## Task 1: Check if the installed version is 22.1.1

```
<copy>
tfactl print status
</copy>
```
Command output:

```
<copy>
.-------------------------------------------------------------------------------.
| Host     | Status of TFA | PID    | Port  | Version    | Build ID             |
+----------+---------------+--------+-------+------------+----------------------+
| den02mwa | RUNNING       | 105916 | 59452 | 22.1.1.0.0 | 22100020220130232427 |
'----------+---------------+--------+-------+------------+----------------------'
</copy>
```

## Task 2: Apply AHF Framework and Metadata Updates

You must apply metadata and framework updates to all cluster nodes.

Use the **ahfctl applyupdate** command to update metadata and framework files on the local node from the zip file provided.

```
<copy>
ahfctl applyupdate -updatefile /home/opc/Downloads/ahf_data_20220602.zip
</copy>
```
Command output:

```
<copy>
Updated file /opt/oracle.ahf/orachk/.cgrep/collections.dat
Updated file /opt/oracle.ahf/orachk/rules.dat
Updated file /opt/oracle.ahf/orachk/.cgrep/versions.dat
Updated file /opt/oracle.ahf/orachk/messages/check_messages.json
Data files updated to 20220602 from 20220516
</copy>
```

## Task 3: Query AHF Framework and Metadata Updates

You can query metadata updates using the **-all** option and the framework updates using **-updateid**.

To verify if the metadata and framework updates were applied to all nodes in a cluster, run the **ahfctl queryupdate** command as the AHF install user on each cluster node.

To check if an update was applied on the local node:

```
<copy>
ahfctl queryupdate -all
</copy>
```
Command output:
```
<copy>
AHF Metadata Update: 20220602
Status: Applied
Applied on: Mon Jun  6 00:23:14 2022
</copy>
```

## Task 4: Rollback AHF Framework and Metadata Updates

Use the **ahfctl rollbackupdate** command to rollback the updates with a specific update ID applied to the local node. If you do not specify the update ID, then AHF rolls back to the previous state by default.

To rollback the metadata and framework updates applied to all nodes in a cluster, you must run the **ahfctl rollbackupdate** command as the AHF install user on each cluster node.

To rollback the metadata and framework updates:

```
<copy>
ahfctl rollbackupdate -updateid 20220602
</copy>
```
Command output:
```
<copy>
Data files with timestamp 20220602 identified. Rolling back the files to Production version 20220516
Rolled back the data files 20220602 to Production version 20220516
</copy>
```

## Task 5: Cleanup AHF Metadata Backup Directories

To delete the backup directories on all nodes in a cluster, you must run the **ahfctl deletebackup** command as the AHF install user on each cluster node.

You must not delete the backup directories randomly. Oracle recommends deleting the backup directories in the same order the updates were applied. If you delete the backup directories associated with a specific timestamp, then you will not be able to roll back to the state before the updates with that specific timestamp were applied.

Upgrading AHF using the **ahf_setup** script automatically deletes the backup directories of the previous AHF versions.

To delete the backup directories:

```
<copy>
ahfctl deleteupdatebackup -updateid 20220602
</copy>
```
Command output:
```
<copy>
No metadata update applied.
</copy>
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
