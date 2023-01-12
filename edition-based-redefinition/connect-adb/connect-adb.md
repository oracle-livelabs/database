# Download ATP DB Wallet and lab files

Estimated Time: 10 minutes

### Objectives

- Download ATP Wallet
- Download Lab files 
- Test the connection 

### Prerequisites

This lab assumes you have:

- Performed the previous lab on provisioning an Oracle Autonomous Database or you already have an existing Autonomous Database

## Task 1: Download ATP Wallet 

1. Login into OCI Console with your provided Credentials. 

2. Click the **Navigation Menu** in the upper left, navigate to **Compute**, and select **Instances**.

   ![Compute Instances](https://oracle-livelabs.github.io/common/images/console/compute-instances.png " ")

3. Select the compartment you were assigned. Expand the **root** compartment and then the **Livelabs** compartment. Select the compartment assigned to you.

   ![Select Compartment](images/select-compartment.png " ")

4. Launch cloud shell. You should be able to open your cloud shell

   ![Cloud Shell](https://oracle-livelabs.github.io/common/images/console/cloud-shell.png " ")
    
   Within few seconds, you will have cloud shell prompt

   ![Cloud Shell prompt](images/cloudshell-prompt.png " ")

5. As next step, need to gather the OCID( Oracle Cloud Identifier) of the ATP database.Leave the existing Cloud Shell browser tab and use duplicate tab to open a new tab in browser.

   From the Hamburger menu, select Oracle Database, then Autonomous Transaction Processing.

  ![Navigate ATP](images/navigate-atp.png " ")

  You should be able to see an ATP database, similar to below. Make sure to change to the compartment which was assigned to you.

  ![ATP Database](images/atp-database.png " ")

6. Click the ATP database, which should have display like "EBRAPP" ( Whichever DB display name used during provisioning) and in the Autonomous Database Information tab, copy the OCID of the ATP database and keep it safe. This is required for downloading the wallet in the next step.

  ![OCID ATP](images/ocid-atp.png " ")

7. Download the ATP Wallet for this lab using the Cloud Shell. Switch to the first tab of your browser, where Cloud Shell was initially opened. In case if the Cloud Shell got disconnected, reconnect it again.

  You can maximize the Cloud Shell view and restore it as your requirements. For better viewing, you can use maximize option.

  ![Maximize Cloud shell](images/maximize-cloudshell.png " ")

8. Make sure to modify the ATP database OCID for your database in the below command.You should replace the OCID after --autonomous-database-id with your values which was captured in Step 6

   ````text
   <copy>oci db autonomous-database generate-wallet --generate-type ALL --file ebronline.zip --password Ebronline@123 --autonomous-database-id ocid1.autonomousdatabase.oc1.iad.xxxxxxxxxxxxxxxxxxxxxx</copy>
   ```

9. Copy the command and execute in Cloud Shell prompt.You should be able to see the Wallet file which was downloaded. Verify that using the list command ls -ltr as provided in the screenshot.

   ![Download wallet](images/download-wallet.png " ")


## Task 2: Download Lab files

1. Using the same cloud shell console, download the Lab required files

   ```text
   <copy>wget http://bit.ly/ebrlabs</copy>
   ```
   Copy the command and execute in Cloud Shell prompt.You should be able to see the ebrlabs.zip got downloaded. Verify that using the list command ls -ltr as provided in the screenshot.

   ![Download ebrlabs](images/download-ebrlabs.png " ")

2. Unzip the ebrlabs.zip file 

   ```text
   <copy>unzip ebrlabs</copy>
   ```
   
   Copy the command and execute in Cloud Shell prompt.You should be able to see the ebrlabs.zip has been unzipped.

   ![Unzip ebrlabs](images/unzip-ebrlabs.png " ")

   It should have two folders **initial_setup** and **changes** with bunch of sql and xml files. Verify that using the list command ls -ltr as provided in the screenshot.

   ![Ebrlabs folders](images/ebrlabs-folders.png " ")


You have successfully downloaded the ADB wallet and lab files,[proceed to the next lab](#next) to setup the HR schema.

## **Acknowledgements**

- Author - Ludovico Caldara and Suraj Ramesh 
- Last Updated By/Date -Suraj Ramesh, Jan 2023

