# Create On-Prem MySQL System

## Introduction

In this lab, we will setup an on-prem environment in which we install a MySQL Server, MySQL Shell, and then lastly load a sample database into the on-prem MySQL Server

_Estimated Time:_ ? minutes

### Objectives

In this lab, you will be guided through the following tasks:

- How to set up an on-prem environment
- Install MySQL Community Edition
- Install MySQL Shell
- Load a sample database

### Prerequisites

- An Oracle Trial or Paid Cloud Account
- An environment where you can install/run a MySQL Server
- Some Experience with MySQL Shell

## Task 1: Set up an on-prem environment

**Note: if you already have an on-prem environment with MySQL installed and have data loaded, skip to Lab 2 Task 1.**

**But assuming you don't have an on-prem environment, start by following the below steps in order to set one up that looks like the image below which uses Oracle Linux 8 as it's OS. Oracle Linux is based on the RHEL.**
![os-version](./images2/image.png "os-version")

1. Login to Oracle Cloud (OCI), go to the Navigation or Hamburger menu again. Navigate to “Networking” and “Virtual Cloud Networks”

    ![](./images/images/nav-vcn.png "navigate-to-vcn")

2. Once on the Virtual Cloud Networks page, click “Start VCN Wizard” and select “Create VCN with Internet Connectivity”

    ![](./images/images/create-vcn.png "create-vcn")

    ![](./images/images/vcn-wizard.png "vcn-wizard")

3. Name your VCN “MDS-VCN” while making sure you are in the correct Compartment. Leave everything as it is, and click “Next”
    ```bash
    <copy>MDS-VCN</copy>
    ```

    ![](./images/images/name-vcn.png "name-vcn-wizard")

4. Review all the information and click “Create”

    ![](./images/images/review-vcn.png "review-vcn-wizard")

5. Once the VCN is created, click “View Virtual Cloud Network”

    ![](./images/images/view-vcn.png "view-vcn-wizard")

6. Once on the MDS-VCN page, under “Resources” click “Subnets” and go to the “Private-Subnet-MDS-VCN”

    ![](./images/images/resources-vcn.png "resources-vcn")

7. On the Private Subnet page, under “Security Lists”, click on “Security List for Private Subnet-MDS-VCN” and select “Add Ingress Rules”

    ![](./images/images/sc-vcn.png "seclist-vcn")

    ![](./images/images/add-ingr.png "add-ingress")

8. For the ‘Source CIDR’ enter “0.0.0.0/0”, select "TCP" for the 'IP Protocol' and for the Destination Port Range, enter “3306,33060”. In the ‘Description’ section, write “MySQL Port Access”
    ```bash
    <copy>0.0.0.0/0</copy>
    ```
    ```bash
    <copy>3306,33060</copy>
    ```

    ![](./images/images/add-rule.png "add-ingress-rule")

9. Inside Oracle Cloud, navigate to "Cloud Shell" under 'Developer tools' next to your Home Region

    ![](./images/devtools.png "developer-tools")

    ![](./images/devtools-cldshell.png "cloud-shell")

10. Once the Cloud Shell loads, it should look similar to this:

    ![](./images/cld-shell-prmpt.png "cloud-shell-prompt")

11. Inside your Cloud Shell, execute the command to create an SSH key-pair

    ```bash
    <copy>ssh-keygen -t rsa</copy>
    ```

    ![](./images/key-gen.png "key-gen")

    **Note:** keep pressing enter for each question. Here is what it should look like, your public and private SSH keys will be stored in a directory .ssh

    ![](./images/ssh-keypair.png "ssh-key-pair")

12. Go to the .ssh directory and copy the contents of the id_rsa.pub file

    ```bash
    <copy>cd .ssh</copy>
    ```
    ```bash
    <copy>ls</copy>
    ```
    ```bash
    <copy>cat id_rsa.pub</copy>
    ```

    ![](./images/ssh-pub-key.png "ssh-pub-key")

13. Within Oracle Cloud, go to the Navigation or Hamburger menu and under Compute, select “Instances”

    ![](./images/compute.png "nav-compute")

14. Make sure you are in the right compartment, and click “Create instance”

    ![](./images/create-compute.png "create-compute")

15. Name your compute instance “MDS-Compute”, leave everything default, and make sure the Public Subnet of your MDS-VCN is selected under the Networking section

    ![](./images/create-compute2.png "create-compute2")

    ![](./images/pub-sub.png "public-subnet")

16. For the “Add SSH keys”, select “Paste public keys” and paste the contents of the id_rsa.pub file here

    ![](./images/ssh-compute.png "pubkey-compute")

17. Click “Create” and your Virtual Machine will be ready in a few minutes

    ![](./images/crt-compute.png "final-compute")

    ![](./images/ready-compute.png "ready-compute")

18. Once your VM or Compute Instance is ready, copy the Public IP address and open Cloud Shell. Perform the ssh command to login to your instance

    ```bash
    <copy>ssh -i ~/.ssh/id_rsa opc@<your_compute_instance_ip></copy>
    ```

    ![](./images/ssh-compute2.png "ssh-into-compute")

## Task 2: Install MySQL Community Edition in your on-prem environment

1. Once you have your system/environment ready and are logged in using SSH, download **MySQL Community Edition** on it
    ```bash
    <copy>sudo yum install mysql-server -y</copy>
    ```

    ![mysql-ce](./images2/install-mysql.png "install-mysql-ce")

    **Note:** once your installation is complete, your screen should look similar to this

    ![](./images2/install-mysql2.png "install-mysql-ce2")

2. Start the MySQL server, find your mysqld.log file, grab the temporary password, and login to your MySQL environment

    ```bash
    <copy>sudo systemctl start mysqld</copy>
    ````
    ````bash
    <copy>sudo find / -iname mysqld.log</copy>
    ````
    ````bash
    <copy>grep 'temporary password' /var/log/mysql/mysqld.log</copy>
    ````
    ````bash
    <copy>mysql -u root -p<temporary-password></copy>
    ```

    **Note:** during my installation of the MySQL server, it created a root account without a password. Hence, I can just skip some the above steps and can login like so:
    ```bash
    <copy>sudo systemctl start mysqld</copy>
    ````
    ````bash
    <copy>mysql -uroot --skip-password</copy>
    ```

    ![](./images2/start-mysql.png "start-mysql")

3. Change the root password

    ```bash
    <copy>ALTER USER 'root'@'localhost' IDENTIFIED BY 'pASsWordGoesHere';</copy>
    ```

    ![](./images2/change-pass.png "change-root-pass")

4. Exit MySQL and download MySQL Shell onto your on-prem environment

    ```bash
    <copy>exit</copy>
    ````
    ````bash
    <copy>sudo yum install mysql-shell -y</copy>
    ```

    ![](./images2/install-shell.png "install-shell")

    ![](./images2/install-shell2.png "install-shell2")

    **Note:** once you have MySQL Shell installed, you can login to your MySQL environment by either executing

    ```bash
    <copy>mysqlsh root@localhost</copy>
    ```

    ![](./images2/connect-shell.png "connect-shell")

    -OR-

    ```bash
    <copy>mysqlsh</copy>
    <copy>\connect root@localhost</copy>
    ```

    ![](./images2/connect-shell2.png "connect-shell2")

## Task 3: Load the sample database into the MySQL on-prem

1. Download the sample 'world' database, unzip the file, and load it into MySQL on-prem

    ```bash
    <copy>wget https://downloads.mysql.com/docs/world-db.zip</copy>
    ````
    ````bash
    <copy>unzip world-db.zip</copy>
    ````
    ````bash
    <copy>cd world-db</copy>
    ````
    ````bash
    <copy>mysql -u root -p < world.sql </copy>
    ```

    ![](./images2/download-sample.png "download-sample-db")

    ![](./images2/load-sample.png "load-sample-db")

2. Login to your MySQL on-prem environment and check if the sample ‘world’ database was successfully loaded

    ```bash
    <copy>mysql -u root -p</copy>
    ````
    ````bash
    <copy>SHOW SCHEMAS;</copy>
    ````
    ````bash
    <copy>SHOW TABLES IN world;</copy>
    ```

    ![](./images2/login-mysql.png "login-mysql")

    ![](./images2/confirm-load.png "confirm-load-db")

    This concludes this lab. You may now **proceed to the next lab.**

## Acknowledgements

- **Author** - Ravish Patel, MySQL Solution Engineering
- **Contributors** - Perside Foster, MySQL Solution Engineering
- **Last Updated By/Date** - Ravish Patel, MySQL Solution Engineering, November 2022
