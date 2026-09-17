# Upgrade Encrypted PDB Using Unplug-Plug

## Introduction

This lab focuses on databases that use Transparent Data Encryption (TDE). You will upgrade an encrypted PDB. The upgrade requires access to the database keystore passwords. For this purpose, AutoUpgrade has its own keystore, which you will use to securely store the required passwords.

Estimated Time: 30 minutes

### Objectives

In this lab, you will:

* Upgrade an encrypted PDB *PLUM*.
* Unplug *PLUM* from 19c CDB, *CDB19ENC*, and plug in to 26ai CDB, *CDB26ENC*.
* Use the AutoUpgrade keystore.

### Prerequisites

None. 

## Task 1: Start Databases

1. Start a new terminal or use an existing one. You can use any terminal for this lab.

1. Set the environment to the 26ai target CDB, *CDB26ENC*, and connect.

    ``` bash
    <copy>
    . cdb26enc
    sql / as sysdba
    </copy>

    # Be sure to press RETURN
    ```

2. Start the database.

    ``` bash
    <copy>
    startup
    </copy>
    ```

    * If the database is already running, you get `ORA-01081: cannot start already-running ORACLE - shut it down first`. Ignore it and continue.

3. Exit SQLcl.

    ``` bash
    <copy>
    exit
    </copy>
    ```        

4. Set the environment to the 19c source CDB, *CDB19ENC*, and connect.

    ``` bash
    <copy>
    . cdb19enc
    sql / as sysdba
    </copy>

    # Be sure to press RETURN
    ```

5. Start the database.

    ``` bash
    <copy>
    startup
    </copy>
    ```

    * If the database is already running, you get `ORA-01081: cannot start already-running ORACLE - shut it down first`. Ignore it and continue.    


## Task 2: Encrypt PDB

The two CDBs, *CDB19ENC* and *CDB26ENC*, have already been configured for TDE.

1. Connect to the *PLUM* PDB, create an encryption key, and an encrypted tablespace.

    ``` bash
    <copy>
    alter session set container=PLUM;
    administer key management set key force keystore identified by "oracle_4U" with backup;
    create tablespace users datafile size 50m autoextend on next 50m encryption using 'AES256' encrypt;
    </copy>

    # Be sure to press RETURN
    ```

    * The PDB is configured to use a unified keystore. This is the default configuration.
    * You must use the CDB keystore password (`oracle_4U`) to create a new encryption key in the PDB.
    * The tablespace uses the AES256 encryption algorithm. This is a stronger algorithm than AES128, the default in Oracle Database 19c. 
    * In Oracle AI Database 26ai, the default changes to AES256 to meet modern security requirements.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> alter session set container=PLUM;

    Session altered.

    SQL> administer key management set key force keystore identified by "oracle_4U" with backup;

    Key MANAGEMENT succeeded.

    SQL> create tablespace users datafile size 50m autoextend on next 50m encryption using 'AES256' encrypt;

    Tablespace USERS created.
    ```

    </details>

2. Create a schema and sample data in the encrypted tablespace.

    ``` bash
    <copy>
    create user appuser no authentication;
    grant resource to appuser;
    alter user appuser quota unlimited on users;
    create table appuser.t1 
        tablespace users 
        as select systimestamp as ts, 'Hello' as msg from dual;    
    </copy>

    # Be sure to press RETURN
    ```

    * Notice the *NO AUTHENTICATION* clause on the `CREATE USER` statement.
    * No one can connect as this user. However, you can connect to the schema through another user using so-called proxy authentication.
    * This is useful for application schemas that should only hold data and not be used for connections.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> create user appuser no authentication;

    User APPUSER created.

    SQL> grant resource to appuser;

    Grant succeeded.

    SQL> alter user appuser quota unlimited on users;

    User APPUSER altered.

    SQL> create table appuser.t1
      2     tablespace users
      3*    as select systimestamp as ts, 'Hello' as msg from dual;

    Table APPUSER.T1 created.    
    ```

    </details>

3. Verify that the sample data is stored in the encrypted tablespace, *USERS*.

    ``` bash
    <copy>
    select tablespace_name, encrypted from dba_tablespaces;
    </copy>

    # Be sure to press RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
       TABLESPACE_NAME    ENCRYPTED
    __________________ ____________
    SYSTEM             NO
    SYSAUX             NO
    UNDOTBS1           NO
    TEMP               NO
    USERS              YES    
    ```

    </details>

4. Exit SQLcl.

    ``` bash
    <copy>
    exit
    </copy>
    ```    
## Task 3: Analyze the database

Analyze the *PLUM* PDB for upgrade readiness.

1. In this lab, you will use a precreated AutoUpgrade config file. Examine the config file.

    ``` bash
    <copy>
    cat /home/oracle/scripts/upg-plum.cfg
    </copy>
    ```

    * AutoUpgrade has its own keystore where it can store sensitive information, such as database keystore passwords.
    * The location for the AutoUpgrade keystore is defined by `global.keystore`. 
    * Do not confuse the AutoUpgrade keystore with the database keystore, which holds the tablespace encryption keys.
    * `sid` and `target_cdb` identify the source and target CDBs, respectively.
    * `pdbs` is the PDB to upgrade, or a comma-separated list of PDBs.
    * You want to plug in the PDB and reuse its data files, so you omit `target_pdb_copy_option`. 

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    global.global_log_dir=/home/oracle/logs/upg-plum
    global.keystore=/u01/app/oracle/keystore/autoupgrade/plum
    upg1.source_home=/u01/app/oracle/product/19
    upg1.target_home=/u01/app/oracle/product/26
    upg1.sid=CDB19ENC
    upg1.target_cdb=CDB26ENC
    upg1.pdbs=PLUM
    ```

    </details>

2. Start AutoUpgrade in analyze mode. Wait for it to complete.

    ``` bash
    <copy>
    java -jar autoupgrade.jar -config /home/oracle/scripts/upg-plum.cfg -mode analyze
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    Processing config file ...
    +--------------------------------+
    | Starting AutoUpgrade execution |
    +--------------------------------+
    1 PDB(s) will be analyzed
    Type 'help' to list console commands
    upg> Job 100 completed
    ------------------- Final Summary --------------------
    Number of databases            [ 1 ]

    Jobs finished                  [1]
    Jobs failed                    [0]

    Please check the summary report at:
    /home/oracle/logs/upg-plum/cfgtoollogs/upgrade/auto/status/status.html
    /home/oracle/logs/upg-plum/cfgtoollogs/upgrade/auto/status/status.log
    ```

    </details>

3. Check the *summary report*.

    ``` bash
    <copy>
    cat /home/oracle/logs/upg-plum/cfgtoollogs/upgrade/auto/status/status.log
    </copy>
    ```

    * *PRECHECKS* has the status *FAILURE*. The database is **not** ready for upgrade.
    * The check *TDE_PASSWORDS_REQUIRED* failed.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    ==========================================
              Autoupgrade Summary Report
    ==========================================
    [Date]           Fri Aug 14 10:37:21 GMT 2026
    [Number of Jobs] 1
    ==========================================
    [Job ID] 100
    ==========================================
    [DB Name]                cdb19enc
    [Version Before Upgrade] 19.31.0.0.0
    [Version After Upgrade]  23.26.3.0.0
    ------------------------------------------
    [Stage Name]    PRECHECKS
    [Status]        FAILURE
    [Start Time]    2026-08-14 10:37:13
    [Duration]      0:00:08
    [Log Directory] /home/oracle/logs/upg-plum/CDB19ENC/100/prechecks
    [Detail]        /home/oracle/logs/upg-plum/CDB19ENC/100/prechecks/cdb19enc_preupgrade.log
                    Check failed for PLUM, manual intervention needed for the below checks
                    [TDE_PASSWORDS_REQUIRED]
    Cause:The following checks have ERROR severity and no auto fixup is available or
    the fixup failed to resolve the issue. Fix them before continuing:
    PLUM TDE_PASSWORDS_REQUIRED
    Reason:Database Checks has Failed details in /home/oracle/logs/upg-plum/CDB19ENC/100/prechecks
    Action:[MANUAL]
    Info:Return status is ERROR
    ExecutionError:No
    Error Message:The following checks have ERROR severity and no auto fixup is available or
    the fixup failed to resolve the issue. Fix them before continuing:
    PLUM TDE_PASSWORDS_REQUIRED

    ------------------------------------------
    ```

    </details>

4. You find additional details in the preupgrade log file. There is a *required action* that you must do before the upgrade.

    * You must load the database keystore password for the databases *CDB19ENC* and *CDB26ENC* into the AutoUpgrade keystore.
    * AutoUpgrade must have access to the keystore passwords to complete the process.
    * Optionally, you can check the entire preupgrade log file. It is in `/home/oracle/logs/upg-plum/CDB19ENC/100/prechecks/cdb19enc_preupgrade.log`.

    ``` text
    (output truncated)

    ==============
    BEFORE UPGRADE
    ==============

      REQUIRED ACTIONS
      ================
      1.
            CheckName                                     FixUp Available
            TDE_PASSWORDS_REQUIRED                        NO

            Severity                                      Stage
            ERROR                                         PRECHECKS

          Perform the specified action for each database in order to satisfy
          AutoUpgrade's TDE keystore requirements. This will involve adding the TDE
          keystore password for the database into either AutoUpgrade's keystore
          using the -load_password command line option or into a Secure External
          Password Store (SEPS) for the database. Once the upgrade has finished and
          there is no intention to use AutoUpgrade's system restore functionality
          to rerun the upgrade, the AutoUpgrade keystore file(s) can be removed
          from the directory or path referenced by the global.keystore
          configuration parameter.

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

          At this point, either (1) the TDE keystore password(s) required by
          AutoUpgrade have not been loaded into AutoUpgrade's keystore or a Secure
          External Password Store or (2) the auto-login keystore status of the
          database has not been modified. Review the required actions for each of
          the following databases:

          ORACLE_SID                      Action Required
          ------------------------------  ----------------------------------------
          ORACLE_SID                      Action Required
          CDB19ENC                        Add TDE password
          CDB26ENC                        Add TDE password      
    ```

5. Load the database keystore passwords into the AutoUpgrade keystore. Start the password loader.

    ``` bash
    <copy>
    java -jar autoupgrade.jar -config /home/oracle/scripts/upg-plum.cfg -load_password
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

7. Because this is the first time you are starting the password loader, AutoUpgrade asks for a password to protect the AutoUpgrade keystore. This is not the database keystore password. Use the following AutoUpgrade keystore password twice:

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

8. Add the database keystore password for *CDB19ENC*.

    ``` bash
    <copy>
    add CDB19ENC
    </copy>
    ```

    Enter the *CDB19ENC* database keystore password twice:

    ``` bash
    <copy>
    oracle_4U
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    TDE> add CDB19ENC
    Enter your secret/Password:
    Re-enter your secret/Password:
    ```

    </details>

9. Add the database keystore password for *CDB26ENC*.

    ``` bash
    <copy>
    add CDB26ENC
    </copy>
    ```

    Enter the *CDB26ENC* database keystore password twice:

    ``` bash
    <copy>
    oracle_4U
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    TDE> add CDB26ENC
    Enter your secret/Password:
    Re-enter your secret/Password:
    ```

    </details>

10. Save the AutoUpgrade keystore and convert it to an auto-login keystore.

    ``` bash
    <copy>
    save
    </copy>
    ```

    * Enter *YES* when prompted to convert to an auto-login keystore.
    * An auto-login keystore works only on the system where it was created.
    * You could also enter *SHARED*. A shared auto-login keystore works on any system.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    TDE> save
    Select auto-login mode for the AutoUpgrade keystore [YES|NO|SHARED]: YES
    ```

    </details>

11. Exit the AutoUpgrade password loader.

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

12. Re-analyze the database for upgrade readiness. Now that you have added the database keystore passwords to the AutoUpgrade keystore, you can re-analyze the PDB to verify that it meets the requirements. The analysis takes a short while. Wait for it to complete.

    ``` bash
    <copy>
    java -jar autoupgrade.jar -config /home/oracle/scripts/upg-plum.cfg -mode analyze
    </copy>
    ```

    * Notice the console messages about the AutoUpgrade keystore.
    * Since you've created an AutoUpgrade keystore, AutoUpgrade now reads it on startup. 

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    Processing config file ...
    Loading AutoUpgrade keystore
    AutoUpgrade keystore is loaded
    +--------------------------------+
    | Starting AutoUpgrade execution |
    +--------------------------------+
    1 PDB(s) will be analyzed
    Type 'help' to list console commands
    upg> Job 101 completed
    ------------------- Final Summary --------------------
    Number of databases            [ 1 ]

    Jobs finished                  [1]
    Jobs failed                    [0]

    Please check the summary report at:
    /home/oracle/logs/upg-plum/cfgtoollogs/upgrade/auto/status/status.html
    /home/oracle/logs/upg-plum/cfgtoollogs/upgrade/auto/status/status.log
    ```

    </details>

13. Check the results in the summary report.

    ``` bash
    <copy>
    cat /home/oracle/logs/upg-plum/cfgtoollogs/upgrade/auto/status/status.log
    </copy>
    ```

    * *PRECHECKS* now has the status *SUCCESS*. The details state: *Check passed and no manual intervention needed*.
    * Oracle recommends that you examine the detailed preupgrade report, but to save time in this lab, you skip it.
    * You may now proceed with upgrading the encrypted PDB.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    ==========================================
              Autoupgrade Summary Report
    ==========================================
    [Date]           Fri Aug 14 11:04:53 GMT 2026
    [Number of Jobs] 1
    ==========================================
    [Job ID] 101
    ==========================================
    [DB Name]                cdb19enc
    [Version Before Upgrade] 19.31.0.0.0
    [Version After Upgrade]  23.26.3.0.0
    ------------------------------------------
    [Stage Name]    PRECHECKS
    [Status]        SUCCESS
    [Start Time]    2026-08-14 11:04:45
    [Duration]      0:00:08
    [Log Directory] /home/oracle/logs/upg-plum/CDB19ENC/101/prechecks
    [Detail]        /home/oracle/logs/upg-plum/CDB19ENC/101/prechecks/cdb19enc_preupgrade.log
                    Check passed and no manual intervention needed
    ------------------------------------------
    ```

    </details>

## Task 4: Upgrade 

All prerequisites have been met. You can now start the upgrade.

1. Start the upgrade using AutoUpgrade in deploy mode. 

    ``` bash
    <copy>
    java -jar autoupgrade.jar -config /home/oracle/scripts/upg-plum.cfg -mode deploy
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    Processing config file ...
    Loading AutoUpgrade keystore
    AutoUpgrade keystore is loaded
    +--------------------------------+
    | Starting AutoUpgrade execution |
    +--------------------------------+
    1 PDB(s) will be processed
    Type 'help' to list console commands
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
    | 102|   PLUM|POSTFIXUPS|EXECUTING|RUNNING|  05:22:43| 9s ago|       |
    +----+-------+----------+---------+-------+----------+-------+-------+
    Total jobs 1

    The command lsj is running every 30 seconds. PRESS ENTER TO EXIT
    ```

    </details>

3. The upgrade takes 10-15 minutes. Leave the process running. When the upgrade completes, AutoUpgrade displays *Job 102 completed* and exits.

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
    /home/oracle/logs/upg-plum/cfgtoollogs/upgrade/auto/status/status.html
    /home/oracle/logs/upg-plum/cfgtoollogs/upgrade/auto/status/status.log
    ```

    </details>

4. Set the environment to *CDB26ENC* and connect.

    ``` bash
    <copy>
    . cdb26enc
    sql / as sysdba
    </copy>
    ```

5. Ensure that the *PLUM* PDB has been plugged in and is open in *READ WRITE* mode and unrestricted.

    ``` bash
    <copy>
    show pdbs
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> show pdbs

        CON_ID CON_NAME                        OPEN MODE  RESTRICTED
    ---------- ------------------------------ ---------- ----------
        2 PDB$SEED                           READ ONLY  NO
        3 PLUM                               READ WRITE NO
    ```

    </details>

6. Switch to the *PLUM* PDB and ensure the *USERS* tablespace is still encrypted.

    ``` bash
    <copy>
    alter session set container=PLUM;
    select tablespace_name, encrypted from dba_tablespaces;
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> alter session set container=PLUM;

    Session altered.

    SQL> select tablespace_name, encrypted from dba_tablespaces;

    TABLESPACE_NAME                ENC
    ------------------------------ ---
    SYSTEM                         NO
    SYSAUX                         NO
    UNDOTBS1                       NO
    TEMP                           NO
    USERS                          YES
    
    ```

    </details>

7. Verify that the PDB is using a keystore.

    ``` bash
    <copy>
    select wrl_type, status, wallet_type, keystore_mode from v$encryption_wallet;
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> select wrl_type, status, wallet_type, keystore_mode from v$encryption_wallet;

    WRL_TYPE             STATUS     WALLET_TYPE          KEYSTORE
    -------------------- ---------- -------------------- --------
    FILE                 OPEN       LOCAL_AUTOLOGIN      UNITED
    ```

    </details>

8. Exit SQLcl.

    ``` bash
    <copy>
    exit
    </copy>
    ```

**Congratulations!** You have now upgraded your encrypted PDB to a new release of Oracle AI Database.

You may now [*proceed to the next lab*](#next).

## Learn More

As the use of database encryption increases, it is important to understand how to upgrade them. AutoUpgrade fully supports any scenario when the database is encrypted, and you can safely store database keystore passwords in AutoUpgrade's keystore.

For fully automated solutions, you should explore Secure External Password Stores, which enables upgrades and migration of encrypted databases even without loading the password into AutoUpgrade's keystore.

* Documentation, [The keystore parameter](https://docs.oracle.com/en/database/oracle/oracle-database/26/upgrd/common-parameters-autoupgrade-config-file.html#GUID-B0D91A5E-F2A1-4714-8908-3C7F4C557EDD)
* Documentation, [Secure External Password Store](https://docs.oracle.com/en/database/oracle/oracle-database/26/refrn/EXTERNAL_KEYSTORE_CREDENTIAL_LOCATION.html#GUID-FD2C1839-E3CC-47E2-99B4-ECE29EB923B6)
* Webinar, [AutoUpgrade 2.0 – New Features and Best Practices](https://www.youtube.com/watch?v=69Hx1WoJ_HE&t=1148s)
* Slides, [AutoUpgrade 2.0 – New Features and Best Practices](https://dohdatabase.com/wp-content/uploads/2022/05/2022_05_05_emea14_autoupgrade_2_0-1.pdf)

## Acknowledgements

* **Author** - Daniel Overby Hansen
* **Contributors** - Rodrigo Jorge, Alex Zaballa, Mike Dietrich, Alejandro Diaz
* **Last Updated By/Date** - Daniel Overby Hansen, August 2026