# Connect to MySQL HeatWave DB System and Load Data into HeatWave Cluster

## Introduction

In this lab, you will connect to the MySQL HeatWave DB System, import data from Amazon S3, and load data into the HeatWave Cluster.

_Estimated Lab Time:_ 10 minutes

### Objectives

In this lab, you will be guided through the following tasks:

- Connect to the MySQL HeatWave DB System.
- Import data from Amazon S3.
- Load data into HeatWave Cluster.

### Prerequisites

- Must complete Lab 1

## Task 1: Connect to the MySQL HeatWave DB System

MySQL HeatWave provides an easy and quick way to import data from Amazon S3 in either MySQL dump file or text file (such as TSV, CSV) format.
To import the sample data, let us connect to the DB System, MyDBSystem, which is now up and running.

The DB system should show up as **Active** state (green). Perform the following tasks:

1. Click the **Workspaces** link.
2. Click the **Connect to MySQL DB Ssytem** button.
3. Select your HeatWave DB System Name.
4. Enter your DB System username and password.
5. Click the **Connect** button.

    ![mysql heatwave login](./images/heatwave-login.png "mysql heatwave login")

## Task 2: Import data from Amazon S3

You will now import sample data from an Amazon S3 bucket, which contains the database, airportdb, in MySQL dump file format.

1. Click the **Data Imports** link.
2. Copy and paste the following to in **S3 URI**.

    ```bash
    <copy>s3://oracle-mysql-heatwave-sample-data-us-east-1/published/airportdb/v1/mysqldump/</copy>
    ```

3. Click the **Import** button.

    ![mysql heatwave import complete](./images/heatwave-import.png "mysql heatwave import complete")

4. The sample data is imported from S3 into the DB System in MySQL HeatWave on AWS. You can view the errors, warnings and info messages related to the import operation.

    ![mysql heatwave import](./images/heatwave-import-complete.png "mysql heatwave import")

## Task 3: Load data into HeatWave Cluster

The imported data is present in the DB System. You will now load the data into the HeatWave Cluster to accelerate query processing. You can select the schemas or tables to load into HeatWave, and get an estimate on the memory and time required to load the data. MySQL HeatWave optimizes the memory usage and load time of the data load operation by predicting the optimal degree of parallelism for the set of tables you have selected to load into HeatWave.

1. Click the **Manage Data in HeatWave** tab.
2. Click the **Load into HeatWave** button.
3. From the MySQL Autopilot dialog, click the **Load Tables** button.

    ![mysql heatwave load](./images/heatwave-load.png "mysql heatwave load")

To provide better visibility into storage and memory usage, the MySQL HeatWave console provides detailed information about the memory size of each table in the HeatWave cluster memory, load status, estimated rows, and so on.

- Final view of the load process:

    ![mysql heatwave load complete](./images/heatwave-load-complete.png "mysql heatwave load complete")

You may now **proceed to the next lab**.

## Learn More

- [MySQL HeatWave on AWS Service Guide](https://dev.mysql.com/doc/heatwave-aws/en/)

- [MySQL Database Documentation](https://dev.mysql.com/)

## Acknowledgements

- **Author** - Perside Foster, MySQL Solution Engineering
- **Contributors** - Mandy Pang, Senior Principal Product Manager, Aijaz Fatima, Product Manager
- **Last Updated By/Date** - Perside Foster, MySQL Solution Engineering, March 2024
