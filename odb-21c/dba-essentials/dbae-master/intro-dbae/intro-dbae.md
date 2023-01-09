# DBA Essentials workshops series

## About this workshop

This workshop introduces all workshops from the *DBA Essentials series*. It not only provides a list of these workshops but also suggests the sequence to run them. 

> **Note:** You can also use the filer **DBA Essentials** on Livelabs and find the workshops that belong to this series.

### **What is the purpose and scope?**

The primary goal of this workshop is to help you get started with the DBA Essentials workshops. It provides a single page to access these workshops in a specific order. 

Each of these individual workshops focus on specific areas of *Oracle Database 21c* and illustrate some basic activities in database administration. Some workshop uses *Oracle Enterprise Manager (Oracle EM)* as an interface for procedures and tasks. Using these workshops, you can learn how to manage your database with simple steps.

Estimated workshop time: 30 minutes

### Objectives

In this workshop, you will find a list of workshops from the DBA Essentials series. Run the DBA Essentials workshops in the sequence specified in this workshop.

### Prerequisites

This lab assumes you have -
 -   An Oracle Cloud account

## Products and technology

Before getting started with the DBA Essentials workshops, it is helpful to gain basic understanding of the products, and a few terms and concepts used in these workshops. 

### **Oracle Database**

With Oracle Database 12c Release 2, the concept of multitenant environment was introduced. A multitenant architecture comprises a Container Database (CDB) that has one or more user-created Pluggable Databases (PDBs). PDBs are fully backward compatible with previous releases before Oracle Database 12c.

The main components of a CDB are *Root*, *seed*, and *PDB*. 

 - **Root**   
	 `CDB$ROOT` stores the Oracle-supplied metadata and common users. An example of metadata is the source code for Oracle-supplied PL/SQL packages. A common user is a database user known across all containers. A CDB has only one root.

 - **Seed**   
	 `PDB$SEED` is the template to create new PDBs. You cannot add or modify objects in the seed. A CDB has only one seed.

 - **PDB**   
	 It is a collection of portable schemas, schema objects, and non-schema objects that interfaces with the Oracle Net client. It contains data and code required to support an application.   
	 Each of these components is a container in itself. In other words, the CDB, the seed, and each PDB is a container. A container has a unique ID and an associated name within the database.

<!--
The main components of a CDB are -

 - *Root*
 - *seed*
 - *PDB*

### Root

`CDB$ROOT` stores the Oracle-supplied metadata and common users. An example of metadata is the source code for Oracle-supplied PL/SQL packages. A common user is a database user known across all containers. A CDB has only one root.

### Seed

`PDB$SEED` is the template to create new PDBs. You cannot add or modify objects in the seed. A CDB has only one seed.

### PDB

It is a collection of portable schemas, schema objects, and non-schema objects that interfaces with the Oracle Net client. It contains data and code required to support an application.

Each of these components is a container in itself. In other words, the CDB, the seed, and each PDB is a container. A container has a unique ID and an associated name within the database.

-->

### **Oracle Enterprise Manager (Oracle EM)**

Oracle EM is Oracle’s on-premise management solution providing centralized monitoring, administration, and lifecycle management functionality for the complete IT infrastructure. It provides a graphical user interface to monitor and manage your database from a web-based console.

Oracle EM offers a comprehensive set of performance and health metrics that allows unattended monitoring of key components in your environment. Examples of these key components are applications, application servers, Oracle Databases, and back-end components on which they rely, such as hosts, operating systems, storage, and so on. 

These products and tools assist you in performing database administration.

## Database administration

**Oracle DBA Essentials** is a task-oriented, quick start approach to familiarize you with database administration and management. It features the basic know-hows of *Oracle Database* and helps you perform tasks essential to administer your database.

You can install Oracle Database on your system, and perform various administrative tasks and activities for monitoring, configuring, and managing your database. 

These tasks are associated with, but not limited to -

 - Oracle home
 - Managed targets, systems, and services
 - Network environment
 - Database instance and memory
 - Storage structures
 - User accounts and security privileges
 - Backup and recovery
 - PDBs
 - Database objects, such as tables, views, indexes, and so on

You will learn the essentials of database administration, such as how to monitor the health, optimize database performance, and manage the lifetime of your Oracle Database.

Click on the next lab to get started.

## Learn More

 - Watch this video to learn about the core *Oracle Database Breakthrough Innovations*.

	 [](youtube:sFQqiGCSh9c)

 - [Blog on Introducing Oracle Database 21c](https://blogs.oracle.com/database/introducing-oracle-database-21c)

 - [Oracle Database Documentation](https://docs.oracle.com/en/database/oracle/oracle-database/index.html)

 - [Oracle Enterprise Manager Cloud Control (Oracle EMCC)](https://docs.oracle.com/en/enterprise-manager/index.html)

## Acknowledgements

 - **Author** - Manish Garodia, Team Database User Assistance Development
 - **Contributors** - Suresh Rajan
 - **Last Updated By/Date** - Manish Garodia, January 2023
