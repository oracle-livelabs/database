# Prepare Target

## Introduction

In this lab, you will create the target PDB and a few additional objects.

Estimated Time: 15 minutes

### Objectives

- Initialize a new target PDB.

### Prerequisites

This lab assumes you have:

- Connected to the Hands On Lab

## Task 1: Open Terminal Window, Create OS Target Directory and Unzip XTTS ZIP File

### Open Terminal Window 
Open a terminal windows by clicking on the "Terminal" icon. <br>
You can use this terminal window to execute all commands related to the __TARGET__ database.

![Screenshot of the Linux Hands On Lab Terminal icon](./images/terminal.png " ")

All following screenshots related to the __TARGET__ will have a light green_ background color.


### Create OS Directory (__TARGET__)
Activate the target terminal window and create a directory for the XTTS TARGET files.

  ```
    <copy>
    mkdir -p /home/oracle/XTTS/TARGET/tmp
    </copy>
  ```

![Create_TARGTE OS directory ](./images/create-target-os-dir.png " ")

### Unzip XTTS ZIP file (__TARGET__)

  ```
    <copy>
    cd /home/oracle/XTTS/TARGET/
    unzip /home/oracle/Desktop/rman_xttconvert_VER4.3.zip
    </copy>
  ```

![Unzipping the XTTS Perl V4 ZIP file on target](./images/xtts-unzip-trg.png " ")


## Task 2: Set the Target Environment and Start SQL*Plus (__TARGET__)


  ```
    <copy>
    . cdb3
    </copy>
  ```
  ```
    <copy>
    sqlplus / as sysdba 
    </copy>
  ```

![Login to CDB3](./images/source-cdb3.png " ")


## Task 3: In SQL*Plus Create the Target PDB (__TARGET__)
When creating a PDB the admin user needs to exist. You can delete it later on if desired. Once the PDB3 is created you need to start it up.
  ```
    <copy>
    startup
    create pluggable database PDB3 admin user adm identified by adm file_name_convert=('pdbseed', 'pdb3');
    alter pluggable database pdb3 open;
    alter pluggable database PDB3 save state;
    </copy>
  ```
__Hit ENTER/RETURN__

![Create PDB3 in CDB3](./images/cdb3-create-pdb3.png " ")



## Task 4: In SQL*Plus Create the Database Directory Used by Data Pump (__TARGET__)
 and create some additional objects for the migration.

  ```
    <copy>
		alter session set container=PDB3;
		CREATE OR REPLACE DIRECTORY "XTTS_METADATA_DIR" AS '/home/oracle/XTTS/DUMP/';
    exit;
    </copy>
  ```
__Hit ENTER/RETURN__

![create database directory in PDB3](./images/create-database-directory-pdb3.png " ")


You may now *proceed to the next lab*.



## Acknowledgements
* **Author** - Klaus Gronau
* **Contributors** -  
* **Last Updated By/Date** - Klaus Gronau, June 2023
