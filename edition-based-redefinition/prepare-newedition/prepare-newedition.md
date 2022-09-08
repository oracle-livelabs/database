# Prepare the scripts to create a new edition and split employees.phone_number to country_code and phone#

As an example of schema change, let's split a column to two columns.

To achieve this goal, there are a few steps to do. To let Liquibase retry them (idempotency), we need separated files. These scripts are avaiable in ebr-online/ebr-human-resources/changes/hr.00002.edition_v2 folder. 

cd ebr-online/ebr-human-resources/changes/hr.00002.edition_v2
ls -ltr 

hr.000001.edition_v2.sql
hr.000002.alter_session.sql
hr.000003.employee_add_columns.sql
hr.000004.employee_forward_trigger.sql
hr.000005.employee_enable_forward_trigger.sql
hr.000006.employee_wait_on_pending_dml.sql
hr.000007.employee_transform_rows.sql
hr.000008.employee_reverse_trigger.sql
hr.000009.employee_enable_reverse_trigger.sql
hr.000010.view_employees.sql

Lets review all the scripts as below


1. Create the new edition

For this, we will use the helper function created earlier:

cat hr.000001.edition_v2.sql

begin
    admin.create_edition('V2');
end;
/

This runs the CREATE EDITION V2 and GRANT USE ON EDITION V2 to HR.

Remember, for real-world scenarios, it would be best to have separate PDBs per deveoloper so that there are no conflicts in the management of editions.

2. Use the new edition

The second one is also important, as it sets the edition for the subsequent changesets:

cat hr.000002.alter_session.sql

ALTER SESSION SET EDITION=V2;

The second changesets must always run in the changelog to ensure that the correct edition is set (in case after an error liquibase disconnects and reconnects again to the previous edition), so we will call it with the parameter runAlways=true: 

This can be verified by opening the file hr.00002.edition_v2.xml in ebr-online/ebr-human-resources/changes/ 

cd ebr-online/ebr-human-resources/changes/ 
cat hr.00002.edition_v2.xml 


<?xml version="1.0" encoding="UTF-8"?>
<databaseChangeLog
  xmlns="http://www.liquibase.org/xml/ns/dbchangelog"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.liquibase.org/xml/ns/dbchangelog
                      http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-3.1.xsd">
    [...]
    <changeSet author="lcaldara" id="hr.000002.alter_session" runAlways="true">
      <sqlFile dbms="oracle" endDelimiter=";"
               path="hr.00001.edition_v1/hr.000002.alter_session.sql"
               relativeToChangelogFile="true" splitStatements="true" stripComments="false"/>
    </changeSet>
    [...]
</databaseChangeLog>

The other changesets have a different splitStatements parameter depending on their nature (SQL or PL/SQL).

3. Add the new columns

This operation is online for subsequent DMLs but must wait on the existing ones. We specify a DDL timeout:

cd ebr-online/ebr-human-resources/changes/hr.00002.edition_v2

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

create or replace trigger employees_fwdxedition_trg
  before insert or update of phone_number on employees$0
  for each row
  forward crossedition
  disable
declare
    first_dot  number;
    second_dot number;
begin
    if :new.phone_number like '011.%'
   then
        first_dot
           := instr( :new.phone_number, '.' );
        second_dot
           := instr( :new.phone_number, '.', 1, 2 );
        :new.country_code
           := '+'||
              substr( :new.phone_number,
                        first_dot+1,
                      second_dot-first_dot-1 );
        :new.phone#
           := substr( :new.phone_number,
                        second_dot+1 );
    else
        :new.country_code := '+1';
        :new.phone# := :new.phone_number;
    end if;
end;
/

-----
Enable the trigger

cat hr.000005.employee_enable_forward_trigger.sql

alter trigger employees_fwdxedition_trg enable;

5. Populate the new columns

Before populating the new columns, we wait for the current DMLs to finish:

cat hr.000006.employee_wait_on_pending_dml.sql

DECLARE
  scn number := null;
  -- A null or negative value for Timeout will cause a very long wait.
  timeout constant integer := null;

BEGIN
  if not sys.dbms_utility.wait_on_pending_dml(
    tables => 'EMPLOYEES$0',
    timeout => timeout,
    scn => scn)
  then
    raise_application_error(-20000,
      'wait_on_pending_dml() timed out. '||
      'CET was enabled before SCN: '||SCN
    );
  end if;
end;
/

The population happens by applying the trigger on the rows of the table, using a special dbms_sql.parse call:

cat hr.000007.employee_transform_rows.sql
ls -ltr *8()
declare
  cur integer := sys.dbms_sql.open_cursor(security_level => 2);
  no_of_updated_rows integer not null := -1;
begin
  sys.dbms_sql.parse(
    c => cur,
    language_flag => sys.dbms_sql.native,
    statement => 'update employees$0 set phone_number = phone_number',
    apply_crossedition_trigger => 'employees_fwdxedition_trg',
    fire_apply_trigger => true
  );
  no_of_updated_rows := sys.dbms_sql.execute(cur);
  sys.dbms_sql.close_cursor(cur);
end;
/

6. Create the reverse trigger and enable trigger

Before using the new edition, we create the reverse trigger so that new DMLs on the new columns will update the old column for the applications still running in the old edition:

cat hr.000008.employee_reverse_trigger.sql

create or replace trigger employees_revxedition_trg
  before insert or update of country_code,phone# on employees$0
  for each row
  reverse crossedition
  disable
declare
    first_dot  number;
    second_dot number;
begin
        if :new.country_code = '+1'
        then
           :new.phone_number :=
              :new.phone#;
        else
           :new.phone_number :=
              '011.' ||
              substr( :new.country_code, 2 ) ||
              '.' || :new.phone#;
        end if;
end;
/

-----
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

cd ebr-online/ebr-human-resources/changes/common

cat  actualize_all.sql

declare
     type obj_t is record(
         object_name user_objects.object_name%type,
         namespace   user_objects.namespace%type);
     type obj_tt is table of obj_t;

     l_obj_list obj_tt;

     l_obj_count binary_integer := 0;

 begin
     dbms_editions_utilities2.actualize_all;
     loop
         select object_name,namespace
         bulk   collect
         into   l_obj_list
         from   user_objects
         where  edition_name != sys_context('userenv', 'session_edition_name')
         or     status = 'INVALID';

         exit when l_obj_list.count = l_obj_count;

         l_obj_count := l_obj_list.count;

         for i in 1 .. l_obj_count
         loop
             dbms_utility.validate(user, l_obj_list(i).object_name, l_obj_list(i).namespace);
         end loop;
     end loop;
 end;
 /


You have successfully reviewed the scripts as part of the schema change [proceed to the next lab](#next) 

## Acknowledgements

- **Author** - Suraj Ramesh
- **Contributors** -
- **Last Updated By/Date** -  