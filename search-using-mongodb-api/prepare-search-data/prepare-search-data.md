# Load and Verify the Search Environment

## Introduction

Oracle Database API for MongoDB maps a MongoDB database to an Oracle schema. It maps a collection to an Oracle table. In this lab, load movie data from a SQL worksheet. Query the same collection through SQL and `mongosh`. Then verify that an in-database ONNX model generates embeddings.

Estimated Time: 20 minutes

### Objectives

In this lab, you will:

- Load the `MOVIES` collection from Oracle Object Storage
- Query the collection through SQL and `mongosh`
- Load and test the `MULTILINGUAL_E5_BASE` ONNX model

### Prerequisites

- The Get Started lab for your environment is complete.
- Keep the SQL worksheet, `mongosh` connection, and model PAR URL available.

## Task 1: Load and query the movie collection with SQL

1. Open the SQL worksheet from the Get Started lab.

2. Run the following block. `COPY_COLLECTION` creates the collection and loads the public movie JSON files:

    ```sql
    BEGIN
      DBMS_CLOUD.COPY_COLLECTION(
        collection_name => 'MOVIES',
        credential_name => NULL,
        file_uri_list   => 'https://objectstorage.us-ashburn-1.oraclecloud.com/n/c4u04/b/moviestream_landing/o/movie/*.json'
      );
    END;
    /
    ```

3. Confirm that the collection contains documents:

    ```sql
    SELECT COUNT(*) AS movie_count
      FROM movies;
    ```

4. Query five movie documents through SQL:

    ```sql
    SELECT JSON_VALUE(data, '$.title') AS title,
           JSON_VALUE(data, '$.year' RETURNING NUMBER NULL ON ERROR) AS year
      FROM movies
     FETCH FIRST 5 ROWS ONLY;
    ```

5. Keep the SQL worksheet open. A nonzero count and five returned movie rows complete the SQL checkpoint.

## Task 2: Query the collection with mongosh

1. Return to the OCI Cloud Shell and MongoDB Shell session that you opened in **Get Started**.

2. If you no longer have an active MongoDB Shell session, repeat the MongoDB Shell installation and connection steps in **Get Started**. Use the completed MongoDB API connection string for the workshop schema.

3. Query five documents from the same `MOVIES` collection:

    ```javascript
    db.MOVIES.find(
      {},
      { _id: 0, title: 1, year: 1 }
    ).limit(5);
    ```

4. Compare the titles with the SQL results. Returned movie documents complete the MongoDB API checkpoint.

## Task 3: Load and test the ONNX model

1. Return to the SQL worksheet.

2. Use the multilingual E5-base ONNX model URL provided with your workshop environment and load the model:

    ```sql
    BEGIN
      DBMS_VECTOR.LOAD_ONNX_MODEL_CLOUD(
        model_name => 'MULTILINGUAL_E5_BASE',
        credential => NULL,
        uri        => '<multilingual-e5-base-onnx-model-url>'
      );
    END;
    /
    ```

3. Generate an embedding and return its dimension count:

    ```sql
    SELECT VECTOR_DIMS(
             VECTOR_EMBEDDING(
               MULTILINGUAL_E5_BASE
               USING 'a team of heroes working together to protect others' AS data
             )
           ) AS embedding_dimensions
      FROM dual;
    ```

4. Confirm that `EMBEDDING_DIMENSIONS` returns `768` for `MULTILINGUAL_E5_BASE`. If you use another model, use its dimension count instead.

5. Return to `mongosh` and run the same dimension query with the MongoDB API `$sql` stage. `$sql` passes Oracle SQL from a MongoDB aggregation to the database. It lets you use SQL features without leaving `mongosh`.

    ```javascript
    db.MOVIES.aggregate({
      $sql: `
        SELECT VECTOR_DIMS(
                 VECTOR_EMBEDDING(
                   MULTILINGUAL_E5_BASE
                   USING 'a team of heroes working together to protect others' AS data
                 )
               ) AS embedding_dimensions
          FROM dual
      `
    });
    ```

6. Confirm that the returned document contains `DATA: 768` for `MULTILINGUAL_E5_BASE`. With another model, this value must match its dimension count.

## Task 4: Confirm the Lab 1 result

1. Confirm that you have all three successful results:

    - SQL returned movie rows from `MOVIES`.
    - `mongosh` returned movie documents from `db.MOVIES`.
    - `VECTOR_EMBEDDING` returned a 768-dimension embedding for `MULTILINGUAL_E5_BASE` (or the dimension count of the model you selected).

2. Continue only after all three checkpoints pass. Lab 2 uses the same collection, MongoDB API connection, and ONNX model.

You are ready to proceed to Lab 2 and generate embeddings for the movie summaries.

## Learn More

- [JSON Collections](https://docs.oracle.com/en/database/oracle/oracle-database/26/adjsn/json-collections.html)
- [Load Collection Data with DBMS_CLOUD](https://docs.oracle.com/en/cloud/paas/autonomous-database/dedicated/adbaa/dbmscloud-for-objects-and-files.html)
- [Load ONNX Models with DBMS_VECTOR](https://docs.oracle.com/en/database/oracle/oracle-database/26/arpls/dbms_vector1.html)

## Acknowledgements

- **Author** - Gael Palomino
- **Last Updated By/Date** - Gael Palomino, August 2026
- **Source** - [Search Examples using Oracle AI Database API for MongoDB](https://blogs.oracle.com/autonomous-ai-database/search-examples-using-oracle-ai-database-api-for-mongodb)
