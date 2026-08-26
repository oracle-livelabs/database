-- PREFLIGHT (Lab 1): validates every dependency of Labs 2-8. Read-only.
SELECT 'SQL worksheet connected as ' || USER AS check_1 FROM dual;

SELECT 'Embedding model: ' ||
       NVL(MAX(model_name), 'not loaded yet - Lab 7 loads it') AS check_2
FROM   user_mining_models
WHERE  model_name = 'MENU_MODEL';

-- Informational, not an assertion: some sandboxes hand out a schema that
-- already holds objects. Labs 4-8 create their own tables with DROP ... IF
-- EXISTS guards, so a non-zero count here is not a problem.
SELECT 'Workshop tables already present: ' || COUNT(*) ||
       ' of 8 (a fresh schema shows 0)' AS check_3
FROM   user_tables
WHERE  table_name IN ('STORE','MENU','CATEGORY','ITEM','MENU_ITEM','EXTRA',
                      'ITEM_OPTION','ITEM_SPECIAL_HOURS');
