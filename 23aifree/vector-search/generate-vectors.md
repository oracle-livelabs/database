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

4. **Create a folder for our vector embedding model in the PDB.**
    ```
    <copy>
    CREATE OR REPLACE DIRECTORY DM_DUMP as 'models';
    </copy>
    ```    

5. **Copy the absolute file path of the PDB's working directory.** Copy the file path returned by the following command.
    ```
    <copy>
    select directory_path from all_directories where directory_name = 'DM_DUMP';
    </copy>
    ```

6. **Return to the container shell. Move the vector model into the PDB's working directory.**
    ```
    <copy>
    exit
    </copy>
    ```
    ```
    <copy>
    cp u01/BERT-TINY.onnx </copy> replace-with-working-directory
    ```

7. **Return to SQL Developer Web.**

8. **Confirm the model appears in the database directory.**
    ```
    <copy>
    SELECT * FROM DBMS_CLOUD.LIST_FILES('DM_DUMP');
    </copy>
    ```
9. **Load the ONNX model into the database.**
    ```
    <copy>
    EXECUTE DBMS_VECTOR.LOAD_ONNX_MODEL('DM_DUMP','BERT-TINY.onnx','doc_model');
    </copy>
    ```
You may now proceed to the next lab.

## Task 2: Generate Vectors From the Data

1. **Transform the product descriptions into vectors.**
    ```
    <copy>
    create table product_vectors as 
    select product_id, product_name, 
    JSON_VALUE(product_details, '$.description') 
    as product_description, TO_VECTOR(VECTOR_EMBEDDING(doc_model USING JSON_VALUE(product_details, '$.description') as data)) as embedding from co.products;
    </copy>
    ```

You may proceed to the next lab.

## Acknowledgements
- **Authors** - Brianna Ambler, Database Product Management
- **Contributors** - Brianna Ambler, Database Product Management
- **Last Updated By/Date** - Dan Williams, August 2024
