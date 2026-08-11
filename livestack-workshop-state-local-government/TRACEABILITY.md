# Source Traceability

Estimated Time: **Not applicable**

| Workshop Area | Source | Evidence Type | Notes |
| --- | --- | --- | --- |
| Workshop structure and active arc | `livestack-workshop-finance/workshops/*/manifest.json` | Gold Standard | Mirrors seven technical labs, conclusion, and quiz. |
| Introduction and business trigger | SLED runbook introduction and Scene 1 | Scenario | Uses Colorado, Jessica Chen, and the 2.7%/3.0% early warning with the original limitation language. |
| Lab 1 | SLED Scene 2; `db/schema/10_sled_views.sql` | App and schema | Inventories only objects used by active labs. |
| Lab 2 | SLED Scene 3; `SLED_OPERATIONS_DASHBOARD_V` | App and SQL | Reproduces database-backed operating measures, not the application-configured eligibility rate. |
| Lab 3 | SLED Scene 7; `db/schema/02_json_collections.sql` | App and SQL | Uses `ORDERS_DV` and SLED semantic views for service requests. |
| Lab 4 | SLED Scene 4; `db/schema/04_vector.sql` | App and SQL | Uses `PRODUCT_EMBEDDINGS`, `POST_EMBEDDINGS`, and `ADMIN.ALL_MINILM_L12_V2`. |
| Lab 5 | SLED Scene 5; `db/schema/03_graph.sql` | App and SQL | Uses the real `INFLUENCER_NETWORK` property graph and explains inherited physical names. |
| Lab 6 | SLED Scene 6; `db/schema/05_spatial.sql` | App and SQL | Uses real point, boundary, distance, and capacity objects. Current application evidence explains VPD; the worksheet does not claim to validate VPD. |
| Lab 7 | SLED Scene 8; `db/schema/13_oml_model_lifecycle.sql` | App and SQL | Uses the four active SLED OML model names and training views. |
| Screenshots | SLED selected screenshot capture, 2026-07-03 | Visual | Reused only for active application pages. |
| Getting Started | Finance Gold Standard | LiveLabs pattern | Reuses Reservation Information and SQL Worksheet assets. |
| Excluded scope | SLED Scenes 9 and 10 | Scope decision | The active workshop omits Ask Data, copilot, agent, and trusted-action flows because the stack lacks validated learner evidence for them. |

## Open Validation Items

- Green Button validation needs the platform wallet, service name, and credentials.
- The supporting-files handoff is available at `C:\Users\Teodor C. Nechita\Documents\Supporting Files\State and Local Government`.

## Development ADB Validation

- The deterministic loader completed successfully and passed all 17 summary checks.
- A second load against the same schema completed successfully, confirming cleanup and idempotence.
- All 16 learner SQL blocks passed as `LLUSER` in manifest order.
- Development ADB captures now supply the vector-search, Spatial, JSON Relational Duality, and OML expected outputs.
- No database name, service alias, wallet location, password, or passphrase is retained in this workshop.

## Acknowledgements

- **Author** - Oracle LiveLabs
- **Last Updated By/Date** - Oracle LiveLabs, August 2026
