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

- You have completed Lab 1: Initialize Environment

## Task 1: Analyze database

Oracle recommends that you first check your database. AutoUpgrade in *analyze* mode is a lightweight and non-intrusive check of an Oracle Database.

1. Use the *yellow* terminal 🟨. AutoUpgrade requires a *config* file with information about the database that you want to patch. In this lab, you use a pre-created config file. Examine the config file.

    ```
    <copy>
    cd
    cat scripts/simple-patching.cfg
    </copy>

    -- Be sure to hit RETURN
    ```

    * `source_home` and `sid` describe the current database.
    * `target_home` is the location of the new Oracle home. It doesn't exist yet. AutoUpgrade creates it for you.
    * `folder` is the location where AutoUpgrade can find and store patch files. Ideally, this location is a network share accessible to all your database hosts. 
    * `patch` informs AutoUpgrade which patches you want to apply. `RECOMMENDED` means the recent-most OPatch and Release Update plus matching OJVM and Data Pump bundle patches.
    * `download` tells whether AutoUpgrade should attempt to download the patches from My Oracle Support using your My Oracle Support credentials. This is not possible inside this lab environment, so all patches have been pre-downloaded.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ cat scripts/simple-patching.cfg
    global.global_log_dir=/home/oracle/autoupgrade-patching/simple-patching/log
    patch1.source_home=/u01/app/oracle/product/19
    patch1.target_home=/u01/app/oracle/product/19_25
    patch1.sid=FTEX
    patch1.folder=/home/oracle/patch-repo
    patch1.patch=RECOMMENDED
    patch1.download=no
    ```
    </details>    

2. Analyze the database.

    ```
    <copy>
    java -jar autoupgrade.jar -config scripts/simple-patching.cfg -patch -mode analyze
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ java -jar autoupgrade.jar -config scripts/simple-patching.cfg -patch -mode analyze
    AutoUpgrade Patching 24.8.241119 launched with default internal options
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

    ```
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

    ```
    <copy>
    cat /home/oracle/autoupgrade-patching/simple-patching/log/cfgtoollogs/patch/auto/status/status.log
    </copy>
    ```

    * You can see that you're patching the *FTEX* database. 
    * You can also see that you're patching from 19.21 to 19.25.
    * In the end, you can see that all checks passed and there's no manual intervention needed.
    * This database was found to be ready for patching. 

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ cat /home/oracle/autoupgrade-patching/simple-patching/log/cfgtoollogs/patch/auto/status/status.log
    ==========================================
       AutoUpgrade Patching Summary Report
    ==========================================
    [Date]           Mon Nov 04 07:45:55 GMT 2024
    [Number of Jobs] 1
    ==========================================
    [Job ID] 100
    ==========================================
    [DB Name]                ftex
    [Version Before AutoUpgrade Patching] 19.21.0.0.0
    [Version After AutoUpgrade Patching]  19.25.0.0.241015
    ------------------------------------------
    [Stage Name]    PENDING
    [Status]        SUCCESS
    [Start Time]    2024-11-04 07:43:51
    [Duration]      0:00:00
    [Log Directory] /home/oracle/autoupgrade-patching/simple-patching/log/FTEX/100/pending
    ------------------------------------------
    [Stage Name]    PRECHECKS
    [Status]        SUCCESS
    [Start Time]    2024-11-04 07:43:51
    [Duration]      0:02:03
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

    ```
    <copy>
    java -jar autoupgrade.jar -config scripts/simple-patching.cfg -patch -mode deploy
    </copy>
    ```

    * You're reusing the same command line as the analysis, however, this time you are activating deploy mode.
    * Deploy mode is the complete automation which performs all parts of a patch process. 

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ java -jar autoupgrade.jar -config scripts/simple-patching.cfg -patch -mode deploy
    AutoUpgrade Patching 24.8.241119 launched with default internal options
    Processing config file ...
    +-----------------------------------------+
    | Starting AutoUpgrade Patching execution |
    +-----------------------------------------+
    1 Non-CDB(s) will be analyzed
    Type 'help' to list console commands
    patch>
    ```
    </details>    

3. Again, you're in the AutoUpgrade console. Monitor the progress.

    ```
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

4. Hit *Enter* to stop the automatic refresh. Let's get more information about the process. 

    ```
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

5. In the output of the `status` command, you can see where AutoUpgrade stores log files. Examine the log files.

6. Leave AutoUpgrade running. Switch to the *blue* 🟦 terminal. Examine the job logging directory.

    ```
    <copy>
    cd /home/oracle/autoupgrade-patching/simple-patching/log/FTEX/101
    ll
    </copy>

    -- Be sure to hit RETURN
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

7. Check the the *user* log file.

    ```
    <copy>
    cat autoupgrade_patching_*_user.log
    </copy>
    ```

    * The output is different in your lab environment.
    * Examine the content to understand that AutoUpgrade is doing behind the scenes.
    * AutoUpgrade prints the patches that it will install. In this case, it is the 19.25 Relese Update plus matching OJVM and Data Pump bundle patches. In addition, it also updated OPatch.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ cat autoupgrade_patching_*_user.log
    2024-11-04 10:10:12.278 INFO
    build.MOS_LINK:https://support.oracle.com/epmos/faces/DocumentDisplay?id=2485457.1
    build.MOS_NOTE:2485457.1
    build.date:2024/10/21 11:16:05 -0400
    build.hash:babf5a631
    build.hash_date:2024/10/18 18:36:27 -0400
    build.label:(HEAD, tag: v24.7, origin/stable_devel, stable_devel)
    build.max_target_version:19
    build.supported_target_versions:19
    build.type:production
    build.version:24.7.241021
    
    2024-11-04 10:10:12.279 INFO The following patches will be used for this job:
    /home/oracle/patch-repo/LINUX.X64_193000_db_home.zip - Base Image - 19
    /home/oracle/patch-repo/p36912597_190000_Linux-x86-64.zip - Database Release Update : 19.25.0.0.241015 (36912597)
    /home/oracle/patch-repo/p37056207_1925000DBRU_Generic.zip - DATAPUMP BUNDLE PATCH 19.25.0.0.0
    /home/oracle/patch-repo/p36878697_190000_Linux-x86-64.zip - OJVM RELEASE UPDATE: 19.25.0.0.241015 (36878697)
    /home/oracle/patch-repo/p6880880_190000_Linux-x86-64.zip - OPatch - 12.2.0.1.44
    2024-11-04 10:10:12.755 INFO Guarantee Restore Point (GRP) successfully removed [FTEX][AU_PATCHING_9212_FTEX1921000]
    2024-11-04 10:10:13.787 INFO Guarantee Restore Point (GRP) successfully created [FTEX][AU_PATCHING_9212_FTEX1921000]
    2024-11-04 10:10:13.851 INFO No user defined actions were specified
    2024-11-04 10:10:19.092 INFO Analyzing FTEX, 61 checks will run using 8 threads
    2024-11-04 10:12:27.560 INFO Analyzing FTEX, 61 checks will run using 8 threads
    2024-11-04 10:14:30.061 INFO The file /home/oracle/patch-repo/LINUX.X64_193000_db_home.zip is being extracted to /u01/app/oracle/product/19_25
    2024-11-04 10:15:19.918 INFO Successfully extracted the gold image to /u01/app/oracle/product/19_25
    2024-11-04 10:15:20.269 INFO Waiting to acquire lock
    2024-11-04 10:15:20.281 INFO Installing ORACLE_HOME
    2024-11-04 10:15:20.283 INFO The new ORACLE_HOME will be created in /u01/app/oracle/product/19_25 and will have the following edition: Enterprise Edition
    2024-11-04 10:15:20.284 INFO Running runInstaller in the target ORACLE_HOME /u01/app/oracle/product/19_25
    2024-11-04 10:16:20.344 INFO Successfully installed the target ORACLE_HOME /u01/app/oracle/product/19_25
    2024-11-04 10:16:20.407 INFO AutoUpgrade Patching has not run /u01/app/oracle/product/19_25/root.sh for the newly installed ORACLE_HOME. This needs to be performed manually after     AutoUpgrade Patching completes.
    2024-11-04 10:16:20.483 INFO The file /home/oracle/patch-repo/p6880880_190000_Linux-x86-64.zip is being extracted to /u01/app/oracle/product/19_25
    2024-11-04 10:16:22.971 INFO The existing autoupgrade.jar is not going to be updated within the new ORACLE_HOME
    2024-11-04 10:16:23.048 INFO Waiting to acquire lock
    2024-11-04 10:16:23.059 INFO Executing OPatch
    2024-11-04 10:16:23.070 INFO Installing Database Release Update : 19.25.0.0.241015 (36912597) - /home/oracle/patch-repo/p36912597_190000_Linux-x86-64.zip
    ```
    </details> 

8. Spend some time examining the other log files and subdirectories.

9. Switch back to the *yellow* terminal 🟨. It takes around 20 minutes to patch the database. If AutoUpgrade is still running, you either wait or you can perform lab 3, *Familiarize with patching*. 

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

    ```
    <copy>
    sed -i 's/^ORACLE_HOME=.*/ORACLE_HOME=\/u01\/app\/oracle\/product\/19_25/' /usr/local/bin/ftex
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

You may now *proceed to the next lab*.

## Learn More

AutoUpgrade can also connect to My Oracle Support and find and download the necessary patches. Learn more in the below webinar:

* Webinar, [One-Button Patching – makes life easier for every Oracle DBA](https://youtu.be/brnBavVLyM0)

## Acknowledgements

* **Author** - Daniel Overby Hansen
* **Contributors** - Rodrigo Jorge, Mike Dietrich
* **Last Updated By/Date** - Daniel Overby Hansen, January 2025