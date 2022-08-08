# Manage backups

## Introduction
This lab shows you how to manage backups after you create them.  

Estimated time: 20 minutes

### About managing backups
An essential part of a backup and recovery strategy is managing backups after creating them. Backup management includes deleting obsolete backups and performing periodic checks to ensure that backups are available and usable. In a multi-tenant environment, you can manage backups for the whole multi-tenant container database (CDB) or one or more pluggable databases (PDBs).

You manage backups by deleting obsolete backups and performing periodic checks to ensure that backups are available and usable.

### Objectives
- Display backup information
- Cross-check backups
- Delete expired backups
- Monitor fast recovery area space usage

### Prerequisites
- A Free Tier, Paid or LiveLabs Oracle Cloud account.
- You have completed:
    - Lab: Prepare setup (_Free-Tier_ and _Paid Tenants_ only)
    - Lab: Initialize environment
    - Lab: Configure recovery settings
    - Lab: Configure backup settings
    - Lab: Perform and schedule backups


## Task 1: Display backup information
Backup reports contain summary and detailed information about past backup jobs run by Recovery Manager (RMAN). The `v$rman_backup_job_details` view includes information on backup jobs run by RMAN. This view contains information such as the time taken for the backup, start and finish time, type of backup performed, and the backup job status.

In this task, you display backup information using the following steps.

1. Start the RMAN prompt.
    ```
    $ <copy>./rman</copy>
    ```
    Output:
    ```
    Recovery Manager: Release 21.0.0.0.0 - Production on Thu Dec 16 07:57:11 2021
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

3. Query the `v$rman_backup_job_details` view to display backup job history. You can see the status, start time, and end time of all the backups performed in the output.
    ```
    RMAN> <copy>select session_key, input_type, status, start_time, end_time, elapsed_seconds/3600 hrs from v$rman_backup_job_details;</copy>
    ```
    Output:
    ```
    SESSION_KEY INPUT_TYPE    STATUS                  START_TIM END_TIME         HRS
    ----------- ------------- ----------------------- --------- --------- ----------
              5 DB FULL       COMPLETED               16-DEC-21 16-DEC-21 .051666666
             13 DB FULL       COMPLETED               16-DEC-21 16-DEC-21       .015
    ```

    >**Note:** `SESSION_KEY` is the unique key for the RMAN session in which the backup job occurred.  


## Task 2: Cross-check backups
Cross-checking a backup synchronizes the physical reality of backups with their logical records in the RMAN repository. For example, if a backup on disk was deleted with an operating system command, then a cross-check detects this condition. After the cross-check, the RMAN repository correctly reflects the state of the backups.

Backups to disk are listed as available if they are still on disk in the location listed in the RMAN repository and if they have no corruption in the file header. Backups on tape are listed as available if they are still on tape. The file headers on tape are not checked for corruption. Backups that are missing or corrupt are listed as expired.

In this task, you cross-check backups using the following steps.

1. Use the following command to view a list of all backup sets to determine which backup you want to cross-check.
    ```
    RMAN> <copy>list backup summary;</copy>
    ```
    Output:
    ```
    using target database control file instead of recovery catalog

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

2. Use the following command to cross-check all backup sets.
    ```
    RMAN> <copy>crosscheck backup;</copy>
    ```
    Output:
    ```
    allocated channel: ORA_DISK_1
    channel ORA_DISK_1: SID=51 device type=DISK
    crosschecked backup piece: found to be 'AVAILABLE'
    backup piece handle=/opt/oracle/recovery_area/CDB1/backupset/2021_12_16/o1_mf_nnndf_TAG20211216T073341_jvotyom3_.bkp RECID=1 STAMP=1091432021
    crosschecked backup piece: found to be 'AVAILABLE'
    backup piece handle=/opt/oracle/recovery_area/CDB1/D33E529B0AE432F7E053F5586864ED09/backupset/2021_12_16/o1_mf_nnndf_TAG20211216T073341_jvotzsb1_.bkp RECID=2 STAMP=1091432057
    crosschecked backup piece: found to be 'AVAILABLE'
    backup piece handle=/opt/oracle/recovery_area/CDB1/D33E36E4677625A6E053F55868649362/backupset/2021_12_16/o1_mf_nnndf_TAG20211216T073341_jvov08hj_.bkp RECID=3 STAMP=1091432072
    crosschecked backup piece: found to be 'AVAILABLE'
    backup piece handle=/opt/oracle/recovery_area/CDB1/autobackup/2021_12_16/o1_mf_s_1091431963_jvov0qz6_.bkp RECID=4 STAMP=1091432087
    crosschecked backup piece: found to be 'AVAILABLE'
    backup piece handle=/opt/oracle/recovery_area/CDB1/backupset/2021_12_16/o1_mf_annnn_TAG20211216T073538_jvov2bjk_.bkp RECID=5 STAMP=1091432138
    crosschecked backup piece: found to be 'AVAILABLE'
    backup piece handle=/opt/oracle/recovery_area/CDB1/backupset/2021_12_16/o1_mf_nnndf_TAG20211216T073539_jvov2d0t_.bkp RECID=6 STAMP=1091432140
    crosschecked backup piece: found to be 'AVAILABLE'
    backup piece handle=/opt/oracle/recovery_area/CDB1/D33E529B0AE432F7E053F5586864ED09/backupset/2021_12_16/o1_mf_nnndf_TAG20211216T073539_jvov3h8y_.bkp RECID=7 STAMP=1091432175
    crosschecked backup piece: found to be 'AVAILABLE'
    backup piece handle=/opt/oracle/recovery_area/CDB1/D33E36E4677625A6E053F55868649362/backupset/2021_12_16/o1_mf_nnndf_TAG20211216T073539_jvov3yhx_.bkp RECID=8 STAMP=1091432190
    crosschecked backup piece: found to be 'AVAILABLE'
    backup piece handle=/opt/oracle/recovery_area/CDB1/backupset/2021_12_16/o1_mf_annnn_TAG20211216T073645_jvov4g0y_.bkp RECID=9 STAMP=1091432206
    crosschecked backup piece: found to be 'AVAILABLE'
    backup piece handle=/opt/oracle/recovery_area/CDB1/autobackup/2021_12_16/o1_mf_s_1091432207_jvov4hdv_.bkp RECID=10 STAMP=1091432207
    crosschecked backup piece: found to be 'AVAILABLE'
    backup piece handle=/opt/oracle/recovery_area/CDB1/autobackup/2021_12_16/o1_mf_s_1091432601_jvovjt72_.bkp RECID=11 STAMP=1091432602
    crosschecked backup piece: found to be 'AVAILABLE'
    backup piece handle=/opt/oracle/recovery_area/CDB1/backupset/2021_12_16/o1_mf_annnn_TAG20211216T075420_jvow5d6r_.bkp RECID=12 STAMP=1091433260
    crosschecked backup piece: found to be 'AVAILABLE'
    backup piece handle=/opt/oracle/recovery_area/CDB1/backupset/2021_12_16/o1_mf_nnndf_TAG20211216T075421_jvow5fos_.bkp RECID=13 STAMP=1091433261
    crosschecked backup piece: found to be 'AVAILABLE'
    backup piece handle=/opt/oracle/recovery_area/CDB1/D33E529B0AE432F7E053F5586864ED09/backupset/2021_12_16/o1_mf_nnndf_TAG20211216T075421_jvow6k4f_.bkp RECID=14 STAMP=1091433297
    crosschecked backup piece: found to be 'AVAILABLE'
    backup piece handle=/opt/oracle/recovery_area/CDB1/backupset/2021_12_16/o1_mf_annnn_TAG20211216T075512_jvow70h6_.bkp RECID=15 STAMP=1091433312
    crosschecked backup piece: found to be 'AVAILABLE'
    backup piece handle=/opt/oracle/recovery_area/CDB1/autobackup/2021_12_16/o1_mf_s_1091433313_jvow71vz_.bkp RECID=16 STAMP=1091433313
    Crosschecked 16 objects
    ```

3. Use the following command to cross-check the specified backupset. You can Identify the backup that you want to cross-check from the output of the previous `LIST` command.
    ```
    RMAN> <copy>crosscheck backupset 1;</copy>
    ```
    Output:
    ```
    using channel ORA_DISK_1
    crosschecked backup piece: found to be 'AVAILABLE'
    backup piece handle=/opt/oracle/recovery_area/CDB1/backupset/2021_12_16/o1_mf_nnndf_TAG20211216T073341_jvotyom3_.bkp RECID=1 STAMP=1091432021
    Crosschecked 1 objects
    ```


## Task 3: Delete expired backups
The delete expired backup command will remove the EXPIRED backups from the RMAN repository. Those backups that are inaccessible during a cross-check are called expired backups. This command updates only the RMAN repository. It does not make any attempt to delete the backup files from disk or tape.

In this task, you delete expired backups using the following steps.

1. Use the following command to delete expired backups from the RMAN repository.
    ```
    RMAN> <copy>delete expired backup;</copy>
    ```
    Output:
    ```
    using channel ORA_DISK_1
    specification does not match any backup in the repository
    ```


## Task 4: Monitor fast recovery area space usage
You should monitor the fast recovery area to ensure that it is large enough to contain backups and other recovery-related files. The space usage in your Oracle Database may vary from what is shown in this lab.

Oracle Database provides two views to monitor fast recovery area space usage, `v$recovery_file_dest`, and `v$recovery_area_usage`.

In this task, you monitor the space usage of fast recovery area using the following steps.

1. Query the `v$recovery_file_dest` view to obtain the following information about the fast recovery area: total number of files, current location, disk quota, space in use, and space reclaimable by deleting files. The space details are in bytes.
    ```
    RMAN> <copy>select * from v$recovery_file_dest;</copy>
    ```
    Output:
    ```
    NAME                                                                            
    --------------------------------------------------------------------------------
    SPACE_LIMIT SPACE_USED SPACE_RECLAIMABLE NUMBER_OF_FILES     CON_ID
    ----------- ---------- ----------------- --------------- ----------
    /opt/oracle/recovery_area
    10737418240 8299215872          32884224              22          0
    ```

2. Query the `v$recovery_area_usage` view to obtain additional information about the fast recovery area. It contains the percentage of disk quota used by different types of files and the percentage of space that can be reclaimed by deleting files that are obsolete, redundant, or backed up to tape.
    ```
    RMAN> <copy>select file_type, percent_space_used PCT_USED, percent_space_reclaimable PCT_RECLAIM, number_of_files NO_FILES from v$recovery_area_usage;</copy>
    ```
    Output:
    ```
    FILE_TYPE                 PCT_USED PCT_RECLAIM   NO_FILES
    ----------------------- ---------- ----------- ----------
    CONTROL FILE                     0           0          0
    REDO LOG                         0           0          0
    ARCHIVED LOG                   .31         .31          4
    BACKUP PIECE                 73.08           0         16
    IMAGE COPY                       0           0          0
    FLASHBACK LOG                 3.91           0          2
    FOREIGN ARCHIVED LOG             0           0          0
    AUXILIARY DATAFILE COPY          0           0          0

    8 rows selected
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
