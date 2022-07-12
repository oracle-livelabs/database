# Configure recovery settings

## Introduction
This lab shows you how to configure the Oracle Database for several recovery settings.  

Estimated Time: 20 minutes

### Objectives
- Set the environment
- Configure the Fast Recovery Area
- Enable archiving of redo log files
- Enable Flashback Database

### Prerequisites
- A Free Tier, Paid or LiveLabs Oracle Cloud account.
- You have completed:
    - Lab: Prepare setup (_Free-Tier_ and _Paid Tenants_ only)
    - Lab: Initialize environment


## Task 1: Configure the fast recovery area
The fast recovery area is an Oracle-managed directory on a file system or Oracle Automatic Storage Management (Oracle ASM) disk group that provides a centralized storage location for backup and recovery files. Oracle creates archived logs and flashback logs in the fast recovery area. Oracle automatically manages the fast recovery area, deleting files that are no longer needed.

Recovery Manager (RMAN) can store its backup sets and image copies in the fast recovery area and use them when restoring files during media recovery. If the fast recovery area is configured, RMAN automatically backs up to the fast recovery area when you issue the RMAN `backup` command without specifying a backup destination.

In this task, you configure the fast recovery area using the following steps.

1. Start the SQL\*Plus prompt and connect as the sysdba user.
    ```
    $ <copy>./sqlplus / as sysdba</copy>
    ```
    Output:
    ```
    SQL*Plus: Release 21.0.0.0.0 - Production on Thu Dec 16 07:31:06 2021
    Version 21.3.0.0.0

    Copyright (c) 1982, 2021, Oracle.  All rights reserved.

    Connected to:
    Oracle Database 21c Enterprise Edition Release 21.0.0.0.0 - Production
    Version 21.3.0.0.0
    ```

2. Use the following command to view the settings for all initialization parameters containing "recovery" in the name.
    ```
    SQL> <copy>show parameter recovery;</copy>
    ```
    Output:
    ```
    NAME                                 TYPE        VALUE
    ------------------------------------ ----------- ------------------------------
    db_recovery_file_dest                string      /opt/oracle/recovery_area
    db_recovery_file_dest_size           big integer 13776M
    recovery_parallelism                 integer     0
    remote_recovery_file_dest            string
    ```

    >**Note:** The `db_recovery_file_dest` parameter sets the location of the fast recovery area. Oracle recommends placing the fast recovery area on a separate storage device from the Oracle Database files. The `db_recovery_file_dest_size` parameter shows the size of your fast recovery area. The size of your fast recovery area may differ from what is shown in this example. Generally, the default size present for the fast recovery area might not be sufficient for your files.

3. Use the following command to set the fast recovery area size to a larger size to store the Oracle Database files sufficiently. In this case, it is set to `10GB`.
    ```
    SQL> <copy>alter system set db_recovery_file_dest_size=10G;</copy>
    ```
    Output:
    ```
    System altered.
    ```

4. If the `db_recovery_file_dest` parameter is not already set, use the following command to set the recovery file destination location. In this case, it is set to `/opt/oracle/recovery_area`.
    ```
    SQL> <copy>alter system set db_recovery_file_dest="/opt/oracle/recovery_area";</copy>
    ```
    Output:
    ```
    System altered.
    ```

5. Use the following command again to view the altered settings. You can see that the `db_recovery_file_dest_size` parameter is set to _`10GB` and `db_recovery_file_dest` parameter is set.
    ```
    SQL> <copy>show parameter recovery;</copy>
    ```
    Output:
    ```
    NAME                                 TYPE        VALUE
    ------------------------------------ ----------- ------------------------------
    db_recovery_file_dest                string      /opt/oracle/recovery_area
    db_recovery_file_dest_size           big integer 10G
    recovery_parallelism                 integer     0
    remote_recovery_file_dest            string
    ```


## Task 2: Enable archiving of redo log files
To back up the Oracle Database while it is open or to be able to perform complete or point-in-time media recovery, you must enable the archiving of redo log files. To do so, you start the Oracle Database in **`ARCHIVELOG`** mode.

In this task, you enable archiving of the redo log files using the following steps.

1. Use the following command to determine whether your Oracle Database is in **`ARCHIVELOG`** mode. In the following output, you can see that the database log mode is in `**No Archive Mode**`.
    ```
    SQL> <copy>archive log list;</copy>
    ```
    Output:
    ```
    Database log mode              No Archive Mode
    Automatic archival             Disabled
    Archive destination            USE_DB_RECOVERY_FILE_DEST
    Oldest online log sequence     1
    Current log sequence           3
    ```

2. Exit the SQL\*Plus prompt.
    ```
    SQL> <copy>exit;</copy>
    ```

3. Start the RMAN prompt.
    ```
    $ <copy>./rman</copy>
    ```
    Output:
    ```
    Recovery Manager: Release 21.0.0.0.0 - Production on Thu Dec 16 07:32:10 2021
    Version 21.3.0.0.0

    Copyright (c) 1982, 2021, Oracle and/or its affiliates.  All rights reserved.
    ```

4. Use the following command to connect to the target Oracle Database.
    ```
    RMAN> <copy>connect target;</copy>
    ```
    Output:
    ```
    connected to target database: CDB1 (DBID=1016703368)
    ```

5. To enable archiving, you must mount the Oracle Database but not open it. Use the following command to shut down the Oracle Database instance.
    ```
    RMAN> <copy>shutdown immediate;</copy>
    ```
    Output:
    ```
    database closed
    database dismounted
    Oracle instance shut down
    ```

6. Use the following command to start the Oracle Database instance and mount the Oracle Database.
    ```
    RMAN> <copy>startup mount;</copy>
    ```
    Output:
    ```
    connected to target database (not started)
    Oracle instance started
    database mounted

    Total System Global Area    4647288568 bytes

    Fixed Size                     9694968 bytes
    Variable Size                855638016 bytes
    Database Buffers            3774873600 bytes
    Redo Buffers                   7081984 bytes
    ```

7. Oracle recommends that you always back up the Oracle Database before making any significant change to the Oracle Database. Use the following command to create a back up of the Oracle Database before you enable the **`ARCHIVELOG`** mode.
    ```
    RMAN> <copy>backup database;</copy>
    ```
    Output:
    ```
    Starting backup at 16-DEC-21
    allocated channel: ORA_DISK_1
    channel ORA_DISK_1: SID=4 device type=DISK
    channel ORA_DISK_1: starting full datafile backup set
    channel ORA_DISK_1: specifying datafile(s) in backup set
    input datafile file number=00001 name=/opt/oracle/oradata/CDB1/system01.dbf
    input datafile file number=00003 name=/opt/oracle/oradata/CDB1/sysaux01.dbf
    input datafile file number=00004 name=/opt/oracle/oradata/CDB1/undotbs01.dbf
    input datafile file number=00007 name=/opt/oracle/oradata/CDB1/users01.dbf
    channel ORA_DISK_1: starting piece 1 at 16-DEC-21
    channel ORA_DISK_1: finished piece 1 at 16-DEC-21
    piece handle=/opt/oracle/recovery_area/CDB1/backupset/2021_12_16/o1_mf_nnndf_TAG20211216T073341_jvotyom3_.bkp tag=TAG20211216T073341 comment=NONE
    channel ORA_DISK_1: backup set complete, elapsed time: 00:00:36
    channel ORA_DISK_1: starting full datafile backup set
    channel ORA_DISK_1: specifying datafile(s) in backup set
    input datafile file number=00010 name=/opt/oracle/oradata/CDB1/pdb1/sysaux01.dbf
    input datafile file number=00009 name=/opt/oracle/oradata/CDB1/pdb1/system01.dbf
    input datafile file number=00011 name=/opt/oracle/oradata/CDB1/pdb1/undotbs01.dbf
    input datafile file number=00012 name=/opt/oracle/oradata/CDB1/pdb1/users01.dbf
    channel ORA_DISK_1: starting piece 1 at 16-DEC-21
    channel ORA_DISK_1: finished piece 1 at 16-DEC-21
    piece handle=/opt/oracle/recovery_area/CDB1/D33E529B0AE432F7E053F5586864ED09/backupset/2021_12_16/o1_mf_nnndf_TAG20211216T073341_jvotzsb1_.bkp tag=TAG20211216T073341 comment=NONE
    channel ORA_DISK_1: backup set complete, elapsed time: 00:00:15
    channel ORA_DISK_1: starting full datafile backup set
    channel ORA_DISK_1: specifying datafile(s) in backup set
    input datafile file number=00006 name=/opt/oracle/oradata/CDB1/pdbseed/sysaux01.dbf
    input datafile file number=00005 name=/opt/oracle/oradata/CDB1/pdbseed/system01.dbf
    input datafile file number=00008 name=/opt/oracle/oradata/CDB1/pdbseed/undotbs01.dbf
    channel ORA_DISK_1: starting piece 1 at 16-DEC-21
    channel ORA_DISK_1: finished piece 1 at 16-DEC-21
    piece handle=/opt/oracle/recovery_area/CDB1/D33E36E4677625A6E053F55868649362/backupset/2021_12_16/o1_mf_nnndf_TAG20211216T073341_jvov08hj_.bkp tag=TAG20211216T073341 comment=NONE
    channel ORA_DISK_1: backup set complete, elapsed time: 00:00:15
    Finished backup at 16-DEC-21

    Starting Control File and SPFILE Autobackup at 16-DEC-21
    piece handle=/opt/oracle/recovery_area/CDB1/autobackup/2021_12_16/o1_mf_s_1091431963_jvov0qz6_.bkp comment=NONE
    Finished Control File and SPFILE Autobackup at 16-DEC-21
    ```

8. Use the following command to enable the **`ARCHIVELOG`** mode.
    ```
    RMAN> <copy>alter database archivelog;</copy>
    ```
    Output:
    ```
    Statement processed
    ```

9. Use the following command to open the Oracle Database.
    ```
    RMAN> <copy>alter database open;</copy>
    ```
    Output:
    ```
    Statement processed
    ```

10. Use the following command to back up the Oracle Database. As the Oracle Database is now in **`ARCHIVELOG`** mode, you can back up the Oracle Database while the Oracle Database is open.  
    ```
    RMAN> <copy>backup database plus archivelog;</copy>
    ```
    Output:
    ```
    Starting backup at 16-DEC-21
    current log archived
    using channel ORA_DISK_1
    channel ORA_DISK_1: starting archived log backup set
    channel ORA_DISK_1: specifying archived log(s) in backup set
    input archived log thread=1 sequence=3 RECID=1 STAMP=1091432138
    channel ORA_DISK_1: starting piece 1 at 16-DEC-21
    channel ORA_DISK_1: finished piece 1 at 16-DEC-21
    piece handle=/opt/oracle/recovery_area/CDB1/backupset/2021_12_16/o1_mf_annnn_TAG20211216T073538_jvov2bjk_.bkp tag=TAG20211216T073538 comment=NONE
    channel ORA_DISK_1: backup set complete, elapsed time: 00:00:01
    Finished backup at 16-DEC-21

    Starting backup at 16-DEC-21
    using channel ORA_DISK_1
    channel ORA_DISK_1: starting full datafile backup set
    channel ORA_DISK_1: specifying datafile(s) in backup set
    input datafile file number=00001 name=/opt/oracle/oradata/CDB1/system01.dbf
    input datafile file number=00003 name=/opt/oracle/oradata/CDB1/sysaux01.dbf
    input datafile file number=00004 name=/opt/oracle/oradata/CDB1/undotbs01.dbf
    input datafile file number=00007 name=/opt/oracle/oradata/CDB1/users01.dbf
    channel ORA_DISK_1: starting piece 1 at 16-DEC-21
    channel ORA_DISK_1: finished piece 1 at 16-DEC-21
    piece handle=/opt/oracle/recovery_area/CDB1/backupset/2021_12_16/o1_mf_nnndf_TAG20211216T073539_jvov2d0t_.bkp tag=TAG20211216T073539 comment=NONE
    channel ORA_DISK_1: backup set complete, elapsed time: 00:00:36
    channel ORA_DISK_1: starting full datafile backup set
    channel ORA_DISK_1: specifying datafile(s) in backup set
    input datafile file number=00010 name=/opt/oracle/oradata/CDB1/pdb1/sysaux01.dbf
    input datafile file number=00009 name=/opt/oracle/oradata/CDB1/pdb1/system01.dbf
    input datafile file number=00011 name=/opt/oracle/oradata/CDB1/pdb1/undotbs01.dbf
    input datafile file number=00012 name=/opt/oracle/oradata/CDB1/pdb1/users01.dbf
    channel ORA_DISK_1: starting piece 1 at 16-DEC-21
    channel ORA_DISK_1: finished piece 1 at 16-DEC-21
    piece handle=/opt/oracle/recovery_area/CDB1/D33E529B0AE432F7E053F5586864ED09/backupset/2021_12_16/o1_mf_nnndf_TAG20211216T073539_jvov3h8y_.bkp tag=TAG20211216T073539 comment=NONE
    channel ORA_DISK_1: backup set complete, elapsed time: 00:00:15
    channel ORA_DISK_1: starting full datafile backup set
    channel ORA_DISK_1: specifying datafile(s) in backup set
    input datafile file number=00006 name=/opt/oracle/oradata/CDB1/pdbseed/sysaux01.dbf
    input datafile file number=00005 name=/opt/oracle/oradata/CDB1/pdbseed/system01.dbf
    input datafile file number=00008 name=/opt/oracle/oradata/CDB1/pdbseed/undotbs01.dbf
    channel ORA_DISK_1: starting piece 1 at 16-DEC-21
    channel ORA_DISK_1: finished piece 1 at 16-DEC-21
    piece handle=/opt/oracle/recovery_area/CDB1/D33E36E4677625A6E053F55868649362/backupset/2021_12_16/o1_mf_nnndf_TAG20211216T073539_jvov3yhx_.bkp tag=TAG20211216T073539 comment=NONE
    channel ORA_DISK_1: backup set complete, elapsed time: 00:00:15
    Finished backup at 16-DEC-21

    Starting backup at 16-DEC-21
    current log archived
    using channel ORA_DISK_1
    channel ORA_DISK_1: starting archived log backup set
    channel ORA_DISK_1: specifying archived log(s) in backup set
    input archived log thread=1 sequence=4 RECID=2 STAMP=1091432205
    channel ORA_DISK_1: starting piece 1 at 16-DEC-21
    channel ORA_DISK_1: finished piece 1 at 16-DEC-21
    piece handle=/opt/oracle/recovery_area/CDB1/backupset/2021_12_16/o1_mf_annnn_TAG20211216T073645_jvov4g0y_.bkp tag=TAG20211216T073645 comment=NONE
    channel ORA_DISK_1: backup set complete, elapsed time: 00:00:01
    Finished backup at 16-DEC-21

    Starting Control File and SPFILE Autobackup at 16-DEC-21
    piece handle=/opt/oracle/recovery_area/CDB1/autobackup/2021_12_16/o1_mf_s_1091432207_jvov4hdv_.bkp comment=NONE
    Finished Control File and SPFILE Autobackup at 16-DEC-21
    ```


## Task 3: Enable flashback database
You can revert the whole Oracle Database to a prior point in time using the following ways: either revert the whole Oracle Database to a prior point in time by restoring a backup and performing a point-in-time recovery or enable flashback database. When you enable flashback database, the Oracle Database generates flashback logs in the fast recovery area. These logs are used to flashback the Oracle Database to a specified time. The Oracle Database automatically creates, deletes, and resizes flashback logs.

In this task, you enable Flashback Database using the following steps.

1. Use the following command to enable flashback database for the whole Oracle Database.
    ```
    RMAN> <copy>alter database flashback on;</copy>
    ```
    Output:
    ```
    Statement processed
    ```

2. Exit the RMAN prompt.
    ```
    RMAN> <copy>exit;</copy>
    ```

You may now **proceed to the next lab**.


## Acknowledgements
- **Author**: Suresh Mohan, Database User Assistance Development Team
- **Contributors**: Suresh Rajan, Manish Garodia, Subhash Chandra, Ramya P
- **Last Updated By & Date**: Suresh Mohan, June 2022
