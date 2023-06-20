# Prepare Source 

## Introduction

In this lab, you will enable archive logging on source database and create the database directory for Data Pump export.

Estimated Time: 5 minutes

### Objectives

- Enable archive logging on source database

### Prerequisites

This lab assumes you have:

- Connected to the Hands On Lab

## Task 1: Open Terminal Window, Create OS SOURCE Directory and Unzip XTTS ZIP File (SOURCE)

### Open Terminal Window 
Open another terminal windows by clicking on the "Terminal" icon. <br> 
Use this second terminal window to execute all commands related to the __SOURCE__ database.

![Screenshot of the Linux Hands On Lab Terminal icon](./images/terminal.png " ")

All following screenshots related to the __SOURCE__ will have a __light blue__ background color.



### Create OS Directories (SOURCE)
Activate the source terminal window and create three directories; one for the Data Pump metadata dump file, another one as XTTS SOURCE and a third directory for RMAN backup/restore files.

  ```
    <copy>
    mkdir -p /home/oracle/XTTS/SOURCE/tmp 
    </copy>
  ```
![Create XTTS Source OS Directory](./images/mkdir-xtts-src-os-dir.png " ")

  ```
    <copy>
    mkdir -p /home/oracle/XTTS/DUMP
    </copy>
  ```
![Create Source OS Directory](./images/mkdir-xtts-dump-dir.png " ")

  ```
    <copy>
    mkdir -p /home/oracle/XTTS/RMAN
    </copy>
  ```

![Create Source OS Directory](./images/mkdir-xtts-rman-dir.png " ")


### Unzip XTTS ZIP file (SOURCE)

  ```
    <copy>
    cd /home/oracle/XTTS/SOURCE/
    </copy>
  ```
![Unzipping the XTTS Perl V4 ZIP file on source](./images/change-xtts-src-dir.png " ")

  ```
    <copy>
    unzip /home/oracle/XTTS/rman_xttconvert_VER4.3.zip
    </copy>
  ```
![Unzipping the XTTS Perl V4 ZIP file on source](./images/unzip-xtts-src.png " ")

## Task 2: Set the Source Database Environment (SOURCE)

Activate source terminal window, set the source environment and start SQL*Plus:

  ```
    <copy>
    . upgr
    </copy>
 ```
![Set source database environment](./images/source-src-env.png " ")

  ```
    <copy>
    sqlplus / as sysdba
    </copy>
 ```
![Login to source 11.2.0.4 database](./images/start-sqlplus-src.png " ")


## Task 3: Configure Source Database (SOURCE)
Enable source database archive logging and create the database directory for Data Pump export. Also alter the TPCC user's password:


  ```
    <copy>
    startup
    archive log list
    shutdown immediate
    STARTUP MOUNT
    ALTER DATABASE ARCHIVELOG;
    ALTER DATABASE OPEN;
    CREATE OR REPLACE DIRECTORY "XTTS_METADATA_DIR" AS '/home/oracle/XTTS/DUMP';
    alter user TPCC identified by oracle;
    exit
    </copy>

    Hit ENTER/RETURN to execute ALL commands.
  ```

![Enabling archive logging in source database](./images/start-src-db-enable-archive.png " ")

You might also consider enabling __Block Change Tracking (BCT)__ using the command "alter database enable block change tracking".

## Task 4: Configuring Default RMAN Settings (SOURCE)
The next parameters you're going to set for RMAN work well in the hands on lab. For your environment you might have to adopt them by increasing parallelism, the backup destination etc.

On source start the rman console: 

  ```
    <copy>
     rman target /
    </copy>
  ```

Please be aware:
in RMAN terminology the target database identifies the database which you're going to back up - so in the migration terminology the source database

  ```
    <copy>
     CONFIGURE DEFAULT DEVICE TYPE TO DISK;
     configure  DEVICE TYPE DISK PARALLELISM 8;
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
