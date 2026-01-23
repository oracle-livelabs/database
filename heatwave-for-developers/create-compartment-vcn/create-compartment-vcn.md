# Create your Compartment and Virtual Cloud Network  

## Introduction

Create a compartment and Virtual Cloud Network (VCN) to connect your Linux instance to the internet. You will configure all the components needed to create your virtual network.

_Estimated Time:_ 15 minutes

### Objectives

In this lab, you will be guided through the following tasks:

- Create Compartment
- Create Virtual Cloud Network
- Configure security list to allow MySQL incoming connections
- Configure security list to allow HTTP incoming connections

### Prerequisites

- An Oracle Free Tier or Paid Cloud Account
- A web browser
- Login to OCI to land on OCI Dashboard

![INTRO](./images/oci-dashboard.png "land on oci dashboard")

## Task 1: Create Compartment

1. Click the **Navigation Menu** in the upper left, navigate to **Identity & Security** and select **Compartments**.

2. On the Compartments page, click **Create Compartment**.

    **Note:** Two Compartments, _Oracle Account Name_ (root) and a compartment for ManagedCompartmentForPaaS, were automatically created by OCI.

3. In the Create Compartment dialog box, complete the following fields:

    Name:

    ```bash
    <copy>heatwave</copy>
    ```

    Description:

    ```bash
    <copy>Compartment for MySQL HeatWave Application Development Project</copy>
    ```

4. Select the **Parent Compartment**, and click **Create Compartment**
    ![VCN](./images/compartment-create.png "create the compartment")

## Task 2: Create Virtual Cloud Network

1. Click Navigation Menu
    Select Networking
    Select Virtual Cloud Networks
    ![VCN](./images/menuvcn.png "show vcn menu")

2. Click **Start VCN Wizard**
    ![VCN](./images/networking-main.png "show networking main dialog")

3. Select 'Create VCN with Internet Connectivity'

    Click 'Start VCN Wizard'
    ![VCN](./images/vcn-wizard-start.png "start vcn wizard")

4. Create a VCN with Internet Connectivity

    On Basic Information, complete the following fields:

    VCN Name:

    ```bash
    <copy>heatwave-vcn</copy>
    ```

    Compartment: Select  **heatwave**

    Your screen should look similar to the following
        ![VCN](./images/vcn-internet-connect-config.png "Configured VCN internet connection ")

5. Click 'Next' at the bottom of the screen

6. Review Oracle Virtual Cloud Network (VCN), Subnets, and Gateways

    Click 'Create' to create the VCN

7. The Virtual Cloud Network creation is completing
    ![VCN](./images/vcn-wizard-review.png "Review complete vcn wizard work")

8. Click 'View VCN' to display the created VCN
    ![VCN](./images/wizard-view-vcn.png "display the created")

## Task 3: Configure security list to allow MySQL incoming connections

1. On MDS-VCN page under 'Subnets in (root) Compartment', click  '**private subnet-heatwave-vcn**'
     ![VCN](./images/vcn-details.png "Show VCN Details")

2. On Private Subnet-MDS-VCN page under 'Security Lists',  click  '**Security List for private subnet-heatwave-vcn**'
    ![VCN](./images/vcn-security-list.png "Show Security Lists")

3. On Security List for Private Subnet-MDS-VCN page under 'Ingress Rules', click '**Add Ingress Rules**'
    ![VCN](./images/vcn-mysql-ingress.png "Prepar for add Add Ingress Rules")

4. On Add Ingress Rules page under Ingress Rule

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

5. Click 'Add Ingress Rule'
    ![VCN](./images/vcn-mysql-add-ingress.png "Save  MySQL Ingress Rule  entries")

6. On Security List for Private Subnet-MDS-VCN page, the new Ingress Rules will be shown under the Ingress Rules List
    ![VCN](./images/vcn-mysql-ingress-completed.png "view  MySQL Ingress Rules")

## Task 4: Configure security list to allow HTTP incoming connections

1. Navigation Menu > Networking > Virtual Cloud Networks

2. Open heatwave-vcn

3. Click  public subnet-heatwave-vcn

4. Click Default Security List for heatwave-vcn

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
    <copy>Allow HTTP connections</copy>
    ```

6. Click 'Add Ingress Rule'

    ![VCN](./images/vcn-ttp-add-ingress.png "Add HTTP Ingress Rule")

7. On Security List for Default Security List for mds_vcn page, the new Ingress Rules will be shown under the Ingress Rules List

    ![VCN](./images/vcn-ttp-ingress-completed.png "View VCN Completed HTTP Ingress rules")

You may now **proceed to the next lab**

## Acknowledgements

- **Author** - Perside Foster, MySQL Solution Engineering
- **Contributors** - Salil Pradhan, Principal Product Manager, Nick Mader, MySQL Global Channel Enablement & Strategy Manager
- **Last Updated By/Date** - Perside Foster, MySQL Solution Engineering, March 2023
