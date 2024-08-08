# Perform Vector Search Yourself

## Introduction
In this lab, you will quickly configure the Oracle Autonomous Database Free 23ai Docker Container in your remote desktop environment.

*Estimated Time:* 10 minutes

### Objectives

In this lab, you will:

* Pull, run, and start an Oracle Autonomous Database 23ai Docker image with Podman.
* Gain access to Database Actions, APEX, and more via your container.
* Explore Oracle’s AI Vector Search. 

### Prerequisites
This lab assumes you have:
- An Oracle account


## Task 1: Load Your Vector Embedding Model

1. **Return to the terminal.** Select Activities >> Terminal.

2. **Launch a new shell session in the container.**
    ```
    <copy>
    podman exec -it oracle_adb-free_1 /bin/bash
    </copy>
    ```
    
3. **Connect to the PDB.**
    ```
    <copy>
    sqlplus admin/Welcome_12345@myatp_low
    </copy>
    ```

4. **Grant the DB_DEVELOPER_ROLE to dmuser.**
    ```
    <copy>
    GRANT DB_DEVELOPER_ROLE TO dmuser identified by Welcome_123456;
    </copy>
    ```

5. **Grant CREATE MINING MODEL privilege to dmuser.**
    ```
    <copy>
    GRANT create mining model TO dmuser;
    </copy>
    ```

6. **Create a folder for our vector embedding model in the PDB.**
    ```
    <copy>
    CREATE OR REPLACE DIRECTORY DM_DUMP as 'models';
    </copy>
    ```

7. **Copy the absolute file path of the PDB's working directory.** Copy the file path returned by the following command.
    ```
    <copy>
    select directory_path from all_directories where directory_name = 'DM_DUMP';
    </copy>
    ```

8. **Move the vector model into the PDB's working directory.**
    ```
    <copy>
    cp u01/BERT-TINY.onnx <working-directory>
    </copy>
    ```

9. 



## Task 2: Generate Vectors From the Data

1. **Extract the product descriptions.**
    ```
    <copy>
    create or replace view co.product_descriptions as select product_id, JSON_VALUE(product_details, '$.description') as product_description from co.products;
    </copy>
    ```

2. **Transform the product descriptions into vectors.**
    ```
    <copy>
    create view product_vectors as 
        select product_id, TO_VECTOR(VECTOR_EMBEDDING(doc_model USING product_description as data)) as embedding from co.product_descriptions;
    </copy>
    ```

You may proceed to the next lab.

## Acknowledgements
- **Authors** - Brianna Ambler, Database Product Management
- **Contributors** - Brianna Ambler, Database Product Management
- **Last Updated By/Date** - Brianna Ambler, August 2024
