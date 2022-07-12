# Configure backup settings

## Introduction

This lab shows you how to configure the Oracle Database for several backup-related settings and policies.

Estimated Time: 20 minutes

### Objectives

- View backup settings
- Configure backup device settings
- Configure backup optimization settings
- Configure retention policy settings
- Configure control file and server parameter file automatic backups
- Enable block change tracking

### Prerequisites

- A Free Tier, Paid or LiveLabs Oracle Cloud account.
- You have completed:
    - Lab: Prepare setup (_Free-Tier_ and _Paid Tenants_ only)
    - Lab: Initialize environment
    - Lab: Configure recovery settings


## Task 1: View backup settings
In this task, you can view all the existing backup settings by using the following steps.

1. Start the RMAN prompt.

    ```
    $ <copy>./rman</copy>
    ```

    Output:
    ```
    Recovery Manager: Release 21.0.0.0.0 - Production on Thu Dec 16 07:38:21 2021
    Version 21.3.0.0.0

    Copyright (c) 1982, 2021, Oracle and/or its affiliates.  All rights reserved.
    ```

2. Use the following command to connect to the target Oracle Database.

    ```
    RMAN> <copy>connect target;</copy>
    ```

    Output:
    ```
    connected to target database: CDB1 (DBID=1016703368)
    ```

3. Use the following command to view the RMAN configuration settings, including backup settings.

    ```
    RMAN> <copy>show all;</copy>
    ```

    Output:
    ```
    using target database control file instead of recovery catalog
    RMAN configuration parameters for database with db_unique_name CDB1 are:
    CONFIGURE RETENTION POLICY TO REDUNDANCY 1; # default
    CONFIGURE BACKUP OPTIMIZATION OFF; # default
    CONFIGURE DEFAULT DEVICE TYPE TO DISK; # default
    CONFIGURE CONTROLFILE AUTOBACKUP ON; # default
    CONFIGURE CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE DISK TO '%F'; # default
    CONFIGURE DEVICE TYPE DISK PARALLELISM 1 BACKUP TYPE TO BACKUPSET; # default
    CONFIGURE DATAFILE BACKUP COPIES FOR DEVICE TYPE DISK TO 1; # default
    CONFIGURE ARCHIVELOG BACKUP COPIES FOR DEVICE TYPE DISK TO 1; # default
    CONFIGURE MAXSETSIZE TO UNLIMITED; # default
    CONFIGURE ENCRYPTION FOR DATABASE OFF; # default
    CONFIGURE ENCRYPTION ALGORITHM 'AES128'; # default
    CONFIGURE COMPRESSION ALGORITHM 'BASIC' AS OF RELEASE 'DEFAULT' OPTIMIZE FOR LOAD TRUE ; # default
    CONFIGURE RMAN OUTPUT TO KEEP FOR 7 DAYS; # default
    CONFIGURE ARCHIVELOG DELETION POLICY TO NONE; # default
    CONFIGURE SNAPSHOT CONTROLFILE NAME TO '/opt/oracle/dbs/snapcf_cdb1.f'; # default
    ```


## Task 2: Configure backup device settings

The default device used to store backups is `disk` by default. If the default type is different, you can change it to `disk`.

In this task, you configure backup device settings using the following steps.

1. Use the following command to set the default device for backups to `disk`.

    ```
    RMAN> <copy>configure default device type to disk;</copy>
    ```

    Output:
    ```
    new RMAN configuration parameters:
    CONFIGURE DEFAULT DEVICE TYPE TO DISK;
    new RMAN configuration parameters are successfully stored
    ```

2. Use the following command to verify that the setting has been updated. In the following output, you can see that the default device type parameter is set to `disk`.

    ```
    RMAN> <copy>show default device type;</copy>
    ```

    Output:
    ```
    RMAN configuration parameters for database with db_unique_name CDB1 are:
    CONFIGURE DEFAULT DEVICE TYPE TO DISK;
    ```

## Task 3: Configure backup optimization settings

Configure backup optimization to save space in the fast recovery area. Optimization excludes unchanged files, such as read-only files and offline data files, that were previously backed up.

In this task, you configure backup optimization settings using the following steps.

1. Use the following command to configure backup optimization.

    ```
    RMAN> <copy>configure backup optimization on;</copy>
    ```

    Output:
    ```
    new RMAN configuration parameters:
    CONFIGURE BACKUP OPTIMIZATION ON;
    new RMAN configuration parameters are successfully stored
    ```

2. Use the following command to verify the setting has been updated. In the following output, you can see that the backup optimization parameter is set to `ON.`

    ```
    RMAN> <copy>show backup optimization;</copy>
    ```

    Output:
    ```
    RMAN configuration parameters for database with db_unique_name CDB1 are:
    CONFIGURE BACKUP OPTIMIZATION ON;
    ```

## Task 4: Configure retention policy settings

Configure the retention policy to specify how long the backups and archived redo logs must be retained for media recovery.

In this task, you configure retention policy settings using the following steps.

1. Use the following command to configure the retention policy to specify that the backups and archived logs must be retained for your specified number of days. In the following command, we have set the recovery window to `31 days`.

    ```
    RMAN> <copy>configure retention policy to recovery window of 31 days;</copy>
    ```

    Output:
    ```
    new RMAN configuration parameters:
    CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF 31 DAYS;
    new RMAN configuration parameters are successfully stored
    ```

2. Use the following command to verify that the setting has been updated. In the following output, you can see that the retention policy parameter is set to `31 days`.

    ```
    RMAN> <copy>show retention policy;</copy>
    ```

    Output:
    ```
    RMAN configuration parameters for database with db_unique_name CDB1 are:
    CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF 31 DAYS;
    ```

## Task 5: Configure control file and server parameter file automatic backups

You can configure RMAN to automatically backup the control file and server parameter file with every backup. This is referred to as an **autobackup.** The control and server parameter files are critical to the Oracle Database and RMAN. Creating automatic backups of the control file enables RMAN to recover the Oracle Database even if the current control file and server parameter file are lost. The control and server parameter files are relatively small compared to typical data files and, therefore, backing them up frequently results in relatively little storage overhead.

If the Oracle Database runs in **`ARCHIVELOG`** mode, an automatic backup is also taken whenever the Oracle Database structure metadata in the control file changes.

In this task, you configure the control file and server parameter file automatic backups using the following steps.

1. Use the following command to configure automatic backups of the control file and server parameter file.

    ```
    RMAN> <copy>configure controlfile autobackup on;</copy>
    ```

    Output:
    ```
    new RMAN configuration parameters:
    CONFIGURE CONTROLFILE AUTOBACKUP ON;
    new RMAN configuration parameters are successfully stored
    ```

2. Use the following command to verify that the setting has been updated. In the following output, you can see that the `controlfile autobackup` parameter is set to `ON.`

    ```
    RMAN> <copy>show controlfile autobackup;</copy>
    ```

    Output:
    ```
    RMAN configuration parameters for database with db_unique_name CDB1 are:
    CONFIGURE CONTROLFILE AUTOBACKUP ON;
    ```

3. Exit the RMAN prompt.

    ```
    RMAN> <copy>exit;</copy>
    ```

## Task 6: Enable block change tracking

Block change tracking improves the performance of incremental backups by recording changed blocks in the block change tracking file. During an incremental backup, instead of scanning all data blocks to identify which blocks have changed, RMAN uses this file to identify the changed blocks that need to be backed up.

You can enable block change tracking when the Oracle Database is either open or mounted. This section assumes that you intend to create the block change tracking file as an Oracle-managed file in the database area, where the Oracle Database maintains active database files such as data files, control files, and online redo log files.

In this task, you enable block change tracking using the following steps.

1. Start the SQL\*Plus prompt.

    ```
    $ <copy>./sqlplus / as sysdba</copy>
    ```

    Output:
    ```
    SQL*Plus: Release 21.0.0.0.0 - Production on Thu Dec 16 07:40:53 2021
    Version 21.3.0.0.0

    Copyright (c) 1982, 2021, Oracle.  All rights reserved.

    Connected to:
    Oracle Database 21c Enterprise Edition Release 21.0.0.0.0 - Production
    Version 21.3.0.0.0
    ```

2. Use the following command to specify the location of the block change tracking file by setting `db_create_file_dest`, if not already set.

    ```
    SQL> <copy>alter system set db_create_file_dest = '/opt/oracle/oradata/CDB1';</copy>
    ```

    Output:
    ```
    System altered.
    ```

    >**Note:** The `db_create_file_dest` specifies the default location for Oracle-managed files. In this lab, the `db_create_file_dest` parameter is set to `/opt/oracle/oradata/CDB1,` the storage location for data files and control files.

3. Use the following command to enable block change tracking.

    ```
    SQL> <copy>alter database enable block change tracking;</copy>
    ```

    Output:
    ```
    Database altered.
    ```

4. Query **`v$block_change_tracking`** to verify that the block change tracking is enabled and to view the name of the block change tracking file. In the following output, you can see that the block change tracking is `ENABLED.`

    ```
    SQL> <copy>select status, filename from v$block_change_tracking;</copy>
    ```

    Output:
    ```
    STATUS   FILENAME
    -------- -------------------------------------------------------------------------------
    ENABLED  /opt/oracle/oradata/CDB1/CDB1/changetracking/o1_mf_jvovlb3m_.chg
    ```

5. Exit the SQL\*Plus prompt.

    ```
    SQL> <copy>exit;</copy>
    ```

You may now **proceed to the next lab**.

## Acknowledgements

- **Author**: Suresh Mohan, Database User Assistance Development Team
- **Contributors**: Suresh Rajan, Manish Garodia, Subhash Chandra, Ramya P
- **Last Updated By & Date**: Suresh Mohan, May 2022
