# Introduction

## About This Workshop

Run this hands-on workshop to learn how Oracle True Cache improves scalability by offloading read queries and reducing the number of requests and connections sent to the primary database. The workshop uses a compute instance running an online transaction processing application and a primary database configured with Oracle True Cache. The demo application is a Java program that uses the 26ai JDBC driver to simulate a heavy transaction workload and demonstrate how routing read-only queries to True Cache affects application performance.

### About Oracle True Cache

Oracle Database True Cache is a consistent, automatically managed, read-only replica designed to serve eligible SQL and key-value read workloads. It is conceptually similar to a diskless Active Data Guard replica. Large-scale web applications can experience performance issues when the primary database becomes a bottleneck. True Cache improves scalability by offloading read queries and reducing the number of requests and connections sent to the primary database.

### Why Use True Cache

True Cache can scale a read-heavy application without requiring data partitioning. When the primary database becomes a bottleneck, True Cache offloads read queries and helps the application handle more work. Each eligible query returns a transactionally consistent result. Because True Cache is maintained from the Primary database, availability of the most recent committed change depends on replication/apply state.

*Estimated Workshop Time:* 1 hour 

![True Cache introduction](https://oracle-livelabs.github.io/database/truecache/introduction/images/truecache-intro.png " ")

The diagram shows the application using one logical connection to both databases. Read-only queries can be served by True Cache, while read-write operations continue to use the Primary database; changes are replicated from the Primary database to keep True Cache current.

### Objectives
Run this hands-on workshop to learn the basics of True Cache.

Once you complete your setup, the next lab will cover:

- Reviewing the preloaded data in the TRANSACTIONS schema
- Running a Java-based JDBC application against the Primary database and then True Cache to compare application performance.


### Prerequisites

- Familiarity with Oracle Database is required
- Familiarity with Java and JDBC is desirable, but not required
- Some understanding of cloud and database terms is helpful
- Familiarity with Oracle Cloud Infrastructure (OCI) is helpful
- Familiarity with Podman or Docker is helpful.

## Choose Your Workshop Path

The DBW26 workshop provides two ways to learn the same True Cache workflow:

- **FastLab:** use the visual command center for a quick guided demonstration.
- **Full LiveLab:** use the terminal to run the database, Java, and Podman commands directly.

Both paths use the same LiveLabs remote desktop. For **FastLab**, open Google Chrome inside the remote desktop and navigate to `http://127.0.0.1:8080/`; this opens the local command center. For the **Full LiveLab**, keep this workshop guide open and select **Activities**, then **Terminal**, when the lab asks you to run commands. The detailed labs do not require the FastLab command center.

The outline is:

- **FastLab:** Quick Guided Demo, covering environment health, routing, warmup, performance, availability, and semantic retrieval.
- **Full LiveLab:** Initialize Environment; Prepare and Warm True Cache; Use True Cache through JDBC; Performance Comparison and Lag Observability; Availability and Failover; New Feature: Semantic Cache with Vector Search. Tenancy deployments continue to Clean Up the Stack and Instances; sandbox deployments are managed by the workshop lifecycle and do not include cleanup.

For tenancy-based workshops, Prepare Setup and Environment Setup appear before the detailed labs because they provision the OCI resources. Sandbox workshops start at Initialize Environment because the image is already provisioned.

The workflow covers environment validation, JDBC routing, cache KEEP and warmup, Primary versus True Cache read performance, availability while Primary is stopped, and semantic payment search with Oracle AI Vector Search. The Full LiveLab path uses terminal commands that require sudo access. The stack writes the generated Transactions password to `/home/opc/.truecache_lab_env`; the JDBC and warmup labs pass that credential into the application container without displaying it. Follow each lab's container-session instructions.

## Learn More
- [True Cache documentation](https://docs.oracle.com/en/database/oracle/oracle-database/23/odbtc/overview-oracle-true-cache.html)

## Acknowledgements
* **Authors** - Sambit Panda, Consulting Member of Technical Staff, Oracle Database Product Management
* **Contributors** - Pankaj Chandiramani, Shefali Bhargava, Jyoti Verma, Nithin Thekkupadam Narayanan, Sarvesh Gupta
* **Last Updated By/Date** - Sambit Panda, Consulting Member of Technical Staff, Sep 2026
