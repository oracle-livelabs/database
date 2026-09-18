# Patch a Database to an Existing Oracle Home

## Introduction

In this lab, you will patch an Oracle AI Database using *AutoUpgrade*. You perform an out-of-place patch and use an existing Oracle home.

Estimated Time: 10 Minutes

### Objectives

In this lab, you will:

* Analyze a database
* Patch a database

### Prerequisites

None.

## Task 1: Analyze Database

Oracle recommends that you first check your database. AutoUpgrade in *analyze* mode performs a lightweight, nonintrusive check of an Oracle AI Database.

1. Use the *blue* terminal 🟦. Examine the config file.

    ``` bash
    <copy>
    cd
    clear
    cat scripts/pt-04-simple-patching-existing-home.cfg
    </copy>

    # Be sure to press RETURN
    ```

    * `source_home` and `sid` describe the current database.
    * `target_home` is the location of the new Oracle home. It has already been created.
    * Also, you specify which database to patch using `sid`.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    global.global_log_dir=/home/oracle/logs/simple-patching-existing-home
    patch1.source_home=/u01/app/oracle/product/19
    patch1.target_home=/u01/app/oracle/product/dbhome_19_32
    patch1.sid=UPGR
    ```

    </details>

2. Analyze the database.

    ``` bash
    <copy>
    java -jar autoupgrade.jar -config scripts/pt-04-simple-patching-existing-home.cfg -mode analyze
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    Processing config file ...
    +-----------------------------------------+
    | Starting AutoUpgrade Patching execution |
    +-----------------------------------------+
    1 Non-CDB(s) will be analyzed
    Type 'help' to list console commands
    patch>
    ```

    </details>

3. You are now in the AutoUpgrade console. Monitor the progress.

    ``` bash
    <copy>
    lsj -a 10
    </copy>
    ```

    * The `lsj` command lists active jobs.
    * The `-a 10` parameter refreshes the information every 10 seconds.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    patch> lsj -a 10
    patch> +----+-------+---------+---------+-------+----------+-------+----------------+
    |Job#|DB_NAME|    STAGE|OPERATION| STATUS|START_TIME|UPDATED|         MESSAGE|
    +----+-------+---------+---------+-------+----------+-------+----------------+
    | 100|   UPGR|PRECHECKS|EXECUTING|RUNNING|  07:43:51|37s ago|Executing Checks|
    +----+-------+---------+---------+-------+----------+-------+----------------+
    Total jobs 1

    The command lsj is running every 10 seconds. PRESS ENTER TO EXIT
    ```

    </details>

4. Wait a minute or two until AutoUpgrade completes. Don't exit from the AutoUpgrade console.

5. When the job completes, AutoUpgrade prints the location of the *summary report*, which contains information about the analysis. Check the summary report.

    ``` bash
    <copy>
    cat /home/oracle/logs/simple-patching-existing-home/cfgtoollogs/upgrade/auto/status/status.log
    </copy>
    ```

    * You can see that you're patching the *UPGR* database.
    * You can also see that you're patching from 19.31 to 19.32.
    * In the end, you can see that *Check passed and no manual intervention needed*.
    * This database was found to be ready for patching.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    ==========================================
              Autoupgrade Summary Report
    ==========================================
    [Date]           Wed Sep 02 04:39:33 GMT 2026
    [Number of Jobs] 1
    ==========================================
    [Job ID] 100
    ==========================================
    [DB Name]                upgr
    [Version Before Upgrade] 19.31.0.0.0
    [Version After Upgrade]  19.32.0.0.0
    ------------------------------------------
    [Stage Name]    PRECHECKS
    [Status]        SUCCESS
    [Start Time]    2026-09-02 04:39:05
    [Duration]      0:00:28
    [Log Directory] /home/oracle/logs/simple-patching-existing-home/UPGR/100/prechecks
    [Detail]        /home/oracle/logs/simple-patching-existing-home/UPGR/100/prechecks/upgr_preupgrade.log
                    Check passed and no manual intervention needed
    ------------------------------------------
    ```

    </details>

6. You can find more details in the precheck reports. You can find them in the *Log Directory* listed in the summary report. Examine the precheck directory.

    ``` bash
    <copy>
    cd /home/oracle/logs/simple-patching-existing-home/UPGR/100/prechecks
    ll
    </copy>

    # Be sure to press RETURN
    ```

    * The detailed precheck report is available in HTML and text formats for easy reading.
    * It is also available as XML or JSON files, which are useful for scripting and automation.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    total 224
    -rw-r-----. 1 oracle oinstall 149332 Sep  2 04:39 prechecks_upgr.log
    -rw-r-----. 1 oracle oinstall  16425 Sep  2 04:39 upgrade.xml
    -rw-r-----. 1 oracle oinstall   2379 Sep  2 04:39 upgr_checklist.cfg
    -rw-r-----. 1 oracle oinstall   6953 Sep  2 04:39 upgr_checklist.json
    -rw-r-----. 1 oracle oinstall   6573 Sep  2 04:39 upgr_checklist.xml
    -rw-r-----. 1 oracle oinstall  23951 Sep  2 04:39 upgr_preupgrade.html
    -rw-r-----. 1 oracle oinstall  11468 Sep  2 04:39 upgr_preupgrade.log
    ```

    </details>

7. Examine the text version.

    ``` bash
    <copy>
    more upgr_preupgrade.log
    </copy>
    ```

    * Scroll through the report using the *space bar*.
    * You can exit the report by pressing the *Q* key.
    * The report starts with details about the database.
    * Next it divides the findings into *BEFORE UPGRADE* and *AFTER UPGRADE* findings.
    * The findings are grouped by severity.
    * Notice that many findings have *FixUp Available YES*. These findings are handled by AutoUpgrade.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    Upgrade-To version: 19.0.0.0.0

    =======================================
    Status of the database prior to upgrade
    =======================================
          Database Name:  UPGR
         Container Name:  UPGR
           Container ID:  0
                Version:  19.31.0.0.0
         DB Patch Level:  UNKNOWN
             Compatible:  19.0.0
              Blocksize:  8192
               Platform:  Linux x86 64-bit
          Timezone File:  44
      Database log mode:  ARCHIVELOG
               Readonly:  false
                Edition:  EE

      Oracle Component                       Upgrade Action    Current Status
      ----------------                       --------------    --------------
      None

      *
      * ALL Components in This Database Registry:
      *
      Component   Current      Current      Original     Previous     Component
      CID         Version      Status       Version      Version      Schema
      ----------  -----------  -----------  -----------  -----------  ------------
      CATALOG     19.31.0.0.0  VALID        19.29.0.0.0               SYS
      CATPROC     19.31.0.0.0  VALID        19.29.0.0.0               SYS
      OWM         19.31.0.0.0  VALID        19.29.0.0.0               WMSYS
      RAC         19.31.0.0.0  OPTION OFF   19.29.0.0.0               SYS
      XDB         19.31.0.0.0  VALID        19.29.0.0.0               XDB

    ==============
    BEFORE UPGRADE
    ==============

    (output truncated)
    ```

8. Examine the HTML version

    </details>

    ``` bash
    <copy>
    firefox upgr_preupgrade.html &
    </copy>
    ```

    * The HTML report is much easier to read.
    * However, it requires a desktop environment which is not always present on database servers.

9. Close Firefox.

## Task 2: Patch Database

Patching a single instance Oracle AI Database requires downtime. Downtime starts now.

1. Remain in the *blue* terminal 🟦.

2. Start patching the database.

    ``` bash
    <copy>
    cd
    java -jar autoupgrade.jar -config scripts/pt-04-simple-patching-existing-home.cfg -mode deploy
    </copy>

    # Be sure to press RETURN
    ```

    * Deploy mode is the complete automation which performs all parts of a patch process.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    Processing config file ...
    +--------------------------------+
    | Starting AutoUpgrade execution |
    +--------------------------------+
    1 Non-CDB(s) will be processed
    Type 'help' to list console commands
    upg>
    ```

    </details>

3. Monitor the progress.

    ``` bash
    <copy>
    lsj
    </copy>
    ```

    * The `lsj` command lists active jobs.
    * There is only one job in this configuration file.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    +----+-------+---------+---------+-------+----------+-------+-------------------+
    |Job#|DB_NAME|    STAGE|OPERATION| STATUS|START_TIME|UPDATED|            MESSAGE|
    +----+-------+---------+---------+-------+----------+-------+-------------------+
    | 101|   UPGR|PREFIXUPS|EXECUTING|RUNNING|  05:01:11| 1s ago|Re-Executing Checks|
    +----+-------+---------+---------+-------+----------+-------+-------------------+
    Total jobs 1
    Total jobs 1
    ```

    </details>

4. Get the status of the job.

    ``` bash
    <copy>
    status -job 101 -a 10
    </copy>
    ```

    * The `status` command requires the job number as input. You can find it in the list of active jobs.
    * The `-a 10` parameter refreshes the information every 10 seconds.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    Details

        Job No           101
        Oracle SID       UPGR
        Start Time       26/09/02 05:01:11
        Elapsed (min):   3
        End time:        N/A

    Logfiles

        Logs Base:    /home/oracle/logs/simple-patching-existing-home/UPGR
        Job logs:     /home/oracle/logs/simple-patching-existing-home/UPGR/101
        Stage logs:   /home/oracle/logs/simple-patching-existing-home/UPGR/101/postfixups
        TimeZone:     /home/oracle/logs/simple-patching-existing-home/UPGR/temp
        Remote Dirs:

    Stages
        SETUP            <1 min
        PREUPGRADE       <1 min
        PRECHECKS        <1 min
        PREFIXUPS        <1 min
        DRAIN            <1 min
        DBUPGRADE        2 min
        DISPATCH         <1 min
        POSTCHECKS       <1 min
        DISPATCH         <1 min
        POSTFIXUPS       ~0 min (RUNNING)
        POSTUPGRADE
        SYSUPDATES

    Stage-Progress Per Container

        +--------+----------+
        |Database|POSTFIXUPS|
        +--------+----------+
        |    UPGR|     33 % |
        +--------+----------+

    The command status is running every 10 seconds. PRESS ENTER TO EXIT
    ```

    </details>

5. It takes just a few minutes to patch the database. Leave AutoUpgrade running.

6. When patching completes, AutoUpgrade exits.

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
    /home/oracle/logs/simple-patching-existing-home/cfgtoollogs/upgrade/auto/status/status.html
    /home/oracle/logs/simple-patching-existing-home/cfgtoollogs/upgrade/auto/status/status.log
    ```

    </details>

## Task 3: Check the Outcome

When AutoUpgrade completes patching, you can start using the database. You may have custom post-patching tasks.

1. Update the profile script. This lab has a profile script for each database that configures the environment accordingly. Since the database now runs out of a new Oracle home, you must update the profile script. This command replaces the `ORACLE_HOME` variable in the profile script.

    ``` bash
    <copy>
    sed -i 's|^ORACLE_HOME=.*|ORACLE_HOME=/u01/app/oracle/product/dbhome_19_32|' /usr/local/bin/upgr
    </copy>
    ```

2. Verify the `oratab` file.

    ``` bash
    <copy>
    cat /etc/oratab | grep UPGR
    </copy>
    ```

    * AutoUpgrade updated the file, so *UPGR* now uses the new Oracle home.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    UPGR:/u01/app/oracle/product/dbhome_19_32:Y
    ```

    </details>

3. AutoUpgrade also moves all the database configuration files to the new Oracle home. Set the environment and check the files.

    ``` bash
    <copy>
    . upgr
    cd $ORACLE_HOME/dbs
    pwd
    ll
    </copy>

    # Be sure to press RETURN
    ```

    * You are now in the *dbs* directory of the new Oracle home.
    * You can find the SPFile and password file belonging to *UPGR*.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    total 20
    -rw-rw----. 1 oracle oinstall 1544 Sep  2 05:02 hc_UPGR.dat
    -rw-r--r--. 1 oracle oinstall 3079 May 14  2015 init.ora
    -rw-r-----. 1 oracle oinstall   24 Sep  2 05:02 lkUPGR
    -rw-r-----. 1 oracle oinstall 2048 Sep  1 13:11 orapwUPGR
    -rw-r-----. 1 oracle oinstall 3584 Sep  2 05:08 spfileUPGR.ora
    ```

    </details>

4. AutoUpgrade also executes Datapatch. Find the Datapatch log files.

    ``` bash
    <copy>
    cd /home/oracle/logs/simple-patching-existing-home/UPGR/101/dbupgrade
    ll
    </copy>

    # Be sure to press RETURN
    ```

    * AutoUpgrade stores the Datapatch log files in the job logs directory in a subdirectory named `dbupgrade`.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    total 89144
    -rw-r-----. 1 oracle oinstall     3697 Sep  2 05:04 applyautoupgrade20260902050111upgr.log
    -rw-r-----. 1 oracle oinstall 12495073 Sep  2 05:04 applydatapatchlogfiles20260902050111upgr.log
    -rw-r-----. 1 oracle oinstall      133 Sep  2 05:04 applydatapatchprogress20260902050111upgr.json
    -rw-r-----. 1 oracle oinstall     9296 Sep  2 05:04 applydatapatchsummary20260902050111upgr.json
    -rw-r-----. 1 oracle oinstall 22713858 Sep  2 05:02 applyinventory.xml
    -rw-r-----. 1 oracle oinstall      838 Sep  2 05:02 applyopatchdatapatch.log
    -rw-r-----. 1 oracle oinstall     1058 Sep  2 05:03 applypreqdatapatch.log
    -rw-r-----. 1 oracle oinstall      133 Sep  2 05:03 applypreqdatapatchprogress.json
    -rw-r-----. 1 oracle oinstall     3219 Sep  2 05:03 applypreqdatapatchsummary.json
    -rw-r-----. 1 oracle oinstall     1573 Sep  2 05:04 applysqlpatch_catcon_0.log
    -rw-r-----. 1 oracle oinstall 53092649 Sep  2 05:04 applysqlpatch_debug.log
    -rw-r-----. 1 oracle oinstall  2921038 Sep  2 05:04 applysqlpatch_invocation.log
    -rw-r-----. 1 oracle oinstall        0 Sep  2 05:04 applyupgr.success
    -rw-r-----. 1 oracle oinstall     1963 Sep  2 05:04 datapatch_summary.log
    -rw-r-----. 1 oracle oinstall     3761 Sep  2 05:02 during_upgrade_pfile_catctl.ora
    ```

    </details>

5. Examine one of the Datapatch log files.

    ``` bash
    <copy>
    cat applyautoupgrade*upgr.log
    </copy>
    ```

    * This is the Datapatch output you would see if you patched the database manually.
    * AutoUpgrade stores all output and log files in the logging directory.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL Patching tool version 19.32.0.0.0 Production on Wed Sep  2 05:03:30 2026
    Copyright (c) 2012, 2026, Oracle.  All rights reserved.

    Log file for this invocation: /u01/app/oracle/cfgtoollogs/sqlpatch/sqlpatch_88330_2026_09_02_05_03_30/sqlpatch_invocation.log

    Connecting to database...OK
    Gathering database info...done
    Bootstrapping registry and package to current versions...done
    Determining current state...done

    Current state of interim SQL patches:
    Interim patch 38194382 (OJVM RELEASE UPDATE: 19.29.0.0.251021 (38194382)):
      Binary registry: Not installed
      SQL registry: Rolled back successfully on 01-SEP-26 01.24.58.500208 PM
    Interim patch 38523609 (OJVM RELEASE UPDATE: 19.30.0.0.260120 (38523609)):
      Binary registry: Not installed
      SQL registry: Rolled back successfully on 01-SEP-26 01.38.18.880352 PM
    Interim patch 38535360 (DATAPUMP BUNDLE PATCH 19.29.0.0.0):
      Binary registry: Not installed
      SQL registry: Rolled back successfully on 01-SEP-26 01.24.58.806838 PM
    Interim patch 38844367 (19.30 OJVM PATCH APPLY IS FAILING ON SECOND NODE IN RAC ENVIRONMENT):
      Binary registry: Not installed
      SQL registry: Rolled back successfully on 01-SEP-26 01.38.18.956087 PM
    Interim patch 38844733 (DATAPUMP BUNDLE PATCH 19.30.0.0.0):
      Binary registry: Not installed
      SQL registry: Rolled back successfully on 01-SEP-26 01.38.19.471926 PM
    Interim patch 38906621 (OJVM RELEASE UPDATE: 19.31.0.0.260421 (38906621)):
      Binary registry: Not installed
      SQL registry: Applied successfully on 01-SEP-26 01.38.18.940987 PM
    Interim patch 39196236 (DATAPUMP BUNDLE PATCH 19.31.0.0.0):
      Binary registry: Not installed
      SQL registry: Applied successfully on 01-SEP-26 01.38.53.761709 PM
    Interim patch 39222882 (OJVM RELEASE UPDATE: 19.32.0.0.260721 (39222882)):
      Binary registry: Installed
      SQL registry: Not installed
    Interim patch 39657094 (DATAPUMP BUNDLE PATCH 19.32.0.0.0):
      Binary registry: Installed
      SQL registry: Not installed

    Current state of release update SQL patches:
      Binary registry:
        19.32.0.0.0 Release_Update 260705220710: Installed
      SQL registry:
        Applied 19.31.0.0.0 Release_Update 260514003012 successfully on 01-SEP-26 01.38.30.009869 PM

    Adding patches to installation queue and performing prereq checks...done
    Installation queue:
      The following interim patches will be rolled back:
        38906621 (OJVM RELEASE UPDATE: 19.31.0.0.260421 (38906621))
        39196236 (DATAPUMP BUNDLE PATCH 19.31.0.0.0)
      Patch 39472050 (Database Release Update : 19.32.0.0.260721 (39472050)):
        Apply from 19.31.0.0.0 Release_Update 260514003012 to 19.32.0.0.0 Release_Update 260705220710
      The following interim patches will be applied:
        39222882 (OJVM RELEASE UPDATE: 19.32.0.0.260721 (39222882))
        39657094 (DATAPUMP BUNDLE PATCH 19.32.0.0.0)

    Installing patches...
    Patch installation complete.  Total patches installed: 5

    Validating logfiles...done
    Patch 38906621 rollback: SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/38906621/28588735/38906621_rollback_UPGR_2026Sep02_05_03_36.log (no errors)
    Patch 39196236 rollback: SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/39196236/28705537/39196236_rollback_UPGR_2026Sep02_05_03_36.log (no errors)
    Patch 39472050 apply: SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/39472050/28919163/39472050_apply_UPGR_2026Sep02_05_03_37.log (no errors)
    Patch 39222882 apply: SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/39222882/28830205/39222882_apply_UPGR_2026Sep02_05_03_36.log (no errors)
    Patch 39657094 apply: SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/39657094/28915841/39657094_apply_UPGR_2026Sep02_05_04_01.log (no errors)
    SQL Patching tool complete on Wed Sep  2 05:04:30 2026
    ```

    </details>

6. You have patched your Oracle AI Database.

You may now [*proceed to the next lab*](#next).

## Acknowledgements

* **Author** - Daniel Overby Hansen
* **Contributors** - Rodrigo Jorge, Alex Zaballa, Mike Dietrich, Alejandro Diaz
* **Last Updated By/Date** - Daniel Overby Hansen, September 2026
