# Introduction

## About this Workshop

Oracle Database 19c is a *Long Term Support Release* for the Oracle Database 12.2 release family. It is available on all popular on-prem platforms, Oracle Exadata and Oracle Database Appliance, and in Oracle Cloud. As the latest Long Term Support Release, it offers customers the highest levels of stability and the longest error correction support. And, by upgrading to Oracle Database 19c, customers will have Premier Support until the end of April 2024 and Extended Support until end of April 2027.  There is a direct upgrade path to Oracle Database 19c from Oracle Database 11.2.0.4, 12.1.0.2, 12.2.0.1 and 18c releases, regardless of the patch bundle applied.

Estimated Workshop Time: 75 minutes

Optionally, you can watch this [introduction to upgrade to Oracle Database 19c](https://www.youtube.com/watch?v=lOzL5irmuJo).

### Objectives

In this workshop, you will:

* Upgrade databases
* Use Performance Stability Perscription to ensure performance stability
* Convert to multitenant architecture
* Migrate databases using Full Transportable Export/Import

## About the workshop contents

This workshop comes with pre-installed Oracle Homes and pre-created databases. 
You can switch between environments with the shortcuts shown in the last column of the below diagram.

![Overview of the Oracle Homes and databases in the lab](./images/00-introduction-overview.png " ")

## Upgrade and data migration methods and processes

### AutoUpgrade

- AutoUpgrade is the only recommended tool to upgrade Oracle databases. Whether you want to upgrade only one or thousands of databases, AutoUpgrade performs not only the upgrade but also all the pre- and post-upgrade tasks. It can upgrade many databases in parallel and allows all sorts of customizations needed in today's complex environments. Furthermore, AutoUpgrade can also plugin your database into a precreated CDB and does the conversion of a non-CDB into a PDB fully unattended. AutoUpgrade works on all supported platforms, for non-CDB and CDBs, for all or only selected pluggable databases.

### Migrating data using Oracle Data Pump

- Data Pump provides export and import capabilities. Oracle Data Pump can perform a full or partial export from your database, followed by a full or partial import into the new release of Oracle Database. Data Pump allows to migrate directly into PDBs as well and works independently of the source database version across versions and operating system platforms. In addition, Data Pump in conjunction with Transportable Tablespaces takes away the complexity of rebuilding all the meta objects with just one command as Full Transportable Export Import.

You may now *proceed to the next lab*.

## Learn More

* Documentation, [Database Upgrade Guide](https://docs.oracle.com/en/database/oracle/oracle-database/19/upgrd/intro-to-upgrading-oracle-database.html#GUID-FA024F34-A61A-4C4B-AA60-C123A9191A16)
* Blog, [Upgrade your Database - NOW!](https://MikeDietrichDE.com)
* My Oracle Support, [Oracle Databases Release and Support Coverage](https://support.oracle.com/epmos/faces/DocumentDisplay?id=742060.1&displayIndex=1)

## Acknowledgements
* **Author** - Mike Dietrich, Database Product Management
* **Contributors** - Daniel Overby Hansen, Roy Swonger, Sanjay Rupprel, Cristian Speranta, Kay Malcom
* **Last Updated By/Date** - Daniel Overby Hansen, July 2023
