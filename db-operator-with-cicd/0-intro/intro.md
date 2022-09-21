# Introduction

## About this Workshop

With the growing Kubernetes adoption, customers, engineers, and DevOps teams have sought ways to manage their cloud resources through automation tools like Kubernetes allowing us to include these resources in development lifecycles and CI/CD pipelines.

The Oracle DB operator for Kubernetes allows users (DBAs, Developers, DevOps, GitOps teams, etc.) **to manage database lifecycles and dynamically do database operations such as provision, clone, and more directly through Kubernetes**. The Oracle DB operator for Kubernetes makes the Oracle Database more accessible through Kubernetes allowing users to focus more on their applications and less on the infrastructure. It also eliminates the dependency on a human operator or administrator for such operations. This lab showcases one example of what you can do with the Oracle DB Operator for Kubernetes (OraOperator) with DevOps.

This workshop will provide the users the knowledge in installing, using, and deploying an Autonomous Database (ADB) with the OraOperator. In the following labs, the users will integrate with Jenkins and provision environments which will consist of an OraOperator-provisioned Single-Instance database (SIDB) whenever they create a branch.

Estimated Workshop Time: 90 minutes

### About Product/Technology

The microservices will be deployed on an Oracle Kubernetes Engine (OKE) cluster which will access the OraOperator-provisioned Oracle Autonomous Transaction Processing database. These microservices consist of a Spring-Boot back-end and a React-frontend.

Jenkins is hosted on Oracle Cloud Infrastructure to centralize build automation. GitHub is used to manage the lab source code which you will need to fork to make changes.

### Objectives

* Learn how to install and use the Oracle DB Operator for Kubernetes
* Learn how to provision an Autonomous Transaction Processing Database with the Operator
* Learn how the OraOperator can provision Single-Instance Databases upon creation of branches on GitHub

### Prerequisites

* An Oracle Cloud Account - Please view this workshop's LiveLabs landing page to see which environments are supported.

## Upcoming Versions
* Leveraging database patch operation in a pipeline
* Introducing Observability
 
You may now **proceed to the next lab.**

## Want to Learn More?

* [Oracle Database Operator for Kubernetes](https://github.com/oracle/oracle-database-operator)
* [Oracle Advanced Queuing](https://docs.oracle.com/en/database/oracle/oracle-database/19/adque/aq-introduction.html)
* [https://developer.oracle.com/databases/](https://developer.oracle.com/databases/)

## Acknowledgements

* **Authors** - Norman Aberin, Developer Advocate
* **Last Updated By/Date** - Norman Aberin, September 2022
