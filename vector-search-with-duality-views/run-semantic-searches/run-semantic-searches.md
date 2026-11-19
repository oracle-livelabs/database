# Lab 2: Run Semantic Search with SQL

## Introduction

Generate an embedding for a natural-language question and compare it with the stored movie-summary vectors. Semantic search can return a related movie even when its JSON document does not contain the exact query words.

Estimated Time: 20 minutes

### Objectives

- Load the multilingual E5-small ONNX model from Object Storage.
- Generate embeddings for movie summaries and query text.
- Create an HNSW vector index over the populated embeddings.
- Run a nearest-neighbor search with SQL.
- Combine semantic search with metadata filters and keyword search.

## Task 1: Load the ONNX model

1. Use the PAR URL from Get Ready to load `MULTILINGUAL_E5_SMALL` with `DBMS_VECTOR.LOAD_ONNX_MODEL_CLOUD`.

    ```sql
    BEGIN
      DBMS_VECTOR.LOAD_ONNX_MODEL_CLOUD(
        model_name => 'MULTILINGUAL_E5_SMALL',
        credential => NULL,
        uri        => '<multilingual-e5-small-onnx-model-url>'
      );
    END;
    /
    ```

    Replace `<multilingual-e5-small-onnx-model-url>` with the Object Storage PAR URL for the extracted `.onnx` file. The loaded model generates 384-dimensional vectors.

2. Check the output dimension from the loaded model before you populate the table.

    ```sql
    SELECT VECTOR_DIMS(
             VECTOR_EMBEDDING(
               MULTILINGUAL_E5_SMALL
               USING 'dimension check' AS data
             )
           ) AS model_dimensions
    FROM dual;
    ```

    Confirm that the model returns `384`, which matches the `embedding_e5_small VECTOR(384, FLOAT32)` column created in Lab 1.

## Task 2: Populate and index movie-summary embeddings

1. Generate an embedding from each movie summary and store it in the empty vector column.

    ```sql
    UPDATE movies
    SET embedding_e5_small =
        VECTOR_EMBEDDING(
            MULTILINGUAL_E5_SMALL
            USING JSON_VALUE(data, '$.summary') AS data
        );

    COMMIT;
    ```

    `DATA` remains the original JSON document and is not rewritten by this update. The embedding is stored outside the document in the relational `EMBEDDING_E5_SMALL` `VECTOR` column, so search metadata can evolve independently from the application JSON. In Lab 3, you will add `EMBEDDING_E5_BASE` as a second relational vector column over the same movie rows, with its own dimensions and index, without duplicating or re-ingesting the documents.

2. Verify the number of generated vectors match the number of document rows.

    ```sql
    SELECT COUNT(*) AS embedded_movies
    FROM movies
    WHERE embedding_e5_small IS NOT NULL;
    ```

3. See how the dimensions of vectors in `EMBEDDING_E5_SMALL` match the embedding model's output dimensions.

    ```sql
    SELECT VECTOR_DIMS(m.embedding_e5_small) AS populated_dimensions
    FROM movies m
    WHERE m.embedding_e5_small IS NOT NULL
    FETCH FIRST 1 ROW ONLY;
    ```

    Confirm that `populated_dimensions` returns `384`, matching the model dimension you verified in Task 1.

4. Create an HNSW vector index over the populated E5-small embeddings.

    ```sql
    CREATE VECTOR INDEX summary_vec_idx
    ON movies (embedding_e5_small)
    ORGANIZATION INMEMORY NEIGHBOR GRAPH
    DISTANCE COSINE
    WITH TARGET ACCURACY 95;
    ```

    The index is built from the embeddings you have generated and committed. It indexes the relational `EMBEDDING_E5_SMALL` column while the original JSON documents in `DATA` remain unchanged. Task 3 uses the same `COSINE` distance metric to search these vectors.

## Task 3: Run a nearest-neighbor search

1. Generate an embedding for a natural-language movie request and order rows by vector distance.

    ```sql
    SELECT JSON_VALUE(m.data, '$.title'
                      RETURNING VARCHAR2(200)) AS title,
           JSON_VALUE(m.data, '$.year'
                      RETURNING NUMBER) AS year,
           JSON_QUERY(m.data, '$.genre'
                      RETURNING VARCHAR2(1000)) AS genre,
           JSON_VALUE(m.data, '$.main_subject'
                      RETURNING VARCHAR2(200) NULL ON ERROR) AS main_subject
    FROM movies m
    ORDER BY VECTOR_DISTANCE(
               m.embedding_e5_small,
               VECTOR_EMBEDDING(
                 MULTILINGUAL_E5_SMALL
                 USING 'a team of heroes working together to protect others' AS data
               ),
               COSINE
             )
    FETCH FIRST 5 ROWS ONLY
    WITH TARGET ACCURACY 90;
    ```

    Sample output:

    ```json
    {"title":"Saving Private Ryan","year":1998,"genre":["War","Drama","Action"],"main_subject":"Invasion of Normandy"}
    {"title":"Avengers: Infinity War","year":2018,"genre":["Action","Sci-Fi","Adventure"],"main_subject":"genocide"}
    {"title":"Avengers: Endgame","year":2019,"genre":["Action","Adventure"],"main_subject":null}
    {"title":"Suicide Squad","year":2016,"genre":["Sci-Fi","Action","Adventure","Crime","Fantasy"],"main_subject":null}
    {"title":"The Avengers","year":2012,"genre":["Action","Sci-Fi","Adventure"],"main_subject":"alien invasion"}
    ```

    This query returns the five closest movie documents using semantic similarity. Compare the results with the keyword search from Lab 1.

## Task 4: Combine semantic search with filters

1. Add metadata filters to the semantic search. This query finds movies about a team of heroes, while restricting the results to Action movies released in 2000 or later.

    ```sql
    SELECT JSON_VALUE(m.data, '$.title'
                      RETURNING VARCHAR2(200)) AS title,
           JSON_VALUE(m.data, '$.year'
                      RETURNING NUMBER) AS year,
           JSON_QUERY(m.data, '$.genre'
                      RETURNING VARCHAR2(1000)) AS genre
    FROM movies m
    WHERE JSON_VALUE(m.data, '$.year' RETURNING NUMBER) >= 2000
      AND JSON_EXISTS(m.data, '$.genre[*]?(@ == "Action")')
    ORDER BY VECTOR_DISTANCE(
               m.embedding_e5_small,
               VECTOR_EMBEDDING(
                 MULTILINGUAL_E5_SMALL
                 USING 'a team of heroes working together to protect others' AS data
               ),
               COSINE
             )
    FETCH FIRST 5 ROWS ONLY
    WITH TARGET ACCURACY 90;
    ```

    The vector search supplies the semantic ranking, while the `WHERE` clause applies structured filters from the movie document.

## Task 5: Combine text and vector results with INTERSECT

1. Return movies that appear in both the title search for `avengers` and the 20 nearest semantic matches.

    `JSON_TEXTCONTAINS` uses the `TITLE_IDX` JSON search index on `MOVIES.DATA`. The vector branch searches the relational `EMBEDDING_E5_SMALL` column using the matching embedding model.

    ```sql
    -- Text results INTERSECT vector results
    WITH text_results AS (
      SELECT JSON_VALUE(data, '$.title' RETURNING VARCHAR2(200)) AS title,
             JSON_VALUE(data, '$.year' RETURNING NUMBER) AS year,
             JSON_QUERY(data, '$.genre' RETURNING VARCHAR2(1000)) AS genre
      FROM movies
      WHERE JSON_TEXTCONTAINS(data, '$.title', 'avengers', 1)
    ),
    vector_results AS (
      SELECT JSON_VALUE(m.data, '$.title' RETURNING VARCHAR2(200)) AS title,
             JSON_VALUE(m.data, '$.year' RETURNING NUMBER) AS year,
             JSON_QUERY(m.data, '$.genre' RETURNING VARCHAR2(1000)) AS genre
      FROM movies m
      ORDER BY VECTOR_DISTANCE(
                 m.embedding_e5_small,
                 VECTOR_EMBEDDING(
                   MULTILINGUAL_E5_SMALL
                   USING 'a team of heroes working together to protect others' AS data
                 ),
                 COSINE
               )
      FETCH FIRST 20 ROWS ONLY
      WITH TARGET ACCURACY 90
    )
    SELECT title, year, genre
    FROM text_results
    INTERSECT
    SELECT title, year, genre
    FROM vector_results
    ORDER BY year, title
    FETCH FIRST 3 ROWS ONLY;
    ```

    `INTERSECT` returns distinct title, year, and genre values found by both searches. The vector branch uses `VECTOR_DISTANCE` only to rank its 20 nearest candidates; the distance is not returned. The final query sorts the shared results by year and title and returns at most three rows.

## Acknowledgements

* **Author** - Gael Palomino
* **Last Updated By/Date** - Gael Palomino, August 2026
