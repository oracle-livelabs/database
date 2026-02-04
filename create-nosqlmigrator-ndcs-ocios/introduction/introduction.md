# Introduction

## About this Workshop

In this workshop you will perform a data migration from Oracle NoSQL Database Cloud Service table to a JSON file in the OCI Object Storage.

This workshop walks you through the steps to download the Migrator utility to a Cloud Shell, create source and sink configuration templates for the Migrator utility, and migrate data from Oracle NoSQL database Cloud Service to OCI Object Storage.

Estimated Lab Time: 35 Minutes

### About NoSQL Database

As a modern application developer, you have many choices when faced with deciding when and how to persist a piece of data. In recent years, NoSQL databases have become increasingly popular and are now seen as one of the necessary tools in the toolbox that every application developer must have at their disposal. While tried and true relational databases are great at solving classic application problems like data normalization, strictly consistent data, and arbitrarily complex queries to access that data, NoSQL databases take a different approach.

Many of the more recent applications have been designed to personalize the user experience to the individual, ingest huge volumes of machine generated data, deliver blazingly fast, crisp user interface experiences, and deliver these experiences to large populations of concurrent users. In addition, these applications must always be operational, with zero down-time, and with zero tolerance for failure. The approach taken by Oracle NoSQL Database is to provide extreme availability and exceptionally predictable, single digit millisecond response times to simple queries at scale. The Oracle NoSQL Database Cloud Service is designed from the ground up for high availability, predictably fast responses, resiliency to failure, all while operating at extreme scale. Largely, this is due to Oracle NoSQL Database’s shared nothing, replicated, horizontal scale-out architecture and by using the Oracle NoSQL Database Cloud Service, Oracle manages the scale out, monitoring, tuning, and hardware/software maintenance, all while providing your application with predictable behavior.

### About Cloud Shell

The OCI Cloud Shell is a feature that is available to all the OCI users. It is a free to use web browser-based terminal accessible from your Oracle Cloud Console. You can use the Cloud Shell to access a pre-authenticated OCI CLI LINUX shell on a VM provisioned for you, which runs in its own tenancy. For more details, see **[Cloud Shell.](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/cloudshellintro.htm)**

In this workshop, you will use the Cloud Shell to run the Oracle NoSQL Migrator utility.

### About Oracle NoSQL Migrator

Oracle NoSQL Database Migrator is a utility that lets you move Oracle NoSQL tables from one data source to another. The Migrator utility exports data from the selected source and imports that data into the target. NoSQL Database Migrator allows the source to provide a schema definition for the table data. You can select a default schema or identify a schema for the target table. Ensure that the source data matches with the target schema. If required, you can use transformations to map the source data to the target table.


### Objectives

In this workshop you will:
* Download the Oracle NoSQL Migrator utility to the Cloud Shell in the subscribed region.
* Create a Migrator configuration file.
* Migrate data from Oracle NoSQL Database Cloud Service table to a JSON file in the OCI Object Storage.

*Note: If you have a **Free Trial** account, when your Free Trial expires your account will be converted to an **Always Free** account. You will not be able to conduct Free Tier workshops unless the Always Free environment is available. **[Click here for the Free Tier FAQ page.](https://www.oracle.com/cloud/free/faq.html)***

### Prerequisites

*  An Oracle Free Tier, Always Free, Paid or LiveLabs Cloud Account

You may proceed to the next lab.

## Learn More

* **[Using Oracle NoSQL Database Migrator](https://docs.oracle.com/en/cloud/paas/nosql-cloud/cjphq/#GUID-44D8559E-175B-4A9E-8743-95A056BC13FD)**
* **[Supported Sources and Sinks](https://docs.oracle.com/en/cloud/paas/nosql-cloud/cjphq/#GUID-58EC3366-3E9E-44F8-9C88-AD71771F2FF0)**

## Acknowledgements
* **Author** - Ramya Umesh, Principal UA Developer, DB OnPrem Tech Svcs & User Assistance
* **Last Updated By/Date** - Ramya Umesh, Principal UA Developer, DB OnPrem Tech Svcs & User Assistance, December 2025
