# Create the schema including JSON Duality Views

## Introduction

This lab walks you through the setup steps to create the user, tables, and JSON duality views needed to execute the rest of this workshop. Then you will populate the views and tables.

Estimated Time: 10 minutes

### Objectives

In this lab, you will:
* Login as your database user
* Create the JSON Duality Views and base tables needed
* Populate your database

### Prerequisites

This lab assumes you have:
* Oracle Database 23c Free Developer Release
* All previous labs successfully completed
* SQL Developer Web 23.1 or a compatible tool for running SQL statements

## Task 1: Operating System Setup

1. Open a terminal if you don't currently have one open. To open one Click on Activities and then Terminal.

    ![Open Terminal](images/.png " ")

2. Create the directories needed for this workshop

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

2. Before installing you should check to see if anything is running on port 1521. This is what the configure command will use when creating the listener. If it cannot it will try and use another port. If a service is running on that port you can try and restart it to see if it will restart on another port.

    ````
    <copy>
    sudo netstat -anp|grep 1521
    </copy>
    ````

8. Restart the service using the "sudo systemctl restart" command

    ````
    <copy>
    sudo systemctl restart <replace with service>

    sudo netstat -anp|grep 1521
    </copy>
    ````

3. Get the download for 23c Free
    ```
    <copy>
    cd /u01/downloads
    wget https://download.oracle.com/otn-pub/otn_software/db-free/oracle-database-free-23c-1.0-1.el8.x86_64.rpm
    </copy>
    ```
    ![Download Install](images/.png " ")

## Task 2: Database Setup

4. Enable the developer repo to be able to run the prerequisites check as a part of the install
    ```
    <copy>
    sudo dnf config-manager --set-enabled ol8_developer
    </copy>
    ```
    ![Image alt text](images/.png " ")

5. Install the database software. This will take about 5-10 minutes.
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

8. To set your environment each time Oracle logs in add these lines to your profile. This will specifically set it for the FREE database
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

9. Connect to your database
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

    alter session set container = FREEPDB1;

    show pdbs
    </copy>
    ```
    ![Image alt text](images/.png " ")

11. We will be using the user hol23c throughout the workshop. You can specify any password you want. I'm going to use Welcome123# for my examples.
    ```
    <copy>
    create user hol23c identified by Welcome123#;
    alter user hol23c quota unlimited on users;
    grant create session to hol23c;
    exit;
    </copy>
    ```
    ![Image alt text](images/.png " ")


30. You may proceed to the next lab.


## Learn More

* [JSON Relational Duality: The Revolutionary Convergence of Document, Object, and Relational Models](https://blogs.oracle.com/database/post/json-relational-duality-app-dev)
* [JSON Duality View documentation](http://docs.oracle.com)
* [Blog: Key benefits of JSON Relational Duality] (https://blogs.oracle.com/database/post/key-benefits-of-json-relational-duality-experience-it-today-using-oracle-database-23c-free-developer-release)

## Acknowledgements
* **Author** - Kaylien Phan, William Masdon
* **Contributors** - David Start, Ranjan Priyadarshi
* **Last Updated By/Date** - Kaylien Phan, Database Product Management, April 2023
