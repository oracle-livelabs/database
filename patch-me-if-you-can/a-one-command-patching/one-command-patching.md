# Patch a Database in One Command

## Introduction

In this lab, you will patch an Oracle AI Database in the simplest way using AutoUpgrade. AutoUpgrade not only patches the database but also downloads the required patches and builds a new Oracle home. This allows you to apply patches using the *out-of-place* method according to our best practices.

Estimated Time: 30 Minutes

### Objectives

In this lab, you will:

* Assess the patch readiness of a database
* Install an Oracle home
* Patch a database

### Prerequisites

None.

## Task 1: Analyze Database

Oracle recommends that you first check your database. AutoUpgrade in *analyze* mode is a lightweight and non-intrusive check of an Oracle AI Database.

This lab uses the *BEIGE* non-CDB.

1. In this lab, you use a pre-created config file. Examine the config file.

    ``` bash
    <copy>
    cd
    cat scripts/pt-a-one-command-patching.cfg
    </copy>

    # Be sure to press RETURN
    ```

    * `source_home` and `sid` identify the current database.
    * `target_home` is the location of the new Oracle home. It does not exist yet. AutoUpgrade creates it for you. AutoUpgrade uses the settings from the source Oracle home to create the new one.
    * `download_folder` is the location where AutoUpgrade can find and store patch files. Ideally, this location is a network share accessible to all your database hosts.
    * `patch` informs AutoUpgrade which patches you want to apply. `RECOMMENDED` means the most recent OPatch and Release Update plus matching OJVM and Data Pump bundle patches.
    * `download` tells whether AutoUpgrade should attempt to download the patches from My Oracle Support using your My Oracle Support credentials. This is not possible in this lab environment, so all patches have been pre-downloaded.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    global.global_log_dir=/home/oracle/logs/one-command-patching
    patch1.source_home=/u01/app/oracle/product/19
    patch1.target_home=/u01/app/oracle/product/dbhome_19_32_lab_a
    patch1.sid=BEIGE
    patch1.download_folder=/home/oracle/patch-repo
    patch1.patch=RECOMMENDED
    patch1.download=no
    ```

    </details>

2. Ensure the target Oracle home does not exist yet.

    ``` bash
    <copy>
    ll /u01/app/oracle/product/dbhome_19_32_lab_a
    </copy>
    ```

    * AutoUpgrade creates the Oracle home later.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    ls: cannot access '/u01/app/oracle/product/dbhome_19_32_lab_a': No such file or directory
    ```

    </details>

3. Analyze the database.

    ``` bash
    <copy>
    java -jar autoupgrade.jar -config scripts/pt-a-one-command-patching.cfg -patch -mode analyze
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

4. You are now in the AutoUpgrade console. Monitor the progress.

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
    +----+-------+---------+---------+-------+----------+-------+----------------------------+
    |Job#|DB_NAME|    STAGE|OPERATION| STATUS|START_TIME|UPDATED|                     MESSAGE|
    +----+-------+---------+---------+-------+----------+-------+----------------------------+
    | 100|  BEIGE|PRECHECKS|EXECUTING|RUNNING|  07:35:27| 3s ago|Loading database information|
    +----+-------+---------+---------+-------+----------+-------+----------------------------+
    Total jobs 1

    The command lsj is running every 10 seconds. PRESS ENTER TO EXIT
    ```

    </details>

5. Wait a minute or two until AutoUpgrade completes. Do not exit from the AutoUpgrade console.

6. When the job completes, AutoUpgrade prints the location of the *summary report*, which contains detailed information about the analysis. Check the summary report.

    ``` bash
    <copy>
    cat /home/oracle/logs/one-command-patching/cfgtoollogs/patch/auto/status/status.log
    </copy>
    ```

    * You can see that you are patching the *BEIGE* database.
    * You can also see that you are patching from 19.31 to 19.32.
    * In this lab, you can only use already downloaded patches. When this lab was created, 19.32 was the latest Release Update. 
    * In your own environment, when AutoUpgrade downloads patches, it will always take the latest available Release Update from MOS when you specify *patch=recommended*.
    * Finally, all checks passed, and no manual intervention was needed.
    * This database was found to be ready for patching.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    ==========================================
       AutoUpgrade Patching Summary Report
    ==========================================
    [Date]           Thu Sep 03 07:37:45 GMT 2026
    [Number of Jobs] 1
    ==========================================
    [Job ID] 100
    ==========================================
    [DB Name]                beige
    [Version Before AutoUpgrade Patching] 19.31.0.0.0
    [Version After AutoUpgrade Patching]  19.32.0.0.260721
    ------------------------------------------
    [Stage Name]    PENDING
    [Status]        SUCCESS
    [Start Time]    2026-09-03 07:35:27
    [Duration]      0:00:00
    [Log Directory] /home/oracle/logs/one-command-patching/BEIGE/100/pending
    ------------------------------------------
    [Stage Name]    PRECHECKS
    [Status]        SUCCESS
    [Start Time]    2026-09-03 07:35:27
    [Duration]      0:02:17
    [Log Directory] /home/oracle/logs/one-command-patching/BEIGE/100/prechecks
    [Detail]        /home/oracle/logs/one-command-patching/BEIGE/100/prechecks/beige_preupgrade.log
                    Check passed and no manual intervention needed
    ------------------------------------------
    ```

    </details>

## Task 2: Patch Database

Patching a single instance Oracle AI Database requires downtime.

**Downtime starts now.**

1. Start patching the database.

    ``` bash
    <copy>
    java -jar autoupgrade.jar -config scripts/pt-a-one-command-patching.cfg -patch -mode deploy
    </copy>
    ```

    * You are reusing the command line from the analysis, but this time you are using deploy mode.
    * Deploy mode automates all parts of the patching process.
    * Since AutoUpgrade is in *patching* mode, the prompt is `patch>`.

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

2. You are again in the AutoUpgrade console. Monitor the progress.

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
    +----+-------+---------+---------+-------+----------+-------+----------------+
    |Job#|DB_NAME|    STAGE|OPERATION| STATUS|START_TIME|UPDATED|         MESSAGE|
    +----+-------+---------+---------+-------+----------+-------+----------------+
    | 101|  BEIGE|PRECHECKS|EXECUTING|RUNNING|  07:39:34| 1s ago|Executing Checks|
    +----+-------+---------+---------+-------+----------+-------+----------------+
    Total jobs 1

    The command lsj is running every 10 seconds. PRESS ENTER TO EXIT
    ```

    </details>

3. Press *Enter* to stop the automatic refresh. Let's get more information about the process.

    ``` bash
    <copy>
    status -job 101 -a 10
    </copy>
    ```

    * The `status` command provides more detail.
    * It requires the *job ID*, which you can find in the output of `lsj`.
    * Examine the different stages that the job will go through.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    Details
    
        Job No           101
        Oracle SID       BEIGE
        Start Time       26/09/03 07:39:34
        Elapsed (min):   0
        End time:        N/A
    
    Logfiles
    
        Logs Base:    /home/oracle/logs/one-command-patching/BEIGE
        Job logs:     /home/oracle/logs/one-command-patching/BEIGE/101
        Stage logs:   /home/oracle/logs/one-command-patching/BEIGE/101/prechecks
        TimeZone:     /home/oracle/logs/one-command-patching/BEIGE/temp
        Remote Dirs:
    
    Stages
        PENDING          <1 min
        GRP              <1 min
        PREACTIONS       <1 min
        PRECHECKS        ~0 min (RUNNING)
        PREFIXUPS
        EXTRACT
        DBTOOLS
        INSTALL
        OH_PATCHING
        OPTIONS
        ROOTSH
        DB_PATCHING
        POSTCHECKS
        POSTFIXUPS
        POSTACTIONS
    
    Stage-Progress Per Container
    
        +--------+---------+
        |Database|PRECHECKS|
        +--------+---------+
        |   BEIGE|    97 % |
        +--------+---------+
    
    The command status is running every 10 seconds. PRESS ENTER TO EXIT
    ```

    </details>

4. **Patching the database takes approximately 10 minutes or 30 minutes.**
    * In lab 5, you create a 19.32 gold image. If you completed that lab, then AutoUpgrade sees and uses this gold image. Using an already patched gold image is a faster option.
    * If you didn't complete lab, then AutoUpgrade must build the Oracle home from scratch by extracting the base image and apply the 19.32 Release Update which is a slower option. In this case, most of the time is spent in *INSTALL* and *OH_PATCHING* stages.
    * In this lab, you build the new Oracle home and patch the database in one command. This is a convenient option.
    * For less downtime, you can build the Oracle home in advance and then patch the database using an existing Oracle home. This is what you did in Lab 4.

5. When AutoUpgrade completes, it prints a message to the console and exits.

    * AutoUpgrade informs you that there is a guaranteed restore point, which you must remove when it is no longer needed.
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
    Drop GRP from BEIGE: drop restore point AU_PATCHING_9212_BEIGE1931000
    
    Please check the summary report at:
    /home/oracle/logs/one-command-patching/cfgtoollogs/patch/auto/status/status.html
    /home/oracle/logs/one-command-patching/cfgtoollogs/patch/auto/status/status.log
    ```

    </details>

6. Update the profile script. Since the database now runs from a new Oracle home, you must update the profile script. This command replaces the `ORACLE_HOME` variable in the profile script.

    ``` bash
    <copy>
    sed -i 's|^ORACLE_HOME=.*|ORACLE_HOME=/u01/app/oracle/product/dbhome_19_32_lab_a|' /usr/local/bin/beige
    </copy>
    ```

7. Set the environment and connect.

    ``` bash
    <copy>
    . beige
    sql / as sysdba
    </copy>

    # Be sure to press RETURN
    ```

8. Check the version.

    ``` bash
    <copy>
    select version_full from v$instance;
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    VERSION_FULL
    -----------------
    19.32.0.0.0
    ```

    </details>

9. Exit SQLcl.

    ``` 
    <copy>
    exit
    </copy>
    ```

10. Check the Oracle home. 

    ``` bash
    <copy>
    $ORACLE_HOME/OPatch/opatch lspatches
    </copy>

    # Be sure to press RETURN
    ```

    * The new Oracle home is fully up-to-date.
    * 19.32 was the newest Release Update when the workshop was created.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    39779336;Fix for Bug 39779336
    39750798;Fix for Bug 39750798
    39661089;Fix for Bug 39661089
    39222882;OJVM RELEASE UPDATE: 19.32.0.0.260721 (39222882)
    39657094;DATAPUMP BUNDLE PATCH 19.32.0.0.0
    39472050;Database Release Update : 19.32.0.0.260721 (39472050)
    29585399;OCW RELEASE UPDATE 19.3.0.0.0 (29585399)
    
    OPatch succeeded.
    ```

    </details>    

11. You have now patched your Oracle AI Database with one command, including the following:

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

* Webinar, [One-Button Patching - makes life easier for every Oracle DBA](https://youtu.be/brnBavVLyM0)

## Acknowledgements

* **Author** - Daniel Overby Hansen
* **Contributors** - Rodrigo Jorge, Alex Zaballa, Mike Dietrich, Alejandro Diaz
* **Last Updated By/Date** - Daniel Overby Hansen, September 2026
