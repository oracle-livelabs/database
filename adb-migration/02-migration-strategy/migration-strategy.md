# Migration Strategy

## Introduction

In this lab, you will have a look at the necessary steps to move a database running on your local environment to ADB.

Estimated Time: 5 Minutes

### Objectives

In this lab, you will:

* Familiarize yourself with ADB migration steps

### Prerequisites

This lab assumes:

* You have completed Lab 1: Initialize Environment

This is an optional lab. You can skip it if you are already familiar with ADB migration steps.

## Task 1: Undertand the Migration Strategy

For moving a database to ADB, we need to perform basically 4 steps:

1. Checking source database for readiness.

    To evaluate the compatibility of the source database before you migrate to an Oracle Cloud database, use the Cloud Premigration Advisor Tool (CPAT).

    The purpose of the Cloud Premigration Advisor Tool (CPAT) is to help plan successful migrations to Oracle Databases in the Oracle Cloud or on-premises. It analyzes the compatibility of the source database with your database target and chosen migration method, and suggests a course of action for potential incompatibilities. CPAT provides you with information to consider for different migration tools.

2. Evaluating the best Migration Method

    There are multiple ways of migrating a database. You could ether use Data Pump, Database Links, Golden Gate, OCI DMS or ZDM, to name a few. In this lab, we will check how Oracle Cloud Migration Advisor brings you the expert technical knowledge of Oracle Database upgrade and migration to give you the best possible migration advice.

3. Performing the Migration

    Next, we will move:

    * The *RED* local PDB to *RUBY* running on ADB using Data Pump with Database Links.
    * The *BLUE* local PDB to *SAPPHIRE* running on ADB using Data Pump with files over NFS.

    ![Migration Strategy](./images/migration.png)

    We will explore using both a dump file in a shared NFS, as using the database link to move the data.

4. Post steps

    After migration has finished, you will check how to perform some maintainance tasks using the ADB "Database Actions" page.

## Task 2: Test connection on the source PDBs: Blue and Red

1. Use the *yellow* terminal 🟨. Let's connect to the cdb23.

    ``` shell
    <copy>
    . cdb23
    sql / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

    List the PDBS:

    ``` sql
    <copy>
    show pdbs
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> show pdbs

        CON_ID CON_NAME                       OPEN MODE  RESTRICTED
    ---------- ------------------------------ ---------- ----------
             2 PDB$SEED                       READ ONLY  NO
             3 RED                            READ WRITE NO
             4 BLUE                           READ WRITE NO
             5 GREEN                          MOUNTED
    ```

    </details>

2. Switch to the *BLUE* PDB and check all the non-internal users already created on the database.

    ``` sql
    <copy>
    alter session set container=BLUE;

    select username
      from dba_users
     where oracle_maintained='N'
       and cloud_maintained='NO'
     order by 1
    /
    </copy>

    -- Be sure to hit RETURN
    ```

    * `ADMIN` is the default PDB_DBA user on a PDB.
    * `BI`, `HR`, `IX`, `PM` and `SH` are sample schemas that we will move later to ADB.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    USERNAME
    --------------------------------------------------------------------------------
    ADMIN
    BI
    HR
    IX
    PM
    SH
    ```

    </details>

3. Connect now on the *RED* PDB and perform the same query.

    ``` sql
    <copy>
    alter session set container=RED;

    select username
      from dba_users
     where oracle_maintained='N'
       and cloud_maintained='NO'
     order by 1
    /
    </copy>

    -- Be sure to hit RETURN
    ```

    * `ADMIN` is the default PDB_DBA user on a PDB.
    * `F1` is a sample schemas that we will migrate later to ADB.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    USERNAME
    --------------------------------------------------------------------------------
    ADMIN
    F1
    ```

    </details>

4. Now close SQLcl:

    ``` shell
    <copy>
    exit;
    </copy>

    -- Be sure to hit RETURN
    ```

## Task 3: Test connection on the target ADBs: Sapphire and Ruby

To connect on the ADB instance, you must use a ADB Wallet, which is already uncompressed and available at */home/oracle/adb\_tls\_wallet*.

1. Now, switch to the *blue* 🟦 terminal. Set the environment to *ADB* and check the contents TNS\_ADMIN folder.

    ``` shell
    <copy>
    . adb

    echo $TNS_ADMIN

    ls -l $TNS_ADMIN

    cat $TNS_ADMIN/tnsnames.ora
    </copy>

    # Be sure to hit RETURN
    ```

    * Note that TNS\_ADMIN was set to /home/oracle/adb\_tls\_wallet.
    * On ADB, a similar Wallet can be download from the web UI.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    [ADB:oracle@holserv1:~]$ echo $TNS_ADMIN
    /home/oracle/adb_tls_wallet
    [ADB:oracle@holserv1:~]$ ls -l $TNS_ADMIN
    total 48
    -rw-------. 1 oracle oinstall  996 Jun 18 13:49 adb_container.cert
    -rw-------. 1 oracle oinstall 3899 Jun 18 13:49 cwallet.sso
    -rw-------. 1 oracle oinstall    0 Jun 18 13:49 cwallet.sso.lck
    -rw-------. 1 oracle oinstall 3854 Jun 18 13:49 ewallet.p12
    -rw-------. 1 oracle oinstall    0 Jun 18 13:49 ewallet.p12.lck
    -rw-r--r--. 1 oracle oinstall 2874 Jun 18 13:49 ewallet.pem
    -rw-------. 1 oracle oinstall 2045 Jun 18 13:49 keystore.jks
    -rw-r--r--. 1 oracle oinstall  692 Jun 18 13:49 ojdbc.properties
    -rw-r--r--. 1 oracle oinstall   34 Jun 18 13:49 README
    -rw-r--r--. 1 oracle oinstall   98 Jun 18 13:49 sqlnet.ora
    -rw-r--r--. 1 oracle oinstall 5823 Jun 18 14:16 tnsnames.ora
    -rw-r--r--. 1 oracle oinstall 2651 Jun 18 13:57 tnsnames_ruby.ora
    -rw-------. 1 oracle oinstall 2128 Jun 18 13:51 truststore.jks
    [ADB:oracle@holserv1:~]$ cat $TNS_ADMIN/tnsnames.ora
    sapphire_medium = (description=(retry_count=0)(retry_delay=3)
                     (address=(protocol=tcps)(port=1523)(host=holserv1.livelabs.oraclevcn.com))
                     (connect_data=(service_name=sapphire_medium.adb.oraclecloud.com))(security=(SSL_SERVER_DN_MATCH=TRUE)    (SSL_SERVER_CERT_DN="CN=93ced68f921a")))

    sapphire_high = (description=(retry_count=0)(retry_delay=3)
                     (address=(protocol=tcps)(port=1523)(host=holserv1.livelabs.oraclevcn.com))
                     (connect_data=(service_name=sapphire_high.adb.oraclecloud.com))(security=(SSL_SERVER_DN_MATCH=TRUE)    (SSL_SERVER_CERT_DN="CN=93ced68f921a")))

    sapphire_low = (description=(retry_count=0)(retry_delay=3)
                     (address=(protocol=tcps)(port=1523)(host=holserv1.livelabs.oraclevcn.com))
                     (connect_data=(service_name=sapphire_low.adb.oraclecloud.com))(security=(SSL_SERVER_DN_MATCH=TRUE)    (SSL_SERVER_CERT_DN="CN=93ced68f921a")))

    sapphire_tp = (description=(retry_count=0)(retry_delay=3)
                (address=(protocol=tcps)(port=1523)(host=holserv1.livelabs.oraclevcn.com))
                (connect_data=(service_name=sapphire_tp.adb.oraclecloud.com))(security=(SSL_SERVER_DN_MATCH=TRUE)    (SSL_SERVER_CERT_DN="CN=93ced68f921a")))

    sapphire_tpurgent = (description=(retry_count=0)(retry_delay=3)
                       (address=(protocol=tcps)(port=1523)(host=holserv1.livelabs.oraclevcn.com))
                       (connect_data=(service_name=sapphire_tpurgent.adb.oraclecloud.com))(security=(SSL_SERVER_DN_MATCH=TRUE)    (SSL_SERVER_CERT_DN="CN=93ced68f921a")))

    sapphire_medium_tls = (description=(retry_count=0)(retry_delay=3)
                        (address=(protocol=tcps)(port=1523)(host=holserv1.livelabs.oraclevcn.com))
                        (connect_data=(service_name=sapphire_medium.adb.oraclecloud.com))(security=(ssl_server_dn_match=no)))

    sapphire_high_tls = (description=(retry_count=0)(retry_delay=3)
                        (address=(protocol=tcps)(port=1523)(host=holserv1.livelabs.oraclevcn.com))
                        (connect_data=(service_name=sapphire_high.adb.oraclecloud.com))(security=(ssl_server_dn_match=no)))

    sapphire_low_tls = (description=(retry_count=0)(retry_delay=3)
                        (address=(protocol=tcps)(port=1523)(host=holserv1.livelabs.oraclevcn.com))
                        (connect_data=(service_name=sapphire_low.adb.oraclecloud.com))(security=(ssl_server_dn_match=no)))

    sapphire_tp_tls = (description=(retry_count=0)(retry_delay=3)
                    (address=(protocol=tcps)(port=1523)(host=holserv1.livelabs.oraclevcn.com))
                    (connect_data=(service_name=sapphire_tp.adb.oraclecloud.com))(security=(ssl_server_dn_match=no)))

    sapphire_tpurgent_tls = (description=(retry_count=0)(retry_delay=3)
                          (address=(protocol=tcps)(port=1523)(host=holserv1.livelabs.oraclevcn.com))
                          (connect_data=(service_name=sapphire_tpurgent.adb.oraclecloud.com))(security=(ssl_server_dn_match=no)))

    ruby_medium = (description=(retry_count=0)(retry_delay=3)
                     (address=(protocol=tcps)(port=1523)(host=holserv1.livelabs.oraclevcn.com))
                     (connect_data=(service_name=ruby_medium.adb.oraclecloud.com))(security=(SSL_SERVER_DN_MATCH=TRUE)    (SSL_SERVER_CERT_DN="CN=93ced68f921a")))

    ruby_high = (description=(retry_count=0)(retry_delay=3)
                     (address=(protocol=tcps)(port=1523)(host=holserv1.livelabs.oraclevcn.com))
                     (connect_data=(service_name=ruby_high.adb.oraclecloud.com))(security=(SSL_SERVER_DN_MATCH=TRUE)    (SSL_SERVER_CERT_DN="CN=93ced68f921a")))

    ruby_low = (description=(retry_count=0)(retry_delay=3)
                     (address=(protocol=tcps)(port=1523)(host=holserv1.livelabs.oraclevcn.com))
                     (connect_data=(service_name=ruby_low.adb.oraclecloud.com))(security=(SSL_SERVER_DN_MATCH=TRUE)    (SSL_SERVER_CERT_DN="CN=93ced68f921a")))

    ruby_tp = (description=(retry_count=0)(retry_delay=3)
                (address=(protocol=tcps)(port=1523)(host=holserv1.livelabs.oraclevcn.com))
                (connect_data=(service_name=ruby_tp.adb.oraclecloud.com))(security=(SSL_SERVER_DN_MATCH=TRUE)    (SSL_SERVER_CERT_DN="CN=93ced68f921a")))

    ruby_tpurgent = (description=(retry_count=0)(retry_delay=3)
                       (address=(protocol=tcps)(port=1523)(host=holserv1.livelabs.oraclevcn.com))
                       (connect_data=(service_name=ruby_tpurgent.adb.oraclecloud.com))(security=(SSL_SERVER_DN_MATCH=TRUE)    (SSL_SERVER_CERT_DN="CN=93ced68f921a")))

    ruby_medium_tls = (description=(retry_count=0)(retry_delay=3)
                        (address=(protocol=tcps)(port=1523)(host=holserv1.livelabs.oraclevcn.com))
                        (connect_data=(service_name=ruby_medium.adb.oraclecloud.com))(security=(ssl_server_dn_match=no)))

    ruby_high_tls = (description=(retry_count=0)(retry_delay=3)
                        (address=(protocol=tcps)(port=1523)(host=holserv1.livelabs.oraclevcn.com))
                        (connect_data=(service_name=ruby_high.adb.oraclecloud.com))(security=(ssl_server_dn_match=no)))

    ruby_low_tls = (description=(retry_count=0)(retry_delay=3)
                        (address=(protocol=tcps)(port=1523)(host=holserv1.livelabs.oraclevcn.com))
                        (connect_data=(service_name=ruby_low.adb.oraclecloud.com))(security=(ssl_server_dn_match=no)))

    ruby_tp_tls = (description=(retry_count=0)(retry_delay=3)
                    (address=(protocol=tcps)(port=1523)(host=holserv1.livelabs.oraclevcn.com))
                    (connect_data=(service_name=ruby_tp.adb.oraclecloud.com))(security=(ssl_server_dn_match=no)))

    ruby_tpurgent_tls = (description=(retry_count=0)(retry_delay=3)
                          (address=(protocol=tcps)(port=1523)(host=holserv1.livelabs.oraclevcn.com))
                          (connect_data=(service_name=ruby_tpurgent.adb.oraclecloud.com))(security=(ssl_server_dn_match=no)))
    ```

    </details>

2. Connect to the *SAPPHIRE* ADB.

    ``` shell
    <copy>
    . adb
    sql admin/Welcome_1234@sapphire_tp
    </copy>

    -- Be sure to hit RETURN
    ```

3. Check all the non-internal users already created on the database.

    ``` sql
    <copy>
    select username
      from dba_users
     where oracle_maintained='N'
       and cloud_maintained='NO'
     order by 1
    /
    </copy>

    -- Be sure to hit RETURN
    ```

    * `ADMIN` is the default DBA user on ADB.
    * `CMA` is the schema where CMA tool was deployed.
    * `MPACK_OEE` is a pre-created schema available in ADB Free Container with the State Explorer tool.
    * `ORDS_PLSQL_GATEWAY2` and `ORDS_PUBLIC_USER2` are schemas created to handle ORDS access.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    USERNAME
    --------------------------------------------------------------------------------
    ADMIN
    CMA
    MPACK_OEE
    ORDS_PLSQL_GATEWAY2
    ORDS_PUBLIC_USER2
    ```

    </details>

4. Connect now on the *RUBY* ADB and perform the same query.

    ``` sql
    <copy>
    connect admin/Welcome_1234@ruby_tp

    select username
      from dba_users
     where oracle_maintained='N'
       and cloud_maintained='NO'
     order by 1
    /
    </copy>

    -- Be sure to hit RETURN
    ```

    * The output is the very similar, but CMA tool was only deployed on the *SAPPHIRE* ADB.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    USERNAME
    --------------------------------------------------------------------------------
    ADMIN
    MPACK_OEE
    ORDS_PLSQL_GATEWAY2
    ORDS_PUBLIC_USER2
    ```

    </details>

5. Now close SQLcl:

    ``` shell
    <copy>
    exit;
    </copy>

    -- Be sure to hit RETURN
    ```

You may now [*proceed to the next lab*](#next).

## Acknowledgments

* **Author** - Rodrigo Jorge
* **Contributors** - William Beauregard, Daniel Overby Hansen, Mike Dietrich, Klaus Gronau, Alex Zaballa
* **Last Updated By/Date** - Rodrigo Jorge, May 2025
