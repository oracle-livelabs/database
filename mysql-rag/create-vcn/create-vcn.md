# Create the Virtual Cloud Network

## Introduction

In this lab, you will create a create a compartment, and a Virtual Cloud Network.

_Estimated Time:_ 15 minutes

### Objectives

In this lab, you will be guided through the following tasks:

- Create compartment.
- Create Virtual Cloud Network.
- Configure security list to allow incoming connections.
- Configure security list to allow HTTP incoming connections.

### Prerequisites

- An Oracle trial or paid cloud account.
- Some experience with MySQL Shell.
- You have logged into the OCI Console using the default identity domain.

## Task 1: Create Compartment

1. Click the **Navigation menu** in the upper left, navigate to **Identity & Security**, and under **Identity**, select **Compartments**.

    ![Select compartment](./images/1-select-compartment.png "Select compartment")

2. On the Compartments page, click **Create Compartment**.

3. In the **Create Compartment** dialog box, enter the following:

    **Name**:

    ```bash
    <copy>mysql</copy>
    ```

    **Description**:

    ```bash
    <copy>Compartment for mysql</copy>
    ```

4. Click **Create Compartment**.

    ![Create a compartment](./images/2-create-compartment.png "Create a compartment")

## Task 2: Create Virtual Cloud Network

1. Click the **Navigation menu** in the upper left, navigate to **Networking**, and select **Virtual cloud networks**.

    ![Select VCN](./images/3-select-vcn.png "Select VCN")

2. Under **Compartment**, select **mysql**, and Click **Start VCN Wizard**.

    ![Start VCN Wizard](./images/4-start-vcn-wizard.png "Start VCN Wizard ")

3. In the **Start VCN Wizard** dialog box, select **Create VCN with Internet Connectivity**, and click **Start VCN Wizard**.

    ![Start VCN Wizard](./images/5-start-vcn-wizard-dialog-box.png "Start VCN Wizard ")

4. Scroll down to  **Basic information**, provide a **VCN name**:

    ```bash
    <copy>mysql-vcn</copy>
    ```

5. Ensure that **mysql** compartment is selected, and click **Next**.

    ![VCN configuration](./images/6-create-vcn-internet-connectivity.png "VCN configuration")

6. Review Oracle Virtual Cloud Network (VCN), Subnets, and Gateways, and click **Create**.

    ![Create VCN](./images/7-create-vcn.png "Create VCN")

7. When the Virtual Cloud Network is created, click **View VCN** to display the created VCN.

    ![View VCN](./images/8-view-vcn.png "View VCN")

## Task 3: Configure security list to allow incoming connections

1. On the **mysql-vcn** page, under **Subnets**, click  **private subnet-mysql-vcn**.

     ![Show subnet details](./images/9-vcn-subnet.png "Show subnet details")

2. On **private subnet-mysql-vcn** page, click **Security**

    ![Select security](./images/10-private-subnet-security.png "Select security")

3. Click  **security list for private subnet-mysql-vcn**.

    ![Select security lists](./images/11-select-security-list.png "Select security lists")

4. On the **security list for private subnet-mysql-vcn** page, click **Security rules**

    ![Add Security rules](./images/12-select-security-rules.png "Add Security rules")

5. On the **security list for private subnet-mysql-vcn** page, under **Ingress Rules**, click **Add Ingress Rules**.

    ![Add ingress rules](./images/13-add-ingress-rules.png "Add ingress rules")

6. On **Add Ingress Rules** panel, enter the following, and click **Add Ingress Rules**:

    **Source CIDR**:

    ```bash
    <copy>0.0.0.0/0</copy>
    ```

    **Destination Port Range**:

    ```bash
    <copy>3306,33060</copy>
    ```

    ![Ingress rules](./images/14-enter-ingress-rules.png "Ingress rules")

7. On **security list for private subnet-mysql-vcn** page, the new ingress rules are shown under **Ingress Rules**.

    ![New ingress rules](./images/15-new-ingress-rules.png "New ingress rules")

## Task 4: Configure security list to allow HTTP incoming connections

1. Click the **Navigation menu** in the upper left, navigate to **Networking**, and select **Virtual cloud networks**.

    ![Select VCN](./images/3-select-vcn.png "Select VCN")

2. Under **Compartment**, ensure **mysql** is selected, and click the VCN you created, **mysql-vcn**.

    ![Select VCN](./images/16-select-vcn.png "Select VCN")

3. On **mysql-vcn** page, click **Subnets**

    ![Select Subnet](./images/17-mysql-vcn.png "Select Subnet")

4. On the **mysql-vcn** page, under **Subnets**, click  **public subnet-mysql-vcn**.

    ![Select public subnet](./images/18-public-vcn-subnet.png "Select public subnet")

5. On the **public subnet-mysql-vcn** page, click **Security**.

    ![Select public subnet](./images/19-public-subnet-security.png "Select public subnet")

6. On the **public subnet-mysql-vcn** page, click **Default Security List for mysql-vcn**.

    ![Select Default Security List for mysql-vcn](./images/20-public-subnet-security-list.png "Select Default Security List for mysql-vcn")

7. Under **Security**, click **Security Rules**.

    ![Default Security Rules](./images/21-default-security-list.png "Default Security Rules")

8. On **Default Security List for mysql-vcn** page, under **Ingress Rules**, click **Add Ingress Rules**.

    ![Add ingress rules in default security list](./images/22-add-ingress-rules-default-security-list.png "Add ingress rules in default security list")

9. On **Add Ingress Rules** panel, enter the following, and click **Add Ingress Rules**:

    **Source CIDR**:

    ```bash
    <copy>0.0.0.0/0</copy>
    ```

    **Destination Port Range**:

    ```bash
    <copy>80,443</copy>
    ```

    ![Ingress rules](./images/23-enter-ingess-rules-default-security-list.png "Ingress rules") 

10. On **Default Security List for mysql-vcn** page, the new ingress rules are shown under **Ingress Rules**.

    ![New ingress rules](./images/24-new-ingress-rules-default-security-list.png "New ingress rules")


You may now **proceed to the next lab**.

## Acknowledgements

- **Author** - Craig Shallahamer, Applied AI Scientist, Viscosity North America
- **Contributor** - Perside Foster, MySQL Solution Engineering 
- **Last Updated By/Date** - Perside Foster, MySQL Solution Engineering , July 2025
