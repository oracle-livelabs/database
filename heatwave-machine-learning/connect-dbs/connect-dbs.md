# CONNECT TO MYSQL HeatWave

## Introduction

When working in the cloud, there are often times when your servers and services are not exposed to the public internet. The Oracle Cloud Infrastructure (OCI) MySQL cloud service is an example of a service that is only accessible through private networks. Since the service is fully managed, we keep it siloed away from the internet to help protect your data from potential attacks and vulnerabilities. It’s a good practice to limit resource exposure as much as possible, but at some point, you’ll likely want to connect to those resources. That’s where Compute Instance, also known as a Bastion host, enters the picture. This Compute Instance Bastion Host is a resource that sits between the private resource and the endpoint which requires access to the private network and can act as a “jump box” to allow you to log in to the private resource through protocols like SSH.  This bastion host requires a Virtual Cloud Network and Compute Instance to connect with the MySQL DB Systems.

Today, you will use the Compute Instance to connect from the browser to a MDS DB System

_Estimated Lab Time:_ 20 minutes

### Objectives

In this lab, you will be guided through the following tasks:

- Create SSH Key on OCI Cloud
- Create Compute Instance
- Setup Compute Instance with MySQL Shell
- Connect to MySQL DB System

### Prerequisites

- An Oracle Trial or Paid Cloud Account
- Some Experience with MySQL Shell
- Must Complete Lab 1

## Task 1: Create SSH Key on OCI Cloud Shell

The Cloud Shell machine is a small virtual machine running a Bash shell which you access through the Oracle Cloud Console (Homepage). You will start the Cloud Shell and generate an SSH Key to use  for the Bastion Session.

1. To start the Oracle Cloud shell, go to your Cloud console and click the cloud shell icon at the top right of the page. This will open the Cloud Shell in the browser, the first time it takes some time to generate it.

    ![CONNECT](./images/cloudshellopen.png "cloudshellopen ")

    ![CONNECT](./images/cloudshell-open-display.png "cloudshell-open-display ")

    **Note:** You can use the icons in the upper right corner of the Cloud Shell window to minimize, maximize, restart, and close your Cloud Shell session.*

2. Once the cloud shell has started, create the SSH Key using the following command:

    ```bash
    <copy>ssh-keygen -t rsa</copy>
    ```

    Press enter for each question.

    Here is what it should look like.

    ![CONNECT](./images/ssh-key.png "ssh-key")

3. The public and private SSH keys are stored in ~/.ssh/id_rsa.pub.

4. Examine the two files that you just created.

    ```bash
    <copy>cd .ssh</copy>
    ```

    ```bash
    <copy>ls</copy>
    ```

    ![CONNECT](./images/ssh-ls.png "ssh-ls ")

    There are two files in the output, a *private key:* `id_rsa` and a *public key:* `id_rsa.pub`. Keep the private key safe and don't share its content with anyone. The public key will be needed for various activities and can be uploaded to certain systems as well as copied and pasted to facilitate secure communications in the cloud.

## Task 2: Create Compute instance
You will need a compute Instance to connect to your brand new MySQL database.

1. Before creating the Compute instance open a notepad

2. Do the followings steps to copy the public SSH key to the  notepad

    Open the Cloud shell
    ![CONNECT](./images/cloudshell-key-copy.png "cloudshell-key-copy ")

    Enter the following command

    ```bash
    <copy>cat ~/.ssh/id-rsa.pub</copy>
    ```

    ![CONNECT](./images/cloudshell-key-display.png "cloudshell-key-display ")

3. Copy the id_rsa.pub content to the notepad

    Your notepad should look like this
    ![CONNECT](./images/notepad-rsa-key.png "notepad-rsa-key ")

4. To launch a Linux Compute instance, go to
    Navigation Menu
    Compute
    Instances
    ![CONNECT](./images/05compute-instance-menu.png "compute-instance-menu ")

5. On Instances in **(root)** Compartment, click  **Create Instance**
    ![CONNECT](./images/05compute-create-menu.png "compute-create-menu ")

6. On Create Compute Instance

    Enter Name

    ```bash
    <copy>MDS-Client</copy>
    ```

7. Make sure **(root)** compartment is selected

8. On Placement, keep the selected Availability Domain

9. On Image and Shape, keep the selected Image, Oracle Linux 8

      ![CONNECT](./images/05compute-image.png "compute-image ")

10. Select Instance Shape: VM.Standard.E2.2

      ![CONNECT](./images/05compute-shape.png "compute-shape ")

11. On Networking, make sure '**MDS-VCN**' is selected

    'Assign a public IP address should be set to Yes

    ![CONNECT](./images/05compute-ip.png "compute-ip ")

12. On Add SSH keys, paste the public key from the notepad.

    ![CONNECT](./images/05compute-id-rsa-paste.png "compute-id-rsa-past ")

13. Click '**Create**' to finish creating your Compute Instance.

14. The New Virtual Machine will be ready to use after a few minutes. The state will be shown as 'Provisioning' during the creation

    ![CONNECT](./images/05compute-privision.png "compute-provision ")

15. The state 'Running' indicates that the Virtual Machine is ready to use.

    ![CONNECT](./images/05compute-running.png "compute-running ")

## Task 3: Connect to MySQL Database System

1. Copy the public IP address of the active Compute Instance to your notepad

    - Go to Navigation Menu
            Compute
            Instances
    ![CONNECT](./images/db-list.png "db-list")

    - Click the `MDS-Client` Compute Instance link

    ![CONNECT](./images/05compute-intance-link.png "compute-intance-link ")

    - Copy `MDS-Client` plus  the `Public IP Address` to the notepad

2. Copy the private IP address of the active MySQl Database Service Instance to your notepad

    - Go to Navigation Menu
            Databases
            MySQL
     ![CONNECT](./images/db-list.png "db-list ")

    - Click the `MDS-HW` Database System link

     ![CONNECT](./images/db-active.png "db-active ")

    - Copy `MDS-HW` plus the `Private IP Address` to the notepad

3. Your notepad should look like the following:
     ![CONNECT](./images/notepad-rsa-key-compute-mds.png "notepad-rsa-key-compute-mds ")

4. Indicate the location of the private key you created earlier with **MDS-Client**.

    Enter the username **opc** and the Public **IP Address**.

    Note: The **MDS-Client**  shows the  Public IP Address as mentioned on TASK 5: #11

    (Example: **ssh -i ~/.ssh/id_rsa opc@132.145.170...**)

    ```bash
    <copy>ssh -i ~/.ssh/id_rsa opc@<your_compute_instance_ip></copy>
    ```

   ![CONNECT](./images/06connect-signin.png "connect-signin ")

    **Install MySQL Shell on the Compute Instance**

5. You will need a MySQL client tool to connect to your new MySQL DB System from your client machine.

    Install MySQL Shell with the following command (enter y for each question)

    **[opc@…]$**

    ```bash
    <copy>sudo yum install mysql-shell -y</copy>
    ```

    ![CONNECT](./images/06connect-shell.png "connect-shell ")

   **Connect to MySQL Database Service**

6. From your Compute instance, connect to MDS-HW MySQL using the MySQL Shell client tool.

   The endpoint (IP Address) can be found in your notepad or the MDS-HW MySQL DB System Details page, under the "Endpoint" "Private IP Address".

    ![CONNECT](./images/06connect-end-point.png "connect-end-point ")

7. Use the following command to connect to MySQL using the MySQL Shell client tool. Be sure to add the MDS-HW private IP address at the end of the command. Also, enter the admin user and the database password created on Lab 1

    (Example  **mysqlsh -uadmin -p -h10.0.1..   --sql**)

    **[opc@...]$**

    ```bash
    <copy>mysqlsh -uadmin -p -h 10.0.1.... --sql</copy>
    ```

    ![CONNECT](./images/06connect-myslqsh.png "connect-myslqsh ")

You may now proceed to the next lab.

## Learn More

- [Cloud Shell](https://www.oracle.com/devops/cloud-shell/?source=:so:ch:or:awr::::Sc)
- [Virtual Cloud Network](https://docs.oracle.com/en-us/iaas/Content/Network/Concepts/overview.htm)
- [OCI Bastion Service] (https://docs.public.oneportal.content.oci.oraclecloud.com/en-us/iaas/Content/Bastion/Tasks/connectingtosessions.html)

## Acknowledgements

- **Author** - Perside Foster, MySQL Solution Engineering
- **Contributor** - Frédéric Descamps, MySQL Community Manager
- **Last Updated By/Date** - Perside Foster, July  2022
