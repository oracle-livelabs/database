# Create the schema including JSON Duality Views

## Introduction

Setting the password for the hol23c user

Estimated Time: 5 minutes

### Objectives

In this lab, you will:
* Set the password for the hol23c user

### Prerequisites

This lab assumes you have:
* Oracle Database 23c Free Developer Release
* All previous labs successfully completed
* A terminal or console access to the database

## Task 1: Setting database user password and starting SQL Developer Web

1. The first step is to get to a command prompt. If you need to open a terminal and you are running in a Sandbox environment click on Activities and then Terminal.
    ![Image alt text](images/open_terminal.png " ")

2. Next set your environment. The oraenv command will set all of the environment variables based on your database. When prompted type FREE for the database name or if you supplied a different database name use that.
    ```
    [FREE:oracle@hol23cfdr:~]$ <copy>. oraenv</copy>
     ORACLE_SID = [FREE] ? FREE
     The Oracle base has been set to /opt/oracle
    [FREE:oracle@hol23cfdr:~]$
		```

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

4. Next change to your pluggable database. If your pluggable database is a different name, make sure to change the command below.
    ```
    SQL> <copy>alter session set container = freepdb1;</copy>

    Session altered.

    SQL>
		```

5. To change the password for the user hol23c use the syntax below changing the new\_password\_here to your new password. Throughout this workshop we will use Welcome123#
    ```
		<copy>alter user hol23c identified by </copy>new_password_here;
		```
    ```
    SQL> alter user hol23c identified by Welcome123#;

    User altered.

    SQL>
    ```

6. Once the password has been changed you can exit SQL Plus.

    ```
		SQL> <copy>exit</copy>
Disconnected from Oracle Database 23c Free, Release 23.0.0.0.0 - Developer-Release
Version 23.2.0.0.0
[FREE:oracle@hol23cfdr:~]$
		```

7. To start SQL Developer Web, from the same command prompt use the following command. This will run in the background and will stop if you exit the terminal.

    ```
		[FREE:oracle@hol23cfdr:~]$ <copy>ords serve > /dev/null 2>&1 &</copy>
[1] 204454
[FREE:oracle@hol23cfdr:~]$
		```

## Learn More

* [JSON Relational Duality: The Revolutionary Convergence of Document, Object, and Relational Models](https://blogs.oracle.com/database/post/json-relational-duality-app-dev)
* [JSON Duality View documentation](http://docs.oracle.com)

## Acknowledgements
* **Author** - Kaylien Phan, Product Manager, Database Product Management
* **Last Updated By/Date** - Kaylien Phan, Database Product Management, March 2023
