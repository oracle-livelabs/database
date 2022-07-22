# Setup and Configure Always On Availability Group

## Introduction

This lab walks you through the steps to create Database home using the custom DB software image.

Estimated Time:  30 min

### Objectives
In this lab, you will learn to :
* Create DB home using custom DB software image using OCI console.

### Prerequisites  

This lab assumes you have:
- A Free or LiveLabs Oracle Cloud account.
- IAM policies to create resources in the compartment.
- Network setup for Exadata Cloud Infrastructure.
- Exadata Cloud Infrastructure Deployment.

## Task 1: Create DB home using custom DB software image.

1. Open the navigation menu in OCI console. Click **Oracle Database**, then click **Exadata on Oracle Public Cloud**.

  ![DB home creation for ExaCS](./images/navigate_to_exacs_public_cloud.png "DB home creation for ExaCS")


2. Choose your **Compartment**.

  ![DB home creation for ExaCS](./images/choose_compartment.png "DB home creation for ExaCS")


3. Navigate to the cloud VM cluster or DB system you want to create the new Database Home on:

  * Under **Oracle Exadata Database Service on Dedicated Infrastructure** ,click on **Exadata VM Clusters**. 

  * In the list of VM clusters, find the VM cluster you want to access and click its **Display Name** to view the details page for the cluster.

   ![DB home creation for ExaCS](./images/navigate_exacs_vm_cluster.png "DB home creation for ExaCS")

4. Under Resources, 

  * Click on **Database Homes**.
    A list of Database Homes is displayed.
    
  * Click on **Create Database Home**.

    ![DB home creation for ExaCS](./images/create_db_home1.png "DB home creation for ExaCS")

5. In the Create Database Home dialog, enter the following:

  * Provide the **Database Home display name**. Avoid entering confidential information.

  * For **Database image**, determines what Oracle Database version is used for the database. By default, the latest Oracle-published database software image is selected.
  
  * Click **Change Database Image** to use an older Oracle-published image or a custom database software image that you have created in advance.

   ![DB home creation for ExaCS](./images/create_db_home2.png "DB home creation for ExaCS")
  
6. For Image Type, select **Custom Database Software Images**.
    
  * Select **compartment** and **Database version** of your custome DB software image. These selectors are to limit the list of custom database software images to a specific compartment or Oracle Database software major release version.
   
  ### Note
  The custom database software image must be based on an Oracle Database release that meets the following criteria:
    * The release is currently supported by Oracle Cloud Infrastructure.
    * The release is supported by the hardware model on which you are creating the Database Home.

  * After **choosing** the software image, click **Select** to return to the Create Database dialog.

   ![DB home creation for ExaCS](./images/create_db_home3.png "DB home creation for ExaCS")

7. Click **Create**.

   ![DB home creation for ExaCS](./images/create_db_home4.png "DB home creation for ExaCS")

8. The status of the Database home creation shows as **Provisioning**. 

   ![DB home creation for ExaCS](./images/create_db_home_state1.png "DB home creation for ExaCS")

9. When the Database Home creation is complete, the status changes from **Provisioning** to **Available**.

   ![DB home creation for ExaCS](./images/create_db_home_state2.png "DB home creation for ExaCS")



You may now **proceed to the next lab**.

## Acknowledgements
* **Author** - Leona Dsouza, Senior Cloud Engineer, NA Cloud Engineering
* **Contributors** -  Ramesh Babu Donti, Principal Cloud Architect, NA Cloud Engineering
* **Last Updated By/Date** - Leona Dsouza, Senior Cloud Engineer, NA Cloud Engineering, July 2022
