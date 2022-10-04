# Create Registered Databases

## Introduction

This lab walks you through the steps to register a database for use with DMS. Registered database resources enable networking and connectivity for the source and target databases

Estimated Lab Time: 20 minutes

### Objectives

In this lab, you will:
* Create Registered Database for Source CDB
* Create Registered Database for Source PDB
* Create Registered Database for Target ADB
* Create a Migration

### Prerequisites

* An Oracle Cloud Account - Please view this workshop's LiveLabs landing page to see which environments are supported
* This lab requires completion of the preceding labs in the Contents menu on the left.
* Source DB Public IP available in Terraform output
* Source DB CDB Service Name available in Terraform output
* Source DB PDB Service Name available in Terraform output
* Database Administrator Password available in Terraform output

## Task 1: Download generated private key from Object Storage

In this task you need to download a private key file to your local machine to be used to register databases in this lab. Please be advised that this private key is different from any keys you have provided to LiveLabs, it has been generated specifically for you to access the database and GoldenGate environments provided by the lab.

1. In the OCI Console Menu ![](images/hamburger.png =22x22), go to **Storage > Object Storage & Archive Storage > Buckets**

![Screenshot of Object Storage navigation](images/buckets-navigation.png =90%x*)

2. If you see an error message or are not yet in the compartment assigned to you by LiveLabs, please change to the correct compartment in the left hand compartment menu. The compartment will be **(root) > Livelabs > LL#####-COMPARTMENT**, with ##### being your user number

3. Select the bucket named **DMSStorage-#####** with ##### being the number of your user.
![Screenshot of buckets list](images/buckets-list.png =90%x*)

4. In the Objects list of bucket **DMSStorage-#####**, there is a file named **privatekey.txt**. Click on the right-hand context menu on the row and select **Download**. You can locate the file in the download folder of your browser.
![Screenshot of private key file download](images/buckets-download.png =90%x*)

## Task 2: Create Registered Database for Source CDB

For this task you need the following info from previous steps:
* Source DB Public IP
* Source DB CDB Service Name
* Database Administrator Password
* Private Key File

1. In the OCI Console Menu ![](images/hamburger.png =22x22), go to **Migration > Registered Databases**

  ![Screenshot of Registered Databases navigation](images/registered-db.png =90%x*)

2. Press **Register Database**

  ![Screenshot of click register db](images/click-register-db.png =90%x*)

3. On the page Database Details, fill in the following entries, otherwise leave defaults:
    - Name: **SourceCDB**
    - Vault: **DMSVault**
    - Encryption Key: **DMSKey**
    - Choose **Manually configure database**
    - Database Type: **Oracle**
    - Host: Select **dbcs\_public\_ip** value from Terraform output
    - Port: **1521**
    - Connect String: Select **dbcs\_cdb\_service** value from Terraform output

    The checkbox **Create private endpoint to access this database** needs to stay unchecked.

4. Press **Next**

  ![Screenshot of register DB details and click next](images/register-db-next.png =50%x*)

5. On the page Connection Details, fill in the following entries, otherwise leave defaults:
    - Database Administrator Username: **system**
    - Database Administrator Password: Select **admin_password** value from Terraform output
    - SSH Database Server Hostname: Select **dbcs\_public\_ip** value from Terraform output
    - SSH Private Key: Select private key file saved earlier
    - SSH Username: **opc**
    - SSH Sudo Location: **/usr/bin/sudo**

6. Press **Register**

  ![Screenshot of  confirm register DB](images/register-db-confirm.png =50%x*)

## Task 3: Create Registered Database for Source PDB

For this task you need the following info from previous steps:
* Source DB Public IP
* Source DB PDB Service Name
* Database Administrator Password
* Private Key File

1. In the OCI Console Menu ![](images/hamburger.png =22x22), go to **Migration > Registered Databases**

  ![Screenshot of Registered Databases](images/registered-db.png =90%x*)

2. Press **Register Database**

  ![Screenshot of click register db](images/click-register-db.png =90%x*)

3. On the page Database Details, fill in the following entries, otherwise leave defaults:
    - Name: **SourcePDB**
    - Vault: **DMSVault**
    - Encryption Key: **DMSKey**
    - Choose **Manually configure database**
    - Database Type: **Oracle**
    - Host: Select **dbcs\_public\_ip** value from Terraform output
    - Port: **1521**
    - Connect String: Select **dbcs\_pdb\_service** value from Terraform output

    The checkbox **Create private endpoint to access this database** needs to stay unchecked.


4. Press **Next**

  ![Screenshot of register db](images/register-db-next-second.png =50%x*)

5. On the page Connection Details, fill in the following entries, otherwise leave defaults:
    - Database Administrator Username: **system**
    - Database Administrator Password: Select **admin\_password** value from Terraform output
    - SSH Database Server Hostname: Select **dbcs\_public\_ip** value from Terraform output
    - SSH Private Key: Select private key file saved earlier
    - SSH Username: **opc**
    - SSH Sudo Location: **/usr/bin/sudo**

6. Press **Register**

   ![Screenshot of  confirm register DB](images/register-db-confirm.png =50%x*)

## Task 4: Create Registered Database for Target ADB

For this task you need the following info from previous steps:
* Administrator Password

1. In the OCI Console Menu ![](images/hamburger.png =22x22), go to **Migration > Registered Databases**

  ![Screenshot of Registered Databases](images/registered-db.png =90%x*)

2. Press **Register Database**

   ![Screenshot of click register db](images/click-register-db.png =90%x*)

3. On the page Database Details, fill in the following entries, otherwise leave defaults:
    - Name: **TargetADB**
    - Vault: **DMSVault**
    - Encryption Key: **DMSKey**
    - Database Type: **Autonomous Database**
    - Database: **TargetADB#####**

4. Press **Next**

  ![Screenshot of press next after entering details](images/register-adb-1.png =50%x*)

5. On the page Connection Details, fill in the following entries, otherwise leave defaults:
    - Database Administrator Username: **admin**
    - Database Administrator Password: Select **admin_password** value from Terraform output

6. Press **Register**

  ![Screenshot of confirm db registration](images/confirm-db-registration.png =50%x*)

  Please wait for all Database Registration resources to display as **Active** before proceeding to the next task.


## Task 5: Create Migration

  1. In the OCI Console Menu ![](images/hamburger.png =22x22), go to **Migration > Database Migration > Migrations**

    ![Screenshot of migration navigation](images/migrations-navigation.png =90%x*)

  2. Press **Create Migration**

    ![Screenshot of press create migration](images/press-create-migration.png =90%x*)

  3. On the page **Add Details**, fill in the following entries, otherwise leave defaults:
      - Name: **TestMigration**
      - Vault: **DMSVault**
      - Encryption Key: **DMSKey**

      ![Screenshot to add vault details](images/add-details.png =40%x*)

  4. Press **Next**

  5. On the page **Select Databases**, fill in the following entries, otherwise leave defaults:
      - Source Database: **SourcePDB**
      - *Check* Database is pluggable database (PDB)
      - Registered Container Database: **SourceCDB**
      - Target Database: **TargetADB**

      ![Screenshot of source db selection](images/select-databases.png =50%x*)

  6. On the page **Migration Options**, fill in the following entries, otherwise leave defaults:
      - In **Initial Load**, select **Datapump via Object Storage**
      - Object Storage Bucket: **DMSStorage-#####**
      - Export Directory Object:
          - Name: **dumpdir**
          - Path: **/u01/app/oracle/dumpdir**
     
          ![Screenshot for migration options](images/test-migration.png =50%x*)


  7. Check **Use Online Replication**
     - GoldenGate Hub URL: **ogg\_hub\_url** value from Terraform output
     - GoldenGate Administrator Username: **oggadmin**
     - GoldenGate Administrator Password: **admin\_password** value from Terraform output

     ![Online replication check](images/online-goldengate.png =50%x*)

     - Source database:
          - GoldenGate deployment name: **Marketplace**
          - Database Username: **ggadmin**
          - Database Password: **admin\_password** value from Terraform output
          - Container Database Username: **c##ggadmin**
          - Container Database Password: **admin\_password** value from Terraform output

      ![Source database details](images/online-source-database.png =50%x*)    
     
     - Target database:
          - GoldenGate Deployment Name: **Marketplace**
          - Database Username: **ggadmin**
          - Database Password: **admin\_password** value from Terraform output
          - Press Show Advanced Options
          - Press Replication tab
                    

    ![Target database details](images/online-target-database-ggocid.png =50%x*) 

      - Press Create to initiate the Migration creation

You may now [proceed to the next lab](#next).

## Learn More

* [Managing Registered Databases](https://docs.oracle.com/en-us/iaas/database-migration/doc/managing-registered-databases.html)
* [Managing Migrations](https://docs.oracle.com/en-us/iaas/database-migration/doc/managing-migrations.html)


## Acknowledgments
* **Author** - Alex Kotopoulis, Director, Product Management
* **Contributors** -  Kiana McDaniel, Hanna Rakhsha, Killian Lynch, Solution Engineers, Austin Specialist Hub
* **Last Updated By/Date** - Jorge Martinez, Product Manager, July 2022
