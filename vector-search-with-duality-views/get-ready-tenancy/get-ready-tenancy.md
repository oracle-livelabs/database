# Get Ready

## Introduction

Connect to an Autonomous AI Database in your own OCI tenancy and prepare the embedding models used in the labs. You will use Database Actions or another SQL client to run SQL, and your Object Storage bucket to stage the model files.

Estimated Time: 15 minutes

### Objectives

- Sign in to your OCI tenancy and open your Autonomous AI Database.
- Open a SQL worksheet for the database.
- Download both supplied ONNX models, upload them to separate Object Storage folders, and create a PAR URL for each model.

## Task 1: Sign in to OCI and open the database

1. Sign in to [Oracle Cloud Infrastructure](https://cloud.oracle.com/) with your OCI tenancy credentials. Select the region where your Autonomous AI Database is provisioned.

2. Open the OCI navigation menu, select **Oracle AI Database**, and then select **Autonomous AI Database**.

    ![OCI navigation menu with Oracle AI Database and Autonomous AI Database highlighted](images/navigate-to-autonomous-ai-database.png)

3. Select the compartment where you want to work or where your Autonomous AI Database is provisioned.

4. Open the Autonomous AI Database you will use for the labs and confirm that its lifecycle state is **Available**.

5. Select **Database Actions**, and then open **SQL**. If prompted, sign in with the database user credentials you will use for the labs.

    ![Autonomous AI Database details page with the Database Actions menu open and SQL selected](images/open-database-actions.png)

6. Keep the SQL worksheet open in a browser tab.

## Task 2: Prepare both embedding models in Object Storage

1. Download the [multilingual E5-small model archive](https://c4u02.objectstorage.us-ashburn-1.oci.customer-oci.com/p/9DEArLjsgbKXuJgQtSG95E8hMXRFtxgHR8jiHbqz4HgyVYXVnSo0SC_s-zq5CJA3/n/c4u02/b/hosted-files/o/multilingual_e5_small_augmented.zip) to your computer.

    - Extract the archive into a separate local folder, such as `models/e5-small/`, and locate `multilingual_e5_small.onnx`.
    - E5-small produces 384-dimensional vectors.

2. Download the [multilingual E5-base model archive](https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/p/947D91JvPa6rhbK2wU8CcNkuaj3J4Mt6AWHCaRj9vRfDCuwSMDtLAVuLURpNPG2N/n/c4u04/b/livelabsfiles/o/labfiles/multilingual_e5_base_augmented.zip) to your computer.

    - Extract the archive into a different local folder, such as `models/e5-base/`, and locate `multilingual_e5_base.onnx`.
    - E5-base produces 768-dimensional vectors.

    The embedding model shapes semantic-search quality. Models represent meaning differently. More dimensions can capture finer distinctions and may improve results. This workshop provides E5-small and E5-base for a consistent lab experience. You are welcome to bring a compatible ONNX model, using its dimension count when you define the vector column.

3. Open the OCI navigation menu. Select **Storage**, then **Buckets**. Select the compartment in your tenancy where you want to store the models. Create a bucket or open an existing bucket that you have permission to upload files to.

    ![OCI navigation menu with Storage and Buckets highlighted](images/open-object-storage-buckets.png)

4. Upload the extracted `multilingual_e5_small.onnx` file, not the ZIP archive, to a folder such as `models/e5-small/`.

5. Upload the extracted `multilingual_e5_base.onnx` file to a different folder, such as `models/e5-base/`.

6. Open the menu for each uploaded ONNX file and select **Create Pre-Authenticated Request**. Allow **Object Read** access, set an expiry date that gives you enough time to complete the labs, and copy each PAR URL.

    - Copy the E5-small PAR URL. You will use it to load the model in Lab 2.
    - Copy the E5-base PAR URL. You will use it to load the model in Lab 3.

If you want to learn more, see [AI Vector Search Overview](https://docs.oracle.com/en/database/oracle/oracle-database/26/vecse/overview-ai-vector-search.html).

## Task 3: Confirm your SQL workspace

1. In Database Actions, confirm that you can run a simple query in the SQL worksheet.

    ```sql
    SELECT CURRENT_USER FROM dual;
    ```

    Keep this worksheet open. The remaining labs use SQL only.

## Acknowledgements

* **Author** - Gael Palomino
* **Last Updated By/Date** - Gael Palomino, November 2026
