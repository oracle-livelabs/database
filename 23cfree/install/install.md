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

9. Connect to your database
    ```
    <copy>
    sqlplus / as sysdba
    </copy>
    ```
    ![Image alt text](images/.png " ")

10. To see if your database is up and running you can use the following command
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
    grant create session to hol23c
    exit
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


SQLcl Install:
mkdir
cd /u01/app/oracle
wget https://download.oracle.com/otn_software/java/sqldeveloper/sqlcl-latest.zip
unzip sqlcl-latest.zip
rm sqlcl-latest.zip

Let's test out SQLcl by connecting to our Pluggable database as hol23c. Make sure to change the password in the connection string to the one you set.
sql hol23c/Welcome123#@ll23c:1521/FREEPDB1

APEX Install:

cd /u01/app/oracle
wget https://download.oracle.com/otn_software/apex/apex-latest.zip
unzip apex-latest.zip
rm apex-latest.zip

cd /u01/app/oracle/apex
sqlplus / as sysdba


ALTER SESSION SET CONTAINER = FREEPDB1;

@apexins.sql SYSAUX SYSAUX TEMP /i/ -- This will take about 5-7 minutes

exit;

sql / as sysdba
ALTER SESSION SET CONTAINER = FREEPDB1;
@apxchpwd.sql
press enter and accept ADMIN for the username
press enter and accept ADMIN for the email
provide a password Welcome123#
exit;

sql / as sysdba
ALTER SESSION SET CONTAINER = FREEPDB1;
ALTER USER APEX_PUBLIC_USER ACCOUNT UNLOCK;
ALTER USER APEX_PUBLIC_USER IDENTIFIED BY Welcome123#;
@apex_rest_config.sql
APEX_LISTENER USER PASSWORD Welcome123#
APEX_REST_PUBLIC_USER Welcome123#
exit;

12.
ords install:
cd /u01/app/oracle/ords
wget https://download.oracle.com/otn_software/java/ords/ords-latest.zip
unzip ords-latest.zip
rm ords-latest.zip

cd /u01/app/oracle/ords/scripts/installer
sqlplus / as sysdba
ALTER SESSION SET CONTAINER = FREEPDB1;

@ords_installer_privileges.sql hol23c

exit

cd /u01/app/oracle/ords
cp -r /u01/app/oracle/apex/images .
ords install
2 for the install
1 for the connection
localhost or hostname
1521
FREEPDB1
username: hol23c
password: Welcome123#
Take all of the defaults except:
Enter the default tablespace for ORDS_METADATA and ORDS_PUBLIC_USER [SYSAUX]:
  Enter the temporary tablespace for ORDS_METADATA and ORDS_PUBLIC_USER [TEMP]:
  Enter a number to select additional feature(s) to enable:
    [1] Database Actions  (Enables all features)
    [2] REST Enabled SQL and Database API
    [3] REST Enabled SQL
    [4] Database API
    [5] None
  Choose [1]:


Static resources location directory: /u01/app/oracle/ords/images


sqlplus hol23c/Welcome123#@ll23c:1521/freepdb1
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


open a browser

http://localhost:8080/ords/hol23c

Log into sql dev web

13.

## Learn More

* [JSON Relational Duality: The Revolutionary Convergence of Document, Object, and Relational Models](https://blogs.oracle.com/database/post/json-relational-duality-app-dev)
* [JSON Duality View documentation](http://docs.oracle.com)
* [Blog: Key benefits of JSON Relational Duality] (https://blogs.oracle.com/database/post/key-benefits-of-json-relational-duality-experience-it-today-using-oracle-database-23c-free-developer-release)

## Acknowledgements
* **Author** - Kaylien Phan, William Masdon
* **Contributors** - David Start, Ranjan Priyadarshi
* **Last Updated By/Date** - Kaylien Phan, Database Product Management, April 2023
