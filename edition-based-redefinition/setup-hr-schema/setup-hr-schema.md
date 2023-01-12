# Connect to ATP database and prepare the HR schema

Estimated lab time: 10 minutes

### Objectives
In this lab, you will connect as ADMIN to the autonomous database and create the HR schema, along with a few helper procedures.
The HR schema is a modified version of the well-known HR schema to support editions directly after its creation.

### Prerequisites

   - Created or have access the Autonomous Database
   - Downloaded Lab Files and test the connectivity of the Autonomous Database

## Task 1: Connect to ATP Database using SQLCl

   SQLcl(SQL Developer command line) is installed in Cloud Shell by default

1. Connect to admin user to ATP database 

2. We already downloaded the wallet in the Cloud shell home folder in Lab 1.

3. Reopen the Cloud Shell if it is disconnected. From the Cloud shell  home folder, connect to SQLcl 

   ```text
   <copy>sql /nolog </copy>
   ```

4. After getting the SQL prompt, set the cloudconfig details with the wallet file

   ```text
   <copy>set cloudconfig ebronline.zip</copy>
   ```

5. Connect as admin user and enter admin password when prompted. **This is the ADMIN password for the database and it is provided will creating the ATP database**.

   **If you are using livelabs tenancy, you should refer your login page for getting those credentials**

   ```text
   <copy>connect admin@ebronline_medium</copy>
   ```

   ![ATP Connect](images/atp-connect.png " ")

6. Verify the user is connected as admin

   ```text
   <copy>show user</copy>
   ```


## Task 2: Setup the HR schema

1. In SQLCl change the directory to initial_setup and verify the sql files

   ```text
   <copy>cd initial_setup</copy>
   <copy>pwd</copy>
   <copy>!ls -ltr</copy>
   ```

  **Verify you are in the initial_setup directory and able to see the *.sql files**

   ![List initial setup files](images/list-initial-setup.png " ")

2. Execute the SQL file hr_main.sql 

   The scripts prompts for few parameters and make sure you provide the correct details if not the script will error

    - The password for the `HR` user - Input as  **Welcome#Welcome#123**
    - The default tablespace for the `HR` user - Input as **SAMPLESCHEMAS**
    - The temporary tablespace for the `HR` user- Input as **TEMP**
    - The path used to store the logs- Input as **./** 
    - The name of the TNS name to connect to the Autonomous Database- Input as **ebronline_medium**

    ```
      SQL> @hr_main.sql

      specify password for HR as parameter 1:
      Enter value for 1: Welcome#Welcome#123

      specify default tablespeace for HR as parameter 2:
      Enter value for 2: SAMPLESCHEMAS

      specify temporary tablespace for HR as parameter 3:
      Enter value for 3: TEMP

      specify log path as parameter 5:
      Enter value for 5: ./

      specify connect string as parameter 6:
      Enter value for 6: ebronline_medium


      PL/SQL procedure successfully completed.


      Procedure CREATE_EDITION compiled


      Procedure DROP_EDITION compiled


      procedure DEFAULT_EDITION compiled


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
  
  **Verify hr_main.log in the current folders for any log. If you see any errors in the script execution, verify the parameters input an execute again**

## Acknowledgements

- Author - Suraj Ramesh and Ludovico Caldara
- Last Updated By/Date -Suraj Ramesh, Jan 2023