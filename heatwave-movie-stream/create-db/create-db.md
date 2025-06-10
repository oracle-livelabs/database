# Create MySQL HeatWave Database System

![mysql heatwave](./images/mysql-heatwave-logo.jpg "mysql heatwave")

## Introduction

In this lab, you will create and configure a MySQL HeatWave DB System with HeatWave Cluster node.

A HeatWave cluster comprise of a MySQL DB System node and one or more HeatWave nodes. The MySQL DB System node includes a plugin that is responsible for cluster management, loading data into the HeatWave cluster, query scheduling, and returning query result.

![heatwave architect](./images/mysql-heatwave-architecture.png =50%x* "heatwave architect ")

_Estimated Time:_ 20 minutes

### Objectives

In this lab, you will be guided through the following tasks:

- Create Compartment
- Create Virtual Cloud Network
- Create MySQL HeatWave (DB System) Instance with a HeatWave Cluster attached

### Prerequisites

- An Oracle Trial or Paid Cloud Account

## Task 1: Create Compartment

1. Click the **Navigation Menu** in the upper left, navigate to **Identity & Security** and select **Compartments**.

2. On the Compartments page, click **Create Compartment**.

3. In the Create Compartment dialog box, complete the following fields:

    Name:

    ```bash
    <copy>movies</copy>
    ```

    Description:

    ```bash
    <copy>Compartment for MovieHub APP powered by MySQL HeatWave Database Service</copy>
    ```

4. The **Parent Compartment** should be your root compartment. Click **Create Compartment**
    ![VCN](./images/compartment-create.png "create the compartment")


## Task 2: Create Virtual Cloud Network

1. You should be signed in to Oracle Cloud!

    Click **Navigation Menu**,

    ![OCI Console Home Page](./images/homepage.png " home page")

2. Click  **Networking**, then **Virtual Cloud Networks**
    ![menu vcn](./images/home-menu-networking-vcn.png "home menu networking vcn ")

    Select the **movies** compartment

3. Click the 'Actions' menu and Click **Start VCN Wizard**
    ![vcn start wizard](./images/vcn-wizard-menu.png "vcn wizard menu")

4. Select 'Create VCN with Internet Connectivity'

    Click 'Start VCN Wizard'
    ![vcn wizard start create](./images/vcn-wizard-start.png "start vcn wizard start")

5. Create a VCN with Internet Connectivity

    On Basic Information, complete the following fields:

    VCN Name:

    ```bash
    <copy>HEATWAVE-VCN</copy>
    ```

    Compartment: Select  **movies**

    Your screen should look similar to the following
    ![select compartment](./images/vcn-wizard-compartment.png "select compartment")

6. Click **'Next'** at the bottom of the screen

7. Review Oracle Virtual Cloud Network (VCN), Subnets, and Gateways

    Click 'Create' to create the VCN
    ![create vcn](./images/vcn-wizard-create.png "create vcn")

8. When the Virtual Cloud Network creation completes, click 'View Virtual Cloud Network' to display the created VCN
    ![vcn creation completing](./images/vcn-wizard-view.png "vcn creation completing")

## Task 3: Configure security list to allow MySQL incoming connections

1. On HEATWAVE-VCN page in **movies** Compartment', on 'Subnets' tab , click  '**Private Subnet-HEATWAVE-VCN**'
     ![vcn subnet](./images/vcn-details-subnet.png "vcn details subnet")

2. On Private Subnet-HEATWAVE-VCN page on 'Security' tab,  click  '**Security List for Private Subnet-HEATWAVE-VCN**'
    ![vcn private security list](./images/vcn-private-security-list.png "vcn private security list")

3. On Security list for Private Subnet-HEATWAVE-VCN page on 'Security rules' tab and 'Ingress Rules' section, click '**Add Ingress Rules**'
    ![vcn private subnet](./images/vcn-private-security-list-ingress.png "vcn private security list ingress")

4. On Add Ingress Rules page under Ingress Rule 1

    a. Add an Ingress Rule with Source CIDR

    ```bash
    <copy>0.0.0.0/0</copy>
    ```

    b. Destination Port Range

    ```bash
    <copy>3306,33060</copy>
     ```

    c. Description

    ```bash
    <copy>MySQL Ports Access</copy>
    ```

    d. Click 'Add Ingress Rule'
    ![add ingres rule](./images/vcn-private-security-list-ingress-rules-mysql.png "vcn private security list ingress rukes mysql")

5. On Security List for Private Subnet-HEATWAVE-VCN page, the new Ingress Rules will be shown under the Ingress Rules List
    ![show ingres rule](./images/vcn-private-security-list-ingress-display.png "vcn private security list ingress display")

## Task 4: Configure security list to allow HTTP incoming connections

1. **Navigation Menu > Networking > Virtual Cloud Networks**

2. Open HEATWAVE-VCN and Click on 'Security' tab

3. Click 'Default Security List for HEATWAVE-VCN'

4. Click on the 'Security rules' tab

5. Click Add Ingress Rules page under Ingress Rule

    Add an Ingress Rule with Source CIDR

    ```bash
    <copy>0.0.0.0/0</copy>
    ```

    Destination Port Range

    ```bash
    <copy>80,443</copy>
    ```

    Description

    ```bash
    <copy>Allow HTTP and HTTPs connections</copy>
    ```

6. Click 'Add Ingress Rule'

    ![Add HTTP Ingress Rule](./images/vcn-ttp-add-ingress.png "Add HTTP Ingress Rule")

7. On Security List for Default Security List for HEATWAVE-VCN page, the new Ingress Rules will be shown under the Ingress Rules List

    ![View VCN Completed HTTP Ingress rules](./images/vcn-ttp-ingress-completed.png "View VCN Completed HTTP Ingress rules")

## Task 5: Create MySQL Database for HeatWave (DB System) instance

1. Click on Navigation Menu
         Databases, HeatWave MySQL
    ![home menu heatwave mysq](./images/home-menu-database-mysql.png "home menu heatwave mysql")

2. Click 'Create DB System'
    ![mysql create button](./images/mysql-menu.png " mysql create button")

3. Create MySQL DB System dialog by completing the fields in each section

    - Provide DB System information
    - Setup the DB system
    - Create Administrator credentials
    - Configure Networking
    - Configure placement
    - Configure hardware
    - Exclude Backups
    - Set up Advanced Options

4. For DB System Option Select **Development or Testing**

    ![heatwave db option](./images/mysql-create-option-develpment.png "heatwave db option")

5. Provide basic information for the DB System:

    a. Select Compartment **movies**

    b. Enter Name

    ```bash
    <copy>HW-MovieHub</copy>
    ```

    c. Enter Description

    ```bash
    <copy>MySQL HeatWave Database Instance</copy>
    ```

6. Create Administrator Credentials

    **Enter Username** (write username to notepad for later use)

    **Enter Password** (write password to notepad for later use)

    **Confirm Password** (value should match password for later use)

    ![heatwave db admin](./images/mysql-create-admin.png "heatwave db admin ")

7. Select **Standalone**

    ![heatwave db info setup](./images/mysql-create-info-setup.png "heatwave db info setup ")

8. On Configure networking, keep the default values

    a. Virtual Cloud Network: **HEATWAVE-VCN**

    b. Subnet: **Private Subnet-HEATWAVE-VCN (Regional)**

    c. On Configure placement under 'Availability Domain'

    Select AD-1  ...  Do not check 'Choose a Fault Domain' for this DB System.

    ![heatwave db network ad](./images/mysql-create-network-ad.png "heatwave db network ad ")

9. On Configure hardware

    a. Click on 'Edit' at the top right corner to expand the Configure hardware section

    b. Select the checkbox 'Enable HeatWave cluster'

    c. At 'Select Shape' section. Click on **Change shape** button to select the **MySQL.4** shape.

    ![heatwave db  shape](./images/mysql-create-db-shape.png "heatwave db shape ")

    d. At 'HeatWave cluster configuration' section. Click on **Configure HeatWave cluster**

    - 1. Click on **Change shape** button to select the **HeatWave.512GB** node shape. Click on **Select a shape**
    - 2. Keep **1** Node and the checkbox 'HeatWave Lakehouse' selected.
    - 3. Click on **Save changes**

    ![heatwave db  hardware](./images/mysql-create-db-hardware.png "heatwave db hardware ")

    e. For Data Storage Size (GB) Set value to: **1024**

     ![heatwave db hardware summary](./images/mysql-create-db-hardware-summary.png "heatwave db hardware summary")

10. On Configure Backups, disable 'Enable Automatic Backup'

    ![heatwave db  backup](./images/mysql-create-backup.png " heatwave db  backup")

11. Click on Show Advanced Options

12. Go to the Configuration tab

    a. Click on 'Select a database version' and choose the **latest MySQL '9.X.X Innovation'** version.

13. Go to the Connections tab

    a. In the Hostname field enter (same as DB System Name):

    ```bash
        <copy>HW-MovieHub</copy>
    ```

    b. Leave 'Read endpoint' unselected

    c. Choose '**Service defined**' for Security certificate

    ![heatwave db advanced](./images/mysql-create-advanced.png "heatwave db advanced ")

14. Review **Create MySQL DB System**  Screen

    ![heatwave db create](./images/mysql-create.png "heatwave db create ")

    Click the '**Create**' button

15. The New MySQL DB System will be ready to use after a few minutes

    The state will be shown as 'Creating' during the creation
    ![show creeation state](./images/mysql-create-in-progress.png "show creeation state")

16. The state 'Active' indicates that the DB System is ready for use

    ![show active state](./images/mysql-detail-active.png "show active state")

17. On HEATWAVE-HW Page, select the **Connections** tab and save the MySQL Endpoint (Private IP Address) to notepad for use later.

    ![heatwave endpoint](./images/mysql-detail-endpoint.png "heatwave endpoint")

You may now **proceed to the next lab**

## Learn More

- [Oracle Cloud Infrastructure MySQL Database Service Documentation](https://docs.oracle.com/en-us/iaas/mysql-database/home.htm)
- [MySQL Database Documentation](https://www.MySQL.com)

## Acknowledgements

- **Author** - Cristian Aguilar, MySQL Solution Engineering
- **Contributors** - Perside Foster, MySQL Principal Solution Engineering, Mandy Pang, MySQL Principal Product Manager
- **Last Updated By/Date** - Cristian Aguilar, MySQL Solution Engineering, May 2025