# Review the HR schema

## Introduction

Estimated lab time: 10 minutes

### Objectives
In this lab, you will learn how to recognize the edition of an object and review the helper procedures that we have created in the previous lab.

### Prerequisites
- You have completed the previous lab:
   - Lab: Setup the HR schema


## Task 1: Review the helper procedures created to deal with the editions

In a production environment, the management of editions is usually a DBA task.

Some operations like `CREATE EDITION`, `DROP EDITION`, `ALTER DATABASE DEFAULT EDITION`, etc., require elevated privileges that should not be granted to normal users.
For CI/CD testing, and therefore for production environments that rolled out with CI/CD pipelines, these procedures using `AUTHID DEFINER` will facilitate the integration without executing anything as DBA.
Keep in mind, editions are shared among all schemas in the database, therefore all the schemas must belong to the same application and follow the same edition scheme. Different applications should be separated in different databases (or PDBs).

The file `hr_main.sql` that we used to create the HR schema in the previous lab, creates the following procedures to let users manage and use editions themselves:

```text
REM ======================================================
REM procedure to create an edition as DBA (with AUTHID definer) and grant its usage to the invoker
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
REM procedure to drop an edition as DBA (with AUTHID definer)
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
REM procedure to set the default edition as DBA (with AUTHID definer)
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

```text
grant execute on create_edition to hr;
grant execute on drop_edition to hr;
grant execute on default_edition to hr;
ALTER USER hr ENABLE EDITIONS;
```


## Task 2: Review Base Tables and Editioning Views

The set of scripts that install the `HR` schema is different from the default one.

Also give a look at the file `hr_cre.sql`.This script is available in initial_setup folder.Each table has a different name compared to the original `HR` schema (a suffix `$0` in this example):

```text
CREATE TABLE regions$0
    ( region_id      NUMBER
       CONSTRAINT  region_id_nn NOT NULL
    , region_name    VARCHAR2(25)
    );
```

Each table has a corresponding *editioning view* that covers the table one to one:

```text
CREATE EDITIONING VIEW regions as
    SELECT region_id, region_name FROM regions$0;
```

To verify this, connect with the `HR` user in SQLcl ( If you got disconnected from sqlcl, refer Lab2,Task 1 for setting up the DB wallet)

```text
 <copy>connect hr/Welcome#Welcome#123@ebronline_medium</copy>
```

Then use the SQLcl command `ddl` on `regions` and you should able to see DDL of the regions view as below

```text
SQL> ddl regions

  CREATE OR REPLACE FORCE EDITIONABLE EDITIONING VIEW "HR"."REGIONS" ("REGION_ID", "REGION_NAME") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT region_id, region_name FROM regions$0;
```

The views, and all the depending objects, are editioned and belong to the `ORA$BASE` edition. This is the default edition when a database is created. Let us verify using the below SQL in the HR schema.

```text
 <copy>select OBJECT_NAME, OBJECT_TYPE, EDITION_NAME from user_objects_ae WHERE edition_name is not null  order by 2,3;</copy>
 ```

```text
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

You have successfully reviewed the HR schema [proceed to the next lab](#next) to start working with Liquibase and SQLcl.

## Acknowledgements

- Author - Ludovico Caldara and Suraj Ramesh 
- Last Updated By/Date -Suraj Ramesh, Jan 2023
