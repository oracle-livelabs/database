# Traceability

Estimated Time: X

Use this file to track source material and claims used in the workshop.

| Workshop Area | Source | Notes |
| --- | --- | --- |
| Original lab count and sequence | `https://livelabs.oracle.com/ords/r/dbpm/livelabs/run-workshop?p210_wid=4291&p210_wec=&session=101926249610768` and embedded manifest at `https://theinmemoryguy.github.io/pts/ai-vector-search-fundamentals/workshops/tenancy/manifest.json` | Source workshop has nine labs after Get Started: create ADB, create users/data, introduction, embeddings, exhaustive search, approximate search, image search, APEX demo, and RAG. |
| Autonomous AI Vector Database overview, provisioning, users, console, Python SDK, model/table/data/search/index operations | `using-oracle-autonomous-ai-vector-database.pdf` | Used as the main product documentation source. |
| Python SDK methods and REST endpoint naming | `oracle-vecdb-api-ref-1.0.0b2.zip` | Used for method names including `OracleVecDB`, `Configuration`, `list_models`, `create_vector_table`, `upsert_vectors`, `query`, `create_index`, and `rerank`. |
| Sample data | New workshop authoring | The workshop includes small synthetic records, so it does not depend on source National Parks or APEX assets. |
| Technical validation gap | Local environment | This Codex session did not include `oracle-db-skills`. I checked technical language against the provided PDF and SDK reference. |

## Acknowledgements

* **Author** - Oracle LiveLabs workshop authoring team
* **Last Updated By/Date** - Codex, May 28, 2026
