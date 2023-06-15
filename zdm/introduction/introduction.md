# Introduction

## About Zero Downtime Migration

With Zero Downtime Migration, you can migrate Oracle databases from on premises, Oracle Cloud Infrastructure Classic, or from one Oracle Cloud Infrastructure region to another. You can move your databases to co-managed or Autonomous Database services in the cloud, or any Exadata Database Machine in the cloud or on premises.

Zero Downtime Migration provides a robust, flexible, and resumable migration process that is also easy to roll back. Zero Downtime Migration integrates Oracle Maximum Availability Architecture (MAA) and supports Oracle Database 11g Release 2 (11.2.0.4) and later database releases.

You can perform and manage a database migration of an individual database or perform database migrations at a fleet level. Leveraging technologies such as Oracle Data Guard, Oracle Recovery Manager (RMAN), Oracle GoldenGate, and Oracle Data Pump, you can migrate databases online or offline.

The Zero Downtime Migration software is a service with a command line interface that you install and run on a host that you provision. The server where the Zero Downtime Migration software is installed is called the Zero Downtime Migration service host. You can run one or more database migration jobs from the Zero Downtime Migration service host.

Estimated Total Lab Time: 2 hours

For More Information on Zero Downtime Migration: [ZDM Website](https://www.oracle.com/database/technologies/rac/zdm.html)

## About Logical Offline Migration
Zero Downtime Migration supports both online and offline migration, and can perform both physical and logical migrations.

* **Online** migration methods incur zero or minimal downtime and can leverage either physical or logical migration methods.

* **Offline** migration methods will incur downtime on the source database as part of the migration process. It can leverage either physical or logical migration methods.

**Physical** migration methods:

* Use Oracle Data Guard and RMAN to perform migrations

* Allow you to convert a non-multitenant non container database (CDB) source database to a multitenant container database (CDB) target database

**Logical** migration methods:

* Use Oracle Data Pump and, for online migrations, Oracle GoldenGate Microservices

* Include integration with the Cloud Premigration Advisor Tool (CPAT), which a) warns you about any features used by your database that aren't supported in the target cloud environment, and b) makes suggestions for remedial changes and/or parameters to use for the Data Pump export and import operations

For the purpose of this workshop we will be completing a logical offline migration using an Oracle Cloud Infrastructure (OCI) object storage bucket.

The migration will consist of moving data from the source database to an OCI object storage bucket from which it then gets transferred to the target Oracle autonomous database serverless.

## Workshop Objectives

* Configure source database for your migration
* Prepare the host environment
* Set up connectivity with API & RSA keys
* Create the autonomous database credential
* Complete the Zero Downtime Migration (ZDM) template
* Successfully run the migration to the target autonomous database

## Prerequisites

This workshop requires an Oracle Cloud account. You may use your own cloud account, a cloud account that you obtained through a trial, a Free Tier account, or a training account whose details were given to you be an Oracle instructor.

*Note: If you have a **Free Trial** account, when your Free Trial expires your account will be converted to an **Always Free** account. You will not be able to conduct Free Tier workshops unless the Always Free environment is available. **[Click here for the Free Tier FAQ page.](https://www.oracle.com/cloud/free/faq.html)***

You may now [proceed to the next lab](#next).

## Learn More About Zero Downtime Migration (ZDM)

* [ZDM Website](https://www.oracle.com/database/technologies/rac/zdm.html)
* [ZDM Documentation](https://docs.oracle.com/en/database/oracle/zero-downtime-migration/21.1/zdmug/introduction-to-zero-downtime-migration.html#GUID-A4EC1775-307C-47A6-89FB-E4C3F1FBC4F5)
* [Blog](https://blogs.oracle.com/maa/new:-oracle-zero-downtime-migration-21c)

## Acknowledgements
* **Author** - Zachary Talke, Solutions Engineer, NA Tech Solution Engineering
* **Last Updated By/Date** - Zachary Talke, July 2021
