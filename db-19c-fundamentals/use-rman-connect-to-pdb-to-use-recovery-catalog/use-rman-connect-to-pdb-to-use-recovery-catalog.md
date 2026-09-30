
# Use Recovery Manager (RMAN) to Connect to a PDB to Use the Recovery Catalog

## Introduction

Oracle Database 19c provides complete backup and recovery flexibility for multitenant container databases (CDBs) and pluggable databases (PDBs) with recovery catalog support. You can use a virtual private catalog (VPC) user to control permissions to perform backup and restore operations at a PDB level. The metadata view is also limited, so a VPC user can view only data for which the user has been granted permission.

In this lab, you create a PDB named PDB19 to act as the recovery catalog database for all other PDBs in CDB1. You create two VPC users (`vpc_pdb1` and `vpc_pdb2`) and grant them access to the metadata of PDB1 and PDB2 respectively in the recovery catalog database. Next, you use RMAN to perform back up operations on PDB1 as both users and observe the results. `ARCHIVELOG` mode must be enabled on CDB1. Use the `workshop-installed` compute instance.

Estimated Time: 25 minutes

Watch the video below for a quick walk through of the lab.

[](youtube:ZQpFzqnqSyo)


### Objectives

In this lab, you will:

- Prepare your environment
- Create a recovery catalog database
- Create a recovery catalog owner and grant it privileges
- Create the recovery catalog in the recovery catalog database with RMAN and register CDB1
- Grant VPD privileges to the base catalog schema owner
- Upgrade the recovery catalog
- Create VPC users
- Back up PDB1
- Find the handle value that corresponds to your tag value
- Revoke privileges from the VPC users and drop the recovery catalog
- Reset your environment


### Prerequisites

This lab assumes you have:
- Obtained and signed in to your `workshop-installed` compute instance.

## Task 1: Prepare your environment

> **NOTE:** Unless otherwise stated, all passwords will be `Ora4U_1234`. When copying and pasting a command that includes a password, please replace the word `password` with `Ora4U_1234`. This only applies to instances created through OCI Resource Manager with our provided terraform scripts.

1. Open a terminal window on your desktop.

2. Run the `enable_ARCHIVELOG.sh` shell script to enable `ARCHIVELOG` mode in CDB1. Enter **CDB1** at the prompt.

    ```
    $ <copy>$HOME/labs/19cnf/enable_ARCHIVELOG.sh</copy>
    CDB1
    ```

3. Run the `cleanup_PDBs_in_CDB1.sh` shell script to drop all PDBs in CDB1 that may have been created in other labs, and recreate PDB1. You can ignore any error messages that are caused by the script. They are expected.

    ```
    $ <copy>$HOME/labs/19cnf/cleanup_PDBs_in_CDB1.sh</copy>
    ```

4. Run the `recreate_PDB2_in_CDB1.sh` shell script to create PDB2 in CDB1. You can ignore any error messages that are caused by the script. They are expected.

    ```
    $ <copy>$HOME/labs/19cnf/recreate_PDB2_in_CDB1.sh</copy>
    ```

## Task 2: Create a recovery catalog database

Create a PDB named PDB19 to act as the recovery catalog database. This database provides an optional backup store for the RMAN repository.

1.  Run the `create_PDB19_in_CDB1.sh` shell script to create PDB19 in CDB1.

    ```
    $ <copy>$HOME/labs/19cnf/create_PDB19_in_CDB1.sh</copy>
    ```

2. Run the `glogin.sh` shell script to format all the columns selected in queries.

    ```
    $ <copy>$HOME/labs/19cnf/glogin.sh</copy>
    ```

## Task 3: Create a recovery catalog owner and grant it privileges

In PDB19, create a recovery catalog owner named `catowner` and grant it privileges.

1. Set the Oracle environment variables. At the prompt, enter **CDB1**.

    ```
    $ <copy>. oraenv</copy>
    CDB1   
    ```

2. Connect to PDB19 as the `SYSTEM` user.

    ```
    $ <copy>sqlplus system/password@PDB19</copy>
    ```

3. Create a user named `catowner` that will act as the recovery catalog owner.

    ```
    SQL> <copy>CREATE USER catowner IDENTIFIED BY password;</copy>

    User created.
    ```

4. Grant the necessary privileges to `catowner`.

    ```
    SQL> <copy>GRANT create session, recovery_catalog_owner, unlimited tablespace TO catowner;</copy>

    Grant succeeded.
    ```

5. Exit SQL*Plus.

    ```
    SQL> <copy>EXIT</copy>
    ```

## Task 4: Create the recovery catalog in the recovery catalog database with RMAN and register CDB1

Create a virtual private catalog (VPC), also referred to simply as "recovery catalog," in PDB19 for users and databases. Register CDB1 in the recovery catalog.

1. Start Recovery Manager (RMAN).

    ```
    $ <copy>rman</copy>
    ```

2. Connect to the recovery catalog database as the recovery catalog owner.

    ```
    RMAN> <copy>CONNECT CATALOG catowner/password@PDB19</copy>

    connected to recovery catalog database
    ```

3. Create the recovery catalog.

    ```
    RMAN> <copy>CREATE CATALOG;</copy>

    recovery catalog created
    ```

4. Exit RMAN.

    ```
    RMAN> <copy>EXIT</copy>

    Recovery Manager complete.
    ```

5. Using RMAN, connect to CDB1 (the target) and the recovery catalog database (PDB19) as the recovery catalog owner (`catowner`).

    ```
    $ <copy>rman TARGET / CATALOG catowner/password@PDB19</copy>

    connected to target database: CDB1 (DBID=1051548720)
    connected to recovery catalog database
    ```

6. Register CDB1 in the recovery catalog.

    ```
    RMAN> <copy>REGISTER DATABASE;</copy>

    database registered in recovery catalog
    starting full resync of recovery catalog
    full resync complete
    ```

7. Exit RMAN.

    ```
    RMAN> <copy>EXIT</copy>

    Recovery Manager complete.
    ```

## Task 5: Grant VPD privileges to the base catalog schema owner

Oracle Virtual Private Database (VPD) creates security policies to control database access at the row and column level. The VPD functionality is not enabled by default when the RMAN base recovery catalog is created. You need to explicitly enable the VPD model for a base recovery catalog by running the `$ORACLE_HOME/rdbms/admin/dbmsrmanvpc.sql` script.

1. Connect to the recovery catalog database as the `SYS` user.

    ```
    $ <copy>sqlplus sys/password@PDB19 AS SYSDBA</copy>
    ```

2. Run the `dbmsrmanvpc.sql` script with the `–vpd` option to enable the VPD model for the recovery catalog owned by the user `catowner`.

    ```
    SQL> <copy>@/$ORACLE_HOME/rdbms/admin/dbmsrmanvpc.sql -vpd catowner</copy>

    checking the operating user... Passed

    Granting VPD privileges to the owner of the base catalog schema CATOWNER

    ==============================
    VPD SETUP STATUS:
    VPD privileges granted successfully!
    Connect to RMAN base catalog and perform UPGRADE CATALOG.

    Disconnected from Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production

    Version 19.12.0.0.0
    ```

## Task 6: Upgrade the recovery catalog

1. Start RMAN.

    ```
    $ <copy>rman</copy>
    ```
2. Connect to the recovery catalog database as the recovery catalog owner.

    ```
    RMAN> <copy>CONNECT CATALOG catowner/password@PDB19</copy>

    connected to recovery catalog database
    ```
3. Upgrade the recovery catalog. The following command upgrades the recovery catalog schema from an older version to the version required by the RMAN client.

    ```
    RMAN> <copy>UPGRADE CATALOG;</copy>

    recovery catalog owner is CATOWNER
    enter UPGRADE CATALOG command again to confirm catalog upgrade
    ```

4. Enter the command again to confirm that you want to upgrade the recovery catalog.

    ```
    RMAN> <copy>UPGRADE CATALOG;</copy>

    recovery catalog upgraded to version 19.12.00.00.00
    DBMS_RCVMAN package upgraded to version 19.12.00.00
    DBMS_RCVCAT package upgraded to version
    ```

5. Exit RMAN.

    ```
    RMAN> <copy>EXIT</copy>
    ```



## Task 7: Create VPC users

Connect to the recovery catalog database as the `SYSTEM` user and create two VPC users named `vpc_pdb1` and `vpc_pdb2`. Grant the users the `CREATE SESSION` privilege. Next, connect to the recovery catalog database as the base catalog owner and grant the `vpc_pdb1` and `vpc_pdb2` users access to the metadata of PDB1 and PDB2, respectively.

1. Connect to the recovery catalog database as the `SYSTEM` user.

    ```
    $ <copy>sqlplus system/password@PDB19</copy>
    ```

2. Create a `vpc_pdb1` user.

    ```
    SQL> <copy>CREATE USER vpc_pdb1 IDENTIFIED BY password;</copy>

    User created.
    ```

3. Create a `vpc_pdb2` user.

    ```
    SQL> <copy>CREATE USER vpc_pdb2 IDENTIFIED BY password;</copy>

    User created.
    ```

4. Grant the `CREATE SESSION` privilege to the `vpc_pdb1` and `vpc_pdb2` users.

    ```
    SQL> <copy>GRANT CREATE SESSION TO vpc_pdb1, vpc_pdb2;</copy>

    Grant succeeded.
    ```

5. Exit SQL*Plus.

    ```
    SQL> <copy>EXIT</copy>
    ```

6. Start RMAN.

    ```
    $ <copy>rman</copy>
    ```

7. Connect to the recovery catalog database as the recovery catalog owner.

    ```
    RMAN> <copy>CONNECT CATALOG catowner/password@PDB19</copy>

    connected to recovery catalog database
    ```

8. Grant the `vpc_pdb1` user the `GRANT CATALOG` privilege for PDB1.

    ```
    RMAN> <copy>GRANT CATALOG FOR PLUGGABLE DATABASE PDB1 TO vpc_pdb1;</copy>

    Grant succeeded.
    ```

9. Grant the `vpc_pdb2` user the `GRANT CATALOG` privilege for PDB2.

    ```
    RMAN> <copy>GRANT CATALOG FOR PLUGGABLE DATABASE pdb2 TO vpc_pdb2;</copy>

    Grant succeeded.
    ```

10. Exit RMAN.

    ```
    RMAN> <copy>EXIT</copy>

    Recovery Manager complete.
    ```

## Task 8: Back up PDB1

RMAN can store backup data in a logical structure called a backup set, which is the smallest unit of an RMAN backup. A backup set has the data from one or more data files, archived redo logs, control files, or server parameter file. A backup set consists of one or more binary files in an RMAN-specific format. Each of these files is known as a backup piece. In the output from the `BACKUP DATABASE` command, you can find a handle value and a tag value. The handle value is the destination of the backup piece. The tag value is a reference for the backupset. If you do not specify your own tag, RMAN assigns a default tag automatically to all backupsets created. The default tag has a format `TAGYYYYMMDDTHHMMSS`, where `YYYYMMDD` is a date and `HHMMSS` is a time of when taking the backup was started. The instance's timezone is used. In a later task, you create a query using your tag value to find the handle value.

In RMAN, connect to PDB1 (the target PDB) and to the recovery catalog database as the `vpc_pdb1` user to back up and restore PDB1. Next, try to back up PDB1 as the `vpc_pdb2` user and observe what happens.

*This is the new feature!*

1. Using RMAN, connect to PDB1 (the target) and the recovery catalog database (PDB19) as the `vpd_pdb1` user.

    ```
    $ <copy>rman TARGET sys/password@PDB1 CATALOG vpc_pdb1/password@PDB19</copy>

    connected to target database: CDB1:PDB1 (DBID=1388128723)
    connected to recovery catalog database
    ```

2. Run the `BACKUP DATABASE` commmand.

    If you did not previously enable `ARCHIVELOG` mode in CDB1, this step fails.

    ```
    RMAN> <copy>BACKUP DATABASE;</copy>

    Starting backup at 26-AUG-21
    allocated channel: ORA_DISK_1
    channel ORA_DISK_1: SID=146 device type=DISK
    channel ORA_DISK_1: starting full datafile backup set
    channel ORA_DISK_1: specifying datafile(s) in backup set
    input datafile file number=00035 name=/u01/app/oracle/oradata/CDB1/PDB1/sysaux01.dbf
    input datafile file number=00034 name=/u01/app/oracle/oradata/CDB1/PDB1/system01.dbf
    input datafile file number=00036 name=/u01/app/oracle/oradata/CDB1/PDB1/undotbs01.dbf
    input datafile file number=00037 name=/u01/app/oracle/oradata/CDB1/PDB1/users01.dbf
    channel ORA_DISK_1: starting piece 1 at 26-AUG-21
    channel ORA_DISK_1: finished piece 1 at 26-AUG-21
    piece handle=/u01/app/oracle/recovery_area/CDB1/CA79E3F8DC8D5B8CE0534C00000A03EE/backupset/2021_08_26/o1_mf_nnndf_TAG20210826T164511_jlhk8r4z_.bkp tag=TAG20210826T164511 comment=NONE
    channel ORA_DISK_1: backup set complete, elapsed time: 00:00:07
    Finished backup at 26-AUG-21
    ```

3. Save your `tag` value from the previous output. It is located on the third line from the bottom. In the example above, the tag value is `TAG20210826T164511`.

4. Exit RMAN.

    ```
    RMAN> <copy>EXIT</copy>

    Recovery Manager complete.
    ```

5. Using RMAN, connect to PDB1 (the target) and the recovery catalog database (PDB19) as the `vpc_pdb2` user.

    ```
    $ <copy>rman TARGET sys/password@PDB1 CATALOG vpc_pdb2/password@PDB19</copy>

    connected to target database: CDB1:PDB1 (DBID=1388128723)
    connected to recovery catalog database
    ```

6. Try to run the `BACKUP DATABASE` command to back up PDB1.

    ```
    RMAN> <copy>BACKUP DATABASE;</copy>

    Starting backup at 26-AUG-21
    RMAN-00571: ===========================================================
    RMAN-00569: =============== ERROR MESSAGE STACK FOLLOWS ===============
    RMAN-00571: ===========================================================
    RMAN-03002: failure of backup command at 08/26/2021 16:48:37
    RMAN-03014: implicit resync of recovery catalog failed
    RMAN-06004: Oracle error from recovery catalog database: RMAN-20001: target database not found in recovery catalog
    ```

    The backup fails because `vpc_pdb2` is not allowed to access metadata for PDB1.

7. Try to run the `BACKUP PLUGGABLE DATABASE` command to back up PDB1.

    ```
    RMAN> <copy>BACKUP PLUGGABLE DATABASE PDB1;</copy>

    Starting backup at 26-AUG-21
    RMAN-00571: ===========================================================
    RMAN-00569: =============== ERROR MESSAGE STACK FOLLOWS ===============
    RMAN-00571: ===========================================================
    RMAN-03002: failure of backup command at 08/26/2021 16:50:04
    RMAN-03014: implicit resync of recovery catalog failed
    RMAN-06004: Oracle error from recovery catalog database: RMAN-20001: target database not found in recovery catalog
    ```

    The backup fails again because `vpc_pdb2` is not allowed to access metadata for PDB1. The VPC user can perform operations only on the target PDB to which the user is granted access.

8.  Exit RMAN.

    ```
    $ <copy>EXIT</copy>

    Recovery Manager complete.
    ```

## Task 9: Find the handle value that corresponds to your tag value

Query the `RC_BACKUP_PIECE` view, which has information about backup pieces. This view corresponds to the `V$BACKUP_PIECE` view.
Each backup set contains one or more backup pieces. Many copies of the same backup piece can exist, but each copy has its own record in the control file and its own row in the view.

1. Connect to the recovery catalog database as the catalog owner.

    ```
    $ <copy>sqlplus catowner/password@PDB19</copy>
    ```

2. Query the `RC_BACKUP_PIECE` view for the handle that corresponds to your `tag` value. Replace `<insert tag number>` with your `tag` value.

    ```
    SQL> <copy>SELECT HANDLE FROM RC_BACKUP_PIECE WHERE TAG = '<insert tag number>';</copy>

    HANDLE
    --------------------------------------------------------------------
    /u01/app/oracle/recovery_area/CDB1/CA79E3F8DC8D5B8CE0534C00000A03EE/
    backupset/2021_08_26/o1_mf_nnndf_TAG20210826T164511_jlhk8r4z_.bkp
    ```

2. Exit SQL*Plus.

    ```
    SQL> <copy>EXIT</copy>
    ```

## Task 10: Revoke privileges from the VPC users and drop the recovery catalog

Revoke recovery catalog privileges from the two VPC users, `vpc_pdb1` and `vpc_pdb2`. Test that the `vpc_pdb1` can no longer back up PDB1. Next, drop the recovery catalog from PDB19.

1. Connect to the recovery catalog database as the recovery catalog owner.

    ```
    $ <copy>rman CATALOG catowner/password@PDB19</copy>

    connected to recovery catalog database
    ```

2. Revoke recovery catalog privileges from `vpc_pdb1`.

    ```
    RMAN> <copy>REVOKE CATALOG FOR PLUGGABLE DATABASE PDB1 FROM vpc_pdb1;</copy>

    Revoke succeeded.
    ```

3. Revoke recovery catalog privileges from `vpc_pdb2`.

    ```
    RMAN> <copy>REVOKE CATALOG FOR PLUGGABLE DATABASE PDB2 FROM vpc_pdb2;</copy>

    Revoke succeeded.
    ```

4. Exit RMAN.

    ```
    RMAN> <copy>EXIT</copy>

    Recovery Manager complete.
    ```

5. Using RMAN, connect to PDB1 (the target) and the recovery catalog database (PDB19) as the `vpc_pdb1` user. Please note the use of `password`.

    ```
    $ <copy>rman TARGET sys/password@PDB1 CATALOG vpc_pdb1/password@PDB19</copy>

    connected to target database: CDB1:PDB1 (DBID=1388128723)
    connected to recovery catalog database
    ```

6. Try to back up `PDB1`.

    ```
    RMAN> <copy>BACKUP DATABASE;</copy>

    Starting backup at 26-AUG-21
    RMAN-00571: ===========================================================
    RMAN-00569: =============== ERROR MESSAGE STACK FOLLOWS ===============
    RMAN-00571: ===========================================================
    RMAN-03002: failure of backup command at 08/26/2021 16:56:00
    RMAN-03014: implicit resync of recovery catalog failed
    RMAN-06428: recovery catalog is not installed
    ```

    The backup fails, as it should.

7. Exit RMAN.

    ```
    RMAN> <copy>EXIT</copy>

    Recovery Manager complete.
    ```


8. Connect to the recovery catalog database as the catalog owner through RMAN.

    ```
    $ <copy>rman CATALOG catowner/password@PDB19</copy>

    connected to recovery catalog database
    ```

9. Drop the recovery catalog.

    ```
    RMAN> <copy>DROP CATALOG;</copy>

    recovery catalog owner is CATOWNER
    enter DROP CATALOG command again to confirm catalog removal
    ```

10. Confirm that you want to drop the recovery catalog by repeating the command.

    ```
    RMAN> <copy>DROP CATALOG;</copy>

    recovery catalog dropped
    ```

11. Exit RMAN.

    ```
    RMAN> <copy>EXIT</copy>

    Recovery Manager complete.
    ```

## Task 11: Restore your environment

Disable `ARCHIVELOG` mode on CDB1 and clean up the PDBs in CDB1.

1. Run the `disable_ARCHIVELOG.sh` shell script to disable `ARCHIVELOG` mode. Enter **CDB1** at the prompt.

    ```
    $ <copy>$HOME/labs/19cnf/disable_ARCHIVELOG.sh</copy>
    CDB1
    ```
2. Run the `cleanup_PDBs_in_CDB1.sh` shell script to recreate PDB1 and remove other PDBs in CDB1 if they exist. You can ignore any error messages.

    ```
    $ <copy>$HOME/labs/19cnf/cleanup_PDBs_in_CDB1.sh</copy>
    ```

3. Close the terminal window.

    ```
    $ <copy>exit</copy>
    ```


## Learn More

- [Database New Features Guide (Release 19c)](https://docs.oracle.com/en/database/oracle/oracle-database/19/newft/preface.html#GUID-E012DF0F-432D-4C03-A4C8-55420CB185F3)
- [Managing a Recovery Catalog](https://docs.oracle.com/en/database/oracle/oracle-database/19/bradv/managing-recovery-catalog.html#GUID-E836E243-6620-495B-ACFB-AC0001EF4E89)


## Acknowledgements

- **Author** - Dominique Jeunot, Consulting User Assistance Developer
- **Contributor** - Jody Glover, Principal User Assistance Developer
- **Last Updated By/Date** - Matthew McDaniel, Austin Specialists Hub, September 22 2021
