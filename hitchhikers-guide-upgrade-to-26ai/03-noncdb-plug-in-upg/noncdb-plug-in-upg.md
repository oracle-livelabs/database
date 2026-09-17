# Upgrade Non-CDB Using Plug-In

## Introduction

In this lab, you will upgrade a non-CDB and convert it to a pluggable database (PDB). You will plug it into an existing CDB and reuse the data files. This approach completes the upgrade faster, but you must consider your fallback options carefully.

Estimated Time: 35 minutes

### Objectives

In this lab, you will:

* Upgrade a non-CDB and convert it to a PDB
* Plug it into an existing CDB
* Reuse existing data files
* Install an Oracle home

### Prerequisites

None.

## Task 1: Prepare for Upgrade

You can plug in to an existing CDB on the same machine. AutoUpgrade handles the entire process. You start by checking the source database for upgrade readiness.

1. Use the *yellow* 🟨 terminal. For this lab, you will use a precreated config file. Examine the precreated config file.

    ``` bash
    <copy>
    cat /home/oracle/scripts/upg-plugin-upgr.cfg
    </copy>
    ```

    * `sid` specifies the source non-CDB.
    * `target_cdb` is the CDB into which you want to plug in.
    * `timezone_upg` instructs AutoUpgrade to skip the upgrade of the timezone file to save time. You can upgrade it later.
    * `run_dictionary_health` executes a dictionary check. This checks for corruptions in the data dictionary.
    
    <details>
    <summary>*click to see the output*</summary>

    ``` text
    global.global_log_dir=/home/oracle/logs/upg-plugin-upgr
    upg1.source_home=/u01/app/oracle/product/19
    upg1.target_home=/u01/app/oracle/product/26
    upg1.sid=UPGR
    upg1.target_cdb=CDB26
    upg1.timezone_upg=NO
    upg1.run_dictionary_health=critical
    ```

    </details>

2. Start AutoUpgrade in *analyze* mode. The check usually completes very quickly. Wait for it to complete.

    ``` bash
    <copy>
    java -jar autoupgrade.jar -config /home/oracle/scripts/upg-plugin-upgr.cfg -mode analyze
    </copy>
    ```

    * You can use the `lsj` command to get details.

3. When AutoUpgrade completes, it prints the path to the summary report. Check the summary report.

    ``` bash
    <copy>
    cat /home/oracle/logs/upg-plugin-upgr/cfgtoollogs/upgrade/auto/status/status.log
    </copy>
    ```

    * The report states *Check passed and no manual intervention needed*.
    * The *Details* section contains a reference to a detailed report. You will check this later.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    ==========================================
              Autoupgrade Summary Report
    ==========================================
    [Date]           Mon Aug 10 17:22:49 GMT 2026
    [Number of Jobs] 1
    ==========================================
    [Job ID] 100
    ==========================================
    [DB Name]                upgr
    [Version Before Upgrade] 19.31.0.0.0
    [Version After Upgrade]  23.26.3.0.0
    ------------------------------------------
    [Stage Name]    PRECHECKS
    [Status]        SUCCESS
    [Start Time]    2026-08-10 17:22:34
    [Duration]      0:00:15
    [Log Directory] /home/oracle/logs/upg-plugin-upgr/UPGR/100/prechecks
    [Detail]        /home/oracle/logs/upg-plugin-upgr/UPGR/100/prechecks/upgr_preupgrade.log
                    Check passed and no manual intervention needed
    ------------------------------------------
    ```

    </details>

## Task 2: Upgrade and Convert

Inside your maintenance window, you start AutoUpgrade to perform the upgrade and conversion to a PDB.

1. Use the *yellow* 🟨 terminal. Start AutoUpgrade in *deploy* mode.

    ``` bash
    <copy>
    java -jar autoupgrade.jar -config /home/oracle/scripts/upg-plugin-upgr.cfg -mode deploy
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    Processing config file ...
    +--------------------------------+
    | Starting AutoUpgrade execution |
    +--------------------------------+
    1 Non-CDB(s) will be processed
    Type 'help' to list console commands
    upg>
    ```

    </details>

2. Monitor the upgrade. Use the `status` command.

    ``` bash
    <copy>
    status -job 101 -a 10
    </copy>
    ```

    * AutoUpgrade now upgrades the database.

3. Leave the upgrade running. Do not exit AutoUpgrade. 

## Task 3: Further Information

1. In this lab, you instruct AutoUpgrade to reuse the data files. 
    * After shutting down the non-CDB, AutoUpgrade creates the PDB and points to the existing data files. 
    * This is faster but you must consider your rollback options. If something goes wrong during the upgrade or conversion to a PDB, you cannot use Flashback Database to reverse the PDB conversion. It can't undo the PDB conversion. 
    * You must have other rollback options, such as RMAN backups or storage snapshots.

2. An alternative approach is to copy the data files during the plug-in. 
    * This creates a copy of the data files and thus preserves the source non-CDB in case you must roll back. 
    * However, it takes time and requires additional disk space to copy the data files.
    * f you want to copy the data files during the plug-in, use the config file parameter `target_pdb_copy_option`. If you use OMF or ASM, specify the following:

    ``` bash
    upg1.target_pdb_copy_option=file_name_convert=none
    ```

## Task 4: Install Oracle Home

While the upgrade continues, you use AutoUpgrade to install an Oracle home. The Oracle home is not used in this lab, but the task is for educational purposes while the upgrade completes. 

1. Switch to the *blue* 🟦 terminal. Examine the following config file:

    ``` bash
    <copy>
    cat /home/oracle/scripts/upg-plugin-install-home.cfg
    </copy>
    ```

    * AutoUpgrade creates a new Oracle home in the `target_home` location.
    * It copies the settings (language, groups, options, etc.) from the `source_home`. 
    * AutoUpgrade also installs the recommended patches specified by the `patch` parameter.
    * The `RECOMMENDED` keyword gives you the latest Release Update, latest OPatch, latest MRP and Data Pump bundle patch. 
    * The target must be a 26ai Oracle home.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    global.global_log_dir=/home/oracle/logs/upg-plugin-install-home
    upg1.source_home=/u01/app/oracle/product/19
    upg1.target_home=/u01/app/oracle/product/dbhome_263
    upg1.download_folder=/home/oracle/patch-repo
    upg1.patch=RECOMMENDED
    upg1.target_version=26    
    ```

    </details>

2. Start AutoUpgrade to create the Oracle home.

    ``` bash
    <copy>
    java -jar autoupgrade.jar -config /home/oracle/scripts/upg-plugin-install-home.cfg -mode create_home -patch
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    Processing config file ...

    +-----------------------------------------+
    | Starting AutoUpgrade Patching execution |
    +-----------------------------------------+
    Type 'help' to list console commands
    patch>
    ```

    </details>

3. The installation of an Oracle home is much faster with Oracle AI Database 26ai. 
    * Oracle provides fully updated gold images that you can extract and install directly. 
    * OPatch is already updated, and the gold image comes with an updated OCW component and the latest JDK updates.

4. When you upgrade, you need an Oracle home on the new release. 
    * Most likely, you want the new Oracle home to look exactly like the old Oracle home, but on the new release. 
    * AutoUpgrade makes this very easy. You just specify the source Oracle home, and it will copy all the settings, like language, OS groups and other options. 

5. In this lab, the gold images and patches have already been downloaded. 
    * You can also use AutoUpgrade to download patches from My Oracle Support. 
    * Instead of manually finding and downloading the patches, you just create a simple config file and AutoUpgrade downloads the patches for you.
    * Due to security reasons, downloading of patches is not possible in this workshop.

6. Wait for AutoUpgrade to complete the installation. It should only take a few minutes.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    patch> Job 100 completed
    ------------------- Final Summary --------------------
    Number of databases            [ 1 ]

    Jobs finished                  [1]
    Jobs failed                    [0]
    Jobs restored                  [0]
    Jobs pending                   [0]

    Please check the summary report at:
    /home/oracle/logs/upg-plugin-install-home/cfgtoollogs/patch/auto/status/status.html
    /home/oracle/logs/upg-plugin-install-home/cfgtoollogs/patch/auto/status/status.log    
    ```

    </details>

7. AutoUpgrade informs you that you must run the root script. In this lab, you do not have root access, so you skip this step.
    * If the *oracle* user has sudo privileges, AutoUpgrade automatically executes the script for you.

8. Check the new Oracle home.

    ``` bash
    <copy>
    export ORACLE_HOME=/u01/app/oracle/product/dbhome_263
    /u01/app/oracle/product/dbhome_263/OPatch/opatch lspatches
    </copy>

    # Be sure to press RETURN
    ```

    * This is a 26.3 Oracle home installed via a gold image.
    * It includes the OCW Release Update, which is mandatory for Oracle Restart and Oracle RAC.
    * It also includes the Data Pump bundle patch.
    * AutoUpgrade also installed the *Monthly Recommended Patches* (MRP). The MRP doesn't show up as one patch in the inventory. Rather you see all the individual patches.
    * If a patch description starts with *Fix for Bug*, it is most likely a security bug fix.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    39788260;Fix for Bug 39788260
    39779540;39779540:Fix for Bug 39779540
    39779336;Fix for Bug 39779336
    39739695;Fix for Bug 39739695
    39661089;Fix for Bug 39661089
    39593097;DATAPUMP BUNDLE PATCH 23.26.3.0.0
    39578859;OCW RELEASE UPDATE 23.26.3.0.0 (39578859) Gold Image
    39578879;Database Release Update : 23.26.3.0.0 (39578879) Gold Image

    OPatch succeeded.    
    ```

    </details>

9. AutoUpgrade greatly simplifies the installation of a new Oracle home.

## Task 5: Examine the Preupgrade Report

While the upgrade continues (check on it if you want), you take a closer look at the preupgrade report.

1. Stay in the blue 🟦 terminal. Ealier in the lab, you examined the preupgrade summary report. It references a more detailed preupgrade report. Examine the preupgrade report:
    
    ``` bash
    <copy>
    more /home/oracle/logs/upg-plugin-upgr/UPGR/100/prechecks/upgr_preupgrade.log
    </copy>
    ```

    * In the previous lab, you saw an HTML version of a preupgrade report. Now, you look at the text version.
    * Scroll through the report using the *SPACEBAR*. 
    * First, you see details about the database.
    * Next, the preupgrade findings are grouped into *before upgrade* and *after upgrade*.
    * Within the groups the individual findings are grouped by severity. 
    * Notice how many findings have *FixUp Available Yes*. AutoUpgrade clears these findings for you automatically. 

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    Upgrade-To version: 23.0.0.0.0

    =======================================
    Status of the database prior to upgrade
    =======================================
          Database Name:  UPGR
         Container Name:  UPGR
           Container ID:  0
                Version:  19.31.0.0.0
         DB Patch Level:  UNKNOWN
             Compatible:  19.0.0
              Blocksize:  8192
               Platform:  Linux x86 64-bit
          Timezone File:  44
      Database log mode:  ARCHIVELOG
               Readonly:  false
                Edition:  EE

      Oracle Component                       Upgrade Action    Current Status
      ----------------                       --------------    --------------
      Oracle Server                          [to be upgraded]  VALID
      Oracle Workspace Manager               [to be upgraded]  VALID
      Real Application Clusters              [to be upgraded]  OPTION OFF
      Oracle XML Database                    [to be upgraded]  VALID

      *
      * ALL Components in This Database Registry:
      *
      Component   Current      Current      Original     Previous     Component
      CID         Version      Status       Version      Version      Schema
      ----------  -----------  -----------  -----------  -----------  ------------
      CATALOG     19.31.0.0.0  VALID        19.29.0.0.0               SYS
      CATPROC     19.31.0.0.0  VALID        19.29.0.0.0               SYS
      OWM         19.31.0.0.0  VALID        19.29.0.0.0               WMSYS
      RAC         19.31.0.0.0  OPTION OFF   19.29.0.0.0               SYS
      XDB         19.31.0.0.0  VALID        19.29.0.0.0               XDB

    ==============
    BEFORE UPGRADE
    ==============

      REQUIRED ACTIONS
      ================
      1.
            CheckName                                     FixUp Available
            PURGE_RECYCLEBIN                              YES

            Severity                                      Stage
            ERROR                                         PRECHECKS

          (AUTOFIXUP) Empty the RECYCLEBIN immediately before database upgrade.

          The recycle bin must be completely empty before database upgrade.

          The database contains 1 objects in the recycle bin.

      RECOMMENDED ACTIONS
      ===================
      2.
            CheckName                                     FixUp Available
            UNIFIED_AUDIT_ON                              NO

            Severity                                      Stage
            WARNING                                       PRECHECKS

          Convert your traditional audit configurations to unified audit policies
          and enable them. To continue using traditional audit in 23, make sure
          initialization parameters AUDIT_TRAIL and AUDIT_SYS_OPERATIONS are set in
          the database after the upgrade process. This is intended as a temporary
          measure until you have time to convert to unified audit. Refer to MOS
          note 2909718.1 for more details on converting to unified audit.

          Starting in 23, Oracle unified audit is the auditing configuration for
          use in newly created databases. Support for traditional audit in 23 is
          limited to upgraded databases. On database upgrades, existent traditional
          audit settings are operational post upgrade for continued generation of
          audit records to the traditional audit trails. However, new traditional
          audit configurations cannot be created. Oracle strongly recommends to
          start using unified audit at the earliest opportunity.

          Traditional audit configuration is found in this database.

      3.
            CheckName                                     FixUp Available
            TARGET_CDB_COMPATIBILITY_WARNINGS             NO

            Severity                                      Stage
            WARNING                                       PRECHECKS

          Review each warning violation reported and take action as needed. Note
          that when AutoUpgrade is run in deploy mode, AutoUpgrade will proceed
          regardless of the presence of any un-resolved warning violations in
          PDB_PLUG_IN_VIOLATIONS.

          Before plugging in database UPGR as a PDB of CDB CDB26, all violations in
          the PDB_PLUG_IN_VIOLATIONS view with type='WARNING' should be reviewed
          for their potential impact.

          The following plugin violations with type='WARNING' are found:
          UPGR 1 WARNING PENDING CDB parameter sga_target mismatch: Previous 956M
          Current 4G Please check the parameter in the current CDB
          UPGR 1 WARNING PENDING CDB parameter compatible mismatch: Previous
          '19.0.0' Current '23.0.0' Please check the parameter in the current CDB
          UPGR 1 WARNING PENDING Downgrade will not be allowed after plugin as
          compatible parameter of the PDB (19.0.0) is lower than the compatible
          parameter of the current CDB (23.0.0).
          UPGR 1 WARNING PENDING CDB parameter pga_aggregate_target mismatch:
          Previous 100M Current 1G Please check the parameter in the current CDB
          UPGR 1 WARNING PENDING Oracle opatch mismatch: opatch 38906621 is missing
          in the CDB. Install the Oracle opatch in the CDB.
          UPGR 1 WARNING PENDING Oracle opatch mismatch: opatch 39034528 is missing
          in the CDB. Install the Oracle opatch in the CDB.
          UPGR 1 WARNING PENDING Oracle opatch mismatch: opatch 29585399 is missing
          in the CDB. Install the Oracle opatch in the CDB.

      4.
            CheckName                                     FixUp Available
            DICTIONARY_STATS                              YES

            Severity                                      Stage
            RECOMMEND                                     PRECHECKS

          (AUTOFIXUP) Gather stale data dictionary statistics prior to database
          upgrade in off-peak time using:

            EXECUTE DBMS_STATS.GATHER_DICTIONARY_STATS;

          Dictionary statistics help the Oracle optimizer find efficient SQL
          execution plans and are essential for proper upgrade timing. Oracle
          recommends gathering dictionary statistics in the last 24 hours before
          database upgrade.

          For information on managing optimizer statistics, refer to the 19.0.0.0
          Oracle Database Upgrade Guide.

          Dictionary statistics do not exist or are stale (not up-to-date).

      INFORMATION ONLY
      ================
      5.
            CheckName                                     FixUp Available
            PARAMETER_DEPRECATED                          NO

            Severity                                      Stage
            INFO                                          PRECHECKS

          Consider removing the following deprecated initialization parameters.

          These deprecated parameters probably will be obsolete in a future release.

          Deprecated Parameter
          --------------------
          Parameter
          audit_file_dest
          audit_trail

      6.
            CheckName                                     FixUp Available
            MANDATORY_UPGRADE_CHANGES                     YES

            Severity                                      Stage
            INFO                                          PRECHECKS

          (AUTOFIXUP) Mandatory changes are applied automatically in the
          during_upgrade_pfile_dbname.ora file. Some of these changes maybe present
          in the after_upgrade_pfile_dbname.ora file. The
          during_upgrade_pfile_dbname.ora is used to start the database in upgrade
          mode. The after_upgrade_pfile_dbname.ora is used to start the database
          once the upgrade has completed successfully.

          Mandatory changes are required to perform the upgrade. These changes are
          implemented in the during_ and after_upgrade_pfile_dbname.ora files.

          Parameter
          ---------
          Parameter
          cluster_database=FALSE

      7.
            CheckName                                     FixUp Available
            DATAPATCH_TIMEOUT_SETTINGS                    YES

            Severity                                      Stage
            INFO                                          PRECHECKS

          (AUTOFIXUP) Timeout changes are applied automatically in the
          during_upgrade_pfile_dbname.ora file. The during_upgrade_pfile_dbname.ora
          is used to start the database in upgrade mode.

          Parameter _xt_preproc_timeout controls the timeout threshold when reading
          the Oracle inventory. Setting a timeout value that is not too small can
          enable Datapatch to read the Oracle inventory successfully within that
          timeframe.

          Parameter
          ---------
          Parameter
          _xt_preproc_timeout=300

      8.
            CheckName                                     FixUp Available
            RMAN_RECOVERY_VERSION                         NO

            Severity                                      Stage
            INFO                                          PRECHECKS

          Check the Oracle Backup and Recovery User's Guide for information on how
          to manage an RMAN recovery catalog schema.

          It is good practice to have the catalog schema the same or higher version
          than the RMAN client version you are using.

          If you are using a version of the recovery catalog schema that is older
          than that required by the RMAN client version, then you must upgrade the
          catalog schema.

      9.
            CheckName                                     FixUp Available
            TABLESPACES_INFO                              NO

            Severity                                      Stage
            INFO                                          PRECHECKS

          To help you keep track of your tablespace allocations, the following
          AUTOEXTEND tablespaces are expected to successfully EXTEND during the
          upgrade process.

          Minimum tablespace sizes for upgrade are estimates.

                                                     Min Size
          Tablespace                        Size     For Upgrade
          ----------                     ----------  -----------
          Tablespace Name                 Allocated  Minimum Req
                                                     uired for U
                                                          pgrade
          SYSTEM                            1160 MB      1400 MB

      10.
            CheckName                                     FixUp Available
            COMPONENT_INFO                                NO

            Severity                                      Stage
            INFO                                          PRECHECKS

          Here are ALL the components in this database registry:

          Review the information before upgrading.

          Component Current     Current     Original    Previous    Component
          CID       Version     Status      Version     Version     Schema
          --------- ----------- ----------- ----------- ----------- -----------
          Component Current Ver Current Sta Original Ve Previous Ve Component S
           CID      sion        tus         rsion       rsion       chema
          CATALOG   19.31.0.0.0 VALID       19.29.0.0.0             SYS
          CATPROC   19.31.0.0.0 VALID       19.29.0.0.0             SYS
          OWM       19.31.0.0.0 VALID       19.29.0.0.0             WMSYS
          RAC       19.31.0.0.0 OPTION OFF  19.29.0.0.0             SYS
          XDB       19.31.0.0.0 VALID       19.29.0.0.0             XDB

      11.
            CheckName                                     FixUp Available
            INVALID_ORA_OBJ_INFO                          NO

            Severity                                      Stage
            INFO                                          PRECHECKS

          Here is a count of invalid objects by Oracle-maintained users:

          Review the information before upgrading.

          Oracle-Maintained User Name                 Number of INVALID Objects
          ---------------------------                 -------------------------
          Oracle-Maintained User Name                 Number of INVALID Objects
          None                                        None

      12.
            CheckName                                     FixUp Available
            INVALID_APP_OBJ_INFO                          NO

            Severity                                      Stage
            INFO                                          PRECHECKS

          Here is a count of invalid objects by Application users:

          Review the information before upgrading.

          Application User Name                       Number of INVALID Objects
          ---------------------------                 -------------------------
          Application User Name                       Number of INVALID Objects
          None                                        None

      13.
            CheckName                                     FixUp Available
            DICTIONARY_HEALTH                             NO

            Severity                                      Stage
            INFO                                          PRECHECKS

          The generated Oracle Dictionary Health Check report is located in
          /home/oracle/logs/upg-plugin-upgr/UPGR/100/prechecks/upgr_healthcheck_resu
          lt.log. For manual fixup details, refer to the MOS note listed next to
          the check that did not pass.

          Oracle Dictionary Health Check (DBMS_DICTIONARY_CHECK) helps to identify
          database dictionary inconsistencies that are manifested in unexpected
          entries in RDBMS dictionary tables or in invalid references between
          dictionary tables. Database dictionary inconsistencies can cause process
          failures and, in some cases, instance crashes. Such inconsistencies may
          be exposed to internal ORA-00600 errors. DBMS_DICTIONARY_CHECK assists
          you in identifying such inconsistencies and in some cases provides guide
          remediation.

          Oracle Dictionary Health Check finds 0 potential problem(s), 0
          warning(s), and 0 CRITICAL problem(s) needing attention.

      14.
            CheckName                                     FixUp Available
            EM_EXPRESS_PRESENT                            NO

            Severity                                      Stage
            INFO                                          PRECHECKS

          No action needed. Enterprise Manager Database Express will be removed by
          the upgrade process.

          Starting with Oracle Database 23, Enterprise Manager Database Express is
          de-supported. Any EM Express specific files and objects will removed from
          your database during the upgrade. EM Express ports will no longer be
          opened to accept any HTTP request. Roles EM_EXPRESS_BASIC and
          EM_EXPRESS_ALL as well as "EM Express Connect" privilege will be removed.
          If user is to downgrade to a release earlier than 23, EM Express will be
          restored, including all of its files and objects, as well as the
          EM_EXPRESS_BASIC and EM_EXPRESS_ALL roles and "EM Express Connect"
          privilege. However, any specific non out-of-box user grants and audit
          policies of these roles and privilege will not be restored upon downgrade.

          Enterprise Manager Database Express is present. The database has EM
          Express files and objects.

    =============
    AFTER UPGRADE
    =============

      REQUIRED ACTIONS
      ================
      None

      RECOMMENDED ACTIONS
      ===================
      15.
            CheckName                                     FixUp Available
            TIMESTAMP_MISMATCH                            YES

            Severity                                      Stage
            WARNING                                       POSTCHECKS

          (AUTOFIXUP) Recompile the objects with timestamp mismatch. Refer to MOS
          note 781959.1 for more details.

          Timestamp of dependent objects must coincide with the timestamp of parent
          objects.

          There are objects whose timestamp are mismatched with its parent objects.

      16.
            CheckName                                     FixUp Available
            POST_DICTIONARY                               YES

            Severity                                      Stage
            RECOMMEND                                     POSTCHECKS

          (AUTOFIXUP) Gather dictionary statistics after the upgrade using the
          command:

            EXECUTE DBMS_STATS.GATHER_DICTIONARY_STATS;

          Dictionary statistics provide essential information to the Oracle
          optimizer to help it find efficient SQL execution plans. After a database
          upgrade, statistics need to be re-gathered as there can now be tables
          that have significantly changed during the upgrade or new tables that do
          not have statistics gathered yet.

          Oracle recommends gathering dictionary statistics after upgrade.


      17.
            CheckName                                     FixUp Available
            POST_FIXED_OBJECTS                            NO

            Severity                                      Stage
            RECOMMEND                                     POSTCHECKS

          Gather statistics on fixed objects after the upgrade and when there is a
          representative workload on the system using the command:

            EXECUTE DBMS_STATS.GATHER_FIXED_OBJECTS_STATS;

          Fixed object statistics provide essential information to the Oracle
          optimizer to help it find efficient SQL execution plans. Those statistics
          are specific to the Oracle Database release that generates them, and can
          be stale upon database upgrade.

          For information on managing optimizer statistics, refer to the 19.0.0.0
          Oracle Database Upgrade Guide.

          Oracle recommends gathering fixed object statistics after upgrade. This
          recommendation is given for all preupgrade runs.

      18.
            CheckName                                     FixUp Available
            POST_RECOMPILE                                YES

            Severity                                      Stage
            RECOMMEND                                     POSTCHECKS

          (AUTOFIXUP) To recompile invalid objects manually in ALL schemas, use
          $ORACLE_HOME/rdbms/admin/utlrp.sql

          Invalid database objects need to be recompiled after a database is
          upgraded. Note that starting with Release 12.2.0.1 and later, AutoUpgrade
          recompiles only invalid objects in Oracle-maintained schemas and defers
          recompilation of invalid application objects post upgrade to users.

          There are 0 invalid objects in Oracle-maintained schemas and 0 invalid
          objects in application schemas after upgrade.
    ```

## Task 6: Complete Upgrade

1. Switch back to the *yellow* 🟨 terminal. Wait for the upgrade to complete.

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
    /home/oracle/logs/upg-plugin-upgr/cfgtoollogs/upgrade/auto/status/status.html
    /home/oracle/logs/upg-plugin-upgr/cfgtoollogs/upgrade/auto/status/status.log    
    ```

    </details>

2. Set the environment to the *CDB26* database and connect.

    ``` bash
    <copy>
    . cdb26
    sql / as sysdba
    </copy>
    ```

3. Check the new PDB.

    ``` bash
    <copy>
    select open_mode, restricted from v$pdbs where name='UPGR';
    </copy>
    ```

    * *UPGR* is now a PDB and is open *read write*.
    * The PDB is also open in *unrestricted* mode indicating all went fine.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    OPEN_MODE     RESTRICTED
    _____________ _____________
    READ WRITE    NO
    ```

    </details>

4. Check the version.

    ``` bash
    <copy>
    alter session set container=UPGR;
    select version_full from v$instance;
    </copy>

    # Be sure to press RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    VERSION_FULL
    _______________
    23.26.3.0.0    
    ```

    </details>

5. Exit SQLcl.

    ``` bash
    <copy>
    exit
    </copy>
    ```

**Congratulations!** You have now:

* Upgraded the *UPGR* database
* Converted it to a PDB
* Reused the data files for a faster upgrade

You may now [*proceed to the next lab*](#next).

## Learn More

Converting a database using the plug-in method is a straightforward approach to multitenant migration. You can reuse the data files for faster upgrades or copy the data files for better rollback options. AutoUpgrade supports both methods.

* Webinar, [Move to Oracle Database 23ai – Everything you need to know about Oracle Multitenant – Part 1](https://www.youtube.com/watch?v=k0wCWbp-htU&t=3411s)
* Slides, [Move to Oracle Database 23ai – Everything you need to know about Oracle Multitenant – Part 1](https://dohdatabase.com/wp-content/uploads/2024/05/vc19_multitenant_part1.pdf)
* Blog post, [Upgrade Oracle Database 19c Non-CDB to 26ai and Convert to PDB](https://dohdatabase.com/2026/01/05/upgrade-oracle-database-19c-non-cdb-to-26ai-and-convert-to-pdb/)
* Blog post [The Easiest Way to Download 19.27 Release Update](https://dohdatabase.com/2025/04/16/the-easiest-way-to-download-19-27-release-update/)

## Acknowledgements

* **Author** - Daniel Overby Hansen
* **Contributors** - Rodrigo Jorge, Alex Zaballa, Mike Dietrich, Alejandro Diaz
* **Last Updated By/Date** - Daniel Overby Hansen, August 2026