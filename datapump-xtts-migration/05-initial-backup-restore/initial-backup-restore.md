# Prepare M5 Script

## Introduction

In this lab, you take a first look at the M5 script. For migrations, Oracle recommends that the source and target hosts shared an NFS drive. In this exercise, we simulate that by using the script from the same directory. 

Estimated Time: 10 Minutes.

### Objectives

In this lab, you will:

* Examine M5 script
* Configure M5 script

## Task 1: Start initial backup

cd /home/oracle/m5
./dbmig_driver_m5.sh L0

    $ ./dbmig_driver_m5.sh L0
    Properties file found, sourcing.
    Next SCN file not found, creating it.
    LOG and CMD directories found
    Backup to disk, creating /home/oracle/m5/rman
    2024-06-21 08:16:10 - 1718957770693: Requested L0 backup for pid 464006.  Using DISK destination, 4 channels and 64G section size.
    2024-06-21 08:16:10 - 1718957770698: Performing L0 backup for pid 464006
    RMAN> 2> 3> 4> RMAN> RMAN> 2> 3> 4> 5> 6> 7> 8> 9> 10> 11> 12> RMAN>
    2024-06-21 08:16:15 - 1718957775298: No errors or warnings found in backup log file for pid 464006
    2024-06-21 08:16:15 - 1718957775308: Manually copy restore script to destination
    2024-06-21 08:16:15 - 1718957775309:  => /home/oracle/m5/cmd/restore_L0_FTEX_240621081610.cmd
    2024-06-21 08:16:15 - 1718957775318: Saving SCN for next backup for pid 464006
    
    BACKUP_TYPE	     INPUT_BYTES(MB) OUTPUT_BYTES(MB) STATUS		      START_TIME	  END_TIME	      ELAPSED_TIME(Min)
    -------------------- --------------- ---------------- ----------------------- ------------------- ------------------- -----------------
    DATAFILE FULL		    62.21875	   60.6796875 COMPLETED 	      06/21/2024:08:16:12 06/21/2024:08:16:14		    .03

cd cmd
ll 
    $ ll
    total 32
    -rw-r--r--. 1 oracle oinstall  641 Jun 21 08:16 bkp_L0_240621081610.cmd
    -rw-r--r--. 1 oracle oinstall 1003 Jun 21 08:21 bkp_report.lst
    -rw-rw-r--. 1 oracle oinstall 5122 Jun 21 08:12 dbmig_driver.properties
    -rw-r--r--. 1 oracle oinstall    6 Jun 21 08:15 dbmig_ts_list.txt
    -rw-r--r--. 1 oracle oinstall  658 Jun 21 08:16 restore_L0_FTEX_240621081610.cmd


    $ cat bkp_L0_240621081610.cmd
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
           TAG FTEX_L0_240621081610
           TABLESPACE USERS;
    }



cd ..
cd log
    $ ll
    total 952
    -rw-r--r--. 1 oracle oinstall   3836 Jun 21 08:16 bkp_L0_4CH_64G_FTEX_240621081610.log
    -rw-r--r--. 1 oracle oinstall 496165 Jun 21 08:16 bkp_L0_4CH_64G_FTEX_240621081610.trc
    -rw-r--r--. 1 oracle oinstall    198 Jun 21 08:16 chk_backup.log
    -rw-r--r--. 1 oracle oinstall   4978 Jun 21 08:16 rman_mig_bkp.log

cd .. 
cd rman    
    $ ll
    total 51624
    -rw-r-----. 1 oracle oinstall 52805632 Jun 21 08:16 L0_FTEX_USERS_1172218572_3_1


## Task 2: Perform initial restore

examine restore script
cd /home/oracle/m5/cmd

ll restore*
-rw-r--r--. 1 oracle oinstall 658 Jun 21 08:16 restore_L0_FTEX_240621081610.cmd



    $ cat restore_L0_FTEX_240621081610.cmd
    SPOOL LOG TO log/restore_L0_FTEX_240621081610.log;
    SPOOL TRACE TO log/restore_L0_FTEX_240621081610.trc;
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
    '/home/oracle/m5/rman/L0_FTEX_USERS_1172218572_3_1';}

. cdb23

export L0SCRIPT=$(ls -tr restore_L0* | tail -1)
cd /home/oracle/m5
rman target "sys/oracle@'localhost/violet'" cmdfile=/home/oracle/m5/cmd/$L0SCRIPT
    

## Get the output from L0 backup!!!


cd /home/oracle/m5/log
egrep "WARN-|ORA-" $(ls -tr restore* | tail -1)
    * The command produces no output because the search string was not found. This means there were no warnings or errors in the log file.



You may now *proceed to the next lab*.

## Acknowledgements

* **Author** - Daniel Overby Hansen
* **Contributors** - Klaus Gronau, Rodrigo Jorge, Mike Dietrich
* **Last Updated By/Date** - Daniel Overby Hansen, July 2024
