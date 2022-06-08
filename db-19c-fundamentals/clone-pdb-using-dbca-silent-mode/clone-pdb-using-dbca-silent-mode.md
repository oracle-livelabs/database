# Clone a PDB from a Remote CDB by Using DBCA in Silent Mode

## Introduction
Starting in Oracle Database 19c, you can use the Oracle Database Configuration Assistant (DBCA) tool to create a clone of a PDB that resides in a remote CDB (a different CDB than the one in which you are creating the clone). To do this, you use the `-createPluggableDatabase` command in DBCA with the new parameter called `-createFromRemotePDB`. Before you can clone a PDB to another CDB, you need to put your CDBs into `ARCHIVELOG` mode.

In this lab, you clone PDB1 from CDB1 as PDB2 in CDB2. Use the `workshop-installed` compute instance.

Estimated Time: 20 minutes

Watch the video below for a quick walk through of the lab.

[](youtube:iVwpljD1tpE)

### Objectives

In this lab, you will:

- Prepare your environment
- Create a common user and grant it privileges
- Use DBCA to clone a remote PDB from a CDB
- Verify that PDB1 is cloned and that `HR.EMPLOYEES` exists in PDB2
- Reset your environment

### Prerequisites

This lab assumes you have:
- Obtained and signed in to your `workshop-installed` compute instance.

## Task 1: Prepare your environment

> **NOTE:** Unless otherwise stated, all passwords will be `Ora4U_1234`. When copying and pasting a command that includes a password, please replace the word `password` with `Ora4U_1234`. This only applies to instances created through OCI Resource Manager with our provided terraform scripts.

To prepare your environment, enable `ARCHIVELOG` mode on CDB1 and CDB2, verify that the default listener is started, and verify that PDB1 has sample data.

1. Open a terminal window on the desktop.

2. Run the `enable_ARCHIVELOG.sh` script and enter **CDB1** at the prompt to enable `ARCHIVELOG` mode on CDB1. The error  message at the beginning of the script is expected if the CDB is already shut down. You can ignore it.

    ```
    $ <copy>$HOME/labs/19cnf/enable_ARCHIVELOG.sh</copy>
    CDB1
    ```

3. Run the `enable_ARCHIVELOG.sh` script again, and this time, enter **CDB2** at the prompt to enable `ARCHIVELOG` mode on CDB2.

    ```
    $ <copy>$HOME/labs/19cnf/enable_ARCHIVELOG.sh</copy>
    CDB2
    ```

4. Set the Oracle environment variables. At the prompt, enter **CDB1**.

    ```
    $ <copy>. oraenv</copy>
    CDB1
    ```

5. Use the Listener Control Utility to verify whether the default listener (LISTENER) is started. Look for `status READY` for CDB1, PDB1, and CDB2 in the Services Summary.

    ```
    LSNRCTL> <copy>lsnrctl status</copy>

    LSNRCTL for Linux: Version 19.0.0.0.0 - Production on 19-AUG-2021 19:34:04

    Copyright (c) 1991, 2021, Oracle.  All rights reserved.

    Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=workshop-installed.livelabs.oraclevcn.com)(PORT=1521)))
    STATUS of the LISTENER
    ------------------------
    Alias                     LISTENER
    Version                   TNSLSNR for Linux: Version 19.0.0.0.0 - Production
    Start Date                19-AUG-2021 18:58:56
    Uptime                    0 days 0 hr. 35 min. 8 sec
    Trace Level               off
    Security                  ON: Local OS Authentication
    SNMP                      OFF
    Listener Parameter File   /u01/app/oracle/product/19c/dbhome_1/network/admin/listener.ora
    Listener Log File         /u01/app/oracle/diag/tnslsnr/workshop-installed/listener/alert/log.xml
    Listening Endpoints Summary...
      (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=workshop-installed.livelabs.oraclevcn.com)(PORT=1521)))
      (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=EXTPROC1521)))
      (DESCRIPTION=(ADDRESS=(PROTOCOL=tcps)(HOST=workshop-installed.livelabs.oraclevcn.com)(PORT=5504))(Security=(my_wallet_directory=/u01/app/oracle/product/19c/dbhome_1/admin/CDB1/xdb_wallet))(Presentation=HTTP)(Session=RAW))
      (DESCRIPTION=(ADDRESS=(PROTOCOL=tcps)(HOST=workshop-installed.livelabs.oraclevcn.com)(PORT=5500))(Security=(my_wallet_directory=/u01/app/oracle/product/19c/dbhome_1/admin/CDB1/xdb_wallet))(Presentation=HTTP)(Session=RAW))
      (DESCRIPTION=(ADDRESS=(PROTOCOL=tcps)(HOST=workshop-installed.livelabs.oraclevcn.com)(PORT=5501))(Security=(my_wallet_directory=/u01/app/oracle/product/19c/dbhome_1/admin/CDB2/xdb_wallet))(Presentation=HTTP)(Session=RAW))
    Services Summary...
    Service "CDB1.livelabs.oraclevcn.com" has 1 instance(s).
      Instance "CDB1", status READY, has 1 handler(s) for this service...
    Service "CDB1XDB.livelabs.oraclevcn.com" has 1 instance(s).
      Instance "CDB1", status READY, has 1 handler(s) for this service...
    Service "CDB2.livelabs.oraclevcn.com" has 1 instance(s).
      Instance "CDB2", status READY, has 1 handler(s) for this service...
    Service "CDB2XDB.livelabs.oraclevcn.com" has 1 instance(s).
      Instance "CDB2", status READY, has 1 handler(s) for this service...
    Service "c9d86333ac737d59e0536800000ad4f1.livelabs.oraclevcn.com" has 1 instance(s).
      Instance "CDB1", status READY, has 1 handler(s) for this service...
    Service "pdb1.livelabs.oraclevcn.com" has 1 instance(s).
      Instance "CDB1", status READY, has 1 handler(s) for this service...
    The command completed successfully
    ```

6. If the default listener is not started, start it now.

    ```
    $ <copy>lsnrctl start</copy>
    ```

7. Connect to CDB1 as the `SYS` user.

    ```
    $ <copy>sqlplus / as sysdba</copy>
    ```

8. Open PDB1. If PDB1 is already open, the results will say so; otherwise, PDB1 is opened.

    ```
    SQL> <copy>alter pluggable database PDB1 open;</copy>

    Pluggable database altered.
    ```

9. Connect to PDB1.

    ```
    SQL> <copy>alter session set container = PDB1;</copy>

    Session altered.
    ```

10. Query the `HR.EMPLOYEES` table. The result shows that the table exists and has 107 rows.

    After cloning PDB1 on CDB2 in a later step, the new PDB should also contain `HR.EMPLOYEES`.

    ```
    SQL> <copy>SELECT count(*) FROM HR.EMPLOYEES;</copy>

      COUNT(*)
    ----------
          107
    ```

11. (Optional) If in the previous step you find that you do not have an `HR.EMPLOYEES` table, run the `hr_main.sql` script to create the HR user and `EMPLOYEES` table in `PDB1`. After running the script, connect to CDB1 as the `SYS` user. Please note the use of `password`.

    ```
    SQL> <copy>@/home/oracle/labs/19cnf/hr_main.sql password USERS TEMP $ORACLE_HOME/demo/schema/log/</copy>
    ```


## Task 2: Create a common user and grant it privileges to clone a database

A common user is a database user that has the same identity in the `root` container and in every existing and future pluggable database (PDB). Every common user can connect to and perform operations within the `root`, and within any PDB in which it has privileges. In this task, we create a common user called `c##remote_user`, which we will later specify in the `-createPluggableDatabase` command as the database link user of the remote PDB.

1. Connect to CDB1 as the `SYS` user.

    ```
    SQL> <copy>CONNECT sys/password@CDB1 as sysdba</copy>
    Connected.
    ```


2. Create a common user named `c##remote_user` in CDB1.

    ```
    SQL> <copy>CREATE USER c##remote_user IDENTIFIED BY password CONTAINER=ALL;</copy>

    User created.
    ```

3. Grant the user the necessary privileges for creating a new PDB.

    ```
    SQL> <copy>GRANT create session, create pluggable database TO c##remote_user CONTAINER=ALL;</copy>

    Grant succeeded.
    ```

4. Exit SQL*Plus.

    ```
    SQL> <copy>exit</copy>
    ```

## Task 3: Use DBCA to clone a remote PDB from a CDB

In this task, you use DBCA in silent mode to clone PDB1 on CDB2 as PDB2.

1. Run the `-createPluggableDatabase` command in DBCA in silent mode to clone PDB1 on CDB2 as PDB2. Please note the use of `password`.

    *This is the new feature!*

    ```
    $ <copy>dbca -silent \
    -createPluggableDatabase \
    -pdbName PDB2 \
    -sourceDB CDB2 \
    -createFromRemotePDB \
    -remotePDBName PDB1 \
    -remoteDBConnString CDB1 \
    -remoteDBSYSDBAUserName SYS \
    -remoteDBSYSDBAUserPassword password \
    -dbLinkUsername c##remote_user \
    -dbLinkUserPassword password</copy>

    Create pluggable database using remote clone operation
    100% complete
    Pluggable database "PDB2" plugged successfully.
    Look at the log file "/u01/app/oracle/cfgtoollogs/dbca/CDB2/PDB2/CDB2.log" for further details.
    ```

2. Review the cloning log.

    ```
    $ <copy>cat /u01/app/oracle/cfgtoollogs/dbca/CDB2/PDB2/CDB2.log</copy>
    ```

## Task 4: Verify that PDB1 is cloned and that `HR.EMPLOYEES` exists in PDB2

1. Set the Oracle environment variables. At the prompt, enter **CDB2**.

    ```
    $ <copy>. oraenv</copy>
    CDB2
    ```

2. Connect to CDB2 as the `SYS` user.

    ```
    $ <copy>sqlplus / as sysdba</copy>
    ```

2. Display the list of PDBs in CDB2 to verify that PDB2 exists.

    ```
    SQL> <copy>show pdbs</copy>

    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
    ------ ------------------------------ ---------- ----------
         2 PDB$SEED                       READ ONLY  NO
         3 PDB2                           READ WRITE NO
    ```

3. Connect to PDB2.

    ```
    SQL> <copy>alter session set container = PDB2;</copy>

    Session altered.
    ```

4. Check that PDB2 has the `HR.EMPLOYEES` table. This command helps us to verify that PDB2 is a clone of PDB1 and its contents. The query result shows 107 rows.

    ```
    SQL> <copy>SELECT count(*) FROM HR.EMPLOYEES;</copy>

    COUNT(*)
    ----------
           107
    ```

5. Exit SQL*Plus.

    ```
    SQL> <copy>exit</copy>
    ```

## Task 5: Reset your environment

1. Delete PDB2.

    ```
    $ <copy>$ORACLE_HOME/bin/dbca -silent -deletePluggableDatabase -sourceDB CDB2 -pdbName PDB2</copy>

    Prepare for db operation
    25% complete
    Deleting Pluggable Database
    40% complete
    85% complete
    92% complete
    100% complete
    Pluggable database "PDB2" deleted successfully.
    Look at the log file "/u01/app/oracle/cfgtoollogs/dbca/CDB2/PDB2/CDB20.log" for further details.
    ```

2. Run the `disable_ARCHIVELOG.sh` script and enter **CDB1** at the prompt to disable `ARCHIVELOG` mode on CDB1.

    ```
    $ <copy>$HOME/labs/19cnf/disable_ARCHIVELOG.sh</copy>
    CDB1
    ```

3. Run the `disable_ARCHIVELOG.sh` script again, and this time, enter **CDB2** at the prompt to disable `ARCHIVELOG` mode on CDB2.

    ```
    $ <copy>$HOME/labs/19cnf/disable_ARCHIVELOG.sh</copy>
    CDB2
    ```

4. Set the Oracle environment variables. At the prompt, enter **CDB1**.

    ```
    $ <copy>. oraenv</copy>
    CDB1
    ```

5. Connect to CDB1 as the `SYS` user.

    ```
    $ <copy>sqlplus / as sysdba</copy>
    ```

6. Drop the common user named `c##remote_user` that you created earlier.

    ```
    SQL> <copy>DROP USER c##remote_user CASCADE;</copy>

    User dropped.
    ```

7. Exit SQL*Plus.

    ```
    SQL> <copy>exit</copy>
    ```

8. Close the terminal window.

    ```
    $ <copy>exit</copy>
    ```



## Learn More

- [New Features in Oracle Database 19c](https://docs.oracle.com/en/database/oracle/oracle-database/19/newft/preface.html#GUID-E012DF0F-432D-4C03-A4C8-55420CB185F3)
- [DBCA Silent Mode Commands](https://docs.oracle.com/en/database/oracle/oracle-database/19/admin/creating-and-configuring-an-oracle-database.html#GUID-EC3C396B-6FFB-4957-BC73-1BE8F4FD852E)
- [Cloning a PDB or non-CDB](https://docs.oracle.com/en/database/oracle/oracle-database/19/multi/cloning-a-pdb.html#GUID-05702CEB-A43C-452C-8081-4CA68DDA8007)

## Acknowledgements

- **Author** - Dominique Jeunot, Consulting User Assistance Developer
- **Contributor** - Jody Glover, Consulting User Assistance Developer, Database Development
- **Last Updated By/Date** - Kherington Barley, Austin Specialist Hub, September 21 2021
