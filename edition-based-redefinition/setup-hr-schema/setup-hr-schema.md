# Setup the HR schema

## Introduction

Estimated lab time: 10 minutes

### Objectives
In this lab, you will connect as DBA to the autonomous database and create the HR schema, along with a few helper procedures.
The HR schema is a modified version of the well-known HR schema to support editions directly after its creation.

### Prerequisites
- You have completed:
   - Lab: Create the Autonomous Database
   - Lab: Connect to the Autonomous Database
- Alternatively:
  - You have DBA access to any Oracle Database release 11gR2 or higher.
  - You have the last version of SQLcl.
  - You know how to map any step provided in this lab to another database.


## Task 1: Download and extract the zip bundle containing the SQL files for the lab.

1. Download the bundle with `wget`:

    ```
      wget {{address_to}}/ebr-human-resources.zip
    ```

2. Unzip the archive:

    ```
      unzip ebr-human-resources.zip
    ```
  ![](./images/01-unzip-bundle-png)

## Task 2: Connect as DBA to the Autonomous Database

1. Execute SQLcl with the `sql` command:

    ```
      $ cd ebr-human-resources/initial_setup
      $ sql /nolog

      SQLcl: Release 21.4 Production on Mon Mar 14 15:18:04 2022

      Copyright (c) 1982, 2022, Oracle.  All rights reserved.
      SQL>
    ```

2. Instruct SQLcl to use the wallet you have uploaded in the previous lab:

    ```
      SQL> set cloudconfig ../../Wallet_DB20220620133943.zip

** This Wallet name will be different for your ADB and  use the correct *.zip file **
    ```

3. Connect using the `admin` user (or another user with DBA privileges). For that, use the TNS name noted down previously, along with the password used during the creation of the Autonomous Database:

    ```
      SQL> connect admin/*****@demoadb_tp
      Connected.
    ```

## Task 3: Setup the HR schema

1. Execute the SQL file hr_main.sql (make sure you are in the directory `ebr-human-resources/initial_setup`).

   The scripts prompts for a few parameters:
     1. The password for the `HR` user (use your preferred one).
     2. The default tablespace for the `HR` user (ADB comes with `SAMPLESCHEMAS` by default, but any existing user tablespace in your environment will work, for example `USERS`).
     3. The temporary tablespace for the `HR` user. ADB comes with `TEMP` by default.
     5. The path used to store the logs. You can use `./` for that.
     6. The name of the TNS name to connect to the Autonomous Database.

    ```
      SQL> @hr_main

      specify password for HR as parameter 1:
      Enter value for 1: Welcome#Welcome#123

      specify default tablespeace for HR as parameter 2:
      Enter value for 2: SAMPLESCHEMAS

      specify temporary tablespace for HR as parameter 3:
      Enter value for 3: TEMP

      specify log path as parameter 5:
      Enter value for 5: ./

      specify connect string as parameter 6:
      Enter value for 6: demoadb_medium

      User HR dropped.

      User HR created.

      User HR altered.

      User HR altered.

      Grant succeeded.

      Grant succeeded.

      Grant succeeded.

      User HR altered.
      Connected.

      Session altered.

      Session altered.
      ******  Creating REGIONS table ....

      Table REGIONS$0 created.

      View REGIONS created.

      INDEX REG_ID_PK created.

      Table REGIONS$0 altered.
      ******  Creating COUNTRIES table ....

      Table COUNTRIES$0 created.

      View COUNTRIES created.

      Table COUNTRIES$0 altered.
      ******  Creating LOCATIONS table ....

      Table LOCATIONS$0 created.

      View LOCATIONS created.

      INDEX LOC_ID_PK created.

      Table LOCATIONS$0 altered.

      Sequence LOCATIONS_SEQ created.
      ******  Creating DEPARTMENTS table ....

      Table DEPARTMENTS$0 created.

      View DEPARTMENTS created.

      INDEX DEPT_ID_PK created.

      Table DEPARTMENTS$0 altered.

      Sequence DEPARTMENTS_SEQ created.
      ******  Creating JOBS table ....

      Table JOBS$0 created.

      View JOBS created.

      INDEX JOB_ID_PK created.

      Table JOBS$0 altered.
      ******  Creating EMPLOYEES table ....

      Table EMPLOYEES$0 created.

      View EMPLOYEES created.

      INDEX EMP_EMP_ID_PK created.

      Table EMPLOYEES$0 altered.

      Table DEPARTMENTS$0 altered.

      Sequence EMPLOYEES_SEQ created.

      ******  Creating JOB_HISTORY table ....

      Table JOB_HISTORY$0 created.

      View JOB_HISTORY created.

      INDEX JHIST_EMP_ID_ST_DATE_PK created.

      Table JOB_HISTORY$0 altered.
      ******  Creating EMP_DETAILS_VIEW view ...

      View EMP_DETAILS_VIEW created.

      Commit complete.

      Session altered.
      ******  Populating REGIONS table ....

      1 row inserted.

      ******  Populating COUNTIRES table ....

      1 row inserted.
      [...]
      1 row inserted.

      ******  Populating LOCATIONS table ....

      1 row inserted.
      [...]
      1 row inserted.

      ******  Populating DEPARTMENTS table ....

      Table DEPARTMENTS$0 altered.

      1 row inserted.
      [...]
      1 row inserted.

      ******  Populating JOBS table ....

      1 row inserted.
      [...]
      1 row inserted.

      ******  Populating EMPLOYEES table ....

      1 row inserted.
      [...]
      1 row inserted.

      ******  Populating JOB_HISTORY table ....

      1 row inserted.
      [...]
      1 row inserted.

      Table DEPARTMENTS$0 altered.

      Commit complete.

      Index EMP_DEPARTMENT_IX created.

      Index EMP_JOB_IX created.

      Index EMP_MANAGER_IX created.

      Index EMP_NAME_IX created.

      Index DEPT_LOCATION_IX created.

      Index JHIST_JOB_IX created.

      Index JHIST_EMPLOYEE_IX created.

      Index JHIST_DEPARTMENT_IX created.

      Index LOC_CITY_IX created.

      Index LOC_STATE_PROVINCE_IX created.

      Index LOC_COUNTRY_IX created.

      Commit complete.

      Procedure SECURE_DML compiled

      Trigger SECURE_EMPLOYEES compiled

      Trigger SECURE_EMPLOYEES altered.

      Procedure ADD_JOB_HISTORY compiled

      Trigger UPDATE_JOB_HISTORY compiled

      Commit complete.

      Comment created.
      [...]
      Commit complete.

      PL/SQL procedure successfully completed.

      SQL>
    ```

    You have successfully created the HR schema [proceed to the next lab](#next) to have an overview of the Editions and the helper procedure that we have created in this lab.

## Acknowledgements

- **Author** - Ludovico Caldara
- **Contributors** -
- **Last Updated By/Date** -  
