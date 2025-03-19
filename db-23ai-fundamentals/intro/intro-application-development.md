# Introduction

Welcome to the Application Development focus area of the LiveLab. This section covers some of the latest features in Oracle Database 23ai for application development. While this is not an exhaustive list of new features, we've chosen to spotlight six particularly exciting ones: AI Vector Search, JSON Duality Views, Property Graphs, Use Case Domains, Schema Annotations, and JSON Schema. From these labs, you'll gain an understanding of each of the new features and how they can improve your development projects. This section will be updated over time. If you'd like to see a specific feature added, tag me on X (twitter) with your suggestion! [@Killianlynchh](https://twitter.com/Killianlynchh)

[Oracle Database 23ai app dev video](youtube:ksVgnhbxj9w)

## About Oracle Database 23ai

Oracle Database 23ai is the latest long-term support release. Oracle Database 23ai provides best-in-class support for all data types, including the new Vector data type along with relational, JSON, XML, spatial, graph, and more. It offers industry-leading performance, scalability, availability, and security for various workloads.

Users of Oracle Database 19c and 21c can directly upgrade to Oracle Database 23ai.

Check out this lab for free access and a hands-on guide to get some experience:
[Hitchhiker's Guide for Upgrading to Oracle Database 19c & Oracle Database 23ai](https://livelabs.oracle.com/pls/apex/dbpm/r/livelabs/view-workshop?wid=3943)

## About the Application Development New Features Section

This section lets you explore and experiment with some of the new Application Development features in Oracle Database 23ai.

* **Application Development Features:**
    - **AI Vector Search** - In Oracle Database 23ai, we are introducing support for a new vector data type, new indexes to improve the search capabilities of the vector data type, and extensions to the SQL language that make querying vectors alongside business data as simple as possible. These are just a few of the new AI enhancements in Oracle Database 23ai.
    - **JSON Duality Views** - In Oracle Database 23ai, the JSON Duality views allow you to access data stored in the Oracle database as either JSON documents or standard relational tables. This means that applications can access (create, query, modify) the same data as a set of JSON documents or as a set of related tables and columns, and both approaches can be employed at the same time.
    - **Oracle Property Graphs** - The Oracle Database has had a graph server and client for some time. However, in Oracle Database 23ai, support for graphs has been built directly into the database. Additionally, new in 23ai is the ability to build graph applications, manipulate, and query those graphs using SQL/PGQ, the preferred ANSI SQL standard for building graph applications.
    - **Data Use Case Domains** - Oracle Database 23ai introduces Data Use Case Domains. A Data Use Case Domain is a high-level dictionary object that belongs to a schema and encapsulates a set of optional properties and constraints. Data Use Case Domains provide consistent metadata for development, analytics, and ETL applications and tools helping to ensure data consistency and validation throughout the schema. With Data Use case Domain, you define how you intend to use data the centrally and they serve as a way for defining properties and constraints associated with columns. 
    - **Schema Annotations** - Annotations enable you to store and retrieve metadata about database objects. They are free-form text fields applications can use to customize business logic or user interfaces. Annotations are name-value pairs or simply a name.
    - **JSON Schema** - With Oracle Database 23ai, Oracle Database now supports JSON Schema to validate the structure and values of JSON data. The SQL operator IS JSON was enhanced to accept a JSON Schema, and various PL/SQL functions were added to validate JSON and describe database objects such as tables, views, and types as JSON Schema documents.

## Learn More

* [Announcing Oracle Database 23ai : General Availability](https://blogs.oracle.com/database/post/oracle-23ai-now-generally-available) 
* [Oracle Database Features and Licensing](https://apex.oracle.com/database-features/)
* [Oracle Database 23ai : Where to find information](https://blogs.oracle.com/database/post/oracle-database-23ai-where-to-find-more-information)
* [Free sandbox to practice upgrading to 23ai!](https://livelabs.oracle.com/pls/apex/dbpm/r/livelabs/view-workshop?wid=3943)


## Acknowledgements
* **Author** - Killian Lynch, Database Product Management
* **Contributors** - Dom Giles, Distinguished Database Product Manager
* **Last Updated By/Date** - Killian Lynch, April 2024

