# Prepare Source 

## Introduction

In this lab, you will enable archive logging on source database and create the database directory for Data Pump export.

Estimated Time: 5 minutes

### Objectives

- Enable archive logging on source database

### Prerequisites

This lab assumes you have:

- Connected to the Hands On Lab

## Task 1: Set the source database environment

Click on the Terminal icon to open a second session
![terminal](./images/Terminal.png " ")

First set the source environment and start SQL*Plus

  ```
    <copy>
    . upgr
    sqlplus / as sysdba
    </copy>
 ```

![Login to CDB3](./images/Source_UPGR_env_sqlplus.png " ")


## Task 2: enable Source database archive logging and create the database directory for Data Pump export


  ```
    <copy>
    archive log list
		shutdown immediate
		STARTUP MOUNT
		ALTER DATABASE ARCHIVELOG;
		ALTER DATABASE OPEN;
    CREATE OR REPLACE DIRECTORY "XTTS_METADATA_DIR" AS '/home/oracle/XTTS/DUMP';
    </copy>
  ```


![Login to CDB3](./images/enable_archive_logging.png " ")





## Acknowledgements
* **Author** - Klaus Gronau
* **Contributors** -  
* **Last Updated By/Date** - Klaus Gronau, June 2023
