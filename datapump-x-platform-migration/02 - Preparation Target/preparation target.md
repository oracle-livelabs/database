# Prepare Target

## Introduction

In this lab, you will create the target PDB and a few additional objects.

Estimated Time: 15 minutes

### Objectives

- Initialize a new target PDB.

### Prerequisites

This lab assumes you have:

- Connected to the Hands On Lab

## Task 1: Open terminal window and create three directories

Click on the Terminal icon
![terminal](./images/Terminal.png " ")

In the terminal window create 3 directories; one for the datapump dump, another one for the SOURCE and the third directory for the TARGET files

    ```
    <copy>
    mkdir -p /home/oracle/DP/DUMP /home/oracle/DP/SOURCE/tmp /home/oracle/DP/TARGET/tmp
    </copy>
    ```

![Login to CDB3](./images/create_directory_os.png " ")


## Task 2: source the target environment and start SQL*Plus


  ```
    <copy>
    . cdb3
    sqlplus / as sysdba
    </copy>
  ```

![Login to CDB3](./images/source_cdb3.png " ")


## Task 3: Create the PDB
When creating a PDB the admin user needs to exist. You can delete it later on if desired. Once the PDB3 is created you need to start it up.
  ```
    <copy>
    create pluggable database PDB3 admin user adm identified by adm file_name_convert=('pdbseed', 'pdb3');
    alter pluggable database pdb3 open;
    alter pluggable database PDB3 save state;
    </copy>
  ```

![Create CDB3](./images/cdb3_create_pdb3.png " ")



## Task 4: Create the database directory used by datapump
 and create some additional objects for the migration.

  ```
    <copy>    
		alter session set container=PDB3;
		CREATE OR REPLACE DIRECTORY "DATAPUMP_DIR" AS '/home/oracle/DP/DUMP';
    </copy>
  ```

![create Database Directory Target](./images/create_database_directory_PDB3.png " ")





## Acknowledgements
* **Author** - Klaus Gronau
* **Contributors** -  
* **Last Updated By/Date** - Klaus Gronau, June 2023
