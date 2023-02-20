# Create MySQL Database HeatWave

## Introduction

In this lab, you will create and configure a Virtual Cloud Network and a MySQL HeatWave Database System. 

_Estimated Time:_ 15 minutes

### Objectives

In this lab, you will be guided through the following tasks:

- Create a Virtual Cloud Network
- Create MySQL HeatWave Database

### Prerequisites

- An Oracle Trial or Paid Cloud Account
- Some Experience with MySQL Shell

## Task 1: Create a Virtual Cloud Network

1. Click **Navigation Menu** in the up-left corner of the page

    ![VCN](./images/01dashboard.png"dashboard")

2. Click **Virtual Cloud Networks**

    ![VCN](./images/03vcn-nav-menu.png"vcn-nav-menu")

3. Click **Start VCN Wizard**

    ![VCN](./images/03vcn-wizard.png"vcn-wizard")

4. Select 'Create VCN with Internet Connectivity'

    Click 'Start VCN Wizard'
    ![VCN](./images/03vcn-create.png "vcn-create ")

5. Create a VCN with Internet Connectivity

    On Basic Information, complete the following fields:

    VCN Name:

    ```bash
    <copy>MDS-VCN</copy>
    ```

    Compartment: Select  **(root)**

    Your screen should look similar to the following

    ![VCN](./images/03vcn-create-screen.png "vcn-create-screen")

6. Click 'Next' at the bottom of the screen

7. Review Oracle Virtual Cloud Network (VCN), Subnets, and Gateways

    Click '**Create**' to create the VCN

    ![VCN](./images/03vcn-create-button.png "vcn-create-button")

8. The Virtual Cloud Network creation is completing.
   Then click '**View VCN**' to display the created VCN

    ![VCN](./images/03vcn-create-complete.png "vcn-create-complete ")

9. On MDS-VCN page under 'Subnets in (root) Compartment', click  '**Private Subnet-MDS-VCN**'

    ![VCN](./images/03vcn-create-display.png "vcn-create-display ")


10. On Private Subnet-MDS-VCN page under 'Security Lists',  click  '**Security List for Private Subnet-MDS-VCN**'

     ![VCN](./images/03vcn-subnets.png "vcn-subnets")
    
11. On Security List for Private Subnet-MDS-VCN page under 'Ingress Rules', click '**Add Ingress Rules**'

    ![VCN](./images/03vcn-seclist.png " vcn-seclist")

    ![VCN](./images/03vcn-ingress.png "vcn-ingress ")

12. On Add Ingress Rules page under Ingress Rule 1

    Add an Ingress Rule with Source CIDR

    ```bash
    <copy>0.0.0.0/0</copy>
    ```

    Destination Port Range

    ```bash
    <copy>3306,33060</copy>
    ```

    Description

    ```bash
    <copy>MySQL Port Access</copy>
    ```

    Click 'Add Ingress Rule'

        ![VCN](./images/03vcn-ingress-rule.png "vcn-ingress-rule")

13. On Security List for Private Subnet-MDS-VCN page, the new Ingress Rules will be shown under the Ingress Rules List

    ![VCN](./images/03vcn-ingress-rule-list.png "vcn-ingress-rule-list")

14. Because we want also create a web application in last lab, we open now the port 80/HTTP. <br>
    Click **Navigation Menu**, **Networking**, then **Virtual Cloud Networks**

    ![VCN](./images/03vcn-nav-menu.png"vcn-nav-menu")

15. Click the VCN name '**MDS-VCN**' to show the subnets

    ![VCN](./images/03vcn-list.png"vcn-list")

16. Click the subnet '**Public Subnet-MDS-VCN**' to show the associated security lists

    ![VCN](./images/03vcn-create-display.png"vcn-create-display")

17. On Public Subnet-MDS-VCN page under 'Security Lists', click '**Default Security List for MDS-VCN**'

    ![VCN](./images/03vcn-public-security-lists.png"vcn-public-security-lists")

18. On Security List for Public Subnet-MDS-VCN page under 'Ingress Rules', click '**Add Ingress Rules**'
    ![VCN](./images/03vcn-ingress.png "vcn-ingress ")

19. On Add Ingress Rules page under Ingress Rule 1

    Add an Ingress Rule with Source CIDR

    ```bash
    <copy>0.0.0.0/0</copy>
    ```

    Destination Port Range

    ```bash
    <copy>80</copy>
    ```

    Description

    ```bash
    <copy>HTTP Access</copy>
    ```

    Click 'Add Ingress Rule'
        ![VCN](./images/03vcn-ingress-rule-80.png "vcn-ingress-rule-80")

20. On Security List for Public Subnet-MDS-VCN page, the new Ingress Rules will be shown under the Ingress Rules List
    ![VCN](./images/03vcn-public-ingress-rule-list.png "vcn-public-ingress-rule-list")

## Task 2: Create a MySQL Database for HeatWave (DB System) 

1. Go to Navigation Menu
         Databases
         MySQL
         DB Systems
    ![MDS](./images/04mysql-nav-menu.png " mysql-nav-menu")

2. Click 'Create MySQL DB System'

    ![MDS](./images/04mysql-create-db.png "mysql-create-db")

3. Create MySQL DB System dialog and complete the fields in each section

    - Provide basic information for the DB System
    - Setup your required DB System
    - Create Administrator credentials
    - Configure Networking
    - Configure placement
    - Configure hardware
    - Exclude Backups
    - Advanced Options - Set  Host Name

4. Provide basic information for the DB System:

    Select Compartment **(root)**

    Enter Name

    ```bash
    <copy>MDS-HW</copy>
    ```

    Enter Description

    ```bash
    <copy>MySQL Database Service HeatWave instance</copy>
    ```

    Select **HeatWave** to specify a HeatWave DB System

    ![MDS](./images/04mysql-select-heatwave.png "mysql-select-heatwave")

5. Create Administrator Credentials (write username and password to notepad for later use)

    **Enter Username** : admin 

    **Enter Password** : 

    **Confirm Password** (value should match the password for later use)

    ![MDS](./images/04mysql-set-password.png "mysql-set-password")

6. On Configure networking, keep the default values

    Virtual Cloud Network: **MDS-VCN**

    Subnet: **Private Subnet-MDS-VCN (Regional)**

    ![MDS](./images/04mysql-vcn.png "mysql-vcn")

7. On Configure hardware, keep default shape as **MySQL.HeatWave.VM.Standard.E3**

    Data Storage Size (GB) Set value to:  **512**

    ```bash
    <copy>512</copy>
    ```

    ![MDS](./images/04mysql-data-storage.png "mysqldata-storage")

8. On Configure Backups, disable 'Enable Automatic Backup'

    ![MDS](./images/04mysqlset-backup.png "mysqlset-backup")

9. Go to the Networking tab, in the Hostname field enter (same as DB System Name):

    ```bash
    <copy>MDS-HW</copy>
    ```

10. Click the '**Create**' button

    ![MDS](./images/04mysql-create-button.png " mysql_create-button")

    

11. The New MySQL DB System will be ready to use after a few minutes

    The state will be shown as 'Creating' during the creation

    ![MDS](./images/04mysql-create-display.png"mysql-create-display ")

12. The state 'Active' indicates that the DB System is ready for use

    On MDS-HW Page, check the MySQL Endpoint (Private IP Address)

    ![MDS](./images/04mysql-create-active.png"mysql-create-active ")

## Acknowledgements

- **Author** - Perside Foster, MySQL Solution Engineering
- **Contributors** - Mandy Pang, MySQL Principal Product Manager,  Priscila Galvao, MySQL Solution Engineering, Nick Mader, MySQL Global Channel Enablement & Strategy Manager, Frédéric Descamps, MySQL Community Manager, Marco Carlessi, MySQL Solution Engineering
- **Last Updated By/Date** - Perside Foster, MySQL Solution Engineering, July 2022
