# Upgrade Non-CDB Using Refreshable Clone PDB

## Introduction

In this lab, you will upgrade a non-CDB to Oracle Database 23ai and convert it io a pluggable database (PDB). You will use refreshable clone PDB. This feature creates a copy of the database and keeps it up-to-date with redo. This minimizes the downtime needed and still keeps the source database untouched for rollback.

You will upgrade the *FTEX* database and plug it into the *CDB23* database.

Estimated Time: 35 minutes

### Objectives

In this lab, you will:

* Prepare database for refreshable clone PDB
* Upgrade a non-CDB and convert to PDB

### Prerequisites

None.

This lab uses the *FTEX* and *CDB23* databases. Don't do this lab at the same time as lab 12 and 13.

## Task 1: Prepare your environment

Refreshable clone PDB works via a database link. You must create a user and grant privileges in the source non-CDB. Also, you must create a database link in the target CDB connecting to the source non-CDB.

1. Set the environment to the source non-CDB database (*FTEX*) and connect.

    ```
    <copy>
    . ftex
    sqlplus / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

2. Create a user and grant the necessary privileges

    ```
    <copy>
    create user dblinkuser identified by dblinkuser;
    grant create session to dblinkuser;
    grant select_catalog_role to dblinkuser;
    grant create pluggable database to dblinkuser;
    grant read on sys.enc$ to dblinkuser;
    </copy>

    -- Be sure to hit RETURN
    ```

    * You use the user to connect from the target CDB via a database link.
    * You can delete the user after the migration.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> create user dblinkuser identified by dblinkuser;

    User created.

    SQL> grant create session to dblinkuser;

    Grant succeeded.

    SQL> grant select_catalog_role to dblinkuser;

    Grant succeeded.

    SQL> grant create pluggable database dblinkuser;

    Grant succeeded.

    SQL> grant read on sys.enc$ to dblinkuser;

    Grant succeeded.
    ```
    </details>

3. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```

4. Set the environment to the target CDB (*CDB23*) and connect.

    ```
    <copy>
    . cdb23
    sqlplus / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

5. Create a database link pointing to the *FTEX* database.

    ```
    <copy>
    create database link clonepdb
    connect to dblinkuser
    identified by dblinkuser
    using 'localhost/ftex';
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> create database link clonepdb
      2  connect to dblinkuser
      3  identified by dblinkuser
      4  using 'localhost/ftex';

    Database link created.
    ```
    </details>

6. Ensure that the database link works.

    ```
    <copy>
    select * from dual@clonepdb;
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> select * from dual@clonepdb;

    D
    -
    X
    ```
    </details>

7. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```

## Task 2: Prepare for upgrade

You check the source database for upgrade readiness and execute pre-upgrade fixups.

1. For this lab, you will use a pre-created config file. Examine the pre-created config file.

    ```
    <copy>
    cat /home/oracle/scripts/ftex-refresh.cfg
    </copy>
    ```

    * `sid` specifies the source non-CDB.
    * `target_cdb` is the CDB where you want to plug in.
    * `source_db_link` is the name of the database link in the target CDB, plus the refresh rate. Here, it's set to 60 seconds which is too low for a realistic scenario, but suitable for demo purposes.
    * `target_pdb_name` renames the database from *FTEX* to *TEAL*.
    * `target_pdb_copy_option` instructs the CDB to use Oracle Managed Files (OMF).
    * `start_time` is set to 10 minutes from starting AutoUpgrade. In a realistic scneario you would probably use an absolute time.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    global.autoupg_log_dir=/home/oracle/logs/ftex-refresh
    upg1.source_home=/u01/app/oracle/product/19
    upg1.target_home=/u01/app/oracle/product/23
    upg1.sid=FTEX
    upg1.target_cdb=CDB23
    upg1.source_dblink.FTEX=CLONEPDB 60
    upg1.target_pdb_name.FTEX=TEAL
    upg1.target_pdb_copy_option.FTEX=file_name_convert=none
    upg1.start_time=+10m
    upg1.timezone_upg=NO
    ```
    </details>

2. Start AutoUpgrade in *analyze* mode. The check usually completes very fast. Wait for it to complete.

    * The analysis must run on the source system. Since source and target is the same in this lab, you don't need to worry about it.

    ```
    <copy>
    java -jar autoupgrade.jar -config /home/oracle/scripts/ftex-refresh.cfg -mode analyze
    </copy>
    ```

3. When AutoUpgrade completes, it prints the path to the summary report. Check the summary report.

    ```
    <copy>
    cat /home/oracle/logs/ftex-refresh/cfgtoollogs/upgrade/auto/status/status.log
    </copy>
    ```

    * The report states *Check passed and no manual intervention needed*.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    ==========================================
              Autoupgrade Summary Report
    ==========================================
    [Date]           Mon May 27 06:55:59 GMT 2024
    [Number of Jobs] 1
    ==========================================
    [Job ID] 100
    ==========================================
    [DB Name]                FTEX
    [Version Before Upgrade] 19.21.0.0.0
    [Version After Upgrade]  23.5.0.24.07
    ------------------------------------------
    [Stage Name]    PRECHECKS
    [Status]        SUCCESS
    [Start Time]    2024-05-27 06:55:52
    [Duration]
    [Log Directory] /home/oracle/logs/ftex-refresh/FTEX/100/prechecks
    [Detail]        /home/oracle/logs/ftex-refresh/FTEX/100/prechecks/ftex_preupgrade.log
                    Check passed and no manual intervention needed
    ------------------------------------------
    ```
    </details>

4. Proceed with the pre-upgrade fixups. Normally, you would do this close to the final refresh (as dictated by `start_time` config file parameter). But in this lab we do it now.

    * The fixups must run on the source system. Since source and target is the same in this lab, you don't need to worry about it.

    ```
    <copy>
    java -jar autoupgrade.jar -config /home/oracle/scripts/ftex-refresh.cfg -mode fixups
    </copy>
    ```

5. Monitor the fixups.

    ```
    <copy>
    lsj -a 10
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    upg> lsj -a 10
    upg>
    +----+-------+---------+---------+-------+----------+-------+----------------------------+
    |Job#|DB_NAME|    STAGE|OPERATION| STATUS|START_TIME|UPDATED|                     MESSAGE|
    +----+-------+---------+---------+-------+----------+-------+----------------------------+
    | 101|   FTEX|PRECHECKS|EXECUTING|RUNNING|  07:53:37| 3s ago|Loading database information|
    +----+-------+---------+---------+-------+----------+-------+----------------------------+
    Total jobs 1

    The command lsj is running every 10 seconds. PRESS ENTER TO EXIT
    ```
    </details>

6. Wait for the fixups to complete. AutoUpgrade prints *Job 101 completed* when done.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    Job 101 completed
    ------------------- Final Summary --------------------
    Number of databases            [ 1 ]

    Jobs finished                  [1]
    Jobs failed                    [0]

    Please check the summary report at:
    /home/oracle/logs/ftex-refresh/cfgtoollogs/upgrade/auto/status/status.html
    /home/oracle/logs/ftex-refresh/cfgtoollogs/upgrade/auto/status/status.log
    ```
    </details>

## Task 3: Build refreshable clone

You build the refreshable clone with AutoUpgrade. It creates the PDB and starts the periodic refresh.

1. Start AutoUpgrade in *deploy* mode.

    * The deploy must run on the target system. Since source and target is the same in this lab, you don't need to worry about it.

    ```
    <copy>
    java -jar autoupgrade.jar -config /home/oracle/scripts/ftex-refresh.cfg -mode deploy
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    AutoUpgrade 24.2.240411 launched with default internal options
    Processing config file ...
    +--------------------------------+
    | Starting AutoUpgrade execution |
    +--------------------------------+
    1 Non-CDB(s) will be processed
    Type 'help' to list console commands
    upg> Copying remote database 'FTEX' as 'TEAL' for job 102
    ```
    </details>

2. Monitor the creation. AutoUpgrade creates the PDB and copies the data files in the phase *CLONEPDB*. The database is small so it completes fairly quick. Hit *RETURN* to bring the console forward and use the `lsj` command.

    ```
    <copy>    

    lsj -a 10
    </copy>
    ```

AutoUpgrade is now refreshing the PDB periodically. In a second terminal, you will enter some data to the *FTEX* database. This allows you to verify that changes made after the initial copy of data files still exist in the PDB after the migration.

3. Do not exit AutoUpgrade. Use a second terminal and set the environment to the *FTEX* database.

    ```
    <copy>
    . ftex
    sqlplus / as sysdba
    </copy>
    ```

4. Create test data.

    ```
    <copy>
    create user sales identified by oracle default tablespace users;
    grant dba to sales;
    create table sales.orders as select * from all_objects;
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> create user sales identified by oracle default tablespace users;

    User created.

    SQL> grant dba to sales;

    Grant succeeded.

    SQL> create table sales.orders as select * from all_objects;

    Table created.
    ```
    </details>

5. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```

7. Back in the first terminal check the progress of the *REFRESHPDB* phase. The *MESSAGE* field tells you how far it is.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    +----+-------+----------+---------+-------+----------+-------+-------------------+
    |Job#|DB_NAME|     STAGE|OPERATION| STATUS|START_TIME|UPDATED|            MESSAGE|
    +----+-------+----------+---------+-------+----------+-------+-------------------+
    | 102|   FTEX|REFRESHPDB|EXECUTING|RUNNING|  07:57:29| 2s ago|Starts in 2 minutes|
    +----+-------+----------+---------+-------+----------+-------+-------------------+
    Total jobs 1

    The command lsj is running every 10 seconds. PRESS ENTER TO EXIT
    ```
    </details>

8. Switch to the second terminal. Examine the alert log of *CDB23*, the target CDB, and see the creation of the refreshable clone PDB.

    ```
    <copy>
    cd /u01/app/oracle/diag/rdbms/cdb23/CDB23/trace
    grep -i -B2 "create pluggable database \"TEAL\"" alert_CDB23.log
    </copy>

    -- Be sure to hit RETURN
    ```

    * Notice how AutoUpgrade used the `CREATE PLUGGABLE DATABASE` statement.
    * The `@CLONEPDB` keyword specifies the use of remote cloning via the database link *CLONEPDB*.
    * The `REFRESH` keyword specifies the use of refreshable clone PDB.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    Opatch validation is skipped for PDB TEAL (con_id=0)
    2024-05-27T07:42:30.747705+00:00
    create pluggable database "TEAL"  FROM FTEX@CLONEPDB   file_name_convert=none  tempfile reuse  REFRESH MODE MANUAL
    --
    2024-05-27T07:42:47.488916+00:00
    TEAL(5):.... (PID:561068): Media Recovery Complete [dbsdrv.c:15613]
    Completed: create pluggable database "TEAL"  FROM FTEX@CLONEPDB   file_name_convert=none  tempfile reuse  REFRESH MODE MANUAL

    (output varies)
    ```
    </details>

9. Further, let's see the period refresh.

    ```
    <copy>
    grep -i -B2 "refresh" alert_CDB23.log
    </copy>
    ```

    * The `ALTER PLUGGABLE DATABASE ... REFRESH` command instructs the CDB to bring the latest redo from the source database and roll forward.
    * Notice how the refresh happens every 60 seconds. The refresh rate specified in the config file.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    2024-05-27T07:55:50.870470+00:00
    TEAL(5):.... (PID:562640): Media Recovery Complete [dbsdrv.c:15613]
    Completed: ALTER PLUGGABLE DATABASE TEAL REFRESH
    2024-05-27T07:56:47.653445+00:00
    ALTER PLUGGABLE DATABASE TEAL REFRESH
    --
    2024-05-27T07:56:50.911562+00:00
    TEAL(5):.... (PID:562736): Media Recovery Complete [dbsdrv.c:15613]
    Completed: ALTER PLUGGABLE DATABASE TEAL REFRESH
    2024-05-27T07:57:33.012205+00:00
    ALTER PLUGGABLE DATABASE TEAL REFRESH
    --
    2024-05-27T07:57:35.934217+00:00
    TEAL(5):.... (PID:562789): Media Recovery Complete [dbsdrv.c:15613]
    Completed: ALTER PLUGGABLE DATABASE TEAL REFRESH
    2024-05-27T07:57:35.993221+00:00
    ALTER PLUGGABLE DATABASE TEAL REFRESH MODE NONE
    Completed: ALTER PLUGGABLE DATABASE TEAL REFRESH MODE NONE

    (output varies)
    ```
    </details>

10. Close the second terminal and return to the first terminal. Do not close the terminal in which AutoUpgrade is running.

    ```
    <copy>
    exit
    </copy>
    ```

## Task 4: Upgrade and convert to PDB

When the *REFRESHPDB* phase is over, AutoUpgrade executes a final refresh to bring over the latest changes. Then, it disconnects the PDB from the non-CDB and starts the upgrade and conversion to PDB.

1. At this time, AutoUpgrade should have moved past the *REFRESHPDB* stage. In the first terminal, check the output of the `lsj` command running in the AutoUpgrade console.

    * AutoUpgrade moves through the next phases. The two main ones are *DBUPGRADE* which performs the upgrade to Oracle Database 23ai. The other one is *NONCDBTOPDB* which transforms the database into a proper PDB.

2. Optionally, while waiting for the job to complete, use some of the other commands in the console.

    * `status -jobid 102 -a 10`: Gives you even more details about the current job.
    * `help`: Show other commands available in the AutoUpgrade console.

3. Wait for AutoUpgrade to complete the migration. When the job completes, AutoUpgrade prints *Job 102 completed*.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    Job 102 completed
    ------------------- Final Summary --------------------
    Number of databases            [ 1 ]

    Jobs finished                  [1]
    Jobs failed                    [0]
    Jobs restored                  [0]
    Jobs pending                   [0]



    Please check the summary report at:
    /home/oracle/logs/ftex-refresh/cfgtoollogs/upgrade/auto/status/status.html
    /home/oracle/logs/ftex-refresh/cfgtoollogs/upgrade/auto/status/status.log
    ```
    </details>

4. Set the environment to the *CDB23* database and connect.

    ```
    <copy>
    . cdb23
    sqlplus / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

5. Switch to *TEAL* and ensure that the *SALES.ORDERS* table exist.

    ```
    <copy>
    alter session set container=TEAL;
    select count(*) from sales.orders;
    </copy>

    -- Be sure to hit RETURN
    ```

    * If the query completes without errors, it means the table is present. This proves that changes made after the initial copy of data files are still in the PDB after the migration.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> alter session set container=TEAL;

    Session altered.

    SQL> select count(*) from sales.orders;

      COUNT(*)
    ----------
         22757
    ```
    </details>

6. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```

## Task 5: Restart FTEX source database

AutoUpgrade stops the source non-CDB immediately after the final refresh. This ensures no one enters data into the wrong database during the migration. The *FTEX* database is used in other labs, so you need to restart it. You would not do this in a real migration.

1. Set the environment to the *FTEX* database and connect.

    ```
    <copy>
    . ftex
    sqlplus / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

2. Start the database.

    ```
    <copy>
    startup
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    ORACLE instance started.

    Total System Global Area 1157627144 bytes
    Fixed Size		    8924424 bytes
    Variable Size		  369098752 bytes
    Database Buffers	  771751936 bytes
    Redo Buffers		    7852032 bytes
    Database mounted.
    Database opened.
    ```
    </details>

3. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```

**Congratulations!** You have now:
* Upgraded the *FTEX* database
* Converted it to a PDB
* Renamed it to *TEAL*
* Left the source database intact for rollback

You may now *proceed to the next lab*.

## Learn More

Refreshable clone PDB is a good technique for multitenant migration. It leaves the source non-CDB intact for rollback. It also builds a copy of the non-CDB in advance which minimizes the downtime window. But you need additional disk space to hold a copy of the data files.

You can even use refreshable clone PDB for databases that are already a PDB. Very useful for unplug-plug upgrades.

* Documentation, [Local Parameters for the AutoUpgrade Configuration File](https://docs.oracle.com/en/database/oracle/oracle-database/23/upgrd/local-parameters-autoupgrade-config-file.html#GUID-005B5435-1CA6-4577-B265-F60D44168DE7)
* Webinar, [Move to Oracle Database 23ai – Everything you need to know about Oracle Multitenant – Part 1](https://www.youtube.com/watch?v=k0wCWbp-htU&t=3960s)
* Slides, [Move to Oracle Database 23ai – Everything you need to know about Oracle Multitenant – Part 1](https://dohdatabase.com/wp-content/uploads/2024/05/vc19_multitenant_part1.pdf)
* Blog post, [Upgrade Oracle Base Database Service to Oracle Database 23ai](https://dohdatabase.com/2024/05/21/upgrade-oracle-base-database-service-to-oracle-database-23ai/)

## Acknowledgements
* **Author** - Daniel Overby Hansen
* **Contributors** - Klaus Gronau, Rodrigo Jorge, Alex Zaballa, Mike Dietrich
* **Last Updated By/Date** - Daniel Overby Hansen, January 2025