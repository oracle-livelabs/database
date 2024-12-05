# Advanced Patching

## Introduction

This lab allows you to patch *backwards*. In other words, going to a previous Release Update. Only in the rare cases that you find a critical issue in a newer Release Update, would you go back to a previous one. After go-live you can no longer use Flashback Database, so you need to use the rollback capabilities in Datapatch. Also, you learn how to enable certain optimizer fixes.

Estimated Time: 15 Minutes

### Objectives

In this lab, you will:

* Perform a manual rollback
* Enable optimizer fixes
* Check other software components

### Prerequisites

This lab assumes:

- You have completed Lab 2: Simple Patching With AutoUpgrade

## Task 1: Manual rollback

If you find an issue after patching, you can safely roll back to the previous patch level when you use out-of-place patching. You perform the patching process back to the original Oracle home.

1. Use the *yellow* terminal 🟨. Set the environment to the *FTEX* database and connect.

    ```
    <copy>
    . ftex
    sqlplus / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

2. Shut down the database.

    ```
    <copy>
    shutdown immediate
    </copy>
    ```

3. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```    

4. Move the SPFile and password file back to the original Oracle home. 

    ```
    <copy>
    export NEW_ORACLE_HOME=/u01/app/oracle/product/19_25
    export OLD_ORACLE_HOME=/u01/app/oracle/product/19
    mv $NEW_ORACLE_HOME/dbs/spfileFTEX.ora $OLD_ORACLE_HOME/dbs
    mv $NEW_ORACLE_HOME/dbs/orapwFTEX $OLD_ORACLE_HOME/dbs
    </copy>

    -- Be sure to hit RETURN
    ```

    * In this lab, there is no PFile, so you don't need to move that one.
    * Also, there are no network files, like `tnsnames.ora` and `sqlnet.ora` in `$ORACLE_HOME/network/admin` so you don't move those either.
    * There might be many other files in the Oracle home. Check the blog post [Files to Move During Oracle Database Out-Of-Place Patching](https://dohdatabase.com/2023/05/30/files-to-move-during-oracle-database-out-of-place-patching/) for details.

5. You need to set the environment to the previous Oracle home. Update the profile script and reset the environment.

    ```
    <copy>
    sed -i 's/^ORACLE_HOME=.*/ORACLE_HOME=\/u01\/app\/oracle\/product\/19/' /usr/local/bin/ftex
    . ftex
    env | grep ORA
    </copy>

    -- Be sure to hit RETURN
    ``` 

6. Update `/etc/oratab` to reflect the new Oracle home.

    ```
    <copy>
    sed 's/^FTEX:.*/FTEX:\/u01\/app\/oracle\/product\/19:Y/' /etc/oratab > /tmp/oratab
    cat /tmp/oratab > /etc/oratab
    grep "FTEX" /etc/oratab
    </copy>

    -- Be sure to hit RETURN
    ``` 

7. Connect to the database.

    ```
    <copy>
    sqlplus / as sysdba
    </copy>
    ```  

8. Start the database instance and exit.

    ```
    <copy>
    startup
    exit
    </copy>

    -- Be sure to hit RETURN
    ```

9. Run Datapatch to rollback the SQL changes from the database. It takes a few minutes. Leave Datapatch running and move to the next task. Do not close the terminal.

    ```
    <copy>
    $ORACLE_HOME/OPatch/datapatch
    </copy>
    ```

## Task 2: Check software components

In the Oracle home you find other software components, that is patched together with the database.

1. Switch to the *blue* 🟦 terminal. Compare the version of the JDK components in two Oracle homes.

    ```
    <copy>
    export OLD_ORACLE_HOME=/u01/app/oracle/product/19
    export NEW_ORACLE_HOME=/u01/app/oracle/product/19_25
    $OLD_ORACLE_HOME/jdk/bin/java -version
    $NEW_ORACLE_HOME/jdk/bin/java -version
    </copy>

    -- Be sure to hit RETURN
    ```

    * The *old* Oracle home is on 19.19 and the *new* is on 19.25.
    * Notice how the JDK is patched as part of the Release Update.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ export OLD_ORACLE_HOME=/u01/app/oracle/product/19
    $ export NEW_ORACLE_HOME=/u01/app/oracle/product/19_25
    $ $OLD_ORACLE_HOME/jdk/bin/java -version
    java version "1.8.0_381"
    Java(TM) SE Runtime Environment (build 1.8.0_381-b09)
    Java HotSpot(TM) 64-Bit Server VM (build 25.381-b09, mixed mode)
    $ $NEW_ORACLE_HOME/jdk/bin/java -version
    java version "1.8.0_421"
    Java(TM) SE Runtime Environment (build 1.8.0_421-b09)
    Java HotSpot(TM) 64-Bit Server VM (build 25.421-b09, mixed mode)
    ```
    </details>   

2. Compare the version of the Perl components.

    ```
    <copy>
    $OLD_ORACLE_HOME/perl/bin/perl -version | grep version
    $NEW_ORACLE_HOME/perl/bin/perl -version | grep version
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ $OLD_ORACLE_HOME/perl/bin/perl -version | grep version
    This is perl 5, version 36, subversion 0 (v5.36.0) built for x86_64-linux-thread-multi
    $ $NEW_ORACLE_HOME/perl/bin/perl -version | grep version
    This is perl 5, version 38, subversion 2 (v5.38.2) built for x86_64-linux-thread-multi
    ```
    </details>       
    
3. A Release Update also contains newer versions of the time zone file. Check the available time zone files in the old Oracle home.

    ```
    <copy>
    cd $OLD_ORACLE_HOME/oracore/zoneinfo
    ls timezone*.dat
    </copy>

    -- Be sure to hit RETURN
    ```

    * The latest version is *42*. 

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ cd $OLD_ORACLE_HOME/oracore/zoneinfo
    $ ls timezone_*dat
    timezone_10.dat  timezone_15.dat  timezone_1.dat   timezone_24.dat  timezone_29.dat  timezone_33.dat  timezone_38.dat  timezone_42.dat  timezone_8.dat
    timezone_11.dat  timezone_16.dat  timezone_20.dat  timezone_25.dat  timezone_2.dat   timezone_34.dat  timezone_39.dat  timezone_4.dat   timezone_9.dat
    timezone_12.dat  timezone_17.dat  timezone_21.dat  timezone_26.dat  timezone_30.dat  timezone_35.dat  timezone_3.dat   timezone_5.dat
    timezone_13.dat  timezone_18.dat  timezone_22.dat  timezone_27.dat  timezone_31.dat  timezone_36.dat  timezone_40.dat  timezone_6.dat
    timezone_14.dat  timezone_19.dat  timezone_23.dat  timezone_28.dat  timezone_32.dat  timezone_37.dat  timezone_41.dat  timezone_7.dat
    ```
    </details>         

3. Check the available time zone files in the new Oracle home.

    ```
    <copy>
    cd $NEW_ORACLE_HOME/oracore/zoneinfo
    ls timezone*.dat
    </copy>

    -- Be sure to hit RETURN
    ```

    * The latest version is *43*. 
    * A newer version of the time zone file was released and is automatically included in the Release Update.
    * Although a new time zone file exists in the Oracle home, it doesn't mean that the database time zone file is also patched. Time zone file update is a separate process which require additional downtime. Many customers update the time zone file only during upgrades.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ cd $NEW_ORACLE_HOME/oracore/zoneinfo
    $ ls timezone_*dat
    timezone_10.dat  timezone_15.dat  timezone_1.dat   timezone_24.dat  timezone_29.dat  timezone_33.dat  timezone_38.dat  timezone_42.dat  timezone_7.dat
    timezone_11.dat  timezone_16.dat  timezone_20.dat  timezone_25.dat  timezone_2.dat   timezone_34.dat  timezone_39.dat  timezone_43.dat  timezone_8.dat
    timezone_12.dat  timezone_17.dat  timezone_21.dat  timezone_26.dat  timezone_30.dat  timezone_35.dat  timezone_3.dat   timezone_4.dat   timezone_9.dat
    timezone_13.dat  timezone_18.dat  timezone_22.dat  timezone_27.dat  timezone_31.dat  timezone_36.dat  timezone_40.dat  timezone_5.dat
    timezone_14.dat  timezone_19.dat  timezone_23.dat  timezone_28.dat  timezone_32.dat  timezone_37.dat  timezone_41.dat  timezone_6.dat
    ```
    </details>   
    
## Task 3: Manual rollback, continued

1. Switch back to the *yellow* terminal 🟨. Datapatch should be done by now. Check the output. 

    * 19.25 Release Update and matching bundle patches were rolled back.
    * 19.21 Release Update and matching bundle patches were applied.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ $ORACLE_HOME/OPatch/datapatch
    SQL Patching tool version 19.21.0.0.0 Production on Tue Dec  3 10:55:30 2024
    Copyright (c) 2012, 2023, Oracle.  All rights reserved.
    
    Log file for this invocation: /u01/app/oracle/cfgtoollogs/sqlpatch/sqlpatch_108337_2024_12_03_10_55_30/sqlpatch_invocation.log
    
    Connecting to database...OK
    Gathering database info...done
    Bootstrapping registry and package to current versions...done
    Determining current state...done
    
    Current state of interim SQL patches:
    Interim patch 35648110 (OJVM RELEASE UPDATE: 19.21.0.0.231017 (35648110)):
      Binary registry: Installed
      SQL registry: Rolled back successfully on 02-DEC-24 10.38.13.950615 AM
    Interim patch 35787077 (DATAPUMP BUNDLE PATCH 19.21.0.0.0):
      Binary registry: Installed
      SQL registry: Rolled back successfully on 02-DEC-24 10.38.14.099176 AM
    Interim patch 36878697 (OJVM RELEASE UPDATE: 19.25.0.0.241015 (36878697)):
      Binary registry: Not installed
      SQL registry: Applied successfully on 02-DEC-24 10.38.13.971532 AM
    Interim patch 37056207 (DATAPUMP BUNDLE PATCH 19.25.0.0.0):
      Binary registry: Not installed
      SQL registry: Applied successfully on 02-DEC-24 10.39.49.664582 AM
    
    Current state of release update SQL patches:
      Binary registry:
        19.21.0.0.0 Release_Update 230930151951: Installed
      SQL registry:
        Applied 19.25.0.0.0 Release_Update 241010184253 successfully on 02-DEC-24 10.39.09.610198 AM
    
    Adding patches to installation queue and performing prereq checks...done
    Installation queue:
      The following interim patches will be rolled back:
        36878697 (OJVM RELEASE UPDATE: 19.25.0.0.241015 (36878697))
        37056207 (DATAPUMP BUNDLE PATCH 19.25.0.0.0)
      Patch 36912597 (Database Release Update : 19.25.0.0.241015 (36912597)):
        Rollback from 19.25.0.0.0 Release_Update 241010184253 to 19.21.0.0.0 Release_Update 230930151951
      The following interim patches will be applied:
        35648110 (OJVM RELEASE UPDATE: 19.21.0.0.231017 (35648110))
        35787077 (DATAPUMP BUNDLE PATCH 19.21.0.0.0)
    
    Installing patches...
    Patch installation complete.  Total patches installed: 5
    
    Validating logfiles...done
    Patch 36878697 rollback: SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/36878697/25797620/36878697_rollback_FTEX_2024Dec03_10_55_55.log (no errors)
    Patch 37056207 rollback: SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/37056207/25840925/37056207_rollback_FTEX_2024Dec03_10_55_55.log (no errors)
    Patch 36912597 rollback: SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/36912597/25871884/36912597_rollback_FTEX_2024Dec03_10_55_55.log (no errors)
    Patch 35648110 apply: SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/35648110/25365038/35648110_apply_FTEX_2024Dec03_10_55_55.log (no errors)
    Patch 35787077 apply: SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/35787077/25410019/35787077_apply_FTEX_2024Dec03_10_56_56.log (no errors)
    SQL Patching tool complete on Tue Dec  3 10:57:40 2024
    ```
    </details>   

2. Connect to the database.

    ```
    <copy>
    sqlplus / as sysdba
    </copy>
    ```

3. Certain directories in the database points to the Oracle home. Check the directories.

    ```
    <copy>
    set line 200
    set pagesize 100
    col directory_name format a25
    col directory_path format a50
    select directory_name , directory_path from dba_directories where owner='SYS' order by 2;
    </copy>

    -- Be sure to hit RETURN
    ```

    * Notice how many of the directories point to a path in the 19.25 Oracle home.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> select directory_name , directory_path from dba_directories where owner='SYS' order by 2;
    
    DIRECTORY_NAME            DIRECTORY_PATH
    ------------------------- --------------------------------------------------
    ORACLE_BASE               /u01/app/oracle
    OPATCH_INST_DIR           /u01/app/oracle/product/19/OPatch
    OPATCH_SCRIPT_DIR         /u01/app/oracle/product/19/QOpatch
    JAVA$JOX$CUJS$DIRECTORY$  /u01/app/oracle/product/19/javavm/admin/
    OPATCH_LOG_DIR            /u01/app/oracle/product/19/rdbms/log
    ORACLE_HOME               /u01/app/oracle/product/19_25
    ORACLE_OCM_CONFIG_DIR     /u01/app/oracle/product/19_25/ccr/state
    ORACLE_OCM_CONFIG_DIR2    /u01/app/oracle/product/19_25/ccr/state
    DBMS_OPTIM_LOGDIR         /u01/app/oracle/product/19_25/cfgtoollogs
    DBMS_OPTIM_ADMINDIR       /u01/app/oracle/product/19_25/rdbms/admin
    DATA_PUMP_DIR             /u01/app/oracle/product/19_25/rdbms/log/
    XMLDIR                    /u01/app/oracle/product/19_25/rdbms/xml
    XSDDIR                    /u01/app/oracle/product/19_25/rdbms/xml/schema
    
    13 rows selected.
    ```
    </details>   

4. Update the directories.

    ```
    <copy>
    @?/rdbms/admin/utlfixdirs.sql
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> @?/rdbms/admin/utlfixdirs.sql
    
    Container: ftex
    
    Current  ORACLE_HOME: /u01/app/oracle/product/19
    Original ORACLE_HOME: /u01/app/oracle/product/19_25
    
    
    DATA_PUMP_DIR
    ...OLD: /u01/app/oracle/product/19_25/rdbms/log/
    ...NEW: /u01/app/oracle/product/19/rdbms/log/
    DBMS_OPTIM_ADMINDIR
    ...OLD: /u01/app/oracle/product/19_25/rdbms/admin
    ...NEW: /u01/app/oracle/product/19/rdbms/admin
    DBMS_OPTIM_LOGDIR
    ...OLD: /u01/app/oracle/product/19_25/cfgtoollogs
    ...NEW: /u01/app/oracle/product/19/cfgtoollogs
    ORACLE_HOME
    ...OLD: /u01/app/oracle/product/19_25
    ...NEW: /u01/app/oracle/product/19
    ORACLE_OCM_CONFIG_DIR
    ...OLD: /u01/app/oracle/product/19_25/ccr/state
    ...NEW: /u01/app/oracle/product/19/ccr/state
    ORACLE_OCM_CONFIG_DIR2
    ...OLD: /u01/app/oracle/product/19_25/ccr/state
    ...NEW: /u01/app/oracle/product/19/ccr/state
    XMLDIR
    ...OLD: /u01/app/oracle/product/19_25/rdbms/xml
    ...NEW: /u01/app/oracle/product/19/rdbms/xml
    XSDDIR
    ...OLD: /u01/app/oracle/product/19_25/rdbms/xml/schema
    ...NEW: /u01/app/oracle/product/19/rdbms/xml/schema
    
    PL/SQL procedure successfully completed.
    ```
    </details>   

5. Check the directories again.

    ```
    <copy>
    set line 200
    set pagesize 100
    col directory_name format a25
    col directory_path format a50
    select directory_name , directory_path from dba_directories where owner='SYS' order by 2;
    </copy>

    -- Be sure to hit RETURN
    ```

    * All of them now points to the current Oracle home.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> select directory_name , directory_path from dba_directories where owner='SYS' order by 2;
    
    DIRECTORY_NAME            DIRECTORY_PATH
    ------------------------- --------------------------------------------------
    ORACLE_BASE               /u01/app/oracle
    OPATCH_INST_DIR           /u01/app/oracle/product/19/OPatch
    OPATCH_SCRIPT_DIR         /u01/app/oracle/product/19/QOpatch
    JAVA$JOX$CUJS$DIRECTORY$  /u01/app/oracle/product/19/javavm/admin/
    OPATCH_LOG_DIR            /u01/app/oracle/product/19/rdbms/log
    ORACLE_HOME               /u01/app/oracle/product/19
    ORACLE_OCM_CONFIG_DIR     /u01/app/oracle/product/19/ccr/state
    ORACLE_OCM_CONFIG_DIR2    /u01/app/oracle/product/19/ccr/state
    DBMS_OPTIM_LOGDIR         /u01/app/oracle/product/19/cfgtoollogs
    DBMS_OPTIM_ADMINDIR       /u01/app/oracle/product/19/rdbms/admin
    DATA_PUMP_DIR             /u01/app/oracle/product/19/rdbms/log/
    XMLDIR                    /u01/app/oracle/product/19/rdbms/xml
    XSDDIR                    /u01/app/oracle/product/19/rdbms/xml/schema
    
    13 rows selected.
    ```
    </details>   

## Task 4: Enable optimizer fixes

Optimizer fixes are provided as part of the Release Update. However, those optimizer fixes which might cause plan changes are turned off. Meaning the fix is present in the database, but the old code is still activated. This allows you to maintain maximum plan stability in your database and only turn on those optimizer fixes that you need for a given problem.

1. List all the optimizer fixes that were added by the last Release Update. 

    ```
    <copy>
    set serveroutput on;
    execute dbms_optim_bundle.getBugsforBundle;
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> set serveroutput on;
    execute dbms_optim_bundle.getBugsforBundle;SQL>
    
    19.21.0.0.231017DBRU:
        Bug: 34044661,  fix_controls: 34044661
        Bug: 34544657,  fix_controls: 33549743
        Bug: 34816383,  fix_controls: 34816383
        Bug: 35330506,  fix_controls: 35330506
    
    PL/SQL procedure successfully completed.
    ```
    </details>   

2. List all the previous Release Updates that has optimizer fixes.

    ```
    <copy>
    exec dbms_optim_bundle.listBundlesWithFCFixes;
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> exec dbms_optim_bundle.listBundlesWithFCFixes;
    bundleId: 190719,  bundleName: 19.4.0.0.190719DBRU
    bundleId: 191015,  bundleName: 19.5.0.0.191015DBRU
    bundleId: 200114,  bundleName: 19.6.0.0.200114DBRU
    bundleId: 200414,  bundleName: 19.7.0.0.200414DBRU
    bundleId: 200714,  bundleName: 19.8.0.0.200714DBRU
    bundleId: 201020,  bundleName: 19.9.0.0.201020DBRU
    bundleId: 210119,  bundleName: 19.10.0.0.210119DBRU
    bundleId: 210420,  bundleName: 19.11.0.0.210420DBRU
    bundleId: 210720,  bundleName: 19.12.0.0.210720DBRU
    bundleId: 211019,  bundleName: 19.13.0.0.211019DBRU
    bundleId: 220118,  bundleName: 19.14.0.0.220118DBRU
    bundleId: 220419,  bundleName: 19.15.0.0.220419DBRU
    bundleId: 220719,  bundleName: 19.16.0.0.220719DBRU
    bundleId: 221018,  bundleName: 19.17.0.0.221018DBRU
    bundleId: 230117,  bundleName: 19.18.0.0.230117DBRU
    bundleId: 230418,  bundleName: 19.19.0.0.230418DBRU
    bundleId: 230718,  bundleName: 19.20.0.0.230718DBRU
    bundleId: 231017,  bundleName: 19.21.0.0.231017DBRU

    PL/SQL procedure successfully completed.
    ```
    </details>       

3. Check which fixes were included in the 19.4 Release Update.

    ```
    <copy>
    execute dbms_optim_bundle.getBugsforBundle(190719);
    </copy>
    ```

    * *190719* is the bundle ID from the previous command.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> execute dbms_optim_bundle.getBugsforBundle(190719);
    
    19.4.0.0.190719DBRU:
        Bug: 29331066,  fix_controls: 29331066
    
    PL/SQL procedure successfully completed.
    ```
    </details>       

4. The state of each optimizer fix is recorded in the parameter `_fix_control`. Check the value of it.

    ```
    <copy>
    select value from v$system_parameter where name='_fix_control';
    </copy>
    ```

    * It is currently empty because no fixed have been turned on.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> select value from v$system_parameter where name='_fix_control';
    
    no rows selected
    ```
    </details>       

5. Turn all fixes *ON*. 

    ```
    <copy>
    execute dbms_optim_bundle.enable_optim_fixes('ON','BOTH', 'YES');
    </copy>
    ```

    * Normally, Oracle recommends turning all fixes *ON* only for new databases or when you are upgrading to a new release. 
    * When you upgrade you typically perform extensive testing and then you can better check the effect on all the new optimizer fixes.
    * Since optimizer fixes may cause plan changes, you typically don't do this after patching, because you often conduct less test compared to an upgrade.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> execute dbms_optim_bundle.enable_optim_fixes('ON','BOTH', 'YES');
    
    ....
    
    PL/SQL procedure successfully completed.
    ```
    </details>      

6. Check the setting of the `_fix_control` parameter.

    ```
    <copy>
    set pagesize 1000
    select replace(value, ', ', chr(10)) as fixes from v$system_parameter where name='_fix_control';
    </copy>

    -- Be sure to hit RETURN
    ```

    * The output is formatted which a fix on each line.
    * You can look up a specific fix in My Oracle Support to learn more about it.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> set pagesize 1000
    SQL> select replace(value, ', ', chr(10)) as fixes from v$system_parameter where name='_fix_control';
    
    FIXES
    --------------------------------------------------------------------------------
    29331066:1
    28965084:1
    28776811:1
    28498976:1
    28567417:1
    ....
    (output truncated)
    ....
    35412607:1
    34044661:1
    33549743:0
    34816383:0
    35330506:1    
    ```
    </details>   

7. Selectively turn a fix *OFF*. 

    ```
    <copy>
    exec dbms_optim_bundle.set_fix_controls('35330506:0','*', 'BOTH','NO');
    </copy>
    ```

    * *35330506* is one of the fixes from the output of the previous command.
    * You can use the procedure to turn fixes *ON* as well.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> exec dbms_optim_bundle.set_fix_controls('35330506:0','*', 'BOTH','NO');
    DBMS_OPTIM command: dbms_optim_bundle.set_fix_controls('35330506:0', '*','BOTH', 'NO')
    
    1) Current _fix_control setting for spfile:
    28965084:1  28776811:1	28567417:1  29132869:1	31444353:0  30927440:1
    24561942:1  17295505:1	30646077:1  29463553:1	31580374:1  28173995:1
    29867728:1  31974424:1	28708585:1  26758837:1	32205825:1  31912834:1
    31843716:0  33443834:1	34028486:1  34816383:0	35330506:1  30001331:0
    ....
    (putput truncated)
    ....  
    31009032:1  30235691:1	28234255:3  31143146:1	32578113:1  32800137:0
    31050103:1  32856375:1	32396085:1  31582179:1	30978868:1  34092979:0
    18101156:0  29499077:1	31487332:1  25869323:1	33421972:0
    
    3) Current _fix_control setting in memory for sid = FTEX
    35330506:1
    
    4) Final _fix_control setting for memory considering current_setting_precedence
    is NO
    35330506:0
    
    PL/SQL procedure successfully completed.
    ```
    </details>      

8. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```    

You may now *proceed to the next lab*.

## Acknowledgements

* **Author** - Daniel Overby Hansen
* **Contributors** - Rodrigo Jorge, Alex Zaballa, Mike Dietrich
* **Last Updated By/Date** - Daniel Overby Hansen, December 2024