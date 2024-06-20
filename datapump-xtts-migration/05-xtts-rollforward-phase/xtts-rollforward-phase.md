# Roll Forward Phase  

## Introduction

In the roll forward phase, the source database remains active. You can take as many incremental backups and restores as you like. 
A good practice is to start the migration some time before the cutover. Run an initial backup and restore and then run these incremental backup and restore operations a few times during the day. On the cutover day, minimize the time required for this process by increasing the frequency. For example, do it every hour.

Estimated Time: 15 minutes

[](videohub:1_ci5d8y73)

### Objectives

- Execute incremental backup and restore.


### Prerequisites

This lab assumes you have:

- Connected to the lab
- A terminal window open on the source
- Another terminal window open on the target
- Prepared the source
- Successfully executed initial backup (prepare phase)
- Successfully executed initial restore (prepare phase)


## Task 1: Adding Table and Data File to Source Database (SOURCE)
In this (and the previous) phase, the database is up, and there is no downtime yet. Users make changes in the source database. Let's simulate that by creating a table and adding a data file.

1. Start SQL\*Plus (SOURCE) </br>
Connect with SQL*Plus as TPCC user to the source database:

    ```
    <copy>
    sqlplus  TPCC/oracle
    </copy>
    ```

    ![connecting to source database](./images/roll-forward-open-sqlplus-src.png " ")

2. Add a New Table (SOURCE)

    ```
    <copy>
    create table object_copy as select * from user_objects;
    </copy>
    ```

    ![creating a new table in TPCC acount](./images/cre-object-copy.png " ")

3. Connect a sysdba (SOURCE) </br>
This time connect as sysdba to the source database:

    ```
    <copy>
    connect / as sysdba 
    </copy>
    ```

    ![connect as sysdba to source](./images/roll-forward-sysdba-conn.png " ")

4. Add a New Data File (SOURCE) </br>
and execute:

    ```
    <copy>
    alter tablespace TPCCTAB add datafile '/u02/oradata/UPGR/tpcctab02.dbf' size 1M;
    exit;
    </copy>

    Hit ENTER/RETURN to execute ALL commands.
    ```

    ![adding new datafile to TBS TPCCTAB](./images/roll-forward-add-datafile.png " ")


## Task 2: Incremental Backup (SOURCE) 
On source change into the XTTS Source directory and execute the incremental backup:

1. Setting Environment for Incremental Backup (SOURCE)

    ```
    <copy>
    cd /home/oracle/xtts/source
    export XTTDEBUG=0
    export TMPDIR=${PWD}/tmp
    </copy>

    Hit ENTER/RETURN to execute ALL commands.
    ```

    ![starting incremental backup](./images/env-incremental-backup.png " ")

2. Starting Incremental Backup (SOURCE)

    ```
    <copy>
    $ORACLE_HOME/perl/bin/perl xttdriver.pl --backup -L
    </copy>
    ```

    ![starting incremental backup](./images/incremental-backup.png " ")

    <details>
    <summary>*click here to see the full incremental backup log file*</summary>

      ``` text
    [UPGR] oracle@hol:~/xtts/source
    $ $ORACLE_HOME/perl/bin/perl xttdriver.pl --backup -L
    ============================================================
    trace file is /home/oracle/xtts/source/tmp/backup_Jun28_Wed_14_45_44_65//Jun28_Wed_14_45_44_65_.log
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
    Added fname here 1:/home/oracle/xtts/rman/USERS_4.tf
    Added fname here 1:/home/oracle/xtts/rman/TPCCTAB_5.tf
    Added fname here 2:/home/oracle/xtts/rman/TPCCTAB_6.tf , fname is /u02/oradata/CDB3/pdb3/TPCCTAB_6.dbf
    ============================================================
    1 new datafiles added
    =============================================================
    TPCCTAB,/home/oracle/xtts/rman/TPCCTAB_6.tf
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
    New /home/oracle/xtts/source/tmp/xttplan.txt with FROM SCN's generated
    [UPGR] oracle@hol:~/xtts/source
    $
      ```
    </details>

    When you look at the log file, you see the XTTS script managed everything for you. It recognized you added a new data file to the tablespace, and it took care of it.

## Task 3: Incremental Restore (TARGET)

The incremental restore needs the "res.txt" and "incrbackups.txt" files from the source. Both are the driving files for the XTTS process.
You just performed your first incremental backup, so there's no previous version of "incrbackups.txt" file. <br>
But the initial load already created the res.txt and you probably remember that you copied it already from source to target in the previous lab. So, let's compare both before starting the restore....

### Comparing Source and Target res.txt
So before overwriting __res.txt__ on target, let's check out the content of this file on source and target:

Source:

  ```
   <copy>
   cat /home/oracle/xtts/source/tmp/res.txt 
   </copy>
  ```

![res.txt content on source](./images/res-txt-src.png " ") 

Target:

  ```
  <copy>
  cat /home/oracle/xtts/target/tmp/res.txt
  </copy>
  ```

![res.txt content on target](./images/res-txt-trg.png " ") 

Take a closer look at both output files posted next to each other below. The first two lines match and contain details from your initial backup taken during the prepare phase. <br>
The difference between source and target res.txt starts in line three beginning with "#0:::6". The roll forward phase added this entry. It is the initial copy of the newly added datafile. In addition, you'll see an incremental backup of all data files marked with "#1":

| res.txt source | res.txt target |
| :--------: | :-----:|
| ![res.txt content on source](./images/res-txt-src.png " ")  | ![res.txt content on target](./images/res-txt-trg.png " ") |
{: title="Comparing res.txt between source and target"}




1. Copy "res.txt" (TARGET) </br>
So let's continue with the process and copy the updated res.txt and the newly created incrbackups.txt from the source to the target directory:

    ```
    <copy>
    cp /home/oracle/xtts/source/tmp/res.txt /home/oracle/xtts/target/tmp/res.txt
    </copy>
    ```

    ![copying rest.txt from source to target](./images/copy-res-txt.png " ") 

2. Copy "incrbackups.txt" (TARGET)

    ```
    <copy>
    cp /home/oracle/xtts/source/tmp/incrbackups.txt /home/oracle/xtts/target/tmp/incrbackups.txt
    </copy>
    ```

    ![copying incrbackups.txt and rest.txt from source to target](./images/copy-incrbackups-txt.png " ") 

3. Start Incremental Restore (TARGET) </br>
Set the incremental restore environment:

    ```
    <copy>
    cd /home/oracle/xtts/target
    export XTTDEBUG=0
    export TMPDIR=${PWD}/tmp
    </copy>

    Hit ENTER/RETURN to execute ALL commands.
    ```


    ![setting incremental restore env](./images/env-incremental-restore.png " ")

    and start the restore:

    ```
    <copy>
    $ORACLE_HOME/perl/bin/perl xttdriver.pl --restore -L
    </copy>
    ```

    ![starting incremental restore](./images/incremental-restore.png " ")

    <details>
    <summary>*click here to see the full incremental restore log file*</summary>

      ``` text
    [CDB3] oracle@hol:~/xtts/target
    $ $ORACLE_HOME/perl/bin/perl xttdriver.pl --restore -L
    ============================================================
    trace file is /home/oracle/xtts/target/tmp/restore_Jun28_Wed_15_13_32_781//Jun28_Wed_15_13_32_781_.log
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

    [CDB3] oracle@hol:~/xtts/target
    $
      ```
    </details>


You can execute the incremental backup and restore whenever you want. As they will minimize your downtime window, you can run them on the cutover day more frequently to minimize the delta.

## Summary of this Lab
In this lab, you executed an incremental backup and restore. You can repeat this process more often and more frequently on the cutover day. </br>
The only requirement for each incremental restore is the current res.txt and incrbackup.txt from the backup.

![incremental backup restore process flow](./images/incremental-backup-restore.png " ")

### Backup (SOURCE)
On source, you used the xtt.properties file created in the previous lab without updating it (no new tablespace was added; only a datafile and the script handled it automatically):

  ```
    <copy>
    ls -al /home/oracle/xtts/source/xtt.properties
    </copy>
  ```

![source xtt.properties file](./images/ls-src-xtt-properties.png " ")

Listing the directory content created in the RMAN backup location containing the backup of the datafiles and the incremental backup(s):

  ```
    <copy>
    ls -al /home/oracle/xtts/rman
    </copy>
  ```

![RMAN backup datafiles](./images/roll-forward-incr-backup-files.png " ")


and the other two mandatory driving files for the restore - the res.txt and incrbackup.txt file - plus all log files of the backup are located in:
  ```
    <copy>
    ls -al /home/oracle/xtts/source/tmp/
    </copy>
  ```

![xtts source tmp directory content](./images/roll-forward-ls-src.png " ")



### Restore (TARGET)
You copied the xtt.properties and the res.txt file from source to target. RMAN restore read from the same location where the backup process created the incremental backup files - so all these files match on source and target. </br>
An interesting directory created by the restore process is in the target XTTS/tmp directory containing the log files:
  ```
    <copy>
    ls -al /home/oracle/xtts/target/tmp
    </copy>
  ```

![RMAN backup datafiles](./images/roll-forward-ls-target.png " ")

The first directory belongs to the restore executed in the prepare phase, and the second one to the incremental backup from the roll forward phase.


You may now *proceed to the next lab*.


## Acknowledgments
* **Author** - Daniel Overby Hansen
* **Contributors** - Klaus Gronau, Rodrigo Jorge, Mike Dietrich
* **Last Updated By/Date** - Daniel Overby Hansen, July 2024
