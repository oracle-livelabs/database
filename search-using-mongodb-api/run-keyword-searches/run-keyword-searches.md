# Prepare Search and Run a Keyword Query

## Introduction

The `MOVIES` collection is available through SQL and Oracle Database API for MongoDB. In this lab, generate embeddings for each movie summary. Create text and vector search indexes. Then verify that the text index returns movie titles.

Estimated Time: 15 minutes

### Objectives

In this lab, you will:

- Add a summary embedding to each movie document
- Create text and vector search indexes through the MongoDB API
- Run a keyword search against movie titles

### Prerequisites

- Lab 1 is complete and the `MOVIES` collection is available.
- Keep the SQL worksheet and connected `mongosh` session open.

## Task 1: Add summary embeddings

1. In the SQL worksheet, run the following statement. It creates an embedding for each movie summary. It stores the vector as `summary_embedding` in the JSON document:

    ```sql
    UPDATE movies
       SET data = JSON_TRANSFORM(
         data,
         SET '$.summary_embedding' =
           TO_VECTOR(
             VECTOR_EMBEDDING(
               MULTILINGUAL_E5_BASE
               USING JSON_VALUE(
                 data,
                 '$.summary'
                 RETURNING VARCHAR2(32767)
                 NULL ON ERROR
               ) AS data
             )
           )
       );

    COMMIT;
    ```

2. Confirm that the collection now contains documents with the new field:

    ```sql
    SELECT COUNT(*) AS embedded_movies
      FROM movies
     WHERE JSON_EXISTS(data, '$.summary_embedding');
    ```

3. Confirm that `EMBEDDED_MOVIES` is greater than zero before creating the vector index.

## Task 2: Create the search indexes

1. Return to the connected `mongosh` session.

2. Create the text search index for movie titles:

    ```javascript
    db.MOVIES.createSearchIndex(
      "title_idx",
      { mappings: { dynamic: true } }
    );
    ```

3. Create a vector search index for the 768-dimension summary embeddings. Use cosine similarity. If you loaded another model, set `numDimensions` to its dimension count.

    ```javascript
    db.MOVIES.createSearchIndex(
      "summary_vec_idx",
      "vectorSearch",
      {
        fields: [
          {
            type: "vector",
            path: "summary_embedding",
            numDimensions: 768,
            similarity: "cosine"
          }
        ]
      }
    );
    ```

4. Retrieve the search indexes and confirm that `title_idx` and `summary_vec_idx` are present:

    ```javascript
    db.MOVIES.getSearchIndexes()
    ```

## Task 3: Run a keyword search

1. Run a `$search` aggregation against the `title` field:

    ```javascript
    db.MOVIES.aggregate([
      {
        $search: {
          text: {
            path: "title",
            query: "avengers"
          }
        }
      },
      {
        $project: {
          _id: 0,
          title: 1,
          year: 1
        }
      }
    ]);
    ```

    Sample result:

    ```javascript
    [
      { title: 'Avengers: Endgame', year: 2019 },
      { title: 'Avengers: Infinity War', year: 2018 },
      { title: 'Avengers: Age of Ultron', year: 2015 },
      { title: 'The Avengers', year: 2012 }
    ]
    ```

2. Confirm that the aggregation returns movie titles and years.

3. Run the complete aggregation below. It searches for `avengers captain` and adds `matchCriteria: "any"`. Titles that match either term can appear in the results:

    ```javascript
    db.MOVIES.aggregate([
      {
        $search: {
          text: {
            path: "title",
            query: "avengers captain",
            matchCriteria: "any"
          }
        }
      },
      {
        $project: {
          _id: 0,
          title: 1,
          year: 1
        }
      }
    ]);
    ```

    Sample result:

    ```javascript
    [
      { title: 'Captain America: The Winter Soldier', year: 2014 },
      { title: 'Captain America: Civil War', year: 2016 },
      { title: 'Captain Marvel', year: 2019 },
      { title: 'Captain Mike Across America', year: 2007 },
      { title: 'Avengers: Endgame', year: 2019 },
      { title: 'Avengers: Infinity War', year: 2018 },
      { title: 'Avengers: Age of Ultron', year: 2015 },
      { title: 'The Avengers', year: 2012 }
    ]
    ```

4. Keep the SQL worksheet and `mongosh` session open for the semantic searches in Lab 3.

You are ready to proceed to Lab 3 and search movie summaries by meaning.

## Learn More

- [MongoDB API Feature Support](https://docs.oracle.com/en/database/oracle/mongodb-api/mgapi/support-mongodb-apis-operations-and-data-types-reference.html)
- [Aggregation Pipelines](https://docs.oracle.com/en/database/oracle/mongodb-api/mgapi/pipelines.html)
- [Keyword Search Examples with Oracle Database API for MongoDB](https://blogs.oracle.com/autonomous-ai-database/search-examples-using-oracle-ai-database-api-for-mongodb)

## Acknowledgements

- **Author** - Gael Palomino
- **Last Updated By/Date** - Gael Palomino, August 2026
- **Source** - [Search Examples using Oracle AI Database API for MongoDB](https://blogs.oracle.com/autonomous-ai-database/search-examples-using-oracle-ai-database-api-for-mongodb)
