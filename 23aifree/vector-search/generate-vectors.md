# Learn the Vector Search Process on Oracle Database 23ai

## Introduction
In this lab, you will quickly configure the Oracle Autonomous Database Free 23ai Docker Container in your remote desktop environment.

**_Estimated Time: 45 minutes_**

### **Objectives**

In this lab, you will:

* Configure your workspace to use Oracle AI Vector Search.
* Load a vector embedding model.
* Vectorize the sample data.
* Leverage your business data with vector search. 

### **Prerequisites**
This lab assumes you have:
- An Oracle account


## Task 1: Prepare the Workspace

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

4. **Grant the DB\_DEVELOPER\_ROLE to dmuser.**
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
6. **Grant READ permissions on the DM_DUMP directory to dmuser.**
    ```
    <copy>
    GRANT READ ON DIRECTORY DM_DUMP TO dmuser;
    </copy>
    ```

7. **Grant WRITE permissions on the DM_DUMP directory to dmuser.**
    ```
    <copy>
    GRANT WRITE ON DIRECTORY DM_DUMP TO dmuser;
    </copy>
    ```

8. **Add quota to tablespace DATA for dmuser.**
    ```
    <copy>
    alter user SALES quota 50m on users;
    </copy>
    ```

9. **Copy the absolute file path of the PDB's working directory.** Copy the file path returned by the following command.
    ```
    <copy>
    select directory_path from all_directories where directory_name = 'DM_DUMP';
    </copy>
    ```

10. **Return to the container shell. Move the vector model into the PDB's working directory.**
    ```
    <copy>
    cp u01/BERT-TINY.onnx <working-directory>
    </copy>
    ```

11. **Return to SQL Developer Web.**

12. **Confirm the model appears in the database directory.**
    ```
    <copy>
    SELECT * FROM DBMS_CLOUD.LIST_FILES('DM_DUMP');
    </copy>
    ```

You may proceed to the next lab.

## Task 2: Import the ONNX Model

1. **Return to the container shell.**

2. **Connect to the ADB as dmuser.**
    ```
    <copy>
    sqlplus dmuser/Welcome_123456@myatp_low
    </copy>
    ```
3. **Load the ONNX model into the database.**
    ```
    <copy>
    EXECUTE DBMS_VECTOR.LOAD_ONNX_MODEL('DM_DUMP','BERT-TINY.onnx','doc_model');
    </copy>
    ```
You may now proceed to the next lab.

## Task 3: Generate Vectors From the Data

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
- **Last Updated By/Date** - Dan Williams, August 2024
