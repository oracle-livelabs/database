# Prepare source 

## Introduction

In this lab, you will enable archive logging on source database and create the database directory for Data Pump export.

Estimated Time: 5 minutes

### Objectives

- Enable archive logging on source database

### Prerequisites

This lab assumes you have:

- Connected to the lab

## Task 1: Open Terminal Window, Create OS Source Directory and Unzip XTTS ZIP File (SOURCE)

### Open Terminal Window 
Open another terminal windows by clicking on the "Terminal" icon. <br> 
Use this second terminal window to execute all commands related to the __source__ database.

![Screenshot of the Linux Hands On Lab Terminal icon](./images/terminal.png " ")

All following screenshots related to the __source__ will have a __light blue__ background color.



### Step 1: Create OS Directories (SOURCE)
Activate the source terminal window and create three directories; one for the Data Pump metadata dump file, another one as XTTS source and a third directory for RMAN backup/restore files.

  ```
    <copy>
    mkdir -p /home/oracle/xtts/source/tmp 
    </copy>
  ```
![Create XTTS source OS Directory](./images/mkdir-xtts-src-os-dir.png " ")


  ```
    <copy>
    mkdir -p /home/oracle/xtts/dump
    </copy>
  ```
![Create source OS Directory](./images/mkdir-xtts-dump-dir.png " ")


  ```
    <copy>
    mkdir -p /home/oracle/xtts/rman
    </copy>
  ```

![Create source OS Directory](./images/mkdir-xtts-rman-dir.png " ")


### Step 2: Unzip XTTS ZIP File (SOURCE)

  ```
    <copy>
    cd /home/oracle/xtts/source/
    </copy>
  ```
![Unzipping the XTTS Perl V4 ZIP file on source](./images/change-xtts-src-dir.png " ")

  ```
    <copy>
    unzip /home/oracle/xtts/rman_xttconvert_VER4.3.zip
    </copy>
  ```
![Unzipping the XTTS Perl V4 ZIP file on source](./images/unzip-xtts-src.png " ")

## Task 2: Configure Source Database (SOURCE)
### Step 1: Set Source Environment (SOURCE)

Activate source terminal window, set the source environment and start SQL*Plus:

  ```
    <copy>
    . upgr
    </copy>
 ```
![Set source database environment](./images/source-src-env.png " ")

### Step 2: Start SQL*Plus (SOURCE)
  ```
    <copy>
    sqlplus / as sysdba
    </copy>
 ```
![Login to source 11.2.0.4 database](./images/start-sqlplus-src.png " ")


### Step 3: Database Changes (SOURCE)
Enable source database archive logging and create the database directory for Data Pump export. Also alter the TPCC user's password:


  ```
    <copy>
    startup mount
    archive log list
    alter database archivelog;
    alter database enable block change tracking;
    alter database open;
    create or replace directory "XTTS_METADATA_DIR" as '/home/oracle/xtts/dump';
    alter user tpcc identified by oracle;
    exit
    </copy>

    Hit ENTER/RETURN to execute ALL commands.
  ```

![Enabling archive logging in source database](./images/start-src-db-enable-archive.png " ")

You might also consider enabling __Block Change Tracking (BCT)__ using the command "alter database enable block change tracking".

## Task 4: Configuring Default RMAN Settings (SOURCE)
The next parameters you're going to set for RMAN work well in the lab. For your environment you might have to adopt them by increasing parallelism, the backup destination etc.

### Step 1: Open RMAN Console (SOURCE)
On source start the rman console connecting to the source database: 

  ```
    <copy>
     rman target /
    </copy>
  ```

Please be aware:
in RMAN terminology the target database identifies the database which you're going to back up - so in the migration terminology the source database. 

### Step 2: Update Default RMAN Settings

  ```
    <copy>
     configure default device type to disk;
     configure  device type disk parallelism 8;
     exit;
    </copy>

    Hit ENTER/RETURN to execute ALL commands.
  ```

![configure default RMAN parameters on source database side](./images/rman-default-target-settings.png " ")


You may now *proceed to the next lab*.


## Acknowledgements
* **Author** - Klaus Gronau
* **Contributors** -  
* **Last Updated By/Date** - Klaus Gronau, June 2023
