# Manage backups

## Introduction
This lab shows you how to manage backups after you create them.

Estimated time: 20 minutes

### About managing backups
An essential part of a backup and recovery strategy is managing backups after they are created. Backup management includes performing periodic checks to ensure that backups are available and usable, as well as deleting obsolete backups. In a multi-tenant environment, you can manage backups for the whole multi-tenant container database (CDB) or one or more pluggable databases (PDBs).


### Objectives
-   Display backup information
-   Cross-check backups
-   Delete expired backups
-   Monitor fast recovery area space usage

### Prerequisites
This lab assumes you have:
-   An Oracle Cloud account
-   Completed all previous labs successfully


## Task 1: Display backup information
Backup reports contain summary and detailed information about past backup jobs run by RMAN. The `v$rman_backup_job_details` view includes information on backup jobs run by RMAN, such as the time taken for the backup, start and finish times, type of backup performed, and backup job status.

1. Start the RMAN prompt.
    ```
    $ <copy>./rman</copy>
    ```
    Output:
    ```
    Recovery Manager: Release 23.0.0.0.0 - Production on Thu Oct 3 13:41:23 2024
    Version 23.4.0.24.05
    
    Copyright (c) 1982, 2024, Oracle and/or its affiliates.  All rights reserved.
    ```

2. Use the following command to connect to the target Oracle Database.
    ```
    RMAN> <copy>connect target;</copy>
    ```
    Output:
    ```
    connected to target database: CDB1 (DBID=1701812036)
    ```

3. Query the `v$rman_backup_job_details` view to display backup job history. You can see the status, start time, and end time of all the backups performed in the output.
    ```
    RMAN> <copy>select session_key, input_type, status, start_time, end_time, elapsed_seconds/3600 hrs from v$rman_backup_job_details;</copy>
    ```
    Output:
    ```
    SESSION_KEY INPUT_TYPE    STATUS                  START_TIM END_TIME         HRS
    ----------- ------------- ----------------------- --------- --------- ----------
            2 DB FULL       COMPLETED               03-OCT-24 03-OCT-24 .071666666
            10 DB FULL       COMPLETED               03-OCT-24 03-OCT-24 .010833333
    ```

    >**Note:** `SESSION_KEY` is the unique key for the RMAN session in which the backup job occurred.  


## Task 2: Cross-check backups
Cross-checking a backup synchronizes the physical reality of backups with their logical records in the RMAN repository. For example, if a backup was deleted with an operating system command, a cross-check would detect this condition. After the cross-check, the RMAN repository correctly reflects the state of the backups.

Backups are listed as available if they are still present in the storage listed in the RMAN repository and if there is no corruption in the file header. Backups that are missing or corrupt are listed as expired.

1. View a list of all backup sets to determine which backup you want to cross-check.
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

2. Cross-check all backup sets.
    ```
    RMAN> <copy>crosscheck backup;</copy>
    ```
    Output:
    ```
    allocated channel: ORA_DISK_1
    channel ORA_DISK_1: SID=148 device type=DISK
    crosschecked backup piece: found to be 'AVAILABLE'
    backup piece handle=/opt/oracle/recovery_area/CDB1/backupset/2024_10_03/o1_mf_nnndf_TAG20241003T132656_mhx6x38g_.bkp RECID=1 STAMP=1181395619
    crosschecked backup piece: found to be 'AVAILABLE'
    backup piece handle=/opt/oracle/recovery_area/CDB1/1CF500B83D440585E0634B0E4664AA19/backupset/2024_10_03/o1_mf_nnndf_TAG20241003T132656_mhx6zh2f_.bkp RECID=2 STAMP=1181395695
    crosschecked backup piece: found to be 'AVAILABLE'
    backup piece handle=/opt/oracle/recovery_area/CDB1/16DBED12D9B6BD08E0631FC45E640B06/backupset/2024_10_03/o1_mf_nnndf_TAG20241003T132656_mhx7088w_.bkp RECID=3 STAMP=1181395720
    crosschecked backup piece: found to be 'AVAILABLE'
    backup piece handle=/opt/oracle/recovery_area/CDB1/autobackup/2024_10_03/o1_mf_s_1181395543_mhx70hmj_.bkp RECID=4 STAMP=1181395727
    crosschecked backup piece: found to be 'AVAILABLE'
    backup piece handle=/opt/oracle/recovery_area/CDB1/backupset/2024_10_03/o1_mf_annnn_TAG20241003T132949_mhx72fr0_.bkp RECID=5 STAMP=1181395789
    crosschecked backup piece: found to be 'AVAILABLE'
    backup piece handle=/opt/oracle/recovery_area/CDB1/backupset/2024_10_03/o1_mf_nnndf_TAG20241003T132951_mhx72jpg_.bkp RECID=6 STAMP=1181395792
    crosschecked backup piece: found to be 'AVAILABLE'
    backup piece handle=/opt/oracle/recovery_area/CDB1/1CF500B83D440585E0634B0E4664AA19/backupset/2024_10_03/o1_mf_nnndf_TAG20241003T132951_mhx73xwo_.bkp RECID=7 STAMP=1181395837
    crosschecked backup piece: found to be 'AVAILABLE'
    backup piece handle=/opt/oracle/recovery_area/CDB1/16DBED12D9B6BD08E0631FC45E640B06/backupset/2024_10_03/o1_mf_nnndf_TAG20241003T132951_mhx74q4h_.bkp RECID=8 STAMP=1181395863
    crosschecked backup piece: found to be 'AVAILABLE'
    backup piece handle=/opt/oracle/recovery_area/CDB1/backupset/2024_10_03/o1_mf_annnn_TAG20241003T133110_mhx74yky_.bkp RECID=9 STAMP=1181395870
    crosschecked backup piece: found to be 'AVAILABLE'
    backup piece handle=/opt/oracle/recovery_area/CDB1/autobackup/2024_10_03/o1_mf_s_1181395871_mhx74zx1_.bkp RECID=10 STAMP=1181395871
    crosschecked backup piece: found to be 'AVAILABLE'
    backup piece handle=/opt/oracle/recovery_area/CDB1/backupset/2024_10_03/o1_mf_annnn_TAG20241003T133716_mhx7jdbw_.bkp RECID=11 STAMP=1181396236
    crosschecked backup piece: found to be 'AVAILABLE'
    backup piece handle=/opt/oracle/recovery_area/CDB1/backupset/2024_10_03/o1_mf_nnndf_TAG20241003T133717_mhx7jg87_.bkp RECID=12 STAMP=1181396238
    crosschecked backup piece: found to be 'AVAILABLE'
    backup piece handle=/opt/oracle/recovery_area/CDB1/backupset/2024_10_03/o1_mf_annnn_TAG20241003T133753_mhx7kkoz_.bkp RECID=13 STAMP=1181396273
    crosschecked backup piece: found to be 'AVAILABLE'
    backup piece handle=/opt/oracle/recovery_area/CDB1/autobackup/2024_10_03/o1_mf_s_1181396274_mhx7km17_.bkp RECID=14 STAMP=1181396275
    Crosschecked 14 objects
    ```

3. Cross-check a specified backup set. You can identify the backup you want to cross-check from the output of the `LIST` command. For this lab, it is `1`.

    ```
    RMAN> <copy>crosscheck backupset 1;</copy>
    ```
    Output:
    ```
    using channel ORA_DISK_1
    crosschecked backup piece: found to be 'AVAILABLE'
    backup piece handle=/opt/oracle/recovery_area/CDB1/backupset/2024_10_03/o1_mf_nnndf_TAG20241003T132656_mhx6x38g_.bkp RECID=1 STAMP=1181395619
    Crosschecked 1 objects
    ```


## Task 3: Delete expired backups
The delete expired backup command will remove the expired backups from the RMAN repository. Those backups that are inaccessible during a cross-check are called expired backups. This command updates only the RMAN repository. It will not attempt to delete the backup files from the storage.

1. Delete expired backups from the RMAN repository.

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

Oracle Database provides two views to monitor fast recovery area space usage: `v$recovery_file_dest` and `v$recovery_area_usage`.

In this task, you monitor the space usage of fast recovery area using the following steps.

1. Query the `v$recovery_file_dest` view to obtain the following information about the fast recovery area: total number of files, current location, disk quota, space in use, and space reclaimable by deleting files. The space details are in bytes.
    ```
    RMAN> <copy>select * from v$recovery_file_dest;</copy>
    ```
    Output:
    ```
    NAME                      SPACE_LIMIT SPACE_USED SPACE_RECLAIMABLE NUMBER_OF_FILES CON_ID
    ------------------------- ----------- ---------- ----------------- --------------- ------
    /opt/oracle/recovery_area 53687091200 1224258150 40629248          20             0
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
    ARCHIVED LOG                   .08         .08          4
    BACKUP PIECE                 21.95           0         14
    IMAGE COPY                       0           0          0
    FLASHBACK LOG                  .78           0          2
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
- **Last Updated By & Date**: Suresh Mohan, October 2024

