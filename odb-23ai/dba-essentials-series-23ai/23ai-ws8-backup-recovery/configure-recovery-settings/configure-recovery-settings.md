# Configure recovery settings

## Introduction
This lab shows you how to configure the Oracle Database for several recovery settings.

Estimated Time: 20 minutes

### Objectives
-   Configure the Fast Recovery Area
-   Enable archiving of redo log files
-   Enable Flashback Database

### Prerequisites
This lab assumes you have:
-   An Oracle Cloud account
-   Completed all previous labs successfully


## Task 1: Configure the fast recovery area
The fast recovery area is an Oracle-managed directory on a file system or disk group on Oracle Automatic Storage Management (Oracle ASM) that provides a centralized storage location for backup and recovery files. Oracle creates archived logs and flashback logs in the fast recovery area. Oracle automatically manages the fast recovery area, deleting files that are no longer needed.

RMAN can store its backup sets and image copies in the fast recovery area and use them when restoring files during media recovery. If the fast recovery area is configured, RMAN automatically backs up to the fast recovery area when you issue the RMAN `backup` command without specifying a backup destination.

1. Start the SQL\*Plus prompt and connect as the `sysdba` user.
    ```
    $ <copy>./sqlplus / as sysdba</copy>
    ```

2. View the settings for all initialization parameters containing "recovery" in the name.
    ```
    SQL> <copy>show parameter recovery;</copy>
    ```
    Output:
    ```
    NAME                             TYPE           VALUE
    -------------------------------- -------------- -----------
    db_recovery_auto_rekey           string         ON
    db_recovery_file_dest            string
    db_recovery_file_dest_size       big integer    0
    recovery_parallelism             integer        0
    remote_recovery_file_dest        string
    transaction_recovery             string         ENABLED
    ```

    >**Note:** The `db_recovery_file_dest` parameter sets the location of the fast recovery area. Oracle recommends placing the fast recovery area on a separate storage device from the Oracle Database files. The `db_recovery_file_dest_size` parameter shows the size of your fast recovery area. The size of your fast recovery area may differ from what is shown in this example. Generally, the default size present for the fast recovery area might not be sufficient for your files.

3. Set the fast recovery area size to a larger size to store the Oracle Database files sufficiently. For this lab, it is set to `50GB`.
    ```
    SQL> <copy>alter system set db_recovery_file_dest_size=50G;</copy>
    ```

    Output:
    ```
    System altered.
    ```

4. Set the recovery file destination location in the `db_recovery_file_dest` parameter. For this lab, it is set to `/opt/oracle/recovery_area`.
    ```
    SQL> <copy>alter system set db_recovery_file_dest="/opt/oracle/recovery_area";</copy>
    ```

    Output:
    ```
    System altered.
    ```

5. View the altered settings again to confirm the changes. You can see that the `db_recovery_file_dest_size` and `db_recovery_file_dest parameters` are set.
    ```
    SQL> <copy>show parameter recovery;</copy>
    ```

    Output:
    ```
    NAME                             TYPE           VALUE
    -------------------------------- -------------- -----------
    db_recovery_auto_rekey           string         ON
    db_recovery_file_dest            string         /opt/oracle/recovery_area
    db_recovery_file_dest_size       big integer    50G
    recovery_parallelism             integer        0
    remote_recovery_file_dest        string
    transaction_recovery             string         ENABLED
    ```



## Task 2: Enable archiving of redo log files
You must enable the archiving of redo log files to back up the Oracle Database while it is open or perform complete or point-in-time media recovery. To do so, you start the Oracle Database in `ARCHIVELOG` mode.

1. Determine whether your Oracle Database is in `ARCHIVELOG` mode. In the following output, you can see that the database log mode is in `No Archive Mode`.
    ```
    SQL> <copy>archive log list;</copy>
    ```
    Output:
    ```
    Database log mode               No Archive Mode
    Automatic archival              Disabled
    Archive destination             USE_DB_RECOVERY_FILE_DEST
    Oldest online log sequence      304
    Current log sequence            303
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
    Recovery Manager: Release 23.0.0.0.0 - Production on Thu Oct 3 13:25:05 2024
    Version 23.4.0.24.05
    
    Copyright (c) 1982, 2024, Oracle and/or its affiliates.  All rights reserved.
    ```

4. Connect to the target Oracle Database.
    ```
    RMAN> <copy>connect target;</copy>
    ```
    Output:
    ```
    connected to target database: CDB1 (DBID=1701812036)
    ```

5.  Shut down the Oracle Database instance.
    ```
    RMAN> <copy>shutdown immediate;</copy>
    ```
    Output:
    ```
    using target database control file instead of recovery catalog
    database closed
    database dismounted
    Oracle instance shut down
    ```

6. Start and mount the Oracle Database instance. To enable archiving, you must mount the Oracle Database but not open it.
    ```
    RMAN> <copy>startup mount;</copy>
    ```
    Output:
    ```
    connected to target database (not started)
    Oracle instance started
    database mounted
    
    Total System Global Area   10013446704 bytes
    
    Fixed Size                     5370416 bytes
    Variable Size               2181038080 bytes
    Database Buffers            7818182656 bytes
    Redo Buffers                   8855552 bytes
    ```

7. Create a backup of the Oracle Database before you enable the `ARCHIVELOG` mode. Oracle recommends that you always back up the Oracle Database before making any significant changes to it.
    ```
    RMAN> <copy>backup database;</copy>
    ```
    Output:
    ```
    Starting backup at 03-OCT-24
    allocated channel: ORA_DISK_1
    channel ORA_DISK_1: SID=144 device type=DISK
    channel ORA_DISK_1: starting full datafile backup set
    channel ORA_DISK_1: specifying datafile(s) in backup set
    input datafile file number=00003 name=/opt/oracle/oradata/CDB1/sysaux01.dbf
    input datafile file number=00001 name=/opt/oracle/oradata/CDB1/system01.dbf
    input datafile file number=00011 name=/opt/oracle/oradata/CDB1/undotbs01.dbf
    input datafile file number=00007 name=/opt/oracle/oradata/CDB1/users01.dbf
    channel ORA_DISK_1: starting piece 1 at 03-OCT-24
    channel ORA_DISK_1: finished piece 1 at 03-OCT-24
    piece handle=/opt/oracle/recovery_area/CDB1/backupset/2024_10_03/o1_mf_nnndf_TAG20241003T132656_mhx6x38g_.bkp tag=TAG20241003T132656 comment=NONE
    channel ORA_DISK_1: backup set complete, elapsed time: 00:01:16
    channel ORA_DISK_1: starting full datafile backup set
    channel ORA_DISK_1: specifying datafile(s) in backup set
    input datafile file number=00013 name=/opt/oracle/oradata/CDB1/PDB1/sysaux01.dbf
    input datafile file number=00012 name=/opt/oracle/oradata/CDB1/PDB1/system01.dbf
    input datafile file number=00014 name=/opt/oracle/oradata/CDB1/PDB1/undotbs01.dbf
    input datafile file number=00016 name=/opt/oracle/product/23.4.0/dbhome_1/dbs/octs.dbf
    input datafile file number=00015 name=/opt/oracle/oradata/CDB1/PDB1/users01.dbf
    channel ORA_DISK_1: starting piece 1 at 03-OCT-24
    channel ORA_DISK_1: finished piece 1 at 03-OCT-24
    piece handle=/opt/oracle/recovery_area/CDB1/1CF500B83D440585E0634B0E4664AA19/backupset/2024_10_03/o1_mf_nnndf_TAG20241003T132656_mhx6zh2f_.bkp tag=TAG20241003T132656 comment=NONE
    channel ORA_DISK_1: backup set complete, elapsed time: 00:00:25
    channel ORA_DISK_1: starting full datafile backup set
    channel ORA_DISK_1: specifying datafile(s) in backup set
    input datafile file number=00004 name=/opt/oracle/oradata/CDB1/pdbseed/sysaux01.dbf
    input datafile file number=00002 name=/opt/oracle/oradata/CDB1/pdbseed/system01.dbf
    input datafile file number=00009 name=/opt/oracle/oradata/CDB1/pdbseed/undotbs01.dbf
    channel ORA_DISK_1: starting piece 1 at 03-OCT-24
    channel ORA_DISK_1: finished piece 1 at 03-OCT-24
    piece handle=/opt/oracle/recovery_area/CDB1/16DBED12D9B6BD08E0631FC45E640B06/backupset/2024_10_03/o1_mf_nnndf_TAG20241003T132656_mhx7088w_.bkp tag=TAG20241003T132656 comment=NONE
    channel ORA_DISK_1: backup set complete, elapsed time: 00:00:07
    Finished backup at 03-OCT-24
    
    Starting Control File and SPFILE Autobackup at 03-OCT-24
    piece handle=/opt/oracle/recovery_area/CDB1/autobackup/2024_10_03/o1_mf_s_1181395543_mhx70hmj_.bkp comment=NONE
    Finished Control File and SPFILE Autobackup at 03-OCT-24
    ```

8. Enable the `ARCHIVELOG` mode.
    ```
    RMAN> <copy>alter database archivelog;</copy>
    ```
    Output:
    ```
    Statement processed
    ```

9. Open the Oracle Database.
    ```
    RMAN> <copy>alter database open;</copy>
    ```
    Output:
    ```
    Statement processed
    ```

10. Back up the Oracle Database. As the Oracle Database is now in `ARCHIVELOG` mode, you can back up the Oracle Database while it is open.  
    ```
    RMAN> <copy>backup database plus archivelog;</copy>
    ```
    Output:
    ```
    Starting backup at 03-OCT-24
    current log archived
    using channel ORA_DISK_1
    channel ORA_DISK_1: starting archived log backup set
    channel ORA_DISK_1: specifying archived log(s) in backup set
    input archived log thread=1 sequence=304 RECID=1 STAMP=1181395789
    channel ORA_DISK_1: starting piece 1 at 03-OCT-24
    channel ORA_DISK_1: finished piece 1 at 03-OCT-24
    piece handle=/opt/oracle/recovery_area/CDB1/backupset/2024_10_03/o1_mf_annnn_TAG20241003T132949_mhx72fr0_.bkp tag=TAG20241003T132949 comment=NONE
    channel ORA_DISK_1: backup set complete, elapsed time: 00:00:01
    Finished backup at 03-OCT-24
    
    Starting backup at 03-OCT-24
    using channel ORA_DISK_1
    channel ORA_DISK_1: starting full datafile backup set
    channel ORA_DISK_1: specifying datafile(s) in backup set
    input datafile file number=00003 name=/opt/oracle/oradata/CDB1/sysaux01.dbf
    input datafile file number=00001 name=/opt/oracle/oradata/CDB1/system01.dbf
    input datafile file number=00011 name=/opt/oracle/oradata/CDB1/undotbs01.dbf
    input datafile file number=00007 name=/opt/oracle/oradata/CDB1/users01.dbf
    channel ORA_DISK_1: starting piece 1 at 03-OCT-24
    channel ORA_DISK_1: finished piece 1 at 03-OCT-24
    piece handle=/opt/oracle/recovery_area/CDB1/backupset/2024_10_03/o1_mf_nnndf_TAG20241003T132951_mhx72jpg_.bkp tag=TAG20241003T132951 comment=NONE
    channel ORA_DISK_1: backup set complete, elapsed time: 00:00:45
    channel ORA_DISK_1: starting full datafile backup set
    channel ORA_DISK_1: specifying datafile(s) in backup set
    input datafile file number=00013 name=/opt/oracle/oradata/CDB1/PDB1/sysaux01.dbf
    input datafile file number=00012 name=/opt/oracle/oradata/CDB1/PDB1/system01.dbf
    input datafile file number=00014 name=/opt/oracle/oradata/CDB1/PDB1/undotbs01.dbf
    input datafile file number=00016 name=/opt/oracle/product/23.4.0/dbhome_1/dbs/octs.dbf
    input datafile file number=00015 name=/opt/oracle/oradata/CDB1/PDB1/users01.dbf
    channel ORA_DISK_1: starting piece 1 at 03-OCT-24
    channel ORA_DISK_1: finished piece 1 at 03-OCT-24
    piece handle=/opt/oracle/recovery_area/CDB1/1CF500B83D440585E0634B0E4664AA19/backupset/2024_10_03/o1_mf_nnndf_TAG20241003T132951_mhx73xwo_.bkp tag=TAG20241003T132951 comment=NONE
    channel ORA_DISK_1: backup set complete, elapsed time: 00:00:25
    channel ORA_DISK_1: starting full datafile backup set
    channel ORA_DISK_1: specifying datafile(s) in backup set
    input datafile file number=00004 name=/opt/oracle/oradata/CDB1/pdbseed/sysaux01.dbf
    input datafile file number=00002 name=/opt/oracle/oradata/CDB1/pdbseed/system01.dbf
    input datafile file number=00009 name=/opt/oracle/oradata/CDB1/pdbseed/undotbs01.dbf
    channel ORA_DISK_1: starting piece 1 at 03-OCT-24
    channel ORA_DISK_1: finished piece 1 at 03-OCT-24
    piece handle=/opt/oracle/recovery_area/CDB1/16DBED12D9B6BD08E0631FC45E640B06/backupset/2024_10_03/o1_mf_nnndf_TAG20241003T132951_mhx74q4h_.bkp tag=TAG20241003T132951 comment=NONE
    channel ORA_DISK_1: backup set complete, elapsed time: 00:00:07
    Finished backup at 03-OCT-24
    
    Starting backup at 03-OCT-24
    current log archived
    using channel ORA_DISK_1
    channel ORA_DISK_1: starting archived log backup set
    channel ORA_DISK_1: specifying archived log(s) in backup set
    input archived log thread=1 sequence=305 RECID=2 STAMP=1181395870
    channel ORA_DISK_1: starting piece 1 at 03-OCT-24
    channel ORA_DISK_1: finished piece 1 at 03-OCT-24
    piece handle=/opt/oracle/recovery_area/CDB1/backupset/2024_10_03/o1_mf_annnn_TAG20241003T133110_mhx74yky_.bkp tag=TAG20241003T133110 comment=NONE
    channel ORA_DISK_1: backup set complete, elapsed time: 00:00:01
    Finished backup at 03-OCT-24
    
    Starting Control File and SPFILE Autobackup at 03-OCT-24
    piece handle=/opt/oracle/recovery_area/CDB1/autobackup/2024_10_03/o1_mf_s_1181395871_mhx74zx1_.bkp comment=NONE
    Finished Control File and SPFILE Autobackup at 03-OCT-24
    ```


## Task 3: Enable flashback database
You can revert the whole Oracle Database to a prior point in time using the following methods: either revert the whole Oracle Database to a prior point in time by restoring a backup and performing a point-in-time recovery, or enable flashback database. When you enable flashback database, the Oracle Database generates flashback logs in the fast recovery area. These logs are used to flashback the Oracle Database to a specified time. The Oracle Database automatically creates, deletes, and resizes flashback logs.

1. Enable flashback database for the whole Oracle Database.
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
- **Last Updated By & Date**: Suresh Mohan, October 2024
