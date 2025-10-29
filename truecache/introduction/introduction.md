# Introduction

## About This Workshop

Run this hands-on workshop to learn how to use True Cache to improve scalability by offloading queries and reducing the number of requests and connections to the primary database. This workshop is based on a compute instance (an online transaction processing application) connected to a primary database configured with True Cache. The demo application is a Java program using the 23ai JDBC driver. Its simulates a high number of transactions for the primary database and how off loading the read only queries to True Cache helps in application performance.

### About Oracle True Cache

Oracle Database True Cache is an in-memory, consistent, and automatically managed SQL and key-value (object) cache. True Cache is conceptually a disk less Active Data Guard (ADG). Many large scale web applications faces performance issues when a database becomes the bottleneck. True Cache improves scalability by offloading queries and reducing the number of requests and connections to the primary database.

Why use True Cache?
True Cache can be used to scale a read-mostly application even without partitioning data. When the primary database becomes a bottleneck , True Cache can be used to offload from the primary and scale the workload. Also the data is always consistent and recent within a single query, This is important when there are joins across multiple rows.



*Estimated Workshop Time:* 1 hour 

![True Cache introduction](https://oracle-livelabs.github.io/database/truecache/introduction/images/truecache-intro.png " ")

### Objectives
Run this hands-on workshop to learn the basics of True Cache.

Once you complete your setup, the next lab will cover:

- Creating and loading data to a transaction based schema
- Running a Java based application using JDBC to connect to the database and run different transactions against the primary database first and True Cache after that, to show how True Cache can improve application performance.


### Prerequisites (Optional)

- Familiarity with Oracle Database is required
- Familiarity with Java and JDBC is desirable, but not required
- Some understanding of cloud and database terms is helpful
- Familiarity with Oracle Cloud Infrastructure (OCI) is helpful
- Familiarity with podman/docker is helpful

## Learn More
- [True Cache documentation] (https://docs.oracle.com/en/database/oracle/oracle-database/23/odbtc/overview-oracle-true-cache.html)

## Acknowledgements
* **Authors** - Sambit Panda, Consulting Member of Technical Staff , Vivek Vishwanathan Software Developer, Oracle Database Product Management
* **Contributors** - Pankaj Chandiramani, Shefali Bhargava, Jyoti Verma, Ilam Siva
* **Last Updated By/Date** - Sambit Panda, Consulting Member of Technical Staff, Aug 2025
