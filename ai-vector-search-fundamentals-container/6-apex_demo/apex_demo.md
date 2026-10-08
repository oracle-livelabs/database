# Use Container-Generated Vectors in APEX

## Introduction

The SQL Worksheet labs separated inference from search: Private AI Services Container generated the vectors, and Autonomous AI Database Serverless searched them. An APEX application can use the same pattern without moving the relational and vector queries out of the database.

This lab explores a National Parks image-search application. APEX accepts either text or an uploaded image, calls a database function that generates the appropriate CLIP vector through the container, and uses the returned vector in SQL against `PARK_IMAGES_BLOB`.

Estimated Time: 15 minutes

### Objectives

In this lab, you will:

* Search park images with text
* Search park images with an uploaded image
* Review how the application calls the container
* See how one SQL query can reuse either type of query vector

### Prerequisites

This lab assumes you have:

* Completed the Image Search lab
* Access to the National Parks APEX application URL
* A populated `PARK_IMAGES_BLOB` table

## Task 1: Open the Application

<if type="sandbox">

1. Open **View Login Info** on the workshop page and select the **APEX Demo** URL.

</if>

<if type="tenancy">

1. Open the Autonomous AI Database Serverless details page, select **Tool configuration**, and copy the APEX public access URL.

2. Replace the path after `/ords/` with:

    ```text
    <copy>
    r/nationalparks/nationalparks108/image-search
    </copy>
    ```

</if>

The application opens on the National Parks image-search page.

![National Parks image-search application](images/container-apex-initial.png " ")

## Task 2: Search with Text

1. Enter `Civil War` in the text-search field and select **Search Text**.

    ![Civil War entered in the APEX text-search field](images/container-apex-text-entry.png " ")

2. Review the ten closest image results.

    ![National Parks text search results for Civil War](images/container-apex-text-search.png " ")

3. Try another phrase such as `arches`, `waterfall`, or `rock climbing`.

For a text search, the application calls `clip-vit-base-patch32-txt`. The returned 512-dimensional vector is compatible with the vectors generated from the stored image BLOBs.

## Task 3: Search with an Image

1. Download the [rock-climbing sample image](images/rock-climber-upload.jpg), select **Upload image for search**, and choose the downloaded image.

    The optimized JPEG is small enough for the APEX upload and embedding workflow while preserving the visual content needed for the search.

    ![Rock-climbing sample selected for image search](images/container-apex-image-selected.png " ")

2. Select **Search Image**.

3. Review the visually similar results.

    ![Visually similar climbing images returned by APEX](images/container-apex-image-results.png " ")

APEX temporarily stores the upload, converts it to a BLOB, and sends the bytes to `clip-vit-base-patch32-img`. The uploaded image does not need to be hosted on a public URL.

## Task 4: Review the Container Calls

The application uses two schema functions so that page processing does not need to duplicate the provider JSON. The text function follows this pattern:

1. Review the text-vector function.

    ```sql
    <copy>
    CREATE OR REPLACE FUNCTION clip_text_model(
      p_text IN CLOB
    ) RETURN VECTOR
    IS
      l_endpoint VARCHAR2(1000);
    BEGIN
      SELECT config_value
      INTO l_endpoint
      FROM private_ai_config
      WHERE config_name = 'HTTP_ENDPOINT';

      RETURN DBMS_VECTOR.UTL_TO_EMBEDDING(
        p_text,
        JSON_OBJECT(
          'provider' VALUE 'privateai',
          'credential_name' VALUE NULL,
          'url' VALUE l_endpoint || '/v1/embeddings',
          'host' VALUE 'local',
          'model' VALUE 'clip-vit-base-patch32-txt'
          RETURNING JSON
        )
      );
    END;
    /
    </copy>
    ```

2. Review the image-vector function.

    ```sql
    <copy>
    CREATE OR REPLACE FUNCTION clip_image_model(
      p_base64_image IN CLOB
    ) RETURN VECTOR
    IS
      l_blob     BLOB;
      l_endpoint VARCHAR2(1000);
    BEGIN
      l_blob := APEX_WEB_SERVICE.CLOBBASE642BLOB(p_base64_image);

      SELECT config_value
      INTO l_endpoint
      FROM private_ai_config
      WHERE config_name = 'HTTP_ENDPOINT';

      RETURN DBMS_VECTOR.UTL_TO_EMBEDDING(
        l_blob,
        'image',
        JSON_OBJECT(
          'provider' VALUE 'privateai',
          'credential_name' VALUE NULL,
          'url' VALUE l_endpoint || '/v1/embeddings',
          'host' VALUE 'local',
          'model' VALUE 'clip-vit-base-patch32-img'
          RETURNING JSON
        )
      );
    END;
    /
    </copy>
    ```

The APEX page computes one search vector with the appropriate function and stores it in page state. The result query then compares that vector with `PARK_IMAGES_BLOB.IMAGE_VECTOR`. This keeps the remote model call outside the row-by-row similarity calculation.

## Learn More

* [Oracle APEX Documentation](https://docs.oracle.com/en/database/oracle/apex/)
* [Oracle AI Vector Search User's Guide](https://docs.oracle.com/en/database/oracle/oracle-database/26/vecse/index.html)
* [Oracle Private AI Services Container User's Guide](https://docs.oracle.com/en/database/oracle/oracle-database/26/prvai/)

## Acknowledgements

* **Authors** - Andy Rivenes and Markus Kissling, Product Managers, AI Vector Search
* **Contributors** - David Start
* **Last Updated By/Date** - David Start, September 2026
