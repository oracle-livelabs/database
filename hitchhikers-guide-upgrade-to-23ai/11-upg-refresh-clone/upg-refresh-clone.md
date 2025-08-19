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

    ``` sql
    <copy>
    . ftex
    sql / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

2. Create a user and grant the necessary privileges

    ``` sql
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

3. Exit SQLcl.

    ``` sql
    <copy>
    exit
    </copy>
    ```

4. Set the environment to the target CDB (*CDB23*) and connect.

    ``` sql
    <copy>
    . cdb23
    sql / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

5. Create a database link pointing to the *FTEX* database.

    ``` sql
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

    ``` sql
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

7. Exit SQLcl.

    ``` sql
    <copy>
    exit
    </copy>
    ```

## Task 2: Prepare for upgrade

You check the source database for upgrade readiness.

1. For this lab, you will use a pre-created config file. Examine the pre-created config file.

    ``` bash
    <copy>
    cat /home/oracle/scripts/upg-11-ftex-refresh.cfg
    </copy>
    ```

    * `sid` specifies the source non-CDB.
    * `target_cdb` is the CDB where you want to plug in.
    * `source_db_link` is the name of the database link in the target CDB, plus the refresh rate. Here, it's set to 60 seconds which is too low for a realistic scenario, but suitable for demo purposes.
    * `target_pdb_name` renames the database from *FTEX* to *TEAL*.
    * `target_pdb_copy_option` instructs the CDB to use Oracle Managed Files (OMF).
    * `parallel_pdb_creation_clause` instructs the CDB to use parallel execution servers to copy the new PDB's data files to a new location. This may result in faster creation of the PDB. If unset, then the CDB automatically chooses the number of parallel execution servers to use.
    * `start_time` is set to 100 hours from starting AutoUpgrade. We set the process start time far ahead so we can later control the execution using the *proceed* command.

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
    upg1.parallel_pdb_creation_clause.FTEX=2
    upg1.start_time=+100h
    upg1.timezone_upg=NO
    ```

    </details>

2. Start AutoUpgrade in *analyze* mode. The check usually completes very fast. Wait for it to complete.

    * The analysis must run on the source system. Since source and target is the same in this lab, you don't need to worry about it.

    ``` bash
    <copy>
    java -jar autoupgrade.jar -config /home/oracle/scripts/upg-11-ftex-refresh.cfg -mode analyze
    </copy>
    ```

3. When AutoUpgrade completes, it prints the path to the summary report. Check the summary report.

    ``` bash
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
    [Version Before Upgrade] 19.27.0.0.0
    [Version After Upgrade]  23.9.0.25.07
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

4. Proceed with the pre-upgrade fixups.

    * Normally, you would do this close to the final refresh (as dictated by `start_time` config file parameter or when you plan to run the *proceed* command). But in this lab we do it now.
    * The fixups must run on the source system. 
    * In the interest of time, you skip the fixups in this exercise.

## Task 3: Build refreshable clone

You build the refreshable clone with AutoUpgrade. It creates the PDB and starts the periodic refresh.

1. Start AutoUpgrade in *deploy* mode.

    * The deploy must run on the target system. Since source and target is the same in this lab, you don't need to worry about it.

    ``` bash
    <copy>
    java -jar autoupgrade.jar -config /home/oracle/scripts/upg-11-ftex-refresh.cfg -mode deploy
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    Processing config file ...
    +--------------------------------+
    | Starting AutoUpgrade execution |
    +--------------------------------+
    1 Non-CDB(s) will be processed
    Type 'help' to list console commands
    upg> Copying remote database 'FTEX' as 'TEAL' for job 101
    ```

    </details>

2. Monitor the creation. AutoUpgrade creates the PDB and copies the data files in the phase *CLONEPDB*. The database is small so it completes fairly quick. Hit *RETURN* to bring the console forward.

3. Use the `lsj` command.

    ``` bash
    <copy> 
    lsj -a 10
    </copy>
    ```

    AutoUpgrade is now refreshing the PDB periodically. In a second terminal, you will enter some data to the *FTEX* database. This allows you to verify that changes made after the initial copy of data files still exist in the PDB after the migration.

3. Do not exit AutoUpgrade. Switch to a *new* terminal. You might have to open a new tab. Set the environment to the *FTEX* database.

    ``` sql
    <copy>
    . ftex
    sql / as sysdba
    </copy>
    ```

4. Create test data.

    ``` sql
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

5. Exit SQLcl.

    ``` sql
    <copy>
    exit
    </copy>
    ```

6. Switch back to the *original* terminal and check the progress of the *REFRESHPDB* phase. The *MESSAGE* field tells you how far it is.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    +----+-------+----------+---------+-------+----------+-------+-----------------------+
    |Job#|DB_NAME|     STAGE|OPERATION| STATUS|START_TIME|UPDATED|                MESSAGE|
    +----+-------+----------+---------+-------+----------+-------+-----------------------+
    | 101|   FTEX|REFRESHPDB|EXECUTING|RUNNING|  07:57:29| 2s ago|Starts in 5,997 minutes|
    +----+-------+----------+---------+-------+----------+-------+-----------------------+
    Total jobs 1

    The command lsj is running every 10 seconds. PRESS ENTER TO EXIT
    ```

    </details>

7. Switch to the *new* terminal. Examine the alert log of *CDB23*, the target CDB, and see the creation of the refreshable clone PDB.

    ``` bash
    <copy>
    cd /u01/app/oracle/diag/rdbms/cdb23/CDB23/trace
    grep -i -B2 "create pluggable database \"TEAL\"" alert_CDB23.log
    </copy>

    # Be sure to hit RETURN
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

8. Further, let's see the period refresh.

    ``` bash
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
    Completed: ALTER PLU
    GGABLE DATABASE TEAL REFRESH
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

## Task 4: Upgrade and convert to PDB

The *REFRESHPDB* phase would stay technically for the next 100 hours. Reason we defined that long time is to have a full control when to start the process. Imagine, for example, we are waiting for a *go* or approval from another team to shut the application down so we can start our migration.

When the upgrade starts, AutoUpgrade executes a final refresh to bring over the latest changes. So no more changes will be captured from the source database. Then, it disconnects the PDB from the non-CDB and starts the upgrade and conversion to PDB.

1. Use the *original* terminal. Press ENTER just to stop *lsj* from spooling the job status. Next, run the `proceed` command to force the start of upgrade process **now**.

    ``` bash
    <copy>
    proceed -job 101
    </copy>

    -- Be sure to hit RETURN
    ```

    * AutoUpgrade will start shortly.
    * You can also specify a new start time using *proceed -job <#> -newStartTime [dd/mm/yyyy hh:mm:ss, +<#>h<#>m]*.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    upg> proceed -job 101
    New start time for job 101 is scheduled 0 minute(s) from now, at 25/07/2025 13:29:41
    ```

    </details>

2. Monitor the progress.

    ``` sql
    <copy>
    status -job 101 -a 10
    </copy>
    ```

    * AutoUpgrade was holding in *REFRESHPDB*; applying redo at the specified interval.
    * When you issued the `proceed` command, AutoUpgrade made a final refresh before moving on to the next phase.
    * Any changes made in the source database at this point in time, would not come over to the target PDB.
    * In the *DBUPGRADE* stage, AutoUpgrade is upgrading the PDB to the new release; Oracle Database 23ai. The CDB is already on the new release, so only the PDB is upgraded which is much faster than a complete database upgrade.
    * Since the source database is a non-CDB, the PDB must also be converted to a proper PDB. AutoUpgrade does that in *NONCDBTOPDB* where it runs the `noncdb_to_pdb.sql` script. 

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    Details
    
    	Job No           101
    	Oracle SID       FTEX
    	Start Time       25/08/01 09:48:23
    	Elapsed (min):   3
    	End time:        N/A
    
    Logfiles
    
    	Logs Base:    /home/oracle/logs/ftex-refresh/FTEX
    	Job logs:     /home/oracle/logs/ftex-refresh/FTEX/101
    	Stage logs:   /home/oracle/logs/ftex-refresh/FTEX/101/dbupgrade
    	TimeZone:     /home/oracle/logs/ftex-refresh/FTEX/temp
    	Remote Dirs:
    
    Stages
    	SETUP            <1 min
    	PREUPGRADE       <1 min
    	DRAIN            <1 min
    	CLONEPDB         <1 min
    	REFRESHPDB       3 min
    	DISPATCH         <1 min
    	DISPATCH         <1 min
    	DBUPGRADE        ~2 min (RUNNING)
    	NONCDBTOPDB
    	POSTCHECKS
    	POSTFIXUPS
    	POSTUPGRADE
    	SYSUPDATES
    
    Stage-Progress Per Container
    
    	+--------+---------+
    	|Database|DBUPGRADE|
    	+--------+---------+
    	|    TEAL|    6  % |
    	+--------+---------+
    
    The command status is running every 10 seconds. PRESS ENTER TO EXIT
    ```
    </details>

3. **Wait for AutoUpgrade to complete the migration**. When the job completes, AutoUpgrade prints *Job 101 completed*. It usually takes 10-15 minutes.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    Job 101 completed
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

5. Set the environment to the *CDB23* database and connect.

    ``` sql
    <copy>
    . cdb23
    sql / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

6. Switch to *TEAL* and ensure that the *SALES.ORDERS* table exist.

    ``` sql
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
         22844
    ```

    </details>

7. Exit SQLcl.

    ``` sql
    <copy>
    exit
    </copy>
    ```

## Task 5: Restart FTEX source database

AutoUpgrade stops the source non-CDB immediately after the final refresh. This ensures no one enters data into the wrong database during the migration, or add new data to it. The *FTEX* database is used in other labs, so you need to restart it. You would not do this in a real migration.

1. Set the environment to the *FTEX* database and connect.

    ``` sql
    <copy>
    . ftex
    sql / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

2. Start the database.

    ``` sql
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

3. Exit SQLcl.

    ``` sql
    <copy>
    exit
    </copy>
    ```

**Congratulations!** You have now:

* Upgraded the *FTEX* database
* Converted it to a PDB
* Renamed it to *TEAL*
* Left the source database intact for rollback

You may now [*proceed to the next lab*](#next).

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
* **Last Updated By/Date** - Rodrigo Jorge, August 2025
