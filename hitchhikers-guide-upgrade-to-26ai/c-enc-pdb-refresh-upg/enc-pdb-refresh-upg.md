# Upgrade Encrypted PDB Using Refreshable Clone

## Introduction

This lab focuses on databases that use Transparent Data Encryption (TDE). You will upgrade an encrypted PDB. The upgrade requires access to the database keystore passwords. For this purpose, AutoUpgrade has its own keystore, which you will use to securely store the required password. You will use a refreshable clone PDB to copy the PDB over a database link. You will then keep the clone synchronized by applying redo until the final refresh and upgrade. This technique preserves the source PDB for rollback.

Estimated Time: 35 minutes

### Objectives

In this lab, you will:

* Upgrade an encrypted PDB *CORAL* and rename it *CHERRY*. 
* Create a refreshable clone PDB in the 26ai CDB, *CDB26ENC*.
* Refresh and upgrade.
* Use the AutoUpgrade keystore.

### Prerequisites

None.

## Task 1: Encrypt PDB and Prepare

The two CDBs, *CDB19ENC* and *CDB26ENC*, have already been configured for TDE.

1. Start a new terminal or use an existing one. This terminal is called *terminal A*. 

1. Set the environment to the 19c source CDB, *CDB19ENC*, and connect.

    ``` bash
    <copy>
    . cdb19enc
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

1. Connect to the *CORAL* PDB, create an encryption key and an encrypted tablespace.

    ``` bash
    <copy>
    alter session set container=CORAL;
    administer key management set key force keystore identified by "oracle_4U" with backup;
    create tablespace users datafile size 50m autoextend on next 50m encryption using 'AES256' encrypt;
    </copy>

    # Be sure to press RETURN
    ```

    * The PDB is configured to use a unified keystore. This is the default configuration.
    * You must use the CDB keystore password (`oracle_4U`) to create a new encryption key in the PDB.
    * The tablespace uses the AES256 encryption algorithm. This is a stronger algorithm than the default, AES128. 
    * In Oracle AI Database 26ai, the default changes to AES256 to meet modern security requirements.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> alter session set container=CORAL;

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

    * Notice the *NO AUTHENCATION* clause on the `CREATE USER` statement.
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

5. Create a user and grant the necessary privileges. You use the user to connect via the database link.

    ``` bash
    <copy>
    create user dblinkuser identified by dblinkuser;
    grant create session to dblinkuser;
    grant select_catalog_role to dblinkuser;
    grant create pluggable database to dblinkuser;
    grant read on sys.enc$ to dblinkuser;
    </copy>
    ```

    * You use the user to connect from the target CDB via a database link.
    * You can drop the user after the migration.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> create user dblinkuser identified by dblinkuser;

    User created.

    SQL> grant create session to dblinkuser;

    Grant succeeded.

    SQL> grant select_catalog_role to dblinkuser;

    Grant succeeded.

    SQL> grant create pluggable database to dblinkuser;

    Grant succeeded.

    SQL> grant read on sys.enc$ to dblinkuser;

    Grant succeeded.
    ```

    </details>    

5. Exit SQLcl.

    ``` bash
    <copy>
    exit
    </copy>
    ```    

## Task 2: Prepare Target CDB

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

3. Create a database link pointing to the *CORAL* database.

    ``` bash
    <copy>
    create database link clonepdb
    connect to dblinkuser
    identified by dblinkuser
    using 'localhost/coral';
    </copy>
    ```

    * You connect as the user you just created.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> create database link clonepdb
      2  connect to dblinkuser
      3  identified by dblinkuser
      4  using 'localhost/coral';

    Database link created.
    ```

    </details>

4. Ensure that the database link works.

    ``` bash
    <copy>
    select * from dual@clonepdb;
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> select * from dual@clonepdb;
    
    DUMMY
    ________
    X
    ```

    </details>    

5. Exit SQLcl.

    ``` bash
    <copy>
    exit
    </copy>
    ```        

## Task 3: Analyze the Database

Analyze the *CORAL* PDB for upgrade readiness.

1. In this lab, you will use a precreated AutoUpgrade config file. Examine the config file.

    ``` bash
    <copy>
    cat /home/oracle/scripts/upg-coral.cfg
    </copy>
    ```

    * AutoUpgrade has its own keystore where it can store sensitive information, such as database keystore passwords.
    * The location for the AutoUpgrade keystore is defined by `global.keystore`. 
    * The AutoUpgrade keystore is not to be confused with the database keystore (which holds the tablespace encryption keys).
    * `sid` and `target_cdb` specifies the source and target CDBs, respectively.
    * `pdbs` is a comma-separated list of PDBs to upgrade.
    * `source_dblink` specifies the database link and the refresh interval in seconds. 60 is unrealistically low and used only for the purpose of this exercise.
    * `target_pdb_name` allows you to rename the PDB to *CHERRY*. 
    * `target_pdb_copy_option` pecifies where to create the data files. You use OMF and set it to `file_name_convert=none`. 
    * `parallel_pdb_creation_clause` is used to avoid overloading the source CDB. Only two channels are used for the initial copy of the database.
    * `start_time` is set to 100 hours from starting AutoUpgrade. We set the process start time far in the future so we can later control the execution using the *proceed* command.
    * `timezone_upg` is used to disable the upgrade of the timezone file. You do this to save time.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    global.global_log_dir=/home/oracle/logs/upg-coral
    global.keystore=/u01/app/oracle/keystore/autoupgrade/coral
    upg1.source_home=/u01/app/oracle/product/19
    upg1.target_home=/u01/app/oracle/product/26
    upg1.sid=CDB19ENC
    upg1.target_cdb=CDB26ENC
    upg1.pdbs=CORAL
    upg1.source_dblink.CORAL=CLONEPDB 60
    upg1.target_pdb_name.CORAL=CHERRY
    upg1.target_pdb_copy_option.CORAL=file_name_convert=none
    upg1.parallel_pdb_creation_clause.CORAL=2
    upg1.start_time=+100h
    upg1.timezone_upg=NO
    ```

    </details>

2. Start AutoUpgrade in analyze mode. Wait for it to complete.

    ``` bash
    <copy>
    java -jar autoupgrade.jar -config /home/oracle/scripts/upg-coral.cfg -mode analyze
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
    /home/oracle/logs/upg-coral/cfgtoollogs/upgrade/auto/status/status.html
    /home/oracle/logs/upg-coral/cfgtoollogs/upgrade/auto/status/status.log
    ```

    </details>

3. Check the *summary report*.

    ``` bash
    <copy>
    cat /home/oracle/logs/upg-coral/cfgtoollogs/upgrade/auto/status/status.log
    </copy>
    ```

    * *PRECHECKS* has status *FAILURE*. The database is **not** ready for upgrade.
    * The check *TDE_PASSWORDS_REQUIRED* failed.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    ==========================================
              Autoupgrade Summary Report
    ==========================================
    [Date]           Fri Aug 14 11:58:13 GMT 2026
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
    [Start Time]    2026-08-14 11:58:03
    [Duration]      0:00:10
    [Log Directory] /home/oracle/logs/upg-coral/CDB19ENC/100/prechecks
    [Detail]        /home/oracle/logs/upg-coral/CDB19ENC/100/prechecks/cdb19enc_preupgrade.log
                    Check failed for CORAL, manual intervention needed for the below checks
                    [TDE_PASSWORDS_REQUIRED]
    Cause:The following checks have ERROR severity and no auto fixup is available or
    the fixup failed to resolve the issue. Fix them before continuing:
    CORAL TDE_PASSWORDS_REQUIRED
    Reason:Database Checks has Failed details in /home/oracle/logs/upg-coral/CDB19ENC/100/prechecks
    Action:[MANUAL]
    Info:Return status is ERROR
    ExecutionError:No
    Error Message:The following checks have ERROR severity and no auto fixup is available or
    the fixup failed to resolve the issue. Fix them before continuing:
    CORAL TDE_PASSWORDS_REQUIRED

    ------------------------------------------
    ```

    </details>

4. You find additional details in the preupgrade log file. There is a *required action* that you must perform before the upgrade.

    * You must load the database keystore password into the AutoUpgrade keystore for the database *CDB26ENC*.
    * AutoUpgrade must have access to the keystore password of the target CDB to complete the process.
    * Optionally, you can check the entire preupgrade log file. It is in `/home/oracle/logs/upg-coral/CDB19ENC/100/prechecks/cdb19enc_preupgrade.log`.

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
          CDB26ENC                        Add TDE password      
    ```

5. Load the database keystore password into the AutoUpgrade keystore. Start the password loader.

    ``` bash
    <copy>
    java -jar autoupgrade.jar -config /home/oracle/scripts/upg-coral.cfg -load_password
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

9. Add the database keystore password for *CDB26ENC*.

    ``` bash
    <copy>
    add CDB26ENC
    </copy>
    ```

    Enter the database keystore password for *CDB26ENC* twice:

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

12. Re-analyze the database for upgrade readiness. Now that you have added the database keystore password to the AutoUpgrade keystore, you can re-analyze the PDB to verify that it meets the requirements. It takes a short while. Wait for it to complete.

    ``` bash
    <copy>
    java -jar autoupgrade.jar -config /home/oracle/scripts/upg-coral.cfg -mode analyze
    </copy>
    ```

    * The analysis must run on the source system. Since the source and target are the same in this lab, you don't need to worry about it.
    * If the target is on a remote host, you can use the parameter `target_is_remote`. 
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
    /home/oracle/logs/upg-coral/cfgtoollogs/upgrade/auto/status/status.html
    /home/oracle/logs/upg-coral/cfgtoollogs/upgrade/auto/status/status.log
    ```

    </details>

13. Check the results in the summary report.

    ``` bash
    <copy>
    cat /home/oracle/logs/upg-coral/cfgtoollogs/upgrade/auto/status/status.log
    </copy>
    ```

    * *PRECHECKS* now has the status *SUCCESS*. The details state: *Check passed and no manual intervention needed*.
    * Oracle recommends that you examine the detailed preupgrade report, but to save time in this lab, you skip it.
    * You may now proceed with upgrading and converting the encrypted database.

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
    [Log Directory] /home/oracle/logs/upg-coral/CDB19ENC/101/prechecks
    [Detail]        /home/oracle/logs/upg-coral/CDB19ENC/101/prechecks/cdb19enc_preupgrade.log
                    Check passed and no manual intervention needed
    ------------------------------------------
    ```

    </details>

## Task 4: Build Refreshable Clone

All prerequisites have been met. You can now start the initial clone of the PDB.

1. Start AutoUpgrade in deploy mode. 

    ``` bash
    <copy>
    java -jar autoupgrade.jar -config /home/oracle/scripts/upg-coral.cfg -mode deploy
    </copy>
    ```
    * AutoUpgrade in deploy mode must run on the target system. Since source and target are on the same system in this lab, you don't need to worry about it.
    * AutoUpgrade creates the clone by copying the data files over the database link.

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
    upg> Copying remote database 'CORAL' as 'CHERRY' for job 102
    ```

    </details>

2. After a short while, AutoUpgrade reports that the initial copy is complete.

    ``` text
    Remote database 'CORAL' created as PDB 'CHERRY' for job 102
    ```

3. Press *ENTER* to bring up the console. Monitor the progress.

    ``` bash
    <copy>
    lsj -a 30
    </copy>
    ```

    * AutoUpgrade is now refreshing the PDB periodically. In a new terminal, you will enter some data to the *CORAL* database. This allows you to verify that changes made after the initial data file copy are propagated to the PDB.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    +----+--------+----------+---------+-------+----------+-------+-----------------------+
    |Job#| DB_NAME|     STAGE|OPERATION| STATUS|START_TIME|UPDATED|                MESSAGE|
    +----+--------+----------+---------+-------+----------+-------+-----------------------+
    | 102|CDB19ENC|REFRESHPDB|EXECUTING|RUNNING|  16:02:18| 3s ago|Starts in 5,997 minutes|
    +----+--------+----------+---------+-------+----------+-------+-----------------------+
    Total jobs 1

    The command lsj is running every 30 seconds. PRESS ENTER TO EXIT    
    ```

    </details>

4. Do not exit AutoUpgrade. Leave it running

## Task 5: Refresh

So far, you've created a copy of the *CORAL* PDB in the *CDB26ENC* database. Every 60 seconds, *CDB26ENC* fetches redo over the database link and keeps *CHERRY* current.

1. **Start a new terminal, *B*.** 

2. Set the environment to the *CDB19ENC* database and connect.

    ``` bash
    <copy>
    . cdb19enc
    sql / as sysdba
    </copy>
    ```

3. Add more test data to the source PDB.

    ``` bash
    <copy>
    alter session set container=CORAL;
    insert into appuser.t1 values(systimestamp, 'World');
    commit;
    </copy>

    # Be sure to press RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> alter session set container=CORAL;

    Session altered.

    SQL> insert into appuser.t1 values(systimestamp, 'World');

    1 row inserted.

    SQL> commit;

    Commit complete.
    ```

    </details>

4. Exit SQLcl.

    ``` bash
    <copy>
    exit
    </copy>
    ```

## Task 6: Upgrade

Now the maintenance window has started. You're ready to perform the final refresh and upgrade.

The *REFRESHPDB* phase would normally remain active for the next 100 hours. We specified such a long interval so that we have full control over when to start the upgrade. For example, you might need to wait for approval from another team before shutting down the application and starting the migration.

When the upgrade starts, AutoUpgrade performs a final refresh to apply the latest changes from the source PDB. After the final refresh, no further changes from the source are applied to the clone. AutoUpgrade then stops refreshing the PDB and starts the upgrade.

1. **Remain in the terminal *B*.** 

2. Start the pre-upgrade fixups.

    * **Do not run the command below**. To save time in this lab, you skip the fixups in this exercise.
    * The fixups must run on the source system.

    ``` bash
    java -jar autoupgrade.jar -config /home/oracle/scripts/upg-coral.cfg -mode fixups
    ```

3. **Switch back to the terminal *A*.**

3. Press ENTER to stop *lsj* from displaying the job status. Next, run the `proceed` command to force the start of the upgrade process **now**.

    ``` bash
    <copy>
    proceed -job 102
    </copy>
    ```

    * AutoUpgrade will start shortly.
    * You can also specify a new start time using *proceed -job <#> -newStartTime [dd/mm/yyyy hh:mm:ss, +<#>h<#>m]*.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    upg> proceed -job 102
    New start time for job 102 is scheduled 0 minute(s) from now, at 14/08/2026 12:57:07
    ```

    </details>

4. Monitor the progress.

    ``` bash
    <copy>
    status -job 102 -a 10
    </copy>
    ```

    * AutoUpgrade was waiting in the *REFRESHPDB*; applying redo at the specified interval.
    * When you issued the `proceed` command, AutoUpgrade made a final refresh before moving on to the next phase.
    * Any changes made in the source database at this point would not be transferred to the target PDB.
    * In the *DBUPGRADE* stage, AutoUpgrade is upgrading the PDB to the new release. The CDB is already on the new release, so only the PDB is upgraded, which is much faster than a complete database upgrade.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    Details

    	Job No           102
    	Oracle SID       CDB19ENC
    	Start Time       26/08/14 12:57:07
    	Elapsed (min):   0
    	End time:        N/A

    Logfiles

    	Logs Base:    /home/oracle/logs/upg-coral/CDB19ENC
    	Job logs:     /home/oracle/logs/upg-coral/CDB19ENC/102
    	Stage logs:   /home/oracle/logs/upg-coral/CDB19ENC/102/dbupgrade
    	TimeZone:     /home/oracle/logs/upg-coral/CDB19ENC/temp
    	Remote Dirs:

    Stages
    	SETUP            <1 min
    	PREUPGRADE       <1 min
    	DRAIN            <1 min
    	CLONEPDB         <1 min
    	REFRESHPDB       54 min
    	DISPATCH         <1 min
    	DISPATCH         <1 min
    	DBUPGRADE        ~0 min (RUNNING)
    	UNPLUGWORK
    	POSTCHECKS
    	POSTFIXUPS
    	POSTUPGRADE
    	SYSUPDATES

    Stage-Progress Per Container

    	+--------+---------+
    	|Database|DBUPGRADE|
    	+--------+---------+
    	|  CHERRY|    0  % |
    	+--------+---------+

    The command status is running every 10 seconds. PRESS ENTER TO EXIT
    ```

    </details>

5. The upgrade takes 10-15 minutes. Leave the process running. In the end, AutoUpgrade displays *Job 102 completed* and exits.

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
    /home/oracle/logs/upg-coral/cfgtoollogs/upgrade/auto/status/status.html
    /home/oracle/logs/upg-coral/cfgtoollogs/upgrade/auto/status/status.log
    ```

    </details>

6. Set the environment to *CDB26ENC* and connect.

    ``` bash
    <copy>
    . cdb26enc
    sql / as sysdba
    </copy>
    ```

7. Ensure that the *CHERRY* PDB has been plugged in and is open *READ WRITE* and unrestricted.

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
        2 PDB$SEED                            READ ONLY  NO
        3 CHERRY                              READ WRITE NO
    ```

    </details>

8. Drop the database link used for the migration.

    ``` bash
    <copy>
    drop database link clonepdb;
    </copy>
    ```

    * You could also have used the AutoUpgrade config file parameter `drop_dblink`.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> drop database link clonepdb;

    Database link CLONEPDB dropped.
    ```

    </details>

9. Switch to the *CHERRY* PDB and ensure the *USERS* tablespace is still encrypted.

    ``` bash
    <copy>
    alter session set container=CHERRY;
    select tablespace_name, encrypted from dba_tablespaces;
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> alter session set container=CHERRY;

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

10. Verify that the PDB is using a keystore.

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

11. Ensure all data is present in the application.

    ``` bash
    <copy>
    select * from appuser.t1 order by ts;
    </copy>
    ```

    * Both records are present. 
    * The *Hello* record was created initially, and the *World* record was created shortly before the final refresh.
    * This proves that changes made after the initial copy of data files are still in the PDB after the upgrade.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    TS                                     MSG
    ______________________________________ ________
    14-AUG-26 11.57.02.258264000 AM GMT    Hello
    14-AUG-26 12.48.24.185881000 PM GMT    World    
    ```

    </details>

12. Exit SQLcl.

    ``` bash
    <copy>
    exit
    </copy>
    ```

13. AutoUpgrade stops the source PDB immediately after the final refresh when the source CDB and target CDB are on the same system. 
    * This ensures no one enters data into the wrong database during the migration, or adds new data to it. 
    * You can control this behavior with the `close_source` config file parameter. 
    * If the databases are on different systems, you must manually shut down the source PDB after the migration.    

**Congratulations!** You have now upgraded your encrypted PDB to a new release of Oracle AI Database.

You may now [*proceed to the next lab*](#next).

## Learn More

As the use of database encryption increases, it is important to understand how to upgrade them. AutoUpgrade fully supports any scenario when the database is encrypted, and you can safely store database keystore passwords in AutoUpgrade's keystore.

For fully automated solutions, consider using a Secure External Password Store, which enables upgrades and migrations of encrypted databases without loading the passwords into the AutoUpgrade keystore.

* Documentation, [The keystore parameter](https://docs.oracle.com/en/database/oracle/oracle-database/26/upgrd/common-parameters-autoupgrade-config-file.html#GUID-B0D91A5E-F2A1-4714-8908-3C7F4C557EDD)
* Documentation, [Secure External Password Store](https://docs.oracle.com/en/database/oracle/oracle-database/26/refrn/EXTERNAL_KEYSTORE_CREDENTIAL_LOCATION.html#GUID-FD2C1839-E3CC-47E2-99B4-ECE29EB923B6)
* Webinar, [AutoUpgrade 2.0 – New Features and Best Practices](https://www.youtube.com/watch?v=69Hx1WoJ_HE&t=1148s)
* Slides, [AutoUpgrade 2.0 – New Features and Best Practices](https://dohdatabase.com/wp-content/uploads/2022/05/2022_05_05_emea14_autoupgrade_2_0-1.pdf)

## Acknowledgements

* **Author** - Daniel Overby Hansen
* **Contributors** - Rodrigo Jorge, Alex Zaballa, Mike Dietrich, Alejandro Diaz
* **Last Updated By/Date** - Daniel Overby Hansen, August 2026