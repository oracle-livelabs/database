# Create MySQL Database HeatWave

## Introduction

In this lab, you will create and configure a MySQL DB System

_Estimated Time:_ 20 minutes

### Objectives

In this lab, you will be guided through the following tasks:

- Create MySQL Database for HeatWave (DB System)

### Prerequisites

- An Oracle Trial or Paid Cloud Account
- Some Experience with MySQL Shell
- Complete Lab1

## Task 1: Create MySQL Database for HeatWave (DB System)

1. Go to Navigation Menu
         Databases
         MySQL
         DB Systems
    ![MDS](./images/mysql-menu.png "mysql menu")

2. Click 'Create MySQL DB System'
    ![MDS](./images/mysql-create.png "mysql create ")

3. Select the Development or Testing Option
    ![MDS](./images/mysql_create_select_option.png "select option")

4. Create MySQL DB System dialog complete the fields in each section

    - Provide basic information for the DB System
    - Setup your required DB System
    - Create Administrator credentials
    - Configure Networking
    - Configure placement
    - Configure hardware
    - Exclude Backups
    - Advanced Options - Data Import

5. Provide basic information for the DB System:

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
    ![MDS](./images/mysql-heatwave.png "mysql heatwave ")

6. Create Administrator Credentials

    **Enter Username** (write username to notepad for later use)

    **Enter Password** (write password to notepad for later use)

    **Confirm Password** (value should match password for later use)

    ![MDS](./images/mysql-password.png "mysql password ")

7. On Configure networking, keep the default values

    Virtual Cloud Network: **MDS-VCN**

    Subnet: **Private Subnet-MDS-VCN (Regional)**

    ![MDS](./images/mysql-vcn.png "mysql vcn ")

8. On Configure placement under 'Availability Domain'

    Select AD-3

    Do not check 'Choose a Fault Domain' for this DB System.

    ![MDS](./images/mysql-fault-domain.png "mysql fault domain ")

9. On Configure hardware, keep default shape as **MySQL.HeatWave.VM.Standard.E3**

    Data Storage Size (GB) Set value to:  **1024**

    ```bash
    <copy>1024</copy>
    ```

    ![MDS](./images/mysql-hardware.png "mysql hardware ")

10. On Configure Backups, disable 'Enable Automatic Backup'

    ![MDS](./images/mysql-backup.png "mysql backup ")

11. Click on Show Advanced Options

12. Go to the Networking tab, in the Hostname field enter (same as DB System Name):

    ```bash
        <copy>MDS-HW</copy> 
    ```

13. Review **Create MySQL DB System**  Screen

    ![MDS](./images/mysql_create_db.png "mysql create db")

    Click the '**Create**' button

14. The New MySQL DB System will be ready to use after a few minutes

    The state will be shown as 'Creating' during the creation
    ![MDS](./images/mysql-create-button.png "mysql create button ")

15. The state 'Active' indicates that the DB System is ready for use

    On MDS-HW Page, check the MySQL Endpoint (Private IP Address)

    ![MDS](./images/mysql-create-button.png"mysql create button ")


## Acknowledgements

- **Author** - Perside Foster, MySQL Solution Engineering

- **Contributors** - Mndy Pang, Principal Product Manager, Salil Pradhan, Principal Product Manager, Nick Mader, MySQL Global Channel Enablement & Strategy Manager
- **Last Updated By/Date** - Perside Foster, MySQL Solution Engineering, May 2022
