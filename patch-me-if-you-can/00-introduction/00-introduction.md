# Introduction and Overview

## About this Workshop


In this Database Patching lab, you will familiarize with the options of a completely unattended installation, including patches. Then you'll do out-of-place patching of a database with AutoUpgrade. To show the difference, the final step is an in-place patching operation causing more downtime.
![Lab activities](./images/overview-patch-me-if-you-can.png " ")


The patching does include not only a Release Update (RU) but also the Oracle Java Virtual Machine Bundle (OJVM), a Monthly Recommended Patch (MRP), and the Data Pump Bundle Patch (DPBP). You will clean up, and do a rollback as well.

Estimated Workshop Time: 120 minutes

### Objectives

In this workshop, you will:

* Patch Oracle Database
* Explore different methods of patching
* Investigate patching internals

## About the workshop contents

This workshop comes with pre-installed Oracle homes and pre-created databases.
You can switch between environments with the shortcuts shown in the last column of the below diagram.

![Overview of the Oracle Homes and databases in the lab](./images/introduction-overview.png " ")

The lab contains *nn* labs.

---- INSERT LAB OVERVIEW ----

* You start by blah blah
* Then blah blah
* As the last lab, blah blah

## Patching methods and processes

### AutoUpgrade

- AutoUpgrade was originally developed to facilitate easier upgrades of Oracle Database. By demand of our customers, it was enhanced to also patch Oracle Database using the same easy methodology that our customers liked. The aim of AutoUpgrade is to fully automated maintenance activites and perform them according to our best practices - include all pre- and post-tasks. It can patch many databases in parallel and allows all sorts of customizations needed in today's complex environments. utoUpgrade works on all supported platforms, for non-CDB and CDBs, for all or only selected pluggable databases.

### OPatch

- OPatch is a common utility used by many products in Oracle, including Oracle Database. OPatch patches the Oracle home, so the binaries that you use to run an Oracle Database instance. OPatch only patches the files inside the Oracle home.

### Datapatch

- Datapatch patches the database itself. Most often, patches requires changes inside the database. This could be changes to existing objects (tables, views, packages) or completely new objects. Datapatch uses *apply* scripts to make those changes. The apply scripts are stored in the Oracle home and are updated by OPatch.

You may *proceed to the next lab*.

## Learn More

* Webinar, [Release and Patching Strategies for Oracle Database 23ai](https://www.youtube.com/watch?v=sF-rmD78zIo)
* Webinar, [One-Button Patching – makes life easier for every Oracle DBA](https://youtu.be/brnBavVLyM0)

## Acknowledgments

* **Author** - Daniel Overby Hansen
* **Contributors** - Rodrigo Jorge, Alex Zaballa, Mike Dietrich
* **Last Updated By/Date** - Daniel Overby Hansen, December 2024
