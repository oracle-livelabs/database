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

- You have completed Lab 1: Initialize Environment

This is an optional lab. You can skip it if you are already familiar with patching Oracle Database.

## Task 1: Use OPatch from shell

You use *OPatch* to perform the first part of patching an Oracle Database; patching the Oracle home. OPatch replaces some files in the Oracle home and might also add new files. If the Oracle home is in use, for instance by a database instance or listener, you must stop those processes. 

1. Use the *blue* 🟦 terminal. Set the environment to *UPGR* and change to the Oracle home.

    ```
    <copy>
    . upgr
    cd $ORACLE_HOME
    </copy>

    -- Be sure to hit RETURN
    ```

2. You find OPatch in a subdirectory. Check the version of OPatch.
    
    ```
    <copy>
    cd OPatch
    ./opatch version
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ cd OPatch
    $ ./opatch version
    OPatch Version: 12.2.0.1.42
    
    OPatch succeeded.
    ```
    </details>        

3. There are other means of finding the OPatch version.

    ```
    <copy>
    cat version.txt
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ cat version.txt
    OPATCH_VERSION:12.2.0.1.42
    ```
    </details>  

4. Update OPatch by unzipping the OPatch patch file. Keep the old Oracle home as back.
    
    ```
    <copy>
    cd $ORACLE_HOME
    mv OPatch OPatch_backup
    unzip /home/oracle/patch-repo/p6880880_190000_Linux-x86-64.zip
    </copy>

    -- Be sure to hit RETURN
    ```

    * You should always use the latest version of OPatch. 
    * You can download the latest of OPatch from My Oracle Support. Search for patch *6880880*.

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
    
    ```
    <copy>
    $ORACLE_HOME/OPatch/opatch version
    </copy>
    ```

    * The previous version of OPatch was *12.2.0.1.42*.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ $ORACLE_HOME/OPatch/opatch version
    OPatch Version: 12.2.0.1.44
    
    OPatch succeeded.
    ```
    </details>     

6. Check the patches currently installed.

    ```
    <copy>
    $ORACLE_HOME/OPatch/opatch lspatches
    </copy>
    ```

    * Currently, the Oracle home on Release Update 19.21.0.
    * The OJVM and Data Pump bundle patches are installed as well.
    * You can ignore the OCW Release Update.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ $ORACLE_HOME/OPatch/opatch lspatches
    35648110;OJVM RELEASE UPDATE: 19.21.0.0.231017 (35648110)
    35787077;DATAPUMP BUNDLE PATCH 19.21.0.0.0
    35643107;Database Release Update : 19.21.0.0.231017 (35643107)
    29585399;OCW RELEASE UPDATE 19.3.0.0.0 (29585399)
    
    OPatch succeeded.
    ```
    </details>   

7. Get detailed information about the patches in the Oracle home.

    ```
    <copy>
    cd $ORACLE_HOME
    OPatch/opatch lsinventory > opatch_lsinventory.txt
    </copy>

    -- Be sure to hit RETURN
    ```

    * You spool the contents to a file.
    * If you create a service request in My Oracle Support, it is often a good idea to attach the file.
    * The file is mandatory in many cases, e.g., when requesting a merge patch or backport.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ cd $ORACLE_HOME
    $ OPatch/opatch lsinventory > opatch_lsinventory.txt
    ```
    </details>  

8. Examine the contents of the file.

    ```
    <copy>
    more opatch_lsinventory.txt
    </copy>
    ```

    * Use *Space* to browse through the pages.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ more opatch_lsinventory.txt
    Oracle Interim Patch Installer version 12.2.0.1.44
    Copyright (c) 2024, Oracle Corporation.  All rights reserved.
    
    
    Oracle Home       : /u01/app/oracle/product/19
    Central Inventory : /u01/app/oraInventory
       from           : /u01/app/oracle/product/19/oraInst.loc
    OPatch version    : 12.2.0.1.44
    OUI version       : 12.2.0.7.0
    Log file location : /u01/app/oracle/product/19/cfgtoollogs/opatch/opatch2024-10-31_11-00-40AM_1.log
    
    Lsinventory Output file location : /u01/app/oracle/product/19/cfgtoollogs/opatch/lsinv/lsinventory2024-10-31_11-00-40AM.txt
    --------------------------------------------------------------------------------
    Local Machine Information::
    Hostname: holserv1.livelabs.oraclevcn.com
    ARU platform id: 226
    ARU platform description:: Linux x86-64
    
    Installed Top-level Products (1):
    
    Oracle Database 19c                                                  19.0.0.0.0
    There are 1 products installed in this Oracle Home.
    
    
    Interim patches (4) :
    
    Patch  35648110     : applied on Wed Jul 10 15:00:04 GMT 2024
    Unique Patch ID:  25365038
    Patch description:  "OJVM RELEASE UPDATE: 19.21.0.0.231017 (35648110)"
       Created on 25 Aug 2023, 10:22:03 hrs UTC
       Bugs fixed:
         26716835, 28209601, 28674263, 28777073, 29224710, 29254623, 29415774

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

1. Remain in the *blue* 🟦 terminal. Connect to the *UPGR* database.

     ```
    <copy>
    . upgr
    sqlplus / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

2. Get information about Oracle home.

     ```
    <copy>
    set long 1000000
    set pagesize 0
    select xmltransform(dbms_qopatch.get_opatch_install_info, dbms_qopatch.get_opatch_xslt) as install_info from dual;
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> set long 1000000
    SQL> set pagesize 0
    SQL> select xmltransform(dbms_qopatch.get_opatch_install_info, dbms_qopatch.get_opatch_xslt) as install_info from dual;
    INSTALL_INFO
    ------------------------------------------
    
    Oracle Home   : /u01/app/oracle/product/19
    Inventory     : /u01/app/oraInventory
    ```
    </details>       

3. See if a patch is installed.

    ```
    <copy>
    select xmltransform(dbms_qopatch.is_patch_installed('35787077'), dbms_qopatch.get_opatch_xslt) "Patch installed?" from dual;
    </copy>
    ```

    * Patch 35787077 is the Data Pump bundle patch for Release Update 19.21.0

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> select xmltransform(dbms_qopatch.is_patch_installed('35787077'), dbms_qopatch.get_opatch_xslt) "Patch installed?" from dual;
    Patch installed?
    --------------------------------------------------------------------------------
    
    Patch Information:
        35787077:   applied on 2024-07-10T14:58:58Z
    ```
    </details>    

4. Get the output of `opatch lsinventory` and find the patches installed.

    ```
    <copy>
    with inv as (select dbms_qopatch.get_opatch_lsinventory output from dual) 
    select patches.patch_id, patches.patch_unique_id, patches.description 
    from inv, 
         xmltable('InventoryInstance/patches/*' passing inv.output columns patch_id number path 'patchID', patch_unique_id number path 'uniquePatchID', description varchar2(80) path 'patchDescription') patches;
    </copy>
    ```

    * The output is a very detailed XML document. 
    * You can extract the information of interest.
    * Here you are extracting the patches installed.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> with inv as (select dbms_qopatch.get_opatch_lsinventory output from dual) 
    select patches.patch_id, patches.patch_unique_id, patches.description 
    from inv, 
         xmltable('InventoryInstance/patches/*' passing inv.output columns patch_id number path 'patchID', patch_unique_id number path 'uniquePatchID', description varchar2(80) path 'patchDescription') patches;

      35648110    25365038 OJVM RELEASE UPDATE: 19.21.0.0.231017 (35648110)
      35787077    25410019 DATAPUMP BUNDLE PATCH 19.21.0.0.0
      35643107    25405995 Database Release Update : 19.21.0.0.231017 (35643107)
      29585399    22840393 OCW RELEASE UPDATE 19.3.0.0.0 (29585399)         
    ```
    </details>    

5. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```

## Task 3: Use Datapatch

Datapatch applies or rolls back SQL changes to the database. 

1. Remain in the *blue* 🟦 terminal. You find Datapatch in the *OPatch* directory. 
    
    ```
    <copy>
    cd $ORACLE_HOME/OPatch
    ls -l datapatch
    </copy>

    -- Be sure to hit RETURN
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

    ```
    <copy>
    ./datapatch -version
    </copy>
    ```

    * Although Datapatch is located in the *OPatch* directory, you update Datapatch via Release Updates, not by updating OPatch.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ ./datapatch -version
    SQL Patching tool version 19.21.0.0.0 Production on Thu Oct 31 13:26:41 2024
    Copyright (c) 2012, 2023, Oracle.  All rights reserved.
    
    Build label: RDBMS_19.21.0.0.0DBRU_LINUX.X64_230923
    SQL Patching tool complete on Thu Oct 31 13:26:41 2024
    ```
    </details>  

3. Run the prerequisites check.

    ```
    <copy>
    ./datapatch -prereq
    </copy>
    ```

    * Datapatch works on one database only.
    * This check is non-instrusive. It examines your database and checks if Datapatch needs to install patches.
    * Datapatch reports that no patches need to be applied.
    * If you need to work on two databases at the same time, you would need to start another terminal, set the environment accordingly, and execute Datapatch.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ ./datapatch -prereq
    SQL Patching tool version 19.21.0.0.0 Production on Thu Oct 31 13:31:00 2024
    Copyright (c) 2012, 2023, Oracle.  All rights reserved.
    
    Log file for this invocation: /u01/app/oracle/cfgtoollogs/sqlpatch/sqlpatch_35298_2024_10_31_13_31_00/sqlpatch_invocation.log
    
    Connecting to database...OK
    Gathering database info...done
    Determining current state...done
    
    Current state of interim SQL patches:
    Interim patch 35648110 (OJVM RELEASE UPDATE: 19.21.0.0.231017 (35648110)):
      Binary registry: Installed
      SQL registry: Applied successfully on 10-JUL-24 04.20.22.526734 PM
    Interim patch 35787077 (DATAPUMP BUNDLE PATCH 19.21.0.0.0):
      Binary registry: Installed
      SQL registry: Applied successfully on 10-JUL-24 04.20.23.439857 PM
    
    Current state of release update SQL patches:
      Binary registry:
        19.21.0.0.0 Release_Update 230930151951: Installed
      SQL registry:
        Applied 19.21.0.0.0 Release_Update 230930151951 successfully on 10-JUL-24 04.20.22.518873 PM
    
    Adding patches to installation queue and performing prereq checks...done
    Installation queue:
      No interim patches need to be rolled back
      No release update patches need to be installed
      No interim patches need to be applied
    
    SQL Patching tool complete on Thu Oct 31 13:31:15 2024    
    ```
    </details>  

4. Run Datapatch Sanity Checks.

    ```
    <copy>
    ./datapatch -sanity_checks
    </copy>
    ```

    * The sanity checks are lightweight and non-instrusive. You can run it on a live database.
    * It examines your database for issues that are known to cause problems during patching.
    * You can ignore the warning *Use of uninitialized value ...*. That's a bug fixed in a later version of Datapatch.
    
    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL Patching sanity checks version 19.21.0.0.0 on Thu 31 Oct 2024 02:03:06 PM GMT
    Copyright (c) 2021, 2024, Oracle.  All rights reserved.
    
    Log file for this invocation: /u01/app/oracle/cfgtoollogs/sqlpatch/sanity_checks_20241031_140306_37299/sanity_checks_20241031_140306_37299.log
    
    Running checks
    JSON report generated in /u01/app/oracle/cfgtoollogs/sqlpatch/sanity_checks_20241031_140306_37299/sqlpatch_sanity_checks_summary.json file
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
      :
        |         JOB_NAME         |            NEXT_RUN_DATE            | SCHEMA_NAME |   STATE   |
        |--------------------------+-------------------------------------+-------------+-----------|
        | CLEANUP_ONLINE_IND_BUILD | 31-OCT-24 02.09.00.285126 PM +00:00 |     SYS     | SCHEDULED |
        |--------------------------+-------------------------------------+-------------+-----------|
        |    CLEANUP_ONLINE_PMO    | 31-OCT-24 02.09.40.464841 PM +00:00 |     SYS     | SCHEDULED |
        |--------------------------+-------------------------------------+-------------+-----------|
        |   CLEANUP_TAB_IOT_PMO    | 31-OCT-24 02.09.10.248636 PM +00:00 |     SYS     | SCHEDULED |
        |--------------------------+-------------------------------------+-------------+-----------|
        |  CLEANUP_TRANSIENT_PKG   | 31-OCT-24 02.09.30.000000 PM +00:00 |     SYS     | SCHEDULED |
        |--------------------------+-------------------------------------+-------------+-----------|
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
    
    Refer to MOS Note 2680521.1 and debug log
    /u01/app/oracle/cfgtoollogs/sqlpatch/sanity_checks_20241031_140306_37299/sanity_checks_debug_20241031_140306_37299.log
    
    SQL Patching sanity checks completed on Thu 31 Oct 2024 02:03:27 PM GMT    
    ```
    </details>   

5. Connect to the *UPGR* database.

     ```
    <copy>
    sqlplus / as sysdba
    </copy>
    ```

6. Examine the Datapatch actions.

    ```
    <copy>
    col action format a8
    col description format a80
    set linesize 300
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
    SQL> col action format a8
    SQL> col description format a80
    SQL> set linesize 300
    SQL> select to_char(action_time, 'YYYY-MM-DD') as event_date,
                patch_id,
                patch_type,
                action,
                description
         from dba_registry_sqlpatch
         order by action_time;

    EVENT_DATE PATCH_ID   PATCH_TYPE ACTION   DESCRIPTION
    ---------- ---------- ---------- -------- -----------------------------------------------------
    2024-07-10 35643107   RU         APPLY    Database Release Update : 19.21.0.0.231017 (35643107)
    2024-07-10 35648110   INTERIM    APPLY    OJVM RELEASE UPDATE: 19.21.0.0.231017 (35648110)
    2024-07-10 35787077   INTERIM    APPLY    DATAPUMP BUNDLE PATCH 19.21.0.0.0
    ```
    </details>       

## Task 4: Useful queries

Here are a few useful queries that informs about the database.

1. Still connected to the *UPGR* database. Get the Oracle home of the database.

    ```
    <copy>
    col oracle_home format a60
    select sys_context('USERENV','ORACLE_HOME') as oracle_home from dual;
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> col oracle_home format a60
    SQL> select sys_context('USERENV','ORACLE_HOME') as oracle_home from dual;

    ORACLE_HOME
    ------------------------------------------------------------
    /u01/app/oracle/product/19
    ```
    </details>     

2. Get the full version of the database.

    ```
    <copy>
    select version_full from v$instance;
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> select version_full from v$instance;

    VERSION_FULL
    -----------------
    19.21.0.0.0
    ```
    </details>     

3. List the components installed in the database.

    ```
    <copy>
    col comp_id format a10
    col version_full format a15
    col status format a15    
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
    SQL> col comp_id format a10
    SQL> col version_full format a15
    SQL> col status format a15
    SQL> select comp_id,
                version_full,
                status
         from dba_registry
         order by comp_id;

    COMP_ID    VERSION_FULL    STATUS
    ---------- --------------- ---------------
    CATALOG    19.21.0.0.0     VALID
    CATPROC    19.21.0.0.0     VALID
    OWM        19.21.0.0.0     VALID
    RAC        19.21.0.0.0     OPTION OFF
    XDB        19.21.0.0.0     VALID
    ```
    </details>    

4. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```    

## Task 5: Check AutoUpgrade

Oracle recommends that you always use the latest version of AutoUpgrade.

1. Check the version of AutoUpgrade.

    ```
    <copy>
    cd
    java -jar autoupgrade.jar -version
    </copy>

    -- Be sure to hit RETURN
    ```

    * *MOS_LINK* contains the URL to the My Oracle Support document where you can download the latest version of AutoUpgrade.
    * In this lab, you will use the existing version.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ cd
    $ java -jar autoupgrade.jar -version
    build.version 24.8.241119
    build.date 2024/11/19 12:49:28 -0500
    build.hash b404cf007
    build.hash_date 2024/11/18 14:39:19 -0500
    build.supported_target_versions 12.2,18,19,21,23
    build.type production
    build.label (HEAD, tag: v24.8, origin/stable_devel, stable_devel)
    build.MOS_NOTE 2485457.1
    build.MOS_LINK https://support.oracle.com/epmos/faces/DocumentDisplay?id=2485457.1
    ```
    </details>   

You may now *proceed to the next lab*. Return to *lab 2* if you didn't finish it.

## Acknowledgements

* **Author** - Daniel Overby Hansen
* **Contributors** - Rodrigo Jorge, Mike Dietrich
* **Last Updated By/Date** - Daniel Overby Hansen, January 2025