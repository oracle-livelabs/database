# Create a Compute Instance

## Introduction

Oracle Cloud Infrastructure Compute lets you provision and manage compute hosts, known as instances. You can create instances as needed to meet your compute and application requirements. After you create an instance, you can access it securely from your computer or cloud shell.

_Estimated Time:_ 10 minutes

### Objectives

In this lab, you will be guided through the following task:

- Create Compute Instance

### Prerequisites

- You have completed Lab 1.

## Task 1: Create a Compute Instance

You need a compute instance to connect to perform the database and application tasks.

1. Click the **Navigation menu** in the upper left, navigate to **Compute**, and under **Compute**, select **Instances**.
  
    ![Click compute](./images/1-click-compute.png "Click compute")

2. Ensure **mysql** compartment is selected, and click **Create instance**.

     ![Create instance](./images/2-create-instance.png "Create instance")

3. On **Create compute instance** page, enter the name of the compute instance.

    ```bash
    <copy>mysql-compute</copy>
    ```

4. Ensure **mysql** compartment is selected.

5. In the **Placement** field, keep the selected **Availability domain**.

    ![Compute instance name](./images/3-compute-name.png "Compute instance name")

6. In the **Image and Shape** field, keep the default shape.

    Click the **Change Image** button to selected image, **Oracle Linux 8**.
    ![Change Image Button](./images/4-compute-image-change-button.png "Change Image Button")

7. In the **Select Image Screen** do the followings:
    1. Click the **Oracle Linux Box**
    2. Enter the following in the search box:

        ```bash
        <copy>Oracle Linux 8</copy>
        ```

    3. Select the **Oracle Linux 8** entry
    4. Click the **Select Image** button
        ![Compute image and shape change](./images/4-compute-image-change.png "Compute image and shape change")

8. In the final **Image and Shape** field, keep the default shape and the new **Oracle Linux 8** image , and click **Next**.
   ![New Compute image and shape](./images/4-compute-image-shape.png "New Compute image and shape")

9. Under **Security** panel, click **Next**.

10. Under **Networking** panel, in **Primary network** field, select **Select existing virtual cloud network**, and ensure the following settings are selected:

    - **Virtual cloud network compartment**: **mysql**

    - **Virtual cloud network**: **mysql-vcn**

11. Under **Subnet**, ensure the following are selected:

    - **Subnet compartment**: **mysql**

    - **Subnet**: **public-subnet-mysql-vcn**

12. In **Primary VNIC IP addresses** field, ensure the following settings are selected:

    - **Private IPv4 address**: **Automatically assign private IPv4 address**

    - **Automatically assign public IPv4 address**: Enabled

    ![Network settings](./images/5-networking.png "Network settings")

13. In **Add SSH keys** field, select **Generate a key pair for me** and Click **Download private key**
  
    ![Add SSH Keys](./images/6-ssh-keys.png "Add SSH Keys")

14. Save **private key** in your ssh folder, and rename the key. For example:

    ```bash
    <copy>ssh-key-2025</copy>
    ```

     ![Save SSH keys](./images/7-ssh-key-store-mac-win.png "Save SSH Keys")

15. Click **Next**, and then **Next**.

16. Click **Create** to create your compute instance.

17. The compute instance will be ready to use after a few minutes. The state is shown as **Provisioning** while the instance is creating.

18. When the compute instance is ready to use, the state is shown as **Running**. _Save_ the **Public IP address** and the **Username**.

    ![Compute instance is created](./images/8-compute.png "Compute instance is created")

You may now **proceed to the next lab**.

## Acknowledgements

- **Author** - Craig Shallahamer, Applied AI Scientist, Viscosity North America
- **Contributor** - Perside Foster, MySQL Solution Engineering 
- **Last Updated By/Date** - Perside Foster, MySQL Solution Engineering , July 2025
