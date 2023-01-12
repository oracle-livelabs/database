# Introduction to Oracle Edition Based Redefinition

Oracle Edition-based redefinition (EBR) enables online application upgrade with uninterrupted availability of the application. When the installation of an upgrade is complete, the pre-upgrade application and the post-upgrade application can be used at the same time. Therefore, an existing session can continue to use the pre-upgrade application until its user decides to end it; and all new sessions can use the post-upgrade application. When there are no longer any sessions using the pre-upgrade application, it can be retired. In this way, EBR allows hot rollover from from the pre-upgrade version to the post-upgrade version, with zero downtime.

EBR enables online application upgrades in the following manner:

- Code changes are installed in the privacy of a new edition.

- Data changes are made safely by writing only to new columns or new tables not seen by the old edition. An editioning view exposes a different projection of a table into each edition to allow each to see just its own columns.

- Crossedition triggers propagate data changes made by the old edition into the new edition’s columns, or (in hot-rollover) vice-versa.

**EBR is available for use in all editions of Oracle Database without the need to license it**

You can watch the video below for an overview on Oracle Edition Based Redefinition.

[EBR Introduction] (videohub:1_p6bapnjx)

# Introduction to Oracle Online Redefinition 

The Online Redefinition feature in Oracle Database offers administrators unprecedented flexibility to modify table physical attributes and transform both data and table structure while allowing users full access to the database. Below are some of the benefits.

- Modify table physical attributes and transform both data and table structure while allowing users full access to the database.
- Improve data availability, query performance, response time and disk space utilization, all of which are important in a mission-critical environment
- Make the application upgrade process easier, safer and faster.
- Execute using Enterprise Manager or SQL*Plus command line interface.


## About this Workshop

This workshop will cover how to evolve your oracle database applications entirely online.

While building automated development pipelines is highly regarded by development teams, making changes to database schemas and stored procedures without interrupting application traffic is tricky. What if the database changes were both safe and online? We will use Oracle Database features that allow for online data movement, schema redefinitions, table reorganizations, and, thanks to the integration with DevOps tools, controlling code versioning (Liquibase)


You can watch the video below for an overview on how to evolve Oracle DB Applications online

[](youtube:wwqDn63q3cw)

*Estimated Workshop Time : 2 hours*

## Workshop Objectives

- Create and connect to Autonomous Database
- Download ADB wallet and lab files
- Prepare and review HR schema
- Use Liquibase to generate schema
- Create Directory structure and sync the metadata
- Review and update new edition scripts
- Verify new edition
- Switch to new edition and decommision the old edition

## Workshop Prerequisites

- Autonomous (ATP or ADW) DB
- Access to OCI Cloud shell


## Additional information

- [Oracle EBR] (https://www.oracle.com/database/technologies/high-availability/ebr.html)
- [Oracle Online Redefenition] (https://www.oracle.com/database/technologies/high-availability/online-ops.html)
- [Using Liquibase with SQLcl] (https://docs.oracle.com/en/database/oracle/sql-developer-command-line/22.4/sqcug/using-liquibase.html#GUID-4CA25386-E442-4D9D-B119-C1ACE6B79539)

## **Acknowledgements**

- Author - Suraj Ramesh and Ludovico Caldara
- Last Updated By/Date -Suraj Ramesh, Jan 2023
