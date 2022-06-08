# Constraining AUDIT POLICY and NOAUDIT POLICY SQL Commands with Oracle Database Vault Command Rules

## Introduction

You can now use command rules to enable and disable individual unified audit policies. This enhancement provides fine-grain control over how each policy is managed, instead of having to manage all the unified audit policies in the same way through a single command rule. For example, an HR auditor can have control over his or her HR unified audit policy, but not the CRM unified audit policy. This new feature extends the AUDIT and NOAUDIT use for command rules, but when you specify unified audit policy for the command rule, you must specify AUDIT POLICY or NOAUDIT POLICY.

Estimated Time: 20 minutes

### Objectives
In this lab, you will:
- Prepare your environment
- Enable Audit Policy
- Create command rule
- Drop the audit policy as the `SYSTEM` user
- Create and attempt to modify a new audit policy
- Attempt to alter the audit policy as the Database Vault owner
- Alter the audit policy as the `SYSTEM` user
- Reset your environment

### Prerequisites

This lab assumes you have:
- Obtained and signed in to your workshop-installed compute instance.

## Task 1: Prepare your environment

> **NOTE:** Unless otherwise stated, all passwords will be `Ora4U_1234`. When copying and pasting a command that includes a password, please replace the word `password` with `Ora4U_1234`. This only applies to instances created through OCI Resource Manager with our provided terraform scripts.

1. Open a terminal window on the desktop.

2. Set the Oracle environment variables. At the prompt, enter **CDB1**.

    ```
    $ <copy>. oraenv</copy>
    ```

3. Run the cleanupPDBsin_CDB1.sh shell script to recreate PDB1 and remove other PDBs in CDB1 if they exist. You can ignore any error messages.

    ```
    $
    <copy>$HOME/labs/19cnf/cleanup_PDBs_in_CDB1.sh</copy>
    ```

4. Execute the $HOME/labs/glogin.sh script to set formatting for all columns selected in queries.

    ```
    $ <copy>$HOME/labs/19cnf/glogin.sh</copy>
    ```

5. Execute the `setup_DV_CDB1.sh` script to create and enable Oracle Database Vault in CDB1. This script is provided for convenience, if you would like to configure Oracle Database Vault manually, please explore the previous lab, Protect Application Data by Using Database Vault Operations Control. Note that you will recieve an error when running this script, please ignore it. This script will take a few minutes to execute.

    ```
    $ <copy>$HOME/labs/19cnf/setup_DV_CDB1.sh</copy>
    ```

## Task 2: Enable Audit Policy
1. Log into CDB1

    ```
    $ <copy>sqlplus system/password@PDB1</copy>
    ```

2. Create the required audit policies.

    ```
    SQL> <copy>CREATE AUDIT POLICY pol1 ACTIONS SELECT ON hr.employees;</copy>

    Audit policy created.
    ```

3. Enable audit policy.

    ```
    SQL> <copy>AUDIT POLICY pol1;</copy>

    Audit succeeded.
    ```

## Task 3: Create command rule
1. Log into PDB1 as `c##sec_admin`, this user was created during the configuration of Oracle Database Vault.

    ```
    SQL> <copy>CONNECT c##sec_admin/password@PDB1</copy>

    Connected.
    ```

2. Create a command rule that forbids users that are not `SYS` or `SYSTEM` from using the `AUDIT POLICY` and `NOAUDIT POLICY` commands in any circumstance and in PDB1. First, create a rule set to which you will associate the `Is Database Administrator` rule that checks whether the user executing a `NOAUDIT POLICY` command is granted the `DBA` role.

    ```
    SQL> <copy>EXEC dvsys.DBMS_MACADM.CREATE_RULE_SET( -
                rule_set_name    => 'Check_user', - 
                description      => 'Check user', -
                enabled          => DBMS_MACUTL.G_YES, -
                eval_options     => DBMS_MACUTL.G_RULESET_EVAL_ANY,-
                audit_options => DBMS_MACUTL.G_RULESET_AUDIT_FAIL,-
                fail_options  => DBMS_MACUTL.G_RULESET_FAIL_SILENT,-
                fail_message     => '',-
                fail_code        => '',-
            handler_options => DBMS_MACUTL.G_RULESET_HANDLER_OFF,-
                handler          => '',-
                is_static        => TRUE,-
                scope            => DBMS_MACUTL.G_SCOPE_LOCAL)</copy>
                > > > > > > > >  > > > > > > > > 
        PL/SQL procedure successfully completed.
    ```

3. Associate the predefined `Is SYS or SYSTEM User` rule to the ruleset.

    ```
    SQL> <copy>EXEC dvsys.DBMS_MACADM.ADD_RULE_TO_RULE_SET( -
             rule_set_name  => 'Check_user',-
            rule_name      => 'Is SYS or SYSTEM User')</copy>
            > > > > > >
    PL/SQL procedure successfully completed.
    ```

4. Create the command rule.

    ```
    SQL> <copy>EXEC dvsys.DBMS_MACADM.CREATE_COMMAND_RULE( -
          command       => 'AUDIT POLICY', -
          rule_set_name => 'Check_user',-               
          object_owner  => '%', -
          object_name   => 'POL1',-
          enabled       => DBMS_MACUTL.G_YES, -
          scope         => DBMS_MACUTL.G_SCOPE_LOCAL)</copy>
    > > > > > >
    PL/SQL procedure successfully completed.
    ```

## Task 4: Drop the audit policy as the `SYSTEM` user

1. Log in to PDB1 as `SYSTEM`.

    ```
    SQL> <copy>CONNECT system/password@pdb1</copy>

    Connected.
    ```

2. Disable the audit policy.

    ```
    SQL> <copy>NOAUDIT POLICY pol1;</copy>

    Noaudit succeeded.
    ```

3. Drop the audit policy.

    ```
    SQL> <copy>DROP AUDIT POLICY pol1;</copy>

    Audit Policy dropped.
    ```

   This works because we specified that only `SYS` and `SYSTEM` users should be allowed to modify the `pol1` audit policy.

## Task 5: Create a new user with `DBA` privileges

1. Log into PDB1 as `c##accts_admin`, this account was created when you setup Oracle Database Vault.

    ```
    SQL> <copy>CONNECT c##accts_admin/password@PDB1;</copy>

    Connected.
    ```

2. Create a DBA junior and grant the user the `DBA` role in PDB1.

    ```
    SQL> <copy>CREATE USER dba_junior IDENTIFIED BY password;</copy>

    User created.
    ```

3. Connect as the `SYS` user.

    ```
    SQL> <copy>CONNECT sys/password@PDB1 as sysdba;</copy>

    Connected.
    ```
4. Grant the `DBA` privilege to `dba_junior`.

    ```
    SQL> <copy>GRANT dba TO dba_junior;</copy>

    Grant succeeded.
    ```

## Task 6: Create and attempt to modify a new audit policy
1. Connect to PDB1 as `dba_junior` and create an audit policy.

    ```
    SQL> <copy>CONNECT dba_junior/password@PDB1</copy>

    Connected.
    ```
2. Create new audit policy.

    ```
    SQL> <copy>CREATE AUDIT POLICY pol1 ACTIONS SELECT ON hr.employees;</copy>

    Audit policy created.
    ```
3. Enable `AUDIT` on `pol1`.

    ```
    SQL> <copy>AUDIT POLICY pol1;</copy>

    ERROR at line 1:
    ORA-47400: Command Rule violation for AUDIT POLICY on POL1
    ```
   This fails because of the previously defined command rule.
   
## Task 7: Attempt to alter the audit policy as the Database Vault owner.
1. Attempt to execute `NOAUDIT` on `pol1` as `c##sec_admin`. First, connect to PDB1 as `c##sec_admin`.

    ```
    SQL> <copy>CONNECT c##sec_admin/password@PDB1</copy>

    Connected.
    ```

2. Enable `NOAUDIT` on `pol1`.

    ```
    SQL> <copy>NOAUDIT POLICY pol1;</copy>

    ERROR at line 1:
    ORA-47400: Command Rule violation for AUDIT POLICY on POL1

    ```

   Although `c##sec_admin` is the Database Vault owner, it cannot disable the `AUDIT POLICY` because of the command rule we established earlier.

## Task 8: Alter the audit policy as the `SYSTEM` user

1. Drop the audit policy as the `SYSTEM` user. Log into PDB1 as the `SYSTEM` user.

    ```
    SQL> <copy>CONNECT system/password@PDB1;</copy>

    Connected.
    ```

2. Activate `NOAUDIT` on `pol1`.

    ```
    SQL> <copy>NOAUDIT POLICY pol1;</copy>

    Noaudit succeeded.
    ```

3. Drop the audit policy.

    ```
    SQL> <copy>DROP AUDIT POLICY pol1;</copy>

    Audit Policy dropped.
    ```

4. Exit SQL*Plus.

    ```
    SQL> <copy>EXIT</copy>
    ```
## Task 9: Reset your environment
1. Reset your environment.

    ```
    $ <copy>$HOME/labs/19cnf/disable_DV_CDB1.sh</copy>
    ```

    You may now **proceed to the next lab**.
   
## Learn More

- [Database Vault Command Rule Support for Unified Audit Policies](https://docs.oracle.com/en/database/oracle/oracle-database/19/newft/new-features.html#GUID-613EED3E-389D-451F-A344-40E4C507A83F)

## Acknowledgements

- **Author**- Dominique Jeunot, Consulting User Assistance Developer
- **Technical Contributor** - Matthew McDaniel, Austin Specialists Hub
- **Last Updated By/Date** - Matthew McDaniel, Austin Specialists Hub, December 21 2021