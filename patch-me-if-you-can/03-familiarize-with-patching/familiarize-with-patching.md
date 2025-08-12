# Familiarize With Patching

## Introduction

In this lab, you will familiarize with some of the tools used to patch Oracle Database.

Estimated Time: 10 Minutes

### Objectives

In this lab, you will:

* Check the tools needed for patching
* Check an Oracle Database

### Prerequisites

This lab assumes:

* You have completed Lab 1: Initialize Environment

This is an optional lab. You can skip it if you are already familiar with patching Oracle Database.

## Task 1: Use OPatch from shell

You use *OPatch* to perform the first part of patching an Oracle Database; patching the Oracle home. OPatch replaces some files in the Oracle home and might also add new files. If the Oracle home is in use, for instance by a database instance or listener, you must stop those processes.

1. Use the *blue* terminal 🟦. Set the environment to *UPGR* and change to the Oracle home.

    ``` bash
    <copy>
    . upgr
    cd $ORACLE_HOME
    </copy>

    # Be sure to hit RETURN
    ```

2. You find OPatch in a subdirectory. Check the version of OPatch.

    ``` bash
    <copy>
    cd OPatch
    ./opatch version
    </copy>

    # Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    $ cd OPatch
    $ ./opatch version
    OPatch Version: 12.2.0.1.46

    OPatch succeeded.
    ```

    </details>

3. There are other means of finding the OPatch version.

    ``` bash
    <copy>
    cat version.txt
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    $ cat version.txt
    OPATCH_VERSION:12.2.0.1.46
    ```

    </details>

4. Update OPatch by unzipping the OPatch patch file. Keep the old Oracle home as back.

    ``` bash
    <copy>
    cd $ORACLE_HOME
    mv OPatch OPatch_backup
    unzip /home/oracle/patch-repo/p6880880_190000_Linux-x86-64.zip
    </copy>

    # Be sure to hit RETURN
    ```

    * You should always use the latest version of OPatch.
    * AutoUpgrade automatically updates OPatch when you use `patch=RECOMMENDED` or includes the `OPATCH` keyword in the the `patch=` specification.
    * You can manually download the latest of OPatch from My Oracle Support. Search for patch *6880880*.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    $ cd $ORACLE_HOME
    $ mv OPatch OPatch_backup
    $ unzip /home/oracle/patch-repo/p6880880_190000_Linux-x86-64.zip
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

    * The previous version of OPatch was *12.2.0.1.46*.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    $ $ORACLE_HOME/OPatch/opatch version
    OPatch Version: 12.2.0.1.47

    OPatch succeeded.
    ```

    </details>

6. Check the patches currently installed.

    ``` bash
    <copy>
    $ORACLE_HOME/OPatch/opatch lspatches
    </copy>
    ```

    * Currently, the Oracle home on Release Update 19.27.
    * The OJVM and Data Pump bundle patches are installed as well.
    * You can see that the OCW component in the Oracle home has not been updated. It's still on the base release, *19.3.0.0.0*. Oracle requires that the OCW component is updated only when you use Oracle RAC or Oracle Restart, which is not the case in this lab. Nevertheless, it is a good idea to always update the component. You'll see how you can do that in another lab using the `OCW` keyword in the `patch` parameter.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    $ $ORACLE_HOME/OPatch/opatch lspatches
    37738908;SEPARATE PURGE_OLD_METADATA FROM PATCHING ACTIVITY IN DATAPATCH
    37777295;DATAPUMP BUNDLE PATCH 19.27.0.0.0
    37499406;OJVM RELEASE UPDATE: 19.27.0.0.250415 (37499406)
    37642901;Database Release Update : 19.27.0.0.250415 (37642901)
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

    # Be sure to hit RETURN
    ```

    * You spool the contents to a file.
    * If you create a service request in My Oracle Support, it is often a good idea to attach the file.
    * The file is mandatory in many cases, e.g., when requesting a merge patch or backport.

8. Examine the contents of the file.

    ``` bash
    <copy>
    more opatch_lsinventory.txt
    </copy>
    ```

    * Use *Space* to browse through the pages.
    * Use *CTRL+C* to break when you'se seen enough.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    $ more opatch_lsinventory.txt
    Oracle Interim Patch Installer version 12.2.0.1.47
    Copyright (c) 2025, Oracle Corporation.  All rights reserved.


    Oracle Home       : /u01/app/oracle/product/19
    Central Inventory : /u01/app/oraInventory
       from           : /u01/app/oracle/product/19/oraInst.loc
    OPatch version    : 12.2.0.1.47
    OUI version       : 12.2.0.7.0
    Log file location : /u01/app/oracle/product/19/cfgtoollogs/opatch/opatch2025-07-26_06-03-27AM_1.log

    Lsinventory Output file location : /u01/app/oracle/product/19/cfgtoollogs/opatch/lsinv/lsinventory2025-07-26_06-03-27AM.txt
    --------------------------------------------------------------------------------
    Local Machine Information::
    Hostname: doverbyh-newhol-04.sub02121342350.daniel.oraclevcn.com
    ARU platform id: 226
    ARU platform description:: Linux x86-64

    Installed Top-level Products (1):

    Oracle Database 19c                                                  19.0.0.0.0
    There are 1 products installed in this Oracle Home.


    Interim patches (4) :

    Patch  37777295     : applied on Thu Jul 24 10:49:34 GMT 2025
    Unique Patch ID:  27238855
    Patch description:  "DATAPUMP BUNDLE PATCH 19.27.0.0.0"
       Created on 18 Apr 2025, 16:56:05 hrs PST8PDT
       Bugs fixed:
         11845132, 20656226, 21664172, 23625458, 24338134, 24794088, 25143018

    ....
    (output truncated)
    ....

         29380527, 29381000, 29382296, 29391301, 29393649, 29402110, 29411931
         29413360, 29457319, 29465047, 3



    --------------------------------------------------------------------------------

    OPatch succeeded.
    ```

    </details>

## Task 2: Use OPatch inside the database

You can use the *queryable inventory* inside the database to get information from OPatch.

1. Remain in the *blue* terminal 🟦. Connect to the *UPGR* database.

     ``` sql
    <copy>
    . upgr
    sql / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

2. Get information about Oracle home.

     ``` sql
    <copy>
    select xmltransform(dbms_qopatch.get_opatch_install_info, dbms_qopatch.get_opatch_xslt) as install_info from dual;
    </copy>

    -- Be sure to hit RETURN
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
    select xmltransform(dbms_qopatch.is_patch_installed('37642901'), dbms_qopatch.get_opatch_xslt) "Patch installed?" from dual;
    </copy>

    -- Be sure to hit RETURN
    ```

    * Patch 37642901 is the Data Pump bundle patch for Release Update 19.27.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> select xmltransform(dbms_qopatch.is_patch_installed('37642901'), dbms_qopatch.get_opatch_xslt) "Patch installed?" from dual;

    Patch installed?
    _____________________________________________________

    Patch Information:
             37642901:   applied on 2025-07-24T10:42:18Z
    ```

    </details>

4. Get the output of `opatch lsinventory` and find the patches installed.

    ``` sql
    <copy>
    with inv as (select dbms_qopatch.get_opatch_lsinventory output from dual)
    select patches.patch_id, patches.patch_unique_id, patches.description
    from inv,
         xmltable('InventoryInstance/patches/*' passing inv.output columns patch_id number path 'patchID', patch_unique_id number path 'uniquePatchID', description varchar2(80) path 'patchDescription') patches;
    </copy>

    -- Be sure to hit RETURN
    ```

    * The output is a very detailed XML document.
    * You can extract the information of interest.
    * Here you are extracting the patches installed.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> with inv as (select dbms_qopatch.get_opatch_lsinventory output from dual)
      2  select patches.patch_id, patches.patch_unique_id, patches.description
      3  from inv,
      4*      xmltable('InventoryInstance/patches/*' passing inv.output columns patch_id number path    'patchID', patch_unique_id number path 'uniquePatchID', description varchar2(80) path   'patchDescription') patches;

       PATCH_ID    PATCH_UNIQUE_ID                                                        DESCRIPTION
    ___________ __________________ __________________________________________________________________
       37738908           27644118 SEPARATE PURGE_OLD_METADATA FROM PATCHING ACTIVITY IN DATAPATCH
       37777295           27238855 DATAPUMP BUNDLE PATCH 19.27.0.0.0
       37499406           26115603 OJVM RELEASE UPDATE: 19.27.0.0.250415 (37499406)
       37642901           27123174 Database Release Update : 19.27.0.0.250415 (37642901)
       29585399           22840393 OCW RELEASE UPDATE 19.3.0.0.0 (29585399)
    ```

    </details>

5. Exit SQLcl.

    ``` sql
    <copy>
    exit
    </copy>
    ```

## Task 3: Use Datapatch

Datapatch applies or rolls back SQL changes to the database.

1. Remain in the *blue* terminal 🟦. You find Datapatch in the *OPatch* directory.

    ``` bash
    <copy>
    cd $ORACLE_HOME/OPatch
    ls -l datapatch
    </copy>

    # Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    $ cd $ORACLE_HOME/OPatch
    $ ls -l datapatch
    -rwxr-x---. 1 oracle oinstall 589 Oct  4 18:43 datapatch
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
    $ ./datapatch -version
    SQL Patching tool version 19.27.0.0.0 Production on Sat Jul 26 06:15:19 2025
    Copyright (c) 2012, 2025, Oracle.  All rights reserved.

    Build label: RDBMS_19.27.0.0.0DBRU_LINUX.X64_250405
    SQL Patching tool complete on Sat Jul 26 06:15:19 2025
    ```

    </details>

3. Run the prerequisites check.

    ``` bash
    <copy>
    ./datapatch -prereq
    </copy>
    ```

    * Datapatch works on one database only.
    * This check is non-intrusive. It examines your database and checks if Datapatch needs to install patches.
    * Datapatch reports that no patches need to be applied.
    * If you need to work on two databases at the same time, you would need to start another terminal, set the environment accordingly, and execute Datapatch.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    $ ./datapatch -prereq
    SQL Patching tool version 19.27.0.0.0 Production on Sat Jul 26 06:15:44 2025
    Copyright (c) 2012, 2025, Oracle.  All rights reserved.

    Log file for this invocation: /u01/app/oracle/cfgtoollogs/sqlpatch/sqlpatch_166073_2025_07_26_06_15_44/sqlpatch_invocation.log

    Connecting to database...OK
    Gathering database info...done
    Determining current state...done

    Current state of interim SQL patches:
    Interim patch 36878697 (OJVM RELEASE UPDATE: 19.25.0.0.241015 (36878697)):
      Binary registry: Not installed
      SQL registry: Rolled back successfully on 24-JUL-25 10.37.27.200664 AM
    Interim patch 37056207 (DATAPUMP BUNDLE PATCH 19.25.0.0.0):
      Binary registry: Not installed
      SQL registry: Rolled back successfully on 24-JUL-25 10.37.27.308823 AM
    Interim patch 37102264 (OJVM RELEASE UPDATE: 19.26.0.0.250121 (37102264)):
      Binary registry: Not installed
      SQL registry: Rolled back successfully on 24-JUL-25 10.50.50.136642 AM
    Interim patch 37470729 (DATAPUMP BUNDLE PATCH 19.26.0.0.0):
      Binary registry: Not installed
      SQL registry: Rolled back successfully on 24-JUL-25 10.50.50.495814 AM
    Interim patch 37499406 (OJVM RELEASE UPDATE: 19.27.0.0.250415 (37499406)):
      Binary registry: Installed
      SQL registry: Applied successfully on 24-JUL-25 10.50.50.193972 AM
    Interim patch 37777295 (DATAPUMP BUNDLE PATCH 19.27.0.0.0):
      Binary registry: Installed
      SQL registry: Applied successfully on 24-JUL-25 10.52.04.139464 AM

    Current state of release update SQL patches:
      Binary registry:
        19.27.0.0.0 Release_Update 250406131139: Installed
      SQL registry:
        Applied 19.27.0.0.0 Release_Update 250406131139 successfully on 24-JUL-25 10.51.34.382883 AM

    Adding patches to installation queue and performing prereq checks...done
    Installation queue:
      No interim patches need to be rolled back
      No release update patches need to be installed
      No interim patches need to be applied

    SQL Patching tool complete on Sat Jul 26 06:16:11 2025
    ```

    </details>

4. Run Datapatch Sanity Checks.

    ``` bash
    <copy>
    ./datapatch -sanity_checks
    </copy>
    ```

    * The sanity checks are lightweight and non-intrusive. You can run it on a live database.
    * It examines your database for issues that are known to cause problems during patching.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL Patching sanity checks version 19.27.0.0.0 on Sat 26 Jul 2025 06:29:45 AM GMT
    Copyright (c) 2021, 2025, Oracle.  All rights reserved.

    Log file for this invocation: /u01/app/oracle/cfgtoollogs/sqlpatch/sanity_checks_20250726_062945_168019/sanity_checks_20250726_062945_168019.log

    Running checks
    JSON report generated in /u01/app/oracle/cfgtoollogs/sqlpatch/sanity_checks_20250726_062945_168019/sqlpatch_sanity_checks_summary.json file
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
      Consider patching the database when jobs are not running and will not be scheduled to run during patching.
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
        |          JOB_NAME           |            NEXT_RUN_DATE            | SCHEMA_NAME |   STATE   |
        |-----------------------------+-------------------------------------+-------------+-----------|
        |  CLEANUP_ONLINE_IND_BUILD   | 26-JUL-25 07.17.01.600183 AM +00:00 |     SYS     | SCHEDULED |
        |-----------------------------+-------------------------------------+-------------+-----------|
        |     CLEANUP_ONLINE_PMO      | 26-JUL-25 07.17.41.163247 AM +00:00 |     SYS     | SCHEDULED |
        |-----------------------------+-------------------------------------+-------------+-----------|
        |     CLEANUP_TAB_IOT_PMO     | 26-JUL-25 07.17.11.162137 AM +00:00 |     SYS     | SCHEDULED |
        |-----------------------------+-------------------------------------+-------------+-----------|
        | OBJNUM_REUSE_MAINTAIN_JOB$$ | 26-JUL-25 06.37.27.148557 AM +00:00 |     SYS     | SCHEDULED |
        |-----------------------------+-------------------------------------+-------------+-----------|
    Check: GoldenGate triggers - OK
    Check: Logminer DDL triggers - OK
    Check: Check sys public grants - OK
    Check: Statistics gathering running - OK
    Check: Optim dictionary upgrade parameter - OK
    Check: Symlinks on oracle home path - OK
    Check: Central Inventory - OK
    Check: Queryable Inventory dba directories - OK
    Check: Queryable Inventory locks - OK
    Check: Queryable Inventory package - OK
    Check: Queryable Inventory external table - OK
    Check: Imperva processes - OK
    Check: Guardium processes - OK
    Check: Locale - OK

    Refer to MOS Note 2975965.1 and debug log
    /u01/app/oracle/cfgtoollogs/sqlpatch/sanity_checks_20250726_062945_168019/sanity_checks_debug_20250726_062945_168019.log

    SQL Patching sanity checks completed on Sat 26 Jul 2025 06:30:23 AM GMT
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

    -- Be sure to hit RETURN
    ```

    * Datapatch keeps track of all apply and rollback actions in a database.
    * You can see those using this view.
    * Over time, as you patch this database, you will see more actions.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> select to_char(action_time, 'YYYY-MM-DD') as event_date,
      2         patch_id,
      3         patch_type,
      4         action,
      5         description
      6  from dba_registry_sqlpatch
      7* order by action_time;

       EVENT_DATE    PATCH_ID    PATCH_TYPE      ACTION                                              DESCRIPTION
    _____________ ___________ _____________ ___________ ________________________________________________________
    2025-07-28       36878697 INTERIM       APPLY       OJVM RELEASE UPDATE: 19.25.0.0.241015 (36878697)
    2025-07-28       36912597 RU            APPLY       Database Release Update : 19.25.0.0.241015 (36912597)
    2025-07-28       37056207 INTERIM       APPLY       DATAPUMP BUNDLE PATCH 19.25.0.0.0
    2025-08-05       36878697 INTERIM       ROLLBACK    OJVM RELEASE UPDATE: 19.25.0.0.241015 (36878697)
    2025-08-05       37102264 INTERIM       APPLY       OJVM RELEASE UPDATE: 19.26.0.0.250121 (37102264)
    2025-08-05       37056207 INTERIM       ROLLBACK    DATAPUMP BUNDLE PATCH 19.25.0.0.0
    2025-08-05       37260974 RU            APPLY       Database Release Update : 19.26.0.0.250121 (37260974)
    2025-08-05       37470729 INTERIM       APPLY       DATAPUMP BUNDLE PATCH 19.26.0.0.0
    2025-08-05       37102264 INTERIM       ROLLBACK    OJVM RELEASE UPDATE: 19.26.0.0.250121 (37102264)
    2025-08-05       37499406 INTERIM       APPLY       OJVM RELEASE UPDATE: 19.27.0.0.250415 (37499406)
    2025-08-05       37470729 INTERIM       ROLLBACK    DATAPUMP BUNDLE PATCH 19.26.0.0.0
    2025-08-05       37642901 RU            APPLY       Database Release Update : 19.27.0.0.250415 (37642901)
    2025-08-05       37777295 INTERIM       APPLY       DATAPUMP BUNDLE PATCH 19.27.0.0.0
    ```

    </details>

## Task 4: Useful queries

Here are a few useful queries that informs about the database.

1. Still connected to the *UPGR* database. Get the Oracle home of the database.

    ``` sql
    <copy>
    select sys_context('USERENV','ORACLE_HOME') as oracle_home from dual;
    </copy>

    -- Be sure to hit RETURN
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
    SQL> select version_full from v$instance;

       VERSION_FULL
    _______________
    19.27.0.0.0
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

    * All components are either *VALID* or *OPTION OFF*. All looks good.

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
    CATALOG    19.27.0.0.0     VALID
    CATPROC    19.27.0.0.0     VALID
    OWM        19.27.0.0.0     VALID
    RAC        19.27.0.0.0     OPTION OFF
    XDB        19.27.0.0.0     VALID
    ```

    </details>

4. Exit SQLcl.

    ``` sql
    <copy>
    exit
    </copy>
    ```

## Task 5: Check AutoUpgrade

Oracle recommends that you always use the latest version of AutoUpgrade.

1. Check the version of AutoUpgrade.

    ``` bash
    <copy>
    cd
    java -jar autoupgrade.jar -version
    </copy>

    # Be sure to hit RETURN
    ```

    * *MOS_LINK* contains the URL to the My Oracle Support document where you can download the latest version of AutoUpgrade.
    * You can also download AutoUpgrade directly from oracle.com without logging on to My Oracle Support.
    * In this lab, you will use the existing version.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    $ cd
    $ java -jar autoupgrade.jar -version
    build.version 25.4.250730
    build.date 2025/07/30 16:33:06 +0000
    build.hash d12ffb74e
    build.hash_date 2025/07/24 14:59:09 +0000
    build.supported_target_versions 12.2,18,19,21,23
    build.type production
    build.label (HEAD, tag: v25.4, origin/stable_devel, stable_devel)
    build.MOS_NOTE 2485457.1
    build.MOS_LINK https://support.oracle.com/epmos/faces/DocumentDisplay?id=2485457.1
    ```

    </details>

You may now [*proceed to the next lab*](#next). Return to *lab 2* if you didn't finish it.

## Acknowledgements

* **Author** - Daniel Overby Hansen
* **Contributors** - Rodrigo Jorge, Mike Dietrich
* **Last Updated By/Date** - Daniel Overby Hansen, August 2025
