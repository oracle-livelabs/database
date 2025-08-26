# Simple Patching to Existing Oracle Home

## Introduction

In this lab, you will patch another Oracle Database using AutoUpgrade. Since you have already created a new Oracle home, you will use that. There is no need to create a separate Oracle home each database.

Estimated Time: 10 Minutes

### Objectives

In this lab, you will:

* Patch a database

### Prerequisites

This lab assumes:

* You have completed Lab 2: Simple Patching With AutoUpgrade

## Task 1: Patch database

You will use AutoUpgrade just like in lab 2.

1. Use the *yellow* terminal 🟨. In this lab, you use a pre-created config file. Examine the config file.

    ``` bash
    <copy>
    cd
    cat scripts/pt-04-simple-patching-existing-home.cfg
    </copy>

    # Be sure to hit RETURN
    ```

    * This config file contains fewer parameters than the previous one from lab 2.
    * Since the Oracle home exists, the patch process becomes easier.
    * The *UPGR* database is not running ARCHIVELOG mode, so you must disable restoration.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    $ cat scripts/pt-04-simple-patching-existing-home.cfg
    global.autoupg_log_dir=/home/oracle/autoupgrade-patching/simple-patching-existing-home/log
    patch1.source_home=/u01/app/oracle/product/19
    patch1.target_home=/u01/app/oracle/product/19_28
    patch1.sid=UPGR
    patch1.restoration=no
    ```

    </details>

2. Patching a single instance Oracle Database require downtime. Downtime starts now.

3. Start patching the database.

    ``` bash
    <copy>
    java -jar autoupgrade.jar -config scripts/pt-04-simple-patching-existing-home.cfg -mode deploy
    </copy>
    ```

    * In this lab, you're skipping the pre-patch analysis. Oracle recommends that you always performs this on a production database. But in the interest of time, you're skipping it on this database.
    * Deploy mode is the complete automation which performs all parts of a patch process.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    $ java -jar autoupgrade.jar -config scripts/pt-04-simple-patching-existing-home.cfg -mode deploy
    AutoUpgrade 25.4.250730 launched with default internal options
    Processing config file ...
    +--------------------------------+
    | Starting AutoUpgrade execution |
    +--------------------------------+
    1 Non-CDB(s) will be processed
    Type 'help' to list console commands
    upg>
    ```

    </details>

4. Monitor the progress.

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
    upg> lsj -a 10
    upg> +----+-------+---------+---------+-------+----------+-------+----------------+
    |Job#|DB_NAME|    STAGE|OPERATION| STATUS|START_TIME|UPDATED|         MESSAGE|
    +----+-------+---------+---------+-------+----------+-------+----------------+
    | 100|   UPGR|PREFIXUPS|EXECUTING|RUNNING|  10:09:45| 0s ago|Executing fixups|
    +----+-------+---------+---------+-------+----------+-------+----------------+
    Total jobs 1

    The command lsj is running every 10 seconds. PRESS ENTER TO EXIT
    ```

    </details>

5. It takes just a few minutes to patch the database. Leave AutoUpgrade running.

    * You can press ENTER and can use the `status -job 100 -a 10` command.
    * You can explore the options in AutoUpgrade using the `help` command.
    * You can see the list of pre- and post-patching fixups using `fxlist -job 100`.
    * You can disable the post-patching dictionary stats run using `fxlist -job 100 -c UPGR alter POST_DICTIONARY run no`.

6. When patching completes, AutoUpgrade exists.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    ....
    (output truncated)
    ....
    Job 100 completed
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

7. Update the profile script. Since the database now runs out of a new Oracle home, you must update the profile script. This command replaces the `ORACLE_HOME` variable in the profile script.

    ``` bash
    <copy>
    sed -i 's|^ORACLE_HOME=.*|ORACLE_HOME=/u01/app/oracle/product/19_28|' /usr/local/bin/upgr
    </copy>
    ```

8. That's it. You just patched your Oracle Database including:
    * Using an existing Oracle home
    * Required and recommended pre- and post-tasks
    * Copying database configuration files from old to new Oracle home
    * Restarting database in new Oracle home
    * Executing Datapatch

You may now [*proceed to the next lab*](#next).

## Acknowledgements

* **Author** - Daniel Overby Hansen
* **Contributors** - Rodrigo Jorge, Mike Dietrich
* **Last Updated By/Date** - Daniel Overby Hansen, August 2025
