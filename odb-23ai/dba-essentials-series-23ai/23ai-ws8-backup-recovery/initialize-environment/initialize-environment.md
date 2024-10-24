# Initialize environment

## Introduction
In this lab, we will review and startup all components required to run this workshop successfully.

Estimated Time: 5 minutes

### Objectives
-   Set up the components required for performing this workshop

### Prerequisites
This lab assumes you have:
-   An Oracle Cloud account
-   Completed all previous labs successfully


## Task 1: Set the environment
You must first set the environment to connect to the Oracle Database and run SQL commands.

1. Log in to your host as `oracle`, the user who can perform database administration.

2. Open a terminal window and change the current working directory to `$ORACLE_HOME/bin`.
    ```
    $ <copy>cd /opt/oracle/product/23.4.0/dbhome_1/bin</copy>
    ```

3. Run the command `oraenv` to set the environment variables.
    ```
    $ <copy>. oraenv</copy>
    ```

4. Enter the Oracle SID. For this lab, it is set to `CDB1`.
    ```
    ORACLE_SID = [oracle] ? CDB1

    The Oracle base has been set to /opt/oracle
    ```
    This command also sets the Oracle home path to `/opt/oracle/product/23.4.0/dbhome_1`.

    >**Note:** Oracle SID is case sensitive.

You have set the environment variables for the active terminal session. You can now connect to Oracle Database and run the commands.

>**Note:** Every time you open a new terminal window, you need to set the environment variables to connect to Oracle Database from that terminal. Environment variables from one terminal do not apply automatically to other terminals. 

Alternatively, you may run the script file `.set-env-db.sh` from the home location and enter the number for `ORACLE_SID`, for example, `3` for `CDB1`. It sets the environment variables automatically.

## Task 2: Download and execute the SQL script file

In this task, you download and execute the SQL script file using the following steps.

1. Download and save the [backup-and-recovery-operations-prerequisities.zip](https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/p/EcTjWk2IuZPZeNnD_fYMcgUhdNDIDA6rt9gaFj_WZMiL7VvxPBNMY60837hu5hga/n/c4u04/b/livelabsfiles/o/labfiles/backup-and-recovery-operations-prerequisities.zip) file in `/opt/oracle/product/23.4.0/dbhome_1/bin` location.

2. Extract the contents from the zip file using the following command.
    ```
    $ <copy>unzip backup-and-recovery-operations-prerequisities.zip</copy>
    ```

3. The `backup-and-recovery-operations-prerequisities.sql` script file contains the following code:
    ```
    <copy>alter session set container = <pdbname>;
    CREATE user appuser IDENTIFIED BY <mypassword> container=current;
    grant all privileges to appuser;
    connect appuser/<mypassword>@//<hostname>:<port>
    create tablespace oc datafile 'octs.dbf' size 32m;
    create table regions (id number(2), name varchar2(20)) tablespace oc;
    insert into regions values (1,'America');
    insert into regions values (2,'Europe');
    insert into regions values (3,'Asia');
    commit;
    !
    mkdir /opt/oracle/oradata/CDB1
    exit;</copy>
    ```

4. Open the `backup-and-recovery-operations-prerequisities.sql` script file, update the following details, and save.
    * pdbname - Provide the name of the PDB you want to connect to. For this lab, it is set to pdb1.
    * password - Provide your password.
    * hostname - Provide the host name of the machine where the database is installed.
    * port - Provide the port name. Usually port number is 1521.

5. Start the SQL\*Plus prompt and connect as the `sysdba` user.
    ```
    $ <copy>./sqlplus / as sysdba</copy>
    ```
    Output:
    ```
    SQL*Plus: Release 23.0.0.0.0 - Production on Thu Oct 3 13:07:20 2024
    Version 23.4.0.24.05
    
    Copyright (c) 1982, 2024, Oracle.  All rights reserved.
    
    Connected to:
    Oracle Database 23ai Enterprise Edition Release 23.0.0.0.0 - Production
    Version 23.4.0.24.05
    ```

6. Run the SQL script file.
    ```
    SQL> <copy>START backup-and-recovery-operations-prerequisities.sql</copy>
    ```

7. Exit the SQL\*Plus prompt.


You may now **proceed to the next lab**.


## Acknowledgements
- **Author**: Suresh Mohan, Database User Assistance Development Team
- **Contributors**: Suresh Rajan, Manish Garodia, Subhash Chandra, Ramya P
- **Last Updated By & Date**: Suresh Mohan, October 2024
