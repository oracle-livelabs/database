/*
 * 04_vector.sql
 * Vector Search for semantic financial product matching from signal bulletins
 * Oracle 26ai — native VECTOR type and similarity search
 *
 * Embedding model : all_MiniLM_L12_v2 (384 dimensions, cosine)
 * Source          : Oracle OML model repository (OCI Object Storage PAR)
 */

-- ============================================================
-- LOAD EMBEDDING MODEL: ALL_MINILM_L12_V2
-- Reads all_MiniLM_L12_v2.onnx from DATA_PUMP_DIR and registers
-- it as an in-database embedding model for VECTOR_EMBEDDING().
--
-- BEFORE RUNNING: place all_MiniLM_L12_v2.onnx in DATA_PUMP_DIR.
--
--   The ONNX is inside the augmented zip (PAR URL below).
--   Unzip it locally — db/data/onnx/ already contains the file
--   (git-ignored). Upload to DATA_PUMP_DIR via ONE of:
--     A) Database Actions ▶ Data Studio ▶ Files  (browser upload)
--     B) OCI CLI + DBMS_CLOUD.GET_OBJECT if stored in OCI Object Storage
--
--   PAR URL (zip):
--     https://adwc4pm.objectstorage.us-ashburn-1.oci.customer-oci.com/p/TtH6hL2y25EypZ0-rrczRZ1aXp7v1ONbRBfCiT-BDBN8WLKQ3lgyW6RxCfIFLdA6/n/adwc4pm/b/OML-ai-models/o/all_MiniLM_L12_v2_augmented.zip
--
-- Idempotent — skips if the model is already present.
-- Prerequisites (00_setup.sql as ADMIN):
--   GRANT EXECUTE ON DBMS_VECTOR             TO livestack;
--   GRANT READ, WRITE ON DIRECTORY data_pump_dir TO livestack;
-- ============================================================

-- ── Method 1: direct directory load — DBMS_VECTOR (recommended for 23ai) ──
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM   user_mining_models
    WHERE  model_name = 'ALL_MINILM_L12_V2';

    IF v_count > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Model ALL_MINILM_L12_V2 already loaded — skipping.');
        RETURN;
    END IF;

    DBMS_VECTOR.LOAD_ONNX_MODEL(
        directory  => 'DATA_PUMP_DIR',
        file_name  => 'all_MiniLM_L12_v2.onnx',
        model_name => 'ALL_MINILM_L12_V2',
        metadata   => JSON('{"function":"embedding",
                             "embeddingOutput":"embedding",
                             "input":{"input":["DATA"]}}')
    );

    DBMS_OUTPUT.PUT_LINE('Model ALL_MINILM_L12_V2 loaded successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error loading model: ' || SQLERRM);
        RAISE;
END;
/

/*
-- ── Method 2: BFILE → BLOB — DBMS_DATA_MINING (alternate per Oracle docs) ──
-- Use when DBMS_VECTOR.LOAD_ONNX_MODEL is unavailable.
-- Ref: Oracle AI Vector Search User's Guide, end-to-end example.
DECLARE
    v_count   NUMBER;
    m_blob    BLOB DEFAULT EMPTY_BLOB();
    m_src_loc BFILE;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM   user_mining_models
    WHERE  model_name = 'ALL_MINILM_L12_V2';

    IF v_count > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Model ALL_MINILM_L12_V2 already loaded — skipping.');
        RETURN;
    END IF;

    DBMS_LOB.createtemporary(m_blob, FALSE);
    m_src_loc := BFILENAME('DATA_PUMP_DIR', 'all_MiniLM_L12_v2.onnx');
    DBMS_LOB.fileopen(m_src_loc, DBMS_LOB.file_readonly);
    DBMS_LOB.loadfromfile(m_blob, m_src_loc, DBMS_LOB.getlength(m_src_loc));
    DBMS_LOB.CLOSE(m_src_loc);

    DBMS_DATA_MINING.import_onnx_model(
        model_name => 'ALL_MINILM_L12_V2',
        model_data => m_blob,
        metadata   => JSON('{"function":"embedding",
                             "embeddingOutput":"embedding",
                             "input":{"input":["DATA"]}}')
    );

    DBMS_LOB.freetemporary(m_blob);
    DBMS_OUTPUT.PUT_LINE('Model ALL_MINILM_L12_V2 loaded successfully.');
EXCEPTION
    WHEN OTHERS THEN
        IF m_blob IS NOT NULL THEN DBMS_LOB.freetemporary(m_blob); END IF;
        DBMS_OUTPUT.PUT_LINE('Error loading model: ' || SQLERRM);
        RAISE;
END;
/
*/

-- ============================================================
-- PRODUCT EMBEDDINGS compatibility marker: products are financial products in this demo
-- MATERIAL EMBEDDINGS
-- Pre-computed vector embeddings for financial product descriptions
-- Used to semantically match signal bulletin text -> financial products
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
-- SIGNAL BULLETIN EMBEDDINGS
-- Embeddings of signal bulletin text for semantic similarity
-- ============================================================
CREATE TABLE signal_embeddings (
    embedding_id      NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    post_id           NUMBER NOT NULL REFERENCES social_posts(post_id),
    embedding_model   VARCHAR2(100) DEFAULT 'all_MiniLM_L12_v2',
    embedding_text    CLOB,
    embedding         VECTOR(384),
    created_at        TIMESTAMP DEFAULT SYSTIMESTAMP,
    CONSTRAINT uq_post_embed UNIQUE (post_id, embedding_model)
);

CREATE VECTOR INDEX idx_post_vec ON signal_embeddings(embedding)
    ORGANIZATION NEIGHBOR PARTITIONS
    WITH DISTANCE COSINE
    WITH TARGET ACCURACY 95;

-- ============================================================
-- SEMANTIC MATCH RESULTS CACHE
-- Stores computed matches between signal bulletins and financial products
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

-- Find financial products semantically similar to a signal bulletin
CREATE OR REPLACE PROCEDURE find_matching_products (
    p_post_id    IN  NUMBER,
    p_top_k      IN  NUMBER DEFAULT 5,
    p_threshold  IN  NUMBER DEFAULT 0.65
)
AS
    v_post_vector VECTOR(384);
BEGIN
    -- Get the signal bulletin embedding
    SELECT embedding INTO v_post_vector
    FROM signal_embeddings
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

-- Batch process: find financial products for all unprocessed signal bulletins
CREATE OR REPLACE PROCEDURE batch_semantic_match (
    p_batch_size IN NUMBER DEFAULT 100
)
AS
BEGIN
    FOR rec IN (
        SELECT pe.post_id
        FROM signal_embeddings pe
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
