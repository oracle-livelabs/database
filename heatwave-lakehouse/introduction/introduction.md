# Introduction

## About this Workshop

MySQL HeatWave is a fully managed database service powered by the HeatWave in-memory query accelerator. It’s the only cloud service that combines transactions, real-time analytics across data warehouses and data lakes, and machine learning in one MySQL Database—without the complexity, latency, risks, and cost of ETL duplication. It’s available on OCI, AWS, and Azure.

MySQL HeatWave includes MySQL HeatWave Lakehouse, letting users query hundreds of terabytes of data in object storage—in a variety of file formats, such as CSV, Parquet, and Aurora/Redshift export files from other databases. Customers can query transactional data in MySQL databases, data in various formats in object storage, or a combination of both using standard MySQL commands. Querying data in object storage is as fast as querying data inside the database.

To best understand the capabilities and ease of use of our managed service, we
will walk you through a deployment scenario that is uniquely possible with MySQL
HeatWave Lakehouse. The deployment goals are:

1. Walk you through the steps needed to load data from Object Storage to MySQL HeatWave.
2. Show how MySQL HeatWave Lakehouse enables you to perform analytics on top of your object storage data without having to move data into the MySQL database.
3. Show how to run queries on data coming from MySQL InnoDB storage loaded into HeatWave and data loaded from object storage into HeatWave all using standard MySQL syntax and familiar querying commands.

_Estimated Time:_ 2 hours

Watch the video below for a quick walk-through of the lab.
[Analyze Data at Web Scale in Object Store with MySQL HeatWave Lakehouse](videohub:1_sokyn79m)

### About Product/Technology


MySQL HeatWave enables users to process and query hundreds of terabytes of data in object storage—in a variety of file formats, such as CSV, Parquet, and Aurora/Redshift export files. The data remains in the object store and customers can query and analyse it with standard SQL syntax. With this capability, MySQL HeatWave provides one service for transaction processing, analytics across data warehouses and data lakes, and machine learning—without the need for complex ETL across cloud services.

MySQL HeatWave Lakehouse is 17X faster than Snowflake and 6X faster than Amazon Redshift. Loading data into MySQL HeatWave Lakehouse is also significantly faster.

#### MySQL HeatWave Lakehouse, lets users process and query hundreds of terabytes of data in the object store

  ![lakehouse diagram](./images/mysql-heatwave-lakehouse.png "MySQL HeatWave Lakehouse")

### Objectives

In this lab, you will be guided through the following steps:

- Create MySQL Database for HeatWave DB System with Compartment and VCN
- Add HeatWave cluster to DB System
- Connect to MySQL HeatWave DB
- Run Autopilot
- Load data from OCI Object Store
- Run queries
- Load additional data

### Prerequisites

- An Oracle Free Tier, Paid or LiveLabs Cloud Account
- Some Experience with MySQL Shell - [MySQL Site](https://dev.MySQL.com/doc/MySQL-shell/8.0/en/).

You may now **proceed to the next lab**

## Acknowledgements

- **Author** - Perside Foster, MySQL Solution Engineering

- **Contributors** - Abhinav Agarwal, Senior Principal Product Manager, Nick Mader, MySQL Global Channel Enablement & Strategy Manager
- **Last Updated By/Date** - Perside Foster, MySQL Solution Engineering, May 2023


[def]: videohub:VideoID