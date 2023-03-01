# Introduction

### Oracle Edition Based Redefinition

Oracle Edition-Based Redefinition (EBR) enables online application upgrades with uninterrupted availability. When the installation of an upgrade is complete, the pre-upgrade application and the post-upgrade application can run at the same time. Therefore, existing sessions can keep working with the pre-upgrade application until the rolling upgrade is over, and new sessions can start working on the post-upgrade application. The pre-upgrade application can be retired when no more sessions use it. Edition-Based Redefinition allows hot-rolling application upgrades without downtime, enabling gradual application rollover used in modern CI/CD pipelines.

Edition-Based Redefinition enables online application upgrades in the following manner:

- Code changes are deployed in the privacy of a new edition. The existing views, packages, and triggers stay valid and unchanged for the sessions using the previous edition.

- A special type of views called editioning views abstracts the access to the base tables so that different application versions can see and use their own projection of the table.

- Cross-edition triggers propagate data changes made by the old edition into the new edition’s columns and vice-versa, making the upgrade tolerant of layout changes.

You can watch the video for an overview of Oracle Edition-Based Redefinition.

[Edition-Based Redefinition Introduction](videohub:1_p6bapnjx)

### Oracle Online Redefinition

The Online Redefinition feature in Oracle Database offers administrators unprecedented flexibility to modify table physical attributes and transform both data and table structure while allowing users full access to the database.

Below are some of the benefits.

- Modify table physical attributes and transform both data and table structure while allowing users full access to the database.
- Improve data availability, query performance, response time and disk space utilization, all of which are important in a mission-critical environment
- Make the application upgrade process easier, safer and faster.

## About this Workshop

This workshop will cover how to evolve your oracle database applications entirely online. While building automated development pipelines is highly regarded by development teams, making changes to database schemas and stored procedures without interrupting application traffic is tricky. What if the database changes were both safe and online? We will use Oracle Database features that allow for online data movement, schema redefinitions, table reorganizations, and, thanks to the integration with DevOps tools, controlling code versioning (Liquibase).

You can watch the video for an overview of evolving Oracle Database Applications online:

[](youtube:wwqDn63q3cw)

### Workshop Objectives

- Create and connect to Autonomous Database
- Download Autonomous Database wallet and lab files
- Prepare and review the HR schema
- Use Liquibase to generate the schema
- Create the directory structure for the changelogs and sync the metadata
- Review and update the new edition scripts
- Verify the new edition
- Switch to the new edition and decommission the old edition

Estimated Workshop Time : 2 hours

### Workshop prerequisites

There are no prerequisites if you run this lab in a LiveLabs sandbox.

You can run this workshop also with the Always Free offering in your tenancy! You will need an OCI Free Tier subscription with an Autonomous Database available.

## Learn More

- [Oracle Edition-Based Redefinition] (<https://www.oracle.com/database/technologies/high-availability/ebr.html>)
- [Oracle Online Redefinition] (<https://www.oracle.com/database/technologies/high-availability/online-ops.html>)
- [Using Liquibase with SQLcl] (<https://docs.oracle.com/en/database/oracle/sql-developer-command-line/22.4/sqcug/using-liquibase.html#GUID-4CA25386-E442-4D9D-B119-C1ACE6B79539>)

## Acknowledgements

- Authors - Ludovico Caldara,Senior Principal Product Manager,Oracle MAA PM Team and Suraj Ramesh,Principal Product Manager,Oracle MAA PM Team
- Last Updated By/Date - Suraj Ramesh, Feb 2023
