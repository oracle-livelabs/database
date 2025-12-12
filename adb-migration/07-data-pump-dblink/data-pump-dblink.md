# Migrate with Data Pump over DB Link

## Introduction

In this lab, we will migrate the *RED* PDB to the *RUBY* ADB using Data Pump with database link.

Differently from the "file method", with a database link, you don't need to create intermediate dump files. This makes this method very fast for smaller databases as we read and load at the same time. However, there are 2 issues with database link over dump files:

* If you have LOB, a network round trip is required for reach row with a LOB. If you have millions of LOB rows and a high latency connection to ADB, this may have a significant negative impact.
* A network link import does not import metadata in parallel. On complex schemas this may have a significant negative impact.

As we are just moving the simple F1 schema, let's proceed with this method.

Estimated Time: 10 Minutes

### Objectives

In this lab, you will:

* Setup a DB link on the target ADB pointing to your source PDB.
* Import using this database link on the target database.

### Prerequisites

This lab assumes:

* You have completed Lab 1: Initialize Environment

## Task 1: Test mTLS to *RED* PDB

To create a database link from Autonomous Database to another non-ADB database, it is required to use mTLS connection.

With Mutual TLS (mTLS) both the server and the client present certificates during establishment of the connection. They mutually authenticate each other. In this case, not only the *RUBY* database wallet would be required, but also the *RED* database wallet.

All the databases used on this lab are listening also on port 1522 using mTLS. We can check that using *lsnrctl*.

1. Use the *blue* 🟦 terminal. Check that *RED* database also authenticates using mTLS.

    ``` bash
    <copy>
    . cdb23
    lsnrctl status
    </copy>

    # Be sure to hit RETURN
    ```

    * In the *Listener Endpoints Summary* you can see that the listener is also running on port *1522* using *TCPS*.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    $ . cdb23
    $ lsnrctl status

    LSNRCTL for Linux: Version 23.0.0.0.0 - for Oracle Cloud and Engineered Systems on 02-JUL-2025 14:04:10

    Copyright (c) 1991, 2025, Oracle.  All rights reserved.

    Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=holserv1.livelabs.oraclevcn.com)(PORT=1521)))
    STATUS of the LISTENER
    ------------------------
    Alias                     LISTENER
    Version                   TNSLSNR for Linux: Version 23.0.0.0.0 - for Oracle Cloud and Engineered Systems
    Start Date                30-JUN-2025 13:34:51
    Uptime                    2 days 0 hr. 29 min. 19 sec
    Trace Level               off
    Security                  ON: Local OS Authentication
    SNMP                      OFF
    Listener Parameter File   /u01/app/oracle/product/23/network/admin/listener.ora
    Listener Log File         /u01/app/oracle/diag/tnslsnr/holserv1/listener/alert/log.xml
    Listening Endpoints Summary...
    (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=holserv1.livelabs.oraclevcn.com)(PORT=1521)))
    (DESCRIPTION=(ADDRESS=(PROTOCOL=tcps)(HOST=holserv1.livelabs.oraclevcn.com)(PORT=1522)))
    Services Summary...
    Service "34386ccc92e05191e063e901000afc0f" has 1 instance(s).
      Instance "CDB23", status READY, has 1 handler(s) for this service...
    Service "3438e280c7587bece063e901000a1574" has 1 instance(s).
      Instance "CDB23", status READY, has 1 handler(s) for this service...
    Service "3438e280c75a7bece063e901000a1574" has 1 instance(s).
      Instance "CDB23", status READY, has 1 handler(s) for this service...
    Service "3438e280c75c7bece063e901000a1574" has 1 instance(s).
      Instance "CDB23", status READY, has 1 handler(s) for this service...
    Service "CDB23XDB" has 1 instance(s).
      Instance "CDB23", status READY, has 1 handler(s) for this service...
    Service "blue" has 1 instance(s).
      Instance "CDB23", status READY, has 1 handler(s) for this service...
    Service "cdb23" has 1 instance(s).
      Instance "CDB23", status READY, has 1 handler(s) for this service...
    Service "green" has 1 instance(s).
      Instance "CDB23", status READY, has 1 handler(s) for this service...
    Service "red" has 1 instance(s).
      Instance "CDB23", status READY, has 1 handler(s) for this service...
    The command completed successfully
    ```

    </details>

2. Verify the listener configuration.

    ``` bash
    <copy>
    cat $ORACLE_HOME/network/admin/listener.ora
    </copy>
    ```

    * The listener has two endpoints. A regular, TCP endpoint on 1521. Plus, another TCPS on 1522.
    * The endpoint on 1522 is used for secure TCPS connections.
    * mTLS connections (TCPS) also require a wallet (*wallet\_location*).

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    LISTENER =
      (DESCRIPTION_LIST =
        (DESCRIPTION =
          (ADDRESS = (PROTOCOL = TCP)(HOST = holserv1.livelabs.oraclevcn.com)(PORT = 1521))
          (ADDRESS = (PROTOCOL = TCPS)(HOST = holserv1.livelabs.oraclevcn.com)(PORT = 1522))
        )
    )

    WALLET_LOCATION = (SOURCE=(METHOD=FILE)(METHOD_DATA=(DIRECTORY=/u01/app/oracle/tls_wallet)))
    ```

    </details>

3. The database link between the two databases must also use TCPS, so a proper configuration in *sqlnet.ora* is required.

    ``` bash
    <copy>
    cat $ORACLE_HOME/network/admin/sqlnet.ora
    </copy>
    ```

    * The *wallet\_location* parameter allows use of the wallet to establish a secure connection.
    * All databases running on this *ORACLE\_HOME* will read the *WALLET\_LOCATION* of *sqlnet.ora* when a new connection is established and check if the provided certificate is available on this wallet.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    WALLET_LOCATION = (SOURCE=(METHOD=FILE)(METHOD_DATA=(DIRECTORY=/u01/app/oracle/tls_wallet)))
    ```

    </details>

4. Authenticate using mTLS.

    ``` bash
    <copy>
    sql admin/admin@"tcps://localhost:1522/red?wallet_location=/home/oracle/client_tls_wallet&ssl_server_dn_match=false"
    </copy>
    ```

    * For this lab, we generated a wallet in advance with the certificate to connect on this server. The wallet is located under */home/oracle/client\_tls\_wallet*.
    * We need to provide *ssl\_server\_dn\_match* as SQLcl would send *localhost* instead of *holserv1*, resulting in *ORA-17965*.
    * If we try to authenticate on TCPS without providing a wallet, we get an TNS error (ORA-29002: SSL transport detected invalid or obsolete server certificate).

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQLcl: Release 25.1 Production on Wed Jul 02 14:50:36 2025

    Copyright (c) 1982, 2025, Oracle.  All rights reserved.

    Connected to:
    Oracle Database 23ai Enterprise Edition Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems
    Version 23.9.0.25.07

    SQL>
    ```

    </details>

5. Close SQLcl.

    ``` bash
    <copy>
    exit
    </copy>
    ```

## Task 2: Modify profile in ADB

In this task, we will change the default profile so passwords for imported users will not expire and match the profile setting from the source database.

1. Still in the *blue* 🟦 terminal, connect on the *RUBY* ADB.

    ``` sql
    <copy>
    . adb
    sql admin/Welcome_1234@ruby_tp
    </copy>

    -- Be sure to hit RETURN
    ```

2. Alter the profile.

    ``` sql
    <copy>
    alter profile default limit PASSWORD_LIFE_TIME unlimited;

    alter profile default limit PASSWORD_GRACE_TIME unlimited;
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> alter profile default limit PASSWORD_LIFE_TIME unlimited;

    Profile DEFAULT altered.

    SQL> alter profile default limit PASSWORD_GRACE_TIME unlimited;

    Profile DEFAULT altered.

    SQL>
    ```

    </details>

## Task 3: Create a database link on ADB

Now we need to create a database link from our ADB to the PDB.

First, we need to upload the *RED* wallet to ADB directory.

1. Create a directory to keep the wallet files.

    ``` bash
    <copy>
    create directory red_dblink_wallet_dir as 'red_dblink_wallet_dir';
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> create directory red_dblink_wallet_dir as 'red_dblink_wallet_dir';

    Directory RED_DBLINK_WALLET_DIR created.
    ```

    </details>

2. Next, let's upload the local wallet files to this directory.

    ``` sql
    <copy>
    @~/scripts/adb-07-upload_file.sql /home/oracle/client_tls_wallet/cwallet.sso RED_DBLINK_WALLET_DIR cwallet.sso
    </copy>
    ```

    * *adb-07-upload\_file.sql* will upload a file to an *Oracle Directory* using SQLcl and JavaScript.
    * The script converts the local file into a BLOB and writes using *UTL\_FILE.PUT\_RAW*.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> @~/scripts/adb-07-upload_file.sql /home/oracle/client_tls_wallet/cwallet.sso RED_DBLINK_WALLET_DIR cwallet.sso
    Starting upload_file.js script...
    Local file path: /home/oracle/client_tls_wallet/cwallet.sso
    Oracle directory: RED_DBLINK_WALLET_DIR
    Target file name: cwallet.sso
    Creating BLOB and opening binary stream...
    Reading local file into stream...
    File read and copied into BLOB stream.
    Saving BLOB to Oracle Directory...
    File successfully written to Oracle directory.
    File uploaded successfully.
    ```

    </details>

3. Check if file was uploaded.

    ``` sql
    <copy>
    select * from dbms_cloud.list_files('red_dblink_wallet_dir');
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> select * from dbms_cloud.list_files('red_dblink_wallet_dir');

    OBJECT_NAME       BYTES CHECKSUM    CREATED                                LAST_MODIFIED
    ______________ ________ ___________ ______________________________________ ______________________________________
    cwallet.sso        3035             02-JUL-25 03.28.11.618341000 PM GMT    02-JUL-25 03.28.11.713437000 PM GMT
    ```

    </details>

4. Create the DB link credentials.

    ``` sql
    <copy>
    begin
      dbms_cloud.create_credential(
        credential_name => 'SYSTEM_RED_CRED',
        username => 'SYSTEM',
        password => 'oracle');
    end;
    /
    </copy>
    ```

    * Please note that *username* and *password* are case sensitive.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> begin
      2    dbms_cloud.create_credential(
      3      credential_name => 'SYSTEM_RED_CRED',
      4      username => 'SYSTEM',
      5      password => 'oracle');
      6  end;
      7* /

    PL/SQL procedure successfully completed.
    ```

    </details>

5. Create the DB link and test it.

    ``` sql
    <copy>
    begin
      dbms_cloud_admin.create_database_link(
        db_link_name => 'SOURCE_DBLINK',
        hostname => 'host.containers.internal',
        port => '1522',
        service_name => 'red',
        ssl_server_cert_dn => 'CN=holserv1',
        credential_name => 'SYSTEM_RED_CRED',
        directory_name => 'RED_DBLINK_WALLET_DIR');
    end;
    /

    select * from dual@SOURCE_DBLINK;
    </copy>

    -- Be sure to hit RETURN
    ```

    * host.containers.internal is the hostname of the machine running the RED database.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> begin
      2    dbms_cloud_admin.create_database_link(
      3      db_link_name => 'SOURCE_DBLINK',
      4      hostname => 'host.containers.internal',
      5      port => '1522',
      6      service_name => 'red',
      7      ssl_server_cert_dn => 'CN=holserv1',
      8      credential_name => 'SYSTEM_RED_CRED',
      9      directory_name => 'RED_DBLINK_WALLET_DIR');
     10  end;
     11* /

    PL/SQL procedure successfully completed.

    SQL> select * from dual@SOURCE_DBLINK;

    DUMMY
    ________
    X
    ```

    </details>

## Task 4: Import schema in ADB

1. Create a directory pointing to *nfs-server:/exports* to store log files.

    ``` sql
    <copy>
    create directory nfs_dir as 'nfs';

    begin
      dbms_cloud_admin.attach_file_system (
          file_system_name      => 'nfs',
          file_system_location  => 'nfs-server:/exports',
          directory_name        => 'nfs_dir',
          description           => 'Source NFS for data'
      );
    end;
    /

    select * from dbms_cloud.list_files('nfs_dir');
    </copy>

    -- Be sure to hit RETURN
    ```

    * Note that the *nfs_dir* directory was created and can read the contents of the NFS share.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> create directory nfs_dir as 'nfs';

    Directory NFS_DIR created.

    SQL> begin
      2    dbms_cloud_admin.attach_file_system (
      3        file_system_name      => 'nfs',
      4        file_system_location  => 'nfs-server:/exports',
      5        directory_name        => 'nfs_dir',
      6        description           => 'Source NFS for data'
      7    );
      8  end;
      9* /

    PL/SQL procedure successfully completed.

    SQL> select * from dbms_cloud.list_files('nfs_dir');

    OBJECT_NAME                     BYTES CHECKSUM    CREATED    LAST_MODIFIED
    _________________________ ___________ ___________ __________ ______________________________________
    WORKING                             0                        01-JUL-25 07.13.46.691421000 PM GMT
    schemas_export.log              19094                        02-JUL-25 01.38.13.002012000 PM GMT
    schemas_export_01.dmp        49623040                        02-JUL-25 01.38.11.020962000 PM GMT
    schemas_export_02.dmp           53248                        02-JUL-25 01.38.11.014962000 PM GMT
    schemas_import_nfs.log          21866                        02-JUL-25 01.43.13.371612000 PM GMT

    SQL>
    ```

    </details>

2. Close SQLcl.

    ``` bash
    <copy>
    exit
    </copy>
    ```

3. Still in the *blue* 🟦 terminal, import the F1 schema on *RUBY* ADB.

    ``` bash
    <copy>
    impdp userid=admin/Welcome_1234@ruby_tpurgent \
       schemas=F1 \
       logtime=all \
       metrics=true \
       directory=nfs_dir \
       network_link=source_dblink \
       logfile=schemas_import_dblink.log \
       parallel=2
    </copy>
    ```

    * Note that we only use *directory* for saving the output *logfile*.
    * Instead of *dumpfile*, we use the *network_link* parameter.
    * No error has happened.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    Import: Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems on Wed Jul 2 17:23:49 2025
    Version 23.9.0.25.07

    Copyright (c) 1982, 2025, Oracle and/or its affiliates.  All rights reserved.

    Connected to: Oracle Database 23ai Enterprise Edition Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems
    02-JUL-25 17:24:15.698: Starting "ADMIN"."SYS_IMPORT_SCHEMA_01":  userid=admin/********@ruby_tpurgent schemas=F1 logtime=all metrics=true directory=nfs_dir network_link=source_dblink logfile=schemas_import_dblink.log parallel=2
    02-JUL-25 17:24:37.288: W-1 Startup on instance 1 took 22 seconds
    02-JUL-25 17:24:39.919: W-1 Processing object type SCHEMA_EXPORT/TABLE/TABLE_DATA
    02-JUL-25 17:24:39.967: W-1      Estimated 14 TABLE_DATA objects in 2 seconds
    02-JUL-25 17:24:40.400: W-1 Processing object type SCHEMA_EXPORT/USER
    02-JUL-25 17:24:40.628: W-1      Completed 1 USER objects in 0 seconds
    02-JUL-25 17:24:40.631: W-1 Processing object type SCHEMA_EXPORT/SYSTEM_GRANT
    02-JUL-25 17:24:40.777: W-1      Completed 2 SYSTEM_GRANT objects in 0 seconds
    02-JUL-25 17:24:40.780: W-1 Processing object type SCHEMA_EXPORT/DEFAULT_ROLE
    02-JUL-25 17:24:40.867: W-1      Completed 1 DEFAULT_ROLE objects in 0 seconds
    02-JUL-25 17:24:40.870: W-1 Processing object type SCHEMA_EXPORT/TABLESPACE_QUOTA
    02-JUL-25 17:24:41.369: W-1      Completed 1 TABLESPACE_QUOTA objects in 1 seconds
    02-JUL-25 17:24:41.374: W-1 Processing object type SCHEMA_EXPORT/PRE_SCHEMA/PROCACT_SCHEMA/LOGREP
    02-JUL-25 17:24:41.475: W-1      Completed 3 LOGREP objects in 0 seconds
    02-JUL-25 17:24:46.848: W-1 Processing object type SCHEMA_EXPORT/TABLE/TABLE
    02-JUL-25 17:24:53.899: W-1      Completed 14 TABLE objects in 12 seconds
    02-JUL-25 17:24:55.196: W-1 . . imported "F1"."F1_LAPTIMES"                          571047 rows in 1 seconds using network link
    02-JUL-25 17:24:55.569: W-1 . . imported "F1"."F1_RESULTS"                            26439 rows in 0 seconds using network link
    02-JUL-25 17:24:55.788: W-1 . . imported "F1"."F1_DRIVERSTANDINGS"                    34511 rows in 0 seconds using network link
    02-JUL-25 17:24:56.006: W-1 . . imported "F1"."F1_QUALIFYING"                         10174 rows in 0 seconds using network link
    02-JUL-25 17:24:56.187: W-1 . . imported "F1"."F1_PITSTOPS"                           10793 rows in 0 seconds using network link
    02-JUL-25 17:24:56.358: W-1 . . imported "F1"."F1_CONSTRUCTORSTANDINGS"               13231 rows in 0 seconds using network link
    02-JUL-25 17:24:56.502: W-1 . . imported "F1"."F1_CONSTRUCTORRESULTS"                 12465 rows in 0 seconds using network link
    02-JUL-25 17:24:56.687: W-1 . . imported "F1"."F1_RACES"                               1125 rows in 0 seconds using network link
    02-JUL-25 17:24:56.863: W-1 . . imported "F1"."F1_DRIVERS"                              859 rows in 0 seconds using network link
    02-JUL-25 17:24:57.023: W-1 . . imported "F1"."F1_SPRINTRESULTS"                        280 rows in 1 seconds using network link
    02-JUL-25 17:24:57.148: W-1 . . imported "F1"."F1_CONSTRUCTORS"                         212 rows in 0 seconds using network link
    02-JUL-25 17:24:57.270: W-1 . . imported "F1"."F1_CIRCUITS"                              77 rows in 0 seconds using network link
    02-JUL-25 17:24:57.362: W-1 . . imported "F1"."F1_SEASONS"                               75 rows in 0 seconds using network link
    02-JUL-25 17:24:57.456: W-1 . . imported "F1"."F1_STATUS"                               139 rows in 0 seconds using network link
    02-JUL-25 17:25:15.589: W-2 Startup on instance 1 took 22 seconds
    02-JUL-25 17:25:15.776: W-1 Processing object type SCHEMA_EXPORT/TABLE/CONSTRAINT/CONSTRAINT
    02-JUL-25 17:25:17.525: W-1      Completed 22 CONSTRAINT objects in 7 seconds
    02-JUL-25 17:25:17.528: W-1 Processing object type SCHEMA_EXPORT/TABLE/INDEX/STATISTICS/INDEX_STATISTICS
    02-JUL-25 17:25:25.116: W-1      Completed 19 INDEX_STATISTICS objects in 8 seconds
    02-JUL-25 17:25:25.119: W-1 Processing object type SCHEMA_EXPORT/TABLE/STATISTICS/TABLE_STATISTICS
    02-JUL-25 17:25:25.134: W-1      Completed 14 TABLE_STATISTICS objects in 8 seconds
    02-JUL-25 17:25:26.477: W-1      Completed 1 [internal] Unknown objects in 1 seconds
    02-JUL-25 17:25:27.353: W-2      Completed 14 SCHEMA_EXPORT/TABLE/TABLE_DATA objects in 3 seconds
    02-JUL-25 17:25:27.400: Job "ADMIN"."SYS_IMPORT_SCHEMA_01" successfully completed at Wed Jul 2 17:25:27 2025 elapsed 0 00:01:36
    ```

    </details>

You may now [*proceed to the next lab*](#next).

## Additional information

* Webinar, [Data Pump Best Practices and Real World Scenarios, Metadata](https://www.youtube.com/watch?v=CUHcKHx_YvA&t=1260s)
* Webinar, [Data Pump Best Practices and Real World Scenarios, Generate metadata with SQLFILE](https://www.youtube.com/watch?v=CUHcKHx_YvA&t=4642s)

## Acknowledgments

* **Author** - Rodrigo Jorge
* **Contributors** - William Beauregard, Daniel Overby Hansen, Mike Dietrich, Klaus Gronau, Alex Zaballa
* **Last Updated By/Date** - Rodrigo Jorge, August 2025
