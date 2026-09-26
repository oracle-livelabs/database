# SEER Telecomms stack handoff

This directory contains the workshop loader and database setup templates.

## Main loader

Use [load_data/telecommunications-platform-handoff-loader.sql](load_data/telecommunications-platform-handoff-loader.sql). It is the only editable loader copy in this target. 

The loader accepts the same two positional arguments: the LLUSER password and the database service alias. It starts as ADMIN, verifies prerequisites, grants the required privileges, connects as LLUSER, and rejects an occupied workshop schema before creating business tables. It preserves existing data instead of dropping tables. DDL commits implicitly; a failed first run may leave a partial schema, so resolve the cause and use a new workshop schema for a full rerun.

## Manual-database run sequence

1. Obtain a fresh Autonomous Database 26ai and authorize its use for this workshop. Keep its credentials outside this repository.
2. Prepare LLUSER, Database Actions, the embedding model, GENAI provider credentials, and grants using the supplied templates or equivalent administrator steps. Templates are parameterized inputs, not SQL files to execute unchanged.
3. In Database Actions user management, assign SPATIAL_AUTHOR to LLUSER. The loader verifies this role; the supplied create-user template does not assign it. Verify Graph Studio, Spatial and OML services are available.
4. Verify ADMIN owns a valid ALL_MINILM_L12_V2 embedding model and GENAI is enabled for LLUSER. Choose a provider model and region that support inference at execution time. Check access to the external model-download URL in the setup template; verify it during provisioning.
5. In an ADMIN SQLcl session connected to the approved database, run the loader with its two arguments. Use the same wallet and service alias as that session. Avoid saving passwords in shell history or a committed script.
6. Require the final `SEER_TELECOMMS_HANDOFF_LOADER_COMPLETE` marker and review all assertion output. Compare the counts with the [tables and sample data](../reference/tables-and-sample-data.md).
7. Run the labs as LLUSER in manifest order. Lab 2 uses reserved order 900001 and line 990001; Lab 3 adds the teaching vector column. The loader prepares GENAI_AGENT for reasoning, but deliberately leaves learner-owned model, collection, scoring and agent objects to the labs. GENAI_AGENT inherits the OCI credential and compartment from GENAI and uses the tested Meta reasoning model in us-chicago-1.
8. For the optional airtime notebook, run the commented PGQL graph definition at the end of the loader in a Graph Studio `%pgql-rdbms` paragraph. The main SQL loader creates ACTIVATION_FRAUD_NETWORK, but does not create AIRTIME_GRAPH. Verify `PREPAID_ACCOUNTS(934)` and other vertex IDs before PGX algorithms run.
