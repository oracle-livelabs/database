Here’s the corrected documentation with your updates:

---

# Video Stream - Geo Distributed Catalog Microservices Demo

## Introduction

This lab walks you through a Book management demo application created by the Oracle NoSQL Product Management team. This application consists of several microservices using various Oracle Cloud Infrastructure services. The focus will be on the Catalog microservice, which is illustrated below. This demo application will be deployed in multiple regions, with data stored in Global Active Tables. Oracle NoSQL Global Active Tables provide active-active replication of table data between geographically separated regions, enabling low-latency local access to data regardless of where the data originated.

![component-arch](images/component-arch-todo.png)

_Estimated Time:_ 12 minutes

### Catalog Microservice

### Serverless Logic Tier

We chose this demo because it addresses real-world business problems, many of which are highlighted on the slide below:

![business-problem](images/business-problem-todo.jpg)

This application is running in all Oracle Cloud Infrastructure regions.

The demo application uses a three-tier architecture, providing the core functionality. The features of these services enable you to build a serverless production application that is highly available, scalable, and secure. Your application can operate at large scale without requiring you to manage any servers.

REST has become the standard for designing web APIs, allowing for stateless servers and structured resource access. This demo will show how easy it is to develop the Catalog service using Jakarta EE, Helidon, and Oracle NoSQL Database.

Using managed services offers the following benefits:
* No need to manage operating systems (choose, secure, patch, or manage)
* No servers to size, monitor, or scale out
* No risk of cost from over-provisioning
* No risk to performance from under-provisioning

Here is a diagram of the architecture for the demo:

![arch-diagram](images/arch-diagram.jpg)

* The **API Gateway** service enables you to publish APIs with private endpoints accessible within your network, which you can also expose with public IPs for internet traffic. The endpoints support API validation, request/response transformation, CORS, authentication/authorization, and request limiting.

* **Oracle Cloud Infrastructure Container Engine for Kubernetes (OKE)** is a fully-managed, scalable, and highly available service for deploying containerized applications in the cloud. With OKE, you can specify virtual or managed nodes, which are then provisioned on Oracle Cloud Infrastructure. The live application is deployed using OKE.

    * In this LiveLab, we use **Container Instances** instead of full Kubernetes orchestration, as it sets up faster. OCI Container Instances provide serverless compute optimized for container workloads, without the need for an orchestration platform. Use cases include APIs, web applications, CI/CD build jobs, automation, data/media processing, and development/test environments.

* **Oracle NoSQL Database Cloud Service** is a serverless database cloud service designed for predictable, single-digit millisecond latency responses to simple queries. It allows developers to focus on application development rather than setting up cluster servers or performing system monitoring, tuning, diagnosing, and scaling.

These services enable you to build a highly available, scalable, and secure serverless application. By leveraging this architecture, you avoid managing any servers directly.

### Objectives

* Explore the Book management - Catalog service

### Prerequisites

* Internet connection

## Task 1: The "Streaming" Challenge

This application originated from an internal Oracle team working with the NoSQL team to deliver a high-value service.

Oracle NoSQL was chosen for its suitability for this use case. Key goals of the application include:

* Predictable low latency
* Scalability for large user bases
* High availability
* Auto-expiry of data

## Task 2: Explore Data Using REST Queries

In this task, we will explore the API and highlight the advantages of using REST.

**Move faster with powerful developer tools**

## Task 7: Key Takeaways

This demo utilizes many Oracle Cloud Infrastructure components:

* The Book management Catalog application runs live in all Oracle Cloud Infrastructure regions
* Oracle Cloud Infrastructure Traffic Management enables Geo-Steering, directing requests to the nearest region
* The application uses the Oracle Cloud Infrastructure API Gateway
* Data is stored in Oracle NoSQL Cloud Service as JSON documents
* Jakarta EE is used for building microservices, providing a clear description of the API data

The benefits to customers are shown in the slide below:

![benefits](images/benefits.png)

You may now **proceed to the next lab.**

## Learn More
* [Architecting Microservices-based Applications](https://docs.oracle.com/en/solutions/learn-architect-microservice/index.html)
* [Speed Matters! Why Choosing the Right Database is Critical for Best Customer Experience?](https://blogs.oracle.com/nosql/post/speed-matters-why-choosing-the-right-database-is-critical-for-best-customer-experience)
* [Security, Identity, and Compliance](https://www.oracle.com/security/)
* [Application Development](https://www.oracle.com/application-development/)
* [Oracle NoSQL Database Cloud Service](https://www.oracle.com/database/nosql-cloud.html)
* [API Gateway](https://www.oracle.com/cloud/cloud-native/api-management/)
* [Container Engine for Kubernetes (OKE)](https://www.oracle.com/cloud/cloud-native/container-engine-kubernetes/)
* [Container Instances](https://www.oracle.com/cloud/cloud-native/container-instances/)
* [AI Services](https://www.oracle.com/artificial-intelligence/ai-services/)
* [Media Streams](https://www.oracle.com/cloud/media-streams/)

## Acknowledgements
* **Authors** - Dario Vega, Product Manager, NoSQL Product Management; Michael Brey, Director NoSQL Development; Otavio Santana, Award-winning Software Engineer and Architect
