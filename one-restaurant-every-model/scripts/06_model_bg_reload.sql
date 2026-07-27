-- Lab 7 Task 1: make sure the in-database embedding model is present.
--
-- Idempotent and self-sufficient: if MENU_MODEL already exists (some
-- environments pre-load it), this is a no-op. Otherwise it downloads Oracle's
-- augmented MiniLM ONNX model straight into the database and loads it — no
-- laptop download, no embedding service, no API key.
--
-- Validated live on Autonomous AI Database (~1 minute end to end).
-- Run it here in Lab 7 so the model is warm by the time Lab 8 needs it.

SET SERVEROUTPUT ON

DECLARE
  model_count NUMBER;
BEGIN
  SELECT COUNT(*) INTO model_count
  FROM   user_mining_models
  WHERE  model_name = 'MENU_MODEL';

  IF model_count > 0 THEN
    DBMS_OUTPUT.PUT_LINE('MENU_MODEL already present - nothing to do.');
  ELSE
    -- 1. Pull the model file into the database's own directory object.
    DBMS_CLOUD.GET_OBJECT(
      object_uri     => 'https://adwc4pm.objectstorage.us-ashburn-1.oci.customer-oci.com/p/eLddQappgBJ7jNi6Guz9m9LOtYe2u8LWY19GfgU8flFK4N9YgP4kTlrE9Px3pE12/n/adwc4pm/b/OML-Resources/o/all_MiniLM_L12_v2.onnx',
      directory_name => 'DATA_PUMP_DIR',
      file_name      => 'all_MiniLM_L12_v2.onnx');

    -- 2. Load it as an in-database model named MENU_MODEL.
    DBMS_VECTOR.LOAD_ONNX_MODEL(
      directory  => 'DATA_PUMP_DIR',
      file_name  => 'all_MiniLM_L12_v2.onnx',
      model_name => 'MENU_MODEL');

    DBMS_OUTPUT.PUT_LINE('MENU_MODEL loaded.');
  END IF;
END;
/

-- STATE CHECK: expect one row, MENU_MODEL
SELECT model_name, algorithm, mining_function
FROM   user_mining_models
WHERE  model_name = 'MENU_MODEL';
