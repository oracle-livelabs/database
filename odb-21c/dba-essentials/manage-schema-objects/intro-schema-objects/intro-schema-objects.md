# Schema objects in Oracle Database

## About this workshop

This workshop enables you to perform various operations like viewing and creating schema objects using Database Actions. You will also learn how to create a new PL/SQL procedure and revalidate schema objects that are invalid.  

You can view and create schema objects such as tables, indexes and views. 

Estimated Workshop Time:  1 hour 20 minutes

### Objective

In this workshop you will learn how to perform the following tasks using Oracle Database Actions:  

-   View existing tables, create tables and load data into a tables from files
-   View and create index and view
-   Create an invalid PL/SQL procedure and validate the invalid schema objects referenced in the procedure

### Prerequisites

This lab assumes you have -

-   An Oracle Cloud account

## Appendix 1: About Schema Objects

A schema is a collection of database objects. A database user owns the schema and the shares the same name as that of the user. Some objects, such as tables or indexes, hold data whereas other objects, such as views or synonyms, consist of a definition only.

Each object in the database has a specific name and belongs to a single schema. If the objects are in separate schemas, then it is possible to have different database objects with the same name.

### About Tables

The table is the basic unit of data storage in an Oracle database. It holds all user-accessible data. Each table is made up of columns and rows. In the `employees` table, for example, there are columns called `last_name` and `employee_id`. Each row in the table represents a different employee and contains a value for `last_name` and `employee_id`.

### About Indexes

Indexes are optional schema objects that are associated with tables. You create indexes on tables to improve query performance. Just as the index in a book helps you to quickly locate specific information, an Oracle Database index provides quick access to table data. You can create as many indexes on a table as you need. 

### About Views

Views are customized presentations of data in one or more tables or other views. You can think of them as stored queries. Views do not actually contain data, but instead derive their data from the tables upon which they are based. These tables are referred to as the base tables of the view.

Similar to tables, you can query on views, update them, insert into them, and delete from them, with some restrictions. All operations performed on a view actually affect the base tables of the view. Views can provide an additional level of security by restricting access to a predetermined set of rows and columns of a table. They can also hide data complexity and store complex queries.

### About Program Code Stored in the Database

Oracle Database offers the ability to store program code in the database. Developers write program code in PL/SQL or Java and store the code in schema objects. You can use SQL Developer to manage program code objects such as:

-   PL/SQL packages, procedures, functions, and triggers
-   Java source code (Java sources) and compiled Java classes

The actions that you can perform include creating, compiling, creating synonyms for, granting privileges on, and showing dependencies for these code objects. You can also edit and debug PL/SQL code objects using Database Actions. You access administration pages for these objects by clicking links in the Programs section of the Schema subpage.

Note that creating and managing program code objects is primarily the responsibility of application developers. However, as a Database Administrator you might have to assist in managing these objects. Your most frequent task for program code objects might be to revalidate (compile) them, because they can become invalidated if the schema objects on which they depend change or are deleted.

**Note:** Other types of schema objects besides program code objects can become invalid. For example, if you delete a table, then any views that reference that table become invalid.

### About Invalid Schema Objects
There are specific types of schema objects that relate to other items. A dependent object is one that references another object, while a referred object is one that is being referenced. The compiler creates these references at compile time, and if it is unable to resolve them, the dependent object is designated as invalid.  
For instance, a view can contain a query that refers to tables or other views, and a PL/SQL subprogram may call other subprograms or refer to tables or views using static SQL.

Due to the impact invalidation has on applications using the database, it is crucial to be aware of changes that could cause schema objects to become invalid.

Use the following query to display the set of invalid objects in the database:  
`SELECT object_ name, object_ type FROM dba_objects  
WHERE status = 'INVALID';`

### Validate Invalid Schema Objects

Schema objects (such as triggers, procedures, or views) become invalid when objects on which they depend change. For example, if a PL/SQL procedure contains a query on a table and you modify table columns that are referenced in the query, then the PL/SQL procedure becomes invalid. You revalidate schema objects by compiling them.

You can use an ALTER statement to manually recompile a single schema object. For example, to recompile package body Pkg1, you would run the following DDL statement:  
`ALTER PACKAGE pkg1 COMPILE REUSE SETTINGS;`

You can also manually recompile invalid objects with `RECOMP_ SERIAL` procedure. The RECOMP_SERIAL procedure recompiles all invalid objects in a specified schema. 

After your application upgrades, it is a good practice to revalidate invalid objects to avoid application latencies. Oracle provides the UTL_RECOMP package to assist in object revalidation.

Click on the next lab to **Get started**. 

## Learn More

-   [Database Administrator’s Guide](https://docs.oracle.com/en/database/oracle/oracle-database/21/admin/index.html)

## Acknowledgements

-   **Author** - Manisha Mati, Database User Assistance Development team
-   **Contributors** - Suresh Rajan, Victor Martinez, Manish Garodia, Aayushi Arora 
-   **Last Updated By/Date** - Manisha Mati, March 2023
