# Introduction

## About the Enable AutoREST on JSON Duality Views using ORDS Workshop

This workshop focuses on working with REST calls to interact with JSON Duality Views in Oracle Database 23c. 

### **JSON Duality**

JSON Relational Duality is a landmark capability in Oracle Database 23c providing game-changing flexibility and simplicity for Oracle Database developers. This breakthrough innovation overcomes the historical challenges developers have faced when building applications, using relational or document models.

“JSON Relational Duality in Oracle Database 23c brings substantial simplicity and flexibility to modern app dev,” said Carl Olofson, research Vice President, Data Management Software, IDC. “It addresses the age-old object - relational mismatch problem, offering an option for developers to pick the best storage and access formats needed for each use case without having to worry about data structure, data mapping, data consistency, or performance tuning. No other specialized document databases offer such a revolutionary solution.”

JSON Relational Duality helps to converge the benefits of both document and relational worlds. Developers now get the flexibility and data access benefits of the JSON document model, plus the storage efficiency and power of the relational model. The new feature enabling this convergence is JSON Relational Duality View (Will be referred below as Duality View).

Key benefits of JSON Relational Duality:
- Experience extreme flexibility in building apps using Duality View. Developers can access the same data relationally or as hierarchical documents based on their use case and are not forced into making compromises because of the limitations of the underlying database. Build document-centric apps on relational data or create SQL apps on documents.
- Duality Views provide fully updatable JSON views over data. Apps can read a document, make necessary changes, and write the document back without worrying about underlying data structure, mapping, consistency, or performance tuning. Experience simplicity by retrieving and storing all the data needed for an app in a single database operation.
- Developers can use the power of Duality View to define multiple JSON Views across overlapping groups of tables. This flexible data modeling makes building multiple apps against the same data easy and efficient.
- Duality Views are fully ACID (atomicity, consistency, isolation, durability) transactions across multiple documents and tables. It eliminates data duplication across documents data, whereas consistency is maintained automatically. They eliminate the inherent problem of data duplication in document databases.
- Build apps that support high concurrency access and updates: Traditional locks don’t work well for modern apps. A new lock-free concurrency control provided with Duality View supports high concurrency updates. The new-lock free concurrency control also works efficiently for interactive applications since the data is not locked during human thinking time.

### **Oracle REST Data Service (ORDS) and AutoREST**

Interacting with your Oracle Database with HTTPS and REST APIs can be as simple as picking the objects in your database you want to start working with.

Oracle REST Data Service (ORDS) includes a feature known as ‘AutoREST,’ where one or more objects are enabled, and REST API endpoints are automatically published. For example, a TABLE can be enabled for GET, PUT, POST, DELETE operations to get one or more rows, insert or update rows, delete rows, or even batchload multiple rows in a single request. This feature has been enhanced for 23c to include similar REST access for JSON-Relational duality views. 

This tutorial will walk through the basic use cases for working with a REST Enabled JSON-Relational duality views. 

If you are familiar with SQL Developer Web, you may optionally use it to REST Enable your DVs, explore your REST APIs, and use the built-in OpenAPI doc to use the APIs based on the examples in this document. 

These tutorials include the SQL, PL/SQL, and cURL commands to work with the examples from your favorite command-line interface. 

For the sake of simplicity, these REST APIs are unprotected. Oracle Database REST APIs offer performance AND secure access for application developers, and it is recommended you protect your endpoints with the proper web privileges and roles.


Estimated Time: 30 minutes

### Objectives
In this lab, you will:

- Create JSON Duality Views
- Enable AutoREST on the JSON Duality Views
- Perform insert, update, delete operations against JSON Duality Views using REST


### Prerequisites
In order to do this workshop you need

- An Oracle Database 23c Free Developer Release or one running in a LiveLabs environment

## Learn More

- [JSON Relational Duality: The Revolutionary Convergence of Document, Object, and Relational Models](https://blogs.oracle.com/database/post/json-relational-duality-app-dev)
- [JSON Duality View documentation](https://docs.oracle.com/en/database/oracle/oracle-database/23/jsnvu/index.html)
- [Blog: Key benefits of JSON Relational Duality](https://blogs.oracle.com/database/post/key-benefits-of-json-relational-duality-experience-it-today-using-oracle-database-23c-free-developer-release)
- [ORDS Documentation](https://docs.oracle.com/en/database/oracle/oracle-rest-data-services/23.1/)

## Acknowledgements

- **Authors**- William Masdon, Product Manager, Database; Jeff Smith, Distinguished Product Manager, Database; Ranjan Priyadarshi, Senior Director, Database Product Management
- **Last Updated By/Date** - William Masdon, Product Manager, Database, April 2023
