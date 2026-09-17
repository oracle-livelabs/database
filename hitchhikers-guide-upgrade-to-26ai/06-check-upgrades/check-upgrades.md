# Check Upgrades

## Introduction

In previous labs, you started two PDB upgrades: one unplug-plug upgrade using AutoUpgrade and another using Replay Upgrade. In this lab, you check the outcome of the upgrades.

Estimated Time: 15 minutes

### Objectives

In this lab, you will:

* Check the PDB upgrades

### Prerequisites

You have completed:
* Lab 4: Upgrade PDB Using Unplug-Plug
* Lab 5: Upgrade PDB Using Replay Upgrade

## Task 1: Check AutoUpgrade

1. Use the *yellow* 🟨 terminal. AutoUpgrade should be done by now. Otherwise, wait for it to complete.

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
    /home/oracle/logs/upg-unplug-plug-orange/cfgtoollogs/upgrade/auto/status/status.html
    /home/oracle/logs/upg-unplug-plug-orange/cfgtoollogs/upgrade/auto/status/status.log
    ```

    </details>

2. Set the environment and connect.

    ``` bash
    <copy>
    . cdb26
    sql / as sysdba
    </copy>

    # Be sure to press RETURN
    ```

3. Switch to the *ORANGE* PDB and check the `COMPATIBLE` parameter.

    ``` bash
    <copy>
    alter session set container=ORANGE;
    select value from v$parameter where name='compatible';
    </copy>

    # Be sure to press RETURN
    ```

    * The `COMPATIBLE` parameter is set to `23.0.0`.
    * Do you remember the previous setting? Before the upgrade, it was set to `19.0.0`.
    * You did not use the config file parameter `raise_compatible`, so why did the value change?
    * This is a consequence of the multitenant architecture. Within a CDB, all PDBs must have the same `COMPATIBLE` setting. 
    * During plug-in, `COMPATIBLE` was automatically adjusted. This happens for all plug-in operations, whether or not you use AutoUpgrade.
    * Although the new `COMPATIBLE` setting allows the use of all new functionality, it also means that you can no longer downgrade the PDB.
    * If you want to preserve the possibility of downgrading, you must plug the PDB into a 26ai CDB with `COMPATIBLE` set to `19.0.0`. 

    <details>
    <summary>*click to see the output*</summary>

    ``` text
        VALUE
    _________
    23.0.0
    ```

    </details>

4. Check the data file locations.

    ``` bash
    <copy>
    select name from v$datafile;
    </copy>
    ```

    * You instructed AutoUpgrade to copy the data files on plug-in.
    * All data files are located in the OMF-compliant location. 
    * Notice that *CDB26* is part of the directory structure. 
    * The identifier after *CDB26* is the PDB GUID, which is also part of the OMF-compliant directory structure.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    NAME
    ____________________________________________________________________________________________
    /u02/oradata/CDB26/579E7F7248B97654E0635C00000A9ED3/datafile/o1_mf_system_o7r0c46l_.dbf
    /u02/oradata/CDB26/579E7F7248B97654E0635C00000A9ED3/datafile/o1_mf_sysaux_o7r0c46w_.dbf
    /u02/oradata/CDB26/579E7F7248B97654E0635C00000A9ED3/datafile/o1_mf_undotbs1_o7r0c46x_.dbf
    ```

    </details>

5. Exit SQLcl.

    ``` bash
    <copy>
    exit
    </copy>
    ```    


## Task 2: Check Replay Upgrade

1. Switch to the *blue* 🟦 terminal. The Replay Upgrade should have completed by now. The command returns an error:

    ``` text
    SQL> alter pluggable database terracotta open;
    ORA-24344: A compilation error occurred while creating an object.
    Help: https://docs.oracle.com/error-help/db/ora-24344/
    24344. 00000 -  "A compilation error occurred while creating an object."
    *Cause:    A SQL or PL/SQL compilation error occurred while creating an
            object.
    *Action:   Return OCI_SUCCESS_WITH_INFO with the error code.

    Pluggable database TERRACOTTA altered.
    ```

    * This is expected. 
    * The `open` command runs most of the upgrade, but you must still run Datapatch to complete it.
    * In the next lab, you learn how to diagnose Replay Upgrade.

2. Exit SQLcl.

    ``` bash
    <copy>
    exit
    </copy>
    ```

3. Set the environment and run Datapatch.

    ``` bash
    <copy>
    . cdb26
    $ORACLE_HOME/OPatch/datapatch -pdbs terracotta
    </copy>

    # Be sure to press RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL Patching tool version 23.26.3.0.0 Production on Wed Aug 12 07:41:44 2026
    Copyright (c) 2012, 2026, Oracle.  All rights reserved.

    Log file for this invocation: /u01/app/oracle/product/26/cfgtoollogs/sqlpatch/  sqlpatch_sid_CDB26_ts_2026_08_12_07_41_44_pid_284489/sqlpatch_invocation.log

    Connecting to database...OK
    Gathering database info...done

    Note:  Datapatch will only apply or rollback SQL fixes for PDBs
           that are in an open state, no patches will be applied to closed PDBs.
           Please refer to Note: Datapatch: Database 12c Post Patch SQL Automation
           (Doc ID 1585822.1)

    Bootstrapping registry and package to current versions...done
    Determining current state...done

    Current state of interim SQL patches:
    Interim patch 39593097 (DATAPUMP BUNDLE PATCH 23.26.3.0.0):
      Binary registry: Installed
      PDB TERRACOTTA: Not installed

    Current state of release update SQL patches:
      Binary registry:
        23.26.3.0.0 Release_Update 260705162604: Installed
      PDB TERRACOTTA:
        Applied 23.26.3.0.0 Release_Update 260705162604 successfully

    Adding patches to installation queue and performing prereq checks...done
    Installation queue:
      For the following PDBs: TERRACOTTA
        No interim patches need to be rolled back
        No release update patches need to be installed
        The following interim patches will be applied:
          39593097 (DATAPUMP BUNDLE PATCH 23.26.3.0.0)

    Bypass install queue:
      For the following PDBs: TERRACOTTA
        No interim rollbacks will bypass install
        Patch 39578879 (Database Release Update : 23.26.3.0.0 (39578879) Gold Image): will bypass install
          Apply from 23.26.3.0.0 Release_Update 260705162604 to 23.26.3.0.0 Release_Update 260705162604
        No interim applys will bypass install


    Installation queue after removing bypass entries...
    Installation queue:
      For the following PDBs: TERRACOTTA
        No interim patches need to be rolled back
        No release update patches need to be installed
        The following interim patches will be applied:
          39593097 (DATAPUMP BUNDLE PATCH 23.26.3.0.0)

    Installing patches...
    Patch installation complete.  Total patches installed: 1

    Validating logfiles...done
    Patch 39593097 apply (pdb TERRACOTTA): SUCCESS
      logfile: /u01/app/oracle/product/26/cfgtoollogs/sqlpatch/sqlpatch_sid_CDB26_ts_2026_08_12_07_41_44_pid_284489/    39593097_apply_CDB26_TERRACOTTA_2026Aug12_07_41_53.log (no errors)

    Processing bypass install queue:
      Patch 39578879 apply (pdb TERRACOTTA): SUCCESS (bypass_install)

    SQL Patching tool complete on Wed Aug 12 07:49:06 2026    
    ```

    </details>

4. Reconnect to the database.

    ``` bash
    <copy>
    sql / as sysdba
    </copy>
    ```

5. Restart the PDB.

    ``` bash
    <copy>
    alter pluggable database terracotta close;
    alter pluggable database terracotta open;
    select open_mode, restricted from v$pdbs where name='TERRACOTTA';
    </copy>

    # Be sure to press RETURN
    ```

    * The PDB now opens without problems in *READ WRITE* mode and unrestricted.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> alter pluggable database terracotta close;

    Pluggable database TERRACOTTA altered.

    SQL> alter pluggable database terracotta open;

    Pluggable database TERRACOTTA altered.

    SQL> select open_mode, restricted from v$pdbs where name='TERRACOTTA';

    OPEN_MODE     RESTRICTED
    _____________ _____________
    READ WRITE    NO
    ```

    </details>

6. Check the data files locations.

    ``` bash
    <copy>
    alter session set container=TERRACOTTA;
    select name from v$datafile;
    </copy>

    # Be sure to press RETURN
    ```

    * You instructed the target CDB, *CDB26*, to reuse the data files on plug-in.
    * All data files are located in the OMF-compliant location of the source CDB, *CDB19*. 
    * Notice that *CDB19* is part of the directory structure. 
    * This violates the OMF naming standard, but it does not prevent the database from using the data files. 
    * However, you might want to move the data files to avoid this naming anomaly.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    NAME
    ____________________________________________________________________________________________
    /u02/oradata/CDB19/579E7F7248B97654E0635C00000A9ED3/datafile/o1_mf_system_o7r0c46l_.dbf
    /u02/oradata/CDB19/579E7F7248B97654E0635C00000A9ED3/datafile/o1_mf_sysaux_o7r0c46w_.dbf
    /u02/oradata/CDB19/579E7F7248B97654E0635C00000A9ED3/datafile/o1_mf_undotbs1_o7r0c46x_.dbf
    ```

    </details>
    
7. Exit SQLcl.

    ``` bash
    <copy>
    exit
    </copy>
 
    ```

8. Execute the post-upgrade fixups.

    ``` bash
    <copy>
    java -jar autoupgrade.jar -preupgrade "dir=/home/oracle/logs/upg-replay-upg-terracotta/postfixups,inclusion_list=TERRACOTTA" -mode postfixups
    </copy>
    ```

    * Normally, AutoUpgrade executes the post-upgrade fixups.
    * For Replay Upgrade, you use a special mode in AutoUpgrade to execute them.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    Processing config file ...
    +--------------------------------+
    | Starting AutoUpgrade execution |
    +--------------------------------+
    1 PDB(s) will be processed
    Job 100 database cdb26
    Job 100 completed
    ------------------- Final Summary --------------------
    Number of databases            [ 1 ]

    Jobs finished                  [1]
    Jobs failed                    [0]

    Please check the summary report at:
    /home/oracle/logs/upg-replay-upg-terracotta/postfixups/cfgtoollogs/upgrade/auto/status/status.html
    /home/oracle/logs/upg-replay-upg-terracotta/postfixups/cfgtoollogs/upgrade/auto/status/status.log    
    ```

    </details>

## Task 3: Compare Methods

You've now upgraded both PDBs. Compare the methods.

* Before moving on spend a few minutes to reflect on the differences between AutoUpgrade and Replay Upgrade.

* AutoUpgrade completely automates the process. You can monitor the progress and customize the upgrade.

* Replay Upgrade allows you to run the commands separately. Some prefer this method for automation, although AutoUpgrade integrates easily with automation as well. 

You may now [*proceed to the next lab*](#next).

## Acknowledgements

* **Author** - Daniel Overby Hansen
* **Contributors** - Rodrigo Jorge, Alex Zaballa, Mike Dietrich, Alejandro Diaz
* **Last Updated By/Date** - Daniel Overby Hansen, August 2026