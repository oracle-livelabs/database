# Introduction

## About this Workshop

Welcome to the serverless world where provisioning instances is a thing of the past. Oracle NoSQL Database cloud service enables modern application development in minutes.

**Simply connect and go.**

Unchain yourself from rigid data modeling and use Oracle NoSQL’s rich JSON query language to go schema-less. Get an in-depth look at the simplicity of the Oracle NoSQL cloud developer experience and see how Oracle’s own developers make use of this new development paradigm.

Learn how Oracle NoSQL Database can provide a delightful developer experience with features such as predictable single-digit millisecond latencies, multi-region tables, and deep integration with VS Code, IntelliJ, and Eclipse. One can simply use the Oracle Cloud Infrastructure (OCI) Code Editor.

This lab is based on data representing activity from customers using a Video on Demand streaming application. This lab walks you through the steps to create tables in Oracle NoSQL Database Cloud Service (NDCS), load data into the database, and perform basic queries. In addition, it lets you use an application that was developed by the Oracle NoSQL team based on the GraphQL API.

_Estimated Workshop Time:_ 90 Minutes



### About NoSQL database
Modern application developers have many choices when faced with deciding when and how to persist a piece of data. In recent years, NoSQL databases have become increasingly popular and are now seen as one of the necessary tools every application developer must have at their disposal. While 'tried and true' relational databases are great at solving classic application problems like data normalization, strict consistency, and arbitrarily complex queries to access that data, NoSQL databases take a different approach.

Many of the recent applications have been designed to personalize the user experience to the individual, ingest huge volumes of machine generated data, deliver blazingly fast and crisp user interface experiences, and deliver these experiences to large populations of concurrent users. In addition, these applications must always be operational, with zero down-time, and with zero tolerance for failure. The approach taken by Oracle NoSQL Database is to offer extreme availability and exceptionally predictable, single digit millisecond response times to simple queries at scale. The Oracle NoSQL Database Cloud Service is designed from the ground up for high availability, predictably fast responses, resiliency to failure, all while operating at extreme scale. Largely, this is because of Oracle NoSQL Database’s shared nothing, replicated, horizontal scale-out architecture. Also, by using the Oracle NoSQL Database Cloud Service, Oracle manages the scale out, monitoring, tuning, and hardware/software maintenance.

Once you are authenticated with your Oracle Cloud account, you can create a NoSQL table, and specify the throughput and storage requirements for that table. Oracle reserves and manages the resources to meet your requirements, and provisions capacity for you. Capacity is specified using read and write units for throughput and storage units for your on-disk space requirements.

As a developer, you can connect to NDCS and work with NoSQL tables using the NoSQL SDKs available in many languages.


### Objectives

In this workshop you will:
  * Work with a live demo application
  * Set up your environment
  * Create a table with provisioned reads/sec, writes/sec, and
  storage
  * Read and write data to the table
  * Run a sample NoSQL application
  * Explore data using OCI NoSQL Console

### Prerequisites

This workshop assumes you have:
  * An Oracle Free Tier or Paid Account
  * Programming knowledge in java, python or node.js
  * Understanding of query languages

*Note: If you have a **Free Tier**  account, when your Free Trial credits expire your account will be converted to an **Always Free** account. You will not be able to conduct
Free Tier workshops unless the Always Free environment is available.  The Oracle NoSQL Database Cloud Service has **Always Free** access in the Phoenix region only.* 
**[Free Tier FAQ](https://www.oracle.com/cloud/free/faq.html)**

## Learn More

* [Oracle NoSQL Database Cloud Service page](https://www.oracle.com/database/nosql-cloud.html)
* [Oracle NoSQL Database Cloud Service documentation](https://docs.oracle.com/en/cloud/paas/nosql-cloud/index.html)
* [About Cloud Shell](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/cloudshellintro.htm)
* [About Code Editor](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/code_editor_intro.htm)

## Acknowledgements
* **Authors** - Dario Vega, Product Manager, NoSQL Product Management; Michael Brey, Director NoSQL Development
* **Last Updated By/Date** - Dario Vega, Product Manager, NoSQL Product Management, July 2023
