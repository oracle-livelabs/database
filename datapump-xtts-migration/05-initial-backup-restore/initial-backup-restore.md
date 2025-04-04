# Initial Backup and Restore

## Introduction

Now, it's time to start the migration. First, you take a level 0 backup that you restore in the target database. Although the migration has started, there is no downtime yet. The initial level 0 backup is taken without downtime.

Estimated Time: 10 Minutes

[Next-Level Platform Migration with Cross-Platform Transportable Tablespaces - lab 5](youtube:fgyDy-QcV_o?start=930)


![Start the initial level 0 backup/restore](./images/initial-backup-restore-overview.png " ")

### Objectives

In this lab, you will:

* Perform initial level 0 backup
* Restore backup
* Examine scripts and logs

## Task 1: Start initial backup

1. Use the *yellow* terminal 🟨. Set the environment to the source database and change to the script base.

    ```
    <copy>
    . ftex
    cd /home/oracle/m5
    </copy>

    -- Be sure to hit RETURN
    ```

2. Start the level 0 backup. 

    ```
    <copy>
    ./dbmig_driver_m5.sh L0
    </copy>
    ```

    * The details of the migration are stored in the properties file that you examined in the previous lab. Hence, you don't need to specify any details to start the backup.
    * The L0 backup needs to scan the entire database. Notice how *INPUT_BYTES* corresponds to the size of the database (around 62 MB).
    * Since you don't use RMAN compression in this exercise, the size of the backup is roughly the size of the database (around 60 MB). It will be smaller since RMAN always uses unused block compression which excludes empty blocks from the backup. 

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ ./dbmig_driver_m5.sh L0
    Properties file found, sourcing.
    Next SCN file not found, creating it.
    LOG and CMD directories found
    Backup to disk, creating /home/oracle/m5/rman
    2024-07-02 18:52:18 - 1719946338839: Requested L0 backup for pid 13055.  Using DISK destination, 4 channels and 64G section size.
    2024-07-02 18:52:18 - 1719946338847: Performing L0 backup for pid 13055
    RMAN> 2> 3> 4> RMAN> RMAN> 2> 3> 4> 5> 6> 7> 8> 9> 10> 11> 12> RMAN>
    2024-07-02 18:52:24 - 1719946344671: No errors or warnings found in backup log file for pid 13055
    2024-07-02 18:52:24 - 1719946344691: Manually copy restore script to destination
    2024-07-02 18:52:24 - 1719946344693:  => /home/oracle/m5/cmd/restore_L0_FTEX_240702185218.cmd
    2024-07-02 18:52:24 - 1719946344705: Saving SCN for next backup for pid 13055
    
    BACKUP_TYPE   INPUT_BYTES(MB) OUTPUT_BYTES(MB) STATUS    START_TIME          END_TIME            ELAPSED_TIME(Min)
    ------------- --------------- ---------------- --------- ------------------- ------------------- -----------------
    DATAFILE FULL 62.09375        60.3203125       COMPLETED 07/02/2024:18:52:21 07/02/2024:18:52:24 .05
    ```
    </details>

3. Switch to the *cmd* directory and examine the files. 

    ```
    <copy>
    cd cmd
    ll
    </copy>

    -- Be sure to hit RETURN
    ```

    * The M5 script generated some scripts during the initial L0 backup. 

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ cd cmd
    $ ll
    total 24
    -rw-r--r--. 1 oracle oinstall  641 Jul  2 18:52 bkp_L0_240702185218.cmd
    -rw-r--r--. 1 oracle oinstall 1003 Jul  2 18:52 bkp_report.lst
    -rw-r--r--. 1 oracle oinstall 5121 Jun 26 14:06 dbmig_driver.properties
    -rw-r--r--. 1 oracle oinstall    6 Jul  2 18:51 dbmig_ts_list.txt
    -rw-r--r--. 1 oracle oinstall  658 Jul  2 18:52 restore_L0_FTEX_240702185218.cmd
    ```
    </details>

4. Examine the backup script used for the initial backup. 

    ```
    <copy>
    cat $(ls -tr bkp_L0_*.cmd | tail -1)
    </copy>
    ```

    * The names of the scripts change, so the command automatically fetches the script with the name in your environment. 
    * Notice how the backup is *just* an RMAN `BACKUP ... TABLESPACE` command.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ cat $(ls -tr bkp_L0_*.cmd | tail -1)
    SET ECHO ON;
    SHOW ALL;
    ALTER SYSTEM CHECKPOINT GLOBAL;
    SELECT checkpoint_change# prev_incr_ckp_scn FROM v$database;
    SET EVENT FOR skip_auxiliary_set_tbs TO 1;
    RUN
    {
    ALLOCATE CHANNEL d1 DEVICE TYPE DISK FORMAT '/home/oracle/m5/rman/L0_%d_%N_%t_%s_%p';
    ALLOCATE CHANNEL d2 DEVICE TYPE DISK FORMAT '/home/oracle/m5/rman/L0_%d_%N_%t_%s_%p';
    ALLOCATE CHANNEL d3 DEVICE TYPE DISK FORMAT '/home/oracle/m5/rman/L0_%d_%N_%t_%s_%p';
    ALLOCATE CHANNEL d4 DEVICE TYPE DISK FORMAT '/home/oracle/m5/rman/L0_%d_%N_%t_%s_%p';
    BACKUP
           FILESPERSET 1
           SECTION SIZE 64G
           TAG FTEX_L0_240702185218
           TABLESPACE USERS;
    }
    ```
    </details>

5. Examine the log directory.

    ```
    <copy>
    cd ../log
    ll
    </copy>

    -- Be sure to hit RETURN
    ```

    * The file names are different in your environment.
    * The backup created a log file named `bkp_L0_4CH_64G_FTEX_240702185218.log`.
    * Tracing is enabled by default and written to `bkp_L0_4CH_64G_FTEX_240702185218.trc`.
    * Additional log files are written as well.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ cd ../log
    $ ll
    total 500
    -rw-r--r--. 1 oracle oinstall   3857 Jul  2 18:52 bkp_L0_4CH_64G_FTEX_240702185218.log
    -rw-r--r--. 1 oracle oinstall 496430 Jul  2 18:52 bkp_L0_4CH_64G_FTEX_240702185218.trc
    -rw-r--r--. 1 oracle oinstall     98 Jul  2 18:52 chk_backup.log
    -rw-r--r--. 1 oracle oinstall   2478 Jul  2 18:52 rman_mig_bkp.log
    ```
    </details>

5. Examine the RMAN backup sets. 

    ```
    <copy>
    cd ../rman
    ll
    </copy>

    -- Be sure to hit RETURN
    ```

    * In this lab, there is only one small tablespace in the database. Hence, there is only one backup set.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ cd ../rman
    $ ll
    total 51328
    -rw-r-----. 1 oracle oinstall 52559872 Jul  2 18:52 L0_FTEX_USERS_1173293541_1_1
    ```
    </details>

## Task 2: Perform initial restore

1. Switch to the *blue* terminal 🟦. The backup also generated a restore script that you can use on the target database. Find the restore script. 

    ```
    <copy>
    cd /home/oracle/m5/cmd
    ll restore*
    </copy>

    -- Be sure to hit RETURN
    ```

    * The name of the restore script in your environment is different. 

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ cd /home/oracle/m5/cmd
    $ ll restore*
    total 51624
    -rw-r--r--. 1 oracle oinstall 658 Jul  2 18:52 restore_L0_FTEX_240702185218.cmd
    ```
    </details>

2. Examine the restore script. 

    ```
    <copy>
    cat $(ls -tr restore_L0*.cmd | tail -1)
    </copy>
    ```

    * Notice how the restore uses `RESTORE ALL FOREIGN DATAFILES` command.
    * This command was introduced in Oracle Database 18c and greatly enhanced in Oracle Database 19c. 
    * It is a packaged command which looks at the specified backup set and determines what to restore and what to recover. There is no specific `RECOVER` command.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ cat restore_L0_FTEX_240621081610.cmd
    SPOOL LOG TO log/restore_L0_FTEX_240702185218.log;
    SPOOL TRACE TO log/restore_L0_FTEX_240702185218.trc;
    SET EVENT FOR catalog_foreign_datafile_restore TO 1;
    SET ECHO ON;
    SHOW ALL;
    DEBUG ON;
    RUN
    {
    ALLOCATE CHANNEL DISK1 DEVICE TYPE DISK FORMAT '/home/oracle/m5/rman/L0_%d_%N_%t_%s_%p';
    ALLOCATE CHANNEL DISK2 DEVICE TYPE DISK FORMAT '/home/oracle/m5/rman/L0_%d_%N_%t_%s_%p';
    ALLOCATE CHANNEL DISK3 DEVICE TYPE DISK FORMAT '/home/oracle/m5/rman/L0_%d_%N_%t_%s_%p';
    ALLOCATE CHANNEL DISK4 DEVICE TYPE DISK FORMAT '/home/oracle/m5/rman/L0_%d_%N_%t_%s_%p';
    RESTORE ALL FOREIGN DATAFILES TO NEW FROM BACKUPSET
    '/home/oracle/m5/rman/L0_FTEX_USERS_1173293541_1_1';}
    ```
    </details>

3. Set the environment to the target database and *start the restore*.

    ```
    <copy>
    cd /home/oracle/m5/cmd
    export L0SCRIPT=$(ls -tr restore_L0* | tail -1)
    cd /home/oracle/m5
    . cdb23
    rman target "sys/oracle@'localhost/violet'" cmdfile=/home/oracle/m5/cmd/$L0SCRIPT
    </copy>

    -- Be sure to hit RETURN
    ```

    * The script auto-generates a file name for the restore script. It's different in each lab, so you find and store the restore script file name in a variable. 
    * Connect with RMAN directly into the target PDB, *violet*. 
    * Run the restore script using the `cmdfile` command line option.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ cd /home/oracle/m5/cmd
    $ export L0SCRIPT=$(ls -tr restore_L0* | tail -1)
    $ cd /home/oracle/m5
    $ . cdb23
    $ rman target "sys/oracle@'localhost/violet'" cmdfile=/home/oracle/m5/cmd/$L0SCRIPT
    
    Recovery Manager: Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems on Tue Jul 2 18:58:07 2024
    Version 23.5.0.24.07
    
    Copyright (c) 1982, 2024, Oracle and/or its affiliates.  All rights reserved.
    
    connected to target database: CDB23:VIOLET (DBID=1874382390)
    
    RMAN> SPOOL LOG TO log/restore_L0_FTEX_240702185218.log;
    2> SPOOL TRACE TO log/restore_L0_FTEX_240702185218.trc;
    3> SET EVENT FOR catalog_foreign_datafile_restore TO 1;
    4> SET ECHO ON;
    5> SHOW ALL;
    6> DEBUG ON;
    7> RUN
    8> {
    9> ALLOCATE CHANNEL DISK1 DEVICE TYPE DISK FORMAT '/home/oracle/m5/rman/L0_%d_%N_%t_%s_%p';
    10> ALLOCATE CHANNEL DISK2 DEVICE TYPE DISK FORMAT '/home/oracle/m5/rman/L0_%d_%N_%t_%s_%p';
    11> ALLOCATE CHANNEL DISK3 DEVICE TYPE DISK FORMAT '/home/oracle/m5/rman/L0_%d_%N_%t_%s_%p';
    12> ALLOCATE CHANNEL DISK4 DEVICE TYPE DISK FORMAT '/home/oracle/m5/rman/L0_%d_%N_%t_%s_%p';
    13> RESTORE ALL FOREIGN DATAFILES TO NEW FROM BACKUPSET
    14> '/home/oracle/m5/rman/L0_FTEX_USERS_1173293541_1_1';}
    15>
    ```
    </details>

4. Search the log file for any warnings or errors. 

    ```
    <copy>
    cd log
    egrep "WARN-|ORA-" $(ls -tr restore*log | tail -1)
    </copy>

    -- Be sure to hit RETURN
    ```

    * The command produces no output because the search string was not found. This means there were no warnings or errors in the log file.

You may now *proceed to the next lab*.

## Further information

In a real migration, if you are worried about the load on the source database, and if you use Data Guard, you can perform the backups from a standby database. Such configuration is out of scope for this exercise. 

## Acknowledgments

* **Author** - Daniel Overby Hansen
* **Contributors** - Rodrigo Jorge, Mike Dietrich, Klaus Gronau, Alex Zaballa
* **Last Updated By/Date** - Daniel Overby Hansen, August 2024
