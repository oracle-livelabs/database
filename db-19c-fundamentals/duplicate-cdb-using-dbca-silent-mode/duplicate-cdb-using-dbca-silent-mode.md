# Duplicate a CDB by Using DBCA in Silent Mode

## Introduction

Starting with Oracle Database 19c, you can duplicate a container database (CDB) by using the `createDuplicateDB` command in silent mode in Database Configuration Assistant (DBCA). A CDB must be in `ARCHIVELOG` mode before you can duplicate it by using DBCA in silent mode.

In this lab, you duplicate CDB1 twice by using the `createDuplicateDB` command of DBCA in silent mode. First, you duplicate CDB1 as a single individual database named DUPCDB1 with a basic configuration that uses the default listener. Next, you duplicate CDB1 as OMFCDB1 with Oracle Managed Files (OMF) enabled and create a new listener at the same time. Oracle Managed Files simplifies the creation of databases as Oracle does all OS operations and file naming. Use the `workshop-installed` compute instance.

Estimated Time: 25 minutes



### Objectives

In this lab, you will:

- Prepare your environment
- Use DBCA to duplicate CDB1 as a single individual database named DUPCDB1
- Use DBCA to duplicate CDB1 as OMFCDB1 with Oracle Managed Files enabled
- Restore your environment

### Prerequisites

This lab assumes you have:
- Obtained and signed in to your `workshop-installed` compute instance.

## Task 1: Prepare your environment

> **NOTE:** Unless otherwise stated, all passwords will be `Ora4U_1234`. When copying and pasting a command that includes a password, please replace the word `password` with `Ora4U_1234`. This only applies to instances created through OCI Resource Manager with our provided terraform scripts.

To prepare your environment, enable `ARCHIVELOG` mode on CDB1, verify that the default listener is started, and verify that PDB1 has sample data.

1. Open a terminal window on the desktop.

2. Run the `enable_ARCHIVELOG.sh` script and enter **CDB1** at the prompt.

    ```
    $ <copy>$HOME/labs/19cnf/enable_ARCHIVELOG.sh</copy>
    CDB1
    ```

3. Set the Oracle environment variables. At the prompt, enter **CDB1**.

    ```
    $ <copy>. oraenv</copy>
    CDB1
    ```

4. Use the Listener Control Utility to verify whether the default listener (LISTENER) is started. Look for `status READY` for CDB1, PDB1, and CDB2 in the Services Summary.

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

5. If the default listener is not started, start it now.

    ```
    $ <copy>lsnrctl start</copy>
    ```

6. Connect to CDB1 as the `SYS` user.

    ```
    $ <copy>sqlplus / as sysdba</copy>
    ```

7. Open PDB1. If PDB1 is already open, the results will say so; otherwise, PDB1 is opened.

    ```
    SQL> <copy>alter pluggable database PDB1 open;</copy>

    Pluggable database altered.
    ```

8. Connect to PDB1.

    ```
    SQL> <copy>alter session set container = PDB1;</copy>

    Session altered.
    ```

9. Query the `HR.EMPLOYEES` table. The results show that the table exists and has 107 rows.

    After cloning PDB1 on CDB2 in a later step, the new PDB should also contain `HR.EMPLOYEES`.

    ```
    SQL> <copy>SELECT count(*) FROM HR.EMPLOYEES;</copy>

      COUNT(*)
    ----------
          107
    ```

10. (Optional) If in the previous step you find that you do not have an `HR.EMPLOYEES` table or you have a different result, run the `hr_main.sql` script to create the HR user and `EMPLOYEES` table in `PDB1`.

    ```
    SQL> <copy>@/home/oracle/labs/19cnf/hr_main.sql password USERS TEMP $ORACLE_HOME/demo/schema/log/</copy>
    ```

11. Exit SQL*Plus.

    ```
    SQL> <copy>EXIT</copy>
    ```

## Task 2: Use DBCA to duplicate CDB1 as a single individual database named DUPCDB1

In this task, you use the ``-createDuplicateDB`` command in DBCA to duplicate CDB1 as DUPCDB1. The database configuration type is set to `SINGLE`, which instructs DBCA to create a single individual database. The storage type is set to file system (FS). Because a listener is not specified in the DBCA command, DBCA automatically configures the default listener, LISTENER, for both DUPCDB1 and PDB1. After the DBCA command is finished running, verify that DUPCDB1 exists and contains PDB1, that PDB1 contains sample data, and that both DUPCDB1 and PDB1 use the default listener.

1. Run the `-createDuplicateDB` command. This step takes a few minutes to complete. Please note the use of `password`.

    *This is the new feature!*

    ```
    $ <copy>dbca -silent \
    -createDuplicateDB \
    -primaryDBConnectionString workshop-installed.livelabs.oraclevcn.com:1521/CDB1.livelabs.oraclevcn.com \
    -sysPassword password \
    -gdbName DUPCDB1.livelabs.oraclevnc.com \
    -sid DUPCDB1 \
    -datafileDestination /u01/app/oracle/oradata \
    -databaseConfigType SINGLE \
    -storageType FS</copy>

    Prepare for db operation
    22% complete
    Listener config step
    44% complete
    Auxiliary instance creation
    67% complete
    RMAN duplicate
    89% complete
    Post duplicate database operations
    100% complete

    Look at the log file "/u01/app/oracle/cfgtoollogs/dbca/DUPCDB1/DUPCDB1.log" for further details.
    ```

2. Set the Oracle environment variables. At the prompt, enter **DUPCDB1**.

    ```
    $ <copy>. oraenv</copy>
    DUPCDB1
    ```

3. Connect to DUPCDB1 as the `SYS` user.

    ```
    SQL> <copy>sqlplus / as sysdba</copy>
    ```

4. List the PDBs in DUPCDB1. The results indicate that PDB1 exists.

    ```
    SQL> <copy>SHOW PDBS</copy>

    CON_ID     CON_NAME                        OPEN MODE  RESTRICTED
    ---------- ------------------------------  ---------- ----------
             2 PDB$SEED                        READ ONLY  NO
             3 PDB1                            READ WRITE NO
    ```

5. View the list of data files. Make note of how the files are named. Also notice that the data files for PDB1 are included.

    ```
    SQL> <copy>COL name FORMAT A78</copy>
    SQL> <copy>SELECT name FROM v$datafile;</copy>

    NAME
    ------------------------------------------------------------------------------
    /u01/app/oracle/oradata/DUPCDB1/system01.dbf
    /u01/app/oracle/oradata/DUPCDB1/sysaux01.dbf
    /u01/app/oracle/oradata/DUPCDB1/undotbs01.dbf
    /u01/app/oracle/oradata/DUPCDB1/pdbseed/system01.dbf
    /u01/app/oracle/oradata/DUPCDB1/pdbseed/sysaux01.dbf
    /u01/app/oracle/oradata/DUPCDB1/users01.dbf
    /u01/app/oracle/oradata/DUPCDB1/pdbseed/undotbs01.dbf
    /u01/app/oracle/oradata/DUPCDB1/PDB1/system01.dbf
    /u01/app/oracle/oradata/DUPCDB1/PDB1/sysaux01.dbf
    /u01/app/oracle/oradata/DUPCDB1/PDB1/undotbs01.dbf
    /u01/app/oracle/oradata/DUPCDB1/PDB1/users01.dbf

    11 rows selected.
    ```

6. Connect to PDB1 as the `HR` user.

    ```
    SQL> <copy>connect HR/password@PDB1</copy>
    Connected.
    ```

7. Verify that PDB1 has an `HR.EMPLOYEES` table with data in it.

    ```
    SQL> <copy>SELECT count(*) FROM employees;</copy>

      COUNT(*)
    ----------
           107
    ```

8. Exit SQL*Plus

    ```
    SQL> <copy>EXIT</copy>
    ```

9. View the status of the default listener. Notice that both DUPCDB1 and PDB1 are listed as a service.

    ```
    $ <copy>lsnrctl status</copy>

    LSNRCTL for Linux: Version 19.0.0.0.0 - Production on 25-AUG-2021 21:36:51

    Copyright (c) 1991, 2021, Oracle.  All rights reserved.

    Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=workshop-installed.livelabs.oraclevcn.com)(PORT=1521)))
    STATUS of the LISTENER
    ------------------------
    Alias                     LISTENER
    Version                   TNSLSNR for Linux: Version 19.0.0.0.0 - Production
    Start Date                24-AUG-2021 20:18:11
    Uptime                    1 days 1 hr. 18 min. 40 sec
    Trace Level               off
    Security                  ON: Local OS Authentication
    SNMP                      OFF
    Listener Parameter File   /u01/app/oracle/product/19c/dbhome_1/network/admin/listener.ora
    Listener Log File         /u01/app/oracle/diag/tnslsnr/workshop-installed/listener/alert/log.xml
    Listening Endpoints Summary...
      (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=workshop-installed.livelabs.oraclevcn.com)(PORT=1521)))
      (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=EXTPROC1521)))
      (DESCRIPTION=(ADDRESS=(PROTOCOL=tcps)(HOST=workshop-installed.livelabs.oraclevcn.com)(PORT=5501))(Security=(my_wallet_directory=/u01/app/oracle/admin/CDB2/xdb_wallet))(Presentation=HTTP)(Session=RAW))
      (DESCRIPTION=(ADDRESS=(PROTOCOL=tcps)(HOST=workshop-installed.livelabs.oraclevcn.com)(PORT=5500))(Security=(my_wallet_directory=/u01/app/oracle/admin/CDB1/xdb_wallet))(Presentation=HTTP)(Session=RAW))
      (DESCRIPTION=(ADDRESS=(PROTOCOL=tcps)(HOST=workshop-installed.livelabs.oraclevcn.com)(PORT=5504))(Security=(my_wallet_directory=/u01/app/oracle/admin/CDB1/xdb_wallet))(Presentation=HTTP)(Session=RAW))
    Services Summary...
    Service "CDB1.livelabs.oraclevcn.com" has 1 instance(s).
      Instance "CDB1", status READY, has 1 handler(s) for this service...
    Service "CDB1XDB.livelabs.oraclevcn.com" has 1 instance(s).
      Instance "CDB1", status READY, has 1 handler(s) for this service...
    Service "CDB1XDB.livelabs.oraclevnc.com" has 1 instance(s).
      Instance "DUPCDB1", status READY, has 1 handler(s) for this service...
    Service "CDB2.livelabs.oraclevcn.com" has 1 instance(s).
      Instance "CDB2", status READY, has 1 handler(s) for this service...
    Service "CDB2XDB.livelabs.oraclevcn.com" has 1 instance(s).
      Instance "CDB2", status READY, has 1 handler(s) for this service...
    Service "DUPCDB1.livelabs.oraclevnc.com" has 1 instance(s).
      Instance "DUPCDB1", status READY, has 1 handler(s) for this service...
    Service "c9d86333ac737d59e0536800000ad4f1.livelabs.oraclevcn.com" has 1 instance(s).
      Instance "CDB1", status READY, has 1 handler(s) for this service...
     Service "c9d86333ac737d59e0536800000ad4f1.livelabs.oraclevnc.com" has 1 instance(s).
      Instance "DUPCDB1", status READY, has 1 handler(s) for this service...
    Service "pdb1.livelabs.oraclevcn.com" has 1 instance(s).
      Instance "CDB1", status READY, has 1 handler(s) for this service...
    Service "pdb1.livelabs.oraclevnc.com" has 1 instance(s).
      Instance "DUPCDB1", status READY, has 1 handler(s) for this service...
    The command completed successfully
    ```

## Task 3: Use DBCA to duplicate CDB1 as OMFCDB1 with Oracle Managed Files enabled

Execute the `-createDuplicateDB` command again to duplicate CDB1 as a single individual database called OMFCDB1. This time, enable Oracle Managed Files and create a dynamic listener called LISTENER_OMFCDB1 that listens on port 1565.


1. Launch DBCA in silent mode to duplicate CDB1 as OMFCDB1. This step takes a few minutes to complete. Please note the use of `password`.

    ```
    $ <copy>dbca -silent \
    -createDuplicateDB \
    -primaryDBConnectionString workshop-installed.livelabs.oraclevcn.com:1521/CDB1.livelabs.oraclevcn.com \
    -sysPassword password \
    -gdbName OMFCDB1.livelabs.oraclevnc.com \
    -sid OMFCDB1 \
    -datafileDestination /u01/app/oracle/oradata \
    -databaseConfigType SINGLE \
    -storageType FS \
    -createListener LISTENER_OMFCDB1:1565 \
    -useOMF true</copy>

    Prepare for db operation
    22% complete
    Listener config step
    44% complete
    Auxiliary instance creation
    67% complete
    RMAN duplicate
    89% complete
    Post duplicate database operations
    100% complete

    Look at the log file "/u01/app/oracle/cfgtoollogs/dbca/OMFCDB1/OMFCDB1.log" for further details.
    ```

2. View the `listener.ora` file and verify that DBCA added the listener information for `LISTENER_OMFCDB1`.

    Dynamic service registration does not make use of the `listener.ora` file. However, your listeners must be listed in this file if you want to manage them with the Listener Control Utility.

    ```
    $ <copy>cat $ORACLE_HOME/network/admin/listener.ora</copy>

    ...
    LISTENER_OMFCDB1 =
     (ADDRESS_LIST =
        (ADDRESS = (PROTOCOL = TCP)(HOST = workshop-installed.livelabs.oraclevcn.com)(PORT = 1565))
     )
    ...
    ```

3. View the status of `LISTENER_OMFCDB1`. OMFCDB1 should be listed as a service.

    ```
    $ <copy>lsnrctl status LISTENER_OMFCDB1</copy>

    LSNRCTL for Linux: Version 19.0.0.0.0 - Production on 12-AUG-2021 15:23:52

    Copyright (c) 1991, 2021, Oracle.  All rights reserved.

    Connecting to (ADDRESS=(PROTOCOL=TCP)(HOST=workshop-installed.livelabs.oraclevcn.com)(PORT=1565))
    STATUS of the LISTENER
    ------------------------
    Alias                     LISTENER_OMFCDB1
    Version                   TNSLSNR for Linux: Version 19.0.0.0.0 - Production
    Start Date                12-AUG-2021 15:09:06
    Uptime                    0 days 0 hr. 14 min. 46 sec
    Trace Level               off
    Security                  ON: Local OS Authentication
    SNMP                      OFF
    Listener Parameter File   /u01/app/oracle/product/19c/dbhome_1/network/admin/listener.ora
    Listener Log File         /u01/app/oracle/diag/tnslsnr/workshop-installed/listener_omfcdb1/alert/log.xml
    Listening Endpoints Summary...
    (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=workshop-installed.livelabs.oraclevcn.com)(PORT=1565)))
    Services Summary...
    Service "OMFCDB1" has 1 instance(s).
    Instance "OMFCDB1", status UNKNOWN, has 1 handler(s) for this service...
    The command completed successfully
    ```

4. Set the Oracle environment variables. At the prompt, enter **OMFCDB1**.

    ```
    $ <copy>. oraenv</copy>
    OMFCDB1
    ```

5. Connect to OMFCDB1 as the `SYS` user.

    ```
    $ <copy>sqlplus / as sysdba</copy>
    ```

6. Verify that DBCA configured the `LOCAL_LISTENER` parameter to `LISTENER_OMFCDB1`. By default, DBCA uses the naming convention `LISTENER_<SID>` when configuring the `LOCAL_LISTENER` parameter value. That is why we used the name `LISTENER_OMFCDB1` when running the `-createDuplicateDB` command in DBCA. Had we used a different name, we would need to update the `LOCAL_LISTENER` parameter value.

    ```
    SQL> <copy>SHOW PARAMETER LOCAL_LISTENER</copy>

    NAME                                               TYPE          VALUE
    ------------------------------------ ----------- --------------------------------
    local_listener                                    string         LISTENER_OMFCDB1
    ```

7. Check if the `LOCAL_LISTENER` parameter is a static or dynamic parameter by querying the `V$PARAMETER` view. The results tell you that you can't change it's value at the session level, but you can at the system level, and the change will take effect immediately. This means that the `LOCAL_LISTENER` parameter is a dynamic system-level parameter.

    ```
    SQL> <copy>SELECT isses_modifiable, issys_modifiable FROM v$parameter
       WHERE name='local_listener';</copy>

    ISSES ISSYS_MOD
    ----- ---------
    FALSE IMMEDIATE
    ```

8. List the PDBs in OMFCDB1. The results show that PDB1 was also duplicated.

    ```
    SQL> <copy>SHOW PDBS</copy>

    CON_ID     CON_NAME                        OPEN MODE  RESTRICTED
    ---------- ------------------------------  ---------- ----------
             2 PDB$SEED                        READ ONLY  NO
             3 PDB1                            READ WRITE NO
    ```

9.  View the list of data files. Notice how the files are named when Oracle Managed Files is enabled on the CDB.

    ```
    SQL> <copy>COL name FORMAT A78</copy>
    SQL> <copy>SELECT name FROM v$datafile;</copy>

    NAME
    ------------------------------------------------------------------------------
    /u01/app/oracle/oradata/OMFCDB1/datafile/o1_mf_system_jh38hypr_.dbf
    /u01/app/oracle/oradata/OMFCDB1/datafile/o1_mf_sysaux_jh38jfsv_.dbf
    /u01/app/oracle/oradata/OMFCDB1/datafile/o1_mf_undotbs1_jh38jwvm_.dbf
    /u01/app/oracle/oradata/OMFCDB1/C6A4294A032D57BEE0534D00000AB5C1/datafile/o1_mf_system_jh38kcwc_.dbf
    /u01/app/oracle/oradata/OMFCDB1/C6A4294A032D57BEE0534D00000AB5C1/datafile/o1_mf_sysaux_jh38kly7_.dbf
    /u01/app/oracle/oradata/OMFCDB1/datafile/o1_mf_users_jh38kt16_.dbf
    /u01/app/oracle/oradata/OMFCDB1/C6A4294A032D57BEE0534D00000AB5C1/datafile/o1_mf_undotbs1_jh38kv31_.dbf
    /u01/app/oracle/oradata/OMFCDB1/C6A44DD9E86F6A1DE0534D00000ACC39/datafile/o1_mf_system_jh38ky58_.dbf
    /u01/app/oracle/oradata/OMFCDB1/C6A44DD9E86F6A1DE0534D00000ACC39/datafile/o1_mf_sysaux_jh38l57c_.dbf
    /u01/app/oracle/oradata/OMFCDB1/C6A44DD9E86F6A1DE0534D00000ACC39/datafile/o1_mf_undotbs1_jh38ld9z_.dbf
    /u01/app/oracle/oradata/OMFCDB1/C6A44DD9E86F6A1DE0534D00000ACC39/datafile/o1_mf_users_jh38lhc8_.dbf

    11 rows selected.
    ```

10. Exit SQL*Plus.

    ```
    SQL> <copy>EXIT</copy>
    ```

## Task 4: Restore your environment

To restore your environment, delete DUPCDB1 and OMFCDB1 and disable `ARCHIVELOG` mode on CDB1.

1. Use DBCA to delete DUPCDB1. Please note the use of `password`.

    ```
    $ <copy>$ORACLE_HOME/bin/dbca -silent -deleteDatabase -sourceDB DUPCDB1.livelabs.oraclevcn.com -sid DUPCDB1 -sysPassword password</copy>

    [WARNING] [DBT-19202] The Database Configuration Assistant will delete the Oracle instances and datafiles for your database. All information in the database will be destroyed.
    Prepare for db operation
    32% complete
    Connecting to database
    35% complete
    39% complete
    42% complete
    45% complete
    48% complete
    52% complete
    65% complete
    Updating network configuration files
    68% complete
    Deleting instance and datafiles
    84% complete
    100% complete
    Database deletion completed.
    Look at the log file "/u01/app/oracle/cfgtoollogs/dbca/DUPCDB1/DUPCDB10.log" for further details.
    ```

2. Use DBCA to delete OMFCDB1. Please note the use of `password`.

    ```
    $ <copy>$ORACLE_HOME/bin/dbca -silent -deleteDatabase -sourceDB OMFCDB1.livelabs.oraclevcn.com -sid OMFCDB1 -sysPassword password</copy>

    [WARNING] [DBT-19202] The Database Configuration Assistant will delete the Oracle instances and datafiles for your database. All information in the database will be destroyed.
    Prepare for db operation
    32% complete
    Connecting to database
    35% complete
    39% complete
    42% complete
    45% complete
    48% complete
    52% complete
    65% complete
    Updating network configuration files
    68% complete
    Deleting instance and datafiles
    84% complete
    100% complete
    Database deletion completed.

    Look at the log file "/u01/app/oracle/cfgtoollogs/dbca/OMFCDB1/OMFCDB10.log" for further details.
    ```

3. Remove the `/u01/app/oracle/recovery_area/DUPCDB1` directory.

    ```
    $ <copy>rm -rfv /u01/app/oracle/recovery_area/DUPCDB1</copy>
    ```

4.  Remove the `/u01/app/oracle/recovery_area/OMFCDB1` directory.

    ```
    $ <copy>rm -rfv /u01/app/oracle/recovery_area/OMFCDB1</copy>
    ```

5. Disable `ARCHIVELOG` mode on CDB1. At the prompt, enter **CDB1**.

    ```
    $ <copy>$HOME/labs/19cnf/disable_ARCHIVELOG.sh</copy>
    CDB1
    ```

6.  Replace the modified `listener.ora` file with the original. A copy of the original is stored with the lab files.

    ```
    $ <copy>cp /home/oracle/labs/19cnf/listener.ora $ORACLE_HOME/network/admin/listener.ora</copy>
    ```

7. Close the terminal window.

    ```
    $ <copy>exit</copy>
    ```



## Learn More
- [dbca -createDuplicateDB command](https://docs.oracle.com/en/database/oracle/oracle-database/19/admin/creating-and-configuring-an-oracle-database.html#GUID-7F4B1A64-5B08-425A-A62E-854542B3FD4E)
- [Using Oracle Managed Files](https://docs.oracle.com/en/database/oracle/oracle-database/19/admin/using-oracle-managed-files.html#GUID-4A3C4616-0D81-4BBA-8EAD-FCAA8AD5C15A)


## Acknowledgements
- **Primary Author** - Dominique Jeunot's, Consulting User Assistance Developer
- **Contributor** - Jody Glover, Consulting User Assistance Developer, Database Development
- **Last Updated By** - Blake Hendricks, Solutions Engineer, September 21 2021
