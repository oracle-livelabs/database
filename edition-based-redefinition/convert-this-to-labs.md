# Human Resources example with Edition-Based Redefinition

## Requirements
* The Autonomous Database created with the Terraform Stack in ../../terraform
* The wallet of the Autonomous Database saved in this directory as `adb_wallet.zip`
* A recent version of `SQLcl` (possibly >= 21.4)


## Install the base HR schema
```
$ cd misc-labs/ebr-online/ebr-human-resources/initial_setup
$ rlwrap sql /nolog

SQLcl: Release 21.4 Production on Mon Mar 14 15:18:04 2022

Copyright (c) 1982, 2022, Oracle.  All rights reserved.

SQL> set cloudconfig ../adb_wallet.zip
SQL> connect admin/*****@demoadb_medium
Connected.
SQL> @hr_main

specify password for HR as parameter 1:
Enter value for 1: Welcome#Welcome#123

specify default tablespeace for HR as parameter 2:
Enter value for 2: SAMPLESCHEMAS

specify temporary tablespace for HR as parameter 3:
Enter value for 3: TEMP

specify log path as parameter 5:
Enter value for 5: ./

specify connect string as parameter 6:
Enter value for 6: demoadb_medium

User HR dropped.

User HR created.

User HR altered.

User HR altered.

Grant succeeded.

Grant succeeded.

Grant succeeded.

User HR altered.
Connected.

Session altered.

Session altered.
******  Creating REGIONS table ....

Table REGIONS$0 created.

View REGIONS created.

INDEX REG_ID_PK created.

Table REGIONS$0 altered.
******  Creating COUNTRIES table ....

Table COUNTRIES$0 created.

View COUNTRIES created.

Table COUNTRIES$0 altered.
******  Creating LOCATIONS table ....

Table LOCATIONS$0 created.

View LOCATIONS created.

INDEX LOC_ID_PK created.

Table LOCATIONS$0 altered.

Sequence LOCATIONS_SEQ created.
******  Creating DEPARTMENTS table ....

Table DEPARTMENTS$0 created.

View DEPARTMENTS created.

INDEX DEPT_ID_PK created.

Table DEPARTMENTS$0 altered.

Sequence DEPARTMENTS_SEQ created.
******  Creating JOBS table ....

Table JOBS$0 created.

View JOBS created.

INDEX JOB_ID_PK created.

Table JOBS$0 altered.
******  Creating EMPLOYEES table ....

Table EMPLOYEES$0 created.

View EMPLOYEES created.

INDEX EMP_EMP_ID_PK created.

Table EMPLOYEES$0 altered.

Table DEPARTMENTS$0 altered.

Sequence EMPLOYEES_SEQ created.
******  Creating JOB_HISTORY table ....

Table JOB_HISTORY$0 created.

View JOB_HISTORY created.

INDEX JHIST_EMP_ID_ST_DATE_PK created.

Table JOB_HISTORY$0 altered.
******  Creating EMP_DETAILS_VIEW view ...

View EMP_DETAILS_VIEW created.

Commit complete.

Session altered.
******  Populating REGIONS table ....

1 row inserted.

******  Populating COUNTIRES table ....

1 row inserted.
[...]
1 row inserted.

******  Populating LOCATIONS table ....

1 row inserted.
[...]
1 row inserted.

******  Populating DEPARTMENTS table ....

Table DEPARTMENTS$0 altered.

1 row inserted.
[...]
1 row inserted.

******  Populating JOBS table ....

1 row inserted.
[...]
1 row inserted.

******  Populating EMPLOYEES table ....

1 row inserted.
[...]
1 row inserted.

******  Populating JOB_HISTORY table ....

1 row inserted.
[...]
1 row inserted.

Table DEPARTMENTS$0 altered.

Commit complete.

Index EMP_DEPARTMENT_IX created.

Index EMP_JOB_IX created.

Index EMP_MANAGER_IX created.

Index EMP_NAME_IX created.

Index DEPT_LOCATION_IX created.

Index JHIST_JOB_IX created.

Index JHIST_EMPLOYEE_IX created.

Index JHIST_DEPARTMENT_IX created.

Index LOC_CITY_IX created.

Index LOC_STATE_PROVINCE_IX created.

Index LOC_COUNTRY_IX created.

Commit complete.

Procedure SECURE_DML compiled

Trigger SECURE_EMPLOYEES compiled

Trigger SECURE_EMPLOYEES altered.

Procedure ADD_JOB_HISTORY compiled

Trigger UPDATE_JOB_HISTORY compiled

Commit complete.

Comment created.
[...]
Commit complete.

PL/SQL procedure successfully completed.

SQL>
```

## Some helper procedures to deal with editions
In a production environment, the management of editions is usually a DBA task.

Some operations like `CREATE EDITION`, `DROP EDITION`, `ALTER DATABASE DEFAULT EDITION`, etc., require elevated privileges that should not be granted to normal users.
For CI/CD testing, and therefore for production environments that rolled out with CI/CD pipelines, these procedures using `AUTHID DEFINER` will facilitate the integration without executing anything as DBA.
Keep in mind, editions are shared among all schemas in the database, therefore all the schemas must belong to the same application and follow the same edition scheme. Different applications should be separated in different databases (or PDBs).

The file `hr_main.sql` creates these procedure to let users manage and use editions themselves.
```
REM ======================================================
REM procedure to create editions as ADMIN (with AUTHID definer) and grant to invoker
REM ======================================================
create or replace procedure create_edition (edition_name varchar2)
   authid definer
as
  e_edition_exists exception;
  e_grant_to_self exception;
  pragma exception_init (e_edition_exists, -955);
  pragma exception_init (e_grant_to_self, -1749);
begin
  begin
    execute immediate 'CREATE EDITION '||edition_name;
  exception
    when e_edition_exists then null;
  end;
  begin
    execute immediate 'GRANT USE ON EDITION '||edition_name||' TO '||USER;
  exception
    when e_grant_to_self then null;
  end;
end;
/

REM ======================================================
REM procedure to drop editions as ADMIN (with AUTHID definer)
REM ======================================================
create or replace procedure drop_edition (edition_name varchar2)
   authid definer
as
  e_inexistent_edition exception;
  e_grant_to_self exception;
  e_not_granted exception;
  pragma exception_init (e_inexistent_edition, -38801);
  pragma exception_init (e_grant_to_self, -1749);
  pragma exception_init (e_not_granted, -1927);
begin
  begin
    execute immediate 'REVOKE USE ON EDITION '||edition_name||' FROM '||USER;
  exception
    when e_grant_to_self then null;
    when e_not_granted then null;
  end;
  begin
    execute immediate 'DROP EDITION '||edition_name||' CASCADE';
  exception
     when e_inexistent_edition then null;
  end;
  dbms_editions_utilities.clean_unusable_editions;
end;
/

REM ======================================================
REM procedure to set the default edition as ADMIN (with AUTHID definer)
REM ======================================================
create or replace procedure default_edition (edition_name varchar2)
   authid definer
as
  e_inexistent_edition exception;
  pragma exception_init (e_inexistent_edition, -38801);
begin
  begin
    execute immediate 'alter database default edition ='||edition_name;
  exception
    when e_inexistent_edition then null;
  end;
end;
/
```
In a normal situation, either a DBA or a single administrative user would take care of the editions, but in a development database, developers may want to maintain the editions themselves. The `CREATE ANY EDITION` privilege is also handy, but not effective when the users that create them are recreated as part of integration tests: an edition is an object at database (PDB) level, but the grants work like for normal objects (grants are lost if the grantor is deleted).

The file `hr_main.sql` gives the extra grants to the `HR` user:
```
grant execute on create_edition to hr;
grant execute on drop_edition to hr;
grant execute on default_edition to hr;
ALTER USER hr ENABLE EDITIONS;
```

## Base Tables and Editioning Views
The set of scripts that install the `HR` schema is different from the default one.
Also give a look at the file `hr_cre.sql`. Each table has a different name compared to the original `HR` schema (a suffix `$0` in this example):
```
CREATE TABLE regions$0
    ( region_id      NUMBER
       CONSTRAINT  region_id_nn NOT NULL
    , region_name    VARCHAR2(25)
    );
```
Each table has a corresponding *editioning view* that covers the table 1 to 1:
```
CREATE EDITIONING VIEW regions as
    SELECT region_id, region_name FROM regions$0;
```

The views, and all the depending objects, are editioned and belong to the `ORA$BASE` edition.
```
SQL> select OBJECT_NAME, OBJECT_TYPE, EDITION_NAME from user_objects_ae WHERE edition_name is not null  order by 2,3;

          OBJECT_NAME    OBJECT_TYPE    EDITION_NAME
_____________________ ______________ _______________
ADD_JOB_HISTORY       PROCEDURE      ORA$BASE
SECURE_DML            PROCEDURE      ORA$BASE
SECURE_EMPLOYEES      TRIGGER        ORA$BASE
UPDATE_JOB_HISTORY    TRIGGER        ORA$BASE
JOBS                  VIEW           ORA$BASE
JOB_HISTORY           VIEW           ORA$BASE
EMP_DETAILS_VIEW      VIEW           ORA$BASE
DEPARTMENTS           VIEW           ORA$BASE
LOCATIONS             VIEW           ORA$BASE
COUNTRIES             VIEW           ORA$BASE
REGIONS               VIEW           ORA$BASE
EMPLOYEES             VIEW           ORA$BASE

12 rows selected.
```

## Generate the base changelog for liquibase
The command `lb genschema` creates the base Liquibase changelog. Run it from `../changes/hr.00000.base` directory:
```
SQL> show user
USER is "HR"
SQL> cd ../changes/hr.00000.base
SQL> lb genschema


Export Flags Used:

Export Grants           false
Export Synonyms         false
[Method loadCaptureTable]:
                 Executing
[Type - TYPE_SPEC]:                          379 ms
[Type - TYPE_BODY]:                          179 ms
[Type - SEQUENCE]:                           136 ms
[Type - DIRECTORY]:                           55 ms
[Type - CLUSTER]:                           1050 ms
[Type - TABLE]:                            11620 ms
[Type - MATERIALIZED_VIEW_LOG]:               63 ms
[Type - MATERIALIZED_VIEW]:                   52 ms
[Type - VIEW]:                              2366 ms
[Type - REF_CONSTRAINT]:                     348 ms
[Type - DIMENSION]:                           52 ms
[Type - FUNCTION]:                            91 ms
[Type - PROCEDURE]:                          117 ms
[Type - PACKAGE_SPEC]:                        87 ms
[Type - DB_LINK]:                             52 ms
[Type - SYNONYM]:                             73 ms
[Type - INDEX]:                             1153 ms
[Type - TRIGGER]:                            158 ms
[Type - PACKAGE_BODY]:                       114 ms
[Type - JOB]:                                 63 ms
                 End
[Method loadCaptureTable]:                 18208 ms
[Method processCaptureTable]:              13787 ms
[Method sortCaptureTable]:                    54 ms
[Method cleanupCaptureTable]:                 24 ms
[Method writeChangeLogs]:                   6928 ms
```

This initial changelog is useful if you plan to recreate the schema from scratch by using `Liquibase` instead of the base scripts.
Notice that the `HR` schema creation is not included in the changelog.

The Liquibase changelog is created as a set of xml files:
```
SQL> exit
$ cd ../changes/hr.00000.base
$ ls -l
total 114
-rw-r--r--    1 LCALDARA UsersGrp      1214 Mar 14 15:50 add_job_history_procedure.xml
-rw-r--r--    1 LCALDARA UsersGrp      2717 Mar 14 15:50 controller.xml
-rw-r--r--    1 LCALDARA UsersGrp       823 Mar 14 15:50 countr_reg_fk_ref_constraint.xml
-rw-r--r--    1 LCALDARA UsersGrp      1080 Mar 14 15:50 countries$0_comments.xml
-rw-r--r--    1 LCALDARA UsersGrp      3884 Mar 14 15:50 countries$0_table.xml
-rw-r--r--    1 LCALDARA UsersGrp      1208 Mar 14 15:50 countries_view.xml
-rw-r--r--    1 LCALDARA UsersGrp      1588 Mar 14 15:50 departments$0_comments.xml
-rw-r--r--    1 LCALDARA UsersGrp      4134 Mar 14 15:50 departments$0_table.xml
-rw-r--r--    1 LCALDARA UsersGrp       950 Mar 14 15:50 departments_seq_sequence.xml
-rw-r--r--    1 LCALDARA UsersGrp      1320 Mar 14 15:50 departments_view.xml
-rw-r--r--    1 LCALDARA UsersGrp       827 Mar 14 15:50 dept_loc_fk_ref_constraint.xml
-rw-r--r--    1 LCALDARA UsersGrp      1731 Mar 14 15:50 dept_location_ix_index.xml
-rw-r--r--    1 LCALDARA UsersGrp       826 Mar 14 15:50 dept_mgr_fk_ref_constraint.xml
-rw-r--r--    1 LCALDARA UsersGrp      1733 Mar 14 15:50 emp_department_ix_index.xml
-rw-r--r--    1 LCALDARA UsersGrp       831 Mar 14 15:50 emp_dept_fk_ref_constraint.xml
-rw-r--r--    1 LCALDARA UsersGrp      2749 Mar 14 15:50 emp_details_view_view.xml
-rw-r--r--    1 LCALDARA UsersGrp      1736 Mar 14 15:50 emp_email_uk_index.xml
-rw-r--r--    1 LCALDARA UsersGrp       808 Mar 14 15:50 emp_job_fk_ref_constraint.xml
-rw-r--r--    1 LCALDARA UsersGrp      1712 Mar 14 15:50 emp_job_ix_index.xml
-rw-r--r--    1 LCALDARA UsersGrp       830 Mar 14 15:50 emp_manager_fk_ref_constraint.xml
-rw-r--r--    1 LCALDARA UsersGrp      1724 Mar 14 15:50 emp_manager_ix_index.xml
-rw-r--r--    1 LCALDARA UsersGrp      1804 Mar 14 15:50 emp_name_ix_index.xml
-rw-r--r--    1 LCALDARA UsersGrp      2296 Mar 14 15:50 employees$0_comments.xml
-rw-r--r--    1 LCALDARA UsersGrp      7249 Mar 14 15:50 employees$0_table.xml
-rw-r--r--    1 LCALDARA UsersGrp       969 Mar 14 15:50 employees_seq_sequence.xml
-rw-r--r--    1 LCALDARA UsersGrp      1916 Mar 14 15:50 employees_view.xml
-rw-r--r--    1 LCALDARA UsersGrp      1739 Mar 14 15:50 jhist_department_ix_index.xml
-rw-r--r--    1 LCALDARA UsersGrp       837 Mar 14 15:50 jhist_dept_fk_ref_constraint.xml
-rw-r--r--    1 LCALDARA UsersGrp       829 Mar 14 15:50 jhist_emp_fk_ref_constraint.xml
-rw-r--r--    1 LCALDARA UsersGrp      1733 Mar 14 15:50 jhist_employee_ix_index.xml
-rw-r--r--    1 LCALDARA UsersGrp       814 Mar 14 15:50 jhist_job_fk_ref_constraint.xml
-rw-r--r--    1 LCALDARA UsersGrp      1718 Mar 14 15:50 jhist_job_ix_index.xml
-rw-r--r--    1 LCALDARA UsersGrp      2058 Mar 14 15:50 job_history$0_comments.xml
-rw-r--r--    1 LCALDARA UsersGrp      4817 Mar 14 15:50 job_history$0_table.xml
-rw-r--r--    1 LCALDARA UsersGrp      1388 Mar 14 15:50 job_history_view.xml
-rw-r--r--    1 LCALDARA UsersGrp      1171 Mar 14 15:50 jobs$0_comments.xml
-rw-r--r--    1 LCALDARA UsersGrp      4122 Mar 14 15:50 jobs$0_table.xml
-rw-r--r--    1 LCALDARA UsersGrp      1271 Mar 14 15:50 jobs_view.xml
-rw-r--r--    1 LCALDARA UsersGrp       823 Mar 14 15:50 loc_c_id_fk_ref_constraint.xml
-rw-r--r--    1 LCALDARA UsersGrp      1712 Mar 14 15:50 loc_city_ix_index.xml
-rw-r--r--    1 LCALDARA UsersGrp      1724 Mar 14 15:50 loc_country_ix_index.xml
-rw-r--r--    1 LCALDARA UsersGrp      1742 Mar 14 15:50 loc_state_province_ix_index.xml
-rw-r--r--    1 LCALDARA UsersGrp      1861 Mar 14 15:50 locations$0_comments.xml
-rw-r--r--    1 LCALDARA UsersGrp      4598 Mar 14 15:50 locations$0_table.xml
-rw-r--r--    1 LCALDARA UsersGrp       948 Mar 14 15:50 locations_seq_sequence.xml
-rw-r--r--    1 LCALDARA UsersGrp      1484 Mar 14 15:50 locations_view.xml
-rw-r--r--    1 LCALDARA UsersGrp      1028 Mar 14 15:50 regions$0_comments.xml
-rw-r--r--    1 LCALDARA UsersGrp      3660 Mar 14 15:50 regions$0_table.xml
-rw-r--r--    1 LCALDARA UsersGrp      1110 Mar 14 15:50 regions_view.xml
-rw-r--r--    1 LCALDARA UsersGrp       980 Mar 14 15:50 secure_dml_procedure.xml
-rw-r--r--    1 LCALDARA UsersGrp       870 Mar 14 15:50 secure_employees_trigger.xml
-rw-r--r--    1 LCALDARA UsersGrp       977 Mar 14 15:50 update_job_history_trigger.xml
```

The `controller.xml` is the changelog file that contains the changesets. You can see that the changesets are called from the current path:
```
<?xml version="1.0" encoding="UTF-8"?>
<databaseChangeLog
  xmlns="http://www.liquibase.org/xml/ns/dbchangelog"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.liquibase.org/xml/ns/dbchangelog
                      http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-3.9.xsd">
  <include file="employees_seq_sequence.xml" relativeToChangelogFile="true" />
  <include file="locations_seq_sequence.xml" relativeToChangelogFile="true" />
  <include file="departments_seq_sequence.xml" relativeToChangelogFile="true" />
  [...]
  <include file="update_job_history_trigger.xml" relativeToChangelogFile="true" />
  <include file="secure_employees_trigger.xml" relativeToChangelogFile="true" />
</databaseChangeLog>
```

## Create your own directory structure
For the base and subsequent changelogs, you might want to use a neater directory organization, for example:
```
main.xml
sub_changelog_1.xml
    -> sub_changelog_1/changesets*
  -> sub_changelog_2.xml
    -> sub_changelog_2/changesets*
```
Having each changelog contained in a separate directory facilitates the development when schemas start getting bigger and the number of changesets important.

For this reason, you can convert the file `hr.00000.base/controller.xml` to `hr.00000.base.xml`. This part is subjective. Different development teams may prefer different directory layouts.

The conversion can be achieved with:
```
sed -e "s/file=\"/file=\"hr.00000.base\//" hr.00000.base/controller.xml > hr.00000.base.xml
```
so that the `<include>` in the new file look like (notice the new path):
```
<?xml version="1.0" encoding="UTF-8"?>
<databaseChangeLog
  xmlns="http://www.liquibase.org/xml/ns/dbchangelog"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.liquibase.org/xml/ns/dbchangelog
                      http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-3.9.xsd">
  <include file="hr.00000.base/employees_seq_sequence.xml" relativeToChangelogFile="true" />
  <include file="hr.00000.base/locations_seq_sequence.xml" relativeToChangelogFile="true" />
  <include file="hr.00000.base/departments_seq_sequence.xml" relativeToChangelogFile="true" />
  <include file="hr.00000.base/departments$0_table.xml" relativeToChangelogFile="true" />
  [...]
  <include file="hr.00000.base/update_job_history_trigger.xml" relativeToChangelogFile="true" />
  <include file="hr.00000.base/secure_employees_trigger.xml" relativeToChangelogFile="true" />
</databaseChangeLog>
```

The file `main.xml` includes all the changelogs, so in a single update, ALL the modifications from the initial version to the last changelog will be checked and eventually applied.
```
<?xml version="1.0" encoding="UTF-8"?>
<databaseChangeLog
  xmlns="http://www.liquibase.org/xml/ns/dbchangelog"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.liquibase.org/xml/ns/dbchangelog
                      http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-3.1.xsd">

  <include file="./hr.00000.base.xml" relativeToChangelogFile="true"/>
  <!-- PLACEHOLDER <include file="./hr.00001.edition_v1.xml" relativeToChangelogFile="true"/>  -->
  <!-- PLACEHOLDER <include file="./hr.00002.edition_v2.xml" relativeToChangelogFile="true"/>  -->

</databaseChangeLog>
```

In the example, there are already two placeholders for the next schema/code releases.

At this point we can run `lb update` to synchronize the definition with the `Liquibase` metadata (optional):
```
SQL> cd ..
SQL> lb status -changelog main.xml

51 change sets have not been applied to HR@jdbc:oracle:thin:@(description=(retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1522)(host=adb.eu-zurich-1.oraclecloud.com))(connect_data=(service_name=ht8k3jwmatw52we_demoadb_medium.adb.oraclecloud.com))(security=(ssl_server_cert_dn="CN=adb.eu-zurich-1.oraclecloud.com, OU=Oracle ADB ZURICH, O=Oracle Corporation, L=Redwood City, ST=California, C=US")))
     hr.00000.base/employees_seq_sequence.xml::42e3db1348e500dade36829bab3b7f5343ad6f09::(HR)-Generated
     hr.00000.base/locations_seq_sequence.xml::7ec49fad51eb8c0b53fa0128bf6ef2d3fee25d35::(HR)-Generated
     hr.00000.base/departments_seq_sequence.xml::93020a4f5c3fc570029b0695d52763142b6e44e1::(HR)-Generated
     hr.00000.base/departments$0_table.xml::8fccd55150e9ae05304edde806cb429fdc3b875f::(HR)-Generated
[...]

SQL> lb update -changelog main.xml

ScriptRunner Executing: hr.00000.base/employees_seq_sequence.xml::42e3db1348e500dade36829bab3b7f5343ad6f09::(HR)-Generated
 -- DONE
ScriptRunner Executing: hr.00000.base/locations_seq_sequence.xml::7ec49fad51eb8c0b53fa0128bf6ef2d3fee25d35::(HR)-Generated
 -- DONE
ScriptRunner Executing: hr.00000.base/departments_seq_sequence.xml::93020a4f5c3fc570029b0695d52763142b6e44e1::(HR)-Generated
 -- DONE
ScriptRunner Executing: hr.00000.base/departments$0_table.xml::8fccd55150e9ae05304edde806cb429fdc3b875f::(HR)-Generated
[...]
```

The next `lb status` shows everything up to date. A subsequent `lb update` will not change anything.
```
SQL> lb status -changelog main.xml

HR@jdbc:oracle:thin:@(description=(retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1522)(host=adb.eu-zurich-1.oraclecloud.com))(connect_data=(service_name=ht8k3jwmatw52we_demoadb_medium.adb.oraclecloud.com))(security=(ssl_server_cert_dn="CN=adb.eu-zurich-1.oraclecloud.com, OU=Oracle ADB ZURICH, O=Oracle Corporation, L=Redwood City, ST=California, C=US"))) is up to date

SQL> lb update -changelog main.xml

######## ERROR SUMMARY ##################
Errors encountered:0

######## END ERROR SUMMARY ##################
```


## Prepare the scripts to create a new edition and split `employees.phone_number` to `country_code` and `phone#`
As an example of schema change, let's split a column to two columns.

To achieve this goal, there are a few steps to do. To let `Liquibase` retry them (idempotency), we need separated files:
```
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
```
### 1. Create the new edition

For this, we will use the helper function created earlier:
```
begin
    admin.create_edition('V2');
end;
/
```
This runs the `CREATE EDITION V2` and `GRANT USE ON EDITION V2 to HR`.

Remember, for real-world scenarios, it would be best to have separate PDBs per deveoloper so that there are no conflicts in the management of editions.

### 2. Use the new edition
The second one is also important, as it sets the edition for the subsequent changesets:
```
ALTER SESSION SET EDITION=V2;
```

The second changesets must always run in the changelog to ensure that the correct edition is set (in case after an error liquibase disconnects and reconnects again to the previous edition), so we will call it with the parameter `runAlways=true`:

```
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
```
The other changesets have a different `splitStatements` parameter depending on their nature (SQL or PL/SQL).

### 3. Add the new columns
This operation is online for subsequent DMLs but must wait on the existing ones. We specify a DDL timeout:
```
alter session set DDL_LOCK_TIMEOUT=30;

alter table employees$0 add (
    country_code varchar2(3),
    phone# varchar2(20)
);
```

### 4. Create the forward cross-edition trigger
Two triggers make sure that changes done in the old and new editions populate the columns correctly.

The `forward crossedition` trigger propagates the changes from the old edition to the new columns.
There will be a reverse one that will do the same for DMLs on the new edition.

```
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
alter trigger employees_fwdxedition_trg enable;
```

### 5. Populate the new columns
Before populating the new columns, we wait for the current DMLs to finish:
```
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
```

The population happens by applying the trigger on the rows of the table, using a special `dbms_sql.parse` call:
```
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
```

### 6. Create the reverse trigger
Before using the new edition, we create the reverse trigger so that new DMLs on the new columns will update the old column for the applications still running in the old edition:

```
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

alter trigger employees_revxedition_trg enable;
```

### 7. Create the new version of the editioning view
The editioning view is "the surrogate" of the base table. In the new edition, we want to have `country_code` and `phone#` columns, and we omit `phone_number`. Note that we can also choose the order of the column in the definition.
```
CREATE OR REPLACE EDITIONING VIEW employees AS
    SELECT employee_id, first_name, last_name, email, country_code, phone#, hire_date, job_id, salary, commission_pct, manager_id, department_id FROM employees$0;
```

### 8. Actualize the objects
Now that the modifications to the existing objects have been made, we can "transfer" all the inherited objects from the previous version to the new one, and at the same time validate/recompile them (nobody is using them yet).
```
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
```

## Run `lb update` for the new changelog
Be sure to cd to the right directory:
```
SQL> exit
$ cd ../changes
$ rlwrap sql /nolog

SQLcl: Release 21.4 Production on Thu Mar 17 18:54:13 2022

Copyright (c) 1982, 2022, Oracle.  All rights reserved.

SQL> set cloudconfig ../../adb_wallet.zip
SQL> connect hr/Welcome#Welcome#123@demoadb_medium
Connected.
SQL> lb update -changelog hr.00002.edition_v2.xml

ScriptRunner Executing: begin
    admin.create_edition('V2');
end;
/
Liquibase Executed:begin
    admin.create_edition('V2');
end;
/
ScriptRunner Executing: ALTER SESSION SET EDITION=V2
Liquibase Executed:ALTER SESSION SET EDITION=V2
ScriptRunner Executing: alter session set DDL_LOCK_TIMEOUT=30
Liquibase Executed:alter session set DDL_LOCK_TIMEOUT=30
ScriptRunner Executing: alter table employees$0 add (
    country_code varchar2(3),
    phone# varchar2(20)
)
Liquibase Executed:alter table employees$0 add (
    country_code varchar2(3),
    phone# varchar2(20)
)
[...]
Liquibase Executed:declare
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
######## ERROR SUMMARY ##################
Errors encountered:0

######## END ERROR SUMMARY ##################
```

## Enjoy the two editions
At this point we have one edition using the old column:
```
SQL> alter session set edition=v0;

Session altered.

SQL> select * from employees where rownum<5;

   EMPLOYEE_ID    FIRST_NAME    LAST_NAME       EMAIL          PHONE_NUMBER    HIRE_DATE    JOB_ID    SALARY    COMMISSION_PCT    MANAGER_ID    DEPARTMENT_ID
______________ _____________ ____________ ___________ _____________________ ____________ _________ _________ _________________ _____________ ________________
           151 David         Bernstein    DBERNSTE    011.44.1344.345268    24-MAR-05    SA_REP         9500              0.25           145               80
           156 Janette       King         JKING       011.44.1345.429268    30-JAN-04    SA_REP        10000              0.35           146               80
           161 Sarath        Sewall       SSEWALL     011.44.1345.529268    03-NOV-06    SA_REP         7000              0.25           146               80
           166 Sundar        Ande         SANDE       011.44.1346.629268    24-MAR-08    SA_REP         6400               0.1           147               80
```
and the new one with the other two columns:
```
SQL> alter session set edition=v2;

Session altered.

SQL> select * from employees where rownum<5;

   EMPLOYEE_ID    FIRST_NAME    LAST_NAME       EMAIL    COUNTRY_CODE         PHONE#    HIRE_DATE    JOB_ID    SALARY    COMMISSION_PCT    MANAGER_ID    DEPARTMENT_ID
______________ _____________ ____________ ___________ _______________ ______________ ____________ _________ _________ _________________ _____________ ________________
           151 David         Bernstein    DBERNSTE    +44             1344.345268    24-MAR-05    SA_REP         9500              0.25           145               80
           156 Janette       King         JKING       +44             1345.429268    30-JAN-04    SA_REP        10000              0.35           146               80
           161 Sarath        Sewall       SSEWALL     +44             1345.529268    03-NOV-06    SA_REP         7000              0.25           146               80
           166 Sundar        Ande         SANDE       +44             1346.629268    24-MAR-08    SA_REP         6400               0.1           147               80
```

The base table itself contains all of them, but should not be used directly.
```
SQL> select * from employees$0 where rownum<5;

   EMPLOYEE_ID    FIRST_NAME    LAST_NAME       EMAIL          PHONE_NUMBER    HIRE_DATE    JOB_ID    SALARY    COMMISSION_PCT    MANAGER_ID    DEPARTMENT_ID    COUNTRY_CODE         PHONE#
______________ _____________ ____________ ___________ _____________________ ____________ _________ _________ _________________ _____________ ________________ _______________ ______________
           151 David         Bernstein    DBERNSTE    011.44.1344.345268    24-MAR-05    SA_REP         9500              0.25           145               80 +44             1344.345268
           156 Janette       King         JKING       011.44.1345.429268    30-JAN-04    SA_REP        10000              0.35           146               80 +44             1345.429268
           161 Sarath        Sewall       SSEWALL     011.44.1345.529268    03-NOV-06    SA_REP         7000              0.25           146               80 +44             1345.529268
           166 Sundar        Ande         SANDE       011.44.1346.629268    24-MAR-08    SA_REP         6400               0.1           147               80 +44             1346.629268
```

We can check the objects for all the editions. We see a copy for each one because we forced their actualization. Without that step, in V2 we would see only the objects that have been changed, and the others would have been inherited from V0.
```
SQL> select OBJECT_NAME, OBJECT_TYPE, STATUS, EDITION_NAME from user_objects_ae WHERE edition_name is not null  order by 2,1,4;

                     OBJECT_NAME    OBJECT_TYPE    STATUS    EDITION_NAME
________________________________ ______________ _________ _______________
ADD_JOB_HISTORY                  PROCEDURE      VALID     V0
ADD_JOB_HISTORY                  PROCEDURE      VALID     V2
SECURE_DML                       PROCEDURE      VALID     V0
SECURE_DML                       PROCEDURE      VALID     V2
DATABASECHANGELOG_ACTIONS_TRG    TRIGGER        VALID     V0
DATABASECHANGELOG_ACTIONS_TRG    TRIGGER        VALID     V2
EMPLOYEES_FWDXEDITION_TRG        TRIGGER        VALID     V2
EMPLOYEES_REVXEDITION_TRG        TRIGGER        VALID     V2
SECURE_EMPLOYEES                 TRIGGER        VALID     V0
SECURE_EMPLOYEES                 TRIGGER        VALID     V2
UPDATE_JOB_HISTORY               TRIGGER        VALID     V0
UPDATE_JOB_HISTORY               TRIGGER        VALID     V2
COUNTRIES                        VIEW           VALID     V0
COUNTRIES                        VIEW           VALID     V2
DEPARTMENTS                      VIEW           VALID     V0
DEPARTMENTS                      VIEW           VALID     V2
EMPLOYEES                        VIEW           VALID     V0
EMPLOYEES                        VIEW           VALID     V2
EMP_DETAILS_VIEW                 VIEW           VALID     V0
EMP_DETAILS_VIEW                 VIEW           VALID     V2
JOBS                             VIEW           VALID     V0
JOBS                             VIEW           VALID     V2
JOB_HISTORY                      VIEW           VALID     V0
JOB_HISTORY                      VIEW           VALID     V2
LOCATIONS                        VIEW           VALID     V0
LOCATIONS                        VIEW           VALID     V2
REGIONS                          VIEW           VALID     V0
REGIONS                          VIEW           VALID     V2

28 rows selected.
```


## Switch to the new edition
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

## Decommission the old edition and redefine the table (optional)
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
