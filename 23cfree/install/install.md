# Installing and configuring Oracle Database 23c Free

## Introduction

This lab walks you through installing the database software, creating the database and creating the workshop user on Linux.

There are other deployment options that will not be covered in the workshop but will be linked in the Learn More section. These include Docker and VirtualBox deployments.

Estimated Time: 25 minutes

### Objectives

In this lab, you will:
* Setup the operating system
* Install the database software
* Create the database
* Create the workshop user

### Prerequisites

This lab assumes you have:
* A virtual machine running Linux (or running the LiveLabs Sandbox environment)
* All previous labs successfully completed
* Access to the internet to download the software

## Task 1: Operating System Setup

1. Open a terminal if you don't currently have one open. To open one Click on Activities and then Terminal.

    ![Open Terminal](images/.png " ")

2. Create the directories needed for this workshop.

    ```
    <copy>
    sudo mkdir /u01
    sudo chown oracle:oinstall /u01
    mkdir /u01/downloads
    mkdir /u01/app
    mkdir /u01/app/oracle
    mkdir /u01/app/oracle/ords
    </copy>
    ```
    ![Make Directories](images/.png " ")

2. Before installing you should check to see if anything is running on port 1521. This is what the database configure command will use when creating the listener. If it cannot it will try and use another port. If a service is running on that port you can try and restart it to see if it will restart on another port. If you choose to run with a different port then just make sure to adjust the commands as you go with the correct port.

    ````
    <copy>
    sudo netstat -anp|grep 1521
    </copy>
    ````

    Restart the service using the "sudo systemctl restart" command. Make sure to replace the text below the the service from the previous command

    ````
    <copy>
    sudo systemctl restart <replace with service>
    </copy>
    ````

    Verify port 1521 is available

    ````
    <copy>
    sudo netstat -anp|grep 1521
    </copy>
    ````

3. Enable the developer repo to be able to run the prerequisites check as a part of the install
    ```
    <copy>
    sudo dnf config-manager --set-enabled ol8_developer
    </copy>
    ```
    ![Image alt text](images/.png " ")

## Task 2: Database Setup

4. Get the download for 23c Free
    ```
    <copy>
    cd /u01/downloads
    wget https://download.oracle.com/otn-pub/otn_software/db-free/oracle-database-free-23c-1.0-1.el8.x86_64.rpm
    </copy>
    ```
    ![Download Install](images/.png " ")

5. Install the database software using the dnf command. This will take about 5-10 minutes.
    ```
    <copy>
    sudo dnf -y localinstall /u01/downloads/oracle-database-free-23c-1.0-1.el8.x86_64.rpm
    </copy>
    ```
    ![Image alt text](images/.png " ")   

6. Create the database. You will be prompted for a password to be used for the database accounts. You can use any password here but you will need it later so note it down. For my examples I will use Welcome123# This should take about 5-10 minutes.
    ```
    <copy>
    sudo /etc/init.d/oracle-free-23c configure
    </copy>
    ```
    ![Image alt text](images/.png " ")

7. To see if your database is up and running you can use the following command
    ```
    <copy>
    sudo /etc/init.d/oracle-free-23c status
    </copy>
    ```
    ![Image alt text](images/.png " ")

## Task 3: Environment and User Setup

8. To set your environment each time Oracle logs in add these lines to your profile. This will specifically set it for the FREE database. Also this adds SQLcl and ORDS to your path.
    ```
    <copy>
    echo "export ORAENV_ASK=NO" >> /home/oracle/.bashrc
    echo "export ORACLE_SID=FREE" >> /home/oracle/.bashrc
    echo ". /usr/local/bin/oraenv" >> /home/oracle/.bashrc
    echo "unset ORAENV_ASK" >> /home/oracle/.bashrc
    echo "export JAVA_HOME=/usr/bin/java" >> /home/oracle/.bashrc
    echo "export PATH=\$PATH:\$ORACLE_HOME/bin:/u01/app/oracle/ords/bin:/u01/app/oracle/sqlcl/bin" >> /home/oracle/.bashrc

    . /home/oracle/.bashrc
    </copy>
    ```
    ![Image alt text](images/.png " ")

9. If your listener was configured on a different port or you wanted to see your listener configuration you can use the lsnrctl command. You can use this port in the later commands if you are not running on port 1521.
    ````
    <copy>
    lsnrctl status
    </copy>
    ````

9. Connect to your database.
    ```
    <copy>
    sqlplus / as sysdba
    </copy>
    ```
    ![Image alt text](images/.png " ")

10. The show pdbs commands will list the pluggable databases running in your container. Once you switch to a pluggable database that same command will list just the current pluggable.
    ```
    <copy>
    show pdbs
    </copy>
    ```
    ```
    <copy>
    alter session set container = FREEPDB1;
    </copy>
    ```
    ```
    <copy>
    show pdbs
    </copy>
    ```
    ![Image alt text](images/.png " ")

11. We will be using the user hol23c throughout the workshop. You can specify any password you want. I'm going to use Welcome123# for my examples.
    ````
    <copy>
    create user hol23c identified by Welcome123#;
    </copy>
    ````
    ````
    <copy>
    alter user hol23c quota unlimited on users;
    </copy>
    ````
    ````
    <copy>
    grant create session to hol23c;
    </copy>
    ````
    ````
    <copy>
    exit;
    </copy>
    ````
    ![Image alt text](images/.png " ")


30. You may proceed to the next lab.


## Learn More

* [Oracle Database 23c Free](https://www.oracle.com/database/free/)
* [Oracle Database 23c Free VirtualBox](https://www.oracle.com/database/technologies/databaseappdev-vm.html)
* [Oracle Database Container Registry] (https://container-registry.oracle.com/ords/f?p=113:4)
* [Oracle Database Container Registry] (https://apexapps-stage.oracle.com/pls/apex/dbpm/r/livelabs/home)

## Acknowledgements
* **Author** - David Start
* **Contributors** - David Start
* **Last Updated By/Date** - David Start, Database Product Management, August 2023
