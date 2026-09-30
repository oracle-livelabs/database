# Introduction

## About this workshop

This workshop is about creating and managing schema objects in Oracle Database, such as tables, indexes, and views. You will use Database Actions to perform various operations, view existing schema objects, create new objects, and so on. 

You will also learn how to create a new PL/SQL procedure and revalidate schema objects that are invalid.

Estimated workshop time: 1 hour 20 minutes

### Objective

In this workshop you will learn how to perform the following tasks in Oracle Database using Oracle Database Actions:

-   View existing tables, create tables, and load data into tables from files
-   View and create an index and view
-   Create a PL/SQL procedure and validate the invalid schema objects referenced in the procedure

### Prerequisites

This lab assumes you have -

-   An Oracle Cloud account

## About Oracle Database Actions

Oracle Database Actions is a web-based interface for on-premises Oracle Database that uses Oracle REST Data Services to provide many of the database development, management and administration features of desktop-based Oracle SQL Developer in Autonomous Databases. The main features include running SQL statements and scripts in the worksheet, exporting data, creating RESTful web services, managing JSON collections, monitoring databases, and creating Data Modeler diagrams. You can use it without downloading or installing additional software on your system. Database Actions was earlier known as SQL Developer Web.Database Actions was earlier known as SQL Developer Web.

## About schema Objects

A schema is a collection of database objects. A database user owns the schema and the shares the same name as that of the user. Some objects, such as tables or indexes, hold data whereas other objects, such as views or synonyms, consist of a definition only.

Each object in the database has a specific name and belongs to a single schema. If the objects are in separate schemas, then it is possible to have different database objects with the same name.

### Know about Tables

The table is the basic unit of data storage in an Oracle Database. It holds all user-accessible data. Each table is made up of columns and rows. In the `employees` table, for example, there are columns called `last_name` and `employee_id`. Each row in the table represents a different employee and contains a value for `last_name` and `employee_id`.

### What are Indexes?

Indexes are optional schema objects that are associated with tables. You create indexes on tables to improve query performance. Like the index in a book helps you to quickly locate specific information, an Oracle Database index provides quick access to table data. You can create as many indexes on a table as you need. 

### What are Views?

Views are customized presentations of data in one or more tables or other views. You can think of them as stored queries. Views do not actually contain data, but instead derive their data from the tables upon which they are based. These tables are referred to as the base tables of the view.

Similar to tables, you can query on views, update them, insert into them, and delete from them, with some restrictions. All operations performed on a view actually affect the base tables of the view. Views can provide an additional level of security by restricting access to a predetermined set of rows and columns of a table. They can also hide data complexity and store complex queries.

### Program code stored in Oracle Database

Oracle Database offers the ability to store program code in the database. Developers write program code in PL/SQL or Java and store the code in schema objects. You can use SQL Developer to manage program code objects such as:

-   PL/SQL packages, procedures, functions, and triggers
-   Java source code (Java sources) and compiled Java classes

The actions that you can perform include creating, compiling, creating synonyms for, granting privileges on, and showing dependencies for these code objects. You can also edit and debug PL/SQL code objects using Database Actions. You access administration pages for these objects by clicking links in the Programs section of the Schema subpage.

Note that creating and managing program code objects is primarily the responsibility of application developers. However, as a database administrator you might have to assist in managing these objects. One of the major tasks for program code objects might be to revalidate (compile) them, because they can become invalidated if the schema objects on which they depend change or are deleted.

**Note:** Besides program code objects, other schema objects can also become invalid. For example, if you delete a table, then any views that reference that table become invalid.

### About Invalid Schema Objects

There are specific types of schema objects that relate to other items. A dependent object is one that references another object, while a referred object is one that is being referenced. The compiler creates these references at compile time, and if it is unable to resolve them, the dependent object is designated as invalid.For instance, a view can contain a query that refers to tables or other views, and a PL/SQL subprogram may call other subprograms or refer to tables or views using static SQL.

**Note:** Due to the impact invalidation has on applications using the database, it is crucial to be aware of changes that could cause schema objects to become invalid.

Use the following query to display the set of invalid objects in the database:`SELECT object_name, object_type FROM dba_objects WHERE status = 'INVALID';`

### Validate Invalid Schema Objects

Schema objects (such as triggers, procedures, or views) become invalid when objects on which they depend change. For example, if a PL/SQL procedure contains a query on a table and you modify table columns that are referenced in the query, then the PL/SQL procedure becomes invalid. You revalidate schema objects by compiling them.

You can use an ALTER statement to manually recompile a single schema object. For example, to recompile package body Pkg1, you would run the following DDL statement:`ALTER PACKAGE pkg1 COMPILE REUSE SETTINGS;`

You can also manually recompile invalid objects with `RECOMP_SERIAL` procedure. The RECOMP_SERIAL procedure recompiles all invalid objects in a specified schema. 

After your application upgrades, it is a good practice to revalidate invalid objects to avoid application latencies. Oracle provides the UTL_RECOMP package to assist in object revalidation.

Click on the next lab to **Get started**. 

## Learn More

-   [Database Administrator’s Guide](https://docs.oracle.com/en/database/oracle/oracle-database/23/admin/index.html)

## Acknowledgments

-   **Author** - Aayushi Arora, Database User Assistance Development Team
-   **Contributors** - Jeff Smith, Manish Garodia, Manisha Mati
-   **Last Updated By/Date** - Aayushi Arora, October 2024