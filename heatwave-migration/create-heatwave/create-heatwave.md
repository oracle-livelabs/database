# Create a MySQL HeatWave System

## Introduction

In this lab, we will be creating our first MySQL HeatWave System inside Oracle Cloud. But before we can provision a HeatWave database, we first need to create a Virtual Cloud Network

_Estimated Time:_ ? minutes

### Objectives

In this lab, you will be guided through the following task:

- Create a Virtual Cloud Network in OCI
- Provision a MySQL HeatWave System

### Prerequisites

- An Oracle Trial or Paid Cloud Account
- Some Experience with MySQL Shell
- Completed Lab 2

## Task 1: Create and configure VCN in OCI

**Note:** please skip Task 1 if you have already configured a VCN in Lab 1

1. While in Oracle Cloud, go to the Navigation or Hamburger menu again. Navigate to “Networking” and “Virtual Cloud Networks”

    ![](./images/nav-vcn.png "navigate-to-vcn")

2. Once on the Virtual Cloud Networks page, click “Start VCN Wizard” and select “Create VCN with Internet Connectivity”

    ![](./images/create-vcn.png "create-vcn")

    ![](./images/vcn-wizard.png "vcn-wizard")

3. Name your VCN “MySQL-VCN” while making sure you are in the correct Compartment. Leave everything as it is, and click “Next”
    ```bash
    <copy>MySQL-VCN</copy>
    ```

    ![](./images/name-vcn.png "name-vcn-wizard")

4. Review all the information and click “Create”

    ![](./images/review-vcn.png "review-vcn-wizard")

5. Once the VCN is created, click “View Virtual Cloud Network”

    ![](./images/view-vcn.png "view-vcn-wizard")

6. Once on the MDS-VCN page, under “Resources” click “Subnets” and go to the “Private-Subnet-MDS-VCN”

    ![](./images/resources-vcn.png "resources-vcn")

7. On the Private Subnet page, under “Security Lists”, click on “Security List for Private Subnet -MDS-VCN” and select “Add Ingress Rules”

    ![](./images/sc-vcn.png "seclist-vcn")

    ![](./images/add-ingr.png "add-ingress")

8. For the ‘Source CIDR’ enter “0.0.0.0/0” and for the Destination Port Range, enter “3306,33060”. In the ‘Description’ section, write “MySQL Port Access”
    ```bash
    <copy>0.0.0.0/0</copy>
    ```
    ```bash
    <copy>3306,33060</copy>
    ```

    ![](./images/add-rule.png "add-ingress-rule")

## Task 2: Set up an OCI MySQL HeatWave system

1. Within Oracle Cloud, go to the Navigation or Hamburger menu and under Databases, select “DB Systems”

    ![](./images/mysql-nav.png "mysql-nav")

2. After you have landed on the ‘DB Systems’ page, ensure you have the correct Compartment selected and click “Create DB System”

    ![](./images/create-hw.png "mysql-nav2")

3. Name your MySQL Database System “MySQL-HW” and select the “HeatWave” offering
    ```bash
    <copy>MySQL-HW</copy>
    ```

    ![](./images/create-hw2.png "mysql-nav3")

4. Enter the admin credentials and under “networking”, make sure the “MDS-VCN” is selected and the Subnet is “Private Subnet”

    ![](./images/hw-priv.png "mysql-nav4")

    **Note:** there are two ways to do the next task. The first way (5 A) shows, instead of using MySQL Shell again to load the dump data which we will do in Lab 4, there is an alternate way to load the stored dump data in Object Storage Bucket into MySQL HeatWave using something called a 'PAR URL'. By using the PAR URL method, all the data in OS Bucket, will be loaded into HeatWave during the database creation. Hence completely eliminating the need of going through Lab 4 (it still might be useful to review Lab 4 on how to connect to MySQL HeatWave and what the alternate way of loading the data looks like using MySQL Shell, which is the second way (6 B)).

5. A) Leave the rest as it is and lastly under “Configure Backup Plan”, disable the “Automatic Backups”. Click on "Show advanced options" and select "Data Import"

    ![](./images/adv-options.png "adv-options-hw")

    ![](./images/data-imp.png "data-imp-options-hw")

    Once you are on the 'Data Import' tab, click on the "Click here to create a PAR URL" link.

    ![](./images/create-par.png "data-imp-options-hw2")

    After clicking the above link, another screen will appear where you will select the "MDS-Bucket" bucket from the drop down list, that we created in Lab 2.

    ![](./images/select-buck.png "select-bucket")

    ![](./images/select-buck2.png "select-bucket2")

    Once you have selected the appropriate bucket where the data was dumped, simply click "Create and set PAR URL". Your screen should look something similar to this:

    ![](./images/create-hw-w-par.png "create-hw-using-par")

    Afterwards, simply click on "Create" and your MySQL HeatWave System will start provisioning and will have the data ready and pre-loaded, once the HeatWave System is in "ACTIVE" status.

6. B) Now assuming you did not choose 5 A option, leave the rest as it is (do not include the PAR URL) and lastly under “Configure Backup Plan”, disable the “Automatic Backups”. Click “Create” afterwards

    ![](./images/create-hw-final.png "create-hw")

    **Note:** your MySQL HeatWave System will be created after 15-20 minutes

    ![](./images/active-hw.png "active-hw")

    **Note:** once your MySQL HeatWave database changes from the state of “Creating” to “Active”, write down the Private IP address

    ![](./images/hw-ip.png "hw-ip")

This concludes this lab. You may now **proceed to the next lab.**

## Acknowledgements

- **Author** - Ravish Patel, MySQL Solution Engineering

- **Contributors** - Perside Foster, MySQL Solution Engineering

- **Last Updated By/Date** - Ravish Patel, MySQL Solution Engineering, November 2022
