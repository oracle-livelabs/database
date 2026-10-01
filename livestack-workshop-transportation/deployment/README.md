# Seer Transport passenger workshop loader

Run `load_seer_transport.sql` once in a fresh workshop schema. The script creates the passenger transportation tables, views, duality view, property graph, and deterministic sample data used by Labs 1–6. It does not drop or overwrite existing objects; a second run will stop on the first existing table.

Before loading, provision the learner schema with `CREATE SESSION`, `CREATE TABLE`, `CREATE VIEW`, `CREATE PROPERTY GRAPH`, `CREATE MINING MODEL`, a data tablespace quota, and `SELECT` on mining model `ADMIN.ALL_MINILM_L12_V2`. The ADMIN grant syntax is:

```sql
GRANT SELECT ON MINING MODEL ADMIN.ALL_MINILM_L12_V2 TO <LEARNER_SCHEMA>;
```

The workshop's Select AI and Agent labs additionally require a working `GENAI` profile for the learner schema and the provider's required credentials and OCI permissions. Those are environment configuration, not embedded in this data loader.

The lab flow adds `TRANSPORT_SERVICES.SERVICE_EMBEDDING` and creates OML models and agent objects as hands-on steps. The loader seeds `SERVICE_EMBEDDINGS` separately for Lab 1, which runs before the vector lab.
