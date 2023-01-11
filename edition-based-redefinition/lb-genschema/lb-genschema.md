# Generate the base changelog for liquibase

Estimated lab time: 10 minutes

### Objectives

In this lab, you will learn how to use Liquibase  to generate the base changelog of HR Schema.

## Task1: Run lb generate-schema to generate the base changelog

The command `lb generate-schema` creates the base Liquibase changelog. Make to sure to run it from ***changes/hr.00000.base*** directory:

```text
SQL> show user
USER is "HR"
SQL> cd ../changes/hr.00000.base
SQL> lb generate-schema


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

