# Introduction

## About this Workshop

Oracle Text is a standard component of the database that allows you to do fast, full-text searching in textual data in Oracle Database. It would, for example, let you find mis-spelled words in an address field or get a list of Microsoft Word documents containing a particular phrase.

While superficially it is similar to an indexed version of the LIKE operator, there are many differences.

Oracle Text creates **word-based** indexes on textual content in the database. That content can range from a few words in a VARCHAR2 column to multi-chapter PDF documents stored in a BLOB column (or even externally on a file system or at a URL or on Cloud storage).

Oracle Text is a standard feature of all versions of Oracle Database, on cloud, on premise, and all variations from XE to Enterprise Edition.

This workshop is an introduction to Oracle Text indexes, and is designed to walk you through the basics of creating a text index, performing text queries, and maintaining text indexes. You can run the steps listed here in an on-premise database but the workshop assumes you are running in a cloud environment.

Later workshops will explore the more advanced capabilities of the Oracle Text.

## Workshop Scenario

We're going to create a simple table called "user_data" with customer information. That includes a number column for record ID, a VARCHAR2 column for the customer name, a number column for order amount and a VARCHAR2 column for any notes that the sales rep took.

We'll populate that table, and then create a Text index on the note column.

We'll then work through various types of queries using the Oracle Text CONTAINS operator. We'll also show some mixed queries with full-text search on the note column with an additional filter on other relational columns.

Finally, we'll look at how to SYNC and OPTIMIZE Oracle Text indexes.

## Prerequisites

Oracle Text is a SQL-level toolkit. This workshop assumes you have:

* Some familiarity with basic SQL concepts
* An Oracle Cloud account

You may now proceed to the next lab.

## Learn More

* [Oracle Text Homepage](https://www-sites.oracle.com/database/technologies/appdev/oracletext.html)

## Acknowledgements

* **Author** - Roger Ford, Principal Product Manager
- **Contributors** - James Zheng
* **Last Updated By/Date** - Roger Ford, March 2022
