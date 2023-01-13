# Connect to ATP database and prepare the HR schema

Estimated lab time: 10 minutes

## Objectives

In this lab, you will connect as ADMIN to the autonomous database and create the HR schema, along with a few helper procedures.
The HR schema is a modified version of the well-known HR schema to support editions directly after its creation.

## Prerequisites

- Created or have access to ATP database
- Downloaded Lab Files

## Task 1: Connect to ATP Database using SQLcl

   SQLcl(SQL Developer command line) is installed in Cloud Shell by default

1. Connect to admin user to ATP database 

2. We already downloaded the wallet in the Cloud shell home folder in Lab 1.

3. Reopen the Cloud Shell if it is disconnected. From the Cloud shell  home folder, connect to SQLcl 

   ```text
   <copy>cd ~</copy>
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

1. In SQLcl change the directory to initial_setup and verify the sql files

   ```text
   <copy>cd initial_setup</copy>
   <copy>pwd</copy>
   <copy>!ls -ltr</copy>
   ```

  **Verify you are in the initial_setup directory and able to see the *.sql files**

   ![List initial setup files](images/list-initial-setup.png " ")

2. Execute the SQL file hr_main.sql 

   ````text
   <copy>@hr_main.sql</copy>
   ```

   The scripts prompts for few parameters and make sure you provide the correct details if not the script will error

- The password for the `HR` user - Input as  **Welcome#Welcome#123**
- The default tablespace for the `HR` user - Input as **SAMPLESCHEMAS**
- The temporary tablespace for the `HR` user- Input as **TEMP**
- The path used to store the logs- Input as **./** 
- The name of the TNS name to connect to the Autonomous Database- Input as **ebronline_medium**

   ![HR main script](images/hr-main-script.png " ")

   ![HR script execution ](images/hr-script-execution.png " ")

   **Verify hr_main.log in the current folder.If you see any errors in the script execution, verify the parameters input an execute again**

    You have successfully created the HR schema [proceed to the next lab](#next) to have an overview of the Editions and the helper procedure that we have created in this lab. 

## Acknowledgements

- Authors - Ludovico Caldara,Senior Principal Product Manager,Oracle MAA PM Team and Suraj Ramesh,Principal Product Manager,Oracle MAA PM Team
- Last Updated By/Date - Suraj Ramesh, Jan 2023
