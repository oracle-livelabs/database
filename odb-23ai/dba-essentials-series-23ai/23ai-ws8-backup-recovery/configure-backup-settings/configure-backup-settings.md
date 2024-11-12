# Configure backup settings

## Introduction

This lab shows you how to configure the Oracle Database for several backup-related settings and policies.

Estimated Time: 20 minutes

### Objectives

-   View backup settings
-   Configure backup device settings
-   Configure retention policy settings
-   Configure control file and server parameter file automatic backups
-   Enable block change tracking

### Prerequisites

This lab assumes you have:
-   An Oracle Cloud account
-   Completed all previous labs successfully


## Task 1: View backup settings

1. Start the RMAN prompt.

    ```
    $ <copy>./rman</copy>
    ```

    Output:
    ```
    Recovery Manager: Release 23.0.0.0.0 - Production on Thu Oct 3 13:32:25 2024
    Version 23.4.0.24.05
    
    Copyright (c) 1982, 2024, Oracle and/or its affiliates.  All rights reserved.
    ```

2. Connect to the target Oracle Database.

    ```
    RMAN> <copy>connect target;</copy>
    ```

    Output:
    ```
    connected to target database: CDB1 (DBID=1701812036)
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
    CONFIGURE ENCRYPTION ALGORITHM 'AES256'; # default
    CONFIGURE COMPRESSION ALGORITHM 'BASIC' AS OF RELEASE 'DEFAULT' OPTIMIZE FOR LOAD TRUE ; # default
    CONFIGURE RMAN OUTPUT TO KEEP FOR 7 DAYS; # default
    CONFIGURE ARCHIVELOG DELETION POLICY TO NONE; # default
    CONFIGURE SNAPSHOT CONTROLFILE NAME TO '/opt/oracle/product/23.4.0/dbhome_1/dbs/snapcf_cdb1.f'; # default
    ```


## Task 2: Configure backup optimization settings

Configure backup optimization to save space in the fast recovery area. Optimization excludes unchanged files, such as read-only files and offline data files, that were previously backed up.

1. Switch on backup optimization.

    ```
    RMAN> <copy>configure backup optimization on;</copy>
    ```

    Output:
    ```
    new RMAN configuration parameters:
    CONFIGURE BACKUP OPTIMIZATION ON;
    new RMAN configuration parameters are successfully stored
    ```

2. Verify if the backup optimization parameter setting has been updated.

    ```
    RMAN> <copy>show backup optimization;</copy>
    ```

    Output:
    ```
    RMAN configuration parameters for database with db_unique_name CDB1 are:
    CONFIGURE BACKUP OPTIMIZATION ON;
    ```

## Task 3: Configure retention policy settings

Configure the retention policy to specify how long the backups and archived redo logs must be retained for media recovery.

1. Set the recovery window in the retention policy. The recovery window specifies the number of days the backups and archived redo logs must be retained. For this lab, it is set to `31 days`.

    ```
    RMAN> <copy>configure retention policy to recovery window of 31 days;</copy>
    ```

    Output:
    ```
    new RMAN configuration parameters:
    CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF 31 DAYS;
    new RMAN configuration parameters are successfully stored
    ```

2. Verify if the recovery window setting has been updated.

    ```
    RMAN> <copy>show retention policy;</copy>
    ```

    Output:
    ```
    RMAN configuration parameters for database with db_unique_name CDB1 are:
    CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF 31 DAYS;
    ```

## Task 4: Configure control file and server parameter file automatic backups

You can configure RMAN to automatically back up the control file and server parameter file with every backup. This is referred to as autobackup. The control and server parameter files are critical to the Oracle Database and RMAN. Creating automatic backups of the control file enables RMAN to recover the Oracle Database even if the current control file and server parameter file are lost. The control and server parameter files are relatively small compared to typical data files, and, therefore, backing them up frequently results in relatively little storage overhead.

If the Oracle Database runs in `ARCHIVELOG` mode, an automatic backup is also taken whenever the Oracle Database structure metadata in the control file changes.

1. Switch on autobackup to set automatic backups of the control file and server parameter file.

    ```
    RMAN> <copy>configure controlfile autobackup on;</copy>
    ```

    Output:
    ```
    new RMAN configuration parameters:
    CONFIGURE CONTROLFILE AUTOBACKUP ON;
    new RMAN configuration parameters are successfully stored
    ```

2. Verify if the autobackup setting has been updated.

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

## Task 5: Enable block change tracking

Block change tracking improves the performance of incremental backups by recording changed blocks in the block change tracking file. During an incremental backup, instead of scanning all data blocks to identify which blocks have changed, RMAN uses this file to identify the changed blocks that need to be backed up.

You can enable block change tracking when the Oracle Database is either open or mounted. This section assumes that you intend to create the block change tracking file as an Oracle-managed file in the database area, where the Oracle Database maintains active database files such as data files, control files, and online redo log files.

1. Start the SQL\*Plus prompt.

    ```
    $ <copy>./sqlplus / as sysdba</copy>
    ```

2. Set the location of the block change tracking file in the `db_create_file_dest` parameter. The `db_create_file_dest` specifies the default location for Oracle-managed files. For this lab, it is set to `/opt/oracle/oradata/CDB1`.

    ```
    SQL> <copy>alter system set db_create_file_dest = '/opt/oracle/oradata/CDB1';</copy>
    ```

    Output:
    ```
    System altered.
    ```

3. Enable block change tracking.

    ```
    SQL> <copy>alter database enable block change tracking;</copy>
    ```

    Output:
    ```
    Database altered.
    ```

4. Query `v$block_change_tracking` to verify that block change tracking is enabled and to view the name of the block change tracking file. In the following output, you can see that block change tracking is `ENABLED`.

    ```
    SQL> <copy>select status, filename from v$block_change_tracking;</copy>
    ```

    Output:
    ```
    STATUS   FILENAME
    -------- -----------------------------------------------------------------
    ENABLED  /opt/oracle/oradata/CDB1/CDB1/changetracking/o1_mf_mhx7ftyw_.chg
    ```

5. Exit the SQL\*Plus prompt.

    ```
    SQL> <copy>exit;</copy>
    ```

You may now **proceed to the next lab**.


## Acknowledgements
- **Author**: Suresh Mohan, Database User Assistance Development Team
- **Contributors**: Suresh Rajan, Manish Garodia, Subhash Chandra, Ramya P
- **Last Updated By & Date**: Suresh Mohan, October 2024