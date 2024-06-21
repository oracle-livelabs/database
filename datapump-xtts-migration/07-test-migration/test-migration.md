# Test Migration

## Introduction

In this lab, you take a first look at the M5 script. For migrations, Oracle recommends that the source and target hosts shared an NFS drive. In this exercise, we simulate that by using the script from the same directory. 

Estimated Time: 10 Minutes.

### Objectives

In this lab, you will:

* Examine M5 script
* Configure M5 script

## Task 1: Perform incremental backup / restore

OUTAGE START

rm /home/oracle/m5/log/rman_mig_bkp.lck
. ftex
cd /home/oracle/m5
./dbmig_driver_m5.sh L1F
    * When prompted for *system password, enter *ftexuser*.
    
    
$ ./dbmig_driver_m5.sh L1F
Properties file found, sourcing.
LOG and CMD directories found
2024-06-21 10:07:52 - 1718964472746: Requested L1F backup for pid 472856.  Using DISK destination, 4 channels and 64G section size.
2024-06-21 10:07:52 - 1718964472751: Performing L1F backup for pid 472856
============================================
Enter the system password to perform read only tablespaces

Connected successfully
Oracle authentication successful

Tablespace altered.

RMAN> 2> 3> 4> RMAN> RMAN> 2> 3> 4> 5> 6> 7> 8> 9> 10> 11> 12> 13> RMAN>
2024-06-21 10:07:58 - 1718964478768: No errors or warnings found in backup log file for pid 472856
2024-06-21 10:07:58 - 1718964478780: Manually copy restore script to destination
2024-06-21 10:07:58 - 1718964478781:  => /home/oracle/m5/cmd/restore_L1F_FTEX_240621100752.cmd

Export: Release 19.0.0.0.0 - Production on Fri Jun 21 10:07:58 2024
Version 19.21.0.0.0

Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.

Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
21-JUN-24 10:08:02.421: Starting "FTEXUSER"."SYS_EXPORT_FULL_01":  FTEXUSER/********@localhost/ftex parfile=/home/oracle/m5/cmd/exp_FTEX_240621100752_xtts.par
21-JUN-24 10:08:02.926: W-1 Startup took 0 seconds
21-JUN-24 10:08:05.868: W-1 Processing object type DATABASE_EXPORT/EARLY_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA
21-JUN-24 10:08:06.803: W-1 Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/TABLE_DATA
21-JUN-24 10:08:11.841: W-1 Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA
21-JUN-24 10:08:12.784: W-1 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/TABLE_DATA
21-JUN-24 10:08:15.128: W-1 Processing object type DATABASE_EXPORT/PLUGTS_FULL/FULL/PLUGTS_TABLESPACE
21-JUN-24 10:08:15.142: W-1      Completed  PLUGTS_TABLESPACE objects in  seconds
21-JUN-24 10:08:15.175: W-1 Processing object type DATABASE_EXPORT/PLUGTS_FULL/PLUGTS_BLK
21-JUN-24 10:08:15.210: W-1      Completed 1 PLUGTS_BLK objects in 0 seconds
21-JUN-24 10:08:15.594: W-1 Processing object type DATABASE_EXPORT/END_PLUGTS_BLK
21-JUN-24 10:08:15.598: W-1      Completed 1 PLUGTS_BLK objects in 0 seconds
21-JUN-24 10:08:15.610: W-1 Processing object type DATABASE_EXPORT/PRE_SYSTEM_IMPCALLOUT/MARKER
21-JUN-24 10:08:15.612: W-1      Completed 1 MARKER objects in 0 seconds
21-JUN-24 10:08:15.618: W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER
21-JUN-24 10:08:15.620: W-1      Completed 1 MARKER objects in 0 seconds
21-JUN-24 10:08:15.661: W-1 Processing object type DATABASE_EXPORT/TABLESPACE
21-JUN-24 10:08:15.665: W-1      Completed 2 TABLESPACE objects in 0 seconds
21-JUN-24 10:08:15.777: W-1 Processing object type DATABASE_EXPORT/PROFILE
21-JUN-24 10:08:15.781: W-1      Completed 1 PROFILE objects in 0 seconds
21-JUN-24 10:08:15.822: W-1 Processing object type DATABASE_EXPORT/SCHEMA/USER
21-JUN-24 10:08:15.826: W-1      Completed 2 USER objects in 0 seconds
21-JUN-24 10:08:15.856: W-1 Processing object type DATABASE_EXPORT/ROLE
21-JUN-24 10:08:15.860: W-1      Completed 1 ROLE objects in 0 seconds
21-JUN-24 10:08:15.874: W-1 Processing object type DATABASE_EXPORT/RADM_FPTM
21-JUN-24 10:08:15.878: W-1      Completed 1 RADM_FPTM objects in 0 seconds
21-JUN-24 10:08:16.058: W-1 Processing object type DATABASE_EXPORT/GRANT/SYSTEM_GRANT/PROC_SYSTEM_GRANT
21-JUN-24 10:08:16.063: W-1      Completed 6 PROC_SYSTEM_GRANT objects in 1 seconds
21-JUN-24 10:08:16.092: W-1 Processing object type DATABASE_EXPORT/SCHEMA/GRANT/SYSTEM_GRANT
21-JUN-24 10:08:16.108: W-1      Completed 75 SYSTEM_GRANT objects in 0 seconds
21-JUN-24 10:08:16.127: W-1 Processing object type DATABASE_EXPORT/SCHEMA/ROLE_GRANT
21-JUN-24 10:08:16.139: W-1      Completed 41 ROLE_GRANT objects in 0 seconds
21-JUN-24 10:08:16.155: W-1 Processing object type DATABASE_EXPORT/SCHEMA/DEFAULT_ROLE
21-JUN-24 10:08:16.160: W-1      Completed 4 DEFAULT_ROLE objects in 0 seconds
21-JUN-24 10:08:16.180: W-1 Processing object type DATABASE_EXPORT/SCHEMA/ON_USER_GRANT
21-JUN-24 10:08:16.186: W-1      Completed 18 ON_USER_GRANT objects in 0 seconds
21-JUN-24 10:08:16.215: W-1 Processing object type DATABASE_EXPORT/SCHEMA/TABLESPACE_QUOTA
21-JUN-24 10:08:16.220: W-1      Completed 3 TABLESPACE_QUOTA objects in 0 seconds
21-JUN-24 10:08:16.232: W-1 Processing object type DATABASE_EXPORT/RESOURCE_COST
21-JUN-24 10:08:16.236: W-1      Completed 1 RESOURCE_COST objects in 0 seconds
21-JUN-24 10:08:16.301: W-1 Processing object type DATABASE_EXPORT/TRUSTED_DB_LINK
21-JUN-24 10:08:16.305: W-1      Completed 1 TRUSTED_DB_LINK objects in 0 seconds
21-JUN-24 10:08:16.365: W-1 Processing object type DATABASE_EXPORT/DIRECTORY/DIRECTORY
21-JUN-24 10:08:16.370: W-1      Completed 2 DIRECTORY objects in 0 seconds
21-JUN-24 10:08:16.569: W-1 Processing object type DATABASE_EXPORT/DIRECTORY/GRANT/OWNER_GRANT/OBJECT_GRANT
21-JUN-24 10:08:16.574: W-1      Completed 4 OBJECT_GRANT objects in 0 seconds
21-JUN-24 10:08:17.154: W-1 Processing object type DATABASE_EXPORT/SCHEMA/PUBLIC_SYNONYM/SYNONYM
21-JUN-24 10:08:17.158: W-1      Completed 1 SYNONYM objects in 0 seconds
21-JUN-24 10:08:17.696: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/PRE_SYSTEM_ACTIONS/PROCACT_SYSTEM
21-JUN-24 10:08:17.782: W-1      Completed 2 PROCACT_SYSTEM objects in 0 seconds
21-JUN-24 10:08:17.932: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/PROCOBJ
21-JUN-24 10:08:17.941: W-1      Completed 24 PROCOBJ objects in 0 seconds
21-JUN-24 10:08:18.140: W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/POST_SYSTEM_ACTIONS/PROCACT_SYSTEM
21-JUN-24 10:08:18.382: W-1      Completed 4 PROCACT_SYSTEM objects in 0 seconds
21-JUN-24 10:08:18.786: W-1 Processing object type DATABASE_EXPORT/SCHEMA/PROCACT_SCHEMA
21-JUN-24 10:08:18.791: W-1      Completed 5 PROCACT_SCHEMA objects in 0 seconds
21-JUN-24 10:08:23.731: W-1 Processing object type DATABASE_EXPORT/EARLY_OPTIONS/VIEWS_AS_TABLES/TABLE
21-JUN-24 10:08:23.732: W-1      Completed 1 TABLE objects in 3 seconds
21-JUN-24 10:08:23.745: W-1 Processing object type DATABASE_EXPORT/EARLY_POST_INSTANCE_IMPCALLOUT/MARKER
21-JUN-24 10:08:23.747: W-1      Completed 1 MARKER objects in 0 seconds
21-JUN-24 10:08:37.434: W-1 Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/TABLE
21-JUN-24 10:08:51.102: W-1      Completed 17 TABLE objects in 28 seconds
21-JUN-24 10:08:53.713: W-1 Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/VIEWS_AS_TABLES/TABLE
21-JUN-24 10:09:04.294: W-1      Completed 15 TABLE objects in 13 seconds
21-JUN-24 10:09:04.327: W-1 Processing object type DATABASE_EXPORT/NORMAL_POST_INSTANCE_IMPCALLOUT/MARKER
21-JUN-24 10:09:04.329: W-1      Completed 1 MARKER objects in 0 seconds
21-JUN-24 10:09:05.584: W-1 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/TABLE
21-JUN-24 10:09:14.482: W-1      Completed 16 TABLE objects in 10 seconds
21-JUN-24 10:09:15.228: W-1 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/COMMENT
21-JUN-24 10:09:16.885: W-1 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/INDEX/INDEX
21-JUN-24 10:09:17.727: W-1 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/CONSTRAINT/CONSTRAINT
21-JUN-24 10:09:17.756: W-1      Completed 22 CONSTRAINT objects in 1 seconds
21-JUN-24 10:09:18.973: W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER
21-JUN-24 10:09:18.975: W-1      Completed 1 MARKER objects in 0 seconds
21-JUN-24 10:09:21.745: W-1 Processing object type DATABASE_EXPORT/AUDIT
21-JUN-24 10:09:21.754: W-1      Completed 31 AUDIT objects in 0 seconds
21-JUN-24 10:09:21.799: W-1 Processing object type DATABASE_EXPORT/POST_SYSTEM_IMPCALLOUT/MARKER
21-JUN-24 10:09:21.800: W-1      Completed 1 MARKER objects in 0 seconds
21-JUN-24 10:09:22.201: W-1 . . exported "SYS"."KU$_USER_MAPPING_VIEW"               5.867 KB      24 rows in 1 seconds using external_table
21-JUN-24 10:09:22.281: W-1 . . exported "SYS"."DAM_CONFIG_PARAM$"                   6.539 KB      14 rows in 0 seconds using direct_path
21-JUN-24 10:09:22.300: W-1 . . exported "SYS"."TSDP_SUBPOL$"                        6.328 KB       1 rows in 0 seconds using direct_path
21-JUN-24 10:09:22.318: W-1 . . exported "SYS"."TSDP_PARAMETER$"                     5.953 KB       1 rows in 0 seconds using direct_path
21-JUN-24 10:09:22.337: W-1 . . exported "SYS"."TSDP_POLICY$"                        5.921 KB       1 rows in 0 seconds using direct_path
21-JUN-24 10:09:22.392: W-1 . . exported "AUDSYS"."AUD$UNIFIED":"AUD_UNIFIED_P0"     50.95 KB       0 rows in 0 seconds using direct_path
21-JUN-24 10:09:22.419: W-1 . . exported "SYS"."AUD$"                                23.46 KB       0 rows in 0 seconds using direct_path
21-JUN-24 10:09:22.437: W-1 . . exported "SYS"."DAM_CLEANUP_EVENTS$"                 7.187 KB       0 rows in 0 seconds using direct_path
21-JUN-24 10:09:22.456: W-1 . . exported "SYS"."DAM_CLEANUP_JOBS$"                   7.179 KB       0 rows in 0 seconds using direct_path
21-JUN-24 10:09:22.459: W-1 . . exported "SYS"."TSDP_ASSOCIATION$"                       0 KB       0 rows in 0 seconds using direct_path
21-JUN-24 10:09:22.461: W-1 . . exported "SYS"."TSDP_CONDITION$"                         0 KB       0 rows in 0 seconds using direct_path
21-JUN-24 10:09:22.463: W-1 . . exported "SYS"."TSDP_FEATURE_POLICY$"                    0 KB       0 rows in 0 seconds using direct_path
21-JUN-24 10:09:22.465: W-1 . . exported "SYS"."TSDP_PROTECTION$"                        0 KB       0 rows in 0 seconds using direct_path
21-JUN-24 10:09:22.467: W-1 . . exported "SYS"."TSDP_SENSITIVE_DATA$"                    0 KB       0 rows in 0 seconds using direct_path
21-JUN-24 10:09:22.470: W-1 . . exported "SYS"."TSDP_SENSITIVE_TYPE$"                    0 KB       0 rows in 0 seconds using direct_path
21-JUN-24 10:09:22.472: W-1 . . exported "SYS"."TSDP_SOURCE$"                            0 KB       0 rows in 0 seconds using direct_path
21-JUN-24 10:09:22.475: W-1 . . exported "SYSTEM"."REDO_DB"                              0 KB       0 rows in 0 seconds using direct_path
21-JUN-24 10:09:22.478: W-1 . . exported "SYSTEM"."REDO_LOG"                             0 KB       0 rows in 0 seconds using direct_path
21-JUN-24 10:09:22.592: W-1 . . exported "SYS"."AUDTAB$TBS$FOR_EXPORT"               5.960 KB       2 rows in 0 seconds using external_table
21-JUN-24 10:09:22.599: W-1 . . exported "SYS"."DBA_SENSITIVE_DATA"                      0 KB       0 rows in 0 seconds using external_table
21-JUN-24 10:09:22.607: W-1 . . exported "SYS"."DBA_TSDP_POLICY_PROTECTION"              0 KB       0 rows in 0 seconds using external_table
21-JUN-24 10:09:22.612: W-1 . . exported "SYS"."FGA_LOG$FOR_EXPORT"                      0 KB       0 rows in 0 seconds using external_table
21-JUN-24 10:09:22.662: W-1 . . exported "SYS"."NACL$_ACE_EXP"                           0 KB       0 rows in 0 seconds using external_table
21-JUN-24 10:09:22.730: W-1 . . exported "SYS"."NACL$_HOST_EXP"                      6.914 KB       1 rows in 0 seconds using external_table
21-JUN-24 10:09:22.733: W-1 . . exported "SYS"."NACL$_WALLET_EXP"                        0 KB       0 rows in 0 seconds using external_table
21-JUN-24 10:09:22.737: W-1 . . exported "SYS"."SQL$TEXT_DATAPUMP"                       0 KB       0 rows in 0 seconds using external_table
21-JUN-24 10:09:22.741: W-1 . . exported "SYS"."SQL$_DATAPUMP"                           0 KB       0 rows in 0 seconds using external_table
21-JUN-24 10:09:22.745: W-1 . . exported "SYS"."SQLOBJ$AUXDATA_DATAPUMP"                 0 KB       0 rows in 0 seconds using external_table
21-JUN-24 10:09:22.749: W-1 . . exported "SYS"."SQLOBJ$DATA_DATAPUMP"                    0 KB       0 rows in 0 seconds using external_table
21-JUN-24 10:09:22.753: W-1 . . exported "SYS"."SQLOBJ$PLAN_DATAPUMP"                    0 KB       0 rows in 0 seconds using external_table
21-JUN-24 10:09:22.757: W-1 . . exported "SYS"."SQLOBJ$_DATAPUMP"                        0 KB       0 rows in 0 seconds using external_table
21-JUN-24 10:09:22.792: W-1 . . exported "SYSTEM"."SCHEDULER_JOB_ARGS"                   0 KB       0 rows in 0 seconds using external_table
21-JUN-24 10:09:22.922: W-1 . . exported "SYSTEM"."SCHEDULER_PROGRAM_ARGS"           9.507 KB      12 rows in 0 seconds using external_table
21-JUN-24 10:09:22.948: W-1 . . exported "SYSTEM"."TRACKING_TAB"                     5.507 KB       1 rows in 0 seconds using direct_path
21-JUN-24 10:09:23.732: W-1      Completed 1 DATABASE_EXPORT/EARLY_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA objects in 1 seconds
21-JUN-24 10:09:23.734: W-1      Completed 17 DATABASE_EXPORT/NORMAL_OPTIONS/TABLE_DATA objects in 0 seconds
21-JUN-24 10:09:23.736: W-1      Completed 15 DATABASE_EXPORT/NORMAL_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA objects in 0 seconds
21-JUN-24 10:09:23.737: W-1      Completed 1 DATABASE_EXPORT/SCHEMA/TABLE/TABLE_DATA objects in 0 seconds
21-JUN-24 10:09:24.518: W-1 Master table "FTEXUSER"."SYS_EXPORT_FULL_01" successfully loaded/unloaded
21-JUN-24 10:09:24.520: ******************************************************************************
21-JUN-24 10:09:24.521: Dump file set for FTEXUSER.SYS_EXPORT_FULL_01 is:
21-JUN-24 10:09:24.522:   /home/oracle/m5/m5dir/exp_FTEX_240621100752.dmp
21-JUN-24 10:09:24.522: ******************************************************************************
21-JUN-24 10:09:24.523: Datafiles required for transportable tablespace USERS:
21-JUN-24 10:09:24.525:   /u02/oradata/FTEX/users01.dbf
21-JUN-24 10:09:24.531: Job "FTEXUSER"."SYS_EXPORT_FULL_01" successfully completed at Fri Jun 21 10:09:24 2024 elapsed 0 00:01:24


BACKUP_TYPE	     INPUT_BYTES(MB) OUTPUT_BYTES(MB) STATUS		      START_TIME	  END_TIME	      ELAPSED_TIME(Min)
-------------------- --------------- ---------------- ----------------------- ------------------- ------------------- -----------------
DATAFILE FULL		  20.3671875	     .0546875 COMPLETED 	      06/21/2024:10:07:57 06/21/2024:10:07:58		    .01

OUTAGE END


cd cmd
export L1FSCRIPT=$(ls -tr restore_L1F* | tail -1) 

. cdb23

cd /home/oracle/m5
rman target "sys/oracle@'localhost/violet'" cmdfile=/home/oracle/m5/cmd/$L1FSCRIPT


Use pre-created impdp file
cd /home/oracle/m5
cp /home/oracle/scripts/DBMIG-impdp-sh.txt impdp.sh

cat impdp.sh

$ head -22 impdp.sh
#!/bin/bash

if [ $# -ne 4 ]; then
        echo "Please call this script using the syntax $0 "
        echo "Example: # sh impdp.sh <expdp_dumpfile> <rman_last_restore_log> [run|test|run-readonly|test-readonly] <encryption_pwd_prompt[Y|N]>"
        exit 1
fi

#Full path to Oracle Home
export ORACLE_HOME=/u01/app/oracle/product/19
export PATH=$PATH:$ORACLE_HOME/bin
#SID of the destination database
export ORACLE_SID=CDB23
#Connect string to destination database. If PDB, connect directly into PDB
export ORACLE_CONNECT_STRING=localhost/violet
#Data Pump directory
export DATA_PUMP_DIR=M5DIR
#Data Pump parallel setting
export DATA_PUMP_PARALLEL=4
#Data Pump trace level. 0 to disable. 3FF0300 for transportable tablespace trace
export DATA_PUMP_TRACE=0


[CDB23:oracle@holserv1:~/m5]$ ./impdp.sh
Please call this script using the syntax ./impdp.sh
Example: # sh impdp.sh <expdp_dumpfile> <rman_last_restore_log> [run|test|run-readonly|test-readonly] <encryption_pwd_prompt[Y|N]>

cd m5dir/
[CDB23:oracle@holserv1:~/m5/m5dir]$ ll
total 2776
-rw-r-----. 1 oracle oinstall 2826240 Jun 21 10:09 exp_FTEX_240621100752.dmp
-rw-r--r--. 1 oracle oinstall   13839 Jun 21 10:09 exp_FTEX.log
[CDB23:oracle@holserv1:~/m5/m5dir]$ export DMPFILE=$(ls -tr exp_FTEX*dmp)
[CDB23:oracle@holserv1:~/m5/m5dir]$ echo $DMPFILE
exp_FTEX_240621100752.dmp

cd ../log
ll restore_L1F*log
export L1FLOGFILE=$(ls -tr restore_L1F*log)

cd ..
$ ./impdp.sh $DMPFILE log/$L1FLOGFILE test-readonly N
Running in test mode with read only, check par file for correctness


$ cat $(ls -tr imp_CDB23*xtts.par | tail -1)
userid='system@localhost/violet'
dumpfile=exp_FTEX_240621100752.dmp
TRANSPORTABLE=KEEP_READ_ONLY
directory=M5DIR
LOGTIME=ALL
TRACE=0
PARALLEL=4
LOGFILE=imp_CDB23_240621101933_xtts.log
METRICS=YES
ENCRYPTION_PWD_PROMPT=NO
TRANSPORT_DATAFILES=
'/u01/app/oracle/oradata/CDB23/1677972AFD1B4805E065000000000001/datafile/o1_mf_users_m7bhc8p0_.dbf'

. cdb23
$ ./impdp.sh $DMPFILE log/$L1FLOGFILE run-readonly N






    
    
    
    
    
    
    
    
    
    
    
    
    You may now *proceed to the next lab*.

## Acknowledgements

* **Author** - Daniel Overby Hansen
* **Contributors** - Klaus Gronau, Rodrigo Jorge, Mike Dietrich
* **Last Updated By/Date** - Daniel Overby Hansen, July 2024
