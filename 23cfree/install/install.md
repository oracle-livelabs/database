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

3. Get the download for 23c Free
    ```
    <copy>
    cd /u01/downloads
    wget https://download.oracle.com/otn-pub/otn_software/db-free/oracle-database-free-23c-1.0-1.el8.x86_64.rpm
    </copy>
    ```
    ![Download Install](images/.png " ")

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

7. Before installing you should check to see if anything is running on port 1521. This is what the configure command will use when creating the listener. If it cannot it will try and use another port. If a service is running on that port you can try and restart it to see if it will restart on another port.

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


8. To set your environment each time Oracle logs in add these lines to your profile. This will specifically set it for the FREE database
    ```
    <copy>
    echo "export ORAENV_ASK=NO" >> /home/oracle/.bashrc
    echo "export ORACLE_SID=FREE" >> /home/oracle/.bashrc
    echo "/usr/local/bin/oraenv" >> /home/oracle/.bashrc
    echo "unset ORAENV_ASK" >> /home/oracle/.bashrc
    echo "export JAVA_HOME=/usr/bin/java" >> /home/oracle/.bashrc
    echo "export PATH=$PATH:$ORACLE_HOME/bin:/u01/app/oracle/ords/bin:/u01/app/oracle/sqlcl/bin" >> /home/oracle/.bashrc

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
12. One thing to be aware of is this image has a newer version of Java installed on it and the environment variable JAVA_HOME is pointing at that. Some of the utilities require a higher version.
    ```
    <copy>
    java -version

    echo $JAVA_HOME
    </copy>
    ```
    ![Image alt text](images/.png " ")

13. Download and unzip the latest version of SQLcl
    ````
    <copy>
    cd /u01/app/oracle
    wget https://download.oracle.com/otn_software/java/sqldeveloper/sqlcl-latest.zip
    unzip sqlcl-latest.zip
    rm sqlcl-latest.zip
    </copy>
    ````

14. Test out SQLcl by connecting to the database. Notice the command is sql not sqlplus
    ````
    <copy>
    sql / as sysdba
    </copy>
    ````

15. You can explore the database if you want. When you get done type exit
    ````
    <copy>
    show pdbs;
    exit;
    </copy>
    ````

16. Download and unzip the latest version of APEX
    ````
    <copy>
    cd /u01/app/oracle
    wget https://download.oracle.com/otn_software/apex/apex-latest.zip
    unzip apex-latest.zip
    rm apex-latest.zip
    </copy>
    ````

17. Run the install script into the <b>Pluggable</b> database. It's important that you install into the pluggable and not the container. Please review the architecture section of the APEX documentation in the additional information section for different deployment modes. This script will take about 5-7 minutes to complete.
    ````
    <copy>
    cd /u01/app/oracle/apex
    sqlplus / as sysdba

    ALTER SESSION SET CONTAINER = FREEPDB1;
    </copy>
    ````
    ````
    <copy>  
    @apexins.sql SYSAUX SYSAUX TEMP /i/
    </copy>
    ````
    ````
    <copy>
    exit;
    </copy>
    ````
18. Run the change password script into the <b>Pluggable</b> database. Accept ADMIN for the username. Accept ADMIN for the email. Provide a password. I will be using Welcome123# for my examples.
    ````
    <copy>
    sql / as sysdba
    ALTER SESSION SET CONTAINER = FREEPDB1;
    </copy>
    ````
    ````
    <copy>
    @apxchpwd.sql
    </copy>
    ````
    ````
    <copy>
    exit;
    </copy>
    ````

19. Unlock and set the passwords for the various accounts in the <b>Pluggable</b> database. You will be prompted during the rest config script. I'm going to use Welcome123# for my examples but you can use any password you want.
    ````
    <copy>
    sql / as sysdba
    ALTER SESSION SET CONTAINER = FREEPDB1;
    ALTER USER APEX_PUBLIC_USER ACCOUNT UNLOCK;
    ALTER USER APEX_PUBLIC_USER IDENTIFIED BY Welcome123#;
    </copy>
    ````
    ````
    <copy>
    @apex_rest_config.sql
    </copy>
    ````
    ````
    <copy>
    exit;
    </copy>
    ````

20. Download the latest version of ORDS.
    ````
    <copy>
    cd /u01/app/oracle/ords
    wget https://download.oracle.com/otn_software/java/ords/ords-latest.zip
    unzip ords-latest.zip
    rm ords-latest.zip
    </copy>
    ````

21. You will need to grant the correct privileges to the hol23c user.
    ````
    <copy>
    cd /u01/app/oracle/ords/scripts/installer
    sqlplus / as sysdba
    ALTER SESSION SET CONTAINER = FREEPDB1;
    </copy>
    ````
    ````
    <copy>
    @ords_installer_privileges.sql hol23c
    </copy>
    ````
    ````
    <copy>
    exit;
    </copy>
    ````

22. Copy the images directory from APEX to the ORDS directory
    ````
    <copy>
    cd /u01/app/oracle/ords
    cp -r /u01/app/oracle/apex/images .
    </copy>
    ````

23. Install ORDS answering the prompts with the following responses:
- Install: 2
- Connection: 1
- localhost
- 1521
- FREEPDB1
- username: hol23c
- password: Welcome123# <Database Password change if you used something different>
- 1 Database Actions (Enables all features)
- Static resources location directory: /u01/app/oracle/ords/images

    ````
    <copy>
    ords install
    </copy>
    ````

24. Stop ORDS by pressing CTRL-C

25. Enable hol23c the ability to use ORDS.
    ````
    <copy>
    sqlplus hol23c/Welcome123#@ll23c:1521/freepdb1
    </copy>
    ````
    ````
    <copy>
    BEGIN
     ords_admin.enable_schema(
         p_enabled => TRUE,
         p_schema => 'HOL23C',
         p_url_mapping_type => 'BASE_PATH',
         p_url_mapping_pattern => 'hol23c',
         p_auto_rest_auth => NULL
     );
    commit;
    END;
    /
    exit;
    </copy>
    ````

26. Restart ORDS. Wait about 30 seconds for it to finish starting before proceeding.
    ````
    <copy>
    ords serve
    </copy>
    ````

27. Open a browser

28. Navigate to the SQL Developer Web by going to the following address http://localhost:8080/ords/

29. Log into sql dev web as hol23c with your password. I used Welcome123#

30. You may proceed to the next lab.


## Learn More

* [JSON Relational Duality: The Revolutionary Convergence of Document, Object, and Relational Models](https://blogs.oracle.com/database/post/json-relational-duality-app-dev)
* [JSON Duality View documentation](http://docs.oracle.com)
* [Blog: Key benefits of JSON Relational Duality] (https://blogs.oracle.com/database/post/key-benefits-of-json-relational-duality-experience-it-today-using-oracle-database-23c-free-developer-release)

## Acknowledgements
* **Author** - Kaylien Phan, William Masdon
* **Contributors** - David Start, Ranjan Priyadarshi
* **Last Updated By/Date** - Kaylien Phan, Database Product Management, April 2023
