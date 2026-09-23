-- Lab 8: embed the CHAIN CATALOG in place with the in-database ONNX model.
-- The vector lives on item, not on menu_item: what a dish MEANS is a property
-- of the dish, not of which location happens to sell it. One embedding serves
-- all 7,500 stores.
SELECT model_name FROM user_mining_models;

ALTER TABLE item ADD (desc_vec VECTOR(384, FLOAT32));

UPDATE item
SET    desc_vec = VECTOR_EMBEDDING(menu_model
                    USING item_name || ' ' || description AS data);
COMMIT;

-- Semantic search. 'leafy starter' shares NO word with any menu item; the
-- Garden Salad wins on meaning alone (verified live, margin 0.08 cosine).
SELECT item_name, base_price
FROM   item
WHERE  active
ORDER  BY VECTOR_DISTANCE(desc_vec,
         VECTOR_EMBEDDING(menu_model USING 'leafy starter' AS data),
         COSINE)
FETCH FIRST 5 ROWS ONLY;

-- Freshness proof: insert, embed and search in the same breath.
INSERT INTO item (item_id, item_name, description, base_price)
VALUES (1099, 'Brisket Melt',
        'Slow-smoked barbecue brisket, melted swiss, grilled sourdough', 15.49);

UPDATE item
SET    desc_vec = VECTOR_EMBEDDING(menu_model
                    USING item_name || ' ' || description AS data)
WHERE  item_id = 1099;
COMMIT;

SELECT item_name, base_price
FROM   item
WHERE  active
ORDER  BY VECTOR_DISTANCE(desc_vec,
         VECTOR_EMBEDDING(menu_model USING 'smoky barbecue brisket' AS data),
         COSINE)
FETCH FIRST 5 ROWS ONLY;
