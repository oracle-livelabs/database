-- Lab 8 FALLBACK: used only if MENU_MODEL cannot be loaded at all (e.g. the
-- object-storage download is blocked by egress rules on a locked-down tenancy).
--
-- History worth recording: this file used to hold PLACEHOLDERS for precomputed
-- vector literals ('[...384 floats...]') that were never generated, so it was
-- not runnable. Shipping ten 384-float literals inside the guide would also be
-- ~10 KB of unreadable text. This is the honest substitute instead: it needs no
-- model, it runs, and it teaches the contrast directly.
--
-- What you lose: semantic search. What you keep: the ability to finish the lab
-- and to SEE what the embedding was buying you.

-- 1. Task 2's question asked with keywords: 'a vegetarian dish with some heat'.
--    Returns ZERO ROWS. Nothing on this menu literally says "vegetarian" or
--    "heat" - the dish you want says "vegetables" and "fiery".
SELECT item_name, price
FROM   item
WHERE  active
AND    (LOWER(item_name || ' ' || description) LIKE '%vegetarian%'
    OR  LOWER(item_name || ' ' || description) LIKE '%heat%');

-- 2. Loosen the terms. Returns exactly ONE row - Beef Chow Fun - the single
--    dish that is emphatically NOT vegetarian. It matched "noodle"; keyword
--    search cannot know that "wok-seared beef" disqualifies it.
SELECT item_name, price
FROM   item
WHERE  active
AND    (LOWER(item_name || ' ' || description) LIKE '%spicy%'
    OR  LOWER(item_name || ' ' || description) LIKE '%noodle%')
ORDER  BY item_name;

-- That gap - nothing, or noise, with no way to rank by closeness - is the
-- whole reason AI Vector Search exists. Ask a proctor to help get MENU_MODEL
-- loaded (Lab 7, Task 1) so you can run the real thing.
