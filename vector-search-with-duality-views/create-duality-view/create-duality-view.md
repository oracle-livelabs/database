# Lab 4: Expose JSON and Vectors with a Duality View

## Introduction

Imagine a movie-discovery application that accepts natural-language requests such as “a team of heroes working together to protect others.” The application needs complete movie documents in JSON. The database team needs relational source data, embeddings in a native `VECTOR` column, and an HNSW index for efficient semantic search. Maintaining separate JSON and search copies would add synchronization work and complicate model or index changes.

Create a JSON-relational duality view to meet both needs. The view exposes the movie JSON and the migrated E5-base vector as one document. The underlying `MOVIES` table remains the system of record. The application receives JSON documents, while SQL can search the underlying vector column using `SUMMARY_BASE_VEC_IDX`. This pattern suits catalog search, recommendations, and retrieval applications. It combines document-style responses with relational integrity, indexing, and gradual embedding-model migration.

Estimated Time: 30 minutes

### Objectives

- Create a duality view over the movie JSON and vector metadata.
- Query the duality view as JSON.
- Run semantic search through the duality view.
- Use an execution plan to verify the vector index access path.
- Combine semantic ranking with JSON filters and keyword search.

## Task 1: Create the movie duality view

1. Create a JSON-relational duality view that maps the movie identifier, JSON fields, and `embedding_e5_base` vector into a single document.

    ```sql
    CREATE OR REPLACE JSON RELATIONAL DUALITY VIEW movies_dv AS
    SELECT JSON {
        '_id': id,
        'movie': data,
        'embedding': embedding_e5_base
    }
    FROM movies
    WITH UPDATE INSERT DELETE;
    ```

2. Query the view and inspect one movie document.

    ```sql
    SELECT JSON_SERIALIZE(data RETURNING CLOB PRETTY) AS movie_document
    FROM movies_dv
    FETCH FIRST 1 ROW ONLY;
    ```

    The returned document contains the `_id`, the original movie JSON under `movie`, and the E5-base vector under `embedding`. The duality view does not copy or re-ingest the source JSON.

## Task 2: Run semantic search through the duality view

1. Use the duality view in a semantic SQL query and return the top five matching movie documents.

    Query `MOVIES_DV` directly and extract its top-level `embedding` field with `JSON_VALUE(... RETURNING VECTOR)`. Leave the dimensions and element format unspecified here so the optimizer can use the underlying vector index. The relational `EMBEDDING_E5_BASE` column already defines the 768-dimensional `FLOAT32` vector type.

    ```sql
    SELECT JSON_SERIALIZE(m.data RETURNING CLOB PRETTY) AS movie_document
    FROM movies_dv m
    ORDER BY VECTOR_DISTANCE(
               JSON_VALUE(
                 m.data,
                 '$.embedding'
                 RETURNING VECTOR
               ),
               VECTOR_EMBEDDING(
                 MULTILINGUAL_E5_BASE
                 USING 'a team of heroes working together to protect others' AS data
               ),
               COSINE
             )
    FETCH FIRST 5 ROWS ONLY
    WITH TARGET ACCURACY 90;
    ```

    The query reads each result directly from the duality view as a JSON document. Compare these documents with the E5-small results from Lab 2.

## Task 3: Inspect the execution plan

1. Ask the optimizer to describe the expected execution path for the duality-view search.

    `EXPLAIN PLAN FOR` does not execute the query. It records the estimated operations for the query over the duality view.

2. Generate the execution plan for the same query.

    ```sql
    EXPLAIN PLAN FOR
    SELECT JSON_SERIALIZE(m.data RETURNING CLOB PRETTY) AS movie_document
    FROM movies_dv m
    ORDER BY VECTOR_DISTANCE(
               JSON_VALUE(
                 m.data,
                 '$.embedding'
                 RETURNING VECTOR
               ),
               VECTOR_EMBEDDING(
                 MULTILINGUAL_E5_BASE
                 USING 'a team of heroes working together to protect others' AS data
               ),
               COSINE
             )
    FETCH FIRST 5 ROWS ONLY
    WITH TARGET ACCURACY 90;
    ```

3. Display the execution plan.

    ```sql
    SELECT *
    FROM TABLE(DBMS_XPLAN.DISPLAY);
    ```

    Review the plan to see whether Oracle rewrites the JSON-vector expression to the underlying `MOVIES.EMBEDDING_E5_BASE` column.

## Task 4: Combine semantic search with filters

1. Add metadata filters to the semantic search. Find movies about a team of heroes and limit the results to Action movies released in 2000 or later.

    Apply the structured filters to the relational rows in the vector search. The vector expression uses `MOVIES.EMBEDDING_E5_BASE`, allowing the nearest-neighbor subquery to use `SUMMARY_BASE_VEC_IDX`. The outer query returns movie fields from `MOVIES_DV`.

    Match `_id` as `VARCHAR2(255)` to preserve the original document identifier and match the type of `MOVIES.ID`.

    ```sql
    WITH nearest_movies AS (
      SELECT m.id
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
      FETCH APPROXIMATE FIRST 5 ROWS ONLY
      WITH TARGET ACCURACY 90
    )
    SELECT JSON_VALUE(d.data, '$.movie.title'
                      RETURNING VARCHAR2(200)) AS title,
           JSON_VALUE(d.data, '$.movie.year'
                      RETURNING NUMBER) AS year,
           JSON_QUERY(d.data, '$.movie.genre'
                      RETURNING VARCHAR2(1000)) AS genre
    FROM movies_dv d
    JOIN nearest_movies n
      ON JSON_VALUE(d.data, '$._id' RETURNING VARCHAR2(255)) = n.id;
    ```

## Task 5: Combine text and vector results with INTERSECT

1. Return movies that appear in both the title search for `men` and the 20 nearest semantic matches.

    Use `men` to look for X-Men titles while keeping the semantic request about a team of heroes unchanged. Compare the results with the `avengers` searches in earlier labs to see how the keyword changes the intersection.

    `JSON_TEXTCONTAINS` uses the `TITLE_IDX` JSON search index on `MOVIES.DATA`. The vector branch returns fields from `MOVIES_DV`. Its ID subquery ranks the relational `EMBEDDING_E5_BASE` column using `SUMMARY_BASE_VEC_IDX`.

    ```sql
    -- Text results INTERSECT vector results
    WITH text_results AS (
      SELECT JSON_VALUE(data, '$.title' RETURNING VARCHAR2(200)) AS title,
             JSON_VALUE(data, '$.year' RETURNING NUMBER) AS year,
             JSON_QUERY(data, '$.genre' RETURNING VARCHAR2(1000)) AS genre
      FROM movies
      WHERE JSON_TEXTCONTAINS(data, '$.title', 'men', 1)
    ),
    nearest_movies AS (
      SELECT m.id
      FROM movies m
      ORDER BY VECTOR_DISTANCE(
                 m.embedding_e5_base,
                 VECTOR_EMBEDDING(
                   MULTILINGUAL_E5_BASE
                   USING 'a team of heroes working together to protect others' AS data
                 ),
                 COSINE
               )
      FETCH APPROXIMATE FIRST 20 ROWS ONLY
      WITH TARGET ACCURACY 90
    ),
    vector_results AS (
      SELECT JSON_VALUE(d.data, '$.movie.title' RETURNING VARCHAR2(200)) AS title,
             JSON_VALUE(d.data, '$.movie.year' RETURNING NUMBER) AS year,
             JSON_QUERY(d.data, '$.movie.genre' RETURNING VARCHAR2(1000)) AS genre
      FROM movies_dv d
      WHERE JSON_VALUE(d.data, '$._id' RETURNING VARCHAR2(255)) IN (
        SELECT id
        FROM nearest_movies
      )
    )
    SELECT title, year, genre
    FROM text_results
    INTERSECT
    SELECT title, year, genre
    FROM vector_results
    ORDER BY year, title
    FETCH FIRST 3 ROWS ONLY;
    ```

    `INTERSECT` returns distinct title, year, and genre combinations found by both searches. The vector branch uses `VECTOR_DISTANCE` to rank its 20 nearest candidates. The output contains only movie fields. The final query sorts the shared results by year and title and returns at most three rows.

## Acknowledgements

- **Author** - Gael Palomino
- **Last Updated By/Date** - Gael Palomino, November 2026
