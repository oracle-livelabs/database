# Introduction

## About this Workshop

As organizations rush to adopt microservices architecture, they often run into problems associated with data consistency as each microservice typically has its own database. In monolithic applications, local transactions were enough as there were no other sources of data that needed to be consistent with the database. An application would start a local transaction, perform some updates, and then commit the local transaction to ensure the application moved from one consistent state to another. Once the application’s state is spread across multiple sources of data, some factors need to be considered. What happens if the updates succeed in one microservice, but fails in another microservice as part of the same request? One solution is to use a distributed transaction that spans across the sources of data used by the microservices involved in a request. To maintain consistency in the state of all microservices participating in a transaction, Oracle Transaction Manager for Microservices (MicroTx) provides a transaction coordination microservice and client libraries.

In this workshop, you will learn how to use MicroTx to maintain data consistency across several microservices by deploying and running a Banking and Trading application. This application contains several microservices and it uses distributed, two-phase commit transaction (XA). You will integrate the MicroTx client libraries with the application. Each microservice also makes updates to an Oracle Database. When you run the application, you will be able to see how MicroTx ensures consistency of transactions across the distributed microservices. You will also integrate MicroTx with the Kubernetes ecosystem by using tools, such as Kiali and Jaeger, to visualize the flow of requests between MicroTx and the microservices.

Estimated Workshop Time: *1 hours 20 minutes*

### Objectives

In this workshop, you will learn how to:

* Provision Oracle Autonomous Database instances and use them as resource managers for microservices.
* Configure the required properties so that MicroTx can connect to the resource manager and microservices.
* Include the MicroTx client libraries in your application to configure your Java application as a transaction initiator service. A transaction initiator service starts and ends a transaction.
* Include the MicroTx client libraries in your application to configure your Java application as a transaction participant. A transaction participant service only joins the transaction. They do not initiate a transaction.
* Run the Banking and Trading application to buy and sell stocks.
* Use tools, such as Kiali and Jaeger, to visualize the flow of requests between MicroTx and the microservices.

### Prerequisites

This lab assumes you have:
- An Oracle Cloud account

Let's begin! If you need to create an Oracle Cloud account, click **Get Started** in the **Contents** menu on the left. Otherwise, if you have an existing account, click **Lab 1**.

## Task: Learn More

* [Oracle® Transaction Manager for Microservices Developer Guide](http://docs.oracle.com/en/database/oracle/transaction-manager-for-microservices/22.3/tmmdg/index.html)
* [Oracle® Transaction Manager for Microservices Quick Start Guide](http://docs.oracle.com/en/database/oracle/transaction-manager-for-microservices/22.3/tmmqs/index.html)

## Acknowledgements

* **Author** - Sylaja Kannan, Principal User Assistance Developer
* **Contributors** - Brijesh Kumar Deo
* **Last Updated By/Date** - Sylaja Kannan, June 2023
