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

1. **Return to the terminal, and connect to the database.**
    ```
    <copy>
    podman exec -it oracle_adb-free_1 sqlplus admin/Welcome_12345@myatp_low
    </copy>
    ```

2. **Create a folder for our vector embedding model in the PDB.**
    ```
    <copy>
    CREATE OR REPLACE DIRECTORY DM_DUMP as 'models';
    </copy>
    ```    

3. **Copy the absolute file path of the PDB's working directory.** Copy the file path returned by the following command.
    ```
    <copy>
    select directory_path from all_directories where directory_name = 'DM_DUMP';
    </copy>
    ```

4. **Disconnect from the database. Move the vector model into the PDB's working directory.**
    ```
    <copy>
    exit
    podman exec -it oracle_adb-free_1 cp -r u01/all-MiniLM-L12-v2.onnx </copy> replace-with-working-directory
    </copy>
    ```

5. **Return to SQL Developer Web.**

6. **Confirm the model appears in the database directory.**
    ```
    <copy>
    SELECT * FROM DBMS_CLOUD.LIST_FILES('DM_DUMP');
    </copy>
    ```
7. **Load the ONNX model into the database.**
    ```
    <copy>
    EXECUTE DBMS_VECTOR.LOAD_ONNX_MODEL('DM_DUMP','all-MiniLM-L12-v2.onnx','doc_model');
    </copy>
    ```
You may now proceed to the next lab.

## Task 2: Generate, Store, & Query Vector Data

1. **Transform the product descriptions into vectors.**
    ```
    <copy>
    create table product_vectors as 
    select product_id, product_name, 
    JSON_VALUE(product_details, '$.description') 
    as product_description, TO_VECTOR(VECTOR_EMBEDDING(doc_model USING JSON_VALUE(product_details, '$.description') as data)) as embedding from co.products;

    select * from product_vectors;
    </copy>
    ```

2. Search for product description vectors based on their similarity to the word "professional".
    ```
    <copy>
    select product_name, product_description, vector_distance(embedding, to_vector(vector_embedding(doc_model using 'professional' as data))) as vector_distance
    FROM PRODUCT_VECTORS
    ORDER BY distance
    FETCH EXACT FIRST 10 ROWS ONLY;
    </copy>
    ```

    This is a vast improvement from the empty result set we got from our traditional search! We can see that the similarity search has returned clothing items described with words contextually similar to "professional". 
    

3. Search for product description vectors based on their similarity to the word "slacks".
    ```
    <copy>
    select product_name, PRODUCT_DESCRIPTION, vector_distance(embedding, to_vector(vector_embedding(doc_model using 'slacks' as data))) as vector_distance
    FROM PRODUCT_VECTORS
    ORDER BY distance
    FETCH EXACT FIRST 10 ROWS ONLY;
    </copy>
    ```

    Once again--big improvements! Notice that the model was able to relate slacks to other bottoms, and use the term's professional context to find other formal wear. So, despite there not being a product description containing the word "slacks", viable results are still returned due to their similarity to the query. 

## Task 3: Combine Business Data with Similarity Search

    You may now proceed to the next lab.

## Acknowledgements
- **Authors** - Brianna Ambler, Database Product Management
- **Contributors** - Brianna Ambler, Database Product Management
- **Last Updated By/Date** - Brianna Ambler, August 2024
