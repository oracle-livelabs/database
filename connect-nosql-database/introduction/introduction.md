# Introduction

## About this Workshop

This workshop is designed to help you quickly get started with developing applications using Oracle NoSQL Database. It shows the different methods by which your application can connect to the database and perform simple operations on it.

Oracle NoSQL Database offers various methods by which your application can access the database:

* Using Integrated Development Environments (IDEs):

You can use integrated development environments to connect to the Oracle NoSQL database and develop your applications efficiently. Oracle NoSQL Database plugins are available for [Microsoft Visual Studio Code](https://docs.oracle.com/en/database/other-databases/nosql-database/25.3/plugins/oracle-nosql-database-visual-studio-code-extension.html) and [IntelliJ](https://docs.oracle.com/en/database/other-databases/nosql-database/25.3/plugins/intellij-plugin.html) IDEs.

* Using Software Development Kits (SDKs):

You can use the SDKs available in different programming languages to develop your applications. These [SDKs](https://docs.oracle.com/en/database/other-databases/nosql-database/25.3/nsdev/oracle-nosql-database-sdk-drivers.html) enable applications to connect to the database using HTTP/HTTPS protocol via the [Oracle NoSQL database proxy](https://docs.oracle.com/en/database/other-databases/nosql-database/25.3/admin/proxy.html).

* Using SQL Command Line Interface (CLI):

You can use the [SQL](https://docs.oracle.com/en/database/other-databases/nosql-database/25.3/sqlfornosql/introduction-sql.html) language in your applications to interact with the Oracle NoSQL Database.

In this workshop, you will be using Microsoft Visual Studio Code to demonstrate the three methods. 

Also, you will be using a simplified version of the Oracle NoSQL Database called [KVLite](https://docs.oracle.com/en/database/other-databases/nosql-database/25.3/kvlite/introduction-kvlite.html). KVLite provides a single storage node, single shard store, that is not replicated.

Estimated Time: 30 mins

### About NoSQL Database

Modern application developers have many choices when faced with deciding when and how to persist a piece of data. In recent years, NoSQL databases have become increasingly popular and are now seen as one of the necessary tools in the toolbox that every application developer must have at their disposal. Many of the more recent applications have been designed to personalize the user experience to the individual, ingest huge volumes of machine generated data, deliver blazingly fast, crisp user interface experiences, and deliver these experiences to large populations of concurrent users. In addition, these applications must always be operational, with zero down-time, and with zero tolerance for failure. The approach taken by Oracle NoSQL Database is to provide extreme availability and exceptionally predictable, single digit millisecond response times to simple queries at scale. Largely, this is due to Oracle NoSQL Database’s shared nothing, replicated, horizontal scale-out architecture and by using the Oracle NoSQL Database Cloud Service, Oracle manages the scale out, monitoring, tuning, and hardware/software maintenance, all while providing your application with predictable behavior.

### Objectives

In this workshop, you will:

* Run a simplified version of Oracle NoSQL Database (KVLite) in a container
* Use an IDE to connect to KVLite
* Use an SDK to connect to KVLite
* Use SQL Command Line Interface (CLI) to connect to KVLite
* Create a JSON collection table and insert data into the table
* Use extensions in Visual Studio Code to view the KVLite instance running in a container and to explore the tables using the table explorer.

### Prerequisites

This lab assumes you have:

* Basic knowledge of Python and SQL
* Basic understanding of containers

## Task 1: Getting started with connecting to Oracle NoSQL Database

You can use the Visual Studio Code to quickly connect to the Oracle NoSQL database using the following steps:

* Start KVLite in a container
* Establish a connection to KVLite using one of the approaches - IDE Plugin, SDK, or SQL CLI
* Create tables and perform operations on them
* View and explore the tables in the database using the table explorer

You may now **proceed to the next lab**.

## Acknowledgements

* **Author** - Purnima Subramanian, Principal UA Developer, DB Cloud Technical Svcs & User Assistance
* **Last Updated By/Date** - Purnima Subramanian, Principal UA Developer, DB Cloud Technical Svcs & User Assistance, December 2025
