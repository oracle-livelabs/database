-- Lab 8 FALLBACK: used only if the embedding model cannot be loaded.
-- Needs no model, runs as written, and demonstrates the gap that motivates
-- vector search.

-- 1. Lab 8's question asked with keywords: 'leafy starter'. ZERO ROWS.
--    Nothing on this menu literally says "leafy" or "starter" - the dish you
--    want says "Crisp greens, heirloom tomato, house vinaigrette".
SELECT item_name, base_price
FROM   item
WHERE  active
AND    (LOWER(item_name || ' ' || description) LIKE '%leafy%'
    OR  LOWER(item_name || ' ' || description) LIKE '%starter%');

-- 2. Loosen the terms to things that DO appear, and you get the wrong shape of
--    answer: everything "crisp" or "fresh", ranked by nothing in particular.
SELECT item_name, base_price
FROM   item
WHERE  active
AND    (LOWER(item_name || ' ' || description) LIKE '%crisp%'
    OR  LOWER(item_name || ' ' || description) LIKE '%green%')
ORDER  BY item_name;

-- Nothing, or an unranked pile. That gap is the whole reason AI Vector Search
-- exists. Ask a proctor to help load the model (Lab 7, Task 1).
