# Generate ADB Wallet and Set IAM as Identity Provider

## Introduction

In this lab you will generate a wallet file for your ADB. This wallet file can be used to connect to the database. Using it you will then connect to the database and enable IAM as its identity provider. You will also create database users and grant them permissions.

*Estimated Lab Time*: 20 minutes

### Objectives
- Generate a wallet file for your ADB
- Access your ADB with the wallet file and configure IAM as the identity provider
- Create database users and grant them permissions
- Unzip wallet and update files so that the ADB can be accessed using a token

### Prerequisites
This lab assumes that you have completed the previous labs and have created all resources outlined in them.

## Task 1: Generate Wallet in adb_wallet folder

1. Create adb_wallet directory.

    ```
    <copy>mkdir -v $HOME/adb_wallet</copy>
    ```

2. Generate the wallet file in the adb_wallet directory.

    ```
    <copy>oci db autonomous-database generate-wallet --autonomous-database-id $ADB_OCID --password Oracle123+ --file $HOME/adb_wallet/lltest_wallet.zip</copy>
    ```

3. Navigate to the adb_wallet directory.

    ```
    <copy>cd $HOME/adb_wallet</copy>
    ```

## Task 2: Enable OCI IAM as the identity provider

1. Open the SQL command line, then connect to the database using the wallet file.
    >**Note:** This command only works from inside the adb_wallet folder. Insure that you have navigated to it as shown in the previous steps.

    ```
    <copy>sql /nolog</copy>
    ```
    ```
    <copy>set cloudconfig lltest_wallet.zip

    conn admin/Oracle123+Oracle123+@lltest_high</copy>
    ```

2. Query to select the identity provider, and see that it is **NONE** by default.

    ```
    <copy>select name, value from v$parameter where name ='identity_provider_type';</copy>
    ```


    ```
    <copy>NAME                      VALUE    
    _________________________ ________
    identity_provider_type    NONE</copy>
    ```

3. Now enable IAM as the identity provider. Query the idenity provider again to see it updated to **OCI_IAM**.

    ```
    <copy>exec dbms_cloud_admin.enable_external_authentication('OCI_IAM');
    select name, value from v$parameter where name ='identity_provider_type';</copy>
    ```

    ```
    <copy>NAME                      VALUE      
    _________________________ __________
    identity_provider_type    OCI_IAM</copy> 
    ```

4. Create the **user\_shared** user and grant it permissions to create sessions. Create the **sr\_dba\_role** role and grant it permissions. Quit the SQL session.

    ```
    <copy>create user user_shared identified globally as 'IAM_GROUP_NAME=All_DB_Users';
    grant create session to user_shared;
    create role sr_dba_role identified globally as 'IAM_GROUP_NAME=DB_Admin';
    grant pdb_dba to sr_dba_role;
    quit</copy>
    ```

## Task 3: Unzip wallet file and edit contents

1. Unzip your ADB wallet file.

    ```
    <copy>unzip -d . lltest_wallet.zip</copy>
    ```

2. Create session variable for location of wallet file.
    >**Note:** If at any point you exit out of the cloud shell, the following commands may need to be executed again to reset the environment variables.

    ```
    <copy>export TNS_ADMIN=$HOME/adb_wallet</copy>
    ```

3. Append the ADB's sqlnet.ora entry with the environment variable for the wallet location.

    ```
    <copy>mv tnsnames.ora tnsnames.ora.orig
    mv sqlnet.ora sqlnet.ora.orig

    echo "WALLET_LOCATION = (SOURCE = (METHOD = file) (METHOD_DATA = (DIRECTORY="/home/`whoami`/adb_wallet")))
    SSL_SERVER_DN_MATCH=yes" >> sqlnet.ora

    cat sqlnet.ora</copy>
    ```

4. Append the TOKEN_AUTH parameter to the ADB instance's tnsname.ora entry so that an authorization token can be used instead of a password.

    ```
    <copy>head -1 tnsnames.ora.orig | sed -e 's/)))/)(TOKEN_AUTH=OCI_TOKEN)))/' > tnsnames.ora

    cat tnsnames.ora</copy>
    ```

You may now **proceed to the next lab.**

## Learn More

* [Parameters for the sqlnet.ora File](https://docs.oracle.com/en/database/oracle/oracle-database/19/netrf/parameters-for-the-sqlnet.ora.html#GUID-2041545B-58D4-48DC-986F-DCC9D0DEC642)
* [Local Naming Parameters in the tnsname.ora File] (https://docs.oracle.com/en/database/oracle/oracle-database/19/netrf/local-naming-parameters-in-tns-ora-file.html#GUID-7F967CE5-5498-427C-9390-4A5C6767ADAA)

## Acknowledgements
* **Author**
  * Richard Evans, Database Security Product Management
  * Miles Novotny, Solution Engineer, North America Specialist Hub
  * Noah Galloso, Solution Engineer, North America Specialist Hub
* **Last Updated By/Date** - Miles Novotny, December 2022
