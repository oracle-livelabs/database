# Upgrade Encrypted Non-CDB and Convert

## Introduction

This lab focuses on databases encrypted using Transparent Data Encryption (TDE). You will upgrade an encrypted non-CDB to Oracle Database 23ai and convert it to a PDB. This requires the database keystore passwords for the non-CDB and CDB. For this purpose, AutoUpgrade has its own keystore which you will use.

Estimated Time: 25 minutes

### Objectives

In this lab, you will:

* Use the AutoUpgrade keystore
* Use the summary report to check keystore password requirements
* Upgrade and convert an encrypted database

### Prerequisites

None.

This lab uses the *FTEX* and *CDB23* databases. It also encrypts both databases which have an effect on the other labs. We recommend that you perform this lab as the last one.

## Task 1: Encrypt source non-CDB

Currently, the *FTEX* database is not encrypted. You must start by preparing the database for encryption, and by encrypting an existing tablespace.

1. Create a directory to hold the database keystore.

    ``` bash
    <copy>
    mkdir -p /u01/app/oracle/admin/FTEX/wallet/tde
    </copy>
    ```

2. Set the environment to the *FTEX* database and connect.

    ``` sql
    <copy>
    . ftex
    sql / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

3. Configure the database to store its keystore in the directory you just created. It's a static parameter requiring a restart of the database.

    ``` sql
    <copy>
    alter system set wallet_root='/u01/app/oracle/admin/FTEX/wallet' scope=spfile;
    shutdown immediate
    startup
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> alter system set wallet_root='/u01/app/oracle/admin/FTEX/wallet' scope=spfile;

    System altered.

    SQL> shutdown immediate

    Database closed.
    Database dismounted.
    ORACLE instance shut down.

    SQL> startup

    ORACLE instance started.

    Total System Global Area 1157627144 bytes
    Fixed Size                  8924424 bytes
    Variable Size             419430400 bytes
    Database Buffers          721420288 bytes
    Redo Buffers                7852032 bytes

    Database mounted.
    Database opened.
    ```

    </details>

4. Configure the database to use a software keystore (in the directory specified in `WALLET_ROOT`).

    ``` sql
    <copy>
    alter system set tde_configuration='keystore_configuration=file' scope=both;
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> alter system set tde_configuration='keystore_configuration=file' scope=both;

    System altered.
    ```

    </details>

5. Create the keystore, open it, set a TDE master key and configure an auto-login keystore.

    ``` sql
    <copy>
    administer key management create keystore '/u01/app/oracle/admin/FTEX/wallet/tde' identified by "oracle_4U";
    administer key management set keystore open force keystore identified by "oracle_4U";
    administer key management set key identified by "oracle_4U" with backup;
    administer key management create local auto_login keystore from keystore '/u01/app/oracle/admin/FTEX/wallet/tde' identified by "oracle_4U";
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> administer key management create keystore '/u01/app/oracle/admin/FTEX/wallet/tde' identified by "oracle_4U";

    keystore altered.

    SQL> administer key management set keystore open force keystore identified by "oracle_4U";

    keystore altered.

    SQL> administer key management set key identified by "oracle_4U" with backup;

    keystore altered.

    SQL> administer key management create local auto_login keystore from keystore '/u01/app/oracle/admin/FTEX/wallet/tde' identified by "oracle_4U";

    keystore altered.
    ```

    </details>

6. Encrypt the *USERS* tablespace. It is an online operation.

    ``` sql
    <copy>
    alter tablespace users encryption encrypt;
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> alter tablespace users encryption encrypt;

    Tablespace altered.
    ```

    </details>

7. Verify that the *USERS* tablespace is encrypted.

    ``` sql
    <copy>
    select tablespace_name, encrypted from dba_tablespaces;
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> select tablespace_name, encrypted from dba_tablespaces;

    TABLESPACE_NAME                ENC
    ------------------------------ ---
    SYSTEM                          NO
    SYSAUX                          NO
    TEMP                            NO
    USERS                          YES
    UNDOTBS100                      NO
    ```

    </details>

8. Exit SQLcl.

    ``` sql
    <copy>
    exit
    </copy>
    ```

## Task 2: Encrypt target CDB

Currently, the *CDB23* database is not encrypted. You must start by preparing the database for encryption.

1. Create a directory to hold the database keystore.

    ``` bash
    <copy>
    mkdir -p /u01/app/oracle/admin/CDB23/wallet/tde
    </copy>
    ```

2. Set the environment to the *CDB23* database and connect.

    ``` sql
    <copy>
    . cdb23
    sql / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

3. Configure the database to store its keystore in the directory you just created. It's a static parameter requiring a restart of the database.

    ``` sql
    <copy>
    alter system set wallet_root='/u01/app/oracle/admin/CDB23/wallet' scope=spfile;
    shutdown immediate
    startup
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> alter system set wallet_root='/u01/app/oracle/admin/CDB23/wallet' scope=spfile;

    System altered.

    SQL> shutdown immediate

    Database closed.
    Database dismounted.
    ORACLE instance shut down.

    SQL> startup

    ORACLE instance started.

    Total System Global Area 4292413984 bytes
    Fixed Size                  5368352 bytes
    Variable Size            1157627904 bytes
    Database Buffers         3120562176 bytes
    Redo Buffers                8855552 bytes

    Database mounted.
    Database opened.
    ```

    </details>

4. Configure the database to use a software keystore (in the directory specified in `WALLET_ROOT`).

    ``` sql
    <copy>
    alter system set tde_configuration='keystore_configuration=file' scope=both;
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> alter system set tde_configuration='keystore_configuration=file' scope=both;

    System altered.
    ```

    </details>

5. Create the keystore, open it, set a TDE master key and configure an auto-login keystore.

    ``` sql
    <copy>
    administer key management create keystore '/u01/app/oracle/admin/CDB23/wallet/tde' identified by "oracle_4U";
    administer key management set keystore open force keystore identified by "oracle_4U";
    administer key management set key identified by "oracle_4U" with backup;
    administer key management create local auto_login keystore from keystore '/u01/app/oracle/admin/CDB23/wallet/tde' identified by "oracle_4U";
    </copy>

    -- Be sure to hit RETURN
    ```

    * You use the same keystore password in *CDB23* as well for simplicity. Realistically, you would choose different keystore passwords.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> administer key management create keystore '/u01/app/oracle/admin/CDB23/wallet/tde' identified by "oracle_4U";

    keystore altered.

    SQL> administer key management set keystore open force keystore identified by "oracle_4U";

    keystore altered.

    SQL> administer key management set key identified by "oracle_4U" with backup;

    keystore altered.

    SQL> administer key management create local auto_login keystore from keystore '/u01/app/oracle/admin/CDB23/wallet/tde' identified by "oracle_4U";

    keystore altered.
    ```

    </details>

6. Exit SQLcl.

    ``` sql
    <copy>
    exit
    </copy>
    ```

## Task 3: Analyze the database

Analyze the *FTEX* database for upgrade readiness.

1. To enable AutoUpgrade to work with encrypted databases, it must have access to a directory where it can store a special keystore just for AutoUpgrade.

    ``` bash
    <copy>
    mkdir -p /u01/app/oracle/keystore/autoupgrade
    </copy>
    ```

2. In this lab, you will use a pre-created AutoUpgrade config file. Examine the config file.

    ``` bash
    <copy>
    cat /home/oracle/scripts/upg-14-encrypted-db-upg-conv.cfg
    </copy>
    ```

    * The location for the AutoUpgrade keystore is defined by `global.keystore`.
    * `target_cdb` specified the CDB where you want to plug in the non-CDB specified by `sid`.
    * `target_pdb_name` renames the *FTEX* database on plug-in to *CYAN*.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    global.autoupg_log_dir=/home/oracle/logs/encrypted-db-upg-conv
    global.keystore=/u01/app/oracle/keystore/autoupgrade
    upg1.source_home=/u01/app/oracle/product/19
    upg1.target_home=/u01/app/oracle/product/23
    upg1.sid=FTEX
    upg1.target_cdb=CDB23
    upg1.target_pdb_name=CYAN
    upg1.timezone_upg=NO
    ```

    </details>

3. Start AutoUpgrade in analyze mode. Wait for it to complete.

    ``` bash
    <copy>
    java -jar autoupgrade.jar -config /home/oracle/scripts/upg-14-encrypted-db-upg-conv.cfg -mode analyze
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    AutoUpgrade 25.4.250730 launched with default internal options
    Processing config file ...
    +--------------------------------+
    | Starting AutoUpgrade execution |
    +--------------------------------+
    1 Non-CDB(s) will be analyzed
    Type 'help' to list console commands
    upg> Job 100 completed
    ------------------- Final Summary --------------------
    Number of databases            [ 1 ]

    Jobs finished                  [1]
    Jobs failed                    [0]

    Please check the summary report at:
    /home/oracle/logs/encrypted-db-upg-conv/cfgtoollogs/upgrade/auto/status/status.html
    /home/oracle/logs/encrypted-db-upg-conv/cfgtoollogs/upgrade/auto/status/status.log
    ```

    </details>

4. Check the *summary report*.

    ``` bash
    <copy>
    cat /home/oracle/logs/encrypted-db-upg-conv/cfgtoollogs/upgrade/auto/status/status.log
    </copy>
    ```

    * *PRECHECKS* has status *FAILURE*. The database is **not** ready for upgrade.
    * The check *TDE_PASSWORDS_REQUIRED* failed.
    * The check *TARGET_CDB_COMPATIBILITY* might fail as well, but you disregard that for now.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    ==========================================
              Autoupgrade Summary Report
    ==========================================
    [Date]           Fri May 31 05:05:37 GMT 2024
    [Number of Jobs] 1
    ==========================================
    [Job ID] 100
    ==========================================
    [DB Name]                FTEX
    [Version Before Upgrade] 19.27.0.0.0
    [Version After Upgrade]  23.9.0.25.07
    ------------------------------------------
    [Stage Name]    PRECHECKS
    [Status]        FAILURE
    [Start Time]    2024-05-31 05:05:31
    [Duration]
    [Log Directory] /home/oracle/logs/encrypted-db-upg-conv/FTEX/100/prechecks
    [Detail]        /home/oracle/logs/encrypted-db-upg-conv/FTEX/100/prechecks/ftex_preupgrade.log
                    Check failed for FTEX, manual intervention needed for the below checks
                    [TDE_PASSWORDS_REQUIRED]
    Cause:Check failed for FTEX, manual intervention needed for the below checks :     [AUDUNIFIED_LOB_TYPE HIDDEN_PARAMS INVALID_OBJECTS_EXIST POST_DICTIONARY POST_FIXED_OBJECTS     OLD_TIME_ZONES_EXIST PARAMETER_DEPRECATED MIN_RECOVERY_AREA_SIZE MANDATORY_UPGRADE_CHANGES     DATAPATCH_TIMEOUT_SETTINGS RMAN_RECOVERY_VERSION TABLESPACES_INFO TIMESTAMP_MISMATCH POST_UTLRP     COMPONENT_INFO INVALID_ORA_OBJ_INFO INVALID_APP_OBJ_INFO TDE_PASSWORDS_REQUIRED     PARAM_VALUES_IN_MEM_ONLY EM_EXPRESS_PRESENT TARGET_CDB_COMPATIBILITY_WARNINGS ]
    Reason:Database Checks has Failed details in /home/oracle/logs/encrypted-db-upg-conv/FTEX/100/    prechecks
    Action:[MANUAL]
    Info:Return status is ERROR
    ExecutionError:No
    Error Message:The following checks have ERROR severity and no fixup is available or
    the fixup failed to resolve the issue. Fix them manually before continuing:
    FTEX TDE_PASSWORDS_REQUIRED

    ------------------------------------------
    ```

    </details>

5. You find additional details in the preupgrade log file. There is a *required action* that you must do before the upgrade.

    * You must load the database keystore password into the AutoUpgrade keystore for the databases *FTEX* and *CDB23*.
    * AutoUpgrade must have access to keystore password to complete the process.
    * Optionally, you can check the entire preupgrade log file. It is in `/home/oracle/logs/encrypted-db-upg-conv/FTEX/100/prechecks/ftex_preupgrade.log`.

    ``` text
    (output truncated)

    ==============
    BEFORE UPGRADE
    ==============

      REQUIRED ACTIONS
      ================
      1.  Perform the specified action for each database in order to satisfy
          AutoUpgrade's TDE keystore requirements. This will involve adding the TDE
          keystore password for the database into either AutoUpgrade's keystore
          using the -load_password command line option or into a Secure External
          Password Store (SEPS) for the database. Once the upgrade has finished and
          there is no intention to use AutoUpgrade's system restore functionality
          to rerun the upgrade, the AutoUpgrade keystore file(s) can be removed
          from the directory or path referenced by the global.keystore
          configuration parameter.

          At this point, either (1) the TDE keystore password(s) required by
          AutoUpgrade have not been loaded into AutoUpgrade's keystore or a Secure
          External Password Store or (2) the auto-login keystore status of the
          database has not been modified. Review the required actions for each of
          the following databases:

          ORACLE_SID                      Action Required
          ------------------------------  ----------------------------------------
          CDB23                           Add TDE password
          FTEX                            Add TDE password

          For AutoUpgrade to upgrade a database using Oracle Transparent Data
          Encryption (TDE), the following conditions must be met:

          1. The TDE keystore password(s) required by AutoUpgrade must be loaded
          into AutoUpgrade's keystore or a Secure External Password Store for the
          database.

          When the source database uses TDE, AutoUpgrade requires TDE passwords for
          the databases listed below:
          * Both the source non-CDB and the target CDB of a non-CDB to PDB operation
          * Both the source CDB and the target CDB of an unplug-plug operation
          * Only the target CDB of an unplug-relocate operation

          2. The target CDB, if specified, must have an auto-login TDE keystore if
          its version is earlier than Oracle Database 19.11

          3. To upgrade a non-CDB or an entire CDB, the TDE keystore must be an
          auto-login keystore. This requirement also applies to a non-CDB to PDB
          operation, but only if the target CDB is at an Oracle Database Release
          earlier than 21c. If earlier than 21c, AutoUpgrade performs a standard
          upgrade of the non-CDB to the target version prior to creating the PDB in
          the target CDB.
    ```

6. Load the database keystore passwords into the AutoUpgrade keystore. Start the password loader.

    ``` bash
    <copy>
    java -jar autoupgrade.jar -config /home/oracle/scripts/upg-14-encrypted-db-upg-conv.cfg -load_password
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    Processing config file ...

    Starting AutoUpgrade Password Loader - Type help for available options
    Creating new AutoUpgrade keystore - Password required
    Enter password:
    ```

7. Since it is the first time you start the password loader, AutoUpgrade asks for a password to protect the AutoUpgrade keystore. This is not the database keystore password. Use the following AutoUpgrade keystore password: 

    ``` bash
    <copy>
    autoupgrade_4U
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    Enter password:
    Enter password again:
    AutoUpgrade keystore was successfully created

    TDE>
    ```

    </details>

7. Add the database keystore password for *FTEX*.

    ``` bash
    <copy>
    add FTEX
    </copy>
    ```

    Enter the *FTEX* database keystore password twice: 
    
    ``` bash
    <copy>
    oracle_4U
    </copy>
    ```    

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    TDE> add FTEX
    Enter your secret/Password:
    Re-enter your secret/Password:
    ```

    </details>

8. Add the database keystore password for *CDB23*.

    ``` bash
    <copy>
    add CDB23
    </copy>
    ```

    Enter the *CDB23* database keystore password twice:
    
    ``` bash
    <copy>
    oracle_4U
    </copy>
    ```
    
    <details>
    <summary>*click to see the output*</summary>

    ``` text
    TDE> add CDB23
    Enter your secret/Password:
    Re-enter your secret/Password:
    ```

    </details>

9. Save the AutoUpgrade keystore and convert it to an auto-login keystore.

    ``` bash
    <copy>
    save
    </copy>
    ```

    * Enter *YES* when prompted to convert to an auto-login keystore.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    TDE> save
    Convert the AutoUpgrade keystore to auto-login [YES|NO] ? YES
    ```

    </details>

10. Exit the AutoUpgrade password loader.

    ``` bash
    <copy>
    exit
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    TDE> exit

    AutoUpgrade Password Loader finished - Exiting AutoUpgrade
    ```

    </details>

11. Re-analyze the database for upgrade readiness. Now that you added the database keystore passwords to AutoUpgrade, you can re-analyze to see if that meets the requirements. It takes a short while. Wait for it to complete.

    ``` bash
    <copy>
    java -jar autoupgrade.jar -config /home/oracle/scripts/upg-14-encrypted-db-upg-conv.cfg -mode analyze
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    AutoUpgrade 25.4.250730 launched with default internal options
    Processing config file ...
    Loading AutoUpgrade keystore
    AutoUpgrade keystore was successfully loaded
    +--------------------------------+
    | Starting AutoUpgrade execution |
    +--------------------------------+
    1 Non-CDB(s) will be analyzed
    Type 'help' to list console commands
    upg> Job 101 completed
    ------------------- Final Summary --------------------
    Number of databases            [ 1 ]

    Jobs finished                  [1]
    Jobs failed                    [0]

    Please check the summary report at:
    /home/oracle/logs/encrypted-db-upg-conv/cfgtoollogs/upgrade/auto/status/status.html
    /home/oracle/logs/encrypted-db-upg-conv/cfgtoollogs/upgrade/auto/status/status.log
    ```

    </details>

12. Check the result in the summary report.

    ``` bash
    <copy>
    cat /home/oracle/logs/encrypted-db-upg-conv/cfgtoollogs/upgrade/auto/status/status.log
    </copy>
    ```

    * The *PRECHECKS* is now in status *SUCCESS*. The details states *Check passed and no manual intervention needed*.
    * You may now proceed with upgrading and converting the encrypted database.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    ==========================================
              Autoupgrade Summary Report
    ==========================================
    [Date]           Fri May 31 05:21:50 GMT 2024
    [Number of Jobs] 1
    ==========================================
    [Job ID] 101
    ==========================================
    [DB Name]                FTEX
    [Version Before Upgrade] 19.27.0.0.0
    [Version After Upgrade]  23.9.0.25.07
    ------------------------------------------
    [Stage Name]    PRECHECKS
    [Status]        SUCCESS
    [Start Time]    2024-05-31 05:21:45
    [Duration]
    [Log Directory] /home/oracle/logs/encrypted-db-upg-conv/FTEX/101/prechecks
    [Detail]        /home/oracle/logs/encrypted-db-upg-conv/FTEX/101/prechecks/ftex_preupgrade.log
                    Check passed and no manual intervention needed
    ------------------------------------------
    ```

    </details>

## Task 4: Upgrade and convert

All prerequisites have been meet. You can now start the upgrade and conversion.

1. Start AutoUpgrade in deploy. This starts the upgrade and conversion in one fully automated process.

    ``` bash
    <copy>
    java -jar autoupgrade.jar -config /home/oracle/scripts/upg-14-encrypted-db-upg-conv.cfg -mode deploy
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    AutoUpgrade 25.4.250730 launched with default internal options
    Processing config file ...
    Loading AutoUpgrade keystore
    AutoUpgrade keystore was successfully loaded
    +--------------------------------+
    | Starting AutoUpgrade execution |
    +--------------------------------+
    1 Non-CDB(s) will be processed
    Type 'help' to list console commands
    upg>
    ```

    </details>

2. Monitor the progress.

    ``` bash
    <copy>
    lsj -a 30
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    +----+-------+----------+---------+-------+----------+-------+-------+
    |Job#|DB_NAME|     STAGE|OPERATION| STATUS|START_TIME|UPDATED|MESSAGE|
    +----+-------+----------+---------+-------+----------+-------+-------+
    | 102|   FTEX|POSTFIXUPS|EXECUTING|RUNNING|  05:22:43| 9s ago|       |
    +----+-------+----------+---------+-------+----------+-------+-------+
    Total jobs 1

    The command lsj is running every 30 seconds. PRESS ENTER TO EXIT
    ```

    </details>

3. The upgrade and conversion takes 10-15 minutes. Leave the process running. In the end, AutoUpgrade prints *Job 102 completed* and exits.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    Job 102 completed
    ------------------- Final Summary --------------------
    Number of databases            [ 1 ]

    Jobs finished                  [1]
    Jobs failed                    [0]
    Jobs restored                  [0]
    Jobs pending                   [0]



    Please check the summary report at:
    /home/oracle/logs/encrypted-db-upg-conv/cfgtoollogs/upgrade/auto/status/status.html
    /home/oracle/logs/encrypted-db-upg-conv/cfgtoollogs/upgrade/auto/status/status.log
    ```

    </details>

4. Set the environment to *CDB23* and connect.

    ``` sql
    <copy>
    . cdb23
    sql / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

5. Ensure that the *FTEX* database has been plugged in and is open *READ WRITE* and unrestricted.

    ``` sql
    <copy>
    show pdbs
    </copy>
    ```

    * You renamed *FTEX* to *CYAN*.
    * You might see other PDBs from other labs. Focus on *CYAN*. 

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> show pdbs

        CON_ID CON_NAME                        OPEN MODE  RESTRICTED
    ---------- ------------------------------ ---------- ----------
        2 PDB$SEED                           READ ONLY  NO
        3 RED                                READ WRITE NO
        4 BLUE                               MOUNTED
        5 GREEN                              MOUNTED
        6 UPGR                               MOUNTED
        7 CYAN                               READ WRITE NO
    ```

    </details>

6. Switch to the *CYAN* PDB and ensure the *USERS* tablespace is still encrypted.

    ``` sql
    <copy>
    alter session set container=CYAN;
    select tablespace_name, encrypted from dba_tablespaces;
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> alter session set container=CYAN;

    Session altered.

    SQL> select tablespace_name, encrypted from dba_tablespaces;

    TABLESPACE_NAME                ENC
    ------------------------------ ---
    SYSTEM                         NO
    SYSAUX                         NO
    TEMP                           NO
    USERS                          YES
    UNDOTBS100                     NO
    ```

    </details>

7. Verify that the PDB is using a keystore.

    ``` sql
    <copy>
    select wrl_type, status, wallet_type, keystore_mode from v$encryption_wallet;
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> select wrl_type, status, wallet_type, keystore_mode from v$encryption_wallet;

    WRL_TYPE             STATUS     WALLET_TYPE          KEYSTORE
    -------------------- ---------- -------------------- --------
    FILE                 OPEN       PASSWORD             UNITED
    ```

    </details>

8. Exit SQLcl.

    ``` sql
    <copy>
    exit
    </copy>
    ```

**Congratulations!** You have now upgraded your encrypted database to Oracle Database 23ai.

You may now [*proceed to the next lab*](#next).

## Learn More

Since encrypted databases are becoming more popular, it's important to know how to deal with them. AutoUpgrade fully supports any scenario when the database is encrypted, and you can safely store database keystore passwords in AutoUpgrade's keystore.

For fully automated solutions, you should explore Secure External Password Stores which enables upgrades and migration of encrypted databases even without loading the password into AutoUpgrade's keystore.

* Documentation, [The keystore parameter](https://docs.oracle.com/en/database/oracle/oracle-database/23/upgrd/global-parameters-autoupgrade-config-file.html#GUID-B0D91A5E-F2A1-4714-8908-3C7F4C557EDD)
* Documentation, [Secure External Password Store](https://docs.oracle.com/en/database/oracle////oracle-database/23/refrn/EXTERNAL_KEYSTORE_CREDENTIAL_LOCATION.html#GUID-FD2C1839-E3CC-47E2-99B4-ECE29EB923B6)
* Webinar, [AutoUpgrade 2.0 – New Features and Best Practices](https://www.youtube.com/watch?v=69Hx1WoJ_HE&t=1148s)
* Slides, [AutoUpgrade 2.0 – New Features and Best Practices](https://dohdatabase.com/wp-content/uploads/2022/05/2022_05_05_emea14_autoupgrade_2_0-1.pdf)

## Acknowledgements

* **Author** - Daniel Overby Hansen
* **Contributors** - Klaus Gronau, Rodrigo Jorge, Alex Zaballa, Mike Dietrich
* **Last Updated By/Date** - Rodrigo Jorge, August 2025
