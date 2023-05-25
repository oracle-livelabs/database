# Load CSV data from OCI Object Store

## Introduction

There are two ways in which you can specify a location for the folder or file (or files) that constitute the table you want to load into HeatWave. One is by using Resource Principal. It is recommended that you use Resource Principal-based approach for access to data in Object Storage for more sensitive data as this approach is more secure.
The second way is by using Pre-Authenticated Request URLs. For more information on creating PARS, see Using PARs. If you choose to use PAR URLs, we recommend that you use read-only PARs with Lakehouse and that you specify short expiration dates on your PARs. The expiration dates should align with your loading schedule. Since we are using a sample data set, we will make use of PAR URLs in this LiveLab.
We already have several tables available in HeatWave that have been loaded from MySQL InnoDB storage.

We will now load the DELIVERY_ORDERS table from the Object Store. This is a large table with 30 million rows and contains information about the delivery vendor for orders.

### Objectives

- Create PAR Link for the  "delivery_order" files
- Run Autoload to infer the schema and estimate capacity
- Load complete DELIVERY table from Object Store into MySQL HeatWave

### Prerequisites

- An Oracle Trial or Paid Cloud Account
- Some Experience with MySQL Shell
- Completed Lab 5

## Task 1: Create the PAR Link for the "delivery_order" files

1. To create a PAR URL
    - Navigate to **Storage —> Buckets —> lakehouse-files —> order**  folder.
2. Select the first file —> **delivery-orders-1.csv** and click the three vertical dots.
3. Click on **Create Pre-Authenticated Request**
4. The **Object** option will be pre-selected.
5. Keep the other options for **Access Type** unchanged.
6. Click the **Create Pre-Authenticated Request** button.
7. Click the **Copy** icon to copy the PAR URL.
8. Save the generated PAR URL; you will need it in the next task

## Task 2: Connect to your MySQL HeatWave system using Cloud Shell

1. If not already connected then connect to MySQL using the MySQL Shell client tool with the following command:

    ```bash
    <copy>mysqlsh -uadmin -p -h 10.0.1... --sql </copy>
    ```

    ![Connect](./images/mysql-shell-login.png " mysql shell login")

2. List schemas in your heatwave instance

    ```bash
        <copy>show databses;</copy>
    ```

    ![CONNECT](./images/list-schemas-after.png "list schemas after")

3. Change to the mysql\_customer\_orders database

    Enter the following command at the prompt

    ```bash
    <copy>USE mysql_customer_orders;</copy>
    ```

4. TO see a list of the tables available in the mysql\_customer\_orders schema

    Enter the following command at the prompt

    ```bash
    <copy>show tables;</copy>
    ```

    You are now ready to use Autoload to load a table from the object store into MySQL HeatWave

## Task 3: Run Autoload to infer the schema and estimate capacity required for the DELIVERY table in the Object Store

1. Part of the DELIVERY information for orders is contained in the delivery-orders-1.csv file in object store for which we have created a PAR URL in the earlier task. In a later task, we will load the other files for the DELIVER_ORDERS table into MySQL HeatWave. Enter the following commands one by one and hit Enter.


2. This sets the schema we will load table data into. Don’t worry if this schema has not been created. Autopilot will generate the commands for you to create this schema if it doesn’t exist.

    ```bash
    <copy>SET @db_list = '["mysql_customer_orders"]';</copy>
    ```

3. This sets the parameters for the table name we want to load data into and other information about the source file in the object store. Substitute the **PAR URL** below with the one you generated in the previous task:

    ```bash
    <copy>SET @dl_tables = '[{
    "db_name": "mysql_customer_orders",
    "tables": [{
        "table_name": "delivery_orders",
        "dialect": 
           {
           "format": "csv",
           "field_delimiter": "\\t",
           "record_delimiter": "\\n"
           },
        "file": [{"par": **PAR URL**"}]
    }] }]';</copy>
    ```

- It should look like the following example:

    SET @dl_tables = '[{
    "db_name": "mysql_customer_orders",
    "tables": [{
        "table_name": "delivery_orders",
        "dialect": 
        {
        "format": "csv",
        "field_delimiter": "\\t",
        "record_delimiter": "\\n"
        },
        "file": [{"par": "https://objectstorage.us-ashburn-1.oraclecloud.com/p/MAGNmpjq3Ej4wX6LN6KaE3R9AM2_h_fQDhfM5C9SbKXO_Zbe4MdrTvypV5XsyHkS/n/mysqlpm/b/lakehousefiles/o/delivery-orders-1.csv"}]
    }] }]';

4. This command populates all the options needed by Autoload:

    ```bash
    <copy>SET @db_list = '["SET @options = JSON_OBJECT('mode', 'dryrun', 
    'policy', 'disable_unsupported_columns',
    'external_tables', CAST(@dl_tables AS JSON));"]';</copy>
    ```

5. Run Autoload:

    ```bash
    <copy>CALL sys.heatwave_load(@db_list, @options);</copy>
    ```

    a. Once Autoload completes running, its output has several pieces of information:
     Whether the table exists in the schema you have identified.

    b. Auto schema inference determines the number of columns in the table.
    Auto schema sampling samples a small number of rows from the table and determines the number of rows in the table and the size of the table.

    c. Auto provisioning determines how much memory would be needed to load this table into HeatWave and how much time loading this data take.

6. Autoload generates the SQL statements needed to create the table and then load this table data from the Object Store into HeatWave.

    ```bash
    <copy>SELECT log->>"$.sql" AS "Load Script" FROM sys.heatwave_autopilot_report WHERE type = "sql" ORDER BY id;</copy>
    ```

    a. Execute the recomende command - What column names ?

    ```bash
    <copy>CREATE TABLE `mysql_customer_orders`.`delivery_orders`( `col_1` int unsigned NOT NULL, `col_2` bigint unsigned NOT NULL, `col_3` tinyint unsigned NOT NULL, `col_4` varchar(9) NOT NULL COMMENT 'RAPID_COLUMN=ENCODING=VARLEN', `col_5` tinyint unsigned NOT NULL, `col_6` tinyint unsigned NOT NULL, `col_7` tinyint unsigned NOT NULL) ENGINE=lakehouse SECONDARY_ENGINE=RAPID ENGINE_ATTRIBUTE='{"file": [{"par": "https://objectstorage.us-ashburn-1.oraclecloud.com/p/MAGNmpjq3Ej4wX6LN6KaE3R9AM2_h_fQDhfM5C9SbKXO_Zbe4MdrTvypV5XsyHkS/n/mysqlpm/b/lakehousefiles/o/delivery-orders-1.csv"}], "dialect": {"format": "csv", "field_delimiter": "\\t", "record_delimiter": "\\n"}}'; ALTER TABLE `mysql_customer_orders`.`delivery_orders` SECONDARY_LOAD;</copy>
    ```

## Task 4: Load complete DELIVERY table from Object Store into MySQL HeatWave

1. Run this command to see the table structure created.

    ```bash
    <copy>desc delivery_orders;</copy>
    ```

2. Now load the data from the Object Store into the ORDERS table.

    ```bash
    <copy> ALTER TABLE `mysql_customer_orders`.`delivery_orders` SECONDARY_LOAD; </copy>
    ```

3. Once Autoload completes,point to the scheem

    ```bash
    <copy>use mysql_customer_orders</copy>
    ```

4. Check the number of rows loaded into the table.

    ```bash
    <copy>select count(*) from delivery_orders;</copy>
    ```

5. View a sample of the data in the table.

    ```bash
    <copy>select * from delivery_orders limit 5;</copy>
    ```

    a. Join the  with othe table in the schema

    ```bash
    <copy> select o.* ,d.*
        from  orders o
        join delivery_orders d on o.ORDER_ID = d.col_2
        where o.order_id = 93751524; </copy>
    ```

    Your DELIVERY table is now ready to be used in queries with other tables. In the next lab, we will see how to load additional data for the DELIVERY table from the Object Store using different options.

## Task 5:  Load all data for DELIVERY table from Object Store

- The DELIVERY table contains data loaded from one file so far. If new data arrives as more files, we can load those files too. The first option is by specifying a list of the files in the table definition. The second option is by specifying a prefix and have all files with that prefix be source files for the DELIVERY table. The third option is by specifying the entire folder in the Object Store to be the source file for the DELIVERY table.

## Task 6: Load data by specifying a PAR URL for all objects with a prefix

1. First unload the DELIVERY table from HeatWave:

    ```bash
    <copy>ALTER TABLE delivery_orders SECONDARY_UNLOAD;</copy>
    ```

2. From your OCI console, navigate to your bucket in OCI.
3. Select the first file —> delivery-orders-1.csv and click the three vertical dots.
4. Click on ‘Create Pre-Authenticated Request’
5. Click to select the ‘Objects with prefix’ option under ‘Pre0Authentcated Request Target’.
6. Leave the ‘Access Type’ option as-is: ‘Permit object reads on those with the specified prefix’.
7. Click to select the ‘Enable Object Listing’ checkbox.
8. Click the ‘Create Pre-Authenticated Request’ button.
9. Click the ‘Copy’ icon to copy the PAR URL.
10. Save the generated PAR URL; you will need it later.
11. You can test the URL out by pasting it in your browser. It should return output like this:

    Since we have already created the table, we will not run Autopilot again. Instead we will simply go ahead and change the table definition to point it to this new PAR URL as the table source.

12. Run this command to add this PAR URL as a source for the DELIVERY table:

    ```bash
    <copy>ALTER TABLE `mysql_customer_orders`.`delivery_orders` ENGINE_ATTRIBUTE='{"file": [{"par": "https://objectstorage.us-ashburn-1.oraclecloud.com/p/4EayDq3tv-D08oTTPja-2XEYZSQ0v5cG87CFNc31wT724QB5R21C1UXbK0_snbZA/n/mysqlpm/b/lakehousefiles/o/"}], "dialect": {"format": "csv", "field_delimiter": "\\t", "record_delimiter": "\\n"}}';
    </copy>
    ```

13. Now load data into the DELIVERY table:

    ```bash
    <copy>alter table delivery_orders secondary_load;</copy>
    ```

14. View the number of rows in the DELIVERY table:

    ```bash
    <copy>select count(*) from delivery_orders;</copy>
    ```

    The DELIVERY table now has 34 million rows. 

You may now **proceed to the next lab**

## Acknowledgements

- **Author** - Perside Foster, MySQL Solution Engineering

- **Contributors** - Abhinav Agarwal, Senior Principal Product Manager, Nick Mader, MySQL Global Channel Enablement & Strategy Manager
- **Last Updated By/Date** - Perside Foster, MySQL Solution Engineering, May 2023
