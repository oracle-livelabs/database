# Verify Editions

At this point we have one edition using the old column (PHONE_NUMBER))

SQL> alter session set edition=ORA$BASE;

Session altered.

SQL> select * from employees where rownum<5;

   EMPLOYEE_ID    FIRST_NAME    LAST_NAME       EMAIL          PHONE_NUMBER    HIRE_DATE    JOB_ID    SALARY    COMMISSION_PCT    MANAGER_ID    DEPARTMENT_ID
______________ _____________ ____________ ___________ _____________________ ____________ _________ _________ _________________ _____________ ________________
           151 David         Bernstein    DBERNSTE    011.44.1344.345268    24-MAR-05    SA_REP         9500              0.25           145               80
           156 Janette       King         JKING       011.44.1345.429268    30-JAN-04    SA_REP        10000              0.35           146               80
           161 Sarath        Sewall       SSEWALL     011.44.1345.529268    03-NOV-06    SA_REP         7000              0.25           146               80
           166 Sundar        Ande         SANDE       011.44.1346.629268    24-MAR-08    SA_REP         6400               0.1           147               80

and the new one with the other two columns (COUNTRY_CODE and PHONE#)

SQL> alter session set edition=v2;

Session altered.

SQL> select * from employees where rownum<5;

   EMPLOYEE_ID    FIRST_NAME    LAST_NAME       EMAIL    COUNTRY_CODE         PHONE#    HIRE_DATE    JOB_ID    SALARY    COMMISSION_PCT    MANAGER_ID    DEPARTMENT_ID
______________ _____________ ____________ ___________ _______________ ______________ ____________ _________ _________ _________________ _____________ ________________
           151 David         Bernstein    DBERNSTE    +44             1344.345268    24-MAR-05    SA_REP         9500              0.25           145               80
           156 Janette       King         JKING       +44             1345.429268    30-JAN-04    SA_REP        10000              0.35           146               80
           161 Sarath        Sewall       SSEWALL     +44             1345.529268    03-NOV-06    SA_REP         7000              0.25           146               80
           166 Sundar        Ande         SANDE       +44             1346.629268    24-MAR-08    SA_REP         6400               0.1           147               80

The base table itself contains all of them, but should not be used directly.

SQL> select * from employees$0 where rownum<5;

   EMPLOYEE_ID    FIRST_NAME    LAST_NAME       EMAIL          PHONE_NUMBER    HIRE_DATE    JOB_ID    SALARY    COMMISSION_PCT    MANAGER_ID    DEPARTMENT_ID    COUNTRY_CODE         PHONE#
______________ _____________ ____________ ___________ _____________________ ____________ _________ _________ _________________ _____________ ________________ _______________ ______________
           151 David         Bernstein    DBERNSTE    011.44.1344.345268    24-MAR-05    SA_REP         9500              0.25           145               80 +44             1344.345268
           156 Janette       King         JKING       011.44.1345.429268    30-JAN-04    SA_REP        10000              0.35           146               80 +44             1345.429268
           161 Sarath        Sewall       SSEWALL     011.44.1345.529268    03-NOV-06    SA_REP         7000              0.25           146               80 +44             1345.529268
           166 Sundar        Ande         SANDE       011.44.1346.629268    24-MAR-08    SA_REP         6400               0.1           147               80 +44             1346.629268

We can check the objects for all the editions. We see a copy for each one because we forced their actualization. Without that step, in V2 we would see only the objects that have been changed, and the others would have been inherited from ORA$BASE.

SQL> select OBJECT_NAME, OBJECT_TYPE, STATUS, EDITION_NAME from user_objects_ae WHERE edition_name is not null  order by 2,1,4;

                     OBJECT_NAME    OBJECT_TYPE    STATUS    EDITION_NAME 
________________________________ ______________ _________ _______________
ADD_JOB_HISTORY                  PROCEDURE      VALID     ORA$BASE
ADD_JOB_HISTORY                  PROCEDURE      VALID     V2
SECURE_DML                       PROCEDURE      VALID     ORA$BASE
SECURE_DML                       PROCEDURE      VALID     V2
DATABASECHANGELOG_ACTIONS_TRG    TRIGGER        VALID     ORA$BASE
DATABASECHANGELOG_ACTIONS_TRG    TRIGGER        VALID     V2
EMPLOYEES_FWDXEDITION_TRG        TRIGGER        VALID     V2
EMPLOYEES_REVXEDITION_TRG        TRIGGER        VALID     V2
SECURE_EMPLOYEES                 TRIGGER        VALID     ORA$BASE
SECURE_EMPLOYEES                 TRIGGER        VALID     V2
UPDATE_JOB_HISTORY               TRIGGER        VALID     ORA$BASE
UPDATE_JOB_HISTORY               TRIGGER        VALID     V2
COUNTRIES                        VIEW           VALID     ORA$BASE
COUNTRIES                        VIEW           VALID     V2
DEPARTMENTS                      VIEW           VALID     ORA$BASE
DEPARTMENTS                      VIEW           VALID     V2
EMPLOYEES                        VIEW           VALID     ORA$BASE
EMPLOYEES                        VIEW           VALID     V2
EMP_DETAILS_VIEW                 VIEW           VALID     ORA$BASE
EMP_DETAILS_VIEW                 VIEW           VALID     V2
JOBS                             VIEW           VALID     ORA$BASE
JOBS                             VIEW           VALID     V2
JOB_HISTORY                      VIEW           VALID     ORA$BASE
JOB_HISTORY                      VIEW           VALID     V2
LOCATIONS                        VIEW           VALID     ORA$BASE
LOCATIONS                        VIEW           VALID     V2
REGIONS                          VIEW           VALID     ORA$BASE
REGIONS                          VIEW           VALID     V2

28 rows selected.

You have successfully executed the verified the editions in  the HR schema [proceed to the next lab](#next)

## Acknowledgements

- **Author** - Suraj Ramesh
- **Contributors** -
- **Last Updated By/Date** -01-Jul-2022
