# Perform backups

## Introduction
This lab shows you how to perform a whole backup of your Oracle Database and then perform a complete recovery with the files from a whole backup using RMAN. A whole backup includes the control file, server parameter file, all data files, and archived redo log files.

Estimated Time: 20 minutes

### Objectives
-   Perform a whole Oracle Database backup
-   Display backup information stored in the RMAN repository
-   Validate backups

### Prerequisites
This lab assumes you have:
-   An Oracle Cloud account
-   Completed all previous labs successfully


## Task 1: Perform a whole Oracle database backup

1. Start the RMAN prompt.  
    ```
    $ <copy>./rman</copy>
    ```
    Output:
    ```
    Recovery Manager: Release 23.0.0.0.0 - Production on Thu Oct 3 13:37:01 2024
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

3. Back up the Oracle Database files, including the archive redo log files.
    ```
    RMAN> <copy>backup database plus archivelog;</copy>
    ```
    Output:
    ```
    Starting backup at 03-OCT-24
    current log archived
    using target database control file instead of recovery catalog
    allocated channel: ORA_DISK_1
    channel ORA_DISK_1: SID=280 device type=DISK
    skipping archived logs of thread 1 from sequence 304 to 305; already backed up
    channel ORA_DISK_1: starting archived log backup set
    channel ORA_DISK_1: specifying archived log(s) in backup set
    input archived log thread=1 sequence=306 RECID=3 STAMP=1181396235
    channel ORA_DISK_1: starting piece 1 at 03-OCT-24
    channel ORA_DISK_1: finished piece 1 at 03-OCT-24
    piece handle=/opt/oracle/recovery_area/CDB1/backupset/2024_10_03/o1_mf_annnn_TAG20241003T133716_mhx7jdbw_.bkp tag=TAG20241003T133716 comment=NONE
    channel ORA_DISK_1: backup set complete, elapsed time: 00:00:01
    Finished backup at 03-OCT-24
    
    Starting backup at 03-OCT-24
    using channel ORA_DISK_1
    skipping datafile 2; already backed up 2 time(s)
    skipping datafile 4; already backed up 2 time(s)
    skipping datafile 9; already backed up 2 time(s)
    skipping datafile 12; already backed up 2 time(s)
    skipping datafile 13; already backed up 2 time(s)
    skipping datafile 14; already backed up 2 time(s)
    skipping datafile 15; already backed up 2 time(s)
    skipping datafile 16; already backed up 2 time(s)
    channel ORA_DISK_1: starting full datafile backup set
    channel ORA_DISK_1: specifying datafile(s) in backup set
    input datafile file number=00003 name=/opt/oracle/oradata/CDB1/sysaux01.dbf
    input datafile file number=00001 name=/opt/oracle/oradata/CDB1/system01.dbf
    input datafile file number=00011 name=/opt/oracle/oradata/CDB1/undotbs01.dbf
    input datafile file number=00007 name=/opt/oracle/oradata/CDB1/users01.dbf
    channel ORA_DISK_1: starting piece 1 at 03-OCT-24
    channel ORA_DISK_1: finished piece 1 at 03-OCT-24
    piece handle=/opt/oracle/recovery_area/CDB1/backupset/2024_10_03/o1_mf_nnndf_TAG20241003T133717_mhx7jg87_.bkp tag=TAG20241003T133717 comment=NONE
    channel ORA_DISK_1: backup set complete, elapsed time: 00:00:35
    Finished backup at 03-OCT-24
    
    Starting backup at 03-OCT-24
    current log archived
    using channel ORA_DISK_1
    channel ORA_DISK_1: starting archived log backup set
    channel ORA_DISK_1: specifying archived log(s) in backup set
    input archived log thread=1 sequence=307 RECID=4 STAMP=1181396273
    channel ORA_DISK_1: starting piece 1 at 03-OCT-24
    channel ORA_DISK_1: finished piece 1 at 03-OCT-24
    piece handle=/opt/oracle/recovery_area/CDB1/backupset/2024_10_03/o1_mf_annnn_TAG20241003T133753_mhx7kkoz_.bkp tag=TAG20241003T133753 comment=NONE
    channel ORA_DISK_1: backup set complete, elapsed time: 00:00:01
    Finished backup at 03-OCT-24
    
    Starting Control File and SPFILE Autobackup at 03-OCT-24
    piece handle=/opt/oracle/recovery_area/CDB1/autobackup/2024_10_03/o1_mf_s_1181396274_mhx7km17_.bkp comment=NONE
    Finished Control File and SPFILE Autobackup at 03-OCT-24
    ```


## Task 2: Display backup information stored in the RMAN repository
Use the `LIST` command to view information about backups stored in the RMAN repository. The information includes backups of data files, individual tablespaces, archived redo log files, and control files. You can also use this command to display information about expired and obsolete backups.

1. View the summary of all the backups, both backup sets and image copies.
    ```
    RMAN> <copy>list backup summary;</copy>
    ```
    Output:
    ```
    List of Backups
    ===============
    Key     TY LV S Device Type Completion Time #Pieces #Copies Compressed Tag
    ------- -- -- - ----------- --------------- ------- ------- ---------- ---
    1       B  F  A DISK        03-OCT-24       1       1       NO         TAG20241003T132656
    2       B  F  A DISK        03-OCT-24       1       1       NO         TAG20241003T132656
    3       B  F  A DISK        03-OCT-24       1       1       NO         TAG20241003T132656
    4       B  F  A DISK        03-OCT-24       1       1       NO         TAG20241003T132847
    5       B  A  A DISK        03-OCT-24       1       1       NO         TAG20241003T132949
    6       B  F  A DISK        03-OCT-24       1       1       NO         TAG20241003T132951
    7       B  F  A DISK        03-OCT-24       1       1       NO         TAG20241003T132951
    8       B  F  A DISK        03-OCT-24       1       1       NO         TAG20241003T132951
    9       B  A  A DISK        03-OCT-24       1       1       NO         TAG20241003T133110
    10      B  F  A DISK        03-OCT-24       1       1       NO         TAG20241003T133111
    11      B  A  A DISK        03-OCT-24       1       1       NO         TAG20241003T133716
    12      B  F  A DISK        03-OCT-24       1       1       NO         TAG20241003T133717
    13      B  A  A DISK        03-OCT-24       1       1       NO         TAG20241003T133753
    14      B  F  A DISK        03-OCT-24       1       1       NO         TAG20241003T133754
    ```

2. View the summary of a specific backup using the `datafile` parameter.
    ```
    RMAN> <copy>list backup of datafile 3;</copy>
    ```
    Output:
    ```
    List of Backup Sets
    ===================
    
    
    BS Key  Type LV Size       Device Type Elapsed Time Completion Time
    ------- ---- -- ---------- ----------- ------------ ---------------
    1       Full    2.40G      DISK        00:01:08     03-OCT-24     
            BP Key: 1   Status: AVAILABLE  Compressed: NO  Tag: TAG20241003T132656
            Piece Name: /opt/oracle/recovery_area/CDB1/backupset/2024_10_03/o1_mf_nnndf_TAG20241003T132656_mhx6x38g_.bkp
    List of Datafiles in backup set 1
    File LV Type Ckp SCN    Ckp Time  Abs Fuz SCN Sparse Name
    ---- -- ---- ---------- --------- ----------- ------ ----
    3       Full 21280192   03-OCT-24              NO    /opt/oracle/oradata/CDB1/sysaux01.dbf
    
    BS Key  Type LV Size       Device Type Elapsed Time Completion Time
    ------- ---- -- ---------- ----------- ------------ ---------------
    6       Full    2.40G      DISK        00:00:35     03-OCT-24     
            BP Key: 6   Status: AVAILABLE  Compressed: NO  Tag: TAG20241003T132951
            Piece Name: /opt/oracle/recovery_area/CDB1/backupset/2024_10_03/o1_mf_nnndf_TAG20241003T132951_mhx72jpg_.bkp
    List of Datafiles in backup set 6
    File LV Type Ckp SCN    Ckp Time  Abs Fuz SCN Sparse Name
    ---- -- ---- ---------- --------- ----------- ------ ----
    3       Full 21281313   03-OCT-24              NO    /opt/oracle/oradata/CDB1/sysaux01.dbf
    
    BS Key  Type LV Size       Device Type Elapsed Time Completion Time
    ------- ---- -- ---------- ----------- ------------ ---------------
    12      Full    2.40G      DISK        00:00:31     03-OCT-24     
            BP Key: 12   Status: AVAILABLE  Compressed: NO  Tag: TAG20241003T133717
            Piece Name: /opt/oracle/recovery_area/CDB1/backupset/2024_10_03/o1_mf_nnndf_TAG20241003T133717_mhx7jg87_.bkp
    List of Datafiles in backup set 12
    File LV Type Ckp SCN    Ckp Time  Abs Fuz SCN Sparse Name
    ---- -- ---- ---------- --------- ----------- ------ ----
    3       Full 21281717   03-OCT-24              NO    /opt/oracle/oradata/CDB1/sysaux01.dbf
    ```


## Task 3: Validate backups
Validating specific backups checks whether these backups exist and can be restored. It does not check whether the set of available backups meets your recoverability goals. For example, image copies of data files for several tablespaces from your Oracle Database may exist, each of which can be validated. If there are some tablespaces for which no valid backups exist, however, then you cannot restore and recover the Oracle Database.

1. Validate the backup for a specific data file and determine whether the backup exists..
    ```
    RMAN> <copy>validate datafile 3;</copy>
    ```
    Output:
    ```
    Starting validate at 03-OCT-24
    using channel ORA_DISK_1
    channel ORA_DISK_1: starting validation of datafile
    channel ORA_DISK_1: specifying datafile(s) for validation
    input datafile file number=00003 name=/opt/oracle/oradata/CDB1/sysaux01.dbf
    channel ORA_DISK_1: validation complete, elapsed time: 00:00:15
    List of Datafiles
    =================
    File Status Marked Corrupt Empty Blocks Blocks Examined High SCN
    ---- ------ -------------- ------------ --------------- ----------
    3    OK     0              28488        221449          21281827 
    File Name: /opt/oracle/oradata/CDB1/sysaux01.dbf
    Block Type Blocks Failing Blocks Processed
    ---------- -------------- ----------------
    Data       0              55782          
    Index      0              69123          
    Other      0              68047          
    
    Finished validate at 03-OCT-24
    ```

2. Restore the tablespace. The `restore` command will first validate if you can restore the data files for a specified tablespace and then restore the tablespace. The following command restores the `users` tablespace.
    ```
    RMAN> <copy>restore tablespace users validate;</copy>
    ```
    Output:
    ```
    Starting restore at 03-OCT-24
    using channel ORA_DISK_1
    
    channel ORA_DISK_1: starting validation of datafile backup set
    channel ORA_DISK_1: reading from backup piece /opt/oracle/recovery_area/CDB1/backupset/2024_10_03/o1_mf_nnndf_TAG20241003T133717_mhx7jg87_.bkp
    channel ORA_DISK_1: piece handle=/opt/oracle/recovery_area/CDB1/backupset/2024_10_03/o1_mf_nnndf_TAG20241003T133717_mhx7jg87_.bkp tag=TAG20241003T133717
    channel ORA_DISK_1: restored backup piece 1
    channel ORA_DISK_1: validation complete, elapsed time: 00:00:15
    Finished restore at 03-OCT-24
    ```

3. Exit the RMAN prompt.

    ```
    RMAN> <copy>exit;</copy>
    ```

You may now **proceed to the next lab**.


## Acknowledgements
- **Author**: Suresh Mohan, Database User Assistance Development Team
- **Contributors**: Suresh Rajan, Manish Garodia, Subhash Chandra, Ramya P
- **Last Updated By & Date**: Suresh Mohan, October 2024
