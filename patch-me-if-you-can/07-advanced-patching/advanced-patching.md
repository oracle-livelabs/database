# Advanced Patching

## Introduction

This lab allows you to patch *back to an earlier Release Update*. You would do this only in the rare case that you find a critical issue in a newer Release Update. You will also learn how to enable certain optimizer fixes.

Estimated Time: 20 Minutes

### Objectives

In this lab, you will:

* Perform an AutoUpgrade rollback
* Perform a manual rollback
* Enable optimizer fixes
* Check other software components

### Prerequisites

This lab assumes:

* You have completed Lab 4: Simple Patching to Existing Oracle Home
* You have completed Lab 5: Install Oracle Home - Continued
* You have completed Lab 6: Manual Patching of a Container Database

## Task 1: Rollback Using AutoUpgrade

In Lab 4, you patched the *UPGR* database to 19.32. Imagine that you found a critical issue and decided to go back to 19.31. You can roll back with Datapatch without losing data.

1. Use the *yellow* terminal 🟨. Since you patched the database using AutoUpgrade, you can roll back as well. Start AutoUpgrade:

    ``` bash
    <copy>
    java -jar autoupgrade.jar -config scripts/pt-04-simple-patching-existing-home.cfg -rollback -jobs 101
    </copy>
    ```

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

2. AutoUpgrade needs a few minutes to perform the rollback. Leave AutoUpgrade running.

## Task 2: Manual Rollback

You can also roll back manually. In Lab 6, you patched the *CDB19* database to 19.32. Now, you will roll back to 19.31.

1. Use the *blue* terminal 🟦. Set the environment to the *CDB19* database and connect.

    ``` sql
    <copy>
    . cdb19
    sql / as sysdba
    </copy>
    ```

2. Shut down the database.

    ``` sql
    <copy>
    shutdown immediate
    </copy>
    ```

3. Exit SQLcl.

    ``` bash
    <copy>
    exit
    </copy>
    ```

4. Move the SPFile and password file back to the original Oracle home.

    ``` bash
    <copy>
    export NEW_ORACLE_HOME=/u01/app/oracle/product/dbhome_19_32
    export OLD_ORACLE_HOME=/u01/app/oracle/product/19
    mv $NEW_ORACLE_HOME/dbs/spfileCDB19.ora $OLD_ORACLE_HOME/dbs
    mv $NEW_ORACLE_HOME/dbs/orapwCDB19 $OLD_ORACLE_HOME/dbs
    </copy>

    # Be sure to press RETURN
    ```

    * In this lab, there is no PFile, so you don't need to move that one.
    * There are also no network files, such as `tnsnames.ora` and `sqlnet.ora`, in `$ORACLE_HOME/network/admin`, so you do not move those either.
    * There might be many other files in the Oracle home. Check the blog post [Files to Move During Oracle Database Out-Of-Place Patching](https://dohdatabase.com/2023/05/30/files-to-move-during-oracle-database-out-of-place-patching/) for details.

5. You need to set the environment to the previous Oracle home. Update the profile script and reset the environment.

    ``` bash
    <copy>
    sed -i 's|^ORACLE_HOME=.*|ORACLE_HOME=/u01/app/oracle/product/19|' /usr/local/bin/cdb19
    . cdb19
    env | grep ORA
    </copy>

    # Be sure to press RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    ORACLE_SID=CDB19
    ORACLE_BASE=/u01/app/oracle
    ORACLE_HOME=/u01/app/oracle/product/19
    NEW_ORACLE_HOME=/u01/app/oracle/product/dbhome_19_32
    OLD_ORACLE_HOME=/u01/app/oracle/product/19
    ```

    </details>

6. Update `/etc/oratab` to reflect the new Oracle home.

    ``` bash
    <copy>
    sed 's|^CDB19:.*|CDB19:/u01/app/oracle/product/19:Y|' /etc/oratab > /tmp/oratab
    cat /tmp/oratab > /etc/oratab
    grep "CDB19:" /etc/oratab
    </copy>

    # Be sure to press RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    CDB19:/u01/app/oracle/product/19:Y
    ```

    </details>

7. Connect to the database.

    ``` sql
    <copy>
    sql / as sysdba
    </copy>
    ```

8. Start the database instance and exit.

    ``` sql
    <copy>
    startup
    alter pluggable database all open;
    exit
    </copy>
    ```

9. Run Datapatch to rollback the SQL changes from the database. It takes a few minutes. Leave Datapatch running and move to the next task. Do not close the terminal.

    ``` bash
    <copy>
    $ORACLE_HOME/OPatch/datapatch
    </copy>
    ```

## Task 3: Rollback Using AutoUpgrade, Continued

In Task 1, you left AutoUpgrade while it performed the rollback of *UPGR*.

1. Switch back to the *yellow* terminal 🟨. AutoUpgrade should have completed the rollback.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    Previous execution found loading latest data
    Total jobs being restored: 1
    +--------------------------------+
    | Starting AutoUpgrade execution |
    +--------------------------------+
    Job 101 completed
    ------------------- Final Summary --------------------
    Number of databases            [ 1 ]

    Jobs restored                  [1]
    Jobs failed                    [0]
    Please check the summary report at:
    /home/oracle/logs/simple-patching-existing-home/cfgtoollogs/upgrade/auto/status/status.html
    /home/oracle/logs/simple-patching-existing-home/cfgtoollogs/upgrade/auto/status/status.log
    Exiting
    ```

    </details>

2. Update the profile script. This lab has a profile script for each database that configures the environment accordingly. Since the database now runs out of the original Oracle home, you must update the profile script. This command replaces the `ORACLE_HOME` variable in the profile script.

    ``` bash
    <copy>
    sed -i 's|^ORACLE_HOME=.*|ORACLE_HOME=/u01/app/oracle/product/19|' /usr/local/bin/upgr
    </copy>
    ```

3. Check the `oratab` file.

    ``` bash
    <copy>
    grep UPGR /etc/oratab
    </copy>
    ```

    * As part of the rollback, AutoUpgrade updated `/etc/oratab`.
    * It also moved database configuration files, such as SPFile and password file, back to the original Oracle home.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    UPGR:/u01/app/oracle/product/19:Y
    ```

    </details>

4. Set the environment and connect to *UPGR*.

    ``` sql
    <copy>
    . upgr
    sql / as sysdba
    </copy>
    ```

5. Verify the database version.

    ``` sql
    <copy>
    select version_full from v$instance;
    </copy>
    ```

    * *UPGR* runs in the original Oracle home and on 19.31.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    VERSION_FULL
    _______________
    19.31.0.0.0
    ```

    </details>

6. Exit SQLcl.

    ``` bash
    <copy>
    exit
    </copy>
    ```

## Task 4: Manual Rollback, Continued

In Task 2, you left Datapatch while it applied the SQL changes to *CDB19* to complete the rollback.

1. Switch back to the *blue* terminal 🟦.

2. Datapatch should be done by now. Check the output.

    * 19.32 Release Update and matching bundle patches were rolled back.
    * 19.31 Release Update and matching bundle patches were applied.
    * The report first shows the current 19.32 SQL patch state, then shows the rollback actions that return the database to 19.31.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL Patching tool version 19.31.0.0.0 Production on Wed Sep  2 09:16:32 2026
    Copyright (c) 2012, 2026, Oracle.  All rights reserved.

    Log file for this invocation: /u01/app/oracle/cfgtoollogs/sqlpatch/sqlpatch_126847_2026_09_02_09_16_32/sqlpatch_invocation.log

    Connecting to database...OK
    Gathering database info...done

    Note:  Datapatch will only apply or rollback SQL fixes for PDBs
           that are in an open state, no patches will be applied to closed PDBs.
           Please refer to Note: Datapatch: Database 12c Post Patch SQL Automation
           (Doc ID 1585822.1)

    Bootstrapping registry and package to current versions...done
    Determining current state...done

    Current state of interim SQL patches:
    Interim patch 38194382 (OJVM RELEASE UPDATE: 19.29.0.0.251021 (38194382)):
      Binary registry: Not installed
      PDB CDB$ROOT: Not installed
      PDB ORANGE: Not installed
      PDB PDB$SEED: Not installed
      PDB TERRACOTTA: Not installed
      PDB INDIGO: Not installed
    Interim patch 38523609 (OJVM RELEASE UPDATE: 19.30.0.0.260120 (38523609)):
      Binary registry: Not installed
      PDB CDB$ROOT: Not installed
      PDB ORANGE: Not installed
      PDB PDB$SEED: Not installed
      PDB TERRACOTTA: Not installed
      PDB INDIGO: Not installed
    Interim patch 38535360 (DATAPUMP BUNDLE PATCH 19.29.0.0.0):
      Binary registry: Not installed
      PDB CDB$ROOT: Not installed
      PDB ORANGE: Not installed
      PDB PDB$SEED: Not installed
      PDB TERRACOTTA: Not installed
      PDB INDIGO: Not installed
    Interim patch 38844367 (19.30 OJVM PATCH APPLY IS FAILING ON SECOND NODE IN RAC ENVIRONMENT):
      Binary registry: Not installed
      PDB CDB$ROOT: Not installed
      PDB ORANGE: Not installed
      PDB PDB$SEED: Not installed
      PDB TERRACOTTA: Not installed
      PDB INDIGO: Not installed
    Interim patch 38844733 (DATAPUMP BUNDLE PATCH 19.30.0.0.0):
      Binary registry: Not installed
      PDB CDB$ROOT: Not installed
      PDB ORANGE: Not installed
      PDB PDB$SEED: Not installed
      PDB TERRACOTTA: Not installed
      PDB INDIGO: Not installed
    Interim patch 38906621 (OJVM RELEASE UPDATE: 19.31.0.0.260421 (38906621)):
      Binary registry: Installed
      PDB CDB$ROOT: Rolled back successfully on 02-SEP-26 08.39.39.597794 AM
      PDB ORANGE: Rolled back successfully on 02-SEP-26 08.40.24.396895 AM
      PDB PDB$SEED: Rolled back successfully on 02-SEP-26 08.40.24.300039 AM
      PDB TERRACOTTA: Rolled back successfully on 02-SEP-26 08.40.24.406620 AM
      PDB INDIGO: Rolled back successfully on 02-SEP-26 08.40.24.406620 AM
    Interim patch 39196236 (DATAPUMP BUNDLE PATCH 19.31.0.0.0):
      Binary registry: Installed
      PDB CDB$ROOT: Rolled back successfully on 02-SEP-26 08.39.40.227002 AM
      PDB ORANGE: Rolled back successfully on 02-SEP-26 08.40.25.200260 AM
      PDB PDB$SEED: Rolled back successfully on 02-SEP-26 08.40.24.978736 AM
      PDB TERRACOTTA: Rolled back successfully on 02-SEP-26 08.40.25.211283 AM
      PDB INDIGO: Rolled back successfully on 02-SEP-26 08.40.25.211283 AM
    Interim patch 39222882 (OJVM RELEASE UPDATE: 19.32.0.0.260721 (39222882)):
      Binary registry: Not installed
      PDB CDB$ROOT: Applied successfully on 02-SEP-26 08.39.39.662600 AM
      PDB ORANGE: Applied successfully on 02-SEP-26 08.40.24.481642 AM
      PDB PDB$SEED: Applied successfully on 02-SEP-26 08.40.24.370309 AM
      PDB TERRACOTTA: Applied successfully on 02-SEP-26 08.40.24.476454 AM
      PDB INDIGO: Applied successfully on 02-SEP-26 08.40.24.476454 AM
    Interim patch 39657094 (DATAPUMP BUNDLE PATCH 19.32.0.0.0):
      Binary registry: Not installed
      PDB CDB$ROOT: Applied successfully on 02-SEP-26 08.40.22.856727 AM
      PDB ORANGE: Applied successfully on 02-SEP-26 08.40.43.071173 AM
      PDB PDB$SEED: Applied successfully on 02-SEP-26 08.40.42.210025 AM
      PDB TERRACOTTA: Applied successfully on 02-SEP-26 08.40.42.928391 AM
      PDB INDIGO: Applied successfully on 02-SEP-26 08.40.42.928391 AM

    Current state of release update SQL patches:
      Binary registry:
        19.31.0.0.0 Release_Update 260514003012: Installed
      PDB CDB$ROOT:
        Applied 19.32.0.0.0 Release_Update 260705220710 successfully on 02-SEP-26 08.39.58.389938 AM
      PDB ORANGE:
        Applied 19.32.0.0.0 Release_Update 260705220710 successfully on 02-SEP-26 08.40.34.429431 AM
      PDB PDB$SEED:
        Applied 19.32.0.0.0 Release_Update 260705220710 successfully on 02-SEP-26 08.40.33.866042 AM
      PDB TERRACOTTA:
        Applied 19.32.0.0.0 Release_Update 260705220710 successfully on 02-SEP-26 08.40.34.380717 AM
      PDB INDIGO:
        Applied 19.32.0.0.0 Release_Update 260705220710 successfully on 02-SEP-26 08.40.34.380717 AM

    Adding patches to installation queue and performing prereq checks...done
    Installation queue:
      For the following PDBs: CDB$ROOT PDB$SEED ORANGE TERRACOTTA INDIGO
        The following interim patches will be rolled back:
          39222882 (OJVM RELEASE UPDATE: 19.32.0.0.260721 (39222882))
          39657094 (DATAPUMP BUNDLE PATCH 19.32.0.0.0)
        Patch 39472050 (Database Release Update : 19.32.0.0.260721 (39472050)):
          Rollback from 19.32.0.0.0 Release_Update 260705220710 to 19.31.0.0.0 Release_Update 260514003012
        The following interim patches will be applied:
          38906621 (OJVM RELEASE UPDATE: 19.31.0.0.260421 (38906621))
          39196236 (DATAPUMP BUNDLE PATCH 19.31.0.0.0)

    Installing patches...
    Patch installation complete.  Total patches installed: 20

    Validating logfiles...done
    Patch 39222882 rollback (pdb CDB$ROOT): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/39222882/28830205/39222882_rollback_CDB19_CDBROOT_2026Sep02_09_16_58.log (no errors)
    Patch 39657094 rollback (pdb CDB$ROOT): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/39657094/28915841/39657094_rollback_CDB19_CDBROOT_2026Sep02_09_16_58.log (no errors)
    Patch 39472050 rollback (pdb CDB$ROOT): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/39472050/28919163/39472050_rollback_CDB19_CDBROOT_2026Sep02_09_16_58.log (no errors)
    Patch 38906621 apply (pdb CDB$ROOT): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/38906621/28588735/38906621_apply_CDB19_CDBROOT_2026Sep02_09_16_58.log (no errors)
    Patch 39196236 apply (pdb CDB$ROOT): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/39196236/28705537/39196236_apply_CDB19_CDBROOT_2026Sep02_09_17_19.log (no errors)
    Patch 39222882 rollback (pdb PDB$SEED): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/39222882/28830205/39222882_rollback_CDB19_PDBSEED_2026Sep02_09_17_39.log (no errors)
    Patch 39657094 rollback (pdb PDB$SEED): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/39657094/28915841/39657094_rollback_CDB19_PDBSEED_2026Sep02_09_17_40.log (no errors)
    Patch 39472050 rollback (pdb PDB$SEED): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/39472050/28919163/39472050_rollback_CDB19_PDBSEED_2026Sep02_09_17_40.log (no errors)
    Patch 38906621 apply (pdb PDB$SEED): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/38906621/28588735/38906621_apply_CDB19_PDBSEED_2026Sep02_09_17_40.log (no errors)
    Patch 39196236 apply (pdb PDB$SEED): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/39196236/28705537/39196236_apply_CDB19_PDBSEED_2026Sep02_09_17_50.log (no errors)
    Patch 39222882 rollback (pdb ORANGE): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/39222882/28830205/39222882_rollback_CDB19_ORANGE_2026Sep02_09_17_39.log (no errors)
    Patch 39657094 rollback (pdb ORANGE): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/39657094/28915841/39657094_rollback_CDB19_ORANGE_2026Sep02_09_17_40.log (no errors)
    Patch 39472050 rollback (pdb ORANGE): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/39472050/28919163/39472050_rollback_CDB19_ORANGE_2026Sep02_09_17_40.log (no errors)
    Patch 38906621 apply (pdb ORANGE): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/38906621/28588735/38906621_apply_CDB19_ORANGE_2026Sep02_09_17_40.log (no errors)
    Patch 39196236 apply (pdb ORANGE): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/39196236/28705537/39196236_apply_CDB19_ORANGE_2026Sep02_09_17_50.log (no errors)
    Patch 39222882 rollback (pdb TERRACOTTA): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/39222882/28830205/39222882_rollback_CDB19_TERRACOTTA_2026Sep02_09_17_39.log (no errors)
    Patch 39657094 rollback (pdb TERRACOTTA): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/39657094/28915841/39657094_rollback_CDB19_TERRACOTTA_2026Sep02_09_17_40.log (no errors)
    Patch 39472050 rollback (pdb TERRACOTTA): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/39472050/28919163/39472050_rollback_CDB19_TERRACOTTA_2026Sep02_09_17_40.log (no errors)
    Patch 38906621 apply (pdb TERRACOTTA): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/38906621/28588735/38906621_apply_CDB19_TERRACOTTA_2026Sep02_09_17_40.log (no errors)
    Patch 39196236 apply (pdb TERRACOTTA): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/39196236/28705537/39196236_apply_CDB19_TERRACOTTA_2026Sep02_09_17_50.log (no errors)
    Patch 39222882 rollback (pdb INDIGO): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/39222882/28830205/39222882_rollback_CDB19_INDIGO_2026Sep02_09_17_39.log (no errors)
    Patch 39657094 rollback (pdb INDIGO): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/39657094/28915841/39657094_rollback_CDB19_INDIGO_2026Sep02_09_17_40.log (no errors)
    Patch 39472050 rollback (pdb INDIGO): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/39472050/28919163/39472050_rollback_CDB19_INDIGO_2026Sep02_09_17_40.log (no errors)
    Patch 38906621 apply (pdb INDIGO): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/38906621/28588735/38906621_apply_CDB19_INDIGO_2026Sep02_09_17_40.log (no errors)
    Patch 39196236 apply (pdb INDIGO): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/39196236/28705537/39196236_apply_CDB19_INDIGO_2026Sep02_09_17_50.log (no errors)
    SQL Patching tool complete on Wed Sep  2 09:18:19 2026
    ```

    </details>

3. Connect to the database.

    ``` sql
    <copy>
    sql / as sysdba
    </copy>
    ```

4. Update the directories that points to the Oracle home.

    ``` python
    <copy>
    @?/rdbms/admin/utlfixdirs.sql
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> @?/rdbms/admin/utlfixdirs.sql

    Container: cdb19

    Current  ORACLE_HOME: /u01/app/oracle/product/19
    Original ORACLE_HOME: /u01/app/oracle/product/dbhome_19_32


    DATA_PUMP_DIR
    ...OLD: /u01/app/oracle/product/dbhome_19_32/rdbms/log/
    ...NEW: /u01/app/oracle/product/19/rdbms/log/
    DBMS_OPTIM_ADMINDIR
    ...OLD: /u01/app/oracle/product/dbhome_19_32/rdbms/admin
    ...NEW: /u01/app/oracle/product/19/rdbms/admin
    DBMS_OPTIM_LOGDIR
    ...OLD: /u01/app/oracle/product/dbhome_19_32/cfgtoollogs
    ...NEW: /u01/app/oracle/product/19/cfgtoollogs
    ORACLE_HOME
    ...OLD: /u01/app/oracle/product/dbhome_19_32
    ...NEW: /u01/app/oracle/product/19
    XMLDIR
    ...OLD: /u01/app/oracle/product/dbhome_19_32/rdbms/xml
    ...NEW: /u01/app/oracle/product/19/rdbms/xml
    XSDDIR
    ...OLD: /u01/app/oracle/product/dbhome_19_32/rdbms/xml/schema
    ...NEW: /u01/app/oracle/product/19/rdbms/xml/schema

    PL/SQL procedure successfully completed.
    ```

    </details>

5. Check the directories.

    ``` sql
    <copy>
    select directory_name , directory_path from dba_directories where owner='SYS' order by 2;
    </copy>
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

6. Exit SQLcl.

    ``` bash
    <copy>
    exit
    </copy>
    ```

## Task 5: Check Software Components

In the Oracle home you find other software components, that is patched together with the database.

1. Remain in the *blue* terminal 🟦. Compare the version of the JDK components in two Oracle homes.

    ``` bash
    <copy>
    export OLD_ORACLE_HOME=/u01/app/oracle/product/19
    export NEW_ORACLE_HOME=/u01/app/oracle/product/dbhome_19_32
    $OLD_ORACLE_HOME/jdk/bin/java -version
    $NEW_ORACLE_HOME/jdk/bin/java -version
    </copy>

    # Be sure to press RETURN
    ```

    * The *old* Oracle home is on 19.31 and the *new* is on 19.32.
    * Notice how the JDK is patched as part of the Release Update.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    $ export OLD_ORACLE_HOME=/u01/app/oracle/product/19
    $ export NEW_ORACLE_HOME=/u01/app/oracle/product/dbhome_19_32
    $ $OLD_ORACLE_HOME/jdk/bin/java -version

    java version "1.8.0_481"
    Java(TM) SE Runtime Environment (build 1.8.0_481-b10)
    Java HotSpot(TM) 64-Bit Server VM (build 25.481-b10, mixed mode)
    $ $NEW_ORACLE_HOME/jdk/bin/java -version

    java version "1.8.0_491"
    Java(TM) SE Runtime Environment (build 1.8.0_491-b10)
    Java HotSpot(TM) 64-Bit Server VM (build 25.491-b10, mixed mode)
    ```

    </details>

2. Compare two Oracle homes on 19.32.

    ``` bash
    <copy>
    export ORACLE_HOME_1=/u01/app/oracle/product/dbhome_19_32
    export ORACLE_HOME_2=/u01/app/oracle/product/dbhome_19_32_au
    $ORACLE_HOME_1/jdk/bin/java -version
    $ORACLE_HOME_2/jdk/bin/java -version
    </copy>

    # Be sure to press RETURN
    ```

    * Both Oracle homes are on 19.32. Why is there a difference in the JDK version?
    * *Oracle home 1* is patched with the 19.32 Release Update. The Release Update contains a recent update to JDK, but not the newest.
    * You created *Oracle home 2* in lab 2. You told AutoUpgrade to include the newest update to JDK. You did that with the *JDK* keyword in the `patch` specification.
    * The new Release Update and JDK patch are built at the same time. This leaves no time to include the newest JDK in the new Release Update. The newest JDK is made available as a one-off patch and scheduled to be included in a coming Release Update.
    * But you can stay fully up-to-date by using AutoUpgrade and instruct it to include the newest JDK patch.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    $ export ORACLE_HOME_1=/u01/app/oracle/product/dbhome_19_32
    $ export ORACLE_HOME_2=/u01/app/oracle/product/dbhome_19_32_au
    $ $ORACLE_HOME_1/jdk/bin/java -version

    java version "1.8.0_491"
    Java(TM) SE Runtime Environment (build 1.8.0_491-b10)
    Java HotSpot(TM) 64-Bit Server VM (build 25.491-b10, mixed mode)

    $ $ORACLE_HOME_2/jdk/bin/java -version

    java version "1.8.0_503"
    Java(TM) SE Runtime Environment (build 1.8.0_503-b01)
    Java HotSpot(TM) 64-Bit Server VM (build 25.503-b01, mixed mode)
    ```

    </details>

3. Compare the version of the Perl components.

    ``` bash
    <copy>
    $OLD_ORACLE_HOME/perl/bin/perl -version | grep version
    $NEW_ORACLE_HOME/perl/bin/perl -version | grep version
    </copy>

    # Be sure to press RETURN
    ```

    * Perl is up to date in both Oracle homes.
    * Perl patches are included in Release Updates, but apparently there were no Perl updates when 19.32 was built.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    $ $OLD_ORACLE_HOME/perl/bin/perl -version | grep version
    This is perl 5, version 38, subversion 4 (v5.38.4) built for x86_64-linux-thread-multi
    $ $NEW_ORACLE_HOME/perl/bin/perl -version | grep version
    This is perl 5, version 38, subversion 4 (v5.38.4) built for x86_64-linux-thread-multi
    ```

    </details>

## Task 6: Enable Optimizer Fixes

Optimizer fixes are provided as part of the Release Update. However, optimizer fixes that might cause plan changes are turned off. This means that the fixes are present in the database, but the old code is still active. This allows you to maintain maximum plan stability in your database and turn on only the optimizer fixes that you need for a given problem.

1. Switch to the *yellow* terminal 🟨. Set the environment to the *BEIGE* database and connect.

    ``` sql
    <copy>
    . beige
    sql / as sysdba
    </copy>
    ```

2. List all the optimizer fixes that were added by the last Release Update.

    ``` sql
    <copy>
    set serveroutput on;
    execute dbms_optim_bundle.getBugsforBundle;
    </copy>
    ```

    * *BEIGE* has already been patched to 19.31.
    * 19.31 contained no optimizer fixes, so the latest Release Update with optimizer fixes is 19.30.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    19.30.0.0.260120DBRU:
        Bug: 34807859,  fix_controls: 34807859
        Bug: 37695497,  fix_controls: 37695497
        Bug: 31495387,  fix_controls: 31495387
        Bug: 33875479,  fix_controls: 32455005
        Bug: 34396205,  fix_controls: 34396205


    PL/SQL procedure successfully completed.
    ```

    </details>

3. List all the previous Release Updates that has optimizer fixes.

    ``` sql
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
    bundleId: 240116,  bundleName: 19.22.0.0.240116DBRU
    bundleId: 240416,  bundleName: 19.23.0.0.240416DBRU
    bundleId: 240716,  bundleName: 19.24.0.0.240716DBRU
    bundleId: 241015,  bundleName: 19.25.0.0.241015DBRU
    bundleId: 250121,  bundleName: 19.26.0.0.250121DBRU
    bundleId: 250415,  bundleName: 19.27.0.0.250415DBRU
    bundleId: 250715,  bundleName: 19.28.0.0.250715DBRU
    bundleId: 251021,  bundleName: 19.29.0.0.251021DBRU
    bundleId: 260120,  bundleName: 19.30.0.0.260120DBRU

    PL/SQL procedure successfully completed.
    ```

    </details>

4. Check which fixes were included in the 19.4 Release Update.

    ``` sql
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

5. The state of each optimizer fix is recorded in the parameter `_fix_control`. Check the value of it.

    ``` sql
    <copy>
    select value from v$system_parameter where name='_fix_control';
    </copy>
    ```

    * It is currently empty because no fixes have been turned on.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> select value from v$system_parameter where name='_fix_control';

    no rows selected
    ```

    </details>

6. Turn all fixes *ON*.

    ``` sql
    <copy>
    execute dbms_optim_bundle.enable_optim_fixes('ON','BOTH', 'YES');
    </copy>
    ```

    * Normally, Oracle recommends turning all fixes *ON* only for new databases or when you are upgrading to a new release.
    * When you upgrade, you typically perform extensive testing, so you can better evaluate the effects of all the new optimizer fixes.
    * Since optimizer fixes may cause plan changes, you typically do not do this after patching because you often conduct less testing than during an upgrade.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> execute dbms_optim_bundle.enable_optim_fixes('ON','BOTH', 'YES');

    ....
    (output truncated)
    ....

    PL/SQL procedure successfully completed.
    ```

    </details>

7. Check the setting of the `_fix_control` parameter.

    ``` sql
    <copy>
    select value from v$system_parameter where name='_fix_control';
    </copy>
    ```

    * The output is formatted as a comma-separated string.
    * Each element is a key-value pair with the bug number and the setting.
    * You can look up a specific fix in My Oracle Support to learn more about it.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> select value from v$system_parameter where name='_fix_control';

    VALUE
    -----------------------------------------------------------------------------------------------------------------------
    29331066:1, 28965084:1, 28776811:1, 28498976:1, 28567417:1, 28558645:1, 29132869:1, 29450812:1, 29687220:1, 29939400:1, 30232638:1, 29304314:1, 29930457:1, 30028663:1, 28144569:1, 28776431:1, 27261477:1, 31069997:1, 31077481:1, 28602253:1, 29937655:1, 30347410:1, 30602828:1, 29487407:1, 30998035:1, 30786641:1, 30486896:1, 28999046:1, 30902655:1, 30681521:1, 29302565:1, 30972817:1, 30222669:1, 31668694:1, 31001490:1, 30198239:7, 30980115:1, 19138896:1, 30564898:1, 30570982:1, 30927440:1, 30822446:1, 24561942:1, 31625959:1, 31579233:1, 29696242:1, 30228422:1, 17295505:1, 29725425:1, 30618230:1, 30008456:1, 30537403:1, 30235878:1, 30646077:1, 29657973:1, 29712727:1, 20922160:1, 30006705:1, 29463553:1, 30751171:1, 31009032:1, 30063629:1, 30207519:1, 31517502:1, 30617002:1, 30483217:1, 30235691:1, 30568514:1, 28414968:3, 32014520:1, 30249927:1, 31580374:1, 29435966:1, 28173995:1, 29867728:1, 30776676:1, 26577716:1, 30470947:1, 30979701:1, 30483184:1, 31001295:1, 31191224:1, 31974424:1, 29385774:1, 28234255:3, 31082719:1, 28708585:1, 31821701:1, 32107621:1, 26758837:1, 31558194:1, 30142527:1, 31143146:1, 31496840:1, 22387320:1, 30652595:1, 25979242:1, 32578113:1, 32205825:1, 32408640:1, 31988833:1, 31360214:1, 29738374:1, 33325981:1, 32508585:1, 29651517:1, 31912834:1, 33145153:1, 31050103:1, 30018126:1, 33303725:1, 32856375:1, 32754044:1, 33297275:1, 32851615:1, 32302470:1, 33323903:1, 31162457:1, 28044739:1, 30771009:1, 31545400:1, 30618406:1, 32614157:1, 33329027:1, 33311488:1, 32396085:1, 29972495:1, 32363981:1, 31582179:1, 30978868:1, 33381775:1, 33906515:1, 33443834:1, 33730024:1, 33649782:1, 33236729:1, 33987911:1, 34028486:1, 26491973:1, 10123661:1, 30887435:1, 30231086:1, 30195773:1, 31091402:1, 33547527:1, 34428819:1, 31209735:1, 30609737:1, 32498602:1, 29499077:1, 32527739:1, 31266779:1, 31487332:1, 25869323:1, 33667505:1, 33369863:1, 34131435:1, 33745469:1, 34701323:1, 34123350:1, 34244753:1, 23220873:1, 32061341:1, 32616683:1, 33627879:1, 32005394:1, 33069936:1, 35012562:1, 34685578:1, 31184370:1, 35313797:1, 35412607:1, 34044661:1, 35330506:1, 34803323:1, 34384239:1, 34610498:1, 34225667:1, 32078078:1, 30587089:1, 35614342:1, 24408754:1, 31072746:1, 35465301:1, 28469386:1, 34902561:1, 35192015:1, 35233495:1, 34424818:1, 32436948:1, 34764262:1, 36527753:1, 33753810:1, 31953809:1, 36605166:1, 35586002:1, 35330725:1, 36906464:1, 31720959:1, 36004220:1, 35365062:1, 35421474:1, 31428395:1, 35111847:1, 36868551:1, 36698344:1, 32321289:1, 36373163:1, 36549584:1, 30758835:1, 36040099:1, 37065327:1, 34196994:1, 36426596:5, 37155490:1, 36027309:1, 36875804:1, 35151159:1, 30630477:1, 37466869:1, 35680150:1, 36446103:1, 37000075:1, 36936899:1, 34605396:1, 36004815:1, 37651954:1, 30947294:1, 35206087:1, 36769534:1, 37815535:1, 37253686:1, 31898456:1, 35751181:1, 37818321:1, 30479981:1, 31134487:1, 34807859:1, 37695497:1, 31495387:1, 32455005:1, 34396205:1
    ```

    </details>

8. Format the output in a more readable way.

    ``` sql
    <copy>
    select * from (
       select     trim(regexp_substr (str,'[^,]+',1,level)) value
       from       (select value as str from v$system_parameter where name='_fix_control')
       connect by level <= length ( str ) - length ( replace ( str, ',' ) ) + 1
    ) order by 1;
    </copy>
    ```

    * Each bug is now in a separate row.
    * You can see there are 242 bug fixes currently.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> select * from (
            select     trim(regexp_substr (str,'[^,]+',1,level)) value
            from       (select value as str from v$system_parameter where name='_fix_control')
            connect by level <= length ( str ) - length ( replace ( str, ',' ) ) + 1
         ) order by 1;

    VALUE
    ----------------------------------------
    10123661:1
    17295505:1
    18101156:0
    19138896:1
    ....
    (output truncated)
    ....
    37466869:1
    37651954:1
    37695497:1
    37815535:1
    37818321:1

    242 rows selected.
    ```

    </details>

9. Selectively turn a fix *OFF*.

    ``` sql
    <copy>
    exec dbms_optim_bundle.set_fix_controls('37818321:0','*', 'BOTH','NO');
    </copy>
    ```

    * *37818321* is one of the fixes from the output of the previous command.
    * You can use the procedure to turn fixes *ON* as well.
    * Check the last section (no. 4) to see that the fix is turned off.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    DBMS_OPTIM command: dbms_optim_bundle.set_fix_controls('37818321:0', '*','BOTH', 'NO')

    1) Current _fix_control setting for spfile:
    28965084:1  28776811:1  28567417:1  29132869:1  31444353:0  30927440:1
    24561942:1  17295505:1  30646077:1  29463553:1  31580374:1  28173995:1
    29867728:1  31974424:1  28708585:1  26758837:1  32205825:1  31912834:1
    31843716:0  33443834:1  34028486:1  34816383:0  35330506:1  30001331:0
    ....
    (output truncated)
    ....
    31009032:1  30235691:1  28234255:3  31143146:1  32578113:1  32800137:0
    31050103:1  32856375:1  32396085:1  31582179:1  30978868:1  34092979:0
    18101156:0  29499077:1  31487332:1  25869323:1  33421972:0

    3) Current _fix_control setting in memory for sid = BEIGE
    37818321:1

    4) Final _fix_control setting for memory considering current_setting_precedence is NO
    37818321:0

    PL/SQL procedure successfully completed.
    ```

    </details>

10. Check the parameter *\_fix\_control* again and see that the value has changed for bug 37818321 from *1* to *0*.

    ``` sql
    <copy>
    select * from (
       select     trim(regexp_substr (str,'[^,]+',1,level)) value
       from       (select value as str from v$system_parameter where name='_fix_control')
       connect by level <= length ( str ) - length ( replace ( str, ',' ) ) + 1
    ) where value like '37818321%';
    </copy>
    ```

    * This time a predicate is added to show just that bug fix.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    VALUE
    ----------------------------------------
    37818321:0
    ```

    </details>

11. Create a PFile.

    ``` sql
    <copy>
    create pfile from spfile;
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> create pfile from spfile;

    Pfile FROM created.
    ```

    </details>

12. Exit SQLcl.

    ``` bash
    <copy>
    exit
    </copy>
    ```

13. Check the lengthy *\_fix\_control* parameter in the PFile.

    ``` bash
    <copy>
    grep "fix_control" $ORACLE_HOME/dbs/initBEIGE.ora
    </copy>
    ```

    * All bug fix key-value pairs are in one long comma-separated line.
    * The comment at the end of the line indicates that the value was added through the `DBMS_OPTIM_BUNDLE` package.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    *._fix_control='37818321:0','28965084:1','28776811:1','28567417:1','29132869:1','30927440:1','24561942:1','17295505:1','30646077:1','29463553:1','31580374:1','28173995:1','29867728:1','31974424:1','28708585:1','26758837:1','32205825:1','31912834:1','33443834:1','34028486:1','35465301:1','28469386:1','35365062:1','36698344:1','32321289:1','36549584:1','36875804:1','37466869:1','36446103:1','29930457:1','30028663:1','30998035:1','30902655:1','30681521:1','29302565:1','30198239:7','31625959:1','31579233:1','31517502:1','30568514:1','32014520:1','26577716:1','29385774:1','31082719:1','31558194:1','29738374:1','32851615:1','33730024:1','31091402:1','33369863:1','32061341:1','35412607:1','35330506:1','34610498:1','35614342:1','34424818:1','32436948:1','34764262:1','30758835:1','34605396:1','28144569:1','30347410:1','30602828:1','30570982:1','30822446:1','30008456:1','29657973:1','30483217:1','22387320:1','31360214:1','33325981:1','30771009:1','32614157:1','33329027:1','33311488:1','32363981:1','33236729:1','30887435:1','30195773:1','33547527:1','31209735:1','32498602:1','32005394:1','35012562:1','34044661:1','34803323:1','30587089:1','35192015:1','36527753:1','35330725:1','31428395:1','35111847:1','36868551:1','36426596:5','30630477:1','32455005:1','28558645:1','29450812:1','29687220:1','29939400:1','28999046:1','30972817:1','30222669:1','31668694:1','29725425:1','29712727:1','20922160:1','30063629:1','30617002:1','29435966:1','31191224:1','31496840:1','33145153:1','33303725:1','32754044:1','29972495:1','33906515:1','10123661:1','34428819:1','34131435:1','34701323:1','34384239:1','31953809:1','35586002:1','36906464:1','36004220:1','37155490:1','36027309:1','37000075:1','35751181:1','30479981:1','31134487:1','30232638:1','29304314:1','28776431:1','31077481:1','29487407:1','30980115:1','30564898:1','30618230:1','30537403:1','30235878:1','30249927:1','30979701:1','31001295:1','32107621:1','30142527:1','32508585:1','33297275:1','32302470:1','28044739:1','33381775:1','33649782:1','30231086:1','34244753:1','23220873:1','31072746:1','35421474:1','36373163:1','34196994:1','35680150:1','37651954:1','37815535:1','34807859:1','29331066:1','27261477:1','31069997:1','30486896:1','19138896:1','29696242:1','30228422:1','30751171:1','28414968:3','30652595:1','25979242:1','29651517:1','31545400:1','30618406:1','26491973:1','32527739:1','31266779:1','34123350:1','32616683:1','33627879:1','34685578:1','35313797:1','24408754:1','33753810:1','36040099:1','37065327:1','35151159:1','37253686:1','34396205:1','28602253:1','29937655:1','31001490:1','30006705:1','30207519:1','30776676:1','30470947:1','30483184:1','31821701:1','32408640:1','31988833:1','30018126:1','33323903:1','31162457:1','33987911:1','30609737:1','33667505:1','33745469:1','33069936:1','31184370:1','34225667:1','32078078:1','36004815:1','30947294:1','35206087:1','36769534:1','28498976:1','30786641:1','31009032:1','30235691:1','28234255:3','31143146:1','32578113:1','31050103:1','32856375:1','32396085:1','31582179:1','30978868:1','29499077:1','31487332:1','25869323:1','34902561:1','35233495:1','36605166:1','31720959:1','36936899:1','31898456:1','37695497:1','31495387:1'#added through dbms_optim_bundle package
    ```

    </details>

You may now [*proceed to the next lab*](#next).

## Acknowledgements

* **Author** - Daniel Overby Hansen
* **Contributors** - Rodrigo Jorge, Alex Zaballa, Mike Dietrich, Alejandro Diaz
* **Last Updated By/Date** - Daniel Overby Hansen, September 2026
