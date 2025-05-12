# Manual Patching of a Container Database

## Introduction

In this lab, you will manually patch a container database. The *CDB19* database is running on 19.21 and you will patch it to an existing Oracle home on 19.25. In addition, you will check how PDBs behaves during patching.

Estimated Time: 15 Minutes

### Objectives

In this lab, you will:

* Patch a container database
* Check PDB behavior

### Prerequisites

This lab assumes:

- You have completed Lab 2: Simple Patching With AutoUpgrade

## Task 1: Patch a container database

You will patch *CDB19* to 19.25 and use an existing Oracle home.

1. Use the *yellow* terminal 🟨. Set the environment to the *CDB19* database and connect.

    ```
    <copy>
    . cdb19
    sqlplus / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

2. Start the database.

    ```
    <copy>
    startup
    </copy>
    ```

3. Create a new PDB.

    ```
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

5. Shut down the database, so you can patch it to 19.25.    

    ```
    <copy>
    shutdown immediate
    </copy>
    ```

6. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```    

7. Move the SPFile and password file to the new Oracle home. 

    ```
    <copy>
    export NEW_ORACLE_HOME=/u01/app/oracle/product/19_25
    export OLD_ORACLE_HOME=/u01/app/oracle/product/19
    mv $OLD_ORACLE_HOME/dbs/spfileCDB19.ora $NEW_ORACLE_HOME/dbs
    mv $OLD_ORACLE_HOME/dbs/orapwCDB19 $NEW_ORACLE_HOME/dbs
    </copy>

    -- Be sure to hit RETURN
    ```

    * In this lab, there is no PFile, so we don't need to move that one.
    * Also, there are no network files, like `tnsnames.ora` and `sqlnet.ora` in `$ORACLE_HOME/network/admin` so we don't move those either.
    * There might be many other files in the Oracle home. Check the blog post [Files to Move During Oracle Database Out-Of-Place Patching](https://dohdatabase.com/2023/05/30/files-to-move-during-oracle-database-out-of-place-patching/) for details.

8. You need to set the environment to the new Oracle home. Update the profile script and reset the environment.

    ```
    <copy>
    sed -i 's/^ORACLE_HOME=.*/ORACLE_HOME=\/u01\/app\/oracle\/product\/19_25/' /usr/local/bin/cdb19
    . cdb19
    env | grep ORA
    </copy>

    -- Be sure to hit RETURN
    ``` 

9. Update `/etc/oratab` to reflect the new Oracle home.

    ```
    <copy>
    sed 's/^CDB19:.*/CDB19:\/u01\/app\/oracle\/product\/19_25:Y/' /etc/oratab > /tmp/oratab
    cat /tmp/oratab > /etc/oratab
    grep "CDB19" /etc/oratab
    </copy>

    -- Be sure to hit RETURN
    ``` 

10. Connect to the database.

    ```
    <copy>
    sqlplus / as sysdba
    </copy>
    ```  

11. Start the database instance and check PDBs.

    ```
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
    Fixed Size		    9186096 bytes
    Variable Size		  838860800 bytes
    Database Buffers	 3439329280 bytes
    Redo Buffers		    7589888 bytes
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

12. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```    

## Task 2: Examine Datapatch behavior    

1. Remain in the *yellow* terminal 🟨. 

2. Run Datapatch to apply the SQL changes to the database. It takes a few minutes to apply the patches. Wait for Datapatch to complete.

    ```
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
    SQL Patching tool version 19.25.0.0.0 Production on Wed Dec  4 13:55:10 2024
    Copyright (c) 2012, 2024, Oracle.  All rights reserved.
    
    Log file for this invocation: /u01/app/oracle/cfgtoollogs/sqlpatch/sqlpatch_198077_2024_12_04_13_55_10/sqlpatch_invocation.log
    
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
    Interim patch 35648110 (OJVM RELEASE UPDATE: 19.21.0.0.231017 (35648110)):
      Binary registry: Not installed
      PDB CDB$ROOT: Applied successfully on 10-JUL-24 04.58.54.057867 PM
      PDB ORANGE: Applied successfully on 10-JUL-24 04.58.58.762662 PM
      PDB PDB$SEED: Applied successfully on 10-JUL-24 04.58.58.762662 PM
    Interim patch 35787077 (DATAPUMP BUNDLE PATCH 19.21.0.0.0):
      Binary registry: Not installed
      PDB CDB$ROOT: Applied successfully on 10-JUL-24 04.58.54.963317 PM
      PDB ORANGE: Applied successfully on 10-JUL-24 04.58.59.378213 PM
      PDB PDB$SEED: Applied successfully on 10-JUL-24 04.58.59.378213 PM
    Interim patch 36878697 (OJVM RELEASE UPDATE: 19.25.0.0.241015 (36878697)):
      Binary registry: Installed
      PDB CDB$ROOT: Not installed
      PDB ORANGE: Not installed
      PDB PDB$SEED: Not installed
    Interim patch 37056207 (DATAPUMP BUNDLE PATCH 19.25.0.0.0):
      Binary registry: Installed
      PDB CDB$ROOT: Not installed
      PDB ORANGE: Not installed
      PDB PDB$SEED: Not installed
    
    Current state of release update SQL patches:
      Binary registry:
        19.25.0.0.0 Release_Update 241010184253: Installed
      PDB CDB$ROOT:
        Applied 19.21.0.0.0 Release_Update 230930151951 successfully on 10-JUL-24 04.58.54.054946 PM
      PDB ORANGE:
        Applied 19.21.0.0.0 Release_Update 230930151951 successfully on 10-JUL-24 04.58.58.759864 PM
      PDB PDB$SEED:
        Applied 19.21.0.0.0 Release_Update 230930151951 successfully on 10-JUL-24 04.58.58.759864 PM
    
    Adding patches to installation queue and performing prereq checks...done
    Installation queue:
      For the following PDBs: CDB$ROOT PDB$SEED ORANGE
        The following interim patches will be rolled back:
          35648110 (OJVM RELEASE UPDATE: 19.21.0.0.231017 (35648110))
          35787077 (DATAPUMP BUNDLE PATCH 19.21.0.0.0)
        Patch 36912597 (Database Release Update : 19.25.0.0.241015 (36912597)):
          Apply from 19.21.0.0.0 Release_Update 230930151951 to 19.25.0.0.0 Release_Update 241010184253
        The following interim patches will be applied:
          36878697 (OJVM RELEASE UPDATE: 19.25.0.0.241015 (36878697))
          37056207 (DATAPUMP BUNDLE PATCH 19.25.0.0.0)
    
    Installing patches...
    Patch installation complete.  Total patches installed: 15
    
    Validating logfiles...done
    Patch 35648110 rollback (pdb CDB$ROOT): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/35648110/25365038/35648110_rollback_CDB19_CDBROOT_2024Dec04_13_55_49.log (no errors)
    Patch 35787077 rollback (pdb CDB$ROOT): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/35787077/25410019/35787077_rollback_CDB19_CDBROOT_2024Dec04_13_55_49.log (no errors)
    Patch 36912597 apply (pdb CDB$ROOT): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/36912597/25871884/36912597_apply_CDB19_CDBROOT_2024Dec04_13_55_49.log (no errors)
    Patch 36878697 apply (pdb CDB$ROOT): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/36878697/25797620/36878697_apply_CDB19_CDBROOT_2024Dec04_13_55_49.log (no errors)
    Patch 37056207 apply (pdb CDB$ROOT): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/37056207/25840925/37056207_apply_CDB19_CDBROOT_2024Dec04_13_56_48.log (no errors)
    Patch 35648110 rollback (pdb PDB$SEED): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/35648110/25365038/35648110_rollback_CDB19_PDBSEED_2024Dec04_13_57_27.log (no errors)
    Patch 35787077 rollback (pdb PDB$SEED): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/35787077/25410019/35787077_rollback_CDB19_PDBSEED_2024Dec04_13_57_27.log (no errors)
    Patch 36912597 apply (pdb PDB$SEED): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/36912597/25871884/36912597_apply_CDB19_PDBSEED_2024Dec04_13_57_27.log (no errors)
    Patch 36878697 apply (pdb PDB$SEED): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/36878697/25797620/36878697_apply_CDB19_PDBSEED_2024Dec04_13_57_27.log (no errors)
    Patch 37056207 apply (pdb PDB$SEED): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/37056207/25840925/37056207_apply_CDB19_PDBSEED_2024Dec04_13_58_09.log (no errors)
    Patch 35648110 rollback (pdb ORANGE): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/35648110/25365038/35648110_rollback_CDB19_ORANGE_2024Dec04_13_57_27.log (no errors)
    Patch 35787077 rollback (pdb ORANGE): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/35787077/25410019/35787077_rollback_CDB19_ORANGE_2024Dec04_13_57_27.log (no errors)
    Patch 36912597 apply (pdb ORANGE): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/36912597/25871884/36912597_apply_CDB19_ORANGE_2024Dec04_13_57_27.log (no errors)
    Patch 36878697 apply (pdb ORANGE): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/36878697/25797620/36878697_apply_CDB19_ORANGE_2024Dec04_13_57_27.log (no errors)
    Patch 37056207 apply (pdb ORANGE): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/37056207/25840925/37056207_apply_CDB19_ORANGE_2024Dec04_13_58_08.log (no errors)
    SQL Patching tool complete on Wed Dec  4 13:58:50 2024
    ```
    </details>  

3. Connect to the database.

    ```
    <copy>
    sqlplus / as sysdba
    </copy>
    ```

4. Open the *INDIGO* PDB.

    ```
    <copy>
    alter pluggable database indigo open;
    </copy>
    ```

    * The PDB opens with errors.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> alter pluggable database indigo open;
    
    Warning: PDB altered with errors.
    ```
    </details>      

5. Examine the error happening while opening the *INDIGO* PDB.

    ```
    <copy>
    set line 200
    col cause format a14
    col type format a8
    col message format a140
    select cause, type, message 
    from   pdb_plug_in_violations 
    where  name='INDIGO' and status!='RESOLVED';
    </copy>

    -- Be sure to hit RETURN
    ```

    * The PDB won't open because it hasn't been properly patched.
    * Datapatch skipped the PDB because it was not open.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> set line 200
    SQL> col cause format a14
    SQL> col type format a8
    SQL> col message format a140
    SQL> select cause, type, message
         from   pdb_plug_in_violations
         where  name='INDIGO' and status!='RESOLVED';
         
    CAUSE          TYPE     MESSAGE
    -------------- -------- --------------------------------------------------------------------------------------------------------------------------------------------
    SQL Patch      ERROR	Interim patch 36878697/25797620 (OJVM RELEASE UPDATE: 19.25.0.0.241015 (36878697)): Installed in the CDB but not in the PDB
    SQL Patch      ERROR	Interim patch 37056207/25840925 (DATAPUMP BUNDLE PATCH 19.25.0.0.0): Installed in the CDB but not in the PDB
    SQL Patch      ERROR	Interim patch 35648110/25365038 (OJVM RELEASE UPDATE: 19.21.0.0.231017 (35648110)): Not installed in the CDB but installed in the PDB
    SQL Patch      ERROR	Interim patch 35787077/25410019 (DATAPUMP BUNDLE PATCH 19.21.0.0.0): Not installed in the CDB but installed in the PDB
    SQL Patch      ERROR	'19.25.0.0.0 Release_Update 2410101842' is installed in the CDB but '19.21.0.0.0 Release_Update 2309301519' is installed in the PDB
    ```
    </details>     

6. Although the PDB is open, it is in *restricted* mode. Only users with *restricted session* privilege can connect.

    ```
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

    ```
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

    ```
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

9. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```    

10. Patch the *INDIGO* PDB. 

    ```
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
    SQL Patching tool version 19.25.0.0.0 Production on Wed Dec  4 14:19:57 2024
    Copyright (c) 2012, 2024, Oracle.  All rights reserved.
    
    Log file for this invocation: /u01/app/oracle/cfgtoollogs/sqlpatch/sqlpatch_199665_2024_12_04_14_19_57/sqlpatch_invocation.log
    
    Connecting to database...OK
    Gathering database info...done
    
    Note:  Datapatch will only apply or rollback SQL fixes for PDBs
           that are in an open state, no patches will be applied to closed PDBs.
           Please refer to Note: Datapatch: Database 12c Post Patch SQL Automation
           (Doc ID 1585822.1)
    
    Bootstrapping registry and package to current versions...done
    Determining current state...done
    
    Current state of interim SQL patches:
    Interim patch 35648110 (OJVM RELEASE UPDATE: 19.21.0.0.231017 (35648110)):
      Binary registry: Not installed
      PDB INDIGO: Applied successfully on 10-JUL-24 04.58.58.762662 PM
    Interim patch 35787077 (DATAPUMP BUNDLE PATCH 19.21.0.0.0):
      Binary registry: Not installed
      PDB INDIGO: Applied successfully on 10-JUL-24 04.58.59.378213 PM
    Interim patch 36878697 (OJVM RELEASE UPDATE: 19.25.0.0.241015 (36878697)):
      Binary registry: Installed
      PDB INDIGO: Not installed
    Interim patch 37056207 (DATAPUMP BUNDLE PATCH 19.25.0.0.0):
      Binary registry: Installed
      PDB INDIGO: Not installed
    
    Current state of release update SQL patches:
      Binary registry:
        19.25.0.0.0 Release_Update 241010184253: Installed
      PDB INDIGO:
        Applied 19.21.0.0.0 Release_Update 230930151951 successfully on 10-JUL-24 04.58.58.759864 PM
    
    Adding patches to installation queue and performing prereq checks...done
    Installation queue:
      For the following PDBs: INDIGO
        The following interim patches will be rolled back:
          35648110 (OJVM RELEASE UPDATE: 19.21.0.0.231017 (35648110))
          35787077 (DATAPUMP BUNDLE PATCH 19.21.0.0.0)
        Patch 36912597 (Database Release Update : 19.25.0.0.241015 (36912597)):
          Apply from 19.21.0.0.0 Release_Update 230930151951 to 19.25.0.0.0 Release_Update 241010184253
        The following interim patches will be applied:
          36878697 (OJVM RELEASE UPDATE: 19.25.0.0.241015 (36878697))
          37056207 (DATAPUMP BUNDLE PATCH 19.25.0.0.0)
    
    Installing patches...
    Patch installation complete.  Total patches installed: 5
    
    Validating logfiles...done
    Patch 35648110 rollback (pdb INDIGO): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/35648110/25365038/35648110_rollback_CDB19_INDIGO_2024Dec04_14_20_21.log (no errors)
    Patch 35787077 rollback (pdb INDIGO): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/35787077/25410019/35787077_rollback_CDB19_INDIGO_2024Dec04_14_20_21.log (no errors)
    Patch 36912597 apply (pdb INDIGO): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/36912597/25871884/36912597_apply_CDB19_INDIGO_2024Dec04_14_20_21.log (no errors)
    Patch 36878697 apply (pdb INDIGO): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/36878697/25797620/36878697_apply_CDB19_INDIGO_2024Dec04_14_20_21.log (no errors)
    Patch 37056207 apply (pdb INDIGO): SUCCESS
      logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/37056207/25840925/37056207_apply_CDB19_INDIGO_2024Dec04_14_20_51.log (no errors)
    SQL Patching tool complete on Wed Dec  4 14:23:24 2024
    ```
    </details>   

You may now *proceed to the next lab*. Return to *lab 5* if you didn't finish it.

## Acknowledgements

* **Author** - Daniel Overby Hansen
* **Contributors** - Rodrigo Jorge, Mike Dietrich
* **Last Updated By/Date** - Daniel Overby Hansen, January 2025