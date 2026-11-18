# Lab 3: Compare Embedding Models on the Same Movie Data

## Introduction

The original JSON documents do not determine which embedding model you use. You can keep several vector columns and indexes beside the same `DATA` column, then direct each search to the model that best serves the workload. A model with more dimensions can encode finer distinctions, but it is not automatically more relevant for every language, domain, or question. Test the result quality with representative queries before selecting a model.

Keeping multiple models for the same data is useful when different applications or search experiences need different representations. For example, a multilingual model can support broad discovery across languages, while a larger or domain-tuned model can capture finer distinctions for detailed searches. Each model has its own vector column and index, but both are generated from the same movie documents. This allows workloads to use the appropriate search path and supports a gradual migration without changing or duplicating the original JSON data.

In this lab, you migrate from multilingual E5-small to E5-base. E5-small produces 384-dimensional vectors, while E5-base produces 768-dimensional vectors. You will add and index E5-base independently, then run the same kind of semantic search with the new model. If you have another compatible ONNX embedding model, repeat this pattern with its own vector column and index.

Estimated Time: 20 minutes

### Objectives

- Load the multilingual E5-base ONNX model prepared in Get Ready.
- Add a 768-dimensional embedding column without changing the movie JSON.
- Generate and index E5-base embeddings alongside the existing E5-small embeddings.
- Run semantic search with the migrated model and compare its results.
- Combine semantic search with metadata filters and keyword search.

## Task 1: Load multilingual E5-base

1. Load the model into the database using the E5-base PAR URL created in Get Ready.

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

    Replace `<multilingual-e5-base-onnx-model-url>` with the E5-base PAR URL from Get Ready.

## Task 2: Add the E5-base embedding column

1. Check the output dimension from the loaded E5-base model before changing the table.

    ```sql
    SELECT VECTOR_DIMS(
             VECTOR_EMBEDDING(
               MULTILINGUAL_E5_BASE
               USING 'dimension check' AS data
             )
           ) AS model_dimensions
    FROM dual;
    ```

    Confirm that the model returns `768`. The result determines the dimension required by the new vector column.

2. Add a vector column sized for E5-base.

    ```sql
    ALTER TABLE movies
    ADD embedding_e5_base VECTOR(768, FLOAT32);
    ```

    The new column does not alter the original JSON in `DATA` or the existing 384-dimensional `EMBEDDING_E5_SMALL` column. Each model has an independent storage and indexing path.

## Task 3: Generate and index the E5-base embeddings

1. Populate the new column with an E5-base embedding for every existing movie summary.

    `MOVIES` already contains the movie rows created in Lab 1, so update the new column instead of inserting duplicate rows.

    ```sql
    UPDATE movies
    SET embedding_e5_base =
        VECTOR_EMBEDDING(
            MULTILINGUAL_E5_BASE
            USING JSON_VALUE(data, '$.summary') AS data
        );

    COMMIT;
    ```

2. Gather optimizer statistics on `MOVIES` after populating the embeddings and before creating the vector index.

    Run this block as the workshop user that owns `MOVIES`. The statistics describe the populated table and help the optimizer estimate query costs when choosing an access path.

    ```sql
    BEGIN
      DBMS_STATS.GATHER_TABLE_STATS(
        ownname          => USER,
        tabname          => 'MOVIES',
        estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE
      );
    END;
    /
    ```

3. Create an HNSW index for the new column.

    ```sql
    CREATE VECTOR INDEX summary_base_vec_idx
    ON movies (embedding_e5_base)
    ORGANIZATION INMEMORY NEIGHBOR GRAPH
    DISTANCE COSINE
    WITH TARGET ACCURACY 95;
    ```

## Task 4: Search with multilingual E5-base

1. Run a semantic search using the E5-base vector column and the same model for the query embedding.

    ```sql
    SELECT JSON_VALUE(data, '$.title') AS title,
           JSON_VALUE(data, '$.year' RETURNING NUMBER) AS year,
           JSON_QUERY(data, '$.genre'
                      RETURNING VARCHAR2(1000)) AS genre
    FROM movies
    ORDER BY VECTOR_DISTANCE(
               embedding_e5_base,
               VECTOR_EMBEDDING(
                 MULTILINGUAL_E5_BASE
                 USING 'Find a movie about a military rescue mission.' AS data
               ),
               COSINE
             )
    FETCH FIRST 5 ROWS ONLY;
    ```

2. Compare these titles with the E5-small search from Lab 2.

    - Different models can rank the same movies differently. Measure relevance against questions and languages that matter to your application.
    - To try your own compatible ONNX model, add another appropriately sized vector column, load the model, generate vectors, and create a separate index. Keep the existing model and index until you have validated the new results.

## Task 5: Combine semantic search with filters

1. Add metadata filters to the E5-base semantic search. This query finds movies about a team of heroes, while restricting the results to Action movies released in 2000 or later.

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
               m.embedding_e5_base,
               VECTOR_EMBEDDING(
                 MULTILINGUAL_E5_BASE
                 USING 'a team of heroes working together to protect others' AS data
               ),
               COSINE
             )
    FETCH FIRST 5 ROWS ONLY
    WITH TARGET ACCURACY 90;
    ```

    The E5-base vector supplies the semantic ranking, while the `WHERE` clause applies structured filters from the movie document.

## Task 6: Combine text and vector results with INTERSECT

1. Return movies that appear in both the title search for `avengers` and the 20 nearest semantic matches.

    `JSON_TEXTCONTAINS` uses the `TITLE_IDX` JSON search index on `MOVIES.DATA`. The vector branch searches the relational `EMBEDDING_E5_BASE` column using the matching embedding model.

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
                 m.embedding_e5_base,
                 VECTOR_EMBEDDING(
                   MULTILINGUAL_E5_BASE
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
