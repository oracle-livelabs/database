# Introduction

MySQL HeatWave is a fully managed database service, powered by the integrated
HeatWave in-memory query accelerator. It’s the only cloud database service that
combines transactions, analytics, and machine learning services into one MySQL
Database, delivering real-time, secure analytics without the complexity, latency,
and cost of ETL duplication.

MySQL HeatWave expands to include MySQL HeatWave Lakehouse, letting users
process and query hundreds of terabytes of data in the object store—in a variety
of file formats, such as CSV, Parquet, and Aurora/Redshift backups. Customers
can query transactional data in MySQL databases, data in various formats in object
storage, or a combination of both using standard MySQL commands. Querying the
data in the database is as fast as querying data in the object store.

To best understand the capabilities and ease of use of our managed service, we
will walk you through a deployment scenario that is uniquely possible with MySQL
HeatWave Lakehouse. The deployment goals are:

1. Walk you through the steps needed to load data from Object Storage to MySQL HeatWave.
2. Show the different ways in which data from Object Storage can be loaded to highlight the flexibility offered by MySQL HeatWave Lakehouse.
3. Highlight that Lakehouse offers you a way to perform analytics on top of their Object Store without moving any data into MySQL InnoDB storage.
4. Highlight that you can perform queries on data from InnoDB, data from InnoDB loaded into HeatWave, and data loaded from Object Storage into HeatWave using standard MySQL syntax.



_Estimated Lab Time:_ 1.5 hours +

### About Product/Technology

**MySQL HeatWave Lakehouse**

MySQL HeatWave enables users to process and query hundreds of terabytes of data in the object store—in a variety of file formats, such as CSV, Parquet, and Aurora/Redshift export files. The data remains in the object store and customer can query it with standard SQL syntax. With this capability, , MySQL HeatWave provides one service for transaction processing, analytics across data warehouses and data lakes, and machine learning—without ETL across cloud services. There is no additional cost for this capability except the cost of storing the data in object store.

MySQL HeatWave Lakehouse is 17X faster than Snowflake and 6X faster than Amazon Redshift. Loading data into MySQL HeatWave Lakehouse is also significantly faster.

**MySQL HeatWave Lakehouse, lets users process and query hundreds of terabytes of data in the object store**
  ![INTRO](./images/mysql_heatwave_lakehouse.png "MySQL HeatWave Lakehouse")

### Objectives

In this lab, you will be guided through the following steps:

- Create MySQL Database for HeatWave DB System
- Add HeatWave cluster to DB System
- Connect to MySQL HeatWave DB
- Load data from OCI Object Store
- Run queries
- Unload one table from HeatWave
- Run Autopilot
- Re-run queries

### Prerequisites

- An Oracle Free Tier, Paid or LiveLabs Cloud Account
- Some Experience with MySQL Shell - [MySQL Site](https://dev.MySQL.com/doc/MySQL-shell/8.0/en/).

You may now **proceed to the next lab**

## Acknowledgements

- **Author** - Perside Foster, MySQL Solution Engineering

- **Contributors** - Abhinav Agarwal, Senior Principal Product Manager, Nick Mader, MySQL Global Channel Enablement & Strategy Manager
- **Last Updated By/Date** - Perside Foster, MySQL Solution Engineering, May 2023
