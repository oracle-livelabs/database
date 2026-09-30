# Introduction

## About this Workshop

This workshop introduces Instance Principal in Oracle Cloud Infrastructure (OCI), an authentication method that allows compute instances to make service calls directly to OCI services without needing user credentials. This eliminates the operational overhead of managing API keys or rotating credentials for services running on instances.

In this workshop, you will build a sample HelloWorld application, with your desired SDK, to connect to Oracle NoSQL Database Cloud Service using instance principal authentication and perform basic table level operations.

Estimated workshop time: 1 hour 30 minutes

### About NoSQL Database

Modern application developers have many choices when faced with deciding when and how to persist a piece of data. In recent years, NoSQL databases have become increasingly popular and are now seen as one of the necessary tools in the toolbox that every application developer must have at their disposal. While tried and true relational databases are great at solving classic application problems like data normalization, strictly consistent data, and arbitrarily complex queries to access that data, NoSQL databases take a different approach.

Many of the more recent applications have been designed to personalize the user experience to the individual, ingest huge volumes of machine generated data, deliver blazingly fast, crisp user interface experiences, and deliver these experiences to large populations of concurrent users. In addition, these applications must always be operational, with zero down-time, and with zero tolerance for failure. The approach taken by Oracle NoSQL Database is to provide extreme availability and exceptionally predictable, single digit millisecond response times to simple queries at scale. The Oracle NoSQL Database Cloud Service is designed from the ground up for high availability, predictably fast responses, resiliency to failure, all while operating at extreme scale. Largely, this is due to Oracle NoSQL Database’s shared nothing, replicated, horizontal scale-out architecture and by using the Oracle NoSQL Database Cloud Service, Oracle manages the scale out, monitoring, tuning, and hardware/software maintenance, all while providing your application with predictable behavior.

### Objectives

In this workshop you will:

-   Download an Oracle NoSQL Database SDK
-   Use Instance Principal authentication method to authenticate to Oracle NoSQL Database Cloud Service
-   Create an NDCS table write data to the table and read data from the table
-   Run the sample NoSQL application

### Prerequisites

-   An Oracle Cloud Account

## Task 1: Getting started with the Oracle NoSQL Database Cloud Service

The Oracle NoSQL Database Cloud Service is a server-less, fully managed data store that delivers predictable single digit response times and allows application to scale on demand via provisioning API calls. There are four steps to getting started with the Oracle NoSQL Database Cloud Service.

1.  Download an Oracle NoSQL Database SDK
2.  Connect to the Oracle NoSQL Database Cloud Service
3.  Create an NDCS table 
4.  Write data to the table and read data from the table
5.  Click on the next lab to get started

## Learn More

-   [Getting Started with Oracle NoSQL Database Cloud Service](https://docs.oracle.com/en/cloud/paas/nosql-cloud/dtddt/index.html)

## Acknowledgements

-   **Author** - Aayushi Arora, Database User Assistance Development 
-   **Contributors** - Suresh Rajan, Michael Brey, Ramya Umesh
-   **Last Updated By/Date** - Aayushi Arora, January 2026