# Create an on-premise environment

## Introduction

In this lab, we will setup an on-prem environment in which we install a MySQL Server, MySQL Shell, and then lastly load a sample database into the on-prem MySQL Server.

_Estimated Time:_ 15 minutes

### Objectives

In this lab, you will be guided through the following tasks:

- Set up an on-prem environment
    - Create and configure Virtual Cloud Network (VCN) in OCI
    - Create SSH Key in OCI using Cloud Shell
    - Setup a Compute Instance
- Install MySQL Community Server and MySQL Shell
- Load a sample database into MySQL

### Prerequisites

- An Oracle Trial or Paid Cloud Account
- An environment where you can install/run a MySQL Server
- Some Experience with MySQL Shell

## Task 1: Create and configure Virtual Cloud Network (VCN) in OCI

1. Login to Oracle Cloud (OCI), click on the “Hamburger” menu on the top left. Navigate to “Networking” and “Virtual Cloud Networks”

    ![](./images2/ham-menu.png "oci-hamburger-menu")

    ![](./images2/vcn-menu.png "navigate-to-vcn")

2. Once on the Virtual Cloud Networks page, click “Start VCN Wizard” and select “Create VCN with Internet Connectivity”

    ![](./images2/vcn-wiz-2.png "create-vcn")

    ![](./images2/vcn-wiz1.png "vcn-wizard")

3. Name your VCN “MySQL-VCN” while making sure you are in the correct Compartment. Leave everything as it is, and click “Next”

    ```bash
    <copy>MySQL-VCN</copy>
    ```

    ![](./images2/name-vcn.png "name-vcn-wizard")

4. Review all the information and click “Create”

    ![](./images2/review-vcn.png "review-vcn-wizard")

5. Once the VCN is created, click “View Virtual Cloud Network”

    ![](./images2/view-vcn.png "view-vcn-wizard")

6. Once on the MySQL-VCN page, under “Resources” click “Subnets” and go to the “Private-Subnet-MySQL-VCN”

    ![](./images2/resources-vcn.png "resources-vcn")

7. On the Private Subnet page, under “Security Lists”, click on “Security List for Private Subnet-MySQL-VCN” and select “Add Ingress Rules”

    ![](./images2/sc-vcn.png "seclist-vcn")

    ![](./images2/add-ingr.png "add-ingress")

8. For the ‘Source CIDR’ enter “0.0.0.0/0”, select "TCP" for the 'IP Protocol' and for the Destination Port Range, enter “3306,33060”. In the ‘Description’ section, write “MySQL Port Access”

    ```bash
    <copy>0.0.0.0/0</copy>
    ```

    ```bash
    <copy>3306,33060</copy>
    ```

    ```bash
    <copy>MySQL Port Access</copy>
    ```

    ![](./images2/add-rule.png "add-ingress-rule")

## Task 2: Create SSH Key in OCI using Cloud Shell

1. Inside Oracle Cloud, navigate to "Cloud Shell" under 'Developer tools' next to your Home Region

    ![](./images2/devtools.png "developer-tools")

    ![](./images2/devtools-cldshell.png "cloud-shell")

2. Once the Cloud Shell loads, it should look similar to this:

    ![](./images2/cld-shell-prmpt.png "cloud-shell-prompt")

3. Inside your Cloud Shell, execute the command to create an SSH key-pair

    ```bash
    <copy>ssh-keygen -t rsa</copy>
    ```

    ![](./images2/key-gen.png "key-gen")

    **Note:** keep pressing the enter/return key for each question. Here is what it should look like, your public and private SSH keys will be stored in a directory called .ssh

    ![](./images/ssh-keypair.png "ssh-key-pair")

4. After your public/private rsa key pair has been created, go to the '.ssh' directory and copy the contents of the "id_rsa.pub" file

    ```bash
    <copy>cd .ssh</copy>
    ```

    ```bash
    <copy>ls</copy>
    ```

    ```bash
    <copy>cat id_rsa.pub</copy>
    ```

    ![](./images2/ssh-pub-key.png "ssh-pub-key")

## Task 3: Setup a Compute Instance

1. Within Oracle Cloud, go to the Navigation or Hamburger menu and under Compute, select “Instances”

    ![](./images2/compute.png "nav-compute")

2. Make sure you are in the right compartment, and click “Create instance”

    ![](./images2/create-compute.png "create-compute")

3. Name your compute instance "MySQL-Compute". For Placement, leave it at default. For Image and Shape, make sure "Oracle Linux 8" is selected and choose an appropriate Shape that fits your needs. Under Networking, make sure the Public Subnet of your MySQL-VCN is selected

    ```bash
    <copy>MySQL-Compute</copy>
    ```

    ![](./images2/create-compute2.png "create-compute2")

    ![](./images2/compute-image.png "create-compute3")

    ![](./images2/pub-sub.png "public-subnet")

4. Lastly for the 'Add SSH keys', select "Paste public keys" and paste the contents of the id_rsa.pub file here that we copied in Step 4 of Lab 1 Task 2. After pasting your public key, leave everything default and click "Create"

    ![](./images2/add-ssh.png "pubkey-compute")

5. Your Compute instance will be ready in a few minutes. Copy the Public IP address of your Compute instance afterwards.

    ![](./images2/ready-compute.png "ready-compute")

6. After copying the Public IP of your Compute, open/restore Cloud Shell. Once Cloud Shell loads, perform the ssh command to connect to your Compute instance

    ```bash
    <copy>ssh -i ~/.ssh/id_rsa opc@<your_compute_instance_ip></copy>
    ```

    ![](./images2/ssh-compute.png "ssh-into-compute")

## Task 4: Install MySQL Community Edition in your on-prem environment

1. Once you have your on-premise environment/Compute instance ready and are connected to it, download **MySQL Community Edition** on the Compute instance by executing

    ```bash
    <copy>sudo yum install mysql-server -y</copy>
    ```

    ![mysql-ce](./images2/install-mysql1.png "install-mysql-ce")

    **Note:** MySQL Community Server can also be downloaded by visiting this website: <https://dev.mysql.com/downloads/mysql/>

2. Start the MySQL server after it has been successfully installed onto your Compute instance. Once the server starts, login to MySQL:

    ```bash
    <copy>sudo systemctl start mysqld</copy>
    ```

    ```bash
    <copy>mysql -uroot --skip-password</copy>
    ```

    ![](./images2/start-mysql1.png "start-mysql")

    **Note:** during the installation of the MySQL server, it created a root account without a password. Therefore we have explicitly specified that there is no password and that the client program should not prompt for one, by providing the --skip-password option.

3. Change the root password

    ```bash
    <copy>ALTER USER 'root'@'localhost' IDENTIFIED BY 'pASsWordGoesHere';</copy>
    ```

    ![](./images2/change-pass2.png "change-root-pass")

    **Note:** after changing your root password, make a note of it or save it. This will be used later.

4. Exit MySQL and download MySQL Shell onto your on-prem environment

    ```bash
    <copy>exit</copy>
    ````

    ````bash
    <copy>sudo yum install mysql-shell -y</copy>
    ```

    ![](./images2/install-shell1.png "install-shell")

    **Note:** MySQL Shell can also be downloaded by visiting this website: https://dev.mysql.com/downloads/shell/

5. Once MySQL Shell is installed on your on-premise environment/Compute, you can login to your MySQL Server by either executing

    ```bash
    <copy>mysqlsh root@localhost</copy>
    ```

    ![](./images2/connect-shell1.png "connect-shell")

    -OR-

    ```bash
    <copy>mysqlsh -uroot -p</copy>
    ```

    ![](./images2/connect-shell2.png "connect-shell2")

## Task 5: Load the sample database into the MySQL on-prem

1. Exit out of your MySQL Server. Download the sample 'world' database onto your Compute instance, unzip the file, and load it onto your on-prem MySQL Server

    ```bash
    <copy>\q</copy>
    ````

    ```bash
    <copy>wget https://downloads.mysql.com/docs/world-db.zip</copy>
    ```

    ```bash
    <copy>unzip world-db.zip</copy>
    ```

    ```bash
    <copy>cd world-db</copy>
    ```

    ```bash
    <copy>mysql -u root -p < world.sql </copy>
    ```

    ![](./images2/download-sample1.png "download-sample-db")

    ![](./images2/load-sample1.png "load-sample-db")

    **Note:** additional sample MySQL databases can be found here: https://dev.mysql.com/doc/index-other.html

2. Login to your MySQL on-prem environment using MySQL Shell and check if the sample ‘world’ database was successfully loaded

    ```bash
    <copy>mysqlsh root@localhost</copy>
    ```

    ```bash
    <copy>\sql</copy>
    ```

    ```bash
    <copy>SHOW SCHEMAS;</copy>
    ```

    ```bash
    <copy>SHOW TABLES IN world;</copy>
    ```

    ![](./images2/connect-shell1.png "connect-shell")

    ![](./images2/confirm-load1.png "confirm-load-db")

    **Note:** exit MySQL Shell and minimize Cloud Shell afterwards.

    This concludes this lab. You may now **proceed to the next lab.**

## Acknowledgements

- **Author** - Ravish Patel, MySQL Solution Engineering
- **Contributors** - Perside Foster, MySQL Solution Engineering
- **Last Updated By/Date** - Ravish Patel, MySQL Solution Engineering, November 2022
