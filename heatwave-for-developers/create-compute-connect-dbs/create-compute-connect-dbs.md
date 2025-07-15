# Connect to MySQL HeatWave With Compute and Create and Load DBShema and  data

## Introduction

When working in the cloud, there are often times when your servers and services are not exposed to the public internet. The Oracle Cloud Infrastructure (OCI) MySQL cloud service is an example of a service that is only accessible through private networks. Since the service is fully managed, we keep it siloed away from the internet to help protect your data from potential attacks and vulnerabilities. It’s a good practice to limit resource exposure as much as possible, but at some point, you’ll likely want to connect to those resources. That’s where Compute Instance, also known as a Bastion host, enters the picture. This Compute Instance Bastion Host is a resource that sits between the private resource and the endpoint which requires access to the private network and can act as a “jump box” to allow you to log in to the private resource through protocols like SSH.  This bastion host requires a Virtual Cloud Network and Compute Instance to connect with the MySQL DB Systems.

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

    ![CONNECT](./images/cloudshellopen.png "cloudshellopen ")

    ![CONNECT](./images/cloudshell-welcome.png "cloudshell welcome ")

    *Note: You can use the icons in the upper right corner of the Cloud Shell window to minimize, maximize, restart, and close your Cloud Shell session.

2. Once the cloud shell has started, create the SSH Key using the following command:

    ```bash
    <copy>ssh-keygen -t rsa</copy>
    ```

    Press enter for each question.

    Here is what it should look like.  

    ![CONNECT](./images/ssh-keygen.png "ssh keygen ")

3. The public  and  private SSH keys  are stored in ~/.ssh/id_rsa.pub.

4. Examine the two files that you just created.

    ```bash
    <copy>cd .ssh</copy>
    ```

    ```bash
    <copy>ls</copy>
    ```

    ![CONNECT](./images/ssh-list.png "ssh list ")

    Note in the output there are two files, a *private key:`id_rsa` and a public key: `id_rsa.pub`. Keep the private key safe and don't share its content with anyone. The public key will be needed for various activities and can be uploaded to certain systems as well as copied and pasted to facilitate secure communications in the cloud.

## Task 2: Create Compute instance

You will need a compute Instance to connect to your brand new MySQL database.

1. Before creating the Compute instance open a notepad

2. Do the followings steps to copy the public SSH key to the  notepad

    Open the Cloud shell
    ![CONNECT](./images/cloudshell-copy-ssh.png "cloudshell copy ssh")

    Enter the following command  

    ```bash
    <copy>cat ~/.ssh/id_rsa.pub</copy>
    ```

    ![CONNECT](./images/cloudshell-cat.png "cloudshell cat") 

3. Copy the id_rsa.pub content the notepad

    Your notepad should look like this
    ![CONNECT](./images/notepad-rsa-key.png "notepad rsa key ")  

4. To launch a Linux Compute instance, go to 
    Navigation Menu
    Compute
    Instances
    ![CONNECT](./images/compute-launch.png "compute launch ")

5. On Instances in **heatwave** Compartment, click  **Create Instance**
    ![CONNECT](./images/compute-create.png "compute create")

6. On Create Compute Instance

    Enter Name

    ```bash
    <copy>heatwave-client</copy>
    ```

7. Make sure **heatwave** compartment is selected

8. On Placement, keep the selected Availability Domain

9. On Image and Shape, keep the selected Image, Oracle Linux 8

      ![CONNECT](./images/compute-oracle-linux.png "compute oracle linux")  

10. Select Instance Shape: VM.Standard.E2.2

      ![CONNECT](./images/compute-shape-select.png "compute shape select")
 
11. On Networking, make sure '**heatwave-vcn**' is selected

    'Assign a public IP address' should be set to Yes

    ![CONNECT](./images/compute-vcn.png "compute vcn.")

12. On Add SSH keys, paste the public key from the notepad.
  
    ![CONNECT](./images/compute-id-rsa-paste.png "compute id rsa paste")

13. Click '**Create**' to finish creating your Compute Instance.

14. The New Virtual Machine will be ready to use after a few minutes. The state will be shown as 'Provisioning' during the creation
    ![CONNECT](./images/compute-provisioning.png "compute provisioning")

15. The state 'Running' indicates that the Virtual Machine is ready to use.

    ![CONNECT](./images/compute-running.png "compute running")

## Task 3: Connect to MySQL Database System and Create and Load DB schema

1. Copy the public IP address of the active Compute Instance to your notepad

    - Go to Navigation Menu
            Compute
            Instances
    ![CONNECT](./images/compute-list.png "compute list")

    - Click the `heatwave-cient` Instance link

    ![CONNECT](./images/compute-running.png "compute public ip")

    - Copy `heatwave-cient` plus  the `Public IP Address` to the notepad

2. Copy the private IP address of the active MySQl Database heatwave-client Service Instance to your notepad

    - Go to Navigation Menu
            Databases
            MySQL

     ![CONNECT](./images/db-list.png "db list")

    - Click the `heatwave-db` Database System link

     ![CONNECT](./images/mysql-heatwave-active.png "db active ")

    - Copy `heatwave-db` plus the `Private IP Address` to the notepad

3. Indicate the location of the private key you created earlier with **heatwave-client**.

    Enter the username **opc** and the Public **IP Address**.

    Note: The **heatwave-client**  shows the  Public IP Address as mentioned on TASK 5: #11

    (Example: **ssh -i ~/.ssh/id_rsa opc@132.145.170...**)

    ```bash
    <copy>ssh -i ~/.ssh/id_rsa opc@<your_compute_instance_ip></copy>
    ```

    ![CONNECT](./images/connect-signin.png "connect signin")

    **Install MySQL Shell on the Compute Instance**

4. You will need a MySQL client tool to connect to your new MySQL DB System from your client machine.

    Install MySQL Shell with the following command (enter y for each question)

    **[opc@…]$**

     ```bash
    <copy>sudo yum install mysql-shell -y</copy>
    ```

    ![CONNECT](./images/connect-shell.png "connect shell")

5. Use the following command to connect to MySQL using the MySQL Shell client tool. Be sure to add the MDS-HW private IP address at the end of the command. Also enter the admin user and the db password created on Lab 1

    (Example  **mysqlsh -uadmin -p -h10.0.1..   --sql**)

    **[opc@...]$**

    ```bash
    <copy>mysqlsh -uadmin -p -h 10.0.1.... --sql</copy>
    ```

    ![CONNECT](./images/connect-myslqsh.png "connect myslqsh")

6. List schemas in your heatwave instance before Shell Load

    ```bash
        <copy>show databses;</copy>
    ```

    ![CONNECT](./images/list-schemas-before.png "list schemas before")

7. Create  and load sample database (mysql\_customer\_orders) from object storage

     a. 

    ```bash
        <copy>\js</copy>
    ```

    b. 

    ```bash
    <copy>util.loadDump("https://objectstorage.us-ashburn-1.oraclecloud.com/p/If-D5OfqC9QrIMJwVQ5aOYWUPWf3n26do9KBOkKb96hnw9Sy-1s4C64lvwD48Sb6/n/mysqlpm/b/mysql_customer_orders/o/mco_dump_02102023/", {progressFile: "progress.json"})</copy>
    ```

    **Note** It takes about 5 minutes to create and load the mysql\_customer\_orders schema

8. List schemas in your heatwave instance after Shell Load

    a. 

    ```bash
        <copy>\sql</copy>
    ```

    b.
 
    ```bash
        <copy>show databases;</copy>
    ```
    
    ![CONNECT](./images/list-schemas-after.png "list schemas after")

9. View  the mysql\_customer\_orders total records per table in



    b. 

    ```bash
    <copy>SELECT table_name, table_rows FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'mysql_customer_orders';</copy>
    ```

    ![CONNECT](./images/mysql_customer_orders-list.png "mysql_customer_orderslist") 

You may now **proceed to the next lab**

## Acknowledgements

- **Author** - Perside Foster, MySQL Solution Engineering

- **Contributors** - Mandy Pang, Principal Product Manager, Salil Pradhan, Principal Product Manager, Nick Mader, MySQL Global Channel Enablement & Strategy Manager
- **Last Updated By/Date** - Perside Foster, MySQL Solution Engineering, March 2023
