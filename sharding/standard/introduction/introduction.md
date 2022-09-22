# Introduction


## About this Workshop

In this workshop you will learn how to deploy Oracle Sharding, work with the sharded database and scale the sharded database. You will also learn how to migrate an application from a non-shard database to a sharded database.

Estimated Lab Time: 4 hours.

### About Oracle Sharding

Oracle Sharding is a scalability and availability feature for custom-designed OLTP applications that enables distribution and replication of data across a pool of discrete Oracle databases that share no hardware or software. The pool of databases is presented to the application as a single logical database. Applications elastically scale (data, transactions and users) to any level, on any platform, simply by adding additional databases (shards) to the pool. Scaling up to 1000 shards is supported in the first release.

Oracle Sharding provides superior run-time performance and simpler life-cycle management compared to home-grown deployments that use a similar approach to scalability. It also provides the advantages of an enterprise DBMS, including: relational schema, SQL, and other programmatic interfaces, support for complex data types, online schema changes, multi-core scalability, advanced security, compression, high-availability, ACID properties, consistent reads, developer agility with JSON, and much more. 

When deploying a sharded configuration, there are two different `GDSCTL` commands, `ADD SHARD` and `CREATE SHARD`, that can be used to add a shard.

Before you start to configure the sharding topology, decide which shard creation method to use because this decision affects some of the configuration steps. In this workshop, We will use the multitenant database for the shard database, so only the `ADD SHARD` command is supported. 

The differences between the `ADD SHARD` and `CREATE SHARD` methods are explained where necessary in the configuration instructions.

- **ADD SHARD Method**

    The `GDSCTL ADD SHARD` command can be used to add a shard to an Oracle Sharding configuration. When using this command, you are responsible for creating the Oracle databases that will become shards during deployment. You can use whatever method you want to create the databases as long as the databases meet the prerequisites for inclusion in an Oracle Sharding configuration.

    Some of the benefits of using the `ADD SHARD` method include:

    - You have complete control over the process used to create the databases.
    - It is straightforward to customize database parameters, naming, and storage locations.
    - Both PDB and non-CDB shards are supported.
    - There is less Oracle software to configure on the shard hosts.
    - There is much less complexity in the deployment process because the shard databases are created before you run any `GDSCTL` commands.



- **CREATE SHARD Method**

    The `GDSCTL CREATE SHARD` command can be used to create a shard in an Oracle Sharding configuration. With `CREATE SHARD`, the shard catalog leverages the Oracle Remote Scheduler Agent to run the Database Configuration Assistant (DBCA) remotely on each shard host to create a database for you. This method does not support PDBs, so any shard databases added must be non-CDBs.

    Some of the benefits of using the `CREATE SHARD` method include:

    - It is easier to create shard databases for non-database administrators.
    - It provides a standard way to provision a new database, when no standard is in current practice.
    - Any database created with `CREATE SHARD` is automatically configured correctly for Oracle Sharding without the need to run SQL statements against the database or otherwise adjust database parameters.
    - You can create standby databases automatically.



### Objectives

In this workshop, you will

- Deploy a shard database with two shards using system managed sharding.
- Migrate application to the shard database
- Working with the shard database.
- Extent the shard database with the third shard.



###  Prerequisites

In order to do this workshop, you need

- An Oracle Free Tier, Always Free, Paid or LiveLabs Cloud Account



## Learn More

- [Oracle Sharded Database](https://docs.oracle.com/en/database/oracle/oracle-database/19/shard/sharding-deployment.html)





## Acknowledgements

* **Author** - Minqiao Wang, DB Product Management, Dec 2020 
* **Last Updated By/Date** - Minqiao Wang, Jun 2021

