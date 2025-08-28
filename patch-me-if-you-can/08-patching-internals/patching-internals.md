# Patching Internals

## Introduction

In this lab, you will examine how some parts of Datapatch works. This will give you insights into the patching process.

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

1. Use the *yellow* terminal 🟨. Set the environment to the *FTEX* database and connect.

    ``` sql
    <copy>
    . ftex
    sql / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

2. Datapatch uses two tables to keep track of patching activities. Examine the two tables.

    ``` sql
    <copy>
    desc REGISTRY$SQLPATCH_RU_INFO
    desc REGISTRY$SQLPATCH
    </copy>

    -- Be sure to hit RETURN
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

3. To check Datapatch activity you should not use the dictionary tables. Instead use the view `DBA_REGISTRY_SQLPATCH`. Examine the patching history of this database.

    ``` sql
    <copy>
    select   patch_id, action, status, action_time, description
    from     dba_registry_sqlpatch
    order by action_time;
    </copy>

    -- Be sure to hit RETURN
    ```

    * This database was first patched from the base release, 19.3, to 19.27, including the OJVM and Data Pump bundle patches.
    * Then, in a previous lab you patched the database to 19.28.
    * Finally, you manually rolled back to 19.27.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> select   patch_id, action, status, action_time, description
      2  from     dba_registry_sqlpatch
      3* order by action_time;

       PATCH_ID      ACTION     STATUS                        ACTION_TIME                                              DESCRIPTION
    ___________ ___________ __________ __________________________________ ________________________________________________________
       37499406 APPLY       SUCCESS    28-JUL-25 06.47.19.709775000 AM    OJVM RELEASE UPDATE: 19.27.0.0.250415 (37499406)
       37642901 APPLY       SUCCESS    28-JUL-25 06.49.05.749475000 AM    Database Release Update : 19.27.0.0.250415 (37642901)
       37777295 APPLY       SUCCESS    28-JUL-25 06.49.21.076437000 AM    DATAPUMP BUNDLE PATCH 19.27.0.0.0
       37499406 ROLLBACK    SUCCESS    06-AUG-25 02.51.46.116801000 PM    OJVM RELEASE UPDATE: 19.27.0.0.250415 (37499406)
       37847857 APPLY       SUCCESS    06-AUG-25 02.51.46.197901000 PM    OJVM RELEASE UPDATE: 19.28.0.0.250715 (37847857)
       37777295 ROLLBACK    SUCCESS    06-AUG-25 02.51.46.726059000 PM    DATAPUMP BUNDLE PATCH 19.27.0.0.0
       37960098 APPLY       SUCCESS    06-AUG-25 02.52.15.642992000 PM    Database Release Update : 19.28.0.0.250715 (37960098)
       38170982 APPLY       SUCCESS    06-AUG-25 02.53.07.995809000 PM    DATAPUMP BUNDLE PATCH 19.28.0.0.0
       37847857 ROLLBACK    SUCCESS    06-AUG-25 04.27.00.257227000 PM    OJVM RELEASE UPDATE: 19.28.0.0.250715 (37847857)
       37499406 APPLY       SUCCESS    06-AUG-25 04.27.00.306292000 PM    OJVM RELEASE UPDATE: 19.27.0.0.250415 (37499406)
       38170982 ROLLBACK    SUCCESS    06-AUG-25 04.27.03.284323000 PM    DATAPUMP BUNDLE PATCH 19.28.0.0.0
       37960098 ROLLBACK    SUCCESS    06-AUG-25 04.27.25.907309000 PM    Database Release Update : 19.28.0.0.250715 (37960098)
       37777295 APPLY       SUCCESS    06-AUG-25 04.27.57.047666000 PM    DATAPUMP BUNDLE PATCH 19.27.0.0.0

    13 rows selected.
    ```

    </details>

4. Find the log file used to apply the 19.28 Release Update.

    ``` sql
    <copy>
    select logfile
    from   dba_registry_sqlpatch
    where  description like 'Database Release Update : 19.28%'
           and action='APPLY';
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> select logfile
         from   dba_registry_sqlpatch
         where  description like 'Database Release Update : 19.28%'
                and action='APPLY';

    LOGFILE
    ----------------------------------------------------------------------------------------------------
    /u01/app/oracle/cfgtoollogs/sqlpatch/37960098/27635722/37960098_apply_FTEX_2025Jul26_06_13_58.log
    ```

    </details>

5. Exit SQLcl.

    ``` sql
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

    # Be sure to hit RETURN
    ```

    * `sqlpatch_history.txt` contains an overview of all Datapatch invocations.
    * Each invocation writes to a specific directory named `sqlpatch_<number>_<timestamp>`.
    * The apply and/or rollback actions of each patch is stored in a folder matching the patch number.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    $ cd $ORACLE_BASE/cfgtoollogs/sqlpatch
    $ ll
    total 48
    drwxr-x---. 3 oracle oinstall   22 Jul 24 10:21 36878697
    -rw-r-----. 1 oracle oinstall    0 Jul 24 10:21 36878697_25797620.lock
    drwxr-x---. 3 oracle oinstall   22 Jul 24 10:21 36912597
    -rw-r-----. 1 oracle oinstall    0 Jul 24 10:21 36912597_25871884.lock
    drwxr-x---. 3 oracle oinstall   22 Jul 24 10:21 37056207
    -rw-r-----. 1 oracle oinstall    0 Jul 24 10:21 37056207_25840925.lock
    drwxr-xr-x. 3 oracle oinstall   22 Jul 24 10:37 37102264
    -rw-r--r--. 1 oracle oinstall    0 Jul 24 10:37 37102264_25987410.lock
    drwxr-xr-x. 3 oracle oinstall   22 Jul 24 10:37 37260974
    -rw-r--r--. 1 oracle oinstall    0 Jul 24 10:37 37260974_26040769.lock
    drwxr-xr-x. 3 oracle oinstall   22 Jul 24 10:37 37470729
    -rw-r--r--. 1 oracle oinstall    0 Jul 24 10:37 37470729_26036111.lock
    drwxr-xr-x. 3 oracle oinstall   22 Jul 24 10:50 37499406
    -rw-r--r--. 1 oracle oinstall    0 Jul 24 10:50 37499406_26115603.lock
    drwxr-xr-x. 3 oracle oinstall   22 Jul 24 10:50 37642901
    -rw-r--r--. 1 oracle oinstall    0 Jul 24 10:50 37642901_27123174.lock
    drwxr-xr-x. 3 oracle oinstall   22 Jul 24 10:50 37777295
    -rw-r--r--. 1 oracle oinstall    0 Jul 24 10:50 37777295_27238855.lock
    drwxr-xr-x. 3 oracle oinstall   22 Jul 26 06:13 37847857
    -rw-r--r--. 1 oracle oinstall    0 Jul 26 06:13 37847857_27534561.lock
    drwxr-xr-x. 3 oracle oinstall   22 Jul 26 06:13 37960098
    -rw-r--r--. 1 oracle oinstall    0 Jul 26 06:13 37960098_27635722.lock
    drwxr-xr-x. 3 oracle oinstall   22 Jul 26 06:13 38170982
    -rw-r--r--. 1 oracle oinstall    0 Jul 26 06:13 38170982_27628376.lock
    drwxr-xr-x. 2 oracle oinstall  151 Jul 26 06:30 sanity_checks_20250726_062945_168019
    drwxr-xr-x. 2 oracle oinstall  134 Jul 26 06:13 sqlpatch_165318_2025_07_26_06_13_17
    drwxr-xr-x. 2 oracle oinstall 4096 Jul 26 06:15 sqlpatch_165611_2025_07_26_06_13_50
    drwxr-xr-x. 2 oracle oinstall 4096 Jul 26 06:16 sqlpatch_166073_2025_07_26_06_15_44
    drwxr-xr-x. 2 oracle oinstall  134 Jul 26 06:44 sqlpatch_172743_2025_07_26_06_44_20
    drwxr-xr-x. 2 oracle oinstall 4096 Jul 26 06:45 sqlpatch_172825_2025_07_26_06_44_29
    drwxr-x---. 2 oracle oinstall 4096 Jul 24 10:24 sqlpatch_175565_2025_07_24_10_21_21
    drwxr-xr-x. 2 oracle oinstall 4096 Jul 24 10:38 sqlpatch_181458_2025_07_24_10_36_38
    drwxr-xr-x. 2 oracle oinstall 4096 Jul 24 10:52 sqlpatch_186303_2025_07_24_10_49_53
    drwxr-x---. 2 oracle oinstall 4096 Jul 24 11:10 sqlpatch_188512_2025_07_24_11_06_55
    drwxr-x---. 2 oracle oinstall 4096 Jul 24 11:41 sqlpatch_193646_2025_07_24_11_37_19
    drwxr-xr-x. 2 oracle oinstall 4096 Jul 27 16:36 sqlpatch_302392_2025_07_27_16_34_06
    drwxr-xr-x. 2 oracle oinstall 4096 Jul 27 16:42 sqlpatch_303293_2025_07_27_16_42_12
    drwxr-xr-x. 2 oracle oinstall 4096 Jul 27 16:46 sqlpatch_304182_2025_07_27_16_44_43
    -rw-r-----. 1 oracle oinstall 1456 Jul 27 16:44 sqlpatch_history.txt
    ```

    </details>

2. Examine the log file used to apply the 19.28 Release Update to the FTEX database. This is the log file you found in the previous task.

    ``` bash
    <copy>
    cd $ORACLE_BASE/cfgtoollogs/sqlpatch
    head -n20 37960098/27635722/37960098_apply_FTEX_*.log
    </copy>

    # Be sure to hit RETURN
    ```

    * The apply starts by recording the action to the Datapatch tables through `DBMS_SQLPATCH`.
    * These tables and packages are for internal use only. You should never use them, but they give an understanding of the patch infrastructure.
    * If you want you can view more of the file using `vi`.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    $ cd $ORACLE_BASE/cfgtoollogs/sqlpatch
    $ head -n20 36912597/25871884/36912597_apply_FTEX_*.log
    SQL>
    SQL> SET PAGESIZE 0
    SQL> SELECT 'Starting apply for patch 37960098/27635722 on ' ||
      2         SYSTIMESTAMP FROM dual;
    Starting apply for patch 37960098/27635722 on 26-JUL-25 06.13.58.374133 AM +00:0
    0


    1 row selected.

    Elapsed: 00:00:00.00
    SQL> SET PAGESIZE 10
    SQL>
    SQL> BEGIN
      2      dbms_sqlpatch.patch_initialize(p_patch_id      => 37960098,
      3                                     p_patch_uid     => 27635722,
      4                                     p_logfile       => '&full_logfile');
      5  END;
      6  /
    ```

    </details>

3. Each invocation has it's own subdirectory named `sqlpatch_<number>_<timestamp>`. Change to one of the directories and examine the files.

4. When Datapatch applies patches it might invalidate objects. Datapatch keeps track of this and will recompile the objects at the end of the patching process. Examine the log files for traces of recompilation.

    ``` bash
    <copy>
    cd $ORACLE_BASE/cfgtoollogs/sqlpatch
    grep -r -i "Invalid ORACLE_MAINTAINED" *
    </copy>

    # Be sure to hit RETURN
    ```

    * The results might vary in your environment.
    * In the below example, you can see that *76* objects were invalidated. But Datapatch automatically recompiles them.
    * The *recomp_threshold* specifies the number of recompilations allowed before it is reported to the user.
    * Datapatch always tries to recompile all Oracle-maintained objects invalidated by the patching.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    $ cd $ORACLE_BASE/cfgtoollogs/sqlpatch
    $ grep -r -i "Invalid ORACLE_MAINTAINED" *
    sqlpatch_108337_2024_12_03_10_55_30/sqlpatch_catcon_0.log:{ftex} Invalid ORACLE_MAINTAINED objects: before patching=0, after patching=76, recomp_threshold=300
    sqlpatch_108337_2024_12_03_10_55_30/install1.sql:        'Invalid ORACLE_MAINTAINED objects: before patching=' || inv_count_pre ||
    sqlpatch_108337_2024_12_03_10_55_30/install1.sql:          'New invalid ORACLE_MAINTAINED object count exceeded the recomp_threshold; run utlrp.sql.');
    sqlpatch_108337_2024_12_03_10_55_30/install1.sql:               ' remaining invalid ORACLE_MAINTAINED objects.');
    sqlpatch_108337_2024_12_03_10_55_30/sqlpatch_autorecomp_ftex.log:{ftex} Invalid ORACLE_MAINTAINED objects: before patching=0, after patching=76, recomp_threshold=300
    ```

    </details>

5. In fact, there is no functionality in Datapatch. It is just a wrapper for another tool called *SQLPatch*. However, Oracle always refers to Datapatch as the patching tool. Examine the Datapatch script.

    ``` bash
    <copy>
    cd $ORACLE_HOME/OPatch
    cat datapatch
    </copy>

    # Be sure to hit RETURN
    ```

    * *SQLPatch* is found in `$ORACLE_HOME/sqlpatch`.
    * Since SQLPatch is not in the `OPatch` folder, it means that you don't update Datapatch when you update OPatch.
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

## Task 3: Patch storage clean-up

OPatch keeps track of all the patches that you apply over time to an Oracle home. It stores a lot of patching metadata as well as the actual patches.

1. Stay in the *yellow* terminal 🟨. Set the environment and use OPatch to generate a list of patch metadata.

    ``` bash
    <copy>
    . ftex
    cd $ORACLE_HOME/OPatch
    ./opatch util ListOrderedInactivePatches
    </copy>

    # Be sure to hit RETURN
    ```

    * The output shows that the patching chain in this Oracle home is from 19.3 (base release) to 19.25 to 19.26 and then 19.27.
    * This means that several in-place patch applies have been made to this Oracle home. Oracle doesn't recommend in-place patching. It's used here for illustrative purposes.
    * The *active* RU is 19.27 - this is where the Oracle home currently is.
    * The *inactive* RUs are 19.3, 19.25 and 19.26 - this is where the Oracle home came from.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    $ . ftex
    $ cd $ORACLE_HOME/OPatch
    $ ./opatch util ListOrderedInactivePatches
    Oracle Interim Patch Installer version 12.2.0.1.47
    Copyright (c) 2025, Oracle Corporation.  All rights reserved.


    Oracle Home       : /u01/app/oracle/product/19
    Central Inventory : /u01/app/oraInventory
       from           : /u01/app/oracle/product/19/oraInst.loc
    OPatch version    : 12.2.0.1.47
    OUI version       : 12.2.0.7.0
    Log file location : /u01/app/oracle/product/19/cfgtoollogs/opatch/opatch2025-07-27_17-04-29PM_1.log

    Invoking utility "listorderedinactivepatches"
    List Inactive patches option provided

    The oracle home has the following inactive patch(es) and their respective overlay patches:

    The number of RU chains is  2

    ***** There are 3 inactive RU patches in chain 1
    -Inactive RU/BP 29517242:Database Release Update : 19.3.0.0.190416 (29517242), installed on: Thu Apr 18 07:21:17 GMT 2019, with no overlays
    -Inactive RU/BP 36912597:Database Release Update : 19.25.0.0.241015 (36912597), installed on: Thu Jul 24 09:49:33 GMT 2025, with no overlays
    -Inactive RU/BP 37260974:Database Release Update : 19.26.0.0.250121 (37260974), installed on: Thu Jul 24 10:30:23 GMT 2025, with no overlays
    -Active RU/BP 37642901:Database Release Update : 19.27.0.0.250415 (37642901), installed on: Thu Jul 24 10:42:18 GMT 2025, with no overlays

    ***** There are 2 inactive RU patches in chain 2
    -Inactive RU/BP 36878697:OJVM RELEASE UPDATE: 19.25.0.0.241015 (36878697), installed on: Thu Jul 24 09:53:30 GMT 2025, with no overlays
    -Inactive RU/BP 37102264:OJVM RELEASE UPDATE: 19.26.0.0.250121 (37102264), installed on: Thu Jul 24 10:35:00 GMT 2025, with no overlays
    -Active RU/BP 37499406:OJVM RELEASE UPDATE: 19.27.0.0.250415 (37499406), installed on: Thu Jul 24 10:47:46 GMT 2025, with no overlays

    OPatch succeeded.
    ```

    </details>

2. You can remove information about the *inactive* patches. This reduces the patching metadata which makes OPatch run faster. It also deletes patches from the `.patch_storage` directory inside the Oracle home and reduces the space used. Check the size of the `.patch_storage` folder.

    ``` bash
    <copy>
    du -sh $ORACLE_HOME/.patch_storage
    </copy>
    ```

    * Currently, OPatch uses 8.2 GB to store old patch files. All the way back to 19.3.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    $ du -sh $ORACLE_HOME/.patch_storage
    8.2G    /u01/app/oracle/product/19/.patch_storage
    ```

    </details>

3. Delete the inactive patches. When prompted to proceed, enter *Y*.

    ``` bash
    <copy>
    ./opatch util deleteinactivepatches
    </copy>
    ```

    * OPatch keeps one inactive patch - and deletes the rest of the inactive patches.
    * By keeping one inactive patch - the latest - it ensures that you can always roll back to the previous patch. Going back even further would require that you restore the files or simply install a new Oracle home with the required patches.
    * The number of inactive patches to keep is configurable.
    * If you find OPatch is running slow in your own environment, try to clear our inactive patching metadata.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    $ . ftex
    $ cd $ORACLE_HOME/OPatch
    $ ./opatch util deleteinactivepatches
    Oracle Interim Patch Installer version 12.2.0.1.47
    Copyright (c) 2025, Oracle Corporation.  All rights reserved.


    Oracle Home       : /u01/app/oracle/product/19
    Central Inventory : /u01/app/oraInventory
       from           : /u01/app/oracle/product/19/oraInst.loc
    OPatch version    : 12.2.0.1.47
    OUI version       : 12.2.0.7.0
    Log file location : /u01/app/oracle/product/19/cfgtoollogs/opatch/opatch2025-07-27_17-10-05PM_1.log

    Invoking utility "deleteinactivepatches"
    Inactive Patches Cleanup option provided
    Delete Inactive Patches .......

    ***** There are 3 inactive RU patches in chain 1

    ***** 2 inactive patches will be deleted
    -To be deleted inactive RU/BP 29517242:Database Release Update : 19.3.0.0.190416 (29517242), installed on: Thu Apr 18 07:21:17 GMT 2019, with no     overlays
    -To be deleted inactive RU/BP 36912597:Database Release Update : 19.25.0.0.241015 (36912597), installed on: Thu Jul 24 09:49:33 GMT 2025, with no     overlays
    -To be retained inactive RU/BP 37260974:Database Release Update : 19.26.0.0.250121 (37260974), installed on: Thu Jul 24 10:30:23 GMT 2025, with no     overlays
    -Active RU/BP 37642901:Database Release Update : 19.27.0.0.250415 (37642901), installed on: Thu Jul 24 10:42:18 GMT 2025, with no overlays

    ***** There are 2 inactive RU patches in chain 2

    ***** 1 inactive patches will be deleted
    -To be deleted inactive RU/BP 36878697:OJVM RELEASE UPDATE: 19.25.0.0.241015 (36878697), installed on: Thu Jul 24 09:53:30 GMT 2025, with no     overlays
    -To be retained inactive RU/BP 37102264:OJVM RELEASE UPDATE: 19.26.0.0.250121 (37102264), installed on: Thu Jul 24 10:35:00 GMT 2025, with no     overlays
    -Active RU/BP 37499406:OJVM RELEASE UPDATE: 19.27.0.0.250415 (37499406), installed on: Thu Jul 24 10:47:46 GMT 2025, with no overlays

    Do you want to proceed? [y|n]
    y
    User Responded with: Y
    Deleted RU/BP patch: 29517242
    Deleted RU/BP patch: 36912597
    Deleted RU/BP patch: 36878697

    OPatch succeeded.
    ```

    </details>

4. How much space did you reclaim inside the Oracle home? Check the size of the `.patch_storage` folder.

    ``` bash
    <copy>
    du -sh $ORACLE_HOME/.patch_storage
    </copy>
    ```

    * Now, OPatch uses 5.5 GB to store old patch files.
    * You reclaimed almost 3 GBs.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    $ du -sh $ORACLE_HOME/.patch_storage
    5.5G    /u01/app/oracle/product/19/.patch_storage
    ```

    </details>

5. OPatch stores the patching information in the Oracle home. Examine the directory.

    ``` bash
    <copy>
    cd $ORACLE_HOME/.patch_storage
    ll
    </copy>

    # Be sure to hit RETURN
    ```

    * You should never delete files from this directory manually.
    * Instead, use the `opatch util deleteinactivepatches` command.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    $ cd $ORACLE_HOME/.patch_storage
    $ ll
    total 392
    drwxr-xr-x.  3 oracle oinstall     74 Apr 18  2019 29585399_Apr_9_2019_19_12_47
    drwxr-xr-x.  4 oracle oinstall     87 Jul 24 10:35 37102264_Dec_18_2024_05_06_41
    drwxr-xr-x.  4 oracle oinstall     87 Jul 24 10:33 37260974_Jan_20_2025_04_30_30
    drwxr-xr-x.  4 oracle oinstall     87 Jul 24 10:48 37499406_Apr_8_2025_08_50_50
    drwxr-xr-x.  4 oracle oinstall     87 Jul 24 10:46 37642901_Apr_15_2025_08_17_25
    drwxr-xr-x.  4 oracle oinstall     87 Jul 24 10:49 37777295_Apr_18_2025_16_56_05
    drwxr-xr-x.  3 oracle oinstall     33 Jul 27 17:46 backup_delete_inactive
    -rw-r--r--.  1 oracle oinstall 127747 Jul 24 10:49 interim_inventory.txt
    -rw-r-----.  1 oracle oinstall     93 Jul 24 10:49 LatestOPatchSession.properties
    drwxr-xr-x. 15 oracle oinstall   4096 Jul 24 10:49 NApply
    -rw-r--r--.  1 oracle oinstall 131708 Jul 24 10:45 newdirs.txt
    -rw-r--r--.  1 oracle oinstall 125662 Jul 24 10:49 record_inventory.txt
    ```

    </details>

## Task 4: Datapatch clean-up

Everytime you patch your datababase, Datapatch stores the rollback scripts inside the database. This ensures, that Datapatch always have the option of rolling back patches - even when you use out-of-place patching and the rollback scripts are no longer in the Oracle home. Datapatch stores the rollback scripts in the SYSAUX tablespace and over time it might take up a significant amount of space.

1. Stay in the *yellow* terminal 🟨. Set the environment and connect to the *UPGR* database.

    ``` sql
    <copy>
    . upgr
    sql / as sysdba
    </copy>

    -- Be sure to hit RETURN
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

    * Datapatch stored the rollback script for each of the patch actions in this database; for Release Updates and one-off patches.
    * The total size is around 750 MB. Underlying segments are in the SYSAUX tablespace.
    * In a container database, Datapatch stores the data in the root container and all PDBs.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    DESCRIPTION                                           SIZE_MB
    -------------------------------------------------- ----------
    DATAPUMP BUNDLE PATCH 19.25.0.0.0                        1.03
    DATAPUMP BUNDLE PATCH 19.26.0.0.0                        1.03
    DATAPUMP BUNDLE PATCH 19.27.0.0.0                        1.03
    DATAPUMP BUNDLE PATCH 19.28.0.0.0                        1.04
    OJVM RELEASE UPDATE: 19.25.0.0.241015 (36878697)          .01
    OJVM RELEASE UPDATE: 19.26.0.0.250121 (37102264)          .02
    OJVM RELEASE UPDATE: 19.27.0.0.250415 (37499406)          .02
    OJVM RELEASE UPDATE: 19.28.0.0.250715 (37847857)          .02
    Release Update 19.25.0.0.0                                175
    Release Update 19.26.0.0.0                                184
    Release Update 19.27.0.0.0                                194
    Release Update 19.28.0.0.0                                203
    Release Update 19.3.0.0.0                                   4

    10 rows selected.
    ```

    </details>

3. Exit SQLcl

    ``` sql
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
    * This doesn't prevent you from rolling back the currently applied patches.
    * The old rollback scripts are no longer needed and can be safely cleaned up.
    * This doesn't remove the patching history, just the rollback scripts.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL Patching tool version 19.28.0.0.0 Production on Fri Aug  1 06:55:12 2025
    Copyright (c) 2012, 2025, Oracle.  All rights reserved.

    Log file for this invocation: /u01/app/oracle/cfgtoollogs/sqlpatch/sqlpatch_120240_2025_08_01_06_55_12/sqlpatch_invocation.log

    Connecting to database...OK
    Gathering database info...done
    Bootstrapping registry and package to current versions...done
    Determining current state...done

    Current state of interim SQL patches:
    Interim patch 36878697 (OJVM RELEASE UPDATE: 19.25.0.0.241015 (36878697)):
      Binary registry: Not installed
      SQL registry: Rolled back successfully on 31-JUL-25 08.23.09.135446 AM
    Interim patch 37056207 (DATAPUMP BUNDLE PATCH 19.25.0.0.0):
      Binary registry: Not installed
      SQL registry: Rolled back successfully on 31-JUL-25 08.23.09.246077 AM
    Interim patch 37102264 (OJVM RELEASE UPDATE: 19.26.0.0.250121 (37102264)):
      Binary registry: Not installed
      SQL registry: Rolled back successfully on 31-JUL-25 08.38.11.022067 AM
    Interim patch 37470729 (DATAPUMP BUNDLE PATCH 19.26.0.0.0):
      Binary registry: Not installed
      SQL registry: Rolled back successfully on 31-JUL-25 08.38.11.360518 AM
    Interim patch 37499406 (OJVM RELEASE UPDATE: 19.27.0.0.250415 (37499406)):
      Binary registry: Not installed
      SQL registry: Rolled back successfully on 01-AUG-25 06.08.25.411000 AM
    Interim patch 37777295 (DATAPUMP BUNDLE PATCH 19.27.0.0.0):
      Binary registry: Not installed
      SQL registry: Rolled back successfully on 01-AUG-25 06.08.25.837984 AM
    Interim patch 37847857 (OJVM RELEASE UPDATE: 19.28.0.0.250715 (37847857)):
      Binary registry: Installed
      SQL registry: Applied successfully on 01-AUG-25 06.08.25.457376 AM
    Interim patch 38170982 (DATAPUMP BUNDLE PATCH 19.28.0.0.0):
      Binary registry: Installed
      SQL registry: Applied successfully on 01-AUG-25 06.09.26.991082 AM

    Current state of release update SQL patches:
      Binary registry:
        19.28.0.0.0 Release_Update 250705030417: Installed
      SQL registry:
        Applied 19.28.0.0.0 Release_Update 250705030417 successfully on 01-AUG-25 06.08.48.499528 AM

      Purging old patch metadata process started...

    CAUTION: This could be I/O intensive sometimes due to cleanup of BLOB columns. If you find this process taking unusually long time or if you are     seeing any impact to the database performance, then abort this datapatch process and reschedule this clean up activity in a quiet maintenance     window.

      Purge old patch metadata process completed.

    SQL Patching tool complete on Fri Aug  1 06:55:33 2025
    ```

    </details>

5. Reconnect to the database.

    ``` bash
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

    * The total size is around 200 MB.
    * The cleanup happens via a `TRUNCATE TABLE` command which effectively reclaims space so other segments may use it. However, it doesn't shrink the tablespace, so the physical size of the data files remain the same.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    DESCRIPTION                                           SIZE_MB
    -------------------------------------------------- ----------
    DATAPUMP BUNDLE PATCH 19.25.0.0.0
    DATAPUMP BUNDLE PATCH 19.26.0.0.0
    DATAPUMP BUNDLE PATCH 19.27.0.0.0
    DATAPUMP BUNDLE PATCH 19.28.0.0.0                        1.04
    OJVM RELEASE UPDATE: 19.25.0.0.241015 (36878697)
    OJVM RELEASE UPDATE: 19.26.0.0.250121 (37102264)
    OJVM RELEASE UPDATE: 19.27.0.0.250415 (37499406)
    OJVM RELEASE UPDATE: 19.28.0.0.250715 (37847857)          .02
    Release Update 19.25.0.0.0
    Release Update 19.26.0.0.0
    Release Update 19.27.0.0.0
    Release Update 19.28.0.0.0                                203
    Release Update 19.3.0.0.0

    10 rows selected.
    ```

    </details>

7. Oracle expects to add the Datapatch cleanup functionality in Release Update 19.29. Until then, you can add the functionality using a one-off patch (37738908).

**Congratulations!** This is the end of *Patch Me If You Can*.

## Acknowledgements

* **Author** - Daniel Overby Hansen
* **Contributors** - Rodrigo Jorge, Mike Dietrich
* **Last Updated By/Date** - Daniel Overby Hansen, August 2025
