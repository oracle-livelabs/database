# Create MySQL HeatWave Standard Database

## Introduction

In this lab, you will create and configure the a MySQL HeatWave standard DB Systems.

_Estimated Time:_ 10 minutes

### Objectives

In this lab, you will be guided through the following tasks:

- Create Stand Alone  MySQL Database instances 

### Prerequisites

- An Oracle Trial or Paid Cloud Account
- Some Experience with MySQL Shell
- Must complete Lab1

## Task 1: Create a MySQL DB System - Standalone.

In this Task, you will create and configure a MySQL Standalone DB System.

1. Open the navigation menu. Under Databases ->MySQL, click DB Systems
    ![MDS](./images/04mysql01.png " ")

2. Click Create MySQL DB System
    ![MDS](./images/04mysql02.png" ")

3. Create MySQL DB System dialog complete the fields in each section

    - Provide basic information for the DB System
    - Setup your required DB System
    - Create Administrator credentials
    - Configure Networking
    - Configure placement
    - Configure hardware
    - Exclude Backups

4. Provide basic information for the DB System:

    Select Compartment **heatwave**

    Enter Name
        ````
        <copy>heatwave-sa</copy>
        ````
    Enter Description
        ````
        <copy>MySQL HeatWAve Database Service Standalone instance</copy>
        ````

    Select **Standalone** to specify a Standalone DB System
        ![MDS](./images/04mysql03-1.png " ")

5. Create Administrator credentials

    **Enter Username** (write username to notepad for later use)

    **Enter Password** (write password to notepad for later use)

    **Confirm Password** (value should match password for later use)

    ![MDS](./images/04mysql04.png " ")

6. Configure networking Keep default values

    Virtual Cloud Network: **heatwave**

    Subnet: **Private Subnet-heatwave (Regional)**

    ![MDS](./images/04mysql05.png " ")

7. Configure placement  keep checked  "Availability Domain"

    Do not check "Choose a Fault Domain" for this DB System. Oracle will chooses the best placement for you.
    ![MDS](./images/04mysql06-1.png" ")

8. Configure hardware keep default shape  **MySQL.VM.Standard.E3.1.8GB**

    Data Storage Size (GB) keep default value **50**
    ![MDS](./images/04mysql07-1.png" ")

9. Configure Backups, "Enable Automatic Backups"

    Turn on button to enable automatic backup

    ![MDS](./images/04mysql08.png" ")

    Click the **Create button**
    ![MDS](./images/04mysql09-1.png" ")

10. The New MySQL DB System will be ready to use after a few minutes.

    The state will be shown as Creating during the creation
    ![MDS](./images/04mysql10-1.png" ")

11. The state Active indicates that the DB System is ready to use.

    Check  the MySQL endpoint (Address) under Instances in the MySQL DB System Details page.

    ![MDS](./images/04mysql11-1.png" ")

## Acknowledgements

- **Author** - Perside Foster, MySQL Solution Engineering
- **Contributors** - Airton Lastori, Principal Product Manager, Nick Mader, MySQL Global Channel Enablement & Strategy Manager
- **Last Updated By/Date** - Perside Foster, MySQL Solution Engineering, Oct 2022
