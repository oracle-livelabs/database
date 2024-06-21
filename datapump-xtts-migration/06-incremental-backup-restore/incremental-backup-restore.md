# Prepare M5 Script

## Introduction

In this lab, you take a first look at the M5 script. For migrations, Oracle recommends that the source and target hosts shared an NFS drive. In this exercise, we simulate that by using the script from the same directory. 

Estimated Time: 10 Minutes.

### Objectives

In this lab, you will:

* Examine M5 script
* Configure M5 script

## Task 1: Perform incremental backup / restore

cd /home/oracle/m5
    ./dbmig_driver_m5.sh L1
    Properties file found, sourcing.
    LOG and CMD directories found
    2024-06-21 08:21:00 - 1718958060528: Requested L1 backup for pid 464450.  Using DISK destination, 4 channels and 64G section size.
    2024-06-21 08:21:00 - 1718958060533: Performing L1 backup for pid 464450
    RMAN> 2> 3> 4> RMAN> RMAN> 2> 3> 4> 5> 6> 7> 8> 9> 10> 11> 12> 13> RMAN>
    2024-06-21 08:21:03 - 1718958063471: No errors or warnings found in backup log file for pid 464450
    2024-06-21 08:21:03 - 1718958063481: Manually copy restore script to destination
    2024-06-21 08:21:03 - 1718958063482:  => /home/oracle/m5/cmd/restore_L1_FTEX_240621082100.cmd
    2024-06-21 08:21:03 - 1718958063491: Saving SCN for next backup for pid 464450
    
    BACKUP_TYPE	     INPUT_BYTES(MB) OUTPUT_BYTES(MB) STATUS		      START_TIME	  END_TIME	      ELAPSED_TIME(Min)
    -------------------- --------------- ---------------- ----------------------- ------------------- ------------------- -----------------
    DATAFILE FULL		    .0078125	      .046875 COMPLETED 	      06/21/2024:08:21:02 06/21/2024:08:21:03		    .01

    * Notice how *INPUT_BYTES* is very small. This is a consequence of block change tracking. The database knows which blocks were changed since the last backup. On incremental backups, the database just scans the changed blocks.
    * Also notice how *OUTPUT_BYTES* is very small. You didn't change anything in the database since the last backup, so there are very little changes to back up.
    * The more often you perform incremental backups, the faster they run and the smaller the backup is.
    * In a real migration, you would run incremental backups as often as practicically possible, the limit the amount of changes that goes into the final incremental backup. Only the final incremental backup affects the downtime duration. All other backups are performed before the outage.

cd cmd
ll bkp*cmd
-rw-r--r--. 1 oracle oinstall 641 Jun 21 08:16 bkp_L0_240621081610.cmd
-rw-r--r--. 1 oracle oinstall 677 Jun 21 08:21 bkp_L1_240621082100.cmd

$ cat bkp_L1_240621082100.cmd
SET ECHO ON;
SHOW ALL;
ALTER SYSTEM CHECKPOINT GLOBAL;
SELECT checkpoint_change# prev_incr_ckp_scn FROM v$database;
SET EVENT FOR skip_auxiliary_set_tbs TO 1;
RUN
{
ALLOCATE CHANNEL d1 DEVICE TYPE DISK FORMAT '/home/oracle/m5/rman/L1_%d_%N_%t_%s_%p';
ALLOCATE CHANNEL d2 DEVICE TYPE DISK FORMAT '/home/oracle/m5/rman/L1_%d_%N_%t_%s_%p';
ALLOCATE CHANNEL d3 DEVICE TYPE DISK FORMAT '/home/oracle/m5/rman/L1_%d_%N_%t_%s_%p';
ALLOCATE CHANNEL d4 DEVICE TYPE DISK FORMAT '/home/oracle/m5/rman/L1_%d_%N_%t_%s_%p';
BACKUP
       FILESPERSET 1
       INCREMENTAL FROM SCN 2417184
       SECTION SIZE 64G
       TAG FTEX_L1_240621082100
       TABLESPACE USERS;
} 

ll restore_L1*cmd
-rw-r--r--. 1 oracle oinstall 658 Jun 21 08:21 restore_L1_FTEX_240621082100.cmd

    $ cat restore_L1_FTEX_240621082100.cmd
    SPOOL LOG TO log/restore_L1_FTEX_240621082100.log;
    SPOOL TRACE TO log/restore_L1_FTEX_240621082100.trc;
    SET EVENT FOR catalog_foreign_datafile_restore TO 1;
    SET ECHO ON;
    SHOW ALL;
    DEBUG ON;
    RUN
    {
    ALLOCATE CHANNEL DISK1 DEVICE TYPE DISK FORMAT '/home/oracle/m5/rman/L1_%d_%N_%t_%s_%p';
    ALLOCATE CHANNEL DISK2 DEVICE TYPE DISK FORMAT '/home/oracle/m5/rman/L1_%d_%N_%t_%s_%p';
    ALLOCATE CHANNEL DISK3 DEVICE TYPE DISK FORMAT '/home/oracle/m5/rman/L1_%d_%N_%t_%s_%p';
    ALLOCATE CHANNEL DISK4 DEVICE TYPE DISK FORMAT '/home/oracle/m5/rman/L1_%d_%N_%t_%s_%p';
    RESTORE ALL FOREIGN DATAFILES TO NEW FROM BACKUPSET
    '/home/oracle/m5/rman/L1_FTEX_USERS_1172218862_5_1';}

export L1SCRIPT=$(ls -tr restore_L1* | tail -1) 

cd ..
cd rman
$ ll L1*
-rw-r-----. 1 oracle oinstall 57344 Jun 21 08:21 L1_FTEX_USERS_1172218862_5_1


. cdb23

cd /home/oracle/m5
rman target "sys/oracle@'localhost/violet'" cmdfile=/home/oracle/m5/cmd/$L1SCRIPT
    
$ rman target "sys@'localhost/violet'" cmdfile=/home/oracle/m5/cmd/$L1SCRIPT

Recovery Manager: Release 23.0.0.0.0 - Production on Fri Jun 21 09:01:03 2024
Version 23.4.0.24.05

Copyright (c) 1982, 2024, Oracle and/or its affiliates.  All rights reserved.

connected to target database: CDB23:VIOLET (DBID=932816428)

RMAN> SPOOL LOG TO log/restore_L1_FTEX_240621082100.log;
2> SPOOL TRACE TO log/restore_L1_FTEX_240621082100.trc;
3> SET EVENT FOR catalog_foreign_datafile_restore TO 1;
4> SET ECHO ON;
5> SHOW ALL;
6> DEBUG ON;
7> RUN
8> {
9> ALLOCATE CHANNEL DISK1 DEVICE TYPE DISK FORMAT '/home/oracle/m5/rman/L1_%d_%N_%t_%s_%p';
10> ALLOCATE CHANNEL DISK2 DEVICE TYPE DISK FORMAT '/home/oracle/m5/rman/L1_%d_%N_%t_%s_%p';
11> ALLOCATE CHANNEL DISK3 DEVICE TYPE DISK FORMAT '/home/oracle/m5/rman/L1_%d_%N_%t_%s_%p';
12> ALLOCATE CHANNEL DISK4 DEVICE TYPE DISK FORMAT '/home/oracle/m5/rman/L1_%d_%N_%t_%s_%p';
13> RESTORE ALL FOREIGN DATAFILES TO NEW FROM BACKUPSET
14> '/home/oracle/m5/rman/L1_FTEX_USERS_1172218862_5_1';}
15>

cd log
egrep "WARN-|ORA-" $(ls -tr restore* | tail -1)
    * The command produces no output because the search string was not found. This means there were no warnings or errors in the log file.

## Task 2: Make changes in source database

Let's simulate changes to data in the source database and let's see how it affects the backup and restore phase.

. ftex
sqlplus / as sysdba

SQL> create table f1.f1_laptimes_backup as select * from f1.f1_laptimes;

Table created.

exit

## Task 3: Perform incremental backup / restore

cd /home/oracle/m5
    ./dbmig_driver_m5.sh L1

$     ./dbmig_driver_m5.sh L1
Properties file found, sourcing.
LOG and CMD directories found
2024-06-21 09:12:37 - 1718961157875: Requested L1 backup for pid 468294.  Using DISK destination, 4 channels and 64G section size.
2024-06-21 09:12:37 - 1718961157880: Performing L1 backup for pid 468294
RMAN> 2> 3> 4> RMAN> RMAN> 2> 3> 4> 5> 6> 7> 8> 9> 10> 11> 12> 13> RMAN>
2024-06-21 09:12:40 - 1718961160912: No errors or warnings found in backup log file for pid 468294
2024-06-21 09:12:40 - 1718961160922: Manually copy restore script to destination
2024-06-21 09:12:40 - 1718961160924:  => /home/oracle/m5/cmd/restore_L1_FTEX_240621091237.cmd
2024-06-21 09:12:40 - 1718961160933: Saving SCN for next backup for pid 468294

BACKUP_TYPE	     INPUT_BYTES(MB) OUTPUT_BYTES(MB) STATUS		      START_TIME	  END_TIME	      ELAPSED_TIME(Min)
-------------------- --------------- ---------------- ----------------------- ------------------- ------------------- -----------------
DATAFILE FULL		  20.3671875	   20.3515625 COMPLETED 	      06/21/2024:09:12:39 06/21/2024:09:12:40		    .01

    * Notice how *INPUT_BYTES* increases from the previous incremental backup. From below 1 MB to around 20 MB. You made changes, so the database needs to scan more blocks. 
    * Also, notice how *OUTPUT_BYTES* increases. From below 1 MB to around 20 MB. You entered new data, so the size of the backup increases.

cd cmd
export L1FSCRIPT=$(ls -tr restore_L1F* | tail -1) 

cd ..
cd rman
$ ll L1*
-rw-r-----. 1 oracle oinstall 57344 Jun 21 08:21 L1_FTEX_USERS_1172218862_5_1


. cdb23

cd /home/oracle/m5
rman target "sys/oracle@'localhost/violet'" cmdfile=/home/oracle/m5/cmd/$L1SCRIPT

$ rman target "sys/oracle@'localhost/violet'" cmdfile=/home/oracle/m5/cmd/$L1SCRIPT

Recovery Manager: Release 23.0.0.0.0 - Production on Fri Jun 21 09:15:21 2024
Version 23.4.0.24.05

Copyright (c) 1982, 2024, Oracle and/or its affiliates.  All rights reserved.

connected to target database: CDB23:VIOLET (DBID=932816428)

RMAN> SPOOL LOG TO log/restore_L1_FTEX_240621091237.log;
2> SPOOL TRACE TO log/restore_L1_FTEX_240621091237.trc;
3> SET EVENT FOR catalog_foreign_datafile_restore TO 1;
4> SET ECHO ON;
5> SHOW ALL;
6> DEBUG ON;
7> RUN
8> {
9> ALLOCATE CHANNEL DISK1 DEVICE TYPE DISK FORMAT '/home/oracle/m5/rman/L1_%d_%N_%t_%s_%p';
10> ALLOCATE CHANNEL DISK2 DEVICE TYPE DISK FORMAT '/home/oracle/m5/rman/L1_%d_%N_%t_%s_%p';
11> ALLOCATE CHANNEL DISK3 DEVICE TYPE DISK FORMAT '/home/oracle/m5/rman/L1_%d_%N_%t_%s_%p';
12> ALLOCATE CHANNEL DISK4 DEVICE TYPE DISK FORMAT '/home/oracle/m5/rman/L1_%d_%N_%t_%s_%p';
13> RESTORE ALL FOREIGN DATAFILES TO NEW FROM BACKUPSET
14> '/home/oracle/m5/rman/L1_FTEX_USERS_1172221959_6_1';}
15>


cd log
egrep "WARN-|ORA-" $(ls -tr restore* | tail -1)
    * The command produces no output because the search string was not found. This means there were no warnings or errors in the log file.

You may now *proceed to the next lab*.

## Acknowledgements

* **Author** - Daniel Overby Hansen
* **Contributors** - Klaus Gronau, Rodrigo Jorge, Mike Dietrich
* **Last Updated By/Date** - Daniel Overby Hansen, July 2024
