# Validation report: 29 September 2026

### Objectives

- Summarize the completed manual and fresh green-button validation, recorded results, and remaining checks.

Estimated Time: **10 minutes**

**The corrected stack and complete LiveLabs learner path passed in a fresh green-button reservation.** Resource Manager created the Seoul database, extracted and ran the manufacturing loader, populated the expected fresh `LLUSER` schema, and exposed the learner services with the generated reservation credentials. Every published SQL lab, the primary Graph Studio notebook, AutoML, Select AI, the Select AI agent, and the final quiz passed.

## Data model and loader alignment

The single canonical loader creates manufacturing plants, component revisions, customer sites, production orders and lines, inspections, traceability entities, work centers and material transfers. Its 15 tables, 18 foreign keys, four reporting/training views, JSON duality view, SQL property graph and three spatial indexes match the revised labs. The fixture includes 16 plants, 192 components, 1,024 customer sites, 3,739 orders, 4,985 lines and 1,536 inspections. All 15 live table counts and the loader assertions passed; 192 vectors have 384 dimensions. The OML view has 192 rows, evenly split between REVIEW and STABLE.

The earlier manual loader check ran in stages through Database Actions after interrupted sessions. Its completion marker and all assertions were observed. The 29 September green-button run then verified the corrected archive-extraction and SQLcl sequence end to end on a fresh database. Only the optional appendix's Python graph-source spelling changed during the manual walkthrough; executable loader SQL was retained. The optional PGQL graph was then created separately in Graph Studio and loaded with 105 vertices and 114 edges.

See [live-validation.json](live-validation.json), [recorded SQL results](live-sql-results.json), [PGX results](pgx-results.json), and the [schema contract](schema-contract.json). The reproducible [validator](validate.py) separately checks exact loader/fixture equality, relational constraints and arithmetic, manifests, local links, code fences, table and column references, notebook JSON/Python, quiz structure and deployment entry point. Its SQLite checks do not claim Oracle syntax validation.

## Live walkthrough results

| Exercise | Observed result |
| --- | --- |
| Converged dashboard | Baseline bearing query and revised drive-shaft search returned manufacturing results. |
| JSON and duality | JSON insert/update and relational/document projections agreed. Order 900001 and line 990001 were created. |
| Vector search | 192 teaching embeddings populated; component and affected-site searches returned results. |
| SQL property graph | Traceability queries and shared-lot pairs passed. Primary notebook displayed all 9 vertices/12 edges and the shared-lot view's 6 vertices/10 edges. |
| Optional PGX | All 43 paragraphs ran through the final two-hop query after correcting the case-sensitive source option to `pg_pgql`. PageRank, paths, personalized PageRank and hop-distance stages completed. |
| Spatial | Four queries returned region distances and nearest-plant routing results. |
| OML | SQL GLM created and scored 12 rows. AutoML completed with five models. Synthetic same-window labels explain the high scores; this is not a future-quality benchmark. |
| Select AI | SQL generation, execution, refinement and narrative passed after explicit lowercase order-status values were added to prompts. |
| Agent | Approved temporary Llama test succeeded in 32.019 seconds with one SQL tool call. Cohere was restored and verified. |
| Quiz | Refreshed browser run scored 7/7 and displayed the completion badge. |

## Fresh green-button results: 29 September 2026

The fresh fixture contained 16 plants, 192 components, 3,739 production orders, 4,985 order lines, 1,536 quality observations, 105 work centers, and 114 material transfers. The learner account had the expected spatial grant, GENAI profile, and SQL property graph. This is direct evidence that the deployed stack selected the manufacturing loader and completed its bootstrap prerequisites.

| Exercise | Fresh reservation result |
| --- | --- |
| Getting Started | Database Actions opened as `LLUSER`; SQL Worksheet ran successfully. |
| Dashboard | Converged query returned 10 manufacturing rows. |
| JSON and duality | All 14 blocks passed; order 900001 and line 990001 were inserted and updated through the duality view. |
| Vector search | The ADMIN embedding model was available, 192 vectors were populated, and both ranked searches passed. |
| SQL graph | Direct, one-to-four-hop, and shared-entity queries returned the expected manufacturing records. |
| Graph Studio | The supplied notebook imported, compute attached, the table returned 9 entities, and both graph paragraphs rendered; the shared-lot result contained 6 vertices and 10 edges. |
| Spatial | All four queries returned plant geometry, regional distance, and nearest-plant routing results. |
| OML SQL | The GLM was created and 12 rows were scored with `REVIEW` and `STABLE` probabilities. |
| AutoML | The experiment completed with `OML_QUALITY_TRAINING_V`, `REVIEW_LABEL`, `Classification`, and `COMPONENT_ID`. Decision Tree, GLM, Ridge GLM, Neural Network, and Random Forest each reached 1.0000 balanced accuracy. The GLM confusion matrix showed 40.82% REVIEW, 59.18% STABLE, and 0.00% off-diagonal errors. |
| Select AI | All nine blocks passed. SHOWSQL, RUNSQL, and NARRATE returned manufacturing-specific results. |
| Select AI Agent | The team finished `SUCCEEDED` in 108.654 seconds with one SQL tool invocation. The original Cohere model was restored and verified. |
| Final quiz | The fresh authenticated run scored 7/7 and displayed the manufacturing completion badge. |

The detailed machine-readable record is [green-button-results.json](green-button-results.json). The original generated password and protected Terraform outputs are intentionally absent. The fresh reservation used the corrected loader-extraction revision, so the result covers both provisioning and the learner path.

Database Actions displayed a few trailing `Unknown Command` or line-number messages when **Run Script** parsed content after an otherwise successful single statement. The affected statements had already completed and returned their expected rows or object state. No required lab ended with an unresolved Oracle SQL or PL/SQL error. Learners should use **Run Statement** or **Ctrl+Enter** for a single query and reserve **Run Script (F5)** for the PL/SQL and multi-statement blocks that call for it.

The earlier Cohere agent request timed out after 300 seconds and six repeated successful SQL calls. Its history still shows RUNNING with a null end time. That historical row does not establish continued execution. Lab 8 now records the previous model, selects the tested model, and restores it after inspection or a failed request. Its five tasks remain in order; these three additional SQL blocks are the justified executable change.

After the labs, there are 3,740 orders and 4,986 lines, and the teaching vector column exists. Fresh-loader assertions deliberately expect the earlier state and should not be rerun against this occupied schema. The optional destructive agent-reset appendix was not executed.

## Images, structure and residue

All 11 lesson pages were rendered again after screenshot replacement: 69 image references loaded successfully, with no broken images. [Screenshot coverage](screenshots.md) records 43 authentic database captures and six live-application captures with their inline placement. Five generic platform screenshots remain. There are no pending capture markers.

Seven original persona banners have zero changed pixels outside their caption masks; the repeated Nina banner is byte-identical. Captions reflect manufacturing roles and scenarios. The introduction retains its static Redwood-style Jessica/Thomas scene and illustrated five-table ERD; the linked technical SVG and five relationships match the loader contract. OCR covers all 64 raster files. See [image review](image-review.json), [domain audit](domain-audit.json), and [structure comparison](structure-comparison.json).

The source workshop was not a write target. All 116 current source files match the existing source archive byte-for-byte. Eleven existing files differ from the original starting snapshot, including six banners, and one introduction image was added. The cause was not established; this conversion did not write to or restore the source. This distinction remains recorded in [source preservation](source-preservation.json).

Unavoidable platform content includes LiveLabs reservation labels, Oracle property-graph terminology and Graph Studio's built-in BANK_GRAPH, MovieStream and sales-history templates/tags visible in authentic service captures. These are not workshop data or business scenarios.

## Remaining validation

The reservation destroy flow and resource cleanup remain. Local `terraform init` and `terraform validate` were not run. Prior public URL HEAD checks timed out; local links and hosted renderer loading passed. Clipboard contents remain unverified although the copy control was exercised. See the [green-button checklist](green-button-checklist.md).

The target now aligns with the tested reference Terraform sequence. `main.tf`, `output.tf`, and `create_user.sql.tmpl` have identical content; `output.tf` differs only by its final newline. `adb.tf` extracts the domain-specific loader archive before SQLcl runs it, and the target grants `SPATIAL_AUTHOR` before the loader checks it. The remaining target differences are the manufacturing loader contents and the explicit GENAI region/model used by this workshop. Static parity and template-variable checks pass.

## Wording review update, 22 September 2026

The [jargon and antislop review](copy-review.md) updated 20 files while preserving all SQL, notebook code, task headings, and navigation. All 11 pages rendered and the revised quiz passed 7/7. No image writes were made by the wording edit. Ten illustration files changed outside those edits, including eight with changed dimensions. Earlier exact-pixel banner comparisons are historical; see [current image checks](copy-review-image-changes.json) and [fresh OCR](current-image-ocr.json). All 43 authentic database captures remain byte-identical; this follow-up adds six live-application captures.

## Acknowledgements

* **Author** - Matt Kowalik
* **Last Updated By/Date** - Matt Kowalik, September 2026
