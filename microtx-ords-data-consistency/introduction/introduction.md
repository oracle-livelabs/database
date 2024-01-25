# Introduction

## About this Workshop

As organizations rush to adopt microservices architecture, they often run into problems associated with data consistency as each microservice typically has its own database. In monolithic applications, local transactions were enough as there were no other sources of data that needed to be consistent with the database. An application would start a local transaction, perform some updates, and then commit the local transaction to ensure the application moved from one consistent state to another. Once the application’s state is spread across multiple sources of data, some factors need to be considered. What happens if the updates succeed in one microservice, but fails in another microservice as part of the same request? One solution is to use a distributed transaction that spans across the sources of data used by the microservices involved in a request. To maintain consistency in the state of all microservices participating in a distributed transaction, Oracle Transaction Manager for Microservices (MicroTx) provides a transaction coordination microservice and client libraries.

In this workshop, you will learn how to use MicroTx to maintain data consistency across multiple Oracle REST Data Services (ORDS) applications by deploying and running a Bank Transfer application. You will also integrate MicroTx with the Kubernetes ecosystem by using tools, such as Kiali and Jaeger, to visualize the flow of requests between MicroTx and the microservices.

### About the Bank Transfer Application

The Bank Transfer application is created in PL/SQL and deployed using ORDS in Oracle Database. It demonstrates how you can develop ORDS applications that participate in a distributed transaction while using MicroTx to coordinate the transaction. You can use the Bank Transfer application to withdraw or deposit an amount. Since financial applications that move funds require strong global consistency, the application uses the XA transaction protocol.

The following figure shows the various microservices in the Bank Transfer application. Some microservices connect to a resource manager. Resource managers manage stateful resources such as databases, queuing or messaging systems, and caches.
![Microservices in Bank Transfer application](./images/ords-microtx-bank-transfer-app.png)

* The MicroTx coordinator manages transactions amongst the participant services.

* Teller microservice, a Java microservice, initiates the transactions. It is called an XA transaction initiator service. The user interacts with this microservice to transfer money from Department One to Department Two. It exposes a REST API method to transfer funds. This method defines the transaction boundary and initiates the distributed transaction. When a new request is created, MicroTx starts an XA transaction at the Teller microservice. This microservice also contains the business logic to issue the XA commit and roll back calls.

* Department One and Department Two are ORDS applications. They participate in the transactions, so they are called as XA participant services. Two PDBs, FREEPDB1 and FREEPDB2, are created in a standalone instance of Oracle Database 23c Free to simulate the distributed transaction.  The standalone ORDS APEX service instance, runs on port 8080, and it is configured with two database pools that connect to FREEPDB1 and FREEPDB2. The ORDS service creates database pool for each PDB and exposes the REST endpoint. A single ORDS standalone service has two database connection pools connecting to different PDBs: FREEPDB1 and FREEPDB2. Department One and Department 2 connect to individual PDBs and the ORDS participant services expose three REST APIs, namely withdraw, deposit and get balance. The MicroTx library includes headers that enable the participant services to automatically enlist in the transaction. These microservices expose REST APIs to get the account balance and to withdraw or deposit money from a specified account. They also use resources from resource manager.

The service must meet ACID requirements, so an XA transaction is initiated and both withdraw and deposit are called in the context of this transaction.

When you run the Bank Transfer application, the Teller microservice calls the exposed `transfer` REST API call to initiate the transaction to withdraw an amount from Department 1, an ORDS service, which is connected to FREEPDB1. After the amount is successfully withdrawn, the Teller service receives HTTP 200. Then the Teller calls the `deposit` REST API from Department 2, an ORDS service, which is connected to FREEPDB2. After the amount is successfully deposited, the Teller service receives HTTP 200, and then the Teller commits the transaction. MicroTx coordinates this distributed transaction. Within the XA transaction, all actions such as withdraw and deposit either succeed, or they all are rolled back in case of a failure of any one or more actions.

During a transaction, the microservices also update the associated resource manager to track the change in the amount. When you run the Bank Transfer application, you will see how MicroTx ensures consistency of transactions across the distributed microservices and their resource managers.

Participant microservices must use the MicroTx client libraries which registers callbacks and provides implementation of the callbacks for the resource manager. As shown in the following image, MicroTx communicates with the resource managers to commit or roll back the transaction. MicroTx connects with each resource manager involved in the transaction to prepare, commit, or rollback the transaction. The participant service provides the credentials to the coordinator to access the resource manager.

Estimated Workshop Time: 62 minutes

### Objectives

In this workshop, you will learn how to:

* Configure the required properties so that MicroTx can connect to the resource manager and microservices.
* 
* Run the Bank Transfer application to transfer an amount from one account to another.
* Use tools, such as Kiali and Jaeger, to visualize the flow of requests between MicroTx and the microservices.

### Prerequisites

This lab assumes you have:
- An Oracle Cloud account
- At least 4 OCPUs, 24 GB memory, and 128 GB of bootable storage volume is available in your Oracle Cloud Infrastructure tenancy to run the Bank Transfer application.

Let's begin! If you need to create an Oracle Cloud account, click **Get Started** in the **Contents** menu on the left. Otherwise, if you have an existing account, click **Lab 1**.

## Learn More

* [Oracle® Transaction Manager for Microservices Developer Guide](http://docs.oracle.com/en/database/oracle/transaction-manager-for-microservices/23.4.1/tmmdg/index.html)
* [Oracle® Transaction Manager for Microservices Quick Start Guide](http://docs.oracle.com/en/database/oracle/transaction-manager-for-microservices/23.4.1/tmmqs/index.html)

## Acknowledgements

* **Author** - Sylaja Kannan, Consulting User Assistance Developer
* **Contributors** - Brijesh Kumar Deo and Bharath MC
* **Last Updated By/Date** - Sylaja Kannan, February 2024
