# Manual Patching of a Container Database

## Introduction

In this lab, you will *manually* patch a container database. The *CDB19* database is running on 19.31 and you will patch it to an existing Oracle home on 19.32. In addition, you will check how PDBs behave during patching.

It is safer and easier to patch a database using AutoUpgrade. By patching a database manually, you can compare the two methods and see the benefits of AutoUpgrade.

Estimated Time: 15 Minutes

### Objectives

In this lab, you will:

* Patch a container database
* Check PDB behavior

### Prerequisites

None.

## Task 1: Patch a Container Database

You will patch *CDB19* to 19.32 and use an existing Oracle home.

1. Use the *yellow* terminal 🟨. Set the environment to the *CDB19* database and connect.

    ``` sql
    <copy>
    . cdb19
    sql / as sysdba
    </copy>
    ```

2. Create a new PDB.

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

3. Check the current version.

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
    19.31.0.0.0
    ```

    </details>

4. Shut down the database, so you can patch it to 19.32.

    ``` sql
    <copy>
    shutdown immediate
    </copy>
    ```

    * You must shut down a single instance database to patch it. In contrast, if it was an Oracle RAC Database, you could patch it using the *RAC Rolling* method without downtime.

5. Exit SQLcl.

    ``` bash
    <copy>
    exit
    </copy>
    ```

6. Move the SPFile and password file to the new Oracle home.

    ``` bash
    <copy>
    export NEW_ORACLE_HOME=/u01/app/oracle/product/dbhome_19_32
    export OLD_ORACLE_HOME=/u01/app/oracle/product/19
    mv $OLD_ORACLE_HOME/dbs/spfileCDB19.ora $NEW_ORACLE_HOME/dbs
    mv $OLD_ORACLE_HOME/dbs/orapwCDB19 $NEW_ORACLE_HOME/dbs
    </copy>

    # Be sure to press RETURN
    ```

    * In this lab, there is no PFile, so we don't need to move that one.
    * There are also no network files, such as `tnsnames.ora` and `sqlnet.ora`, in `$ORACLE_HOME/network/admin`, so we do not move those either.
    * There might be many other files in the Oracle home. Check the blog post [Files to Move During Oracle Database Out-Of-Place Patching](https://dohdatabase.com/2023/05/30/files-to-move-during-oracle-database-out-of-place-patching/) for details.

7. You need to set the environment to the new Oracle home. Update the profile script and reset the environment.

    ``` bash
    <copy>
    sed -i 's|^ORACLE_HOME=.*|ORACLE_HOME=/u01/app/oracle/product/dbhome_19_32|' /usr/local/bin/cdb19
    . cdb19
    env | grep ORA
    </copy>

    # Be sure to press RETURN
    ```

8. Update `/etc/oratab` to reflect the new Oracle home.

    ``` bash
    <copy>
    sed 's|^CDB19:.*|CDB19:/u01/app/oracle/product/dbhome_19_32:Y|' /etc/oratab > /tmp/oratab
    cat /tmp/oratab > /etc/oratab
    grep "CDB19:" /etc/oratab
    </copy>

    # Be sure to press RETURN
    ```

9. Connect to the database.

    ``` sql
    <copy>
    sql / as sysdba
    </copy>
    ```

10. Start the database instance and check PDBs.

    ``` sql
    <copy>
    startup
    select name, open_mode, restricted from v$pdbs;
    </copy>
    ```

    * Notice that the *INDIGO* PDB is mounted because its open state was not saved.

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
    SQL> select name, open_mode, restricted from v$pdbs;

    NAME          OPEN_MODE     RESTRICTED
    _____________ _____________ _____________
    PDB$SEED      READ ONLY     NO
    INDIGO        MOUNTED
    ORANGE        READ WRITE    NO
    TERRACOTTA    READ WRITE    NO
    ```

    </details>

11. Exit SQLcl.

    ``` bash
    <copy>
    exit
    </copy>
    ```

## Task 2: Examine Datapatch Behavior

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
    SQL Patching tool version 19.32.0.0.0 Production on Wed Sep  2 08:38:54 2026
    Copyright (c) 2012, 2026, Oracle.  All rights reserved.

    Log file for this invocation: /u01/app/oracle/cfgtoollogs/sqlpatch/sqlpatch_120734_2026_09_02_08_38_54/sqlpatch_invocation.log

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
    Interim patch 38906621 (OJVM RELEASE UPDATE: 19.31.0.0.260421 (38906621)):
      Binary registry: Not installed
      PDB CDB$ROOT: Applied successfully on 01-SEP-26 02.34.09.543024 PM
      PDB ORANGE: Applied successfully on 01-SEP-26 02.35.56.902699 PM
      PDB PDB$SEED: Applied successfully on 01-SEP-26 02.35.56.902699 PM
      PDB TERRACOTTA: Applied successfully on 01-SEP-26 02.35.56.902699 PM
    Interim patch 39196236 (DATAPUMP BUNDLE PATCH 19.31.0.0.0):
      Binary registry: Not installed
      PDB CDB$ROOT: Applied successfully on 01-SEP-26 02.35.51.553181 PM
      PDB ORANGE: Applied successfully on 01-SEP-26 02.37.08.635055 PM
      PDB PDB$SEED: Applied successfully on 01-SEP-26 02.37.08.635055 PM
      PDB TERRACOTTA: Applied successfully on 01-SEP-26 02.37.08.635055 PM
    Interim patch 39222882 (OJVM RELEASE UPDATE: 19.32.0.0.260721 (39222882)):
      Binary registry: Installed
      PDB CDB$ROOT: Not installed
      PDB ORANGE: Not installed
      PDB PDB$SEED: Not installed
      PDB TERRACOTTA: Not installed
    Interim patch 39657094 (DATAPUMP BUNDLE PATCH 19.32.0.0.0):
      Binary registry: Installed
      PDB CDB$ROOT: Not installed
      PDB ORANGE: Not installed
      PDB PDB$SEED: Not installed
      PDB TERRACOTTA: Not installed

    Current state of release update SQL patches:
      Binary registry:
        19.32.0.0.0 Release_Update 260705220710: Installed
      PDB CDB$ROOT:
        Applied 19.31.0.0.0 Release_Update 260514003012 successfully on 01-SEP-26 02.35.39.827433 PM
      PDB ORANGE:
        Applied 19.31.0.0.0 Release_Update 260514003012 successfully on 01-SEP-26 02.37.02.349192 PM
      PDB PDB$SEED:
        Applied 19.31.0.0.0 Release_Update 260514003012 successfully on 01-SEP-26 02.37.02.349192 PM
      PDB TERRACOTTA:
        Applied 19.31.0.0.0 Release_Update 260514003012 successfully on 01-SEP-26 02.37.02.349192 PM

    Adding patches to installation queue and performing prereq checks...done
    Installation queue:
      For the following PDBs: CDB$ROOT PDB$SEED ORANGE TERRACOTTA
        The following interim patches will be rolled back:
          38906621 (OJVM RELEASE UPDATE: 19.31.0.0.260421 (38906621))
          39196236 (DATAPUMP BUNDLE PATCH 19.31.0.0.0)
        Patch 39472050 (Database Release Update : 19.32.0.0.260721 (39472050)):
          Apply from 19.31.0.0.0 Release_Update 260514003012 to 19.32.0.0.0 Release_Update 260705220710
        The following interim patches will be applied:
          39222882 (OJVM RELEASE UPDATE: 19.32.0.0.260721 (39222882))
          39657094 (DATAPUMP BUNDLE PATCH 19.32.0.0.0)

    Installing patches...
    Patch installation complete.  Total patches installed: 20

    Validating logfiles...done
    Patch 38906621 rollback (pdb CDB$ROOT): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/38906621/28588735/38906621_rollback_CDB19_CDBROOT_2026Sep02_08_39_39.log (no errors)
    Patch 39196236 rollback (pdb CDB$ROOT): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/39196236/28705537/39196236_rollback_CDB19_CDBROOT_2026Sep02_08_39_39.log (no errors)
    Patch 39472050 apply (pdb CDB$ROOT): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/39472050/28919163/39472050_apply_CDB19_CDBROOT_2026Sep02_08_39_40.log (no errors)
    Patch 39222882 apply (pdb CDB$ROOT): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/39222882/28830205/39222882_apply_CDB19_CDBROOT_2026Sep02_08_39_39.log (no errors)
    Patch 39657094 apply (pdb CDB$ROOT): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/39657094/28915841/39657094_apply_CDB19_CDBROOT_2026Sep02_08_40_02.log (no errors)
    Patch 38906621 rollback (pdb PDB$SEED): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/38906621/28588735/38906621_rollback_CDB19_PDBSEED_2026Sep02_08_40_24.log (no errors)
    Patch 39196236 rollback (pdb PDB$SEED): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/39196236/28705537/39196236_rollback_CDB19_PDBSEED_2026Sep02_08_40_24.log (no errors)
    Patch 39472050 apply (pdb PDB$SEED): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/39472050/28919163/39472050_apply_CDB19_PDBSEED_2026Sep02_08_40_24.log (no errors)
    Patch 39222882 apply (pdb PDB$SEED): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/39222882/28830205/39222882_apply_CDB19_PDBSEED_2026Sep02_08_40_24.log (no errors)
    Patch 39657094 apply (pdb PDB$SEED): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/39657094/28915841/39657094_apply_CDB19_PDBSEED_2026Sep02_08_40_35.log (no errors)
    Patch 38906621 rollback (pdb ORANGE): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/38906621/28588735/38906621_rollback_CDB19_ORANGE_2026Sep02_08_40_24.log (no errors)
    Patch 39196236 rollback (pdb ORANGE): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/39196236/28705537/39196236_rollback_CDB19_ORANGE_2026Sep02_08_40_24.log (no errors)
    Patch 39472050 apply (pdb ORANGE): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/39472050/28919163/39472050_apply_CDB19_ORANGE_2026Sep02_08_40_25.log (no errors)
    Patch 39222882 apply (pdb ORANGE): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/39222882/28830205/39222882_apply_CDB19_ORANGE_2026Sep02_08_40_24.log (no errors)
    Patch 39657094 apply (pdb ORANGE): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/39657094/28915841/39657094_apply_CDB19_ORANGE_2026Sep02_08_40_36.log (no errors)
    Patch 38906621 rollback (pdb TERRACOTTA): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/38906621/28588735/38906621_rollback_CDB19_TERRACOTTA_2026Sep02_08_40_24.log (no errors)
    Patch 39196236 rollback (pdb TERRACOTTA): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/39196236/28705537/39196236_rollback_CDB19_TERRACOTTA_2026Sep02_08_40_24.log (no errors)
    Patch 39472050 apply (pdb TERRACOTTA): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/39472050/28919163/39472050_apply_CDB19_TERRACOTTA_2026Sep02_08_40_25.log (no errors)
    Patch 39222882 apply (pdb TERRACOTTA): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/39222882/28830205/39222882_apply_CDB19_TERRACOTTA_2026Sep02_08_40_24.log (no errors)
    Patch 39657094 apply (pdb TERRACOTTA): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/39657094/28915841/39657094_apply_CDB19_TERRACOTTA_2026Sep02_08_40_36.log (no errors)
    SQL Patching tool complete on Wed Sep  2 08:41:05 2026
    ```

    </details>

3. Connect to the database.

    ``` sql
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
    ```

    * The PDB does not open because it has not been properly patched.
    * The dictionary version of the CDB$ROOT and the PDB are now different and must be aligned.
    * Datapatch skipped the PDB because it was not open.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> select cause, type, message
         from   pdb_plug_in_violations
         where  name='INDIGO' and status!='RESOLVED';

    CAUSE        TYPE     MESSAGE
    ------------ -------- --------------------------------------------------------------------------------------------------------------------------------------------
    SQL Patch    ERROR    Interim patch 39222882/28830205 (OJVM RELEASE UPDATE: 19.32.0.0.260721 (39222882)): Installed in the CDB but not in the PDB
    SQL Patch    ERROR    Interim patch 39657094/28915841 (DATAPUMP BUNDLE PATCH 19.32.0.0.0): Installed in the CDB but not in the PDB
    SQL Patch    ERROR    Interim patch 38906621/28588735 (OJVM RELEASE UPDATE: 19.31.0.0.260421 (38906621)): Not installed in the CDB but installed in the PDB
    SQL Patch    ERROR    Interim patch 39196236/28705537 (DATAPUMP BUNDLE PATCH 19.31.0.0.0): Not installed in the CDB but installed in the PDB
    SQL Patch    ERROR    '19.32.0.0.0 Release_Update 2607052207' is installed in the CDB but '19.31.0.0.0 Release_Update 2605140030' is installed in the PDB
    ```

    </details>

6. Although the PDB is open, it is in *restricted* mode. Only users with *restricted session* privilege can connect.

    ``` sql
    <copy>
    select name, open_mode, restricted from v$pdbs;
    </copy>
    ```

    * Notice *YES* in the *RESTRICTED* column of *INDIGO*.
    * Datapatch can patch a PDB as long as it is open *READ WRITE*. Even if a PDB is open in *RESTRICTED* mode, you can still patch it with Datapatch.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    NAME          OPEN_MODE     RESTRICTED
    _____________ _____________ _____________
    PDB$SEED      READ ONLY     NO
    INDIGO        READ WRITE    YES
    ORANGE        READ WRITE    NO
    TERRACOTTA    READ WRITE    NO
    ```

    </details>

7. You can override this behavior and force the database to open unpatched PDBs.

    ``` sql
    <copy>
    alter system set "_pdb_datapatch_violation_restricted"=false;
    alter pluggable database indigo close;
    alter pluggable database indigo open;
    </copy>
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
    select name, open_mode, restricted from v$pdbs;
    </copy>
    ```

    * Notice *NO* in the *RESTRICTED* column of *INDIGO*.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    NAME          OPEN_MODE     RESTRICTED
    _____________ _____________ _____________
    PDB$SEED      READ ONLY     NO
    INDIGO        READ WRITE    NO
    ORANGE        READ WRITE    NO
    TERRACOTTA    READ WRITE    NO
    ```

    </details>

9. Exit SQLcl.

    ``` bash
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

    * The command-line parameter `-pdbs` ensures that Datapatch works only on the *INDIGO* PDB.
    * You could also run Datapatch without the parameter. It would then examine the database and determine only *INDIGO* needed patching. However, this might take slightly longer.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL Patching tool version 19.32.0.0.0 Production on Wed Sep  2 08:43:45 2026
    Copyright (c) 2012, 2026, Oracle.  All rights reserved.

    Log file for this invocation: /u01/app/oracle/cfgtoollogs/sqlpatch/sqlpatch_121821_2026_09_02_08_43_45/sqlpatch_invocation.log

    Connecting to database...OK
    Gathering database info...done

    Note:  Datapatch will only apply or rollback SQL fixes for PDBs
           that are in an open state, no patches will be applied to closed PDBs.
           Please refer to Note: Datapatch: Database 12c Post Patch SQL Automation
           (Doc ID 1585822.1)

    Bootstrapping registry and package to current versions...done
    Determining current state...done

    Current state of interim SQL patches:
    Interim patch 38906621 (OJVM RELEASE UPDATE: 19.31.0.0.260421 (38906621)):
      Binary registry: Not installed
      PDB INDIGO: Applied successfully on 01-SEP-26 02.35.56.902699 PM
    Interim patch 39196236 (DATAPUMP BUNDLE PATCH 19.31.0.0.0):
      Binary registry: Not installed
      PDB INDIGO: Applied successfully on 01-SEP-26 02.37.08.635055 PM
    Interim patch 39222882 (OJVM RELEASE UPDATE: 19.32.0.0.260721 (39222882)):
      Binary registry: Installed
      PDB INDIGO: Not installed
    Interim patch 39657094 (DATAPUMP BUNDLE PATCH 19.32.0.0.0):
      Binary registry: Installed
      PDB INDIGO: Not installed

    Current state of release update SQL patches:
      Binary registry:
        19.32.0.0.0 Release_Update 260705220710: Installed
      PDB INDIGO:
        Applied 19.31.0.0.0 Release_Update 260514003012 successfully on 01-SEP-26 02.37.02.349192 PM

    Adding patches to installation queue and performing prereq checks...done
    Installation queue:
      For the following PDBs: INDIGO
        The following interim patches will be rolled back:
          38906621 (OJVM RELEASE UPDATE: 19.31.0.0.260421 (38906621))
          39196236 (DATAPUMP BUNDLE PATCH 19.31.0.0.0)
        Patch 39472050 (Database Release Update : 19.32.0.0.260721 (39472050)):
          Apply from 19.31.0.0.0 Release_Update 260514003012 to 19.32.0.0.0 Release_Update 260705220710
        The following interim patches will be applied:
          39222882 (OJVM RELEASE UPDATE: 19.32.0.0.260721 (39222882))
          39657094 (DATAPUMP BUNDLE PATCH 19.32.0.0.0)

    Installing patches...
    Patch installation complete.  Total patches installed: 5

    Validating logfiles...done
    Patch 38906621 rollback (pdb INDIGO): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/38906621/28588735/38906621_rollback_CDB19_INDIGO_2026Sep02_08_44_09.log (no errors)
    Patch 39196236 rollback (pdb INDIGO): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/39196236/28705537/39196236_rollback_CDB19_INDIGO_2026Sep02_08_44_09.log (no errors)
    Patch 39472050 apply (pdb INDIGO): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/39472050/28919163/39472050_apply_CDB19_INDIGO_2026Sep02_08_44_09.log (no errors)
    Patch 39222882 apply (pdb INDIGO): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/39222882/28830205/39222882_apply_CDB19_INDIGO_2026Sep02_08_44_09.log (no errors)
    Patch 39657094 apply (pdb INDIGO): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/39657094/28915841/39657094_apply_CDB19_INDIGO_2026Sep02_08_44_19.log (no errors)
    SQL Patching tool complete on Wed Sep  2 08:44:41 2026
    ```

    </details>

## Task 3: Complete Patching

1. Remain in the *yellow* terminal 🟨.

2. Reconnect to *CDB19*.

    ``` sql
    <copy>
    sql / as sysdba
    </copy>
    ```

3. Check the database directories.

    ``` sql
    <copy>
    set pagesize 100
    select directory_name , directory_path from dba_directories where owner='SYS' order by 2;
    </copy>
    ```

    * Some database directories point to the Oracle home.
    * When you patch out-of-place the Oracle home location changes, and the directory path must point to the new Oracle home.
    * Some of these directories are not updated and continue to point to the old Oracle home.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> select directory_name , directory_path from dba_directories where owner='SYS' order by 2;

    DIRECTORY_NAME              DIRECTORY_PATH
    ___________________________ _____________________________________________________
    ORACLE_BASE                 /u01/app/oracle
    ORACLE_HOME                 /u01/app/oracle/product/19
    ORACLE_OCM_CONFIG_DIR       /u01/app/oracle/product/19/ccr/state
    ORACLE_OCM_CONFIG_DIR2      /u01/app/oracle/product/19/ccr/state
    DBMS_OPTIM_LOGDIR           /u01/app/oracle/product/19/cfgtoollogs
    DBMS_OPTIM_ADMINDIR         /u01/app/oracle/product/19/rdbms/admin
    DATA_PUMP_DIR               /u01/app/oracle/product/19/rdbms/log/
    XMLDIR                      /u01/app/oracle/product/19/rdbms/xml
    XSDDIR                      /u01/app/oracle/product/19/rdbms/xml/schema
    OPATCH_INST_DIR             /u01/app/oracle/product/dbhome_19_32/OPatch
    OPATCH_SCRIPT_DIR           /u01/app/oracle/product/dbhome_19_32/QOpatch
    JAVA$JOX$CUJS$DIRECTORY$    /u01/app/oracle/product/dbhome_19_32/javavm/admin/
    OPATCH_LOG_DIR              /u01/app/oracle/product/dbhome_19_32/rdbms/log

    13 rows selected.
    ```

    </details>

4. The outdated directory paths occur in all containers.

    ``` sql
    <copy>
    select   con$name, directory_name , directory_path
    from     cdb_directories
    where    owner='SYS'
    order by 1, 3, 2;
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> select   con$name, directory_name , directory_path
         from     cdb_directories
         where    owner='SYS'
         order by 1, 3, 2;

    CON$NAME      DIRECTORY_NAME              DIRECTORY_PATH
    _____________ ___________________________ __________________________________________________________________________________
    CDB$ROOT      ORACLE_BASE                 /u01/app/oracle
    CDB$ROOT      ORACLE_HOME                 /u01/app/oracle/product/19
    CDB$ROOT      ORACLE_OCM_CONFIG_DIR       /u01/app/oracle/product/19/ccr/state
    CDB$ROOT      ORACLE_OCM_CONFIG_DIR2      /u01/app/oracle/product/19/ccr/state
    CDB$ROOT      DBMS_OPTIM_LOGDIR           /u01/app/oracle/product/19/cfgtoollogs
    CDB$ROOT      DBMS_OPTIM_ADMINDIR         /u01/app/oracle/product/19/rdbms/admin
    CDB$ROOT      DATA_PUMP_DIR               /u01/app/oracle/product/19/rdbms/log/
    CDB$ROOT      XMLDIR                      /u01/app/oracle/product/19/rdbms/xml
    CDB$ROOT      XSDDIR                      /u01/app/oracle/product/19/rdbms/xml/schema
    CDB$ROOT      OPATCH_INST_DIR             /u01/app/oracle/product/dbhome_19_32/OPatch
    CDB$ROOT      OPATCH_SCRIPT_DIR           /u01/app/oracle/product/dbhome_19_32/QOpatch
    CDB$ROOT      JAVA$JOX$CUJS$DIRECTORY$    /u01/app/oracle/product/dbhome_19_32/javavm/admin/
    CDB$ROOT      OPATCH_LOG_DIR              /u01/app/oracle/product/dbhome_19_32/rdbms/log
    INDIGO        ORACLE_BASE                 /u01/app/oracle
    INDIGO        ORACLE_HOME                 /u01/app/oracle/product/19
    INDIGO        DBMS_OPTIM_LOGDIR           /u01/app/oracle/product/19/cfgtoollogs
    INDIGO        DBMS_OPTIM_ADMINDIR         /u01/app/oracle/product/19/rdbms/admin
    INDIGO        DATA_PUMP_DIR               /u01/app/oracle/product/19/rdbms/log/5A98C02165A191EDE0631D01000AFDFA
    INDIGO        XMLDIR                      /u01/app/oracle/product/19/rdbms/xml
    INDIGO        XSDDIR                      /u01/app/oracle/product/19/rdbms/xml/schema
    INDIGO        OPATCH_INST_DIR             /u01/app/oracle/product/dbhome_19_32/OPatch
    INDIGO        OPATCH_SCRIPT_DIR           /u01/app/oracle/product/dbhome_19_32/QOpatch
    INDIGO        JAVA$JOX$CUJS$DIRECTORY$    /u01/app/oracle/product/dbhome_19_32/javavm/admin/
    INDIGO        OPATCH_LOG_DIR              /u01/app/oracle/product/dbhome_19_32/rdbms/log
    ORANGE        ORACLE_BASE                 /u01/app/oracle
    ORANGE        ORACLE_HOME                 /u01/app/oracle/product/19
    ORANGE        DBMS_OPTIM_LOGDIR           /u01/app/oracle/product/19/cfgtoollogs
    ORANGE        DBMS_OPTIM_ADMINDIR         /u01/app/oracle/product/19/rdbms/admin
    ORANGE        DATA_PUMP_DIR               /u01/app/oracle/product/19/rdbms/log/5A91FC7727F88FEBE0631D01000ABD4F
    ORANGE        XMLDIR                      /u01/app/oracle/product/19/rdbms/xml
    ORANGE        XSDDIR                      /u01/app/oracle/product/19/rdbms/xml/schema
    ORANGE        OPATCH_INST_DIR             /u01/app/oracle/product/dbhome_19_32/OPatch
    ORANGE        OPATCH_SCRIPT_DIR           /u01/app/oracle/product/dbhome_19_32/QOpatch
    ORANGE        JAVA$JOX$CUJS$DIRECTORY$    /u01/app/oracle/product/dbhome_19_32/javavm/admin/
    ORANGE        OPATCH_LOG_DIR              /u01/app/oracle/product/dbhome_19_32/rdbms/log
    TERRACOTTA    ORACLE_BASE                 /u01/app/oracle
    TERRACOTTA    ORACLE_HOME                 /u01/app/oracle/product/19
    TERRACOTTA    DBMS_OPTIM_LOGDIR           /u01/app/oracle/product/19/cfgtoollogs
    TERRACOTTA    DBMS_OPTIM_ADMINDIR         /u01/app/oracle/product/19/rdbms/admin
    TERRACOTTA    DATA_PUMP_DIR               /u01/app/oracle/product/19/rdbms/log/5A91FC7727FA8FEBE0631D01000ABD4F
    TERRACOTTA    XMLDIR                      /u01/app/oracle/product/19/rdbms/xml
    TERRACOTTA    XSDDIR                      /u01/app/oracle/product/19/rdbms/xml/schema
    TERRACOTTA    OPATCH_INST_DIR             /u01/app/oracle/product/dbhome_19_32/OPatch
    TERRACOTTA    OPATCH_SCRIPT_DIR           /u01/app/oracle/product/dbhome_19_32/QOpatch
    TERRACOTTA    JAVA$JOX$CUJS$DIRECTORY$    /u01/app/oracle/product/dbhome_19_32/javavm/admin/
    TERRACOTTA    OPATCH_LOG_DIR              /u01/app/oracle/product/dbhome_19_32/rdbms/log

    46 rows selected.
    ```

    </details>

5. Update the directories.

    ``` sql
    <copy>
    @?/rdbms/admin/utlfixdirs.sql
    </copy>
    ```

    * You update the directories in the root container.
    * These directories are shared through metadata links. Once you update the root container, they are updated in all containers.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> @?/rdbms/admin/utlfixdirs.sql

    Container: CDB$ROOT

    Current  ORACLE_HOME: /u01/app/oracle/product/dbhome_19_32
    Original ORACLE_HOME: /u01/app/oracle/product/19

    DATA_PUMP_DIR
    ...OLD: /u01/app/oracle/product/19/rdbms/log/
    ...NEW: /u01/app/oracle/product/dbhome_19_32/rdbms/log/
    DBMS_OPTIM_ADMINDIR
    ...OLD: /u01/app/oracle/product/19/rdbms/admin
    ...NEW: /u01/app/oracle/product/dbhome_19_32/rdbms/admin
    DBMS_OPTIM_LOGDIR
    ...OLD: /u01/app/oracle/product/19/cfgtoollogs
    ...NEW: /u01/app/oracle/product/dbhome_19_32/cfgtoollogs
    ORACLE_HOME
    ...OLD: /u01/app/oracle/product/19
    ...NEW: /u01/app/oracle/product/dbhome_19_32
    ORACLE_OCM_CONFIG_DIR
    ...OLD: /u01/app/oracle/product/19/ccr/state
    ...NEW: /u01/app/oracle/product/dbhome_19_32/ccr/state
    ORACLE_OCM_CONFIG_DIR2
    ...OLD: /u01/app/oracle/product/19/ccr/state
    ...NEW: /u01/app/oracle/product/dbhome_19_32/ccr/state
    XMLDIR
    ...OLD: /u01/app/oracle/product/19/rdbms/xml
    ...NEW: /u01/app/oracle/product/dbhome_19_32/rdbms/xml
    XSDDIR
    ...OLD: /u01/app/oracle/product/19/rdbms/xml/schema
    ...NEW: /u01/app/oracle/product/dbhome_19_32/rdbms/xml/schema


    PL/SQL procedure successfully completed.
    ```

    </details>

6. Verify the directories are correct.

    ``` sql
    <copy>
    select   con$name, directory_name , directory_path
    from     cdb_directories
    where    owner='SYS'
    order by 1, 3, 2;
    </copy>
    ```

    * Notice that all Oracle-home-dependent directory paths point to the new Oracle home; `ORACLE_BASE` remains `/u01/app/oracle`.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> select   con$name, directory_name , directory_path
         from     cdb_directories
         where    owner='SYS'
         order by 1, 3, 2;

    CON$NAME      DIRECTORY_NAME              DIRECTORY_PATH
    _____________ ___________________________ __________________________________________________________________________________
    CDB$ROOT      ORACLE_BASE                 /u01/app/oracle
    CDB$ROOT      ORACLE_HOME                 /u01/app/oracle/product/dbhome_19_32
    CDB$ROOT      OPATCH_INST_DIR             /u01/app/oracle/product/dbhome_19_32/OPatch
    CDB$ROOT      OPATCH_SCRIPT_DIR           /u01/app/oracle/product/dbhome_19_32/QOpatch
    CDB$ROOT      ORACLE_OCM_CONFIG_DIR       /u01/app/oracle/product/dbhome_19_32/ccr/state
    CDB$ROOT      ORACLE_OCM_CONFIG_DIR2      /u01/app/oracle/product/dbhome_19_32/ccr/state
    CDB$ROOT      DBMS_OPTIM_LOGDIR           /u01/app/oracle/product/dbhome_19_32/cfgtoollogs
    CDB$ROOT      JAVA$JOX$CUJS$DIRECTORY$    /u01/app/oracle/product/dbhome_19_32/javavm/admin/
    CDB$ROOT      DBMS_OPTIM_ADMINDIR         /u01/app/oracle/product/dbhome_19_32/rdbms/admin
    CDB$ROOT      OPATCH_LOG_DIR              /u01/app/oracle/product/dbhome_19_32/rdbms/log
    CDB$ROOT      DATA_PUMP_DIR               /u01/app/oracle/product/dbhome_19_32/rdbms/log/
    CDB$ROOT      XMLDIR                      /u01/app/oracle/product/dbhome_19_32/rdbms/xml
    CDB$ROOT      XSDDIR                      /u01/app/oracle/product/dbhome_19_32/rdbms/xml/schema
    INDIGO        ORACLE_BASE                 /u01/app/oracle
    INDIGO        ORACLE_HOME                 /u01/app/oracle/product/dbhome_19_32
    INDIGO        OPATCH_INST_DIR             /u01/app/oracle/product/dbhome_19_32/OPatch
    INDIGO        OPATCH_SCRIPT_DIR           /u01/app/oracle/product/dbhome_19_32/QOpatch
    INDIGO        DBMS_OPTIM_LOGDIR           /u01/app/oracle/product/dbhome_19_32/cfgtoollogs
    INDIGO        JAVA$JOX$CUJS$DIRECTORY$    /u01/app/oracle/product/dbhome_19_32/javavm/admin/
    INDIGO        DBMS_OPTIM_ADMINDIR         /u01/app/oracle/product/dbhome_19_32/rdbms/admin
    INDIGO        OPATCH_LOG_DIR              /u01/app/oracle/product/dbhome_19_32/rdbms/log
    INDIGO        DATA_PUMP_DIR               /u01/app/oracle/product/dbhome_19_32/rdbms/log/5A98C02165A191EDE0631D01000AFDFA
    INDIGO        XMLDIR                      /u01/app/oracle/product/dbhome_19_32/rdbms/xml
    INDIGO        XSDDIR                      /u01/app/oracle/product/dbhome_19_32/rdbms/xml/schema
    ORANGE        ORACLE_BASE                 /u01/app/oracle
    ORANGE        ORACLE_HOME                 /u01/app/oracle/product/dbhome_19_32
    ORANGE        OPATCH_INST_DIR             /u01/app/oracle/product/dbhome_19_32/OPatch
    ORANGE        OPATCH_SCRIPT_DIR           /u01/app/oracle/product/dbhome_19_32/QOpatch
    ORANGE        DBMS_OPTIM_LOGDIR           /u01/app/oracle/product/dbhome_19_32/cfgtoollogs
    ORANGE        JAVA$JOX$CUJS$DIRECTORY$    /u01/app/oracle/product/dbhome_19_32/javavm/admin/
    ORANGE        DBMS_OPTIM_ADMINDIR         /u01/app/oracle/product/dbhome_19_32/rdbms/admin
    ORANGE        OPATCH_LOG_DIR              /u01/app/oracle/product/dbhome_19_32/rdbms/log
    ORANGE        DATA_PUMP_DIR               /u01/app/oracle/product/dbhome_19_32/rdbms/log/5A91FC7727F88FEBE0631D01000ABD4F
    ORANGE        XMLDIR                      /u01/app/oracle/product/dbhome_19_32/rdbms/xml
    ORANGE        XSDDIR                      /u01/app/oracle/product/dbhome_19_32/rdbms/xml/schema
    TERRACOTTA    ORACLE_BASE                 /u01/app/oracle
    TERRACOTTA    ORACLE_HOME                 /u01/app/oracle/product/dbhome_19_32
    TERRACOTTA    OPATCH_INST_DIR             /u01/app/oracle/product/dbhome_19_32/OPatch
    TERRACOTTA    OPATCH_SCRIPT_DIR           /u01/app/oracle/product/dbhome_19_32/QOpatch
    TERRACOTTA    DBMS_OPTIM_LOGDIR           /u01/app/oracle/product/dbhome_19_32/cfgtoollogs
    TERRACOTTA    JAVA$JOX$CUJS$DIRECTORY$    /u01/app/oracle/product/dbhome_19_32/javavm/admin/
    TERRACOTTA    DBMS_OPTIM_ADMINDIR         /u01/app/oracle/product/dbhome_19_32/rdbms/admin
    TERRACOTTA    OPATCH_LOG_DIR              /u01/app/oracle/product/dbhome_19_32/rdbms/log
    TERRACOTTA    DATA_PUMP_DIR               /u01/app/oracle/product/dbhome_19_32/rdbms/log/5A91FC7727FA8FEBE0631D01000ABD4F
    TERRACOTTA    XMLDIR                      /u01/app/oracle/product/dbhome_19_32/rdbms/xml
    TERRACOTTA    XSDDIR                      /u01/app/oracle/product/dbhome_19_32/rdbms/xml/schema

    46 rows selected.
    ```

    </details>

7. Exit SQLcl.

    ``` bash
    <copy>
    exit
    </copy>
    ```

You may now [*proceed to the next lab*](#next).

## Acknowledgements

* **Author** - Daniel Overby Hansen
* **Contributors** - Rodrigo Jorge, Alex Zaballa, Mike Dietrich, Alejandro Diaz
* **Last Updated By/Date** - Daniel Overby Hansen, September 2026
