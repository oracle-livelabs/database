-- Lab 7 step 1 (belt-and-suspenders): ensure the ONNX embedding model is
-- loaded before Lab 8 needs it. No-op when MENU_MODEL is already present
-- (the provisioned state, confirmed by the preflight).
DECLARE
  cnt NUMBER;
BEGIN
  SELECT COUNT(*) INTO cnt FROM user_mining_models WHERE model_name = 'MENU_MODEL';
  IF cnt = 0 THEN
    DBMS_VECTOR.LOAD_ONNX_MODEL(
      directory  => 'DATA_PUMP_DIR',
      file_name  => 'all_MiniLM_L12_v2.onnx',
      model_name => 'MENU_MODEL');
  END IF;
END;
/
