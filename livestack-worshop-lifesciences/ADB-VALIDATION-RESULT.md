# ADB Validation Result - Life Sciences Workshop

Estimated Time: 5 minutes

Generated: 2026-07-27

## Target

- Database: `LM38HD1DQ8ZMCGVB`
- Service alias used: `lm38hd1dq8zmcgvb_low`
- Learner schema: `LLUSER`
- Validation mode: ADB runtime validation with the supplied wallet and credentials.

No passwords, wallet contents, or local wallet paths are stored in this report.

## Database Preparation

- Confirmed ADB network connectivity on port 1522.
- Confirmed `ADMIN` and `LLUSER` connectivity.
- Granted `LLUSER` access to `ADMIN.ALL_MINILM_L12_V2`.
- Reset and reloaded active Life Sciences source data from the current stack.
- Refreshed active lab objects:
  - `ORDERS_DV`
  - `PRODUCTS_INVENTORY_DV`
  - `POST_EMBEDDINGS`
  - `PRODUCT_EMBEDDINGS`
  - `LS_*_V` semantic views
  - OML training views
  - OML mining models

## Active Object Status

Invalid objects after refresh: `0`

Validated active object families:

| Object family | Result |
| --- | --- |
| Life Sciences semantic views | Valid |
| JSON Relational Duality views | Valid |
| Property graph | Valid |
| Vector embedding tables | Valid |
| OML training views and models | Valid |

## Validated Row Counts

| Data group | Rows |
| --- | ---: |
| Manufacturers | 50 |
| Regulated products | 79 |
| Clinical supply orders | 3000 |
| Clinical supply order items | 8966 |
| Quality signals | 5000 |
| Product embeddings | 79 |
| Signal embeddings | 5000 |
| Trial sites | 2000 |
| Cold-chain sites | 30 |
| Supply capacity rows | 781 |
| Cold-chain routes | 1500 |

## Learner SQL Validation

Extracted learner copy blocks: `18`

Runtime result: `18 passed, 0 failed`

Validated examples include:

| Lab area | Representative validated output |
| --- | --- |
| JSON duality | `ORDERS_DV` returned order document `_id = 1` with status `confirmed`. |
| Spatial | Nearest pair returned `Site LasVegas-1211` to `North Las Vegas West Storage Site` at `0.2` miles. |
| Foundation | Semantic views returned `10`; JSON duality views returned `2`. |
| OML | `DEMAND_SURGE_MODEL` scored `mRNA LNP Clinical Batch` as `WATCH` with confidence `0.6552`. |
| Dashboard | KPI query returned `5000` total signals and `480` high-review signals. |
| Vector search | Product query returned `Temperature Excursion Triage Kit` with similarity `0.5281`. |
| Graph | Source reach query returned `@recall_desk` from `@fda_lab`; manufacturer query returned `@inspection_queue` for `VitaCore Therapeutics`. |

## Platform Handoff Loader

Loader file: `lifesciences-platform-handoff-loader.sql`

The loader is a single SQLcl-runnable handoff script. It accepts the learner schema password as `&1` and the service alias as `&2`.

No password, wallet path, wallet passphrase, or database-specific connection string is embedded in the file.

Validation results:

| Check | Result |
| --- | --- |
| Static loader scan | Passed; no hard-coded credentials, wallet paths, service aliases, `DBMS_RANDOM`, or vector dimension shortcuts found. |
| Runtime loader execution | Passed; loader rebuilt `LLUSER` active workshop objects and data in ADB. |
| Active object inventory after loader | Passed; invalid objects after loader run: `0`. |
| Learner SQL against loader-built schema | Passed; `18` extracted copy blocks passed, `0` failed. |

## Notes

- Embedding similarity and OML confidence values can vary when the embedding model or model training inputs change.
- SQLcl was available locally, but the desktop shell raised a SQLcl console I/O exception before executing the script. Runtime loader validation used Python `oracledb` against the same ADB wallet and service.
- The source stack general data scripts still contain non-deterministic generation patterns such as `DBMS_RANDOM` and date functions. The platform handoff loader replaces those patterns with deterministic data and generated embeddings from fixed text inputs for Green Button publication.

## Acknowledgements

- Oracle LiveLabs
- Oracle Database 23ai
- Oracle Autonomous Database
