# Generate ADB Wallet and Set IAM as Identity Provider

## Introduction

In this lab you will generate a wallet file for your ADB. This wallet file can be used to connect to the database. Using it you will then connect to the database and enable IAM as its identity provider. You will also create database users and grant them permissions.

*Estimated Lab Time*: 20 minutes

### Objectives
- Generate a wallet file for your ADB
- Access your ADB with the wallet file and configure IAM as the identity provider
- Create database users and grant them permissions
- unzip wallet and update files so that the ADB can be accessed using a token

### Prerequisites
This lab assumes you have:
- Completed Lab 1: Create ADB and set up Environment

## Task 1: Generate Wallet in adb_wallet folder

1. Create adb_wallet directory.

    ```
    mkdir $HOME/adb_wallet
    ```

    ```
    ls -al $HOME/adb_wallet
    ```

2. Generate the wallet file in the adb_wallet directory.

    ```
    oci db autonomous-database generate-wallet --autonomous-database-id $ADB_OCID --password Oracle123+ --file $HOME/adb_wallet/lltest_wallet.zip
    ```

3. Navigate to the adb_wallet directory.

    ```
    cd $HOME/adb_wallet
    ```

## Task 2: Enable OCI IAM as the identity provider

1. Connect to the database using the wallet file. This step and the following steps will not run until the **EOF** statement at the end of step 4.

    ```
    sql /nolog <<EOF
    set cloudconfig $HOME/adb_wallet/lltest_wallet.zip
    conn admin/Oracle123+Oracle123+@lltest_high
    ```

2. Query to select the identity provider, and see that it is **NONE** by default.

    ```
    select name, value from v\$parameter where name ='identity_provider_type';
    ```


    ```
    NAME                      VALUE    
    _________________________ ________
    identity_provider_type    NONE   
    ```

3. Now enable IAM as the identity provider. Query the idenity provider again to see it updated to **OCI_IAM**.

    ```
    exec dbms_cloud_admin.enable_external_authentication('OCI_IAM');

    select name, value from v\$parameter where name ='identity_provider_type';
    ```

    ```
    NAME                      VALUE      
    _________________________ __________
    identity_provider_type    OCI_IAM    
    ```

4. Create the **user\_shared** user and grant it permissions to create sessions. Create the **sr\_dba\_role** role and grant it permissions. This command and all previous ones will run when this is entered into the Cloud Shell.

    ```
    create user user_shared identified globally as 'IAM_GROUP_NAME=All_DB_Users';
    grant create session to user_shared;
    create role sr_dba_role identified globally as 'IAM_GROUP_NAME=DB_Admin';
    grant pdb_dba to sr_dba_role;
    EOF
    ```

## Task 3: Unzip wallet file and edit contents

1. unzip your ADB wallet file.

    ```
    unzip -d . lltest_wallet.zip
    ```

2. Create variable for location of wallet file.
    >**Note:** If at any point you exit out of the cloud shell, the following commands may need to be ran again.

    ```
    export TNS_ADMIN=$HOME/adb_wallet
    ```

3. update tnsname.ora and sqlnet.ora files. Append sqlnet.ora with the wallet location.

    ```
    mv tnsnames.ora tnsnames.ora.orig
    mv sqlnet.ora sqlnet.ora.orig

    echo "WALLET_LOCATION = (SOURCE = (METHOD = file) (METHOD_DATA = (DIRECTORY="/home/`whoami`/adb_wallet")))
    SSL_SERVER_DN_MATCH=yes" >> sqlnet.ora

    cat sqlnet.ora
    ```

4. Append tnsname.ora so than an authorization token can be used to access the datbase.

    ```
    head -1 tnsnames.ora.orig | sed -e 's/)))/)(TOKEN_AUTH=OCI_TOKEN)))/' > tnsnames.ora

    cat tnsnames.ora
    ```

You may now proceed to the next lab!
