# Connect to MySQL HeatWave With Compute and Create and Load DBShema and  data

## Introduction

When working in the cloud, there are often times when your servers and services are not exposed to the public internet. MySQL HeatWave on OCI is an example of a service that is only accessible through private networks. Since the service is fully managed, we keep it siloed away from the internet to help protect your data from potential attacks and vulnerabilities. It’s a good practice to limit resource exposure as much as possible, but at some point, you’ll likely want to connect to those resources. That’s where Compute Instance, also known as a Bastion host, enters the picture. This Compute Instance Bastion Host is a resource that sits between the private resource and the endpoint which requires access to the private network and can act as a “jump box” to allow you to log in to the private resource through protocols like SSH.  This bastion host requires a Virtual Cloud Network and Compute Instance to connect with the MySQL DB Systems.

Today, you will use the Compute Instance to connect from the browser to a HeatWave DB System

_Estimated Lab Time:_ 20 minutes

### Objectives

In this lab, you will be guided through the following tasks:

- Create SSH Key on OCI Cloud
- Create Compute Instance
- Setup Compute Instance with MySQL Shell
- Connect to MySQL Heatwave System
- Create and Load mysql\_customer\_orders Schema

### Prerequisites

- An Oracle Trial or Paid Cloud Account
- Some Experience with MySQL Shell
- Must Complete Lab 2

## Task 1: Create SSH Key on OCI Cloud Shell

The Cloud Shell machine is a small virtual machine running a Bash shell which you access through the Oracle Cloud Console (Homepage). You will start the Cloud Shell and generate a SSH Key to use  for the Bastion  session.

1. To start the Oracle Cloud shell, go to your Cloud console and click the cloud shell icon at the top right of the page. This will open the Cloud Shell in the browser, the first time it takes some time to generate it.

    ![Open Cloudshell](./images/cloudshellopen.png "cloudshellopen ")

    ![Cloudshell Message](./images/cloudshell-welcome.png "cloudshell welcome ")

    *Note: You can use the icons in the upper right corner of the Cloud Shell window to minimize, maximize, restart, and close your Cloud Shell session.

2. Once the cloud shell has started, create the SSH Key using the following command:

    ```bash
    <copy>ssh-keygen -t rsa</copy>
    ```

    Press enter for each question.

    Here is what it should look like.  

    ![Generate SSH Key](./images/ssh-keygen.png "ssh keygen ")

3. The SSH keys are stored as follows:
    - public SSH key stored in ~/.ssh/id_rsa.pub.
    - private SSH keys stored in ~/.ssh/id_rsa

4. Examine the two files that you just created.

    ```bash
    <copy>cd .ssh</copy>
    ```

    ```bash
    <copy>ls</copy>
    ```

    ![SSH files list](./images/ssh-list.png "ssh list ")

    **Note** in the output there are two files, a *private key:`id_rsa` and a public key: `id_rsa.pub`. Keep the private key safe and don't share its content with anyone. The public key will be needed for various activities and can be uploaded to certain systems as well as copied and pasted to facilitate secure communications in the cloud.

5. To asign the right permissions to your SSH keys, run the following command:

    ```bash
    <copy>chmod 600 id_rsa.pub</copy>
    ```

    ```bash
    <copy>chmod 600 id_rsa</copy>
    ```

## Task 2: Copy public SSH key value to Notepad

You will need a compute Instance to connect to your brand new MySQL database.

1. Before creating the Compute instance open a notepad

2. Do the followings steps to copy the public SSH key to the  notepad

    Open the Cloud shell
    ![Copy SSh Key](./images/cloudshell-copy-ssh.png "cloudshell copy ssh")

    Enter the following command  

    ```bash
    <copy>cat ~/.ssh/id_rsa.pub</copy>
    ```

    ![Display SSH Key](./images/cloudshell-cat.png "cloudshell cat") 

3. Copy the id_rsa.pub content the notepad

    Your notepad should look like this
    ![Completed SSH key](./images/notepad-rsa-key.png "notepad rsa key ")

## Task 3: Create Compute instance

1. To launch a Linux Compute instance, go to 
    Navigation Menu
    Compute
    Instances
    ![Compute Template](./images/compute-launch.png "compute launch ")

2. On Instances in **lakehouse** Compartment, click  **Create Instance**
    ![Create Compute button](./images/compute-create.png "compute create")

3. On Create Compute Instance

    Enter Name

    ```bash
    <copy>heatwave-client</copy>
    ```

4. Make sure **lakehouse** compartment is selected

5. On Placement, keep the selected Availability Domain

6. Keep the selected Image, Oracle Linux 8

    ![Use Linux OS](./images/compute-oracle-linux.png "compute oracle linux")  

7. Change the Instance Shape:
    - Click **Change shape** button
    - Click **Virtual Machine** box
    - Click **Specialty and previous generation** box
    - Click **VM.Standard.E2.2**
    - Click the **Select Shape** button

    ![New Shape](./images/compute-shape-select.png "compute shape select")

8. On Networking, make sure '**heatwave-vcn**' is selected

    'Assign a public IP address' should be set to Yes

    ![Select VCN](./images/compute-vcn.png "compute vcn.")

9. On Add SSH keys, paste the public key from the notepad.
  
    ![Add SSH key](./images/compute-id-rsa-paste.png "compute id rsa paste")

10. Click '**Create**' to finish creating your Compute Instance.

11. The New Virtual Machine will be ready to use after a few minutes. The state will be shown as 'Provisioning' during the creation
    ![Provision Compute](./images/compute-provisioning.png "compute provisioning")

12. The state 'Running' indicates that the Virtual Machine is ready to use.

    ![Completed Compute](./images/compute-running.png "compute running")

## Task 4: Connect to Compute and Install MySQl Shell

1. Copy the public IP address of the active Compute Instance to your notepad

    - Go to Navigation Menu
            Compute
            Instances
        ![Navigate to Compute ](./images/compute-list.png "compute list")

    - Click the `heatwave-cient` Instance link

        ![Compute Instance List](./images/compute-running.png "compute public ip")

    - Copy the compute name `heatwave-cient`  and  the `Public IP Address` to the notepad

2. Copy the private IP address of the active MySQl Database heatwave-client Service Instance to your notepad

    - Go to Navigation Menu
            Databases
            MySQL

        ![Database list](./images/db-list.png "db list")

    - Click the `heatwave-db` Database System link

        ![HeatWave create complete](./images/mysql-heatwave-active.png"mysql heatwave active ")

    - Select the **Connections** tab, copy the database nane `heatwave-db`  and the `Private IP Address` to the notepad
        ![HeatWave create complete connection](./images/mysql-heatwave-connection-tab.png"mysql heatwave connection ")
3. Indicate the location of the private key you created earlier with **heatwave-client**.

    Enter the username **opc** and the Public **IP Address**.

     (Example: **ssh -i ~/.ssh/id_rsa opc@132.145.170...**)

    ```bash
    <copy>ssh -i ~/.ssh/id_rsa opc@<your_compute_instance_ip></copy>
    ```

    ![SSH Connected](./images/connect-signin.png "connect signin")

    **Install MySQL Shell on the Compute Instance**

4. You will need a MySQL client tool to connect to your new MySQL DB System from your client machine.

    Install MySQL Shell with the following command (enter y for each question)

    **[opc@…]$**

     ```bash
    <copy>sudo yum install mysql-shell -y</copy>
    ```

    ![MySQL Shell Install](./images/connect-shell.png "connect shell")

You may now **proceed to the next lab**

## Acknowledgements

- **Author** - Perside Foster, MySQL Solution Engineering

- **Contributors** - Abhinav Agarwal, Senior Principal Product Manager, Nick Mader, MySQL Global Channel Enablement & Strategy Manager
- **Last Updated By/Date** - Perside Foster, MySQL Solution Engineering, May 2023
