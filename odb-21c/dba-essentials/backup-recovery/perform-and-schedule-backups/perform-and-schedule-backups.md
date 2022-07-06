# Perform and schedule backups

## Introduction
This lab shows you how to perform a whole backup of your Oracle Database and then perform a complete recovery with the files from a whole backup using Recovery Manager (RMAN). A whole backup includes the control file, server parameter file, all data files, and archived redo log files.

Estimated Time: 20 minutes

### Objectives
- Perform a whole Oracle Database backup
- Display backup information stored in the RMAN repository
- Validate backups

### Prerequisites
- A Free Tier, Paid or LiveLabs Oracle Cloud account.
- You have completed:
    - Lab: Prepare setup (_Free-Tier_ and _Paid Tenants_ only)
    - Lab: Initialize environment
    - Lab: Configure recovery settings
    - Lab: Configure backup settings


## Task 1: Perform a whole Oracle database backup
In this task, you back up the whole Oracle Database using the following steps.

1. Start the RMAN prompt.  
    ```
    $ <copy>./rman</copy>
    ```
    Output:
    ```
    Recovery Manager: Release 21.0.0.0.0 - Production on Thu Dec 16 07:53:57 2021
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

3. Use the following command to back up the Oracle Database files, including the archive redo log files.
    ```
    RMAN> <copy>backup database plus archivelog;</copy>
    ```
    Output:
    ```
    Starting backup at 16-DEC-21
    current log archived
    using target database control file instead of recovery catalog
    allocated channel: ORA_DISK_1
    channel ORA_DISK_1: SID=53 device type=DISK
    skipping archived logs of thread 1 from sequence 3 to 4; already backed up
    channel ORA_DISK_1: starting archived log backup set
    channel ORA_DISK_1: specifying archived log(s) in backup set
    input archived log thread=1 sequence=5 RECID=3 STAMP=1091433259
    channel ORA_DISK_1: starting piece 1 at 16-DEC-21
    channel ORA_DISK_1: finished piece 1 at 16-DEC-21
    piece handle=/opt/oracle/recovery_area/CDB1/backupset/2021_12_16/o1_mf_annnn_TAG20211216T075420_jvow5d6r_.bkp tag=TAG20211216T075420 comment=NONE
    channel ORA_DISK_1: backup set complete, elapsed time: 00:00:01
    Finished backup at 16-DEC-21

    Starting backup at 16-DEC-21
    using channel ORA_DISK_1
    skipping datafile 5; already backed up 2 time(s)
    skipping datafile 6; already backed up 2 time(s)
    skipping datafile 8; already backed up 2 time(s)
    channel ORA_DISK_1: starting full datafile backup set
    channel ORA_DISK_1: specifying datafile(s) in backup set
    input datafile file number=00001 name=/opt/oracle/oradata/CDB1/system01.dbf
    input datafile file number=00003 name=/opt/oracle/oradata/CDB1/sysaux01.dbf
    input datafile file number=00004 name=/opt/oracle/oradata/CDB1/undotbs01.dbf
    input datafile file number=00007 name=/opt/oracle/oradata/CDB1/users01.dbf
    channel ORA_DISK_1: starting piece 1 at 16-DEC-21
    channel ORA_DISK_1: finished piece 1 at 16-DEC-21
    piece handle=/opt/oracle/recovery_area/CDB1/backupset/2021_12_16/o1_mf_nnndf_TAG20211216T075421_jvow5fos_.bkp tag=TAG20211216T075421 comment=NONE
    channel ORA_DISK_1: backup set complete, elapsed time: 00:00:35
    channel ORA_DISK_1: starting full datafile backup set
    channel ORA_DISK_1: specifying datafile(s) in backup set
    input datafile file number=00010 name=/opt/oracle/oradata/CDB1/pdb1/sysaux01.dbf
    input datafile file number=00009 name=/opt/oracle/oradata/CDB1/pdb1/system01.dbf
    input datafile file number=00011 name=/opt/oracle/oradata/CDB1/pdb1/undotbs01.dbf
    input datafile file number=00013 name=/opt/oracle/homes/OraDB21Home/dbs/octs.dbf
    input datafile file number=00012 name=/opt/oracle/oradata/CDB1/pdb1/users01.dbf
    channel ORA_DISK_1: starting piece 1 at 16-DEC-21
    channel ORA_DISK_1: finished piece 1 at 16-DEC-21
    piece handle=/opt/oracle/recovery_area/CDB1/D33E529B0AE432F7E053F5586864ED09/backupset/2021_12_16/o1_mf_nnndf_TAG20211216T075421_jvow6k4f_.bkp tag=TAG20211216T075421 comment=NONE
    channel ORA_DISK_1: backup set complete, elapsed time: 00:00:16
    Finished backup at 16-DEC-21

    Starting backup at 16-DEC-21
    current log archived
    using channel ORA_DISK_1
    channel ORA_DISK_1: starting archived log backup set
    channel ORA_DISK_1: specifying archived log(s) in backup set
    input archived log thread=1 sequence=6 RECID=4 STAMP=1091433312
    channel ORA_DISK_1: starting piece 1 at 16-DEC-21
    channel ORA_DISK_1: finished piece 1 at 16-DEC-21
    piece handle=/opt/oracle/recovery_area/CDB1/backupset/2021_12_16/o1_mf_annnn_TAG20211216T075512_jvow70h6_.bkp tag=TAG20211216T075512 comment=NONE
    channel ORA_DISK_1: backup set complete, elapsed time: 00:00:01
    Finished backup at 16-DEC-21

    Starting Control File and SPFILE Autobackup at 16-DEC-21
    piece handle=/opt/oracle/recovery_area/CDB1/autobackup/2021_12_16/o1_mf_s_1091433313_jvow71vz_.bkp comment=NONE
    Finished Control File and SPFILE Autobackup at 16-DEC-21
    ```


## Task 2: Display backup information stored in the RMAN repository
Use the `LIST` command to view information about backups stored in the RMAN repository. The information includes backups of data files, individual tablespaces, archived redo log files, and control files. You can also use this command to display information about expired and obsolete backups.

In this task, you display backup information stored in the RMAN repository using the following steps.

1. Use the following command to display a summary of all the backups, both backup sets, and image copies.
    ```
    RMAN> <copy>list backup summary;</copy>
    ```
    Output:
    ```
    List of Backups
    ===============
    Key     TY LV S Device Type Completion Time #Pieces #Copies Compressed Tag
    ------- -- -- - ----------- --------------- ------- ------- ---------- ---
    1       B  F  A DISK        16-DEC-21       1       1       NO         TAG20211216T073341
    2       B  F  A DISK        16-DEC-21       1       1       NO         TAG20211216T073341
    3       B  F  A DISK        16-DEC-21       1       1       NO         TAG20211216T073341
    4       B  F  A DISK        16-DEC-21       1       1       NO         TAG20211216T073447
    5       B  A  A DISK        16-DEC-21       1       1       NO         TAG20211216T073538
    6       B  F  A DISK        16-DEC-21       1       1       NO         TAG20211216T073539
    7       B  F  A DISK        16-DEC-21       1       1       NO         TAG20211216T073539
    8       B  F  A DISK        16-DEC-21       1       1       NO         TAG20211216T073539
    9       B  A  A DISK        16-DEC-21       1       1       NO         TAG20211216T073645
    10      B  F  A DISK        16-DEC-21       1       1       NO         TAG20211216T073647
    11      B  F  A DISK        16-DEC-21       1       1       NO         TAG20211216T074321
    12      B  A  A DISK        16-DEC-21       1       1       NO         TAG20211216T075420
    13      B  F  A DISK        16-DEC-21       1       1       NO         TAG20211216T075421
    14      B  F  A DISK        16-DEC-21       1       1       NO         TAG20211216T075421
    15      B  A  A DISK        16-DEC-21       1       1       NO         TAG20211216T075512
    16      B  F  A DISK        16-DEC-21       1       1       NO         TAG20211216T075513
    ```

2. Use the following command with the `datafile` parameter to display the specified backups, both backup sets, and image copies.
    ```
    RMAN> <copy>list backup of datafile 3;</copy>
    ```
    Output:
    ```
    List of Backup Sets
    ===================


    BS Key  Type LV Size       Device Type Elapsed Time Completion Time
    ------- ---- -- ---------- ----------- ------------ ---------------
    1       Full    1.58G      DISK        00:00:24     16-DEC-21      
            BP Key: 1   Status: AVAILABLE  Compressed: NO  Tag: TAG20211216T073341
            Piece Name: /opt/oracle/recovery_area/CDB1/backupset/2021_12_16/o1_mf_nnndf_TAG20211216T073341_jvotyom3_.bkp
      List of Datafiles in backup set 1
      File LV Type Ckp SCN    Ckp Time  Abs Fuz SCN Sparse Name
      ---- -- ---- ---------- --------- ----------- ------ ----
      3       Full 2694202    16-DEC-21              NO    /opt/oracle/oradata/CDB1/sysaux01.dbf

    BS Key  Type LV Size       Device Type Elapsed Time Completion Time
    ------- ---- -- ---------- ----------- ------------ ---------------
    6       Full    1.58G      DISK        00:00:24     16-DEC-21      
            BP Key: 6   Status: AVAILABLE  Compressed: NO  Tag: TAG20211216T073539
            Piece Name: /opt/oracle/recovery_area/CDB1/backupset/2021_12_16/o1_mf_nnndf_TAG20211216T073539_jvov2d0t_.bkp
      List of Datafiles in backup set 6
      File LV Type Ckp SCN    Ckp Time  Abs Fuz SCN Sparse Name
      ---- -- ---- ---------- --------- ----------- ------ ----
      3       Full 2695538    16-DEC-21              NO    /opt/oracle/oradata/CDB1/sysaux01.dbf

    BS Key  Type LV Size       Device Type Elapsed Time Completion Time
    ------- ---- -- ---------- ----------- ------------ ---------------
    13      Full    1.58G      DISK        00:00:23     16-DEC-21      
            BP Key: 13   Status: AVAILABLE  Compressed: NO  Tag: TAG20211216T075421
            Piece Name: /opt/oracle/recovery_area/CDB1/backupset/2021_12_16/o1_mf_nnndf_TAG20211216T075421_jvow5fos_.bkp
      List of Datafiles in backup set 13
      File LV Type Ckp SCN    Ckp Time  Abs Fuz SCN Sparse Name
      ---- -- ---- ---------- --------- ----------- ------ ----
      3       Full 2697986    16-DEC-21              NO    /opt/oracle/oradata/CDB1/sysaux01.dbf
    ```


## Task 3: Validate backups
Validating specific backups checks whether these backups exist and can be restored. It does not test whether the set of available backups meet your recoverability goals. For example, image copies of data files for several tablespaces from your Oracle Database may exist, each of which can be validated. If there are some tablespaces for which no valid backups exist, however, then you cannot restore and recover the Oracle Database.

In this task, you validate backups using the following steps.

1. Use the following command to validate the backup for a specific data file and to determine whether the backup exists.
    ```
    RMAN> <copy>validate datafile 3;</copy>
    ```
    Output:
    ```
    Starting validate at 16-DEC-21
    using channel ORA_DISK_1
    channel ORA_DISK_1: starting validation of datafile
    channel ORA_DISK_1: specifying datafile(s) for validation
    input datafile file number=00003 name=/opt/oracle/oradata/CDB1/sysaux01.dbf
    channel ORA_DISK_1: validation complete, elapsed time: 00:00:07
    List of Datafiles
    =================
    File Status Marked Corrupt Empty Blocks Blocks Examined High SCN
    ---- ------ -------------- ------------ --------------- ----------
    3    OK     0              24517        75529           2698233   
      File Name: /opt/oracle/oradata/CDB1/sysaux01.dbf
      Block Type Blocks Failing Blocks Processed
      ---------- -------------- ----------------
      Data       0              5633            
      Index      0              3196            
      Other      0              42174           

    Finished validate at 16-DEC-21
    ```

2. Use the following command to restore the 'users' tablespace. It will first validate if you can restore the data files for a specified tablespace and then restores the tablespace.  
    ```
    RMAN> <copy>restore tablespace users validate;</copy>
    ```
    Output:
    ```
    Starting restore at 16-DEC-21
    using channel ORA_DISK_1

    channel ORA_DISK_1: starting validation of datafile backup set
    channel ORA_DISK_1: reading from backup piece /opt/oracle/recovery_area/CDB1/backupset/2021_12_16/o1_mf_nnndf_TAG20211216T075421_jvow5fos_.bkp
    channel ORA_DISK_1: piece handle=/opt/oracle/recovery_area/CDB1/backupset/2021_12_16/o1_mf_nnndf_TAG20211216T075421_jvow5fos_.bkp tag=TAG20211216T075421
    channel ORA_DISK_1: restored backup piece 1
    channel ORA_DISK_1: validation complete, elapsed time: 00:00:15
    Finished restore at 16-DEC-21
    ```

3. Exit the RMAN prompt.
    ```
    RMAN> <copy>exit;</copy>
    ```

You may now **proceed to the next lab**.


## Acknowledgements
- **Author**: Suresh Mohan, Database User Assistance Development Team
- **Contributors**: Suresh Rajan, Manish Garodia, Subhash Chandra, Ramya P
- **Last Updated By & Date**: Suresh Mohan, May 2022
