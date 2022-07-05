## Switch to the new edition,Decommission the old edition and redefine the table


Now selected application containers can connect to the new edition using either a dedicated service or by issuing an `alter session` (either explicit or in the connection string).
Once the application is validated, all the new sessions can switch to the new edition by changing the database default:
```
ALTER DATABASE DEFAULT EDITION=V2;
```
As `HR` user, we achieve that using the helper procedure previously created:
```
begin
  admin.default_edition('V2');
end;
/
```
However, all the applications that are sensible to the change should explicitly set the edition so that reconnections will not cause any harm.

For this demo, we will integrate this step in a changelog that decommission the old edition.


The last changelog contains the SQL files that cleanup everything, drop the old edition and redefine the table without the `phone_number` column.
```
hr.000001.alter_session.sql
hr.000002.change_default_edition.sql
hr.000003.drop_old_edition.sql
hr.000004.drop_x_triggers.sql
hr.000009.employees_create_interim.sql
hr.000010.start_redef.sql
hr.000011.copy_dependents.sql
hr.000012.finish_redef_table.sql
hr.000013.drop_interim_table.sql
```

### 1. Alter the session to use the new edition
For a new connection, the edition is still the default. Use the new one!
```
ALTER SESSION SET EDITION=V2;
```

### 2. Change the default edition

For this step, we use again a helper procedure that we have defined previously, and that runs with DBA privileges.
```
begin
  admin.default_edition('V2');
end;
/
```

Internally, the procedure just runs `execute immediate 'alter database default edition ='||edition_name;`


### 3. Drop the old edition
Here we use a helper procedure again:
```
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

```
alter trigger EMPLOYEES_REVXEDITION_TRG disable;

drop trigger EMPLOYEES_REVXEDITION_TRG;

alter trigger EMPLOYEES_FWDXEDITION_TRG disable;

drop trigger EMPLOYEES_FWDXEDITION_TRG;
```


### 5. Redefine the Table: Create the interim table
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
```
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
```
begin
  dbms_redefinition.finish_redef_table ( user, 'EMPLOYEES$0', 'EMPLOYEES$INTERIM');
  dbms_utility.compile_schema(schema => user, compile_all => FALSE);
end;
/
```

### 9. Redefine the table: Drop the interim table
```
drop table employees$interim cascade constraints;
```
The cascade constraints is necessary for the self-referencing foreign key (employee->manager).


### Run the changelog with liquibase
The changelog file will look similar to this:
```
<?xml version="1.0" encoding="UTF-8"?>
<databaseChangeLog
  xmlns="http://www.liquibase.org/xml/ns/dbchangelog"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.liquibase.org/xml/ns/dbchangelog
                      http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-3.1.xsd">
    <changeSet author="lcaldara" id="hr.000001.alter_session" runAlways="true">
      <sqlFile dbms="oracle" endDelimiter=";"
               path="hr.00003.edition_v2_post_rollout/hr.000001.alter_session.sql"
               relativeToChangelogFile="true" splitStatements="false" stripComments="false"/>
    </changeSet>
    <changeSet author="lcaldara" id="hr.000002.change_default_edition">
      <sqlFile dbms="oracle" endDelimiter=";"
               path="hr.00003.edition_v2_post_rollout/hr.000002.change_default_edition.sql"
               relativeToChangelogFile="true" splitStatements="false" stripComments="false"/>
    </changeSet>
    <changeSet author="lcaldara" id="hr.000003.drop_old_edition">
      <sqlFile dbms="oracle" endDelimiter=";"
               path="hr.00003.edition_v2_post_rollout/hr.000003.drop_old_edition.sql"
               relativeToChangelogFile="true" splitStatements="false" stripComments="false"/>
    </changeSet>
    <changeSet author="lcaldara" id="hr.000004.drop_x_triggers">
      <sqlFile dbms="oracle" endDelimiter=";"
               path="hr.00003.edition_v2_post_rollout/hr.000004.drop_x_triggers.sql"
               relativeToChangelogFile="true" splitStatements="true" stripComments="false"/>
    </changeSet>
    <changeSet author="lcaldara" id="hr.000009.employees_create_interim">
      <sqlFile dbms="oracle" endDelimiter=";"
               path="hr.00003.edition_v2_post_rollout/hr.000009.employees_create_interim.sql"
               relativeToChangelogFile="true" splitStatements="false" stripComments="false"/>
    </changeSet>
    <changeSet author="lcaldara" id="hr.000010.start_redef">
      <sqlFile dbms="oracle" endDelimiter=";"
               path="hr.00003.edition_v2_post_rollout/hr.000010.start_redef.sql"
               relativeToChangelogFile="true" splitStatements="false" stripComments="false"/>
    </changeSet>
    <changeSet author="lcaldara" id="hr.000011.copy_dependents">
      <sqlFile dbms="oracle" endDelimiter=";"
               path="hr.00003.edition_v2_post_rollout/hr.000011.copy_dependents.sql"
               relativeToChangelogFile="true" splitStatements="false" stripComments="false"/>
    </changeSet>
    <changeSet author="lcaldara" id="hr.000012.finish_redef_table">
      <sqlFile dbms="oracle" endDelimiter=";"
               path="hr.00003.edition_v2_post_rollout/hr.000012.finish_redef_table.sql"
               relativeToChangelogFile="true" splitStatements="false" stripComments="false"/>
    </changeSet>
    <changeSet author="lcaldara" id="hr.000013.drop_interim_table">
      <sqlFile dbms="oracle" endDelimiter=";"
               path="hr.00003.edition_v2_post_rollout/hr.000013.drop_interim_table.sql"
               relativeToChangelogFile="true" splitStatements="false" stripComments="false"/>
    </changeSet>
</databaseChangeLog>
```

Let's run it:
```
$ rlwrap sql /nolog

SQLcl: Release 21.4 Production on Mon Mar 14 15:18:04 2022

Copyright (c) 1982, 2022, Oracle.  All rights reserved.

SQL> set cloudconfig ../../adb_wallet.zip
SQL> connect hr/*****@demoadb_medium
Connected.
SQL> lb update -changelog hr.00003.edition_v2_post_rollout.xml

ScriptRunner Executing: ALTER SESSION SET EDITION=V2
Liquibase Executed:ALTER SESSION SET EDITION=V2
ScriptRunner Executing: begin
  admin.default_edition('V2');
end;
/
Liquibase Executed:begin
  admin.default_edition('V2');
end;
/
ScriptRunner Executing: declare
  l_parent_edition dba_editions.edition_name%type;
begin
  select  PARENT_EDITION_NAME into l_parent_edition
    from dba_editions where edition_name='V2';
  admin.drop_edition(l_parent_edition);
end;
/
Liquibase Executed:declare
  l_parent_edition dba_editions.edition_name%type;
begin
  select  PARENT_EDITION_NAME into l_parent_edition
    from dba_editions where edition_name='V2';
  admin.drop_edition(l_parent_edition);
end;
/
ScriptRunner Executing: alter trigger EMPLOYEES_REVXEDITION_TRG disable
Liquibase Executed:alter trigger EMPLOYEES_REVXEDITION_TRG disable
ScriptRunner Executing: drop trigger EMPLOYEES_REVXEDITION_TRG
Liquibase Executed:drop trigger EMPLOYEES_REVXEDITION_TRG
ScriptRunner Executing: alter trigger EMPLOYEES_FWDXEDITION_TRG disable
Liquibase Executed:alter trigger EMPLOYEES_FWDXEDITION_TRG disable
ScriptRunner Executing: drop trigger EMPLOYEES_FWDXEDITION_TRG
Liquibase Executed:drop trigger EMPLOYEES_FWDXEDITION_TRG
ScriptRunner Executing: create table employees$interim

[...]

ScriptRunner Executing: drop table employees$interim cascade constraints
Liquibase Executed:drop table employees$interim cascade constraints
######## ERROR SUMMARY ##################
Errors encountered:0

######## END ERROR SUMMARY ##################
SQL>
```


You have successfully executed the verified the editions in  the HR schema [proceed to the next lab](#next)

## Acknowledgements

- **Author** - Suraj Ramesh
- **Contributors** -
- **Last Updated By/Date** -01-Jul-2022
