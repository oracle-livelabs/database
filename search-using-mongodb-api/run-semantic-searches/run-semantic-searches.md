# Run Semantic and Combined Searches

## Introduction

Semantic search compares a query with movie-summary embeddings. In this lab, use `$sql` in `mongosh` to create query vectors. Search the summary vectors, refine the results, and combine keyword and vector branches.

Estimated Time: 20 minutes

### Objectives

In this lab, you will:

- Generate a query vector with the same model used for movie summaries
- Run vector search against `summary_embedding`
- Filter or sort semantic results
- Combine keyword and vector result sets

### Prerequisites

- Lab 2 is complete and `summary_embedding` is populated.
- Keep the connected `mongosh` session and `summary_vec_idx` index available.

## Task 1: Generate a semantic query vector

1. Return to the connected MongoDB shell.

2. Run the following code. Pass the `$sql` stage directly to `aggregate()`. `VECTOR_SERIALIZE` returns the embedding as text. `JSON.parse` turns it into the array that `$vectorSearch` requires.

    ```javascript
    const queryVector1 = JSON.parse(
      db.MOVIES.aggregate({
        $sql:
          "SELECT VECTOR_SERIALIZE(VECTOR_EMBEDDING(MULTILINGUAL_E5_BASE USING 'a team of heroes working together to protect others' AS data)) FROM dual"
      }).next().DATA
    );
    ```

3. Confirm that `queryVector1` contains the expected number of dimensions. The MongoDB API returns the SQL scalar in the `DATA` property.

    ```javascript
    queryVector1.length;
    ```

    The result is:

    ```text
    768
    ```

    This is the expected dimension count for the provided `MULTILINGUAL_E5_BASE` model. If you selected a different model, expect its dimension count here.

## Task 2: Search movie summaries by meaning

1. Run the following vector search:

    ```javascript
    db.MOVIES.aggregate([
      {
        $vectorSearch: {
          index: "summary_vec_idx",
          path: "summary_embedding",
          queryVector: queryVector1,
          limit: 5,
          exact: false
        }
      },
      {
        $project: {
          _id: 0,
          title: 1,
          year: 1,
          genre: 1,
          main_subject: 1
        }
      }
    ]);
    ```

    Example result:

    ```javascript
    [
      {
        title: 'Saving Private Ryan',
        year: 1998,
        genre: [ 'War', 'Drama', 'Action' ],
        main_subject: 'Invasion of Normandy'
      },
      {
        title: 'Avengers: Infinity War',
        year: 2018,
        genre: [ 'Action', 'Sci-Fi', 'Adventure' ],
        main_subject: 'genocide'
      },
      {
        title: 'Avengers: Endgame',
        year: 2019,
        genre: [ 'Action', 'Adventure' ],
        main_subject: null
      },
      {
        title: 'Suicide Squad',
        year: 2016,
        genre: [ 'Sci-Fi', 'Action', 'Adventure', 'Crime', 'Fantasy' ],
        main_subject: null
      },
      {
        title: 'The Avengers',
        year: 2012,
        genre: [ 'Action', 'Sci-Fi', 'Adventure' ],
        main_subject: 'alien invasion'
      }
    ]
    ```

    `Saving Private Ryan` can appear even though it is not an Avengers movie. Its summary may describe people working together on a dangerous mission. Semantic search can match that meaning without matching the query's exact words.

2. Identify at least one result whose title does not contain the query terms. Use its genre or `main_subject` to explain why its summary could still be semantically relevant.

3. Generate a second query embedding with `$sql`:

    ```javascript
    const queryVector2 = JSON.parse(
      db.MOVIES.aggregate({
        $sql:
          "SELECT VECTOR_SERIALIZE(VECTOR_EMBEDDING(MULTILINGUAL_E5_BASE USING 'an ordinary person rising to the occasion and becoming a hero' AS data)) FROM dual"
      }).next().DATA
    );
    ```

4. Run the complete vector search with `queryVector2`:

    ```javascript
    db.MOVIES.aggregate([
      {
        $vectorSearch: {
          index: "summary_vec_idx",
          path: "summary_embedding",
          queryVector: queryVector2,
          limit: 5,
          exact: false
        }
      },
      {
        $project: {
          _id: 0,
          title: 1,
          year: 1,
          genre: 1,
          main_subject: 1
        }
      }
    ]);
    ```

    Example result:

    ```javascript
    [
      {
        title: 'The Hero',
        year: 2017,
        genre: [ 'Comedy' ],
        main_subject: null
      },
      {
        title: 'No Ordinary Hero',
        year: 2013,
        genre: [ 'Comedy', 'Drama' ],
        main_subject: null
      },
      {
        title: 'Just Say Hi',
        year: 2013,
        genre: [ 'Unknown' ],
        main_subject: null
      },
      {
        title: '6 Below: Miracle on the Mountain',
        year: 2017,
        genre: [ 'Thriller', 'Drama', 'Biography', 'Adventure' ],
        main_subject: null
      },
      {
        title: "Being Elmo: A Puppeteer's Journey",
        year: 2011,
        genre: [ 'Documentary' ],
        main_subject: null
      }
    ]
    ```

5. Compare the results from `queryVector1` and `queryVector2`.

## Task 3: Refine the semantic results

This task adds a metadata filter to semantic search. Think of `$match` as an intersection. The vector query finds relevant movies first. `$match` keeps only results in the selected genres.

1. Run the complete aggregation below. The `$match` stage retains selected genres after vector search:

    ```javascript
    db.MOVIES.aggregate([
      {
        $vectorSearch: {
          index: "summary_vec_idx",
          path: "summary_embedding",
          queryVector: queryVector1,
          limit: 5,
          exact: false
        }
      },
      {
        $match: {
          genre: {
            $in: ["War", "Drama"]
          }
        }
      },
      {
        $project: {
          _id: 0,
          title: 1,
          year: 1,
          genre: 1,
          main_subject: 1
        }
      }
    ]);
    ```

    Example result:

    ```javascript
    [
      {
        title: 'Saving Private Ryan',
        year: 1998,
        genre: [ 'War', 'Drama', 'Action' ],
        main_subject: 'Invasion of Normandy'
      }
    ]
    ```

2. Run the aggregation and compare the result set with the unfiltered semantic search.

3. Run the following complete aggregation to sort the semantic results by year:

    ```javascript
    db.MOVIES.aggregate([
      {
        $vectorSearch: {
          index: "summary_vec_idx",
          path: "summary_embedding",
          queryVector: queryVector1,
          limit: 5,
          exact: false
        }
      },
      { $sort: { year: 1 } },
      {
        $project: {
          _id: 0,
          title: 1,
          year: 1,
          genre: 1,
          main_subject: 1
        }
      }
    ]);
    ```

    Example result:

    ```javascript
    [
      {
        title: 'Saving Private Ryan',
        year: 1998,
        genre: [ 'War', 'Drama', 'Action' ],
        main_subject: 'Invasion of Normandy'
      },
      {
        title: 'The Avengers',
        year: 2012,
        genre: [ 'Action', 'Sci-Fi', 'Adventure' ],
        main_subject: 'alien invasion'
      },
      {
        title: 'Suicide Squad',
        year: 2016,
        genre: [ 'Sci-Fi', 'Action', 'Adventure', 'Crime', 'Fantasy' ],
        main_subject: null
      },
      {
        title: 'Avengers: Infinity War',
        year: 2018,
        genre: [ 'Action', 'Sci-Fi', 'Adventure' ],
        main_subject: 'genocide'
      },
      {
        title: 'Avengers: Endgame',
        year: 2019,
        genre: [ 'Action', 'Adventure' ],
        main_subject: null
      }
    ]
    ```

4. Vector search selects the most relevant movies. The next stage sorts those results by year.

## Task 4: Combine keyword and vector results

Combining both branches broadens search. Keyword search finds exact title matches. Vector search adds movies with related summaries. The `source` field identifies the branch that returned each movie.

1. Run the following aggregation. The first branch searches titles, and `$unionWith` appends the vector-search results from the same collection:

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
          year: 1,
          source: { $literal: "text" }
        }
      },
      {
        $unionWith: {
          coll: "MOVIES",
          pipeline: [
            {
              $vectorSearch: {
                index: "summary_vec_idx",
                path: "summary_embedding",
                queryVector: queryVector1,
                limit: 5,
                exact: false
              }
            },
            {
              $project: {
                _id: 0,
                title: 1,
                year: 1,
                source: { $literal: "vector" }
              }
            }
          ]
        }
      },
      { $sort: { year: 1 } }
    ]);
    ```

    Example result:

    ```javascript
    [
      { title: 'Saving Private Ryan', year: 1998, source: 'vector' },
      { title: 'The Avengers', year: 2012, source: 'vector' },
      { title: 'The Avengers', year: 2012, source: 'text' },
      { title: 'Avengers: Age of Ultron', year: 2015, source: 'text' },
      { title: 'Suicide Squad', year: 2016, source: 'vector' },
      { title: 'Avengers: Infinity War', year: 2018, source: 'vector' },
      { title: 'Avengers: Infinity War', year: 2018, source: 'text' },
      { title: 'Avengers: Endgame', year: 2019, source: 'vector' },
      { title: 'Avengers: Endgame', year: 2019, source: 'text' }
    ]
    ```

    Duplicate titles are expected when both branches find the same movie. Keeping both rows shows that keyword and semantic search can independently find one document.

2. Use the `source` field to identify which branch returned each document.

3. Compare the approaches you used:

    - Choose keyword search when users know the terms to find.
    - Choose vector search when the meaning of a natural-language request matters.
    - Combine the result sets when an application needs both behaviors.

## Summary

You used the MongoDB API for Oracle AI Database to load JSON movie data. You created search indexes and queried one collection from `mongosh`. You generated embeddings with the ONNX model used for movie summaries. You then searched by similarity and refined results with metadata and sorting. Finally, you combined keyword and vector results.

MongoDB-compatible commands give applications a familiar document interface. Oracle AI Database supplies JSON storage, keyword search, AI Vector Search, and SQL through `$sql`. This approach can add semantic search to a MongoDB-style application without changing its document model. Vector indexes and in-database embedding generation remain available.

Use these patterns for catalog discovery, knowledge retrieval, recommendations, and retrieval-augmented generation (RAG). In each case, relevant documents provide context for an application or AI agent.

Congratulations! You have completed the workshop.

You can now apply these MongoDB API search patterns to your own JSON collections on Oracle AI Database.

## Learn More

- [Generate Vector Embeddings](https://docs.oracle.com/en/database/oracle/oracle-database/26/vecse/generate-vector-embeddings-node.html)
- [Oracle AI Vector Search Documentation](https://docs.oracle.com/en/database/oracle/oracle-database/26/vecse/index.html)
- [Semantic and Combined Search Examples with Oracle Database API for MongoDB](https://blogs.oracle.com/autonomous-ai-database/search-examples-using-oracle-ai-database-api-for-mongodb)

## Acknowledgements

- **Author** - Gael Palomino
- **Last Updated By/Date** - Gael Palomino, August 2026
- **Source** - [Search Examples using Oracle AI Database API for MongoDB](https://blogs.oracle.com/autonomous-ai-database/search-examples-using-oracle-ai-database-api-for-mongodb)
