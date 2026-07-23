-- Lab 8: AI Vector Search on the SAME item table - embed in place with the
-- in-database ONNX model, search by meaning, and prove same-commit freshness.

SELECT model_name FROM user_mining_models;

ALTER TABLE item ADD (desc_vec VECTOR(384, FLOAT32));

UPDATE item
SET    desc_vec = VECTOR_EMBEDDING(menu_model
                    USING item_name || ' ' || description AS data);
COMMIT;

-- Search by meaning, filtered by a relational predicate in the same statement
SELECT item_name, price
FROM   item
WHERE  active
ORDER  BY VECTOR_DISTANCE(desc_vec,
         VECTOR_EMBEDDING(menu_model USING 'spicy vegetarian noodles' AS data),
         COSINE)
FETCH FIRST 5 ROWS ONLY;

-- FRESHNESS PROOF: insert a brand-new item, embed it in the same transaction,
-- and find it by meaning immediately. No sync window, no backfill job.
INSERT INTO item (item_id, category_id, item_name, description, price, active)
VALUES (2003, 120, 'Vegan Dan Dan Noodles',
        'Hand-pulled noodles, spicy sesame-chili sauce, plant-based, no meat',
        1299, TRUE);

UPDATE item
SET    desc_vec = VECTOR_EMBEDDING(menu_model
                    USING item_name || ' ' || description AS data)
WHERE  item_id = 2003;
COMMIT;

SELECT item_name, price
FROM   item
WHERE  active
ORDER  BY VECTOR_DISTANCE(desc_vec,
         VECTOR_EMBEDDING(menu_model USING 'spicy vegetarian noodles' AS data),
         COSINE)
FETCH FIRST 5 ROWS ONLY;
