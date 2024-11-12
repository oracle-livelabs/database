# Introduction

## About this Workshop

Welcome to the serverless world where provisioning instances is a thing of the past.
Oracle NoSQL Database Cloud Service enables modern application development in mere minutes.

**Simply connect and go.**

Unchain yourself from rigid data modeling and leverage Oracle NoSQL’s rich JSON query language to go schema-less. Explore the simplicity of the Oracle NoSQL cloud developer experience and see how Oracle’s developers use this new development paradigm.

Learn how Oracle NoSQL Database provides an optimal developer experience with predictable single-digit millisecond latencies, Global Active Tables, and deep integration with Visual Studio Code and IntelliJ. The Oracle Cloud Infrastructure (OCI) Code Editor is also available for streamlined development.

This lab uses a Book management system as the sample application to walk you through the steps to create tables in Oracle NoSQL Database Cloud Service (NDCS), load data, and perform basic queries. You’ll also make a Java application using Helidon, Jakarta NoSQL, and Jakarta Data, which Eclipse JNoSQL implements.

Finally, enhance your applications with Oracle NoSQL Global Active Tables, whose design motto is "Simplicity Hides Complexity." This feature enables local read and write performance for globally distributed applications, with automatic conflict resolution for data consistency.

_Estimated Workshop Time:_ 90 Minutes

_Estimated Time:_ 4 minutes

### About Oracle NoSQL Database

Modern application developers have many choices when it comes to persisting data. NoSQL databases have become an essential tool, solving modern challenges that require handling high volumes of data, delivering fast response times, and supporting globally distributed users. Oracle NoSQL Database provides exceptional availability and predictable, single-digit millisecond response times, thanks to its horizontally scalable, shared-nothing architecture. The Oracle NoSQL Database Cloud Service further simplifies development by handling scale-out, monitoring, and maintenance.

Once authenticated with Oracle Cloud, you can create NoSQL tables with specified throughput and storage requirements. Oracle manages the provisioning, ensuring resources are available to meet your needs.

Oracle NoSQL SDKs are available in popular programming languages, allowing developers to connect to NDCS and work with NoSQL tables efficiently.

### Objectives

In this workshop, you will:
* Set up your environment
* Create a table with provisioned reads/sec, writes/sec, and GB storage, write data to it, and read data from it
* Develop a NoSQL Application using Java, Helidon, and Eclipse JNoSQL with Jakarta NoSQL and Jakarta Data
* Deploy this application as a **containerized application** using OCI services
* Set up Global Active Table for your application

### Prerequisites

This workshop assumes you have:
* Programming knowledge in Java, Helidon, and Jakarta EE
* Familiarity with query languages

## Task 1: Architecture of the Application

1. Review the architecture information below.

   This application uses a three-tier architecture with components including an API Gateway and OKE for serverless application management. REST has become a standard for designing web APIs, offering a structured, stateless approach for accessing resources, simplifying development.

   In this LiveLab, we’ll develop a Book management system using Java with Helidon and Oracle NoSQL Database.

   Benefits of using managed services include:
    * No operating systems to manage, secure, or patch
    * No servers to size, monitor, or scale out
    * Cost control with minimized over-provisioning risks
    * Optimized performance without under-provisioning risks

   Here is a diagram of the architecture:

   ![arch-diagram](images/arch-diagram.jpg)

    * The **API Gateway** enables private endpoints accessible within your network, supporting validation, CORS, authentication, authorization, and request limiting.

    * **Oracle Cloud Infrastructure Container Engine for Kubernetes (OKE)** allows deploying containerized applications to the cloud, either on virtual or managed nodes in Oracle Cloud Infrastructure. OKE provisions these nodes, enabling reliable deployment and management of cloud-native applications.

      For this lab, **OCI Container Instances** are used for quick, serverless container management, suitable for workloads that don’t require a full orchestration platform.

    * **Oracle NoSQL Database Cloud Service** is designed for operations requiring predictable, low-latency responses to simple queries. This service allows developers to focus on application development, as Oracle manages server clusters, monitoring, tuning, and scaling.

## Task 2: Key takeaways

1. Review the following information.

   This lab is a demo application showcasing various Oracle Cloud Infrastructure (OCI) components.
    * The Book management application is running live in all Oracle Cloud Infrastructure regions
    * Oracle Cloud Infrastructure Traffic Management handles Geo-Steering to route requests to the nearest region
    * Oracle Cloud Infrastructure API Gateway is used for API management
    * Data is stored as JSON documents in Oracle NoSQL Cloud Service
    * Java with Helidon, Jakarta NoSQL, and Jakarta Data provide a clear and understandable description of the data within your API

   These benefits help simplify the development process with Oracle NoSQL Database Cloud Service. We hope this lab demonstrates the ease of integrating with Oracle NoSQL. You may now **proceed to the next lab.**

## Learn More

* [Architecting Microservices-based applications](https://docs.oracle.com/en/solutions/learn-architect-microservice/index.html)
* [Speed Matters! Why Choosing the Right Database is Critical for Best Customer Experience?](https://blogs.oracle.com/nosql/post/speed-matters-why-choosing-the-right-database-is-critical-for-best-customer-experience)
* [Security, Identity, and Compliance](https://www.oracle.com/security/)
* [Application Development](https://www.oracle.com/application-development/)
* [Oracle NoSQL Database Cloud Service](https://www.oracle.com/database/nosql-cloud.html)
* [API Gateway](https://www.oracle.com/cloud/cloud-native/api-management/)
* [Container Engine for Kubernetes (OKE)](https://www.oracle.com/cloud/cloud-native/container-engine-kubernetes/)
* [Container Instance](https://www.oracle.com/cloud/cloud-native/container-instances/)
* [Cloud Shell](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/cloudshellintro.htm)
* [Code Editor](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/code_editor_intro.htm)

## Acknowledgements
* **Authors** - Dario Vega, Product Manager, NoSQL Product Management; Michael Brey, Director NoSQL Development; Otavio Santana, Award-winning Software Engineer and Architect
