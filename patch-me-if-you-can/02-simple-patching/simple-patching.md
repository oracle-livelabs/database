# Simple Patching With AutoUpgrade

## Introduction

In this lab, you will patch an Oracle Database in the most simple way using AutoUpgrade. AutoUpgrade not only patches the database but also downloads the right patches and builds a new Oracle home. This allows you to apply patches using the *out-of-place* method according to our best practices.

In the lab environment there is no connection to download patches from My Oracle Support, so all patches are already downloaded.

Estimated Time: 30 Minutes

### Objectives

In this lab, you will:

* Assess the patch readiness of a database
* Patch a database

### Prerequisites

This lab assumes:

* You have completed Lab 1: Initialize Environment

## Task 1: Analyze database

Oracle recommends that you first check your database. AutoUpgrade in *analyze* mode is a lightweight and non-intrusive check of an Oracle Database.

1. Use the *yellow* terminal 🟨. AutoUpgrade requires a *config* file with information about the database that you want to patch. In this lab, you use a pre-created config file. Examine the config file.

    ``` bash
    <copy>
    cd
    cat scripts/pt-02-simple-patching.cfg
    </copy>

    # Be sure to hit RETURN
    ```

    * `source_home` and `sid` describe the current database.
    * `target_home` is the location of the new Oracle home. It doesn't exist yet. AutoUpgrade creates it for you. AutoUpgrade uses the settings from the source Oracle home to create the new one.
    * `folder` is the location where AutoUpgrade can find and store patch files. Ideally, this location is a network share accessible to all your database hosts.
    * `patch` informs AutoUpgrade which patches you want to apply. `RECOMMENDED` means the recent-most OPatch and Release Update plus matching OJVM and Data Pump bundle patches. In addition, you're adding a one-off patch.
    * `download` tells whether AutoUpgrade should attempt to download the patches from My Oracle Support using your My Oracle Support credentials. This is not possible inside this lab environment, so all patches have been pre-downloaded.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    $ cat scripts/pt-02-simple-patching.cfg
    global.global_log_dir=/home/oracle/autoupgrade-patching/simple-patching/log
    patch1.source_home=/u01/app/oracle/product/19
    patch1.target_home=/u01/app/oracle/product/19_28
    patch1.sid=FTEX
    patch1.folder=/home/oracle/patch-repo
    patch1.patch=RECOMMENDED,37738908
    patch1.download=no
    ```

    </details>

2. Analyze the database.

    ``` bash
    <copy>
    java -jar autoupgrade.jar -config scripts/pt-02-simple-patching.cfg -patch -mode analyze
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    $ java -jar autoupgrade.jar -config scripts/pt-02-simple-patching.cfg -patch -mode analyze
    AutoUpgrade Patching 25.4.250730 launched with default internal options
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
    | 100|   FTEX|PRECHECKS|EXECUTING|RUNNING|  07:43:51|37s ago|Executing Checks|
    +----+-------+---------+---------+-------+----------+-------+----------------+
    Total jobs 1

    The command lsj is running every 10 seconds. PRESS ENTER TO EXIT
    ```

    </details>

4. Wait a minute or two until AutoUpgrade completes. Don't exit from the AutoUpgrade console.

5. When the job completes, AutoUpgrade prints the location of the *summary report* which contains detailed information about the analysis. Check the summary report.

    ``` bash
    <copy>
    cat /home/oracle/autoupgrade-patching/simple-patching/log/cfgtoollogs/patch/auto/status/status.log
    </copy>
    ```

    * You can see that you're patching the *FTEX* database.
    * You can also see that you're patching from 19.27 to 19.28.
    * In this lab, you can only use already downloaded patches. When this lab was created, 19.28 was the latest Release Update. 
    * In your own environment, when AutoUpgrade downloads patches, it will always take the latest available Release Upgrade from MOS when you specify *patch=recommended*. 
    * In the end, you can see that all checks passed and there's no manual intervention needed.
    * This database was found to be ready for patching.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    $ cat /home/oracle/autoupgrade-patching/simple-patching/log/cfgtoollogs/patch/auto/status/status.log
    ==========================================
       AutoUpgrade Patching Summary Report
    ==========================================
    [Date]           Sat Jul 26 05:49:47 GMT 2025
    [Number of Jobs] 1
    ==========================================
    [Job ID] 100
    ==========================================
    [DB Name]                ftex
    [Version Before AutoUpgrade Patching] 19.27.0.0.0
    [Version After AutoUpgrade Patching]  19.28.0.0.250715
    ------------------------------------------
    [Stage Name]    PENDING
    [Status]        SUCCESS
    [Start Time]    2025-07-26 05:47:39
    [Duration]      0:00:00
    [Log Directory] /home/oracle/autoupgrade-patching/simple-patching/log/FTEX/100/pending
    ------------------------------------------
    [Stage Name]    PRECHECKS
    [Status]        SUCCESS
    [Start Time]    2025-07-26 05:47:39
    [Duration]      0:02:08
    [Log Directory] /home/oracle/autoupgrade-patching/simple-patching/log/FTEX/100/prechecks
    [Detail]        /home/oracle/autoupgrade-patching/simple-patching/log/FTEX/100/prechecks/ftex_preupgrade.log
                    Check passed and no manual intervention needed
    ------------------------------------------
    ```

    </details>

## Task 2: Patch database

Patching a single instance Oracle Database require downtime.

**Downtime starts now.**

1. Start patching the database.

    ``` bash
    <copy>
    java -jar autoupgrade.jar -config scripts/pt-02-simple-patching.cfg -patch -mode deploy
    </copy>
    ```

    * You're reusing the same command line as the analysis, however, this time you are activating deploy mode.
    * Deploy mode is the complete automation which performs all parts of a patch process.
    * Since AutoUpgrade is in *patching* mode, the prompt is `patch>`. 

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    $ java -jar autoupgrade.jar -config scripts/pt-02-simple-patching.cfg -patch -mode deploy
    AutoUpgrade Patching 25.4.250730 launched with default internal options
    Processing config file ...
    +-----------------------------------------+
    | Starting AutoUpgrade Patching execution |
    +-----------------------------------------+
    1 Non-CDB(s) will be analyzed
    Type 'help' to list console commands
    patch>
    ```

    </details>

2. Again, you're in the AutoUpgrade console. Monitor the progress.

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
    lsj -a 10
    patch> +----+-------+---------+---------+-------+----------+-------+----------------+
    |Job#|DB_NAME|    STAGE|OPERATION| STATUS|START_TIME|UPDATED|         MESSAGE|
    +----+-------+---------+---------+-------+----------+-------+----------------+
    | 101|   FTEX|PRECHECKS|EXECUTING|RUNNING|  10:10:12|12s ago|Executing Checks|
    +----+-------+---------+---------+-------+----------+-------+----------------+
    Total jobs 1

    The command lsj is running every 10 seconds. PRESS ENTER TO EXIT
    ```

    </details>

3. Hit *Enter* to stop the automatic refresh. Let's get more information about the process.

    ``` bash
    <copy>
    status -job 101 -a 10
    </copy>
    ```

    * The `status` command gives much more details.
    * It requires the *jobid* which you can find in the output of `lsj`.
    * Take a look at the different stages that the job will go through.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    Details

    	Job No           101
    	Oracle SID       FTEX
    	Start Time       24/11/04 10:10:12
    	Elapsed (min):   3
    	End time:        N/A

    Logfiles

    	Logs Base:    /home/oracle/autoupgrade-patching/simple-patching/log/FTEX
    	Job logs:     /home/oracle/autoupgrade-patching/simple-patching/log/FTEX/101
    	Stage logs:   /home/oracle/autoupgrade-patching/simple-patching/log/FTEX/101/prefixups
    	TimeZone:     /home/oracle/autoupgrade-patching/simple-patching/log/FTEX/temp
    	Remote Dirs:

    Stages
    	PENDING          <1 min
    	GRP              <1 min
    	PREACTIONS       <1 min
    	PRECHECKS        2 min
    	PREFIXUPS        ~1 min (RUNNING)
    	EXTRACT
    	INSTALL
    	ROOTSH
    	DBTOOLS
    	OPATCH
    	AUTOUPGRADE
    	POSTCHECKS
    	POSTFIXUPS
    	POSTACTIONS

    Stage-Progress Per Container

    	+--------+---------+
    	|Database|PREFIXUPS|
    	+--------+---------+
    	|    ftex|    0  % |
    	+--------+---------+

    The command status is running every 10 seconds. PRESS ENTER TO EXIT
    ```

    </details>

4. In the output of the `status` command, you can see where AutoUpgrade stores log files. Examine the log files.

5. Leave AutoUpgrade running. Switch to the *blue* terminal 🟦. Examine the job logging directory.

    ``` bash
    <copy>
    cd /home/oracle/autoupgrade-patching/simple-patching/log/FTEX/101
    ll
    </copy>

    # Be sure to hit RETURN
    ```

    * The output in your lab varies from the sample output.
    * Notice how each stage has a subdirectory

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    $ cd /home/oracle/autoupgrade-patching/simple-patching/log/FTEX/101
    $ ll
    total 36
    -rw-r-----. 1 oracle oinstall 22287 Nov  4 10:16 autoupgrade_patching_20241104.log
    -rw-r-----. 1 oracle oinstall     0 Nov  4 10:10 autoupgrade_patching_20241104.log.lck
    -rw-r-----. 1 oracle oinstall  2880 Nov  4 10:16 autoupgrade_patching_20241104_user.log
    -rw-r-----. 1 oracle oinstall     0 Nov  4 10:10 autoupgrade_patching_20241104_user.log.lck
    -rw-r-----. 1 oracle oinstall     0 Nov  4 10:10 autoupgrade_patching_err.log
    -rw-r-----. 1 oracle oinstall     0 Nov  4 10:10 autoupgrade_patching_err.log.lck
    drwxr-x---. 2 oracle oinstall    49 Nov  4 10:16 dbtools
    drwxr-x---. 2 oracle oinstall    52 Nov  4 10:15 extract
    drwxr-x---. 2 oracle oinstall    21 Nov  4 10:10 grp
    drwxr-x---. 2 oracle oinstall    96 Nov  4 10:16 install
    drwxr-x---. 2 oracle oinstall  4096 Nov  4 10:16 opatch
    drwxr-x---. 2 oracle oinstall    25 Nov  4 10:10 pending
    drwxr-x---. 2 oracle oinstall    28 Nov  4 10:10 preaction
    drwxr-x---. 4 oracle oinstall  4096 Nov  4 10:12 prechecks
    drwxr-x---. 2 oracle oinstall   155 Nov  4 10:14 prefixups
    drwxr-x---. 2 oracle oinstall    24 Nov  4 10:16 rootsh
    ```

    </details>

6. Check the the *user* log file.

    ``` bash
    <copy>
    cat autoupgrade_patching_*_user.log
    </copy>
    ```

    * The output is different in your lab environment.
    * Examine the content to understand that AutoUpgrade is doing behind the scenes.
    * AutoUpgrade prints the patches that it will install. In this case, it is the 19.28 Relese Update plus matching OJVM and Data Pump bundle patches. In addition, it also updated OPatch and installed a one-off patch.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    $ cat autoupgrade_patching_*_user.log
    2025-07-26 05:54:09.876 INFO
    build.MOS_LINK:https://support.oracle.com/epmos/faces/DocumentDisplay?id=2485457.1
    build.MOS_NOTE:2485457.1
    build.date 2025/07/30 16:33:06 +0000
    build.hash:d12ffb74e
    build.hash_date 2025/07/24 14:59:09 +0000
    build.label:(HEAD, tag: v25.4, origin/stable_devel, stable_devel)
    build.max_target_version:19
    build.supported_target_versions:19
    build.type:production
    build.version:25.4.250730

    2025-07-26 05:54:09.877 INFO The following patches will be used for this job:
    /home/oracle/patch-repo/LINUX.X64_193000_db_home.zip - Base Image - 19
    /home/oracle/patch-repo/p37960098_190000_Linux-x86-64_dbru1928.zip - Database Release Update : 19.28.0.0.250715 (37960098)
    /home/oracle/patch-repo/p38170982_1928000DBRU_Generic_dpbp1928.zip - DATAPUMP BUNDLE PATCH 19.28.0.0.0
    /home/oracle/patch-repo/p37847857_190000_Linux-x86-64_ojvm1928.zip - OJVM RELEASE UPDATE: 19.28.0.0.250715 (37847857)
    /home/oracle/patch-repo/p6880880_190000_Linux-x86-64.zip - OPatch - 12.2.0.1.47
    /home/oracle/patch-repo/p37738908_1928000DBRU_Generic.zip - SEPARATE PURGE_OLD_METADATA FROM PATCHING ACTIVITY IN DATAPATCH
    2025-07-26 05:54:10.386 INFO Guarantee Restore Point (GRP) successfully removed [FTEX][AU_PATCHING_9212_FTEX1927000]
    2025-07-26 05:54:11.468 INFO Guarantee Restore Point (GRP) successfully created [FTEX][AU_PATCHING_9212_FTEX1927000]
    2025-07-26 05:54:11.530 INFO No user defined actions were specified
    2025-07-26 05:54:16.467 INFO Analyzing FTEX, 60 checks will run using 8 threads
    ```

    </details>

7. Spend some time examining the other log files and subdirectories.

8. Switch back to the *yellow* terminal 🟨. **It takes around 20 minutes to patch the database**. If AutoUpgrade is still running, you either wait or you can perform lab 3, *Familiarize with patching*.

## Task 3: Patch database, continued

1. Use the *yellow* terminal 🟨. When AutoUpgrade completes, it prints a message to the console and exists.

    * AutoUpgrade informs that there is a guaranteed restore point which you must remove when it is no longer needed. Don't remove the restore point yet.
    * Optionally, you can instruct AutoUpgrade to remove the restore point automatically using `drop_grp_after_upgrade=yes` in the config file.

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
    Drop GRP from FTEX: drop restore point AU_PATCHING_9212_FTEX1921000


    Please check the summary report at:
    /home/oracle/autoupgrade-patching/simple-patching/log/cfgtoollogs/patch/auto/status/status.html
    /home/oracle/autoupgrade-patching/simple-patching/log/cfgtoollogs/patch/auto/status/status.log
    ```

    </details>

2. Update the profile script. Since the database now runs out of a new Oracle home, you must update the profile script. This command replaces the `ORACLE_HOME` variable in the profile script.

    ``` bash
    <copy>
    sed -i 's|^ORACLE_HOME=.*|ORACLE_HOME=/u01/app/oracle/product/19_28|' /usr/local/bin/ftex
    </copy>
    ```

3. That's it. You just patched your Oracle Database including:

    * Building a brand-new Oracle home enabling out-of-place patching
    * Updating OPatch
    * Installing Release Update and bundle patches
    * Required and recommended pre- and post-tasks
    * Copying database configuration files from old to new Oracle home
    * Restarting database in new Oracle home
    * Executing Datapatch

You may now [*proceed to the next lab*](#next).

## Learn More

AutoUpgrade can also connect to My Oracle Support and find and download the necessary patches. Learn more in the below webinar:

* Webinar, [One-Button Patching – makes life easier for every Oracle DBA](https://youtu.be/brnBavVLyM0)

## Acknowledgements

* **Author** - Daniel Overby Hansen
* **Contributors** - Rodrigo Jorge, Mike Dietrich
* **Last Updated By/Date** - Daniel Overby Hansen, August 2025
