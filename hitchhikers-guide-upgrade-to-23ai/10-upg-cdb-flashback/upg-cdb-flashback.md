# Upgrade CDB and Roll Back Using Flashback Database

## Introduction

In this lab, you will upgrade an entire CDB including PDBs from Oracle Database 19c to 23ai. Then, you will practice a rollback and the restoration option in AutoUpgrade. This uses Flashback Database to get the database back to the starting point.

Estimated Time: 35 minutes

### Objectives

In this lab, you will:

* Upgrade entire CDB
* Restore CDB

### Prerequisites

None.

This lab uses the *CDB19* databases. Don't do this lab at the same time as other labs using the same database.

## Task 1: Prepare your environment

You start by checking the *CDB19* database.

1. Set the environment to the *CDB19* database and connect.

    ```
    <copy>
    . cdb19
    sqlplus / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

2. Get a list of PDBs.

    ```
    <copy>
    show pdbs
    </copy>
    ```

    * There is one user-created PDBs in the CDB, *ORANGE*.
    * If you have already made lab 15 Downgrade a PDB, you will also see *YELLOW*.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    CON_ID     CON_NAME           OPEN MODE  RESTRICTED
    ---------- ------------------ ---------- ----------
             2 PDB$SEED           READ ONLY  NO
             4 ORANGE             READ WRITE NO
     ```
    </details>

3. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```

4. For this lab, you will use a pre-created config file. Examine the pre-created config file.

    ```
    <copy>
    cat /home/oracle/scripts/cdb19.cfg
    </copy>
    ```

    * `restoration=yes` ensures that AutoUpgrade creates a guaranteed restore point that you can use later on to roll back to. The default value is *yes* but it is shown here for clarity.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    global.autoupg_log_dir=/home/oracle/logs/upg-cdb-flashback
    upg1.source_home=/u01/app/oracle/product/19
    upg1.target_home=/u01/app/oracle/product/23
    upg1.sid=CDB19
    upg1.restoration=yes
    ```
    </details>

## Task 2: Analyze your database

It is best practice to first analyze your database for upgrade readiness. It is a lightweight, non-intrusive check that you can run on a live database.

1. Start AutoUpgrade in *analyze* mode. The check usually completes very fast. Wait for it to complete.

    ```
    <copy>
    java -jar autoupgrade.jar -config /home/oracle/scripts/cdb19.cfg -mode analyze
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    AutoUpgrade 24.4.240426 launched with default internal options
    Processing config file ...
    +--------------------------------+
    | Starting AutoUpgrade execution |
    +--------------------------------+
    1 CDB(s) plus 2 PDB(s) will be analyzed
    Type 'help' to list console commands
    upg> Job 100 completed
    ------------------- Final Summary --------------------
    Number of databases            [ 1 ]

    Jobs finished                  [1]
    Jobs failed                    [0]

    Please check the summary report at:
    /home/oracle/logs/upg-cdb-flashback/cfgtoollogs/upgrade/auto/status/status.html
    /home/oracle/logs/upg-cdb-flashback/cfgtoollogs/upgrade/auto/status/status.log
    ```
    </details>

3. AutoUpgrade prints the path to the summary report. Check it.

    ```
    <copy>
    cat /home/oracle/logs/upg-cdb-flashback/cfgtoollogs/upgrade/auto/status/status.log
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    ==========================================
              Autoupgrade Summary Report
    ==========================================
    [Date]           Fri May 24 12:47:36 GMT 2024
    [Number of Jobs] 1
    ==========================================
    [Job ID] 100
    ==========================================
    [DB Name]                CDB19
    [Version Before Upgrade] 19.21.0.0.0
    [Version After Upgrade]  23.4.0.24.05
    ------------------------------------------
    [Stage Name]    PRECHECKS
    [Status]        SUCCESS
    [Start Time]    2024-05-24 12:47:20
    [Duration]
    [Log Directory] /home/oracle/logs/upg-cdb-flashback/CDB19/100/prechecks
    [Detail]        /home/oracle/logs/upg-cdb-flashback/CDB19/100/prechecks/cdb19_preupgrade.log
                    Check passed and no manual intervention needed
    ------------------------------------------
    ```
    </details>

    * The report states: *Check passed and no manual intervention needed*. AutoUpgrade found no severe issues that it couldn't fix automatically.

## Task 3: Upgrade your database

You determined that the database is ready to upgrade. Start AutoUpgrade in *deploy* mode. One command is all it takes to perform the upgrade - including all pre- and post-upgrade tasks.

1. Start AutoUpgrade in *deploy* mode to perform the upgrade. Notice you are re-using the same command, but this time `-mode` is set to `deploy`.

    ```
    <copy>
    java -jar autoupgrade.jar -config /home/oracle/scripts/cdb19.cfg -mode deploy
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    AutoUpgrade 24.4.240426 launched with default internal options
    Processing config file ...
    +--------------------------------+
    | Starting AutoUpgrade execution |
    +--------------------------------+
    1 CDB(s) plus 2 PDB(s) will be processed
    Type 'help' to list console commands
    upg>
    ```
    </details>

2. You are now in the AutoUpgrade console. The upgrade job is running in the background. Show a list of running jobs and set it to refresh automatically

    ```
    <copy>
    lsj -a 30
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    +----+-------+-----+---------+-------+----------+-------+----------------------+
    |Job#|DB_NAME|STAGE|OPERATION| STATUS|START_TIME|UPDATED|               MESSAGE|
    +----+-------+-----+---------+-------+----------+-------+----------------------+
    | 101|  CDB19|DRAIN|EXECUTING|RUNNING|  12:51:56|38s ago|Shutting down database|
    +----+-------+-----+---------+-------+----------+-------+----------------------+
    Total jobs 1

    The command lsj is running every 30 seconds. PRESS ENTER TO EXIT

    (output varies)
    ```
    </details>

3. Wait until the upgrade completes. Depending on the hardware, the upgrade will take about 15-25 minutes. Don't exit from the AutoUpgrade console. Leave it running.

4. Optionally, you do another lab while the upgrade completes.

5. When the upgrade completes, AutoUpgrade prints a message saying *Job 101 completed* and exits from the AutoUpgrade console.

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

    ---- Drop GRP at your convenience once you consider it is no longer needed ----
    Drop GRP from CDB19: drop restore point AUTOUPGRADE_9212_CDB191921000


    Please check the summary report at:
    /home/oracle/logs/upg-cdb-flashback/cfgtoollogs/upgrade/auto/status/status.html
    /home/oracle/logs/upg-cdb-flashback/cfgtoollogs/upgrade/auto/status/status.log
    ```
    </details>

## Task 4: Restore database using AutoUpgrade

The database is now running on Oracle Database 23ai. Suppose your tests find a critical error and you would like to go back to Oracle Database 19c. AutoUpgrade automatically created a guaranteed restore point, and you can use Flashback Database to go back to the starting point.

1. Set the environment to the new Oracle home and connect to the upgraded *CDB19* database.

    ```
    <copy>
    export ORACLE_HOME=/u01/app/oracle/product/23
    export PATH=$ORACLE_HOME/bin:$PATH
    sqlplus / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

2. Verify that the database is on Oracle Database 23ai.

    ```
    <copy>
    select version from v$instance;
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    VERSION
    _____________
    23.0.0.0.0
    ```
    </details>

3. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```

4. Get the database back to the starting point; the guaranteed restore point that AutoUpgrade automatically created before the upgrade.

    ```
    <copy>
    java -jar autoupgrade.jar -config /home/oracle/scripts/cdb19.cfg -restore -jobs 101
    </copy>
    ```

    * You start the restoration based on the *job ID*.
    * Job *101* was the job that upgraded the database.
    * If you had multiple jobs to restore, you can supply a comma-separated list.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    Previous execution found loading latest data
    Total jobs being restored: 1
    +--------------------------------+
    | Starting AutoUpgrade execution |
    +--------------------------------+
    ```
    </details>

5. After a short while the restoration completes. It usually takes only a few minutes. AutoUpgrade uses Flashback Database which is a very effective mean of restoring the database. Then, it needs to open the database with `RESETLOGS` which can take a short while if the redo log members are big.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    Job 101 completed
    ------------------- Final Summary --------------------
    Number of databases            [ 1 ]

    Jobs restored                  [1]
    Jobs failed                    [0]
    -------------------- JOBS PENDING --------------------
    Job 101 for CDB19

    Please check the summary report at:
    /home/oracle/logs/upg-cdb-flashback/cfgtoollogs/upgrade/auto/status/status.html
    /home/oracle/logs/upg-cdb-flashback/cfgtoollogs/upgrade/auto/status/status.log
    Exiting
    ```
    </details>

6. Set the environment to the original Oracle home and connect.

    ```
    <copy>
    . cdb19
    sqlplus / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

7. Verify that the database is running on Oracle Database 19c.

    ```
    <copy>
    select version from v$instance;
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    VERSION
    -----------------
    19.0.0.0.0
    ```
    </details>

8. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```

9. AutoUpgrade also updated the *oratab* registration.

    ```
    <copy>
    cat /etc/oratab | grep CDB19
    </copy>
    ```

    * Notice how the Oracle home is set to the original, 19c Oracle home.
    * If Grid Infrastructure would manage the database, AutoUpgrade would modify the clusterware registration as well.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    CDB19:/u01/app/oracle/product/19:N
    ```
    </details>

10. AutoUpgrade also moved database configuration files back into the original Oracle home.

    ```
    <copy>
    ll $ORACLE_HOME/dbs/*CDB19*
    </copy>
    ```

    * AutoUpgrade also moves other configuration files like network files (`sqlnet.ora`, `tnsnames.ora`).

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    -rw-r-----. 1 oracle oinstall       24 May 23 11:52 /u01/app/oracle/product/19/dbs/lkCDB19
    -rw-r-----. 1 oracle oinstall     2048 May 23 12:20 /u01/app/oracle/product/19/dbs/orapwCDB19
    -rw-r-----. 1 oracle oinstall 19120128 May 26 05:23 /u01/app/oracle/product/19/dbs/snapcf_CDB19.f
    -rw-r-----. 1 oracle oinstall     3584 May 26 05:24 /u01/app/oracle/product/19/dbs/spfileCDB19.ora
    -rw-rw----. 1 oracle oinstall     1544 May 26 05:24 /u01/app/oracle/product/19/dbs/hc_CDB19.dat
    ```
    </details>

**You have now restored the *CDB19* database.**

You may now *proceed to the next lab*.

## Learn More

AutoUpgrade completely automates restoration of a database. By default, AutoUpgrade creates a guaranteed restore point before making any changes to the database. If a critical error occurs during upgrade or if your post-upgrade test reveals an issue preventing go-live, you can use AutoUpgrade to bring the database back into the *before-upgrade* state.

* My Oracle Support, [AutoUpgrade Tool (Doc ID 2485457.1)](https://support.oracle.com/epmos/faces/DocumentDisplay?id=2485457.1)
* Documentation, [AutoUpgrade Command-Line Syntax](hhttps://docs.oracle.com/en/database/oracle/oracle-database/23/upgrd/autoupgrade-command-line-parameters.html#GUID-B969F325-EB44-42B3-AD93-43E47493E271)
* Webinar, [Secure Your Job – Fallback Is Your Insurance](https://www.youtube.com/watch?v=P12UqVRzarw)

## Acknowledgements
* **Author** - Daniel Overby Hansen
* **Contributors** - Klaus Gronau, Rodrigo Jorge, Alex Zaballa, Mike Dietrich
* **Last Updated By/Date** - Daniel Overby Hansen, June 2024