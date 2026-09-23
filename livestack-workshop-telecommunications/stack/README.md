# SEER Telecomms stack handoff

This directory packages the workshop loader with the original provisioning templates. The canonical Oracle statements and learner flows were tested in a manually provisioned database; see manual results in the full workshop (`validation/manual-results.md`). The SQLcl launch step was not exercised. Terraform and LiveLabs green-button validation have not been run.

## Main loader

Use [load_data/telecommunications-platform-handoff-loader.sql](load_data/telecommunications-platform-handoff-loader.sql). It is the only editable loader copy in this target. The full workshop ZIP and stack ZIP contain this same file; compare its SHA-256 with the release manifest after packaging.

The loader accepts the same two positional arguments: the LLUSER password and the database service alias. It starts as ADMIN, verifies prerequisites, grants the required privileges, connects as LLUSER, and rejects an occupied workshop schema before creating business tables. It preserves existing data instead of dropping tables. DDL commits implicitly; a failed first run may leave a partial schema, so resolve the cause and use a new workshop schema for a full rerun.

## Manual-database run sequence

1. Obtain a fresh Autonomous Database 26ai and authorize its use for this workshop. Keep its credentials outside this repository.
2. Prepare LLUSER, Database Actions, the embedding model, GENAI provider credentials, and grants using the supplied templates or equivalent administrator steps. Templates are parameterized inputs, not SQL files to execute unchanged.
3. In Database Actions user management, assign SPATIAL_AUTHOR to LLUSER. The loader verifies this role; the supplied create-user template does not assign it. Verify Graph Studio, Spatial and OML services are available.
4. Verify ADMIN owns a valid ALL_MINILM_L12_V2 embedding model and GENAI is enabled for LLUSER. Choose a provider model and region that support inference at execution time. Check access to the external model-download URL in the setup template; the model download succeeded on 23 September 2026; verify it again during provisioning.
5. In an ADMIN SQLcl session connected to the approved database, run the loader with its two arguments. Use the same wallet and service alias as that session. Avoid saving passwords in shell history or a committed script.
6. Require the final `SEER_TELECOMMS_HANDOFF_LOADER_COMPLETE` marker and review all assertion output. Compare the counts with the schema contract in the full workshop (`validation/schema-contract.md`).
7. Run the labs as LLUSER in manifest order. Lab 2 uses reserved order 900001 and line 990001; Lab 3 adds the teaching vector column. The loader prepares GENAI_AGENT for reasoning, but deliberately leaves learner-owned model, collection, scoring and agent objects to the labs. GENAI_AGENT inherits the OCI credential and compartment from GENAI and uses the tested Meta reasoning model in us-chicago-1.
8. For the optional airtime notebook, run the commented PGQL graph definition at the end of the loader in a Graph Studio `%pgql-rdbms` paragraph. The main SQL loader creates ACTIVATION_FRAUD_NETWORK, but does not create AIRTIME_GRAPH. Verify `PREPAID_ACCOUNTS(934)` and other vertex IDs before PGX algorithms run.
9. When retesting, refresh the inline screenshots and update the screenshot inventory in the full workshop (`validation/screenshot-inventory.json`). Do not replace markers with simulated database screens.

## Deployment references and boundaries

`adb.tf` points to the telecom loader filename. That path is the only domain-driven change to the inherited Terraform/templates. Provider credentials, user creation, tenancy mappings, outputs, and infrastructure settings retain their original flow. Static review is not a Terraform plan, apply, or provisioning test.

The next green-button phase must verify user/grant setup, the spatial-role prerequisite, model download, provider regional availability, wallet/SQLcl arguments, generated template ordering, loader completion, Terraform outputs, and sandbox/tenancy launch behavior. Do not treat a manual SQL run as proof that provisioning works.
