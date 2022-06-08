# Relocate a PDB to a Remote CDB by Using DBCA in Silent Mode

## Introduction
Starting in Oracle Database 19c, you can use the Oracle Database Configuration Assistant (DBCA) tool to relocate a PDB that resides in a remote CDB (a different CDB than the one to which you are relocating). To do this, you use the new `-relocatePDB` command in DBCA. Before you can relocate a PDB from one CDB to another, you need to put your CDBs into `ARCHIVELOG` mode.

In this lab, you relocate PDB1 from CDB1 to CDB2. Use the `workshop-installed` compute instance.

Estimated Time: 20 minutes

### Objectives

In this lab, you will:

- Prepare your environment
- Create a common user and grant it privileges
- Use DBCA in silent mode to relocate PDB1 from CDB1 to CDB2
- Verify that PDB1 is relocated to CDB2 and that the `HR.EMPLOYEES` table still exists in PDB1
- Relocate PDB1 back to CDB1
- Reset your environment

### Prerequisites

This lab assumes you have:
- Obtained and signed in to your `workshop-installed` compute instance.

## Task 1: Prepare your environment

> **NOTE:** Unless otherwise stated, all passwords will be `Ora4U_1234`. When copying and pasting a command that includes a password, please replace the word `password` with `Ora4U_1234`. This only applies to instances created through OCI Resource Manager with our provided terraform scripts.

To prepare your environment, enable `ARCHIVELOG` mode on CDB1 and CDB2, verify that the default listener is started, and verify that PDB1 has sample data. CDB1, PDB1, and CDB2 all use the default listener.

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

10. Query the `HR.EMPLOYEES` table. The results show that the table exists and has 107 rows. After relocating PDB1 to CDB2 in a later step, the new PDB should also contain the `HR.EMPLOYEES` table and its data.

    ```
    SQL> <copy>SELECT count(*) FROM HR.EMPLOYEES;</copy>

      COUNT(*)
    ----------
          107
    ```

11. (Optional) If in the previous step you find that you do not have an `HR.EMPLOYEES` table, run the `hr_main.sql` script to create the HR user and `EMPLOYEES` table in `PDB1`.

    ```
    SQL> <copy>@/home/oracle/labs/19cnf/hr_main.sql password USERS TEMP $ORACLE_HOME/demo/schema/log/</copy>
    ```

## Task 2: Create a common user and grant it privileges

A common user is a database user that has the same identity in the `root` container and in every existing and future pluggable database (PDB). Every common user can connect to and perform operations within the `root` and within any PDB in which it has privileges. In this task, we create a user called `c##remote_user`, which we will later specify in the `-relocatePDB` command as the database link user of the remote PDB.

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

3. Grant the user the necessary privileges to create PDBs.

    ```
    SQL> <copy>GRANT create session, create pluggable database, sysoper TO c##remote_user CONTAINER=ALL;</copy>

    Grant succeeded.
    ```

4. Exit SQL*Plus.

    ```
    SQL> <copy>exit</copy>
    ```

## Task 3: Use DBCA in silent mode to relocate PDB1 from CDB1 to CDB2

1. Run the `-relocatePDB` command in DBCA in silent mode to relocate PDB1 from CDB1 to CDB2. Please note the use of `password`.

    *This is the new feature!*

    ```
    $ <copy>dbca -silent \
    -relocatePDB \
    -remotePDBName PDB1 \
    -remoteDBConnString CDB1 \
    -sysDBAUserName SYSTEM \
    -sysDBAPassword password \
    -remoteDBSYSDBAUserName SYS \
    -remoteDBSYSDBAUserPassword password \
    -dbLinkUsername c##remote_user \
    -dbLinkUserPassword password \
    -sourceDB CDB2 \
    -pdbName PDB1</copy>

    Create pluggable database using relocate PDB operation
    100% complete
    Pluggable database "PDB1" plugged successfully.
    Look at the log file "/u01/app/oracle/cfgtoollogs/dbca/CDB2/PDB1/CDB2.log" for further details.
    ```

2. Review the relocating log.

    ```
    $ <copy>cat /u01/app/oracle/cfgtoollogs/dbca/CDB2/PDB1/CDB2.log</copy>
    ```

## Task 4: Verify that PDB1 is relocated to CDB2 and that the `HR.EMPLOYEES` table still exists in PDB1

1. Set the Oracle environment variables. At the prompt, enter **CDB2**.

    ```
    $ <copy>. oraenv</copy>
    CDB2
    ```

2. Connect to CDB2 as the `SYS` user.

    ```
    $ <copy>sqlplus / as sysdba</copy>
    ```

3. Display the list of PDBs in CDB2 to verify that PDB1 exists.

    ```
    SQL> <copy>show pdbs</copy>

    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
    ------ ------------------------------ ---------- ----------
         2 PDB$SEED                       READ ONLY  NO
         3 PDB1                           READ WRITE NO
    ```

4. Connect to PDB1 in CDB2.

    ```
    SQL> <copy>alter session set container = PDB1;</copy>

    Session altered.
    ```

5. Check that PDB1 still contains the `HR.EMPLOYEES` table with 107 rows. This command helps us verify that PDB1 is relocated with its data to CDB2.

    ```
    SQL> <copy>SELECT count(*) FROM hr.employees;</copy>

    COUNT(*)
    ----------
           107
    ```

6. Exit SQL*Plus.

    ```
    SQL> <copy>exit</copy>
    ```

## Task 5: Relocate PDB1 back to CDB1

1. Try to run the `-relocatePDB` command in DBCA in silent mode to relocate PDB1 from CDB2 back to CDB1. Please note the use of `password`.

    ```
    $ <copy>dbca -silent \
    -relocatePDB \
    -remotePDBName PDB1 \
    -remoteDBConnString CDB2 \
    -sysDBAUserName SYS \
    -sysDBAPassword password \
    -remoteDBSYSDBAUserName SYSTEM \
    -remoteDBSYSDBAUserPassword password \
    -dbLinkUsername c##remote_user \
    -dbLinkUserPassword password \
    -sourceDB CDB1 \
    -pdbName PDB1</copy>

    [FATAL] [DBT-19404] Specified database link user (C##REMOTE_USER) does not exist in the database(CDB2).

    ACTION: Specify an existing database link user.
    ```

2. Question: Why did you get an error when trying to relocate PDB1 back to CDB1?

    Answer: In preparation for the first relocation (PDB1 moving to CDB2), we created the database link user only in CDB1 because at that time, it was considered the remote CDB. But now, you are trying to move PDB1 back to CDB1, and CDB2 is considered the remote CDB. To fix the problem, you need to create the remote user in CDB2 too.

3. Set the Oracle environment variables. At the prompt, enter **CDB2**.

    ```
    $ <copy>. oraenv</copy>
    CDB2
    ```

4. Connect to CDB2 as the `SYS` user.

    ```
    $ <copy>sqlplus sys/password@CDB2 as sysdba</copy>
    ```

5. Create a common user named `c##remote_user` in CDB2.

    ```
    SQL> <copy>CREATE USER c##remote_user IDENTIFIED BY password CONTAINER=ALL;</copy>

    User created.
    ```

6. Grant `c##remote_user` the necessary privileges for creating a new PDB.

    ```
    SQL> <copy>GRANT create session, create pluggable database, sysoper TO c##remote_user CONTAINER=ALL;</copy>

    Grant succeeded.
    ```

7. Exit SQL*Plus.

    ```
    SQL> <copy>exit</copy>
    ```

8. Rerun the `-relocatePDB` command in DBCA in silent mode to relocate PDB1 from CDB2 back to CDB1. This time you shouldn't get any error messages. Please note the use of `password`.

    ```
    $ <copy>dbca -silent \
    -relocatePDB \
    -remotePDBName PDB1 \
    -remoteDBConnString CDB2 \
    -sysDBAUserName SYS \
    -sysDBAPassword password \
    -remoteDBSYSDBAUserName SYSTEM \
    -remoteDBSYSDBAUserPassword password \
    -dbLinkUsername c##remote_user \
    -dbLinkUserPassword password \
    -sourceDB CDB1 \
    -pdbName PDB1</copy>

    Create pluggable database using relocate PDB operation
    100% complete
    Pluggable database "PDB1" plugged successfully.
    Look at the log file "/u01/app/oracle/cfgtoollogs/dbca/CDB1/PDB1/CDB1.log" for further details.
    ```

9. Set the Oracle environment variables. At the prompt, enter **CDB1**.

    ```
    $ <copy>. oraenv</copy>
    CDB1
    ```

10. Connect to CDB1 as the `SYS` user.

    ```
    $ <copy>sqlplus / as sysdba</copy>
    ```

11. Display the list of PDBs in CDB1 to verify that PDB1 exists.

    ```
    SQL> <copy>show pdbs</copy>

    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
    ------ ------------------------------ ---------- ----------
         2 PDB$SEED                       READ ONLY  NO
         3 PDB1                           READ WRITE NO
    ```

12. Exit SQL*Plus.

    ```
    SQL> <copy>exit</copy>
    ```

## Task 6: Reset your environment

1. Run the `disable_ARCHIVELOG.sh` script and enter **CDB1** at the prompt to disable `ARCHIVELOG` mode on CDB1.

    ```
    $ <copy>$HOME/labs/19cnf/disable_ARCHIVELOG.sh</copy>
    CDB1
    ```

2. Run the `disable_ARCHIVELOG.sh` script again, and this time, enter **CDB2** at the prompt to disable `ARCHIVELOG` mode on CDB2.

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

8. Set the Oracle environment variables. At the prompt, enter **CDB2**.

    ```
    $ <copy>. oraenv</copy>
    CDB2
    ```

9. Connect to CDB2 as the `SYS` user.

    ```
    $ <copy>sqlplus / as sysdba</copy>
    ```

10. Drop the common user named `c##remote_user` that you created earlier.

    ```
    SQL> <copy>DROP USER c##remote_user CASCADE;</copy>

    User dropped.
    ```

11. Exit SQL*Plus.

    ```
    SQL> <copy>exit</copy>
    ```

12. Close the terminal window.

    ```
    $ <copy>exit</copy>
    ```


## Learn More

- [New Features in Oracle Database 19c](https://docs.oracle.com/en/database/oracle/oracle-database/19/newft/preface.html#GUID-E012DF0F-432D-4C03-A4C8-55420CB185F3)
- [DBCA Silent Mode Commands](https://docs.oracle.com/en/database/oracle/oracle-database/19/admin/creating-and-configuring-an-oracle-database.html#GUID-EC3C396B-6FFB-4957-BC73-1BE8F4FD852E)
- [Relocating a PDB](https://docs.oracle.com/en/database/oracle/oracle-database/19/multi/relocating-a-pdb.html#GUID-75519361-3DA2-4558-A7E5-64BC16FAFC7D)

## Acknowledgements

- **Author**- Dominique Jeunot, Consulting User Assistance Developer
- **Technical Contributor** - Jody Glover, Principal User Assistance Developer
- **Last Updated By/Date** - Kherington Barley, Austin Specialist Hub, September 21 2021
