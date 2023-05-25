# Load Parquet data from OCI Object Store

## Introduction

In this final task of loading data we will load data into a table DELIVERY_VENDOR from the Object Store. This time, the data in the object store is in the parquet format.

**Note:** Apache Parquet is an open source, column-oriented data file format designed for efficient data storage and retrieval. It provides efficient data compression and encoding schemes with enhanced performance to handle complex data in bulk. Parquet is available in multiple languages including Java, C++, Python, etc... You can read up more on the Parquet format here.


### Objectives

- Create PAR URL for Parquet file
- Create DELIVERY_VENDOR table

### Prerequisites

- An Oracle Trial or Paid Cloud Account
- Some Experience with MySQL Shell
- Completed Lab 6

## Task 1: Load Parquet format data directly from Object Store

1. Create PAR URL for Parquet file
2. Create DELIVERY_VENDOR table
3. On your SQL prompt, run the following command:

    ```bash
    <copy>CREATE TABLE DELIVERY_VENDOR(
    id INTEGER,
    vendor_name VARCHAR(200)
    ) 
    ENGINE=lakehouse SECONDARY_ENGINE=RAPID 
    ENGINE_ATTRIBUTE='{"file": [{"par": "https://objectstorage.us-ashburn-1.oraclecloud.com/p/FEE4UaxvnmCHkVCbDFcqe38AJIjaxJAiJSheDBt4LgB-ZvZFrfxCeWhHgB1O3eqE/n/mysqlpm/b/lakehouse-livelabs/o/delivery-vendor.pq"}], "dialect": {"format":"parquet"}}';</copy>
    ```

4. Run this command to see the table structure created.

    ```bash
    <copy>desc DELIVERY_VENDOR;</copy>
    ```

5. Now load the data from the Object Store into the ORDERS table.

    ```bash
    <copy>ALTER TABLE DELIVERY_VENDOR SECONDARY_LOAD;</copy>
    ```

6. Once Autoload completes, check the number of rows loaded into the table.

    ```bash
    <copy>select count(*) from DELIVERY_VENDOR;</copy>
    ```
    
7. View a sample of the data in the table.

    ```bash
    <copy>select * from DELIVERY_VENDOR limit 5;</copy>
    ```

You may now **proceed to the next lab**

## Acknowledgements

- **Author** - Perside Foster, MySQL Solution Engineering

- **Contributors** - Abhinav Agarwal, Senior Principal Product Manager, Nick Mader, MySQL Global Channel Enablement & Strategy Manager
- **Last Updated By/Date** - Perside Foster, MySQL Solution Engineering, May 2023