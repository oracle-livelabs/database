# Upgrade CDB and Restore

## Introduction

In this lab, you will upgrade an entire CDB to Oracle AI Database 26ai. Then, you will practice a rollback using the restoration option in AutoUpgrade. AutoUpgrade uses Flashback Database to return the database to its starting point.

Estimated Time: 55 minutes

### Objectives

In this lab, you will:

* Upgrade the *COBALT* CDB
* Use AutoUpgrade restoration to restore the database using Flashback Database

### Prerequisites

None.

## Task 1: Prepare for Upgrade

You will upgrade the *COBALT* database. It's a CDB with one PDB, *MOCHA*. It's currently running Oracle Database 19c.

1. Start a new terminal or use an existing one. You can use any terminal for this lab.

1. Set the environment and connect.

    ``` bash
    <copy>
    . cobalt
    sqlplus / as sysdba
    </copy>

    # Be sure to press RETURN
    ```

2. Start the database.

    ``` bash
    <copy>
    startup
    </copy>
    ```
    
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

3. List all the PDBs.

    ``` bash
    <copy>
    show pdbs
    </copy>
    ```

    * There is one user-created PDB in the CDB: *MOCHA*.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    CON_ID     CON_NAME           OPEN MODE  RESTRICTED
    ---------- ------------------ ---------- ----------
             2 PDB$SEED           READ ONLY  NO
             3 MOCHA              READ WRITE NO
    ```

    </details>

4. Exit.

    ``` bash
    <copy>
    exit
    </copy>
    ```

5. Examine the AutoUpgrade config file.

    ``` bash
    <copy>
    cat /home/oracle/scripts/upg-cdb-restore.cfg
    </copy>
    ```

    * `sid` is the database to upgrade.
    * It currently runs from the Oracle home specified by `source_home`.
    * The target Oracle home is specified by `target_home`.
    * To ensure a rollback option, you set `restoration=YES`. This creates a guaranteed restore point before the upgrade.
    * In the interest of time, you will skip the timezone file upgrade using the `timezone_upg` parameter.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    global.global_log_dir=/home/oracle/logs/upg-cdb-restore
    upg1.source_home=/u01/app/oracle/product/19
    upg1.target_home=/u01/app/oracle/product/26
    upg1.sid=COBALT
    upg1.restoration=YES
    upg1.timezone_upg=NO    
    ```

    </details>

7. Assess the upgrade readiness of the database.

    ``` bash
    <copy>
    java -jar autoupgrade.jar -config /home/oracle/scripts/upg-cdb-restore.cfg -mode analyze
    </copy>
    ```

    * The preupgrade analysis usually completes quickly. Wait for it to complete.
    * Notice that AutoUpgrade informs you that it will analyze one CDB plus two PDBs. 

    <details>
    <summary>*click to see the output*</summary>

    ``` text
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
    /home/oracle/logs/upg-cdb-restore/cfgtoollogs/upgrade/auto/status/status.html
    /home/oracle/logs/upg-cdb-restore/cfgtoollogs/upgrade/auto/status/status.log
    ```

    </details>

8. Check the summary report.

    ``` bash
    <copy>
    cat /home/oracle/logs/upg-cdb-restore/cfgtoollogs/upgrade/auto/status/status.log
    </copy>
    ```

    * It reports: *Check passed and no manual intervention needed*. 

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    ==========================================
              Autoupgrade Summary Report
    ==========================================
    [Date]           Thu Aug 13 09:20:36 GMT 2026
    [Number of Jobs] 1
    ==========================================
    [Job ID] 100
    ==========================================
    [DB Name]                cobalt
    [Version Before Upgrade] 19.31.0.0.0
    [Version After Upgrade]  23.26.3.0.0
    ------------------------------------------
    [Stage Name]    PRECHECKS
    [Status]        SUCCESS
    [Start Time]    2026-08-13 09:20:23
    [Duration]      0:00:13
    [Log Directory] /home/oracle/logs/upg-cdb-restore/COBALT/100/prechecks
    [Detail]        /home/oracle/logs/upg-cdb-restore/COBALT/100/prechecks/cobalt_preupgrade.log
                    Check passed and no manual intervention needed
    ------------------------------------------
    ```

    </details>

9. Examine the preupgrade report.

    ``` bash
    <copy>
    less /home/oracle/logs/upg-cdb-restore/COBALT/100/prechecks/cobalt_preupgrade.log
    </copy>
    ```

    * The report is different since you upgrade an entire CDB. 
    * Now, it contains three sections, one for each container: *CDB$ROOT*, *PDB$SEED* and *MOCHA*.
    * Notice that *Container Name: CDB$ROOT* appears near the beginning of the report.
    * Use *PAGE UP* and *PAGE DOWN* to scroll through the report.
    * Find the sections for the other containers: *PDB$SEED* and *MOCHA*.
    * Examine some of the findings.
    * Press *q* to exit the report.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    Upgrade-To version: 23.0.0.0.0

    =======================================
    Status of the database prior to upgrade
    =======================================
          Database Name:  COBALT
         Container Name:  CDB$ROOT
           Container ID:  1
                Version:  19.31.0.0.0
         DB Patch Level:  Database Release Update : 19.31.0.0.260421 (REL-APR2026) (39034528)
             Compatible:  19.0.0
              Blocksize:  8192
               Platform:  Linux x86 64-bit
          Timezone File:  45
      Database log mode:  ARCHIVELOG
               Readonly:  false
                Edition:  EE

      Oracle Component                       Upgrade Action    Current Status
      ----------------                       --------------    --------------
      Oracle Server                          [to be upgraded]  VALID
      Oracle Workspace Manager               [to be upgraded]  VALID
      Real Application Clusters              [to be upgraded]  OPTION OFF
      Oracle XML Database                    [to be upgraded]  VALID

      *
      * ALL Components in This Database Registry:
      *
      Component   Current      Current      Original     Previous     Component
      CID         Version      Status       Version      Version      Schema
      ----------  -----------  -----------  -----------  -----------  ------------    
        CATALOG     19.31.0.0.0  VALID        19.31.0.0.0               SYS
      CATPROC     19.31.0.0.0  VALID        19.31.0.0.0               SYS
      OWM         19.31.0.0.0  VALID        19.31.0.0.0               WMSYS
      RAC         19.31.0.0.0  OPTION OFF   19.31.0.0.0               SYS
      XDB         19.31.0.0.0  VALID        19.31.0.0.0               XDB

    ==============
    BEFORE UPGRADE
    ==============

      REQUIRED ACTIONS
      ================
      None

      RECOMMENDED ACTIONS
      ===================
      1.
            CheckName                                     FixUp Available
            UNIFIED_AUDIT_ON                              NO

            Severity                                      Stage
            WARNING                                       PRECHECKS

          Convert your traditional audit configurations to unified audit policies
          and enable them. To continue using traditional audit in 23, make sure
          initialization parameters AUDIT_TRAIL and AUDIT_SYS_OPERATIONS are set in
          the database after the upgrade process. This is intended as a temporary
          measure until you have time to convert to unified audit. Refer to MOS

    (output truncated)      
    ```

    </details>

10. Examine the preupgrade HTML report.

    ``` bash
    <copy>
    firefox /home/oracle/logs/upg-cdb-restore/COBALT/100/prechecks/cobalt_preupgrade.html &
    </copy>
    ```

11. Exit Firefox.

## Task 2: Start the Upgrade

1. Upgrade the database by starting AutoUpgrade in deploy mode.

    ``` bash
    <copy>
    java -jar autoupgrade.jar -config /home/oracle/scripts/upg-cdb-restore.cfg -mode deploy
    </copy>
    ```

    * AutoUpgrade now re-analyzes the database and executes any pre-upgrade actions.
    * It creates a guaranteed restore point before restarting the database in the target Oracle home.
    * Next, the upgrade starts with CDB$ROOT. Then it moves on with PDB$SEED and MOCHA in parallel.
    * Finally, AutoUpgrade runs the post-upgrade actions. 
    * It takes around 30-40 minutes. 


    <details>
    <summary>*click to see the output*</summary>

    ``` text
    Processing config file ...
    +--------------------------------+
    | Starting AutoUpgrade execution |
    +--------------------------------+
    1 CDB(s) plus 2 PDB(s) will be processed
    Type 'help' to list console commands
    upg>
    ```

    </details>

2. Monitor the upgrade.

    ``` bash
    <copy>
    status -job 101 -a 30
    </copy>
    ```

4. Wait for the upgrade to complete. Do not exit AutoUpgrade.
    * You can open a new terminal and work on other labs while the upgrade runs.

5. When the upgrade completes, AutoUpgrade writes information to the console.

    * There is a guaranteed restore point (GRP) which you should drop when no longer needed.
    * Links to the upgrade summary report.
    * You use the GRP later to restore the database to the pre-upgrade state.

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
    Drop GRP from COBALT: drop restore point AUTOUPGRADE_9212_COBALT1931000


    Please check the summary report at:
    /home/oracle/logs/upg-cdb-restore/cfgtoollogs/upgrade/auto/status/status.html
    /home/oracle/logs/upg-cdb-restore/cfgtoollogs/upgrade/auto/status/status.log    
    ```

    </details>

6. Set the environment and connect.

    ``` bash
    <copy>
    export ORACLE_HOME=/u01/app/oracle/product/26
    export PATH=$ORACLE_HOME/bin:$PATH
    export ORACLE_SID=COBALT
    sql / as sysdba
    </copy>

    # Be sure to press RETURN
    ```

7. Check the database release.

    ``` bash
    <copy>
    select version_full from v$instance;
    </copy>
    ```

    * The database is running on the new release, Oracle AI Database 26ai.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    VERSION_FULL
    _______________
    23.26.3.0.0
    ```

    </details>

8. Check the PDBs.

    ``` bash
    <copy>
    show pdbs
    </copy>
    ```

    * The *MOCHA* PDB is open *READ WRITE* and unrestricted.
    * Everything looks fine.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
       CON_ID CON_NAME    OPEN MODE     RESTRICTED
    _________ ___________ _____________ _____________
            2 PDB$SEED    READ ONLY     NO
            3 MOCHA       READ WRITE    NO
    ```

    </details>

9. Exit SQLcl.

    ``` bash
    <copy>
    exit
    </copy>
    ```    

## Task 3: Undo the Upgrade

Suppose your tests identify a critical error and you need to return to Oracle Database 19c. AutoUpgrade automatically created a guaranteed restore point that you can use with Flashback Database to return to the pre-upgrade state.

1. Check the oratab registration.

    ``` bash
    <copy>
    cat /etc/oratab | grep COBALT
    </copy>
    ```

    * Notice that the database is registered with the new Oracle home. This was done by AutoUpgrade.
    * If Grid Infrastructure managed the database, AutoUpgrade would modify the clusterware registration as well.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    COBALT:/u01/app/oracle/product/26:N
    ```

    </details>

2. Undo the upgrade and return the database to the starting point using the guaranteed restore point that AutoUpgrade created before the upgrade.

    ``` bash
    <copy>
    java -jar autoupgrade.jar -config /home/oracle/scripts/upg-cdb-restore.cfg -restore -jobs 101
    </copy>
    ```

    * You start the restoration using on the job ID.
    * Job 101 performed the database upgrade.
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

3. The restoration usually completes within a few minutes. AutoUpgrade uses Flashback Database, which is a very effective means of restoring the database. Then, it needs to open the database with `RESETLOGS`, which can take a short while if the redo log members are big.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    Job 101 completed
    ------------------- Final Summary --------------------
    Number of databases            [ 1 ]

    Jobs restored                  [1]
    Jobs failed                    [0]
    -------------------- JOBS PENDING --------------------
    Job 101 for COBALT

    Please check the summary report at:
    /home/oracle/logs/upg-cdb-restore/cfgtoollogs/upgrade/auto/status/status.html
    /home/oracle/logs/upg-cdb-restore/cfgtoollogs/upgrade/auto/status/status.log
    Exiting
    ```

    </details>

4. Set the environment to the original Oracle home and connect.

    ``` bash
    <copy>
    . cobalt
    sql / as sysdba
    </copy>
    ```

5. Verify that the database is running on Oracle Database 19c.

    ``` bash
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
    COBALT           19.0.0.0.0
    ```

    </details>

6. Exit SQLcl.

    ``` bash
    <copy>
    exit
    </copy>
    ```

7. AutoUpgrade also reverted the *oratab* registration.

    ``` bash
    <copy>
    cat /etc/oratab | grep COBALT
    </copy>
    ```

    * Notice that the database is registered with the original 19c Oracle home.
    * If Grid Infrastructure would manage the database, AutoUpgrade would modify the clusterware registration as well.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    COBALT:/u01/app/oracle/product/19:N
    ```

    </details>

8. AutoUpgrade also moved database configuration files back into the original Oracle home.

    ``` bash
    <copy>
    ll $ORACLE_HOME/dbs/*COBALT*
    </copy>
    ```

    * AutoUpgrade also moves other configuration files, such as network files (`sqlnet.ora`, `tnsnames.ora`).

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    -rw-rw----. 1 oracle oinstall     1544 Aug 13 10:24 /u01/app/oracle/product/19/dbs/hc_COBALT.dat
    -rw-r-----. 1 oracle oinstall       24 Aug 12 23:07 /u01/app/oracle/product/19/dbs/lkCOBALT
    -rw-r-----. 1 oracle oinstall     2048 Aug 12 20:24 /u01/app/oracle/product/19/dbs/orapwCOBALT
    -rw-r-----. 1 oracle oinstall 19152896 Aug 13 10:23 /u01/app/oracle/product/19/dbs/snapcf_COBALT.f
    -rw-r-----. 1 oracle oinstall     3584 Aug 13 10:24 /u01/app/oracle/product/19/dbs/spfileCOBALT.ora
    ```

    </details>

**You have now restored the *COBALT* database.**

You may now [*proceed to the next lab*](#next).

## Learn More

AutoUpgrade completely automates database restoration. By default, AutoUpgrade creates a guaranteed restore point before making any changes to the database. If a critical error occurs during the upgrade or if your post-upgrade tests reveal an issue preventing go-live, you can use AutoUpgrade to bring the database back to its *pre-upgrade* state.

* My Oracle Support, [AutoUpgrade Tool (Doc ID 2485457.1)](https://support.oracle.com/epmos/faces/DocumentDisplay?id=2485457.1)
* Documentation, [AutoUpgrade Command-Line Syntax](https://docs.oracle.com/en/database/oracle/oracle-database/26/upgrd/autoupgrade-command-line-parameters.html#GUID-E532008C-77BD-4BC0-9EBC-DAD84C2C2805)
* Webinar, [Secure Your Job – Fallback Is Your Insurance](https://www.youtube.com/watch?v=P12UqVRzarw)

## Acknowledgements

* **Author** - Daniel Overby Hansen
* **Contributors** - Rodrigo Jorge, Alex Zaballa, Mike Dietrich, Alejandro Diaz
* **Last Updated By/Date** - Daniel Overby Hansen, August 2026
