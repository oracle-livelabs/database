# Prepare Phase  

## Introduction
"__PREPARE PHASE__" is the first phase in the XTTS transfer. You're going to back up on source database the datafiles belonging to the tablespaces you want to transfer using XTTS. After a successful backup you're going to restore them on the target database side. <br>
During this complete process the source database remains active and everyone can continue to use it.

Estimated Time: 15 minutes

### Objectives

- Create XTTS V4 properties file.
- Execute initial backup and restore.


### Prerequisites

This lab assumes you have:

- Connected to the Hands On Lab
- A terminal window open to source.
- Another terminal window open to target
- Source and target prepared.
- XTTS prechecks done


## Task 1: XTTS Properties File (SOURCE)
On source change into the XTTS Source directory and copy the xtt.properties containing all necessary parameters to run this lab.

  ```
    <copy>
     cd /home/oracle/XTTS/SOURCE
    </copy>
  ```
![change into XTTS source dir](./images/switch-src-xtts-dir.png " ")

  ```
    <copy>
     cp /home/oracle/XTTS/xtt.properties .
    </copy>
  ```
![DBTIMEZONE output source](./images/cpy-xtt-properties.png " ")

<details>
 <summary>*click here to see the xtt.properties file content*</summary>


  ``` text
    ## xtt.properties
    ## (Doc ID 2471245.1)
    ##
    ## Properties file for xttdriver.pl
    ##
    ## Properties to set are the following:
    ##   tablespaces
    ##   platformid
    ##   dest_datafile_location
    ##   dest_datafile_location
    ##   dest_scratch_location
    ##   cnvinst_home
    ##   cnvinst_sid
    ##   asm_home
    ##   asm_sid
    ##   parallel
    ##   rollparallel
    ##   getfileparallel
    ##   metatransfer
    ##   destuser
    ##   desthost
    ##   desttmpdir
    ##   srcconnstr
    ##   destconnstr
    ##   allowstandby
    ##   usermantransport
    ##
    ## See documentation below and My Oracle Support Note 2471245.1 for details on V4.
    ##
    ##
    ##
    ## Next parameters are needed ONLY when using dbms_file_transfer package
    ## source database directory pointing to the SOURCE datafile location
    ##
    ## srcdir=XTTS_SOURCE_DIR1
    ##
    ## target database directory pointing to the TARGET datafile location
    ##
    ## dstdir=XTTS_TARGET_DIR
    ## srclink=XTTS_SOURCE_LNK
    ## Tablespaces to transport
    ## ========================
    ##
    ## tablespaces
    ## -----------
    ## Comma separated list of tablespaces to transport from source database to destination databa
    ## Do NOT use quotes
    ## Specify tablespace names in CAPITAL letters.
    ## Be sure there are NO space between the names
    ## TABLESPACES w/o sys, system, sysaux, temp and undo - list is comma separated without spaces!
    tablespaces=TPCCTAB,USERS
    ## Source database platform ID
    ## ===========================
    ##
    ## platformid
    ## ----------
    ## Source database platform id, obtained from V$DATABASE.PLATFORM_ID
    platformid=13
    ## SOURCE system file locations
    ## ============================
    ##
    ## src_scratch_location
    ## ------------
    ## Location where datafile copies and incremental backups are created on the source system.
    ##
    ## This location may be an NFS-mounted filesystem that is shared with the
    ## destination system, in which case it should reference the same NFS location
    ## as the dest_scratch_location property for the destination system.
    src_scratch_location=/home/oracle/XTTS/RMAN
    ## DESTINATION system file locations
    ## =================================
    ##
    ## dest_datafile_location
    ## -------------
    ##
    ## This is the FINAL location of the datafiles to be used by the destination database.
    ## Be sure there are NO TRAILING space
    ## Location where the converted datafile copies will be written in the destination.
    ## If using ASM, this should be set to the disk group name:
    ## dest_datafile_location=+DATAMCH
    dest_datafile_location=/u02/oradata/CDB3/pdb3/
    ## dest_scratch_location
    ## -----------
    ## This is the location where datafile copies and backups are placed on the destination system
    ## transferred manually from the souce system.  This location must have
    ## sufficient free space to hold copies of all datafiles and backups being transported.
    ##
    ## This location may be a DBFS-mounted filesystem.
    ##
    ## This location may be an NFS-mounted filesystem that is shared with the
    ## source system in which case it should reference the same NFS location
    ## as the src_scratch_location for the source system.
    ## dest_scratch_location=/dest_backups/
    dest_scratch_location=/home/oracle/XTTS/RMAN
    ## asm_home, asm_sid
    ## -----------------
    ## Grid home and SID for the ASM instance that runs on the destination
    ## system when the destination datafiles will reside on ASM.
    ##
    #asm_home=/u01/app/11.2.0.4/grid
    #asm_sid=+ASM1
    #asm_home=/u01/app/12.1.0.2/grid
    #asm_sid=+ASM1
    ## Parallel parameters
    ## ===================
    ##
    ## parallel
    ## --------
    ## Parallel defines the channel parallelism used in copying (prepare phase),
    ## converting.
    ##
    ## Note: Incremental backup creation parallelism is defined by RMAN
    ## configuration for DEVICE TYPE DISK PARALLELISM.
    ##
    ## If undefined, default value is 8.
    parallel=8
    ## rollparallel
    ## ------------
    ## Defines the level of parallelism for the -r roll forward operation.
    ##
    ## If undefined, default value is 0 (serial roll forward).
    rollparallel=2
    ## getfileparallel
    ## ---------------
    ## Defines the level of parallelism for the -G operation
    ##
    ## If undefined, default value is 1. Max value supported is 8.
    ## This will be enhanced in the future to support more than 8
    ## depending on the destination system resources.
    #getfileparallel=4
    ## metatransfer
    ## ---------------
    ## If passwordless ssh is enabled between the source and the destination, the
    ## script can automatically transfer the temporary files and the backups from
    ## source to destination. Other parameters like desthost, desttmpdir needs to
    ## be defined for this to work. destuser is optional
    ## metatransfer=1
    #metatransfer=1
    ## destuser
    ## ---------
    ## The username that will be used for copying the files from source to dest
    ## using scp. This is optional
    ## dest_user=username
    # dest_user=DESTUSERDUMP
    ## desthost
    ## --------
    ## This will be the name of the destination host.
    ## dest_host=machinename
    #dest_host=hol.localdomain
    ## desttmpdir
    ## ---------------
    ## This should be defined to same directory as TMPDIR for getting the
    ## temporary files. The incremental backups will be copied to directory pointed
    ## by stageondest parameter.
    ## desttmpdir=/ogg/oraacs/XTTS
    #desttmpdir=DUMPTARGET/XTTS/ogg/oraacs/XTTS
    ## dumpdir
    ## ---------
    ## The directory in which the dump file be restored to. If this is not specified
    ## then TMPDIR is used.
    ## dumpdir=/ogg/oraacs/XTTS
    ## using scp. This is optional
    ## dumpdir=
    ## srcconnstr
    ## ---------
    ## Only needs to be set in CDB environment. Specifies connect string of the
    ## source pluggable database
    #srcconnstr=sys/knl_test7@cdb1_pdb1
    ## destconnstr
    ## ---------
    ## Only needs to be set in CDB environment. Specifies connect string of the
    ## destination pluggable database
    destconnstr=sys/oracle@pdb3
    ## allowstandby
    ## ---------
    ## This will allow the script to be run from standby database.
    ## allowstandby=1
    ## usermantransport
    ## -----------------
    ## This should be set if using 12c.
    #usermantransport=1
    ## usermantransport=1
  ```
</details>

<details>
 <summary>*click here if you want to see the xtt.properties parameters you're going to use in this lab and a short description*</summary>


| Parameter | Comment |
| :-------- | :-----|
| tablespaces=TPCCTAB,USERS | Comma separated list of tablespaces to transport from source database to destination database |
| platformid=13 | Source database platform id, obtained from V$DATABASE.PLATFORM_ID |
| src_scratch_location=/home/oracle/XTTS/RMAN | Location where datafile copies and incremental backups are created on the source system |
| dest_datafile_location=/u02/oradata/CDB3/pdb3/ | This is the FINAL location of the datafiles to be used by the destination database |
| parallel=8 | Parallel defines the channel parallelism used in copying (prepare phase), converting (NOT RMAN) |
| rollparallel=2 | Defines the level of parallelism for the roll forward operation |
| destconnstr=sys/oracle@pdb3 | Only needs to be set in CDB environment. Specifies connect string of the destination pluggable database |
{: title="xtts.properties parameters used in this lab"}

</details>



## Task 2: Initial Backup (SOURCE)
While the source database remains active, you're now going to back it up for the first time:


  ```
    <copy>
     cd /home/oracle/XTTS/SOURCE
     export XTTDEBUG=0
     export TMPDIR=${PWD}/tmp
    </copy>

    Hit ENTER/RETURN to execute ALL commands.
  ```
![prepare initial backup](./images/prepare-phase-backup-src.png " ")
  ```
    <copy>
     $ORACLE_HOME/perl/bin/perl xttdriver.pl --backup -L
    </copy>
  ```

![Starting initial backup](./images/initial-backup.png " ")

<details>
 <summary>*click here to open/close the full backup log*</summary>

  ```text
    [UPGR] oracle@hol:~/XTTS/SOURCE
    $ $ORACLE_HOME/perl/bin/perl xttdriver.pl --backup -L
    ============================================================
    trace file is /home/oracle/XTTS/SOURCE/tmp/backup_Jun5_Mon_14_46_08_289//Jun5_Mon_14_46_08_289_.log
    =============================================================

    --------------------------------------------------------------------
    Parsing properties
    --------------------------------------------------------------------


    --------------------------------------------------------------------
    Done parsing properties
    --------------------------------------------------------------------


    --------------------------------------------------------------------
    Checking properties
    --------------------------------------------------------------------


    --------------------------------------------------------------------
    Done checking properties
    --------------------------------------------------------------------


    --------------------------------------------------------------------
    Starting prepare phase
    --------------------------------------------------------------------

    scalar(or2
    XXX: adding here for 2, 0, TPCCTAB,USERS

    --------------------------------------------------------------------
    Find list of datafiles in system
    --------------------------------------------------------------------

    sqlplus -L -s  / as sysdba  @/home/oracle/XTTS/SOURCE/tmp/backup_Jun5_Mon_14_46_08_289//diff.sql /u02/oradata/CDB3/pdb3/

    --------------------------------------------------------------------
    Done finding list of datafiles in system
    --------------------------------------------------------------------

    Prepare source for Tablespaces:
                      'TPCCTAB'  /home/oracle/XTTS/DUMP
    xttpreparesrc.sql for 'TPCCTAB' started at Mon Jun  5 14:46:08 2023
    xttpreparesrc.sql for  ended at Mon Jun  5 14:46:08 2023
    Prepare source for Tablespaces:
                      'USERS'  /home/oracle/XTTS/DUMP
    xttpreparesrc.sql for 'USERS' started at Mon Jun  5 14:46:27 2023
    xttpreparesrc.sql for  ended at Mon Jun  5 14:46:27 2023
    Prepare source for Tablespaces:
                      ''''  /home/oracle/XTTS/DUMP
    xttpreparesrc.sql for '''' started at Mon Jun  5 14:46:32 2023
    xttpreparesrc.sql for  ended at Mon Jun  5 14:46:32 2023
    Prepare source for Tablespaces:
                      ''''  /home/oracle/XTTS/DUMP
    xttpreparesrc.sql for '''' started at Mon Jun  5 14:46:33 2023
    xttpreparesrc.sql for  ended at Mon Jun  5 14:46:33 2023
    Prepare source for Tablespaces:
                      ''''  /home/oracle/XTTS/DUMP
    xttpreparesrc.sql for '''' started at Mon Jun  5 14:46:34 2023
    xttpreparesrc.sql for  ended at Mon Jun  5 14:46:34 2023

    --------------------------------------------------------------------
    Done with prepare phase
    --------------------------------------------------------------------

    Prepare newscn for Tablespaces: 'TPCCTAB'
    Prepare newscn for Tablespaces: 'USERS'
    Prepare newscn for Tablespaces: ''''''''''''
    New /home/oracle/XTTS/SOURCE/tmp/xttplan.txt with FROM SCN's generated
    scalar(or2
    XXX: adding here for 2, 0, TPCCTAB,USERS
    Added fname here 1:/home/oracle/XTTS/DUMP/USERS_4.tf
    Added fname here 1:/home/oracle/XTTS/DUMP/TPCCTAB_5.tf
    ============================================================
    No new datafiles added
    =============================================================
    [UPGR] oracle@hol:~/XTTS/SOURCE
  ```
</details>




## Task 3: Initial Restore (TARGET)
The initial restore on Target requires the "xtt.properties" and "res.txt" file from source. In this hands on lab exercise the source and target machine are the same, so you can simply use the copy command:


  ```
    <copy>
     cd /home/oracle/XTTS/TARGET/
    </copy>
  ```

![changing to the target XTTS directory](./images/prepare-phase-cd-target-dir.png " ")

  ```
    <copy>
     cp /home/oracle/XTTS/SOURCE/xtt.properties /home/oracle/XTTS/TARGET/xtt.properties 
    </copy>
  ```
![copying xtt.properties from source to target](./images/cpy-xtt-properties-src-trg.png " ")

  ```
    <copy>
     cp /home/oracle/XTTS/SOURCE/tmp/res.txt /home/oracle/XTTS/TARGET/tmp/res.txt
    </copy>
  ```


![copying rest.txt from source to target](./images/cpy-res-txt-src-trg.png " ")

Starting restore:
  ```
    <copy>
     cd /home/oracle/XTTS/TARGET
     export XTTDEBUG=0
     export TMPDIR=${PWD}/tmp
    </copy>

    Hit ENTER/RETURN to execute ALL commands.
  ```
![set restore environment on target](./images/env-initial-restore.png " ")

  ```
    <copy>
     $ORACLE_HOME/perl/bin/perl xttdriver.pl --restore -L
    </copy>
  ```
![executing initial restore on target](./images/initial-restore.png " ")

<details>
 <summary>*click here to open the full restore log*</summary>

  ```text
[CDB3] oracle@hol:~/XTTS/TARGET
$ $ORACLE_HOME/perl/bin/perl xttdriver.pl --restore -L
============================================================
trace file is /home/oracle/XTTS/TARGET/tmp/restore_Jun5_Mon_15_23_48_597//Jun5_Mon_15_23_48_597_.log
=============================================================

--------------------------------------------------------------------
Parsing properties
--------------------------------------------------------------------


--------------------------------------------------------------------
Done parsing properties
--------------------------------------------------------------------


--------------------------------------------------------------------
Checking properties
--------------------------------------------------------------------


--------------------------------------------------------------------
Done checking properties
--------------------------------------------------------------------


--------------------------------------------------------------------
Performing convert for file 4
--------------------------------------------------------------------


--------------------------------------------------------------------
Performing convert for file 5
--------------------------------------------------------------------

[CDB3] oracle@hol:~/XTTS/TARGET

  ```
</details>


## Summary of this Lab

In this lab you executed the initial backup and restore using the parameter file xtt.properties containing information about the tablespaces you want to transfer:

![source xtt.properties file](./images/initial-backup-restore.png " ")

### Backup (SOURCE)
On Source we created the xtt.properties file:

  ```
    <copy>
    ls -al /home/oracle/XTTS/SOURCE/xtt.properties
    </copy>
  ```
![source xtt.properties file](./images/ls-src-xtt-properties.png " ")

Listing the directory content created in the RMAN backup location:

  ```
    <copy>
    ls -al /home/oracle/XTTS/RMAN
    </copy>
  ```
![RMAN backup datafiles](./images/ls-rman-src.png " ")

and the another mandatory driving file for the restore - the res.txt file - plus all log files of the backup are located in:
  ```
    <copy>
    ls -al /home/oracle/XTTS/SOURCE/tmp/
    </copy>
  ```
![xtts source tmp directory content](./images/ls-xtts-tmp-src.png " ")



#### Restore (TARGET)
You copied the xtt.properties and the res.txt file from source to target. RMAN read the same files the backup process created - so these files match between source and target. An interesting directory created by the restore process is the target XTTS/tmp directory containing the log files:
  ```
    <copy>
    ls -al /home/oracle/XTTS/TARGET/tmp
    </copy>
  ```
![RMAN backup datafiles](./images/ls-prepare-target-tmp-dir.png " ")


You may now *proceed to the next lab*.




## Acknowledgements
* **Author** - Klaus Gronau
* **Contributors** -  
* **Last Updated By/Date** - Klaus Gronau, June 2023
