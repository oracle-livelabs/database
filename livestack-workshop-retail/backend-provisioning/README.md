# Retail LiveStack Backend Provisioning

This bundle provisions the database objects used by the retail LiveLabs workshop.

Estimated Time: 20 minutes

## Target schema

Recommended schema owner: `RETAILDB`

The schema is intentionally separate from other workshop schemas so retail testing does not overwrite unrelated tables.

## Execution order

Run the scripts from `backend-provisioning/database-source`:

1. Connect as `ADMIN` and run `@run_as_admin.sql`.
2. Upload `all_MiniLM_L12_v2.onnx` to `DATA_PUMP_DIR` if the model is not already loaded for `RETAILDB`.
3. Connect as `RETAILDB` and run `@run_as_retaildb_core.sql`.
4. Reconnect as `ADMIN` and run `@run_as_admin_security.sql`.
5. Reconnect as `RETAILDB` and run `@run_as_retaildb_finish.sql`.

Do not copy wallet files, private keys, OCIDs, or environment-specific credentials into this workshop. Replace the placeholder schema password in `run_as_admin.sql` before an instructor-run provisioning pass if your environment requires a different password.

## Acknowledgements

* **Author** - Oracle LiveLabs
* **Last Updated By/Date** - Oracle Database Product Management, May 2026
