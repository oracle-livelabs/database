# Introduction

## About This Workshop

Oracle AI Database 26ai is a *Long-Term Support Release* with Premier Support until the end of 2031 and Extended Support for a period thereafter. In this lab, you'll learn how to upgrade your databases using different techniques. You'll gain an understanding of the pros and cons of each method, enabling you to make the best decisions in your daily work. Besides upgrading and converting databases, this lab covers common upgrade-related tasks like installing a new Oracle home and diagnosing upgrade issues.

Estimated Workshop Time: 120 minutes

### Objectives

In this workshop, you will:

* Upgrade databases
* Convert from non-CDB architecture
* Install an Oracle home
* Diagnose and troubleshoot

## About the Workshop Contents

This workshop comes with pre-installed Oracle homes and pre-created databases.
You can switch between environments with the shortcuts shown in the last column of the diagram below.

![Overview of the Oracle Homes and databases in the lab](./images/introduction-overview.png " ")

The lab contains:
* 15 labs total
* 9 labs on the main track
* 6 optional labs

Guidance:
* Start by completing labs 1 through 9 in the specified order.
* Then, you may complete the optional labs in any order.
* You may also start an optional lab when time allows. For instance, if you're waiting for an upgrade to complete.
* All the optional labs are self-contained and can be run simultaneously with other labs.

## Upgrade and data migration methods and processes

### AutoUpgrade

* AutoUpgrade is the only recommended tool to upgrade Oracle AI Database. Whether you want to upgrade a single or thousands of databases, AutoUpgrade performs not only the upgrade itself but also all the pre- and post-upgrade tasks. It can upgrade many databases in parallel and allows all sorts of customizations required in today's complex environments. Furthermore, AutoUpgrade can also plug in your database into a precreated CDB and can convert a non-CDB into a PDB fully unattended. AutoUpgrade works on all supported platforms and supports non-CDBs, CDBs, and either all or selected PDBs.

### Migrating data using Oracle Data Pump

* Data Pump provides export and import capabilities. Oracle Data Pump can perform full or partial export from your database, followed by a full or partial import into the new release of Oracle AI Database. Data Pump allows you to migrate directly into PDBs as well, works independently of the source database version and across versions and operating system platforms. In addition, Data Pump in conjunction with transportable tablespaces eliminates the complexity of rebuilding all the metadata objects with just one command using Full Transportable Export/Import.

You may now [*proceed to the next lab*](#next).

## Learn More

* Documentation, [Database Upgrade Guide](https://docs.oracle.com/en/database/oracle/oracle-database/26/upgrd/intro-to-upgrading-oracle-database.html)
* Blog, [Upgrade your Database - NOW!](https://MikeDietrichDE.com)
* My Oracle Support, [Release Schedule of Current Database Releases (Doc ID 742060.1)](https://support.oracle.com/epmos/faces/DocumentDisplay?id=742060.1&displayIndex=1)

## Acknowledgements

* **Author** - Daniel Overby Hansen
* **Contributors** - Rodrigo Jorge, Alex Zaballa, Mike Dietrich, Alejandro Diaz
* **Last Updated By/Date** - Daniel Overby Hansen, August 2026
