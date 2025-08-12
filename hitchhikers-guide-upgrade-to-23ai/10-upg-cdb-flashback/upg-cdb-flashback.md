# Upgrade CDB and Roll Back Using Flashback Database

## Introduction

In this lab, you will start by checking an entire CDB that was already upgraded, to save time, from Oracle Database 19c to 23ai. Then, you will practice a rollback and the restoration option in AutoUpgrade. This uses Flashback Database to get the database back to the starting point.

Estimated Time: 60 minutes

### Objectives

In this lab, you will:

* Check the upgraded CDB
* Restore CDB

### Prerequisites

None.

This lab uses the *CDBRES* databases.

## Task 1: Check your environment

You start by checking the *CDBRES* database. This database was originally on Oracle Database 19c and later upgraded to Oracle Database 23ai. You should imagine that you already upgraded the database, and now you find a critical problem and decide to roll back to the previous release.

1. Set the environment to the new Oracle home and connect to the upgraded *CDBRES* database.

    ``` sql
    <copy>
    . cdbres
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

    * The *CDBRES* database might be running already. If so, you will get `ORA-01081: cannot start already-running ORACLE - shut it down first`. You can safely ignore the error.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> startup
    ORACLE instance started.

    Total System Global Area 4294964616 bytes
    Fixed Size                  9172360 bytes
    Variable Size             855638016 bytes
    Database Buffers         3422552064 bytes
    Redo Buffers                7602176 bytes

    Database mounted.
    Database opened.
    ```

    </details>

3. Verify that the database is on Oracle Database 23ai.

    ``` sql
    <copy>
    select instance_name, version from v$instance;
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> select instance_name, version from v$instance;

    INSTANCE_NAME    VERSION
    ---------------- -----------------
    CDBRES           23.0.0.0.0
    ```

    </details>

4. Get a list of PDBs.

    ``` sql
    <copy>
    show pdbs
    </copy>
    ```

    * There is one user-created PDBs in the CDB, *GREY*.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    CON_ID     CON_NAME           OPEN MODE  RESTRICTED
    ---------- ------------------ ---------- ----------
             2 PDB$SEED           READ ONLY  NO
             3 GREY               READ WRITE NO
    ```

    </details>

5. Get a list of restore points.

    ``` sql
    <copy>
    select scn, storage_size, time, preserved, name from v$restore_point;
    </copy>

    -- Be sure to hit RETURN
    ```

    * There is one restore point named "AUTOUPGRADE\_9212\_CDBRES1927000".

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> select scn, storage_size, time, preserved, name from v$restore_point;

          SCN    STORAGE_SIZE TIME                               PRESERVED    NAME
    _________ _______________ __________________________________ ____________ _________________________________
       715819      1677721600 24-JUL-25 03.15.50.000000000 PM    YES          AUTOUPGRADE_9212_CDBRES1927000
    ```

    </details>

6. Exit SQLcl.

    ``` sql
    <copy>
    exit
    </copy>
    ```

7. To upgrade this database from 19c to 23ai, we used the *upg-10-cdbres.cfg* config file. Examine config file.

    ``` bash
    <copy>
    cat /home/oracle/scripts/upg-10-cdbres.cfg
    </copy>
    ```

    * `restoration=yes` ensured that AutoUpgrade created a guaranteed restore point that you can use to roll back. The default value is *yes* but it is shown here for clarity.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    global.autoupg_log_dir=/home/oracle/logs/upg-cdb-flashback
    upg1.source_home=/u01/app/oracle/product/19
    upg1.target_home=/u01/app/oracle/product/23
    upg1.sid=CDBRES
    upg1.restoration=yes
    upg1.timezone_upg=NO
    ```

    </details>

8. By the config file contents, you can tell the logs are placed on */home/oracle/logs/upg-cdb-flashback*. Check AutoUpgrade the log contents.

    ``` bash
    <copy>
    cat /home/oracle/logs/upg-cdb-flashback/cfgtoollogs/upgrade/auto/status/status.log
    </copy>
    ```

    * Notice the *GRP* stage. AutoUpgrade wrote the name of the restore point to the log file.
    * It is the same restore point that you found in the query above.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    ==========================================
              Autoupgrade Summary Report
    ==========================================
    [Date]           Thu Jul 24 16:26:24 GMT 2025
    [Number of Jobs] 1
    ==========================================
    [Job ID] 100
    ==========================================
    [DB Name]                cdbres
    [Version Before Upgrade] 19.27.0.0.0
    [Version After Upgrade]  23.9.0.25.07
    ------------------------------------------
    [Stage Name]    GRP
    [Status]        SUCCESS
    [Start Time]    2025-07-24 15:15:50
    [Duration]      0:00:02
    [Detail]        Please drop the following GRPs after Autoupgrade completes:
                     AUTOUPGRADE_9212_CDBRES1927000
    ------------------------------------------
    [Stage Name]    PREUPGRADE
    [Status]        SUCCESS
    [Start Time]    2025-07-24 15:15:52
    [Duration]      0:00:00
    [Log Directory] /home/oracle/logs/upg-cdb-flashback/CDBRES/100/preupgrade
    ------------------------------------------
    [Stage Name]    PRECHECKS
    [Status]        SUCCESS
    [Start Time]    2025-07-24 15:15:52
    [Duration]      0:00:32
    [Log Directory] /home/oracle/logs/upg-cdb-flashback/CDBRES/100/prechecks
    [Detail]        /home/oracle/logs/upg-cdb-flashback/CDBRES/100/prechecks/cdbres_preupgrade.log
                    Check passed and no manual intervention needed
    ------------------------------------------
    [Stage Name]    PREFIXUPS
    [Status]        SUCCESS
    [Start Time]    2025-07-24 15:16:24
    [Duration]      0:02:48
    [Log Directory] /home/oracle/logs/upg-cdb-flashback/CDBRES/100/prefixups
    [Detail]        /home/oracle/logs/upg-cdb-flashback/CDBRES/100/prefixups/prefixups.html
    ------------------------------------------
    [Stage Name]    DRAIN
    [Status]        SUCCESS
    [Start Time]    2025-07-24 15:19:13
    [Duration]      0:00:43
    [Log Directory] /home/oracle/logs/upg-cdb-flashback/CDBRES/100/drain
    ------------------------------------------
    [Stage Name]    DBUPGRADE
    [Status]        SUCCESS
    [Start Time]    2025-07-24 15:19:57
    [Duration]      0:48:01
    [Log Directory] /home/oracle/logs/upg-cdb-flashback/CDBRES/100/dbupgrade
    ------------------------------------------
    [Stage Name]    POSTCHECKS
    [Status]        SUCCESS
    [Start Time]    2025-07-24 16:08:12
    [Duration]      0:00:04
    [Log Directory] /home/oracle/logs/upg-cdb-flashback/CDBRES/100/postchecks
    [Detail]        /home/oracle/logs/upg-cdb-flashback/CDBRES/100/postchecks/cdbres_postupgrade.log
                    Check passed and no manual intervention needed
    ------------------------------------------
    [Stage Name]    POSTFIXUPS
    [Status]        SUCCESS
    [Start Time]    2025-07-24 16:08:18
    [Duration]      0:17:33
    [Log Directory] /home/oracle/logs/upg-cdb-flashback/CDBRES/100/postfixups
    [Detail]        /home/oracle/logs/upg-cdb-flashback/CDBRES/100/postfixups/postfixups.html
    ------------------------------------------
    [Stage Name]    POSTUPGRADE
    [Status]        SUCCESS
    [Start Time]    2025-07-24 16:25:51
    [Duration]      0:00:31
    [Log Directory] /home/oracle/logs/upg-cdb-flashback/CDBRES/100/postupgrade
    ------------------------------------------
    [Stage Name]    SYSUPDATES
    [Status]        SUCCESS
    [Start Time]    2025-07-24 16:26:23
    [Duration]      0:00:01
    [Log Directory] /home/oracle/logs/upg-cdb-flashback/CDBRES/100/sysupdates
    ------------------------------------------
    Summary:/home/oracle/logs/upg-cdb-flashback/CDBRES/100/dbupgrade/upg_summary.log
    ```

    </details>

## Task 2: Restore database using AutoUpgrade

Suppose your tests find a critical error and you would like to go back to Oracle Database 19c. AutoUpgrade automatically created a guaranteed restore point, and you can use Flashback Database to go back to the starting point.

1. Check the *oratab* registration.

    ``` bash
    <copy>
    cat /etc/oratab | grep CDBRES
    </copy>
    ```

    * Notice how the Oracle home is set to the new, 23ai Oracle home. This was done by AutoUpgrade.
    * If Grid Infrastructure would manage the database, AutoUpgrade would modify the clusterware registration as well.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    CDBRES:/u01/app/oracle/product/23:N
    ```

    </details>

2. Get the database back to the starting point; the guaranteed restore point that AutoUpgrade automatically created before the upgrade.

    ``` bash
    <copy>
    java -jar autoupgrade.jar -config /home/oracle/scripts/upg-10-cdbres.cfg -restore -jobs 100
    </copy>
    ```

    * You start the restoration based on the *job ID*.
    * Job *100* was the job that upgraded the database.
    * If you had multiple jobs to restore, you can supply a comma-separated list.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    Previous execution found loading latest data
    Total jobs being restored: 1
    +--------------------------------+
    | Starting AutoUpgrade execution |
    +--------------------------------+
    +----+-------+---------+---------+--------+------------+-------+-------+
    |Job#|DB_NAME|    STAGE|OPERATION|  STATUS|  START_TIME|UPDATED|MESSAGE|
    +----+-------+---------+---------+--------+------------+-------+-------+
    | 100| CDBRES|COMPLETED|  STOPPED|FINISHED|Jul-31 09:15|       |       |
    +----+-------+---------+---------+--------+------------+-------+-------+
    Total jobs 1
    ```

    </details>

3. After a short while the restoration completes. It usually takes only a few minutes. AutoUpgrade uses Flashback Database which is a very effective mean of restoring the database. Then, it needs to open the database with `RESETLOGS` which can take a short while if the redo log members are big.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    Job 100 completed
    ------------------- Final Summary --------------------
    Number of databases            [ 1 ]

    Jobs restored                  [1]
    Jobs failed                    [0]
    -------------------- JOBS PENDING --------------------
    Job 100 for CDBRES

    Please check the summary report at:
    /home/oracle/logs/upg-cdb-flashback/cfgtoollogs/upgrade/auto/status/status.html
    /home/oracle/logs/upg-cdb-flashback/cfgtoollogs/upgrade/auto/status/status.log
    Exiting
    ```

    </details>

4. Set the environment to the original Oracle home and connect.

    ``` bash
    <copy>
    . cdbres
    export ORACLE_HOME=/u01/app/oracle/product/19
    sqlplus / as sysdba
    </copy>

    # Be sure to hit RETURN
    ```

5. Verify that the database is running on Oracle Database 19c.

    ``` sql
    <copy>
    select instance_name, version from v$instance;
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> select instance_name, version from v$instance;

    INSTANCE_NAME    VERSION
    ---------------- -----------------
    CDBRES           19.0.0.0.0
    ```

    </details>

6. Exit SQL*Plus.

    ``` sql
    <copy>
    exit
    </copy>
    ```

7. AutoUpgrade also reverted the *oratab* registration.

    ``` bash
    <copy>
    cat /etc/oratab | grep CDBRES
    </copy>
    ```

    * Notice how the Oracle home is set to the original, 19c Oracle home.
    * If Grid Infrastructure would manage the database, AutoUpgrade would modify the clusterware registration as well.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    CDBRES:/u01/app/oracle/product/19:N
    ```

    </details>

8. AutoUpgrade also moved database configuration files back into the original Oracle home.

    ``` bash
    <copy>
    ll $ORACLE_HOME/dbs/*CDBRES*
    </copy>
    ```

    * AutoUpgrade also moves other configuration files like network files (`sqlnet.ora`, `tnsnames.ora`).

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    -rw-r-----. 1 oracle oinstall       24 May 23 11:52 /u01/app/oracle/product/19/dbs/lkCDBRES
    -rw-r-----. 1 oracle oinstall     2048 May 23 12:20 /u01/app/oracle/product/19/dbs/orapwCDBRES
    -rw-r-----. 1 oracle oinstall 19120128 May 26 05:23 /u01/app/oracle/product/19/dbs/snapcf_CDBRES.f
    -rw-r-----. 1 oracle oinstall     3584 May 26 05:24 /u01/app/oracle/product/19/dbs/spfileCDBRES.ora
    -rw-rw----. 1 oracle oinstall     1544 May 26 05:24 /u01/app/oracle/product/19/dbs/hc_CDBRES.dat
    ```

    </details>

**You have now restored the *CDBRES* database.**

You may now [*proceed to the next lab*](#next).

## Learn More

AutoUpgrade completely automates restoration of a database. By default, AutoUpgrade creates a guaranteed restore point before making any changes to the database. If a critical error occurs during upgrade or if your post-upgrade test reveals an issue preventing go-live, you can use AutoUpgrade to bring the database back into the *before-upgrade* state.

* My Oracle Support, [AutoUpgrade Tool (Doc ID 2485457.1)](https://support.oracle.com/epmos/faces/DocumentDisplay?id=2485457.1)
* Documentation, [AutoUpgrade Command-Line Syntax](hhttps://docs.oracle.com/en/database/oracle/oracle-database/23/upgrd/autoupgrade-command-line-parameters.html#GUID-B969F325-EB44-42B3-AD93-43E47493E271)
* Webinar, [Secure Your Job – Fallback Is Your Insurance](https://www.youtube.com/watch?v=P12UqVRzarw)

## Acknowledgements

* **Author** - Daniel Overby Hansen
* **Contributors** - Klaus Gronau, Rodrigo Jorge, Alex Zaballa, Mike Dietrich
* **Last Updated By/Date** - Rodrigo Jorge, August 2025
