# Introduction

## About this Workshop

Welcome to the serverless world where provisioning instances is a thing of the past.
Oracle NoSQL Database cloud service enables modern application development in mere minutes.

**Simply connect and go.**

Unchain yourself from rigid data modeling and use Oracle NoSQL’s rich JSON query language to go schema-less.  Get an in-depth look at the simplicity of the Oracle NoSQL cloud developer experience and see how
Oracle’s own developers make use of this new development paradigm.

Learn how Oracle NoSQL Database can provide a delightful developer experience with features
such as predictable single-digit millisecond latencies, Global Active Tables, and deep integration
with Visual Studio Code and IntelliJ. One can also simply use the Oracle Cloud Infrastructure (OCI) Code Editor.

This lab is based on the data catalog used by Oracle's MovieStream application; a fictitious online movie-streaming company.  This Oracle home-grown application models what you would see in Netflix, Hulu, Peacock, Disney+ and the many others available.  This live lab walks you through the steps to create tables in Oracle NoSQL Database Cloud Service (NDCS), load data into the database, and perform basic queries. Additionally, you will learn how to create an application using the Oracle NoSQL Database SDK for Spring Data.

Spring Data REST is part of the umbrella Spring Data project and makes it easy to build hypermedia-driven REST web services on top of Spring Data repositories.  Building on top of Spring Data repositories, it analyzes your application’s domain model and exposes hypermedia-driven
HTTP resources for aggregates contained in the model.

Finally, boost your applications with Oracle NoSQL Global Active Tables where the design motto was *Simplicity Hides Complexity*. The Global Active Tables feature is an active/active set of table replicas across your choice of cloud regions, making it possible to achieve local read and write performance of globally distributed applications. Global Active Tables provide businesses with data synchronization and built-in conflict resolution of business application data even when data is written simultaneously to any participating regional table replica.

_Estimated Workshop Time:_ 90 Minutes



### About NoSQL database
Modern application developers have many choices when faced with deciding when and how to persist a piece of data.  In recent years, NoSQL databases have become tremendously popular and are now seen as one of the necessary tools every application developer must have at their disposal. While *'tried and true'* relational databases are great at solving classic application problems like data normalization, strict consistency, and arbitrarily complex queries to access that data, NoSQL databases take a different approach.

Most modern applications targeted at end users have been designed to personalize the user experience to the individual, ingest huge volumes of machine generated data, deliver blazingly fast and crisp user interface experiences, and deliver these experiences to large populations of concurrent users **distributed around the globe**. In addition, these applications must always be operational, with zero down-time, and with zero tolerance for failure. The approach taken by Oracle NoSQL Database is to offer extreme availability and exceptionally predictable, single digit millisecond response times to simple queries at scale. The Oracle NoSQL Database Cloud Service is designed from the ground up for high availability, predictably fast responses, resiliency to failure, all while operating at extreme scale. Largely, this is because of Oracle NoSQL Database’s shared nothing, replicated, horizontal scale-out architecture. Also, by using the Oracle NoSQL Database Cloud Service, Oracle manages the scale out, monitoring, tuning, and hardware/software maintenance: basically everything.

Once you are authenticated with your Oracle Cloud account, you can create a NoSQL table, along with the throughput and storage requirements for that table. Oracle reserves and manages those resources to meet your requirements, and provisions the capacity for you. Capacity is specified using read and write units for throughput and storage units for your on-disk space requirements.

As a developer, you can connect to NDCS and work with NoSQL tables using the NoSQL SDKs available in common developer languages.


### Objectives

In this workshop you will:
  * Work with a live demo application
  * Set up your environment
  * Create a table with provisioned reads/sec, writes/sec, and GB storage and write data to the table and read data from the table
  * Develop a NoSQL Application using Oracle NoSQL Database SDK for Spring Data
  * Deploy this application as a *containerized application* using OCI service
  * Set up Global Active Table for your application

### Prerequisites

This workshop assumes you have:
  * An Oracle Free Tier or Paid Account
  * Programming knowledge in Java and Spring framework
  * Understanding of query languages

*Note: If you have a **Free Tier**  account, when your Free Trial credits expire your account will be converted to an **Always Free** account. You will not be able to conduct this workshop after your account has been converted to an Always Free environment. The Oracle NoSQL Database Cloud Service **Always Free** tenancies are only available in the Phoenix region.*
**[Free Tier FAQ](https://www.oracle.com/cloud/free/faq.html)**

## Learn More

* [Oracle NoSQL Database Cloud Service page](https://www.oracle.com/database/nosql-cloud.html)
* [Oracle NoSQL Database Cloud Service documentation](https://docs.oracle.com/en/cloud/paas/nosql-cloud/index.html)
* [About Cloud Shell](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/cloudshellintro.htm)
* [About Code Editor](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/code_editor_intro.htm)

## Acknowledgements
* **Authors** - Dario Vega, Product Manager, NoSQL Product Management; Michael Brey, Director NoSQL Development
