# Audit Direct User Activities

## Introduction
Before Oracle Database 18c, the audit policies record user activities, including both directly issued events and recursive SQL statements.

In Oracle Database 19c, auditing can exclude recursive SQL statements. Top-level statements are SQL statements that users directly issue. These statements can be important for both security and compliance. SQL statements run from within PL/SQL procedures or functions are not considered top-level because they may be less relevant for auditing purposes.

Estimated Time: 15 minutes

### Objectives
- Prepare your environment
- Create the table and the procedure
- Create and enable the Audit Policy
- Audit the user activities including recursive statements
- Display the audited activities
- Audit the top-level statements only
- Display the top-level audited activities
- Reset your environment

### Prerequisites
  This lab assumes you have:
  - Obtained and signed in to your `workshop-installed` compute instance

## Task 1: Prepare your environment

> **NOTE:** Unless otherwise stated, all passwords will be `Ora4U_1234`. When copying and pasting a command that includes a password, please replace the word `password` with `Ora4U_1234`. This only applies to instances created through OCI Resource Manager with our provided terraform scripts.

1. Open a terminal window on the desktop.

2. Set the Oracle environment variables. At the prompt, enter CDB1.

    ```
    $ <copy>. oraenv</copy>
    CDB1
    ```


## Task 2: Create the table and the procedure
1. Log in to PDB1 as `SYS`.
   
    ```
    $ <copy>sqlplus sys/password@PDB1 as sysdba</copy>

    Connected.
    ```

2. Query the HR.EMPLOYEES table.

    ```
    SQL> <copy>SELECT employee_id, salary FROM hr.employees; </copy>

    107 rows selected.
    ```

3. Create a procedure that allows the HR user to raise the employees’ salaries in PDB1.

    ```
    SQL> <copy>@$HOME/labs/19cnf/create_proc.sql</copy>
    ```

## Task 3: Create and enable the audit policy

1. Create the security officer. The security officer is the one responsible for managing audit policies.

    ```
    SQL> <copy>CREATE USER auditor_admin IDENTIFIED BY password;</copy>

    User created.
    ```

2. Grant the security officer the CREATE SESSION system privilege and the AUDIT_ADMIN role.
   
    ```
    SQL> <copy>GRANT create session, audit_admin TO auditor_admin;</copy>

    Grant succeeded.
    ```

3. Connect to PDB1 as auditor_admin.

    ```
    SQL> <copy>CONNECT auditor_admin/password@PDB1</copy>

    Connected.
    ```

4. Create an audit policy that audits any salary increase.

    ```
    SQL> <copy>CREATE AUDIT POLICY pol_sal_increase
                      ACTIONS UPDATE ON hr.employees;</copy>

    Audit policy created.
    ```

5. Enable the audit policy.

    ```
    SQL> <copy>AUDIT POLICY pol_sal_increase WHENEVER SUCCESSFUL;</copy>

    Audit succeeded.
    ```

## Task 4: Audit the user activities including recursive statements

1. In another terminal session, set the Oracle environment variables. Enter **CDB1** when prompted.

    ```
    $ <copy>. oraenv</copy>

    CDB1
    ```
2. In this session, which will be labelled `session2`, log into PDB1 as `HR`.

    ```
    $ <copy>sqlplus hr/password@PDB1</copy>
    ```

2. Increase the salary for employee ID 106 through the `RAISE_SALARY` procedure.

    ```
    SQL> <copy>EXEC emp_admin.raise_salary(106,10)</copy>

    PL/SQL procedure successfully completed.
    ```

3. Still in `session2`, update the row directly and commit.

    ```
    SQL> <copy>UPDATE hr.employees SET salary=salary*0.1
    WHERE  employee_id = 106;</copy>

    1 row updated.
    ```
4. Commit the changes.

    ```
    SQL> <copy>COMMIT;</copy>

    Commit completed.
    ```

## Task 5: Display the activities audited

1. Verify from `session1` that the update actions executed through the PL/SQL procedure and directly by the UPDATE command are audited.

    ```
    SQL> <copy>SELECT action_name, object_name, sql_text
       FROM   unified_audit_trail
       WHERE  unified_audit_policies = 'POL_SAL_INCREASE';</copy>

    ACTION_NAME  OBJECT_NAME SQL_TEXT
    ----------- ------------ ------------------------------------------------------------------- 
    UPDATE       EMPLOYEES    UPDATE EMPLOYEES SET SALARY = SALARY + :B2 WHERE EMPLOYEE_ID = :B1
    

    UPDATE       EMPLOYEES    UPDATE hr.employees SET salary=salary*0.1 WHERE  employee_id = 106
    ```

2. Disable the audit policy.

    ```
    SQL> <copy>NOAUDIT POLICY pol_sal_increase;</copy>

    Noaudit succeeded.
    ```

3. Drop the audit policy.

    ```
    SQL> <copy>DROP AUDIT POLICY pol_sal_increase;</copy>

    Audit Policy dropped.
    ```

## Task 6: Audit the top-Level statements only

1. Create an audit policy that audits any salary increase executed directly with an UPDATE command only.

    ```
    SQL> <copy>CREATE AUDIT POLICY pol_sal_increase_direct
                      ACTIONS UPDATE ON hr.employees ONLY TOPLEVEL;</copy>

    Audit policy created.
    ```

2. Enable the audit policy.

    ```
    SQL> <copy>AUDIT POLICY pol_sal_increase_direct WHENEVER SUCCESSFUL;</copy>

    Audit succeeded.
    ```

3. In `session2`, connect as HR to PDB1.

    ```
    SQL> <copy>CONNECT hr/password@PDB1</copy>

    Connected.
    ```

4. Increase the salary for employee ID 107 through the RAISE_SALARY procedure.

    ```
    SQL> <copy>EXEC emp_admin.raise_salary(107,30)</copy>

    PL/SQL procedure successfully completed.
    ```

5. Still in `session2`, update the row directly and commit.

    ```
    SQL> <copy>UPDATE hr.employees SET salary=salary*0.1
    WHERE  employee_id = 107;</copy>

    1 row updated.
    ```

6. Commit the changes.

    ```
    SQL> <copy>COMMIT;</copy>
    ```

## Task 7: Display the top-Level activities audited

1. Verify from `session1` that the update actions executed through the PL/SQL procedure are not audited.

    ```
    SQL> <copy>SELECT action_name, object_name, sql_text FROM unified_audit_trail
    WHERE  unified_audit_policies = 'POL_SAL_INCREASE_DIRECT';</copy>

    ACTION_NAME  OBJECT_NAME
    ------------ ------------
    SQL_TEXT
    ---------------------------------------------------------
    UPDATE       EMPLOYEES
    UPDATE hr.employees SET salary=salary*0.1 WHERE employee_id = 107
    ```

Observe that only the direct UPDATE statement is audited as this is the purpose of the ONLY TOPLEVEL clause of the CREATE AUDIT POLICY command.

## Task 8: Reset your environment

1. In `session1`, disable the audit policy.

    ```
    SQL> <copy>NOAUDIT POLICY pol_sal_increase_direct;</copy>

    Noaudit succeeded.
    ```

2. Drop the audit policy.

    ```
    SQL> <copy>DROP AUDIT POLICY pol_sal_increase_direct;</copy>

    Audit Policy dropped.
    ```
3. Connect as `SYSTEM` to PDB1.

    ```
    SQL> <copy>CONNECT system/password@PDB1</copy>

    Connected.
    ```

4. Drop the auditor_admin user.

    ```
    SQL> <copy>DROP USER auditor_admin CASCADE;</copy>

    User dropped.
    ```
5. Quit the session. You may quit `session2` as well.

    ```
    SQL> <copy>EXIT</copy>
    ```

    You may now **proceed to the next lab**.

## Acknowledgements
- **Author**- Dominique Jeunot, Consulting User Assistance Developer
- **Technical Contributor** -  Blake Hendricks, Austin Specialist Hub
- **Last Updated By/Date** - Matthew McDaniel, Austin Specialist Hub, December 21 2021
