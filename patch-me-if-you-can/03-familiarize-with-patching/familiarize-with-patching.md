# Familiarize With Patching

## Introduction

In this lab, you will become familiar with the tools used to patch Oracle AI Database.

Estimated Time: 15 Minutes

### Objectives

In this lab, you will:

* Examine a patch file
* Check the tools needed for patching
* Check an Oracle AI Database

### Prerequisites

None.

## Task 1: Check Patch Files

1. Switch to the *blue* terminal 🟦. Extract one of the patch files.

    ``` bash
    <copy>
    cd /home/oracle/patch-repo
    unzip p39472050_190000_Linux-x86-64_dbru1932.zip -d ./39472050
    </copy>

    # Be sure to press RETURN
    ```

    * Patch files come from My Oracle Support as ZIP files.
    * The patch zip file you are extracting is the 19.32 Release Update.
    * It takes a minute or two to unzip. Just watch the characters fly by on screen as if you were part of the *Matrix* movies. 

2. Switch to the directory where you extracted the Release Update. The patch metadata is stored in PatchSearch.xml.

    ``` bash
    <copy>
    cd 39472050
    ll
    </copy>

    # Be sure to press RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    total 2632
    drwxr-xr-x. 5 oracle oinstall      81 Jul 13 14:51 39472050
    -rw-rw-r--. 1 oracle oinstall 2693881 Jul 22 15:20 PatchSearch.xml
    ```

    </details>

3. Examine the file.

    ``` bash
    <copy>
    head -n10 PatchSearch.xml
    </copy>
    ```

    * One of the XML elements contains the patch text, *DATABASE RELEASE UPDATE 19.32.0.0.0*.
    * The file contains a lot of metadata about the patch.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    <!-- This file contain patch Metadata -->
    <results md5_sum="95d3a1281c5b4952daf6e23b4db7bcc7">
      <generated_date in_epoch_ms="1784733657000">2026-07-22 15:20:57</generated_date>
      <patch has_prereqs="n" has_postreqs="n" is_system_patch="n">
        <bug>
          <number>39472050</number>
          <abstract><![CDATA[DATABASE RELEASE UPDATE 19.32.0.0.0]]></abstract>
        </bug>
        <name>39472050</name>
        <type>Patch</type>
    ```

    </details>

4. Switch to the subdirectory to find the patch *README* file.

    ``` bash
    <copy>
    cd 39472050
    ll
    </copy>

    # Be sure to press RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    total 108
    drwxr-x---.  3 oracle oinstall     21 Jul 13 14:55 custom
    drwxr-x---.  3 oracle oinstall     20 Jul 13 14:55 etc
    drwxr-x---. 51 oracle oinstall   4096 Jul 13 14:51 files
    -rw-rw-r--.  1 oracle oinstall 100035 Jul 21 04:46 README.html
    -rw-r--r--.  1 oracle oinstall     21 Jul 13 14:55 README.txt
    ```

    </details>

5. Open the patch *README* file.

    ``` bash
    <copy>
    firefox README.html &
    </copy>
    ```

    * It takes a little while to open Firefox.
    * In section *1 Patch Information* you can find specific information about this patch.
    * It states that this patch is *RAC Rolling* and *Standby-First Installable*.
    * The file also contains installation instructions.

6. Close Firefox.

7. Find all the *bug apply scripts* in the Release Update.

    ``` bash
    <copy>
    find . -iname "bug*apply*sql*"
    </copy>
    ```

    * OPatch adds the apply scripts to the Oracle home as part of the patching process.
    * Later, Datapatch uses the apply scripts to make changes inside the database.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    ./files/rdbms/admin/bug31115653_postapply.sql
    ./files/rdbms/admin/bug29261906_apply.sql
    ./files/rdbms/admin/bug_35271571_apply.sql
    ./files/rdbms/admin/bug_32124176_apply.sql
    ./files/rdbms/admin/bug_29443559_apply.sql
    ....
    (output truncated)
    ....
    ./files/rdbms/admin/bug37062405_apply.sql
    ./files/rdbms/admin/bug36386191_apply.sql
    ./files/sqlpatch/39472050/28919163/rollback_files/19.31.0.0.0-RU-Release_Update-260426152757/md/admin/bug38592316_apply.sql
    ./files/sqlpatch/39472050/28919163/rollback_files/19.32.0.0.0-RU-Release_Update-260705220710/md/admin/bug38992540_apply.sql
    ./files/sqlpatch/39472050/28919163/rollback_files/19.32.0.0.0-RU-Release_Update-260705220710/md/admin/bug38592316_apply.sql
    ```

    </details>

8. Examine one of the apply scripts.

    ``` bash
    <copy>
    cat ./files/rdbms/admin/backport_files/bug_28971177_apply.sql
    </copy>
    ```

    * The apply script adds two indexes on `SYS.RECYCLEBIN$`.
    * The text on bug 28971177 states *Delete from recyclebin$ going for full table scan*.
    * The bug is fixed by adding two indexes.
    * This illustrates how a bug fix can introduce changes into the database.
    * Also note how the backport is registered by inserting a row into `REGISTRY$BACKPORTS`.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    Rem
    Rem $Header: rdbms/admin/backport_files/bug_28971177_apply.sql /st_rdbms_19/1 2022/09/21 16:37:52 skiyer Exp $
    Rem
    Rem bug_28971177_apply.sql
    Rem
    Rem Copyright (c) 2019, 2022, Oracle and/or its affiliates.
    Rem
    Rem    NAME
    Rem      bug_28971177_apply.sql - <one-line expansion of the name>
    Rem
    Rem    DESCRIPTION
    Rem      <short description of component this file declares/defines>
    Rem
    Rem    NOTES
    Rem      <other useful comments, qualifications, etc.>
    Rem
    Rem    BEGIN SQL_FILE_METADATA
    Rem    SQL_SOURCE_FILE: rdbms/admin/backport_files/bug_28971177_apply.sql
    Rem    SQL_SHIPPED_FILE: rdbms/admin/backport_files/bug_28971177_apply.sql
    Rem    SQL_PHASE: RDBMS_PREAPPLY
    Rem    SQL_STARTUP_MODE: NORMAL
    Rem    SQL_IGNORABLE_ERRORS: NONE
    Rem    END SQL_FILE_METADATA
    Rem
    Rem    MODIFIED   (MM/DD/YY)
    Rem    skiyer      11/05/19 - Bug28971177 add apply scripts
    Rem    skiyer      11/05/19 - Created
    Rem

    @@?/rdbms/admin/sqlsessstart.sql
    create index recyclebin$_purgeobj on recyclebin$(purgeobj);
    create index recyclebin$_bo on recyclebin$(bo);

    -- Record the fix for bug 28971177 into registry$backports
    INSERT /*+IGNORE_ROW_ON_DUPKEY_INDEX(registry$backports, registry_backports_pk)*/
    INTO sys.registry$backports (version_full, bugno)
    VALUES ((SELECT version_full FROM sys.v$instance),
            28971177);
    COMMIT;
    @?/rdbms/admin/sqlsessend.sql
    ```

    </details>

## Task 2: Use OPatch From Shell

You use *OPatch* to perform the first part of patching an Oracle AI Database; patching the Oracle home. OPatch replaces some files in the Oracle home and might also add new files. If the Oracle home is in use, for instance by a database instance or listener, you must stop those processes.

1. Still in the *blue* terminal 🟦. Set the environment to *UPGR* and change to the Oracle home.

    ``` bash
    <copy>
    . upgr
    cd $ORACLE_HOME
    </copy>

    # Be sure to press RETURN
    ```

2. OPatch is located in a subdirectory. Check the OPatch version.

    ``` bash
    <copy>
    cd OPatch
    ./opatch version
    </copy>

    # Be sure to press RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    OPatch Version: 12.2.0.1.51

    OPatch succeeded.
    ```

    </details>

3. You can also check the OPatch version by inspecting `version.txt`.

    ``` bash
    <copy>
    cat version.txt
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    OPATCH_VERSION:12.2.0.1.51
    ```

    </details>

4. Update OPatch by unzipping the OPatch patch file. Keep the old OPatch directory as a backup.

    ``` bash
    <copy>
    cd $ORACLE_HOME
    mv OPatch OPatch_backup
    unzip /home/oracle/patch-repo/p6880880_190000_Linux-x86-64.zip
    </copy>

    # Be sure to press RETURN
    ```

    * You should always use the latest version of OPatch.
    * AutoUpgrade automatically updates OPatch when you use `patch=RECOMMENDED` or include the `OPATCH` keyword in the `patch` specification.
    * You can manually download the latest version of OPatch from My Oracle Support. Search for patch *6880880*.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    Archive:  /home/oracle/patch-repo/p6880880_190000_Linux-x86-64.zip
       creating: OPatch/
      inflating: OPatch/opatchauto
      ...
      (output truncated)
      ...
      inflating: OPatch/modules/com.sun.xml.bind.jaxb-jxc.jar
      inflating: OPatch/modules/javax.activation.javax.activation.jar
    ```

    </details>

5. Check the new version of OPatch

    ``` bash
    <copy>
    $ORACLE_HOME/OPatch/opatch version
    </copy>
    ```

    * The previous version of OPatch was *12.2.0.1.51*.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    OPatch Version: 12.2.0.1.52

    OPatch succeeded.
    ```

    </details>

6. Check the patches currently installed.

    ``` bash
    <copy>
    $ORACLE_HOME/OPatch/opatch lspatches
    </copy>
    ```

    * Currently, the Oracle home is on Release Update 19.31.
    * The OJVM and Data Pump bundle patches are installed as well.
    * The OCW component in the Oracle home has not been updated; it remains at the base release, *19.3.0.0.0*. Oracle RAC and Oracle Restart use OCW. Although this lab does not use either, keeping OCW updated is generally recommended. You will see how to do this in another lab using the `OCW` keyword in the `patch` parameter.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    39196236;DATAPUMP BUNDLE PATCH 19.31.0.0.0
    38906621;OJVM RELEASE UPDATE: 19.31.0.0.260421 (38906621)
    39034528;Database Release Update : 19.31.0.0.260421 (REL-APR2026) (39034528)
    29585399;OCW RELEASE UPDATE 19.3.0.0.0 (29585399)

    OPatch succeeded.
    ```

    </details>

7. Get detailed information about the patches in the Oracle home.

    ``` bash
    <copy>
    cd $ORACLE_HOME
    OPatch/opatch lsinventory > opatch_lsinventory.txt
    </copy>

    # Be sure to press RETURN
    ```

    * You spool the contents to a file.
    * If you create a service request in My Oracle Support, it is often a good idea to attach the file.
    * The file is mandatory in many cases, for example, when requesting a merge patch or backport.

8. Examine the contents of the file.

    ``` bash
    <copy>
    more opatch_lsinventory.txt
    </copy>
    ```

    * Use the *space bar* to browse through the pages.
    * Use *Q* or *CTRL+C* to break when you'se seen enough.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    Oracle Interim Patch Installer version 12.2.0.1.52
    Copyright (c) 2026, Oracle Corporation.  All rights reserved.


    Oracle Home       : /u01/app/oracle/product/19
    Central Inventory : /u01/app/oraInventory
       from           : /u01/app/oracle/product/19/oraInst.loc
    OPatch version    : 12.2.0.1.52
    OUI version       : 12.2.0.7.0
    Log file location : /u01/app/oracle/product/19/cfgtoollogs/opatch/opatch2026-08-31_14-54-47PM_1.log

    Lsinventory Output file location : /u01/app/oracle/product/19/cfgtoollogs/opatch/lsinv/lsinventory2026-08-31_14-54-47PM.txt
    --------------------------------------------------------------------------------
    Local Machine Information::
    Hostname: holserv1.livelabs.oraclevcn.com
    ARU platform id: 226
    ARU platform description:: Linux x86-64

    Installed Top-level Products (1):

    Oracle Database 19c                                                  19.0.0.0.0
    There are 1 products installed in this Oracle Home.


    Interim patches (4) :

    Patch  39196236     : applied on Fri Aug 21 06:46:28 GMT 2026
    Unique Patch ID:  28705537
    Patch description:  "DATAPUMP BUNDLE PATCH 19.31.0.0.0"
       Created on 29 Apr 2026, 15:21:56 hrs PST8PDT
       Bugs fixed:
         11845132, 20656226, 21664172, 23625458, 24338134, 24794088, 25143018
         25449474, 25672265, 25672973, 25680526, 25769134, 25804034, 25921352

    ....
    (output truncated)
    ....

         29380527, 29381000, 29382296, 29391301, 29393649, 29402110, 29411931
         29413360, 29457319, 29465047, 3



    --------------------------------------------------------------------------------

    OPatch succeeded.
    ```

    </details>

## Task 3: Use OPatch Inside the Database

You can use the *queryable inventory* inside the database to get information from OPatch.

1. Remain in the *blue* terminal 🟦. Connect to the *UPGR* database.

     ``` sql
    <copy>
    . upgr
    sql / as sysdba
    </copy>

    -- Be sure to press RETURN
    ```

2. Get information about the Oracle home.

     ``` sql
    <copy>
    select xmltransform(dbms_qopatch.get_opatch_install_info, dbms_qopatch.get_opatch_xslt) as install_info from dual;
    </copy>

    -- Be sure to press RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> select xmltransform(dbms_qopatch.get_opatch_install_info, dbms_qopatch.get_opatch_xslt) as install_info from dual;

    INSTALL_INFO
    _______________________________________________

    Oracle Home       : /u01/app/oracle/product/19
    Inventory         : /u01/app/oraInventory
    ```

    </details>

3. See if a patch is installed.

    ``` sql
    <copy>
    select xmltransform(dbms_qopatch.is_patch_installed('39196236'), dbms_qopatch.get_opatch_xslt) "Patch installed?" from dual;
    </copy>
    ```

    * Patch 39196236 is the Data Pump bundle patch for Release Update 19.31.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    Patch installed?
    _____________________________________________________

    Patch Information:
             39196236:   applied on 2026-08-21T06:39:41Z
    ```

    </details>

4. Get a list of installed patches using `DBMS_QOPATCH`.

    ``` sql
    <copy>
    with inv as (select dbms_qopatch.get_opatch_lsinventory output from dual)
    select patches.patch_id, patches.patch_unique_id, patches.description
    from inv,
         xmltable('InventoryInstance/patches/*' passing inv.output columns patch_id number path 'patchID', patch_unique_id number path 'uniquePatchID', description varchar2(80) path 'patchDescription') patches;
    </copy>

    -- Be sure to press RETURN
    ```

    * The output is a very detailed XML document.
    * You can extract the information you need.
    * This query extracts the installed patches.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    PATCH_ID    PATCH_UNIQUE_ID DESCRIPTION
    ___________ _______________ __________________________________________________________________
    39196236           28705537 DATAPUMP BUNDLE PATCH 19.31.0.0.0
    38906621           28588735 OJVM RELEASE UPDATE: 19.31.0.0.260421 (38906621)
    39034528           28740323 Database Release Update : 19.31.0.0.260421 (REL-APR2026) (39034528)
    29585399           22840393 OCW RELEASE UPDATE 19.3.0.0.0 (29585399)
    ```

    </details>

5. Exit SQLcl.

    ``` 
    <copy>
    exit
    </copy>
    ```    


## Task 4: Use Datapatch

Datapatch applies or rolls back SQL changes to the database.

1. Remain in the *blue* terminal 🟦. Datapatch is located in the *OPatch* directory.

    ``` bash
    <copy>
    cd $ORACLE_HOME/OPatch
    ls -l datapatch
    </copy>

    # Be sure to press RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    -rwxr-x---. 1 oracle oinstall 589 Jul 22 07:47 datapatch
    ```

    </details>

2. Check the version of Datapatch.

    ``` bash
    <copy>
    ./datapatch -version
    </copy>
    ```

    * Although Datapatch is located in the *OPatch* directory, you update Datapatch via Release Updates, not by updating OPatch.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL Patching tool version 19.31.0.0.0 Production on Mon Aug 31 14:58:23 2026
    Copyright (c) 2012, 2026, Oracle.  All rights reserved.
    
    Build label: RDBMS_19.31.0.0.0DBRU_LINUX.X64_260424.2
    SQL Patching tool complete on Mon Aug 31 14:58:23 2026
    ```

    </details>

3. Run the prerequisite check.

    ``` bash
    <copy>
    ./datapatch -prereq
    </copy>
    ```

    * Datapatch operates on one database at a time.
    * This nonintrusive check examines the database and determines whether Datapatch needs to install patches.
    * Datapatch reports that no patches need to be applied.
    
    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL Patching tool version 19.31.0.0.0 Production on Mon Aug 31 14:58:41 2026
    Copyright (c) 2012, 2026, Oracle.  All rights reserved.
    
    Log file for this invocation: /u01/app/oracle/cfgtoollogs/sqlpatch/sqlpatch_64086_2026_08_31_14_58_41/sqlpatch_invocation.log
    
    Connecting to database...OK
    Gathering database info...done
    Determining current state...done
    
    Current state of interim SQL patches:
    Interim patch 38194382 (OJVM RELEASE UPDATE: 19.29.0.0.251021 (38194382)):
      Binary registry: Not installed
      SQL registry: Rolled back successfully on 21-AUG-26 06.34.56.337255 AM
    Interim patch 38523609 (OJVM RELEASE UPDATE: 19.30.0.0.260120 (38523609)):
      Binary registry: Not installed
      SQL registry: Rolled back successfully on 21-AUG-26 06.47.31.865857 AM
    Interim patch 38535360 (DATAPUMP BUNDLE PATCH 19.29.0.0.0):
      Binary registry: Not installed
      SQL registry: Rolled back successfully on 21-AUG-26 06.34.56.799087 AM
    Interim patch 38844367 (19.30 OJVM PATCH APPLY IS FAILING ON SECOND NODE IN RAC ENVIRONMENT):
      Binary registry: Not installed
      SQL registry: Rolled back successfully on 21-AUG-26 06.47.31.929220 AM
    Interim patch 38844733 (DATAPUMP BUNDLE PATCH 19.30.0.0.0):
      Binary registry: Not installed
      SQL registry: Rolled back successfully on 21-AUG-26 06.47.32.415083 AM
    Interim patch 38906621 (OJVM RELEASE UPDATE: 19.31.0.0.260421 (38906621)):
      Binary registry: Installed
      SQL registry: Applied successfully on 21-AUG-26 06.47.31.916632 AM
    Interim patch 39196236 (DATAPUMP BUNDLE PATCH 19.31.0.0.0):
      Binary registry: Installed
      SQL registry: Applied successfully on 21-AUG-26 06.48.04.650842 AM
    
    Current state of release update SQL patches:
      Binary registry:
        19.31.0.0.0 Release_Update 260514003012: Installed
      SQL registry:
        Applied 19.31.0.0.0 Release_Update 260514003012 successfully on 21-AUG-26 06.47.42.474544 AM
    
    Adding patches to installation queue and performing prereq checks...done
    Installation queue:
      No interim patches need to be rolled back
      No release update patches need to be installed
      No interim patches need to be applied
    
    SQL Patching tool complete on Mon Aug 31 14:59:07 2026
    ```

    </details>

4. Run Datapatch Sanity Checks.

    ``` bash
    <copy>
    ./datapatch -sanity_checks
    </copy>
    ```

    * The sanity checks are lightweight and nonintrusive. You can run them on a live database.
    * They examine the database for issues known to cause problems during patching.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL Patching sanity checks version 19.31.0.0.0 on Mon 31 Aug 2026 03:04:15 PM GMT
    Copyright (c) 2021, 2026, Oracle.  All rights reserved.
    
    Log file for this invocation: /u01/app/oracle/cfgtoollogs/sqlpatch/sanity_checks_20260831_150415_65004/sanity_checks_20260831_150415_65004.log
    
    Running checks
    Use of uninitialized value $pdb in concatenation (.) or string at /u01/app/oracle/product/19/sqlpatch/sqlpatch_sanity_checks.pm line 1300.
    JSON report generated in /u01/app/oracle/cfgtoollogs/sqlpatch/sanity_checks_20260831_150415_65004/sqlpatch_sanity_checks_summary.json file
    Checks completed. Printing report:
    
    Check: Database component status - OK
    Check: PDB Violations - OK
    Check: Invalid System Objects - OK
    Check: Tablespace Status - OK
    Check: Backup jobs - OK
    Check: Temp file exists - OK
    Check: Temp file online - OK
    Check: Data Pump running - OK
    Check: Container status - OK
    Check: Oracle Database Keystore - OK
    Check: Dictionary statistics gathering - OK
    Check: Scheduled Jobs - WARNING
      Execution of scheduler jobs while database patching is running may lead to failures and/or performance issues.
      There are jobs currently running or scheduled to be executed during next hour.
      If you experience Datapatch errors caused by locking in the database, consider patching the database when jobs are not running or preventing jobs from     starting.
      To check for jobs that are running or scheduled to run:
        SELECT owner as schema_name, job_name, state, next_run_date
        FROM sys.all_scheduler_jobs
        WHERE state = 'RUNNING'
        UNION
          SELECT owner as schema_name, job_name, state, next_run_date
          FROM sys.all_scheduler_jobs
          WHERE state = 'SCHEDULED'
          and cast(next_run_date as date) > sysdate
          and cast(next_run_date as date) < sysdate + 1/24;
      UPGR:
        | SCHEMA_NAME |          JOB_NAME           |   STATE   |            NEXT_RUN_DATE            |
        |-------------+-----------------------------+-----------+-------------------------------------|
        |     SYS     |  CLEANUP_ONLINE_IND_BUILD   | SCHEDULED | 31-AUG-26 03.39.10.154237 PM +00:00 |
        |-------------+-----------------------------+-----------+-------------------------------------|
        |     SYS     |     CLEANUP_ONLINE_PMO      | SCHEDULED | 31-AUG-26 03.39.50.152450 PM +00:00 |
        |-------------+-----------------------------+-----------+-------------------------------------|
        |     SYS     |     CLEANUP_TAB_IOT_PMO     | SCHEDULED | 31-AUG-26 03.39.20.930625 PM +00:00 |
        |-------------+-----------------------------+-----------+-------------------------------------|
        |     SYS     |    CLEANUP_TRANSIENT_PKG    | SCHEDULED | 31-AUG-26 03.39.40.000000 PM +00:00 |
        |-------------+-----------------------------+-----------+-------------------------------------|
        |     SYS     | OBJNUM_REUSE_MAINTAIN_JOB$$ | SCHEDULED | 31-AUG-26 03.49.56.150637 PM +00:00 |
        |-------------+-----------------------------+-----------+-------------------------------------|
    Check: GoldenGate triggers - OK
    Check: Logminer DDL triggers - OK
    Check: Check sys public grants - OK
    Check: Statistics gathering running - OK
    Check: Optim dictionary upgrade parameter - OK
    Check: Symlinks on oracle home path - OK
    Check: Central Inventory - OK
    Check: Java Virtual Machine Enable - OK
    Check: Oracle Database Vault Enabled - OK
    Check: Queryable Inventory database directories - OK
    Check: Queryable Inventory locks - OK
    Check: Queryable Inventory package - OK
    Check: Queryable Inventory external table - OK
    Check: Imperva processes - OK
    Check: Guardium processes - OK
    Check: Locale - OK
    
    Refer to MOS Note 2975965.1 and debug log
    /u01/app/oracle/cfgtoollogs/sqlpatch/sanity_checks_20260831_150415_65004/sanity_checks_debug_20260831_150415_65004.log
    
    SQL Patching sanity checks completed on Mon 31 Aug 2026 03:04:17 PM GMT
    ```

    </details>

5. Connect to the *UPGR* database.

     ``` bash
    <copy>
    sql / as sysdba
    </copy>
    ```

6. Examine the Datapatch actions.

    ``` sql
    <copy>
    select to_char(action_time, 'YYYY-MM-DD') as event_date,
           patch_id,
           patch_type,
           action,
           description
    from dba_registry_sqlpatch
    order by action_time;
    </copy>

    -- Be sure to press RETURN
    ```

    * Datapatch keeps track of all apply and rollback actions in a database.
    * You can view these actions in this view.
    * Over time, as you patch this database, you will see more actions.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    EVENT_DATE    PATCH_ID    PATCH_TYPE      ACTION    DESCRIPTION
    _____________ ___________ _____________ ___________ _______________________________________________________________________
    2026-07-23       38194382 INTERIM       APPLY       OJVM RELEASE UPDATE: 19.29.0.0.251021 (38194382)
    2026-07-23       38291812 RU            APPLY       Database Release Update : 19.29.0.0.251021 (38291812)
    2026-07-23       38535360 INTERIM       APPLY       DATAPUMP BUNDLE PATCH 19.29.0.0.0
    2026-08-21       38194382 INTERIM       ROLLBACK    OJVM RELEASE UPDATE: 19.29.0.0.251021 (38194382)
    2026-08-21       38523609 INTERIM       APPLY       OJVM RELEASE UPDATE: 19.30.0.0.260120 (38523609)
    2026-08-21       38535360 INTERIM       ROLLBACK    DATAPUMP BUNDLE PATCH 19.29.0.0.0
    2026-08-21       38632161 RU            APPLY       Database Release Update : 19.30.0.0.260120(REL-JAN260130) (38632161)
    2026-08-21       38844367 INTERIM       APPLY       19.30 OJVM PATCH APPLY IS FAILING ON SECOND NODE IN RAC ENVIRONMENT
    2026-08-21       38844733 INTERIM       APPLY       DATAPUMP BUNDLE PATCH 19.30.0.0.0
    2026-08-21       38523609 INTERIM       ROLLBACK    OJVM RELEASE UPDATE: 19.30.0.0.260120 (38523609)
    2026-08-21       38906621 INTERIM       APPLY       OJVM RELEASE UPDATE: 19.31.0.0.260421 (38906621)
    2026-08-21       38844367 INTERIM       ROLLBACK    19.30 OJVM PATCH APPLY IS FAILING ON SECOND NODE IN RAC ENVIRONMENT
    2026-08-21       38844733 INTERIM       ROLLBACK    DATAPUMP BUNDLE PATCH 19.30.0.0.0
    2026-08-21       39034528 RU            APPLY       Database Release Update : 19.31.0.0.260421 (REL-APR2026) (39034528)
    2026-08-21       39196236 INTERIM       APPLY       DATAPUMP BUNDLE PATCH 19.31.0.0.0
    
    15 rows selected.
    ```

    </details>

## Task 5: Useful Queries

Here are a few useful queries that provide information about the database.

1. Remain in the *blue* terminal 🟦 and connected to the *UPGR* database. Get the Oracle home for the database.

    ``` sql
    <copy>
    select sys_context('USERENV','ORACLE_HOME') as oracle_home from dual;
    </copy>

    -- Be sure to press RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> select sys_context('USERENV','ORACLE_HOME') as oracle_home from dual;

                      ORACLE_HOME
    _____________________________
    /u01/app/oracle/product/19
    ```

    </details>

2. Get the full version of the database.

    ``` sql
    <copy>
    select version_full from v$instance;
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
       VERSION_FULL
    _______________
    19.31.0.0.0
    ```

    </details>

3. List the components installed in the database.

    ``` sql
    <copy>
    select comp_id,
           version_full,
           status
    from dba_registry
    order by comp_id;
    </copy>
    ```

    * All components have a status of *VALID* or *OPTION OFF*, so the database appears healthy.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> select comp_id,
      2         version_full,
      3         status
      4  from dba_registry
      5* order by comp_id;

       COMP_ID    VERSION_FULL        STATUS
    __________ _______________ _____________
    CATALOG    19.31.0.0.0     VALID
    CATPROC    19.31.0.0.0     VALID
    OWM        19.31.0.0.0     VALID
    RAC        19.31.0.0.0     OPTION OFF
    XDB        19.31.0.0.0     VALID
    ```

    </details>

4. Exit SQLcl.

    ``` 
    <copy>
    exit
    </copy>
    ```

## Task 6: Check AutoUpgrade

Oracle recommends that you always use the latest version of AutoUpgrade.

1. Check the version of AutoUpgrade.

    ``` bash
    <copy>
    cd
    java -jar autoupgrade.jar -version
    </copy>

    # Be sure to press RETURN
    ```

    * *MOS_LINK* contains the URL to the My Oracle Support document where you can download the latest version of AutoUpgrade.
    * You can also download AutoUpgrade directly from oracle.com without logging on to My Oracle Support.
    * In this lab, you will use the existing version.

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

You may now [*proceed to the next lab*](#next). 

## Acknowledgements

* **Author** - Daniel Overby Hansen
* **Contributors** - Rodrigo Jorge, Alex Zaballa, Mike Dietrich, Alejandro Diaz
* **Last Updated By/Date** - Daniel Overby Hansen, September 2026