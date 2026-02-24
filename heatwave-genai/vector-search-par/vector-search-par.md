# Perform Retrieval Augmented Generation 

## Introduction

Using the in-database vector store and retrieval-augmented generation (RAG), you can load and query unstructured documents stored in Object Storage using natural language within the HeatWave ecosystem.

_Estimated Time:_ 30 minutes

### Objectives

In this lab, you will be guided through the following tasks:

- Download HeatWave files.
- Create a bucket and a folder.
- Upload files to the bucket folder.
- Create a Pre-Authenticated Request (PAR) for secure access.
- Set up a vector store.
- Perform retrieval augmented generation (RAG) queries.

### Prerequisites

- Must complete Lab **Use HeatWave in-database LLM**...




## Task 1: Download HeatWave files

Download HeatWave files on which we will perform a vector search.

1. Download the following files and save it in your local computer.

    - https://www.oracle.com/a/ocom/docs/mysql-heatwave-technical-brief.pdf
    - https://www.oracle.com/a/ocom/docs/mysql/mysql-heatwave-on-aws-brief.pdf
    - https://www.oracle.com/a/ocom/docs/mysql/mysql-heatwave-ml-technical-brief.pdf
    - https://www.oracle.com/a/ocom/docs/mysql/mysql-heatwave-lakehouse-technical-brief.pdf

    ![Download files](./images/vector-search-folder.png "Download files")

## Task 2: Create a bucket and a folder

The Object Storage service provides reliable, secure, and scalable object storage. Object Storage uses buckets to organize your files. 

1. From the Oracle Cloud Account, open the **Navigation menu** and click **Storage**. Under **Object Storage & Archive Storage**, click **Buckets**.

    ![Click bucket](./images/1-click-bucket.png "Click bucket")

2. Select the  Cloud Account **Region** then  the  **Compartment**. Ignore the API error, it  will go away after the correct compartment has been selected.

    ![Click Region](./images/41-region-compartment.png "Click Region")    

3. In the selected  compartment, click **Create Bucket**. 

    ![Create bucket](./images/3-create-bucket.png "Create bucket")

4. Enter the **Bucket Name**, and accept the defaults for the rest of the fields.

    ```bash
    <copy>bucket-vector-search</copy>
    ```

5. Click **Create**.

    ![Enter bucket details](./images/3-enter-bucket-details.png "Enter bucket details")

6. Once the bucket is created, click the name of the bucket to open the **Bucket Details** page. 

    ![Created bucket](./images/4-created-bucket.png "Created bucket")

7. Copy the bucket name and **Namespace**, and paste the it somewhere for future reference.

    ![Bucket namespace](./images/35-bucket-namespace.png "Bucket namespace")

8. Under **Objects**, click **Actions**, and then click **Create New Folder**.

    ![Create new folder](./images/31-create-new-folder.png "Create new folder")

9. In the **Create New Folder** page, enter a **Name** of the folder, and note it for future reference.

    ```bash
    <copy>bucket-folder-heatwave</copy>
    ```

    ![Enter new folder details](./images/32-enter-folder-details.png "Enter new folder details")

10. Click **Create**.

## Task 3: Upload files to the bucket folder

1.  In the **Bucket Details** page, under **Objects**, click the bucket folder name.

    ![Click bucket folder](./images/33-click-bucket-folder.png "Click bucket folder")

2.  Click **Upload Objects**.

    ![Click upload](./images/34-click-upload.png "Click upload")

3. Click **Choose Files from your Computer** to display a file selection dialog box.

4. Select the files you had downloaded earlier in Task 1, and click **Upload**.

    ![Upload files](./images/6-upload-files.png "Upload files")

5. Click **Next**, then **Upload Objects**.  When the file statuses shows **Done**, click **Close** to return to the bucket.

    ![Upload files finished](./images/7-upload-files-finished.png "Upload files finished")


## Task 4: Create a Pre-Authenticated Request (PAR)

Pre-authenticated requests provide a way to let HeatWave access your bucket or objects without requiring dynamic groups or IAM policies. This is a simpler and more direct method for granting access.

1. On the Objects tab for your bucket, click on the three dots to the far right of the bucket name.  Click **Create pre-authenicated request**. 

    ![Create Pre-Authenticated Request](./images/8-create-par.png "Create Pre-Authenticated Request")

2. In the **Create Pre-Authenticated Request** dialog box, do the following:
    
    **Name**: Enter a descriptive name for the PAR.
    
    ```bash
    <copy>heatwave-vector-search-par</copy>
    ```
    
    **Pre-Authenticated Request Target**: Select **Bucket** (this allows access to all files within the bucket and its folders).
    
    **Access Type**: Select **Permits object reads** (HeatWave only needs to read the files).
    
    **Enable Object Listing**: **Check this box** (this is required for HeatWave to list and access multiple files in the folder).
    
    **Expiration**: You can choose to increase the **Expiration** date of the Pre-Authenticated Request. Set an appropriate expiration date based on your usage requirements. The default is typically 7 days, but you may want to extend this for longer-term access.
    
    Click **Create Pre-Authenticated Request**. 

    ![Enter Pre-Authenticated Request details](./images/9-par-details.png "Enter Pre-Authenticated Request details")

3. **CRITICAL**: Copy the URL that appears in the **Pre-Authenticated Request Details** dialog box. 

    **Important Notes**:
    - This URL will **only be displayed once** and cannot be retrieved later.
    - Save this URL in a secure location for use in the next task.
    - The URL provides tokenized access to your bucket without requiring additional authentication.
    
    Paste the URL somewhere for future reference, and click **Close**.

    ![Copy Pre-Authenticated Request details](./images/10-copy-par.png "Copy Pre-Authenticated Request details")

    **Example PAR URL**:
    ```
    https://objectstorage.us-ashburn-1.oraclecloud.com/p/abc123def456.../n/your-namespace/b/bucket-vector-search/o/
    ```


## Task 5: Set up a vector store

1. Go to Visual Studio Code, and under **DATABASE CONNECTIONS**, click **Open New Database Connection** icon next to your HeatWave instance to connect to it. 

    ![Connect database](./images/vscode-connection.png "Connect database")

2. Create a new schema and select it.

    ```bash
    <copy>create database genai_db;</copy>
	<copy>use genai_db;</copy>
    ```

    ![Create database](./images/11-create-database.png "Create database")

3. **Important: Verify Your Files Are in the Correct Location**

    Before proceeding, ensure your 4 PDF files are inside the `bucket-folder-heatwave/` folder in Object Storage, not at the bucket root level. The `VECTOR_STORE_LOAD` procedure will process ALL files it finds at the specified path.
    
    - Go to OCI Console → Storage → Buckets → bucket-vector-search-3
    - Click on `bucket-folder-heatwave/` folder
    - Verify all 4 PDF files are inside this folder
    - If files are at the root level, move them into the folder before proceeding

4. Ingest the files from Object Storage using the Pre-Authenticated Request URL, create vector embeddings, and load the vector embeddings into HeatWave:

    ```bash
    <copy>call sys.VECTOR_STORE_LOAD('<PAR-URL>', '{"table_name": "livelab_embedding"}');</copy>
    ```
    Replace the following:

    - **PAR-URL**: The complete Pre-Authenticated Request URL that you copied in Task 4, Step 3. Make sure to include the full URL.
    - **livelab_embedding**: The name you want for the vector store table.
   
    **Important**: If your files are in a folder within the bucket, you may need to append the folder path to the PAR URL:
    ```
    <PAR-URL>bucket-folder-heatwave/
    ```

    **Example**:

    ```bash
    <copy>call sys.VECTOR_STORE_LOAD('https://objectstorage.us-ashburn-1.oraclecloud.com/p/abc123def456.../n/axqzijr6ae84/b/bucket-vector-search/o/bucket-folder-heatwave/', '{"table_name": "livelab_embedding"}');</copy>
    ```

    ![Ingest files from Object Storage](./images/14-ingest-files.png "Ingest files from Object Storage")

    **Note**: The command returns a `task_id` and a `task_status_query`. Copy the `task_id` for checking the status in the next step. Right click on the task_id SQL statement and select `Copy Field Unquoted`


5. Check the task status using the `task_id` returned in the previous step:

    ```bash
    <copy>SELECT mysql_tasks.task_status_brief("<your-task-id>");</copy>
    ```
    
    For example:
    ```bash
    <copy>SELECT mysql_tasks.task_status_brief("9ff44dad-d3ca-11f0-ad82-020017142e41");</copy>
    ```
    
    The status will show:
    - **RUNNING**: Task is in progress (check every 30-60 seconds)
    - **COMPLETED**: Task finished successfully
    - **ERROR**: Task failed (check error message for details)
    
    Example output during processing:
    ```json
    {
      "data": {"tables_to_load": "[{\"table_name\": \"livelab_embedding_pdf\", \"load_progress\": 100.0}]"},
      "status": "RUNNING",
      "message": "Loading in progress...",
      "progress": 60
    }
    ```
    
    Wait until the status shows `"status": "COMPLETED"` and `"progress": 100` before proceeding.
    
    **Note**: Vector embedding generation takes approximately 20-25 minutes depending on file size and HeatWave cluster configuration.

6. Once the task shows COMPLETED status, verify that embeddings are loaded in the vector embeddings table.
    

    ```bash
    <copy>select count(*) from <EmbeddingsTableName>;</copy>
    ```
    For example:  
    - Get a list of tables:
    ```bash
    <copy>SHOW TABLES; </copy>
    ```
    - Get a count of the table ending in "pdf".:
    ```bash
    <copy>select count(*) from livelab_embedding_pdf; </copy>
    ```
    It takes a couple of minutes to create vector embeddings. You should see a numerical value in the output (e.g., 592), which means your embeddings are successfully loaded in the table.

    ![Vector embeddings](./images/15-check-count.png "Vector embeddings")


### Troubleshooting Common Issues

**Error: "No valid data found for processing"**

This error means HeatWave cannot find files at the specified PAR URL location. Check:

1. **Files are in the correct location**: Verify PDFs are inside `bucket-folder-heatwave/` folder, not at bucket root
2. **PAR URL includes folder path**: Ensure your URL ends with `/bucket-folder-heatwave/`
3. **PAR has Object Listing enabled**: This is required for HeatWave to discover files
4. **PAR has not expired**: Check expiration date and create new PAR if needed

**Error: "Table is not loaded in HeatWave"**

This means the task is still processing. Wait for the task status to show "COMPLETED" before querying the table.

**Empty tables (0 count)**

If only `livelab_embedding_pdf` has data and other tables (\_doc, \_html, \_ppt, \_txt) show 0 rows, this is normal - you only uploaded PDF files. HeatWave creates table structures for all supported file types but only populates tables that have corresponding files.

## Task 6: Perform retrieval augmented generation

HeatWave retrieves content from the vector store and provide that as context to the LLM. This process is called as retrieval-augmented generation or RAG. This helps the LLM to produce more relevant and accurate results for your queries.

1. Set the @options session variable to specify the table for retrieving the vector embeddings, and click **Enter**.

    ```bash
    <copy>set @options = JSON_OBJECT("vector_store", JSON_ARRAY("<DBName>.<EmbeddingsTableName>"));</copy>
    ```

    For example:

    ```bash
    <copy>set @options = JSON_OBJECT("vector_store", JSON_ARRAY("genai_db.livelab_embedding_pdf"));</copy>
    ```

2. Set the session @query variable to define your natural language query, and click **Enter**.

    ```bash
    <copy>set @query="<AddYourQuery>";</copy>
    ```
    
    Replace AddYourQuery with your natural language query.

    For example:

    ```bash
    <copy>set @query="What is HeatWave AutoML?";</copy>
    ```

3. Retrieve the augmented prompt, using the ML_RAG routine, and click **Execute the selection or full block on HeatWave and create a new block**.

    ```bash
    <copy>call sys.ML_RAG(@query,@output,@options);</copy>
    ```

    ![Set options](./images/17-set-options.png "Set options")
    
    **Important**: The first RAG query will take 2-5 minutes as HeatWave loads the Large Language Model (LLM) into memory. Subsequent queries will be much faster (10-30 seconds).

4. Print the output:

    ```bash
    <copy>select JSON_PRETTY(@output);</copy>
    ```
    
    Text-based content that is generated by the LLM in response to your query is printed as output. The output generated by RAG is comprised of two parts:

    - The text section contains the text-based content generated by the LLM as a response for your query.

    - The citations section shows the segments and documents it referred to as context.

    ![Vector search results](./images/18-vector-search-output.png "Vector search results")
    

## Additional Example Queries

Now that your RAG system is working, try these additional queries to explore your HeatWave documentation:

```bash
-- Query about Lakehouse capabilities
<copy>set @query="What file formats does HeatWave Lakehouse support?";</copy>
<copy>call sys.ML_RAG(@query,@output,@options);</copy>
<copy>select JSON_PRETTY(@output);</copy>
```

```bash
-- Query about AWS deployment
<copy>set @query="What are the benefits of running HeatWave on AWS?";</copy>
<copy>call sys.ML_RAG(@query,@output,@options);</copy>
<copy>select JSON_PRETTY(@output);</copy>
```

```bash
-- Query about ML capabilities
<copy>set @query="What types of machine learning models can I build with HeatWave AutoML?";</copy>
<copy>call sys.ML_RAG(@query,@output,@options);</copy>
<copy>select JSON_PRETTY(@output);</copy>
```

```bash
-- Query about performance
<copy>set @query="How does HeatWave performance compare to other databases?";</copy>
<copy>call sys.ML_RAG(@query,@output,@options);</copy>
<copy>select JSON_PRETTY(@output);</copy>
```

## Important Notes on Pre-Authenticated Requests

- **Security**: PARs provide time-limited, tokenized access to your Object Storage. Anyone with the PAR URL can access the specified resources until the expiration date.
- **Expiration**: Make sure to set an appropriate expiration date. If the PAR expires, you'll need to create a new one and update your vector store configuration.
- **URL Management**: Store PAR URLs securely. They provide direct access to your data without additional authentication.
- **Revocation**: If needed, you can revoke a PAR before its expiration date from the OCI Console.
- **Scope**: The PAR created in this lab provides read-only access to the entire bucket, which is sufficient for HeatWave vector store operations.

## Learn More

- [HeatWave User Guide](https://dev.mysql.com/doc/heatwave/en/)

- [HeatWave on OCI User Guide](https://docs.oracle.com/en-us/iaas/mysql-database/index.html)

- [MySQL Documentation](https://dev.mysql.com/)

- [Oracle Cloud Infrastructure Pre-Authenticated Requests](https://docs.oracle.com/en-us/iaas/Content/Object/Tasks/usingpreauthenticatedrequests.htm)


## Acknowledgements

- **Author** - Aijaz Fatima, Product Manager
- **Contributors** - Mandy Pang, Senior Principal Product Manager, Aijaz Fatima, Product Manager
- ***Last Updated By/Date** - Perside Lafrance Foster, Open Source Principal Partner Solution Engineer, December 2025
