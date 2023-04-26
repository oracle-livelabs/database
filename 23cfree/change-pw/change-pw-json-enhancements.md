# Prepare your environment for the workshop 

## Introduction

In this section we will reset the password for the hol23c user in the Oracle Database and start up ORDS, which will be needed for the Oracle Database API for MongoDB.

Estimated Time: 5 minutes

### Objectives

In this lab, you will:
* Set the password for the hol23c user
* Start up ORDS

### Prerequisites

This lab assumes you have:
* Oracle Database 23c Free Developer Release
* A terminal or console access to the database

## Task 1: Setting database user password and ensure you can connect properly

1. The first step is to get to a command prompt. If you need to open a terminal and you are running in a Sandbox environment click on Activities and then Terminal.

    ![Open a new terminal](images/open-terminal.png " ")

2. Next set your environment. The oraenv command will set all of the environment variables based on your database. When prompted type FREE for the database name or if you supplied a different database name use that.
    ```
    [FREE:oracle@hol23cfdr:~]$ <copy>. oraenv</copy>
     ORACLE_SID = [FREE] ? FREE
     The Oracle base has been set to /opt/oracle
    [FREE:oracle@hol23cfdr:~]$
		```

    <!-- ![Set environment](images/set-envt-free1.png " ") -->


3. Next connect to your database.
    ```
		[FREE:oracle@hol23cfdr:~]$ <copy>sqlplus / as sysdba</copy>

    SQL*Plus: Release 23.0.0.0.0 - Developer-Release on Wed Apr 5 13:38:14 2023
    Version 23.2.0.0.0

    Copyright (c) 1982, 2023, Oracle.  All rights reserved.


    Connected to:
    Oracle Database 23c Free, Release 23.0.0.0.0 - Developer-Release
    Version 23.2.0.0.0

    SQL>
		```
    ![Connect to the database](images/connect-db-sysdba1.png " ")

4. Next change to your pluggable database. If your pluggable database is a different name, make sure to change the command below.
    ```
    SQL> <copy>alter session set container = freepdb1;</copy>

    Session altered.

    SQL>
		```
    ![Change to PDB](images/alter-session1.png " ")

5. To change the password for the user hol23c use the "alter user <username> identified by <new password" command. The syntax below for the hol23c user, make sure to replace new\_password\_here to your new password. Throughout this workshop we will use the Welcome123 password.
    ```
		<copy>alter user hol23c identified by </copy>new_password_here;
		```
    ```
    SQL> alter user hol23c identified by Welcome123;

    User altered.

    SQL>
    ```
    ![Change password](images/change-password1.png " ")

6. Once the password has been changed you can exit SQL Plus.

    ```
		SQL> <copy>exit</copy>
Disconnected from Oracle Database 23c Free, Release 23.0.0.0.0 - Developer-Release
Version 23.2.0.0.0
[FREE:oracle@hol23cfdr:~]$
		```

    ![Exit](images/exit1.png " ")

7. Log in with database user hol23c to your database

    ```
		[FREE:oracle@hol23cfdr:~]$ <copy>sqlplus hol23c/<your_password>@freepdb1</copy>

    SQL*Plus: Release 23.0.0.0.0 - Developer-Release on Wed Apr 5 13:38:14 2023
    Version 23.2.0.0.0

    Copyright (c) 1982, 2023, Oracle.  All rights reserved.


    Connected to:
    Oracle Database 23c Free, Release 23.0.0.0.0 - Developer-Release
    Version 23.2.0.0.0

    SQL>
		```
  The following shows a successful connection with hol23c using our Welcome123 as password.
    ![Connect to the database](images/connect-hol23c.png " ")

You have verified that your database user is ready for the workshop.

## Task 2: Start ORDS and ensure that the MongoDB API is enabled


1. To start ORDS, from the same command prompt use the following command. The output of [1] 204454 is just an example, your output could be different.

    ```
		[FREE:oracle@hol23cfdr:~]$ <copy>ords serve &</copy>
[1] 204454
[FREE:oracle@hol23cfdr:~]$
		```

    **NOTE:** We did not use nohup or send the output to /dev/null to verify that ORDS is properly started and the MongoDB API enabled. This is for demonstration purposes. So you must leave this terminal open and the process running. Closing either will stop ORDS from running, and you will not be able to access other applications that are used in this lab.

  If ORDS started successfully and the MongoDB API is successfully enabled, then you will see an output similar to the following:

    ![Start ORDS](images/ords-with-mongo-enabled.png " ")


2. You may now proceed to the next lab.

## Learn More

* [JSON in Oracle Database Documentation](https://docs.oracle.com/en/database/oracle/oracle-database/23/adjsn/index.html)
* [Oracle Database API for MongoDB Documentation](https://docs.oracle.com/en/database/oracle/mongodb-api/)
* [Blog: Installing Database API for MongoDB for any Oracle Database] (https://blogs.oracle.com/database/post/installing-database-api-for-mongodb-for-any-oracle-database)
* [Blog: Oracle Database API for MongoDB] (https://blogs.oracle.com/database/post/mongodb-api)

## Acknowledgements
* **Author** - Kaylien Phan, William Masdon, Hermann Baer
* **Contributors** - David Start
* **Last Updated By/Date** - Hermann Baer, Database Product Management, April 2023
