# Introduction

## About the DBMS_SEARCH Workshop

This workshop focuses on working with DBMS_SEARCH indexes in Oracle Database 23ai.

### **DBMS_SEARCH**

DBMS\_SEARCH is a new package in Oracle Database 23ai which allows you to create a single index covering multiple schema objects.

Also known as an "ubiquitous search index", you can add sets of tables and views as data sources to such an index, and all the columns in the sources are indexed in a single index. Full-text search is available on text columns (such as VARCHAR2 and CLOB) and range search is available on numeric or date columns.

The DBMS_SEARCH maintains metadata about the indexed objects, but crucially it doesn't duplicate the indexed data (avoiding storage bloat) that can be fetched back from the original source if needed.

Estimated Time: 30 minutes

### Objectives

In this lab, you will:
* Create a DBMS_SEARCH index
* Add some tables to the index as sources
* Explore the indexed data and the stored metadata
* Run queries against the DBMS_SEARCH index, and join back to the original sources

### Prerequisites

In order to do this workshop you need
* An Oracle Database 23ai Free Developer Release Database or one running in a LiveLabs environment
* Some understanding of basic SQL concepts
* Knowledge of SQL/JSON will be an advantage, but is not required

## Learn More

* [Blog: Using JSON documents and don’t know what you’re looking for? 23ai Search Indexes to the rescue] (https://blogs.oracle.com/database/post/23c-search-index)

## Acknowledgements
* **Author** - Roger Ford
* **Contributors** - Alexandra Czarlinska
* **Last Updated By/Date** - Roger Ford, Database Product Management, June 2023
