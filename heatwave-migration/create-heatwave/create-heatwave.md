# Create a MySQL HeatWave System

## Introduction

In this lab, we will be creating our first MySQL HeatWave System inside Oracle Cloud. While creating the MySQL HeatWave system, we need to create a PAR URL. The PAR URL will allow us to load the Object Storage bucket data into MySQL HeatWave, while the system is creating.

_Estimated Time:_ 25 minutes

### Objectives

In this lab, you will be guided through the following task:

- Provision a MySQL HeatWave System
- Load data into MySQL HeatWave

### Prerequisites

- An Oracle Trial or Paid Cloud Account
- Some Experience with MySQL Shell
- Completed Lab 2

## Task 1: Set up an OCI MySQL HeatWave system

1. Once the all the dump files have successfully been exported to Object Storage Bucket, in OCI click on the “Hamburger” menu and go to “Databases” > “MySQL”.

    ![OCI Databases Menu](./images/mysql-nav1-new.png "mysql-nav")

1. After you have landed on the ‘DB Systems’ page, ensure you have the correct Compartment selected and click “Create DB System”.

    ![Database Landing Page](./images/create-hw1-new.png "mysql-nav2")

1. Name your MySQL Database System “MySQL-HW”, and create your admin credentials for the MySQL HeatWave system that is being created.

    ```bash
    <copy>MySQL-HW</copy>
    ```

    ![Database Creation Page](./images/create-hw02-new.png "mysql-nav3")
    
1. Select "Standalone", then under “Configure networking”, make sure the “MySQL-VCN” is selected and the Subnet is “Private Subnet”, and ensure that the “Enable HeatWave cluster” toggle is enabled. If you require High Availability for MySQL, you may turn it on after completing Lab 3.

    ![Database Creation Page - Admin/Networking Section](./images/hw-priv1-new.png "mysql-nav4")

1. Leave the rest as it is and lastly click "Show advanced options", and expand "Connections". Under "Hostname", enter the name of your MySQL Database System.

    ![Database Creation Page - Advanced Options](./images/show-adv-new.png "show-advanced-options")

    ![Database Creation Page - Hostname](./images/hostname1-new.png "enter-hostname")

1. Afterwards, expand "Data Import".

    ![Database Creation Page - Data Import Tab](./images/show-adv2-new.png "data-import")

1. Click the "Create a new PAR URL" link.

    ![Database Creation Page - Data Import Link](./images/create-par1-new.png "data-imp-options-hw2")

1. After clicking the above link, another screen will appear where you will select the "MySQL-Bucket" bucket from the drop down list, that we created in Lab 2.

    ![PAR URL Creation Page](./images/select-buck01-new.png "select-bucket")

    ![PAR URL Creation Page - Bucket Selection](./images/select-buck02-new.png "select-bucket2")

1. Once you have selected the appropriate bucket where the data was dumped, adjust the PAR expiration according to your needs. Then, simply click "Create and set PAR URL". Afterwards, your screen should look something similar to below:

    ![PAR URL Creation Page](./images/set-par-new.png "create-hw-using-par")

    ![Database Creation Page - Populated PAR URL](./images/create-hw-01-new.png "create-hw")

     **Note:** click "Create" as shown in the above image, once your 'PAR Source URL' has been populated.

1. After clicking "Create" in the previous Step, your MySQL HeatWave System will start provisioning and will have the data pre-loaded that we dumped from our on-premise environment into Object Storage bucket, once the HeatWave System is in an "ACTIVE" status.

    ![MySQL Database Active Status](./images/db-ready-new.png "MySQL-Active")

    **Note:** it may take MySQL HeatWave a few minutes to be in an "ACTIVE" state

1. Once your MySQL DB System is 'ACTIVE', a “Private IP Address” will be allocated to it, find and copy it. You can find this Private IP under the “Connections" tab.

    ![MySQL DB System Information Section](./images/hw-ip1-new.png "MySQL-IP")

    **Note:** you can navigate to the “DB System Details” page by going to the “Hamburger” menu in OCI. “Databases” > “MySQL” > “DB Systems”. Click on the name of your MySQL DB System to open the “DB System Details” page.

1. Copy the Private IP Address in the previous Step. You can now login to your MySQL DB System using MySQL Shell from your Compute. Execute:

    ```bash
    <copy>mysqlsh <username>@<private-mysql-ip></copy>
    ```

    -OR-

    ```bash
    <copy>mysqlsh -u <username> -h <private-mysql-ip> -P <portnumber> -p</copy>
    ```

This concludes this lab. You may now **proceed to the next lab.**

## Acknowledgements

- **Author** - Ravish Patel, MySQL Solution Engineering

- **Contributors** - Perside Foster, MySQL Solution Engineering

- **Last Updated By/Date** - Ravish Patel, MySQL Solution Engineering, June 2023
