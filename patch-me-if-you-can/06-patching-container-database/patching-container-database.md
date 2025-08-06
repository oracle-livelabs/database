# Manual Patching of a Container Database

## Introduction

In this lab, you will manually patch a container database. The *CDB19* database is running on 19.27 and you will patch it to an existing Oracle home on 19.28. In addition, you will check how PDBs behaves during patching.

Estimated Time: 15 Minutes

### Objectives

In this lab, you will:

* Patch a container database
* Check PDB behavior

### Prerequisites

This lab assumes:

* You have completed Lab 2: Simple Patching With AutoUpgrade

## Task 1: Patch a container database

You will patch *CDB19* to 19.28 and use an existing Oracle home.

1. Use the *yellow* terminal 🟨. Set the environment to the *CDB19* database and connect.

    ``` sql
    <copy>
    . cdb19
    sql / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

2. Start the database.

    ``` sql
    <copy>
    startup
    </copy>
    ```

3. Create a new PDB.

    ``` sql
    <copy>
    create pluggable database indigo admin user admin identified by oracle;
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> create pluggable database indigo admin user admin identified by oracle;

    Pluggable database created.
    ```

    </details>

4. Check the current version.

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
    -----------------
    19.27.0.0.0
    ```

    </details>

5. Shut down the database, so you can patch it to 19.28.

    ``` sql
    <copy>
    shutdown immediate
    </copy>
    ```

    * You must shut down a single instance database to patch it. In contrast, if it was an Oracle RAC Database, you could patch it using the *RAC Rolling* method without downtime.

6. Exit SQLcl.

    ``` sql
    <copy>
    exit
    </copy>
    ```

7. Move the SPFile and password file to the new Oracle home.

    ``` bash
    <copy>
    export NEW_ORACLE_HOME=/u01/app/oracle/product/19_28
    export OLD_ORACLE_HOME=/u01/app/oracle/product/19
    mv $OLD_ORACLE_HOME/dbs/spfileCDB19.ora $NEW_ORACLE_HOME/dbs
    mv $OLD_ORACLE_HOME/dbs/orapwCDB19 $NEW_ORACLE_HOME/dbs
    </copy>

    # Be sure to hit RETURN
    ```

    * In this lab, there is no PFile, so we don't need to move that one.
    * Also, there are no network files, like `tnsnames.ora` and `sqlnet.ora` in `$ORACLE_HOME/network/admin` so we don't move those either.
    * There might be many other files in the Oracle home. Check the blog post [Files to Move During Oracle Database Out-Of-Place Patching](https://dohdatabase.com/2023/05/30/files-to-move-during-oracle-database-out-of-place-patching/) for details.

8. You need to set the environment to the new Oracle home. Update the profile script and reset the environment.

    ``` bash
    <copy>
    sed -i 's|^ORACLE_HOME=.*|ORACLE_HOME=/u01/app/oracle/product/19_28|' /usr/local/bin/cdb19
    . cdb19
    env | grep ORA
    </copy>

    # Be sure to hit RETURN
    ```

9. Update `/etc/oratab` to reflect the new Oracle home.

    ``` bash
    <copy>
    sed 's|^CDB19:.*|CDB19:/u01/app/oracle/product/19_28:Y|' /etc/oratab > /tmp/oratab
    cat /tmp/oratab > /etc/oratab
    grep "CDB19" /etc/oratab
    </copy>

    # Be sure to hit RETURN
    ```

10. Connect to the database.

    ``` bash
    <copy>
    sql / as sysdba
    </copy>
    ```

11. Start the database instance and check PDBs.

    ``` sql
    <copy>
    startup
    show pdbs
    </copy>

    -- Be sure to hit RETURN
    ```

    * Notice how the *INDIGO* PDB doesn't start because you didn't save the state.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> startup
    ORACLE instance started.

    Total System Global Area 4294966064 bytes
    Fixed Size                  9186096 bytes
    Variable Size             838860800 bytes
    Database Buffers         3439329280 bytes
    Redo Buffers                7589888 bytes
    Database mounted.
    Database opened.
    SQL> show pdbs

        CON_ID CON_NAME      OPEN MODE  RESTRICTED
    ---------- ------------- ---------- ----------
             2 PDB$SEED      READ ONLY  NO
             3 INDIGO        MOUNTED
             4 ORANGE        READ WRITE NO
    ```

    </details>

12. Exit SQLcl.

    ``` sql
    <copy>
    exit
    </copy>
    ```

## Task 2: Examine Datapatch behavior

1. Remain in the *yellow* terminal 🟨.

2. Run Datapatch to apply the SQL changes to the database. It takes a few minutes to apply the patches. Wait for Datapatch to complete.

    ``` bash
    <copy>
    $ORACLE_HOME/OPatch/datapatch
    </copy>
    ```

    * Datapatch patches only the open PDBs. It prints a warning for the *INDIGO* PDB.
    * `Warning: PDB INDIGO is in mode MOUNTED and will be skipped.`
    * Scroll through the output and see how Datapatch applies changes to all containers, including CDB$ROOT and PDB$SEED.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    $ $ORACLE_HOME/OPatch/datapatch
    SQL Patching tool version 19.28.0.0.0 Production on Sun Jul 27 16:34:06 2025
    Copyright (c) 2012, 2025, Oracle.  All rights reserved.

    Log file for this invocation: /u01/app/oracle/cfgtoollogs/sqlpatch/sqlpatch_302392_2025_07_27_16_34_06/sqlpatch_invocation.log

    Connecting to database...OK
    Gathering database info...done

    Note:  Datapatch will only apply or rollback SQL fixes for PDBs
           that are in an open state, no patches will be applied to closed PDBs.
           Please refer to Note: Datapatch: Database 12c Post Patch SQL Automation
           (Doc ID 1585822.1)

    Warning: PDB INDIGO is in mode MOUNTED and will be skipped.
    Bootstrapping registry and package to current versions...done
    Determining current state...done

    Current state of interim SQL patches:
    Interim patch 37499406 (OJVM RELEASE UPDATE: 19.27.0.0.250415 (37499406)):
      Binary registry: Not installed
      PDB CDB$ROOT: Applied successfully on 24-JUL-25 11.38.03.761631 AM
      PDB ORANGE: Applied successfully on 24-JUL-25 11.40.06.122876 AM
      PDB PDB$SEED: Applied successfully on 24-JUL-25 11.40.06.122876 AM
    Interim patch 37777295 (DATAPUMP BUNDLE PATCH 19.27.0.0.0):
      Binary registry: Not installed
      PDB CDB$ROOT: Applied successfully on 24-JUL-25 11.40.00.817914 AM
      PDB ORANGE: Applied successfully on 24-JUL-25 11.41.23.598307 AM
      PDB PDB$SEED: Applied successfully on 24-JUL-25 11.41.23.598307 AM
    Interim patch 37847857 (OJVM RELEASE UPDATE: 19.28.0.0.250715 (37847857)):
      Binary registry: Installed
      PDB CDB$ROOT: Not installed
      PDB ORANGE: Not installed
      PDB PDB$SEED: Not installed
    Interim patch 38170982 (DATAPUMP BUNDLE PATCH 19.28.0.0.0):
      Binary registry: Installed
      PDB CDB$ROOT: Not installed
      PDB ORANGE: Not installed
      PDB PDB$SEED: Not installed

    Current state of release update SQL patches:
      Binary registry:
        19.28.0.0.0 Release_Update 250705030417: Installed
      PDB CDB$ROOT:
        Applied 19.27.0.0.0 Release_Update 250406131139 successfully on 24-JUL-25 11.39.47.050576 AM
      PDB ORANGE:
        Applied 19.27.0.0.0 Release_Update 250406131139 successfully on 24-JUL-25 11.41.15.860182 AM
      PDB PDB$SEED:
        Applied 19.27.0.0.0 Release_Update 250406131139 successfully on 24-JUL-25 11.41.15.860182 AM

    Adding patches to installation queue and performing prereq checks...done
    Installation queue:
      For the following PDBs: CDB$ROOT PDB$SEED ORANGE
        The following interim patches will be rolled back:
          37499406 (OJVM RELEASE UPDATE: 19.27.0.0.250415 (37499406))
          37777295 (DATAPUMP BUNDLE PATCH 19.27.0.0.0)
        Patch 37960098 (Database Release Update : 19.28.0.0.250715 (37960098)):
          Apply from 19.27.0.0.0 Release_Update 250406131139 to 19.28.0.0.0 Release_Update 250705030417
        The following interim patches will be applied:
          37847857 (OJVM RELEASE UPDATE: 19.28.0.0.250715 (37847857))
          38170982 (DATAPUMP BUNDLE PATCH 19.28.0.0.0)

    Installing patches...
    Patch installation complete.  Total patches installed: 15

    Validating logfiles...done
    Patch 37499406 rollback (pdb CDB$ROOT): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/37499406/26115603/37499406_rollback_CDB19_CDBROOT_2025Jul27_16_34_50.log (no errors)
    Patch 37777295 rollback (pdb CDB$ROOT): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/37777295/27238855/37777295_rollback_CDB19_CDBROOT_2025Jul27_16_34_50.log (no errors)
    Patch 37960098 apply (pdb CDB$ROOT): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/37960098/27635722/37960098_apply_CDB19_CDBROOT_2025Jul27_16_34_50.log (no errors)
    Patch 37847857 apply (pdb CDB$ROOT): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/37847857/27534561/37847857_apply_CDB19_CDBROOT_2025Jul27_16_34_50.log (no errors)
    Patch 38170982 apply (pdb CDB$ROOT): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/38170982/27628376/38170982_apply_CDB19_CDBROOT_2025Jul27_16_35_19.log (no errors)
    Patch 37499406 rollback (pdb PDB$SEED): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/37499406/26115603/37499406_rollback_CDB19_PDBSEED_2025Jul27_16_35_47.log (no errors)
    Patch 37777295 rollback (pdb PDB$SEED): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/37777295/27238855/37777295_rollback_CDB19_PDBSEED_2025Jul27_16_35_47.log (no errors)
    Patch 37960098 apply (pdb PDB$SEED): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/37960098/27635722/37960098_apply_CDB19_PDBSEED_2025Jul27_16_35_47.log (no errors)
    Patch 37847857 apply (pdb PDB$SEED): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/37847857/27534561/37847857_apply_CDB19_PDBSEED_2025Jul27_16_35_47.log (no errors)
    Patch 38170982 apply (pdb PDB$SEED): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/38170982/27628376/38170982_apply_CDB19_PDBSEED_2025Jul27_16_35_57.log (no errors)
    Patch 37499406 rollback (pdb ORANGE): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/37499406/26115603/37499406_rollback_CDB19_ORANGE_2025Jul27_16_35_47.log (no errors)
    Patch 37777295 rollback (pdb ORANGE): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/37777295/27238855/37777295_rollback_CDB19_ORANGE_2025Jul27_16_35_47.log (no errors)
    Patch 37960098 apply (pdb ORANGE): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/37960098/27635722/37960098_apply_CDB19_ORANGE_2025Jul27_16_35_47.log (no errors)
    Patch 37847857 apply (pdb ORANGE): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/37847857/27534561/37847857_apply_CDB19_ORANGE_2025Jul27_16_35_47.log (no errors)
    Patch 38170982 apply (pdb ORANGE): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/38170982/27628376/38170982_apply_CDB19_ORANGE_2025Jul27_16_35_58.log (no errors)
    SQL Patching tool complete on Sun Jul 27 16:36:15 2025
    ```

    </details>

3. Connect to the database.

    ``` bash
    <copy>
    sql / as sysdba
    </copy>
    ```

4. Open the *INDIGO* PDB.

    ``` sql
    <copy>
    alter pluggable database indigo open;
    </copy>
    ```

    * The PDB opens with errors.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> alter pluggable database indigo open;
    ORA-24344: success with compilation error
    24344. 00000 -  "success with compilation error"
    *Cause:    A sql/plsql compilation error occurred.
    *Action:   Return OCI_SUCCESS_WITH_INFO along with the error code

    Pluggable database INDIGO altered.
    ```

    </details>

5. Examine the error happening while opening the *INDIGO* PDB.

    ``` sql
    <copy>
    select cause, type, message
    from   pdb_plug_in_violations
    where  name='INDIGO' and status!='RESOLVED';
    </copy>

    -- Be sure to hit RETURN
    ```

    * The PDB won't open because it hasn't been properly patched.
    * The dictionary version of the CDB$ROOT and the PDB are now different and must be aligned.
    * Datapatch skipped the PDB because it was not open.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> select cause, type, message
         from   pdb_plug_in_violations
         where  name='INDIGO' and status!='RESOLVED';

    CAUSE          TYPE     MESSAGE
    -------------- -------- --------------------------------------------------------------------------------------------------------------------------------------------
    SQL Patch      ERROR    Interim patch 37847857/27534561 (OJVM RELEASE UPDATE: 19.28.0.0.250715 (37847857)): Installed in the CDB but not in the PDB
    SQL Patch      ERROR    Interim patch 38170982/27628376 (DATAPUMP BUNDLE PATCH 19.28.0.0.0): Installed in the CDB but not in the PDB
    SQL Patch      ERROR    Interim patch 37499406/26115603 (OJVM RELEASE UPDATE: 19.27.0.0.250415 (37499406)): Not installed in the CDB but installed in the PDB
    SQL Patch      ERROR    Interim patch 37777295/27238855 (DATAPUMP BUNDLE PATCH 19.27.0.0.0): Not installed in the CDB but installed in the PDB
    SQL Patch      ERROR    '19.28.0.0.0 Release_Update 2507050304' is installed in the CDB but '19.27.0.0.0 Release_Update 2504061311' is installed in the PDB
    ```

    </details>

6. Although the PDB is open, it is in *restricted* mode. Only users with *restricted session* privilege can connect.

    ``` sql
    <copy>
    show pdbs
    </copy>
    ```

    * Notice *YES* in the *RESTRICTED* column of *INDIGO*.
    * Datapatch can patch a PDB as long as it is open *READ WRITE*. Even if a PDB is open in *RESTRICTED* mode, you can still patch it with Datapatch.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> show pdbs

        CON_ID CON_NAME      OPEN MODE  RESTRICTED
    ---------- ------------- ---------- ----------
             2 PDB$SEED      READ ONLY  NO
             3 INDIGO        READ WRITE YES
             4 ORANGE        READ WRITE NO
    ```

    </details>

7. You can override this behavior and force the database to open unpatched PDBs.

    ``` sql
    <copy>
    alter system set "_pdb_datapatch_violation_restricted"=false;
    alter pluggable database indigo close;
    alter pluggable database indigo open;
    </copy>

    -- Be sure to hit RETURN
    ```

    * Notice that *INDIGO* now opens without errors.
    * **Use this underscore parameter with caution!** Although the PDB opens unrestricted, it is still unpatched.
    * Although you can use the parameter to forcefully open the PDB and allow users to connect, you must still complete the patching process.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> alter system set "_pdb_datapatch_violation_restricted"=false;

    System altered.

    SQL> alter pluggable database indigo close;

    Pluggable database altered.

    SQL> alter pluggable database indigo open;

    Pluggable database altered.
    ```

    </details>

8. Check the status of the PDB.

    ``` sql
    <copy>
    show pdbs
    </copy>
    ```

    * Notice *NO* in the *RESTRICTED* column of *INDIGO*.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> show pdbs

        CON_ID CON_NAME      OPEN MODE  RESTRICTED
    ---------- ------------- ---------- ----------
             2 PDB$SEED      READ ONLY  NO
             3 INDIGO        READ WRITE NO
             4 ORANGE        READ WRITE NO
    ```

    </details>

9. Exit SQLcl.

    ``` sql
    <copy>
    exit
    </copy>
    ```

10. Patch the *INDIGO* PDB.

    ``` bash
    <copy>
    $ORACLE_HOME/OPatch/datapatch -pdbs INDIGO
    </copy>
    ```

    * The command line parameter `-pdbs` ensure that Datapatch just works on the *INDIGO* PDB.
    * You could also run Datapatch without the parameter. It would then examine the database and determine only *INDIGO* needed patching. However, this might take slightly longer.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    $ $ORACLE_HOME/OPatch/datapatch -pdbs INDIGO
    SQL Patching tool version 19.28.0.0.0 Production on Sun Jul 27 16:42:12 2025
    Copyright (c) 2012, 2025, Oracle.  All rights reserved.

    Log file for this invocation: /u01/app/oracle/cfgtoollogs/sqlpatch/sqlpatch_303293_2025_07_27_16_42_12/sqlpatch_invocation.log

    Connecting to database...OK
    Gathering database info...done

    Note:  Datapatch will only apply or rollback SQL fixes for PDBs
           that are in an open state, no patches will be applied to closed PDBs.
           Please refer to Note: Datapatch: Database 12c Post Patch SQL Automation
           (Doc ID 1585822.1)

    Bootstrapping registry and package to current versions...done
    Determining current state...done

    Current state of interim SQL patches:
    Interim patch 37499406 (OJVM RELEASE UPDATE: 19.27.0.0.250415 (37499406)):
      Binary registry: Not installed
      PDB INDIGO: Applied successfully on 24-JUL-25 11.40.06.122876 AM
    Interim patch 37777295 (DATAPUMP BUNDLE PATCH 19.27.0.0.0):
      Binary registry: Not installed
      PDB INDIGO: Applied successfully on 24-JUL-25 11.41.23.598307 AM
    Interim patch 37847857 (OJVM RELEASE UPDATE: 19.28.0.0.250715 (37847857)):
      Binary registry: Installed
      PDB INDIGO: Not installed
    Interim patch 38170982 (DATAPUMP BUNDLE PATCH 19.28.0.0.0):
      Binary registry: Installed
      PDB INDIGO: Not installed

    Current state of release update SQL patches:
      Binary registry:
        19.28.0.0.0 Release_Update 250705030417: Installed
      PDB INDIGO:
        Applied 19.27.0.0.0 Release_Update 250406131139 successfully on 24-JUL-25 11.41.15.860182 AM

    Adding patches to installation queue and performing prereq checks...done
    Installation queue:
      For the following PDBs: INDIGO
        The following interim patches will be rolled back:
          37499406 (OJVM RELEASE UPDATE: 19.27.0.0.250415 (37499406))
          37777295 (DATAPUMP BUNDLE PATCH 19.27.0.0.0)
        Patch 37960098 (Database Release Update : 19.28.0.0.250715 (37960098)):
          Apply from 19.27.0.0.0 Release_Update 250406131139 to 19.28.0.0.0 Release_Update 250705030417
        The following interim patches will be applied:
          37847857 (OJVM RELEASE UPDATE: 19.28.0.0.250715 (37847857))
          38170982 (DATAPUMP BUNDLE PATCH 19.28.0.0.0)

    Installing patches...
    Patch installation complete.  Total patches installed: 5

    Validating logfiles...done
    Patch 37499406 rollback (pdb INDIGO): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/37499406/26115603/37499406_rollback_CDB19_INDIGO_2025Jul27_16_42_37.log (no errors)
    Patch 37777295 rollback (pdb INDIGO): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/37777295/27238855/37777295_rollback_CDB19_INDIGO_2025Jul27_16_42_37.log (no errors)
    Patch 37960098 apply (pdb INDIGO): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/37960098/27635722/37960098_apply_CDB19_INDIGO_2025Jul27_16_42_37.log (no errors)
    Patch 37847857 apply (pdb INDIGO): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/37847857/27534561/37847857_apply_CDB19_INDIGO_2025Jul27_16_42_37.log (no errors)
    Patch 38170982 apply (pdb INDIGO): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/38170982/27628376/38170982_apply_CDB19_INDIGO_2025Jul27_16_42_47.log (no errors)
    SQL Patching tool complete on Sun Jul 27 16:42:57 2025
    ```

    </details>

You may now [*proceed to the next lab*](#next).

## Acknowledgements

* **Author** - Daniel Overby Hansen
* **Contributors** - Rodrigo Jorge, Mike Dietrich
* **Last Updated By/Date** - Daniel Overby Hansen, August 2025
