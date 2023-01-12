# Review and update new edition scripts

Estimated lab time: 10 minutes

### Objectives

In this lab,you will review the new edition scripts to create a new edition and split employees.phone_number to country_code and phone#


## Task 1: Review the new edition scripts

FRom the Cloud Shell home,navigate to *changes/hr.00002.edition_v2* directory 

```text
<copy>cd changes/hr.00002.edition_v2</copy>
<copy>ls -ltr</copy>
```

You will be able to see the list of new edition scripts.

![list v2 scripts](images/list-scripts.png " ")

Lets review all the scripts as below. **If you interested to know the details of the scripts you can review, else you can skip this and jump to Task #2**

1. Create the new edition

For this, we will use the helper function created earlier:

    cat hr.000001.edition_v2.sql

    begin
    admin.create_edition('V2');
    end;
    /

This runs the CREATE EDITION V2 and GRANT USE ON EDITION V2 to HR.

Remember, for real-world scenarios, it would be best to have separate PDBs per developer so that there are no conflicts in the management of editions.

2. Use the new edition

The second one is also important, as it sets the edition for the subsequent changesets:

    cat hr.000002.alter_session.sql

    ALTER SESSION SET EDITION=V2;

The second changesets must always run in the changelog to ensure that the correct edition is set (in case after an error liquibase disconnects and reconnects again to the previous edition), so we will call it with the parameter runAlways=true: 

This can be verified by opening the file hr.00002.edition_v2.xml in changes directory

    cd changes/ 
    cat hr.00002.edition_v2.xml 

![alter-session](images/alter-session.png " ")

The other changesets have a different splitStatements parameter depending on their nature (SQL or PL/SQL).

3. Add the new columns

This operation is online for subsequent DMLs but must wait on the existing ones. We specify a DDL timeout:

    cd changes/hr.00002.edition_v2

    cat hr.000003.employee_add_columns.sql

    alter session set DDL_LOCK_TIMEOUT=30;

    alter table employees$0 add (
    country_code varchar2(3),
    phone# varchar2(20)
    );

4. Create the forward cross-edition trigger and enable the trigger

Two triggers make sure that changes done in the old and new editions populate the columns correctly.

The forward crossedition trigger propagates the changes from the old edition to the new columns. There will be a reverse one that will do the same for DMLs on the new edition.

    cat hr.000004.employee_forward_trigger.sql

![employee-forward-trigger](images/employee-forward-trigger.png " ")

Enable the trigger

    cat hr.000005.employee_enable_forward_trigger.sql

    alter trigger employees_fwdxedition_trg enable;

5. Populate the new columns

Before populating the new columns, we wait for the current DMLs to finish:

     cat hr.000006.employee_wait_on_pending_dml.sql

![pending dml](images/pending-dml.png " ")


The population happens by applying the trigger on the rows of the table, using a special dbms_sql.parse call:

    cat hr.000007.employee_transform_rows.sql

![employee transform](images/employee-transform.png " ")

6. Create the reverse trigger and enable trigger

Before using the new edition, we create the reverse trigger so that new DMLs on the new columns will update the old column for the applications still running in the old edition:

    cat hr.000008.employee_reverse_trigger.sql

![employee reverse](images/employee-reverse.png " ")

Enable the trigger 

    cat hr.000009.employee_enable_reverse_trigger.sql

    alter trigger employees_revxedition_trg enable;

7. Create the new version of the editioning view

The editioning view is "the surrogate" of the base table. In the new edition, we want to have country_code and phone# columns, and we omit phone_number. Note that we can also choose the order of the column in the definition.

      cat hr.000010.view_employees.sql

     CREATE OR REPLACE EDITIONING VIEW employees AS
     SELECT employee_id, first_name, last_name, email, country_code, phone#, hire_date, job_id, salary, commission_pct, manager_id, department_id FROM employees$0;

8. Actualize the objects

Now that the modifications to the existing objects have been made, we can "transfer" all the inherited objects from the previous version to the new one, and at the same time validate/recompile them (nobody is using them yet).

    cd changes/common

    cat actualize_all.sql

![Actualize all](images/actualize-all.png " ")

## Task 2: Run liquibase update for the new changelog 

```text
suraj_rame@cloudshell:~ (us-ashburn-1)$ pwd
/home/suraj_rame
suraj_rame@cloudshell:~ (us-ashburn-1)$ 
```

***Home folder will be different for you***

```text
<copy>sql /nolog</copy>
```

```text
<copy>set cloudconfig ebronline.zip</copy>
<copy>connect hr/Welcome#Welcome#123@ebronline_medium</copy>
<copy>show user</copy>
<copy>pwd</copy>
```

![sqlcl-hr](images/sqlcl-hr.png " ")

Run the v2 changelog

```text
<copy>cd changes</copy>
<copy>lb update -changelog-file hr.00002.edition_v2.xml</copy>
```

![Lb V2 changelog ](images/lb-changelog-v2.png " ")

Verify for the successfully execution.


You have successfully executed the new changelog the HR schema [proceed to the next lab](#next)

## Acknowledgements

- Author - Ludovico Caldara and Suraj Ramesh 
- Last Updated By/Date -Suraj Ramesh, Jan 2023