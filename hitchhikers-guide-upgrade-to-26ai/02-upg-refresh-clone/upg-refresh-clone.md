# Upgrade Non-CDB Using Refreshable Clone PDB

## Introduction

In this lab, you will upgrade a non-CDB and convert it to a pluggable database (PDB). You will use a refreshable clone PDB. This feature creates a copy of the database and keeps it synchronized by periodically applying redo from the source database. This minimizes the required downtime while keeping the source database untouched for rollback.

Estimated Time: 35 minutes

### Objectives

In this lab, you will:

* Upgrade a non-CDB and convert it to PDB
* Plug it in to existing CDB
* Prepare databases for refreshable clone PDB

### Prerequisites

None.

## Task 1: Prepare your environment

A refreshable clone PDB uses a database link. You must create a user and grant the required privileges in the source non-CDB. Also, you must create a database link in the target CDB connecting to the source non-CDB.

1. Use the *yellow* 🟨 terminal. Set the environment to the source non-CDB database (*BEIGE*) and connect.

    ``` bash
    <copy>
    . beige
    sql / as sysdba
    </copy>
    ```

2. Create a user and grant the necessary privileges.

    ``` bash
    <copy>
    create user dblinkuser identified by dblinkuser;
    grant create session to dblinkuser;
    grant select_catalog_role to dblinkuser;
    grant create pluggable database to dblinkuser;
    grant read on sys.enc$ to dblinkuser;
    </copy>
    ```

    * You use the user to connect from the target CDB via a database link.
    * You can drop the user after the migration.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> create user dblinkuser identified by dblinkuser;

    User created.

    SQL> grant create session to dblinkuser;

    Grant succeeded.

    SQL> grant select_catalog_role to dblinkuser;

    Grant succeeded.

    SQL> grant create pluggable database to dblinkuser;

    Grant succeeded.

    SQL> grant read on sys.enc$ to dblinkuser;

    Grant succeeded.
    ```

    </details>

3. Exit SQLcl.

    ``` bash
    <copy>
    exit
    </copy>
    ```

4. Set the environment to the target CDB (*CDB26*) and connect.

    ``` bash
    <copy>
    . cdb26
    sql / as sysdba
    </copy>
    ```

5. Create a database link pointing to the *BEIGE* database.

    ``` bash
    <copy>
    create database link clonepdb
    connect to dblinkuser
    identified by dblinkuser
    using 'localhost/beige';
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> create database link clonepdb
      2  connect to dblinkuser
      3  identified by dblinkuser
      4  using 'localhost/beige';

    Database link CLONEPDB created.
    ```

    </details>

6. Ensure that the database link works.

    ``` bash
    <copy>
    select * from dual@clonepdb;
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> select * from dual@clonepdb;
    
    DUMMY
    ________
    X
    ```

    </details>

7. Exit SQLcl.

    ``` bash
    <copy>
    exit
    </copy>
    ```

## Task 2: Prepare for upgrade

You check the source database for upgrade readiness.

1. Use the *yellow* 🟨 terminal. For this lab, you will use a pre-created config file. Examine the pre-created config file.

    ``` bash
    <copy>
    cat /home/oracle/scripts/upg-refresh-clone-beige.cfg
    </copy>
    ```

    * `sid` specifies the source non-CDB.
    * `target_cdb` is the CDB where you want to plug in.
    * `source_dblink` is the name of the database link in the target CDB, plus the refresh rate. Here, it is set to 60 seconds, which is shorter than you would typically use in a production environment but is suitable for this lab.
    * `target_pdb_name` renames the database from *BEIGE* to *TEAL*.
    * `target_pdb_copy_option` instructs the CDB to use Oracle Managed Files (OMF).
    * `parallel_pdb_creation_clause` instructs the CDB to use parallel execution servers to copy the new PDB's data files to a new location. This may result in faster creation of the PDB. If unset, then the CDB automatically chooses the number of parallel execution servers to use.
    * `start_time` is set to 100 hours from starting AutoUpgrade. We set the process start time far in the future so we can later control the execution using the *proceed* command.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    global.global_log_dir=/home/oracle/logs/beige-refresh
    upg1.source_home=/u01/app/oracle/product/19
    upg1.target_home=/u01/app/oracle/product/26
    upg1.sid=BEIGE
    upg1.target_cdb=CDB26
    upg1.source_dblink.BEIGE=CLONEPDB 60
    upg1.target_pdb_name.BEIGE=TEAL
    upg1.target_pdb_copy_option.BEIGE=file_name_convert=none
    upg1.parallel_pdb_creation_clause.BEIGE=2
    upg1.start_time=+100h
    upg1.timezone_upg=NO
    ```

    </details>

2. Start AutoUpgrade in *analyze* mode. The check usually completes very fast. Wait for it to complete.

    * The analysis must run on the source system. Since the source and target are the same in this lab, you don't need to worry about it.
    * If the target is on a remote host, you can use the parameter `target_is_remote`. 

    ``` bash
    <copy>
    java -jar autoupgrade.jar -config /home/oracle/scripts/upg-refresh-clone-beige.cfg -mode analyze
    </copy>
    ```

3. When AutoUpgrade completes, it prints the path to the summary report. Check the summary report.

    ``` bash
    <copy>
    cat /home/oracle/logs/beige-refresh/cfgtoollogs/upgrade/auto/status/status.log
    </copy>
    ```

    * The report states *Check passed and no manual intervention needed*.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    ==========================================
              Autoupgrade Summary Report
    ==========================================
    [Date]           Mon Aug 10 09:24:03 GMT 2026
    [Number of Jobs] 1
    ==========================================
    [Job ID] 100
    ==========================================
    [DB Name]                beige
    [Version Before Upgrade] 19.31.0.0.0
    [Version After Upgrade]  23.26.3.0.0
    ------------------------------------------
    [Stage Name]    PRECHECKS
    [Status]        SUCCESS
    [Start Time]    2026-08-10 09:23:48
    [Duration]      0:00:15
    [Log Directory] /home/oracle/logs/beige-refresh/BEIGE/100/prechecks
    [Detail]        /home/oracle/logs/beige-refresh/BEIGE/100/prechecks/beige_preupgrade.log
                    Check passed and no manual intervention needed
    ------------------------------------------
    ```

    </details>

4. Although the summary report states *Check passed...* it is still recommended to examine the detailed preupgrade report.

    * The preupgrade report comes in a number of formats.
    * The HTML report is easier to read and provides a good overview of the findings. However, it requires a desktop environment which is not always present on database servers.
    * The text format is a regular file that you can read in a terminal.
    * The XML and JSON formats are useful for scripting and automation. 

5. Examine the detailed preupgrade HTML report. 

    ``` bash
    <copy>
    firefox /home/oracle/logs/beige-refresh/BEIGE/100/prechecks/beige_preupgrade.html &
    </copy>
    ```

6. Close Firefox.  

7. Proceed with the pre-upgrade fixups.

    * Normally, you would do this shortly before the final refresh (as dictated by `start_time` config file parameter or when you plan to run the *proceed* command). But in this lab we do it now.
    * The fixups must run on the source system.
    * In the interest of time, you skip the fixups in this exercise.

## Task 3: Build refreshable clone

You build the refreshable clone with AutoUpgrade. It creates the PDB and starts the periodic refresh.

1. Use the *yellow* 🟨 terminal. Start AutoUpgrade in *deploy* mode.

    * AutoUpgrade in deploy mode must run on the target system. Since source and target is the same in this lab, you don't need to worry about it.

    ``` bash
    <copy>
    java -jar autoupgrade.jar -config /home/oracle/scripts/upg-refresh-clone-beige.cfg -mode deploy
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
    upg> Copying remote database 'BEIGE' as 'TEAL' for job 101
    ```

    </details>

2. When AutoUpgrade displays *Copying remote database ...*, press *RETURN* to bring the console forward.

3. Monitor the creation. Use the `lsj` command.

    ``` bash
    <copy>
    lsj -a 10
    </copy>
    ```

    * AutoUpgrade creates the PDB and copies the data files in the phase *CLONEPDB*. The database is small so it completes fairly quickly. 
    * Then it refreshes the PDB periodically in the *REFRESHPDB* phase.
    * Notice the *Starts in 5,996 minutes* message. In the config file, you set `start_time` to *plus 10 hours*. This means that AutoUpgrade will refresh the PDB for 10 hours before moving on with the upgrade. Of course, you don't want to wait 10 hours for the upgrade, so later you will use the `PROCEED` command in AutoUpgrade. The command moves `start_now` to `now` and this allows you control the exact time of the final refresh and the start of the upgrade.  

4. Do not exit AutoUpgrade. Leave it running.

5. Switch to the blue 🟦 terminal. Set the environment to the *BEIGE* database.

    ``` bash
    <copy>
    . beige
    sql / as sysdba
    </copy>
    ```

5. Create test data.

    ``` bash
    <copy>
    create user sales identified by oracle default tablespace users;
    grant dba to sales;
    create table sales.orders as select * from all_objects;
    </copy>
    ```
    
    * You will enter some data to the *BEIGE* database. This allows you to verify that changes made after the initial data file copy are propagated to the PDB in the PDB after the migration.
    * Later, you will use the test data to ensure that no data is lost.

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

6. Exit SQLcl.

    ``` bash
    <copy>
    exit
    </copy>
    ```

## Task 4: Upgrade and convert to PDB

1. Switch back to the *yellow* 🟨 terminal.

2. Examine the output. AutoUpgrade is still in the *REFRESHPDB* phase.

3. Press *ENTER* to stop *lsj* from spooling the job status and bring back the console.

4. Next, run the `proceed` command to force the start of the upgrade process **now**.

    ``` bash
    <copy>
    proceed -job 101
    </copy>
    ```

    * AutoUpgrade will start shortly.
    * You can also specify a new start time using *proceed -job <#> -newStartTime [dd/mm/yyyy hh:mm:ss, +<#>h<#>m]*.
    * AutoUpgrade executes a final refresh to bring over the latest changes. So no more changes will be captured from the source database. 
    * Then, it starts the upgrade and conversion to PDB.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    upg> proceed -job 101
    New start time for job 101 is scheduled 0 minute(s) from now, at 25/07/2025 13:29:41
    ```

    </details>

5. Monitor the progress.

    ``` bash
    <copy>
    status -job 101 -a 10
    </copy>
    ```

    * AutoUpgrade was waiting in the *REFRESHPDB* phase; applying redo at the specified interval.
    * When you issued the `proceed` command, AutoUpgrade made a final refresh before moving on to the next phase.
    * Any changes made in the source database at this point would not be transferred to the target PDB.
    * In the *DBUPGRADE* stage, AutoUpgrade is upgrading the PDB to the new release. The CDB is already on the new release, so only the PDB is upgraded, which is much faster than a complete database upgrade.
    * Since the source database is a non-CDB, the PDB must also be converted to a proper PDB. AutoUpgrade does this during the *NONCDBTOPDB* phase, where it runs the `noncdb_to_pdb.sql` script.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    Details

    	Job No           101
    	Oracle SID       BEIGE
    	Start Time       26/08/10 09:32:19
    	Elapsed (min):   3
    	End time:        N/A

    Logfiles

    	Logs Base:    /home/oracle/logs/beige-refresh/BEIGE
    	Job logs:     /home/oracle/logs/beige-refresh/BEIGE/101
    	Stage logs:   /home/oracle/logs/beige-refresh/BEIGE/101/dbupgrade
    	TimeZone:     /home/oracle/logs/beige-refresh/BEIGE/temp
    	Remote Dirs:

    Stages
    	SETUP            <1 min
    	PREUPGRADE       <1 min
    	DRAIN            <1 min
    	CLONEPDB         <1 min
    	REFRESHPDB       3 min
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

6. Leave the upgrade running. Do not exit AutoUpgrade.

7. Move on with the next task.

## Task 5: Look Behind the Scenes

While the upgrade runs, let's look at some of the details.

1. Switch to the *blue* 🟦 terminal. Examine the alert log of *CDB26*, the target CDB, to see the creation of the refreshable clone PDB.

    ``` bash
    <copy>
    cd /u01/app/oracle/diag/rdbms/cdb26/CDB26/trace
    grep -i -B2 "create pluggable database \"TEAL\"" alert_CDB26.log
    </copy>

    # Be sure to press RETURN
    ```

    * Notice how AutoUpgrade used the `CREATE PLUGGABLE DATABASE` statement.
    * The `@CLONEPDB` keyword specifies the use of remote cloning via the database link *CLONEPDB*.
    * The `REFRESH` clause creates the PDB as a refreshable clone.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    Opatch validation is skipped for PDB TEAL (con_id=0)
    2024-05-27T07:42:30.747705+00:00
    create pluggable database "TEAL"  FROM BEIGE@CLONEPDB   file_name_convert=none  tempfile reuse  REFRESH MODE MANUAL
    --
    2024-05-27T07:42:47.488916+00:00
    TEAL(5):.... (PID:561068): Media Recovery Complete [dbsdrv.c:15613]
    Completed: create pluggable database "TEAL"  FROM BEIGE@CLONEPDB   file_name_convert=none  tempfile reuse  REFRESH MODE MANUAL

    (output varies)
    ```

    </details>

2. Further, let's see the periodic refresh.

    ``` bash
    <copy>
    grep -i -B2 "refresh" alert_CDB26.log
    </copy>
    ```

    * The `ALTER PLUGGABLE DATABASE ... REFRESH` command instructs the CDB to bring the latest redo from the source database and roll forward.
    * Notice how the refresh happens every 60 seconds. This is the refresh rate specified in the config file.
    * The refresh stopped when you used the `proceed` command. Now, AutoUpgrade executes a final refresh before moving on with the upgrade.

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

3. Let's examine the AutoUpgrade log files. Go to the *Logs Base* directory. You can find this location using the AutoUpgrade console command `status`. 

    ``` bash
    <copy>
    cd /home/oracle/logs/beige-refresh/BEIGE
    ls -l
    </copy>

    # Be sure to press RETURN
    ```

    * Explore the subdirectories.
    * Notice how each job number has its own dedicated directory.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    total 8
    drwxr-x---.  3 oracle oinstall  119 Aug 10 09:24 100
    drwxr-x---. 11 oracle oinstall 4096 Aug 10 09:53 101
    drwxr-x---.  2 oracle oinstall 4096 Aug 10 09:53 temp
    ```

    </details>

4. Explore the directory of your current upgrade job. If your job number is different, you must change it (from 101).

    ``` bash
    <copy>
    cd /home/oracle/logs/beige-refresh/BEIGE/101
    ls -l
    </copy>

    # Be sure to press RETURN
    ```

    * Each phase (*preupgrade*, *prefixups*, *drain*, *dbupgrade*, etc.) has its own subdirectory. 
    * If you need to troubleshoot, you can go to the relevant subdirectory and examine the log files.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    -rw-r-----. 1 oracle oinstall 796425 Aug 10 09:53 autoupgrade_20260814.log
    -rw-r-----. 1 oracle oinstall   4756 Aug 10 09:53 autoupgrade_20260814_user.log
    -rw-r-----. 1 oracle oinstall    618 Aug 10 09:53 autoupgrade_err.log
    drwxr-x---. 2 oracle oinstall     88 Aug 10 09:32 clonepdb
    drwxr-x---. 2 oracle oinstall   4096 Aug 10 09:47 dbupgrade
    drwxr-x---. 2 oracle oinstall     28 Aug 10 09:25 drain
    drwxr-x---. 2 oracle oinstall     28 Aug 10 09:25 preupgrade
    ```

    </details>

5. Examine the upgrade log files. You find them in the *dbupgrade* directory.

    ``` bash
    <copy>
    cd /home/oracle/logs/beige-refresh/BEIGE/101/dbupgrade
    ls -l
    </copy>

    # Be sure to press RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    total 55228
    -rw-r-----. 1 oracle oinstall     9853 Aug 10 09:47 autoupgrade20260810092529teal.log
    -rw-r-----. 1 oracle oinstall     1114 Aug 10 09:47 catupgrd20260810092529cdbroot0.log
    -rw-r-----. 1 oracle oinstall 37869016 Aug 10 09:47 catupgrd20260810092529teal0.log
    -rw-r-----. 1 oracle oinstall  7886153 Aug 10 09:47 catupgrd20260810092529teal1.log
    -rw-r-----. 1 oracle oinstall  5042877 Aug 10 09:47 catupgrd20260810092529teal2.log
    -rw-r-----. 1 oracle oinstall  5636948 Aug 10 09:47 catupgrd20260810092529teal3.log
    -rw-r-----. 1 oracle oinstall      533 Aug 10 09:32 catupgrd20260810092529teal_catcon_16399.lst
    -rw-r-----. 1 oracle oinstall        0 Aug 10 09:46 catupgrd20260810092529teal_datapatch_upgrade.err
    -rw-r-----. 1 oracle oinstall     2229 Aug 10 09:46 catupgrd20260810092529teal_datapatch_upgrade.log
    -rw-r-----. 1 oracle oinstall    10363 Aug 10 09:47 catupgrd20260810092529teal_stderr.log
    -rw-r-----. 1 oracle oinstall     3127 Aug 10 09:32 beige_autocompile20260810093239cdbroot.log
    -rw-r-----. 1 oracle oinstall    34284 Aug 10 09:32 phase.log
    ```

    </details>

6. AutoUpgrade writes the output of the upgrade to the *catupgrd* log files.

    ``` bash
    <copy>
    ls -l catupgrd*teal*log
    </copy>
    ```

    * There are four log files because AutoUpgrade uses four threads for the upgrade.
    * Each thread logs to a separate file. 

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    -rw-r-----. 1 oracle oinstall 37869016 Aug 10 09:47 catupgrd20260810092529teal0.log
    -rw-r-----. 1 oracle oinstall  7886153 Aug 10 09:47 catupgrd20260810092529teal1.log
    -rw-r-----. 1 oracle oinstall  5042877 Aug 10 09:47 catupgrd20260810092529teal2.log
    -rw-r-----. 1 oracle oinstall  5636948 Aug 10 09:47 catupgrd20260810092529teal3.log
    ```

    </details>

7. You can follow the upgrade by *tailing* the log files.

    ``` bash
    <copy>
    tail -100f catupgrd*teal0.log
    </copy>
    ```
    
    * Before AutoUpgrade, this was an effective way of monitoring the upgrade.
    * AutoUpgrade now provides more meaningful output and monitors the upgrade for you.

8. Stop tailing. Press *CTRL+C*. 

9. Examine some of the other log files.

10. Get details about AutoUpgrade.

    ``` bash
    <copy>
    cd
    java -jar autoupgrade.jar -version
    </copy>

    # Be sure to press RETURN
    ```

    * Any version of AutoUpgrade is backward compatible. Always use the latest version when you upgrade.
    * You can see a list of supported target versions.
    * You can find new versions of AutoUpgrade in the referenced MOS note, on [https://download.oracle.com/otn-pub/otn_software/autoupgrade.jar](oracle.com), or AutoUpgrade can download it for you.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    build.version 26.5.260807
    build.date 2026/08/07 17:06:01 +0000
    build.hash 0d4f2f519
    build.hash_date 2026/07/31 15:26:55 +0000
    build.supported_target_versions 12.2,18,19,21,23,26
    build.type production
    build.label (HEAD, tag: v26.5, origin/stable_devel, stable_devel)
    build.MOS_NOTE KB123450
    build.MOS_LINK https://support.oracle.com/support/?anchorId=&kmContentId=2485457&page=sptemplate&sptemplate=km-article 
    ```

    </details>

11. Examine the command line help.

    ``` bash
    <copy>
    cd
    java -jar autoupgrade.jar -help    
    </copy>

    # Be sure to press RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    Usage: java -jar autoupgrade.jar (misc_options | run_options | patch_options |
                                      legacy_options)
    
      The AutoUpgrade utility is designed to automate the upgrade process, both
      before starting upgrades, during upgrade deployments, and during postupgrade
      checks and configuration migration.
    
    misc_options = -help |
                   -version |
                   -create_sample_file (config [filename] [<type>] |
                                        settings [filename]) |
                   -listchecks [<checkName>]
                   -error_code [<errorcode>]
    
    run_options = (-config <filename> | -config_values "<config_values>")
                  [-settings <filename>]
                  [-mode (analyze|fixups|deploy|upgrade|postfixups)]
                  [-restore -jobs <job#,job#,...>]
                  [-rollback -jobs <job#,job#,...>]
                  [-restore_on_fail]
                  [-load_password]
                  [-load_win_credential <sid>]
                  [-noconsole]
                  [-clear_recovery_data [-jobs <job#,job#,...>]]
                  [-zip [-sid <sid>] [-d <dir>] [-zip_exclusion_list <list>]]
                  [-regen_hash]
                  [-debug]
    
    patch_options = -patch (misc_options | run_options)
    
    legacy_options = (-preupgrade <preupgrade>)
                     [-mode (analyze|fixups|postfixups)]
                     [-debug]
    
    Options:
      -help                           Displays available options.
    
                                      Example:
    
                                      java -jar autoupgrade.jar -help
    
      -version                        Displays the AutoUpgrade version.
    
                                      Example:
    
                                      java -jar autoupgrade.jar -version
    
      -auto_config
                                      Automatically creates a configuration file
                                      with default settings for upgrading
                                      specified database(s).
    
                                      Examples:
    
                                      java -jar autoupgrade.jar -auto_config
    
                                      java -jar autoupgrade.jar -auto_config -mode analyze
    
      -create_sample_file (config [filename] [<type>] | settings [filename])
                                      Creates a sample configuration file or
                                      internal settings file.
    
                                      type = [full | unplug | noncdbtopdb]
    
                                      Examples:
    
                                      java -jar autoupgrade.jar
                                      -create_sample_file settings settings.cfg
    
                                      java -jar autoupgrade.jar
                                      -create_sample_file config config.cfg
    
                                      java -jar autoupgrade.jar
                                      -create_sample_file config config.cfg unplug
    
      -listchecks [<checkName>]       Lists all checks or specified check.
    
                                      Examples:
    
                                      java -jar autoupgrade.jar -listchecks
    
                                      java -jar autoupgrade.jar
                                      -listchecks ORACLE_RESERVED_USERS
    
      -error_code [<errorcode>]       Displays the AutoUpgrade error codes.
    
                                      Examples:
    
                                      java -jar autoupgrade.jar -error_code
                                      java -jar autoupgrade.jar
                                      -error_code UPG-3101
    
      -config <filename>              Specifies the user config file with the
                                      database(s) to upgrade or patch.
    
                                      Example:
    
                                      java -jar autoupgrade.jar
                                      -config config.cfg -mode analyze
    
      -config_values "<param>=<value>[,<param>=<value>]"
                                      Specifies the content of the configuration
                                      file without creating one, it will read the
                                      ORACLE_HOME, ORACLE_SID, ORACLE_TARGET_HOME,
                                      and ORACLE_TARGET_VERSION from the
                                      environmental variables. Each database
                                      configuration is separated by an asterisk
                                      (*).
    
                                      Example:
                                      java -jar autoupgrade.jar -config_values
                                      "source_home=value,...,*,source_home=..."
                                      -mode analyze
    
      -settings <filename>            Overwrites the default internal settings.
                                      This is not needed for most cases.
    
                                      Example:
    
                                      java -jar autoupgrade.jar
                                      -settings settings.cfg -config config.cfg
                                      -mode analyze
    
      -mode (analyze|fixups|deploy|upgrade|postfixups)
                                      Operational mode for AutoUpgrade.
    
                                      Modes:
    
                                      analyze  -   Executes the checks in the
                                                   source home database readiness
                                                   status.
                                      fixups   -   Executes the checks and
                                                   pre-upgrade fixups but does not
                                                   perform the upgrade or patch.
                                      deploy   -   Performs the upgrade or
                                                   patching of the databases from
                                                   start to end.
                                      upgrade  -   Performs the database upgrade or
                                                   patching and post actions. The
                                                   database must already be up and
                                                   running in the target home.
                                      postfixups - Executes the postfixups in the
                                                   target home.
    
                                      Examples:
    
                                      java -jar autoupgrade.jar -config config.cfg
                                      -mode analyze
    
                                      java -jar autoupgrade.jar -config config.cfg
                                      -mode deploy
    
                                      java -jar autoupgrade.jar -preupgrade
                                      "target_version=21" -mode fixups
    
      -restore -jobs <job#,job#,...>  Executes a system-level restoration of the
                                      specified jobs. The databases are flashed
                                      back to the Guarantee Restore Point (GRP).
                                      The GRP must have been created by AutoUpgrade
                                      prior this command is run. The console is
                                      disabled by default.
    
                                      Examples:
    
                                      java -jar autoupgrade.jar -config config.cfg
                                      -restore -jobs 111
    
                                      java -jar autoupgrade.jar -config config.cfg
                                      -restore -jobs 111,222 -noconsole
    
      -rollback -jobs <job#,job#,...> Execute in the same manner as -restore except
                                      it uses Datapatch to rollback the databases to
                                      the previous version.
    
                                      Example:
    
                                      java -jar autoupgrade.jar -config config.cfg
                                      -rollback -jobs 111
    
      -restore_on_fail                If present, when a job fails, the database
                                      is restored automatically. Errors in PDBs are
                                      not considered irrecoverable, only errors in
                                      CDB$ROOT or Non-CDBs.
    
      -load_password                  Initiates an interactive console allowing
                                      passwords to be loaded into AutoUpgrade's
                                      keystore.
    
                                      Example:
    
                                      java -jar autoupgrade.jar -config config.cfg
                                      -load_password
    
      -load_win_credential <sid>      Opens a WinCredential cmdlet which prompts
                                      for user name and password and stores the
                                      values into an encrypted credential.
    
                                      If no SID is provided as an option to
                                      -load_win_credential, and only one database
                                      is specified in the config file, then the
                                      SID in the config file is used. However, if
                                      two or more SIDs are specified in the config
                                      file, and no SID is provided as an option to
                                      -load_win_credential, the result is an error.
    
                                      Example:
    
                                      java -jar autoupgrade.jar -config config.cfg
                                      -load_win_credential db19300
    
      -noconsole                      Starts the AutoUpgrade with the console
                                      disabled.
    
      -clear_recovery_data [-jobs <job#,job#,...>]
                                      Removes the recovery information which causes
                                      AutoUpgrade to start from scratch on the
                                      specified or all databases. Use after
                                      manually restoring a database and attempting
                                      a new upgrade or patch.  If no list of jobs
                                      is provided by default all the metadata is
                                      removed, this will not remove log files or
                                      reset the jobid counter, only the AutoUpgrade
                                      files used to keep track of the progress of
                                      each job.
    
                                      Examples:
    
                                      java -jar autoupgrade.jar -config config.cfg
                                      -clear_recovery_data
    
                                      java -jar autoupgrade.jar -config config.cfg
                                      -clear_recovery_data -jobs 111,222
    
      -zip [-sid <sid>] [-d <dir>] [-zip_exclusion_list <list>]
                                      Zips up log files required for filing an
                                      AutoUpgrade service request.
    
                                      Options:
                                        [-sid <sid>] - Specify SIDs to include in
                                        the zip.
                                        [-d <dir>] - Directory to save the zip
                                        file. Defaults to current directory.
                                        [-zip_exclusion_list <list>] - Files
                                        matching this list will be excluded from
                                        the zip.
    
                                      Examples:
    
    
                                      java -jar autoupgrade.jar -config config.cfg
                                      -zip
    
                                      java -jar autoupgrade.jar -config config.cfg
                                      -zip -sid db18700
    
                                      java -jar autoupgrade.jar -config config.cfg
                                      -zip -sid db18700,db19300
    
                                      java -jar autoupgrade.jar -config config.cfg
                                      -zip -zip_exclusion_list "db18700/.*"
    
                                      java -jar autoupgrade.jar -config config.cfg
                                      -zip -sid db18700 -d /tmp/
    
      -regen_hash                     Skips safety check that requires the same
                                      autoupgrade.jar file when resuming.
    
                                      Example:
    
                                      java -jar autoupgrade.jar -patch -config
                                      config.cfg -mode deploy -regen_hash
    
      -debug                          Enables debug logging. All debug messages
                                      are printed to the screen.
    
                                      Example:
    
                                      java -jar autoupgrade.jar -config config.cfg
                                      -mode deploy -debug
    
      -patch (misc_options | run_options)
                                      Executes AutoUpgrade Patching. For more details
                                      please run:
    
                                      java -jar autoupgrade.jar -patch -help
    
      -preupgrade <preupgrade>        Makes the autoupgrade behave as the legacy
                                      preupgrade tool, it will read the target
                                      ORACLE_HOME and ORACLE_VERSION from the
                                      environmental variables.
    
                                      Example:
    
                                      java -jar autoupgrade.jar -preupgrade
                                      "target_version=21,dir=/tmp/log"
                                      -mode fixups    
    ```

    </details>

## Task 6: Check Upgrade

1. Use the *yellow* 🟨 terminal. Wait for AutoUpgrade to complete the migration. 

2. When the job completes, AutoUpgrade prints *Job 101 completed*. 

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
    /home/oracle/logs/beige-refresh/cfgtoollogs/upgrade/auto/status/status.html
    /home/oracle/logs/beige-refresh/cfgtoollogs/upgrade/auto/status/status.log
    ```

    </details>

2. Set the environment to the *CDB26* database and connect.

    ``` bash
    <copy>
    . cdb26
    sql / as sysdba
    </copy>
    ```

3. Switch to *TEAL* and ensure that the *SALES.ORDERS* table exists.

    ``` bash
    <copy>
    alter session set container=TEAL;

    select count(*) from sales.orders;
    </copy>
    ```

    * If the query completes without errors, the table is present. This proves that changes made after the initial copy of data files are still in the PDB after the migration.

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

4. Exit SQLcl.

    ``` bash
    <copy>
    exit
    </copy>
    ```

5. AutoUpgrade stops the source non-CDB immediately after the final refresh when the source non-CDB and target CDB are on the same system. 
    * This ensures that no one enters data into the wrong database or adds new data to the source database after the migration.
    * You can control this behavior with the `close_source` config file parameter. 
    * If the databases are on different systems, you must manually shut down the source non-CDB after the migration.
    
**Congratulations!** You have now:

* Upgraded the *BEIGE* database
* Converted it to a PDB
* Renamed it to *TEAL*
* Left the source database intact for rollback

You may now [*proceed to the next lab*](#next).

## Learn More

Refreshable clone PDB is a good technique for multitenant migration. It leaves the source non-CDB intact for rollback. It also builds a copy of the non-CDB in advance, which minimizes the downtime window. However, you need additional disk space to hold a copy of the data files.

You can also use the method for databases that are already a PDB, on-prem to cloud migrations, Exascale migrations, or anywhere where you can establish a database link.

* Documentation, [Local Parameters for the AutoUpgrade Configuration File](https://docs.oracle.com/en/database/oracle/oracle-database/26/upgrd/upgrade-parameters-autoupgrade-config-file.html#GUID-E3064569-8BEB-424C-B05C-9559E2DC3342)
* Webinar, [Move to Oracle Database 23ai – Everything you need to know about Oracle Multitenant – Part 1](https://www.youtube.com/watch?v=k0wCWbp-htU&t=3960s)
* Slides, [Move to Oracle Database 23ai – Everything you need to know about Oracle Multitenant – Part 1](https://dohdatabase.com/wp-content/uploads/2024/05/vc19_multitenant_part1.pdf)
* Blog post, [Upgrade Oracle Database 19c Non-CDB to 26ai and Convert to PDB Using Refreshable Clone PDB](https://dohdatabase.com/2026/01/08/upgrade-oracle-database-19c-non-cdb-to-26ai-and-convert-to-pdb-using-refreshable-clone-pdb/)

## Acknowledgements

* **Author** - Daniel Overby Hansen
* **Contributors** - Rodrigo Jorge, Alex Zaballa, Mike Dietrich, Alejandro Diaz
* **Last Updated By/Date** - Daniel Overby Hansen, August 2026
