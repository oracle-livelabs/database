# Build HeatWave ML Web App  with PHP

## Introduction

MySQL HeatWave Machine Learning can easily be used for development tasks with existing Oracle services. New applications can also be created with the LAMP or other software stacks.

_Estimated Time:_ 30 minutes

### Objectives

In this lab, you will be guided through the following tasks:

- Install Apache and PHP and create PHP / MYSQL Connect ML access Application

### Prerequisites

- An Oracle Trial or Paid Cloud Account
- Some Experience with PHP
- Completed Lab 3

## Task 1: Create Compute instance

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

12. 'Assign a public IP' address should be set to Yes

    ![CONNECT](./images/05compute-ip.png "compute-ip ")

13. On Add SSH keys, paste the public key from the notepad.

    ![CONNECT](./images/05compute-id-rsa-paste.png "compute-id-rsa-past ")

14. Click '**Create**' to finish creating your Compute Instance.

15. The New Virtual Machine will be ready to use after a few minutes. The state will be shown as 'Provisioning' during the creation

    ![CONNECT](./images/05compute-privision.png "compute-provision ")

16. The state 'Running' indicates that the Virtual Machine is ready to use.

    ![CONNECT](./images/05compute-running.png "compute-running ")

## TASK 2: Install App Server (APACHE)

1. If not already connected with SSH, on Command Line, connect to the Compute instance using SSH ... be sure to replace the  "private key file"  and the "new compute instance IP".

    ```bash
        <copy>ssh -i private_key_file opc@new_compute_instance_ip</copy>
    ```

2. Install app server

    a. Install Apache

    ```bash
    <copy>sudo yum install httpd -y </copy>
    ```

    b. Enable Apache

    ```bash
    <copy>sudo systemctl enable httpd</copy>
    ```

    c. Start Apache

    ```bash
    <copy>sudo systemctl restart httpd</copy>
    ```

    d. Setup firewall

    ```bash
    <copy>sudo firewall-cmd --permanent --add-port=80/tcp</copy>
    ```

    e. Reload firewall

    ```bash
    <copy>sudo firewall-cmd --reload</copy>
    ```

3. From a browser test apache from your local machine using the Public IP Address of your Compute Instance

    **Example: http://129.213....**

## TASK 3: Install PHP

1. Install PHP:

    a. Install php:7.4

    ```bash
    <copy> sudo dnf module install php:7.4 -y</copy>
    ```

    b. Install associated PHP libraries

    ```bash
    <copy>sudo yum install php-cli php-mysqlnd php-zip php-gd php-mbstring php-xml php-json -y</copy>
    ```

    c. View PHP / MySQL libraries

    ```bash
    <copy>php -m |grep mysql</copy>
    ```

    d. View PHP version

    ```bash
    <copy>php -v</copy>
    ```

    e. Restart Apache

    ```bash
    <copy>sudo systemctl restart httpd</copy>
    ```

2. Create test PHP file (info.php)

    ```bash
    <copy>sudo nano /var/www/html/info.php</copy>
    ```

3. Add the following code to the editor and save the file (ctr + o) (ctrl + x)

    ```bash
        <copy><?php
    phpinfo();
    ?></copy>
        ```

4. From your local machine, browse the page info.php

    **Example: http://129.213.167.../info.php**

## TASK 4: Create Connection Test Code

1. Security update"   set SELinux to allow Apache to connect to MySQL

    ```bash
    <copy> sudo setsebool -P httpd_can_network_connect 1 </copy>
    ```

2. Create config.php

    ```bash
    <copy>cd /var/www/html</copy>
    ```

    ```bash
    <copy>sudo nano config.php</copy>
    ```

3. Add the following code to the editor and save the file (ctr + o) (ctl + x)

    ```bash
    <copy><?php
    // Database credentials
    define('DB_SERVER', '10.0.1...');// MDS server IP address
    define('DB_USERNAME', 'admin');
    define('DB_PASSWORD', 'Welcome#12345');
    define('DB_NAME', 'airportdb');
    //Attempt to connect to MySQL database
    $link = mysqli_connect(DB_SERVER, DB_USERNAME, DB_PASSWORD, DB_NAME);
    // Check connection
    if($link === false){
        die("ERROR: Could not connect. " . mysqli_connect_error());
    }
    // Print host information
    echo 'Successfull Connect.';
    echo 'Host info: ' . mysqli_get_host_info($link);
    ?>
    </copy>
    ```

4. From your local machine, browse the page info.php

    **Test Config.php on Web Sever http://150.230..../config.php**

## TASK 5: Create HeatWave ML Web App

1. Go to the development folder

    ```bash
    <copy>cd /var/www/html</copy>
    ```

2. Download the iris application zip file

    ```bash
    <copy> sudo wget https://objectstorage.us-phoenix-1.oraclecloud.com/p/2DOHO3J49Z66FDdv-C4tkEOjm5_XL6UWAECDaVoWGDVgCnSI1PajwAZpj2oFRp_A/n/idazzjlcjqzj/b/iris_app/o/iris.zip </copy>
    ```

    ```bash
    <copy>sudo unzip iris.zip</copy>
    ```

    ```bash
    <copy>cd /var/www/html/iris</copy>
    ```

    Replace the database IP in config.php file with your heatwave database IP and save the file.

    ```bash
    <copy>sudo nano config.php</copy>
    ```

    run the application as follows:

    computeIP//iris/iris_web.php

    ![MDS](./images/iris-web-php.png "iris-web-php")

## Acknowledgements

- **Author** - Perside Foster, MySQL Solution Engineering, Harsh Nayak, MySQL Solution Engineering

- **Contributors** - Mandy Pang, MySQL Principal Product Manager,  Priscila Galvao, MySQL Solution Engineering, Nick Mader, MySQL Global Channel Enablement & Strategy Manager
- **Last Updated By/Date** - Perside Foster, MySQL Solution Engineering, July 2022