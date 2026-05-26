# Retail LiveStack Backend Provisioning

This bundle provisions the database objects and fixed sample data used by the retail LiveLabs workshop.

Estimated Time: 20 minutes

## Target schema

Recommended schema owner: `LLUSER` for LiveLabs Sandbox reservations. The exact-data setup also supports `RETAILDB` when a local environment uses that schema name.

The schema is intentionally separate from other workshop schemas so retail testing does not overwrite unrelated tables.

## Canonical compact learner setup

Run the setup from `backend-provisioning/database-source`:

1. Connect as `ADMIN`.
2. Substitute the `${user_password}` placeholder in `retail_workshop_admin_create_lab_seed.sql` with the workshop schema password required by the target environment.
3. Run `@retail_workshop_admin_create_lab_seed.sql`.
4. Connect as the workshop schema user, usually `LLUSER`, and run `@verify_retail_workshop_ready.sql` if you want an explicit readiness check.

This compact learner script is the workshop source of truth for learner builds. It creates the schema, database objects, policies, tools, and fixed INSERT data in one repeatable pass. It keeps the rows needed to reproduce the lab output tables, omits unused post embedding row payloads, and keeps only the semantic-match rows shown in the MiniLM lab.

Use `retail_workshop_admin_create_all_exact_data.sql` only when you need the full exported demo-application dataset for app-parity testing. Do not use the legacy staged loader path for learner builds because it calls random data loaders and can produce values that do not match the lab markdown.

Do not copy wallet files, private keys, OCIDs, or environment-specific credentials into this workshop. Keep passwords as runtime substitutions only.

## Legacy staged scripts

The older staged files are retained only as source references while the compact learner setup is reviewed. `run_as_retaildb_core.sql` is intentionally blocked because it invokes the legacy random data loader.

## Acknowledgements

* **Author** - Pat Shepherd, Senior Principal Database Product Manager
* **Last Updated By/Date** - Oracle Database Product Management, May 2026
