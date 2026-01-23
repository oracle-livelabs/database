# Install MySQL Enterprise Edition

## Introduction

Developers can access the full range of MySQL Enterprise Edition features for free while learning, developing, and prototyping.You wil be using the latest available download  from Oracle Technical Resources (OTR, formerly Oracle Technology Network, OTN). For more details review the   [MySQL Enterprise Edition Downloads page](https://www.oracle.com/mysql/technologies/mysql-enterprise-edition-downloads.html)

_Estimated Time:_ 20 minutes

### Objectives

In this lab, you will be guided through the following tasks:

- Install MySQL Enterprise Edition
- Install MySQL Shell and Connect to MySQL Enterprise 
- Start and test MySQL Enterprise Edition Install


### Prerequisites

This lab assumes you have:

- Completed Labs 4 
- or a working Oracle Linux machine

## Task 1: Get MySQL Enterprise Edition Download from Oracle Technology Network (OTN)

1. Connect to **myserver** instance using Cloud Shell (**Example:** ssh -i  ~/.ssh/id_rsa opc@132.145.17….)

     ```bash
    <copy>ssh -i ~/.ssh/id_rsa opc@<your_compute_instance_ip></copy>
    ```

    ![CONNECT](./images/ssh-login-2.png " ")

2. Create a new directory named "tmp"

    ```bash
    <copy>mkdir tmp</copy>
    ```

3. Navigate into the "tmp" directory

     ```bash
    <copy>cd tmp</copy>
    ```

4. Get  OTN MySQL Enterprise Edition package

    ```bash
    <copy>wget 'https://objectstorage.us-ashburn-1.oraclecloud.com/p/_85tMv-_I0WRJRAuHI9StGHfo3WXtAsSbpslsOIqIu2hsHgmKc8n7zmhk-5KvVw8/n/idazzjlcjqzj/b/mysql-ee-downloads/o/Oracle%20Technical%20Resource(OTR)/mysql-enterprise-9.2.0_el8_x86_64_bundle.tar'</copy>
    ```

5. Extract the contents of the `mysql-enterprise-9.2.0_el8_x86_64_bundle.tar` archive file

    ```bash
    <copy>tar xvf mysql-enterprise-9.2.0_el8_x86_64_bundle.tar</copy>
    ```

## Task 2: Install MySQL Enterprise Edition

1. Import the MySQL repository GPG key using the RPM package manager

    ```bash
    <copy>sudo rpm --import https://objectstorage.us-ashburn-1.oraclecloud.com/p/Yja90YIvw39JvHu0YusNxl_wdKS-1hPt0_a_39eT_ihp-xm8kYR3CA3eKe5ny99C/n/idazzjlcjqzj/b/mysql-ee-downloads/o/RPM-GPG-KEY-mysql-2023</copy>
    ```

2. Install the "yum-utils" package using the Yum package manager

    ```bash
    <copy>sudo yum install yum-utils</copy>
    ```

3. Add a new Yum repository configuration file located at "/home/opc/tmp"

    ```bash
    <copy>sudo yum-config-manager --add file:///home/opc/tmp</copy>
    ```
 
4. Disable the "mysql" module using the Yum package manager

    ```bash
    <copy>sudo yum module disable mysql -y </copy>
    ```

5. Install the "mysql-commercial-server" package

    ```bash
    <copy>sudo yum install mysql-commercial-server -y </copy>
    ```

6. Install the "mysql-shell-commercial" package

    ```bash
    <copy>sudo yum install mysql-shell-commercial -y </copy>
    ```

## Task 3: Configure and Start MySQL Enterprise Edition

1. Start the MySQL server using the systemd system and service manager

    ```bash
    <copy>sudo systemctl start mysqld</copy>
    ```

2. Check the status of the MySQL server service

    ```bash
    <copy>sudo systemctl status mysqld</copy>
    ```

3. List all running processes and filter for those containing "mysqld" in their command line

    ```bash
    <copy>ps -ef | grep mysqld</copy>
    ```

## Task 4: Change root password and create admin account

1. Search for the phrase "temporary password" in the "/var/log/mysqld.log" file, ignoring case sensitivity

    ```bash
    <copy>sudo grep -i 'temporary password' /var/log/mysqld.log</copy>
    ```

2. Login to MySQL using password retrieved in previous step

    ```bash
    <copy>mysqlsh -uroot -hlocalhost -p</copy>
    ```

3. Change root password

    ```bash
    <copy>ALTER USER 'root'@'localhost' IDENTIFIED BY 'Welcome#123';</copy>
    ```

4. Show MySQL server  status

    ```bash
    <copy>\status</copy>
    ```

5. The root account **can connect only locally**, so we create now the 'admin'@'%' account that **can connect locally and remotely**

    ```bash
    <copy>CREATE USER 'admin'@'%' IDENTIFIED BY 'Welcome#123';</copy>
    ```

    ```bash
    <copy> GRANT ALL ON *.* TO admin@'%' WITH GRANT OPTION;</copy>
    ```

    ```bash
    <copy>\q</copy>
    ```

You may now **proceed to the next lab**.

## Learn More

- [MySQL Enterprise Edition](https://www.oracle.com/mysql/enterprise/)
- [MySQL Linux Installation](https://dev.mysql.com/doc/en/binary-installation.html)
- [MySQL Shell Installation](https://dev.mysql.com/doc/mysql-shell/en/mysql-shell-install.html)

## Acknowledgements

- **Author** - Craig Shallahamer, Applied AI Scientist, Viscosity North America
- **Contributor** - Perside Foster, MySQL Solution Engineering 
- **Last Updated By/Date** - Perside Foster, MySQL Solution Engineering , July 2025
