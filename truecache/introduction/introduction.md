# Introduction

## About This Workshop

Run this hands-on workshop to learn how to use True Cache to improve scalability by offloading queries and reducing the number of requests and connections to the primary database. This workshop is based on a compute instance (a online transaction processing application) connected to a Primary database configured with True Cache. The demo application is a Java program using the 23c JDBC driver. Its simulates a high number of transactions for the primary database and how off loading the read only queries to true cache helps in application performance.

## About Oracle True Cache

Oracle Database True Cache is an in-memory, consistent, and automatically managed SQL and key-value (object) cache. True Cache is conceptually a disk less Active Data Guard (ADG). Many large scale Web applications faces performance issues when a a database becomes the bottleneck. Run this hands-on workshop to learn how to use True Cache to improve scalability by offloading queries and reducing the number of requests and connections to the primary database.

Why use True Cache?
True Cache can be used to scale a read-mostly application even without partitioning data. When primary database becomes the bottleneck , True Cache can be used to offload the primary and scale the workload. Also the data is always consistent and recent within a single query, this is important when there are joins across multiple rows.



*Estimated Workshop Time:* 1 hour 

![True Cache introduction](https://oracle-livelabs.github.io/database/truecache/introduction/images/truecache-intro.png " ")

### Objectives
Run this hands-on workshop to learn how to use True Cache to improve scalability by offloading queries and reducing the number of requests and connections to the primary database.

Once you complete your setup, the next lab will cover:

- Creating and loading data to a transaction based schema
- Running a Java based application using jdbc to connect to the database and run different transactions against primary database first and True Cache instance after that, to display how True Cache could improve application performance. 


### Prerequisites (Optional)

- Familiarity with Oracle Database is desirable, but not required
- Familiarity with Java and JDBC is desirable, but not required
- Some understanding of cloud and database terms is helpful
- Familiarity with Oracle Cloud Infrastructure (OCI) is helpful

## Learn More
- [True Cache documentation for internal purposes] (https://docs-uat.us.oracle.com/en/database/oracle/oracle-database/23/odbtc/oracle-true-cache.html#GUID-147CD53B-DEA7-438C-9639-EDC18DAB114B)

## Acknowledgements
* **Authors** - Sambit Panda, Consulting Member of Technical Staff , Vivek Vishwanathan Software Developer, Oracle Database Product Management
* **Contributors** - Pankaj Chandiramani, Shefali Bhargava, Param Saini, Thirumalai Thathachary
* **Last Updated By/Date** - Vivek Vishwanathan ,Software Developer, Oracle Database Product Management, August 2023
