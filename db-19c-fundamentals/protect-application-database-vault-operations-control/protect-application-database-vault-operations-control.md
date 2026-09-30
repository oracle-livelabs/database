# Protect Application Data by using Database Vault Operations Control

## Introduction
In Oracle Database 18c, Oracle Database Vault provides command rules and realms to protect sensitive data from users with system privileges and object privileges (mandatory realms). A command rule controls whether a particular SQL command can be executed for a given circumstance. A realm can prevent a user from accessing protected objects if the user is not authorized in the realm. This protection requires the creation and configuration of command rules or realms.

Starting in Oracle Database 19c, Oracle Database Vault provides an extra layer of protection on the database objects. Database Vault Operations Control creates a wall between common users in databases and the customer database data that resides in the associated PDBs. Database Vault Operations Control prevents common users from accessing application local data that resides in PDBs. The capability allows you to store sensitive data for your business applications and manage the database without having to access the sensitive data in PDBs.

In this lab, you will learn how to use Database Vault Operations Control to automatically restrict common users from accessing PDB local data in autonomous, regular Cloud, or on-premise environments.

Estimated Time: 25 minutes

### Objectives

In this lab, you will:

- Prepare your environment
- Create a table in the PDB
- Configure and enable Database Vault in the CDB root
- Enable Database Vault Operations
- Test Database Vault Operations Control
- Complete administrative tasks in PDBs
- Add users to an exception list to allow to operations in PDBs
- Reset your environment

### Prerequisites

This lab assumes you have:
- Obtained and signed in to your `workshop-installed` compute instance

## Task 1: Prepare your environment

> **NOTE:** Unless otherwise stated, all passwords will be `Ora4U_1234`. When copying and pasting a command that includes a password, please replace the word `password` with `Ora4U_1234`. This only applies to instances created through OCI Resource Manager with our provided terraform scripts.

1. Open a terminal window on the desktop and set the Oracle environment variables. At the prompt, enter **CDB1**.

    ```
    $ <copy>. oraenv</copy>
    CDB1
    ```

2. Run the cleanup_PDBs_in_CDB1.sh shell script to recreate PDB1 and remove other PDBs in CDB1 if they exist. You can ignore any error messages.

    ```
    $ <copy>$HOME/labs/19cnf/cleanup_PDBs_in_CDB1.sh</copy>
    ```

3. Execute the `$HOME/labs/glogin.sh` script to set formatting for all columns selected in queries.

    ```
    $ <copy>$HOME/labs/19cnf/glogin.sh</copy>
    ```

4. This lab requires `ARCHIVELOG` mode to be enabled, execute the following shell script to enable it. At the prompt, enter **CDB1**.

    ```
    $ <copy>$HOME/labs/19cnf/enable_ARCHIVELOG.sh</copy>
    CDB1
    ```


5. Connect to CDB1 as the `SYS` user.

    ```
    $ <copy>sqlplus / as sysdba</copy>
    ```

6. Open PDB1. If PDB1 is already open, the results will say so; otherwise, PDB1 is opened.

    ```
    SQL> <copy>alter pluggable database PDB1 open;</copy>

    Pluggable database altered.
    ```

7. Connect to PDB1.

    ```
    SQL> <copy>alter session set container = PDB1;</copy>

    Session altered.
    ```

## Task 2: Create a table in the PDB

1. Check that the user `SYS` is connected to PDB1.

    ```
    SQL> <copy>show con_name</copy>

    CON_NAME
    ------------------------------
    PDB1  
    ```

2. Query the `HR.EMPLOYEES` table. The results show that the table exists and has 107 rows.

    ```
    SQL> <copy>SELECT count(*) FROM HR.EMPLOYEES;</copy>

      COUNT(*)
    ----------
          107
    ```

3. Verify that neither Oracle Database Vault nor Database Vault Operations Control is configured in PDB1.

    ```
    SQL> <copy>SELECT * FROM dba_dv_status;</copy>

    NAME                           STATUS
    ------------------------------ --------------
    DV_APP_PROTECTION              NOT CONFIGURED
    DV_CONFIGURE_STATUS            FALSE
    DV_ENABLE_STATUS               FALSE
    ```

> **Note**: `DV_APP_PROTECTION` status of `NOT CONFIGURED` means that Operations Control is not configured. If you have already completed the next lab, Restrict Users from Executing the AUDIT POLICY and NOAUDIT POLICY SQL Commands by Using Oracle Database Vault Command, then `DV_CONFIGURE_STATUS` will will have a `STATUS` of `TRUE`.

## Task 3: Configure and enable Database Vault in the CDB root

In this task, you will configure Database Vault at the CDB root level, ensuring that the `DV_OWNER` role is granted locally in the CDB root to the common Oracle Database Vault owner, `C##SEC_ADMIN`. Granting `DV_OWNER` locally prevents the CDB common user with `DV_OWNER` from changing containers or logging into PDBs with this role and changing customer DV controls.

1. Log in to the CDB root as `SYS`

    ```
    SQL> <copy>connect sys/password as sysdba</copy>

    Connected.
    ```

2. Execute the `drop_create_user_sec_admin.sql` script that creates the Database Vault `C##SEC_ADMIN` owner and the Database Vault `C##ACCTS_ADMIN` account manager in the CDB root. Update the passwords in the SQL script, if necessary.

    ```
    SQL> <copy>@$HOME/labs/19cnf/drop_create_user_sec_admin.sql</copy>
    ```

3. Reconnect to CDB root after previous script forces exit from SQL*Plus.

    ```
    $ <copy>sqlplus / as sysdba</copy>
    ```

    Verify that container is CDB root.

    ```
    SQL> <copy>show con_name</copy>

    CON_NAME
    ------------------------------
    CDB$ROOT

    ```

4. Configure Database Vault at the CDB root level ensuring that the `DV_OWNER` role is granted locally in the CDB root to the common Oracle Database Vault owner, `C##SEC_ADMIN`.

    ```
    SQL> <copy>exec DVSYS.CONFIGURE_DV ( dvowner_uname =>'c##sec_admin',-
                                         dvacctmgr_uname =>'c##accts_admin', -
                                         force_local_dvowner => TRUE)</copy>

    PL/SQL procedure successfully completed.
    ```

5. Observe the Oracle Database Vault status in the CDB root. Oracle Database Vault is configured but Database Vault Operations Control is not configured.

    ```
    SQL> <copy>SELECT * FROM dba_dv_status;</copy>

    NAME                     STATUS
    ------------------------ --------------
    DV_APP_PROTECTION        NOT CONFIGURED
    DV_CONFIGURE_STATUS      TRUE
    DV_ENABLE_STATUS         FALSE
    ```

6. Log in to PDB1.

    ```
    SQL> <copy>CONNECT sys/password@PDB1 as sysdba</copy>

    Connected.
    ```

7. Observe the Oracle Database Vault status in PDB1.

    ```
    SQL> <copy>SELECT * FROM dba_dv_status;</copy>

    NAME                     STATUS
    ------------------------ --------------
    DV_APP_PROTECTION        NOT CONFIGURED
    DV_CONFIGURE_STATUS      FALSE
    DV_ENABLE_STATUS         FALSE
    ```

8. Check that the user SYS can still count the `HR.EMPLOYEES` table rows.

    ```
    SQL> <copy>SELECT count(*) FROM HR.EMPLOYEES;</copy>

    COUNT(*)
    ----------
          107
    ```

## Task 4: Enable Database Vault Operations Control

1. In the CDB root, login as `C##ACCTS_ADMIN`.
    ```
    SQL> <copy>CONNECT c##accts_admin/password</copy>

    Connected.
    ```

2. Create a common user to grant the `CREATE SESSION` and `SELECT ANY TABLE` privileges.

    ```
    SQL> <copy>CREATE USER c##common IDENTIFIED BY password CONTAINER=ALL;</copy>

    User created.
    ```

3. Login as `SYS`.

    ```
    SQL> <copy> CONNECT / as sysdba</copy>

    Connected.
    ```

4. Grant the `CREATE SESSION` and `SELECT ANY TABLE` privileges to the common user.

    ```
    SQL> <copy>GRANT create session, select any table TO c##common CONTAINER=ALL;</copy>

    Grant succeeded.
    ```

5. Connect to PDB1 as the common user.

    ```
    SQL> <copy>CONNECT c##common/password@PDB1</copy>

    Connected.
    ```

6. Verify that the common user can query the `HR.EMPLOYEES` table.

    ```
    SQL> <copy>SELECT count(*) FROM hr.employees;</copy>

    COUNT(*)
    ----------
           107
    ```

7. Login as `SYS`.

    ```
    SQL> <copy>CONNECT / as sysdba</copy>

    Connected.
    ```

8.  Enable Database Vault Operations Control in the CDB root. An error should occur when running this command because the Database Vault is not enabled in the CDB root. The next step will show how to first enable Oracle Database Vault in the CDB root.

    ```
    SQL> <copy>EXEC dvsys.dbms_macadm.enable_app_protection</copy>
    BEGIN dvsys.dbms_macadm.enable_app_protection; END;
    *
    ERROR at line 1:
    ORA-47503: Database Vault is not enabled in CDB$ROOT or application root.
    ORA-06512: at "DVSYS.DBMS_MACADM", line 2811
    ORA-06512: at line 1
    ```

9.  Log in to CDB1 as the Oracle Database Vault owner, `C##SEC_ADMIN`.

    ```
    SQL> <copy>CONNECT c##sec_admin/password@CDB1</copy>

    Connected.
    ```
10. Enable Oracle Database Vault in CDB1.

    ```
    SQL> <copy>EXEC dvsys.dbms_macadm.enable_dv</copy>

    PL/SQL procedure successfully completed.
    ```

11. Login as `SYS`.

    ```
    SQL> <copy>CONNECT / as sysdba</copy>

    Connected.
    ```

12. Shutdown the database instance to enforce DV configuration and enabling.

    ```
    SQL> <copy>shutdown immediate</copy>
    ```

13. Start the database.

    ```
    SQL> <copy>startup</copy>
    ```

14. If the PDB1 is not automatically opened, then manually open it.

    ```
    SQL> <copy>ALTER PLUGGABLE DATABASE PDB1 OPEN;</copy>
    ```

15. Verify the Oracle Database Vault status in the CDB root. The result should show that the Oracle Database Vault is configured and enabled but Database Vault Operations Control is still not configured.

    ```
    SQL> <copy>SELECT * FROM dba_dv_status;</copy>

    NAME                     STATUS
    ------------------------ --------------
    DV_APP_PROTECTION        NOT CONFIGURED
    DV_CONFIGURE_STATUS      TRUE
    DV_ENABLE_STATUS         TRUE
    ```

16. Log in to the CDB root as the common account with the `DV_OWNER` role.

    ```
    SQL> <copy>CONNECT c##sec_admin/password</copy>
    ```

17.  Enable Database Vault Operations Control.

    ```
    SQL> <copy>EXEC dvsys.dbms_macadm.enable_app_protection</copy>

    PL/SQL procedure successfully completed.
    ```

18. Login as `SYS`.

    ```
    SQL> <copy>CONNECT / as sysdba</copy>
    ```

19. Verify the Oracle Database Vault Operations Control status in the CDB root.

    ```
    SQL> <copy>SELECT * FROM dba_dv_status;</copy>

    NAME                     STATUS
    ------------------------ --------------
    DV_APP_PROTECTION        ENABLED
    DV_CONFIGURE_STATUS      TRUE
    DV_ENABLE_STATUS         TRUE
    ```

20. Connect to PDB1 as `SYS`.
    ```
    SQL> <copy>CONNECT sys/password@PDB1 as sysdba</copy>

    Connected.
    ```

21. Verify the Oracle Database Vault Operations Control status in PDB1.
    
    ```
    SQL> <copy>SELECT * FROM dba_dv_status;</copy>

    NAME                     STATUS
    ------------------------ --------------
    DV_APP_PROTECTION        ENABLED
    DV_CONFIGURE_STATUS      FALSE
    DV_ENABLE_STATUS         FALSE
    ```

Observe that Oracle Database Vault Operations Control is enabled at the PDB level with its status inherited from the CDB root. Oracle Database Vault is not required to be configured and enabled in PDBs, but must be configured and enabled at the CDB root level.

## Task 5: Test Database Vault Operations Control

1. Connect to PDB1 as the common user.

    ```
    SQL> <copy>CONNECT c##common/password@PDB1</copy>

    Connected.
    ```
2. Verify that the common user cannot query the `HR.EMPLOYEES` table due to insufficient privileges.

    ```
    SQL> <copy>SELECT * FROM hr.employees;</copy>
    SELECT * FROM hr.employees
                 *
    ERROR at line 1:
    ORA-01031: insufficient privileges
    ```

## Task 6: Complete administrative tasks in PDBs

In this task, you back up the PDB although Oracle Database Vault Operations Control is enabled. Because database patching, backing up, restoring, and upgrading do not touch customer schemas, DBAs and privileged common users can still run tools as `SYSDBA` to patch, backup, restore, and upgrade the database (with `DV_PATCH_ADMIN` granted commonly in the CDB root).

1. Grant to PDB1 as `SYS`.

    ```
    SQL> <copy>CONNECT sys/password@PDB1 as sysdba</copy>

    Connected.
    ```

2. Grant `SYSDBA` to `c##common`.

    ```
    SQL> <copy>GRANT sysdba TO c##common;</copy>

    Grant succeeded.
    ```

3. Quit the session.

    ```
    SQL> <copy>exit</copy>
    ```

4. Use RMAN to back up PDB1. Connect as the common user to PDB1.

    ```
    $ <copy>rman target c##common@PDB1/password</copy>

    connected to target database: CDB1:PDB1 (DBID=30627184)
    ```

5. Backup PDB1;

    ```
    RMAN> <copy>BACKUP DATABASE;</copy>
    ```

Although common users cannot query application data in PDBs, they can still complete administrative tasks for which they are granted privileges.

6. Quit the RMAN session.

    ```
    RMAN> <copy>exit</copy>
    ```

## Task 7: Add users to an exception list to allow access to operations in PDBs

In this task, you will maintain the exception list of common users and packages so that the tasks that need to be completed by common users can be completed despite Database Vault Operations Control being enabled. These common users are automation accounts, not used by humans.

HR application data in PDB1 is very sensitive and should be protected against common users in the CDB. Nevertheless, the `C##REPORT` common user should be able to access some of the HR application information in PDB1 to generate statistics for Human Resources.

1. Log in as the `C##ACCTS_ADMIN` user who has been granted the `DV_ACCTMGR` role.

    ```
    $ <copy>sqlplus c##accts_admin/password</copy>

    Connected.
    ```

2. Create the common user `C##REPORT`.

    ```
    SQL> <copy>CREATE USER c##report IDENTIFIED BY password CONTAINER=ALL;</copy>

    User created.
    ```

3. Connect as `SYS`.

    ```
    SQL> <copy>CONNECT / as sysdba</copy>

    Connected.
    ```

4. Grant `CREATE SESSION` and `SELECT ANY TABLE` to `C##REPORT`.

    ```
    SQL> <copy>GRANT create session, select any table TO c##report CONTAINER=ALL;</copy>

    Grant succeeded.
    ```

5. Log in as the `C##REPORT` user in PDB1.

    ```
    SQL> <copy>CONNECT c##report/password@PDB1</copy>

    Connected.
    ```
6. Check if the user can query the application data in PDB1. Error should display as shown below.

    ```
    SQL> <copy>SELECT count(*) FROM hr.employees;</copy>

    SELECT count(*) FROM hr.employees
    *
    ERROR at line 1:
    ORA-01031: insufficient privileges
    ```

The behavior is expected because Oracle Database Vault Operations Control is enabled.

7. Connect as `C##SEC_ADMIN`.

    ```
    SQL> <copy>CONNECT c##sec_admin/password</copy>

    Connected.
    ```

8. Add the user to the exception list of users and packages allowed to access local data in PDB1. This operation can only be completed in the CDB root.

    ```
    SQL> <copy>EXEC dvsys.dbms_macadm.add_app_exception (owner => 'C##REPORT', package_name => '')</copy>

    PL/SQL procedure successfully completed.
    ```

9.  Query the exception list.

    ```
    SQL> <copy>SELECT * FROM DVSYS.DBA_DV_APP_EXCEPTION;</copy>

    OWNER          PACKAGE
    -------------- --------------
    C##REPORT      %
    ```

Automation accounts frequently have procedure or functions that need to access local data. In this case, include the package name so that only the package name can access local data and not someone who has stolen the credentials and runs SQL statements.

1. Re-connect as the common user in PDB1.

    ```
    SQL> <copy>CONNECT c##report/password@PDB1</copy>
    ```

2. Check that the common user can query the application data in PDB1.
    ```
    SQL> <copy>SELECT count(*) FROM hr.employees;</copy>

    COUNT(*)
    ----------
           107
    ```

## Task 8: Reset your environment

1. Connect as `C##SEC_ADMIN`.

    ```
    SQL> <copy>CONNECT c##sec_admin/password</copy>

    Connected.
    ```

2. Disable Database Vault Operations Control.

    ```
    SQL> <copy>EXEC dvsys.dbms_macadm.disable_app_protection</copy>

    PL/SQL procedure successfully completed.
    ```

3. Connect to PDB1 as `SYS`.

    ```
    SQL> <copy>CONNECT sys/password@PDB1 as sysdba</copy>

    Connected.
    ```

4. Revoke the `SYSDBA` privilege from the common user in PDB1.

    ```
    SQL> <copy>REVOKE sysdba FROM c##common;</copy>

    Revoke succeeded.
    ```

5. Connect as `C##ACCTS_ADMIN`.

    ```
    SQL> <copy>CONNECT c##accts_admin/password</copy>

    Connected.
    ```

6. Drop the `C##COMMON` user in the CDB.

    ```
    SQL> <copy>DROP USER c##common CASCADE;</copy>

    User dropped.
    ```

7. Drop the `C##REPORT` user in the CDB.

    ```
    SQL> <copy>DROP USER c##report CASCADE;</copy>

    User dropped.
    ```

8.  Quit the session.

    ```
    SQL> <copy>exit</copy>
    ```

9. Disable archivelog mode. At the prompt, enter **CDB1**.

    ```
    $ <copy>$HOME/labs/19cnf/disable_ARCHIVELOG.sh</copy>
    CDB1
    ```

    You may now **proceed to the next lab**.


## Learn More

- [New Features in Oracle Database 19c](https://docs.oracle.com/en/database/oracle/oracle-database/19/newft/preface.html#GUID-E012DF0F-432D-4C03-A4C8-55420CB185F3)

## Acknowledgements

- **Author**- Dominique Jeunot, Consulting User Assistance Developer
- **Technical Contributor** - Kherington Barley, Austin Specalist Hub.
- **Last Updated By/Date** - Matthew McDaniel, Austin Specialist Hub, December 21 2021
