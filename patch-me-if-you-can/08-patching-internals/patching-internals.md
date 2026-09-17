# Patching Internals

## Introduction

In this lab, you will examine how parts of Datapatch work. This will give you insight into the patching process.

Estimated Time: 15 Minutes

### Objectives

In this lab, you will:

* Check Datapatch infrastructure and logs
* Delete old patch files and metadata

### Prerequisites

This lab assumes:

* You have completed Lab 7: Advanced Patching

## Task 1: Examine Datapatch tables

Datapatch stores patching information inside the database. Understanding these tables helps you understand how Datapatch works.

1. Use the *yellow* terminal 🟨. Set the environment to the *UPGR* database and connect.

    ``` sql
    <copy>
    clear
    . upgr
    sql / as sysdba
    </copy>
    ```

2. Datapatch uses two tables to keep track of patching activities. Examine the two tables.

    ``` sql
    <copy>
    desc REGISTRY$SQLPATCH_RU_INFO
    desc REGISTRY$SQLPATCH
    </copy>
    ```

    * Datapatch uses `REGISTRY$SQLPATCH_RU_INFO` to hold information about Release Updates, whereas it uses `REGISTRY$SQLPATCH` for all patches.
    * Notice the additional columns in `REGISTRY$SQLPATCH`.
    * The `PATCH_DIRECTORY` column contains the rollback script for a specific patch. Datapatch always adds the rollback script to the database when applying a patch. This ensures that Datapatch can always perform a rollback, if needed, even if the original Oracle home is missing.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> desc REGISTRY$SQLPATCH_RU_INFO
     Name                       Null?    Type
     -------------------------- -------- ------------
     PATCH_ID                   NOT NULL NUMBER
     PATCH_UID                  NOT NULL NUMBER
     PATCH_DESCRIPTOR                    XMLTYPE
     RU_VERSION                          VARCHAR2(15)
     RU_BUILD_DESCRIPTION                VARCHAR2(80)
     RU_BUILD_TIMESTAMP                  TIMESTAMP(6)
     PATCH_DIRECTORY                     BLOB

    SQL> desc REGISTRY$SQLPATCH
     Name                       Null?    Type
     -------------------------- -------- ------------
     INSTALL_ID                 NOT NULL NUMBER
     PATCH_ID                   NOT NULL NUMBER
     PATCH_UID                  NOT NULL NUMBER
     PATCH_TYPE                 NOT NULL VARCHAR2(10)
     ACTION                     NOT NULL VARCHAR2(15)
     STATUS                     NOT NULL VARCHAR2(25)
     ACTION_TIME                NOT NULL TIMESTAMP(6)
     DESCRIPTION                         VARCHAR2(100)
     LOGFILE                    NOT NULL VARCHAR2(500)
     RU_LOGFILE                          VARCHAR2(500)
     FLAGS                               VARCHAR2(10)
     PATCH_DESCRIPTOR           NOT NULL XMLTYPE
     PATCH_DIRECTORY                     BLOB
     SOURCE_VERSION                      VARCHAR2(15)
     SOURCE_BUILD_DESCRIPTION            VARCHAR2(80)
     SOURCE_BUILD_TIMESTAMP              TIMESTAMP(6)
     TARGET_VERSION                      VARCHAR2(15)
     TARGET_BUILD_DESCRIPTION            VARCHAR2(80)
     TARGET_BUILD_TIMESTAMP              TIMESTAMP(6)
    ```

    </details>

3. To check Datapatch activity, do not use the dictionary tables. Instead, use the `DBA_REGISTRY_SQLPATCH` view. Examine the patching history of this database.

    ``` sql
    <copy>
    select   patch_id, action, status, action_time, description
    from     dba_registry_sqlpatch
    order by action_time;
    </copy>
    ```

    * This database was first patched from the base release, 19.3, to 19.29, including the OJVM and Data Pump bundle patches.
    * Then it was patched to 19.30, then to 19.31, and finally to 19.32 in Lab 4.
    * In lab 7, you performed a rollback to 19.31. That removed the 19.32 patching information from the dictionary.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
       PATCH_ID      ACTION     STATUS                        ACTION_TIME                                              DESCRIPTION
    ___________ ___________ __________ __________________________________ ________________________________________________________
       38194382 APPLY       SUCCESS    01-SEP-26 01.09.16.786413000 PM    OJVM RELEASE UPDATE: 19.29.0.0.251021 (38194382)
       38291812 APPLY       SUCCESS    01-SEP-26 01.10.51.564986000 PM    Database Release Update : 19.29.0.0.251021 (38291812)
       38535360 APPLY       SUCCESS    01-SEP-26 01.11.03.247364000 PM    DATAPUMP BUNDLE PATCH 19.29.0.0.0
       38194382 ROLLBACK    SUCCESS    04-SEP-26 10.09.04.665639000 AM    OJVM RELEASE UPDATE: 19.29.0.0.251021 (38194382)
       38523609 APPLY       SUCCESS    04-SEP-26 10.09.04.748117000 AM    OJVM RELEASE UPDATE: 19.30.0.0.260120 (38523609)
       38535360 ROLLBACK    SUCCESS    04-SEP-26 10.09.05.045782000 AM    DATAPUMP BUNDLE PATCH 19.29.0.0.0
       38632161 APPLY       SUCCESS    04-SEP-26 10.09.27.063171000 AM    Database Release Update : 19.30.0.0.260120(REL-JAN260130) (38632161)
       38844367 APPLY       SUCCESS    04-SEP-26 10.09.32.481615000 AM    19.30 OJVM PATCH APPLY IS FAILING ON SECOND NODE IN RAC ENVIRONMENT
       38844733 APPLY       SUCCESS    04-SEP-26 10.09.59.492225000 AM    DATAPUMP BUNDLE PATCH 19.30.0.0.0
       38523609 ROLLBACK    SUCCESS    04-SEP-26 10.21.49.642475000 AM    OJVM RELEASE UPDATE: 19.30.0.0.260120 (38523609)
       38906621 APPLY       SUCCESS    04-SEP-26 10.21.49.695123000 AM    OJVM RELEASE UPDATE: 19.31.0.0.260421 (38906621)
       38844367 ROLLBACK    SUCCESS    04-SEP-26 10.21.49.707551000 AM    19.30 OJVM PATCH APPLY IS FAILING ON SECOND NODE IN RAC ENVIRONMENT
       38844733 ROLLBACK    SUCCESS    04-SEP-26 10.21.50.192497000 AM    DATAPUMP BUNDLE PATCH 19.30.0.0.0
       39034528 APPLY       SUCCESS    04-SEP-26 10.22.00.370013000 AM    Database Release Update : 19.31.0.0.260421 (REL-APR2026) (39034528)
       39196236 APPLY       SUCCESS    04-SEP-26 10.22.22.775483000 AM    DATAPUMP BUNDLE PATCH 19.31.0.0.0

    15 rows selected.
    ```

    </details>

4. Find the log file used to apply the 19.31 Release Update.

    ``` sql
    <copy>
    select logfile
    from   dba_registry_sqlpatch
    where  description like 'Database Release Update : 19.31%'
           and action='APPLY';
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> select logfile
         from   dba_registry_sqlpatch
         where  description like 'Database Release Update : 19.31%'
                and action='APPLY';

    LOGFILE
    ----------------------------------------------------------------------------------------------------
    /u01/app/oracle/cfgtoollogs/sqlpatch/39034528/28740323/39034528_apply_UPGR_2026Sep04_10_21_50.log
    ```

    </details>

5. Exit SQLcl.

    ``` bash
    <copy>
    exit
    </copy>
    ```

## Task 2: Examine Datapatch logs

Datapatch also stores log files in the file system.

1. Still in the *yellow* terminal 🟨. Examine the Datapatch logging directory.

    ``` bash
    <copy>
    cd $ORACLE_BASE/cfgtoollogs/sqlpatch
    ll
    </copy>

    # Be sure to press RETURN
    ```

    * `sqlpatch_history.txt` contains an overview of all Datapatch invocations.
    * Each invocation writes to a specific directory named `sqlpatch_<number>_<timestamp>`.
    * The apply and/or rollback actions for each patch are stored in a folder matching the patch number.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    total 32
    drwxr-xr-x. 3 oracle oinstall   22 Sep  4 10:08 38194382
    -rw-r--r--. 1 oracle oinstall    0 Sep  4 10:08 38194382_27894333.lock
    drwxr-xr-x. 3 oracle oinstall   22 Sep  4 10:08 38523609
    -rw-r--r--. 1 oracle oinstall    0 Sep  4 10:08 38523609_28341036.lock
    drwxr-xr-x. 3 oracle oinstall   22 Sep  4 10:08 38535360
    -rw-r--r--. 1 oracle oinstall    0 Sep  4 10:08 38535360_28165873.lock
    drwxr-xr-x. 3 oracle oinstall   22 Sep  4 10:08 38632161
    -rw-r--r--. 1 oracle oinstall    0 Sep  4 10:08 38632161_28482211.lock
    drwxr-xr-x. 3 oracle oinstall   22 Sep  4 10:08 38844367
    -rw-r--r--. 1 oracle oinstall    0 Sep  4 10:08 38844367_28560248.lock
    drwxr-xr-x. 3 oracle oinstall   22 Sep  4 10:08 38844733
    -rw-r--r--. 1 oracle oinstall    0 Sep  4 10:08 38844733_28440761.lock
    drwxr-xr-x. 3 oracle oinstall   22 Sep  4 10:21 38906621
    -rw-r--r--. 1 oracle oinstall    0 Sep  4 10:21 38906621_28588735.lock
    drwxr-xr-x. 3 oracle oinstall   22 Sep  4 10:21 39034528
    -rw-r--r--. 1 oracle oinstall    0 Sep  4 10:21 39034528_28740323.lock
    drwxr-xr-x. 3 oracle oinstall   22 Sep  4 10:21 39196236
    -rw-r--r--. 1 oracle oinstall    0 Sep  4 10:21 39196236_28705537.lock
    drwxr-xr-x. 3 oracle oinstall   22 Sep  4 12:30 39222882
    -rw-r--r--. 1 oracle oinstall    0 Sep  4 12:30 39222882_28830205.lock
    drwxr-xr-x. 3 oracle oinstall   22 Sep  4 12:29 39472050
    -rw-r--r--. 1 oracle oinstall    0 Sep  4 12:29 39472050_28919163.lock
    drwxr-xr-x. 3 oracle oinstall   22 Sep  4 12:30 39657094
    -rw-r--r--. 1 oracle oinstall    0 Sep  4 12:30 39657094_28915841.lock
    drwxr-xr-x. 2 oracle oinstall  149 Sep  4 12:21 sanity_checks_20260904_122135_24961
    drwxr-xr-x. 2 oracle oinstall 4096 Sep  5 06:03 sqlpatch_130093_2026_09_05_06_00_22
    drwxr-xr-x. 2 oracle oinstall 4096 Sep  5 06:05 sqlpatch_131103_2026_09_05_06_04_25
    drwxr-xr-x. 2 oracle oinstall 4096 Sep  5 06:14 sqlpatch_134490_2026_09_05_06_11_49
    drwxr-xr-x. 2 oracle oinstall 4096 Sep  4 10:10 sqlpatch_223407_2026_09_04_10_08_23
    drwxr-xr-x. 2 oracle oinstall 4096 Sep  4 10:22 sqlpatch_229127_2026_09_04_10_21_03
    drwxr-xr-x. 2 oracle oinstall 4096 Sep  4 12:21 sqlpatch_24360_2026_09_04_12_20_42
    drwxr-xr-x. 2 oracle oinstall  133 Sep  4 12:30 sqlpatch_35239_2026_09_04_12_29_31
    drwxr-xr-x. 2 oracle oinstall 4096 Sep  4 12:31 sqlpatch_35670_2026_09_04_12_30_19
    -rw-r--r--. 1 oracle oinstall  893 Sep  5 06:11 sqlpatch_history.txt
    ```

    </details>

2. Examine the log file used to apply the 19.31 Release Update to the *UPGR* database. This is the log file you found in the previous task.

    ``` bash
    <copy>
    cd $ORACLE_BASE/cfgtoollogs/sqlpatch
    head -n20 39034528/28740323/39034528_apply_UPGR_*.log
    </copy>

    # Be sure to press RETURN
    ```

    * The apply starts by recording the action to the Datapatch tables through `DBMS_SQLPATCH`.
    * These tables and packages are for internal use only. You should never use them, but they give an understanding of the patch infrastructure.
    * If you want, you can view more of the file using `vi`.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL>
    SQL> SET PAGESIZE 0
    SQL> SELECT 'Starting apply for patch 39034528/28740323 on ' ||
      2         SYSTIMESTAMP FROM dual;
    Starting apply for patch 39034528/28740323 on 04-SEP-26 10.21.50.203980 AM +00:0
    0


    1 row selected.

    Elapsed: 00:00:00.00
    SQL> SET PAGESIZE 10
    SQL>
    SQL> BEGIN
      2      dbms_sqlpatch.patch_initialize(p_patch_id      => 39034528,
      3                                     p_patch_uid     => 28740323,
      4                                     p_logfile       => '&full_logfile');
      5  END;
      6  /
    ```

    </details>

3. Each invocation has its own subdirectory named `sqlpatch_<number>_<timestamp>`. Change to one of the directories and examine its files.

4. When Datapatch applies patches it might invalidate objects. Datapatch keeps track of this and will recompile the objects at the end of the patching process. Examine the log files for traces of recompilation.

    ``` bash
    <copy>
    cd $ORACLE_BASE/cfgtoollogs/sqlpatch
    grep -ri --include='*autorecomp*' "Invalid ORACLE_MAINTAINED" .
    </copy>

    # Be sure to press RETURN
    ```

    * The results might vary in your environment.
    * In the example below, you can see recompilation after patching a container database.
    * For each container, you can see the number of invalid objects before patching (in the prerequisite phase).
    * You can also see the number of invalid objects after patching.
    * Datapatch always recompile all Oracle-maintained objects invalidated by the patching.
    * After the Datapatch recompilation there shouldn't be any invalid objects.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    ./sqlpatch_223407_2026_09_04_10_08_23/sqlpatch_autorecomp_UPGR.log:  UPGR - Number of invalid ORACLE_MAINTAINED objects in prereq phase: 0
    ./sqlpatch_223407_2026_09_04_10_08_23/sqlpatch_autorecomp_upgr.log:{upgr} Invalid ORACLE_MAINTAINED objects: after patching=14
    ./sqlpatch_229127_2026_09_04_10_21_03/sqlpatch_autorecomp_UPGR.log:  UPGR - Number of invalid ORACLE_MAINTAINED objects in prereq phase: 0
    ./sqlpatch_229127_2026_09_04_10_21_03/sqlpatch_autorecomp_upgr.log:{upgr} Invalid ORACLE_MAINTAINED objects: after patching=0
    ./sqlpatch_24360_2026_09_04_12_20_42/sqlpatch_autorecomp_UPGR.log:  UPGR - Number of invalid ORACLE_MAINTAINED objects in prereq phase: 0
    ./sqlpatch_35670_2026_09_04_12_30_19/sqlpatch_autorecomp_UPGR.log:  UPGR - Number of invalid ORACLE_MAINTAINED objects in prereq phase: 0
    ./sqlpatch_130093_2026_09_05_06_00_22/sqlpatch_autorecomp_CDBROOT.log:  CDB$ROOT - Number of invalid ORACLE_MAINTAINED objects in prereq phase: 0
    ./sqlpatch_130093_2026_09_05_06_00_22/sqlpatch_autorecomp_CDBROOT.log:{CDB$ROOT} Invalid ORACLE_MAINTAINED objects: after patching=10
    ./sqlpatch_130093_2026_09_05_06_00_22/sqlpatch_autorecomp_PDBSEED.log:  PDB$SEED - Number of invalid ORACLE_MAINTAINED objects in prereq phase: 0
    ./sqlpatch_130093_2026_09_05_06_00_22/sqlpatch_autorecomp_PDBSEED.log:{PDB$SEED} Invalid ORACLE_MAINTAINED objects: after patching=40
    ./sqlpatch_130093_2026_09_05_06_00_22/sqlpatch_autorecomp_ORANGE.log:  ORANGE - Number of invalid ORACLE_MAINTAINED objects in prereq phase: 0
    ./sqlpatch_130093_2026_09_05_06_00_22/sqlpatch_autorecomp_ORANGE.log:{ORANGE} Invalid ORACLE_MAINTAINED objects: after patching=40
    ./sqlpatch_130093_2026_09_05_06_00_22/sqlpatch_autorecomp_TERRACOTTA.log:  TERRACOTTA - Number of invalid ORACLE_MAINTAINED objects in prereq phase: 0
    ./sqlpatch_130093_2026_09_05_06_00_22/sqlpatch_autorecomp_TERRACOTTA.log:{TERRACOTTA} Invalid ORACLE_MAINTAINED objects: after patching=40
    ./sqlpatch_131103_2026_09_05_06_04_25/sqlpatch_autorecomp_INDIGO.log:  INDIGO - Number of invalid ORACLE_MAINTAINED objects in prereq phase: 0
    ./sqlpatch_131103_2026_09_05_06_04_25/sqlpatch_autorecomp_INDIGO.log:{INDIGO} Invalid ORACLE_MAINTAINED objects: after patching=40
    ./sqlpatch_134490_2026_09_05_06_11_49/sqlpatch_autorecomp_CDBROOT.log:  CDB$ROOT - Number of invalid ORACLE_MAINTAINED objects in prereq phase: 0
    ./sqlpatch_134490_2026_09_05_06_11_49/sqlpatch_autorecomp_CDBROOT.log:{CDB$ROOT} Invalid ORACLE_MAINTAINED objects: after patching=10
    ./sqlpatch_134490_2026_09_05_06_11_49/sqlpatch_autorecomp_PDBSEED.log:  PDB$SEED - Number of invalid ORACLE_MAINTAINED objects in prereq phase: 0
    ./sqlpatch_134490_2026_09_05_06_11_49/sqlpatch_autorecomp_PDBSEED.log:{PDB$SEED} Invalid ORACLE_MAINTAINED objects: after patching=41
    ./sqlpatch_134490_2026_09_05_06_11_49/sqlpatch_autorecomp_INDIGO.log:  INDIGO - Number of invalid ORACLE_MAINTAINED objects in prereq phase: 0
    ./sqlpatch_134490_2026_09_05_06_11_49/sqlpatch_autorecomp_INDIGO.log:{INDIGO} Invalid ORACLE_MAINTAINED objects: after patching=41
    ./sqlpatch_134490_2026_09_05_06_11_49/sqlpatch_autorecomp_ORANGE.log:  ORANGE - Number of invalid ORACLE_MAINTAINED objects in prereq phase: 0
    ./sqlpatch_134490_2026_09_05_06_11_49/sqlpatch_autorecomp_ORANGE.log:{ORANGE} Invalid ORACLE_MAINTAINED objects: after patching=41
    ./sqlpatch_134490_2026_09_05_06_11_49/sqlpatch_autorecomp_TERRACOTTA.log:  TERRACOTTA - Number of invalid ORACLE_MAINTAINED objects in prereq phase: 0
    ./sqlpatch_134490_2026_09_05_06_11_49/sqlpatch_autorecomp_TERRACOTTA.log:{TERRACOTTA} Invalid ORACLE_MAINTAINED objects: after patching=41
    ```

    </details>

5. In fact, there is no functionality in Datapatch. It is just a wrapper for another tool called *SQLPatch*. However, Oracle always refers to Datapatch as the patching tool. Examine the Datapatch script.

    ``` bash
    <copy>
    cd $ORACLE_HOME/OPatch
    cat datapatch
    </copy>

    # Be sure to press RETURN
    ```

    * *SQLPatch* is found in `$ORACLE_HOME/sqlpatch`.
    * Since SQLPatch is not in the `OPatch` folder, it means that you do not update Datapatch when you update OPatch.
    * SQLPatch is updated by Release Updates.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    $ cd $ORACLE_HOME/OPatch
    $ cat datapatch
    #!/bin/sh
    #
    # $Header: opatch/OPatch/datapatch /main/3 2016/09/16 23:29:40 vkekalo Exp $
    #
    # t.sh
    #
    # Copyright (c) 2012, 2016, Oracle and/or its affiliates. All rights reserved.
    #
    #    NAME
    #      datapatch - <one-line expansion of the name>
    #
    #    DESCRIPTION
    #      <short description of component this file declares/defines>
    #
    #    NOTES
    #      <other useful comments, qualifications, etc.>
    #
    #    MODIFIED   (MM/DD/YY)
    #    opatch    09/03/15 - : Update the copyright year
    #    opatch      07/12/12 - : Creation

    # Call sqlpatch to do the real work
    $ORACLE_HOME/sqlpatch/sqlpatch $@
    ```

    </details>

## Task 3: Patch Storage Clean-Up

OPatch keeps track of all the patches that you apply over time to an Oracle home. It stores patching metadata as well as the patch files themselves.

1. Stay in the *yellow* terminal 🟨. Set the environment and use OPatch to generate a list of patch metadata.

    ``` bash
    <copy>
    . upgr
    cd $ORACLE_HOME/OPatch
    ./opatch util ListOrderedInactivePatches
    </copy>

    # Be sure to press RETURN
    ```

    * The output shows that the patching chain in this Oracle home is from 19.3 (base release) to 19.29 to 19.30 and then 19.31.
    * This means that several in-place patch applies have been made to this Oracle home. Oracle does not recommend in-place patching. It is used here for illustrative purposes.
    * The *active* RU is 19.31 - this is where the Oracle home currently is.
    * The *inactive* RUs are 19.3, 19.29, and 19.30; this is where the Oracle home came from.

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
    Log file location : /u01/app/oracle/product/19/cfgtoollogs/opatch/opatch2026-09-02_10-36-32AM_1.log

    Invoking utility "listorderedinactivepatches"
    List Inactive patches option provided

    The oracle home has the following inactive patch(es) and their respective overlay patches:

    The number of RU chains is  2

    ***** There are 3 inactive RU patches in chain 1
    -Inactive RU/BP 29517242:Database Release Update : 19.3.0.0.190416 (29517242), installed on: Thu Apr 18 07:21:17 GMT 2019, with no overlays
    -Inactive RU/BP 38291812:Database Release Update : 19.29.0.0.251021 (38291812), installed on: Tue Sep 01 12:21:53 GMT 2026, with no overlays
    -Inactive RU/BP 38632161:Database Release Update : 19.30.0.0.260120(REL-JAN260130) (38632161), installed on: Tue Sep 01 13:17:09 GMT 2026, with no overlays
    -Active RU/BP 39034528:Database Release Update : 19.31.0.0.260421 (REL-APR2026) (39034528), installed on: Tue Sep 01 13:29:45 GMT 2026, with no overlays

    ***** There are 2 inactive RU patches in chain 2
    -Inactive RU/BP 38194382:OJVM RELEASE UPDATE: 19.29.0.0.251021 (38194382), installed on: Tue Sep 01 12:25:14 GMT 2026, with no overlays
    -Inactive RU/BP 38523609:OJVM RELEASE UPDATE: 19.30.0.0.260120 (38523609), installed on: Tue Sep 01 13:21:44 GMT 2026, with overlays: 38844367
    -Active RU/BP 38906621:OJVM RELEASE UPDATE: 19.31.0.0.260421 (38906621), installed on: Tue Sep 01 13:35:29 GMT 2026, with no overlays

    OPatch succeeded.
    ```

    </details>

2. You can remove information about the *inactive* patches. This reduces the patching metadata which makes OPatch run faster. It also deletes patches from the `.patch_storage` directory inside the Oracle home and reduces the space used. Check the size of the `.patch_storage` folder.

    ``` bash
    <copy>
    du -sh $ORACLE_HOME/.patch_storage
    </copy>
    ```

    * Currently, OPatch uses 9.4 GB to store old patch files. All the way back to 19.3.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    9.4G  /u01/app/oracle/product/19/.patch_storage
    ```

    </details>

3. Delete the inactive patches.

    ``` bash
    <copy>
    ./opatch util deleteinactivepatches
    </copy>
    ```

    * When prompted to proceed, enter *Y*.
    * OPatch keeps one inactive patch and deletes the rest of the inactive patches.
    * Keeping one inactive patch - the latest - ensures that you can always roll back to the previous patch. Going back even further would require that you restore the files or simply install a new Oracle home with the required patches.
    * The number of inactive patches to keep is configurable.
    * If OPatch runs slowly in your own environment, try to clear out inactive patching metadata.
    * If you patch out of place, you do not need this functionality.

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
    Log file location : /u01/app/oracle/product/19/cfgtoollogs/opatch/opatch2026-09-02_10-41-15AM_1.log

    Invoking utility "deleteinactivepatches"
    Inactive Patches Cleanup option provided
    Delete Inactive Patches .......

    ***** There are 3 inactive RU patches in chain 1

    ***** 2 inactive patches will be deleted
    -To be deleted inactive RU/BP 29517242:Database Release Update : 19.3.0.0.190416 (29517242), installed on: Thu Apr 18 07:21:17 GMT 2019, with no overlays
    -To be deleted inactive RU/BP 38291812:Database Release Update : 19.29.0.0.251021 (38291812), installed on: Tue Sep 01 12:21:53 GMT 2026, with no overlays
    -To be retained inactive RU/BP 38632161:Database Release Update : 19.30.0.0.260120(REL-JAN260130) (38632161), installed on: Tue Sep 01 13:17:09 GMT 2026, with no overlays
    -Active RU/BP 39034528:Database Release Update : 19.31.0.0.260421 (REL-APR2026) (39034528), installed on: Tue Sep 01 13:29:45 GMT 2026, with no overlays

    ***** There are 2 inactive RU patches in chain 2

    ***** 1 inactive patches will be deleted
    -To be deleted inactive RU/BP 38194382:OJVM RELEASE UPDATE: 19.29.0.0.251021 (38194382), installed on: Tue Sep 01 12:25:14 GMT 2026, with no overlays
    -To be retained inactive RU/BP 38523609:OJVM RELEASE UPDATE: 19.30.0.0.260120 (38523609), installed on: Tue Sep 01 13:21:44 GMT 2026, with overlays: 38844367
    -Active RU/BP 38906621:OJVM RELEASE UPDATE: 19.31.0.0.260421 (38906621), installed on: Tue Sep 01 13:35:29 GMT 2026, with no overlays

    Do you want to proceed? [y|n]
    y
    User Responded with: Y
    Deleted RU/BP patch: 29517242
    Deleted RU/BP patch: 38291812
    Deleted RU/BP patch: 38194382

    OPatch succeeded.
    ```

    </details>

4. How much space did you reclaim inside the Oracle home? Check the size of the `.patch_storage` folder.

    ``` bash
    <copy>
    du -sh $ORACLE_HOME/.patch_storage
    </copy>
    ```

    * Now, OPatch uses 6.2 GB to store old patch files.
    * You reclaimed more than 3 GB.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    6.2G  /u01/app/oracle/product/19/.patch_storage
    ```

    </details>

5. OPatch stores the patching information in the Oracle home. Examine the directory.

    ``` bash
    <copy>
    cd $ORACLE_HOME/.patch_storage
    ll
    </copy>

    # Be sure to press RETURN
    ```

    * You should never delete files from this directory manually.
    * Instead, use the `opatch util deleteinactivepatches` command.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    total 424
    drwxr-xr-x.  3 oracle oinstall     74 Apr 18  2019 29585399_Apr_9_2019_19_12_47
    drwxr-xr-x.  4 oracle oinstall     87 Sep  1 13:22 38523609_Jan_13_2026_05_30_16
    drwxr-xr-x.  4 oracle oinstall     87 Sep  1 13:20 38632161_Jan_27_2026_05_17_30
    drwxr-xr-x.  4 oracle oinstall     87 Sep  1 13:24 38844367_Mar_4_2026_07_51_42
    drwxr-xr-x.  4 oracle oinstall     87 Sep  1 13:35 38906621_Apr_28_2026_12_39_34
    drwxr-xr-x.  4 oracle oinstall     87 Sep  1 13:34 39034528_May_14_2026_10_49_49
    drwxr-xr-x.  4 oracle oinstall     87 Sep  1 13:37 39196236_Apr_29_2026_15_21_56
    drwxr-xr-x.  3 oracle oinstall     33 Sep  2 10:42 backup_delete_inactive
    -rw-r--r--.  1 oracle oinstall 145459 Sep  1 13:37 interim_inventory.txt
    -rw-r-----.  1 oracle oinstall     93 Sep  1 13:37 LatestOPatchSession.properties
    drwxr-xr-x. 16 oracle oinstall   4096 Sep  1 13:37 NApply
    -rw-r--r--.  1 oracle oinstall 131365 Sep  1 13:32 newdirs.txt
    -rw-r--r--.  1 oracle oinstall 143032 Sep  1 13:37 record_inventory.txt
    ```

    </details>

## Task 4: Datapatch Clean-Up

Every time you patch your database, Datapatch stores the rollback scripts inside the database. This ensures that Datapatch always has the option to roll back patches, even when you use out-of-place patching and the rollback scripts are no longer in the Oracle home. Datapatch stores the rollback scripts in the SYSTEM tablespace, which can consume a significant amount of space over time.

1. Stay in the *yellow* terminal 🟨. Set the environment and connect to the *UPGR* database.

    ``` sql
    <copy>
    . upgr
    sql / as sysdba
    </copy>
    ```

2. Generate a list of rollback scripts and the size of them.

    ``` sql
    <copy>
    select * from (
       select description, round(dbms_lob.getlength(PATCH_DIRECTORY)/1024/1024, 2) as size_mb
       from DBA_REGISTRY_SQLPATCH
       where action='APPLY' and description not like 'Database Release Update%'
       union
       select 'Release Update ' || RU_version as description, round(dbms_lob.getlength(PATCH_DIRECTORY)/1024/1024) as size_mb
       from DBA_REGISTRY_SQLPATCH_RU_INFO)
    order by description;
    </copy>
    ```

    * Datapatch stores the rollback script for each patch action in this database, including Release Updates and one-off patches.
    * The total size is approximately 700 MB. The underlying segments are in the SYSTEM tablespace.
    * In a container database, Datapatch stores the data in the root container and all PDBs.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    DESCRIPTION                                           SIZE_MB
    -------------------------------------------------- ----------
    19.30 OJVM PATCH APPLY IS FAILING ON SECOND NODE IN RAC ENVIRONMENT             0
    DATAPUMP BUNDLE PATCH 19.29.0.0.0                                            1.03
    DATAPUMP BUNDLE PATCH 19.30.0.0.0                                            1.08
    DATAPUMP BUNDLE PATCH 19.31.0.0.0                                            1.09
    OJVM RELEASE UPDATE: 19.29.0.0.251021 (38194382)                             0.02
    OJVM RELEASE UPDATE: 19.30.0.0.260120 (38523609)                             0.03
    OJVM RELEASE UPDATE: 19.31.0.0.260421 (38906621)                             0.03
    Release Update 19.29.0.0.0                                                    213
    Release Update 19.3.0.0.0                                                       4
    Release Update 19.30.0.0.0                                                    223
    Release Update 19.31.0.0.0                                                    233

    11 rows selected.
    ```

    </details>

3. Exit SQLcl

    ``` bash
    <copy>
    exit
    </copy>
    ```

4. Purge the old rollback scripts.

    ``` bash
    <copy>
    $ORACLE_HOME/OPatch/datapatch -purge_old_metadata
    </copy>
    ```

    * Datapatch removes the rollback scripts from the database for all patches except those that are currently applied.
    * This does not prevent you from rolling back the currently applied patches.
    * The old rollback scripts are no longer needed and can be safely cleaned up.
    * This does not remove the patching history, just the rollback scripts.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL Patching tool version 19.31.0.0.0 Production on Wed Sep  2 10:45:23 2026
    Copyright (c) 2012, 2026, Oracle.  All rights reserved.

    Log file for this invocation: /u01/app/oracle/cfgtoollogs/sqlpatch/sqlpatch_135655_2026_09_02_10_45_23/sqlpatch_invocation.log

    Connecting to database...OK
    Gathering database info...done
    Bootstrapping registry and package to current versions...done
    Determining current state...done

    Current state of interim SQL patches:
    Interim patch 38194382 (OJVM RELEASE UPDATE: 19.29.0.0.251021 (38194382)):
      Binary registry: Not installed
      SQL registry: Rolled back successfully on 01-SEP-26 01.24.58.500208 PM
    Interim patch 38523609 (OJVM RELEASE UPDATE: 19.30.0.0.260120 (38523609)):
      Binary registry: Not installed
      SQL registry: Rolled back successfully on 01-SEP-26 01.38.18.880352 PM
    Interim patch 38535360 (DATAPUMP BUNDLE PATCH 19.29.0.0.0):
      Binary registry: Not installed
      SQL registry: Rolled back successfully on 01-SEP-26 01.24.58.806838 PM
    Interim patch 38844367 (19.30 OJVM PATCH APPLY IS FAILING ON SECOND NODE IN RAC ENVIRONMENT):
      Binary registry: Not installed
      SQL registry: Rolled back successfully on 01-SEP-26 01.38.18.956087 PM
    Interim patch 38844733 (DATAPUMP BUNDLE PATCH 19.30.0.0.0):
      Binary registry: Not installed
      SQL registry: Rolled back successfully on 01-SEP-26 01.38.19.471926 PM
    Interim patch 38906621 (OJVM RELEASE UPDATE: 19.31.0.0.260421 (38906621)):
      Binary registry: Installed
      SQL registry: Applied successfully on 02-SEP-26 08.59.57.947550 AM
    Interim patch 39196236 (DATAPUMP BUNDLE PATCH 19.31.0.0.0):
      Binary registry: Installed
      SQL registry: Applied successfully on 02-SEP-26 09.00.49.338020 AM
    Interim patch 39222882 (OJVM RELEASE UPDATE: 19.32.0.0.260721 (39222882)):
      Binary registry: Not installed
      SQL registry: Rolled back successfully on 02-SEP-26 08.59.57.880157 AM
    Interim patch 39657094 (DATAPUMP BUNDLE PATCH 19.32.0.0.0):
      Binary registry: Not installed
      SQL registry: Rolled back successfully on 02-SEP-26 08.59.58.184537 AM

    Current state of release update SQL patches:
      Binary registry:
        19.31.0.0.0 Release_Update 260514003012: Installed
      SQL registry:
        Rolled back to 19.31.0.0.0 Release_Update 260514003012 successfully on 02-SEP-26 09.00.16.186360 AM

      Purging old patch metadata process started...

    CAUTION: This could be I/O intensive sometimes due to cleanup of BLOB columns. If you find this process taking unusually long time or if you are seeing any impact to the     database performance, then abort this datapatch process and reschedule this clean up activity in a quiet maintenance window.

      Purge old patch metadata process completed.

    SQL Patching tool complete on Wed Sep  2 10:45:55 2026
    ```

    </details>

5. Reconnect to the database.

    ``` sql
    <copy>
    sql / as sysdba
    </copy>
    ```

6. Generate a list of rollback scripts and the size of them.

    ``` sql
    <copy>
    select * from (
       select description, round(dbms_lob.getlength(PATCH_DIRECTORY)/1024/1024, 2) as size_mb
       from DBA_REGISTRY_SQLPATCH
       where action='APPLY' and description not like 'Database Release Update%'
       union
       select 'Release Update ' || RU_version as description, round(dbms_lob.getlength(PATCH_DIRECTORY)/1024/1024) as size_mb
       from DBA_REGISTRY_SQLPATCH_RU_INFO)
    order by description;
    </copy>
    ```

    * The total size is around 230 MB.
    * The cleanup uses a `TRUNCATE TABLE` command, which effectively reclaims space for other segments to use. However, it does not shrink the tablespace, so the physical size of the data files remains the same.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
                                                               DESCRIPTION    SIZE_MB
    ______________________________________________________________________ __________
    19.30 OJVM PATCH APPLY IS FAILING ON SECOND NODE IN RAC ENVIRONMENT
    DATAPUMP BUNDLE PATCH 19.29.0.0.0
    DATAPUMP BUNDLE PATCH 19.30.0.0.0
    DATAPUMP BUNDLE PATCH 19.31.0.0.0                                            1.09
    DATAPUMP BUNDLE PATCH 19.31.0.0.0
    OJVM RELEASE UPDATE: 19.29.0.0.251021 (38194382)
    OJVM RELEASE UPDATE: 19.30.0.0.260120 (38523609)
    OJVM RELEASE UPDATE: 19.31.0.0.260421 (38906621)                             0.03
    OJVM RELEASE UPDATE: 19.31.0.0.260421 (38906621)
    Release Update 19.29.0.0.0
    Release Update 19.3.0.0.0
    Release Update 19.30.0.0.0
    Release Update 19.31.0.0.0                                                    233

    13 rows selected.
    ```

    </details>

You may now [*proceed to the next lab*](#next).

## Acknowledgements

* **Author** - Daniel Overby Hansen
* **Contributors** - Rodrigo Jorge, Alex Zaballa, Mike Dietrich, Alejandro Diaz
* **Last Updated By/Date** - Daniel Overby Hansen, September 2026
