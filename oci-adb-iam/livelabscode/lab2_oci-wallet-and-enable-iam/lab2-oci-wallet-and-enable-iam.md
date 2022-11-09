# ADB Wallet and Enable IAM

## Introduction

*Estimated Lab Time*: 30 minutes (TEMP)

### Objectives
- Generate a wallet file for your ADB
- Configure your ADB to use IAM as its identity provider with the help of the wallet file
-


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

1. Configure the ADB to use OCI IAM authentication - where the wallet connects

    ```
    sql /nolog <<EOF
    set cloudconfig $HOME/adb_wallet/lltest_wallet.zip
    conn admin/Oracle123+Oracle123+@lltest_high
    ```

2. Set the IAM provider to OCI IAM (error on end select statement from v$parameter line was fixed by changing to "v\$parameter")

    ```
    select name, value from v\$parameter where name ='identity_provider_type';
    exec dbms_cloud_admin.enable_external_authentication('OCI_IAM');

    select name, value from v\$parameter where name ='identity_provider_type';
    create user user_shared identified globally as 'IAM_GROUP_NAME=All_DB_Users';
    grant create session to user_shared;
    create role sr_dba_role identified globally as 'IAM_GROUP_NAME=DB_Admin';
    grant pdb_dba to sr_dba_role;
    EOF
    ```

3. Move wallet? Not sure exactly what is done in these steps

    ```
    unzip -d . lltest_wallet.zip

    export TNS_ADMIN=$HOME/adb_wallet

    mv tnsnames.ora tnsnames.ora.orig
    mv sqlnet.ora sqlnet.ora.orig

    echo "WALLET_LOCATION = (SOURCE = (METHOD = file) (METHOD_DATA = (DIRECTORY="/home/`whoami`/adb_wallet")))
    SSL_SERVER_DN_MATCH=yes" >> sqlnet.ora

    cat sqlnet.ora

    head -1 tnsnames.ora.orig | sed -e 's/)))/)(TOKEN_AUTH=OCI_TOKEN)))/' > tnsnames.ora

    cat tnsnames.ora
    ```
