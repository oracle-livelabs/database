# Create your own directory structure for liquibase and sync metadata

## Task1: Modify the directory structure 

For the base and subsequent changelogs, you might want to use a neater directory organization, for example:

main.xml
sub_changelog_1.xml
    -> sub_changelog_1/changesets*
  -> sub_changelog_2.xml
    -> sub_changelog_2/changesets*

Having each changelog contained in a separate directory facilitates the development when schemas start getting bigger and the number of changesets important.

For this reason, you can convert the file hr.00000.base/controller.xml to hr.00000.base.xml. This part is subjective. Different development teams may prefer different directory layouts.

The conversion can be achieved with the below steps:

cd ../changes/

sed -e "s/file=\"/file=\"hr.00000.base\//" hr.00000.base/controller.xml > hr.00000.base.xml

so that the <include> in the new file look like (notice the new path), this can be verified using

cat hr.00000.base.xml  

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

The file main.xml includes all the changelogs, so in a single update, ALL the modifications from the initial version to the last changelog will be checked and eventually applied.This can be verified using

cat main.xml

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

## Task2: Syncronize the metadata 

In the example, there are already two placeholders for the next schema/code releases.

At this point we can run lb update to synchronize the definition with the Liquibase metadata (optional):

SQL> cd ..
SQL> lb status -changelog main.xml

51 change sets have not been applied to HR@jdbc:oracle:thin:@(description=(retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1522)(host=adb.eu-zurich-1.oraclecloud.com))(connect_data=(service_name=ht8k3jwmatw52we_demoadb_medium.adb.oraclecloud.com))(security=(ssl_server_cert_dn="CN=adb.eu-zurich-1.oraclecloud.com, OU=Oracle ADB ZURICH, O=Oracle Corporation, L=Redwood City, ST=California, C=US")))
     hr.00000.base/employees_seq_sequence.xml::42e3db1348e500dade36829bab3b7f5343ad6f09::(HR)-Generated
     hr.00000.base/locations_seq_sequence.xml::7ec49fad51eb8c0b53fa0128bf6ef2d3fee25d35::(HR)-Generated
     hr.00000.base/departments_seq_sequence.xml::93020a4f5c3fc570029b0695d52763142b6e44e1::(HR)-Generated
     hr.00000.base/departments$0_table.xml::8fccd55150e9ae05304edde806cb429fdc3b875f::(HR)-Generated
[...]



SQL> lb update -changelog main.xml

--Starting Liquibase at 17:50:14 (version 4.7.1 #0 built at 2022-01-25 22:12+0000)

-- Loaded 51 changeSets
Running Changeset: hr.00000.base/employees_seq_sequence.xml::42e3db1348e500dade36829bab3b7f5343ad6f09::(HR)-Generated
No SQL to execute object not changed.
Running Changeset: hr.00000.base/locations_seq_sequence.xml::7ec49fad51eb8c0b53fa0128bf6ef2d3fee25d35::(HR)-Generated
No SQL to execute object not changed.
Running Changeset: hr.00000.base/departments_seq_sequence.xml::93020a4f5c3fc570029b0695d52763142b6e44e1::(HR)-Generated
No SQL to execute object not changed.
Running Changeset: hr.00000.base/departments$0_table.xml::8fccd55150e9ae05304edde806cb429fdc3b875f::(HR)-Generated
.........
Action logged sucessfully.
Running Changeset: hr.00000.base/secure_employees_trigger.xml::64cba4cbb3b32b865cc97fd069651c126de0de9f::(HR)-Generated
Trigger SECURE_EMPLOYEES compiled
Trigger "HR"."SECURE_EMPLOYEES" altered.
Action logged sucessfully.
No Errors Encountered


The next lb status shows everything up to date. A subsequent lb update will not change anything.

SQL> lb status -changelog main.xml

HR@jdbc:oracle:thin:@(description=(retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1522)(host=adb.eu-zurich-1.oraclecloud.com))(connect_data=(service_name=ht8k3jwmatw52we_demoadb_medium.adb.oraclecloud.com))(security=(ssl_server_cert_dn="CN=adb.eu-zurich-1.oraclecloud.com, OU=Oracle ADB ZURICH, O=Oracle Corporation, L=Redwood City, ST=California, C=US"))) is up to date

SQL> lb update -changelog main.xml

######## ERROR SUMMARY ##################
Errors encountered:0

######## END ERROR SUMMARY ##################

You have successfully organized the directory structure and synchronized the metadata [proceed to the next lab](#next)

## Acknowledgements

- **Author** -Suraj Ramesh
- **Contributors** -
- **Last Updated By/Date** -  
