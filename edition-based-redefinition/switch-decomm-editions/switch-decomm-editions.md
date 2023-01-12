## Switch to the new edition, decommission the old edition and redefine the table online

Estimated lab time: 15 minutes

### Objectives

In this lab,we will switch to the new edition (v2) and decomission the old edition. We will be also using DBMS_REDEF procedure to redefine the tables online.

## Task 1: Verify all the scripts 

All these scripts are reviewed for understanding. If you want to directly execute the script, skip **Task 1** and proceed to **Task 2** 

Now selected application containers can connect to the new edition using either a dedicated service or by issuing an `alter session` (either explicit or in the connection string).

Once the application is validated, all the new sessions can switch to the new edition by changing the database default:

However, all the applications that are sensible to the change should explicitly set the edition so that reconnections will not cause any harm.

For this demo, we will integrate this step in a changelog that decommission the old edition.

The last changelog contains the SQL files that cleanup everything, drop the old edition and redefine the table without the `phone_number` column.

All the scripts are available in **hr.00003.edition_v2_post_rollout** directory.

```text
<copy>cd changes/hr.00003.edition_v2_post_rollout</copy>
```

### 1. Alter session for v2 

Script is setting edition as v2

    cat hr.000001.alter_session.sql

    --hr.000001.alter_session.sql
    ALTER SESSION SET EDITION=V2;

### 2. Change default edition as v2

As `HR` user, we achieve that using the helper procedure previously created.Internally, the procedure just runs `execute immediate 'alter database default edition ='||edition_name;`

    cat hr.000002.change_default_edition.sql

    --hr.000002.change_default_edition.sql
    begin
    admin.default_edition('V2');
    end;
    /

###3. Drop the old edition

Here we use a helper procedure again:

    cat hr.000003.drop_old_edition.sql

```text
declare
  l_parent_edition dba_editions.edition_name%type;
begin
  select  PARENT_EDITION_NAME into l_parent_edition
    from dba_editions where edition_name='V2';
  admin.drop_edition(l_parent_edition);
end;
/
```

The user has a `grant select on dba_editions`. The `drop_edition` procedure will execute internally a `execute immediate 'DROP EDITION '||edition_name||' CASCADE`, then a `dbms_editions_utilities.clean_unusable_editions`.

### 4. Drop the cross-edition triggers

Keeping the cross-edition triggers when the previous edition is no longer in use will just add overhead to the table DMLs.

    cat hr.000004.drop_x_triggers.sql

```text
alter trigger EMPLOYEES_REVXEDITION_TRG disable;

drop trigger EMPLOYEES_REVXEDITION_TRG;

alter trigger EMPLOYEES_FWDXEDITION_TRG disable;

drop trigger EMPLOYEES_FWDXEDITION_TRG;
```

### 5. Redefine the Table: Create the interim table

    cat hr.000009.employees_create_interim.sql

Create interim table for employees$0 table 

```
create table employees$interim
    ( employee_id    NUMBER(6)
    , first_name     VARCHAR2(20)
    , last_name      VARCHAR2(25)
    , email          VARCHAR2(25)
        , country_code          VARCHAR2(3)
    , phone#   VARCHAR2(20)
    , hire_date      DATE
    , job_id         VARCHAR2(10)
    , salary         NUMBER(8,2)
    , commission_pct NUMBER(2,2)
    , manager_id     NUMBER(6)
    , department_id  NUMBER(4)
    ) ;

```

### 6. Redefine the Table: Start the redefinition

    cat hr.000010.start_redef.sql

Start redef table using DBMS_REDEFITION

```text
declare
  l_colmap varchar(512);
begin
  l_colmap :=
    'employee_id
    , first_name
    , last_name
    , email
    , country_code
    , phone#
    , hire_date
    , job_id
    , salary
    , commission_pct
    , manager_id
    , department_id';

  dbms_redefinition.start_redef_table (
    uname        => user,
    orig_table   => 'EMPLOYEES$0',
    int_table    => 'EMPLOYEES$INTERIM',
    col_mapping  => l_colmap
  );
end;
/
```

### 7. Redefine the Table: Copy the table dependents

    cat hr.000011.copy_dependents.sql

Start copy table dependents using DBMS_REDEFITION

```
declare
  nerrors number;
begin
  dbms_redefinition.copy_table_dependents
    ( user, 'EMPLOYEES$0', 'EMPLOYEES$INTERIM',
      copy_indexes => dbms_redefinition.cons_orig_params,
      num_errors => nerrors );
  if nerrors > 0  then
    raise_application_error(-20000,'Errors in copying the dependents');
  end if;
end;
/
```

### 8. Redefine the Table: Finish the redefinition

    cat hr.000012.finish_redef_table.sql

Start finish redef table using DBMS_REDEFITION

```
begin
  dbms_redefinition.finish_redef_table ( user, 'EMPLOYEES$0', 'EMPLOYEES$INTERIM');
  dbms_utility.compile_schema(schema => user, compile_all => FALSE);
end;
/
```

### 9. Redefine the table: Drop the interim table

    cat hr.000013.drop_interim_table.sql

Drop employee$interim table 

```
drop table employees$interim cascade constraints;
```

The cascade constraints is necessary for the self-referencing foreign key (employee->manager).

### 10. Run the changelog with liquibase

The changelog file will look similar to this. The script used is **hr.00003.edition_v2_post_rollout.xml** and this file is available in **changes** folder.

![v2-post-rollout](images/v2-post-rollout.png " ")

## Task 2: Run the change log 

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

Run the changelog 

```text
<copy>cd changes</copy>
<copy>lb update -changelog-file hr.00003.edition_v2_post_rollout.xml</copy>
```
![execute-changelog](images/execute-changelog.png " ")

Verify for successful execution. In case if you are getting error like the below one, restart the ATP database from OCI console and retry again.

![execute-error](images/execute-error.png " ")

You have successfully switched to the new edition, decommissioned the old edition and redefined the table online


## Acknowledgements

- Author - Ludovico Caldara and Suraj Ramesh 
- Last Updated By/Date -Suraj Ramesh, Jan 2023