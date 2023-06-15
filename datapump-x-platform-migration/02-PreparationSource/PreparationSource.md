# Prepare Source 

## Introduction

In this lab, you will enable archive logging on source database and create the database directory for Data Pump export.

Estimated Time: 5 minutes

### Objectives

- Enable archive logging on source database

### Prerequisites

This lab assumes you have:

- Connected to the Hands On Lab

## Task 1: Create OS Source Directories and Unzip XTTS ZIP File
Activate the source terminal window and create three directories; one for the Data Pump metadata dump file, another one as XTTS SOURCE and a third directory for RMAN backup/restore files.

### Source directory for XTTS 

  ```
    <copy>
    mkdir -p /home/oracle/XTTS/SOURCE/tmp 
    mkdir -p /home/oracle/XTTS/DUMP
    mkdir -p /home/oracle/XTTS/RMAN
    </copy>
  ```

![Create_Source_OS_Dir](./images/Create_Source_OS_DIR.png " ")


### Unzip XTTS ZIP file

  ```
    <copy>
    cd /home/oracle/XTTS/SOURCE/
    unzip /home/oracle/Desktop/rman_xttconvert_VER4.3.zip

    </copy>
  ```

![Unzip_XTTS](./images/XTTS_unzip_SRC.png " ")

## Task 2: Set the Source Database Environment

Activate source terminal window, set the source environment and start SQL*Plus:

  ```
    <copy>
    . upgr
    sqlplus / as sysdba

    </copy>
 ```

![Login to CDB3](./images/Source_UPGR_env_sqlplus.png " ")


## Task 3: Configure Source Database
Enable source database archive logging and create the database directory for Data Pump export. Also alter the TPCC user's password:


  ```
    <copy>
    archive log list
    shutdown immediate
    STARTUP MOUNT
    ALTER DATABASE ARCHIVELOG;
    ALTER DATABASE OPEN;
    CREATE OR REPLACE DIRECTORY "XTTS_METADATA_DIR" AS '/home/oracle/XTTS/DUMP';
    alter user TPCC identified by oracle;
    exit
    
    </copy>
  ```


![Login to CDB3](./images/enable_archive_logging.png " ")


You might also consider enabling __Block Change Tracking (BCT)__ using the command "alter database enable block change tracking".

## Task 4: Configuring Default RMAN Settings on Source
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
  ```
![configure_RMAN_Source](./images/rman_default_target_settings.png " ")


You may now *proceed to the next lab*.


## Acknowledgements
* **Author** - Klaus Gronau
* **Contributors** -  
* **Last Updated By/Date** - Klaus Gronau, June 2023