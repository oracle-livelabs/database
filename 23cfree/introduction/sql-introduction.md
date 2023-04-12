# Introduction

## About the JSON Duality Views Workshop

This workshop focuses on working with JSON Duality Views in Oracle Database 23c.

### **JSON Duality**

JSON Relational Duality is a landmark capability in Oracle Database 23c that provides game-changing flexibility and simplicity for Oracle Database developers. This breakthrough innovation overcomes the historical challenges that developers have faced when building applications, either when using the relational model or when using the document model.

“JSON Relational Duality in Oracle Database 23c brings substantial simplicity and flexibility to modern app dev,” said Carl Olofson, research vice president, Data Management Software, IDC. “It addresses the age-old object—relational mismatch problem, offering an option for developers to pick the best storage and access formats needed for each use case without having to worry about data structure, data mapping, data consistency, or performance tuning. No other specialized document databases offer such a revolutionary solution.”

JSON Relational Duality helps to converge benefits of both document and relational worlds. Developers now get the flexibility and data access benefits of the JSON document model, plus the storage efficiency and power of the relational model. The new feature that enables this convergence is called JSON Relational Duality View (Will be simply referred below as Duality View).

Key benefits of JSON Relational Duality:

- Experience extreme flexibility in building apps using Duality view. Developers can access the same data relationally or as hierarchical documents based on their use case and are not forced into making compromises because of the limitations of the underlying database. Build document-centric apps on relational data or create SQL apps on documents.
- Duality views provides fully updateable JSON views over data. Apps can simply read a document, make necessary changes, and write the document back without worrying about underlying data structure, mapping, consistency, or performance tuning. Experience simplicity by retrieving and storing all the data needed for an app in a single database operation.
- Developers can use the power of Duality view in defining multiple JSON Views across overlapping groups of tables. This flexible data modeling makes building multiple apps against the same data easy and efficient.
- Duality Views are fully ACID (atomicity, consistency, isolation, durability) transactions across multiple documents and tables. It eliminates data duplication across documents data, whereas consistency is maintained automatically. They eliminate the inherent problem of data duplication in document databases.
- Build apps that support high concurrency access and updates: Traditional locks don’t work well for modern apps. A new lock-free concurrency  control provided with Duality View helps support high concurrency updates, which also works efficiently for interactive applications since the data is not locked during human thinking time.

Estimated Time: 30 minutes

### Objectives

In this lab, you will:
* Create JSON Duality Views
* Perform insert, update, delete operations against JSON Duality Views
* Perform both JSON and SQL operations against JSON Duality Views

### Prerequisites

In order to do this workshop you need
* An Oracle 23c Free Developer Release Database or one running in a LiveLabs environment

## Learn More

* [JSON Relational Duality: The Revolutionary Convergence of Document, Object, and Relational Models](https://blogs.oracle.com/database/post/json-relational-duality-app-dev)
* [JSON Duality View documentation](http://docs.oracle.com)
* [Blog: Key benefits of JSON Relational Duality] (https://blogs.oracle.com/database/post/key-benefits-of-json-relational-duality-experience-it-today-using-oracle-database-23c-free-developer-release)

## Acknowledgements
* **Author** - Kaylien Phan, William Masdon
* **Contributors** - David Start, Ranjan Priyadarshi
* **Last Updated By/Date** - Kaylien Phan, Database Product Management, April 2023
