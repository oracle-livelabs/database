-- PRODUCT EMBEDDINGS
-- Pre-computed vector embeddings for product descriptions
-- Used to semantically match social post text → products
-- ============================================================
CREATE TABLE product_embeddings (
    embedding_id      NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id        NUMBER NOT NULL REFERENCES products(product_id),
    embedding_model   VARCHAR2(100) DEFAULT 'all_MiniLM_L12_v2',
    embedding_text    CLOB,           -- the text that was embedded
    embedding         VECTOR(384),    -- 384-dim for MiniLM; adjust for your model
    created_at        TIMESTAMP DEFAULT SYSTIMESTAMP,
    CONSTRAINT uq_prod_embed UNIQUE (product_id, embedding_model)
);

-- Vector index for fast approximate nearest neighbor search
CREATE VECTOR INDEX idx_product_vec ON product_embeddings(embedding)
    ORGANIZATION NEIGHBOR PARTITIONS
    WITH DISTANCE COSINE
    WITH TARGET ACCURACY 95;

-- ============================================================
-- SOCIAL POST EMBEDDINGS
-- Embeddings of social post text for semantic similarity
-- ============================================================
CREATE TABLE post_embeddings (
    embedding_id      NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    post_id           NUMBER NOT NULL REFERENCES social_posts(post_id),
    embedding_model   VARCHAR2(100) DEFAULT 'all_MiniLM_L12_v2',
    embedding_text    CLOB,
    embedding         VECTOR(384),
    created_at        TIMESTAMP DEFAULT SYSTIMESTAMP,
    CONSTRAINT uq_post_embed UNIQUE (post_id, embedding_model)
);

CREATE VECTOR INDEX idx_post_vec ON post_embeddings(embedding)
    ORGANIZATION NEIGHBOR PARTITIONS
    WITH DISTANCE COSINE
    WITH TARGET ACCURACY 95;

-- ============================================================
-- SEMANTIC MATCH RESULTS CACHE
-- Stores computed matches between posts and products
-- ============================================================
CREATE TABLE semantic_matches (
    match_id          NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    post_id           NUMBER NOT NULL REFERENCES social_posts(post_id),
    product_id        NUMBER NOT NULL REFERENCES products(product_id),
    similarity_score  NUMBER(6,5),     -- cosine similarity 0-1
    match_rank        NUMBER(4),
    match_method      VARCHAR2(30) DEFAULT 'vector'
                      CHECK (match_method IN ('vector','keyword','hybrid','visual')),
    verified          NUMBER(1) DEFAULT 0,
    created_at        TIMESTAMP DEFAULT SYSTIMESTAMP
);

CREATE INDEX idx_semantic_post    ON semantic_matches(post_id);
CREATE INDEX idx_semantic_product ON semantic_matches(product_id);
CREATE INDEX idx_semantic_score   ON semantic_matches(similarity_score DESC);

-- ============================================================
-- VECTOR SEARCH PROCEDURES
-- ============================================================

-- Find products semantically similar to a social post
CREATE OR REPLACE PROCEDURE find_matching_products (
    p_post_id    IN  NUMBER,
    p_top_k      IN  NUMBER DEFAULT 5,
    p_threshold  IN  NUMBER DEFAULT 0.65
)
AS
    v_post_vector VECTOR(384);
BEGIN
    -- Get the post embedding
    SELECT embedding INTO v_post_vector
    FROM post_embeddings
    WHERE post_id = p_post_id
    FETCH FIRST 1 ROWS ONLY;

    -- Find nearest product embeddings and insert matches
    INSERT INTO semantic_matches (post_id, product_id, similarity_score, match_rank, match_method)
    SELECT p_post_id,
           pe.product_id,
           VECTOR_DISTANCE(v_post_vector, pe.embedding, COSINE) AS sim_score,
           ROW_NUMBER() OVER (ORDER BY VECTOR_DISTANCE(v_post_vector, pe.embedding, COSINE)),
           'vector'
    FROM product_embeddings pe
    WHERE VECTOR_DISTANCE(v_post_vector, pe.embedding, COSINE) <= (1 - p_threshold)
    ORDER BY VECTOR_DISTANCE(v_post_vector, pe.embedding, COSINE)
    FETCH FIRST p_top_k ROWS ONLY;

    COMMIT;
END;
/

-- Batch process: find products for all unprocessed social posts
CREATE OR REPLACE PROCEDURE batch_semantic_match (
    p_batch_size IN NUMBER DEFAULT 100
)
AS
BEGIN
    FOR rec IN (
        SELECT pe.post_id
        FROM post_embeddings pe
        LEFT JOIN semantic_matches sm ON pe.post_id = sm.post_id
        WHERE sm.match_id IS NULL
        FETCH FIRST p_batch_size ROWS ONLY
    ) LOOP
        find_matching_products(rec.post_id);
    END LOOP;
END;
/

-- Core search: accepts a pre-computed embedding (always compilable and runnable)
-- The caller generates the VECTOR via ONNX, OCI AI, Python, etc.
CREATE OR REPLACE FUNCTION search_products_by_vector (
    p_query_vec IN VECTOR,
    p_top_k     IN NUMBER DEFAULT 10
) RETURN SYS_REFCURSOR
AS
    v_results SYS_REFCURSOR;
BEGIN
    OPEN v_results FOR
        SELECT p.product_id,
               p.product_name,
               p.category,
               p.unit_price,
               b.brand_name,
               VECTOR_DISTANCE(pe.embedding, p_query_vec, COSINE) AS similarity
        FROM product_embeddings pe
        JOIN products p ON pe.product_id = p.product_id
        JOIN brands   b ON p.brand_id    = b.brand_id
        ORDER BY VECTOR_DISTANCE(pe.embedding, p_query_vec, COSINE)
        FETCH APPROXIMATE FIRST p_top_k ROWS ONLY;

    RETURN v_results;
END;
/

-- Text convenience wrapper: delegates to search_products_by_vector after generating
-- the query embedding inline. Requires ALL_MINILM_L12_V2 to be loaded (see block above).
-- Until the model is loaded, call search_products_by_vector with a pre-computed VECTOR.
CREATE OR REPLACE FUNCTION search_products_by_text (
    p_query_text IN CLOB,
    p_top_k      IN NUMBER DEFAULT 10
) RETURN SYS_REFCURSOR
AS
    v_query_vec VECTOR(384);
BEGIN
    -- VECTOR_EMBEDDING is SQL-only; use SELECT INTO to cross the PL/SQL boundary
    SELECT VECTOR_EMBEDDING(ALL_MINILM_L12_V2 USING p_query_text AS DATA)
    INTO   v_query_vec
    FROM   dual;

    RETURN search_products_by_vector(v_query_vec, p_top_k);
END;
/

COMMIT;

SELECT 'Vector search objects created' AS status FROM dual;
