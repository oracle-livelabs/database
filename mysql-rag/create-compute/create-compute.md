# Create Linux Compute Instance

## Introduction

Oracle Cloud Infrastructure Compute lets you provision and manage compute hosts, known as instances . You can create instances as needed to meet your compute and application requirements. After you create an instance, you can access it securely from your computer or cloud shell.

In this lab, you will create a compartment, a Virtual Cloud Network,  and a Compute instance.

_Estimated Time:_ 10 minutes

### Objectives

In this lab, you will be guided through the following tasks:

- Create compartment.
- Create Virtual Cloud Network.
- Configure security list to allow incoming connections.
- Configure security list to allow HTTP incoming connections.
- Create Compute Instance

### Prerequisites

- An Oracle Free Tier or Paid Cloud Account


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

4. Under **Basic information**, provide a **VCN name**:

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

     ![Show subnet details](./images/9-mysql-vcn-subnets.png "Show subnet details")

2. On **private subnet-mysql-vcn** page, under **Security Lists**, click  **security List for private subnet-mysql-vcn**.

    ![Select security lists](./images/10-select-security-list.png "Select security lists")

3. On the **security list for private subnet-mysql-vcn** page, under **Ingress Rules**, click **Add Ingress Rules**.

    ![Add ingress rules](./images/11-add-ingress-rules.png "Add ingress rules")

4. On **Add Ingress Rules** panel, enter the following, and click **Add Ingress Rules**:

    **Source CIDR**:

    ```bash
    <copy>0.0.0.0/0</copy>
    ```

    **Destination Port Range**:

    ```bash
    <copy>3306,33060</copy>
    ```

    ![Ingress rules](./images/12-enter-ingress-rules.png "Ingress rules")

5. On **security list for private subnet-mysql-vcn** page, the new ingress rules are shown under **Ingress Rules**.

    ![New ingress rules](./images/13-new-ingress-rules.png "New ingress rules")

## Task 4: Configure security list to allow HTTP incoming connections

1. Click the **Navigation menu** in the upper left, navigate to **Networking**, and select **Virtual cloud networks**.

    ![Select VCN](./images/3-select-vcn.png "Select VCN")

2. Under **Compartment**, ensure **mysql** is selected, and click the VCN you created, **mysql-vcn**.

    ![Select VCN](./images/14-select-vcn.png "Select VCN")

3. On the **mysql-vcn** page, under **Subnets**, click  **public subnet-mysql-vcn**.

    ![Select public subnet](./images/15-public-subnet.png "Select public subnet")

4. Click **Default Security List for mysql-vcn**.

    ![Default security list](./images/16-default-security-list.png "Default security list")

5. On **Default Security List for mysql-vcn** page, under **Ingress Rules**, click **Add Ingress Rules**.

    ![Add ingress rules in default security list](./images/17-add-ingress-rules-default-security-list.png "Add ingress rules in default security list")

6. On **Add Ingress Rules** panel, enter the following, and click **Add Ingress Rules**:

    **Source CIDR**:

    ```bash
    <copy>0.0.0.0/0</copy>
    ```

    **Destination Port Range**:

    ```bash
    <copy>80,443</copy>
    ```

    ![Ingress rules](./images/18-enter-ingess-rules-default-security-list.png "Ingress rules") 

7. On **Default Security List for mysql-vcn** page, the new ingress rules are shown under **Ingress Rules**.

    ![New ingress rules](./images/19-new-ingress-rules-default-security-list.png "New ingress rules")


## Task 5: Create Compute Instance

You need a compute instance to connect to perform the database and application tasks

1. Click the **Navigation menu** in the upper left, navigate to **Compute**, and under **Compute**, select **Instances**.
  
    ![Click compute](./images/click-compute.png "Click compute")

2. Ensure **mysql** compartment is selected, and click click  **Create instance**.

     ![Create instance](./images/create-instance.png "Create instance")

3. On **Create compute instance** page, enter the name of the compute instance.

    ```bash
    <copy>mysql-compute</copy>
    ```

4. Ensure **mysql** compartment is selected.

    ![Compute instance name](./images/compute-name.png "Compute instance name")

5. In the **Placement** field, keep the selected **Availability Domain**.

6. In the **Image and Shape** field, keep the selected image, **Oracle Linux 8**, and the default shape.

    ![Compute image and shape](./images/compute-image-shape.png "Compute image and shape")

7. In **Primary VNIC information** field, ensure the following settings are selected:

    - **Primary Network**: **mysql-vcn**

    - **Subnet**: **public-subnet-mysql-vcn**

8. In **Primary VNIC IP addresses** field, ensure the following settings are selected:

    - **Private IPv4 address**: **Automatically assign private IPv4 address**

    - **Public IPv4 address**: Selected

    ![Network settings](./images/networking.png "Network settings")

9. In **Add SSH keys** field, click **Generate a key pair for me**.
  
    ![Add SSH Keys](./images/ssh-keys.png "Add SSH Keys")

10. Save the downloaded SSH keys in your .ssh folder. and rename the key. For example:

    ```bash
    <copy>ssh-key-2024</copy>
    ```

     ![Save SSH keys](./images/ssh-key-store.png "Save SSH Keys")

    > **Note:**   For linux and Mac terminals, make sure to asign the right permissions to your key, use:

    ```bash
        <copy>chmod 600 ssh-key-2024</copy>
    ```

11. Click '**Create**' to create your compute instance.

12. The compute instance will be ready to use after a few minutes. The state is shown as **Provisioning** while the instance is creating.

13. When the compute instance is ready to use, the state is shown as **Running**. _Note_ the **Public IP address** and the **Username**.

    ![Compute instance is created](./images/compute.png "Compute instance is created")

You may now **proceed to the next lab**.

## Acknowledgements

- **Author** - Craig Shallahamer, Applied AI Scientist, Viscosity North America
- **Contributor** - Perside Foster, MySQL Solution Engineering 
- **Last Updated By/Date** - Perside Foster, MySQL Solution Engineering , April 2025
