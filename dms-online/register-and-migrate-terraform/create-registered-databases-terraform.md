# Create Database Connections

## Introduction

This lab walks you through the steps to create a database connections to use with DMS. Database connection resources enable networking and connectivity for the source and target databases.
You will also create and Online Migration leveraging the integrated GoldenGate feature available in DMS.

Estimated Lab Time: 20 minutes

Watch the video below for a quick walk-through of the lab.
[Create Registered Databases](videohub:1_51ktrlb6)

### Objectives

In this lab, you will:
* Create a Database Connection for Source CDB
* Create a Database Connection for Source PDB
* Create a Database Connection for Target ADB
* Create an Online Migration

### Prerequisites

* An Oracle Cloud Account - Please view this workshop's LiveLabs landing page to see which environments are supported
* This lab requires completion of the preceding labs in the Contents menu on the left.
* Source DB Public IP available in Terraform output
* Source DB CDB Service Name available in Terraform output
* Source DB PDB Service Name available in Terraform output
* Database Administrator Password available in Terraform output

## Task 1: Create Database Connection for Source CDB

For this task you need the following info from previous steps:
* Source DB Public IP
* Source DB CDB Service Name
* Database Administrator Password

1. In the OCI Console Menu ![](images/hamburger.png =22x22), go to **Migration & Disaster Recovery > Database Migration > Database Connections**

  ![Screenshot of Database Connections navigation](images/db-connection.png =90%x*)

2. Select your assigned compartment. Identify the value assigned to you in the **Reservation Information** then in OCI go to the **Compartment** field and look for the value under Root / Livelabs, an example is displayed below:

  ![Screenshot to select compartment](images/compartment-selection.png =90%x*)

3. Press **Create connection**

  ![Screenshot of click create connection](images/create-connection.png =90%x*)

4. On the page General information, fill in the following entries, otherwise leave defaults:
    - Name: **SourceCDB**
    - Type: **Oracle Database**
    - Vault: **DMSVault**
    - Encryption Key: **DMSKey**
    
5. Press **Next**

  ![Screenshot of database details and click next](images/database-details-cdb.png =50%x*)

6. On the page Connection details, fill in the following entries, otherwise leave defaults:
    - Database details, select **Enter database information**
    - Database connection string : **CDB Connection String** value from the terraform output
    - Initial load database username: **system**
    - Initial load database password: Select **Admin Password** value from Terraform output
    - Select **Use different credentials for replication**
    - Replication database username: **c##ggadmin**
    - Replication database password: Select **Admin Password** value from Terraform output

    Please uncheck the checkbox **Create private endpoint to access this database**.

7. Press **Create**

  ![Screenshot of  confirm create connection](images/connection-details-cdb.png =50%x*)

8. Wait for connection to get created and press **Test connection** to confirm that your Database Connection details are correct

  ![Screenshot of CDB connection test](images/test-cdb.png =50%x*)
    - If the test is not successful, correct your connection details and try again.

  ![Screenshot of close connection test](images/close-test.png =50%x*)  

## Task 2: Create Database Connection for Source PDB

For this task you need the following info from previous steps:
* Source DB Public IP
* Source DB PDB Service Name
* Database Administrator Password

1. In the OCI Console Menu ![](images/hamburger.png =22x22), go to **Migration & Disaster Recovery > Database Migration > Database Connections**

  ![Screenshot of Database Connections navigation](images/db-connection.png =90%x*)

2. Press **Create connection**

  ![Screenshot of click create connection](images/create-connection-pdb.png =90%x*)

3. On the page General information, fill in the following entries, otherwise leave defaults:
    - Name: **SourcePDB**
    - Type: **Oracle Database**
    - Vault: **DMSVault**
    - Encryption Key: **DMSKey**
    
4. Press **Next**

  ![Screenshot of database details and click next](images/database-details-pdb.png =50%x*)

5. On the page Connection details, fill in the following entries, otherwise leave defaults:
    - Database details, select **Enter database information**
    - Database connection string: **PDB Connection String** value from the terraform output
    - Initial load database username: **system**
    - Initial load database password: Select **Admin Password** value from Terraform output
    - Select **Use different credentials for replication**
    - Replication database username: **ggadmin**
    - Replication database password: Select **Admin Password** value from Terraform output

    Please uncheck the checkbox **Create private endpoint to access this database**.

6. Press **Create**

  ![Screenshot of  confirm create connection](images/connection-details-pdb.png =50%x*)

7. Wait for connection to get created and press **Test connection** to confirm that your Database Connection details are correct

  ![Screenshot of PDB connection test](images/test-pdb.png =50%x*)
    - If the test is not successful, correct your connection details and try again.

  ![Screenshot of close connection test](images/close-test.png =50%x*)  

## Task 3: Create Database Connection for Target ADB

For this task you need the following info from previous steps:
* Administrator Password

1. In the OCI Console Menu ![](images/hamburger.png =22x22), go to **Migration & Disaster Recovery > Database Migration > Database Connections**

  ![Screenshot of Database Connections navigation](images/db-connection.png =90%x*)

2. Press **Create connection**

  ![Screenshot of click create connection](images/create-connection-adb.png =90%x*)

3. On the page General information, fill in the following entries, otherwise leave defaults:
    - Name: **TargetADB**
    - Type: **Oracle Autonomous Database**
    - Vault: **DMSVault**
    - Encryption Key: **DMSKey**

4. Press **Next**

  ![Screenshot of press next after entering details](images/db-connection-adb.png =50%x*)

5. On the page Connection details, fill in the following entries, otherwise leave defaults:
    - Database: **TargetADB#####**
    - Initial load database username: **admin**
    - Initial load database password: Select **Admin Password** value from Terraform output
    - Select **Use different credentials for replication**
    - Replication database username: **ggadmin**
    - Replication database password: Select **Admin Password** value from Terraform output

    Please uncheck the checkbox **Create private endpoint to access this database** needs to stay unchecked.

6. Press **Create**

  ![Screenshot of confirm db connection](images/confirm-db-connection-adb.png =50%x*)

  Please wait for all Database Connection resources to display as **Active** before proceeding to the next task.

7. Press **Test connection** to confirm that your Database Connection details are correct

  ![Screenshot of CDB connection test](images/test-adb.png =50%x*)
    - If the test is not successful, correct your connection details and try again.

  ![Screenshot of close connection test](images/close-test.png =50%x*)    


## Task 4: Create Migration

  1. In the OCI Console Menu ![](images/hamburger.png =22x22), go to **Migration & Disaster Recovery > Database Migration > Migrations**

  ![Screenshot of Migrations navigation](images/migration-nav.png =90%x*)

  2. Press **Create Migration**

    ![Screenshot of press create migration](images/press-create-migration.png =90%x*)

  3. On the page **General information**, fill in the following entries, otherwise leave defaults:
      - Name: **TestMigration**

      ![Screenshot to add vault details](images/add-details.png =40%x*)

  4. Press **Next**

  5. On the page **Select Databases**, fill in the following entries with the Database Connections created in tasks 1 to 3, otherwise leave defaults:
      - Source Database connection: **SourcePDB**
      - *Check* Database is pluggable database (PDB)
      - Container database connection: **SourceCDB**
      - Target Database connection: **TargetADB**

      ![Screenshot of source db selection](images/select-databases.png =50%x*)

  6. On the page **Migration Options**, fill in the following entries, otherwise leave defaults:
      - Transfer medium for initial load:  **Datapump via Object Storage**
      - Export Directory Object:
          - Name: **dumpdir**
          - Path: **/u01/app/oracle/dumpdir**
      - Source Database file system SSL wallet path: **/u01/app/oracle/myserverwallet**
      - Object Storage Bucket: **DMSStorage-#####**
      - Select **Use online replication**

         
          ![Screenshot for migration options](images/test-migration.png =50%x*)


  

      - Press Create to initiate the Migration creation

You may now [proceed to the next lab](#next).

## Learn More

* [Managing Registered Databases](https://docs.oracle.com/en-us/iaas/database-migration/doc/managing-registered-databases.html)
* [Managing Migrations](https://docs.oracle.com/en-us/iaas/database-migration/doc/managing-migrations.html)


## Acknowledgments
* **Author** - Alex Kotopoulis, Director, Product Management
* **Contributors** -  Kiana McDaniel, Hanna Rakhsha, Killian Lynch, Solution Engineers, Austin Specialist Hub
* **Last Updated By/Date** - Jorge Martinez, Product Manager, June 2024
