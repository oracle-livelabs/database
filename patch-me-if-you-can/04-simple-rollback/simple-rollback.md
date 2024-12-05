# Simple Patching With AutoUpgrade

## Introduction

In this lab, you will roll back after applying patches. AutoUpgrade protects your database during patching using a guaranteed restore point. If something happens in your maintenance window, you can use AutoUpgrade to roll back.

**Caution:** AutoUpgrade rolls back by flashing the database back to a restore point created before patching. This means any data entered after patching with AutoUpgrade is lost. Use AutoUpgrade restore functionality only before go-live. If you need to rollback after go-live, please look at lab 8 - Advanced patching.

Estimated Time: 10 Minutes

### Objectives

In this lab, you will:

* Undo a database patch apply
* Use AutoUpgrade restoration feature

### Prerequisites

This lab assumes:

- You have completed Lab 2: Simple Patching

## Task 1: Check database

1. Use the *yellow* terminal 🟨. Verify the *FTEX* database has been patched. Check `/etc/oratab`.

    ```
    <copy>
    cat /etc/oratab
    </copy>
    ```

    * The *FTEX* database is now running from *19.25* Oracle home.
    * When you patched the database in the previous lab, AutoUpgrade updated `/etc/oratab` for you.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ cat /etc/oratab
    # This file is used by ORACLE utilities.  It is created by root.sh
    # and updated by either Database Configuration Assistant while creating
    # a database or ASM Configuration Assistant while creating ASM instance.
    
    # A colon, ':', is used as the field terminator.  A new line terminates
    # the entry.  Lines beginning with a pound sign, '#', are comments.
    #
    # Entries are of the form:
    #   $ORACLE_SID:$ORACLE_HOME:<N|Y>:
    #
    # The first and second fields are the system identifier and home
    # directory of the database respectively.  The third field indicates
    # to the dbstart utility that the database should , "Y", or should not,
    # "N", be brought up at system boot time.
    #
    # Multiple entries with the same $ORACLE_SID are not allowed.
    #
    #
    UPGR:/u01/app/oracle/product/19:Y
    FTEX:/u01/app/oracle/product/19_25:Y
    CDB19:/u01/app/oracle/product/19:N
    CDB23:/u01/app/oracle/product/23:Y
    CDB23COM:/u01/app/oracle/product/23:N
    ```
    </details>    

2. Set the environment and connect to the *FTEX* database.

    ```
    <copy>
    . ftex
    sqlplus / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

3. Verify database is running on *19.25*. 

    ```
    <copy>
    select version_full from v$instance;
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    VERSION_FULL
    -----------------
    19.25.0.0.0
    ```
    </details>    

4. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```

## Task 2: Roll back

1. Perform the rollback using AutoUpgrade. Use the `-restore` command line parameter and specify the job to restore.

    ```
    <copy>
    java -jar autoupgrade.jar -config scripts/simple-patching.cfg -patch -restore -jobs 101
    </copy>
    ```

    * With `-jobs` you specify the job IDs of the AutoUpgrade jobs that you want to restore. 
    * Use *101* because that is the job ID of the job that patched the database. 

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ java -jar autoupgrade.jar -config scripts/simple-patching.cfg -patch -restore -jobs 101
    Previous execution found loading latest data
    Total jobs being restored: 1
    +-----------------------------------------+
    | Starting AutoUpgrade Patching execution |
    +-----------------------------------------+
    
    
    Job 101 completed
    ------------------- Final Summary --------------------
    Number of databases            [ 1 ]
    
    Jobs restored                  [1]
    Jobs failed                    [0]
    -------------------- JOBS PENDING --------------------
    Job 101 for FTEX
    
    Please check the summary report at:
    /home/oracle/autoupgrade-patching/simple-patching/log/cfgtoollogs/patch/auto/status/status.html
    /home/oracle/autoupgrade-patching/simple-patching/log/cfgtoollogs/patch/auto/status/status.log
    Exiting
    ```
    </details>    

2. When AutoUpgrade exits, the rollback is complete. AutoUpgrade issues a `FLASHBACK DATABASE` command and opens the database with the `RESETLOGS` option in the old Oracle home. 

3. Verify the *FTEX* database has been rolled back. Check `/etc/oratab`.

    ```
    <copy>
    cat /etc/oratab
    </copy>
    ```

    * The *FTEX* database is now running from *19.21* Oracle home, `/u01/app/oracle/product/19`.
    * When you roll back, AutoUpgrade updates `/etc/oratab` for you.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ cat /etc/oratab
    # This file is used by ORACLE utilities.  It is created by root.sh
    # and updated by either Database Configuration Assistant while creating
    # a database or ASM Configuration Assistant while creating ASM instance.
    
    # A colon, ':', is used as the field terminator.  A new line terminates
    # the entry.  Lines beginning with a pound sign, '#', are comments.
    #
    # Entries are of the form:
    #   $ORACLE_SID:$ORACLE_HOME:<N|Y>:
    #
    # The first and second fields are the system identifier and home
    # directory of the database respectively.  The third field indicates
    # to the dbstart utility that the database should , "Y", or should not,
    # "N", be brought up at system boot time.
    #
    # Multiple entries with the same $ORACLE_SID are not allowed.
    #
    #
    UPGR:/u01/app/oracle/product/19:Y
    FTEX:/u01/app/oracle/product/19:Y
    CDB19:/u01/app/oracle/product/19:N
    CDB23:/u01/app/oracle/product/23:Y
    CDB23COM:/u01/app/oracle/product/23:N
    ```
    </details>    

4. Update the profile script. Since the database now runs out of the old Oracle home, you must update the profile script. This command replaces the `ORACLE_HOME` variable in the profile script.

    ```
    <copy>
    sed -i 's/^ORACLE_HOME=.*/ORACLE_HOME=\/u01\/app\/oracle\/product\/19/' /usr/local/bin/ftex
    </copy>
    ``` 

5. Connect to the *FTEX* database.

    ```
    <copy>
    . ftex
    sqlplus / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

6. Verify the database is running in the old Release Update.

    ```
    <copy>
    select version_full from v$instance;
    </copy>
    ``` 

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    VERSION_FULL
    -----------------
    19.21.0.0.0
    ```
    </details>      

7. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```

You may now *proceed to the next lab*.

## Learn More

* Webinar, [Secure Your Job – Fallback Is Your Insurance](https://www.youtube.com/watch?v=P12UqVRzarw)

## Acknowledgements

* **Author** - Daniel Overby Hansen
* **Contributors** - Rodrigo Jorge, Alex Zaballa, Mike Dietrich
* **Last Updated By/Date** - Daniel Overby Hansen, December 2024