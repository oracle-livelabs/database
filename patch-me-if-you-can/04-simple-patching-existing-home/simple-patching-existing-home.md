# Simple Patching to Existing Oracle Home

## Introduction

In this lab, you will patch another Oracle Database using AutoUpgrade. Since you have already created a new Oracle home, you will use that. There is no need to create a separate Oracle home each database. 

Estimated Time: 10 Minutes

### Objectives

In this lab, you will:

* Assess the patch readiness of a database
* Patch a database

### Prerequisites

This lab assumes:

- You have completed Lab 2: Simple Patching With AutoUpgrade

## Task 1: Analyze database

You will use AutoUpgrade just like in lab 2. 

1. Use the *yellow* terminal 🟨. In this lab, you use a pre-created config file. Examine the config file.

    ```
    <copy>
    cd
    cat scripts/simple-patching-existing-home.cfg
    </copy>

    -- Be sure to hit RETURN
    ```

    * This config file contains fewer parameters than the previous one from lab 2.
    * Since the Oracle home exists, the patch process becomes easier.
    * The *UPGR* database is not running ARCHIVELOG mode, so you must disable restoration.
    
    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ cat scripts/simple-patching-existing-home.cfg
    global.autoupg_log_dir=/home/oracle/autoupgrade-patching/simple-patching-existing-home/log
    patch1.source_home=/u01/app/oracle/product/19
    patch1.target_home=/u01/app/oracle/product/19_25
    patch1.sid=UPGR
    patch1.restoration=no
    ```
    </details>    

2. Analyze the database.

    ```
    <copy>
    java -jar autoupgrade.jar -config scripts/simple-patching-existing-home.cfg -mode analyze
    </copy>
    ```

    * Since you don't need to build a new Oracle home, you need to omit the `-patch` parameter from the command line.
    * Otherwise, you use the same commands as in lab 2.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ java -jar autoupgrade.jar -config scripts/simple-patching-existing-home.cfg -mode analyze
    AutoUpgrade 24.8.241119 launched with default internal options
    Processing config file ...
    +--------------------------------+
    | Starting AutoUpgrade execution |
    +--------------------------------+
    1 Non-CDB(s) will be analyzed
    Type 'help' to list console commands
    upg>
    ```
    </details>    

3. Wait a minute or two until AutoUpgrade completes. Don't exit from the AutoUpgrade console. 

4. When the job completes, AutoUpgrade prints the location of the *summary report* which contains detailed information about the analysis. Check the summary report.

    ```
    <copy>
    cat /home/oracle/autoupgrade-patching/simple-patching-existing-home/log/cfgtoollogs/upgrade/auto/status/status.log    
    </copy>
    ```

    * You can see that you're patching the UPGR database. 
    * You can also see that you're patching from 19.21 to 19.25.
    * In the end, you can see that all checks passed and there's no manual intervention needed.
    * This database was found to be ready for patching. 

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    ==========================================
              Autoupgrade Summary Report
    ==========================================
    [Date]           Tue Dec 03 10:08:28 GMT 2024
    [Number of Jobs] 1
    ==========================================
    [Job ID] 100
    ==========================================
    [DB Name]                upgr
    [Version Before Upgrade] 19.21.0.0.0
    [Version After Upgrade]  19.25.0.0.0
    ------------------------------------------
    [Stage Name]    PRECHECKS
    [Status]        SUCCESS
    [Start Time]    2024-12-03 10:08:07
    [Duration]      0:00:21
    [Log Directory] /home/oracle/autoupgrade-patching/simple-patching-existing-home/log/UPGR/100/prechecks
    [Detail]        /home/oracle/autoupgrade-patching/simple-patching-existing-home/log/UPGR/100/prechecks/upgr_preupgrade.log
                    Check passed and no manual intervention needed
    ------------------------------------------ 
    ```
    </details>   

## Task 2: Patch database

Patching a single instance Oracle Database require downtime. Downtime starts now.

1. Start patching the database. 

    ```
    <copy>
    java -jar autoupgrade.jar -config scripts/simple-patching-existing-home.cfg -mode deploy
    </copy>
    ```

    * You're reusing the same command line as the analysis, however, this time you are activating deploy mode.
    * Deploy mode is the complete automation which performs all parts of a patch process. 

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ java -jar autoupgrade.jar -config scripts/simple-patching-existing-home.cfg -mode deploy
    AutoUpgrade 24.8.241119 launched with default internal options
    Processing config file ...
    +--------------------------------+
    | Starting AutoUpgrade execution |
    +--------------------------------+
    1 Non-CDB(s) will be processed
    Type 'help' to list console commands
    upg>
    ```
    </details>    

2. Monitor the progress.

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
    upg> lsj -a 10
    upg> +----+-------+---------+---------+-------+----------+-------+----------------+
    |Job#|DB_NAME|    STAGE|OPERATION| STATUS|START_TIME|UPDATED|         MESSAGE|
    +----+-------+---------+---------+-------+----------+-------+----------------+
    | 101|   UPGR|PREFIXUPS|EXECUTING|RUNNING|  10:09:45| 0s ago|Executing fixups|
    +----+-------+---------+---------+-------+----------+-------+----------------+
    Total jobs 1
    
    The command lsj is running every 10 seconds. PRESS ENTER TO EXIT
    ```
    </details>        

3. It takes just a few minutes to patch the database. Leave AutoUpgrade running.

    * You can press ENTER and can use the `status -job 101 -a 10` command.
    * You can explore the options in AutoUpgrade using the `help` command.
    * You can see the list of pre- and post-patching fixups using `fxlist -job 101`.
    * You can disable the post-patching dictionary stats run using `fxlist -job 101 -c UPGR alter POST_DICTIONARY run no`.

4. When patching completes, AutoUpgrade exists.    

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    ....
    (output truncated)
    ....
    Job 101 completed
    ------------------- Final Summary --------------------
    Number of databases            [ 1 ]
    
    Jobs finished                  [1]
    Jobs failed                    [0]
    Jobs restored                  [0]
    Jobs pending                   [0]
    
    
    
    Please check the summary report at:
    /home/oracle/autoupgrade-patching/simple-patching-existing-home/log/cfgtoollogs/upgrade/auto/status/status.html
    /home/oracle/autoupgrade-patching/simple-patching-existing-home/log/cfgtoollogs/upgrade/auto/status/status.log
    ```
    </details>      

5. Update the profile script. Since the database now runs out of a new Oracle home, you must update the profile script. This command replaces the `ORACLE_HOME` variable in the profile script.

    ```
    <copy>
    sed -i 's/^ORACLE_HOME=.*/ORACLE_HOME=\/u01\/app\/oracle\/product\/19_25/' /usr/local/bin/upgr
    </copy>
    ``` 

11. That's it. You just patched your Oracle Database including:
    * Using an existing Oracle home
    * Required and recommended pre- and post-tasks
    * Copying database configuration files from old to new Oracle home
    * Restarting database in new Oracle home
    * Executing Datapatch

You may now *proceed to the next lab*.

## Acknowledgements

* **Author** - Daniel Overby Hansen
* **Contributors** - Rodrigo Jorge, Mike Dietrich
* **Last Updated By/Date** - Daniel Overby Hansen, January 2025