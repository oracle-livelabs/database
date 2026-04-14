# Lab 3: Social Vector Trends

## Introduction

This lab demonstrates prompt-compatible Oracle Vector SQL for semantic product retrieval.

Estimated Time: 12 minutes

### Objectives

In this lab, you will:
- Verify the embedding model and embedding table created in Lab 1.
- Create a vector index on the workshop embedding table.
- Run semantic similarity ranking with cosine distance.

## Task 1: Verify Lab 1 Prerequisites

This prerequisite check confirms vector foundations are ready before indexing and retrieval. It is important because vector SQL fails quickly when the model or embedding table is missing.

1. Run this SQL to confirm the embedding model and `PRODUCT_EMBEDDINGS` table were created in Lab 1.

    ```
    <copy>
    SELECT 'MODEL_READY' AS check_name, COUNT(*) AS ready_flag
    FROM user_mining_models
    WHERE model_name = 'ALL_MINILM_L12_V2'
    UNION ALL
    SELECT 'PRODUCT_EMBEDDINGS_TABLE', COUNT(*) AS ready_flag
    FROM user_tables
    WHERE table_name = 'PRODUCT_EMBEDDINGS';
    </copy>
    ```

    <iframe
            class="freesql-embed"
            data-freesql-src="https://freesql.com/embedded/?layout=vertical&compressed_code=H4sIAAAAAAAC%252F42OuwrCQBBFe79iulWxMa1YJNlRA%252FuQPBSrYU3WGEwiJFr498YFRbCxnHPvXA4AQIICwxSY1BwFxejzAwM%252Fgfxs8wu1prEzCHWm0vF08uKdNcWDTrUpR8M3rGIt4d7bjpqqrdqSmmth695l%252Bw3GCA64IVgC84UgGalISBJzj3Yec9VMRVrBELrr7bSNNc%252FClFAGyHmk1gmlfiCQ%252Fal0M8fafrs48HH5nWeLJ9161MYTAQAA&code_language=SQL&code_format=false"
            height="460px"
            width="100%"
            scrolling="no"
            frameborder="0"
            allowfullscreen="true"
            name="FreeSQL Embedded Playground"
            title="FreeSQL"
            style="width: 100%; border: 1px solid #e0e0e0; border-radius: 12px; overflow: hidden;"
        >FreeSQL Embedded Playground</iframe>

2. If either row returns `0`, rerun Lab 1 Task 1 and Lab 1 Task 2, then return here.

## Task 2: Create the Vector Index Used by This Workshop

This task creates the exact vector index used in this workshop path. The index is critical for fast nearest-neighbor lookups that mirror the demo's semantic ranking behavior.

1. Run this SQL.

    ```
    <copy>
    CREATE VECTOR INDEX idx_product_embeddings_ivf
    ON product_embeddings(embedding)
    ORGANIZATION NEIGHBOR PARTITIONS
    DISTANCE COSINE
    PARAMETERS(
      TYPE IVF,
      NEIGHBOR PARTITIONS 10,
      MIN_VECTORS_PER_PARTITION 0
    );
    </copy>
    ```

    <iframe
            class="freesql-embed"
            data-freesql-src="https://freesql.com/embedded/?layout=vertical&compressed_code=H4sIAAAAAAAC%252F22POw%252FCMBCDd36Fx1ZiKDNTSI9yQ9MqiSpgiQQpqAMP8RI%252Fn5BCF9jO9neWDABSk7CEhqStNFjltETnn%252B58Ofn79ubaw6b1vjvur6577EbhA5XCb5oMZ9pDuhCK18JywBVxsZiF%252Flpoy2%252FLRChnY4WSBFkZVhS9gIiSLGmTRA3YVU3gZj7%252B6D9tmGTftGTl%252BjXG1aTdACGLRDp9AUoebUL3AAAA&code_language=SQL&code_format=false"
            height="460px"
            width="100%"
            scrolling="no"
            frameborder="0"
            allowfullscreen="true"
            name="FreeSQL Embedded Playground"
            title="FreeSQL"
            style="width: 100%; border: 1px solid #e0e0e0; border-radius: 12px; overflow: hidden;"
        >FreeSQL Embedded Playground</iframe>

2. Confirm the index is created.

## Task 3: Run Semantic Similarity Retrieval

Now you run the retrieval pattern that powers prompt-compatible semantic discovery. This step connects SQL output to what users experience when searching for conceptually similar products.

1. Run this SQL.

    ```
    <copy>
    SELECT p.product_id,
           p.product_name,
           ROUND(1 - VECTOR_DISTANCE(pe.embedding,
             VECTOR_EMBEDDING(ALL_MINILM_L12_V2 USING 'viral lightweight running gear' AS DATA),
             COSINE), 4) AS similarity_score
    FROM product_embeddings pe
    JOIN products p ON p.product_id = pe.product_id
    ORDER BY similarity_score DESC
    FETCH FIRST 10 ROWS ONLY;
    </copy>
    ```

    <iframe
            class="freesql-embed"
            data-freesql-src="https://freesql.com/embedded/?layout=vertical&compressed_code=H4sIAAAAAAAC%252F2VQz0%252BDMBS%252B%252B1d8t0EyF1m8GQ%252BMdlpT2qRlMzs1OBpsAowA0%252Fjf223Bifbwkr7v13sPADTlNMnQLtruUBz3g3HF%252FAbXdwWavLYTSMmNIEGEW2y9hVSGMJ3FIqFBaxe2frNF4ZpyIsFIpemKEsLEUxBzblImGE8Nj5Zmu8RG%252Bz5mH67LK1SufB8%252B7amiOzaNd0Rp826GWIPEWRz%252BCUikl9NwjvvwROld7aq8c8OX6feHzp7JayVTjHv9TNqjvcAvkokR9k1IMbkPHj3x1%252F%252BskYpQhdXuXyAI1ckllWbJM9ZM6QzRnT%252Ffq%252FbWfPfwDa%252BuWY%252BIAQAA&code_language=SQL&code_format=false"
            height="460px"
            width="100%"
            scrolling="no"
            frameborder="0"
            allowfullscreen="true"
            name="FreeSQL Embedded Playground"
            title="FreeSQL"
            style="width: 100%; border: 1px solid #e0e0e0; border-radius: 12px; overflow: hidden;"
        >FreeSQL Embedded Playground</iframe>

2. Record the top 3 matches and explain why they fit the query intent.

## Task 4: Check Your Understanding

Use this checkpoint to confirm the vector execution order is clear. Getting model, embeddings, and indexing sequence right is essential in production workflows.

```quiz
Q: Why must `ALL_MINILM_L12_V2` exist before creating `PRODUCT_EMBEDDINGS`?
* `VECTOR_EMBEDDING` needs a loaded model at table-creation time.
- The vector index creates the model automatically.
- The model is only needed after the index is created.
> Correct. The table build calls `VECTOR_EMBEDDING` immediately.

Q: Why verify `PRODUCT_EMBEDDINGS` before creating the vector index?
* The index depends on the `embedding` column in that table.
- Oracle can create the table automatically from index DDL.
- The index only uses `PRODUCTS` and does not require embeddings.
> Correct. No `PRODUCT_EMBEDDINGS` table means no vector index target.
```

## Acknowledgements
* **Author** - Pat Shepherd + Codex
* **Last Updated By/Date** - Codex, April 2026
