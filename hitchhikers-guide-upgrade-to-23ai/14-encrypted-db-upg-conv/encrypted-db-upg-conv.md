# Upgrade Encrypted Non-CDB and Convert

## Introduction



Estimated Time: 25 minutes

### Objectives

In this lab, you will:

* Downgrade a PDB
* Unplug from Oracle Database 23ai back to 19c

### Prerequisites

None.

This lab uses the *FTEX* and *CDB23* databases. It also encrypts both databases which have an effect on the other labs. We recommend that you perform this lab as the last one.

## Task 1: Encrypt source non-CDB

You need to prepare a few things before you can start the downgrade.

mkdir -p /u01/app/oracle/admin/FTEX/wallet/tde

. ftex

sqlplus / as sysdba

alter system set wallet_root='/u01/app/oracle/admin/FTEX/wallet' scope=spfile;

SQL> alter system set wallet_root='/u01/app/oracle/admin/FTEX/wallet' scope=spfile;

System altered.


shutdown immediate
startup

SQL> shutdown immediate
startup



Database closed.
Database dismounted.
ORACLE instance shut down.
SQL>

ORACLE instance started.

Total System Global Area 1157627144 bytes
Fixed Size		    8924424 bytes
Variable Size		  419430400 bytes
Database Buffers	  721420288 bytes
Redo Buffers		    7852032 bytes





Database mounted.
Database opened.

alter system set tde_configuration='keystore_configuration=file' scope=both;

SQL> alter system set tde_configuration='keystore_configuration=file' scope=both;

System altered.


administer key management create keystore '/u01/app/oracle/admin/FTEX/wallet/tde' identified by "oracle_4U";
administer key management set keystore open force keystore identified by "oracle_4U";
administer key management set key identified by "oracle_4U" with backup;
administer key management create local auto_login keystore from keystore '/u01/app/oracle/admin/FTEX/wallet/tde' identified by "oracle_4U";


SQL> alter tablespace users encryption encrypt;

Tablespace altered.

SQL> select tablespace_name, encrypted from dba_tablespaces;

TABLESPACE_NAME 	       ENC
------------------------------ ---
SYSTEM			       NO
SYSAUX			       NO
TEMP			       NO
USERS			       YES
UNDOTBS100		       NO

exit

SQL> exit
Disconnected from Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.21.0.0.0

## Task 2: Encrypt target CDB

You need to prepare a few things before you can start the downgrade.

mkdir -p /u01/app/oracle/admin/CDB23/wallet/tde

. cdb23

sqlplus / as sysdba

alter system set wallet_root='/u01/app/oracle/admin/CDB23/wallet' scope=spfile;

SQL> alter system set wallet_root='/u01/app/oracle/admin/CDB23/wallet' scope=spfile;

System altered.


shutdown immediate
startup

SQL> shutdown immediate
startup






Database closed.
Database dismounted.
ORACLE instance shut down.
SQL> ORACLE instance started.

Total System Global Area 4292413984 bytes
Fixed Size		    5368352 bytes
Variable Size		 1157627904 bytes
Database Buffers	 3120562176 bytes
Redo Buffers		    8855552 bytes
Database mounted.
Database opened.

alter system set tde_configuration='keystore_configuration=file' scope=both;

SQL> alter system set tde_configuration='keystore_configuration=file' scope=both;

System altered.


I'm using the same keystore password in the CDB as well for simplicity. Realistically, you would choose different keystore passwords. 
administer key management create keystore '/u01/app/oracle/admin/CDB23/wallet/tde' identified by "oracle_4U";
administer key management set keystore open force keystore identified by "oracle_4U";
administer key management set key identified by "oracle_4U" with backup;
administer key management create local auto_login keystore from keystore '/u01/app/oracle/admin/CDB23/wallet/tde' identified by "oracle_4U";



SQL> select con_id, tablespace_name, encrypted from cdb_tablespaces order by 1;

    CON_ID TABLESPACE_NAME		  ENC
---------- ------------------------------ ---
	 1 SYSTEM			  NO
	 1 SYSAUX			  NO
	 1 USERS			  NO
	 1 TEMP 			  NO
	 1 UNDOTBS1			  NO
	 3 SYSTEM			  NO
	 3 TEMP 			  NO
	 3 UNDOTBS1			  NO
	 3 SYSAUX			  NO

9 rows selected.


mkdir -p /u01/app/oracle/keystore/autoupgrade


[oracle@holserv1:~]$ cat /home/oracle/scripts/encrypted-db-upg-conv.cfg
global.autoupg_log_dir=/home/oracle/logs/encrypted-db-upg-conv
global.keystore=/u01/app/oracle/keystore/autoupgrade
upg1.source_home=/u01/app/oracle/product/19
upg1.target_home=/u01/app/oracle/product/23
upg1.sid=FTEX
upg1.target_cdb=CDB23


java -jar autoupgrade.jar -config /home/oracle/scripts/encrypted-db-upg-conv.cfg -mode analyze


AutoUpgrade 24.3.240419 launched with default internal options
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

cat /home/oracle/logs/encrypted-db-upg-conv/cfgtoollogs/upgrade/auto/status/status.log
==========================================
          Autoupgrade Summary Report
==========================================
[Date]           Fri May 31 05:05:37 GMT 2024
[Number of Jobs] 1
==========================================
[Job ID] 100
==========================================
[DB Name]                FTEX
[Version Before Upgrade] 19.21.0.0.0
[Version After Upgrade]  23.4.0.24.05
------------------------------------------
[Stage Name]    PRECHECKS
[Status]        FAILURE
[Start Time]    2024-05-31 05:05:31
[Duration]
[Log Directory] /home/oracle/logs/encrypted-db-upg-conv/FTEX/100/prechecks
[Detail]        /home/oracle/logs/encrypted-db-upg-conv/FTEX/100/prechecks/ftex_preupgrade.log
                Check failed for FTEX, manual intervention needed for the below checks
                [TDE_PASSWORDS_REQUIRED]
Cause:Check failed for FTEX, manual intervention needed for the below checks : [AUDUNIFIED_LOB_TYPE HIDDEN_PARAMS INVALID_OBJECTS_EXIST POST_DICTIONARY POST_FIXED_OBJECTS OLD_TIME_ZONES_EXIST PARAMETER_DEPRECATED MIN_RECOVERY_AREA_SIZE MANDATORY_UPGRADE_CHANGES DATAPATCH_TIMEOUT_SETTINGS RMAN_RECOVERY_VERSION TABLESPACES_INFO TIMESTAMP_MISMATCH POST_UTLRP COMPONENT_INFO INVALID_ORA_OBJ_INFO INVALID_APP_OBJ_INFO TDE_PASSWORDS_REQUIRED PARAM_VALUES_IN_MEM_ONLY EM_EXPRESS_PRESENT TARGET_CDB_COMPATIBILITY_WARNINGS ]
Reason:Database Checks has Failed details in /home/oracle/logs/encrypted-db-upg-conv/FTEX/100/prechecks
Action:[MANUAL]
Info:Return status is ERROR
ExecutionError:No
Error Message:The following checks have ERROR severity and no fixup is available or
the fixup failed to resolve the issue. Fix them manually before continuing:
FTEX TDE_PASSWORDS_REQUIRED

------------------------------------------





[oracle@holserv1:~]$ more /home/oracle/logs/encrypted-db-upg-conv/FTEX/100/prechecks/ftex_preupgrade.log

Report generated by AutoUpgrade 24.3.240419 (#a1ea950cc) on 2024-05-31 05:05:37

Upgrade-To version: 23.0.0.0.0

=======================================
Status of the database prior to upgrade
=======================================
      Database Name:  FTEX
     Container Name:  FTEX
       Container ID:  0
            Version:  19.21.0.0.0
     DB Patch Level:  Database Release Update : 19.21.0.0.231017 (35643107)
         Compatible:  19.0.0
          Blocksize:  8192
           Platform:  Linux x86 64-bit
      Timezone File:  42
  Database log mode:  ARCHIVELOG
           Readonly:  false
            Edition:  EE

  Oracle Component                       Upgrade Action    Current Status
  ----------------                       --------------    --------------
  Oracle Server                          [to be upgraded]  VALID
  Real Application Clusters              [to be upgraded]  OPTION OFF
  Oracle XML Database                    [to be upgraded]  VALID

  *
  * ALL Components in This Database Registry:
  *
  Component   Current      Current      Original     Previous     Component
  CID         Version      Status       Version      Version      Schema
  ----------  -----------  -----------  -----------  -----------  ------------
  CATALOG     19.21.0.0.0  VALID                                  SYS
  CATPROC     19.21.0.0.0  VALID                                  SYS
  RAC         19.21.0.0.0  OPTION OFF   19.21.0.0.0               SYS
  XDB         19.21.0.0.0  VALID        19.21.0.0.0               XDB

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



java -jar autoupgrade.jar -config /home/oracle/scripts/encrypted-db-upg-conv.cfg -load_password

Processing config file ...

Starting AutoUpgrade Password Loader - Type help for available options
Creating new AutoUpgrade keystore - Password required
Enter password:
Enter password again:
AutoUpgrade keystore was successfully created

TDE>

autoupgrade_4U

TDE> add FTEX
Enter your secret/Password:
Re-enter your secret/Password:

oracle_4U

TDE> add CDB23
Enter your secret/Password:
Re-enter your secret/Password:

oracle_4U

TDE> save
Convert the AutoUpgrade keystore to auto-login [YES|NO] ? YES

TDE> exit

AutoUpgrade Password Loader finished - Exiting AutoUpgrade


java -jar autoupgrade.jar -config /home/oracle/scripts/encrypted-db-upg-conv.cfg -mode analyze

AutoUpgrade 24.3.240419 launched with default internal options
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

cat /home/oracle/logs/encrypted-db-upg-conv/cfgtoollogs/upgrade/auto/status/status.log
==========================================
          Autoupgrade Summary Report
==========================================
[Date]           Fri May 31 05:21:50 GMT 2024
[Number of Jobs] 1
==========================================
[Job ID] 101
==========================================
[DB Name]                FTEX
[Version Before Upgrade] 19.21.0.0.0
[Version After Upgrade]  23.4.0.24.05
------------------------------------------
[Stage Name]    PRECHECKS
[Status]        SUCCESS
[Start Time]    2024-05-31 05:21:45
[Duration]
[Log Directory] /home/oracle/logs/encrypted-db-upg-conv/FTEX/101/prechecks
[Detail]        /home/oracle/logs/encrypted-db-upg-conv/FTEX/101/prechecks/ftex_preupgrade.log
                Check passed and no manual intervention needed
------------------------------------------


java -jar autoupgrade.jar -config /home/oracle/scripts/encrypted-db-upg-conv.cfg -mode deploy
AutoUpgrade 24.3.240419 launched with default internal options
Processing config file ...
Loading AutoUpgrade keystore
AutoUpgrade keystore was successfully loaded
+--------------------------------+
| Starting AutoUpgrade execution |
+--------------------------------+
1 Non-CDB(s) will be processed
Type 'help' to list console commands
upg>

lsj -a 30



The command lsj is running every 30 seconds. PRESS ENTER TO EXIT
+----+-------+----------+---------+-------+----------+-------+-------+
|Job#|DB_NAME|     STAGE|OPERATION| STATUS|START_TIME|UPDATED|MESSAGE|
+----+-------+----------+---------+-------+----------+-------+-------+
| 102|   FTEX|POSTFIXUPS|EXECUTING|RUNNING|  05:22:43| 9s ago|       |
+----+-------+----------+---------+-------+----------+-------+-------+
Total jobs 1

The command lsj is running every 30 seconds. PRESS ENTER TO EXIT
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





[CDB23:oracle@holserv1:~]$ . cdb23
[CDB23:oracle@holserv1:~]$ sqlplus / as sysdba

SQL*Plus: Release 23.0.0.0.0 - Production on Fri May 31 05:48:49 2024
Version 23.4.0.24.05

Copyright (c) 1982, 2024, Oracle.  All rights reserved.


Connected to:
Oracle Database 23ai Enterprise Edition Release 23.0.0.0.0 - Production
Version 23.4.0.24.05

SQL> show pdbs

    CON_ID CON_NAME			  OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
	 2 PDB$SEED			  READ ONLY  NO
	 3 RED				  READ WRITE NO
	 4 BLUE 			  MOUNTED
	 5 GREEN			  MOUNTED
	 6 UPGR 			  MOUNTED
	 7 FTEX 			  READ WRITE NO
SQL> alter session set container=FTEX;

Session altered.

SQL> select tablespace_name, encrypted from dba_tablespaces;

TABLESPACE_NAME 	       ENC
------------------------------ ---
SYSTEM			       NO
SYSAUX			       NO
TEMP			       NO
USERS			       YES
UNDOTBS100		       NO

SQL> col status format a10
SQL> select wrl_type, status, wallet_type, keystore_mode from v$encryption_wallet;

WRL_TYPE	     STATUS	WALLET_TYPE	     KEYSTORE
-------------------- ---------- -------------------- --------
FILE		     OPEN	PASSWORD	     UNITED







**Congratulations!** You have now upgraded your encrypted database to Oracle Database 23ai.

You may now *proceed to the next lab*.

## Learn More

Since encrypted databases are becoming more popular due, it's important to know how to deal with them. AutoUpgrade fully supports any scenario when the database is encrypted, and you can safely store database keystore passwords in AutoUpgrade's keystore.

For fully automated solutions, you should explore Secure External Password Stores which enables upgrades and migration of encrypted databases even without loading the password into AutoUpgrade's keystore.


* Documentation, [The keystore parameter](https://docs.oracle.com/en/database/oracle/oracle-database/23/upgrd/global-parameters-autoupgrade-config-file.html#GUID-B0D91A5E-F2A1-4714-8908-3C7F4C557EDD)
* Documentation, [Secure External Password Store](https://docs.oracle.com/en/database/oracle////oracle-database/23/refrn/EXTERNAL_KEYSTORE_CREDENTIAL_LOCATION.html#GUID-FD2C1839-E3CC-47E2-99B4-ECE29EB923B6)
* Webinar, [AutoUpgrade 2.0 – New Features and Best Practices](https://www.youtube.com/watch?v=69Hx1WoJ_HE&t=1148s)
* Slides, [AutoUpgrade 2.0 – New Features and Best Practices](https://dohdatabase.com/wp-content/uploads/2022/05/2022_05_05_emea14_autoupgrade_2_0-1.pdf)

## Acknowledgements
* **Author** - Daniel Overby Hansen
* **Contributors** - Klaus Gronau
* **Last Updated By/Date** - Daniel Overby Hansen, June 2024