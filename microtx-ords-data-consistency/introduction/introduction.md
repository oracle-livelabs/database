# Introduction

## About this Workshop

As organizations rush to adopt microservices architecture, they often run into problems associated with data consistency as each microservice typically has its own database. In monolithic applications, local transactions were enough as there were no other sources of data that needed to be consistent with the database. An application would start a local transaction, perform some updates, and then commit the local transaction to ensure the application moved from one consistent state to another. Once the application’s state is spread across multiple sources of data, some factors need to be considered. What happens if the updates succeed in one microservice, but fails in another microservice as part of the same request? One solution is to use a distributed transaction that spans across the sources of data used by the microservices involved in a request. To maintain consistency in the state of all microservices participating in a distributed transaction, Oracle Transaction Manager for Microservices (MicroTx) provides a transaction coordination microservice and client libraries.

In this workshop, you will learn how to use MicroTx to maintain data consistency across multiple Oracle REST Data Services (ORDS) applications by deploying and running a Bank Transfer application. You will also integrate MicroTx with the Kubernetes ecosystem by using tools, such as Kiali and Jaeger, to visualize the flow of requests between MicroTx and the microservices.

Estimated Workshop Time: 60 minutes

### Objectives

In this workshop, you will learn how to:

* Set up various microservices. A Java service, Teller, is the transaction initiator application. The ORDS instances, Department 1 and Department 2 participate in the service. MicroTx is connected to all the resource managers and microservices so that it can coordinate the transaction.
* Run the Bank Transfer application to transfer an amount from one account to another.
* Use tools, such as Kiali and Jaeger, to visualize the flow of requests between MicroTx and the microservices.

### Prerequisites

This lab assumes you have:

* An Oracle Cloud account

* At least 4 OCPUs, 24 GB memory, and 128 GB of bootable storage volume is available in your Oracle Cloud Infrastructure tenancy to run the Bank Transfer application.

Let's begin! If you need to create an Oracle Cloud account, click **Get Started** in the **Contents** menu on the left. Otherwise, if you have an existing account, click **Lab 1**.

## Learn More

* [Oracle® Transaction Manager for Microservices Developer Guide](https://docs.oracle.com/pls/topic/lookup?ctx=microtx-latest&id=TMMDG)
* [Oracle® Transaction Manager for Microservices Quick Start Guide](https://docs.oracle.com/pls/topic/lookup?ctx=microtx-latest&id=TMMQS)

## Acknowledgements

* **Author** - Sylaja Kannan, Consulting User Assistance Developer
* **Contributors** - Brijesh Kumar Deo and Bharath MC
* **Last Updated By/Date** - Sylaja Kannan, February 2024
