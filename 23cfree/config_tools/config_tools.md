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

## Task 1: Setup SQLcl

1. Open a terminal if you don't currently have one open. To open one Click on Activities and then Terminal.

    ![Open Terminal](images/.png " ")


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

## Task 2: Setup APEX

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
18. Run the change password script into the <b>Pluggable</b> database. When prompted use the values below
- Username: Use the default ADMIN
- Email: Use the default ADMIN
- Password: Provide a password, I will use Welcome123#
    ````
    <copy>
    sqlplus / as sysdba
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
    sqlplus / as sysdba
    ALTER SESSION SET CONTAINER = FREEPDB1;
    </copy>
    ````
    ````
    <copy>
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

## Task 2: Setup ORDS

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
- Installation: 2
- Connection: 1
- Hostname: localhost
- Port: 1521 (Unless you used a different one)
- Service Name: <b>FREEPDB1 (The PDB not the container)</b>
- username: hol23c
- password: Welcome123# (Unless you used a different one for hol23c)
- Default tablespace: SYSAUX
- Temporary Tablespace: TEMP
- Features: 1 Database Actions (Enables all features)
- Configuration: 1 Configure and Start
- Protocol: 1 HTTP
- HTTP port: 8080
- Static resources location: /u01/app/oracle/ords/images

    ````
    <copy>
    ords install
    </copy>
    ````

24. After the installation has completed, the screen stops scrolling and you see the line "Oracle REST Data Services initialized" Stop ORDS by pressing CTRL-C

25. Enable hol23c the ability to use ORDS.
    ````
    <copy>
    sqlplus hol23c/Welcome123#@localhost:1521/freepdb1
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

## Task 4: Login

26. Restart ORDS. Wait about 30 seconds for it to finish starting before proceeding.
    ````
    <copy>
    ords serve
    </copy>
    ````

27. Open a browser

28. Navigate to the SQL Developer Web by going to the following address
    ````
    <copy>
    http://localhost:8080/ords/
    </copy>
    ````

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
