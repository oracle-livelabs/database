# Lab 1: Create JSON and Vector Data, Then Run Text Search

## Introduction

Create the movie search table with a stable identifier, the original JSON movie document, and a separate vector column for semantic metadata. This design lets the application JSON remain unchanged while you add, rebuild, or drop a vector index.

Estimated Time: 20 minutes

### Objectives

- Create the movie table with `id`, JSON `data`, and an embedding vector.
- Load the movie documents and create an Oracle Text index.
- Run a keyword search in SQL.

## Task 1: Import the movie collection

1. Load the movie JSON files into a database collection.

    ```sql
    BEGIN
      DBMS_CLOUD.COPY_COLLECTION(
        collection_name => 'MOVIE_COLLECTION',
        file_uri_list   => 'https://objectstorage.us-ashburn-1.oraclecloud.com/n/c4u04/b/moviestream_landing/o/movie/*.json',
        format          => '{"ignoreblanklines":true}'
      );
    END;
    /
    ```

    `COPY_COLLECTION` creates the collection when it does not already exist, then loads each JSON document from the matching files. In this workshop, `MOVIE_COLLECTION` exposes the imported JSON document in its `DATA` column.

2. Confirm that the collection contains 3800 documents.

    ```sql
    SELECT COUNT(*) AS movie_count
    FROM movie_collection;
    ```

## Task 2: Create the SQL movie table and copy the documents

1. Create the table used by the remaining labs.

    ```sql
    CREATE TABLE movies (
      id         VARCHAR2(255) CONSTRAINT movies_pk PRIMARY KEY,
      data       JSON NOT NULL,
      embedding_e5_small VECTOR(384, FLOAT32)
    );
    ```

    `DATA` keeps the original application document. `EMBEDDING_E5_SMALL` is separate semantic-search metadata. Lab 2 populates this column with the 384-dimensional multilingual E5-small model; if you use another model, change the vector dimension to match it.

2. Copy each MongoDB document identifier and its original JSON into the table. Leave the `embedding_e5_small` column empty for now.

    ```sql
    INSERT INTO movies (id, data)
    SELECT JSON_VALUE(data, '$._id') AS id,
           data
    FROM movie_collection;

    COMMIT;
    ```

    `MOVIES.ID` uses the `_id` value from each JSON document. Lab 2 stores embeddings in a separate relational column, leaving `DATA` unchanged.

3. Verify the copied documents.

    ```sql
    SELECT id,
           JSON_VALUE(data, '$.title') AS title,
           JSON_VALUE(data, '$.year' RETURNING NUMBER) AS year
    FROM movies
    FETCH FIRST 5 ROWS ONLY;
    ```

## Task 3: Create the text index

1. Create a JSON search index for keyword search.

    ```sql
    CREATE SEARCH INDEX title_idx
    ON movies (data)
    FOR JSON;
    ```

    Lab 2 creates the HNSW vector index after populating the movie-summary embeddings.

## Task 4: Run a text search

1. Use the JSON search index to find movie titles that contain `Avengers`.

    ```sql
    SELECT JSON_VALUE(data, '$.title') AS title,
           JSON_VALUE(data, '$.year' RETURNING NUMBER) AS year
    FROM movies
    WHERE JSON_TEXTCONTAINS(data, '$.title', 'Avengers');
    ```

    This is lexical search: it matches the indexed `title` text, not semantic meaning. Lab 2 uses the vector index to search the meaning encoded in movie summaries.

2. Search for movies with either `Avengers` or `Captain` in the title.

    ```sql
    SELECT JSON_VALUE(data, '$.title') AS title,
           JSON_VALUE(data, '$.year' RETURNING NUMBER) AS year
    FROM movies
    WHERE JSON_TEXTCONTAINS(data, '$.title', 'Avengers OR Captain')
    FETCH FIRST 5 ROWS ONLY;
    ```

3. Search for movies that match either of two genre keywords.

    ```sql
    SELECT JSON_VALUE(data, '$.title') AS title,
           JSON_VALUE(data, '$.year' RETURNING NUMBER) AS year,
           JSON_QUERY(data, '$.genre') AS genre
    FROM movies
    WHERE JSON_TEXTCONTAINS(data, '$.genre', 'Action OR Comedy')
    FETCH FIRST 5 ROWS ONLY;
    ```

    `OR` is a match-any operator. This query returns a movie when its `genre` array contains `Action`, `Comedy`, or both.

## Acknowledgements

* **Author** - Gael Palomino
* **Last Updated By/Date** - Gael Palomino, August 2026
