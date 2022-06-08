# Handle Operations on Oracle-Managed and User-Managed Tablespaces Encrypted

## Introduction

This tutorial shows you how to handle operations on the metadata and data of Oracle-managed and user-managed tablespaces when the Transparent Data Encryption (TDE) keystore is closed.

In Oracle Database 19c, you must close the TDE keystore to disallow operations on encrypted tablespaces. The behavior when the keystore is closed does not depend on the type of tablespace being accessed. Operations on user-managed tablespaces or Oracle-managed tablespaces like SYSTEM, SYSAUX, UNDO, and TEMP tablespaces raise the ORA-28365 "wallet is not open" error.

Estimated Time: 15 minutes

### Objectives
- Prepare your environment
- Prepare the CDB to use TDE
- Encrypt Oracle-managed and user-managed tablespaces
- Handle encrypted data in Oracle-managed and user-managed tablespaces when keystore is closed
- Reset your environment

### Prerequisites
This lab assumes you have:
- Obtained and signed in to your `workshop-installed` compute instance

## Task 1: Prepare your environment

> **NOTE:** Unless otherwise stated, all passwords will be `Ora4U_1234`. When copying and pasting a command that includes a password, please replace the word `password` with `Ora4U_1234`. This only applies to instances created through OCI Resource Manager with our provided terraform scripts.

1. Open a terminal window on the desktop.

2. Set the Oracle environment variables. At the prompt, enter **CDB1**.

    ```
    $ <copy>. oraenv</copy>
    CDB1
    ```

## Task 2: Prepare the CDB to use TDE
1. Make the directory for the CDB1 with tde_wallet

    ```
    $ <copy>mkdir -p /u01/app/oracle/admin/CDB1/tde_wallet</copy>
    ```

2. Add the wallet location

    ```
    $ <copy>$HOME/labs/19cnf/add_wallet_location_to_sql_net.sh</copy>
    ```

3. Log in to CDB1.

    ```
    $ <copy>sqlplus / as sysdba</copy>
    ```

3. Create the keystore for the CDB in /u01/app/oracle/admin/CDB1/tde_wallet

    ```
    SQL> <copy>ADMINISTER KEY MANAGEMENT CREATE KEYSTORE '/u01/app/oracle/admin/CDB1/tde_wallet' IDENTIFIED BY password;</copy>

    keystore altered.
    ```

4. Open the keystore.

    ```
    SQL> <copy>ADMINISTER KEY MANAGEMENT SET KEYSTORE OPEN IDENTIFIED BY password CONTAINER=ALL;</copy>

    keystore altered.
    ```

5. Set the TDE master encryption key.

    ```
    SQL> <copy>ADMINISTER KEY MANAGEMENT SET KEY IDENTIFIED BY password WITH BACKUP CONTAINER=ALL;</copy>

    keystore altered.
    ```
 
6. Create a user-managed tablespace.

    ```
    SQL> <copy>CREATE TABLESPACE omtbs DATAFILE '/u01/app/oracle/oradata/CDB1/omts01.dbf' SIZE 10M;</copy>

    Tablespace created.
    ```

7. Check that the tablespaces are not encrypted.

    ```
    SQL> <copy>SELECT tablespace_name, encrypted FROM dba_tablespaces;</copy>

    TABLESPACE_NAME   ENC
    ----------------- ---
    SYSTEM            NO
    SYSAUX            NO
    UNDOTBS1          NO
    TEMP              NO
    USERS             NO
    OMTBS             NO
    ```

## Task 3: Encrypt Oracle-managed and user-managed tablespaces
In this section, you close the keystore and see which operations on Oracle-managed tablespaces and user-managed tablespaces can be handled on the metadata and data.

1. Close the keystore.

    ```
    SQL> <copy>ADMINISTER KEY MANAGEMENT SET KEYSTORE CLOSE IDENTIFIED BY password CONTAINER = ALL;</copy>

    keystore altered.
    ```

2. Switch one of the Oracle-managed tablespaces to encryption.

    ```
    SQL> <copy>ALTER TABLESPACE system ENCRYPTION ENCRYPT;</copy>
    ALTER TABLESPACE system ENCRYPTION USING ENCRYPT
    *
    ERROR at line 1:
    ORA-28365: wallet is not open
    ```

3. Switch one of the user-managed tablespaces to encryption.

    ```
    SQL> <copy>ALTER TABLESPACE omtbs ENCRYPTION ENCRYPT;</copy>
    ALTER TABLESPACE omtbs ENCRYPTION ENCRYPT
    *
    ERROR at line 1:
    ORA-28365: wallet is not open
    ```

4. Open the keystore.

    ```
    SQL> <copy>ADMINISTER KEY MANAGEMENT SET KEYSTORE OPEN IDENTIFIED BY password CONTAINER = ALL;</copy>

    keystore altered.
    ```

5. Switch one of the Oracle-managed tablespaces to encryption.

    ```
    SQL> <copy>ALTER TABLESPACE system ENCRYPTION ENCRYPT;</copy>

    Tablespace altered.
    ```

6. Switch one of the user-managed tablespaces to encryption.

    ```
    SQL> <copy>ALTER TABLESPACE omtbs ENCRYPTION ENCRYPT;</copy>

    Tablespace altered.
    ```

7. Check that the tablespaces are encrypted.

    ```
    SQL> <copy>SELECT tablespace_name, encrypted FROM dba_tablespaces;</copy>

    TABLESPACE_NAME   ENC
    ----------------- ---
    SYSTEM            YES
    SYSAUX            NO
    UNDOTBS1          NO
    TEMP              NO
    USERS             NO
    OMTBS             YES

    6 rows selected.
    ```

## Task 4: Handle encrypted data in Oracle-managed and user-managed tablespaces when keystore is closed
1. Close the keystore.

    ```
    SQL> <copy>ADMINISTER KEY MANAGEMENT SET KEYSTORE CLOSE IDENTIFIED BY password CONTAINER = ALL;</copy>
    ```

2. Change the encryption algorithm in SYSTEM tablespace.
    ```

    SQL> <copy>ALTER TABLESPACE system ENCRYPTION USING 'AES128' ENCRYPT;</copy>
    ALTER TABLESPACE system ENCRYPTION USING 'AES128' ENCRYPT
    *
    ERROR at line 1:
    ORA-28365: wallet is not open
    ```

3. Change the encryption algorithm in OMTBS tablespace.
    ```

    SQL> <copy>ALTER TABLESPACE omtbs ENCRYPTION USING 'AES128' ENCRYPT;</copy>
    ALTER TABLESPACE omtbs ENCRYPTION USING 'AES128' ENCRYPT
    *
    ERROR at line 1:
    ORA-28365: wallet is not open
    ```

The operation fails because the operation affects the metadata of the Oracle-managed and user-managed tablespaces.

4. Create a table and insert data in the tablespace SYSTEM.

    ```
    SQL> <copy>CREATE TABLE system.test (c NUMBER, C2 CHAR(4)) TABLESPACE system;</copy>

    Table created.
    ```

5. Insert data into `TEST`.

    ```
    <copy>INSERT INTO system.test VALUES (1,'Test');</copy>

    1 row created.
    ```

6. Commit the changes.

    ```
    <copy>COMMIT;</copy>

    Commit complete.
    ```

The operation completes because the operation affects only the data of the Oracle-managed tablespace and because the tablespace is an Oracle-managed tablespace.

7. Create a table and insert data in the tablespace OMTBS.

    ```
    SQL> <copy>CREATE TABLE system.test2 (c NUMBER, C2 CHAR(4)) TABLESPACE omtbs;</copy>
    CREATE TABLE system.test2
    *
    ERROR at line 1:
    ORA-28365: wallet is not open
    ```

Operations on user-managed tablespaces still raise the ORA-28365 "wallet is not open" error when the CDB root keystore is closed.
The behavior is the same in pluggable databases (PDBs).

## Task 5: Clean up the environment
1. Open the keystore.

    ```
    SQL> <copy>ADMINISTER KEY MANAGEMENT SET KEYSTORE OPEN IDENTIFIED BY password CONTAINER = ALL;</copy>

    Keystore altered.
    ```

2. Drop the SYSTEM.TEST table.

    ```
    SQL> <copy>DROP TABLE system.test;</copy>

    Table dropped.
    ```

3. Drop the user-managed tablespace.

    ```
    SQL> <copy>DROP TABLESPACE omtbs INCLUDING CONTENTS AND DATAFILES;</copy>

    Tablespace dropped.
    ```

4. Decrypt the Oracle-managed tablespaces.

    ```
    SQL> <copy>ALTER TABLESPACE system ENCRYPTION DECRYPT;</copy>

    Tablespace altered.
    ```

5. Quit the session.

    ```
    SQL> <copy>EXIT</copy>
    ```

    You may now **proceed to the next lab**.


## Acknowledgements

- **Author**- Dominique Jeunot, Consulting User Assistance Developer
- **Technical Contributor** - Blake Hendricks, Austin Specalist Hub.
- **Last Updated By/Date** - Matthew McDaniel, Austin Specialist Hub, December 21 2021

