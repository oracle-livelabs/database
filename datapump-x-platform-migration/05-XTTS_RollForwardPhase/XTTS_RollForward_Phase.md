# Roll Forward Phase  

## Introduction

In the roll forward phase the source database remains active. You can take as many incremental backups and restores as you like. 
A good practice is to start the migration some time before the cutover. Run an initial backup and restore and run these incremental backup and restore operations a few times during the day. On the cutover day minimize the delta by for example running these incremental backup/restore commands every hour.

Estimated Time: 15 minutes

### Objectives

- Execute incremental backup and restore.


### Prerequisites

This lab assumes you have:

- Connected to the Hands On Lab
- A terminal window open on source.
- Another terminal window open on target
- Prepared the source
- Successfully executed initial backup
- Successfully executed initial restore

## Task 0: Adding Table and Data File to Source Database
As mentioned, in this phase the database is up and open so everyone can use it. Let's do some changes in the source database... 

### Add a New Table
Connect with SQL*Plus as TPCC user to the source database:
  ```
    <copy>
     sqlplus  TPCC/oracle
     
    </copy>
  ```
and create a table:
  ```
    <copy>
     create table object_copy as select * from user_objects;
     exit;

    </copy>
  ```

![new_table](./images/cre_oject_copy.png " ")

### Add a New Data File
This time connect as sysdba to the source database:
  ```
    <copy>
     sqlplus  / as sysdba 
     
    </copy>
  ```
and execute:
  ```
    <copy>
     alter tablespace TPCCTAB add datafile '/u02/oradata/UPGR/tpcctab02.dbf' size 1M;
     exit;
    </copy>
  ```

![new_datafile](./images/add_datafile_tbs.png " ")


## Task 1: Incremental Backup on Source
On source change into the XTTS Source directory and execute the incremental backup:

  ```
    <copy>
     cd /home/oracle/XTTS/SOURCE
     export XTTDEBUG=0
     export TMPDIR=${PWD}/tmp
     $ORACLE_HOME/perl/bin/perl xttdriver.pl --backup -L

    </copy>
  ```

![incremental_backup](./images/incremental_backup.png " ")

<details>
 <summary>*click here to see the full incremental backup log file*</summary>

  ``` text
    [UPGR] oracle@hol:~/XTTS/SOURCE
    $ $ORACLE_HOME/perl/bin/perl xttdriver.pl --backup -L
    ============================================================
    trace file is /home/oracle/XTTS/SOURCE/tmp/backup_Jun5_Mon_15_40_20_162//Jun5_Mon_15_40_20_162_.log
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
    Backup incremental
    --------------------------------------------------------------------
    
    scalar(or2
    XXX: adding here for 2, 0, TPCCTAB,USERS
    Added fname here 1:/home/oracle/XTTS/RMAN/USERS_4.tf
    Added fname here 1:/home/oracle/XTTS/RMAN/TPCCTAB_5.tf
    Added fname here 2:/home/oracle/XTTS/RMAN/TPCCTAB_6.tf , fname is /u02/oradata/CDB3/pdb3/TPCCTAB_6.dbf
    ============================================================
    1 new datafiles added
    =============================================================
    TPCCTAB,/home/oracle/XTTS/RMAN/TPCCTAB_6.tf
    ============================================================
    Running prepare cmd for new filesx TPCCTAB_6.tf
    =============================================================
    Adding file to transfer:TPCCTAB_6.tf
    Prepare newscn for Tablespaces: 'TPCCTAB'
    Prepare newscn for Tablespaces: 'USERS'
    Prepare newscn for Tablespaces: ''''
    Prepare newscn for Tablespaces: ''''
    Prepare newscn for Tablespaces: ''''
    
    --------------------------------------------------------------------
    Starting incremental backup
    --------------------------------------------------------------------
    
    
    --------------------------------------------------------------------
    Done backing up incrementals
    --------------------------------------------------------------------
    
    Prepare newscn for Tablespaces: 'TPCCTAB'
    Prepare newscn for Tablespaces: 'USERS'
    Prepare newscn for Tablespaces: ''''''''''''
    New /home/oracle/XTTS/SOURCE/tmp/xttplan.txt with FROM SCN's generated
    [UPGR] oracle@hol:~/XTTS/SOURCE
  ```
</details>

## Task 2: Incremental Restore on Target

Open the Target console.
The incremental restore needs the "res.txt" and "incrbackups.txt" files from source. <br>
Before overwriting the files __res.txt__ and __incrbackups.txt__ on target, let's compare the source and target files:

Source:
  ```
    <copy>
     cat /home/oracle/XTTS/SOURCE/tmp/res.txt 

    </copy>
  ```
![res.txt_SRC](./images/res.txt_src.png " ") 

Target:
  ```
    <copy>
     cat /home/oracle/XTTS/TARGET/tmp/res.txt

    </copy>
  ```
![res.txt_TRG](./images/res.txt_trg.png " ") 

Take a closer look at both output files posted next to each other below. Both contain the details from your initial backup. <br>
The difference between source and target res.txt is the incremental backup entry you just executed on source plus the initial load of the newly added datafile:

![res.txt_SRC_TRG](./images/res_txt_src_trg.png " ")


So let's continue with the process and copy both files from the source to the target directory:

  ```
    <copy>
     cp /home/oracle/XTTS/SOURCE/tmp/res.txt /home/oracle/XTTS/TARGET/tmp/res.txt
     cp /home/oracle/XTTS/SOURCE/tmp/incrbackups.txt /home/oracle/XTTS/TARGET/tmp/incrbackups.txt

    </copy>
  ```

![incremental_restore_prep](./images/incr_restore_copy.png " ") 

And start the restore:
  ```
    <copy>
     export XTTDEBUG=0
     export TMPDIR=${PWD}/tmp
     $ORACLE_HOME/perl/bin/perl xttdriver.pl --restore -L

    </copy>
  ```

![incremental_restore](./images/incremental_restore.png " ")

<details>
 <summary>*click here to see the full incremental restore log file*</summary>

  ``` text
$ $ORACLE_HOME/perl/bin/perl xttdriver.pl --restore -L
============================================================
trace file is /home/oracle/XTTS/TARGET/tmp/restore_Jun5_Mon_15_59_20_665//Jun5_Mon_15_59_20_665_.log
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
Performing convert for file 6
--------------------------------------------------------------------


--------------------------------------------------------------------
Start rollforward
--------------------------------------------------------------------


--------------------------------------------------------------------
End of rollforward phase
--------------------------------------------------------------------

[CDB3] oracle@hol:~/XTTS/TARGET 
  ```
</details>


You can execute the incremental backup and restore whenever you want. As they will minimize your downtime window you can run them on the cutover day more frequently to minimize the delta.


You may now *proceed to the next lab*.


## Acknowledgements
* **Author** - Klaus Gronau
* **Contributors** -  
* **Last Updated By/Date** - Klaus Gronau, June 2023
