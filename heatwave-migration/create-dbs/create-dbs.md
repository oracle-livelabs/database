# Create On-Prem MySQL System

## Introduction

In this lab, we will setup an on-prem environment in which we install a MySQL Server, MySQL Shell, and then lastly load a sample database into the on-prem MySQL Server

_Estimated Time:_ ? minutes

### Objectives

In this lab, you will be guided through the following tasks:

- Install MySQL Community Edition
- Install MySQL Shell
- Load a sample database

### Prerequisites

- An Oracle Trial or Paid Cloud Account
- An environment where you can install/run a MySQL Server
- Some Experience with MySQL Shell

## Task 1: Install MySQL Community Edition in your on-prem environment

1. Identify the **Operating System** where you want to install MySQL. For this example, I have chosen an Oracle Linux OS which is based on the RHEL
    ![os-version](./images2/image.png "os-version")

2. Download **MySQL Community Edition**
    ```bash
    <copy>sudo yum install mysql-server -y</copy>
    ```

    ![mysql-ce](./images2/install-mysql.png "install-mysql-ce")

    **Note:** once your installation is complete, your screen should look similar to this

    ![](./images2/install-mysql2.png "install-mysql-ce2")

3. Start the MySQL server, find your mysqld.log file, grab the temporary password, and login to your MySQL environment

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

4. Change the root password

    ```bash
    <copy>ALTER USER ‘root’@’localhost’ IDENTIFIED BY ‘pASsWordGoesHere’;</copy>
    ```

    ![](./images2/change-pass.png "change-root-pass")

5. Exit MySQL and download MySQL Shell onto your on-prem environment

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

## Task 2: Load the sample database into the MySQL on-prem

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
