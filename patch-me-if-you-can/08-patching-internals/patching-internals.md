# Patching Internals

## Introduction

In this lab, you will examine how some parts of Datapatch works. This will give you insights into the patching process. 

Estimated Time: 15 Minutes

### Objectives

In this lab, you will:

* Check Datapatch infrastructure and logs
* Gather diagnostics information

### Prerequisites

This lab assumes:

- You have completed Lab 2: Simple Patching With AutoUpgrade

## Task 1: Examine Datapatch tables

Datapatch stores patching information inside the database. Understanding these tables helps you understand how Datapatch works.

1. Use the *yellow* terminal 🟨. Set the environment to the *FTEX* database and connect.

    ```
    <copy>
    . ftex
    sqlplus / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

2. Datapatch uses two tables to keep track of patching activities. Examine the two tables.

    ```
    <copy>
    desc REGISTRY$SQLPATCH_RU_INFO 
    desc REGISTRY$SQLPATCH
    </copy>

    -- Be sure to hit RETURN
    ```

    * Datapatch uses `REGISTRY$SQLPATCH_RU_INFO` to hold information about Release Updates, whereas it uses `REGISTRY$SQLPATCH` for all patches.
    * Notice how more columns are in the latter table.
    * The `PATCH_DIRECTORY` column contains the rollback script for a specific patch. Datapatch always adds the rollback script to the database when applying a patch. This ensures that Datapatch can always perform a rollback, if needed, even if the original Oracle home is missing.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> desc REGISTRY$SQLPATCH_RU_INFO
     Name                   Null?    Type
     --------------------- -------- ------------
     PATCH_ID              NOT NULL NUMBER
     PATCH_UID             NOT NULL NUMBER
     PATCH_DESCRIPTOR               XMLTYPE
     RU_VERSION                     VARCHAR2(15)
     RU_BUILD_DESCRIPTION           VARCHAR2(80)
     RU_BUILD_TIMESTAMP             TIMESTAMP(6)
     PATCH_DIRECTORY                BLOB    

    SQL> desc REGISTRY$SQLPATCH
     Name                   Null?    Type
     --------------------- -------- ------------
     INSTALL_ID            NOT NULL NUMBER
     PATCH_ID              NOT NULL NUMBER
     PATCH_UID             NOT NULL NUMBER
     PATCH_TYPE            NOT NULL VARCHAR2(10)
     ACTION                NOT NULL VARCHAR2(15)
     STATUS                NOT NULL VARCHAR2(25)
     ACTION_TIME           NOT NULL TIMESTAMP(6)
     DESCRIPTION                    VARCHAR2(100)
     LOGFILE               NOT NULL VARCHAR2(500)
     RU_LOGFILE                     VARCHAR2(500)
     FLAGS                          VARCHAR2(10)
     PATCH_DESCRIPTOR      NOT NULL XMLTYPE
     PATCH_DIRECTORY                BLOB
     SOURCE_VERSION                 VARCHAR2(15)
     SOURCE_BUILD_DESCRIPTION       VARCHAR2(80)
     SOURCE_BUILD_TIMESTAMP         TIMESTAMP(6)
     TARGET_VERSION                 VARCHAR2(15)
     TARGET_BUILD_DESCRIPTION       VARCHAR2(80)
     TARGET_BUILD_TIMESTAMP         TIMESTAMP(6)
    ```
    </details>   

3. To check Datapatch activity you should not use the dictionary tables. Instead use the view `DBA_REGISTRY_SQLPATCH`. Examine the patching history of this database.

    ```
    <copy>
    set pagesize 1000
    set line 200
    col action format a8
    col status format a10
    col action_time format a30
    col description format a60
    select   patch_id, action, status, action_time, description 
    from     dba_registry_sqlpatch
    order by action_time;
    </copy>

    -- Be sure to hit RETURN
    ```

    * This database was first patched from the base release, 19.3, to 19.21, including the OJVM and Data Pump bundle patches.
    * In lab 2, you patched the database to 19.25.
    * In lab 8, you rolled back to 19.21.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> set pagesize 1000
    SQL> set line 200
    SQL> col action format a8
    SQL> col status format a10
    SQL> col action_time format a30
    SQL> col description format a60
    SQL> select   patch_id, action, status, action_time, description
         from     dba_registSQL> ry_sqlpatch
         order by action_time;
    
      PATCH_ID ACTION   STATUS     ACTION_TIME                    DESCRIPTION
    ---------- -------- ---------- ------------------------------ ------------------------------------------------------------
      35643107 APPLY    SUCCESS    10-JUL-24 04.20.22.518873 PM   Database Release Update : 19.21.0.0.231017 (35643107)
      35648110 APPLY    SUCCESS    10-JUL-24 04.20.22.526734 PM   OJVM RELEASE UPDATE: 19.21.0.0.231017 (35648110)
      35787077 APPLY    SUCCESS    10-JUL-24 04.20.23.439857 PM   DATAPUMP BUNDLE PATCH 19.21.0.0.0
      35648110 ROLLBACK SUCCESS    02-DEC-24 10.38.13.950615 AM   OJVM RELEASE UPDATE: 19.21.0.0.231017 (35648110)
      36878697 APPLY    SUCCESS    02-DEC-24 10.38.13.971532 AM   OJVM RELEASE UPDATE: 19.25.0.0.241015 (36878697)
      35787077 ROLLBACK SUCCESS    02-DEC-24 10.38.14.099176 AM   DATAPUMP BUNDLE PATCH 19.21.0.0.0
      36912597 APPLY    SUCCESS    02-DEC-24 10.39.09.610198 AM   Database Release Update : 19.25.0.0.241015 (36912597)
      37056207 APPLY    SUCCESS    02-DEC-24 10.39.49.664582 AM   DATAPUMP BUNDLE PATCH 19.25.0.0.0
      36878697 ROLLBACK SUCCESS    03-DEC-24 10.57.37.852844 AM   OJVM RELEASE UPDATE: 19.25.0.0.241015 (36878697)
      37056207 ROLLBACK SUCCESS    03-DEC-24 10.57.37.859396 AM   DATAPUMP BUNDLE PATCH 19.25.0.0.0
      36912597 ROLLBACK SUCCESS    03-DEC-24 10.57.39.130585 AM   Database Release Update : 19.25.0.0.241015 (36912597)
      35648110 APPLY    SUCCESS    03-DEC-24 10.57.39.133106 AM   OJVM RELEASE UPDATE: 19.21.0.0.231017 (35648110)
      35787077 APPLY    SUCCESS    03-DEC-24 10.57.40.005614 AM   DATAPUMP BUNDLE PATCH 19.21.0.0.0
    
    13 rows selected.
    ```
    </details>   

4. Find the log file used to apply the 19.25 Release Update.

    ```
    <copy>
    set pagesize 1000
    set line 125
    col logfile format a125
    select logfile 
    from   dba_registry_sqlpatch 
    where  description like 'Database Release Update : 19.25%' 
           and action='APPLY';
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> set line 125
    SQL> col logfile format a125
    SQL> select logfile
         from   dba_registry_sqlpatch
         where  description like 'Database Release Update : 19.25%'
                and action='APPLY';
    
    LOGFILE
    ----------------------------------------------------------------------------------------------------
    /u01/app/oracle/cfgtoollogs/sqlpatch/36912597/25871884/36912597_apply_FTEX_2024Dec02_10_38_14.log
    ```
    </details>      

5. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```  

## Task 2: Examine Datapatch logs

Datapatch also stores log files in the file system. 

1. Still in the *yellow* terminal 🟨. Examine the Datapatch logging directory.

    ```
    <copy>
    cd $ORACLE_BASE/cfgtoollogs/sqlpatch
    ll
    </copy>

    -- Be sure to hit RETURN
    ```

    * `sqlpatch_history.txt` contains an overview of all Datapatch invocations.
    * Each invocation writes to a specific directory named `sqlpatch_<number>_<timestamp>`.
    * The apply and/or rollback actions of each patch is stored in a folder matching the patch number.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ cd $ORACLE_BASE/cfgtoollogs/sqlpatch
    $ ll
    total 16
    drwxr-xr-x. 3 oracle oinstall   22 Dec  2 10:38 35648110
    -rw-r--r--. 1 oracle oinstall    0 Dec  2 10:38 35648110_25365038.lock
    drwxr-xr-x. 3 oracle oinstall   22 Dec  2 10:38 35787077
    -rw-r--r--. 1 oracle oinstall    0 Dec  2 10:38 35787077_25410019.lock
    drwxr-xr-x. 3 oracle oinstall   22 Dec  2 10:38 36878697
    -rw-r--r--. 1 oracle oinstall    0 Dec  2 10:38 36878697_25797620.lock
    drwxr-xr-x. 3 oracle oinstall   22 Dec  2 10:37 36912597
    -rw-r--r--. 1 oracle oinstall    0 Dec  2 10:37 36912597_25871884.lock
    drwxr-xr-x. 3 oracle oinstall   22 Dec  2 10:38 37056207
    -rw-r--r--. 1 oracle oinstall    0 Dec  2 10:38 37056207_25840925.lock
    drwxr-xr-x. 2 oracle oinstall  134 Dec  3 10:12 sqlpatch_105270_2024_12_03_10_11_56
    drwxr-xr-x. 2 oracle oinstall 4096 Dec  3 10:13 sqlpatch_105347_2024_12_03_10_12_02
    drwxr-xr-x. 2 oracle oinstall 4096 Dec  3 10:57 sqlpatch_108337_2024_12_03_10_55_30
    drwxr-xr-x. 2 oracle oinstall  133 Dec  2 10:38 sqlpatch_26012_2024_12_02_10_37_42
    drwxr-xr-x. 2 oracle oinstall 4096 Dec  2 10:39 sqlpatch_26108_2024_12_02_10_38_08
    -rw-r--r--. 1 oracle oinstall  558 Dec  3 10:55 sqlpatch_history.txt
    ```
    </details>       

2. Examine the log file used to apply the 19.25 Release Update to the FTEX database. This is the log file you found in the previous task. 

    ```
    <copy>
    cd $ORACLE_BASE/cfgtoollogs/sqlpatch
    head -n20 36912597/25871884/36912597_apply_FTEX_*.log
    </copy>

    -- Be sure to hit RETURN
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
    SQL> SELECT 'Starting apply for patch 36912597/25871884 on ' ||
      2         SYSTIMESTAMP FROM dual;
    Starting apply for patch 36912597/25871884 on 02-DEC-24 10.38.14.109433 AM +00:0
    0
    
    
    1 row selected.
    
    Elapsed: 00:00:00.00
    SQL> SET PAGESIZE 10
    SQL>
    SQL> BEGIN
      2      dbms_sqlpatch.patch_initialize(p_patch_id      => 36912597,
      3                                     p_patch_uid     => 25871884,
      4                                     p_logfile       => '&full_logfile');
      5  END;
      6  /
    ```
    </details>  

3. Each invocation has it's own subdirectory named `sqlpatch_<number>_<timestamp>`. Change to one of the directories and examine the files.

4. When Datapatch applies patches it might invalidate objects. Datapatch keeps track of this and will recompile the objects at the end of the patching process. Examine the log files for traces of recompilation.

    ```
    <copy>
    cd $ORACLE_BASE/cfgtoollogs/sqlpatch
    grep -r -i "Invalid ORACLE_MAINTAINED" *
    </copy>

    -- Be sure to hit RETURN
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

    ```
    <copy>
    cd $ORACLE_HOME/OPatch
    cat datapatch
    </copy>

    -- Be sure to hit RETURN
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

## Task 3: Patch storage

OPatch keeps track of all the patches that you apply over time to an Oracle home. It stores a lot of patching metadata as well as the actual patches.

1. Stay in the *yellow* terminal 🟨. Set the environment and use OPatch to generate a list of patch metadata.

    ```
    <copy>
    . ftex
    cd $ORACLE_HOME/OPatch
    ./opatch util ListOrderedInactivePatches
    </copy>

    -- Be sure to hit RETURN
    ```

    * The output shows that the patching chain in this Oracle home is from 19.3 (base release) to 19.21.
    * This means that it is a brand-new Oracle home where only 19.21 has been applied.
    * The *active* RU is 19.21 - this is where the Oracle home currently is.
    * The *inactive* RU is 19.3 - this is where the Oracle home came from.
    * In this lab, you create new Oracle homes from the base release which matches Oracle's recommendations.
    * If you use in-place patching or clone existing Oracle homes, you will see more inactive patches.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ . ftex
    $ cd $ORACLE_HOME/OPatch
    $ ./opatch util ListOrderedInactivePatches
    Oracle Interim Patch Installer version 12.2.0.1.42
    Copyright (c) 2024, Oracle Corporation.  All rights reserved.
    
    
    Oracle Home       : /u01/app/oracle/product/19
    Central Inventory : /u01/app/oraInventory
       from           : /u01/app/oracle/product/19/oraInst.loc
    OPatch version    : 12.2.0.1.42
    OUI version       : 12.2.0.7.0
    Log file location : /u01/app/oracle/product/19/cfgtoollogs/opatch/opatch2024-12-04_12-24-27PM_1.log
    
    Invoking utility "listorderedinactivepatches"
    List Inactive patches option provided
    
    The oracle home has the following inactive patch(es) and their respective overlay patches:
    
    The number of RU chains is  1
    
    ***** There are 1 inactive RU patches in chain 1
    -Inactive RU/BP 29517242:Database Release Update : 19.3.0.0.190416 (29517242), installed on: Thu Apr 18 07:21:17 GMT 2019, with no overlays
    -Active RU/BP 35643107:Database Release Update : 19.21.0.0.231017 (35643107), installed on: Wed Jul 10 14:53:39 GMT 2024, with no overlays
    
    OPatch succeeded.
    ```
    </details>       

2. You can remove information about the *inactive* patches. This reduces the patching metadata which makes OPatch run faster. It also deletes patches from the `.patch_storage` directory inside the Oracle home and reduces the space used. Delete the inactive patches.

    ```
    <copy>
    ./opatch util deleteinactivepatches
    </copy>
    ```

    * The command does not delete anything, because OPatch wants to keep at least one inactive RU. This ensure you can always roll back to the previous patch.
    * Since this lab uses out-of-place patching from the base release, there will never be more than 1 inactive patch.
    * If you use in-place patching or patch out-of-place using a cloned Oracle home, you will see the list grows over time. This will require more disk space and prolong OPatch commands.
    * If you find OPatch is running slow, try to clear our inactive patching metadata.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ . ftex
    $ cd $ORACLE_HOME/OPatch
    $ ./opatch util deleteinactivepatches
    Oracle Interim Patch Installer version 12.2.0.1.42
    Copyright (c) 2024, Oracle Corporation.  All rights reserved.
    
    
    Oracle Home       : /u01/app/oracle/product/19
    Central Inventory : /u01/app/oraInventory
       from           : /u01/app/oracle/product/19/oraInst.loc
    OPatch version    : 12.2.0.1.42
    OUI version       : 12.2.0.7.0
    Log file location : /u01/app/oracle/product/19/cfgtoollogs/opatch/opatch2024-12-04_12-23-58PM_1.log
    
    Invoking utility "deleteinactivepatches"
    Inactive Patches Cleanup option provided
    Delete Inactive Patches .......
    Warning: No inactive RU is eligible for delete. See log file for more details
    
    OPatch succeeded.
    ```
    </details>     

3. OPatch stores the patching information in the Oracle home. Examine the directory.

    ```
    <copy>
    cd $ORACLE_HOME/.patch_storage
    ll
    </copy>

    -- Be sure to hit RETURN
    ```

    * You should never delete files from this directory manually.
    * Instead, use the `opatch util deleteinactivepatches` command.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ cd $ORACLE_HOME/.patch_storage
    $ ll
    total 268
    drwxr-xr-x. 3 oracle oinstall     74 Apr 18  2019 29517242_Apr_17_2019_23_27_10
    drwxr-xr-x. 3 oracle oinstall     74 Apr 18  2019 29585399_Apr_9_2019_19_12_47
    drwxr-xr-x. 4 oracle oinstall     87 Jul 10 14:58 35643107_Oct_3_2023_13_34_29
    drwxr-xr-x. 4 oracle oinstall     87 Jul 10 15:00 35648110_Aug_25_2023_10_22_03
    drwxr-xr-x. 4 oracle oinstall     87 Jul 10 14:59 35787077_Oct_6_2023_06_58_49
    -rw-r--r--. 1 oracle oinstall 100145 Jul 10 14:59 interim_inventory.txt
    -rw-r--r--. 1 oracle oinstall     93 Jul 10 14:59 LatestOPatchSession.properties
    drwxr-xr-x. 9 oracle oinstall   4096 Jul 10 14:59 NApply
    -rw-r--r--. 1 oracle oinstall  57729 Jul 10 14:57 newdirs.txt
    -rw-r--r--. 1 oracle oinstall  99508 Jul 10 14:59 record_inventory.txt
    ```
    </details>   

This is the end of *Patch Me If You Can*.

## Acknowledgements

* **Author** - Daniel Overby Hansen
* **Contributors** - Rodrigo Jorge, Mike Dietrich
* **Last Updated By/Date** - Daniel Overby Hansen, January 2025