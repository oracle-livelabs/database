# Introduction

## About the Think Relational, Stay JSON: Oracle's Duality View Revolution Workshop

This workshop focuses on migrating from JSON Collections to Duality Views using the JSON to Duality Migrator in Oracle Database 23ai. You will learn how to migrate apps from a document to relational model automatically without any application changes.

Watch this quick video to know why JSON Relational Duality is awesome.

[](youtube:Eb_ytQBw2i8)


### **JSON Relational Duality**

JSON Relational Duality is a landmark capability in Oracle Database 23ai providing game-changing flexibility and simplicity for Oracle Database developers. This breakthrough innovation overcomes the historical challenges developers have faced when building applications, using relational or document models.

JSON Relational Duality helps to converge the benefits of both document and relational worlds. Developers now get the flexibility and data access benefits of the JSON document model, plus the storage efficiency and power of the relational model. The new feature enabling this convergence is JSON Relational Duality Views (referred to henceforth as Duality Views).

Key benefits of JSON Relational Duality:

* **Experience extreme flexibility** in building apps using Duality Views. Developers can access the same data relationally or as hierarchical documents based on their use case and are not forced into making compromises because of the limitations of the underlying database. Build document-centric apps on relational data or create SQL apps on documents.
* **Experience simplicity** by retrieving and storing all the data needed for an app in a single database operation. Duality Views provide fully updatable JSON views over data. Apps can read a document, make necessary changes, and write the document back without worrying about underlying data structure, mapping, consistency, or performance tuning.
* **Enable flexibility and simplicity** in building multiple apps on same data. Developers can define multiple Duality Views across overlapping groups of tables. This flexible data modeling makes building multiple apps against the same data easy and efficient.
* **Eliminate the inherent problem of data duplication and data inconsistency** in document databases. Duality Views are fully ACID (atomicity, consistency, isolation, durability) transactions across multiple documents and tables. It eliminates data duplication across documents data, whereas consistency is maintained automatically.
* **Support high concurrency access and updates**. Traditional locks don’t work well for modern apps. A new value-based concurrency control protocol provided with Duality Views supports high concurrency updates. The new protocol also works efficiently for interactive applications since the data is not locked during human thinking time.

### **JSON to Duality Migrator**

The JSON to Duality Migrator is a new tool in Oracle Database 23ai that addresses the challenge of preserving JSON document semantics in relational schemas. By inferring implicit relationships from document collections, it generates updatable duality views that mirror original JSON structures. This method ensures backward compatibility for applications reliant on document APIs while leveraging relational optimization, such as indexing and ACID compliance. The tool supports iterative refinement, allowing developers to adjust inferred schemas post-migration.

The migrator allows you to:

1. **Design** an effective normalized relational schema, derived from an existing set of JSON collections.
2. **Migrate** data from document database to Oracle duality views, while automatically transforming to the target schema.
3. **Lift-and-Shift** applications transparently with minimal to no code changes.

What does the JSON to Duality Migrator provide?

1. Generates DDL scripts to create the relational schema (including tables, indexes, constraints, and sequences)
2. Generates duality views that mirror the shape of the JSON documents in the input collections
3. Automatically normalizes and deduplicates data
4. Optionally allows users to fine-tune and optimize the generated schema

How does the JSON to Duality Migrator work?

1. Determines normalized schema after analyzing data and structure of input JSON collections
2. Uses sophisticated unsupervised machine learning (ML) algorithms to create a normalized relational schema
3. Eliminates duplication by identifying shared data across collections
4. Uses functional dependency analysis to automatically identify primary keys for each entity and foreign keys between the identified entities


### Objectives

In this lab, you will:

* Work with JSON Collections
* Work with Duality Views
* Migrate from JSON Collections to Duality Views using the JSON to Duality Migrator
* Use the JSON to Duality Migrator's hint infrastructure to guide relational schema design

Estimated Time: 50 minutes

### Prerequisites

* Oracle Autonomous Database 23ai provisioned or one running in a LiveLabs environment

You may now **proceed to the next lab**.

## Learn More

* [Blog: Key benefits of JSON Relational Duality](https://blogs.oracle.com/database/post/key-benefits-of-json-relational-duality-experience-it-today-using-oracle-database-23c-free-developer-release)
* [Blog: JSON to Duality Migrator](https://blogs.oracle.com/database/post/jsontoduality-migrator)
* [JSON Relational Duality: The Revolutionary Convergence of Document, Object, and Relational Models](https://blogs.oracle.com/database/post/json-relational-duality-app-dev)
* [Migrating from JSON to Duality](https://docs.oracle.com/en/database/oracle/oracle-database/23/sutil/migrating-from-json-to-duality.html)

## Acknowledgements

* **Author** - Shashank Gugnani
* **Contributors** - Julian Dontcheff
* **Last Updated By/Date** - Shashank Gugnani, August 2025
