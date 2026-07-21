-- PREFLIGHT (Lab 1): validates every dependency of Labs 2-8. Read-only.
SELECT 'SQL worksheet connected as ' || USER AS check_1 FROM dual;

SELECT 'ONNX model present: ' ||
       NVL(MAX(model_name), '*** MISSING - tell a proctor ***') AS check_2
FROM   user_mining_models
WHERE  model_name = 'MENU_MODEL';

SELECT 'Application tables: ' || COUNT(*) ||
       ' (expected 0 - you are at the starting line)' AS check_3
FROM   user_tables
WHERE  table_name NOT LIKE 'DM$%'
AND    table_name NOT LIKE 'SYS_%';
