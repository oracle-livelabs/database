SET SERVEROUTPUT ON
PROMPT Hydrating retail spatial, vector, and semantic artifacts after data load

UPDATE fulfillment_centers
SET location = SDO_GEOMETRY(2001, 4326, SDO_POINT_TYPE(longitude, latitude, NULL), NULL, NULL)
WHERE location IS NULL
  AND latitude IS NOT NULL
  AND longitude IS NOT NULL;

UPDATE customers
SET location = SDO_GEOMETRY(2001, 4326, SDO_POINT_TYPE(longitude, latitude, NULL), NULL, NULL)
WHERE location IS NULL
  AND latitude IS NOT NULL
  AND longitude IS NOT NULL;

COMMIT;

DECLARE
  v_model_count NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_model_count
  FROM user_mining_models
  WHERE model_name = 'ALL_MINILM_L12_V2';

  IF v_model_count = 0 THEN
    DBMS_OUTPUT.PUT_LINE('ALL_MINILM_L12_V2 is not loaded. Load it before running vector hydration.');
  ELSE
    DELETE FROM semantic_matches;
    DELETE FROM product_embeddings;
    DELETE FROM post_embeddings;

    INSERT INTO product_embeddings (product_id, embedding_text, embedding)
    SELECT p.product_id,
           p.product_name || ' ' || p.category || ' ' || NVL(p.subcategory, '') || ' ' || NVL(p.tags, ''),
           VECTOR_EMBEDDING(ALL_MINILM_L12_V2 USING p.product_name || ' ' || p.category || ' ' || NVL(p.subcategory, '') || ' ' || NVL(p.tags, '') AS DATA)
    FROM products p
    WHERE p.is_active = 1;

    INSERT INTO post_embeddings (post_id, embedding_text, embedding)
    SELECT sp.post_id,
           SUBSTR(sp.post_text, 1, 500),
           VECTOR_EMBEDDING(ALL_MINILM_L12_V2 USING SUBSTR(sp.post_text, 1, 500) AS DATA)
    FROM social_posts sp;

    INSERT INTO semantic_matches (post_id, product_id, similarity_score, match_rank, match_method)
    SELECT post_id, product_id, similarity_score, match_rank, 'vector'
    FROM (
      SELECT pe.post_id,
             pre.product_id,
             ROUND(1 - VECTOR_DISTANCE(pe.embedding, pre.embedding, COSINE), 5) AS similarity_score,
             ROW_NUMBER() OVER (PARTITION BY pe.post_id ORDER BY VECTOR_DISTANCE(pe.embedding, pre.embedding, COSINE)) AS match_rank
      FROM post_embeddings pe
      CROSS JOIN product_embeddings pre
    )
    WHERE match_rank <= 3;

    DBMS_OUTPUT.PUT_LINE('Product embeddings, post embeddings, and semantic matches hydrated.');
  END IF;
END;
/

COMMIT;
