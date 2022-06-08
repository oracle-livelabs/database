# Initialize Your Environment

## Introduction

During the workshop, you use two Linux compute instances named `workshop-staged` and `workshop-installed`. Both compute instances have a noVNC desktop, which provides an easy-to-use interface. You are automatically signed in to these compute instances as the `oracle` user.

- The `workshop-staged` compute instance has the Oracle Database 19c installer files (release 19.12) staged on it. Only the **Install Oracle Database 19c with Automatic Root Script Execution** lab uses this compute instance. The rest of the labs use the `workshop-installed` compute instance.
- The `workshop-installed` compute instance has Oracle Database 19c (release 19.12) already installed on it with two CDBs (CDB1 and CDB2). CDB1 has one pluggable database named PDB1 with sample data. CDB2 has no PDBs. CDB1, PDB1, and CDB2 use the default listener, LISTENER. The listener and the database instances automatically start up on boot.

In this lab, you verify that the listener on the `workshop-installed` compute instance is started and download the lab files.

Estimated Time: 5 minutes

Watch the video below for a quick walk through of the lab.

[](youtube:AzWNrlQ3_uo)

### Objectives

In this lab, you will:

- Verify that the default listener (LISTENER) is started on the `workshop-installed` compute instance
- Verify that you can connect to CDB1, PDB1, and CDB2 on the `workshop-installed` compute instance
- Download the lab files onto the `workshop-installed` compute instance

### Prerequisites

This lab assumes that you have:

- Obtained and signed in to your `workshop-installed` compute instance


## Task 1: Verify that the default listener (LISTENER) is started on the `workshop-installed` compute instance

> **NOTE:** Unless otherwise stated, all passwords will be `Ora4U_1234`. When copying and pasting a command that includes a password, please replace the word `password` with `Ora4U_1234`. This only applies to instances created through OCI Resource Manager with our provided terraform scripts.

1. On the desktop of your `workshop-installed` compute instance, open a terminal window. You are signed in to the Linux operating system as the `oracle` user.

2. Set the Oracle environment variables. At the prompt, enter **CDB1**.

    ```
    $ <copy>. oraenv</copy>
    CDB1
    ```

3. Use the Listener Control Utility to verify that the default listener is started. Look for `status READY` for CDB1, PDB1, and CDB2 in the Services Summary.

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

4. If the default listener is not started, run the following command to start it.

    ```
    LSNRCTL> <copy>lsnrctl start</copy>
    ```

## Task 2: Verify that you can connect to CDB1, PDB1, and CDB2 on the `workshop-installed` compute instance

1. Using SQL*Plus, test that you can connect to CDB1 as the `SYS` user. If you have the same output as below, you are connected to CDB1.

    ```
    $ <copy>sqlplus / as sysdba</copy>

    SQL*Plus: Release 19.0.0.0.0 - Production on Wed Sep 1 18:14:45 2021
    Version 19.12.0.0.0

    Copyright (c) 1982, 2021, Oracle.  All rights reserved.

    Connected to:
    Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    Version 19.12.0.0.0
    ```

2. Test that you can connect to PDB1. If you have the same output as below, you are connected to PDB1.

    ```
    SQL> <copy>alter session set container = PDB1;</copy>

    Session altered.
    ```

3. Exit SQL*Plus.

    ```
    SQL> <copy>exit</copy>

    Disconnected from Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    Version 19.12.0.0.0
    ```

4. Set the Oracle environment variables. At the prompt, enter **CDB2**.

    ```
    $ <copy>. oraenv</copy>
    CDB2
    ```

5. Using SQL*Plus, test that you can connect to CDB2. If you have the same output as below, you are connected to CDB2.

    ```
    $ <copy>sqlplus / as sysdba</copy>

    SQL*Plus: Release 19.0.0.0.0 - Production on Wed Sep 1 18:18:09 2021
    Version 19.12.0.0.0

    Copyright (c) 1982, 2021, Oracle.  All rights reserved.

    Connected to:
    Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    Version 19.12.0.0.0
    ```

6. Exit SQL*Plus.

    ```
    SQL> <copy>exit</copy>
    Disconnected from Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    Version 19.12.0.0.0
    ```

## Task 3: Download the lab files onto the `workshop-installed` compute instance

1. Run the following commands to download the lab files to a new `/home/oracle/labs/19cnf` directory. The last command lists the lab files.

    ```
    $ <copy>mkdir -p ~/labs/19cnf</copy>
    $ <copy>cd ~/labs/19cnf</copy>
    $ <copy>wget https://objectstorage.us-ashburn-1.oraclecloud.com/p/VEKec7t0mGwBkJX92Jn0nMptuXIlEpJ5XJA-A6C9PymRgY2LhKbjWqHeB5rVBbaV/n/c4u04/b/livelabsfiles/o/data-management-library-files/19cnf-lab-files.zip</copy>
    $ <copy>unzip -q 19cnf-lab-files.zip</copy>
    $ <copy>chmod -R +x ~/labs/19cnf</copy>
    $ <copy>ls -an</copy>
    ```

2. Close the terminal window.

    ```
    $ <copy>exit</copy>
    ```

## Appendix A: Restore your lab files

To restore one or more of your lab files on your `workshop-installed` compute instance, follow these steps:

1. Open a terminal window.

2. Run the following commands.

    ```
    $ <copy>cd ~/labs/19cnf</copy>
    $ <copy>unzip -o 19cnf-lab-files.zip</copy>
    $ <copy>chmod -R +x ~/labs/19cnf</copy>
    $ <copy>ls -an</copy>
    ```


## Acknowledgements

- **Author**- Jody Glover, Consulting User Assistance Developer, Database Development
- **Last Updated By/Date** - Jody Glover, Consulting User Assistance Developer, Database Development, September 21 2021
