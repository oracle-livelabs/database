# Customer Trend Signals with AI Vector Search

## Introduction

A digital merchandising manager, customer insights analyst, or retail marketing strategist needs early signals from shoppers and creators. Those signals often appear before demand shows up in sales reports. This lab follows the Customer Trend Signals scene in the runbook. Semantic Product Discovery turns shopper intent into product matches. Social Trend Intelligence ranks creator posts, customer conversations, sentiment, and social momentum.

Oracle AI Database keeps vector search, SQL, row-level security, and operational retail data together. In the LiveStack application, Customer Trend Signals connects product language, creator posts, reviews, returns, demand, and community signals. In SQL Worksheet, you verify MiniLM vector structures. You then generate product embeddings and run dynamic semantic search against database-managed product vectors.

Estimated Time: 10 minutes

### Objectives

- Connect Semantic Product Discovery to product embeddings stored in Oracle Database.
- Generate product embeddings with the MiniLM embedding model.
- Run dynamic semantic search with `VECTOR_EMBEDDING` and `VECTOR_DISTANCE`.
- Connect Social Trend Intelligence to cached creator-post and product matches.
- Explain how shopper language, social momentum, sentiment, and product demand become governed SQL evidence.


## Task 1: Verify MiniLM vector artifacts and indexes
1. Review the related application screen before you run the SQL.

    ![Customer Trend Signals overview with semantic search and social intelligence](images/customer-trend-signals-overview.png " ")

    *Figure 1: Customer Trend Signals connects semantic product discovery with social trend intelligence.*

2. Run this vector column check.

    Before you search by meaning, confirm that the database has vector-ready structures. This block reads `ALL_TAB_COLS` and finds typed `VECTOR` columns in the embedding tables. Those structures support Semantic Product Discovery and Social Trend Intelligence.

    ```sql
    <copy>
    WITH schema_ctx AS (
      SELECT owner
      FROM all_tab_cols
      WHERE table_name IN ('PRODUCT_EMBEDDINGS','POST_EMBEDDINGS')
        AND column_name = 'EMBEDDING'
        AND owner IN (SYS_CONTEXT('USERENV','CURRENT_SCHEMA'), USER, 'LLUSER')
      GROUP BY owner
      ORDER BY CASE
                 WHEN owner = SYS_CONTEXT('USERENV','CURRENT_SCHEMA') THEN 1
                 WHEN owner = USER THEN 2
                 WHEN owner = 'LLUSER' THEN 3
                 ELSE 4
               END
      FETCH FIRST 1 ROW ONLY
    )
    SELECT c.table_name AS "Table", c.column_name AS "Column", c.data_type AS "Type"
    FROM all_tab_cols c
    JOIN schema_ctx s ON s.owner = c.owner
    WHERE c.table_name IN ('PRODUCT_EMBEDDINGS','POST_EMBEDDINGS')
      AND c.column_name = 'EMBEDDING'
    ORDER BY c.table_name;
    </copy>
    ```

    Expected output:

    | Table | Column | Type |
    | --- | --- | --- |
    | `POST_EMBEDDINGS` | `EMBEDDING` | VECTOR |
    | `PRODUCT_EMBEDDINGS` | `EMBEDDING` | VECTOR |
    {: title="MiniLM Vector Columns"}

3. The compact learner setup creates the embedding tables and vector indexes. You generate the product embeddings in the next task.

4. Check the vector indexes.

    Vector indexes make similarity search practical for an application. This block checks `ALL_INDEXES` for the expected vector indexes and status. Valid vector indexes help Customer Trend Signals search by meaning and complement keyword matching.

    ```sql
    <copy>
    WITH schema_ctx AS (
      SELECT owner
      FROM all_indexes
      WHERE index_name IN ('IDX_PRODUCT_VEC','IDX_POST_VEC')
        AND owner IN (SYS_CONTEXT('USERENV','CURRENT_SCHEMA'), USER, 'LLUSER')
      GROUP BY owner
      ORDER BY CASE
                 WHEN owner = SYS_CONTEXT('USERENV','CURRENT_SCHEMA') THEN 1
                 WHEN owner = USER THEN 2
                 WHEN owner = 'LLUSER' THEN 3
                 ELSE 4
               END
      FETCH FIRST 1 ROW ONLY
    )
    SELECT i.owner AS "Owner", i.index_name AS "Index", i.table_name AS "Table", i.index_type AS "Type"
    FROM all_indexes i
    JOIN schema_ctx s ON s.owner = i.owner
    WHERE i.index_name IN ('IDX_PRODUCT_VEC','IDX_POST_VEC')
    ORDER BY i.index_name;
    </copy>
    ```

    Expected output:

    | Owner | Index | Table | Type |
    | --- | --- | --- | --- |
    | LLUSER | `IDX_POST_VEC` | `POST_EMBEDDINGS` | VECTOR |
    | LLUSER | `IDX_PRODUCT_VEC` | `PRODUCT_EMBEDDINGS` | VECTOR |
    {: title="Vector Indexes"}

## Task 2: Generate product embeddings
1. Use the live Customer Trend Signals context from Figure 1 before you run the SQL.

2. Reset the product embedding table.

    This block clears generated product vectors before you rebuild them. That keeps the lab safe to rerun. It also prevents duplicate embeddings from affecting search results.

    ```sql
    <copy>
    TRUNCATE TABLE product_embeddings;
    </copy>
    ```

3. Review the source rows that will become embeddings.

    The embedding process starts with ordinary product data. This query shows the text that the next step sends to the MiniLM embedding model. The text combines product name, category, subcategory, and tags. That extra context helps the vector represent product meaning.

    ```sql
    <copy>
    SELECT p.product_id AS "Product ID",
           p.product_name AS "Product",
           TO_CLOB(
             p.product_name || ' ' ||
             p.category || ' ' ||
             NVL(p.subcategory, '') || ' ' ||
             NVL(p.tags, '')
           ) AS "Embedding Text"
    FROM products p
    WHERE p.is_active = 1
    ORDER BY p.product_id
    FETCH FIRST 5 ROWS ONLY;
    </copy>
    ```

4. Generate product embeddings.

    This `INSERT ... SELECT` statement creates one embedding row for each active product. The `SELECT` builds the source text and calls `EMBED_RETAIL_TEXT`. That workshop helper wraps Oracle Database `VECTOR_EMBEDDING` with the MiniLM model. Oracle Database stores each generated vector in `PRODUCT_EMBEDDINGS` for later searches.

    ```sql
    <copy>
    INSERT INTO product_embeddings (
      product_id,
      embedding_model,
      embedding_text,
      embedding
    )
    SELECT p.product_id,
           'ALL_MINILM_L12_V2' AS embedding_model,
           TO_CLOB(
             p.product_name || ' ' ||
             p.category || ' ' ||
             NVL(p.subcategory, '') || ' ' ||
             NVL(p.tags, '')
           ) AS embedding_text,
           embed_retail_text(
             p.product_name || ' ' ||
             p.category || ' ' ||
             NVL(p.subcategory, '') || ' ' ||
             NVL(p.tags, '')
           ) AS embedding
    FROM products p
    WHERE p.is_active = 1;

    COMMIT;
    </copy>
    ```

5. Confirm that the active product catalog now has embeddings.

    This check counts the MiniLM vectors you just generated. The count should match the number of active products in the compact workshop data.

    ```sql
    <copy>
    SELECT COUNT(*) AS "Product Embeddings"
    FROM product_embeddings
    WHERE embedding_model = 'ALL_MINILM_L12_V2';
    </copy>
    ```

    Expected output:

    | Product Embeddings |
    | ---: |
    | 187 |
    {: title="Generated Product Embeddings"}

6. The product catalog now has vectors that the next query can compare with a shopper-style search phrase.

## Task 3: Search products by meaning
1. Run this dynamic semantic search.

    Retail users often ask conceptual questions, such as "summer running shoes lightweight breathable." This block embeds that phrase at query time with `EMBED_RETAIL_TEXT`. It compares the query vector with the product vectors you generated and ranks products by cosine distance. Lower distance means the product is closer in meaning to the search phrase.

    ```sql
    <copy>
    WITH query_ctx AS (
      SELECT 'summer running shoes lightweight breathable' AS query_text,
             embed_retail_text('summer running shoes lightweight breathable') AS query_vector
      FROM dual
    )
    SELECT q.query_text AS "Search Phrase",
           p.product_name AS "Product",
           p.category AS "Category",
           ROUND(VECTOR_DISTANCE(pe.embedding, q.query_vector, COSINE), 4) AS "Distance"
    FROM product_embeddings pe
    JOIN products p ON p.product_id = pe.product_id
    CROSS JOIN query_ctx q
    WHERE pe.embedding_model = 'ALL_MINILM_L12_V2'
    ORDER BY VECTOR_DISTANCE(pe.embedding, q.query_vector, COSINE), p.product_id
    FETCH FIRST 5 ROWS ONLY;
    </copy>
    ```

    Expected output:

    | Search Phrase | Product | Category | Distance |
    | --- | --- | --- | ---: |
    | summer running shoes lightweight breathable | AirGlide Runner | Footwear | 0.2682 |
    | summer running shoes lightweight breathable | Marathon Elite Racer | Footwear | 0.3728 |
    | summer running shoes lightweight breathable | Carbon Slim Joggers | Fashion | 0.4327 |
    | summer running shoes lightweight breathable | TrailGrip Hiker | Footwear | 0.4524 |
    | summer running shoes lightweight breathable | AllTerrain Hiking Boots | Outdoor | 0.4627 |
    {: title="Dynamic Semantic Product Search Results"}

2. Try a different shopper phrase.

    Change the search phrase in both places inside `query_ctx`: the displayed `query_text` value and the value passed into `embed_retail_text`. For example, replace `summer running shoes lightweight breathable` with `soft cotton shirts for travel`.

    ```sql
    <copy>
    WITH query_ctx AS (
      SELECT 'soft cotton shirts for travel' AS query_text,
             embed_retail_text('soft cotton shirts for travel') AS query_vector
      FROM dual
    )
    SELECT q.query_text AS "Search Phrase",
           p.product_name AS "Product",
           p.category AS "Category",
           ROUND(VECTOR_DISTANCE(pe.embedding, q.query_vector, COSINE), 4) AS "Distance"
    FROM product_embeddings pe
    JOIN products p ON p.product_id = pe.product_id
    CROSS JOIN query_ctx q
    WHERE pe.embedding_model = 'ALL_MINILM_L12_V2'
    ORDER BY VECTOR_DISTANCE(pe.embedding, q.query_vector, COSINE), p.product_id
    FETCH FIRST 5 ROWS ONLY;
    </copy>
    ```

3. The closest products show how shopper language becomes ranked product evidence for promotion, inventory, and trend analysis.

## Task 4: Inspect social trend matches
1. Use the Social Trend Intelligence region in Figure 1 before you run the SQL.

2. Run this query.

    Social Trend Intelligence is the second half of the scene. It monitors creator posts, customer conversations, sentiment, and momentum. This block joins cached semantic matches to social posts, influencers, and products. The result explains which posts align to which products.

    ```sql
    <copy>
    SELECT sp.momentum_flag AS "Momentum",
           sp.platform AS "Platform",
           NVL(i.handle, 'customer') AS "Creator",
           p.product_name AS "Product",
           ROUND(sm.similarity_score, 5) AS "Score"
    FROM semantic_matches sm
    JOIN social_posts sp ON sp.post_id = sm.post_id
    LEFT JOIN influencers i ON i.influencer_id = sp.influencer_id
    JOIN products p ON p.product_id = sm.product_id
    ORDER BY ROUND(sm.similarity_score, 5) DESC,
             sm.match_rank,
             p.product_name,
             sm.post_id,
             sm.product_id
    FETCH FIRST 10 ROWS ONLY;
    </copy>
    ```

    Expected output:

    | Momentum | Platform | Creator | Product | Score |
    | --- | --- | --- | --- | ---: |
    | rising | instagram | `@jade_gus` | Reef-Safe Sunscreen SPF30 | 0.85589 |
    | normal | twitter | `@zen_omar` | Reef-Safe Sunscreen SPF30 | 0.81837 |
    | normal | youtube | `@urban_omar` | Reef-Safe Sunscreen SPF30 | 0.81234 |
    | normal | youtube | `@frost_aria` | SPF50 Invisible Sunscreen | 0.81222 |
    | normal | tiktok | `@neon_liam` | Reef-Safe Sunscreen SPF30 | 0.8122 |
    | normal | instagram | `@crystal_maya` | Reclaimed Wood Table | 0.80127 |
    | normal | tiktok | `@nexus_ava` | Reef-Safe Sunscreen SPF30 | 0.79946 |
    | rising | tiktok | customer | Reef-Safe Sunscreen SPF30 | 0.7945 |
    | rising | youtube | `@shadow_jace` | Reef-Safe Sunscreen SPF30 | 0.7945 |
    | normal | youtube | `@haze_pia` | Reusable Beeswax Wraps | 0.79096 |
    {: title="Social Trend Product Matches"}

3. This result ties the page back to the runbook story. The application is not only searching a catalog. It connects demand to creator handles, platforms, momentum, and social posts. The next lab uses the creator network to show how those signals can spread through communities.

## Acknowledgements

* **Author** - Pat Shepherd, Senior Principal Database Product Manager
* **Last Updated By/Date** - Oracle Database Product Management, May 2026
