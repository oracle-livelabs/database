# Exploring Oracle-Supplied Schema-Only Accounts

## Introduction
In Oracle Database 19c, You can now grant administrative privileges, such as SYSOPER and SYSBACKUP, to schema-only (passwordless) accounts.

Unused and rarely accessed database user accounts with administrative privileges can now become schema-only accounts. This enhancement prevents administrators from having to manage the passwords of these accounts.

Furthermore, most of the Oracle Database supplied schema-only accounts now have their passwords removed to prevent users from authenticating to these accounts.

This enhancement does not affect the sample schemas. Sample schemas are still installed with their default passwords.

Administrators can still assign passwords to the default schema-only accounts. Oracle recommends changing the schemas back to a schema-only account afterward.

The benefit of this feature is that administrators no longer have to periodically rotate the passwords for these Oracle Database provided schemas. This feature also reduces the security risk of attackers using default passwords to hack into these accounts.

In this lab, you will query the Oracle-supplied schema-only account as well as create your own schema-only account.

Estimated Time: 5 minutes

### Objectives
In this lab, you will:
- Prepare your environment
- Find the Oracle-supplied schemas that are now schema-only accounts
- Create a schema-only account with administrator privileges
- Reset your environment

### Prerequisites

This lab assumes you have:
- Obtained and signed in to your `workshop-installed` compute instance.

## Task 1: Prepare your environment

> **NOTE:** Unless otherwise stated, all passwords will be `Ora4U_1234`. When copying and pasting a command that includes a password, please replace the word `password` with `Ora4U_1234`. This only applies to instances created through OCI Resource Manager with our provided terraform scripts.

1. Open a terminal window on the desktop.

2. Set the Oracle environment variables. At the prompt, enter **CDB1**.

    ```
    $ <copy>. oraenv</copy>
    CDB1
    ```

3. Run the cleanup_PDBs_in_CDB1.sh shell script to recreate PDB1 and remove other PDBs in CDB1 if they exist. You can ignore any error messages.
    ```
    $ <copy>$HOME/labs/19cnf/cleanup_PDBs_in_CDB1.sh</copy>
    ```
   
4. Execute the `$HOME/labs/glogin.sh` script to set formatting for all columns selected in queries. 

    ```
    $ <copy>$HOME/labs/19cnf/glogin.sh</copy>
    ```

## Task 2: Find the Oracle-supplied schemas that are now schema-only accounts.
1. Sign in to SQL*Plus.
   
    ```
    $ <copy>sqlplus / as sysdba</copy>
    ```

2. Query Oracle-supplied schemas that are now schema-only accounts.

    ```
    SQL> <copy>SELECT username FROM dba_users WHERE authentication_type = 'NONE' ORDER BY 1;</copy>

    USERNAME
    ------------------------
    APPQOSSYS
    AUDSYS
    DBSFWUSER
    DBSNMP
    DIP
    DVF
    DVSYS
    GGSYS
    GSMADMIN_INTERNAL
    GSMCATUSER
    GSMROOTUSER
    GSMUSER
    LBACSYS
    MDDATA
    MDSYS
    OJVMSYS
    OLAPSYS
    ORACLE_OCM
    ORDDATA
    ORDPLUGINS
    ORDSYS
    OUTLN
    REMOTE_SCHEDULER_AGENT
    SI_INFORMTN_SCHEMA
    SYS$UMF
    SYSBACKUP
    SYSDG
    SYSKM
    SYSRAC
    WMSYS
    XDB

    31 rows selected.
    ```

## Task 3: Create a schema-only account with administrative privileges. 

1. Create new common user without password. 

    ```
    SQL> <copy>CREATE USER c##user NO AUTHENTICATION CONTAINER=ALL;</copy>

    User Created.
    ```
    
2. Grant the `sysoper` privilege to `c##user`.

    ```
    SQL> <copy>GRANT sysoper TO c##user CONTAINER=ALL;</copy>

    Grant succeeded.
    ```

3. Query the new common user and its authentication type.

    ```
    SQL> <copy>SELECT username, authentication_type from dba_users WHERE username = 'C##USER';</copy>

    USERNAME                 AUTHENTI
    ------------------------ --------
    C##USER                  NONE
    ```

4. Query the password file view `pwfile_users`.

    ```
    SQL> <copy>SELECT username, authentication_type FROM v$pwfile_users;</copy>

    USERNAME                 AUTHENTI
    ------------------------ --------
    SYS                      PASSWORD
    C##USER                  NONE
    ```

## Task 4: Reset your environment

1. Drop the common user `C##USER`.

    ```
    SQL> <copy>DROP USER C##USER;</copy>

    User dropped.
    ```

2. Exit SQL*Plus.

    ```
    SQL> <copy>EXIT</copy>
    ```
    You may now **proceed to the next lab**.

## Learn More
- [Ability to Grant or Revoke Administrative Privileges to and from Schema-Only Accounts](https://docs.oracle.com/en/database/oracle/oracle-database/19/newft/new-features.html#GUID-5A1DE85F-6485-402E-9D76-34D63186E555)
- [Passwords Removed from Oracle Database Accounts](https://docs.oracle.com/en/database/oracle/oracle-database/19/newft/new-features.html#GUID-F56ECD44-1913-4E87-BB5E-DD2B1E2CEAC1)
## Acknowledgements

- **Author**- Dominique Jeunot, Consulting User Assistance Developer
- **Contributors** - Matthew McDaniel, Austin Specialist Hub, October 2021
- **Last Updated By/Date** - Matthew McDaniel, Austin Specialist Hub, December 21 2021
