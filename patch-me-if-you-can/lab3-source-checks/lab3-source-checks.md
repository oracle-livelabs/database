# Lab 3 - Checks in the SOURCE Environment

## Introduction 
We will use this lab to check several things in the source environment while the installation in the new environment progresses.

## Task 1 - Checks

### Step 1: Set the Source Database Environment

Switch to the other tab titled "19.18.0 Source Home" and set the environment.
  ```
    <copy>
    . cdb2
    </copy>
  ```
  
### Step 2: Current Installed Patches

Check the installed patches in the current 19.18.0 home:
 
  ```
    <copy>
    ./OPatch/opatch lspatches
    </copy>
  ```


<details>
 <summary>*click here to see the full output*</summary>

  ``` text
35246710;HIGH DIRECT PATH READ AFTER 19.18 DBRU PATCHING
35213579;MERGE ON DATABASE RU 19.18.0.0.0 OF 35037877 35046819
35162446;NEED BEHAVIOR CHANGE TO BE SWITCHED OFF
35160800;GG IE FAILS WITH ORA-14400 AT SYSTEM.LOGMNRC_USER AFTER ORACLE DB UPGRADE TO 19.18DBRU
35156936;ORA-7445 [KFFBNEW()+351]  AFTER CONVERT TO ASM FLEX DISKGROUP
34974052;DIRECT NFS CONNECTION RESET MESSAGES
34879016;ALL SESSIONS HANG DUE TO INST_RCV BUFFER IS NOT GETTING WRITE PERMISSION
34871935;SBI  QUEUE BUILDUP - SESSIONS SPIKE WITH GC CURRENT REQUEST  (6-DEC-2022)
34861493;RESYNC CATALOG FAILED IN ZDLRA CATALOG AFTER PROTECTED DATABASE PATCHED TO 19.17
34810252;SPIN OFF FOR BUG 34808861 [ORA-00600  INTERNAL ERROR CODE, ARGUMENTS  [KFDS_GETSEGREUSEENQ01] TERMINATED ALL DB INSTANCES
34793099;STRESS FA CDB CREATION FAILS ON 19.17 WITH THE ORA-00704  BOOTSTRAP PROCESS FAILURE WHILE OPENING PDB$SEED
34783802;PARALLEL QUERY ON PARTITIONED TABLE RETURNS WRONG RESULT
34557500;CTWR CAUSED MULTIPLE INSTANCES IN HUNG STATE ON THE RAC STANDBY DATABASE
34340632;AQAH  SMART MONITORING &amp; RESILIENCY IN QUEUE KGL MEMORY USAGE
33973908;DBWR NOT PICKING UP WRITES FOR SOME TIME
32727143;TRANSACTION-LEVEL CONTENT ISOLATION FOR TRANSACTION-DURATION GLOBAL TEMPORARY TABLES
31222103;STRESS RAC ATPD FAN EVENTS ARE NOT GETTING PROCESSED WITH 21C GI AND 19.4 DB
34972375;DATAPUMP BUNDLE PATCH 19.18.0.0.0
34786990;OJVM RELEASE UPDATE: 19.18.0.0.230117 (34786990)
34765931;Database Release Update : 19.18.0.0.230117 (34765931)
29585399;OCW RELEASE UPDATE 19.3.0.0.0 (29585399)
  ```
</details>

### Step 3: Current Java Version

Check the current JDK version:
  ```
    <copy>
     $ORACLE_HOME/jdk/bin/java -version
    </copy>
  ```

<details>
 <summary>*click here to see the full output*</summary>

  ``` text
   java version "1.8.0_351"
   Java(TM) SE Runtime Environment (build 1.8.0_351-b10)
   Java HotSpot(TM) 64-Bit Server VM (build 25.351-b10, mixed mode)
   [CDB2] oracle@hol:/u01/app/oracle/product/19
  ```
</details>


### Step 4: Current Perl Version

Check the current PERL version:
  ```
    <copy>
     $ORACLE_HOME/perl/bin/perl -version
    </copy>
  ```


Take notice of the current version. We will check afterwards whether the PERL version has been updated as well. </br>
`This is perl 5, version 36, subversion 0 (v5.36.0) built for x86_64-linux-thread-multi`

### Step 5: Current Time Zone

Then check the current time zone version in the container database:

  ```
    <copy>
     sqlplus / as sysdba
     column VALUE$ format a8
     select VALUE$, CON_ID from containers(SYS.PROPS$) where NAME='DST_PRIMARY_TT_VERSION' order by CON_ID;
    </copy>

     Hit ENTER/RETURN to execute ALL commands.
  ```

Currently, the database uses the default timezone version deployed with Oracle Database 19c.
```
VALUE$	     CON_ID
-------- ----------
32		  1
32		  2
```

Close SQL*Plus:
  ```
    <copy>
     exit
    </copy>
  ```

### Step 6: Datapatch Sanity Check

And finally, you will do a `datapatch` sanity check:

  ```
    <copy>
     $ORACLE_HOME/OPatch/datapatch -sanity_checks
    </copy>
  ```


Except for the scheduler warning, everything looks good.

<details>
 <summary>*click here to see the full output*</summary>

  ``` text
$ $ORACLE_HOME/OPatch/datapatch -sanity_checks
SQL Patching sanity checks version 19.18.0.0.0 on Mon 26 Jun 2023 11:24:42 PM CEST
Copyright (c) 2021, 2023, Oracle.  All rights reserved.

Log file for this invocation: /u01/app/oracle/product/19/cfgtoollogs/sqlpatch/sanity_checks_20230626_232442_21784/sanity_checks_20230626_232442_21784.log

Running checks
Checks completed. Printing report:

Check: DB Components status - OK
Check: PDB Violations - OK
Check: System invalid objects - OK
Check: Tablespace Status - OK
Check: Backup jobs - OK
Check: Temp Datafile exists - OK
Check: Datapump running - OK
Check: Container status - OK
Check: Encryption wallet - OK
Check: Dictionary statistics gathering - OK
Check: Scheduled Jobs - NOT OK (WARNING)
  Message: There are current running or scheduled jobs set to run on the next hour. Scheduled jobs may have an impact when run during patching.
  CDB$ROOT:
    JOB_NAME,NEXT_RUN_DATE,SCHEMA_NAME,STATE
    CLEANUP_ONLINE_IND_BUILD,26-JUN-23 11.31.11.725568 PM +02:00,SYS,SCHEDULED
    CLEANUP_ONLINE_PMO,26-JUN-23 11.31.51.369376 PM +02:00,SYS,SCHEDULED
    CLEANUP_TAB_IOT_PMO,26-JUN-23 11.31.21.570852 PM +02:00,SYS,SCHEDULED
    RSE$CLEAN_RECOVERABLE_SCRIPT,27-JUN-23 12.00.00.893871 AM EUROPE/VIENNA,SYS,SCHEDULED
    SM$CLEAN_AUTO_SPLIT_MERGE,27-JUN-23 12.00.00.859886 AM EUROPE/VIENNA,SYS,SCHEDULED
Check: Optim dictionary upgrade parameter - OK
Check: Queryable Inventory locks - OK
Check: Queryable Inventory package - OK
Check: Queryable Inventory external table - OK
Check: Imperva processes - OK
Check: Guardium processes - OK
Check: Locale - OK

Refer to MOS Note and debug log
/u01/app/oracle/product/19/cfgtoollogs/sqlpatch/sanity_checks_20230626_232442_21784/sanity_checks_debug_20230626_232442_21784.log

SQL Patching sanity checks completed on Mon 26 Jun 2023 11:25:08 PM CEST
  ```
</details>




## Task 2 - Finish the Patch Installation

At this point the patching installation should be completed. Switch to the tab titled "19.19.0 Home". You should see the following output:

<details>
 <summary>*click here to see the full output*</summary>

  ``` text
$ . /home/oracle/patch/install_patch.sh 

Preparing the home to patch...
Applying the patch /home/oracle/stage/ru/35042068...
Successfully applied the patch.
Applying the patch /home/oracle/stage/ojvm/35050341...
Successfully applied the patch.
Applying the patch /home/oracle/stage/dpbp/35261302...
Successfully applied the patch.
Applying the patch /home/oracle/stage/mrp/35333937/34340632...
Successfully applied the patch.
Applying the patch /home/oracle/stage/mrp/35333937/35012562...
Successfully applied the patch.
Applying the patch /home/oracle/stage/mrp/35333937/35037877...
Successfully applied the patch.
Applying the patch /home/oracle/stage/mrp/35333937/35116995...
Successfully applied the patch.
Applying the patch /home/oracle/stage/mrp/35333937/35225526...
Successfully applied the patch.
The log can be found at: /u01/app/oraInventory/logs/InstallActions2023-06-26_10-49-18PM/installerPatchActions_2023-06-26_10-49-18PM.log
Launching Oracle Database Setup Wizard...

The response file for this session can be found at:
 /u01/app/oracle/product/1919/install/response/db_2023-06-26_10-49-18PM.rsp

You can find the log of this install session at:
 /u01/app/oraInventory/logs/InstallActions2023-06-26_10-49-18PM/installActions2023-06-26_10-49-18PM.log

As a root user, execute the following script(s):
	1. /u01/app/oracle/product/1919/root.sh

Execute /u01/app/oracle/product/1919/root.sh on the following nodes: 
[hol]


Successfully Setup Software.
  ```
</details>

### Step 1: Logon as root

Logon as `root` and type the password `oracle`:
  ```
    <copy>
     su root
    </copy>
  ```

and then enter:
  ```
    <copy>
     oracle
    </copy>
  ```

### Step 2: Execute root.sh

Then execute the root.sh script:
  ```
    <copy>
     /u01/app/oracle/product/1919/root.sh
    </copy>
  ```

Unfortunately, `root.sh` is hanging. But you can check the logfile mentioned on the screen in the other tab of your terminal window. It says:
```
Now product-specific root actions will be performed.
```

Let us ignore that and `CTRL+C` the script. It is rerunnable, and a second execution would complete. But this is not necessary. 

### Step 3: Exit from root

Exit from the `root` user and confirm that you are `oracle` again:

  ```
    <copy>
     exit
     whoami
    </copy>

     Hit ENTER/RETURN to execute ALL commands.
  ```

You may now *proceed to the next lab*



## Acknowledgements
* **Author** - Mike Dietrich 
* **Contributors** Klaus Gronau, Daniel Overby Hansen  
* **Last Updated By/Date** - Klaus Gronau, June 2023