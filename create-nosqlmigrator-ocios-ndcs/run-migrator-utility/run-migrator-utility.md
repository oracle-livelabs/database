# Run the Oracle NoSQL Database Migrator Utility

## Introduction

The Oracle NoSQL Database Migrator utility acts as a connector between the data source and the sink. This utility exports data from the selected source and imports that data into the sink. You can migrate a single table in a single migration task. 

This lab walks you through the steps to run the Migrator utility and view the copied files.

Estimated Time: X

### Objectives

In this lab you will:

* Run the Migrator utility.
* View migrated data in the Oracle NoSQL Database Cloud Service table.

### Prerequisites

* An Oracle Free Tier, Always Free, Paid or LiveLabs Cloud Account
* Migrator configuration file created in **Lab - Create a Configuration File**.

## Task 1: Run the Oracle NoSQL Database Migrator utility

1. From the Cloud Shell, navigate to the directory where you extracted the NoSQL Database Migrator utility.

    ```
    <copy>cd V1053573-01/nosql-migrator-1.8.0</copy>
    ```

2. Run the runMigrator command by passing the configuration file created in **Lab - Create a Migrator Configuration File**.

    ```
    <copy>
    ./runMigrator --config ./migrator-config.json
    </copy>    
    ```

    The NoSQL Database Migrator utility proceeds with the data migration activity. It copies data from the JSON file in the OCI Object Storage bucket to the Oracle NoSQL Database Cloud Service table.

    You can view the progress and status of migration activity on the CLI:

     ```
    <copy>
    [INFO] creating source from given configuration:
    [INFO] source creation completed
    [INFO] creating sink from given configuration:
    [INFO] sink creation completed
    [INFO] creating migrator pipeline
    [INFO] [cloud sink] : start loading DDLs
    [INFO] [cloud sink] : executing DDL: CREATE TABLE IF NOT EXISTS NDCSuploadRestr (id LONG GENERATED ALWAYS AS IDENTITY (CACHE 5000), document JSON, PRIMARY KEY(SHARD(id))),limits: [100, 60, 1]
    [INFO] [cloud sink] : completed loading DDLs
    [INFO] migration started
    [INFO] [OCI OS source] : start parsing JSON records from object: Delegation/NDCSupload.json
    [INFO] Migration success for source NDCSupload. read=50,written=50,failed=0
    [INFO] Migration is successful for all the sources.
    [INFO] migration completed.
    Records provided by source=50, Records written to sink=50, Records failed=0,Records skipped=0.
    Elapsed time: 0min 0sec 420ms
    Migration completed.
    </copy>
    ```

## Task 2: View migrated data in OCI Object Storage Bucket

1. Minimize the Cloud Shell window.
2. From the Oracle Cloud console's navigation menu, select **Databases** and then select **Tables** under **Oracle NoSQL Database**.
3. Select your compartment. You can see the **NDCSuploadRestr** table.
4. To verify, you can scroll down to **Explore** data. The SQL query to fetch all the table rows is displayed by default.
  Select Execute to view the table rows.
  As you have used the **defaultSchema** option in the migrator configuration file, the table is created with the following schema:

    ```
    <copy>
    CREATE TABLE IF NOT EXISTS NDCSuploadRestr (id LONG GENERATED ALWAYS AS IDENTITY,  document JSON, PRIMARY KEY(id))
    </copy>    
    ```

  If you have used the **useSourceSchema** option to restore the data that you previously migrated, your table will be created with the same schema as your original source table.  
 
Congratulations! You have completed the workshop.

## Acknowledgements
* **Author** - Ramya Umesh, Principal UA Developer, DB OnPrem Tech Svcs & User Assistance
* **Last Updated By/Date** - Ramya Umesh, Principal UA Developer, DB OnPrem Tech Svcs & User Assistance, April 2026
